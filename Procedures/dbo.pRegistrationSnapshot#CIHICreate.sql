SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationSnapshot#CIHICreate
	@RegistrationSnapshotSID int = null					-- ID of snapshot to be processed, when NULL next un-processed
 ,@TotalRecordCount				 int = null output	-- count of records processed (includes errors)
 ,@TotalErrorCount				 int = null output	-- count of errors encountered
 ,@JobRunSID							 int = null					-- sf.JobRun record to update on asynchronous calls
 ,@StopOnError						 bit = 0						-- controls whether procedure terminate on first error; s/b OFF on async calls
 ,@RecordLimit						 int = 9999999			-- can be set to lower value to terminate processing early for testing
 ,@ReturnSelect						 bit = 0						-- when 1 output values are returned as a dataset
 ,@DebugLevel							 int = 0						-- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Registration Snapshot - CIHI Create
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure generates a Snapshot conforming to CIHI requirements for reporting healthcare organizations
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
This procedure generates dbo.RegistrationProfile records matching the current format required by CIHI.  The procedure is called to
create a new snapshot.  To updated the CIHI code values with the latest values in the master tables (e.g. Practice Scope Codes, 
ISO Numbers for address provinces etc.) - call pRegistrationSnapshot#CIHIUpdate

The procedure is called directly from pRegistrationSnapshot#Insert where the queued-time is not future dated. The procedure is
also called from a nightly schedule job - in which case no @RegistrationSnapshotSID is provided but a @JobRunSID is.  In 
this context the procedure looks for the next unprocessed CIHI snapshot record where the queued time has been reached.  If no 
record is found, no error results and the batch job re-runs the next evening. This method is used for queuing up the CIHI
generation jobs weeks (or even months) before the preferred snapshot date.

Synchronous Calling only for Debugging!
---------------------------------------
This procedure supports being called asynchronously through the built-in job system. Asynchronous mode should always be used
when invoked from the user interface of the application.  Use the pJob#Call procedure:

	exec sf.pJob#Call @JobSCD = 'dbo.pRegistrationSnapshot#CIHICreate'

Errors in Parameters/Configuration Will FAIL Job
------------------------------------------------
This routine must not be invoked with any transaction pending. If a non-zero @@trancount is detected at startup, an error is 
returned and when called asynchronously, this will fail the job. The procedure also performs several checks of parameter
values and the configuration to ensure the snapshot can be successfully created. Errors arising in these validations will
fail the job and no profile records will be created.  The error is reported in the associated job record.

Example
-------
<TestHarness>
  <Test Name = "NoJob10" IsDefault ="true" Description="Executes the procedure with a synchronous call for 10 records (No Job)">
    <SQLScript>
      <![CDATA[

declare
	@registrationSnapshotSID		 int
 ,@registrationSnapshotTypeSID int

select
	@registrationSnapshotTypeSID = rst.RegistrationSnapshotTypeSID
from
	dbo.RegistrationSnapshotType rst
where
	rst.RegistrationSnapshotTypeSCD = 'CIHI';

if @registrationSnapshotTypeSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationSnapshot#Insert
		 @RegistrationSnapshotSID = @registrationSnapshotSID output
		,@RegistrationSnapshotTypeSID = @registrationSnapshotTypeSID
		,@Description = N'This is a test CIHI snapshot.' -- "This is a test .." avoids automatic background call from SPROC!

	exec dbo.pRegistrationSnapshot#CIHICreate
		@RegistrationSnapshotSID = @registrationSnapshotSID
	 ,@StopOnError = 1
	 ,@RecordLimit = 10
	 ,@ReturnSelect = 1
	 ,@DebugLevel = 3;

	select
		rs.RegistrationSnapshotSID
	 ,rs.RegistrationSnapshotLabel
	 ,rs.SnapshotStatusLabel
	 ,rs.RegistrationYearLabel
	 ,rs.QueuedDateTimeCTZ
	 ,rs.QueuedTime
	 ,rs.ProfileCount
	 ,rs.InValidCount
	from
		dbo.vRegistrationSnapshot rs
	where
		rs.RegistrationSnapshotSID = @registrationSnapshotSID;

	select
		rp.RegistrantLabel
	 ,rp.IsInvalid
	 ,rp.MessageText
	from
		dbo.vRegistrationProfile rp
	where
		rp.RegistrationSnapshotSID = @registrationSnapshotSID;

end;
		]]>
    </SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="NotEmptyResultSet" ResultSet="3" />
			<Assertion Type="ExecutionTime" Value="00:15:00"/>
		</Assertions>
  </Test>
  <Test Name = "Job100" Description="Executes the procedure with an asynchronous call (full snapshot)">    
		<SQLScript>
      <![CDATA[

declare
	@registrationSnapshotSID		 int
 ,@registrationSnapshotTypeSID int
 ,@parameters									 xml;

select
	@registrationSnapshotTypeSID = rst.RegistrationSnapshotTypeSID
from
	dbo.RegistrationSnapshotType rst
where
	rst.RegistrationSnapshotTypeSCD = 'CIHI';

if @registrationSnapshotTypeSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationSnapshot#Insert
		@RegistrationSnapshotSID = @registrationSnapshotSID output
	 ,@RegistrationSnapshotTypeSID = @registrationSnapshotTypeSID
	 ,@Description = N'This is a test CIHI snapshot.' -- "This is a test .." avoids automatic background call from SPROC!

	set @parameters = cast(N'<Parameters p1="' + ltrim(@registrationSnapshotSID) + '"/>' as xml);

	exec sf.pJob#Call
		@JobSCD = 'dbo.pRegistrationSnapshot#CIHICreate'
	 ,@Parameters = @parameters;

	waitfor delay '00:00:03';

	select
		jr.JobSCD
	 ,jr.CurrentProcessLabel
	 ,jr.JobStatusSCD
	 ,jr.EstimatedMinutesRemaining
	 ,jr.TotalRecords
	 ,jr.RecordsProcessed
	 ,jr.TotalErrors
	 ,jr.RecordsRemaining
	 ,jr.EstimatedMinutesRemaining
	 ,jr.RecordsPerMinute
	 ,jr.DurationMinutes
	 ,jr.ResultMessage
	from
		sf.vJobRun jr
	where
		jr.JobRunSID =
	(
		select top (1)
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			jr.JobSCD = 'dbo.pRegistrationSnapshot#CIHICreate'
		order by
			jr.JobRunSID desc
	);

	select
		jre.DataSource
	 ,jre.MessageText
	from
		sf.JobRunError jre
	where
		jre.JobRunSID =
	(
		select top (1)
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			jr.JobSCD = 'dbo.pRegistrationSnapshot#CIHICreate'
		order by
			jr.JobRunSID desc
	)
	order by
		jre.JobRunErrorSID;

	select
		rs.RegistrationSnapshotSID
	 ,rs.RegistrationSnapshotLabel
	 ,rs.SnapshotStatusLabel
	 ,rs.RegistrationYearLabel
	 ,rs.QueuedDateTimeCTZ
	 ,rs.QueuedTime
	 ,rs.ProfileCount
	 ,rs.InValidCount
	from
		dbo.vRegistrationSnapshot rs
	where
		rs.RegistrationSnapshotSID = @registrationSnapshotSID;

	select
		rp.RegistrantLabel
	 ,rp.IsInvalid
	 ,rp.MessageText
	from
		dbo.vRegistrationProfile rp
	where
		rp.RegistrationSnapshotSID = @registrationSnapshotSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:15:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrationSnapshot#CIHICreate'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							nvarchar(4000)										-- message text for business rule errors
	 ,@ON											bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF										bit							 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@resultMessage					nvarchar(4000)										-- summary of job result
	 ,@isCancelled						bit							 = cast(0 as bit) -- checks for cancellation request on async job calls  
	 ,@registrationProfileSID int																-- key of next record to process
	 ,@queuedTime							datetimeoffset(7)									-- date snapshot is scheduled to be generated (earliest time)
	 ,@asOfTime								datetime													-- time in UTZ to locate active employment records
	 ,@jurisdictionNo					smallint													-- ISO number of the province of jurisdiction
	 ,@defaultCountryISO			smallint													-- the ISO number of the default country in this configuration
	 ,@recordsProcessed				int							 = 0							-- records processed for a single entity 
	 ,@registrantSID					int																-- key of current registrant being processed
	 ,@registrantNo						varchar(50)												-- member number of registrant being processed
	 ,@registrantPracticeSID	int																-- latest employment status record available
	 ,@registrationYear				smallint													-- year of the snapshot
	 ,@registrantCredential1	int																-- key of qualifying registration credential
	 ,@registrantCredential2	int																-- key of related education credential
	 ,@timeCheck							datetimeoffset										-- traces debug interval times
	 ,@dataSource							nvarchar(257)											-- traces source of query for debugging
	 ,@currentProcessLabel		nvarchar(35);											-- label for stage of work

	-- ensure output parameters are set for all code paths

	set @TotalRecordCount = 0;
	set @TotalErrorCount = 0;

	begin try

		if @DebugLevel is null -- debug level defaults to off
		begin
			set @DebugLevel = 0;
		end;

		if @StopOnError is null -- stop on error defaults off
		begin
			set @StopOnError = @OFF;
		end;

		if @RecordLimit is null -- record limit defaults to 10M
		begin
			set @RecordLimit = 9999999;
		end;

		set @currentProcessLabel = N'Validating configuration';

		if @JobRunSID is not null -- if call is async, update the job run record 
		begin

			set @ReturnSelect = 0;

			update
				dbo.RegistrationSnapshot
			set
				JobRunSID = @JobRunSID
			where
				RegistrationSnapshotSID = @RegistrationSnapshotSID; -- write job key back to header to establish status link and avoid duplicate processing

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = @currentProcessLabel;

		end;
		else if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = @currentProcessLabel
			 ,@TimeCheck = @timeCheck output;

		end;

		-- validate parameters and startup values

		-- if called from job schedule no snapshot key
		-- will be provided so lookup the next to process

		if @RegistrationSnapshotSID is null
		begin

			select
				@RegistrationSnapshotSID = min(@RegistrationSnapshotSID)
			from
				dbo.RegistrationSnapshot		 rs
			join
				dbo.RegistrationSnapshotType rst on rs.RegistrationSnapshotTypeSID = rst.RegistrationSnapshotTypeSID
			where
				rst.RegistrationSnapshotTypeSCD = 'CIHI' and rs.LastCodeUpdateTime is null -- not processed
				and rs.QueuedTime								<= sysdatetimeoffset();

		end;

		if @RegistrationSnapshotSID is not null or @JobRunSID is null
		begin

			select
				@queuedTime				= rs.QueuedTime
			 ,@registrationYear = rs.RegistrationYear
			from
				dbo.RegistrationSnapshot rs
			where
				rs.RegistrationSnapshotSID = @RegistrationSnapshotSID;

			if @queuedTime is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Registration Snapshot'
				 ,@Arg2 = @RegistrationSnapshotSID;

				raiserror(@errorText, 18, 1);
			end;

			if @queuedTime > sysdatetimeoffset()
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'InvalidSnapshotStart'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The queued time (%1) is in the future.  This procedure was called too early.'
				 ,@Arg1 = @queuedTime;

				raiserror(@errorText, 18, 1);

			end;

			select
				@TotalRecordCount = count(1)
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID;

			if @TotalRecordCount > 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'AlreadyCreated'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Records have already been created for this %1. Record ID = "%2".'
				 ,@Arg1 = 'snapshot'
				 ,@Arg2 = @RegistrationSnapshotSID;

				raiserror(@errorText, 18, 1);

			end;

			select
				@jurisdictionNo		 = sp.ISONumber
			 ,@defaultCountryISO = c.ISONumber
			from
				dbo.Country				c
			join
				dbo.StateProvince sp on c.CountrySID = sp.CountrySID and sp.IsDefault = @ON
			where
				c.IsDefault = @ON;

			if @jurisdictionNo is null or @defaultCountryISO is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
				 ,@Arg1 = '"Reporting Jurisdiction (default Province or Country ISO Code)"';

				raiserror(@errorText, 17, 1);
			end;

			if (select isnull (sf.fConfigParam#Value('CIHIOccupationID'), 'X')) = 'X'
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
				 ,@Arg1 = '"CIHI Occupation Identifier"';

				raiserror(@errorText, 17, 1);
			end;

			set @currentProcessLabel = N'Creating snapshot ...';
			set @dataSource = N'BaseProfile';

			if @JobRunSID is not null
			begin

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @currentProcessLabel;

			end;
			else if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = @currentProcessLabel
				 ,@TimeCheck = @timeCheck output;

			end;

			insert
				dbo.RegistrationProfile
			(
				RegistrationSnapshotSID
			 ,JursidictionStateProvinceISONumber
			 ,RegistrantSID
			 ,RegistrantNo
			 ,GenderSCD
			 ,BirthDate
			 ,PersonMailingAddressSID
			 ,ResidenceStateProvinceISONumber
			 ,ResidencePostalCode
			 ,ResidenceCountryISONumber
			 ,ResidenceIsDefaultCountry
			 ,RegistrationSID
			 ,IsActivePractice
			)
			select top (@RecordLimit)
				@RegistrationSnapshotSID
			 ,@jurisdictionNo										JursidictionStateProvinceISONumber
			 ,reg.RegistrantSID
			 ,r.RegistrantNo
			 ,g.GenderSCD
			 ,p.BirthDate
			 ,ma.PersonMailingAddressSID
			 ,ma.StateProvinceISONumber					ResidenceStateProvinceISONumber
			 ,ma.PostalCode											ResidencePostalCode
			 ,ma.CountryISONumber								ResidenceCountryISONumber
			 ,isnull(ma.CountryIsDefault, @OFF) IsDefaultCountry
			 ,x.RegistrationSID									RegistrationSID
			 ,pr.IsActivePractice
			from
				dbo.fRegistrant#LatestRegistration$SID(-1, null)				 x -- retrieve registration in effect  now
			join
				dbo.Registration																				 reg on x.RegistrationSID = reg.RegistrationSID
			join
				dbo.PracticeRegisterSection															 prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister																		 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID and pr.IsActivePractice = @ON -- only include "Practicing" registers
			join
				dbo.Registrant																					 r on reg.RegistrantSID = r.RegistrantSID
			join
				sf.Person																								 p on r.PersonSID = p.PersonSID
			join
				sf.Gender																								 g on p.GenderSID = g.GenderSID
			outer apply dbo.fPersonMailingAddress#Current(r.PersonSID) ma
			order by
				r.RegistrantNo;

			set @TotalRecordCount = @@rowcount;

			-- to support initial evaluation, write the
			-- current system date to the parent row 

			update
				dbo.RegistrationSnapshot
			set
				UpdateTime = sysdatetimeoffset()
			where
				RegistrationSnapshotSID = @RegistrationSnapshotSID;

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'Profiles created'
				 ,@TimeCheck = @timeCheck output;

			end;

			-- set time to use to check for expired employers; has no effect
			-- if client configuration does not use expiry times on employment

			set @asOfTime = sf.fNow();

			select -- get first key to process
				@registrationProfileSID = min(rp.RegistrationProfileSID)
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID;

			set @recordsProcessed = 0;

			-- process each record

			while isnull(@registrationProfileSID, 0) <> 0 and @isCancelled = @OFF and @recordsProcessed < @RecordLimit
			begin

				select
					@registrantSID = rp.RegistrantSID
				 ,@registrantNo	 = rp.RegistrantNo
				from
					dbo.RegistrationProfile rp
				where
					rp.RegistrationProfileSID = @registrationProfileSID;

				set @currentProcessLabel = N'Processing: #' + @registrantNo + N' (' + ltrim(@recordsProcessed + 1) + N' of ' + ltrim(@TotalRecordCount) + N')';

				if @JobRunSID is not null
				begin

					-- check if a cancellation request occurred
					-- where job is running in async mode

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
					end;

					exec sf.pJobRun#Update
						@JobRunSID = @JobRunSID
					 ,@CurrentProcessLabel = @currentProcessLabel
					 ,@TotalRecords = @TotalRecordCount
					 ,@RecordsProcessed = @recordsProcessed
					 ,@TotalErrors = @TotalErrorCount
					 ,@IsCancelled = @isCancelled;

				end;

				if @isCancelled = @OFF
				begin

					if @DebugLevel > 0
					begin

						exec sf.pDebugPrint
							@DebugString = @currentProcessLabel
						 ,@TimeCheck = @timeCheck output;

					end;

					-- process each record - capturing errors to
					-- the logging table

					begin try


						set @dataSource = N'Employment';

						if @DebugLevel > 1
						begin

							exec sf.pDebugPrint
								@DebugString = @dataSource
							 ,@TimeCheck = @timeCheck output;

						end;

						-- get latest employment status record (look last 2 years)

						select
							@registrantPracticeSID = max(regP.RegistrantPracticeSID)
						from
							dbo.RegistrantPractice regP
						where
							regP.RegistrantSID = @registrantSID and regP.RegistrationYear >= (@registrationYear - 1);

						if @@rowcount = 0 or @registrantPracticeSID is null
						begin
							set @registrantPracticeSID = -1;
						end;

						update -- set all columns for employment 
							rp
						set
							rp.RegistrantPracticeSID = regP.RegistrantPracticeSID
						 ,rp.EmploymentStatusCode = es.EmploymentStatusCode
						 ,rp.Employment1RegistrantEmploymentSID = emp.Rank1RegistrantEmploymentSID
						 ,rp.Employment1TypeCode = emp.Rank1EmploymentTypeCode
						 ,rp.Employment1StateProvinceISONumber = emp.Rank1OrgStateProvinceISONumber
						 ,rp.Employment1CountryISONumber = emp.Rank1OrgCountryISONumber
						 ,rp.Employment1IsDefaultCountry = cast(case when emp.Rank1OrgCountryISONumber = @defaultCountryISO then 1 else 0 end as bit)
						 ,rp.Employment1PostalCode = emp.Rank1OrgPostalCode
						 ,rp.Employment1OrgTypeCode = emp.Rank1OrgTypeCode
						 ,rp.Employment1PracticeAreaCode = emp.Rank1PracticeAreaCode
						 ,rp.Employment1PracticeScopeCode = emp.Rank1PracticeScopeCode
						 ,rp.Employment1RoleCode = emp.Rank1EmploymentRoleCode
						 ,rp.Employment2RegistrantEmploymentSID = emp.Rank2RegistrantEmploymentSID
						 ,rp.Employment2TypeCode = emp.Rank2EmploymentTypeCode
						 ,rp.Employment2StateProvinceISONumber = emp.Rank2OrgStateProvinceISONumber
						 ,rp.Employment2CountryISONumber = emp.Rank2OrgCountryISONumber
						 ,rp.Employment2IsDefaultCountry = cast(case when emp.Rank2OrgCountryISONumber = @defaultCountryISO then 1 else 0 end as bit)
						 ,rp.Employment2PostalCode = emp.Rank2OrgPostalCode
						 ,rp.Employment2OrgTypeCode = emp.Rank2OrgTypeCode
						 ,rp.Employment2PracticeAreaCode = emp.Rank2PracticeAreaCode
						 ,rp.Employment2PracticeScopeCode = emp.Rank2PracticeScopeCode
						 ,rp.Employment2RoleCode = emp.Rank2EmploymentRoleCode
						 ,rp.Employment3RegistrantEmploymentSID = emp.Rank3RegistrantEmploymentSID
						 ,rp.Employment3TypeCode = emp.Rank3EmploymentTypeCode
						 ,rp.Employment3StateProvinceISONumber = emp.Rank3OrgStateProvinceISONumber
						 ,rp.Employment3CountryISONumber = emp.Rank3OrgCountryISONumber
						 ,rp.Employment3IsDefaultCountry = cast(case when emp.Rank3OrgCountryISONumber = @defaultCountryISO then 1 else 0 end as bit)
						 ,rp.Employment3PostalCode = emp.Rank3OrgPostalCode
						 ,rp.Employment3OrgTypeCode = emp.Rank3OrgTypeCode
						 ,rp.Employment3PracticeAreaCode = emp.Rank3PracticeAreaCode
						 ,rp.Employment3PracticeScopeCode = emp.Rank3PracticeScopeCode
						 ,rp.Employment3RoleCode = emp.Rank3EmploymentRoleCode
						 ,rp.EmploymentCount = (case
																			when isnull(emp.Rank3RegistrantEmploymentSID, -1) <> -1 then 3
																			when isnull(emp.Rank2RegistrantEmploymentSID, -1) <> -1 then 2
																			when isnull(emp.Rank1RegistrantEmploymentSID, -1) <> -1 then 1
																			else 0
																		end
																	 )
						 ,rp.PracticeHours = (case
																		when regP.TotalPracticeHours > 0 then regP.TotalPracticeHours -- if conversion hours are defined for the year, use them
																		else
																			isnull(
																			(
																				select
																					sum(re.PracticeHours) -- otherwise sum up hours from employment records
																				from
																					dbo.RegistrantEmployment re
																				where
																					re.RegistrantSID = rp.RegistrantSID and re.RegistrationYear = (rs.RegistrationYear - 1) -- only previous year - all employers (not just top 3)
																			)
																						 ,0
																						)
																	end
																 )
						from
							dbo.RegistrationProfile																																			rp
						join
							dbo.RegistrationSnapshot																																		rs on rp.RegistrationSnapshotSID = rs.RegistrationSnapshotSID
						left outer join
							dbo.RegistrantPractice																																			regP on regP.RegistrantPracticeSID = @registrantPracticeSID
						left outer join
							dbo.EmploymentStatus																																				es on regP.EmploymentStatusSID = es.EmploymentStatusSID
						outer apply dbo.fRegistrantEmployment#Flat3(rp.RegistrantSID, rs.RegistrationYear, @asOfTime) emp
						where
							rp.RegistrationProfileSID = @registrationProfileSID;

						set @dataSource = N'QualifyingEducation';
						set @registrantCredential1 = null;
						set @registrantCredential2 = null;

						if @DebugLevel > 1
						begin

							exec sf.pDebugPrint
								@DebugString = @dataSource
							 ,@TimeCheck = @timeCheck output;

						end;

						update -- set all columns for qualifying education
							rp
						set
							Education1RegistrantCredentialSID = ed.RegistrantCredentialSID
						 ,Education1CredentialCode = ed.CredentialCode
						 ,Education1GraduationYear = year(ed.EffectiveTime)
						 ,Education1StateProvinceISONumber = ed.ISONumber
						 ,rp.Education1CountryISONumber = ed.CountryISONumber
						 ,Education1IsDefaultCountry = ed.IsDefaultCountry
						from
							dbo.RegistrationProfile rp
						join
						(
							select
								rc.RegistrantSID
							 ,rc.RegistrantCredentialSID
							 ,c.CredentialCode
							 ,rc.EffectiveTime	-- use as basis for graduation year
							 ,sp.ISONumber
							 ,ctry.ISONumber																														CountryISONumber
							 ,ctry.IsDefault																														IsDefaultCountry
							 ,row_number() over (order by rc.EffectiveTime, rc.RegistrantCredentialSID) RankOrder
							from
								dbo.RegistrantCredential		rc
							join
								dbo.QualifyingCredentialOrg qco on rc.CredentialSID		 = qco.CredentialSID and rc.OrgSID = qco.OrgSID
							join
								dbo.Credential							c on rc.CredentialSID			 = c.CredentialSID and c.IsSpecialization = @OFF
							join
								dbo.Org											o on rc.OrgSID						 = o.OrgSID
							join
								dbo.City										cty on o.CitySID					 = cty.CitySID
							join
								dbo.StateProvince						sp on cty.StateProvinceSID = sp.StateProvinceSID
							join
								dbo.Country									ctry on sp.CountrySID			 = ctry.CountrySID
							where
								rc.RegistrantSID = @registrantSID
						)													ed on ed.RankOrder = 1
						where
							rp.RegistrationProfileSID = @registrationProfileSID;

						set @dataSource = N'RelatedEducation';

						if @DebugLevel > 1
						begin

							exec sf.pDebugPrint
								@DebugString = @dataSource
							 ,@TimeCheck = @timeCheck output;

						end;

						select
							@registrantCredential1 = rp.Education1RegistrantCredentialSID -- capture qualifying key to avoid reporting it twice
						from
							dbo.RegistrationProfile rp
						where
							rp.RegistrationProfileSID = @registrationProfileSID;

						if @registrantCredential1 is null
						begin
							set @registrantCredential1 = -1;
						end;

						update -- set all columns for related education
							rp
						set
							Education2RegistrantCredentialSID = ed.RegistrantCredentialSID
						 ,Education2CredentialCode = ed.CredentialCode
						 ,Education2GraduationYear = year(ed.EffectiveTime)
						 ,Education2StateProvinceISONumber = ed.ISONumber
						 ,rp.Education2CountryISONumber = ed.CountryISONumber
						 ,Education2IsDefaultCountry = ed.IsDefaultCountry
						from
							dbo.RegistrationProfile rp
						join
						(
							select
								rc.RegistrantSID
							 ,rc.RegistrantCredentialSID
							 ,c.CredentialCode
							 ,rc.EffectiveTime
							 ,sp.ISONumber
							 ,ctry.ISONumber			CountryISONumber
							 ,ctry.IsDefault			IsDefaultCountry
							 ,row_number() over (order by
																		 c.CredentialCode desc	-- highest CIHI code is selected first
																		,rc.EffectiveTime
																		,rc.RegistrantCredentialSID
																	) RankOrder
							from
								dbo.RegistrantCredential rc
							join
								dbo.Credential					 c on rc.CredentialSID			= c.CredentialSID and c.IsRelatedToProfession = @ON and c.IsSpecialization = @OFF
							left outer join
								dbo.Org									 o on rc.OrgSID							= o.OrgSID
							left outer join
								dbo.City								 cty on o.CitySID						= cty.CitySID
							left outer join
								dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
							left outer join
								dbo.Country							 ctry on sp.CountrySID			= ctry.CountrySID
							where
								rc.RegistrantSID = @registrantSID and rc.RegistrantCredentialSID <> @registrantCredential1	-- avoid re-reporting the qualifying credential
						)													ed on ed.RankOrder = 1
						where
							rp.RegistrationProfileSID = @registrationProfileSID;

						set @dataSource = N'NonRelatedEducation';

						if @DebugLevel > 1
						begin

							exec sf.pDebugPrint
								@DebugString = @dataSource
							 ,@TimeCheck = @timeCheck output;

						end;

						select
							@registrantCredential2 = rp.Education1RegistrantCredentialSID -- capture qualifying key to avoid reporting it again
						from
							dbo.RegistrationProfile rp
						where
							rp.RegistrationProfileSID = @registrationProfileSID;

						if @registrantCredential2 is null
						begin
							set @registrantCredential2 = -1;
						end;

						update -- set all columns for non-related education
							rp
						set
							Education3RegistrantCredentialSID = ed.RegistrantCredentialSID
						 ,Education3CredentialCode = ed.CredentialCode
						 ,Education3GraduationYear = year(ed.EffectiveTime)
						 ,Education3StateProvinceISONumber = ed.ISONumber
						 ,rp.Education3CountryISONumber = ed.CountryISONumber
						 ,Education3IsDefaultCountry = ed.IsDefaultCountry
						from
							dbo.RegistrationProfile rp
						join
						(
							select
								rc.RegistrantSID
							 ,rc.RegistrantCredentialSID
							 ,c.CredentialCode
							 ,rc.EffectiveTime
							 ,sp.ISONumber
							 ,ctry.ISONumber			CountryISONumber
							 ,ctry.IsDefault			IsDefaultCountry
							 ,row_number() over (order by
																		 c.CredentialCode desc	-- highest CIHI code is selected first
																		,rc.EffectiveTime
																		,rc.RegistrantCredentialSID
																	) RankOrder
							from
								dbo.RegistrantCredential rc
							join
								dbo.Credential					 c on rc.CredentialSID			= c.CredentialSID and c.IsRelatedToProfession = @OFF and c.IsSpecialization = @OFF
							left outer join
								dbo.Org									 o on rc.OrgSID							= o.OrgSID
							left outer join
								dbo.City								 cty on o.CitySID						= cty.CitySID
							left outer join
								dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
							left outer join
								dbo.Country							 ctry on sp.CountrySID			= ctry.CountrySID
							where
								rc.RegistrantSID							 = @registrantSID
								and rc.RegistrantCredentialSID <> @registrantCredential1
								and rc.RegistrantCredentialSID <> @registrantCredential2	-- avoid re-reporting the previous 2 credentials
						)													ed on ed.RankOrder = 1
						where
							rp.RegistrationProfileSID = @registrationProfileSID;

						set @recordsProcessed += 1;

						select -- get next key to process
							@registrationProfileSID = min(rp.RegistrationProfileSID)
						from
							dbo.RegistrationProfile rp
						where
							rp.RegistrationSnapshotSID = @RegistrationSnapshotSID and rp.RegistrationProfileSID > @registrationProfileSID;

						if @@rowcount = 0 set @registrationProfileSID = 0; -- terminate loop when no more to process

					end try
					begin catch

						set @TotalErrorCount += 1;
						set @recordsProcessed += 1;

						if xact_state() <> 0 -- rollback all
						begin
							rollback;
						end;

						if @JobRunSID is null and @DebugLevel > 0
						begin
							print (error_message());
						end;

						-- if the procedure is running asynchronously record the
						-- error, else re-throw it to end processing

						if @JobRunSID is not null
						begin

							insert
								sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
							select
								@JobRunSID
							 ,N'* ERROR: ' + error_message() + char(13) + char(10) + '[Registrant#/SID = ' + isnull(@registrantNo, '?') + '/'
								+ isnull(ltrim(@registrantSID), '?') + ']'
							 ,@dataSource
							 ,@registrationProfileSID;

						end;

						if @StopOnError = @ON
						begin
							exec @errorNo = sf.pErrorRethrow;
						end;

					end catch;

				end;

			end;

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = 'Calling validation'
				 ,@TimeCheck = @timeCheck output;

			end;

			exec dbo.pRegistrationSnapshot#CIHIValidate
				@RegistrationSnapshotSID = @RegistrationSnapshotSID
			 ,@DebugLevel = @DebugLevel;

		end; -- end of processing (restart here if no next snapshot to process from job schedule)

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = 'Updating results'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- update job with final totals for records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @TotalRecordCount = 0
			begin

				if @RegistrationSnapshotSID is not null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'NoRecordsToProcess'
					 ,@MessageText = @resultMessage output
					 ,@DefaultText = N'Warning: No records were found to process. Configuration updates may be required.';

				end;
				else
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'NoQueuedSnapshot'
					 ,@MessageText = @resultMessage output
					 ,@DefaultText = N'No pending %1 was found to process at this time. This is not an error. The job completed successfullly.';

				end;

			end;
			else if @recordsProcessed >= @RecordLimit
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedOnRecordLimit'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job completed %2 records (Record limit was set).'
				 ,@Arg1 = 'CIHI Snapshot'
				 ,@Arg2 = @RecordLimit;

			end;
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'CIHI Snapshot';

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @TotalRecordCount
			 ,@RecordsProcessed = @TotalRecordCount
			 ,@TotalErrors = @TotalErrorCount
			 ,@ResultMessage = @resultMessage;

		end;

		-- set last update time to same as verified time

		update
			dbo.RegistrationSnapshot
		set
			LastCodeUpdateTime = LastVerifiedTime -- LastCodeUpdateTime was set by #CIHIVerify subroutine
		where
			RegistrationSnapshotSID = @RegistrationSnapshotSID;

		if @ReturnSelect = @ON
		begin
			select @TotalRecordCount TotalRecordCount , @TotalErrorCount TotalErrorCount;
		end;

	end try
	begin catch

		if xact_state() <> 0
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		if @JobRunSID is not null
		begin

			set @errorText = N'*** JOB FAILED' + isnull(N' AT : ' + @dataSource + char(13) + char(10), N'');
			set @errorText += char(13) + char(10) + error_message() + N' at procedure "' + error_procedure() + N'" line# ' + ltrim(error_line());

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = @ON;

		end;

		if @ReturnSelect = @ON
		begin
			select @TotalRecordCount TotalRecordCount , @TotalErrorCount TotalErrorCount;
		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);
end;
GO
