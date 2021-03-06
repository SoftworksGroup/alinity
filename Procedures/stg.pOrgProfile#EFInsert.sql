SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pOrgProfile#EFInsert]
	 @ProcessingStatusSID       int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@SourceFileName            nvarchar(150)     = null										-- required! if not passed value must be set in custom logic prior to insert
	,@OrgName                   nvarchar(150)     = null										
	,@OrgLabel                  nvarchar(35)      = null										
	,@EmailAddress              varchar(150)      = null										
	,@StreetAddress1            nvarchar(75)      = null										
	,@StreetAddress2            nvarchar(75)      = null										
	,@StreetAddress3            nvarchar(75)      = null										
	,@CityName                  nvarchar(30)      = null										
	,@StateProvinceName         nvarchar(30)      = null										
	,@PostalCode                varchar(10)       = null										
	,@CountryName               nvarchar(50)      = null										
	,@RegionName                nvarchar(50)      = null										
	,@Phone                     varchar(25)       = null										
	,@Fax                       varchar(25)       = null										
	,@WebSite                   varchar(250)      = null										
	,@Comments                  nvarchar(max)     = null										
	,@LastVerifiedTime          datetimeoffset(7) = null										
	,@IsEmployer                bit               = null										-- default: CONVERT(bit,(0))
	,@IsEducationInstitution    bit               = null										-- default: CONVERT(bit,(0))
	,@IsActive                  bit               = null										-- default: (1)
	,@ParentOrgProfileSID       int               = null										
	,@CitySID                   int               = null										
	,@StateProvinceSID          int               = null										
	,@CountrySID                int               = null										
	,@RegionSID                 int               = null										
	,@ProcessingComments        nvarchar(max)     = null										
	,@UserDefinedColumns        xml               = null										
	,@OrgProfileXID             varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@ProcessingStatusSCD       varchar(10)       = null										-- not a base table column (default ignored)
	,@ProcessingStatusLabel     nvarchar(35)      = null										-- not a base table column (default ignored)
	,@IsClosedStatus            bit               = null										-- not a base table column (default ignored)
	,@ProcessingStatusIsActive  bit               = null										-- not a base table column (default ignored)
	,@ProcessingStatusIsDefault bit               = null										-- not a base table column (default ignored)
	,@ProcessingStatusRowGUID   uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : stg.pOrgProfile#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pOrgProfile#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = stg.pOrgProfile#Insert
			 @ProcessingStatusSID       = @ProcessingStatusSID
			,@SourceFileName            = @SourceFileName
			,@OrgName                   = @OrgName
			,@OrgLabel                  = @OrgLabel
			,@EmailAddress              = @EmailAddress
			,@StreetAddress1            = @StreetAddress1
			,@StreetAddress2            = @StreetAddress2
			,@StreetAddress3            = @StreetAddress3
			,@CityName                  = @CityName
			,@StateProvinceName         = @StateProvinceName
			,@PostalCode                = @PostalCode
			,@CountryName               = @CountryName
			,@RegionName                = @RegionName
			,@Phone                     = @Phone
			,@Fax                       = @Fax
			,@WebSite                   = @WebSite
			,@Comments                  = @Comments
			,@LastVerifiedTime          = @LastVerifiedTime
			,@IsEmployer                = @IsEmployer
			,@IsEducationInstitution    = @IsEducationInstitution
			,@IsActive                  = @IsActive
			,@ParentOrgProfileSID       = @ParentOrgProfileSID
			,@CitySID                   = @CitySID
			,@StateProvinceSID          = @StateProvinceSID
			,@CountrySID                = @CountrySID
			,@RegionSID                 = @RegionSID
			,@ProcessingComments        = @ProcessingComments
			,@UserDefinedColumns        = @UserDefinedColumns
			,@OrgProfileXID             = @OrgProfileXID
			,@LegacyKey                 = @LegacyKey
			,@CreateUser                = @CreateUser
			,@IsReselected              = @IsReselected
			,@zContext                  = @zContext
			,@ProcessingStatusSCD       = @ProcessingStatusSCD
			,@ProcessingStatusLabel     = @ProcessingStatusLabel
			,@IsClosedStatus            = @IsClosedStatus
			,@ProcessingStatusIsActive  = @ProcessingStatusIsActive
			,@ProcessingStatusIsDefault = @ProcessingStatusIsDefault
			,@ProcessingStatusRowGUID   = @ProcessingStatusRowGUID
			,@IsDeleteEnabled           = @IsDeleteEnabled

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
