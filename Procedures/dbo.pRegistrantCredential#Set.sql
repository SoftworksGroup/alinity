SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantCredential#Set
	@UpdateRule									 varchar(10) = 'NEWONLY'	-- setting of update rule - see comments below
 ,@RegistrantSID							 int											-- key of person record to insert/update credential for (required!)
 ,@CredentialLabel						 nvarchar(35)							-- value to lookup credential record (FK)
 ,@IsQualifying								 bit = 0									-- indicates whether credential inserted must be qualifying (optional - applies error check)
 ,@OrgLabel										 nvarchar(150) = null			-- optional: lookup value for granting organization (required if Qualifying credential)
 ,@ProgramName								 nvarchar(65) = null			-- optional: name of program to apply to registrant credential record
 ,@ProgramStartDate						 date = null							-- optional: date when registrant started in program
 ,@ProgramTargetCompletionDate date = null							-- optional: date when registrant completed/scheduled to complete
 ,@FieldOfStudyName						 nvarchar(50) = null			-- optional: name of field of study to apply to registrant credential record
 ,@EffectiveTime							 datetime = null					-- date and time (client timezone) when credential is active
 ,@ExpiryTime									 datetime = null					-- date and time (client timezone) when credential expires
 ,@UpdateTime									 datetimeoffset(7) = null -- required if update rule is "LATEST"
 ,@LegacyKey									 nvarchar(50) = null			-- key of registrant credential record in source/converted system 
 ,@RegistrantCredentialSID		 int = null output				-- key of registrant credential record inserted or updated
as
/*********************************************************************************************************************************
Procedure : Registrant Credential - Set
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Applies registrant credential information from user-entered forms or staging records into main (DBO) tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure supports adding or updating a registrant credential (dbo.RegistrantCredential) from source data provided from forms 
or from the staging area (e.g. stg.RegistrantProfile).  The source data is passed into the procedure and the registrant credential 
record is created where it does not already exist. 

The procedure requires a RegistrantSID to associate the credential with.  A Credential identifier (label) which must be found in 
the master table is also required. Where the credential is qualifying (@IsQualifying = 1), an organization identifier (label)
must also be provided.  All other parameters are optional and/or can be defaulted.  

For details on how look ups of identifiers in master tables is carried out, see the #Lookup subroutine documentation. 

Updating existing registrant credentials is carried out where an existing record is found for the person and label passed in.  
The update will only occur, however if the setting of the @UpdateRule allows it (see below).

Update Rule
-----------
The content passed in will create new records if none are found but if an existing record is found, it will only be updated
based on the setting of the @UpdateRule - which if not passed is set to NEWONLY. The following settings are supported:

NEWONLY			-- existing records are never updated, but new records are added
LATEST			-- existing record overwritten if the @UpdateTime passed in is later than the existing record, new records are added
ALWAYS			-- existing record is always overwritten with information passed in, new records are added

The default setting is "NEWONLY", since the products are normally considered to be the repository of the most up-to-date
information. Note that the LATEST rule depends on the @UpdateTime parameter being passed in.  If the value is not provided an 
error is returned.

Errors Must Be Raised to the Caller
-----------------------------------
This procedure is often called in batch processing scenarios for sets of records stored in staging where an error on any 
individual record should not stop processing of remaining records. For that reason, errors raised by the procedure must be caught 
by the top-level calling procedure and handled.  The call to this procedure must be wrapped in a try-catch block. Failing to 
raise an error in this subroutine will generate a mismatch in the transaction count and the message: "Transaction count after 
EXECUTE indicates a mismatching number of BEGIN and COMMIT statements. Previous count = 1, current count = 0." The caller must 
determine whether errors should be raised to the application, or logged when executed in batch processes.

Example
-------
<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Calls procedure to insert and then rollback a new registrant credential.">
		<SQLScript>
			<![CDATA[
declare
	@registrantSID							 int
 ,@credentialLabel						 nvarchar(35)
 ,@orgLabel										 nvarchar(150)
 ,@programName								 nvarchar(65)
 ,@programStartDate						 date
 ,@programTargetCompletionDate date
 ,@fieldOfStudyName						 nvarchar(50)
 ,@effectiveTime							 datetime
 ,@expiryTime									 datetime
 ,@registrantCredentialSID		 int

select top (1) -- locate a valid qualifying credential and extract parameter values
	@registrantSID							 = rc.RegistrantSID
 ,@credentialLabel						 = N'SID:' + ltrim(rc.CredentialSID)
 ,@orgLabel										 = o.OrgName
 ,@programName								 = rc.ProgramName
 ,@programStartDate						 = rc.ProgramStartDate
 ,@programTargetCompletionDate = rc.ProgramTargetCompletionDate
 ,@fieldOfStudyName						 = fos.FieldOfStudyName
 ,@effectiveTime							 = rc.EffectiveTime
 ,@expiryTime									 = rc.ExpiryTime
from
	dbo.RegistrantCredential		rc
join
	dbo.QualifyingCredentialOrg qco on rc.CredentialSID		= qco.CredentialSID and rc.OrgSID = qco.OrgSID
join
	dbo.Org											o on rc.OrgSID						= o.OrgSID
left outer join
	dbo.FieldOfStudy						fos on rc.FieldOfStudySID = fos.FieldOfStudySID
order by
	newid();

select top (1) -- isolate a registrant who does not have the qualifying credential identified above
	@registrantSID = r.RegistrantSID
from
	dbo.Registrant					 r
left outer join
	dbo.RegistrantCredential rc on r.RegistrantSID = rc.RegistrantSID and 'SID:' + ltrim(rc.CredentialSID) = @credentialLabel
left outer join
	dbo.Org									 o on rc.OrgSID				 = o.OrgSID and o.OrgName = @orgLabel
where
	rc.RegistrantCredentialSID is null
order by
	newid();

if @@rowcount = 0 or @registrantSID is null or @credentialLabel is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantCredential#Set
		@RegistrantSID = @registrantSID
	 ,@CredentialLabel = @credentialLabel
	 ,@IsQualifying = 1
	 ,@OrgLabel = @orgLabel
	 ,@ProgramName = @programName
	 ,@ProgramStartDate = @programStartDate
	 ,@ProgramTargetCompletionDate = @programTargetCompletionDate
	 ,@FieldOfStudyName = @fieldOfStudyName
	 ,@EffectiveTime = @effectiveTime
	 ,@ExpiryTime = @expiryTime
	 ,@RegistrantCredentialSID = @registrantCredentialSID output;

	select
	  @credentialLabel					 CredentialLabel
	 ,@orgLabel									 OrgLabel
	 ,@fieldOfStudyName					 FieldOfStudyName
	 ,@registrantCredentialSID	 RegistrantCredentialSID
	 ,rc.RegistrantCredentialSID InsertedRegistrantCredentialSID
	 ,rc.CredentialLabel				 InsertedCredentialLabel
	 ,rc.FieldOfStudyName				 InsertedFieldOfStudyName
	 ,rc.RegistrantNo						 InsertedRegistrantNo
	 ,rc.OrgLabel								 InsertedOrgLabel
	from
		dbo.vRegistrantCredential rc
	where
		rc.RegistrantCredentialSID = @registrantCredentialSID;

	rollback;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantCredential#Set'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm					nvarchar(100)											-- error checking buffer for required parameters
	 ,@ON									bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@existingUpdateTime datetimeoffset(7)									-- value of existing record update time (overwrite check input)
	 ,@credentialSID			int																-- master table keys for new record (obtained via lookup):
	 ,@orgSID							int
	 ,@fieldOfStudySID		int;

	set @RegistrantCredentialSID = @RegistrantCredentialSID; -- in/out (may be passed in to support updates)

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @IsQualifying = @ON and @OrgLabel is null	set @blankParm = '@OrgLabel' -- required if a qualifying credential
		if @CredentialLabel is null										set @blankParm = N'@CredentialLabel';
		if @RegistrantSID		is null										set @blankParm = N'@RegistrantSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @UpdateRule not in ('NEWONLY', 'LATEST', 'ALWAYS')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'update-rule-code'
			 ,@Arg2 = @UpdateRule
			 ,@Arg3 = '"NewOnly", "Latest", "Always"';

			raiserror(@errorText, 18, 1);
		end;

		if @RegistrantCredentialSID is null
		begin

			-- lookup credential

			exec dbo.pCredential#Lookup
				@CredentialIdentifier = @CredentialLabel
			 ,@CredentialSID = @credentialSID output;

			if @credentialSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'MasterTableValueNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
				 ,@Arg1 = @CredentialLabel
				 ,@Arg2 = 'Credential'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);

			end;

			-- lookup organization if provided (optional)

			if @OrgLabel is not null
			begin

				exec dbo.pOrg#Lookup
					@OrgIdentifier = @OrgLabel
				 ,@OrgSID = @orgSID output;

				if @orgSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'MasterTableValueNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
					 ,@Arg1 = @OrgLabel
					 ,@Arg2 = 'Organization'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);

				end;
			end;

			-- ensure credentials marked as qualifying exist
			-- in the master table

			if @IsQualifying = @ON
			begin

				if not exists
				(
					select
						1
					from
						dbo.QualifyingCredentialOrg qco
					where
						qco.CredentialSID = @credentialSID and qco.OrgSID = @orgSID
				)
				begin

					set @OrgLabel = @OrgLabel + ': ' + @CredentialLabel;

					exec sf.pMessage#Get
						@MessageSCD = 'MasterTableValueNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
					 ,@Arg1 = @OrgLabel
					 ,@Arg2 = 'Qualifying Credential Organization'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);

				end;

				if @EffectiveTime is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'MissingEffectiveDate'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'An effective date is required for %1.  Correct the source value or add it to the master table before re-processing the record.'
					 ,@Arg1 = 'qualifying credentials'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);

				end;

			end;

			-- lookup field of study if provided (optional)

			if @FieldOfStudyName is not null
			begin

				exec dbo.pFieldOfStudy#Lookup
					@FieldOfStudyIdentifier = @FieldOfStudyName
				 ,@FieldOfStudySID = @fieldOfStudySID output;

				if @fieldOfStudySID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'MasterTableValueNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
					 ,@Arg1 = @FieldOfStudyName
					 ,@Arg2 = 'FieldOfStudy'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);

				end;

			end;

			-- avoid creating a duplicate where the record already exists

			select
				@RegistrantCredentialSID = rc.RegistrantCredentialSID
			from
				dbo.RegistrantCredential rc
			where
				rc.RegistrantSID = @RegistrantSID and rc.CredentialSID = @credentialSID;

			if @RegistrantCredentialSID is null
			begin

				-- add the record; additional error checks are performed in the 
				-- constraint function and violations are reported to catch block

				exec dbo.pRegistrantCredential#Insert
					@RegistrantCredentialSID = @RegistrantCredentialSID output	-- int
				 ,@RegistrantSID = @RegistrantSID
				 ,@CredentialSID = @credentialSID
				 ,@OrgSID = @orgSID
				 ,@ProgramName = @ProgramName
				 ,@ProgramStartDate = @ProgramStartDate
				 ,@ProgramTargetCompletionDate = @ProgramTargetCompletionDate
				 ,@EffectiveTime = @EffectiveTime
				 ,@ExpiryTime = @ExpiryTime
				 ,@FieldOfStudySID = @fieldOfStudySID
				 ,@LegacyKey = @LegacyKey;

			end;

		end;


		-- process update scenarios 

		if @RegistrantCredentialSID is not null
		begin

			if @UpdateRule = 'LATEST' and @UpdateTime is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'LatestWithNoUpdateTime'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The update rule specified in the configuration is "LATEST" but no update time was provided from the source record.'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);

			end;
			else if @UpdateRule = 'ALWAYS' or (@UpdateRule = 'LATEST' and @UpdateTime > @existingUpdateTime)
			begin

				exec dbo.pRegistrantCredential#Update
					@RegistrantCredentialSID = @RegistrantCredentialSID
				 ,@RegistrantSID = @RegistrantSID
				 ,@CredentialSID = @credentialSID
				 ,@OrgSID = @orgSID
				 ,@ProgramName = @ProgramName
				 ,@ProgramStartDate = @ProgramStartDate
				 ,@ProgramTargetCompletionDate = @ProgramTargetCompletionDate
				 ,@EffectiveTime = @EffectiveTime
				 ,@ExpiryTime = @ExpiryTime
				 ,@FieldOfStudySID = @fieldOfStudySID
				 ,@LegacyKey = @LegacyKey;

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
