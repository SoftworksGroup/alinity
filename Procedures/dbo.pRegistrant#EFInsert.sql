SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrant#EFInsert]
	 @PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrantNo                   varchar(50)       = null								-- required! if not passed value must be set in custom logic prior to insert
	,@YearOfInitialEmployment        smallint          = null								
	,@IsOnPublicRegistry             bit               = null								-- default: CONVERT(bit,(1))
	,@CityNameOfBirth                nvarchar(30)      = null								
	,@CountrySID                     int               = null								
	,@DirectedAuditYearCompetence    smallint          = null								
	,@DirectedAuditYearPracticeHours smallint          = null								
	,@LateFeeExclusionYear           smallint          = null								
	,@IsRenewalAutoApprovalBlocked   bit               = null								-- default: CONVERT(bit,(0))
	,@RenewalExtensionExpiryTime     datetime          = null								
	,@PublicDirectoryComment         nvarchar(max)     = null								
	,@ArchivedTime                   datetimeoffset(7) = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantXID                  varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@GenderSID                      int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                  int               = null								-- not a base table column (default ignored)
	,@FirstName                      nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                      date              = null								-- not a base table column (default ignored)
	,@DeathDate                      date              = null								-- not a base table column (default ignored)
	,@HomePhone                      varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled         bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                    nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@CountryName                    nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ISOA2                          char(2)           = null								-- not a base table column (default ignored)
	,@ISOA3                          char(3)           = null								-- not a base table column (default ignored)
	,@ISONumber                      smallint          = null								-- not a base table column (default ignored)
	,@IsStateProvinceRequired        bit               = null								-- not a base table column (default ignored)
	,@CountryIsDefault               bit               = null								-- not a base table column (default ignored)
	,@CountryIsActive                bit               = null								-- not a base table column (default ignored)
	,@CountryRowGUID                 uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@RegistrantLabel                nvarchar(75)      = null								-- not a base table column (default ignored)
	,@FileAsName                     nvarchar(65)      = null								-- not a base table column (default ignored)
	,@DisplayName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@RegistrationSID                int               = null								-- not a base table column (default ignored)
	,@RegistrationNo                 nvarchar(50)      = null								-- not a base table column (default ignored)
	,@PracticeRegisterSID            int               = null								-- not a base table column (default ignored)
	,@PracticeRegisterSectionSID     int               = null								-- not a base table column (default ignored)
	,@EffectiveTime                  datetime          = null								-- not a base table column (default ignored)
	,@ExpiryTime                     datetime          = null								-- not a base table column (default ignored)
	,@PracticeRegisterName           nvarchar(65)      = null								-- not a base table column (default ignored)
	,@PracticeRegisterLabel          nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsActivePractice               bit               = null								-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel   nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsSectionDisplayedOnLicense    bit               = null								-- not a base table column (default ignored)
	,@LicenseRegistrationYear        smallint          = null								-- not a base table column (default ignored)
	,@RenewalRegistrationYear        smallint          = null								-- not a base table column (default ignored)
	,@HasOpenAudit                   bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrant#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrant#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrant#Insert
			 @PersonSID                      = @PersonSID
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
			,@PublicDirectoryComment         = @PublicDirectoryComment
			,@ArchivedTime                   = @ArchivedTime
			,@UserDefinedColumns             = @UserDefinedColumns
			,@RegistrantXID                  = @RegistrantXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@GenderSID                      = @GenderSID
			,@NamePrefixSID                  = @NamePrefixSID
			,@FirstName                      = @FirstName
			,@CommonName                     = @CommonName
			,@MiddleNames                    = @MiddleNames
			,@LastName                       = @LastName
			,@BirthDate                      = @BirthDate
			,@DeathDate                      = @DeathDate
			,@HomePhone                      = @HomePhone
			,@MobilePhone                    = @MobilePhone
			,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
			,@ImportBatch                    = @ImportBatch
			,@PersonRowGUID                  = @PersonRowGUID
			,@CountryName                    = @CountryName
			,@ISOA2                          = @ISOA2
			,@ISOA3                          = @ISOA3
			,@ISONumber                      = @ISONumber
			,@IsStateProvinceRequired        = @IsStateProvinceRequired
			,@CountryIsDefault               = @CountryIsDefault
			,@CountryIsActive                = @CountryIsActive
			,@CountryRowGUID                 = @CountryRowGUID
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@RegistrantLabel                = @RegistrantLabel
			,@FileAsName                     = @FileAsName
			,@DisplayName                    = @DisplayName
			,@EmailAddress                   = @EmailAddress
			,@RegistrationSID                = @RegistrationSID
			,@RegistrationNo                 = @RegistrationNo
			,@PracticeRegisterSID            = @PracticeRegisterSID
			,@PracticeRegisterSectionSID     = @PracticeRegisterSectionSID
			,@EffectiveTime                  = @EffectiveTime
			,@ExpiryTime                     = @ExpiryTime
			,@PracticeRegisterName           = @PracticeRegisterName
			,@PracticeRegisterLabel          = @PracticeRegisterLabel
			,@IsActivePractice               = @IsActivePractice
			,@PracticeRegisterSectionLabel   = @PracticeRegisterSectionLabel
			,@IsSectionDisplayedOnLicense    = @IsSectionDisplayedOnLicense
			,@LicenseRegistrationYear        = @LicenseRegistrationYear
			,@RenewalRegistrationYear        = @RenewalRegistrationYear
			,@HasOpenAudit                   = @HasOpenAudit

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
