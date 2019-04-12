SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pForm#EFInsert]
	 @FormTypeSID                      int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormName                         nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormLabel                        nvarchar(35)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormContext                      varchar(25)       = null							
	,@AuthorCredit                     nvarchar(500)     = null							-- default: (('Anonymous Work'+char((13)))+char((10)))+'See https://commons.wikimedia.org/wiki/Anonymous_works'
	,@IsActive                         bit               = null							-- default: (1)
	,@UsageTerms                       nvarchar(max)     = null							
	,@ApplicationUserSID               int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@UsageNotes                       nvarchar(max)     = null							
	,@FormInstructions                 nvarchar(max)     = null							
	,@VersionHistory                   xml               = null							
	,@UserDefinedColumns               xml               = null							
	,@FormXID                          varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@PersonSID                        int               = null							-- not a base table column (default ignored)
	,@CultureSID                       int               = null							-- not a base table column (default ignored)
	,@AuthenticationAuthoritySID       int               = null							-- not a base table column (default ignored)
	,@UserName                         nvarchar(75)      = null							-- not a base table column (default ignored)
	,@LastReviewTime                   datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastReviewUser                   nvarchar(75)      = null							-- not a base table column (default ignored)
	,@IsPotentialDuplicate             bit               = null							-- not a base table column (default ignored)
	,@IsTemplate                       bit               = null							-- not a base table column (default ignored)
	,@GlassBreakPassword               varbinary(8000)   = null							-- not a base table column (default ignored)
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserIsActive          bit               = null							-- not a base table column (default ignored)
	,@AuthenticationSystemID           nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ApplicationUserRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
	,@FormTypeSCD                      varchar(25)       = null							-- not a base table column (default ignored)
	,@FormTypeLabel                    nvarchar(35)      = null							-- not a base table column (default ignored)
	,@FormOwnerSID                     int               = null							-- not a base table column (default ignored)
	,@FormTypeIsDefault                bit               = null							-- not a base table column (default ignored)
	,@FormTypeRowGUID                  uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@LatestVersionNo                  smallint          = null							-- not a base table column (default ignored)
	,@LatestRevisionNo                 smallint          = null							-- not a base table column (default ignored)
	,@LatestVersionFormVersionSID      int               = null							-- not a base table column (default ignored)
	,@LatestRevisionFormVersionSID     int               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pForm#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pForm#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pForm#Insert
			 @FormTypeSID                      = @FormTypeSID
			,@FormName                         = @FormName
			,@FormLabel                        = @FormLabel
			,@FormContext                      = @FormContext
			,@AuthorCredit                     = @AuthorCredit
			,@IsActive                         = @IsActive
			,@UsageTerms                       = @UsageTerms
			,@ApplicationUserSID               = @ApplicationUserSID
			,@UsageNotes                       = @UsageNotes
			,@FormInstructions                 = @FormInstructions
			,@VersionHistory                   = @VersionHistory
			,@UserDefinedColumns               = @UserDefinedColumns
			,@FormXID                          = @FormXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@PersonSID                        = @PersonSID
			,@CultureSID                       = @CultureSID
			,@AuthenticationAuthoritySID       = @AuthenticationAuthoritySID
			,@UserName                         = @UserName
			,@LastReviewTime                   = @LastReviewTime
			,@LastReviewUser                   = @LastReviewUser
			,@IsPotentialDuplicate             = @IsPotentialDuplicate
			,@IsTemplate                       = @IsTemplate
			,@GlassBreakPassword               = @GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime = @LastGlassBreakPasswordChangeTime
			,@ApplicationUserIsActive          = @ApplicationUserIsActive
			,@AuthenticationSystemID           = @AuthenticationSystemID
			,@ApplicationUserRowGUID           = @ApplicationUserRowGUID
			,@FormTypeSCD                      = @FormTypeSCD
			,@FormTypeLabel                    = @FormTypeLabel
			,@FormOwnerSID                     = @FormOwnerSID
			,@FormTypeIsDefault                = @FormTypeIsDefault
			,@FormTypeRowGUID                  = @FormTypeRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@LatestVersionNo                  = @LatestVersionNo
			,@LatestRevisionNo                 = @LatestRevisionNo
			,@LatestVersionFormVersionSID      = @LatestVersionFormVersionSID
			,@LatestRevisionFormVersionSID     = @LatestRevisionFormVersionSID

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
