SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationSnapshot#CIHIValidate
	@RegistrationSnapshotSID int = null -- identifies the snapshot to be updated (required unless @RegistrationProfileSID is passed)
 ,@RegistrationProfileSID	 int = null -- key of a single profile to validate 
 ,@JobRunSID							 int = null -- sf.JobRun record to update on asynchronous calls
 ,@DebugLevel							 int = 0		-- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Registration Snapshot - CIHI Validate
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure checks CIHI profiles for compliance with reporting rules
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
This procedure is called to re-run validations against profiles in a CIHI registration snapshot.  The procedure first clears
messages and invalid flag settings (IsInvalid bit column) and then checks records for compliance against the current
rule set.  Execution of the procedure against locked snapshots is not allowed.

This procedure should be called in background to avoid time outs for larger data sets.  

No output or data set is returned.

To run the procedure against a single profile record only, pass the @RegistrationProfileSID parameter. 

Limitations
-----------
When the procedure is called asychronously (@JobRunSID passed), cancellation actions from the UI are not supported.  Only the 
start up of the job and end of job are updated.  The job is relatively short running - generally less than 5 minutes.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a CIHI snapshot selected at random">
    <SQLScript>
      <![CDATA[

declare
	@registrationSnapshotSID		 int

select top (1)
	@registrationSnapshotSID = rs.RegistrationSnapshotSID
from
	dbo.vRegistrationSnapshot rs
where
	rs.RegistrationSnapshotTypeSCD = 'CIHI'
and
	rs.LockedTime is null
and
	rs.ProfileCount > 0
order by
	newid()

if @registrationSnapshotSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationSnapshot#CIHIValidate
		@RegistrationSnapshotSID = @registrationSnapshotSID
	 ,@DebugLevel = 1

	select
		rp.RegistrantLabel
	 ,rp.IsInvalid
	 ,rp.MessageText
	from
		dbo.vRegistrationProfile rp
	where
		rp.RegistrationSnapshotSID = @registrationSnapshotSID
	and
		rp.IsInvalid = 1

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:25"/>
    </Assertions>
  </Test>
  <Test Name = "Validate1" Description="Executes the procedure to validate a single record from a CIHI snapshot selected at random">
    <SQLScript>
      <![CDATA[
declare
	@registrationSnapshotSID int
 ,@registrationProfileSID	 int;

select top (1)
	@registrationSnapshotSID = rs.RegistrationSnapshotSID
from
	dbo.vRegistrationSnapshot rs
where
	rs.RegistrationSnapshotTypeSCD = 'CIHI' and rs.LockedTime is null and rs.ProfileCount > 0
order by
	newid();

select top (1)
	@registrationProfileSID = rp.RegistrationProfileSID
from
	dbo.RegistrationProfile rp
where
	rp.RegistrationSnapshotSID = @registrationSnapshotSID
order by
	newid();

if @registrationSnapshotSID is null or @registrationProfileSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationSnapshot#CIHIValidate
		@RegistrationProfileSID = @registrationProfileSID
	 ,@DebugLevel = 1;

	select
		rp.RegistrantLabel
	 ,rp.IsInvalid
	 ,rp.MessageText
	from
		dbo.vRegistrationProfile rp
	where
		rp.RegistrationProfileSID = @registrationProfileSID

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrationSnapshot#CIHIValidate'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)												-- message text for business rule errors
	 ,@xState							int																		-- error state detected in catch block	
	 ,@ON									bit						= cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@OFF								bit						= cast(0 as bit)				-- constant for bit comparison = 0
	 ,@CRLF								nchar(2)			= char(13) + char(10)		-- constant for message formatting
	 ,@tranCount					int						= @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName						nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@practiceHoursLimit smallint															-- configuration parameter defining max practice hours allowed
	 ,@recordsUpdated			int																		-- tracks records changed by each update statement (for debugging)
	 ,@resultMessage			nvarchar(4000)												-- summary of job result
	 ,@totalRecords				int																		-- total count of records to report to job processing
	 ,@progressLabel			nvarchar(257)													-- tracks locaion in logic for debugging
	 ,@debugString				nvarchar(100)													-- label used to describe status in debug output
	 ,@timeCheck					datetimeoffset;												-- traces debug interval times

	begin try

		if @DebugLevel is null -- debug level defaults to off
		begin
			set @DebugLevel = 0;
		end;

		set @progressLabel = N'startup';

		if @JobRunSID is not null -- if call is async, update the job run record 
		begin

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = 'Validating ...';

			select
				@totalRecords = count(1)
			from
				dbo.RegistrationProfile
			where
				RegistrationSnapshotSID	 = @RegistrationSnapshotSID -- limit to the given snapshot
				and
				(
					RegistrationProfileSID = @RegistrationProfileSID or @RegistrationProfileSID is null -- and further limit by specific profile record if specified
				);

		end;

		-- validate parameters and startup values

		if @RegistrationProfileSID is not null
		begin

			select
				@RegistrationSnapshotSID = rp.RegistrationSnapshotSID
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID;

			if @@rowcount = 0 or @RegistrationSnapshotSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Registration Profile'
				 ,@Arg2 = @RegistrationProfileSID;

				raiserror(@errorText, 18, 1);
			end;

		end;

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NoRecordsToUpdate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'No records exist %1 for this %2. Record ID = "%3".'
			 ,@Arg1 = 'to update'
			 ,@Arg2 = 'snapshot'
			 ,@Arg3 = @RegistrationSnapshotSID;

			raiserror(@errorText, 18, 1);

		end;
		else if exists
		(
			select
				1
			from
				dbo.RegistrationSnapshot rs
			where
				rs.RegistrationSnapshotSID = @RegistrationSnapshotSID and rs.LockedTime is not null
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'LockedNoUpdate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'This %1 is locked.  %2 not allowed.'
			 ,@Arg1 = 'snapshot'
			 ,@Arg2 = 'Update';

			raiserror(@errorText, 16, 1);

		end;

		set @practiceHoursLimit = isnull(cast(sf.fConfigParam#Value('PracticeHoursLimit') as smallint), 4000); -- lookup practice hours limit (default is 4000)

		-- clear out the validate time to show that the
		-- process is pending on the UI

		if @RegistrationProfileSID is null
		begin

			set @progressLabel = N'last verified';

			update
				dbo.RegistrationSnapshot
			set
				LastVerifiedTime = null
			where
				RegistrationSnapshotSID = @RegistrationSnapshotSID;

		end;

		-- update coding associated with the address
		-- record selected for the profile

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = 'Clearing previous errors'
			 ,@TimeCheck = @timeCheck output;
		end;

		set @progressLabel = N'reset';

		update
			dbo.RegistrationProfile
		set
			IsInvalid = @OFF
		 ,MessageText = null
		from
			dbo.RegistrationProfile
		where
			RegistrationSnapshotSID	 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				RegistrationProfileSID = @RegistrationProfileSID or @RegistrationProfileSID is null
			) and (IsInvalid				 = @ON or MessageText is not null);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Checking qualifying education'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'qualifying education';

		update
			rp
		set
			rp.IsInvalid = @ON
		 ,rp.MessageText = isnull(rp.MessageText + @CRLF, N'') + 'ERROR:'
											 + (case when rp.Education1RegistrantCredentialSID is null then ' Qualifying education missing' else '' end)
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID = rp.RegistrationSnapshotSID
		where
			rs.RegistrationSnapshotSID	= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.RegistrationProfileSID = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and (rp.Education1RegistrantCredentialSID is null -- missing qualifying education
					);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Checking birth/graduation year'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'birth/graduation year';

		update
			rp
		set
			rp.IsInvalid = @ON
		 ,rp.MessageText = isnull(rp.MessageText + @CRLF, N'') + 'ERROR:'
											 + (case when year(rp.BirthDate) >= rp.Education1GraduationYear then ' Birth year after graduation year' else '' end)
											 + (case
														when (rs.RegistrationYear - rp.Education1GraduationYear) > 75 then ' Graduation year > 75 years in the past'
														else ''
													end
												 ) + (case
																when rp.Education1GraduationYear - year(rp.BirthDate) < 17 then ' Graduation year < 17 years from birth year'
																else ''
															end
														 )
											 + (case
														when
														(
															rs.RegistrationYear - year(rp.BirthDate) < 17 or rs.RegistrationYear - year(rp.BirthDate) > 100
														) then ' Registrant age not between 17 and 100 (check birth year)'
														else ''
													end
												 )
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID = rp.RegistrationSnapshotSID
		where
			rs.RegistrationSnapshotSID															 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.RegistrationProfileSID															 = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and rp.Education1RegistrantCredentialSID is not null
			and rp.BirthDate is not null
			and
			(
				year(rp.BirthDate)																		 >= rp.Education1GraduationYear
				or (rs.RegistrationYear - rp.Education1GraduationYear) > 75
				or rp.Education1GraduationYear - year(rp.BirthDate)		 < 17
				or rs.RegistrationYear - year(rp.BirthDate)						 < 17
				or rs.RegistrationYear - year(rp.BirthDate)						 > 100
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Checking education defaults'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'education defaults';

		update
			dbo.RegistrationProfile
		set
			IsInvalid = @ON
		 ,MessageText = isnull(MessageText + @CRLF, N'') + 'ERROR: Code 5 invalid for education record(s):'
										+ (case
												 when Education1RegistrantCredentialSID is not null and Education1CredentialCode = '5' then ' QUALIFYING'
												 else ''
											 end
											) + (case when Education2RegistrantCredentialSID is not null and Education2CredentialCode = '5' then ' RELATED' else '' end)
										+ (case
												 when Education3RegistrantCredentialSID is not null and Education3CredentialCode = '5' then ' NON-RELATED'
												 else ''
											 end
											)
		where
			RegistrationSnapshotSID																												 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				RegistrationProfileSID																											 = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				(
					Education1RegistrantCredentialSID is not null and Education1CredentialCode = '5'
				)
				or
				(
					Education2RegistrantCredentialSID is not null and Education2CredentialCode = '5'
				)
				or
				(
					Education3RegistrantCredentialSID is not null and Education3CredentialCode = '5'
				)
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;


			exec sf.pDebugPrint
				@DebugString = 'Checking credential codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'credential codes';

		update
			dbo.RegistrationProfile
		set
			IsInvalid = @ON
		 ,MessageText = isnull(MessageText + @CRLF, N'') + 'ERROR: Credential code missing for education record(s):'
										+ (case
												 when Education1RegistrantCredentialSID is not null and Education1CredentialCode is null then ' QUALIFYING'
												 else ''
											 end
											) + (case
														 when Education2RegistrantCredentialSID is not null and Education2CredentialCode is null then ' RELATED'
														 else ''
													 end
													) + (case
																 when Education3RegistrantCredentialSID is not null and Education3CredentialCode is null then ' NON-RELATED'
																 else ''
															 end
															)
		where
			RegistrationSnapshotSID	 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				RegistrationProfileSID = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				(
					Education1RegistrantCredentialSID is not null and Education1CredentialCode is null
				)
				or
				(
					Education2RegistrantCredentialSID is not null and Education2CredentialCode is null
				)
				or
				(
					Education3RegistrantCredentialSID is not null and Education3CredentialCode is null
				)
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;


			exec sf.pDebugPrint
				@DebugString = 'Checking credential org province codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'credential orgs';

		update
			dbo.RegistrationProfile
		set
			IsInvalid = @ON
		 ,MessageText = isnull(MessageText + @CRLF, N'') + 'ERROR: Credential organization missing province (ISO) code for education record(s):'
										+ (case
												 when Education1RegistrantCredentialSID is not null and Education1StateProvinceISONumber is null and Education1IsDefaultCountry = @ON then
													 ' QUALIFYING'
												 else ''
											 end
											)
										+ (case
												 when Education2RegistrantCredentialSID is not null and Education2StateProvinceISONumber is null and Education2IsDefaultCountry = @ON then
													 ' RELATED'
												 else ''
											 end
											)
										+ (case
												 when Education3RegistrantCredentialSID is not null and Education3StateProvinceISONumber is null and Education3IsDefaultCountry = @ON then
													 ' NON-RELATED'
												 else ''
											 end
											)
		where
			RegistrationSnapshotSID																																																				= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				RegistrationProfileSID																																																			= @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				(
					Education1RegistrantCredentialSID is not null and Education1StateProvinceISONumber is null and Education1IsDefaultCountry = @ON
				)
				or
				(
					Education2RegistrantCredentialSID is not null and Education2StateProvinceISONumber is null and Education2IsDefaultCountry = @ON
				)
				or
				(
					Education3RegistrantCredentialSID is not null and Education3StateProvinceISONumber is null and Education3IsDefaultCountry = @ON
				)
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;


			exec sf.pDebugPrint
				@DebugString = 'Checking credential org country codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'credential org countries';

		update
			dbo.RegistrationProfile
		set
			IsInvalid = @ON
		 ,MessageText = isnull(MessageText + @CRLF, N'') + 'ERROR: Credential organization missing country (ISO) code for education record(s):'
										+ (case
												 when Education1RegistrantCredentialSID is not null and Education1CountryISONumber is null and Education1IsDefaultCountry = @OFF then
													 ' QUALIFYING'
												 else ''
											 end
											)
										+ (case
												 when Education2RegistrantCredentialSID is not null and Education2CountryISONumber is null and Education2IsDefaultCountry = @OFF then
													 ' RELATED'
												 else ''
											 end
											)
										+ (case
												 when Education3RegistrantCredentialSID is not null and Education3CountryISONumber is null and Education3IsDefaultCountry = @OFF then
													 ' NON-RELATED'
												 else ''
											 end
											)
		where
			RegistrationSnapshotSID																																																	= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				RegistrationProfileSID																																																= @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				(
					Education1RegistrantCredentialSID is not null and Education1CountryISONumber is null and Education1IsDefaultCountry = @OFF
				)
				or
				(
					Education2RegistrantCredentialSID is not null and Education2CountryISONumber is null and Education2IsDefaultCountry = @OFF
				)
				or
				(
					Education3RegistrantCredentialSID is not null and Education3CountryISONumber is null and Education3IsDefaultCountry = @OFF
				)
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;


			exec sf.pDebugPrint
				@DebugString = 'Checking employment'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employment status';

		update
			rp
		set
			rp.IsInvalid = @ON
		 ,rp.MessageText = isnull(rp.MessageText + @CRLF, N'') + 'ERROR: '
											 + (case
														when regP.RegistrantPracticeSID is null then 'Employment status record missing for member'
														when rp.EmploymentStatusCode is null then 'Employment status code is blank (update master table)'
														when es.IsEmploymentExpected = @ON and re.RegistrantEmploymentSID is null then
															'Employers expected for status "' + es.EmploymentStatusName + '"'
														when es.IsEmploymentExpected = @OFF and re.RegistrantEmploymentSID is not null then
															'Employers not expected for status "' + es.EmploymentStatusName + '"'
														when rp.PracticeHours > @practiceHoursLimit then
															'Practice hours too high (configured max = ' + ltrim(@practiceHoursLimit) + ' hours)'
														else 'Error condition detected in filter but message not defined.  Report to HelpDesk.'
													end
												 )
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		left outer join
			dbo.RegistrantPractice	 regP on rp.RegistrantPracticeSID						 = regP.RegistrantPracticeSID
		left outer join
			dbo.EmploymentStatus		 es on regP.EmploymentStatusSID							 = es.EmploymentStatusSID
		left outer join
			dbo.RegistrantEmployment re on rp.Employment1RegistrantEmploymentSID = re.RegistrantEmploymentSID
		where
			rs.RegistrationSnapshotSID	= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.RegistrationProfileSID = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				regP.RegistrantPracticeSID is null
				or rp.EmploymentStatusCode is null
				or
				(
					es.IsEmploymentExpected = @ON and re.RegistrantEmploymentSID is null
				)
				or
				(
					es.IsEmploymentExpected = @OFF and re.RegistrantEmploymentSID is not null
				)
				or rp.PracticeHours				> @practiceHoursLimit
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Checking employment #1 codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employer #1';

		update
			rp
		set
			rp.IsInvalid = @ON
		 ,rp.MessageText = isnull(rp.MessageText + @CRLF, N'') + 'ERROR: Code value(s) missing for Employer #1:'
											 + (case when rp.Employment1TypeCode is null then ' Employment-Type' else '' end)
											 + (case
														when rp.Employment1IsDefaultCountry = @ON and rp.Employment1StateProvinceISONumber is null then ' Organization-Province(ISO)'
														else ''
													end
												 ) + (case when rp.Employment1OrgTypeCode is null then ' Organization-Type' else '' end)
											 + (case when rp.Employment1PracticeScopeCode is null then ' Employment-Scope' else '' end)
											 + (case when rp.Employment1RoleCode is null then ' Employment-Role' else '' end)
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantEmployment re on rp.Employment1RegistrantEmploymentSID = re.RegistrantEmploymentSID
		where
			rs.RegistrationSnapshotSID				 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.RegistrationProfileSID				 = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				rp.Employment1TypeCode is null
				or
				(
					rp.Employment1IsDefaultCountry = @ON and rp.Employment1StateProvinceISONumber is null
				)
				or rp.Employment1OrgTypeCode is null
				or rp.Employment1PracticeScopeCode is null
				or rp.Employment1RoleCode is null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Checking employment #2 codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employer #2';

		update
			rp
		set
			rp.IsInvalid = @ON
		 ,rp.MessageText = isnull(rp.MessageText + @CRLF, N'') + 'ERROR: Code value(s) missing for Employer #2:'
											 + (case when rp.Employment2TypeCode is null then ' Employment-Type' else '' end)
											 + (case
														when rp.Employment2IsDefaultCountry = @ON and rp.Employment2StateProvinceISONumber is null then ' Organization-Province(ISO)'
														else ''
													end
												 ) + (case when rp.Employment2OrgTypeCode is null then ' Organization-Type' else '' end)
											 + (case when rp.Employment2PracticeScopeCode is null then ' Employment-Scope' else '' end)
											 + (case when rp.Employment2RoleCode is null then ' Employment-Role' else '' end)
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantEmployment re on rp.Employment2RegistrantEmploymentSID = re.RegistrantEmploymentSID
		where
			rs.RegistrationSnapshotSID				 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.RegistrationProfileSID				 = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				rp.Employment2TypeCode is null
				or
				(
					rp.Employment2IsDefaultCountry = @ON and rp.Employment2StateProvinceISONumber is null
				)
				or rp.Employment2OrgTypeCode is null
				or rp.Employment2PracticeScopeCode is null
				or rp.Employment2RoleCode is null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Checking employment #3 codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employer #3';

		update
			rp
		set
			rp.IsInvalid = @ON
		 ,rp.MessageText = isnull(rp.MessageText + @CRLF, N'') + 'ERROR: Code value(s) missing for Employer #3:'
											 + (case when rp.Employment3TypeCode is null then ' Employment-Type' else '' end)
											 + (case
														when rp.Employment3IsDefaultCountry = @ON and rp.Employment3StateProvinceISONumber is null then ' Organization-Province(ISO)'
														else ''
													end
												 ) + (case when rp.Employment3OrgTypeCode is null then ' Organization-Type' else '' end)
											 + (case when rp.Employment3PracticeScopeCode is null then ' Employment-Scope' else '' end)
											 + (case when rp.Employment3RoleCode is null then ' Employment-Role' else '' end)
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantEmployment re on rp.Employment3RegistrantEmploymentSID = re.RegistrantEmploymentSID
		where
			rs.RegistrationSnapshotSID				 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.RegistrationProfileSID				 = @RegistrationProfileSID or @RegistrationProfileSID is null
			) -- restrict to 1 profile record where key provided
			and
			(
				rp.Employment3TypeCode is null
				or
				(
					rp.Employment3IsDefaultCountry = @ON and rp.Employment3StateProvinceISONumber is null
				)
				or rp.Employment3OrgTypeCode is null
				or rp.Employment3PracticeScopeCode is null
				or rp.Employment3RoleCode is null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

		end;

		-- set verified time

		if @RegistrationProfileSID is null
		begin

			set @progressLabel = N'verified time';

			update
				dbo.RegistrationSnapshot
			set
				LastVerifiedTime = sysdatetime()
			where
				RegistrationSnapshotSID = @RegistrationSnapshotSID;

		end;

		if @JobRunSID is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'CIHI Snapshot Validation';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @totalRecords
			 ,@RecordsProcessed = @totalRecords
			 ,@TotalErrors = 0
			 ,@ResultMessage = @resultMessage;

		end;

	end try
	begin catch

		set @xState = xact_state();

		if @tranCount = 0 and (@xState = -1 or @xState = 1)
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		if @JobRunSID is not null
		begin

			set @errorText = N'*** JOB FAILED' + isnull(N' AT : ' + @progressLabel + char(13) + char(10), N'');
			set @errorText += char(13) + char(10) + error_message() + N' at procedure "' + error_procedure() + N'" line# ' + ltrim(error_line());

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = @ON;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
