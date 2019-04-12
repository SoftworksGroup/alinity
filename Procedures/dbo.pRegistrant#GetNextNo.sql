SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#GetNextNo
	@Mode					 varchar(25) = 'APPLICANT'	-- or 'REGISTRANT' defines whether to check for applicant sequence (see comments)
 ,@RegistrantSID int = null									-- key of registrant new number will be assigned to (NULL for applicants)
 ,@RegistrantNo	 varchar(50) output					-- the next registrant number to assign to the dbo.Registrant record
as
/*********************************************************************************************************************************
Sproc    : Registrant - Get Next No
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns the next application or registration number from the sequence to assign to the Registrant
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Aug 2018		|	Initial version

Comments	
--------
This procedure is called from pRegistrant#Insert and pRegistration#Insert. It reads configuration values to return either then 
next application number or registration number from a database sequence.  There are 2 modes:

APPLICANT - called from pRegistrant#Insert when a new registrant is being created. Registrants are added as applicants and the 
procedure checks the configuration to see if a separate application sequence is being used. If a separate application sequence is 
not being used then the next number is taken from the general Registrant sequence.  The format of the value returned - which may 
include prefix and suffix values around the number, is returned based on a template string also read from configuration (parameter).

REGISTRANT - called from pRegistration#Insert when the member is being assigned their first active-practice registration. The
procedure checks if a separate application sequence is configured and if so they would have received an applicant number which
must now be replaced by the next number from the registration sequence. A template is read from the configuration to format
prefix and suffix values to return in the new number.  In this scenario, the previous registration number should be passed in
so that this procedure can record it as an alternate identifier for the registrant (in dbo.RegistrantIdentifier).

Note that it is possible for applicant and registrant numbers to be set manually on the pass into the caller.  This would
occur, for example, as historical data is being converted. If a registrant# has already been provided to the calling 
procedure this routine is not executed.

In addition to reading a template to format prefix and/or suffix values for the new number, the procedure also reads the
minimum value to assign for the sequence. If this value is greater than the current value, the procedure modifies the 
sequence to reset to the new minimum.  This allows control of the sequence to be managed through configuration values
completely without requiring the help desk.

Example
-------
-- NOTE: even with "ROLLBACK" these tests use up next sequence number values!

<TestHarness>
  <Test Name = "Applicant" IsDefault ="true" Description="Executes the procedure to return a number for a new applicant.">
    <SQLScript>
      <![CDATA[     
declare @registrantNo varchar(50);

begin transaction;

exec dbo.pRegistrant#GetNextNo
	@Mode = 'APPLICANT'
 ,@RegistrantNo = @registrantNo output;

select @registrantNo RegistrantNo ;
rollback;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "Registrant" Description="Executes the procedure to return a number for an applicant transition to 
        first-active registration.">
    <SQLScript>
      <![CDATA[
declare
	@registrantSID int
 ,@registrantNo	 varchar(50);

select top(1)
	@registrantSID = reg.RegistrantSID
from
	dbo.[fRegistrant#LatestRegistration$SID](-1, null) rlr
join
	dbo.Registration																	 reg on rlr.RegistrationSID						 = reg.RegistrationSID
join
	dbo.PracticeRegisterSection												 prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister															 pr on pr.IsDefault										 = 1
order by
	newid()

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrant#GetNextNo
		@Mode = 'REGISTRANT'
	 ,@RegistrantSID = @registrantSID
	 ,@RegistrantNo = @registrantNo output;

	select @registrantNo RegistrantNo ;
	rollback;
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	 @ObjectName = 'dbo.pRegistrant#GetNextNo'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo							int						= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)												-- message text (for business rule errors)
	 ,@tranCount						int						= @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName						nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@xState								int																		-- error state detected in catch block
	 ,@applicantNoTemplate	varchar(50)														-- config-param value defining format of applicant number
	 ,@registrantNoTemplate varchar(50)														-- config-param value defining format of registrant number
	 ,@applicantNoMinimum		bigint																-- config-param value defining minimum applicant number
	 ,@registrantNoMinimum	bigint																-- config-param value defining minimum registrant number
	 ,@registrantSeqNo			bigint																-- next value from the sequence
	 ,@templateDigits				smallint			= 0											-- count of digits in the selected template
	 ,@i										int						= 1											-- string position counter
	 ,@identifierTypeSID		int																		-- key of S!APPLICANT identifier type for tracking previous application#
	 ,@applicantNo					varchar(50)														-- previous application number to record to identifier table
	 ,@alterSeq							nvarchar(1000);												-- buffer for dynamic SQL to alter sequence next values and minimum values

	set @RegistrantNo = @RegistrantNo; -- ensure output parameters initialized in all code paths (for code analysis)

	begin try

		-- use a transaction to allow recovery by the caller if required

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

		-- validate parameters

		if @Mode = 'REGISTRANT' -- for registrant mode the previous value of the registrant# is required
		begin

			select
				@applicantNo = r.RegistrantNo
			from
				dbo.Registrant r
			where
				r.RegistrantSID = @RegistrantSID;

			if @applicantNo is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Registrant'
				 ,@Arg2 = @RegistrantSID;

				raiserror(@errorText, 18, 1);
			end;

		end;

		-- check if a separate applicant sequence is 
		-- applied in this configuration

		set @applicantNoTemplate = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ApplicantNoTemplate'), '[NONE]'))) as varchar(50));

		if @Mode = 'APPLICANT' and @applicantNoTemplate not in ('[NONE]', 'NONE') -- new registrant record inserted requiring application#
		begin

			set @i = 1
			set @templateDigits = 0

			while charindex('#', @applicantNoTemplate, @i) > 0 and @i <= len(@applicantNoTemplate) -- validate the template for minimum digits
			begin
				set @i = charindex('#', @applicantNoTemplate, @i)
				set @templateDigits += 1
				set @i += 1;
			end;

			if @templateDigits = 0 or @templateDigits < 4
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SeqTemplateInvalid'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" template is invalid.  A %2 of %3 "#" symbols are required. (Ensure starting value is compatible.)'
				 ,@Arg1 = 'Applicant Number'
				 ,@Arg2 = 'minimum'
				 ,@Arg3 = '4';

				raiserror(@errorText, 17, 1);

			end;

			select @registrantSeqNo	 = next value for dbo.sApplicant; -- get next value from the sequence

			set @applicantNoMinimum = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ApplicantNoMinimum'), '1001'))) as bigint); -- if next value is too low, update the sequence

			if @registrantSeqNo < @applicantNoMinimum
			begin

				set @alterSeq =
					N'alter sequence dbo.sApplicant' + N' restart with ' + ltrim(@applicantNoMinimum) + N'	increment by 1' + N' minvalue ' + ltrim(@applicantNoMinimum)
					+ N' maxvalue 9999999' + N'	no cache' ;

				exec sp_executesql @stmt = @alterSeq;
				select @registrantSeqNo	 = next value for dbo.sApplicant; -- obtain next value to verify revised sequence settings 

			end;

			if len(ltrim(@registrantSeqNo)) < @templateDigits -- validate that template format is compatible with sequence range
			begin

				set @i = len(ltrim(@registrantSeqNo));

				exec sf.pMessage#Get
					@MessageSCD = 'SeqTemplateInvalid'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" template is invalid.  A %2 of %3 "#" symbols are required. (Ensure starting value is compatible.)'
				 ,@Arg1 = 'Applicant Number'
				 ,@Arg2 = 'maximum'
				 ,@Arg3 = @i;

				raiserror(@errorText, 17, 1);

			end;

			set @RegistrantNo = replace(@applicantNoTemplate, replicate('#', @templateDigits), ltrim(@registrantSeqNo)); -- finally return the next applicant number

		end;
		else
		begin

			-- if a registrant no is requested but no separate applicant sequence is 
			-- defined, then the- number assigned initially continues to be used

			if @Mode = 'REGISTRANT' and @applicantNoTemplate in ('[NONE]', 'NONE')
			begin
				set @RegistrantNo = @applicantNo; -- return previously assigned #
			end;
			else
			begin

				-- if the mode is to return a new number for the 1st-active registration, 
				-- then the previous number will be stored to identifiers 

				if @Mode = 'REGISTRANT' and not exists -- ensure this identifier does not already exist for the registrant
				(
					select
						1
					from
						dbo.RegistrantIdentifier ri
					where
						ri.RegistrantSID = @RegistrantSID
				)
				begin

					select
						@identifierTypeSID = it.IdentifierTypeSID
					from
						dbo.IdentifierType it
					where
						it.IdentifierCode = 'S!APPLICANT';	-- applicant type is inserted via pSetup

					if @identifierTypeSID is null
					begin

						exec sf.pMessage#Get
							@MessageSCD = 'RecordNotConfigured'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
						 ,@Arg1 = '"Applicant Identifier Type"';

						raiserror(@errorText, 17, 1);
					end;

					exec dbo.pRegistrantIdentifier#Insert -- add the identifier
						@RegistrantSID = @RegistrantSID
					 ,@IdentifierValue = @applicantNo
					 ,@IdentifierTypeSID = @identifierTypeSID;

				end;

				-- a new registrant# is required either to assign to the new applicant 
				-- (no separate sequence) or for 1st-active-practice registration

				set @registrantNoTemplate = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('RegistrantNoTemplate'), '####'))) as varchar(50)); -- read formatting template from configuration
				set @i = 1
				set @templateDigits = 0

				while charindex('#', @registrantNoTemplate, @i) > 0 and @i <= len(@registrantNoTemplate) -- validate the template for minimum digits
				begin
					set @i = charindex('#', @registrantNoTemplate, @i)
					set @templateDigits += 1
					set @i += 1;
				end;

				if @templateDigits = 0 or @templateDigits < 4
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'SeqTemplateInvalid'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The "%1" template is invalid.  A %2 of %3 "#" symbols are required. (Ensure starting value is compatible.)'
					 ,@Arg1 = 'Registrant Number'
					 ,@Arg2 = 'minimum'
					 ,@Arg3 = '4';

					raiserror(@errorText, 17, 1);

				end;

				select @registrantSeqNo	 = next value for dbo.sRegistrant;	-- get next value from the sequence

				set @registrantNoMinimum = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('RegistrantNoMinimum'), '1001'))) as bigint); -- if next value is too low, update the sequence

				if @registrantSeqNo < @registrantNoMinimum
				begin

					set @alterSeq =
						N'alter sequence dbo.sRegistrant' + N' restart with ' + ltrim(@registrantNoMinimum) + N'	increment by 1' + N' minvalue '
						+ ltrim(@registrantNoMinimum) + N' maxvalue 9999999' + N'	no cache';

					exec sp_executesql @stmt = @alterSeq;
					select @registrantSeqNo	 = next value for dbo.sRegistrant;	-- obtain next value to verify revised sequence settings 

				end;

				if len(ltrim(@registrantSeqNo)) < @templateDigits -- validate that template format is compatible with sequence range
				begin

					set @i = len(ltrim(@registrantSeqNo));

					exec sf.pMessage#Get
						@MessageSCD = 'SeqTemplateInvalid'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The "%1" template is invalid.  A %2 of %3 "#" symbols are required. (Ensure starting value is compatible.)'
					 ,@Arg1 = 'Registrant Number'
					 ,@Arg2 = 'maximum'
					 ,@Arg3 = @i;

					raiserror(@errorText, 17, 1);

				end;

				set @RegistrantNo = replace(@registrantNoTemplate, replicate('#', @templateDigits), ltrim(@registrantSeqNo)); -- finally return the next applicant number
			end;
		end;

		if @tranCount = 0 and xact_state() = 1
		begin
			commit transaction;
		end;

	end try
	begin catch
		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName; -- committable wrapping trx exists: rollback to savepoint
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
