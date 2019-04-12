SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pCredentialProfile#Update]
	 @CredentialProfileSID           int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ProcessingStatusSID            int               = null -- table column values to update:
	,@SourceFileName                 nvarchar(100)     = null
	,@ProgramStartDate               date              = null
	,@ProgramTargetCompletionDate    date              = null
	,@EffectiveTime                  date              = null
	,@IsDisplayedOnLicense           bit               = null
	,@ProgramName                    nvarchar(65)      = null
	,@OrgName                        nvarchar(15)      = null
	,@OrgLabel                       nvarchar(35)      = null
	,@StreetAddress1                 nvarchar(75)      = null
	,@StreetAddress2                 nvarchar(75)      = null
	,@StreedAddress3                 nvarchar(75)      = null
	,@CityName                       nvarchar(30)      = null
	,@StateProvinceName              nvarchar(30)      = null
	,@StateProvinceCode              nvarchar(5)       = null
	,@PostalCode                     varchar(10)       = null
	,@CountryName                    nvarchar(50)      = null
	,@CountryISOA3                   char(3)           = null
	,@Phone                          varchar(25)       = null
	,@Fax                            varchar(25)       = null
	,@WebSite                        varchar(250)      = null
	,@RegionLabel                    nvarchar(35)      = null
	,@RegionName                     nvarchar(50)      = null
	,@CredentialTypeLabel            nvarchar(35)      = null
	,@RegistrantSID                  int               = null
	,@CredentialSID                  int               = null
	,@CredentialTypeSID              int               = null
	,@OrgSID                         int               = null
	,@RegionSID                      int               = null
	,@ProcessingComments             nvarchar(max)     = null
	,@UserDefinedColumns             xml               = null
	,@CredentialProfileXID           varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@ProcessingStatusSCD            varchar(10)       = null -- not a base table column
	,@ProcessingStatusLabel          nvarchar(35)      = null -- not a base table column
	,@IsClosedStatus                 bit               = null -- not a base table column
	,@ProcessingStatusIsActive       bit               = null -- not a base table column
	,@ProcessingStatusIsDefault      bit               = null -- not a base table column
	,@ProcessingStatusRowGUID        uniqueidentifier  = null -- not a base table column
	,@CredentialCredentialTypeSID    int               = null -- not a base table column
	,@CredentialLabel                nvarchar(35)      = null -- not a base table column
	,@ToolTip                        nvarchar(500)     = null -- not a base table column
	,@IsRelatedToProfession          bit               = null -- not a base table column
	,@IsProgramRequired              bit               = null -- not a base table column
	,@IsSpecialization               bit               = null -- not a base table column
	,@CredentialIsActive             bit               = null -- not a base table column
	,@CredentialCode                 varchar(15)       = null -- not a base table column
	,@CredentialRowGUID              uniqueidentifier  = null -- not a base table column
	,@ParentOrgSID                   int               = null -- not a base table column
	,@OrgTypeSID                     int               = null -- not a base table column
	,@OrgOrgName                     nvarchar(150)     = null -- not a base table column
	,@OrgOrgLabel                    nvarchar(35)      = null -- not a base table column
	,@OrgStreetAddress1              nvarchar(75)      = null -- not a base table column
	,@OrgStreetAddress2              nvarchar(75)      = null -- not a base table column
	,@StreetAddress3                 nvarchar(75)      = null -- not a base table column
	,@CitySID                        int               = null -- not a base table column
	,@OrgPostalCode                  varchar(10)       = null -- not a base table column
	,@OrgRegionSID                   int               = null -- not a base table column
	,@OrgPhone                       varchar(25)       = null -- not a base table column
	,@OrgFax                         varchar(25)       = null -- not a base table column
	,@OrgWebSite                     varchar(250)      = null -- not a base table column
	,@EmailAddress                   varchar(150)      = null -- not a base table column
	,@InsuranceOrgSID                int               = null -- not a base table column
	,@InsurancePolicyNo              varchar(25)       = null -- not a base table column
	,@InsuranceAmount                decimal(11,2)     = null -- not a base table column
	,@IsEmployer                     bit               = null -- not a base table column
	,@IsCredentialAuthority          bit               = null -- not a base table column
	,@IsInsurer                      bit               = null -- not a base table column
	,@IsInsuranceCertificateRequired bit               = null -- not a base table column
	,@IsPublic                       nchar(10)         = null -- not a base table column
	,@OrgIsActive                    bit               = null -- not a base table column
	,@IsAdminReviewRequired          bit               = null -- not a base table column
	,@LastVerifiedTime               datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                     uniqueidentifier  = null -- not a base table column
	,@RegionRegionLabel              nvarchar(35)      = null -- not a base table column
	,@RegionRegionName               nvarchar(50)      = null -- not a base table column
	,@RegionIsDefault                bit               = null -- not a base table column
	,@RegionIsActive                 bit               = null -- not a base table column
	,@RegionRowGUID                  uniqueidentifier  = null -- not a base table column
	,@PersonSID                      int               = null -- not a base table column
	,@RegistrantNo                   varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment        smallint          = null -- not a base table column
	,@IsOnPublicRegistry             bit               = null -- not a base table column
	,@CityNameOfBirth                nvarchar(30)      = null -- not a base table column
	,@CountrySID                     int               = null -- not a base table column
	,@DirectedAuditYearCompetence    smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours smallint          = null -- not a base table column
	,@LateFeeExclusionYear           smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked   bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime     datetime          = null -- not a base table column
	,@ArchivedTime                   datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID              uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsQualifying                   bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : stg.pCredentialProfile#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the stg.CredentialProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the stg.CredentialProfile table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vCredentialProfile entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pCredentialProfile procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fCredentialProfileCheck to test all rules.

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

		if @CredentialProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CredentialProfileSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @SourceFileName = ltrim(rtrim(@SourceFileName))
		set @ProgramName = ltrim(rtrim(@ProgramName))
		set @OrgName = ltrim(rtrim(@OrgName))
		set @OrgLabel = ltrim(rtrim(@OrgLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreedAddress3 = ltrim(rtrim(@StreedAddress3))
		set @CityName = ltrim(rtrim(@CityName))
		set @StateProvinceName = ltrim(rtrim(@StateProvinceName))
		set @StateProvinceCode = ltrim(rtrim(@StateProvinceCode))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @CountryName = ltrim(rtrim(@CountryName))
		set @CountryISOA3 = ltrim(rtrim(@CountryISOA3))
		set @Phone = ltrim(rtrim(@Phone))
		set @Fax = ltrim(rtrim(@Fax))
		set @WebSite = ltrim(rtrim(@WebSite))
		set @RegionLabel = ltrim(rtrim(@RegionLabel))
		set @RegionName = ltrim(rtrim(@RegionName))
		set @CredentialTypeLabel = ltrim(rtrim(@CredentialTypeLabel))
		set @ProcessingComments = ltrim(rtrim(@ProcessingComments))
		set @CredentialProfileXID = ltrim(rtrim(@CredentialProfileXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ProcessingStatusSCD = ltrim(rtrim(@ProcessingStatusSCD))
		set @ProcessingStatusLabel = ltrim(rtrim(@ProcessingStatusLabel))
		set @CredentialLabel = ltrim(rtrim(@CredentialLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @CredentialCode = ltrim(rtrim(@CredentialCode))
		set @OrgOrgName = ltrim(rtrim(@OrgOrgName))
		set @OrgOrgLabel = ltrim(rtrim(@OrgOrgLabel))
		set @OrgStreetAddress1 = ltrim(rtrim(@OrgStreetAddress1))
		set @OrgStreetAddress2 = ltrim(rtrim(@OrgStreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @OrgPostalCode = ltrim(rtrim(@OrgPostalCode))
		set @OrgPhone = ltrim(rtrim(@OrgPhone))
		set @OrgFax = ltrim(rtrim(@OrgFax))
		set @OrgWebSite = ltrim(rtrim(@OrgWebSite))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))
		set @RegionRegionLabel = ltrim(rtrim(@RegionRegionLabel))
		set @RegionRegionName = ltrim(rtrim(@RegionRegionName))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))

		-- set zero length strings to null to avoid storing them in the record

		if len(@SourceFileName) = 0 set @SourceFileName = null
		if len(@ProgramName) = 0 set @ProgramName = null
		if len(@OrgName) = 0 set @OrgName = null
		if len(@OrgLabel) = 0 set @OrgLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreedAddress3) = 0 set @StreedAddress3 = null
		if len(@CityName) = 0 set @CityName = null
		if len(@StateProvinceName) = 0 set @StateProvinceName = null
		if len(@StateProvinceCode) = 0 set @StateProvinceCode = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@CountryName) = 0 set @CountryName = null
		if len(@CountryISOA3) = 0 set @CountryISOA3 = null
		if len(@Phone) = 0 set @Phone = null
		if len(@Fax) = 0 set @Fax = null
		if len(@WebSite) = 0 set @WebSite = null
		if len(@RegionLabel) = 0 set @RegionLabel = null
		if len(@RegionName) = 0 set @RegionName = null
		if len(@CredentialTypeLabel) = 0 set @CredentialTypeLabel = null
		if len(@ProcessingComments) = 0 set @ProcessingComments = null
		if len(@CredentialProfileXID) = 0 set @CredentialProfileXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ProcessingStatusSCD) = 0 set @ProcessingStatusSCD = null
		if len(@ProcessingStatusLabel) = 0 set @ProcessingStatusLabel = null
		if len(@CredentialLabel) = 0 set @CredentialLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@CredentialCode) = 0 set @CredentialCode = null
		if len(@OrgOrgName) = 0 set @OrgOrgName = null
		if len(@OrgOrgLabel) = 0 set @OrgOrgLabel = null
		if len(@OrgStreetAddress1) = 0 set @OrgStreetAddress1 = null
		if len(@OrgStreetAddress2) = 0 set @OrgStreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@OrgPostalCode) = 0 set @OrgPostalCode = null
		if len(@OrgPhone) = 0 set @OrgPhone = null
		if len(@OrgFax) = 0 set @OrgFax = null
		if len(@OrgWebSite) = 0 set @OrgWebSite = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null
		if len(@RegionRegionLabel) = 0 set @RegionRegionLabel = null
		if len(@RegionRegionName) = 0 set @RegionRegionName = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		
		if @EffectiveTime is not null	set @EffectiveTime = cast(cast(@EffectiveTime as date) as datetime)						-- ensure Effective value has start-of-day time component

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ProcessingStatusSID            = isnull(@ProcessingStatusSID,cp.ProcessingStatusSID)
				,@SourceFileName                 = isnull(@SourceFileName,cp.SourceFileName)
				,@ProgramStartDate               = isnull(@ProgramStartDate,cp.ProgramStartDate)
				,@ProgramTargetCompletionDate    = isnull(@ProgramTargetCompletionDate,cp.ProgramTargetCompletionDate)
				,@EffectiveTime                  = isnull(@EffectiveTime,cp.EffectiveTime)
				,@IsDisplayedOnLicense           = isnull(@IsDisplayedOnLicense,cp.IsDisplayedOnLicense)
				,@ProgramName                    = isnull(@ProgramName,cp.ProgramName)
				,@OrgName                        = isnull(@OrgName,cp.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,cp.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,cp.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,cp.StreetAddress2)
				,@StreedAddress3                 = isnull(@StreedAddress3,cp.StreedAddress3)
				,@CityName                       = isnull(@CityName,cp.CityName)
				,@StateProvinceName              = isnull(@StateProvinceName,cp.StateProvinceName)
				,@StateProvinceCode              = isnull(@StateProvinceCode,cp.StateProvinceCode)
				,@PostalCode                     = isnull(@PostalCode,cp.PostalCode)
				,@CountryName                    = isnull(@CountryName,cp.CountryName)
				,@CountryISOA3                   = isnull(@CountryISOA3,cp.CountryISOA3)
				,@Phone                          = isnull(@Phone,cp.Phone)
				,@Fax                            = isnull(@Fax,cp.Fax)
				,@WebSite                        = isnull(@WebSite,cp.WebSite)
				,@RegionLabel                    = isnull(@RegionLabel,cp.RegionLabel)
				,@RegionName                     = isnull(@RegionName,cp.RegionName)
				,@CredentialTypeLabel            = isnull(@CredentialTypeLabel,cp.CredentialTypeLabel)
				,@RegistrantSID                  = isnull(@RegistrantSID,cp.RegistrantSID)
				,@CredentialSID                  = isnull(@CredentialSID,cp.CredentialSID)
				,@CredentialTypeSID              = isnull(@CredentialTypeSID,cp.CredentialTypeSID)
				,@OrgSID                         = isnull(@OrgSID,cp.OrgSID)
				,@RegionSID                      = isnull(@RegionSID,cp.RegionSID)
				,@ProcessingComments             = isnull(@ProcessingComments,cp.ProcessingComments)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,cp.UserDefinedColumns)
				,@CredentialProfileXID           = isnull(@CredentialProfileXID,cp.CredentialProfileXID)
				,@LegacyKey                      = isnull(@LegacyKey,cp.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,cp.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,cp.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,cp.IsNullApplied)
				,@zContext                       = isnull(@zContext,cp.zContext)
				,@ProcessingStatusSCD            = isnull(@ProcessingStatusSCD,cp.ProcessingStatusSCD)
				,@ProcessingStatusLabel          = isnull(@ProcessingStatusLabel,cp.ProcessingStatusLabel)
				,@IsClosedStatus                 = isnull(@IsClosedStatus,cp.IsClosedStatus)
				,@ProcessingStatusIsActive       = isnull(@ProcessingStatusIsActive,cp.ProcessingStatusIsActive)
				,@ProcessingStatusIsDefault      = isnull(@ProcessingStatusIsDefault,cp.ProcessingStatusIsDefault)
				,@ProcessingStatusRowGUID        = isnull(@ProcessingStatusRowGUID,cp.ProcessingStatusRowGUID)
				,@CredentialCredentialTypeSID    = isnull(@CredentialCredentialTypeSID,cp.CredentialCredentialTypeSID)
				,@CredentialLabel                = isnull(@CredentialLabel,cp.CredentialLabel)
				,@ToolTip                        = isnull(@ToolTip,cp.ToolTip)
				,@IsRelatedToProfession          = isnull(@IsRelatedToProfession,cp.IsRelatedToProfession)
				,@IsProgramRequired              = isnull(@IsProgramRequired,cp.IsProgramRequired)
				,@IsSpecialization               = isnull(@IsSpecialization,cp.IsSpecialization)
				,@CredentialIsActive             = isnull(@CredentialIsActive,cp.CredentialIsActive)
				,@CredentialCode                 = isnull(@CredentialCode,cp.CredentialCode)
				,@CredentialRowGUID              = isnull(@CredentialRowGUID,cp.CredentialRowGUID)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,cp.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,cp.OrgTypeSID)
				,@OrgOrgName                     = isnull(@OrgOrgName,cp.OrgOrgName)
				,@OrgOrgLabel                    = isnull(@OrgOrgLabel,cp.OrgOrgLabel)
				,@OrgStreetAddress1              = isnull(@OrgStreetAddress1,cp.OrgStreetAddress1)
				,@OrgStreetAddress2              = isnull(@OrgStreetAddress2,cp.OrgStreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,cp.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,cp.CitySID)
				,@OrgPostalCode                  = isnull(@OrgPostalCode,cp.OrgPostalCode)
				,@OrgRegionSID                   = isnull(@OrgRegionSID,cp.OrgRegionSID)
				,@OrgPhone                       = isnull(@OrgPhone,cp.OrgPhone)
				,@OrgFax                         = isnull(@OrgFax,cp.OrgFax)
				,@OrgWebSite                     = isnull(@OrgWebSite,cp.OrgWebSite)
				,@EmailAddress                   = isnull(@EmailAddress,cp.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,cp.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,cp.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,cp.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,cp.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,cp.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,cp.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,cp.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,cp.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,cp.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,cp.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,cp.LastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,cp.OrgRowGUID)
				,@RegionRegionLabel              = isnull(@RegionRegionLabel,cp.RegionRegionLabel)
				,@RegionRegionName               = isnull(@RegionRegionName,cp.RegionRegionName)
				,@RegionIsDefault                = isnull(@RegionIsDefault,cp.RegionIsDefault)
				,@RegionIsActive                 = isnull(@RegionIsActive,cp.RegionIsActive)
				,@RegionRowGUID                  = isnull(@RegionRowGUID,cp.RegionRowGUID)
				,@PersonSID                      = isnull(@PersonSID,cp.PersonSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,cp.RegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,cp.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,cp.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,cp.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,cp.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,cp.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,cp.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,cp.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,cp.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,cp.RenewalExtensionExpiryTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,cp.ArchivedTime)
				,@RegistrantRowGUID              = isnull(@RegistrantRowGUID,cp.RegistrantRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,cp.IsDeleteEnabled)
				,@IsQualifying                   = isnull(@IsQualifying,cp.IsQualifying)
			from
				stg.vCredentialProfile cp
			where
				cp.CredentialProfileSID = @CredentialProfileSID

		end
		
		set @Phone = sf.fFormatPhone(@Phone)																	-- format phone numbers to standard
		set @Fax   = sf.fFormatPhone(@Fax)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ProcessingStatusSCD is not null and @ProcessingStatusSID = (select x.ProcessingStatusSID from stg.CredentialProfile x where x.CredentialProfileSID = @CredentialProfileSID)
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.CredentialSID from stg.CredentialProfile x where x.CredentialProfileSID = @CredentialProfileSID) <> @CredentialSID
		begin
			if (select x.IsActive from dbo.Credential x where x.CredentialSID = @CredentialSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'credential'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.OrgSID from stg.CredentialProfile x where x.CredentialProfileSID = @CredentialProfileSID) <> @OrgSID
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
		
		if (select x.ProcessingStatusSID from stg.CredentialProfile x where x.CredentialProfileSID = @CredentialProfileSID) <> @ProcessingStatusSID
		begin
			if (select x.IsActive from sf.ProcessingStatus x where x.ProcessingStatusSID = @ProcessingStatusSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'processing status'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.RegionSID from stg.CredentialProfile x where x.CredentialProfileSID = @CredentialProfileSID) <> @RegionSID
		begin
			if (select x.IsActive from dbo.Region x where x.RegionSID = @RegionSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'region'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
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
				r.RoutineName = 'stg#pCredentialProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pCredentialProfile
				 @Mode                           = 'update.pre'
				,@CredentialProfileSID           = @CredentialProfileSID
				,@ProcessingStatusSID            = @ProcessingStatusSID output
				,@SourceFileName                 = @SourceFileName output
				,@ProgramStartDate               = @ProgramStartDate output
				,@ProgramTargetCompletionDate    = @ProgramTargetCompletionDate output
				,@EffectiveTime                  = @EffectiveTime output
				,@IsDisplayedOnLicense           = @IsDisplayedOnLicense output
				,@ProgramName                    = @ProgramName output
				,@OrgName                        = @OrgName output
				,@OrgLabel                       = @OrgLabel output
				,@StreetAddress1                 = @StreetAddress1 output
				,@StreetAddress2                 = @StreetAddress2 output
				,@StreedAddress3                 = @StreedAddress3 output
				,@CityName                       = @CityName output
				,@StateProvinceName              = @StateProvinceName output
				,@StateProvinceCode              = @StateProvinceCode output
				,@PostalCode                     = @PostalCode output
				,@CountryName                    = @CountryName output
				,@CountryISOA3                   = @CountryISOA3 output
				,@Phone                          = @Phone output
				,@Fax                            = @Fax output
				,@WebSite                        = @WebSite output
				,@RegionLabel                    = @RegionLabel output
				,@RegionName                     = @RegionName output
				,@CredentialTypeLabel            = @CredentialTypeLabel output
				,@RegistrantSID                  = @RegistrantSID output
				,@CredentialSID                  = @CredentialSID output
				,@CredentialTypeSID              = @CredentialTypeSID output
				,@OrgSID                         = @OrgSID output
				,@RegionSID                      = @RegionSID output
				,@ProcessingComments             = @ProcessingComments output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@CredentialProfileXID           = @CredentialProfileXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@ProcessingStatusSCD            = @ProcessingStatusSCD
				,@ProcessingStatusLabel          = @ProcessingStatusLabel
				,@IsClosedStatus                 = @IsClosedStatus
				,@ProcessingStatusIsActive       = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault      = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID        = @ProcessingStatusRowGUID
				,@CredentialCredentialTypeSID    = @CredentialCredentialTypeSID
				,@CredentialLabel                = @CredentialLabel
				,@ToolTip                        = @ToolTip
				,@IsRelatedToProfession          = @IsRelatedToProfession
				,@IsProgramRequired              = @IsProgramRequired
				,@IsSpecialization               = @IsSpecialization
				,@CredentialIsActive             = @CredentialIsActive
				,@CredentialCode                 = @CredentialCode
				,@CredentialRowGUID              = @CredentialRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgOrgName                     = @OrgOrgName
				,@OrgOrgLabel                    = @OrgOrgLabel
				,@OrgStreetAddress1              = @OrgStreetAddress1
				,@OrgStreetAddress2              = @OrgStreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@OrgPostalCode                  = @OrgPostalCode
				,@OrgRegionSID                   = @OrgRegionSID
				,@OrgPhone                       = @OrgPhone
				,@OrgFax                         = @OrgFax
				,@OrgWebSite                     = @OrgWebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@OrgIsActive                    = @OrgIsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@LastVerifiedTime               = @LastVerifiedTime
				,@OrgRowGUID                     = @OrgRowGUID
				,@RegionRegionLabel              = @RegionRegionLabel
				,@RegionRegionName               = @RegionRegionName
				,@RegionIsDefault                = @RegionIsDefault
				,@RegionIsActive                 = @RegionIsActive
				,@RegionRowGUID                  = @RegionRowGUID
				,@PersonSID                      = @PersonSID
				,@RegistrantNo                   = @RegistrantNo
				,@YearOfInitialEmployment        = @YearOfInitialEmployment
				,@IsOnPublicRegistry             = @IsOnPublicRegistry
				,@CityNameOfBirth                = @CityNameOfBirth
				,@CountrySID                     = @CountrySID
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear           = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
				,@ArchivedTime                   = @ArchivedTime
				,@RegistrantRowGUID              = @RegistrantRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsQualifying                   = @IsQualifying
		
		end

		-- update the record

		update
			stg.CredentialProfile
		set
			 ProcessingStatusSID = @ProcessingStatusSID
			,SourceFileName = @SourceFileName
			,ProgramStartDate = @ProgramStartDate
			,ProgramTargetCompletionDate = @ProgramTargetCompletionDate
			,EffectiveTime = @EffectiveTime
			,IsDisplayedOnLicense = @IsDisplayedOnLicense
			,ProgramName = @ProgramName
			,OrgName = @OrgName
			,OrgLabel = @OrgLabel
			,StreetAddress1 = @StreetAddress1
			,StreetAddress2 = @StreetAddress2
			,StreedAddress3 = @StreedAddress3
			,CityName = @CityName
			,StateProvinceName = @StateProvinceName
			,StateProvinceCode = @StateProvinceCode
			,PostalCode = @PostalCode
			,CountryName = @CountryName
			,CountryISOA3 = @CountryISOA3
			,Phone = @Phone
			,Fax = @Fax
			,WebSite = @WebSite
			,RegionLabel = @RegionLabel
			,RegionName = @RegionName
			,CredentialTypeLabel = @CredentialTypeLabel
			,RegistrantSID = @RegistrantSID
			,CredentialSID = @CredentialSID
			,CredentialTypeSID = @CredentialTypeSID
			,OrgSID = @OrgSID
			,RegionSID = @RegionSID
			,ProcessingComments = @ProcessingComments
			,UserDefinedColumns = @UserDefinedColumns
			,CredentialProfileXID = @CredentialProfileXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			CredentialProfileSID = @CredentialProfileSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from stg.CredentialProfile where CredentialProfileSID = @credentialProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'stg.CredentialProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'stg.CredentialProfile'
					,@Arg2        = @credentialProfileSID
				
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
				,@Arg2        = 'stg.CredentialProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @credentialProfileSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
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
				r.RoutineName = 'stg#pCredentialProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pCredentialProfile
				 @Mode                           = 'update.post'
				,@CredentialProfileSID           = @CredentialProfileSID
				,@ProcessingStatusSID            = @ProcessingStatusSID
				,@SourceFileName                 = @SourceFileName
				,@ProgramStartDate               = @ProgramStartDate
				,@ProgramTargetCompletionDate    = @ProgramTargetCompletionDate
				,@EffectiveTime                  = @EffectiveTime
				,@IsDisplayedOnLicense           = @IsDisplayedOnLicense
				,@ProgramName                    = @ProgramName
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreedAddress3                 = @StreedAddress3
				,@CityName                       = @CityName
				,@StateProvinceName              = @StateProvinceName
				,@StateProvinceCode              = @StateProvinceCode
				,@PostalCode                     = @PostalCode
				,@CountryName                    = @CountryName
				,@CountryISOA3                   = @CountryISOA3
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@RegionLabel                    = @RegionLabel
				,@RegionName                     = @RegionName
				,@CredentialTypeLabel            = @CredentialTypeLabel
				,@RegistrantSID                  = @RegistrantSID
				,@CredentialSID                  = @CredentialSID
				,@CredentialTypeSID              = @CredentialTypeSID
				,@OrgSID                         = @OrgSID
				,@RegionSID                      = @RegionSID
				,@ProcessingComments             = @ProcessingComments
				,@UserDefinedColumns             = @UserDefinedColumns
				,@CredentialProfileXID           = @CredentialProfileXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@ProcessingStatusSCD            = @ProcessingStatusSCD
				,@ProcessingStatusLabel          = @ProcessingStatusLabel
				,@IsClosedStatus                 = @IsClosedStatus
				,@ProcessingStatusIsActive       = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault      = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID        = @ProcessingStatusRowGUID
				,@CredentialCredentialTypeSID    = @CredentialCredentialTypeSID
				,@CredentialLabel                = @CredentialLabel
				,@ToolTip                        = @ToolTip
				,@IsRelatedToProfession          = @IsRelatedToProfession
				,@IsProgramRequired              = @IsProgramRequired
				,@IsSpecialization               = @IsSpecialization
				,@CredentialIsActive             = @CredentialIsActive
				,@CredentialCode                 = @CredentialCode
				,@CredentialRowGUID              = @CredentialRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgOrgName                     = @OrgOrgName
				,@OrgOrgLabel                    = @OrgOrgLabel
				,@OrgStreetAddress1              = @OrgStreetAddress1
				,@OrgStreetAddress2              = @OrgStreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@OrgPostalCode                  = @OrgPostalCode
				,@OrgRegionSID                   = @OrgRegionSID
				,@OrgPhone                       = @OrgPhone
				,@OrgFax                         = @OrgFax
				,@OrgWebSite                     = @OrgWebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@OrgIsActive                    = @OrgIsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@LastVerifiedTime               = @LastVerifiedTime
				,@OrgRowGUID                     = @OrgRowGUID
				,@RegionRegionLabel              = @RegionRegionLabel
				,@RegionRegionName               = @RegionRegionName
				,@RegionIsDefault                = @RegionIsDefault
				,@RegionIsActive                 = @RegionIsActive
				,@RegionRowGUID                  = @RegionRowGUID
				,@PersonSID                      = @PersonSID
				,@RegistrantNo                   = @RegistrantNo
				,@YearOfInitialEmployment        = @YearOfInitialEmployment
				,@IsOnPublicRegistry             = @IsOnPublicRegistry
				,@CityNameOfBirth                = @CityNameOfBirth
				,@CountrySID                     = @CountrySID
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear           = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
				,@ArchivedTime                   = @ArchivedTime
				,@RegistrantRowGUID              = @RegistrantRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsQualifying                   = @IsQualifying
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.CredentialProfileSID
			from
				stg.vCredentialProfile ent
			where
				ent.CredentialProfileSID = @CredentialProfileSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.CredentialProfileSID
				,ent.ProcessingStatusSID
				,ent.SourceFileName
				,ent.ProgramStartDate
				,ent.ProgramTargetCompletionDate
				,ent.EffectiveTime
				,ent.IsDisplayedOnLicense
				,ent.ProgramName
				,ent.OrgName
				,ent.OrgLabel
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreedAddress3
				,ent.CityName
				,ent.StateProvinceName
				,ent.StateProvinceCode
				,ent.PostalCode
				,ent.CountryName
				,ent.CountryISOA3
				,ent.Phone
				,ent.Fax
				,ent.WebSite
				,ent.RegionLabel
				,ent.RegionName
				,ent.CredentialTypeLabel
				,ent.RegistrantSID
				,ent.CredentialSID
				,ent.CredentialTypeSID
				,ent.OrgSID
				,ent.RegionSID
				,ent.ProcessingComments
				,ent.UserDefinedColumns
				,ent.CredentialProfileXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ProcessingStatusSCD
				,ent.ProcessingStatusLabel
				,ent.IsClosedStatus
				,ent.ProcessingStatusIsActive
				,ent.ProcessingStatusIsDefault
				,ent.ProcessingStatusRowGUID
				,ent.CredentialCredentialTypeSID
				,ent.CredentialLabel
				,ent.ToolTip
				,ent.IsRelatedToProfession
				,ent.IsProgramRequired
				,ent.IsSpecialization
				,ent.CredentialIsActive
				,ent.CredentialCode
				,ent.CredentialRowGUID
				,ent.ParentOrgSID
				,ent.OrgTypeSID
				,ent.OrgOrgName
				,ent.OrgOrgLabel
				,ent.OrgStreetAddress1
				,ent.OrgStreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.OrgPostalCode
				,ent.OrgRegionSID
				,ent.OrgPhone
				,ent.OrgFax
				,ent.OrgWebSite
				,ent.EmailAddress
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.OrgIsActive
				,ent.IsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.OrgRowGUID
				,ent.RegionRegionLabel
				,ent.RegionRegionName
				,ent.RegionIsDefault
				,ent.RegionIsActive
				,ent.RegionRowGUID
				,ent.PersonSID
				,ent.RegistrantNo
				,ent.YearOfInitialEmployment
				,ent.IsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsQualifying
			from
				stg.vCredentialProfile ent
			where
				ent.CredentialProfileSID = @CredentialProfileSID

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
