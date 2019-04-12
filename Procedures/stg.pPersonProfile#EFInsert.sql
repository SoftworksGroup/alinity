SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pPersonProfile#EFInsert]
	 @ProcessingStatusSID                       int               = null		-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : stg.pPersonProfile#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonProfile#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = stg.pPersonProfile#Insert
			 @ProcessingStatusSID                       = @ProcessingStatusSID
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
