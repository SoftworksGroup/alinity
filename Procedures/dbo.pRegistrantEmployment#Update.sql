SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantEmployment#Update]
	 @RegistrantEmploymentSID                    int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                              int               = null -- table column values to update:
	,@OrgSID                                     int               = null
	,@RegistrationYear                           smallint          = null
	,@EmploymentTypeSID                          int               = null
	,@EmploymentRoleSID                          int               = null
	,@PracticeHours                              int               = null
	,@PracticeScopeSID                           int               = null
	,@AgeRangeSID                                int               = null
	,@IsOnPublicRegistry                         bit               = null
	,@Phone                                      varchar(25)       = null
	,@SiteLocation                               nvarchar(50)      = null
	,@EffectiveTime                              datetime          = null
	,@ExpiryTime                                 datetime          = null
	,@Rank                                       smallint          = null
	,@OwnershipPercentage                        smallint          = null
	,@IsEmployerInsurance                        bit               = null
	,@InsuranceOrgSID                            int               = null
	,@InsurancePolicyNo                          varchar(25)       = null
	,@InsuranceAmount                            decimal(11,2)     = null
	,@UserDefinedColumns                         xml               = null
	,@RegistrantEmploymentXID                    varchar(150)      = null
	,@LegacyKey                                  nvarchar(50)      = null
	,@UpdateUser                                 nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                   timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                               tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                              bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                   xml               = null -- other values defining context for the update (if any)
	,@AgeRangeTypeSID                            int               = null -- not a base table column
	,@AgeRangeLabel                              nvarchar(35)      = null -- not a base table column
	,@StartAge                                   smallint          = null -- not a base table column
	,@EndAge                                     smallint          = null -- not a base table column
	,@AgeRangeIsDefault                          bit               = null -- not a base table column
	,@AgeRangeRowGUID                            uniqueidentifier  = null -- not a base table column
	,@EmploymentRoleName                         nvarchar(50)      = null -- not a base table column
	,@EmploymentRoleCode                         varchar(20)       = null -- not a base table column
	,@EmploymentRoleIsDefault                    bit               = null -- not a base table column
	,@EmploymentRoleIsActive                     bit               = null -- not a base table column
	,@EmploymentRoleRowGUID                      uniqueidentifier  = null -- not a base table column
	,@EmploymentTypeName                         nvarchar(50)      = null -- not a base table column
	,@EmploymentTypeCode                         varchar(20)       = null -- not a base table column
	,@EmploymentTypeCategory                     nvarchar(65)      = null -- not a base table column
	,@EmploymentTypeIsDefault                    bit               = null -- not a base table column
	,@EmploymentTypeIsActive                     bit               = null -- not a base table column
	,@EmploymentTypeRowGUID                      uniqueidentifier  = null -- not a base table column
	,@OrgParentOrgSID                            int               = null -- not a base table column
	,@OrgOrgTypeSID                              int               = null -- not a base table column
	,@OrgOrgName                                 nvarchar(150)     = null -- not a base table column
	,@OrgOrgLabel                                nvarchar(35)      = null -- not a base table column
	,@OrgStreetAddress1                          nvarchar(75)      = null -- not a base table column
	,@OrgStreetAddress2                          nvarchar(75)      = null -- not a base table column
	,@OrgStreetAddress3                          nvarchar(75)      = null -- not a base table column
	,@OrgCitySID                                 int               = null -- not a base table column
	,@OrgPostalCode                              varchar(10)       = null -- not a base table column
	,@OrgRegionSID                               int               = null -- not a base table column
	,@OrgPhone                                   varchar(25)       = null -- not a base table column
	,@OrgFax                                     varchar(25)       = null -- not a base table column
	,@OrgWebSite                                 varchar(250)      = null -- not a base table column
	,@OrgEmailAddress                            varchar(150)      = null -- not a base table column
	,@OrgInsuranceOrgSID                         int               = null -- not a base table column
	,@OrgInsurancePolicyNo                       varchar(25)       = null -- not a base table column
	,@OrgInsuranceAmount                         decimal(11,2)     = null -- not a base table column
	,@OrgIsEmployer                              bit               = null -- not a base table column
	,@OrgIsCredentialAuthority                   bit               = null -- not a base table column
	,@OrgIsInsurer                               bit               = null -- not a base table column
	,@OrgIsInsuranceCertificateRequired          bit               = null -- not a base table column
	,@OrgIsPublic                                nchar(10)         = null -- not a base table column
	,@OrgIsActive                                bit               = null -- not a base table column
	,@OrgIsAdminReviewRequired                   bit               = null -- not a base table column
	,@OrgLastVerifiedTime                        datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                                 uniqueidentifier  = null -- not a base table column
	,@PracticeScopeName                          nvarchar(50)      = null -- not a base table column
	,@PracticeScopeCode                          varchar(20)       = null -- not a base table column
	,@PracticeScopeIsDefault                     bit               = null -- not a base table column
	,@PracticeScopeIsActive                      bit               = null -- not a base table column
	,@PracticeScopeRowGUID                       uniqueidentifier  = null -- not a base table column
	,@PersonSID                                  int               = null -- not a base table column
	,@RegistrantNo                               varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment                    smallint          = null -- not a base table column
	,@RegistrantIsOnPublicRegistry               bit               = null -- not a base table column
	,@CityNameOfBirth                            nvarchar(30)      = null -- not a base table column
	,@CountrySID                                 int               = null -- not a base table column
	,@DirectedAuditYearCompetence                smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours             smallint          = null -- not a base table column
	,@LateFeeExclusionYear                       smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked               bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime                 datetime          = null -- not a base table column
	,@ArchivedTime                               datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                          uniqueidentifier  = null -- not a base table column
	,@OrgInsuranceParentOrgSID                   int               = null -- not a base table column
	,@OrgInsuranceOrgTypeSID                     int               = null -- not a base table column
	,@OrgInsuranceOrgName                        nvarchar(150)     = null -- not a base table column
	,@OrgInsuranceOrgLabel                       nvarchar(35)      = null -- not a base table column
	,@OrgInsuranceStreetAddress1                 nvarchar(75)      = null -- not a base table column
	,@OrgInsuranceStreetAddress2                 nvarchar(75)      = null -- not a base table column
	,@OrgInsuranceStreetAddress3                 nvarchar(75)      = null -- not a base table column
	,@OrgInsuranceCitySID                        int               = null -- not a base table column
	,@OrgInsurancePostalCode                     varchar(10)       = null -- not a base table column
	,@OrgInsuranceRegionSID                      int               = null -- not a base table column
	,@OrgInsurancePhone                          varchar(25)       = null -- not a base table column
	,@OrgInsuranceFax                            varchar(25)       = null -- not a base table column
	,@OrgInsuranceWebSite                        varchar(250)      = null -- not a base table column
	,@OrgInsuranceEmailAddress                   varchar(150)      = null -- not a base table column
	,@OrgInsuranceInsuranceOrgSID                int               = null -- not a base table column
	,@OrgInsuranceInsurancePolicyNo              varchar(25)       = null -- not a base table column
	,@OrgInsuranceInsuranceAmount                decimal(11,2)     = null -- not a base table column
	,@OrgInsuranceIsEmployer                     bit               = null -- not a base table column
	,@OrgInsuranceIsCredentialAuthority          bit               = null -- not a base table column
	,@OrgInsuranceIsInsurer                      bit               = null -- not a base table column
	,@OrgInsuranceIsInsuranceCertificateRequired bit               = null -- not a base table column
	,@OrgInsuranceIsPublic                       nchar(10)         = null -- not a base table column
	,@OrgInsuranceIsActive                       bit               = null -- not a base table column
	,@OrgInsuranceIsAdminReviewRequired          bit               = null -- not a base table column
	,@OrgInsuranceLastVerifiedTime               datetimeoffset(7) = null -- not a base table column
	,@OrgInsuranceRowGUID                        uniqueidentifier  = null -- not a base table column
	,@IsActive                                   bit               = null -- not a base table column
	,@IsPending                                  bit               = null -- not a base table column
	,@IsDeleteEnabled                            bit               = null -- not a base table column
	,@IsSelfEmployed                             bit               = null -- not a base table column
	,@EmploymentRankNo                           int               = null -- not a base table column
	,@PrimaryPracticeAreaSID                     int               = null -- not a base table column
	,@PrimaryPracticeAreaName                    nvarchar(50)      = null -- not a base table column
	,@PrimaryPracticeAreaCode                    varchar(20)       = null -- not a base table column
	,@IsPracticeScopeRequired                    bit               = null -- not a base table column
	,@EmploymentSupervisorSID                    int               = null -- not a base table column
	,@SupervisorPersonSID                        int               = null -- not a base table column
	,@IsPrivateInsurance                         bit               = null -- not a base table column
	,@EffectiveInsuranceProviderName             nvarchar(150)     = null -- not a base table column
	,@EffectiveInsurancePolicyNo                 varchar(25)       = null -- not a base table column
	,@EffectiveInsuranceAmount                   decimal(11,2)     = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantEmployment#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantEmployment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantEmployment table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantEmployment entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantEmployment procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Business rule compliance is checked through a table constraint which calls fRegistrantEmploymentCheck to test all rules.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@errorText                                    nvarchar(4000)					-- message text (for business rule errors)
		,@rowsAffected                                 int = 0								-- tracks rows impacted by the operation (error check)
		,@recordSID                                    int										-- tracks primary key value for clearing current default
		,@ON                                           bit = cast(1 as bit)		-- constant for bit comparison and assignments
		,@OFF                                          bit = cast(0 as bit)		-- constant for bit comparison and assignments

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

		-- check parameters

		if @RegistrantEmploymentSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantEmploymentSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @Phone = ltrim(rtrim(@Phone))
		set @SiteLocation = ltrim(rtrim(@SiteLocation))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @RegistrantEmploymentXID = ltrim(rtrim(@RegistrantEmploymentXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @AgeRangeLabel = ltrim(rtrim(@AgeRangeLabel))
		set @EmploymentRoleName = ltrim(rtrim(@EmploymentRoleName))
		set @EmploymentRoleCode = ltrim(rtrim(@EmploymentRoleCode))
		set @EmploymentTypeName = ltrim(rtrim(@EmploymentTypeName))
		set @EmploymentTypeCode = ltrim(rtrim(@EmploymentTypeCode))
		set @EmploymentTypeCategory = ltrim(rtrim(@EmploymentTypeCategory))
		set @OrgOrgName = ltrim(rtrim(@OrgOrgName))
		set @OrgOrgLabel = ltrim(rtrim(@OrgOrgLabel))
		set @OrgStreetAddress1 = ltrim(rtrim(@OrgStreetAddress1))
		set @OrgStreetAddress2 = ltrim(rtrim(@OrgStreetAddress2))
		set @OrgStreetAddress3 = ltrim(rtrim(@OrgStreetAddress3))
		set @OrgPostalCode = ltrim(rtrim(@OrgPostalCode))
		set @OrgPhone = ltrim(rtrim(@OrgPhone))
		set @OrgFax = ltrim(rtrim(@OrgFax))
		set @OrgWebSite = ltrim(rtrim(@OrgWebSite))
		set @OrgEmailAddress = ltrim(rtrim(@OrgEmailAddress))
		set @OrgInsurancePolicyNo = ltrim(rtrim(@OrgInsurancePolicyNo))
		set @OrgIsPublic = ltrim(rtrim(@OrgIsPublic))
		set @PracticeScopeName = ltrim(rtrim(@PracticeScopeName))
		set @PracticeScopeCode = ltrim(rtrim(@PracticeScopeCode))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @OrgInsuranceOrgName = ltrim(rtrim(@OrgInsuranceOrgName))
		set @OrgInsuranceOrgLabel = ltrim(rtrim(@OrgInsuranceOrgLabel))
		set @OrgInsuranceStreetAddress1 = ltrim(rtrim(@OrgInsuranceStreetAddress1))
		set @OrgInsuranceStreetAddress2 = ltrim(rtrim(@OrgInsuranceStreetAddress2))
		set @OrgInsuranceStreetAddress3 = ltrim(rtrim(@OrgInsuranceStreetAddress3))
		set @OrgInsurancePostalCode = ltrim(rtrim(@OrgInsurancePostalCode))
		set @OrgInsurancePhone = ltrim(rtrim(@OrgInsurancePhone))
		set @OrgInsuranceFax = ltrim(rtrim(@OrgInsuranceFax))
		set @OrgInsuranceWebSite = ltrim(rtrim(@OrgInsuranceWebSite))
		set @OrgInsuranceEmailAddress = ltrim(rtrim(@OrgInsuranceEmailAddress))
		set @OrgInsuranceInsurancePolicyNo = ltrim(rtrim(@OrgInsuranceInsurancePolicyNo))
		set @OrgInsuranceIsPublic = ltrim(rtrim(@OrgInsuranceIsPublic))
		set @PrimaryPracticeAreaName = ltrim(rtrim(@PrimaryPracticeAreaName))
		set @PrimaryPracticeAreaCode = ltrim(rtrim(@PrimaryPracticeAreaCode))
		set @EffectiveInsuranceProviderName = ltrim(rtrim(@EffectiveInsuranceProviderName))
		set @EffectiveInsurancePolicyNo = ltrim(rtrim(@EffectiveInsurancePolicyNo))

		-- set zero length strings to null to avoid storing them in the record

		if len(@Phone) = 0 set @Phone = null
		if len(@SiteLocation) = 0 set @SiteLocation = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@RegistrantEmploymentXID) = 0 set @RegistrantEmploymentXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@AgeRangeLabel) = 0 set @AgeRangeLabel = null
		if len(@EmploymentRoleName) = 0 set @EmploymentRoleName = null
		if len(@EmploymentRoleCode) = 0 set @EmploymentRoleCode = null
		if len(@EmploymentTypeName) = 0 set @EmploymentTypeName = null
		if len(@EmploymentTypeCode) = 0 set @EmploymentTypeCode = null
		if len(@EmploymentTypeCategory) = 0 set @EmploymentTypeCategory = null
		if len(@OrgOrgName) = 0 set @OrgOrgName = null
		if len(@OrgOrgLabel) = 0 set @OrgOrgLabel = null
		if len(@OrgStreetAddress1) = 0 set @OrgStreetAddress1 = null
		if len(@OrgStreetAddress2) = 0 set @OrgStreetAddress2 = null
		if len(@OrgStreetAddress3) = 0 set @OrgStreetAddress3 = null
		if len(@OrgPostalCode) = 0 set @OrgPostalCode = null
		if len(@OrgPhone) = 0 set @OrgPhone = null
		if len(@OrgFax) = 0 set @OrgFax = null
		if len(@OrgWebSite) = 0 set @OrgWebSite = null
		if len(@OrgEmailAddress) = 0 set @OrgEmailAddress = null
		if len(@OrgInsurancePolicyNo) = 0 set @OrgInsurancePolicyNo = null
		if len(@OrgIsPublic) = 0 set @OrgIsPublic = null
		if len(@PracticeScopeName) = 0 set @PracticeScopeName = null
		if len(@PracticeScopeCode) = 0 set @PracticeScopeCode = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@OrgInsuranceOrgName) = 0 set @OrgInsuranceOrgName = null
		if len(@OrgInsuranceOrgLabel) = 0 set @OrgInsuranceOrgLabel = null
		if len(@OrgInsuranceStreetAddress1) = 0 set @OrgInsuranceStreetAddress1 = null
		if len(@OrgInsuranceStreetAddress2) = 0 set @OrgInsuranceStreetAddress2 = null
		if len(@OrgInsuranceStreetAddress3) = 0 set @OrgInsuranceStreetAddress3 = null
		if len(@OrgInsurancePostalCode) = 0 set @OrgInsurancePostalCode = null
		if len(@OrgInsurancePhone) = 0 set @OrgInsurancePhone = null
		if len(@OrgInsuranceFax) = 0 set @OrgInsuranceFax = null
		if len(@OrgInsuranceWebSite) = 0 set @OrgInsuranceWebSite = null
		if len(@OrgInsuranceEmailAddress) = 0 set @OrgInsuranceEmailAddress = null
		if len(@OrgInsuranceInsurancePolicyNo) = 0 set @OrgInsuranceInsurancePolicyNo = null
		if len(@OrgInsuranceIsPublic) = 0 set @OrgInsuranceIsPublic = null
		if len(@PrimaryPracticeAreaName) = 0 set @PrimaryPracticeAreaName = null
		if len(@PrimaryPracticeAreaCode) = 0 set @PrimaryPracticeAreaCode = null
		if len(@EffectiveInsuranceProviderName) = 0 set @EffectiveInsuranceProviderName = null
		if len(@EffectiveInsurancePolicyNo) = 0 set @EffectiveInsurancePolicyNo = null
		
		if @EffectiveTime is not null	set @EffectiveTime = cast(cast(@EffectiveTime as date) as datetime)																			-- ensure Effective value has start-of-day time component
		if @ExpiryTime is not null		set @ExpiryTime = cast(convert(varchar(8), cast(@ExpiryTime as date), 112) + ' 23:59:59.99' as datetime)-- ensure Expiry value has end-of-day time component

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)													-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()																-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                              = isnull(@RegistrantSID,re.RegistrantSID)
				,@OrgSID                                     = isnull(@OrgSID,re.OrgSID)
				,@RegistrationYear                           = isnull(@RegistrationYear,re.RegistrationYear)
				,@EmploymentTypeSID                          = isnull(@EmploymentTypeSID,re.EmploymentTypeSID)
				,@EmploymentRoleSID                          = isnull(@EmploymentRoleSID,re.EmploymentRoleSID)
				,@PracticeHours                              = isnull(@PracticeHours,re.PracticeHours)
				,@PracticeScopeSID                           = isnull(@PracticeScopeSID,re.PracticeScopeSID)
				,@AgeRangeSID                                = isnull(@AgeRangeSID,re.AgeRangeSID)
				,@IsOnPublicRegistry                         = isnull(@IsOnPublicRegistry,re.IsOnPublicRegistry)
				,@Phone                                      = isnull(@Phone,re.Phone)
				,@SiteLocation                               = isnull(@SiteLocation,re.SiteLocation)
				,@EffectiveTime                              = isnull(@EffectiveTime,re.EffectiveTime)
				,@ExpiryTime                                 = isnull(@ExpiryTime,re.ExpiryTime)
				,@Rank                                       = isnull(@Rank,re.Rank)
				,@OwnershipPercentage                        = isnull(@OwnershipPercentage,re.OwnershipPercentage)
				,@IsEmployerInsurance                        = isnull(@IsEmployerInsurance,re.IsEmployerInsurance)
				,@InsuranceOrgSID                            = isnull(@InsuranceOrgSID,re.InsuranceOrgSID)
				,@InsurancePolicyNo                          = isnull(@InsurancePolicyNo,re.InsurancePolicyNo)
				,@InsuranceAmount                            = isnull(@InsuranceAmount,re.InsuranceAmount)
				,@UserDefinedColumns                         = isnull(@UserDefinedColumns,re.UserDefinedColumns)
				,@RegistrantEmploymentXID                    = isnull(@RegistrantEmploymentXID,re.RegistrantEmploymentXID)
				,@LegacyKey                                  = isnull(@LegacyKey,re.LegacyKey)
				,@UpdateUser                                 = isnull(@UpdateUser,re.UpdateUser)
				,@IsReselected                               = isnull(@IsReselected,re.IsReselected)
				,@IsNullApplied                              = isnull(@IsNullApplied,re.IsNullApplied)
				,@zContext                                   = isnull(@zContext,re.zContext)
				,@AgeRangeTypeSID                            = isnull(@AgeRangeTypeSID,re.AgeRangeTypeSID)
				,@AgeRangeLabel                              = isnull(@AgeRangeLabel,re.AgeRangeLabel)
				,@StartAge                                   = isnull(@StartAge,re.StartAge)
				,@EndAge                                     = isnull(@EndAge,re.EndAge)
				,@AgeRangeIsDefault                          = isnull(@AgeRangeIsDefault,re.AgeRangeIsDefault)
				,@AgeRangeRowGUID                            = isnull(@AgeRangeRowGUID,re.AgeRangeRowGUID)
				,@EmploymentRoleName                         = isnull(@EmploymentRoleName,re.EmploymentRoleName)
				,@EmploymentRoleCode                         = isnull(@EmploymentRoleCode,re.EmploymentRoleCode)
				,@EmploymentRoleIsDefault                    = isnull(@EmploymentRoleIsDefault,re.EmploymentRoleIsDefault)
				,@EmploymentRoleIsActive                     = isnull(@EmploymentRoleIsActive,re.EmploymentRoleIsActive)
				,@EmploymentRoleRowGUID                      = isnull(@EmploymentRoleRowGUID,re.EmploymentRoleRowGUID)
				,@EmploymentTypeName                         = isnull(@EmploymentTypeName,re.EmploymentTypeName)
				,@EmploymentTypeCode                         = isnull(@EmploymentTypeCode,re.EmploymentTypeCode)
				,@EmploymentTypeCategory                     = isnull(@EmploymentTypeCategory,re.EmploymentTypeCategory)
				,@EmploymentTypeIsDefault                    = isnull(@EmploymentTypeIsDefault,re.EmploymentTypeIsDefault)
				,@EmploymentTypeIsActive                     = isnull(@EmploymentTypeIsActive,re.EmploymentTypeIsActive)
				,@EmploymentTypeRowGUID                      = isnull(@EmploymentTypeRowGUID,re.EmploymentTypeRowGUID)
				,@OrgParentOrgSID                            = isnull(@OrgParentOrgSID,re.OrgParentOrgSID)
				,@OrgOrgTypeSID                              = isnull(@OrgOrgTypeSID,re.OrgOrgTypeSID)
				,@OrgOrgName                                 = isnull(@OrgOrgName,re.OrgOrgName)
				,@OrgOrgLabel                                = isnull(@OrgOrgLabel,re.OrgOrgLabel)
				,@OrgStreetAddress1                          = isnull(@OrgStreetAddress1,re.OrgStreetAddress1)
				,@OrgStreetAddress2                          = isnull(@OrgStreetAddress2,re.OrgStreetAddress2)
				,@OrgStreetAddress3                          = isnull(@OrgStreetAddress3,re.OrgStreetAddress3)
				,@OrgCitySID                                 = isnull(@OrgCitySID,re.OrgCitySID)
				,@OrgPostalCode                              = isnull(@OrgPostalCode,re.OrgPostalCode)
				,@OrgRegionSID                               = isnull(@OrgRegionSID,re.OrgRegionSID)
				,@OrgPhone                                   = isnull(@OrgPhone,re.OrgPhone)
				,@OrgFax                                     = isnull(@OrgFax,re.OrgFax)
				,@OrgWebSite                                 = isnull(@OrgWebSite,re.OrgWebSite)
				,@OrgEmailAddress                            = isnull(@OrgEmailAddress,re.OrgEmailAddress)
				,@OrgInsuranceOrgSID                         = isnull(@OrgInsuranceOrgSID,re.OrgInsuranceOrgSID)
				,@OrgInsurancePolicyNo                       = isnull(@OrgInsurancePolicyNo,re.OrgInsurancePolicyNo)
				,@OrgInsuranceAmount                         = isnull(@OrgInsuranceAmount,re.OrgInsuranceAmount)
				,@OrgIsEmployer                              = isnull(@OrgIsEmployer,re.OrgIsEmployer)
				,@OrgIsCredentialAuthority                   = isnull(@OrgIsCredentialAuthority,re.OrgIsCredentialAuthority)
				,@OrgIsInsurer                               = isnull(@OrgIsInsurer,re.OrgIsInsurer)
				,@OrgIsInsuranceCertificateRequired          = isnull(@OrgIsInsuranceCertificateRequired,re.OrgIsInsuranceCertificateRequired)
				,@OrgIsPublic                                = isnull(@OrgIsPublic,re.OrgIsPublic)
				,@OrgIsActive                                = isnull(@OrgIsActive,re.OrgIsActive)
				,@OrgIsAdminReviewRequired                   = isnull(@OrgIsAdminReviewRequired,re.OrgIsAdminReviewRequired)
				,@OrgLastVerifiedTime                        = isnull(@OrgLastVerifiedTime,re.OrgLastVerifiedTime)
				,@OrgRowGUID                                 = isnull(@OrgRowGUID,re.OrgRowGUID)
				,@PracticeScopeName                          = isnull(@PracticeScopeName,re.PracticeScopeName)
				,@PracticeScopeCode                          = isnull(@PracticeScopeCode,re.PracticeScopeCode)
				,@PracticeScopeIsDefault                     = isnull(@PracticeScopeIsDefault,re.PracticeScopeIsDefault)
				,@PracticeScopeIsActive                      = isnull(@PracticeScopeIsActive,re.PracticeScopeIsActive)
				,@PracticeScopeRowGUID                       = isnull(@PracticeScopeRowGUID,re.PracticeScopeRowGUID)
				,@PersonSID                                  = isnull(@PersonSID,re.PersonSID)
				,@RegistrantNo                               = isnull(@RegistrantNo,re.RegistrantNo)
				,@YearOfInitialEmployment                    = isnull(@YearOfInitialEmployment,re.YearOfInitialEmployment)
				,@RegistrantIsOnPublicRegistry               = isnull(@RegistrantIsOnPublicRegistry,re.RegistrantIsOnPublicRegistry)
				,@CityNameOfBirth                            = isnull(@CityNameOfBirth,re.CityNameOfBirth)
				,@CountrySID                                 = isnull(@CountrySID,re.CountrySID)
				,@DirectedAuditYearCompetence                = isnull(@DirectedAuditYearCompetence,re.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours             = isnull(@DirectedAuditYearPracticeHours,re.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear                       = isnull(@LateFeeExclusionYear,re.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked               = isnull(@IsRenewalAutoApprovalBlocked,re.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime                 = isnull(@RenewalExtensionExpiryTime,re.RenewalExtensionExpiryTime)
				,@ArchivedTime                               = isnull(@ArchivedTime,re.ArchivedTime)
				,@RegistrantRowGUID                          = isnull(@RegistrantRowGUID,re.RegistrantRowGUID)
				,@OrgInsuranceParentOrgSID                   = isnull(@OrgInsuranceParentOrgSID,re.OrgInsuranceParentOrgSID)
				,@OrgInsuranceOrgTypeSID                     = isnull(@OrgInsuranceOrgTypeSID,re.OrgInsuranceOrgTypeSID)
				,@OrgInsuranceOrgName                        = isnull(@OrgInsuranceOrgName,re.OrgInsuranceOrgName)
				,@OrgInsuranceOrgLabel                       = isnull(@OrgInsuranceOrgLabel,re.OrgInsuranceOrgLabel)
				,@OrgInsuranceStreetAddress1                 = isnull(@OrgInsuranceStreetAddress1,re.OrgInsuranceStreetAddress1)
				,@OrgInsuranceStreetAddress2                 = isnull(@OrgInsuranceStreetAddress2,re.OrgInsuranceStreetAddress2)
				,@OrgInsuranceStreetAddress3                 = isnull(@OrgInsuranceStreetAddress3,re.OrgInsuranceStreetAddress3)
				,@OrgInsuranceCitySID                        = isnull(@OrgInsuranceCitySID,re.OrgInsuranceCitySID)
				,@OrgInsurancePostalCode                     = isnull(@OrgInsurancePostalCode,re.OrgInsurancePostalCode)
				,@OrgInsuranceRegionSID                      = isnull(@OrgInsuranceRegionSID,re.OrgInsuranceRegionSID)
				,@OrgInsurancePhone                          = isnull(@OrgInsurancePhone,re.OrgInsurancePhone)
				,@OrgInsuranceFax                            = isnull(@OrgInsuranceFax,re.OrgInsuranceFax)
				,@OrgInsuranceWebSite                        = isnull(@OrgInsuranceWebSite,re.OrgInsuranceWebSite)
				,@OrgInsuranceEmailAddress                   = isnull(@OrgInsuranceEmailAddress,re.OrgInsuranceEmailAddress)
				,@OrgInsuranceInsuranceOrgSID                = isnull(@OrgInsuranceInsuranceOrgSID,re.OrgInsuranceInsuranceOrgSID)
				,@OrgInsuranceInsurancePolicyNo              = isnull(@OrgInsuranceInsurancePolicyNo,re.OrgInsuranceInsurancePolicyNo)
				,@OrgInsuranceInsuranceAmount                = isnull(@OrgInsuranceInsuranceAmount,re.OrgInsuranceInsuranceAmount)
				,@OrgInsuranceIsEmployer                     = isnull(@OrgInsuranceIsEmployer,re.OrgInsuranceIsEmployer)
				,@OrgInsuranceIsCredentialAuthority          = isnull(@OrgInsuranceIsCredentialAuthority,re.OrgInsuranceIsCredentialAuthority)
				,@OrgInsuranceIsInsurer                      = isnull(@OrgInsuranceIsInsurer,re.OrgInsuranceIsInsurer)
				,@OrgInsuranceIsInsuranceCertificateRequired = isnull(@OrgInsuranceIsInsuranceCertificateRequired,re.OrgInsuranceIsInsuranceCertificateRequired)
				,@OrgInsuranceIsPublic                       = isnull(@OrgInsuranceIsPublic,re.OrgInsuranceIsPublic)
				,@OrgInsuranceIsActive                       = isnull(@OrgInsuranceIsActive,re.OrgInsuranceIsActive)
				,@OrgInsuranceIsAdminReviewRequired          = isnull(@OrgInsuranceIsAdminReviewRequired,re.OrgInsuranceIsAdminReviewRequired)
				,@OrgInsuranceLastVerifiedTime               = isnull(@OrgInsuranceLastVerifiedTime,re.OrgInsuranceLastVerifiedTime)
				,@OrgInsuranceRowGUID                        = isnull(@OrgInsuranceRowGUID,re.OrgInsuranceRowGUID)
				,@IsActive                                   = isnull(@IsActive,re.IsActive)
				,@IsPending                                  = isnull(@IsPending,re.IsPending)
				,@IsDeleteEnabled                            = isnull(@IsDeleteEnabled,re.IsDeleteEnabled)
				,@IsSelfEmployed                             = isnull(@IsSelfEmployed,re.IsSelfEmployed)
				,@EmploymentRankNo                           = isnull(@EmploymentRankNo,re.EmploymentRankNo)
				,@PrimaryPracticeAreaSID                     = isnull(@PrimaryPracticeAreaSID,re.PrimaryPracticeAreaSID)
				,@PrimaryPracticeAreaName                    = isnull(@PrimaryPracticeAreaName,re.PrimaryPracticeAreaName)
				,@PrimaryPracticeAreaCode                    = isnull(@PrimaryPracticeAreaCode,re.PrimaryPracticeAreaCode)
				,@IsPracticeScopeRequired                    = isnull(@IsPracticeScopeRequired,re.IsPracticeScopeRequired)
				,@EmploymentSupervisorSID                    = isnull(@EmploymentSupervisorSID,re.EmploymentSupervisorSID)
				,@SupervisorPersonSID                        = isnull(@SupervisorPersonSID,re.SupervisorPersonSID)
				,@IsPrivateInsurance                         = isnull(@IsPrivateInsurance,re.IsPrivateInsurance)
				,@EffectiveInsuranceProviderName             = isnull(@EffectiveInsuranceProviderName,re.EffectiveInsuranceProviderName)
				,@EffectiveInsurancePolicyNo                 = isnull(@EffectiveInsurancePolicyNo,re.EffectiveInsurancePolicyNo)
				,@EffectiveInsuranceAmount                   = isnull(@EffectiveInsuranceAmount,re.EffectiveInsuranceAmount)
			from
				dbo.vRegistrantEmployment re
			where
				re.RegistrantEmploymentSID = @RegistrantEmploymentSID

		end
		
		set @Phone = sf.fFormatPhone(@Phone)																	-- format phone numbers to standard

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.EmploymentRoleSID from dbo.RegistrantEmployment x where x.RegistrantEmploymentSID = @RegistrantEmploymentSID) <> @EmploymentRoleSID
			begin
			
				if (select x.IsActive from dbo.EmploymentRole x where x.EmploymentRoleSID = @EmploymentRoleSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'employment role'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.EmploymentTypeSID from dbo.RegistrantEmployment x where x.RegistrantEmploymentSID = @RegistrantEmploymentSID) <> @EmploymentTypeSID
			begin
			
				if (select x.IsActive from dbo.EmploymentType x where x.EmploymentTypeSID = @EmploymentTypeSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'employment type'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.InsuranceOrgSID from dbo.RegistrantEmployment x where x.RegistrantEmploymentSID = @RegistrantEmploymentSID) <> @InsuranceOrgSID
			begin
			
				if (select x.IsActive from dbo.Org x where x.OrgSID = @InsuranceOrgSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'insurance org'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.OrgSID from dbo.RegistrantEmployment x where x.RegistrantEmploymentSID = @RegistrantEmploymentSID) <> @OrgSID
			begin
			
				if (select x.IsActive from dbo.Org x where x.OrgSID = @OrgSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'org'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeScopeSID from dbo.RegistrantEmployment x where x.RegistrantEmploymentSID = @RegistrantEmploymentSID) <> @PracticeScopeSID
			begin
			
				if (select x.IsActive from dbo.PracticeScope x where x.PracticeScopeSID = @PracticeScopeSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice scope'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Cory Ng | Jan 2018
		-- Lookup the RegistrantSID if its not passed and the
		-- PersonSID is passed

		if @PersonSID is not null and @RegistrantSID is null
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID

		end

		-- Tim Edlund | Oct 2018
		-- If the member has indicated they are self employed
		-- but no share percentage is specified, set the
		-- percentage to -1 to show self-employed bit ON in UI

		if @IsSelfEmployed = @ON and @OwnershipPercentage = 0
		begin
			set @OwnershipPercentage = -1; -- indicates member is owner but percentage is unknown/not-collected
		end;
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrantEmployment'
		)
		begin
		
			exec @errorNo = ext.pRegistrantEmployment
				 @Mode                                       = 'update.pre'
				,@RegistrantEmploymentSID                    = @RegistrantEmploymentSID
				,@RegistrantSID                              = @RegistrantSID output
				,@OrgSID                                     = @OrgSID output
				,@RegistrationYear                           = @RegistrationYear output
				,@EmploymentTypeSID                          = @EmploymentTypeSID output
				,@EmploymentRoleSID                          = @EmploymentRoleSID output
				,@PracticeHours                              = @PracticeHours output
				,@PracticeScopeSID                           = @PracticeScopeSID output
				,@AgeRangeSID                                = @AgeRangeSID output
				,@IsOnPublicRegistry                         = @IsOnPublicRegistry output
				,@Phone                                      = @Phone output
				,@SiteLocation                               = @SiteLocation output
				,@EffectiveTime                              = @EffectiveTime output
				,@ExpiryTime                                 = @ExpiryTime output
				,@Rank                                       = @Rank output
				,@OwnershipPercentage                        = @OwnershipPercentage output
				,@IsEmployerInsurance                        = @IsEmployerInsurance output
				,@InsuranceOrgSID                            = @InsuranceOrgSID output
				,@InsurancePolicyNo                          = @InsurancePolicyNo output
				,@InsuranceAmount                            = @InsuranceAmount output
				,@UserDefinedColumns                         = @UserDefinedColumns output
				,@RegistrantEmploymentXID                    = @RegistrantEmploymentXID output
				,@LegacyKey                                  = @LegacyKey output
				,@UpdateUser                                 = @UpdateUser
				,@RowStamp                                   = @RowStamp
				,@IsReselected                               = @IsReselected
				,@IsNullApplied                              = @IsNullApplied
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
		
		end

		-- update the record

		update
			dbo.RegistrantEmployment
		set
			 RegistrantSID = @RegistrantSID
			,OrgSID = @OrgSID
			,RegistrationYear = @RegistrationYear
			,EmploymentTypeSID = @EmploymentTypeSID
			,EmploymentRoleSID = @EmploymentRoleSID
			,PracticeHours = @PracticeHours
			,PracticeScopeSID = @PracticeScopeSID
			,AgeRangeSID = @AgeRangeSID
			,IsOnPublicRegistry = @IsOnPublicRegistry
			,Phone = @Phone
			,SiteLocation = @SiteLocation
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,Rank = @Rank
			,OwnershipPercentage = @OwnershipPercentage
			,IsEmployerInsurance = @IsEmployerInsurance
			,InsuranceOrgSID = @InsuranceOrgSID
			,InsurancePolicyNo = @InsurancePolicyNo
			,InsuranceAmount = @InsuranceAmount
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantEmploymentXID = @RegistrantEmploymentXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantEmploymentSID = @RegistrantEmploymentSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantEmployment where RegistrantEmploymentSID = @registrantEmploymentSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantEmployment'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantEmployment'
					,@Arg2        = @registrantEmploymentSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'dbo.RegistrantEmployment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantEmploymentSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Oct 2018
		-- If the phone number is being updated, copy
		-- it across to the org-contact record if one
		-- exists for this person and org combination

		if @Phone is not null
		begin

			update
				oc
			set
				oc.DirectPhone = re.Phone
			from
				dbo.RegistrantEmployment re
			join
				dbo.Registrant					 r on re.RegistrantSID = r.RegistrantSID
			join
				dbo.OrgContact					 oc on r.PersonSID		 = oc.PersonSID and re.OrgSID = oc.OrgSID
			where
				re.RegistrantEmploymentSID					 = @RegistrantEmploymentSID
				and re.Phone is not null
				and
				(
					oc.DirectPhone is null or re.Phone <> oc.DirectPhone -- phone number has changed
				);

		end;

		-- Tim Edlund | Jul 2017
		-- If the organization associated with the employment record is not already
		-- marked as an employer, mark it now.
		
		exec dbo.pOrg#SetBaseTypes
			@OrgSID = @OrgSID
		 ,@UpdateUser = @UpdateUser

		-- Tim Edlund | Jul 2018
		-- If the primary practice area is being changed on the form, update it.
		-- If a value is provided and no primary exists, insert it now.

		if @PrimaryPracticeAreaSID is not null
		begin

			declare
				@registrantEmploymentPracticeAreaSID int
			 ,@practiceAreaSID										 int;

			select -- lookup the current primary practice area for this employment record
				@registrantEmploymentPracticeAreaSID = repa.RegistrantEmploymentPracticeAreaSID
			 ,@practiceAreaSID										 = repa.PracticeAreaSID
			from
				dbo.RegistrantEmploymentPracticeArea repa
			where
				repa.RegistrantEmploymentSID = @RegistrantEmploymentSID and repa.IsPrimary = @ON;

			if @registrantEmploymentPracticeAreaSID is not null -- if one exists ...
			begin

				if @PrimaryPracticeAreaSID <> @practiceAreaSID -- and user is changing it - update the record with the new area
				begin

					update
						dbo.RegistrantEmploymentPracticeArea
					set
						PracticeAreaSID = @PrimaryPracticeAreaSID
					where
						RegistrantEmploymentPracticeAreaSID = @registrantEmploymentPracticeAreaSID;

				end;

			end
			else
			begin

				-- if there is no primary currently - insert it now

				exec dbo.pRegistrantEmploymentPracticeArea#Insert
					@RegistrantEmploymentSID = @RegistrantEmploymentSID
				 ,@PracticeAreaSID = @PrimaryPracticeAreaSID
			
			end;

		end;

		-- Tim Edlund | Oct 2018
		-- If a supervisor was passed in the initial call and no
		-- record for it exists, add it here. This action does
		-- not expire any previous supervisory in effect.

		if @SupervisorPersonSID is not null
		begin

			if not exists
			(
				select
					1
				from
					dbo.EmploymentSupervisor es
				where
					es.RegistrantEmploymentSID = @RegistrantEmploymentSID and es.PersonSID = @SupervisorPersonSID
			)
			begin

				exec dbo.pEmploymentSupervisor#Insert
					@RegistrantEmploymentSID = @RegistrantEmploymentSID
				 ,@PersonSID = @SupervisorPersonSID;

			end;
		end;
		--! </PostUpdate>
	
		-- call the extended version of the procedure for update.post - if it exists
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrantEmployment'
		)
		begin
		
			exec @errorNo = ext.pRegistrantEmployment
				 @Mode                                       = 'update.post'
				,@RegistrantEmploymentSID                    = @RegistrantEmploymentSID
				,@RegistrantSID                              = @RegistrantSID
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
				,@UpdateUser                                 = @UpdateUser
				,@RowStamp                                   = @RowStamp
				,@IsReselected                               = @IsReselected
				,@IsNullApplied                              = @IsNullApplied
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantEmploymentSID
			from
				dbo.vRegistrantEmployment ent
			where
				ent.RegistrantEmploymentSID = @RegistrantEmploymentSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantEmploymentSID
				,ent.RegistrantSID
				,ent.OrgSID
				,ent.RegistrationYear
				,ent.EmploymentTypeSID
				,ent.EmploymentRoleSID
				,ent.PracticeHours
				,ent.PracticeScopeSID
				,ent.AgeRangeSID
				,ent.IsOnPublicRegistry
				,ent.Phone
				,ent.SiteLocation
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.Rank
				,ent.OwnershipPercentage
				,ent.IsEmployerInsurance
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.UserDefinedColumns
				,ent.RegistrantEmploymentXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.AgeRangeTypeSID
				,ent.AgeRangeLabel
				,ent.StartAge
				,ent.EndAge
				,ent.AgeRangeIsDefault
				,ent.AgeRangeRowGUID
				,ent.EmploymentRoleName
				,ent.EmploymentRoleCode
				,ent.EmploymentRoleIsDefault
				,ent.EmploymentRoleIsActive
				,ent.EmploymentRoleRowGUID
				,ent.EmploymentTypeName
				,ent.EmploymentTypeCode
				,ent.EmploymentTypeCategory
				,ent.EmploymentTypeIsDefault
				,ent.EmploymentTypeIsActive
				,ent.EmploymentTypeRowGUID
				,ent.OrgParentOrgSID
				,ent.OrgOrgTypeSID
				,ent.OrgOrgName
				,ent.OrgOrgLabel
				,ent.OrgStreetAddress1
				,ent.OrgStreetAddress2
				,ent.OrgStreetAddress3
				,ent.OrgCitySID
				,ent.OrgPostalCode
				,ent.OrgRegionSID
				,ent.OrgPhone
				,ent.OrgFax
				,ent.OrgWebSite
				,ent.OrgEmailAddress
				,ent.OrgInsuranceOrgSID
				,ent.OrgInsurancePolicyNo
				,ent.OrgInsuranceAmount
				,ent.OrgIsEmployer
				,ent.OrgIsCredentialAuthority
				,ent.OrgIsInsurer
				,ent.OrgIsInsuranceCertificateRequired
				,ent.OrgIsPublic
				,ent.OrgIsActive
				,ent.OrgIsAdminReviewRequired
				,ent.OrgLastVerifiedTime
				,ent.OrgRowGUID
				,ent.PracticeScopeName
				,ent.PracticeScopeCode
				,ent.PracticeScopeIsDefault
				,ent.PracticeScopeIsActive
				,ent.PracticeScopeRowGUID
				,ent.PersonSID
				,ent.RegistrantNo
				,ent.YearOfInitialEmployment
				,ent.RegistrantIsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.OrgInsuranceParentOrgSID
				,ent.OrgInsuranceOrgTypeSID
				,ent.OrgInsuranceOrgName
				,ent.OrgInsuranceOrgLabel
				,ent.OrgInsuranceStreetAddress1
				,ent.OrgInsuranceStreetAddress2
				,ent.OrgInsuranceStreetAddress3
				,ent.OrgInsuranceCitySID
				,ent.OrgInsurancePostalCode
				,ent.OrgInsuranceRegionSID
				,ent.OrgInsurancePhone
				,ent.OrgInsuranceFax
				,ent.OrgInsuranceWebSite
				,ent.OrgInsuranceEmailAddress
				,ent.OrgInsuranceInsuranceOrgSID
				,ent.OrgInsuranceInsurancePolicyNo
				,ent.OrgInsuranceInsuranceAmount
				,ent.OrgInsuranceIsEmployer
				,ent.OrgInsuranceIsCredentialAuthority
				,ent.OrgInsuranceIsInsurer
				,ent.OrgInsuranceIsInsuranceCertificateRequired
				,ent.OrgInsuranceIsPublic
				,ent.OrgInsuranceIsActive
				,ent.OrgInsuranceIsAdminReviewRequired
				,ent.OrgInsuranceLastVerifiedTime
				,ent.OrgInsuranceRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsSelfEmployed
				,ent.EmploymentRankNo
				,ent.PrimaryPracticeAreaSID
				,ent.PrimaryPracticeAreaName
				,ent.PrimaryPracticeAreaCode
				,ent.IsPracticeScopeRequired
				,ent.EmploymentSupervisorSID
				,ent.SupervisorPersonSID
				,ent.IsPrivateInsurance
				,ent.EffectiveInsuranceProviderName
				,ent.EffectiveInsurancePolicyNo
				,ent.EffectiveInsuranceAmount
			from
				dbo.vRegistrantEmployment ent
			where
				ent.RegistrantEmploymentSID = @RegistrantEmploymentSID

		end

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
