SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pCredentialProfile#Insert]
	 @CredentialProfileSID           int               = null output				-- identity value assigned to the new record
	,@ProcessingStatusSID            int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@SourceFileName                 nvarchar(100)     = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ProgramStartDate               date              = null								
	,@ProgramTargetCompletionDate    date              = null								
	,@EffectiveTime                  date              = null								
	,@IsDisplayedOnLicense           bit               = null								-- default: (0)
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
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@ProcessingStatusSCD            varchar(10)       = null								-- not a base table column (default ignored)
	,@ProcessingStatusLabel          nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsClosedStatus                 bit               = null								-- not a base table column (default ignored)
	,@ProcessingStatusIsActive       bit               = null								-- not a base table column (default ignored)
	,@ProcessingStatusIsDefault      bit               = null								-- not a base table column (default ignored)
	,@ProcessingStatusRowGUID        uniqueidentifier  = null								-- not a base table column (default ignored)
	,@CredentialCredentialTypeSID    int               = null								-- not a base table column (default ignored)
	,@CredentialLabel                nvarchar(35)      = null								-- not a base table column (default ignored)
	,@ToolTip                        nvarchar(500)     = null								-- not a base table column (default ignored)
	,@IsRelatedToProfession          bit               = null								-- not a base table column (default ignored)
	,@IsProgramRequired              bit               = null								-- not a base table column (default ignored)
	,@IsSpecialization               bit               = null								-- not a base table column (default ignored)
	,@CredentialIsActive             bit               = null								-- not a base table column (default ignored)
	,@CredentialCode                 varchar(15)       = null								-- not a base table column (default ignored)
	,@CredentialRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ParentOrgSID                   int               = null								-- not a base table column (default ignored)
	,@OrgTypeSID                     int               = null								-- not a base table column (default ignored)
	,@OrgOrgName                     nvarchar(150)     = null								-- not a base table column (default ignored)
	,@OrgOrgLabel                    nvarchar(35)      = null								-- not a base table column (default ignored)
	,@OrgStreetAddress1              nvarchar(75)      = null								-- not a base table column (default ignored)
	,@OrgStreetAddress2              nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress3                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@CitySID                        int               = null								-- not a base table column (default ignored)
	,@OrgPostalCode                  varchar(10)       = null								-- not a base table column (default ignored)
	,@OrgRegionSID                   int               = null								-- not a base table column (default ignored)
	,@OrgPhone                       varchar(25)       = null								-- not a base table column (default ignored)
	,@OrgFax                         varchar(25)       = null								-- not a base table column (default ignored)
	,@OrgWebSite                     varchar(250)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@InsuranceOrgSID                int               = null								-- not a base table column (default ignored)
	,@InsurancePolicyNo              varchar(25)       = null								-- not a base table column (default ignored)
	,@InsuranceAmount                decimal(11,2)     = null								-- not a base table column (default ignored)
	,@IsEmployer                     bit               = null								-- not a base table column (default ignored)
	,@IsCredentialAuthority          bit               = null								-- not a base table column (default ignored)
	,@IsInsurer                      bit               = null								-- not a base table column (default ignored)
	,@IsInsuranceCertificateRequired bit               = null								-- not a base table column (default ignored)
	,@IsPublic                       nchar(10)         = null								-- not a base table column (default ignored)
	,@OrgIsActive                    bit               = null								-- not a base table column (default ignored)
	,@IsAdminReviewRequired          bit               = null								-- not a base table column (default ignored)
	,@LastVerifiedTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@OrgRowGUID                     uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegionRegionLabel              nvarchar(35)      = null								-- not a base table column (default ignored)
	,@RegionRegionName               nvarchar(50)      = null								-- not a base table column (default ignored)
	,@RegionIsDefault                bit               = null								-- not a base table column (default ignored)
	,@RegionIsActive                 bit               = null								-- not a base table column (default ignored)
	,@RegionRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@PersonSID                      int               = null								-- not a base table column (default ignored)
	,@RegistrantNo                   varchar(50)       = null								-- not a base table column (default ignored)
	,@YearOfInitialEmployment        smallint          = null								-- not a base table column (default ignored)
	,@IsOnPublicRegistry             bit               = null								-- not a base table column (default ignored)
	,@CityNameOfBirth                nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CountrySID                     int               = null								-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence    smallint          = null								-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours smallint          = null								-- not a base table column (default ignored)
	,@LateFeeExclusionYear           smallint          = null								-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked   bit               = null								-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime     datetime          = null								-- not a base table column (default ignored)
	,@ArchivedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@RegistrantRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsQualifying                   bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : stg.pCredentialProfile#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the stg.CredentialProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.CredentialProfile table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vCredentialProfile entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pCredentialProfile procedure. The extended procedure is only called
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

	set @CredentialProfileSID = null																				-- initialize output parameter

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
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsDisplayedOnLicense = isnull(@IsDisplayedOnLicense,(0))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                = isnull(@IsReselected               ,(0))
		
		set @Phone = sf.fFormatPhone(@Phone)																	-- format phone numbers to standard
		set @Fax   = sf.fFormatPhone(@Fax)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ProcessingStatusSCD is not null
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @ProcessingStatusSID  is null select @ProcessingStatusSID  = x.ProcessingStatusSID from sf.ProcessingStatus  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
		
		exec sf.pEffectiveExpiry#Set																					-- ensure effective time has start of day time component or current time if today
		   @EffectiveTime = @EffectiveTime output
	
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
				r.RoutineName = 'stg#pCredentialProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pCredentialProfile
				 @Mode                           = 'insert.pre'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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

		-- insert the record

		insert
			stg.CredentialProfile
		(
			 ProcessingStatusSID
			,SourceFileName
			,ProgramStartDate
			,ProgramTargetCompletionDate
			,EffectiveTime
			,IsDisplayedOnLicense
			,ProgramName
			,OrgName
			,OrgLabel
			,StreetAddress1
			,StreetAddress2
			,StreedAddress3
			,CityName
			,StateProvinceName
			,StateProvinceCode
			,PostalCode
			,CountryName
			,CountryISOA3
			,Phone
			,Fax
			,WebSite
			,RegionLabel
			,RegionName
			,CredentialTypeLabel
			,RegistrantSID
			,CredentialSID
			,CredentialTypeSID
			,OrgSID
			,RegionSID
			,ProcessingComments
			,UserDefinedColumns
			,CredentialProfileXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @ProcessingStatusSID
			,@SourceFileName
			,@ProgramStartDate
			,@ProgramTargetCompletionDate
			,@EffectiveTime
			,@IsDisplayedOnLicense
			,@ProgramName
			,@OrgName
			,@OrgLabel
			,@StreetAddress1
			,@StreetAddress2
			,@StreedAddress3
			,@CityName
			,@StateProvinceName
			,@StateProvinceCode
			,@PostalCode
			,@CountryName
			,@CountryISOA3
			,@Phone
			,@Fax
			,@WebSite
			,@RegionLabel
			,@RegionName
			,@CredentialTypeLabel
			,@RegistrantSID
			,@CredentialSID
			,@CredentialTypeSID
			,@OrgSID
			,@RegionSID
			,@ProcessingComments
			,@UserDefinedColumns
			,@CredentialProfileXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected         = @@rowcount
			,@CredentialProfileSID = scope_identity()														-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'stg.CredentialProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @CredentialProfileSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
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
				r.RoutineName = 'stg#pCredentialProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pCredentialProfile
				 @Mode                           = 'insert.post'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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
