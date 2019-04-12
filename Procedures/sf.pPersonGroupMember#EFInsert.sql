SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroupMember#EFInsert]
	 @PersonGroupSID                 int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@Title                          nvarchar(75)      = null								
	,@IsAdministrator                bit               = null								-- default: CONVERT(bit,(0))
	,@IsContributor                  bit               = null								-- default: CONVERT(bit,(1))
	,@EffectiveTime                  datetime          = null								-- default: sf.fNow()
	,@ExpiryTime                     datetime          = null								
	,@IsReplacementRequiredAfterTerm bit               = null								-- default: CONVERT(bit,(0))
	,@ReplacementClearedDate         date              = null								
	,@UserDefinedColumns             xml               = null								
	,@PersonGroupMemberXID           varchar(150)      = null								
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
	,@PersonGroupName                nvarchar(65)      = null								-- not a base table column (default ignored)
	,@PersonGroupLabel               nvarchar(35)      = null								-- not a base table column (default ignored)
	,@PersonGroupCategory            nvarchar(65)      = null								-- not a base table column (default ignored)
	,@Description                    nvarchar(500)     = null								-- not a base table column (default ignored)
	,@ApplicationUserSID             int               = null								-- not a base table column (default ignored)
	,@IsPreference                   bit               = null								-- not a base table column (default ignored)
	,@IsDocumentLibraryEnabled       bit               = null								-- not a base table column (default ignored)
	,@QuerySID                       int               = null								-- not a base table column (default ignored)
	,@LastReviewUser                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@LastReviewTime                 datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@SmartGroupCount                int               = null								-- not a base table column (default ignored)
	,@SmartGroupCountTime            datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@PersonGroupIsActive            bit               = null								-- not a base table column (default ignored)
	,@PersonGroupRowGUID             uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsActive                       bit               = null								-- not a base table column (default ignored)
	,@IsPending                      bit               = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@DisplayName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@PhoneNumber                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTermExpired                  bit               = null								-- not a base table column (default ignored)
	,@TermLabel                      nvarchar(4000)    = null								-- not a base table column (default ignored)
	,@IsReplacementRequired          bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroupMember#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonGroupMember#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
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

		exec @errorNo = sf.pPersonGroupMember#Insert
			 @PersonGroupSID                 = @PersonGroupSID
			,@PersonSID                      = @PersonSID
			,@Title                          = @Title
			,@IsAdministrator                = @IsAdministrator
			,@IsContributor                  = @IsContributor
			,@EffectiveTime                  = @EffectiveTime
			,@ExpiryTime                     = @ExpiryTime
			,@IsReplacementRequiredAfterTerm = @IsReplacementRequiredAfterTerm
			,@ReplacementClearedDate         = @ReplacementClearedDate
			,@UserDefinedColumns             = @UserDefinedColumns
			,@PersonGroupMemberXID           = @PersonGroupMemberXID
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
			,@PersonGroupName                = @PersonGroupName
			,@PersonGroupLabel               = @PersonGroupLabel
			,@PersonGroupCategory            = @PersonGroupCategory
			,@Description                    = @Description
			,@ApplicationUserSID             = @ApplicationUserSID
			,@IsPreference                   = @IsPreference
			,@IsDocumentLibraryEnabled       = @IsDocumentLibraryEnabled
			,@QuerySID                       = @QuerySID
			,@LastReviewUser                 = @LastReviewUser
			,@LastReviewTime                 = @LastReviewTime
			,@SmartGroupCount                = @SmartGroupCount
			,@SmartGroupCountTime            = @SmartGroupCountTime
			,@PersonGroupIsActive            = @PersonGroupIsActive
			,@PersonGroupRowGUID             = @PersonGroupRowGUID
			,@IsActive                       = @IsActive
			,@IsPending                      = @IsPending
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@DisplayName                    = @DisplayName
			,@EmailAddress                   = @EmailAddress
			,@PhoneNumber                    = @PhoneNumber
			,@IsTermExpired                  = @IsTermExpired
			,@TermLabel                      = @TermLabel
			,@IsReplacementRequired          = @IsReplacementRequired

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
