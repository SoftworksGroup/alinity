SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantEmployment#Upsert
	@RegistrantEmploymentSID				int = null output					-- key of existing record to update or output of new key when inserted
 ,@RowGUID												uniqueidentifier					-- pass sub-form ID here
 ,@RegistrantSID									int = null								-- table column values to update:
 ,@OrgSID													int = null
 ,@RegistrationYear								smallint = null
 ,@EmploymentTypeSID							int = null
 ,@EmploymentRoleSID							int = null
 ,@PracticeHours									int = null
 ,@PracticeScopeSID								int = null
 ,@AgeRangeSID										int = null
 ,@IsOnPublicRegistry							bit = null
 ,@Phone													varchar(25) = null
 ,@SiteLocation										nvarchar(50) = null
 ,@EffectiveTime									datetime = null
 ,@ExpiryTime											datetime = null
 ,@Rank														smallint = null
 ,@OwnershipPercentage						smallint = null
 ,@IsEmployerInsurance						bit = null
 ,@InsuranceOrgSID								int = null
 ,@InsurancePolicyNo							varchar(25) = null
 ,@InsuranceAmount								decimal(11, 2) = null
 ,@UserDefinedColumns							xml = null
 ,@RegistrantEmploymentXID				varchar(150) = null
 ,@LegacyKey											nvarchar(50) = null
 ,@UpdateUser											nvarchar(75) = null				-- set to current application user unless "SystemUser" passed
 ,@RowStamp												timestamp = null					-- row time stamp - pass for preemptive check for overwrites
 ,@IsReselected										tinyint = 0								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
 ,@IsNullApplied									bit = 0										-- when 1 null parameters overwrite corresponding columns with null
 ,@zContext												xml = null								-- other values defining context for the update (if any)
 ,@AgeRangeTypeSID								int = null								-- not a base table column
 ,@AgeRangeLabel									nvarchar(35) = null				-- not a base table column
 ,@StartAge												smallint = null						-- not a base table column
 ,@EndAge													smallint = null						-- not a base table column
 ,@AgeRangeIsDefault							bit = null								-- not a base table column
 ,@AgeRangeRowGUID								uniqueidentifier = null		-- not a base table column
 ,@EmploymentRoleName							nvarchar(50) = null				-- not a base table column
 ,@EmploymentRoleCode							varchar(20) = null				-- not a base table column
 ,@EmploymentRoleIsDefault				bit = null								-- not a base table column
 ,@EmploymentRoleIsActive					bit = null								-- not a base table column
 ,@EmploymentRoleRowGUID					uniqueidentifier = null		-- not a base table column
 ,@EmploymentTypeName							nvarchar(50) = null				-- not a base table column
 ,@EmploymentTypeCode							varchar(20) = null				-- not a base table column
 ,@EmploymentTypeCategory					nvarchar(65) = null				-- not a base table column
 ,@EmploymentTypeIsDefault				bit = null								-- not a base table column
 ,@EmploymentTypeIsActive					bit = null								-- not a base table column
 ,@EmploymentTypeRowGUID					uniqueidentifier = null		-- not a base table column
 ,@ParentOrgSID										int = null								-- not a base table column
 ,@OrgTypeSID											int = null								-- not a base table column
 ,@OrgName												nvarchar(150) = null			-- not a base table column
 ,@OrgLabel												nvarchar(35) = null				-- not a base table column
 ,@StreetAddress1									nvarchar(75) = null				-- not a base table column
 ,@StreetAddress2									nvarchar(75) = null				-- not a base table column
 ,@StreetAddress3									nvarchar(75) = null				-- not a base table column
 ,@CitySID												int = null								-- not a base table column
 ,@PostalCode											varchar(10) = null				-- not a base table column
 ,@RegionSID											int = null								-- not a base table column
 ,@OrgPhone												varchar(25) = null				-- not a base table column
 ,@Fax														varchar(25) = null				-- not a base table column
 ,@WebSite												varchar(250) = null				-- not a base table column
 ,@IsEmployer											bit = null								-- not a base table column
 ,@IsCredentialAuthority					bit = null								-- not a base table column
 ,@IsInsurer											bit = null								-- not a base table column
 ,@OrgIsActive										bit = null								-- not a base table column
 ,@IsAdminReviewRequired					bit = null								-- not a base table column
 ,@LastVerifiedTime								datetimeoffset(7) = null	-- not a base table column
 ,@OrgRowGUID											uniqueidentifier = null		-- not a base table column
 ,@PracticeScopeName							nvarchar(50) = null				-- not a base table column
 ,@PracticeScopeCode							varchar(20) = null				-- not a base table column
 ,@PracticeScopeIsDefault					bit = null								-- not a base table column
 ,@PracticeScopeIsActive					bit = null								-- not a base table column
 ,@PracticeScopeRowGUID						uniqueidentifier = null		-- not a base table column
 ,@PersonSID											int = null								-- not a base table column
 ,@RegistrantNo										varchar(50) = null				-- not a base table column
 ,@YearOfInitialEmployment				smallint = null						-- not a base table column
 ,@RegistrantIsOnPublicRegistry		bit = null								-- not a base table column
 ,@DirectedAuditYearCompetence		smallint = null						-- not a base table column
 ,@DirectedAuditYearPracticeHours smallint = null						-- not a base table column
 ,@LateFeeExclusionYear						smallint = null						-- not a base table column
 ,@IsRenewalAutoApprovalBlocked		bit = null								-- not a base table column
 ,@RenewalExtensionExpiryTime			datetime = null						-- not a base table column
 ,@ArchivedTime										datetimeoffset(7) = null	-- not a base table column
 ,@RegistrantRowGUID							uniqueidentifier = null		-- not a base table column
 ,@IsActive												bit = null								-- not a base table column
 ,@IsPending											bit = null								-- not a base table column
 ,@IsDeleteEnabled								bit = null								-- not a base table column
 ,@IsSelfEmployed									bit = null								-- not a base table column
 ,@EmploymentRankNo								int = null								-- not a base table column
 ,@PrimaryPracticeAreaSID					int = null								-- not a base table column
 ,@PrimaryPracticeAreaName				nvarchar(50) = null				-- not a base table column
 ,@PrimaryPracticeAreaCode				varchar(20) = null				-- not a base table column
 ,@IsPracticeScopeRequired				bit = null								-- not a base table column
 ,@EmploymentSupervisorSID				int = null								-- not a base table column
 ,@SupervisorPersonSID						int = null								-- not a base table column

as
/*********************************************************************************************************************************
Procedure: Registrant Employment - Upsert
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates or inserts a record in the in the dbo.RegistrantEmployment table
----------------------------------------------------------------------------------------------------------------------------------
History	 : Author							| Month Year	| Change Summary
				 : ------------------ + ----------- + ------------------------------------------------------------------------------------
 				 : Tim Edlund         | Oct 2017		|	Initial version
				 : Russ Poirier				| Feb 2018		|	Added lookup of @RegistrantSID based on @PersonSID passed in
				 : Tim Edlund					| Oct 2018		| Added pass-through of SupervisorPersonSID to add dbo.EmploymentSupervisor
				 : Russ Poirier				|	Nov 2018		|	Modified sproc to use RowGUID for record searching
				 : Tim Edlund					| Mar 2019		| Added insurance columns to call syntax of sproc and #insert/#update

Comments	
--------
This procedure is a wrapper for the #Insert and #Update procedures on the table. The procedure is called during form processing 
(from sf.pForm#Post) to save values on new registrant-employer records. When a primary key value is provided the #Upsert sproc
is always called.  If a key is not provided, but a record already exists for that registrant and employer combination in the
same registration year and role, then the existing record is updated with the @PracticeHours amount added onto the previous
total of hours. This handles the scenario where the registrant works for the same employer in the same role multiple times
in the same registration year but with a break in timing between employments.

Form Design
-----------
When configuring renewal forms that include effective and expiry dates, out join to dbo.OrgContact on the dblink setup for
dbo.RegistrantEmployment.  This will populate the effective time value where it exists.  Another dblink must be created for
dbo.OrgContact and established as an UPSERT type in order to see that this procedure is called.
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	set @RegistrantEmploymentSID = null; -- populate output variable in all code paths

	if @RegistrationYear is null
		set @RegistrationYear = dbo.fRegistrationYear#Current();

	begin try

		if @PersonSID is not null and @RegistrantSID is null
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID;

		end;

		-- unless a primary key value is provided, check if the registrant 
		-- already has a record for this employer in the same year and role

		if @RowGUID is not null
		begin

			select
				@RegistrantEmploymentSID = re.RegistrantEmploymentSID
			from
				dbo.RegistrantEmployment re
			where
				re.RowGUID = @RowGUID and re.RegistrationYear = @RegistrationYear;

		end;

		-- call #update on existing records or #insert if a new record
		-- is required

		if @RegistrantEmploymentSID is not null and @RegistrantEmploymentSID <> -1
		begin

			exec dbo.pRegistrantEmployment#Update
				@RegistrantEmploymentSID = @RegistrantEmploymentSID
			 ,@RegistrantSID = @RegistrantSID
			 ,@OrgSID = @OrgSID
			 ,@RegistrationYear = @RegistrationYear
			 ,@EmploymentTypeSID = @EmploymentTypeSID
			 ,@EmploymentRoleSID = @EmploymentRoleSID
			 ,@PracticeHours = @PracticeHours
			 ,@PrimaryPracticeAreaSID = @PrimaryPracticeAreaSID
			 ,@PracticeScopeSID = @PracticeScopeSID
			 ,@AgeRangeSID = @AgeRangeSID
			 ,@IsOnPublicRegistry = @IsOnPublicRegistry
			 ,@Phone = @Phone
			 ,@PersonSID = @PersonSID
			 ,@UserDefinedColumns = @UserDefinedColumns
			 ,@RegistrantEmploymentXID = @RegistrantEmploymentXID
			 ,@LegacyKey = @LegacyKey
			 ,@SiteLocation = @SiteLocation
			 ,@EffectiveTime = @EffectiveTime
			 ,@ExpiryTime = @ExpiryTime
			 ,@Rank = @Rank
			 ,@OwnershipPercentage = @OwnershipPercentage
			 ,@IsEmployerInsurance = @IsEmployerInsurance
			 ,@InsuranceOrgSID = @InsuranceOrgSID
			 ,@InsurancePolicyNo = @InsurancePolicyNo
			 ,@InsuranceAmount = @InsuranceAmount
			 ,@IsSelfEmployed = @IsSelfEmployed
			 ,@SupervisorPersonSID = @SupervisorPersonSID;

		end;
		else
		begin

			exec dbo.pRegistrantEmployment#Insert
				@RegistrantEmploymentSID = @RegistrantEmploymentSID output
			 ,@RegistrantSID = @RegistrantSID
			 ,@OrgSID = @OrgSID
			 ,@RegistrationYear = @RegistrationYear
			 ,@EmploymentTypeSID = @EmploymentTypeSID
			 ,@EmploymentRoleSID = @EmploymentRoleSID
			 ,@PracticeHours = @PracticeHours
			 ,@PrimaryPracticeAreaSID = @PrimaryPracticeAreaSID
			 ,@PracticeScopeSID = @PracticeScopeSID
			 ,@AgeRangeSID = @AgeRangeSID
			 ,@IsOnPublicRegistry = @IsOnPublicRegistry
			 ,@Phone = @Phone
			 ,@PersonSID = @PersonSID
			 ,@UserDefinedColumns = @UserDefinedColumns
			 ,@RegistrantEmploymentXID = @RegistrantEmploymentXID
			 ,@LegacyKey = @LegacyKey
			 ,@SiteLocation = @SiteLocation
			 ,@EffectiveTime = @EffectiveTime
			 ,@ExpiryTime = @ExpiryTime
			 ,@Rank = @Rank
			 ,@OwnershipPercentage = @OwnershipPercentage
			 ,@IsEmployerInsurance = @IsEmployerInsurance
			 ,@InsuranceOrgSID = @InsuranceOrgSID
			 ,@InsurancePolicyNo = @InsurancePolicyNo
			 ,@InsuranceAmount = @InsuranceAmount
			 ,@IsSelfEmployed = @IsSelfEmployed
			 ,@SupervisorPersonSID = @SupervisorPersonSID;

		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
