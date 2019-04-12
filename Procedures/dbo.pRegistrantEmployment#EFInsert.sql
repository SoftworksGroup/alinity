SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantEmployment#EFInsert]
	 @RegistrantSID                              int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@OrgSID                                     int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                           smallint          = null		-- default: sf.fTodayYear()
	,@EmploymentTypeSID                          int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@EmploymentRoleSID                          int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeHours                              int               = null		-- default: (0)
	,@PracticeScopeSID                           int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@AgeRangeSID                                int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@IsOnPublicRegistry                         bit               = null		-- default: CONVERT(bit,(1))
	,@Phone                                      varchar(25)       = null		
	,@SiteLocation                               nvarchar(50)      = null		
	,@EffectiveTime                              datetime          = null		
	,@ExpiryTime                                 datetime          = null		
	,@Rank                                       smallint          = null		-- default: (5)
	,@OwnershipPercentage                        smallint          = null		-- default: (0)
	,@IsEmployerInsurance                        bit               = null		-- default: CONVERT(bit,(0))
	,@InsuranceOrgSID                            int               = null		
	,@InsurancePolicyNo                          varchar(25)       = null		
	,@InsuranceAmount                            decimal(11,2)     = null		
	,@UserDefinedColumns                         xml               = null		
	,@RegistrantEmploymentXID                    varchar(150)      = null		
	,@LegacyKey                                  nvarchar(50)      = null		
	,@CreateUser                                 nvarchar(75)      = null		-- default: suser_sname()
	,@IsReselected                               tinyint           = null		-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                   xml               = null		-- other values defining context for the insert (if any)
	,@AgeRangeTypeSID                            int               = null		-- not a base table column (default ignored)
	,@AgeRangeLabel                              nvarchar(35)      = null		-- not a base table column (default ignored)
	,@StartAge                                   smallint          = null		-- not a base table column (default ignored)
	,@EndAge                                     smallint          = null		-- not a base table column (default ignored)
	,@AgeRangeIsDefault                          bit               = null		-- not a base table column (default ignored)
	,@AgeRangeRowGUID                            uniqueidentifier  = null		-- not a base table column (default ignored)
	,@EmploymentRoleName                         nvarchar(50)      = null		-- not a base table column (default ignored)
	,@EmploymentRoleCode                         varchar(20)       = null		-- not a base table column (default ignored)
	,@EmploymentRoleIsDefault                    bit               = null		-- not a base table column (default ignored)
	,@EmploymentRoleIsActive                     bit               = null		-- not a base table column (default ignored)
	,@EmploymentRoleRowGUID                      uniqueidentifier  = null		-- not a base table column (default ignored)
	,@EmploymentTypeName                         nvarchar(50)      = null		-- not a base table column (default ignored)
	,@EmploymentTypeCode                         varchar(20)       = null		-- not a base table column (default ignored)
	,@EmploymentTypeCategory                     nvarchar(65)      = null		-- not a base table column (default ignored)
	,@EmploymentTypeIsDefault                    bit               = null		-- not a base table column (default ignored)
	,@EmploymentTypeIsActive                     bit               = null		-- not a base table column (default ignored)
	,@EmploymentTypeRowGUID                      uniqueidentifier  = null		-- not a base table column (default ignored)
	,@OrgParentOrgSID                            int               = null		-- not a base table column (default ignored)
	,@OrgOrgTypeSID                              int               = null		-- not a base table column (default ignored)
	,@OrgOrgName                                 nvarchar(150)     = null		-- not a base table column (default ignored)
	,@OrgOrgLabel                                nvarchar(35)      = null		-- not a base table column (default ignored)
	,@OrgStreetAddress1                          nvarchar(75)      = null		-- not a base table column (default ignored)
	,@OrgStreetAddress2                          nvarchar(75)      = null		-- not a base table column (default ignored)
	,@OrgStreetAddress3                          nvarchar(75)      = null		-- not a base table column (default ignored)
	,@OrgCitySID                                 int               = null		-- not a base table column (default ignored)
	,@OrgPostalCode                              varchar(10)       = null		-- not a base table column (default ignored)
	,@OrgRegionSID                               int               = null		-- not a base table column (default ignored)
	,@OrgPhone                                   varchar(25)       = null		-- not a base table column (default ignored)
	,@OrgFax                                     varchar(25)       = null		-- not a base table column (default ignored)
	,@OrgWebSite                                 varchar(250)      = null		-- not a base table column (default ignored)
	,@OrgEmailAddress                            varchar(150)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceOrgSID                         int               = null		-- not a base table column (default ignored)
	,@OrgInsurancePolicyNo                       varchar(25)       = null		-- not a base table column (default ignored)
	,@OrgInsuranceAmount                         decimal(11,2)     = null		-- not a base table column (default ignored)
	,@OrgIsEmployer                              bit               = null		-- not a base table column (default ignored)
	,@OrgIsCredentialAuthority                   bit               = null		-- not a base table column (default ignored)
	,@OrgIsInsurer                               bit               = null		-- not a base table column (default ignored)
	,@OrgIsInsuranceCertificateRequired          bit               = null		-- not a base table column (default ignored)
	,@OrgIsPublic                                nchar(10)         = null		-- not a base table column (default ignored)
	,@OrgIsActive                                bit               = null		-- not a base table column (default ignored)
	,@OrgIsAdminReviewRequired                   bit               = null		-- not a base table column (default ignored)
	,@OrgLastVerifiedTime                        datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@OrgRowGUID                                 uniqueidentifier  = null		-- not a base table column (default ignored)
	,@PracticeScopeName                          nvarchar(50)      = null		-- not a base table column (default ignored)
	,@PracticeScopeCode                          varchar(20)       = null		-- not a base table column (default ignored)
	,@PracticeScopeIsDefault                     bit               = null		-- not a base table column (default ignored)
	,@PracticeScopeIsActive                      bit               = null		-- not a base table column (default ignored)
	,@PracticeScopeRowGUID                       uniqueidentifier  = null		-- not a base table column (default ignored)
	,@PersonSID                                  int               = null		-- not a base table column (default ignored)
	,@RegistrantNo                               varchar(50)       = null		-- not a base table column (default ignored)
	,@YearOfInitialEmployment                    smallint          = null		-- not a base table column (default ignored)
	,@RegistrantIsOnPublicRegistry               bit               = null		-- not a base table column (default ignored)
	,@CityNameOfBirth                            nvarchar(30)      = null		-- not a base table column (default ignored)
	,@CountrySID                                 int               = null		-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence                smallint          = null		-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours             smallint          = null		-- not a base table column (default ignored)
	,@LateFeeExclusionYear                       smallint          = null		-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked               bit               = null		-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime                 datetime          = null		-- not a base table column (default ignored)
	,@ArchivedTime                               datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@RegistrantRowGUID                          uniqueidentifier  = null		-- not a base table column (default ignored)
	,@OrgInsuranceParentOrgSID                   int               = null		-- not a base table column (default ignored)
	,@OrgInsuranceOrgTypeSID                     int               = null		-- not a base table column (default ignored)
	,@OrgInsuranceOrgName                        nvarchar(150)     = null		-- not a base table column (default ignored)
	,@OrgInsuranceOrgLabel                       nvarchar(35)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceStreetAddress1                 nvarchar(75)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceStreetAddress2                 nvarchar(75)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceStreetAddress3                 nvarchar(75)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceCitySID                        int               = null		-- not a base table column (default ignored)
	,@OrgInsurancePostalCode                     varchar(10)       = null		-- not a base table column (default ignored)
	,@OrgInsuranceRegionSID                      int               = null		-- not a base table column (default ignored)
	,@OrgInsurancePhone                          varchar(25)       = null		-- not a base table column (default ignored)
	,@OrgInsuranceFax                            varchar(25)       = null		-- not a base table column (default ignored)
	,@OrgInsuranceWebSite                        varchar(250)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceEmailAddress                   varchar(150)      = null		-- not a base table column (default ignored)
	,@OrgInsuranceInsuranceOrgSID                int               = null		-- not a base table column (default ignored)
	,@OrgInsuranceInsurancePolicyNo              varchar(25)       = null		-- not a base table column (default ignored)
	,@OrgInsuranceInsuranceAmount                decimal(11,2)     = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsEmployer                     bit               = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsCredentialAuthority          bit               = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsInsurer                      bit               = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsInsuranceCertificateRequired bit               = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsPublic                       nchar(10)         = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsActive                       bit               = null		-- not a base table column (default ignored)
	,@OrgInsuranceIsAdminReviewRequired          bit               = null		-- not a base table column (default ignored)
	,@OrgInsuranceLastVerifiedTime               datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@OrgInsuranceRowGUID                        uniqueidentifier  = null		-- not a base table column (default ignored)
	,@IsActive                                   bit               = null		-- not a base table column (default ignored)
	,@IsPending                                  bit               = null		-- not a base table column (default ignored)
	,@IsDeleteEnabled                            bit               = null		-- not a base table column (default ignored)
	,@IsSelfEmployed                             bit               = null		-- not a base table column (default ignored)
	,@EmploymentRankNo                           int               = null		-- not a base table column (default ignored)
	,@PrimaryPracticeAreaSID                     int               = null		-- not a base table column (default ignored)
	,@PrimaryPracticeAreaName                    nvarchar(50)      = null		-- not a base table column (default ignored)
	,@PrimaryPracticeAreaCode                    varchar(20)       = null		-- not a base table column (default ignored)
	,@IsPracticeScopeRequired                    bit               = null		-- not a base table column (default ignored)
	,@EmploymentSupervisorSID                    int               = null		-- not a base table column (default ignored)
	,@SupervisorPersonSID                        int               = null		-- not a base table column (default ignored)
	,@IsPrivateInsurance                         bit               = null		-- not a base table column (default ignored)
	,@EffectiveInsuranceProviderName             nvarchar(150)     = null		-- not a base table column (default ignored)
	,@EffectiveInsurancePolicyNo                 varchar(25)       = null		-- not a base table column (default ignored)
	,@EffectiveInsuranceAmount                   decimal(11,2)     = null		-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantEmployment#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantEmployment#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

	begin try

		-- use a transaction so that any additional updates implemented through the extended
		-- procedure or through table-specific logic succeed or fail as a logical unit

		if @tranCount = 0																											-- no outer transaction
		begin
			begin transaction
		end
		else																																	-- outer transaction so create save point
		begin
			save transaction @sprocName
		end

		-- call the main procedure

		exec @errorNo = dbo.pRegistrantEmployment#Insert
			 @RegistrantSID                              = @RegistrantSID
			,@OrgSID                                     = @OrgSID
			,@RegistrationYear                           = @RegistrationYear
			,@EmploymentTypeSID                          = @EmploymentTypeSID
			,@EmploymentRoleSID                          = @EmploymentRoleSID
			,@PracticeHours                              = @PracticeHours
			,@PracticeScopeSID                           = @PracticeScopeSID
			,@AgeRangeSID                                = @AgeRangeSID
			,@IsOnPublicRegistry                         = @IsOnPublicRegistry
			,@Phone                                      = @Phone
			,@SiteLocation                               = @SiteLocation
			,@EffectiveTime                              = @EffectiveTime
			,@ExpiryTime                                 = @ExpiryTime
			,@Rank                                       = @Rank
			,@OwnershipPercentage                        = @OwnershipPercentage
			,@IsEmployerInsurance                        = @IsEmployerInsurance
			,@InsuranceOrgSID                            = @InsuranceOrgSID
			,@InsurancePolicyNo                          = @InsurancePolicyNo
			,@InsuranceAmount                            = @InsuranceAmount
			,@UserDefinedColumns                         = @UserDefinedColumns
			,@RegistrantEmploymentXID                    = @RegistrantEmploymentXID
			,@LegacyKey                                  = @LegacyKey
			,@CreateUser                                 = @CreateUser
			,@IsReselected                               = @IsReselected
			,@zContext                                   = @zContext
			,@AgeRangeTypeSID                            = @AgeRangeTypeSID
			,@AgeRangeLabel                              = @AgeRangeLabel
			,@StartAge                                   = @StartAge
			,@EndAge                                     = @EndAge
			,@AgeRangeIsDefault                          = @AgeRangeIsDefault
			,@AgeRangeRowGUID                            = @AgeRangeRowGUID
			,@EmploymentRoleName                         = @EmploymentRoleName
			,@EmploymentRoleCode                         = @EmploymentRoleCode
			,@EmploymentRoleIsDefault                    = @EmploymentRoleIsDefault
			,@EmploymentRoleIsActive                     = @EmploymentRoleIsActive
			,@EmploymentRoleRowGUID                      = @EmploymentRoleRowGUID
			,@EmploymentTypeName                         = @EmploymentTypeName
			,@EmploymentTypeCode                         = @EmploymentTypeCode
			,@EmploymentTypeCategory                     = @EmploymentTypeCategory
			,@EmploymentTypeIsDefault                    = @EmploymentTypeIsDefault
			,@EmploymentTypeIsActive                     = @EmploymentTypeIsActive
			,@EmploymentTypeRowGUID                      = @EmploymentTypeRowGUID
			,@OrgParentOrgSID                            = @OrgParentOrgSID
			,@OrgOrgTypeSID                              = @OrgOrgTypeSID
			,@OrgOrgName                                 = @OrgOrgName
			,@OrgOrgLabel                                = @OrgOrgLabel
			,@OrgStreetAddress1                          = @OrgStreetAddress1
			,@OrgStreetAddress2                          = @OrgStreetAddress2
			,@OrgStreetAddress3                          = @OrgStreetAddress3
			,@OrgCitySID                                 = @OrgCitySID
			,@OrgPostalCode                              = @OrgPostalCode
			,@OrgRegionSID                               = @OrgRegionSID
			,@OrgPhone                                   = @OrgPhone
			,@OrgFax                                     = @OrgFax
			,@OrgWebSite                                 = @OrgWebSite
			,@OrgEmailAddress                            = @OrgEmailAddress
			,@OrgInsuranceOrgSID                         = @OrgInsuranceOrgSID
			,@OrgInsurancePolicyNo                       = @OrgInsurancePolicyNo
			,@OrgInsuranceAmount                         = @OrgInsuranceAmount
			,@OrgIsEmployer                              = @OrgIsEmployer
			,@OrgIsCredentialAuthority                   = @OrgIsCredentialAuthority
			,@OrgIsInsurer                               = @OrgIsInsurer
			,@OrgIsInsuranceCertificateRequired          = @OrgIsInsuranceCertificateRequired
			,@OrgIsPublic                                = @OrgIsPublic
			,@OrgIsActive                                = @OrgIsActive
			,@OrgIsAdminReviewRequired                   = @OrgIsAdminReviewRequired
			,@OrgLastVerifiedTime                        = @OrgLastVerifiedTime
			,@OrgRowGUID                                 = @OrgRowGUID
			,@PracticeScopeName                          = @PracticeScopeName
			,@PracticeScopeCode                          = @PracticeScopeCode
			,@PracticeScopeIsDefault                     = @PracticeScopeIsDefault
			,@PracticeScopeIsActive                      = @PracticeScopeIsActive
			,@PracticeScopeRowGUID                       = @PracticeScopeRowGUID
			,@PersonSID                                  = @PersonSID
			,@RegistrantNo                               = @RegistrantNo
			,@YearOfInitialEmployment                    = @YearOfInitialEmployment
			,@RegistrantIsOnPublicRegistry               = @RegistrantIsOnPublicRegistry
			,@CityNameOfBirth                            = @CityNameOfBirth
			,@CountrySID                                 = @CountrySID
			,@DirectedAuditYearCompetence                = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours             = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear                       = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked               = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime                 = @RenewalExtensionExpiryTime
			,@ArchivedTime                               = @ArchivedTime
			,@RegistrantRowGUID                          = @RegistrantRowGUID
			,@OrgInsuranceParentOrgSID                   = @OrgInsuranceParentOrgSID
			,@OrgInsuranceOrgTypeSID                     = @OrgInsuranceOrgTypeSID
			,@OrgInsuranceOrgName                        = @OrgInsuranceOrgName
			,@OrgInsuranceOrgLabel                       = @OrgInsuranceOrgLabel
			,@OrgInsuranceStreetAddress1                 = @OrgInsuranceStreetAddress1
			,@OrgInsuranceStreetAddress2                 = @OrgInsuranceStreetAddress2
			,@OrgInsuranceStreetAddress3                 = @OrgInsuranceStreetAddress3
			,@OrgInsuranceCitySID                        = @OrgInsuranceCitySID
			,@OrgInsurancePostalCode                     = @OrgInsurancePostalCode
			,@OrgInsuranceRegionSID                      = @OrgInsuranceRegionSID
			,@OrgInsurancePhone                          = @OrgInsurancePhone
			,@OrgInsuranceFax                            = @OrgInsuranceFax
			,@OrgInsuranceWebSite                        = @OrgInsuranceWebSite
			,@OrgInsuranceEmailAddress                   = @OrgInsuranceEmailAddress
			,@OrgInsuranceInsuranceOrgSID                = @OrgInsuranceInsuranceOrgSID
			,@OrgInsuranceInsurancePolicyNo              = @OrgInsuranceInsurancePolicyNo
			,@OrgInsuranceInsuranceAmount                = @OrgInsuranceInsuranceAmount
			,@OrgInsuranceIsEmployer                     = @OrgInsuranceIsEmployer
			,@OrgInsuranceIsCredentialAuthority          = @OrgInsuranceIsCredentialAuthority
			,@OrgInsuranceIsInsurer                      = @OrgInsuranceIsInsurer
			,@OrgInsuranceIsInsuranceCertificateRequired = @OrgInsuranceIsInsuranceCertificateRequired
			,@OrgInsuranceIsPublic                       = @OrgInsuranceIsPublic
			,@OrgInsuranceIsActive                       = @OrgInsuranceIsActive
			,@OrgInsuranceIsAdminReviewRequired          = @OrgInsuranceIsAdminReviewRequired
			,@OrgInsuranceLastVerifiedTime               = @OrgInsuranceLastVerifiedTime
			,@OrgInsuranceRowGUID                        = @OrgInsuranceRowGUID
			,@IsActive                                   = @IsActive
			,@IsPending                                  = @IsPending
			,@IsDeleteEnabled                            = @IsDeleteEnabled
			,@IsSelfEmployed                             = @IsSelfEmployed
			,@EmploymentRankNo                           = @EmploymentRankNo
			,@PrimaryPracticeAreaSID                     = @PrimaryPracticeAreaSID
			,@PrimaryPracticeAreaName                    = @PrimaryPracticeAreaName
			,@PrimaryPracticeAreaCode                    = @PrimaryPracticeAreaCode
			,@IsPracticeScopeRequired                    = @IsPracticeScopeRequired
			,@EmploymentSupervisorSID                    = @EmploymentSupervisorSID
			,@SupervisorPersonSID                        = @SupervisorPersonSID
			,@IsPrivateInsurance                         = @IsPrivateInsurance
			,@EffectiveInsuranceProviderName             = @EffectiveInsuranceProviderName
			,@EffectiveInsurancePolicyNo                 = @EffectiveInsurancePolicyNo
			,@EffectiveInsuranceAmount                   = @EffectiveInsuranceAmount

	end try

	begin catch
		set @xState = xact_state()
		
		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName																			-- committable wrapping trx exists: rollback to savepoint
		end
		else if @xState <> 0																									-- full rollback
		begin
			rollback
		end
		
		exec @errorNo = sf.pErrorRethrow																			-- process message text and re-throw the error
	end catch

	return(@errorNo)

end
GO
