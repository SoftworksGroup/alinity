SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationProfile#Update$Refresh
	@RegistrationProfileSID							int
 ,@RegistrationSnapshotSID						int
 ,@RegistrantSID											int
 ,@RegistrantNo												varchar(50) output
 ,@GenderSCD													char(1)			output
 ,@BirthDate													date				output
 ,@PersonMailingAddressSID						int					output
 ,@ResidenceStateProvinceISONumber		smallint		output
 ,@ResidencePostalCode								varchar(10) output
 ,@ResidenceCountryISONumber					smallint		output
 ,@ResidenceIsDefaultCountry					bit					output
 ,@IsActivePractice										bit					output
 ,@Education1RegistrantCredentialSID	int					output
 ,@Education1CredentialCode						varchar(15) output
 ,@Education1GraduationYear						smallint		output
 ,@Education1StateProvinceISONumber		smallint		output
 ,@Education1CountryISONumber					smallint		output
 ,@Education1IsDefaultCountry					bit					output
 ,@Education2RegistrantCredentialSID	int					output
 ,@Education2CredentialCode						varchar(15) output
 ,@Education2GraduationYear						smallint		output
 ,@Education2StateProvinceISONumber		smallint		output
 ,@Education2CountryISONumber					smallint		output
 ,@Education2IsDefaultCountry					bit					output
 ,@Education3RegistrantCredentialSID	int					output
 ,@Education3CredentialCode						varchar(15) output
 ,@Education3GraduationYear						smallint		output
 ,@Education3StateProvinceISONumber		smallint		output
 ,@Education3CountryISONumber					smallint		output
 ,@Education3IsDefaultCountry					bit					output
 ,@RegistrantPracticeSID							int					output
 ,@EmploymentStatusCode								varchar(20) output
 ,@EmploymentCount										smallint		output
 ,@PracticeHours											smallint		output
 ,@Employment1RegistrantEmploymentSID int					output
 ,@Employment1TypeCode								varchar(20) output
 ,@Employment1StateProvinceISONumber	smallint		output
 ,@Employment1PostalCode							varchar(10) output
 ,@Employment1OrgTypeCode							varchar(20) output
 ,@Employment1PracticeScopeCode				varchar(20) output
 ,@Employment1RoleCode								varchar(20) output
 ,@Employment2RegistrantEmploymentSID int					output
 ,@Employment2TypeCode								varchar(20) output
 ,@Employment2StateProvinceISONumber	smallint		output
 ,@Employment2PostalCode							varchar(10) output
 ,@Employment2OrgTypeCode							varchar(20) output
 ,@Employment2PracticeScopeCode				varchar(20) output
 ,@Employment2RoleCode								varchar(20) output
 ,@Employment3RegistrantEmploymentSID int					output
 ,@Employment3TypeCode								varchar(20) output
 ,@Employment3StateProvinceISONumber	smallint		output
 ,@Employment3PostalCode							varchar(10) output
 ,@Employment3OrgTypeCode							varchar(20) output
 ,@Employment3PracticeScopeCode				varchar(20) output
 ,@Employment3RoleCode								varchar(20) output
as
/*********************************************************************************************************************************
Sproc    : Registration Profile Update - Refresh
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure updates coded values on the profile based on changes in the FK or requests to "refresh" current record
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Jul 2018		|	Initial version
Comments	
--------
This is a subroutine of the registration-profile update process.  It supports manual editing of profile records where the user
performs any of the following actions:

1) Changes an existing foreign key value
2) Requests "refresh" of the existing foreign key value
3) Adds a foreign key (changes from NULL to a value)
4) Deletes a foreign key (changes from a value to NULL)

The foreign keys which are supported include:
	o PersonMailingAddressSID
	o RegistrantPracticeSID
	o Employment1RegistrantEmployment
	o Employment2RegistrantEmployment
	o Employment2RegistrantEmployment
	o Education1RegistrantCredential
	o Education2RegistrantCredential
	o Education3RegistrantCredential

The procedure updates the values in the output parameters (column variables in the callilng sproc) when a change in the foreign
key value is detected.  The calling procedure may also force refresh of the values for current value of the foreign key by 
passing that value as a negative number.  The procedure turns on the @refresh variable and multiplies the FK value by -1 to 
reset it back to its original value before saving the record.

For the 3 employment record keys, the procedure avoids updating values when the key value is changing but the new key value
is reflected in one of the other 2 positions for employment.  The UI allows the end user to re-order the employment records
- e.g. moving Employment #2 to Employment #1's position - and this must be possible without executing a refresh.  The 
procedure accomplishes this by only performing the refresh where the new key value is not found in any of the 3 possible
positions for employers.

The procedure does not update the database.  The output variables are returned to the caller which performs the update. 
Any errors which may occur are raised directly to the caller.  A local error handling block is not included.

Known Limitations
-----------------
The current version of the procedure does not support refrehsing individual columns on the profile but only all columns associated
with one of the 8 FK's identified above.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the parent procedure to update the mailing address (same key) 
	for a record selected at random">
    <SQLScript>
      <![CDATA[
declare
	@registrationProfileSID	 int
 ,@personMailingAddressSID int;

select top (1)
	@registrationProfileSID	 = x.RegistrationProfileSID
 ,@personMailingAddressSID = (-1 * x.PersonMailingAddressSID)
from
	dbo.RegistrationProfile	 x
join
	dbo.RegistrationSnapshot rs on x.RegistrationSnapshotSID = rs.RegistrationSnapshotSID
where
	rs.LockedTime is null
order by
	newid();

exec dbo.pRegistrationProfile#Update
	@RegistrationProfileSID = @registrationProfileSID
 ,@PersonMailingAddressSID = @personMailingAddressSID;

select
	rp.RegistrantNo
 ,rp.PersonMailingAddressSID
 ,rp.ResidenceStateProvinceISONumber
 ,rp.ResidencePostalCode
 ,rp.ResidenceCountryISONumber
 ,rp.ResidenceIsDefaultCountry
from
	dbo.RegistrationProfile rp
where
	rp.RegistrationProfileSID = @registrationProfileSID;


		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrationProfile#Update$Refresh'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@ON			 bit = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF		 bit = cast(0 as bit) -- constant for bit comparison = 0
	 ,@refresh bit;									-- tracks whether refresh of codes of same FK is required

	-- if mailing address FK value has changed or a refresh
	-- has been requested then re-populate associated columns 
	-- based on the key

	set @refresh = @OFF;

	if @PersonMailingAddressSID < 0
	begin
		set @refresh = @ON;
		set @PersonMailingAddressSID = (-1 * @PersonMailingAddressSID);
	end;

	if @PersonMailingAddressSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID and isnull(rp.PersonMailingAddressSID, -1) = @PersonMailingAddressSID
		)	 or @refresh = @ON
		begin

			select
				@ResidenceStateProvinceISONumber = sp.ISONumber
			 ,@ResidencePostalCode						 = pma.PostalCode
			 ,@ResidenceCountryISONumber			 = c.ISONumber
			 ,@ResidenceIsDefaultCountry			 = c.IsDefault
			from
				dbo.PersonMailingAddress pma
			join
				dbo.City								 cty on pma.CitySID					= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 c on sp.CountrySID					= c.CountrySID
			where
				pma.PersonMailingAddressSID = @PersonMailingAddressSID;

		end;

	end;
	else -- FK value is null so set associated column to null
	begin
		set @ResidenceStateProvinceISONumber = null;
		set @ResidencePostalCode = null;
		set @ResidenceCountryISONumber = null;
		set @ResidenceIsDefaultCountry = @OFF;
	end;

	-- Registrant Practice (employment status)

	set @refresh = @OFF;

	if @RegistrantPracticeSID < 0
	begin
		set @refresh = @ON;
		set @RegistrantPracticeSID = (-1 * @RegistrantPracticeSID);
	end;

	if @RegistrantPracticeSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID and isnull(rp.RegistrantPracticeSID, -1) = @RegistrantPracticeSID
		)	 or @refresh = @ON
		begin

			select
				@EmploymentStatusCode = es.EmploymentStatusCode
			from
				dbo.RegistrantPractice regP
			join
				dbo.EmploymentStatus	 es on regP.EmploymentStatusSID = es.EmploymentStatusSID
			where
				regP.RegistrantPracticeSID = @RegistrantPracticeSID;

		end;

	end;
	else -- FK value is null so set associated column to null
	begin
		set @EmploymentStatusCode = null;
	end;

	-- Employment#1 - if employment 1 FK value has changed or a refresh
	-- for the existing key was requested, lookup and re-populate columns;
	-- the search for a changed key occurs in all 3 slots as user may
	-- be re-ordering existing employers

	set @refresh = @OFF;

	if @Employment1RegistrantEmploymentSID < 0
	begin
		set @refresh = @ON;
		set @Employment1RegistrantEmploymentSID = (-1 * @Employment1RegistrantEmploymentSID);
	end;

	if @Employment1RegistrantEmploymentSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID															 = @RegistrationProfileSID
				and
				(
					isnull(rp.Employment1RegistrantEmploymentSID, -1)		 = @Employment1RegistrantEmploymentSID -- check all 3 slots for new key
					or isnull(rp.Employment2RegistrantEmploymentSID, -1) = @Employment1RegistrantEmploymentSID -- if found re-ordering of existing employments is occurring
					or isnull(rp.Employment3RegistrantEmploymentSID, -1) = @Employment1RegistrantEmploymentSID
				)
		)
			 or @refresh = @ON
		begin

			select
				@Employment1TypeCode							 = et.EmploymentTypeCode
			 ,@Employment1StateProvinceISONumber = sp.ISONumber
			 ,@Employment1OrgTypeCode						 = ot.OrgTypeCode
			 ,@Employment1PracticeScopeCode			 = ps.PracticeScopeCode
			 ,@Employment1RoleCode							 = er.EmploymentRoleCode
			from
				dbo.RegistrantEmployment re
			join
				dbo.Org									 o on re.OrgSID							= o.OrgSID
			join
				dbo.EmploymentType			 et on re.EmploymentTypeSID = et.EmploymentTypeSID
			join
				dbo.PracticeScope				 ps on re.PracticeScopeSID	= ps.PracticeScopeSID
			join
				dbo.EmploymentRole			 er on re.EmploymentRoleSID = er.EmploymentRoleSID
			join
				dbo.OrgType							 ot on o.OrgTypeSID					= ot.OrgTypeSID
			join
				dbo.City								 cty on o.CitySID						= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 c on sp.CountrySID					= c.CountrySID
			where
				re.RegistrantEmploymentSID = @Employment1RegistrantEmploymentSID;

			set @PracticeHours = -1; -- set value to force refresh of hours since employment was updated

		end;
	end;
	else
	begin

		set @Employment1TypeCode = null;
		set @Employment1StateProvinceISONumber = null;
		set @Employment1OrgTypeCode = null;
		set @Employment1PracticeScopeCode = null;
		set @Employment1RoleCode = null;

	end;

	-- Employment#2 (see comments above)

	set @refresh = @OFF;

	if @Employment2RegistrantEmploymentSID < 0
	begin
		set @refresh = @ON;
		set @Employment2RegistrantEmploymentSID = -1 * @Employment2RegistrantEmploymentSID;
	end;

	if @Employment2RegistrantEmploymentSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID															 = @RegistrationProfileSID
				and
				(
					isnull(rp.Employment1RegistrantEmploymentSID, -1)		 = @Employment2RegistrantEmploymentSID -- check all 3 slots for new key
					or isnull(rp.Employment2RegistrantEmploymentSID, -1) = @Employment2RegistrantEmploymentSID -- if found re-ordering of existing employments is occurring
					or isnull(rp.Employment3RegistrantEmploymentSID, -1) = @Employment2RegistrantEmploymentSID
				)
		)
			 or @refresh = @ON
		begin

			select
				@Employment2TypeCode							 = et.EmploymentTypeCode
			 ,@Employment2StateProvinceISONumber = sp.ISONumber
			 ,@Employment2OrgTypeCode						 = ot.OrgTypeCode
			 ,@Employment2PracticeScopeCode			 = ps.PracticeScopeCode
			 ,@Employment2RoleCode							 = er.EmploymentRoleCode
			from
				dbo.RegistrantEmployment re
			join
				dbo.Org									 o on re.OrgSID							= o.OrgSID
			join
				dbo.EmploymentType			 et on re.EmploymentTypeSID = et.EmploymentTypeSID
			join
				dbo.PracticeScope				 ps on re.PracticeScopeSID	= ps.PracticeScopeSID
			join
				dbo.EmploymentRole			 er on re.EmploymentRoleSID = er.EmploymentRoleSID
			join
				dbo.OrgType							 ot on o.OrgTypeSID					= ot.OrgTypeSID
			join
				dbo.City								 cty on o.CitySID						= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 c on sp.CountrySID					= c.CountrySID
			where
				re.RegistrantEmploymentSID = @Employment2RegistrantEmploymentSID;

			set @PracticeHours = -1;

		end;
	end;
	else
	begin

		set @Employment2TypeCode = null;
		set @Employment2StateProvinceISONumber = null;
		set @Employment2OrgTypeCode = null;
		set @Employment2PracticeScopeCode = null;
		set @Employment2RoleCode = null;

	end;

	-- Employment#3 (see comments above)

	set @refresh = @OFF;

	if @Employment3RegistrantEmploymentSID < 0
	begin
		set @refresh = @ON;
		set @Employment3RegistrantEmploymentSID = -1 * @Employment3RegistrantEmploymentSID;
	end;

	if @Employment3RegistrantEmploymentSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID															 = @RegistrationProfileSID
				and
				(
					isnull(rp.Employment1RegistrantEmploymentSID, -1)		 = @Employment3RegistrantEmploymentSID -- check all 3 slots for new key
					or isnull(rp.Employment2RegistrantEmploymentSID, -1) = @Employment3RegistrantEmploymentSID -- if found re-ordering of existing employments is occurring
					or isnull(rp.Employment3RegistrantEmploymentSID, -1) = @Employment3RegistrantEmploymentSID
				)
		)
			 or @refresh = @ON
		begin

			select
				@Employment3TypeCode							 = et.EmploymentTypeCode
			 ,@Employment3StateProvinceISONumber = sp.ISONumber
			 ,@Employment3OrgTypeCode						 = ot.OrgTypeCode
			 ,@Employment3PracticeScopeCode			 = ps.PracticeScopeCode
			 ,@Employment3RoleCode							 = er.EmploymentRoleCode
			from
				dbo.RegistrantEmployment re
			join
				dbo.Org									 o on re.OrgSID							= o.OrgSID
			join
				dbo.EmploymentType			 et on re.EmploymentTypeSID = et.EmploymentTypeSID
			join
				dbo.PracticeScope				 ps on re.PracticeScopeSID	= ps.PracticeScopeSID
			join
				dbo.EmploymentRole			 er on re.EmploymentRoleSID = er.EmploymentRoleSID
			join
				dbo.OrgType							 ot on o.OrgTypeSID					= ot.OrgTypeSID
			join
				dbo.City								 cty on o.CitySID						= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 c on sp.CountrySID					= c.CountrySID
			where
				re.RegistrantEmploymentSID = @Employment3RegistrantEmploymentSID;

			set @PracticeHours = -1;

		end;
	end;
	else
	begin

		set @Employment3TypeCode = null;
		set @Employment3StateProvinceISONumber = null;
		set @Employment3OrgTypeCode = null;
		set @Employment3PracticeScopeCode = null;
		set @Employment3RoleCode = null;

	end;

	-- update the employment count to match the current count of 
	-- keys (adjusts for manual add and delete of employers)

	set @EmploymentCount = (case
														when isnull(@Employment3RegistrantEmploymentSID, -1) <> -1 then 3
														when isnull(@Employment2RegistrantEmploymentSID, -1) <> -1 then 2
														when isnull(@Employment1RegistrantEmploymentSID, -1) <> -1 then 1
														else 0
													end
												 );

	-- if the user has entered -1 into the hours field or any employers
	-- were refreshed then, revise the total for the employment records 

	if @PracticeHours = -1
	begin

		select
			@PracticeHours = isnull(sum(re.PracticeHours), 0)
		from
			dbo.RegistrantEmployment re
		join
			dbo.RegistrationSnapshot rs on rs.RegistrationSnapshotSID = @RegistrationSnapshotSID
		where
			re.RegistrantSID = @RegistrantSID and re.RegistrationYear = (rs.RegistrationYear - 1);	-- only previous year - all employers (not just top 3)

	end;

	-- Education#1 - if education 1 FK value has changed or a refresh
	-- for the existing key was requested, lookup and re-populate columns;

	set @refresh = @OFF;

	if @Education1RegistrantCredentialSID < 0
	begin
		set @refresh = @ON;
		set @Education1RegistrantCredentialSID = (-1 * @Education1RegistrantCredentialSID);
	end;

	if @Education1RegistrantCredentialSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID and isnull(rp.Education1RegistrantCredentialSID, -1) = @Education1RegistrantCredentialSID
		)
			 or @refresh = @ON
		begin

			select
				@Education1CredentialCode					= c.CredentialCode
			 ,@Education1StateProvinceISONumber = sp.ISONumber
			 ,@Education1CountryISONumber				= ctry.ISONumber
			 ,@Education1IsDefaultCountry				= ctry.IsDefault
			 ,@Education1GraduationYear					= year(rc.EffectiveTime)
			from
				dbo.RegistrantCredential rc
			join
				dbo.Org									 o on rc.OrgSID							= o.OrgSID
			join
				dbo.Credential					 c on rc.CredentialSID			= c.CredentialSID
			join
				dbo.City								 cty on o.CitySID						= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 ctry on sp.CountrySID			= ctry.CountrySID
			where
				rc.RegistrantCredentialSID = @Education1RegistrantCredentialSID;

		end;
	end;
	else
	begin
		set @Education1CredentialCode = null;
		set @Education1StateProvinceISONumber = null;
		set @Education1CountryISONumber = null;
		set @Education1IsDefaultCountry = @OFF;
		set @Education1GraduationYear = null;
	end;

	-- Education #2

	set @refresh = @OFF;

	if @Education2RegistrantCredentialSID < 0
	begin
		set @refresh = @ON;
		set @Education2RegistrantCredentialSID = (-1 * @Education2RegistrantCredentialSID);
	end;

	if @Education2RegistrantCredentialSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID and isnull(rp.Education2RegistrantCredentialSID, -1) = @Education2RegistrantCredentialSID
		)
			 or @refresh = @ON
		begin

			select
				@Education2CredentialCode					= c.CredentialCode
			 ,@Education2StateProvinceISONumber = sp.ISONumber
			 ,@Education2CountryISONumber				= ctry.ISONumber
			 ,@Education2IsDefaultCountry				= ctry.IsDefault
			 ,@Education2GraduationYear					= year(rc.EffectiveTime)
			from
				dbo.RegistrantCredential rc
			join
				dbo.Org									 o on rc.OrgSID							= o.OrgSID
			join
				dbo.Credential					 c on rc.CredentialSID			= c.CredentialSID
			join
				dbo.City								 cty on o.CitySID						= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 ctry on sp.CountrySID			= ctry.CountrySID
			where
				rc.RegistrantCredentialSID = @Education2RegistrantCredentialSID;

		end;
	end;
	else
	begin
		set @Education2CredentialCode = null;
		set @Education2StateProvinceISONumber = null;
		set @Education2CountryISONumber = null;
		set @Education2IsDefaultCountry = @OFF;
		set @Education2GraduationYear = null;
	end;

	-- Education#3

	set @refresh = @OFF;

	if @Education3RegistrantCredentialSID < 0
	begin
		set @refresh = @ON;
		set @Education3RegistrantCredentialSID = (-1 * @Education3RegistrantCredentialSID);
	end;

	if @Education3RegistrantCredentialSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID and isnull(rp.Education3RegistrantCredentialSID, -1) = @Education3RegistrantCredentialSID
		)
			 or @refresh = @ON
		begin

			select
				@Education3CredentialCode					= c.CredentialCode
			 ,@Education3StateProvinceISONumber = sp.ISONumber
			 ,@Education3CountryISONumber				= ctry.ISONumber
			 ,@Education3IsDefaultCountry				= ctry.IsDefault
			 ,@Education3GraduationYear					= year(rc.EffectiveTime)
			from
				dbo.RegistrantCredential rc
			join
				dbo.Org									 o on rc.OrgSID							= o.OrgSID
			join
				dbo.Credential					 c on rc.CredentialSID			= c.CredentialSID
			join
				dbo.City								 cty on o.CitySID						= cty.CitySID
			join
				dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country							 ctry on sp.CountrySID			= ctry.CountrySID
			where
				rc.RegistrantCredentialSID = @Education3RegistrantCredentialSID;

		end;
	end;
	else
	begin
		set @Education3CredentialCode = null;
		set @Education3StateProvinceISONumber = null;
		set @Education3CountryISONumber = null;
		set @Education3IsDefaultCountry = @OFF;
		set @Education3GraduationYear = null;
	end;

	return (0);
end;
GO
