SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantProfile#EFInsert]
	 @ImportFileSID                   int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ProcessingStatusSID             int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@LastName                        nvarchar(35)      = null							
	,@FirstName                       nvarchar(30)      = null							
	,@CommonName                      nvarchar(30)      = null							
	,@MiddleNames                     nvarchar(30)      = null							
	,@EmailAddress                    varchar(150)      = null							
	,@HomePhone                       varchar(25)       = null							
	,@MobilePhone                     varchar(25)       = null							
	,@IsTextMessagingEnabled          bit               = null							-- default: (0)
	,@GenderLabel                     nvarchar(35)      = null							
	,@NamePrefixLabel                 nvarchar(35)      = null							
	,@BirthDate                       date              = null							
	,@DeathDate                       date              = null							
	,@UserName                        nvarchar(75)      = null							
	,@SubDomain                       varchar(63)       = null							
	,@Password                        nvarchar(50)      = null							
	,@StreetAddress1                  nvarchar(75)      = null							
	,@StreetAddress2                  nvarchar(75)      = null							
	,@StreetAddress3                  nvarchar(75)      = null							
	,@CityName                        nvarchar(30)      = null							
	,@StateProvinceName               nvarchar(30)      = null							
	,@PostalCode                      varchar(10)       = null							
	,@CountryName                     nvarchar(50)      = null							
	,@RegionLabel                     nvarchar(35)      = null							
	,@RegistrantNo                    varchar(50)       = null							
	,@PersonGroupLabel1               nvarchar(35)      = null							
	,@PersonGroupTitle1               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator1     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate1       date              = null							
	,@PersonGroupExpiryDate1          date              = null							
	,@PersonGroupLabel2               nvarchar(35)      = null							
	,@PersonGroupTitle2               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator2     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate2       date              = null							
	,@PersonGroupExpiryDate2          date              = null							
	,@PersonGroupLabel3               nvarchar(35)      = null							
	,@PersonGroupTitle3               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator3     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate3       date              = null							
	,@PersonGroupExpiryDate3          date              = null							
	,@PersonGroupLabel4               nvarchar(35)      = null							
	,@PersonGroupTitle4               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator4     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate4       date              = null							
	,@PersonGroupExpiryDate4          date              = null							
	,@PersonGroupLabel5               nvarchar(35)      = null							
	,@PersonGroupTitle5               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator5     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate5       date              = null							
	,@PersonGroupExpiryDate5          date              = null							
	,@PracticeRegisterLabel           nvarchar(35)      = null							
	,@PracticeRegisterSectionLabel    nvarchar(35)      = null							
	,@RegistrationEffectiveDate       date              = null							
	,@QualifyingCredentialLabel       nvarchar(35)      = null							
	,@QualifyingCredentialOrgLabel    nvarchar(35)      = null							
	,@QualifyingProgramName           nvarchar(65)      = null							
	,@QualifyingProgramStartDate      date              = null							
	,@QualifyingProgramCompletionDate date              = null							
	,@QualifyingFieldOfStudyName      nvarchar(50)      = null							
	,@CredentialLabel1                nvarchar(35)      = null							
	,@CredentialOrgLabel1             nvarchar(35)      = null							
	,@CredentialProgramName1          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName1     nvarchar(50)      = null							
	,@CredentialEffectiveDate1        date              = null							
	,@CredentialExpiryDate1           date              = null							
	,@CredentialLabel2                nvarchar(35)      = null							
	,@CredentialOrgLabel2             nvarchar(35)      = null							
	,@CredentialProgramName2          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName2     nvarchar(50)      = null							
	,@CredentialEffectiveDate2        date              = null							
	,@CredentialExpiryDate2           date              = null							
	,@CredentialLabel3                nvarchar(35)      = null							
	,@CredentialOrgLabel3             nvarchar(35)      = null							
	,@CredentialProgramName3          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName3     nvarchar(50)      = null							
	,@CredentialEffectiveDate3        date              = null							
	,@CredentialExpiryDate3           date              = null							
	,@CredentialLabel4                nvarchar(35)      = null							
	,@CredentialOrgLabel4             nvarchar(35)      = null							
	,@CredentialProgramName4          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName4     nvarchar(50)      = null							
	,@CredentialEffectiveDate4        date              = null							
	,@CredentialExpiryDate4           date              = null							
	,@CredentialLabel5                nvarchar(35)      = null							
	,@CredentialOrgLabel5             nvarchar(35)      = null							
	,@CredentialProgramName5          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName5     nvarchar(50)      = null							
	,@CredentialEffectiveDate5        date              = null							
	,@CredentialExpiryDate5           date              = null							
	,@CredentialLabel6                nvarchar(35)      = null							
	,@CredentialOrgLabel6             nvarchar(35)      = null							
	,@CredentialProgramName6          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName6     nvarchar(50)      = null							
	,@CredentialEffectiveDate6        date              = null							
	,@CredentialExpiryDate6           date              = null							
	,@CredentialLabel7                nvarchar(35)      = null							
	,@CredentialOrgLabel7             nvarchar(35)      = null							
	,@CredentialProgramName7          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName7     nvarchar(50)      = null							
	,@CredentialEffectiveDate7        date              = null							
	,@CredentialExpiryDate7           date              = null							
	,@CredentialLabel8                nvarchar(35)      = null							
	,@CredentialOrgLabel8             nvarchar(35)      = null							
	,@CredentialProgramName8          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName8     nvarchar(50)      = null							
	,@CredentialEffectiveDate8        date              = null							
	,@CredentialExpiryDate8           date              = null							
	,@CredentialLabel9                nvarchar(35)      = null							
	,@CredentialOrgLabel9             nvarchar(35)      = null							
	,@CredentialProgramName9          nvarchar(65)      = null							
	,@CredentialFieldOfStudyName9     nvarchar(50)      = null							
	,@CredentialEffectiveDate9        date              = null							
	,@CredentialExpiryDate9           date              = null							
	,@PersonSID                       int               = null							
	,@PersonEmailAddressSID           int               = null							
	,@ApplicationUserSID              int               = null							
	,@PersonMailingAddressSID         int               = null							
	,@RegionSID                       int               = null							
	,@NamePrefixSID                   int               = null							
	,@GenderSID                       int               = null							
	,@CitySID                         int               = null							
	,@StateProvinceSID                int               = null							
	,@CountrySID                      int               = null							
	,@RegistrantSID                   int               = null							
	,@ProcessingComments              nvarchar(max)     = null							
	,@UserDefinedColumns              xml               = null							
	,@RegistrantProfileXID            varchar(150)      = null							
	,@LegacyKey                       nvarchar(50)      = null							
	,@CreateUser                      nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                    tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                        xml               = null							-- other values defining context for the insert (if any)
	,@FileFormatSID                   int               = null							-- not a base table column (default ignored)
	,@ApplicationEntitySID            int               = null							-- not a base table column (default ignored)
	,@FileName                        nvarchar(100)     = null							-- not a base table column (default ignored)
	,@LoadStartTime                   datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LoadEndTime                     datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@IsFailed                        bit               = null							-- not a base table column (default ignored)
	,@MessageText                     nvarchar(4000)    = null							-- not a base table column (default ignored)
	,@ImportFileRowGUID               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ProcessingStatusSCD             varchar(10)       = null							-- not a base table column (default ignored)
	,@ProcessingStatusLabel           nvarchar(35)      = null							-- not a base table column (default ignored)
	,@IsClosedStatus                  bit               = null							-- not a base table column (default ignored)
	,@ProcessingStatusIsActive        bit               = null							-- not a base table column (default ignored)
	,@ProcessingStatusIsDefault       bit               = null							-- not a base table column (default ignored)
	,@ProcessingStatusRowGUID         uniqueidentifier  = null							-- not a base table column (default ignored)
	,@PersonEmailAddressPersonSID     int               = null							-- not a base table column (default ignored)
	,@PersonEmailAddressEmailAddress  varchar(150)      = null							-- not a base table column (default ignored)
	,@IsPrimary                       bit               = null							-- not a base table column (default ignored)
	,@PersonEmailAddressIsActive      bit               = null							-- not a base table column (default ignored)
	,@PersonEmailAddressRowGUID       uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                 bit               = null							-- not a base table column (default ignored)
	,@RegistrantLabel                 nvarchar(75)      = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantProfile#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantProfile#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = stg.pRegistrantProfile#Insert
			 @ImportFileSID                   = @ImportFileSID
			,@ProcessingStatusSID             = @ProcessingStatusSID
			,@LastName                        = @LastName
			,@FirstName                       = @FirstName
			,@CommonName                      = @CommonName
			,@MiddleNames                     = @MiddleNames
			,@EmailAddress                    = @EmailAddress
			,@HomePhone                       = @HomePhone
			,@MobilePhone                     = @MobilePhone
			,@IsTextMessagingEnabled          = @IsTextMessagingEnabled
			,@GenderLabel                     = @GenderLabel
			,@NamePrefixLabel                 = @NamePrefixLabel
			,@BirthDate                       = @BirthDate
			,@DeathDate                       = @DeathDate
			,@UserName                        = @UserName
			,@SubDomain                       = @SubDomain
			,@Password                        = @Password
			,@StreetAddress1                  = @StreetAddress1
			,@StreetAddress2                  = @StreetAddress2
			,@StreetAddress3                  = @StreetAddress3
			,@CityName                        = @CityName
			,@StateProvinceName               = @StateProvinceName
			,@PostalCode                      = @PostalCode
			,@CountryName                     = @CountryName
			,@RegionLabel                     = @RegionLabel
			,@RegistrantNo                    = @RegistrantNo
			,@PersonGroupLabel1               = @PersonGroupLabel1
			,@PersonGroupTitle1               = @PersonGroupTitle1
			,@PersonGroupIsAdministrator1     = @PersonGroupIsAdministrator1
			,@PersonGroupEffectiveDate1       = @PersonGroupEffectiveDate1
			,@PersonGroupExpiryDate1          = @PersonGroupExpiryDate1
			,@PersonGroupLabel2               = @PersonGroupLabel2
			,@PersonGroupTitle2               = @PersonGroupTitle2
			,@PersonGroupIsAdministrator2     = @PersonGroupIsAdministrator2
			,@PersonGroupEffectiveDate2       = @PersonGroupEffectiveDate2
			,@PersonGroupExpiryDate2          = @PersonGroupExpiryDate2
			,@PersonGroupLabel3               = @PersonGroupLabel3
			,@PersonGroupTitle3               = @PersonGroupTitle3
			,@PersonGroupIsAdministrator3     = @PersonGroupIsAdministrator3
			,@PersonGroupEffectiveDate3       = @PersonGroupEffectiveDate3
			,@PersonGroupExpiryDate3          = @PersonGroupExpiryDate3
			,@PersonGroupLabel4               = @PersonGroupLabel4
			,@PersonGroupTitle4               = @PersonGroupTitle4
			,@PersonGroupIsAdministrator4     = @PersonGroupIsAdministrator4
			,@PersonGroupEffectiveDate4       = @PersonGroupEffectiveDate4
			,@PersonGroupExpiryDate4          = @PersonGroupExpiryDate4
			,@PersonGroupLabel5               = @PersonGroupLabel5
			,@PersonGroupTitle5               = @PersonGroupTitle5
			,@PersonGroupIsAdministrator5     = @PersonGroupIsAdministrator5
			,@PersonGroupEffectiveDate5       = @PersonGroupEffectiveDate5
			,@PersonGroupExpiryDate5          = @PersonGroupExpiryDate5
			,@PracticeRegisterLabel           = @PracticeRegisterLabel
			,@PracticeRegisterSectionLabel    = @PracticeRegisterSectionLabel
			,@RegistrationEffectiveDate       = @RegistrationEffectiveDate
			,@QualifyingCredentialLabel       = @QualifyingCredentialLabel
			,@QualifyingCredentialOrgLabel    = @QualifyingCredentialOrgLabel
			,@QualifyingProgramName           = @QualifyingProgramName
			,@QualifyingProgramStartDate      = @QualifyingProgramStartDate
			,@QualifyingProgramCompletionDate = @QualifyingProgramCompletionDate
			,@QualifyingFieldOfStudyName      = @QualifyingFieldOfStudyName
			,@CredentialLabel1                = @CredentialLabel1
			,@CredentialOrgLabel1             = @CredentialOrgLabel1
			,@CredentialProgramName1          = @CredentialProgramName1
			,@CredentialFieldOfStudyName1     = @CredentialFieldOfStudyName1
			,@CredentialEffectiveDate1        = @CredentialEffectiveDate1
			,@CredentialExpiryDate1           = @CredentialExpiryDate1
			,@CredentialLabel2                = @CredentialLabel2
			,@CredentialOrgLabel2             = @CredentialOrgLabel2
			,@CredentialProgramName2          = @CredentialProgramName2
			,@CredentialFieldOfStudyName2     = @CredentialFieldOfStudyName2
			,@CredentialEffectiveDate2        = @CredentialEffectiveDate2
			,@CredentialExpiryDate2           = @CredentialExpiryDate2
			,@CredentialLabel3                = @CredentialLabel3
			,@CredentialOrgLabel3             = @CredentialOrgLabel3
			,@CredentialProgramName3          = @CredentialProgramName3
			,@CredentialFieldOfStudyName3     = @CredentialFieldOfStudyName3
			,@CredentialEffectiveDate3        = @CredentialEffectiveDate3
			,@CredentialExpiryDate3           = @CredentialExpiryDate3
			,@CredentialLabel4                = @CredentialLabel4
			,@CredentialOrgLabel4             = @CredentialOrgLabel4
			,@CredentialProgramName4          = @CredentialProgramName4
			,@CredentialFieldOfStudyName4     = @CredentialFieldOfStudyName4
			,@CredentialEffectiveDate4        = @CredentialEffectiveDate4
			,@CredentialExpiryDate4           = @CredentialExpiryDate4
			,@CredentialLabel5                = @CredentialLabel5
			,@CredentialOrgLabel5             = @CredentialOrgLabel5
			,@CredentialProgramName5          = @CredentialProgramName5
			,@CredentialFieldOfStudyName5     = @CredentialFieldOfStudyName5
			,@CredentialEffectiveDate5        = @CredentialEffectiveDate5
			,@CredentialExpiryDate5           = @CredentialExpiryDate5
			,@CredentialLabel6                = @CredentialLabel6
			,@CredentialOrgLabel6             = @CredentialOrgLabel6
			,@CredentialProgramName6          = @CredentialProgramName6
			,@CredentialFieldOfStudyName6     = @CredentialFieldOfStudyName6
			,@CredentialEffectiveDate6        = @CredentialEffectiveDate6
			,@CredentialExpiryDate6           = @CredentialExpiryDate6
			,@CredentialLabel7                = @CredentialLabel7
			,@CredentialOrgLabel7             = @CredentialOrgLabel7
			,@CredentialProgramName7          = @CredentialProgramName7
			,@CredentialFieldOfStudyName7     = @CredentialFieldOfStudyName7
			,@CredentialEffectiveDate7        = @CredentialEffectiveDate7
			,@CredentialExpiryDate7           = @CredentialExpiryDate7
			,@CredentialLabel8                = @CredentialLabel8
			,@CredentialOrgLabel8             = @CredentialOrgLabel8
			,@CredentialProgramName8          = @CredentialProgramName8
			,@CredentialFieldOfStudyName8     = @CredentialFieldOfStudyName8
			,@CredentialEffectiveDate8        = @CredentialEffectiveDate8
			,@CredentialExpiryDate8           = @CredentialExpiryDate8
			,@CredentialLabel9                = @CredentialLabel9
			,@CredentialOrgLabel9             = @CredentialOrgLabel9
			,@CredentialProgramName9          = @CredentialProgramName9
			,@CredentialFieldOfStudyName9     = @CredentialFieldOfStudyName9
			,@CredentialEffectiveDate9        = @CredentialEffectiveDate9
			,@CredentialExpiryDate9           = @CredentialExpiryDate9
			,@PersonSID                       = @PersonSID
			,@PersonEmailAddressSID           = @PersonEmailAddressSID
			,@ApplicationUserSID              = @ApplicationUserSID
			,@PersonMailingAddressSID         = @PersonMailingAddressSID
			,@RegionSID                       = @RegionSID
			,@NamePrefixSID                   = @NamePrefixSID
			,@GenderSID                       = @GenderSID
			,@CitySID                         = @CitySID
			,@StateProvinceSID                = @StateProvinceSID
			,@CountrySID                      = @CountrySID
			,@RegistrantSID                   = @RegistrantSID
			,@ProcessingComments              = @ProcessingComments
			,@UserDefinedColumns              = @UserDefinedColumns
			,@RegistrantProfileXID            = @RegistrantProfileXID
			,@LegacyKey                       = @LegacyKey
			,@CreateUser                      = @CreateUser
			,@IsReselected                    = @IsReselected
			,@zContext                        = @zContext
			,@FileFormatSID                   = @FileFormatSID
			,@ApplicationEntitySID            = @ApplicationEntitySID
			,@FileName                        = @FileName
			,@LoadStartTime                   = @LoadStartTime
			,@LoadEndTime                     = @LoadEndTime
			,@IsFailed                        = @IsFailed
			,@MessageText                     = @MessageText
			,@ImportFileRowGUID               = @ImportFileRowGUID
			,@ProcessingStatusSCD             = @ProcessingStatusSCD
			,@ProcessingStatusLabel           = @ProcessingStatusLabel
			,@IsClosedStatus                  = @IsClosedStatus
			,@ProcessingStatusIsActive        = @ProcessingStatusIsActive
			,@ProcessingStatusIsDefault       = @ProcessingStatusIsDefault
			,@ProcessingStatusRowGUID         = @ProcessingStatusRowGUID
			,@PersonEmailAddressPersonSID     = @PersonEmailAddressPersonSID
			,@PersonEmailAddressEmailAddress  = @PersonEmailAddressEmailAddress
			,@IsPrimary                       = @IsPrimary
			,@PersonEmailAddressIsActive      = @PersonEmailAddressIsActive
			,@PersonEmailAddressRowGUID       = @PersonEmailAddressRowGUID
			,@IsDeleteEnabled                 = @IsDeleteEnabled
			,@RegistrantLabel                 = @RegistrantLabel

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
