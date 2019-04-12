SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationSnapshot#CIHIUpdate
	@RegistrationSnapshotSID int				-- identifies the snapshot to be updated
 ,@JobRunSID							 int = null -- sf.JobRun record to update on asynchronous calls
 ,@DebugLevel							 int = 0		-- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Registration Snapshot - CIHI Update
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure updates the CIHI code values for an existing snapshot (no other columns are modified)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
This procedure is used after CIHI coding values (e.g. province ISO codes) are updated in master tables, and the updated codes
need to be refreshed on the registration profile records associated with a snapshot.  Note that only "code" columns are updated
on the profile. Registration and demographic related columns are not modified.

This procedure is designed to be run directly from the UI but should be called in background to avoid time outs for
larger data sets. No output or data set is returned.

Limitations
-----------
When the procedure is called asynchronously (@JobRunSID passed), cancellation actions from the UI are not supported.  Only the 
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

	exec dbo.pRegistrationSnapshot#CIHIUpdate
		@RegistrationSnapshotSID = @registrationSnapshotSID
	 ,@DebugLevel = 1

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrationSnapshot#CIHIUpdate'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo				int						= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText			nvarchar(4000)												-- message text for business rule errors
	 ,@tranCount			int						= @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName				nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@recordsUpdated int																		-- tracks records changed by each update statement (for debugging)
	 ,@resultMessage	nvarchar(4000)												-- summary of job result
	 ,@totalRecords		int																		-- total count of records to report to job processing
	 ,@progressLabel	nvarchar(257)													-- tracks locaion in logic for debugging
	 ,@debugString		nvarchar(100)													-- label used to describe status in debug output
	 ,@timeCheck			datetimeoffset												-- traces debug interval times
	 ,@OFF						bit						= cast(0 as bit);				-- constant for bit comparison = 0

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
			 ,@CurrentProcessLabel = 'Updating ...';

			select
				@totalRecords = count(1)
			from
				dbo.RegistrationProfile
			where
				RegistrationSnapshotSID = @RegistrationSnapshotSID; -- limit to the given snapshot

		end;

		-- validate parameters and startup values

		if @tranCount > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A transaction was started prior to calling this procedure. Procedure "%1" does not allow nested transactions.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

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

		-- clear out the last code update time to show 
		-- that the process is pending on the UI

		update
			dbo.RegistrationSnapshot
		set
			LastCodeUpdateTime = null
		where
			RegistrationSnapshotSID = @RegistrationSnapshotSID;

		-- update coding associated with the address
		-- record selected for the profile

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = 'Updating address codes'
			 ,@TimeCheck = @timeCheck output;
		end;

		set @progressLabel = N'address codes';

		update
			rp
		set
			rp.ResidenceStateProvinceISONumber = sp.ISONumber
		 ,rp.ResidenceCountryISONumber = c.ISONumber
		 ,rp.ResidenceIsDefaultCountry = c.IsDefault
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID	 = rp.RegistrationSnapshotSID
		join
			dbo.Registrant					 r on rp.RegistrantSID						 = r.RegistrantSID
		join
			dbo.PersonMailingAddress pma on rp.PersonMailingAddressSID = pma.PersonMailingAddressSID
		join
			dbo.City								 cty on pma.CitySID								 = cty.CitySID
		join
			dbo.StateProvince				 sp on cty.StateProvinceSID				 = sp.StateProvinceSID
		join
			dbo.Country							 c on sp.CountrySID								 = c.CountrySID
		where
			rs.RegistrationSnapshotSID							= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.ResidenceStateProvinceISONumber is null -- code has changed or was null
				or rp.ResidenceStateProvinceISONumber <> sp.ISONumber
				or rp.ResidenceCountryISONumber is null
				or rp.ResidenceCountryISONumber				<> c.ISONumber
				or rp.ResidenceIsDefaultCountry				<> c.IsDefault
			);

		-- employment code updates; first the status
		-- and then each of 3 employers

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Updating employment status codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employment status';

		update
			rp
		set
			rp.EmploymentStatusCode = es.EmploymentStatusCode
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantPractice	 regP on rp.RegistrantPracticeSID = regP.RegistrantPracticeSID
		join
			dbo.EmploymentStatus		 es on regP.EmploymentStatusSID		= es.EmploymentStatusSID
		where
			rs.RegistrationSnapshotSID																	 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.EmploymentStatusCode is null or rp.EmploymentStatusCode <> es.EmploymentStatusCode -- code has changed or was null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Updating employer 1 codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employer #1';

		update
			rp
		set
			rp.Employment1TypeCode = et.EmploymentTypeCode
		 ,rp.Employment1StateProvinceISONumber = sp.ISONumber
		 ,rp.Employment1CountryISONumber = c.ISONumber
		 ,rp.Employment1IsDefaultCountry = c.IsDefault
		 ,rp.Employment1OrgTypeCode = ot.OrgTypeCode
		 ,rp.Employment1PracticeAreaCode = pa.PracticeAreaCode
		 ,rp.Employment1PracticeScopeCode = ps.PracticeScopeCode
		 ,rp.Employment1RoleCode = er.EmploymentRoleCode
		 ,rp.EmploymentCount = (case
															when isnull(rp.Employment3RegistrantEmploymentSID, -1) <> -1 then 3
															when isnull(rp.Employment2RegistrantEmploymentSID, -1) <> -1 then 2
															when isnull(rp.Employment1RegistrantEmploymentSID, -1) <> -1 then 1
															else 0
														end
													 )	-- also update the count in case any add/deletions were processed manually
		from
			dbo.RegistrationSnapshot						 rs
		join
			dbo.RegistrationProfile							 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantEmployment						 re on rp.Employment1RegistrantEmploymentSID = re.RegistrantEmploymentSID
		join
			dbo.Org															 o on re.OrgSID															 = o.OrgSID
		join
			dbo.EmploymentType									 et on re.EmploymentTypeSID									 = et.EmploymentTypeSID
		join
			dbo.PracticeScope										 ps on re.PracticeScopeSID									 = ps.PracticeScopeSID
		join
			dbo.EmploymentRole									 er on re.EmploymentRoleSID									 = er.EmploymentRoleSID
		join
			dbo.OrgType													 ot on o.OrgTypeSID													 = ot.OrgTypeSID
		join
			dbo.City														 cty on o.CitySID														 = cty.CitySID
		join
			dbo.StateProvince										 sp on cty.StateProvinceSID									 = sp.StateProvinceSID
		join
			dbo.Country													 c on sp.CountrySID													 = c.CountrySID
		left outer join
			dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID					 = repa.RegistrantEmploymentSID and repa.IsPrimary = cast(1 as bit)
		left outer join
			dbo.PracticeArea										 pa on repa.PracticeAreaSID									 = pa.PracticeAreaSID
		where
			rs.RegistrationSnapshotSID								= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.Employment1TypeCode									<> et.EmploymentTypeCode -- code has changed or profile value is null
				or rp.Employment1StateProvinceISONumber <> sp.ISONumber
				or rp.Employment1CountryISONumber				<> c.ISONumber
				or rp.Employment1IsDefaultCountry				<> c.IsDefault
				or rp.Employment1OrgTypeCode						<> ot.OrgTypeCode
				or rp.Employment1PracticeAreaCode				<> pa.PracticeAreaCode
				or rp.Employment1PracticeScopeCode			<> ps.PracticeScopeCode
				or rp.Employment1RoleCode								<> er.EmploymentRoleCode
				or rp.Employment1PracticeAreaCode is null
				or rp.Employment1TypeCode is null
				or rp.Employment1StateProvinceISONumber is null
				or rp.Employment1CountryISONumber is null
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
				@DebugString = 'Updating employer 2 codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employer #2';

		update
			rp
		set
			rp.Employment2TypeCode = et.EmploymentTypeCode
		 ,rp.Employment2StateProvinceISONumber = sp.ISONumber
		 ,rp.Employment2CountryISONumber = c.ISONumber
		 ,rp.Employment2IsDefaultCountry = c.IsDefault
		 ,rp.Employment2OrgTypeCode = ot.OrgTypeCode
		 ,rp.Employment2PracticeAreaCode = pa.PracticeAreaCode
		 ,rp.Employment2PracticeScopeCode = ps.PracticeScopeCode
		 ,rp.Employment2RoleCode = er.EmploymentRoleCode
		from
			dbo.RegistrationSnapshot						 rs
		join
			dbo.RegistrationProfile							 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantEmployment						 re on rp.Employment2RegistrantEmploymentSID = re.RegistrantEmploymentSID
		join
			dbo.Org															 o on re.OrgSID															 = o.OrgSID
		join
			dbo.EmploymentType									 et on re.EmploymentTypeSID									 = et.EmploymentTypeSID
		join
			dbo.PracticeScope										 ps on re.PracticeScopeSID									 = ps.PracticeScopeSID
		join
			dbo.EmploymentRole									 er on re.EmploymentRoleSID									 = er.EmploymentRoleSID
		join
			dbo.OrgType													 ot on o.OrgTypeSID													 = ot.OrgTypeSID
		join
			dbo.City														 cty on o.CitySID														 = cty.CitySID
		join
			dbo.StateProvince										 sp on cty.StateProvinceSID									 = sp.StateProvinceSID
		join
			dbo.Country													 c on sp.CountrySID													 = c.CountrySID
		left outer join
			dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID					 = repa.RegistrantEmploymentSID and repa.IsPrimary = cast(1 as bit)
		left outer join
			dbo.PracticeArea										 pa on repa.PracticeAreaSID									 = pa.PracticeAreaSID
		where
			rs.RegistrationSnapshotSID								= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.Employment2TypeCode									<> et.EmploymentTypeCode -- code has changed or profile value is null
				or rp.Employment2StateProvinceISONumber <> sp.ISONumber
				or rp.Employment2CountryISONumber				<> c.ISONumber
				or rp.Employment2IsDefaultCountry				<> c.IsDefault
				or rp.Employment2OrgTypeCode						<> ot.OrgTypeCode
				or rp.Employment2PracticeAreaCode				<> pa.PracticeAreaCode
				or rp.Employment2PracticeScopeCode			<> ps.PracticeScopeCode
				or rp.Employment2RoleCode								<> er.EmploymentRoleCode
				or rp.Employment2PracticeAreaCode is null
				or rp.Employment2TypeCode is null
				or rp.Employment2StateProvinceISONumber is null
				or rp.Employment2CountryISONumber is null
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
				@DebugString = 'Updating employer 3 codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'employer #3';

		update
			rp
		set
			rp.Employment3TypeCode = et.EmploymentTypeCode
		 ,rp.Employment3StateProvinceISONumber = sp.ISONumber
		 ,rp.Employment3CountryISONumber = c.ISONumber
		 ,rp.Employment3IsDefaultCountry = c.IsDefault
		 ,rp.Employment3OrgTypeCode = ot.OrgTypeCode
		 ,rp.Employment3PracticeAreaCode = pa.PracticeAreaCode
		 ,rp.Employment3PracticeScopeCode = ps.PracticeScopeCode
		 ,rp.Employment3RoleCode = er.EmploymentRoleCode
		from
			dbo.RegistrationSnapshot						 rs
		join
			dbo.RegistrationProfile							 rp on rs.RegistrationSnapshotSID						 = rp.RegistrationSnapshotSID
		join
			dbo.RegistrantEmployment						 re on rp.Employment3RegistrantEmploymentSID = re.RegistrantEmploymentSID
		join
			dbo.Org															 o on re.OrgSID															 = o.OrgSID
		join
			dbo.EmploymentType									 et on re.EmploymentTypeSID									 = et.EmploymentTypeSID
		join
			dbo.PracticeScope										 ps on re.PracticeScopeSID									 = ps.PracticeScopeSID
		join
			dbo.EmploymentRole									 er on re.EmploymentRoleSID									 = er.EmploymentRoleSID
		join
			dbo.OrgType													 ot on o.OrgTypeSID													 = ot.OrgTypeSID
		join
			dbo.City														 cty on o.CitySID														 = cty.CitySID
		join
			dbo.StateProvince										 sp on cty.StateProvinceSID									 = sp.StateProvinceSID
		join
			dbo.Country													 c on sp.CountrySID													 = c.CountrySID
		left outer join
			dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID					 = repa.RegistrantEmploymentSID and repa.IsPrimary = cast(1 as bit)
		left outer join
			dbo.PracticeArea										 pa on repa.PracticeAreaSID									 = pa.PracticeAreaSID
		where
			rs.RegistrationSnapshotSID								= @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.Employment3TypeCode									<> et.EmploymentTypeCode -- code has changed or profile value is null
				or rp.Employment3StateProvinceISONumber <> sp.ISONumber
				or rp.Employment3CountryISONumber				<> c.ISONumber
				or rp.Employment3IsDefaultCountry				<> c.IsDefault
				or rp.Employment3OrgTypeCode						<> ot.OrgTypeCode
				or rp.Employment3PracticeAreaCode				<> pa.PracticeAreaCode
				or rp.Employment3PracticeScopeCode			<> ps.PracticeScopeCode
				or rp.Employment3RoleCode								<> er.EmploymentRoleCode
				or rp.Employment3PracticeAreaCode is null
				or rp.Employment3TypeCode is null
				or rp.Employment3StateProvinceISONumber is null
				or rp.Employment3CountryISONumber is null
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

			exec sf.pDebugPrint
				@DebugString = 'Updating qualifying education codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'qualifying education';

		-- update the CIHI coding values for each of the 3 education types

		update
			rp
		set
			rp.Education1CredentialCode = c.CredentialCode
		 ,rp.Education1StateProvinceISONumber = sp.ISONumber
		 ,rp.Education1CountryISONumber = ctry.ISONumber
		 ,rp.Education1IsDefaultCountry = ctry.IsDefault
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						= rp.RegistrationSnapshotSID
		join
			dbo.RegistrantCredential rc on rp.Education1RegistrantCredentialSID = rc.RegistrantCredentialSID
		join
			dbo.Org									 o on rc.OrgSID															= o.OrgSID
		join
			dbo.Credential					 c on rc.CredentialSID											= c.CredentialSID and c.IsSpecialization = @OFF
		join
			dbo.City								 cty on o.CitySID														= cty.CitySID
		join
			dbo.StateProvince				 sp on cty.StateProvinceSID									= sp.StateProvinceSID
		join
			dbo.Country							 ctry on sp.CountrySID											= ctry.CountrySID
		where
			rs.RegistrationSnapshotSID							 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.Education1CredentialCode						 <> c.CredentialCode -- code has changed or is null
				or rp.Education1StateProvinceISONumber <> sp.ISONumber
				or rp.Education1CountryISONumber			 <> ctry.ISONumber
				or rp.Education1IsDefaultCountry			 <> ctry.IsDefault
				or rp.Education1CredentialCode is null
				or rp.Education1StateProvinceISONumber is null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Updating related education codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'related education';

		update
			rp
		set
			rp.Education2CredentialCode = c.CredentialCode
		 ,rp.Education2StateProvinceISONumber = sp.ISONumber
		 ,rp.Education2CountryISONumber = ctry.ISONumber
		 ,rp.Education2IsDefaultCountry = ctry.IsDefault
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						= rp.RegistrationSnapshotSID
		join
			dbo.RegistrantCredential rc on rp.Education2RegistrantCredentialSID = rc.RegistrantCredentialSID
		join
			dbo.Org									 o on rc.OrgSID															= o.OrgSID
		join
			dbo.Credential					 c on rc.CredentialSID											= c.CredentialSID and c.IsSpecialization = @OFF
		join
			dbo.City								 cty on o.CitySID														= cty.CitySID
		join
			dbo.StateProvince				 sp on cty.StateProvinceSID									= sp.StateProvinceSID
		join
			dbo.Country							 ctry on sp.CountrySID											= ctry.CountrySID
		where
			rs.RegistrationSnapshotSID							 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.Education2CredentialCode						 <> c.CredentialCode -- code has changed or is null
				or rp.Education2StateProvinceISONumber <> sp.ISONumber
				or rp.Education2CountryISONumber			 <> ctry.ISONumber
				or rp.Education2IsDefaultCountry			 <> ctry.IsDefault
				or rp.Education2CredentialCode is null
				or rp.Education2StateProvinceISONumber is null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

			exec sf.pDebugPrint
				@DebugString = 'Updating non-related education codes'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @progressLabel = N'non-related education';

		update
			rp
		set
			rp.Education3CredentialCode = c.CredentialCode
		 ,rp.Education3StateProvinceISONumber = sp.ISONumber
		 ,rp.Education3CountryISONumber = ctry.ISONumber
		 ,rp.Education3IsDefaultCountry = ctry.IsDefault
		from
			dbo.RegistrationSnapshot rs
		join
			dbo.RegistrationProfile	 rp on rs.RegistrationSnapshotSID						= rp.RegistrationSnapshotSID
		join
			dbo.RegistrantCredential rc on rp.Education3RegistrantCredentialSID = rc.RegistrantCredentialSID
		join
			dbo.Org									 o on rc.OrgSID															= o.OrgSID
		join
			dbo.Credential					 c on rc.CredentialSID											= c.CredentialSID and c.IsSpecialization = @OFF
		join
			dbo.City								 cty on o.CitySID														= cty.CitySID
		join
			dbo.StateProvince				 sp on cty.StateProvinceSID									= sp.StateProvinceSID
		join
			dbo.Country							 ctry on sp.CountrySID											= ctry.CountrySID
		where
			rs.RegistrationSnapshotSID							 = @RegistrationSnapshotSID -- restrict to profiles in current snapshot
			and
			(
				rp.Education3CredentialCode						 <> c.CredentialCode -- code has changed or is null
				or rp.Education3StateProvinceISONumber <> sp.ISONumber
				or rp.Education3CountryISONumber			 <> ctry.ISONumber
				or rp.Education3IsDefaultCountry			 <> ctry.IsDefault
				or rp.Education3CredentialCode is null
				or rp.Education3StateProvinceISONumber is null
			);

		set @recordsUpdated = @@rowcount;

		if @DebugLevel > 0
		begin

			set @debugString = ltrim(@recordsUpdated) + N' records updated';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

		end;

		-- set last update time

		set @progressLabel = N'last update time';

		update
			dbo.RegistrationSnapshot
		set
			LastCodeUpdateTime = sysdatetime()
		where
			RegistrationSnapshotSID = @RegistrationSnapshotSID;

		if @JobRunSID is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'Snapshot Reset Modified';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @totalRecords
			 ,@RecordsProcessed = @totalRecords
			 ,@TotalErrors = 0
			 ,@ResultMessage = @resultMessage;

		end;

	end try
	begin catch

		if @JobRunSID is not null
		begin

			set @errorText = N'*** JOB FAILED' + isnull(N' AT : ' + @progressLabel + char(13) + char(10), N'');
			set @errorText += char(13) + char(10) + error_message() + N' at procedure "' + error_procedure() + N'" line# ' + ltrim(error_line());

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = 1;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
