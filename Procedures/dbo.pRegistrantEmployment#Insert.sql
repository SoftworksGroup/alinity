SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantEmployment#Insert]
	 @RegistrantEmploymentSID                    int               = null output											-- identity value assigned to the new record
	,@RegistrantSID                              int               = null		-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistrantEmployment#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantEmployment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantEmployment table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantEmployment entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantEmployment procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

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

	set @RegistrantEmploymentSID = null																			-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @Phone = ltrim(rtrim(@Phone))
		set @SiteLocation = ltrim(rtrim(@SiteLocation))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @RegistrantEmploymentXID = ltrim(rtrim(@RegistrantEmploymentXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RegistrationYear = isnull(@RegistrationYear,sf.fTodayYear())
		set @PracticeHours = isnull(@PracticeHours,(0))
		set @IsOnPublicRegistry = isnull(@IsOnPublicRegistry,CONVERT(bit,(1)))
		set @Rank = isnull(@Rank,(5))
		set @OwnershipPercentage = isnull(@OwnershipPercentage,(0))
		set @IsEmployerInsurance = isnull(@IsEmployerInsurance,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))
		
		set @Phone = sf.fFormatPhone(@Phone)																	-- format phone numbers to standard
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @AgeRangeSID        is null select @AgeRangeSID        = x.AgeRangeSID       from dbo.AgeRange       x where x.IsDefault = @ON
		if @EmploymentRoleSID  is null select @EmploymentRoleSID  = x.EmploymentRoleSID from dbo.EmploymentRole x where x.IsDefault = @ON
		if @EmploymentTypeSID  is null select @EmploymentTypeSID  = x.EmploymentTypeSID from dbo.EmploymentType x where x.IsDefault = @ON
		if @PracticeScopeSID   is null select @PracticeScopeSID   = x.PracticeScopeSID  from dbo.PracticeScope  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
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

		-- Tim Edlund | Mar 2019
		-- If member-provider insurance is indicated but the
		-- policy information is not provided, look it up
		-- in the Organization record to store in the record

		if @IsEmployerInsurance = @ON and (@InsurancePolicyNo is null or @InsuranceOrgSID is null or @InsuranceAmount is null)
		begin

			select
				 @InsurancePolicyNo = isnull(@InsurancePolicyNo, o.InsurancePolicyNo)
				,@InsuranceOrgSID = isnull(@InsuranceOrgSID, o.InsuranceOrgSID)
				,@InsuranceAmount = isnull(@InsuranceAmount, o.InsuranceAmount)
			from
				dbo.Org o
			where
				o.OrgSID = @OrgSID;

		end;

		-- Tim Edlund | Oct 2018
		-- If the member has indicated they are self employed
		-- but no share percentage is specified, set the
		-- percentage to -1 to show self-employed bit ON in UI

		if @IsSelfEmployed = @ON and @OwnershipPercentage = 0
		begin
			set @OwnershipPercentage = -1; -- indicates member is owner but percentage is unknown/not-collected
		end;
		--! </PreInsert>
		
		exec sf.pEffectiveExpiry#Set																					-- ensure values have start/end of day time components or current time if today
		   @EffectiveTime = @EffectiveTime output
		  ,@ExpiryTime    = @ExpiryTime    output
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
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
				 @Mode                                       = 'insert.pre'
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
		
		end

		-- insert the record

		insert
			dbo.RegistrantEmployment
		(
			 RegistrantSID
			,OrgSID
			,RegistrationYear
			,EmploymentTypeSID
			,EmploymentRoleSID
			,PracticeHours
			,PracticeScopeSID
			,AgeRangeSID
			,IsOnPublicRegistry
			,Phone
			,SiteLocation
			,EffectiveTime
			,ExpiryTime
			,Rank
			,OwnershipPercentage
			,IsEmployerInsurance
			,InsuranceOrgSID
			,InsurancePolicyNo
			,InsuranceAmount
			,UserDefinedColumns
			,RegistrantEmploymentXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@OrgSID
			,@RegistrationYear
			,@EmploymentTypeSID
			,@EmploymentRoleSID
			,@PracticeHours
			,@PracticeScopeSID
			,@AgeRangeSID
			,@IsOnPublicRegistry
			,@Phone
			,@SiteLocation
			,@EffectiveTime
			,@ExpiryTime
			,@Rank
			,@OwnershipPercentage
			,@IsEmployerInsurance
			,@InsuranceOrgSID
			,@InsurancePolicyNo
			,@InsuranceAmount
			,@UserDefinedColumns
			,@RegistrantEmploymentXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@RegistrantEmploymentSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantEmployment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantEmploymentSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>

		-- Tim Edlund | Apr 2018
		-- If a phone number was provided, copy it
		-- across to the org-contact record if one
		-- exists for this person and org combination

		if @Phone is not null
		begin

			update
				oc
			set
				oc.DirectPhone = @Phone
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
		 ,@UpdateUser = @CreateUser

		-- Tim Edlund | Jul 2018
		-- If a practice area was passed in the initial call add
		-- the record for it here. This avoids a second call to
		-- the DB where only 1 practice area is required.

		if @PrimaryPracticeAreaCode is not null and @PrimaryPracticeAreaSID is null -- allow lookup of key by code
		begin
			select @PrimaryPracticeAreaSID = 1 from dbo.PracticeArea pa where pa.PracticeAreaCode = @PrimaryPracticeAreaCode
		end

		if @PrimaryPracticeAreaSID is not null
		begin

			exec dbo.pRegistrantEmploymentPracticeArea#Insert
			  @RegistrantEmploymentSID = @RegistrantEmploymentSID
			 ,@PracticeAreaSID = @PrimaryPracticeAreaSID

		end

		-- Tim Edlund | Oct 2018
		-- If a supervisor was passed in the initial call add
		-- the record for it here to avoid requirement for a
		-- second call.

		if @SupervisorPersonSID is not null
		begin

			exec dbo.pEmploymentSupervisor#Insert
				@RegistrantEmploymentSID = @RegistrantEmploymentSID
			 ,@PersonSID = @SupervisorPersonSID;

		end;
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
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
				 @Mode                                       = 'insert.post'
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
