SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pPersonProfile#Insert]
	 @PersonProfileSID                          int               = null output												-- identity value assigned to the new record
	,@ProcessingStatusSID                       int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@SourceFileName                            nvarchar(100)     = null		-- required! if not passed value must be set in custom logic prior to insert
	,@LastName                                  nvarchar(35)      = null		
	,@FirstName                                 nvarchar(30)      = null		
	,@CommonName                                nvarchar(30)      = null		
	,@MiddleNames                               nvarchar(30)      = null		
	,@EmailAddress                              varchar(150)      = null		
	,@HomePhone                                 varchar(25)       = null		
	,@MobilePhone                               varchar(25)       = null		
	,@IsTextMessagingEnabled                    bit               = null		-- default: CONVERT(bit,(0))
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
	,@IsOnPublicRegistry                        bit               = null		-- default: CONVERT(bit,(1))
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
	,@CreateUser                                nvarchar(75)      = null		-- default: suser_sname()
	,@IsReselected                              tinyint           = null		-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                  xml               = null		-- other values defining context for the insert (if any)
	,@ProcessingStatusSCD                       varchar(10)       = null		-- not a base table column (default ignored)
	,@ProcessingStatusLabel                     nvarchar(35)      = null		-- not a base table column (default ignored)
	,@IsClosedStatus                            bit               = null		-- not a base table column (default ignored)
	,@ProcessingStatusIsActive                  bit               = null		-- not a base table column (default ignored)
	,@ProcessingStatusIsDefault                 bit               = null		-- not a base table column (default ignored)
	,@ProcessingStatusRowGUID                   uniqueidentifier  = null		-- not a base table column (default ignored)
	,@CityCityName                              nvarchar(30)      = null		-- not a base table column (default ignored)
	,@CityStateProvinceSID                      int               = null		-- not a base table column (default ignored)
	,@CityIsDefault                             bit               = null		-- not a base table column (default ignored)
	,@CityIsActive                              bit               = null		-- not a base table column (default ignored)
	,@CityIsAdminReviewRequired                 bit               = null		-- not a base table column (default ignored)
	,@CityRowGUID                               uniqueidentifier  = null		-- not a base table column (default ignored)
	,@CountryCountryName                        nvarchar(50)      = null		-- not a base table column (default ignored)
	,@ISOA2                                     char(2)           = null		-- not a base table column (default ignored)
	,@ISOA3                                     char(3)           = null		-- not a base table column (default ignored)
	,@CountryISONumber                          smallint          = null		-- not a base table column (default ignored)
	,@IsStateProvinceRequired                   bit               = null		-- not a base table column (default ignored)
	,@CountryIsDefault                          bit               = null		-- not a base table column (default ignored)
	,@CountryIsActive                           bit               = null		-- not a base table column (default ignored)
	,@CountryRowGUID                            uniqueidentifier  = null		-- not a base table column (default ignored)
	,@PersonMailingAddressPersonSID             int               = null		-- not a base table column (default ignored)
	,@PersonMailingAddressStreetAddress1        nvarchar(75)      = null		-- not a base table column (default ignored)
	,@PersonMailingAddressStreetAddress2        nvarchar(75)      = null		-- not a base table column (default ignored)
	,@PersonMailingAddressStreetAddress3        nvarchar(75)      = null		-- not a base table column (default ignored)
	,@PersonMailingAddressCitySID               int               = null		-- not a base table column (default ignored)
	,@PersonMailingAddressPostalCode            varchar(10)       = null		-- not a base table column (default ignored)
	,@PersonMailingAddressRegionSID             int               = null		-- not a base table column (default ignored)
	,@EffectiveTime                             datetime          = null		-- not a base table column (default ignored)
	,@PersonMailingAddressIsAdminReviewRequired bit               = null		-- not a base table column (default ignored)
	,@LastVerifiedTime                          datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@PersonMailingAddressRowGUID               uniqueidentifier  = null		-- not a base table column (default ignored)
	,@RegionRegionLabel                         nvarchar(35)      = null		-- not a base table column (default ignored)
	,@RegionRegionName                          nvarchar(50)      = null		-- not a base table column (default ignored)
	,@RegionIsDefault                           bit               = null		-- not a base table column (default ignored)
	,@RegionIsActive                            bit               = null		-- not a base table column (default ignored)
	,@RegionRowGUID                             uniqueidentifier  = null		-- not a base table column (default ignored)
	,@RegistrantPersonSID                       int               = null		-- not a base table column (default ignored)
	,@RegistrantRegistrantNo                    varchar(50)       = null		-- not a base table column (default ignored)
	,@YearOfInitialEmployment                   smallint          = null		-- not a base table column (default ignored)
	,@RegistrantIsOnPublicRegistry              bit               = null		-- not a base table column (default ignored)
	,@CityNameOfBirth                           nvarchar(30)      = null		-- not a base table column (default ignored)
	,@RegistrantCountrySID                      int               = null		-- not a base table column (default ignored)
	,@RegistrantDirectedAuditYearCompetence     smallint          = null		-- not a base table column (default ignored)
	,@RegistrantDirectedAuditYearPracticeHours  smallint          = null		-- not a base table column (default ignored)
	,@LateFeeExclusionYear                      smallint          = null		-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked              bit               = null		-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime                datetime          = null		-- not a base table column (default ignored)
	,@RegistrantArchivedTime                    datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@RegistrantRowGUID                         uniqueidentifier  = null		-- not a base table column (default ignored)
	,@StateProvinceStateProvinceName            nvarchar(30)      = null		-- not a base table column (default ignored)
	,@StateProvinceStateProvinceCode            nvarchar(5)       = null		-- not a base table column (default ignored)
	,@StateProvinceCountrySID                   int               = null		-- not a base table column (default ignored)
	,@StateProvinceISONumber                    smallint          = null		-- not a base table column (default ignored)
	,@IsDisplayed                               bit               = null		-- not a base table column (default ignored)
	,@StateProvinceIsDefault                    bit               = null		-- not a base table column (default ignored)
	,@StateProvinceIsActive                     bit               = null		-- not a base table column (default ignored)
	,@StateProvinceIsAdminReviewRequired        bit               = null		-- not a base table column (default ignored)
	,@StateProvinceRowGUID                      uniqueidentifier  = null		-- not a base table column (default ignored)
	,@ApplicationUserPersonSID                  int               = null		-- not a base table column (default ignored)
	,@CultureSID                                int               = null		-- not a base table column (default ignored)
	,@AuthenticationAuthoritySID                int               = null		-- not a base table column (default ignored)
	,@ApplicationUserUserName                   nvarchar(75)      = null		-- not a base table column (default ignored)
	,@LastReviewTime                            datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@LastReviewUser                            nvarchar(75)      = null		-- not a base table column (default ignored)
	,@IsPotentialDuplicate                      bit               = null		-- not a base table column (default ignored)
	,@IsTemplate                                bit               = null		-- not a base table column (default ignored)
	,@GlassBreakPassword                        varbinary(8000)   = null		-- not a base table column (default ignored)
	,@LastGlassBreakPasswordChangeTime          datetimeoffset(7) = null		-- not a base table column (default ignored)
	,@ApplicationUserIsActive                   bit               = null		-- not a base table column (default ignored)
	,@AuthenticationSystemID                    nvarchar(50)      = null		-- not a base table column (default ignored)
	,@ApplicationUserRowGUID                    uniqueidentifier  = null		-- not a base table column (default ignored)
	,@GenderSCD                                 char(1)           = null		-- not a base table column (default ignored)
	,@GenderGenderLabel                         nvarchar(35)      = null		-- not a base table column (default ignored)
	,@GenderIsActive                            bit               = null		-- not a base table column (default ignored)
	,@GenderRowGUID                             uniqueidentifier  = null		-- not a base table column (default ignored)
	,@NamePrefixNamePrefixLabel                 nvarchar(35)      = null		-- not a base table column (default ignored)
	,@NamePrefixIsActive                        bit               = null		-- not a base table column (default ignored)
	,@NamePrefixRowGUID                         uniqueidentifier  = null		-- not a base table column (default ignored)
	,@PersonGenderSID                           int               = null		-- not a base table column (default ignored)
	,@PersonNamePrefixSID                       int               = null		-- not a base table column (default ignored)
	,@PersonFirstName                           nvarchar(30)      = null		-- not a base table column (default ignored)
	,@PersonCommonName                          nvarchar(30)      = null		-- not a base table column (default ignored)
	,@PersonMiddleNames                         nvarchar(30)      = null		-- not a base table column (default ignored)
	,@PersonLastName                            nvarchar(35)      = null		-- not a base table column (default ignored)
	,@PersonBirthDate                           date              = null		-- not a base table column (default ignored)
	,@PersonDeathDate                           date              = null		-- not a base table column (default ignored)
	,@PersonHomePhone                           varchar(25)       = null		-- not a base table column (default ignored)
	,@PersonMobilePhone                         varchar(25)       = null		-- not a base table column (default ignored)
	,@PersonIsTextMessagingEnabled              bit               = null		-- not a base table column (default ignored)
	,@ImportBatch                               nvarchar(100)     = null		-- not a base table column (default ignored)
	,@PersonRowGUID                             uniqueidentifier  = null		-- not a base table column (default ignored)
	,@PersonEmailAddressPersonSID               int               = null		-- not a base table column (default ignored)
	,@PersonEmailAddressEmailAddress            varchar(150)      = null		-- not a base table column (default ignored)
	,@IsPrimary                                 bit               = null		-- not a base table column (default ignored)
	,@PersonEmailAddressIsActive                bit               = null		-- not a base table column (default ignored)
	,@PersonEmailAddressRowGUID                 uniqueidentifier  = null		-- not a base table column (default ignored)
	,@IsDeleteEnabled                           bit               = null		-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : stg.pPersonProfile#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the stg.PersonProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.PersonProfile table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonProfile entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonProfile procedure. The extended procedure is only called
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

	set @PersonProfileSID = null																						-- initialize output parameter

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
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsTextMessagingEnabled = isnull(@IsTextMessagingEnabled,CONVERT(bit,(0)))
		set @IsOnPublicRegistry = isnull(@IsOnPublicRegistry,CONVERT(bit,(1)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                   = isnull(@IsReselected                  ,(0))
		
		set @HomePhone    = sf.fFormatPhone(@HomePhone)												-- format phone numbers to standard
		set @MobilePhone  = sf.fFormatPhone(@MobilePhone)
		set @AddressPhone = sf.fFormatPhone(@AddressPhone)
		set @AddressFax   = sf.fFormatPhone(@AddressFax)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @GenderSCD is not null
		begin
		
			select
				@GenderSID = x.GenderSID
			from
				sf.Gender x
			where
				x.GenderSCD = @GenderSCD
		
		end
		
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
				r.RoutineName = 'stg#pPersonProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pPersonProfile
				 @Mode                                      = 'insert.pre'
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
				,@CreateUser                                = @CreateUser
				,@IsReselected                              = @IsReselected
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

		-- insert the record

		insert
			stg.PersonProfile
		(
			 ProcessingStatusSID
			,SourceFileName
			,LastName
			,FirstName
			,CommonName
			,MiddleNames
			,EmailAddress
			,HomePhone
			,MobilePhone
			,IsTextMessagingEnabled
			,SignatureImage
			,IdentityPhoto
			,GenderCode
			,GenderLabel
			,NamePrefixLabel
			,BirthDate
			,DeathDate
			,UserName
			,SubDomain
			,Password
			,StreetAddress1
			,StreetAddress2
			,StreetAddress3
			,CityName
			,StateProvinceName
			,StateProvinceCode
			,PostalCode
			,CountryName
			,CountryISOA3
			,AddressPhone
			,AddressFax
			,AddressEffectiveTime
			,RegionLabel
			,RegionName
			,RegistrantNo
			,ArchivedTime
			,IsOnPublicRegistry
			,DirectedAuditYearCompetence
			,DirectedAuditYearPracticeHours
			,PersonSID
			,PersonEmailAddressSID
			,ApplicationUserSID
			,PersonMailingAddressSID
			,RegionSID
			,NamePrefixSID
			,GenderSID
			,CitySID
			,StateProvinceSID
			,CountrySID
			,RegistrantSID
			,ProcessingComments
			,UserDefinedColumns
			,PersonProfileXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @ProcessingStatusSID
			,@SourceFileName
			,@LastName
			,@FirstName
			,@CommonName
			,@MiddleNames
			,@EmailAddress
			,@HomePhone
			,@MobilePhone
			,@IsTextMessagingEnabled
			,@SignatureImage
			,@IdentityPhoto
			,@GenderCode
			,@GenderLabel
			,@NamePrefixLabel
			,@BirthDate
			,@DeathDate
			,@UserName
			,@SubDomain
			,@Password
			,@StreetAddress1
			,@StreetAddress2
			,@StreetAddress3
			,@CityName
			,@StateProvinceName
			,@StateProvinceCode
			,@PostalCode
			,@CountryName
			,@CountryISOA3
			,@AddressPhone
			,@AddressFax
			,@AddressEffectiveTime
			,@RegionLabel
			,@RegionName
			,@RegistrantNo
			,@ArchivedTime
			,@IsOnPublicRegistry
			,@DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours
			,@PersonSID
			,@PersonEmailAddressSID
			,@ApplicationUserSID
			,@PersonMailingAddressSID
			,@RegionSID
			,@NamePrefixSID
			,@GenderSID
			,@CitySID
			,@StateProvinceSID
			,@CountrySID
			,@RegistrantSID
			,@ProcessingComments
			,@UserDefinedColumns
			,@PersonProfileXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected     = @@rowcount
			,@PersonProfileSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'stg.PersonProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonProfileSID
			
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
				r.RoutineName = 'stg#pPersonProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pPersonProfile
				 @Mode                                      = 'insert.post'
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
				,@CreateUser                                = @CreateUser
				,@IsReselected                              = @IsReselected
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
