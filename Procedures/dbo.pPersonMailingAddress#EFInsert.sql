SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonMailingAddress#EFInsert]
	 @PersonSID                 int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@StreetAddress1            nvarchar(75)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@StreetAddress2            nvarchar(75)      = null										
	,@StreetAddress3            nvarchar(75)      = null										
	,@CitySID                   int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@PostalCode                varchar(10)       = null										
	,@RegionSID                 int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime             datetime          = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsAdminReviewRequired     bit               = null										-- default: CONVERT(bit,(0))
	,@LastVerifiedTime          datetimeoffset(7) = null										
	,@ChangeLog                 xml               = null										-- default: CONVERT(xml,'<Changes />')
	,@UserDefinedColumns        xml               = null										
	,@PersonMailingAddressXID   varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@CityName                  nvarchar(30)      = null										-- not a base table column (default ignored)
	,@StateProvinceSID          int               = null										-- not a base table column (default ignored)
	,@CityIsDefault             bit               = null										-- not a base table column (default ignored)
	,@CityIsActive              bit               = null										-- not a base table column (default ignored)
	,@CityIsAdminReviewRequired bit               = null										-- not a base table column (default ignored)
	,@CityRowGUID               uniqueidentifier  = null										-- not a base table column (default ignored)
	,@RegionLabel               nvarchar(35)      = null										-- not a base table column (default ignored)
	,@RegionName                nvarchar(50)      = null										-- not a base table column (default ignored)
	,@RegionIsDefault           bit               = null										-- not a base table column (default ignored)
	,@RegionIsActive            bit               = null										-- not a base table column (default ignored)
	,@RegionRowGUID             uniqueidentifier  = null										-- not a base table column (default ignored)
	,@GenderSID                 int               = null										-- not a base table column (default ignored)
	,@NamePrefixSID             int               = null										-- not a base table column (default ignored)
	,@FirstName                 nvarchar(30)      = null										-- not a base table column (default ignored)
	,@CommonName                nvarchar(30)      = null										-- not a base table column (default ignored)
	,@MiddleNames               nvarchar(30)      = null										-- not a base table column (default ignored)
	,@LastName                  nvarchar(35)      = null										-- not a base table column (default ignored)
	,@BirthDate                 date              = null										-- not a base table column (default ignored)
	,@DeathDate                 date              = null										-- not a base table column (default ignored)
	,@HomePhone                 varchar(25)       = null										-- not a base table column (default ignored)
	,@MobilePhone               varchar(25)       = null										-- not a base table column (default ignored)
	,@IsTextMessagingEnabled    bit               = null										-- not a base table column (default ignored)
	,@ImportBatch               nvarchar(100)     = null										-- not a base table column (default ignored)
	,@PersonRowGUID             uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
	,@HtmlAddress               nvarchar(512)     = null										-- not a base table column (default ignored)
	,@StateProvinceCode         nvarchar(5)       = null										-- not a base table column (default ignored)
	,@StateProvinceName         nvarchar(30)      = null										-- not a base table column (default ignored)
	,@ISOA3                     char(3)           = null										-- not a base table column (default ignored)
	,@CountryName               nvarchar(50)      = null										-- not a base table column (default ignored)
	,@IsCurrentAddress          bit               = null										-- not a base table column (default ignored)
	,@CountrySID                int               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonMailingAddress#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonMailingAddress#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pPersonMailingAddress#Insert
			 @PersonSID                 = @PersonSID
			,@StreetAddress1            = @StreetAddress1
			,@StreetAddress2            = @StreetAddress2
			,@StreetAddress3            = @StreetAddress3
			,@CitySID                   = @CitySID
			,@PostalCode                = @PostalCode
			,@RegionSID                 = @RegionSID
			,@EffectiveTime             = @EffectiveTime
			,@IsAdminReviewRequired     = @IsAdminReviewRequired
			,@LastVerifiedTime          = @LastVerifiedTime
			,@ChangeLog                 = @ChangeLog
			,@UserDefinedColumns        = @UserDefinedColumns
			,@PersonMailingAddressXID   = @PersonMailingAddressXID
			,@LegacyKey                 = @LegacyKey
			,@CreateUser                = @CreateUser
			,@IsReselected              = @IsReselected
			,@zContext                  = @zContext
			,@CityName                  = @CityName
			,@StateProvinceSID          = @StateProvinceSID
			,@CityIsDefault             = @CityIsDefault
			,@CityIsActive              = @CityIsActive
			,@CityIsAdminReviewRequired = @CityIsAdminReviewRequired
			,@CityRowGUID               = @CityRowGUID
			,@RegionLabel               = @RegionLabel
			,@RegionName                = @RegionName
			,@RegionIsDefault           = @RegionIsDefault
			,@RegionIsActive            = @RegionIsActive
			,@RegionRowGUID             = @RegionRowGUID
			,@GenderSID                 = @GenderSID
			,@NamePrefixSID             = @NamePrefixSID
			,@FirstName                 = @FirstName
			,@CommonName                = @CommonName
			,@MiddleNames               = @MiddleNames
			,@LastName                  = @LastName
			,@BirthDate                 = @BirthDate
			,@DeathDate                 = @DeathDate
			,@HomePhone                 = @HomePhone
			,@MobilePhone               = @MobilePhone
			,@IsTextMessagingEnabled    = @IsTextMessagingEnabled
			,@ImportBatch               = @ImportBatch
			,@PersonRowGUID             = @PersonRowGUID
			,@IsDeleteEnabled           = @IsDeleteEnabled
			,@HtmlAddress               = @HtmlAddress
			,@StateProvinceCode         = @StateProvinceCode
			,@StateProvinceName         = @StateProvinceName
			,@ISOA3                     = @ISOA3
			,@CountryName               = @CountryName
			,@IsCurrentAddress          = @IsCurrentAddress
			,@CountrySID                = @CountrySID

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
