SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantExam#Set
	@UpdateRule				 varchar(10) = 'NEWONLY'	-- setting of update rule - see comments below
 ,@RegistrantNo			 varchar(50)							-- values of next record to process (see table doc for details):
 ,@EmailAddress			 varchar(150)
 ,@FirstName				 nvarchar(30)
 ,@LastNameToMatch	 nvarchar(35)
 ,@BirthDate				 date
 ,@ExamDate					 date
 ,@OrgLabel					 nvarchar(65)
 ,@ExamResultDate		 date
 ,@PassingScore			 int
 ,@Score						 int
 ,@ExamIdentifier		 nvarchar(50)
 ,@AssignedLocation	 varchar(15)
 ,@ExamReference		 varchar(25)
 ,@PersonSID				 int output
 ,@RegistrantSID		 int output
 ,@OrgSID						 int output
 ,@ExamSID					 int output
 ,@ExamOfferingSID	 int output
 ,@ExamStatusSID		 int output
 ,@RegistrantExamSID int output
 ,@LegacyKey				 nvarchar(50)
 ,@UpdateTime				 datetimeoffset(7)
as
/*********************************************************************************************************************************
Procedure : Registrant Exam - Set
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Applies registrant exam information from user-entered forms or staging records into main (DBO) tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure supports adding or updating a registrant exam (dbo.RegistrantExam) from source data provided from forms or from
the staging area (stg.RegistrantExamProfile). The source data is passed into the procedure and the registrant exam record is created 
where it does not already exist. 

The procedure requires a RegistrantSID and an ExamSID to create the target record.  The RegistrantSID may be provided directly
or derived from a RegistrantNo, or a combination of name and birthdate (see pRegistrant#Lookup).  An Exam key must be provided
directly or looked up through an identifier such as name, vendor exam ID, legacy key (see pExam#Lookup). Where a score is provided
an exam date must also be provided. 

Scheduling Only
---------------
If no score is provided but an exam date is, then the procedure considers the record to be created for the purpose of scheduling
the exam in which case an Exam Offering must also be identified.  The Exam Offering can be located based on the Exam SID identified 
and the Exam Date, and optionally an Organization. The Organization key can be passed directly or looked through the OrgLabel column
which may contain an organization name, label or legacy key. 

Adding Offerings
---------------
Note that if an Organization key has been provided or looked up, and, an Exam Date are provided and no Exam Offering exists for that 
combination, then the procedure will add the Exam Offering.  This supports the scheduling scenario where the vendor is providing a 
file of exam bookings for registrants which have not yet been entered into the system's exam offering master schedule.

For additional details on how look ups of identifiers in master tables is carried out, see the #Lookup subroutine documentation. 

Updating existing registrant exams is carried out where an existing record is found. The update will only occur, however if 
the setting of the @UpdateRule allows it (see below).

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
	<Test Name="Random" IsDefault="true" Description="Calls procedure to insert and then rollback a new registrant exam.">
		<SQLScript>
			<![CDATA[
declare
	@registrantSID							 int
 ,@examLabel						 nvarchar(35)
 ,@orgLabel										 nvarchar(65)
 ,@programName								 nvarchar(65)
 ,@programStartDate						 date
 ,@programTargetCompletionDate date
 ,@fieldOfStudyName						 nvarchar(50)
 ,@effectiveTime							 datetime
 ,@expiryTime									 datetime
 ,@registrantExamSID		 int

select top (1) -- locate a valid qualifying exam and extract parameter values
	@registrantSID							 = rc.RegistrantSID
 ,@examLabel						 = N'SID:' + ltrim(rc.ExamSID)
 ,@orgLabel										 = o.OrgName
 ,@programName								 = rc.ProgramName
 ,@programStartDate						 = rc.ProgramStartDate
 ,@programTargetCompletionDate = rc.ProgramTargetCompletionDate
 ,@fieldOfStudyName						 = fos.FieldOfStudyName
 ,@effectiveTime							 = rc.EffectiveTime
 ,@expiryTime									 = rc.ExpiryTime
from
	dbo.RegistrantExam		rc
join
	dbo.QualifyingExamOrg qco on rc.ExamSID		= qco.ExamSID and rc.OrgSID = qco.OrgSID
join
	dbo.Org											o on rc.OrgSID						= o.OrgSID
left outer join
	dbo.FieldOfStudy						fos on rc.FieldOfStudySID = fos.FieldOfStudySID
order by
	newid();

select top (1) -- isolate a registrant who does not have the qualifying exam identified above
	@registrantSID = r.RegistrantSID
from
	dbo.Registrant					 r
left outer join
	dbo.RegistrantExam rc on r.RegistrantSID = rc.RegistrantSID and 'SID:' + ltrim(rc.ExamSID) = @examLabel
left outer join
	dbo.Org									 o on rc.OrgSID				 = o.OrgSID and o.OrgName = @orgLabel
where
	rc.RegistrantExamSID is null
order by
	newid();

if @@rowcount = 0 or @registrantSID is null or @examLabel is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantExam#Set
		@RegistrantSID = @registrantSID
	 ,@ExamLabel = @examLabel
	 ,@IsQualifying = 1
	 ,@OrgLabel = @orgLabel
	 ,@ProgramName = @programName
	 ,@ProgramStartDate = @programStartDate
	 ,@ProgramTargetCompletionDate = @programTargetCompletionDate
	 ,@FieldOfStudyName = @fieldOfStudyName
	 ,@EffectiveTime = @effectiveTime
	 ,@ExpiryTime = @expiryTime
	 ,@RegistrantExamSID = @registrantExamSID output;

	select
	  @examLabel					 ExamLabel
	 ,@orgLabel									 OrgLabel
	 ,@fieldOfStudyName					 FieldOfStudyName
	 ,@registrantExamSID	 RegistrantExamSID
	 ,rc.RegistrantExamSID InsertedRegistrantExamSID
	 ,rc.ExamLabel				 InsertedExamLabel
	 ,rc.FieldOfStudyName				 InsertedFieldOfStudyName
	 ,rc.RegistrantNo						 InsertedRegistrantNo
	 ,rc.OrgLabel								 InsertedOrgLabel
	from
		dbo.vRegistrantExam rc
	where
		rc.RegistrantExamSID = @registrantExamSID;

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
	@ObjectName = 'dbo.pRegistrantExam#Set'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo						int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm					nvarchar(100)											-- error checking buffer for required parameters
	 ,@ON									bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@isSchedulingOnly		bit							 = cast(0 as bit) -- indicates whether only scheduling will be updated (otherwise result required)
	 ,@existingUpdateTime datetimeoffset(7);								-- value of existing record update time (overwrite check input)

	set @PersonSID = @PersonSID; -- in/out (may be passed in to support updates)
	set @RegistrantSID = @RegistrantSID;
	set @OrgSID = @OrgSID
	set @ExamSID = @ExamSID;
	set @ExamOfferingSID = @ExamOfferingSID;
	set @ExamStatusSID = @ExamStatusSID;

	begin try

		-- check parameters

		-- SQL Prompt formatting off
		if @ExamIdentifier	is null set @blankParm = N'ExamIdentifier'
		if @LastNameToMatch is null set @blankParm = N'LastNameToMatch';
		-- SQL Prompt formatting on
		--
		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 16, 1);
		end;

		-- if no score or status provided then the record is applied as
		-- scheduling-only, in which case an exam date is required
		if @Score is null and @ExamStatusSID is null
		begin
			set @isSchedulingOnly = @ON;

			if @ExamDate is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'ScoreRequired'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'An exam date must be provided to schedule the registrant. If scheduling was not intended, then an exam score must be provided.'
				 ,@Arg1 = @blankParm;

				raiserror(@errorText, 16, 1);
			end;
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

		if @ExamStatusSID is not null
		begin
			if not exists (select 1 from dbo .ExamStatus xs where xs.ExamStatusSID = @ExamStatusSID)
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.ExamStatus'
				 ,@Arg2 = @ExamStatusSID;

				raiserror(@errorText, 18, 1);
			end;
		end;

		if @RegistrantSID is null
		begin

			-- lookup registrant
			if @RegistrantSID is null or @PersonSID is null
			begin
				exec dbo.pRegistrant#Lookup
					@RegistrantNo = @RegistrantNo
				 ,@EmailAddress = @EmailAddress
				 ,@LastNameToMatch = @LastNameToMatch
				 ,@FirstName = @FirstName
				 ,@BirthDate = @BirthDate
				 ,@LegacyKey = @LegacyKey
				 ,@PersonSID = @PersonSID output
				 ,@RegistrantSID = @RegistrantSID output;
			end;

			if @RegistrantSID is null or @PersonSID is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'NotIdentifiedByLookup'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A(n) %1 record could not be identified from the source values provided. Lookup is supported through the following: %2'
				 ,@Arg1 = 'registrant'
				 ,@Arg2 = 'Registrant#, Email Address, Last Name + First Name + Date-of-Birth, Legacy Key, or System Identifiers';

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- if the org key was not passed directly and a label was
		-- provided, lookup the organization key based on the label
		if @OrgSID is null and @OrgLabel is not null
		begin
			exec dbo.pOrg#Lookup
				@OrgIdentifier = @OrgLabel
			 ,@OrgSID = @OrgSID output;

			if @OrgSID is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'NotIdentifiedByLookup'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A(n) %1 record could not be identified from the source values provided. Lookup is supported through the following: %2'
				 ,@Arg1 = 'organization'
				 ,@Arg2 = 'Organization name, Label, Legacy Key, or System Identifiers';

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- lookup the exam and offerring; the offering is not 
		-- mandatory except in scheduling scenarios
		exec dbo.pExam#Lookup
			@ExamIdentifier = @ExamIdentifier
		 ,@LegacyKey = @LegacyKey
		 ,@ExamDate = @ExamDate
		 ,@OrgSID = @OrgSID
		 ,@ExamSID = @ExamSID output
		 ,@ExamOfferingSID = @ExamOfferingSID output;

		if @ExamSID is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'NotIdentifiedByLookup'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A(n) %1 record could not be identified from the source values provided. Lookup is supported through the following: %2'
			 ,@Arg1 = 'exam'
			 ,@Arg2 = 'Exam Name, Exam Vendor ID, Legacy Key, or System Identifier';

			raiserror(@errorText, 16, 1);
		end;

		-- if this is a scheduling record but no offering was found
		-- it can onlybe created where an organization was also provided
		if @ExamOfferingSID is null and @isSchedulingOnly = @ON
		begin
			if @OrgSID is not null
			begin
				exec dbo.pExamOffering#Insert
					@ExamOfferingSID = @ExamOfferingSID output
				 ,@ExamSID = @ExamSID
				 ,@OrgSID = @OrgSID
				 ,@ExamTime = @ExamDate;
			end;
			else
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'NotIdentifiedByLookup'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A(n) %1 record could not be identified from the source values provided. Lookup is supported through the following: %2'
				 ,@Arg1 = 'exam offering'
				 ,@Arg2 = 'Exam Name + Date, Exam Offering Vendor ID, or System Identifier';

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- record the exam result or scheduling information 
		-- into the registrant-exam
		if @RegistrantExamSID is null
		begin
			exec dbo.pRegistrantExam#Insert
				@RegistrantExamSID = @RegistrantExamSID output
			 ,@RegistrantSID = @RegistrantSID
			 ,@ExamSID = @ExamSID
			 ,@ExamDate = @ExamDate
			 ,@ExamResultDate = @ExamResultDate
			 ,@PassingScore = @PassingScore
			 ,@Score = @Score
			 ,@ExamStatusSID = @ExamStatusSID
			 ,@AssignedLocation = @AssignedLocation
			 ,@ExamReference = @ExamReference
			 ,@ExamOfferingSID = @ExamOfferingSID;
		end;
		else -- process #update scenario if existing record found
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
				exec dbo.pRegistrantExam#Update
					@RegistrantExamSID = @RegistrantExamSID
				 ,@RegistrantSID = @RegistrantSID
				 ,@ExamSID = @ExamSID
				 ,@ExamDate = @ExamDate
				 ,@ExamResultDate = @ExamResultDate
				 ,@PassingScore = @PassingScore
				 ,@Score = @Score
				 ,@ExamStatusSID = @ExamStatusSID
				 ,@AssignedLocation = @AssignedLocation
				 ,@ExamReference = @ExamReference
				 ,@ExamOfferingSID = @ExamOfferingSID;
			end;
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
