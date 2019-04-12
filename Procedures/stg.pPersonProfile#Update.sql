SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pPersonProfile#Update]
	 @PersonProfileSID                          int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ProcessingStatusSID                       int               = null -- table column values to update:
	,@SourceFileName                            nvarchar(100)     = null
	,@LastName                                  nvarchar(35)      = null
	,@FirstName                                 nvarchar(30)      = null
	,@CommonName                                nvarchar(30)      = null
	,@MiddleNames                               nvarchar(30)      = null
	,@EmailAddress                              varchar(150)      = null
	,@HomePhone                                 varchar(25)       = null
	,@MobilePhone                               varchar(25)       = null
	,@IsTextMessagingEnabled                    bit               = null
	,@SignatureImage                            varbinary(max)    = null
	,@IdentityPhoto                             varbinary(max)    = null
	,@GenderCode                                varchar(5)        = null
	,@GenderLabel                               nvarchar(35)      = null
	,@NamePrefixLabel                           nvarchar(35)      = null
	,@BirthDate                                 date              = null
	,@DeathDate                                 date              = null
	,@UserName                                  nvarchar(75)      = null
	,@SubDomain                                 varchar(63)       = null
	,@Password                                  nvarchar(50)      = null
	,@StreetAddress1                            nvarchar(75)      = null
	,@StreetAddress2                            nvarchar(75)      = null
	,@StreetAddress3                            nvarchar(75)      = null
	,@CityName                                  nvarchar(30)      = null
	,@StateProvinceName                         nvarchar(30)      = null
	,@StateProvinceCode                         nvarchar(5)       = null
	,@PostalCode                                varchar(10)       = null
	,@CountryName                               nvarchar(50)      = null
	,@CountryISOA3                              char(3)           = null
	,@AddressPhone                              varchar(25)       = null
	,@AddressFax                                varchar(25)       = null
	,@AddressEffectiveTime                      datetime          = null
	,@RegionLabel                               nvarchar(35)      = null
	,@RegionName                                nvarchar(50)      = null
	,@RegistrantNo                              varchar(50)       = null
	,@ArchivedTime                              datetimeoffset(7) = null
	,@IsOnPublicRegistry                        bit               = null
	,@DirectedAuditYearCompetence               smallint          = null
	,@DirectedAuditYearPracticeHours            smallint          = null
	,@PersonSID                                 int               = null
	,@PersonEmailAddressSID                     int               = null
	,@ApplicationUserSID                        int               = null
	,@PersonMailingAddressSID                   int               = null
	,@RegionSID                                 int               = null
	,@NamePrefixSID                             int               = null
	,@GenderSID                                 int               = null
	,@CitySID                                   int               = null
	,@StateProvinceSID                          int               = null
	,@CountrySID                                int               = null
	,@RegistrantSID                             int               = null
	,@ProcessingComments                        nvarchar(max)     = null
	,@UserDefinedColumns                        xml               = null
	,@PersonProfileXID                          varchar(150)      = null
	,@LegacyKey                                 nvarchar(50)      = null
	,@UpdateUser                                nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                  timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                              tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                             bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                  xml               = null -- other values defining context for the update (if any)
	,@ProcessingStatusSCD                       varchar(10)       = null -- not a base table column
	,@ProcessingStatusLabel                     nvarchar(35)      = null -- not a base table column
	,@IsClosedStatus                            bit               = null -- not a base table column
	,@ProcessingStatusIsActive                  bit               = null -- not a base table column
	,@ProcessingStatusIsDefault                 bit               = null -- not a base table column
	,@ProcessingStatusRowGUID                   uniqueidentifier  = null -- not a base table column
	,@CityCityName                              nvarchar(30)      = null -- not a base table column
	,@CityStateProvinceSID                      int               = null -- not a base table column
	,@CityIsDefault                             bit               = null -- not a base table column
	,@CityIsActive                              bit               = null -- not a base table column
	,@CityIsAdminReviewRequired                 bit               = null -- not a base table column
	,@CityRowGUID                               uniqueidentifier  = null -- not a base table column
	,@CountryCountryName                        nvarchar(50)      = null -- not a base table column
	,@ISOA2                                     char(2)           = null -- not a base table column
	,@ISOA3                                     char(3)           = null -- not a base table column
	,@CountryISONumber                          smallint          = null -- not a base table column
	,@IsStateProvinceRequired                   bit               = null -- not a base table column
	,@CountryIsDefault                          bit               = null -- not a base table column
	,@CountryIsActive                           bit               = null -- not a base table column
	,@CountryRowGUID                            uniqueidentifier  = null -- not a base table column
	,@PersonMailingAddressPersonSID             int               = null -- not a base table column
	,@PersonMailingAddressStreetAddress1        nvarchar(75)      = null -- not a base table column
	,@PersonMailingAddressStreetAddress2        nvarchar(75)      = null -- not a base table column
	,@PersonMailingAddressStreetAddress3        nvarchar(75)      = null -- not a base table column
	,@PersonMailingAddressCitySID               int               = null -- not a base table column
	,@PersonMailingAddressPostalCode            varchar(10)       = null -- not a base table column
	,@PersonMailingAddressRegionSID             int               = null -- not a base table column
	,@EffectiveTime                             datetime          = null -- not a base table column
	,@PersonMailingAddressIsAdminReviewRequired bit               = null -- not a base table column
	,@LastVerifiedTime                          datetimeoffset(7) = null -- not a base table column
	,@PersonMailingAddressRowGUID               uniqueidentifier  = null -- not a base table column
	,@RegionRegionLabel                         nvarchar(35)      = null -- not a base table column
	,@RegionRegionName                          nvarchar(50)      = null -- not a base table column
	,@RegionIsDefault                           bit               = null -- not a base table column
	,@RegionIsActive                            bit               = null -- not a base table column
	,@RegionRowGUID                             uniqueidentifier  = null -- not a base table column
	,@RegistrantPersonSID                       int               = null -- not a base table column
	,@RegistrantRegistrantNo                    varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment                   smallint          = null -- not a base table column
	,@RegistrantIsOnPublicRegistry              bit               = null -- not a base table column
	,@CityNameOfBirth                           nvarchar(30)      = null -- not a base table column
	,@RegistrantCountrySID                      int               = null -- not a base table column
	,@RegistrantDirectedAuditYearCompetence     smallint          = null -- not a base table column
	,@RegistrantDirectedAuditYearPracticeHours  smallint          = null -- not a base table column
	,@LateFeeExclusionYear                      smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked              bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime                datetime          = null -- not a base table column
	,@RegistrantArchivedTime                    datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                         uniqueidentifier  = null -- not a base table column
	,@StateProvinceStateProvinceName            nvarchar(30)      = null -- not a base table column
	,@StateProvinceStateProvinceCode            nvarchar(5)       = null -- not a base table column
	,@StateProvinceCountrySID                   int               = null -- not a base table column
	,@StateProvinceISONumber                    smallint          = null -- not a base table column
	,@IsDisplayed                               bit               = null -- not a base table column
	,@StateProvinceIsDefault                    bit               = null -- not a base table column
	,@StateProvinceIsActive                     bit               = null -- not a base table column
	,@StateProvinceIsAdminReviewRequired        bit               = null -- not a base table column
	,@StateProvinceRowGUID                      uniqueidentifier  = null -- not a base table column
	,@ApplicationUserPersonSID                  int               = null -- not a base table column
	,@CultureSID                                int               = null -- not a base table column
	,@AuthenticationAuthoritySID                int               = null -- not a base table column
	,@ApplicationUserUserName                   nvarchar(75)      = null -- not a base table column
	,@LastReviewTime                            datetimeoffset(7) = null -- not a base table column
	,@LastReviewUser                            nvarchar(75)      = null -- not a base table column
	,@IsPotentialDuplicate                      bit               = null -- not a base table column
	,@IsTemplate                                bit               = null -- not a base table column
	,@GlassBreakPassword                        varbinary(8000)   = null -- not a base table column
	,@LastGlassBreakPasswordChangeTime          datetimeoffset(7) = null -- not a base table column
	,@ApplicationUserIsActive                   bit               = null -- not a base table column
	,@AuthenticationSystemID                    nvarchar(50)      = null -- not a base table column
	,@ApplicationUserRowGUID                    uniqueidentifier  = null -- not a base table column
	,@GenderSCD                                 char(1)           = null -- not a base table column
	,@GenderGenderLabel                         nvarchar(35)      = null -- not a base table column
	,@GenderIsActive                            bit               = null -- not a base table column
	,@GenderRowGUID                             uniqueidentifier  = null -- not a base table column
	,@NamePrefixNamePrefixLabel                 nvarchar(35)      = null -- not a base table column
	,@NamePrefixIsActive                        bit               = null -- not a base table column
	,@NamePrefixRowGUID                         uniqueidentifier  = null -- not a base table column
	,@PersonGenderSID                           int               = null -- not a base table column
	,@PersonNamePrefixSID                       int               = null -- not a base table column
	,@PersonFirstName                           nvarchar(30)      = null -- not a base table column
	,@PersonCommonName                          nvarchar(30)      = null -- not a base table column
	,@PersonMiddleNames                         nvarchar(30)      = null -- not a base table column
	,@PersonLastName                            nvarchar(35)      = null -- not a base table column
	,@PersonBirthDate                           date              = null -- not a base table column
	,@PersonDeathDate                           date              = null -- not a base table column
	,@PersonHomePhone                           varchar(25)       = null -- not a base table column
	,@PersonMobilePhone                         varchar(25)       = null -- not a base table column
	,@PersonIsTextMessagingEnabled              bit               = null -- not a base table column
	,@ImportBatch                               nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                             uniqueidentifier  = null -- not a base table column
	,@PersonEmailAddressPersonSID               int               = null -- not a base table column
	,@PersonEmailAddressEmailAddress            varchar(150)      = null -- not a base table column
	,@IsPrimary                                 bit               = null -- not a base table column
	,@PersonEmailAddressIsActive                bit               = null -- not a base table column
	,@PersonEmailAddressRowGUID                 uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                           bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : stg.pPersonProfile#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the stg.PersonProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the stg.PersonProfile table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonProfile entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonProfile procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonProfileCheck to test all rules.

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

		if @PersonProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonProfileSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @SourceFileName = ltrim(rtrim(@SourceFileName))
		set @LastName = ltrim(rtrim(@LastName))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @GenderCode = ltrim(rtrim(@GenderCode))
		set @GenderLabel = ltrim(rtrim(@GenderLabel))
		set @NamePrefixLabel = ltrim(rtrim(@NamePrefixLabel))
		set @UserName = ltrim(rtrim(@UserName))
		set @SubDomain = ltrim(rtrim(@SubDomain))
		set @Password = ltrim(rtrim(@Password))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @CityName = ltrim(rtrim(@CityName))
		set @StateProvinceName = ltrim(rtrim(@StateProvinceName))
		set @StateProvinceCode = ltrim(rtrim(@StateProvinceCode))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @CountryName = ltrim(rtrim(@CountryName))
		set @CountryISOA3 = ltrim(rtrim(@CountryISOA3))
		set @AddressPhone = ltrim(rtrim(@AddressPhone))
		set @AddressFax = ltrim(rtrim(@AddressFax))
		set @RegionLabel = ltrim(rtrim(@RegionLabel))
		set @RegionName = ltrim(rtrim(@RegionName))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @ProcessingComments = ltrim(rtrim(@ProcessingComments))
		set @PersonProfileXID = ltrim(rtrim(@PersonProfileXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ProcessingStatusSCD = ltrim(rtrim(@ProcessingStatusSCD))
		set @ProcessingStatusLabel = ltrim(rtrim(@ProcessingStatusLabel))
		set @CityCityName = ltrim(rtrim(@CityCityName))
		set @CountryCountryName = ltrim(rtrim(@CountryCountryName))
		set @ISOA2 = ltrim(rtrim(@ISOA2))
		set @ISOA3 = ltrim(rtrim(@ISOA3))
		set @PersonMailingAddressStreetAddress1 = ltrim(rtrim(@PersonMailingAddressStreetAddress1))
		set @PersonMailingAddressStreetAddress2 = ltrim(rtrim(@PersonMailingAddressStreetAddress2))
		set @PersonMailingAddressStreetAddress3 = ltrim(rtrim(@PersonMailingAddressStreetAddress3))
		set @PersonMailingAddressPostalCode = ltrim(rtrim(@PersonMailingAddressPostalCode))
		set @RegionRegionLabel = ltrim(rtrim(@RegionRegionLabel))
		set @RegionRegionName = ltrim(rtrim(@RegionRegionName))
		set @RegistrantRegistrantNo = ltrim(rtrim(@RegistrantRegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @StateProvinceStateProvinceName = ltrim(rtrim(@StateProvinceStateProvinceName))
		set @StateProvinceStateProvinceCode = ltrim(rtrim(@StateProvinceStateProvinceCode))
		set @ApplicationUserUserName = ltrim(rtrim(@ApplicationUserUserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @GenderSCD = ltrim(rtrim(@GenderSCD))
		set @GenderGenderLabel = ltrim(rtrim(@GenderGenderLabel))
		set @NamePrefixNamePrefixLabel = ltrim(rtrim(@NamePrefixNamePrefixLabel))
		set @PersonFirstName = ltrim(rtrim(@PersonFirstName))
		set @PersonCommonName = ltrim(rtrim(@PersonCommonName))
		set @PersonMiddleNames = ltrim(rtrim(@PersonMiddleNames))
		set @PersonLastName = ltrim(rtrim(@PersonLastName))
		set @PersonHomePhone = ltrim(rtrim(@PersonHomePhone))
		set @PersonMobilePhone = ltrim(rtrim(@PersonMobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @PersonEmailAddressEmailAddress = ltrim(rtrim(@PersonEmailAddressEmailAddress))

		-- set zero length strings to null to avoid storing them in the record

		if len(@SourceFileName) = 0 set @SourceFileName = null
		if len(@LastName) = 0 set @LastName = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@GenderCode) = 0 set @GenderCode = null
		if len(@GenderLabel) = 0 set @GenderLabel = null
		if len(@NamePrefixLabel) = 0 set @NamePrefixLabel = null
		if len(@UserName) = 0 set @UserName = null
		if len(@SubDomain) = 0 set @SubDomain = null
		if len(@Password) = 0 set @Password = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@CityName) = 0 set @CityName = null
		if len(@StateProvinceName) = 0 set @StateProvinceName = null
		if len(@StateProvinceCode) = 0 set @StateProvinceCode = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@CountryName) = 0 set @CountryName = null
		if len(@CountryISOA3) = 0 set @CountryISOA3 = null
		if len(@AddressPhone) = 0 set @AddressPhone = null
		if len(@AddressFax) = 0 set @AddressFax = null
		if len(@RegionLabel) = 0 set @RegionLabel = null
		if len(@RegionName) = 0 set @RegionName = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@ProcessingComments) = 0 set @ProcessingComments = null
		if len(@PersonProfileXID) = 0 set @PersonProfileXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ProcessingStatusSCD) = 0 set @ProcessingStatusSCD = null
		if len(@ProcessingStatusLabel) = 0 set @ProcessingStatusLabel = null
		if len(@CityCityName) = 0 set @CityCityName = null
		if len(@CountryCountryName) = 0 set @CountryCountryName = null
		if len(@ISOA2) = 0 set @ISOA2 = null
		if len(@ISOA3) = 0 set @ISOA3 = null
		if len(@PersonMailingAddressStreetAddress1) = 0 set @PersonMailingAddressStreetAddress1 = null
		if len(@PersonMailingAddressStreetAddress2) = 0 set @PersonMailingAddressStreetAddress2 = null
		if len(@PersonMailingAddressStreetAddress3) = 0 set @PersonMailingAddressStreetAddress3 = null
		if len(@PersonMailingAddressPostalCode) = 0 set @PersonMailingAddressPostalCode = null
		if len(@RegionRegionLabel) = 0 set @RegionRegionLabel = null
		if len(@RegionRegionName) = 0 set @RegionRegionName = null
		if len(@RegistrantRegistrantNo) = 0 set @RegistrantRegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@StateProvinceStateProvinceName) = 0 set @StateProvinceStateProvinceName = null
		if len(@StateProvinceStateProvinceCode) = 0 set @StateProvinceStateProvinceCode = null
		if len(@ApplicationUserUserName) = 0 set @ApplicationUserUserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@GenderSCD) = 0 set @GenderSCD = null
		if len(@GenderGenderLabel) = 0 set @GenderGenderLabel = null
		if len(@NamePrefixNamePrefixLabel) = 0 set @NamePrefixNamePrefixLabel = null
		if len(@PersonFirstName) = 0 set @PersonFirstName = null
		if len(@PersonCommonName) = 0 set @PersonCommonName = null
		if len(@PersonMiddleNames) = 0 set @PersonMiddleNames = null
		if len(@PersonLastName) = 0 set @PersonLastName = null
		if len(@PersonHomePhone) = 0 set @PersonHomePhone = null
		if len(@PersonMobilePhone) = 0 set @PersonMobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@PersonEmailAddressEmailAddress) = 0 set @PersonEmailAddressEmailAddress = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ProcessingStatusSID                       = isnull(@ProcessingStatusSID,pp.ProcessingStatusSID)
				,@SourceFileName                            = isnull(@SourceFileName,pp.SourceFileName)
				,@LastName                                  = isnull(@LastName,pp.LastName)
				,@FirstName                                 = isnull(@FirstName,pp.FirstName)
				,@CommonName                                = isnull(@CommonName,pp.CommonName)
				,@MiddleNames                               = isnull(@MiddleNames,pp.MiddleNames)
				,@EmailAddress                              = isnull(@EmailAddress,pp.EmailAddress)
				,@HomePhone                                 = isnull(@HomePhone,pp.HomePhone)
				,@MobilePhone                               = isnull(@MobilePhone,pp.MobilePhone)
				,@IsTextMessagingEnabled                    = isnull(@IsTextMessagingEnabled,pp.IsTextMessagingEnabled)
				,@SignatureImage                            = isnull(@SignatureImage,pp.SignatureImage)
				,@IdentityPhoto                             = isnull(@IdentityPhoto,pp.IdentityPhoto)
				,@GenderCode                                = isnull(@GenderCode,pp.GenderCode)
				,@GenderLabel                               = isnull(@GenderLabel,pp.GenderLabel)
				,@NamePrefixLabel                           = isnull(@NamePrefixLabel,pp.NamePrefixLabel)
				,@BirthDate                                 = isnull(@BirthDate,pp.BirthDate)
				,@DeathDate                                 = isnull(@DeathDate,pp.DeathDate)
				,@UserName                                  = isnull(@UserName,pp.UserName)
				,@SubDomain                                 = isnull(@SubDomain,pp.SubDomain)
				,@Password                                  = isnull(@Password,pp.Password)
				,@StreetAddress1                            = isnull(@StreetAddress1,pp.StreetAddress1)
				,@StreetAddress2                            = isnull(@StreetAddress2,pp.StreetAddress2)
				,@StreetAddress3                            = isnull(@StreetAddress3,pp.StreetAddress3)
				,@CityName                                  = isnull(@CityName,pp.CityName)
				,@StateProvinceName                         = isnull(@StateProvinceName,pp.StateProvinceName)
				,@StateProvinceCode                         = isnull(@StateProvinceCode,pp.StateProvinceCode)
				,@PostalCode                                = isnull(@PostalCode,pp.PostalCode)
				,@CountryName                               = isnull(@CountryName,pp.CountryName)
				,@CountryISOA3                              = isnull(@CountryISOA3,pp.CountryISOA3)
				,@AddressPhone                              = isnull(@AddressPhone,pp.AddressPhone)
				,@AddressFax                                = isnull(@AddressFax,pp.AddressFax)
				,@AddressEffectiveTime                      = isnull(@AddressEffectiveTime,pp.AddressEffectiveTime)
				,@RegionLabel                               = isnull(@RegionLabel,pp.RegionLabel)
				,@RegionName                                = isnull(@RegionName,pp.RegionName)
				,@RegistrantNo                              = isnull(@RegistrantNo,pp.RegistrantNo)
				,@ArchivedTime                              = isnull(@ArchivedTime,pp.ArchivedTime)
				,@IsOnPublicRegistry                        = isnull(@IsOnPublicRegistry,pp.IsOnPublicRegistry)
				,@DirectedAuditYearCompetence               = isnull(@DirectedAuditYearCompetence,pp.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours            = isnull(@DirectedAuditYearPracticeHours,pp.DirectedAuditYearPracticeHours)
				,@PersonSID                                 = isnull(@PersonSID,pp.PersonSID)
				,@PersonEmailAddressSID                     = isnull(@PersonEmailAddressSID,pp.PersonEmailAddressSID)
				,@ApplicationUserSID                        = isnull(@ApplicationUserSID,pp.ApplicationUserSID)
				,@PersonMailingAddressSID                   = isnull(@PersonMailingAddressSID,pp.PersonMailingAddressSID)
				,@RegionSID                                 = isnull(@RegionSID,pp.RegionSID)
				,@NamePrefixSID                             = isnull(@NamePrefixSID,pp.NamePrefixSID)
				,@GenderSID                                 = isnull(@GenderSID,pp.GenderSID)
				,@CitySID                                   = isnull(@CitySID,pp.CitySID)
				,@StateProvinceSID                          = isnull(@StateProvinceSID,pp.StateProvinceSID)
				,@CountrySID                                = isnull(@CountrySID,pp.CountrySID)
				,@RegistrantSID                             = isnull(@RegistrantSID,pp.RegistrantSID)
				,@ProcessingComments                        = isnull(@ProcessingComments,pp.ProcessingComments)
				,@UserDefinedColumns                        = isnull(@UserDefinedColumns,pp.UserDefinedColumns)
				,@PersonProfileXID                          = isnull(@PersonProfileXID,pp.PersonProfileXID)
				,@LegacyKey                                 = isnull(@LegacyKey,pp.LegacyKey)
				,@UpdateUser                                = isnull(@UpdateUser,pp.UpdateUser)
				,@IsReselected                              = isnull(@IsReselected,pp.IsReselected)
				,@IsNullApplied                             = isnull(@IsNullApplied,pp.IsNullApplied)
				,@zContext                                  = isnull(@zContext,pp.zContext)
				,@ProcessingStatusSCD                       = isnull(@ProcessingStatusSCD,pp.ProcessingStatusSCD)
				,@ProcessingStatusLabel                     = isnull(@ProcessingStatusLabel,pp.ProcessingStatusLabel)
				,@IsClosedStatus                            = isnull(@IsClosedStatus,pp.IsClosedStatus)
				,@ProcessingStatusIsActive                  = isnull(@ProcessingStatusIsActive,pp.ProcessingStatusIsActive)
				,@ProcessingStatusIsDefault                 = isnull(@ProcessingStatusIsDefault,pp.ProcessingStatusIsDefault)
				,@ProcessingStatusRowGUID                   = isnull(@ProcessingStatusRowGUID,pp.ProcessingStatusRowGUID)
				,@CityCityName                              = isnull(@CityCityName,pp.CityCityName)
				,@CityStateProvinceSID                      = isnull(@CityStateProvinceSID,pp.CityStateProvinceSID)
				,@CityIsDefault                             = isnull(@CityIsDefault,pp.CityIsDefault)
				,@CityIsActive                              = isnull(@CityIsActive,pp.CityIsActive)
				,@CityIsAdminReviewRequired                 = isnull(@CityIsAdminReviewRequired,pp.CityIsAdminReviewRequired)
				,@CityRowGUID                               = isnull(@CityRowGUID,pp.CityRowGUID)
				,@CountryCountryName                        = isnull(@CountryCountryName,pp.CountryCountryName)
				,@ISOA2                                     = isnull(@ISOA2,pp.ISOA2)
				,@ISOA3                                     = isnull(@ISOA3,pp.ISOA3)
				,@CountryISONumber                          = isnull(@CountryISONumber,pp.CountryISONumber)
				,@IsStateProvinceRequired                   = isnull(@IsStateProvinceRequired,pp.IsStateProvinceRequired)
				,@CountryIsDefault                          = isnull(@CountryIsDefault,pp.CountryIsDefault)
				,@CountryIsActive                           = isnull(@CountryIsActive,pp.CountryIsActive)
				,@CountryRowGUID                            = isnull(@CountryRowGUID,pp.CountryRowGUID)
				,@PersonMailingAddressPersonSID             = isnull(@PersonMailingAddressPersonSID,pp.PersonMailingAddressPersonSID)
				,@PersonMailingAddressStreetAddress1        = isnull(@PersonMailingAddressStreetAddress1,pp.PersonMailingAddressStreetAddress1)
				,@PersonMailingAddressStreetAddress2        = isnull(@PersonMailingAddressStreetAddress2,pp.PersonMailingAddressStreetAddress2)
				,@PersonMailingAddressStreetAddress3        = isnull(@PersonMailingAddressStreetAddress3,pp.PersonMailingAddressStreetAddress3)
				,@PersonMailingAddressCitySID               = isnull(@PersonMailingAddressCitySID,pp.PersonMailingAddressCitySID)
				,@PersonMailingAddressPostalCode            = isnull(@PersonMailingAddressPostalCode,pp.PersonMailingAddressPostalCode)
				,@PersonMailingAddressRegionSID             = isnull(@PersonMailingAddressRegionSID,pp.PersonMailingAddressRegionSID)
				,@EffectiveTime                             = isnull(@EffectiveTime,pp.EffectiveTime)
				,@PersonMailingAddressIsAdminReviewRequired = isnull(@PersonMailingAddressIsAdminReviewRequired,pp.PersonMailingAddressIsAdminReviewRequired)
				,@LastVerifiedTime                          = isnull(@LastVerifiedTime,pp.LastVerifiedTime)
				,@PersonMailingAddressRowGUID               = isnull(@PersonMailingAddressRowGUID,pp.PersonMailingAddressRowGUID)
				,@RegionRegionLabel                         = isnull(@RegionRegionLabel,pp.RegionRegionLabel)
				,@RegionRegionName                          = isnull(@RegionRegionName,pp.RegionRegionName)
				,@RegionIsDefault                           = isnull(@RegionIsDefault,pp.RegionIsDefault)
				,@RegionIsActive                            = isnull(@RegionIsActive,pp.RegionIsActive)
				,@RegionRowGUID                             = isnull(@RegionRowGUID,pp.RegionRowGUID)
				,@RegistrantPersonSID                       = isnull(@RegistrantPersonSID,pp.RegistrantPersonSID)
				,@RegistrantRegistrantNo                    = isnull(@RegistrantRegistrantNo,pp.RegistrantRegistrantNo)
				,@YearOfInitialEmployment                   = isnull(@YearOfInitialEmployment,pp.YearOfInitialEmployment)
				,@RegistrantIsOnPublicRegistry              = isnull(@RegistrantIsOnPublicRegistry,pp.RegistrantIsOnPublicRegistry)
				,@CityNameOfBirth                           = isnull(@CityNameOfBirth,pp.CityNameOfBirth)
				,@RegistrantCountrySID                      = isnull(@RegistrantCountrySID,pp.RegistrantCountrySID)
				,@RegistrantDirectedAuditYearCompetence     = isnull(@RegistrantDirectedAuditYearCompetence,pp.RegistrantDirectedAuditYearCompetence)
				,@RegistrantDirectedAuditYearPracticeHours  = isnull(@RegistrantDirectedAuditYearPracticeHours,pp.RegistrantDirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear                      = isnull(@LateFeeExclusionYear,pp.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked              = isnull(@IsRenewalAutoApprovalBlocked,pp.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime                = isnull(@RenewalExtensionExpiryTime,pp.RenewalExtensionExpiryTime)
				,@RegistrantArchivedTime                    = isnull(@RegistrantArchivedTime,pp.RegistrantArchivedTime)
				,@RegistrantRowGUID                         = isnull(@RegistrantRowGUID,pp.RegistrantRowGUID)
				,@StateProvinceStateProvinceName            = isnull(@StateProvinceStateProvinceName,pp.StateProvinceStateProvinceName)
				,@StateProvinceStateProvinceCode            = isnull(@StateProvinceStateProvinceCode,pp.StateProvinceStateProvinceCode)
				,@StateProvinceCountrySID                   = isnull(@StateProvinceCountrySID,pp.StateProvinceCountrySID)
				,@StateProvinceISONumber                    = isnull(@StateProvinceISONumber,pp.StateProvinceISONumber)
				,@IsDisplayed                               = isnull(@IsDisplayed,pp.IsDisplayed)
				,@StateProvinceIsDefault                    = isnull(@StateProvinceIsDefault,pp.StateProvinceIsDefault)
				,@StateProvinceIsActive                     = isnull(@StateProvinceIsActive,pp.StateProvinceIsActive)
				,@StateProvinceIsAdminReviewRequired        = isnull(@StateProvinceIsAdminReviewRequired,pp.StateProvinceIsAdminReviewRequired)
				,@StateProvinceRowGUID                      = isnull(@StateProvinceRowGUID,pp.StateProvinceRowGUID)
				,@ApplicationUserPersonSID                  = isnull(@ApplicationUserPersonSID,pp.ApplicationUserPersonSID)
				,@CultureSID                                = isnull(@CultureSID,pp.CultureSID)
				,@AuthenticationAuthoritySID                = isnull(@AuthenticationAuthoritySID,pp.AuthenticationAuthoritySID)
				,@ApplicationUserUserName                   = isnull(@ApplicationUserUserName,pp.ApplicationUserUserName)
				,@LastReviewTime                            = isnull(@LastReviewTime,pp.LastReviewTime)
				,@LastReviewUser                            = isnull(@LastReviewUser,pp.LastReviewUser)
				,@IsPotentialDuplicate                      = isnull(@IsPotentialDuplicate,pp.IsPotentialDuplicate)
				,@IsTemplate                                = isnull(@IsTemplate,pp.IsTemplate)
				,@GlassBreakPassword                        = isnull(@GlassBreakPassword,pp.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime          = isnull(@LastGlassBreakPasswordChangeTime,pp.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive                   = isnull(@ApplicationUserIsActive,pp.ApplicationUserIsActive)
				,@AuthenticationSystemID                    = isnull(@AuthenticationSystemID,pp.AuthenticationSystemID)
				,@ApplicationUserRowGUID                    = isnull(@ApplicationUserRowGUID,pp.ApplicationUserRowGUID)
				,@GenderSCD                                 = isnull(@GenderSCD,pp.GenderSCD)
				,@GenderGenderLabel                         = isnull(@GenderGenderLabel,pp.GenderGenderLabel)
				,@GenderIsActive                            = isnull(@GenderIsActive,pp.GenderIsActive)
				,@GenderRowGUID                             = isnull(@GenderRowGUID,pp.GenderRowGUID)
				,@NamePrefixNamePrefixLabel                 = isnull(@NamePrefixNamePrefixLabel,pp.NamePrefixNamePrefixLabel)
				,@NamePrefixIsActive                        = isnull(@NamePrefixIsActive,pp.NamePrefixIsActive)
				,@NamePrefixRowGUID                         = isnull(@NamePrefixRowGUID,pp.NamePrefixRowGUID)
				,@PersonGenderSID                           = isnull(@PersonGenderSID,pp.PersonGenderSID)
				,@PersonNamePrefixSID                       = isnull(@PersonNamePrefixSID,pp.PersonNamePrefixSID)
				,@PersonFirstName                           = isnull(@PersonFirstName,pp.PersonFirstName)
				,@PersonCommonName                          = isnull(@PersonCommonName,pp.PersonCommonName)
				,@PersonMiddleNames                         = isnull(@PersonMiddleNames,pp.PersonMiddleNames)
				,@PersonLastName                            = isnull(@PersonLastName,pp.PersonLastName)
				,@PersonBirthDate                           = isnull(@PersonBirthDate,pp.PersonBirthDate)
				,@PersonDeathDate                           = isnull(@PersonDeathDate,pp.PersonDeathDate)
				,@PersonHomePhone                           = isnull(@PersonHomePhone,pp.PersonHomePhone)
				,@PersonMobilePhone                         = isnull(@PersonMobilePhone,pp.PersonMobilePhone)
				,@PersonIsTextMessagingEnabled              = isnull(@PersonIsTextMessagingEnabled,pp.PersonIsTextMessagingEnabled)
				,@ImportBatch                               = isnull(@ImportBatch,pp.ImportBatch)
				,@PersonRowGUID                             = isnull(@PersonRowGUID,pp.PersonRowGUID)
				,@PersonEmailAddressPersonSID               = isnull(@PersonEmailAddressPersonSID,pp.PersonEmailAddressPersonSID)
				,@PersonEmailAddressEmailAddress            = isnull(@PersonEmailAddressEmailAddress,pp.PersonEmailAddressEmailAddress)
				,@IsPrimary                                 = isnull(@IsPrimary,pp.IsPrimary)
				,@PersonEmailAddressIsActive                = isnull(@PersonEmailAddressIsActive,pp.PersonEmailAddressIsActive)
				,@PersonEmailAddressRowGUID                 = isnull(@PersonEmailAddressRowGUID,pp.PersonEmailAddressRowGUID)
				,@IsDeleteEnabled                           = isnull(@IsDeleteEnabled,pp.IsDeleteEnabled)
			from
				stg.vPersonProfile pp
			where
				pp.PersonProfileSID = @PersonProfileSID

		end
		
		set @HomePhone    = sf.fFormatPhone(@HomePhone)												-- format phone numbers to standard
		set @MobilePhone  = sf.fFormatPhone(@MobilePhone)
		set @AddressPhone = sf.fFormatPhone(@AddressPhone)
		set @AddressFax   = sf.fFormatPhone(@AddressFax)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @GenderSCD is not null and @GenderSID = (select x.GenderSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID)
		begin
		
			select
				@GenderSID = x.GenderSID
			from
				sf.Gender x
			where
				x.GenderSCD = @GenderSCD
		
		end
		
		if @ProcessingStatusSCD is not null and @ProcessingStatusSID = (select x.ProcessingStatusSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID)
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @ApplicationUserSID
		begin
			if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'application user'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.CitySID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @CitySID
		begin
			if (select x.IsActive from dbo.City x where x.CitySID = @CitySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'city'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.CountrySID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @CountrySID
		begin
			if (select x.IsActive from dbo.Country x where x.CountrySID = @CountrySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'country'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.GenderSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @GenderSID
		begin
			if (select x.IsActive from sf.Gender x where x.GenderSID = @GenderSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'gender'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.NamePrefixSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @NamePrefixSID
		begin
			if (select x.IsActive from sf.NamePrefix x where x.NamePrefixSID = @NamePrefixSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'name prefix'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.PersonEmailAddressSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @PersonEmailAddressSID
		begin
			if (select x.IsActive from sf.PersonEmailAddress x where x.PersonEmailAddressSID = @PersonEmailAddressSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'person email address'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ProcessingStatusSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @ProcessingStatusSID
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
		
		if (select x.RegionSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @RegionSID
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
		
		if (select x.StateProvinceSID from stg.PersonProfile x where x.PersonProfileSID = @PersonProfileSID) <> @StateProvinceSID
		begin
			if (select x.IsActive from dbo.StateProvince x where x.StateProvinceSID = @StateProvinceSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'state province'
				
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
				r.RoutineName = 'stg#pPersonProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pPersonProfile
				 @Mode                                      = 'update.pre'
				,@PersonProfileSID                          = @PersonProfileSID
				,@ProcessingStatusSID                       = @ProcessingStatusSID output
				,@SourceFileName                            = @SourceFileName output
				,@LastName                                  = @LastName output
				,@FirstName                                 = @FirstName output
				,@CommonName                                = @CommonName output
				,@MiddleNames                               = @MiddleNames output
				,@EmailAddress                              = @EmailAddress output
				,@HomePhone                                 = @HomePhone output
				,@MobilePhone                               = @MobilePhone output
				,@IsTextMessagingEnabled                    = @IsTextMessagingEnabled output
				,@SignatureImage                            = @SignatureImage output
				,@IdentityPhoto                             = @IdentityPhoto output
				,@GenderCode                                = @GenderCode output
				,@GenderLabel                               = @GenderLabel output
				,@NamePrefixLabel                           = @NamePrefixLabel output
				,@BirthDate                                 = @BirthDate output
				,@DeathDate                                 = @DeathDate output
				,@UserName                                  = @UserName output
				,@SubDomain                                 = @SubDomain output
				,@Password                                  = @Password output
				,@StreetAddress1                            = @StreetAddress1 output
				,@StreetAddress2                            = @StreetAddress2 output
				,@StreetAddress3                            = @StreetAddress3 output
				,@CityName                                  = @CityName output
				,@StateProvinceName                         = @StateProvinceName output
				,@StateProvinceCode                         = @StateProvinceCode output
				,@PostalCode                                = @PostalCode output
				,@CountryName                               = @CountryName output
				,@CountryISOA3                              = @CountryISOA3 output
				,@AddressPhone                              = @AddressPhone output
				,@AddressFax                                = @AddressFax output
				,@AddressEffectiveTime                      = @AddressEffectiveTime output
				,@RegionLabel                               = @RegionLabel output
				,@RegionName                                = @RegionName output
				,@RegistrantNo                              = @RegistrantNo output
				,@ArchivedTime                              = @ArchivedTime output
				,@IsOnPublicRegistry                        = @IsOnPublicRegistry output
				,@DirectedAuditYearCompetence               = @DirectedAuditYearCompetence output
				,@DirectedAuditYearPracticeHours            = @DirectedAuditYearPracticeHours output
				,@PersonSID                                 = @PersonSID output
				,@PersonEmailAddressSID                     = @PersonEmailAddressSID output
				,@ApplicationUserSID                        = @ApplicationUserSID output
				,@PersonMailingAddressSID                   = @PersonMailingAddressSID output
				,@RegionSID                                 = @RegionSID output
				,@NamePrefixSID                             = @NamePrefixSID output
				,@GenderSID                                 = @GenderSID output
				,@CitySID                                   = @CitySID output
				,@StateProvinceSID                          = @StateProvinceSID output
				,@CountrySID                                = @CountrySID output
				,@RegistrantSID                             = @RegistrantSID output
				,@ProcessingComments                        = @ProcessingComments output
				,@UserDefinedColumns                        = @UserDefinedColumns output
				,@PersonProfileXID                          = @PersonProfileXID output
				,@LegacyKey                                 = @LegacyKey output
				,@UpdateUser                                = @UpdateUser
				,@RowStamp                                  = @RowStamp
				,@IsReselected                              = @IsReselected
				,@IsNullApplied                             = @IsNullApplied
				,@zContext                                  = @zContext
				,@ProcessingStatusSCD                       = @ProcessingStatusSCD
				,@ProcessingStatusLabel                     = @ProcessingStatusLabel
				,@IsClosedStatus                            = @IsClosedStatus
				,@ProcessingStatusIsActive                  = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault                 = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID                   = @ProcessingStatusRowGUID
				,@CityCityName                              = @CityCityName
				,@CityStateProvinceSID                      = @CityStateProvinceSID
				,@CityIsDefault                             = @CityIsDefault
				,@CityIsActive                              = @CityIsActive
				,@CityIsAdminReviewRequired                 = @CityIsAdminReviewRequired
				,@CityRowGUID                               = @CityRowGUID
				,@CountryCountryName                        = @CountryCountryName
				,@ISOA2                                     = @ISOA2
				,@ISOA3                                     = @ISOA3
				,@CountryISONumber                          = @CountryISONumber
				,@IsStateProvinceRequired                   = @IsStateProvinceRequired
				,@CountryIsDefault                          = @CountryIsDefault
				,@CountryIsActive                           = @CountryIsActive
				,@CountryRowGUID                            = @CountryRowGUID
				,@PersonMailingAddressPersonSID             = @PersonMailingAddressPersonSID
				,@PersonMailingAddressStreetAddress1        = @PersonMailingAddressStreetAddress1
				,@PersonMailingAddressStreetAddress2        = @PersonMailingAddressStreetAddress2
				,@PersonMailingAddressStreetAddress3        = @PersonMailingAddressStreetAddress3
				,@PersonMailingAddressCitySID               = @PersonMailingAddressCitySID
				,@PersonMailingAddressPostalCode            = @PersonMailingAddressPostalCode
				,@PersonMailingAddressRegionSID             = @PersonMailingAddressRegionSID
				,@EffectiveTime                             = @EffectiveTime
				,@PersonMailingAddressIsAdminReviewRequired = @PersonMailingAddressIsAdminReviewRequired
				,@LastVerifiedTime                          = @LastVerifiedTime
				,@PersonMailingAddressRowGUID               = @PersonMailingAddressRowGUID
				,@RegionRegionLabel                         = @RegionRegionLabel
				,@RegionRegionName                          = @RegionRegionName
				,@RegionIsDefault                           = @RegionIsDefault
				,@RegionIsActive                            = @RegionIsActive
				,@RegionRowGUID                             = @RegionRowGUID
				,@RegistrantPersonSID                       = @RegistrantPersonSID
				,@RegistrantRegistrantNo                    = @RegistrantRegistrantNo
				,@YearOfInitialEmployment                   = @YearOfInitialEmployment
				,@RegistrantIsOnPublicRegistry              = @RegistrantIsOnPublicRegistry
				,@CityNameOfBirth                           = @CityNameOfBirth
				,@RegistrantCountrySID                      = @RegistrantCountrySID
				,@RegistrantDirectedAuditYearCompetence     = @RegistrantDirectedAuditYearCompetence
				,@RegistrantDirectedAuditYearPracticeHours  = @RegistrantDirectedAuditYearPracticeHours
				,@LateFeeExclusionYear                      = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked              = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime                = @RenewalExtensionExpiryTime
				,@RegistrantArchivedTime                    = @RegistrantArchivedTime
				,@RegistrantRowGUID                         = @RegistrantRowGUID
				,@StateProvinceStateProvinceName            = @StateProvinceStateProvinceName
				,@StateProvinceStateProvinceCode            = @StateProvinceStateProvinceCode
				,@StateProvinceCountrySID                   = @StateProvinceCountrySID
				,@StateProvinceISONumber                    = @StateProvinceISONumber
				,@IsDisplayed                               = @IsDisplayed
				,@StateProvinceIsDefault                    = @StateProvinceIsDefault
				,@StateProvinceIsActive                     = @StateProvinceIsActive
				,@StateProvinceIsAdminReviewRequired        = @StateProvinceIsAdminReviewRequired
				,@StateProvinceRowGUID                      = @StateProvinceRowGUID
				,@ApplicationUserPersonSID                  = @ApplicationUserPersonSID
				,@CultureSID                                = @CultureSID
				,@AuthenticationAuthoritySID                = @AuthenticationAuthoritySID
				,@ApplicationUserUserName                   = @ApplicationUserUserName
				,@LastReviewTime                            = @LastReviewTime
				,@LastReviewUser                            = @LastReviewUser
				,@IsPotentialDuplicate                      = @IsPotentialDuplicate
				,@IsTemplate                                = @IsTemplate
				,@GlassBreakPassword                        = @GlassBreakPassword
				,@LastGlassBreakPasswordChangeTime          = @LastGlassBreakPasswordChangeTime
				,@ApplicationUserIsActive                   = @ApplicationUserIsActive
				,@AuthenticationSystemID                    = @AuthenticationSystemID
				,@ApplicationUserRowGUID                    = @ApplicationUserRowGUID
				,@GenderSCD                                 = @GenderSCD
				,@GenderGenderLabel                         = @GenderGenderLabel
				,@GenderIsActive                            = @GenderIsActive
				,@GenderRowGUID                             = @GenderRowGUID
				,@NamePrefixNamePrefixLabel                 = @NamePrefixNamePrefixLabel
				,@NamePrefixIsActive                        = @NamePrefixIsActive
				,@NamePrefixRowGUID                         = @NamePrefixRowGUID
				,@PersonGenderSID                           = @PersonGenderSID
				,@PersonNamePrefixSID                       = @PersonNamePrefixSID
				,@PersonFirstName                           = @PersonFirstName
				,@PersonCommonName                          = @PersonCommonName
				,@PersonMiddleNames                         = @PersonMiddleNames
				,@PersonLastName                            = @PersonLastName
				,@PersonBirthDate                           = @PersonBirthDate
				,@PersonDeathDate                           = @PersonDeathDate
				,@PersonHomePhone                           = @PersonHomePhone
				,@PersonMobilePhone                         = @PersonMobilePhone
				,@PersonIsTextMessagingEnabled              = @PersonIsTextMessagingEnabled
				,@ImportBatch                               = @ImportBatch
				,@PersonRowGUID                             = @PersonRowGUID
				,@PersonEmailAddressPersonSID               = @PersonEmailAddressPersonSID
				,@PersonEmailAddressEmailAddress            = @PersonEmailAddressEmailAddress
				,@IsPrimary                                 = @IsPrimary
				,@PersonEmailAddressIsActive                = @PersonEmailAddressIsActive
				,@PersonEmailAddressRowGUID                 = @PersonEmailAddressRowGUID
				,@IsDeleteEnabled                           = @IsDeleteEnabled
		
		end

		-- update the record

		update
			stg.PersonProfile
		set
			 ProcessingStatusSID = @ProcessingStatusSID
			,SourceFileName = @SourceFileName
			,LastName = @LastName
			,FirstName = @FirstName
			,CommonName = @CommonName
			,MiddleNames = @MiddleNames
			,EmailAddress = @EmailAddress
			,HomePhone = @HomePhone
			,MobilePhone = @MobilePhone
			,IsTextMessagingEnabled = @IsTextMessagingEnabled
			,SignatureImage = @SignatureImage
			,IdentityPhoto = @IdentityPhoto
			,GenderCode = @GenderCode
			,GenderLabel = @GenderLabel
			,NamePrefixLabel = @NamePrefixLabel
			,BirthDate = @BirthDate
			,DeathDate = @DeathDate
			,UserName = @UserName
			,SubDomain = @SubDomain
			,Password = @Password
			,StreetAddress1 = @StreetAddress1
			,StreetAddress2 = @StreetAddress2
			,StreetAddress3 = @StreetAddress3
			,CityName = @CityName
			,StateProvinceName = @StateProvinceName
			,StateProvinceCode = @StateProvinceCode
			,PostalCode = @PostalCode
			,CountryName = @CountryName
			,CountryISOA3 = @CountryISOA3
			,AddressPhone = @AddressPhone
			,AddressFax = @AddressFax
			,AddressEffectiveTime = @AddressEffectiveTime
			,RegionLabel = @RegionLabel
			,RegionName = @RegionName
			,RegistrantNo = @RegistrantNo
			,ArchivedTime = @ArchivedTime
			,IsOnPublicRegistry = @IsOnPublicRegistry
			,DirectedAuditYearCompetence = @DirectedAuditYearCompetence
			,DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
			,PersonSID = @PersonSID
			,PersonEmailAddressSID = @PersonEmailAddressSID
			,ApplicationUserSID = @ApplicationUserSID
			,PersonMailingAddressSID = @PersonMailingAddressSID
			,RegionSID = @RegionSID
			,NamePrefixSID = @NamePrefixSID
			,GenderSID = @GenderSID
			,CitySID = @CitySID
			,StateProvinceSID = @StateProvinceSID
			,CountrySID = @CountrySID
			,RegistrantSID = @RegistrantSID
			,ProcessingComments = @ProcessingComments
			,UserDefinedColumns = @UserDefinedColumns
			,PersonProfileXID = @PersonProfileXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonProfileSID = @PersonProfileSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from stg.PersonProfile where PersonProfileSID = @personProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'stg.PersonProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'stg.PersonProfile'
					,@Arg2        = @personProfileSID
				
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
				,@Arg2        = 'stg.PersonProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personProfileSID
			
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
				r.RoutineName = 'stg#pPersonProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pPersonProfile
				 @Mode                                      = 'update.post'
				,@PersonProfileSID                          = @PersonProfileSID
				,@ProcessingStatusSID                       = @ProcessingStatusSID
				,@SourceFileName                            = @SourceFileName
				,@LastName                                  = @LastName
				,@FirstName                                 = @FirstName
				,@CommonName                                = @CommonName
				,@MiddleNames                               = @MiddleNames
				,@EmailAddress                              = @EmailAddress
				,@HomePhone                                 = @HomePhone
				,@MobilePhone                               = @MobilePhone
				,@IsTextMessagingEnabled                    = @IsTextMessagingEnabled
				,@SignatureImage                            = @SignatureImage
				,@IdentityPhoto                             = @IdentityPhoto
				,@GenderCode                                = @GenderCode
				,@GenderLabel                               = @GenderLabel
				,@NamePrefixLabel                           = @NamePrefixLabel
				,@BirthDate                                 = @BirthDate
				,@DeathDate                                 = @DeathDate
				,@UserName                                  = @UserName
				,@SubDomain                                 = @SubDomain
				,@Password                                  = @Password
				,@StreetAddress1                            = @StreetAddress1
				,@StreetAddress2                            = @StreetAddress2
				,@StreetAddress3                            = @StreetAddress3
				,@CityName                                  = @CityName
				,@StateProvinceName                         = @StateProvinceName
				,@StateProvinceCode                         = @StateProvinceCode
				,@PostalCode                                = @PostalCode
				,@CountryName                               = @CountryName
				,@CountryISOA3                              = @CountryISOA3
				,@AddressPhone                              = @AddressPhone
				,@AddressFax                                = @AddressFax
				,@AddressEffectiveTime                      = @AddressEffectiveTime
				,@RegionLabel                               = @RegionLabel
				,@RegionName                                = @RegionName
				,@RegistrantNo                              = @RegistrantNo
				,@ArchivedTime                              = @ArchivedTime
				,@IsOnPublicRegistry                        = @IsOnPublicRegistry
				,@DirectedAuditYearCompetence               = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours            = @DirectedAuditYearPracticeHours
				,@PersonSID                                 = @PersonSID
				,@PersonEmailAddressSID                     = @PersonEmailAddressSID
				,@ApplicationUserSID                        = @ApplicationUserSID
				,@PersonMailingAddressSID                   = @PersonMailingAddressSID
				,@RegionSID                                 = @RegionSID
				,@NamePrefixSID                             = @NamePrefixSID
				,@GenderSID                                 = @GenderSID
				,@CitySID                                   = @CitySID
				,@StateProvinceSID                          = @StateProvinceSID
				,@CountrySID                                = @CountrySID
				,@RegistrantSID                             = @RegistrantSID
				,@ProcessingComments                        = @ProcessingComments
				,@UserDefinedColumns                        = @UserDefinedColumns
				,@PersonProfileXID                          = @PersonProfileXID
				,@LegacyKey                                 = @LegacyKey
				,@UpdateUser                                = @UpdateUser
				,@RowStamp                                  = @RowStamp
				,@IsReselected                              = @IsReselected
				,@IsNullApplied                             = @IsNullApplied
				,@zContext                                  = @zContext
				,@ProcessingStatusSCD                       = @ProcessingStatusSCD
				,@ProcessingStatusLabel                     = @ProcessingStatusLabel
				,@IsClosedStatus                            = @IsClosedStatus
				,@ProcessingStatusIsActive                  = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault                 = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID                   = @ProcessingStatusRowGUID
				,@CityCityName                              = @CityCityName
				,@CityStateProvinceSID                      = @CityStateProvinceSID
				,@CityIsDefault                             = @CityIsDefault
				,@CityIsActive                              = @CityIsActive
				,@CityIsAdminReviewRequired                 = @CityIsAdminReviewRequired
				,@CityRowGUID                               = @CityRowGUID
				,@CountryCountryName                        = @CountryCountryName
				,@ISOA2                                     = @ISOA2
				,@ISOA3                                     = @ISOA3
				,@CountryISONumber                          = @CountryISONumber
				,@IsStateProvinceRequired                   = @IsStateProvinceRequired
				,@CountryIsDefault                          = @CountryIsDefault
				,@CountryIsActive                           = @CountryIsActive
				,@CountryRowGUID                            = @CountryRowGUID
				,@PersonMailingAddressPersonSID             = @PersonMailingAddressPersonSID
				,@PersonMailingAddressStreetAddress1        = @PersonMailingAddressStreetAddress1
				,@PersonMailingAddressStreetAddress2        = @PersonMailingAddressStreetAddress2
				,@PersonMailingAddressStreetAddress3        = @PersonMailingAddressStreetAddress3
				,@PersonMailingAddressCitySID               = @PersonMailingAddressCitySID
				,@PersonMailingAddressPostalCode            = @PersonMailingAddressPostalCode
				,@PersonMailingAddressRegionSID             = @PersonMailingAddressRegionSID
				,@EffectiveTime                             = @EffectiveTime
				,@PersonMailingAddressIsAdminReviewRequired = @PersonMailingAddressIsAdminReviewRequired
				,@LastVerifiedTime                          = @LastVerifiedTime
				,@PersonMailingAddressRowGUID               = @PersonMailingAddressRowGUID
				,@RegionRegionLabel                         = @RegionRegionLabel
				,@RegionRegionName                          = @RegionRegionName
				,@RegionIsDefault                           = @RegionIsDefault
				,@RegionIsActive                            = @RegionIsActive
				,@RegionRowGUID                             = @RegionRowGUID
				,@RegistrantPersonSID                       = @RegistrantPersonSID
				,@RegistrantRegistrantNo                    = @RegistrantRegistrantNo
				,@YearOfInitialEmployment                   = @YearOfInitialEmployment
				,@RegistrantIsOnPublicRegistry              = @RegistrantIsOnPublicRegistry
				,@CityNameOfBirth                           = @CityNameOfBirth
				,@RegistrantCountrySID                      = @RegistrantCountrySID
				,@RegistrantDirectedAuditYearCompetence     = @RegistrantDirectedAuditYearCompetence
				,@RegistrantDirectedAuditYearPracticeHours  = @RegistrantDirectedAuditYearPracticeHours
				,@LateFeeExclusionYear                      = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked              = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime                = @RenewalExtensionExpiryTime
				,@RegistrantArchivedTime                    = @RegistrantArchivedTime
				,@RegistrantRowGUID                         = @RegistrantRowGUID
				,@StateProvinceStateProvinceName            = @StateProvinceStateProvinceName
				,@StateProvinceStateProvinceCode            = @StateProvinceStateProvinceCode
				,@StateProvinceCountrySID                   = @StateProvinceCountrySID
				,@StateProvinceISONumber                    = @StateProvinceISONumber
				,@IsDisplayed                               = @IsDisplayed
				,@StateProvinceIsDefault                    = @StateProvinceIsDefault
				,@StateProvinceIsActive                     = @StateProvinceIsActive
				,@StateProvinceIsAdminReviewRequired        = @StateProvinceIsAdminReviewRequired
				,@StateProvinceRowGUID                      = @StateProvinceRowGUID
				,@ApplicationUserPersonSID                  = @ApplicationUserPersonSID
				,@CultureSID                                = @CultureSID
				,@AuthenticationAuthoritySID                = @AuthenticationAuthoritySID
				,@ApplicationUserUserName                   = @ApplicationUserUserName
				,@LastReviewTime                            = @LastReviewTime
				,@LastReviewUser                            = @LastReviewUser
				,@IsPotentialDuplicate                      = @IsPotentialDuplicate
				,@IsTemplate                                = @IsTemplate
				,@GlassBreakPassword                        = @GlassBreakPassword
				,@LastGlassBreakPasswordChangeTime          = @LastGlassBreakPasswordChangeTime
				,@ApplicationUserIsActive                   = @ApplicationUserIsActive
				,@AuthenticationSystemID                    = @AuthenticationSystemID
				,@ApplicationUserRowGUID                    = @ApplicationUserRowGUID
				,@GenderSCD                                 = @GenderSCD
				,@GenderGenderLabel                         = @GenderGenderLabel
				,@GenderIsActive                            = @GenderIsActive
				,@GenderRowGUID                             = @GenderRowGUID
				,@NamePrefixNamePrefixLabel                 = @NamePrefixNamePrefixLabel
				,@NamePrefixIsActive                        = @NamePrefixIsActive
				,@NamePrefixRowGUID                         = @NamePrefixRowGUID
				,@PersonGenderSID                           = @PersonGenderSID
				,@PersonNamePrefixSID                       = @PersonNamePrefixSID
				,@PersonFirstName                           = @PersonFirstName
				,@PersonCommonName                          = @PersonCommonName
				,@PersonMiddleNames                         = @PersonMiddleNames
				,@PersonLastName                            = @PersonLastName
				,@PersonBirthDate                           = @PersonBirthDate
				,@PersonDeathDate                           = @PersonDeathDate
				,@PersonHomePhone                           = @PersonHomePhone
				,@PersonMobilePhone                         = @PersonMobilePhone
				,@PersonIsTextMessagingEnabled              = @PersonIsTextMessagingEnabled
				,@ImportBatch                               = @ImportBatch
				,@PersonRowGUID                             = @PersonRowGUID
				,@PersonEmailAddressPersonSID               = @PersonEmailAddressPersonSID
				,@PersonEmailAddressEmailAddress            = @PersonEmailAddressEmailAddress
				,@IsPrimary                                 = @IsPrimary
				,@PersonEmailAddressIsActive                = @PersonEmailAddressIsActive
				,@PersonEmailAddressRowGUID                 = @PersonEmailAddressRowGUID
				,@IsDeleteEnabled                           = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PersonProfileSID
			from
				stg.vPersonProfile ent
			where
				ent.PersonProfileSID = @PersonProfileSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonProfileSID
				,ent.ProcessingStatusSID
				,ent.SourceFileName
				,ent.LastName
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.EmailAddress
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.SignatureImage
				,ent.IdentityPhoto
				,ent.GenderCode
				,ent.GenderLabel
				,ent.NamePrefixLabel
				,ent.BirthDate
				,ent.DeathDate
				,ent.UserName
				,ent.SubDomain
				,ent.Password
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CityName
				,ent.StateProvinceName
				,ent.StateProvinceCode
				,ent.PostalCode
				,ent.CountryName
				,ent.CountryISOA3
				,ent.AddressPhone
				,ent.AddressFax
				,ent.AddressEffectiveTime
				,ent.RegionLabel
				,ent.RegionName
				,ent.RegistrantNo
				,ent.ArchivedTime
				,ent.IsOnPublicRegistry
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.PersonSID
				,ent.PersonEmailAddressSID
				,ent.ApplicationUserSID
				,ent.PersonMailingAddressSID
				,ent.RegionSID
				,ent.NamePrefixSID
				,ent.GenderSID
				,ent.CitySID
				,ent.StateProvinceSID
				,ent.CountrySID
				,ent.RegistrantSID
				,ent.ProcessingComments
				,ent.UserDefinedColumns
				,ent.PersonProfileXID
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
				,ent.CityCityName
				,ent.CityStateProvinceSID
				,ent.CityIsDefault
				,ent.CityIsActive
				,ent.CityIsAdminReviewRequired
				,ent.CityRowGUID
				,ent.CountryCountryName
				,ent.ISOA2
				,ent.ISOA3
				,ent.CountryISONumber
				,ent.IsStateProvinceRequired
				,ent.CountryIsDefault
				,ent.CountryIsActive
				,ent.CountryRowGUID
				,ent.PersonMailingAddressPersonSID
				,ent.PersonMailingAddressStreetAddress1
				,ent.PersonMailingAddressStreetAddress2
				,ent.PersonMailingAddressStreetAddress3
				,ent.PersonMailingAddressCitySID
				,ent.PersonMailingAddressPostalCode
				,ent.PersonMailingAddressRegionSID
				,ent.EffectiveTime
				,ent.PersonMailingAddressIsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.PersonMailingAddressRowGUID
				,ent.RegionRegionLabel
				,ent.RegionRegionName
				,ent.RegionIsDefault
				,ent.RegionIsActive
				,ent.RegionRowGUID
				,ent.RegistrantPersonSID
				,ent.RegistrantRegistrantNo
				,ent.YearOfInitialEmployment
				,ent.RegistrantIsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.RegistrantCountrySID
				,ent.RegistrantDirectedAuditYearCompetence
				,ent.RegistrantDirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.RegistrantArchivedTime
				,ent.RegistrantRowGUID
				,ent.StateProvinceStateProvinceName
				,ent.StateProvinceStateProvinceCode
				,ent.StateProvinceCountrySID
				,ent.StateProvinceISONumber
				,ent.IsDisplayed
				,ent.StateProvinceIsDefault
				,ent.StateProvinceIsActive
				,ent.StateProvinceIsAdminReviewRequired
				,ent.StateProvinceRowGUID
				,ent.ApplicationUserPersonSID
				,ent.CultureSID
				,ent.AuthenticationAuthoritySID
				,ent.ApplicationUserUserName
				,ent.LastReviewTime
				,ent.LastReviewUser
				,ent.IsPotentialDuplicate
				,ent.IsTemplate
				,ent.GlassBreakPassword
				,ent.LastGlassBreakPasswordChangeTime
				,ent.ApplicationUserIsActive
				,ent.AuthenticationSystemID
				,ent.ApplicationUserRowGUID
				,ent.GenderSCD
				,ent.GenderGenderLabel
				,ent.GenderIsActive
				,ent.GenderRowGUID
				,ent.NamePrefixNamePrefixLabel
				,ent.NamePrefixIsActive
				,ent.NamePrefixRowGUID
				,ent.PersonGenderSID
				,ent.PersonNamePrefixSID
				,ent.PersonFirstName
				,ent.PersonCommonName
				,ent.PersonMiddleNames
				,ent.PersonLastName
				,ent.PersonBirthDate
				,ent.PersonDeathDate
				,ent.PersonHomePhone
				,ent.PersonMobilePhone
				,ent.PersonIsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.PersonEmailAddressPersonSID
				,ent.PersonEmailAddressEmailAddress
				,ent.IsPrimary
				,ent.PersonEmailAddressIsActive
				,ent.PersonEmailAddressRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				stg.vPersonProfile ent
			where
				ent.PersonProfileSID = @PersonProfileSID

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
