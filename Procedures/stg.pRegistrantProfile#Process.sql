SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stg.pRegistrantProfile#Process
	@Action								varchar(20) = 'PROCESS' -- to validate and not apply records use VALIDATE.ONLY
 ,@RegistrantProfileSID int = null							-- to force a specific record to be processed immediately
 ,@JobRunSID						int = null							-- reference to sf.JobRun for async call updates
 ,@DebugLevel						tinyint = 0							-- when > 0 causes debug statements and timing marks to print
as
/*********************************************************************************************************************************
Procedure : Registrant Profile - Process
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Control procedure for applying Registrant Profile records from staging into the main (dbo) tables of the database
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This is a control procedure for processing staging records from the stg.RegistrantProfile table. The Registrant Profile table
is used for loading member and non-member records and may include user account information, initial register status, credential
and specializations, and group assignment information.  All values except for the columns mandatory in the (sf) Person table
may be left blank and the record can still be successfully processed.

The procedure can be called to immediately process a single record, or called as a background process to apply all un-processed 
records.  If a record failed on an earlier attempt at processing, it will be retried unless it has been marked "CANCELLED".

When records are processed into the main tables by this procedure validations are conducted and any errors are reported back 
into the record for follow-up by administrators. 

The staging area is reserved for initial loading of data in conversion and system-to-system interface processes.  Tables in the 
staging area have a generally flat (non-normalized) structure that is easier to work with for initial data loading. The tables
are loaded from imported files matching a template provided or through custom conversion routines.  

Validation on the initial import of records into the table is limited to data types and data lengths.  This procedure is 
responsible for carrying out detailed validation.  As errors or warnings are encountered, they are written into a comments
column provided in the table and the process proceeds with the next record rather than failing.

By passing @Action = 'VALIDATE.ONLY', only validation will be run and the records will not be applied.  When the @Action is 
'PROCESS' (the default), validation is still executed on each record before it is applied to the main schemas.

The procedure writes content from stg.RegistrantProfile into the following main tables:

o sf.Person
o sf.PersonEmailAddress
o sf.ApplicationUser
o sf.ApplicationUserGrant
o dbo.PersonMailingAddress
o dbo.Registrant
o dbo.Registration
o dbo.RegistrantCredential
o dbo.PersonGroup

Subroutines handle insert and updates while the job control features are implemented in this procedure. The processing of 
each record within the main loop is wrapped in a try-catch block and error caught and reported into the record to avoid 
blocking processing/validation of remaining records in the data set.

Avoiding Duplicates/No Update
-----------------------------
The procedure looks for existing versions of target records by looking up the "LegacyKey" column in the (sf) Person table. The
legacy key value should be filled in for all conversions from legacy systems as it will greatly improve the reliability of 
the import process. Where a legacy key value is not provided - e.g. with applicant records who were not entered in a legacy 
system - the procedure looks for existing records based on name columns + birthdate. Where no legacy key is provided, the last 
name, first name and birth date are required.

Master table additions
----------------------
For master tables the legacy key is not available in the staging profile table so matches are attempted using code, label 
and/or name columns.  If a master table record is not found, the registration profile record does not pass validation. For
example, if a new Credential or Person Group is encountered, an error is reported and the user must add the new value to 
their configuration and processing can be retried.

Note however, that new Cities and State/Province values will be automatically added according to the following rules:
	o Where a new City name is encountered, it is automatically added to the dbo.City table.
	o Where a new State-Province is encountered for a country that is not the default, it will be added to dbo.StateProvince
	o New country values are NOT added (the configuration is pre-loaded with a full country list)

Job Management
--------------
The @JobRunSID parameter is provided automatically when this procedure is called as an asynchronous job.  See documentation
on the Job Scheduler sub-system in the framework for details.  Logic is included in this procedure to update the status of the
job and to "listen" for cancellation requests when this parameter is provided.

@DebugLevel - Debug monitor (timing marks)
------------------------------------------
In order to get timing marks printed to the console (to debug performance problems), the @DebugLevel parameter must be set to a 
value greater than 0. Where the value is 1, only timing marks from the parent procedure are included.  A value of 2 causes
timing marks from the first subroutine level to be printed as well and so on to deeper levels of subroutine calls. 

Limitations
-----------
Each of the target table has one or more parent/master tables associated with it.  When a master table value is not found
for the reference provided in the staging table, it is NOT automatically inserted. For example, if a credential is provided
that is not found in dbo.Credential master table, an error is recorded on the record.  While entry of some master table
values "on-the-fly" may be desirable (e.g. City), the best practice encouraged is to create a separate import for the
master table, have the user validate it, and then insert it via the procedure provided for that purpose.

Example
-------
<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Calls procedure to process a single record at random.  No job control applies.">
		<SQLScript>
			<![CDATA[
declare @registrantProfileSID int;

select top (1)
	@registrantProfileSID = rp.RegistrantProfileSID
from
	stg.RegistrantProfile rp
join
	sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.ProcessingStatusSCD = 'NEW'
where
	rp.LastName is not null and rp.FirstName is not null and rp.QualifyingCredentialLabel is not null and rp.PersonGroupLabel1 is not null
order by
	newid();

if @@rowcount = 0 or @registrantProfileSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec stg.pRegistrantProfile#Process
		@RegistrantProfileSID = @registrantProfileSID
	 ,@DebugLevel = 1
	 --,@Action = 'VALIDATE.ONLY';

	select
		rp.RegistrantProfileSID
	 ,sf.fFormatFileAsName(rp.LastName, rp.FirstName, rp.MiddleNames) SourceFileAsName
	 ,p.FileAsName																										TargetFileAsName
	 ,p.PersonSID
	 ,r.RegistrantSID
	 ,r.RegistrantNo
	 ,rp.EmailAddress																									SourceEmailAddress
	 ,p.PrimaryEmailAddress																						TargetEmailAddress
	 ,rp.UserName																											SourceUserName
	 ,au.UserName																											TargetUserName
	 ,rp.Password																											SourcePassword
	 ,au.GlassBreakPassword																						TargetPassword
	 ,rp.StreetAddress1 + ' ' + rp.CityName + ' ' + rp.PostalCode			SourceAddress
	 ,pma.StreetAddress1 + ' ' + cty.CityName + ' ' + pma.PostalCode	TargetAddress
	 ,rp.HomePhone																										SourceHomePhone
	 ,p.HomePhone																											TargetHomePhone
	 ,rp.RegistrantNo																									SourceRegistrantNo
	 ,rp.PracticeRegisterLabel																				SourceRegister
	 ,reg.PracticeRegisterLabel																				TargetRegister
	 ,rp.PracticeRegisterSectionLabel																	SourceRegisterSection
	 ,reg.PracticeRegisterSectionLabel																TargetRegisterSection
	 ,r.RegistrantSID																									TargetRegistrantSID
	 ,rp.QualifyingCredentialLabel																		SourceQualifyingCredential
	 ,rc.CredentialLabel																							TargetQualifyingCredential
	 ,rp.PersonGroupLabel1																						SourcePersonGroup
	 ,pgm.PersonGroupLabel																						TargetPersonGroup
	 ,rp.ProcessingComments
	from
		stg.RegistrantProfile																					 rp
	left outer join
		sf.vPerson																										 p on rp.PersonSID = p.PersonSID
	left outer join
		dbo.PersonMailingAddress																			 pma on p.PersonSID = pma.PersonSID
	left outer join
		sf.ApplicationUser																						 au on rp.PersonSID = au.PersonSID
	left outer join
		dbo.City																											 cty on pma.CitySID = cty.CitySID
	left outer join
		dbo.Registrant																								 r on rp.RegistrantSID = r.RegistrantSID
	left outer join
		dbo.vRegistrantCredential																			 rc on r.RegistrantSID = rc.RegistrantSID and rc.CredentialLabel = rp.QualifyingCredentialLabel
	left outer join
		sf.vPersonGroupMember																					 pgm on p.PersonSID = pgm.PersonSID and pgm.PersonGroupLabel = rp.PersonGroupLabel1 -- source column must use label value (not SID: override or legacy key)
	outer apply dbo.fRegistrant#RegistrationCurrent(r.RegistrantSID) reg
	where
		rp.RegistrantProfileSID = @registrantProfileSID;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
	<Test Name="All" Description="Calls procedure to process ALL RECORDS. The process runs in background (Job Control applies). Query sf.vJobRun to monitor.">
		<SQLScript>
			<![CDATA[

if sf.fJobSchedule#IsStarted() = 0 exec sf.pJobSchedule#Start							-- start schedule if not running

declare
	 @CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job record
	,@jobSCD							varchar(128)																			-- code for the job to insert 
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@parameters					xml																								-- buffer to record parameters for the call syntax
	,@conversationHandle	uniqueidentifier																	-- ID assigned to each job conversation

set @jobSCD = 'stg.pRegistrantProfile#Process'																

select																																		-- add the job syntax if not already established 
	@jobSID = j.JobSID
from
	sf.Job j
where
	j.JobSCD = @jobSCD

if @jobSID is null
begin

	set @callSyntaxTemplate = 
		'exec ' + @jobSCD
		+ @CRLF + '   @JobRunSID            = {JobRunSID}'

	exec sf.pJob#Insert
		 @JobSID							= @jobSID		output
		,@JobSCD							= @jobSCD
		,@JobLabel						= N'Registrant Profile conversion process'
		,@JobDescription			= N'Reads new and corrected records from the Registrant Profile staging area and, after checking to ensure they are valid, writes their content to the main Alinity database area. This process is best run when the database is not busy with other user tasks.'
		,@CallSyntaxTemplate	= @callSyntaxTemplate

end

exec sf.pJob#Call
	 @JobSCD							= @jobSCD
	,@Parameters					= @parameters

waitfor delay '00:00:02'	-- wait 2 seconds for job to get started

select top 1 
	 jr.CallSyntax
	,jr.JobStatusSCD
	,jr.CurrentProcessLabel
	,jr.TotalRecords
	,jr.RecordsProcessed
	,jr.TotalErrors
	,jr.RecordsPerMinute
	,jr.RecordsRemaining
	,jr.EstimatedEndTime
	,jr.EstimatedMinutesRemaining
	,jr.CancellationRequestTime
	,jr.ResultMessage
	,jr.TraceLog
from 
	sf.vJobRun jr 
where
	jr.JobSCD = @jobSCD
order by 
	UpdateTime desc
 
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'stg.pRegistrantProfile#Process'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo												int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText											nvarchar(4000)																						-- message text (for business rule errors)
	 ,@successText										nvarchar(4000)																						-- message text to log when updates are successful
	 ,@ON															bit							 = cast(1 as bit)													-- used on bit comparisons to avoid multiple casts
	 ,@OFF														bit							 = cast(0 as bit)													-- used on bit comparisons to avoid multiple casts	
	 ,@CRLF														nchar(2)				 = char(13) + char(10)										-- carriage return line feed for formatting text blocks
	 ,@mode														varchar(10)																								-- SINGLE or BATCH - when single errors are raised
	 ,@termLabel											nvarchar(35)																							-- buffer for configurable label text
	 ,@recordLabel										nvarchar(25)																							-- text to identify the record currently being processed
	 ,@progressLabel									nvarchar(35)																							-- label to report job status back to UI console
	 ,@isCancelled										bit							 = 0																			-- checks for cancellation request on async job calls  
	 ,@recordsProcessed								int							 = 0																			-- running total of rows processed 
	 ,@totalErrors										int							 = 0																			-- count of total errors on batch of records processed
	 ,@resultMessage									nvarchar(4000)																						-- summary of job result
	 ,@traceLog												nvarchar(max)																							-- text block for detailed results of job
	 ,@inProcessStatusSID							int																												-- ID of message status for "INPROCESS"
	 ,@validatedStatusSID							int																												-- ID of message status for "VALIDATED"
	 ,@processedStatusSID							int																												-- ID of message status for "PROCESSED"
	 ,@errorStatusSID									int																												-- ID of message status for "ERROR"
	 ,@defaultCountrySID							int																												-- required to auto-add state-province if not directly provided
	 ,@defaultStateProvinceSID				int																												-- required to auto-add city if not directly provided
	 ,@execUserName										nvarchar(75)		 = sf.fApplicationUserSession#UserName()	-- user executing the procedure
	 ,@traceInterval									int																												-- tracks frequency of tracing
	 ,@maxRows												int																												-- loop limiter - records to process from @work
	 ,@i															int																												-- loop index - next record to process
	 ,@isNew													bit																												-- tracks if next record retrieved is in a NEW status
	 ,@timeCheck											datetimeoffset(7)																					-- used to debug time elapsed between subroutines
	 ,@debugString										nvarchar(70)																							-- string to track progress through procedure
	 ,@lastName												nvarchar(35)																							-- values of next record to process (see table doc for details):
	 ,@firstName											nvarchar(30)
	 ,@commonName											nvarchar(30)
	 ,@middleNames										nvarchar(30)
	 ,@emailAddress										varchar(150)
	 ,@homePhone											varchar(25)
	 ,@mobilePhone										varchar(25)
	 ,@isTextMessagingEnabled					bit
	 ,@signatureImage									varbinary(max)
	 ,@identityPhoto									varbinary(max)
	 ,@genderLabel										nvarchar(35)
	 ,@namePrefixLabel								nvarchar(35)
	 ,@birthDate											date
	 ,@deathDate											date
	 ,@userName												nvarchar(75)
	 ,@password												nvarchar(50)
	 ,@streetAddress1									nvarchar(75)
	 ,@streetAddress2									nvarchar(75)
	 ,@streetAddress3									nvarchar(75)
	 ,@cityName												nvarchar(30)
	 ,@stateProvinceName							nvarchar(30)
	 ,@stateProvinceCode							nvarchar(5)
	 ,@postalCode											varchar(10)
	 ,@countryName										nvarchar(50)
	 ,@applicationGrantSID1						int
	 ,@applicationGrantSID2						int
	 ,@addressEffectiveTime						datetime
	 ,@registrantNo										varchar(50)
	 ,@practiceRegisterLabel					nvarchar(35)
	 ,@practiceRegisterSectionLabel		nvarchar(35)
	 ,@archivedTime										datetimeoffset(7)
	 ,@isOnPublicRegistry							bit
	 ,@directedAuditYearCompetence		smallint
	 ,@directedAuditYearPracticeHours smallint
	 ,@personSID											int																												-- key values of records found, updated or added
	 ,@personEmailAddressSID					int
	 ,@applicationUserSID							int
	 ,@personMailingAddressSID				int
	 ,@namePrefixSID									int
	 ,@genderSID											int
	 ,@citySID												int
	 ,@stateProvinceSID								int
	 ,@countrySID											int
	 ,@registrantSID									int
	 ,@practiceRegisterSID						int
	 ,@practiceRegisterSectionSID			int
	 ,@processingComments							nvarchar(max)
	 ,@legacyKey											nvarchar(50)
	 ,@updateTime											datetimeoffset(7)
	 ,@sourceFileName									nvarchar(100);

	declare @work table -- a table to hold keys to process
	(ID int identity(1, 1), RegistrantProfileSID int not null);

	begin try

		if @DebugLevel > 0
		begin
			set @debugString = N'Checking parameters (' + object_name(@@procid) + N')';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

		end;

		-- initialize the trace log (keeps history of job progress)
		-- and check parameters and configuration

		set @traceLog =
			sf.fPadR(N'REGISTRANT PROFILE PROCESSING TRACE LOG', 60) + @CRLF + replicate(N'-', 79) + @CRLF
			+ sf.fPadR(N'Job Run# = ' + isnull(ltrim(@JobRunSID), 'None'), 60) + convert(nvarchar(19), sysdatetime(), 121);

		exec stg.pRegistrantProfile#Process$Check
			@RegistrantProfileSID = @RegistrantProfileSID
		 ,@JobRunSID = @JobRunSID
		 ,@InProcessStatusSID = @inProcessStatusSID output
		 ,@ValidatedStatusSID = @validatedStatusSID output
		 ,@ProcessedStatusSID = @processedStatusSID output
		 ,@ErrorStatusSID = @errorStatusSID output
		 ,@DefaultCountrySID = @defaultCountrySID output
		 ,@DefaultStateProvinceSID = @defaultStateProvinceSID output
		 ,@ApplicationGrantSID1 = @applicationGrantSID1 output
		 ,@ApplicationGrantSID2 = @applicationGrantSID2 output;

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'Loading work'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- load the work table with the keys of new records from the staging area
		-- or the single record if passed explicitly

		if @RegistrantProfileSID is null
		begin

			set @traceLog += @CRLF + sf.fPadR(N'Loading work', 60) + convert(nvarchar(19), sysdatetime(), 121);

			if @JobRunSID is not null
			begin

				exec sf.pTermLabel#Get
					@TermLabelSCD = 'RETRIEVING.PENDING'
				 ,@TermLabel = @termLabel output
				 ,@DefaultLabel = N'Retrieving un-processed records ...'
				 ,@UsageNotes = N'A label reporting processing status when new records are being retrieved from the staging area.';

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @termLabel;

				set @termLabel = null; -- reset for next lookup inside loop!

			end;

			set @mode = 'BATCH';

			insert
				@work (RegistrantProfileSID)
			select
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			join
				sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.IsClosedStatus = @OFF;

			set @maxRows = @@rowcount;

		end;
		else
		begin

			set @mode = 'SINGLE';

			set @traceLog += @CRLF + sf.fPadR(N'Registrant Profile# = ' + isnull(ltrim(@RegistrantProfileSID), 'None'), 60)
											 + convert(nvarchar(19), sysdatetime(), 121);

			insert @work ( RegistrantProfileSID) select @RegistrantProfileSID;
			set @maxRows = @@rowcount;

		end;

		set @i = 0; -- initialize main processing loop index
		set @traceInterval = round(@maxRows / 10, 0); -- update trace log every 10% of job size
		if @traceInterval = 0 set @traceInterval = 1; -- or on every row if too few records

		if @Action = 'VALIDATE.ONLY'
		begin
			set @traceLog += @CRLF + sf.fPadR(N'Validation initiated', 60) + convert(nvarchar(19), sysdatetime(), 121) + @CRLF;
		end;
		else
		begin
			set @traceLog += @CRLF + sf.fPadR(N'Processing initiated', 60) + convert(nvarchar(19), sysdatetime(), 121) + @CRLF;
		end;

		if @maxRows > 100
		begin
			set @DebugLevel = 0; -- turn off debugging if a large data set is being processed
		end;

		-- ensure applicant and registrant number sequences
		-- are set to comply with current configuration settings

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'Resetting sequences'
			 ,@TimeCheck = @timeCheck output;

		end;

		exec dbo.pApplicantNo#Reset;
		exec dbo.pRegistrantNo#Reset;

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'Initiating loop'
			 ,@TimeCheck = @timeCheck output;

		end;

		------------------------------
		-- MAIN PROCESSING LOOP: START
		------------------------------

		while @i < @maxRows and @isCancelled = @OFF -- process all records from the work table or until canceled
		begin

			set @errorText = null;
			set @processingComments = N''; -- reinitialize on each processing run
			set @isNew = @OFF;

			-- if the record was deleted or its status was changed after the work
			-- table was loaded skip the record without raising an error

			while @isNew = @OFF and @i < @maxRows -- START OF INNER LOOP (to avoid records changing status)
			begin

				set @i += 1; -- retrieve values for next record to process

				if @DebugLevel > 0
				begin

					exec sf.pDebugPrint
						@DebugString = N'Starting next record'
					 ,@TimeCheck = @timeCheck output;

				end;

				select
					@RegistrantProfileSID					= w.RegistrantProfileSID
				 ,@recordLabel									= N'#' + ltrim(@i) + N' | SID:' + ltrim(rp.RegistrantProfileSID)
				 ,@lastName											= rp.LastName
				 ,@firstName										= rp.FirstName
				 ,@commonName										= rp.CommonName
				 ,@middleNames									= rp.MiddleNames
				 ,@emailAddress									= rp.EmailAddress
				 ,@homePhone										= rp.HomePhone
				 ,@mobilePhone									= rp.MobilePhone
				 ,@isTextMessagingEnabled				= rp.IsTextMessagingEnabled
				 ,@genderLabel									= rp.GenderLabel
				 ,@namePrefixLabel							= rp.NamePrefixLabel
				 ,@birthDate										= rp.BirthDate
				 ,@deathDate										= rp.DeathDate
				 ,@userName											= rp.UserName
				 ,@password											= rp.Password
				 ,@streetAddress1								= rp.StreetAddress1
				 ,@streetAddress2								= rp.StreetAddress2
				 ,@streetAddress3								= rp.StreetAddress3
				 ,@cityName											= rp.CityName
				 ,@stateProvinceName						= rp.StateProvinceName
				 ,@postalCode										= rp.PostalCode
				 ,@countryName									= rp.CountryName
				 ,@registrantNo									= rp.RegistrantNo
				 ,@practiceRegisterLabel				= rp.PracticeRegisterLabel
				 ,@practiceRegisterSectionLabel = rp.PracticeRegisterSectionLabel
				 ,@personSID										= rp.PersonSID
				 ,@personEmailAddressSID				= rp.PersonEmailAddressSID
				 ,@applicationUserSID						= rp.ApplicationUserSID
				 ,@personMailingAddressSID			= rp.PersonMailingAddressSID
				 ,@namePrefixSID								= rp.NamePrefixSID
				 ,@genderSID										= rp.GenderSID
				 ,@citySID											= rp.CitySID
				 ,@stateProvinceSID							= rp.StateProvinceSID
				 ,@countrySID										= rp.CountrySID
				 ,@registrantSID								= rp.RegistrantSID
				 ,@legacyKey										= rp.LegacyKey
				 ,@updateTime										= rp.UpdateTime
				 ,@sourceFileName								= ifi.FileName
				from
					@work									w
				join
					stg.RegistrantProfile rp on w.RegistrantProfileSID = rp.RegistrantProfileSID
				join
					sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.IsClosedStatus = @OFF
				join
					sf.ImportFile					ifi on rp.ImportFileSID			 = ifi.ImportFileSID
				where
					w.ID = @i;

				if @@rowcount > 0 -- check if record is found
				begin
					set @isNew = @ON;
				end;
				else
				begin
					set @recordsProcessed += 1; -- consider skipped records processed
				end;

			end; -- END OF INNER LOOP (to avoid records with changing status)

			if @i > @maxRows break; -- if last record has change in status, break out of parent loop

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'  Source data selected'
				 ,@TimeCheck = @timeCheck output;

			end;

			if @termLabel is null
			begin

				exec sf.pTermLabel#Get
					@TermLabelSCD = 'PROCESSING'
				 ,@TermLabel = @termLabel output
				 ,@DefaultLabel = N'Processing'
				 ,@UsageNotes = N'A label reporting processing status prefix as records are being processed.  This value is extended by procedures to include an ID/Key of the specific record.';

			end;

			if @i = 1 or @i % @traceInterval = 0
			begin
				set @traceLog += @CRLF + sf.fPadR(N'Record #' + ltrim(@i) + ' ' + @termLabel, 60) + convert(nvarchar(19), sysdatetime(), 121);
			end;

			if @JobRunSID is not null -- for background jobs, check for cancellation requests on each row
			begin

				if exists
				(
					select
						1
					from
						sf.JobRun jr
					where
						jr.CancellationRequestTime is not null and jr.JobRunSID = @JobRunSID
				)
				begin
					set @isCancelled = @ON;
					set @traceLog += @CRLF + sf.fPadR(N'Cancel detected: Record #' + ltrim(@i), 60) + convert(nvarchar(19), sysdatetime(), 121);
				end;

				set @progressLabel = cast(@termLabel + @recordLabel as nvarchar(35));

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@TotalRecords = @maxRows
				 ,@TotalErrors = @totalErrors
				 ,@RecordsProcessed = @recordsProcessed
				 ,@CurrentProcessLabel = @progressLabel
				 ,@IsCancelled = @isCancelled;

			end;

			-- mark the source record as in progress to prevent double processing
			-- or data drift as the process completes it

			exec stg.pRegistrantProfile#Update
				@RegistrantProfileSID = @RegistrantProfileSID
			 ,@ProcessingStatusSID = @inProcessStatusSID;

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'Source marked in-process'
				 ,@TimeCheck = @timeCheck output;

			end;

			set @processingComments += (case when @Action =
				'VALIDATE.ONLY' then					 'VALIDATION' else 'PROCESSING' end
																 ) + N' RESULTS (' + convert(nvarchar(19), sf.fNow(), 121) + N' | ' + @execUserName
																 + N')';

			-- where a user name is not specified but an email address is supplied 
			-- along with registration information, set the username to the email 
			-- address to cause an account to be created

			if @userName is null and @emailAddress is not null and @practiceRegisterLabel is not null
			begin
				set @userName = @emailAddress;
			end;

			begin transaction; -- all updates succeed or fail together | or are rolled back if VALIDATE.ONLY action

			begin try -- START OF TRY BLOCK for processing single record

				-- call procedure to create or update the profile records (in SF) with
				-- validation and lookup of master table key values where not provided in source

				exec sf.pPerson#Set
					@UpdateRule = 'NEWONLY'
				 ,@LastName = @lastName										-- it may be possible to derive one after address is inserted (based on City)
				 ,@FirstName = @firstName
				 ,@CommonName = @commonName
				 ,@MiddleNames = @middleNames
				 ,@EmailAddress = @emailAddress
				 ,@IsTextMessagingEnabled = @isTextMessagingEnabled
				 ,@SignatureImage = @signatureImage
				 ,@IdentityPhoto = @identityPhoto
				 ,@GenderLabel = @genderLabel
				 ,@NamePrefixLabel = @namePrefixLabel
				 ,@BirthDate = @birthDate
				 ,@DeathDate = @deathDate
				 ,@UserName = @userName
				 ,@AuthenticationSystemID = @registrantNo -- registrant no is set by default as alternate login option
				 ,@Password = @password										-- must be passed as plain text!
				 ,@ApplicationGrantSID1 = @applicationGrantSID1
				 ,@ApplicationGrantSID2 = @applicationGrantSID2
				 ,@NamePrefixSID = @namePrefixSID
				 ,@GenderSID = @genderSID
				 ,@LegacyKey = @legacyKey
				 ,@UpdateTime = @updateTime
				 ,@SourceFileName = @sourceFileName
				 ,@PersonSID = @personSID output
				 ,@PersonEmailAddressSID = @personEmailAddressSID output
				 ,@ApplicationUserSID = @applicationUserSID output
				 ,@ReturnResultSet = @OFF
				 ,@DebugLevel = @DebugLevel;

				if @DebugLevel > 1
				begin

					exec sf.pDebugPrint
						@DebugString = N'  Person record set'
					 ,@TimeCheck = @timeCheck output;

				end;

				-- call the address update where address information is provided

				if @streetAddress1 is not null and @cityName is not null
				begin

					exec dbo.pPersonMailingAddress#Set
						@PersonSID = @personSID
					 ,@AutoAddCities = @ON
					 ,@IsAdminReviewRequired = @OFF
					 ,@StreetAddress1 = @streetAddress1
					 ,@StreetAddress2 = @streetAddress2
					 ,@StreetAddress3 = @streetAddress3
					 ,@CityName = @cityName
					 ,@StateProvinceName = @stateProvinceName
					 ,@StateProvinceCode = @stateProvinceCode
					 ,@PostalCode = @postalCode
					 ,@CountryName = @countryName
					 ,@EffectiveTime = @addressEffectiveTime
					 ,@DefaultCountrySID = @defaultCountrySID
					 ,@DefaultStateProvinceSID = @defaultStateProvinceSID
					 ,@CitySID = @citySID output
					 ,@StateProvinceSID = @stateProvinceSID output
					 ,@CountrySID = @countrySID output
					 ,@PersonMailingAddressSID = @personMailingAddressSID output;

					if @DebugLevel > 1
					begin

						exec sf.pDebugPrint
							@DebugString = N'  Mailing address set'
						 ,@TimeCheck = @timeCheck output;

					end;

				end;

				if (@homePhone is not null or @mobilePhone is not null)
				begin

					set @homePhone = sf.fFormatPhone(@homePhone);
					set @mobilePhone = sf.fFormatPhone(@mobilePhone);

					exec sf.pPerson#Update -- call the update whether phones are valid or not (to get error message logged)
						@PersonSID = @personSID
					 ,@HomePhone = @homePhone
					 ,@MobilePhone = @mobilePhone;

					if @DebugLevel > 0
					begin

						exec sf.pDebugPrint
							@DebugString = N'  Phone numbers updated'
						 ,@TimeCheck = @timeCheck output;

					end;

				end;

				-- process group assignments if any

				if @DebugLevel > 0
				begin

					exec sf.pDebugPrint
						@DebugString = N'  Setting person groups'
					 ,@TimeCheck = @timeCheck output;

				end;

				exec stg.[pRegistrantProfile#Process$Groups]
					@RegistrantProfileSID = @RegistrantProfileSID
				 ,@PersonSID = @personSID;

				if @DebugLevel > 0
				begin

					exec sf.pDebugPrint
						@DebugString = N'  Person groups set'
					 ,@TimeCheck = @timeCheck output;

				end;

				-- if a practice register is specified, obtain the section SID 
				-- to assign to the registration (via registrant#set)

				if @practiceRegisterLabel is not null
				begin

					exec dbo.pPracticeRegister#Lookup
						@PracticeRegisterIdentifier = @practiceRegisterLabel
					 ,@PracticeRegisterSID = @practiceRegisterSID output;

					if @practiceRegisterSID is null
					begin

						exec sf.pMessage#Get
							@MessageSCD = 'MasterTableValueNotFound'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
						 ,@Arg1 = @practiceRegisterLabel
						 ,@Arg2 = 'Practice Register'
						 ,@SuppressCode = @ON;

						raiserror(@errorText, 16, 1);

					end;

					if @practiceRegisterSectionLabel is not null
					begin

						exec dbo.pPracticeRegisterSection#Lookup
							@PracticeRegisterSectionIdentifier = @practiceRegisterSectionLabel
						 ,@PracticeRegisterSID = @practiceRegisterSID
						 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID output;

					end;
					else -- if no section specified get the default
					begin

						select
							@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
						from
							dbo.PracticeRegisterSection prs
						where
							prs.PracticeRegisterSID = @practiceRegisterSID;

					end;

					if @practiceRegisterSectionSID is null
					begin

						if @practiceRegisterSectionLabel is null
						begin
							set @practiceRegisterSectionLabel = N'[DEFAULT]';
						end;

						exec sf.pMessage#Get
							@MessageSCD = 'MasterTableValueNotFound'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
						 ,@Arg1 = @practiceRegisterSectionLabel
						 ,@Arg2 = 'Practice Register Section'
						 ,@SuppressCode = @ON;

						raiserror(@errorText, 16, 1);

					end;

				end;

				-- a registrant will be added if a number was provided for them, or
				-- if a "+" sign was provided, or if a practice register is passed

				if @registrantNo is null and @practiceRegisterLabel is not null
				begin
					set @registrantNo = '+';
				end;

				if @personSID is not null and @registrantNo is not null
				begin

					if @DebugLevel > 0
					begin

						exec sf.pDebugPrint
							@DebugString = N'  Setting registrant'
						 ,@TimeCheck = @timeCheck output;

					end;

					exec dbo.pRegistrant#Set
						@UpdateRule = 'NEWONLY'
					 ,@PersonSID = @personSID
					 ,@RegistrantNo = @registrantNo
					 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID -- if new applicant and no specific register identified, then Applicant->(Default) is assigned
					 ,@ArchivedTime = @archivedTime
					 ,@IsOnPublicRegistry = @isOnPublicRegistry
					 ,@DirectedAuditYearCompetence = @directedAuditYearCompetence
					 ,@DirectedAuditYearPracticeHours = @directedAuditYearPracticeHours
					 ,@LegacyKey = @legacyKey
					 ,@UpdateTime = @updateTime
					 ,@RegistrantSID = @registrantSID output;

					if @DebugLevel > 0
					begin

						exec sf.pDebugPrint
							@DebugString = N'  Registrant set'
						 ,@TimeCheck = @timeCheck output;

					end;

				end;

				-- extract and add credentials 

				if @registrantSID is not null
				begin

					if @DebugLevel > 0
					begin

						exec sf.pDebugPrint
							@DebugString = N'  Setting credentials'
						 ,@TimeCheck = @timeCheck output;

					end;

					exec stg.pRegistrantProfile#Process$Credentials
						@RegistrantProfileSID = @RegistrantProfileSID
					 ,@RegistrantSID = @registrantSID;

					if @DebugLevel > 0
					begin

						exec sf.pDebugPrint
							@DebugString = N'  Credentials set'
						 ,@TimeCheck = @timeCheck output;

					end;

				end;

				set @recordsProcessed += 1;

				if @DebugLevel > 1
				begin

					select
						rp.RegistrantProfileSID
					 ,sf.fFormatFileAsName(rp.LastName, rp.FirstName, rp.MiddleNames) SourceFileAsName
					 ,p.FileAsName																										TargetFileAsName
					 ,p.PersonSID
					 ,r.RegistrantSID
					 ,r.RegistrantNo
					 ,rp.EmailAddress																									SourceEmailAddress
					 ,p.PrimaryEmailAddress																						TargetEmailAddress
					 ,rp.UserName																											SourceUserName
					 ,au.UserName																											TargetUserName
					 ,rp.Password																											SourcePassword
					 ,au.GlassBreakPassword																						TargetPassword
					 ,rp.StreetAddress1 + ' ' + rp.CityName + ' ' + rp.PostalCode			SourceAddress
					 ,pma.StreetAddress1 + ' ' + cty.CityName + ' ' + pma.PostalCode	TargetAddress
					 ,rp.HomePhone																										SourceHomePhone
					 ,p.HomePhone																											TargetHomePhone
					 ,rp.RegistrantNo																									SourceRegistrantNo
					 ,rp.PracticeRegisterLabel																				SourceRegister
					 ,reg.PracticeRegisterLabel																				TargetRegister
					 ,rp.PracticeRegisterSectionLabel																	SourceRegisterSection
					 ,reg.PracticeRegisterSectionLabel																TargetRegisterSection
					 ,r.RegistrantSID																									TargetRegistrantSID
					 ,rp.QualifyingCredentialLabel																		SourceQualifyingCredential
					 ,rc.CredentialLabel																							TargetQualifyingCredential
					 ,rp.PersonGroupLabel1																						SourcePersonGroup
					 ,pgm.PersonGroupLabel																						TargetPersonGroup
					 ,@processingComments																							ProcessingComments
					from
						stg.RegistrantProfile																					 rp
					left outer join
						sf.vPerson																										 p on @personSID = p.PersonSID
					left outer join
						dbo.PersonMailingAddress																			 pma on p.PersonSID = pma.PersonSID
																																									and
																																									(
																																										@personMailingAddressSID is null or pma.PersonMailingAddressSID = @personMailingAddressSID
																																									)
					left outer join
						sf.ApplicationUser																						 au on @personSID = au.PersonSID
					left outer join
						dbo.City																											 cty on pma.CitySID = cty.CitySID
					left outer join
						dbo.Registrant																								 r on @registrantSID = r.RegistrantSID
					left outer join
						dbo.vRegistrantCredential																			 rc on r.RegistrantSID = rc.RegistrantSID and rc.CredentialLabel = rp.QualifyingCredentialLabel
					left outer join
						sf.vPersonGroupMember																					 pgm on p.PersonSID = pgm.PersonSID and pgm.PersonGroupLabel = rp.PersonGroupLabel1 -- source column must use label value (not SID: override or legacy key)
					outer apply dbo.fRegistrant#RegistrationCurrent(r.RegistrantSID) reg
					where
						rp.RegistrantProfileSID = @RegistrantProfileSID;

				end;

				-- if only validating the record then rollback
				-- the transaction; otherwise commit

				if @Action = 'VALIDATE.ONLY'
				begin
					if @@trancount > 0 rollback;

					if @successText is null
					begin

						exec sf.pMessage#Get
							@MessageSCD = 'RegistrantProfileValidated'
						 ,@MessageText = @successText output
						 ,@DefaultText = N'Ok - Registrant Profile Validated'
						 ,@SuppressCode = @ON;

					end;

					set @processingComments += @CRLF + @CRLF + @successText;

					exec stg.pRegistrantProfile#Update
						@RegistrantProfileSID = @RegistrantProfileSID
					 ,@ProcessingStatusSID = @validatedStatusSID
					 ,@ProcessingComments = @processingComments;

				end;
				else
				begin

					if @successText is null
					begin

						exec sf.pMessage#Get
							@MessageSCD = 'RegistrantProfileApplied'
						 ,@MessageText = @successText output
						 ,@DefaultText = N'Ok - Registrant Profile Applied'
						 ,@SuppressCode = @ON;

					end;

					if @password is not null
					begin
						set @password = N'*************************'; -- in case of plain text password, overwrite on successful processing
					end;

					set @processingComments += @CRLF + @CRLF + @successText;

					exec stg.pRegistrantProfile#Update
						@RegistrantProfileSID = @RegistrantProfileSID
					 ,@ProcessingStatusSID = @processedStatusSID
					 ,@ProcessingComments = @processingComments
					 ,@PersonSID = @personSID -- write back key values of records found, updated or added
					 ,@PersonEmailAddressSID = @personEmailAddressSID
					 ,@UserName = @userName
					 ,@ApplicationUserSID = @applicationUserSID
					 ,@PersonMailingAddressSID = @personMailingAddressSID
					 ,@RegistrantSID = @registrantSID
					 ,@NamePrefixSID = @namePrefixSID
					 ,@GenderSID = @genderSID
					 ,@CitySID = @citySID
					 ,@StateProvinceSID = @stateProvinceSID
					 ,@CountrySID = @countrySID
					 ,@Password = @password;

					commit; -- success! commit all changes when processing
				end;

				if @DebugLevel > 0
				begin

					exec sf.pDebugPrint
						@DebugString = N'  Source record marked complete'
					 ,@TimeCheck = @timeCheck output;

				end;

			end try -- END OF TRY BLOCK for processing single record
			begin catch

				-- store the error text into processing comments and
				-- increment the error count

				set @errorText = sf.fErrorStripXML(error_message()); -- capture the error message to report back (strip out XML tags)
				set @processingComments = isnull(@processingComments + @CRLF + @CRLF, N'') + N'ERROR: ' + @errorText;
				set @totalErrors += 1;

				if @@trancount > 0 and xact_state() <> 0 rollback; -- reverse any partial update when errors encountered

				exec stg.pRegistrantProfile#Update -- record errors logged to source record
					@RegistrantProfileSID = @RegistrantProfileSID
				 ,@ProcessingStatusSID = @errorStatusSID
				 ,@ProcessingComments = @processingComments;

			end catch;

		end; -- END OF MAIN PROCESSING LOOP

		-- where validating only, reset the next application and registrant sequence 
		-- values since these were rolled back and should be available for re-use

		if @Action = 'VALIDATE.ONLY'
		begin
			exec dbo.pApplicantNo#Reset;
			exec dbo.pRegistrantNo#Reset;
		end;

		-- update job with final totals

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @recordsProcessed = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoPendingRecordsFound'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'No records were found requiring processing. (This is not an error.)'
				 ,@SuppressCode = @ON;

				set @traceLog = N'(No pending records found.)';
			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'Registrant Profile Processing'
				 ,@SuppressCode = @ON;

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @recordsProcessed
			 ,@RecordsProcessed = @recordsProcessed
			 ,@TotalErrors = @totalErrors
			 ,@TraceLog = @traceLog -- post detailed summary report to trace log
			 ,@ResultMessage = @resultMessage;

			set @traceLog += @CRLF + sf.fPadR(N'Final job update OK', 60) + convert(nvarchar(19), sysdatetime(), 121);

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'  Job summary written'
				 ,@TimeCheck = @timeCheck output;

			end;

		end;
		else if @JobRunSID is null
		begin
			set @traceLog += @CRLF + sf.fPadR(N'Process completed OK', 60) + convert(nvarchar(19), sysdatetime(), 121);
		end;

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'  Processing complete'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- if a single record was requested and an error occurred - raise it

		if @mode = 'SINGLE' and @totalErrors > 0
		begin
			raiserror(@processingComments, 16, 1);
		end;
		else if @JobRunSID is null
		begin
			exec sf.pLinePrint @TextToPrint = @traceLog;	-- print trace log to console if no error and not within job
		end;

	end try
	begin catch

		-- errors occurring here will be logged by the job executor

		if @@trancount > 0 and xact_state() <> 0 -- full rollback
		begin
			rollback;
		end;

		-- retrieve and format error text

		if @JobRunSID is not null
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOB.FAILED'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'*** JOB FAILED'
			 ,@UsageNotes = N'A label reporting failure of jobs (normally accompanied by error report text from the database).';

			set @errorText = @termLabel + isnull(N' AT : ' + @progressLabel + @CRLF, N'') + @CRLF;
		end;
		else -- otherwise ensure error text is reset to blank
		begin
			set @errorText = N'';

			if @mode = 'SINGLE'
			begin
				set @processingComments = N'';
			end;

		end;

		set @errorText += sf.fErrorStripXML(error_message());
		set @processingComments += @CRLF + @CRLF + N'ERROR: ' + @errorText;

		-- ensure the last record is marked as an error

		if @RegistrantProfileSID is not null
		begin

			exec stg.pRegistrantProfile#Update
				@RegistrantProfileSID = @RegistrantProfileSID
			 ,@ProcessingStatusSID = @errorStatusSID
			 ,@ProcessingComments = @processingComments;

		end;

		-- update job log for failure status and post logging/tracing information

		if @JobRunSID is not null
		begin

			set @totalErrors += 1;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalErrors = @totalErrors
			 ,@ResultMessage = @errorText
			 ,@TraceLog = @traceLog -- post result message to trace log for debugging
			 ,@IsFailed = @ON;

		end;
		else
		begin
			set @traceLog += @CRLF + @CRLF + isnull(@processingComments, '(Processing comments are empty)');
			exec sf.pLinePrint @TextToPrint = @traceLog;
		end;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
