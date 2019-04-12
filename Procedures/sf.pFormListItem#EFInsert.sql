SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pFormListItem#EFInsert]
	 @FormListSID          int               = null													-- required! if not passed value must be set in custom logic prior to insert
	,@FormListItemCode     varchar(15)       = null													-- required! if not passed value must be set in custom logic prior to insert
	,@FormListItemLabel    nvarchar(35)      = null													-- required! if not passed value must be set in custom logic prior to insert
	,@FormListItemSequence smallint          = null													-- default: (0)
	,@ToolTip              nvarchar(500)     = null													
	,@IsActive             bit               = null													-- default: (1)
	,@UserDefinedColumns   xml               = null													
	,@FormListItemXID      varchar(150)      = null													
	,@LegacyKey            nvarchar(50)      = null													
	,@CreateUser           nvarchar(75)      = null													-- default: suser_sname()
	,@IsReselected         tinyint           = null													-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext             xml               = null													-- other values defining context for the insert (if any)
	,@FormListCode         varchar(15)       = null													-- not a base table column (default ignored)
	,@FormListLabel        nvarchar(35)      = null													-- not a base table column (default ignored)
	,@FormListToolTip      nvarchar(500)     = null													-- not a base table column (default ignored)
	,@FormListRowGUID      uniqueidentifier  = null													-- not a base table column (default ignored)
	,@IsDeleteEnabled      bit               = null													-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pFormListItem#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pFormListItem#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pFormListItem#Insert
			 @FormListSID          = @FormListSID
			,@FormListItemCode     = @FormListItemCode
			,@FormListItemLabel    = @FormListItemLabel
			,@FormListItemSequence = @FormListItemSequence
			,@ToolTip              = @ToolTip
			,@IsActive             = @IsActive
			,@UserDefinedColumns   = @UserDefinedColumns
			,@FormListItemXID      = @FormListItemXID
			,@LegacyKey            = @LegacyKey
			,@CreateUser           = @CreateUser
			,@IsReselected         = @IsReselected
			,@zContext             = @zContext
			,@FormListCode         = @FormListCode
			,@FormListLabel        = @FormListLabel
			,@FormListToolTip      = @FormListToolTip
			,@FormListRowGUID      = @FormListRowGUID
			,@IsDeleteEnabled      = @IsDeleteEnabled

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
