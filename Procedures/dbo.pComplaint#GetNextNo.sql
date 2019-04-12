SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pComplaint#GetNextNo
	@ComplaintNo varchar(50) output -- the next complaint number to assign to the dbo.Complaint record
as
/*********************************************************************************************************************************
Sproc    : Complaint - Get Next No
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : This procedure returns the next complaint # from the sequence to assign to the Complaint
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure is called from pComplaint#Insert . It reads a sequence and optional configuration values to return the next 
complaint number.

Note that it is possible for a complaint number to be set manually on the pass from the caller.  This would occur, for example, 
if historical data is being added/converted. If a complaint# has already been provided to the calling procedure this routine 
should NOT be called.  The procedure does check, however, to see if a value other than "+" or NULL has been passed and
if so, no new sequence number is returned.

In addition to reading a template to format prefix and/or suffix values for the new number, the procedure also reads the
minimum value to assign for the sequence. If this value is greater than the current value, the procedure modifies the 
sequence to reset to the new minimum.  This allows control of the sequence to be managed through configuration values
completely without requiring the help desk.

Example
-------
-- NOTE: even with "ROLLBACK" these tests use up next sequence number values!

<TestHarness>
  <Test Name = "Applicant" IsDefault ="true" Description="Executes the procedure to return a number for a new complaint.">
    <SQLScript>
      <![CDATA[     
declare @complaintNo varchar(50);

begin transaction;

exec dbo.pComplaint#GetNextNo
	@ComplaintNo = @ComplaintNo output;

select @ComplaintNo	 ComplaintNo;
rollback;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	 @ObjectName = 'dbo.pComplaint#GetNextNo'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo						 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)													-- message text (for business rule errors)
	 ,@tranCount					 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName					 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState							 int																		-- error state detected in catch block
	 ,@complaintNoTemplate varchar(50)														-- config-param value defining format of complaint number
	 ,@complaintNoMinimum	 bigint																	-- config-param value defining minimum complaint number
	 ,@complaintSeqNo			 bigint																	-- next value from the sequence
	 ,@templateDigits			 smallint			 = 0											-- count of digits in the selected template
	 ,@i									 int					 = 1											-- string position counter
	 ,@alterSeq						 nvarchar(1000);												-- buffer for dynamic SQL to alter sequence next values and minimum values

	set @ComplaintNo = @ComplaintNo; -- ensure output parameters initialized in all code paths (for code analysis)

	begin try

		if @ComplaintNo is null or @ComplaintNo = '+' -- otherwise do not overwrite the number passed in
		begin

			-- use a transaction to allow recovery by the caller if required

			if @tranCount = 0 -- no outer transaction
			begin
				begin transaction;
			end;
			else -- outer transaction so create save point
			begin
				save transaction @sprocName;
			end;

			-- validate format of complaint number template 

			set @complaintNoTemplate = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ComplaintNoTemplate'), '####'))) as varchar(50)); -- read formatting template from configuration
			set @i = 1;
			set @templateDigits = 0;

			while charindex('#', @complaintNoTemplate, @i) > 0 and @i <= len(@complaintNoTemplate) -- validate the template for minimum digits
			begin
				set @i = charindex('#', @complaintNoTemplate, @i);
				set @templateDigits += 1;
				set @i += 1;
			end;

			if @templateDigits = 0 or @templateDigits < 4
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SeqTemplateInvalid'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" template is invalid.  A %2 of %3 "#" symbols are required. (Ensure starting value is compatible.)'
				 ,@Arg1 = 'Complaint Number'
				 ,@Arg2 = 'minimum'
				 ,@Arg3 = '4';

				raiserror(@errorText, 17, 1);

			end;

			-- read the next number from the sequence and compare
			-- with format, and minimum value in configuration

			select @complaintSeqNo = next	 value for dbo.sComplaint;	-- get next value from the sequence

			set @complaintNoMinimum = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ComplaintNoMinimum'), '1001'))) as bigint); -- if next value is too low, update the sequence

			if @complaintSeqNo < @complaintNoMinimum
			begin

				set @alterSeq =
					N'alter sequence dbo.sComplaint' + N' restart with ' + ltrim(@complaintNoMinimum) + N'	increment by 1' + N' minvalue ' + ltrim(@complaintNoMinimum)
					+ N' maxvalue 9999999' + N'	no cache' ;

				exec sp_executesql @stmt = @alterSeq;
				select @complaintSeqNo = next	 value for dbo.sComplaint;	-- obtain next value to verify revised sequence settings 

			end;

			if len(ltrim(@complaintSeqNo)) < @templateDigits -- validate that template format is compatible with sequence range
			begin

				set @i = len(ltrim(@complaintSeqNo));

				exec sf.pMessage#Get
					@MessageSCD = 'SeqTemplateInvalid'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" template is invalid.  A %2 of %3 "#" symbols are required. (Ensure starting value is compatible.)'
				 ,@Arg1 = 'Complaint Number'
				 ,@Arg2 = 'maximum'
				 ,@Arg3 = @i;

				raiserror(@errorText, 17, 1);

			end;

			set @ComplaintNo = replace(@complaintNoTemplate, replicate('#', @templateDigits), ltrim(@complaintSeqNo)); -- finally return the next complaint number

			if @tranCount = 0 and xact_state() = 1
			begin
				commit transaction;
			end;

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
