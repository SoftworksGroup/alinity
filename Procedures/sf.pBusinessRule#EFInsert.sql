SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pBusinessRule#EFInsert]
	 @ApplicationEntitySID     int               = null											-- required! if not passed value must be set in custom logic prior to insert
	,@MessageSID               int               = null											-- required! if not passed value must be set in custom logic prior to insert
	,@ColumnName               nvarchar(128)     = null											-- required! if not passed value must be set in custom logic prior to insert
	,@BusinessRuleStatus       char(1)           = null											-- default: 'x'
	,@UserDefinedColumns       xml               = null											
	,@BusinessRuleXID          varchar(150)      = null											
	,@LegacyKey                nvarchar(50)      = null											
	,@CreateUser               nvarchar(75)      = null											-- default: suser_sname()
	,@IsReselected             tinyint           = null											-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                 xml               = null											-- other values defining context for the insert (if any)
	,@ApplicationEntitySCD     varchar(50)       = null											-- not a base table column (default ignored)
	,@ApplicationEntityName    nvarchar(50)      = null											-- not a base table column (default ignored)
	,@IsMergeDataSource        bit               = null											-- not a base table column (default ignored)
	,@ApplicationEntityRowGUID uniqueidentifier  = null											-- not a base table column (default ignored)
	,@MessageSCD               varchar(128)      = null											-- not a base table column (default ignored)
	,@MessageName              nvarchar(100)     = null											-- not a base table column (default ignored)
	,@MessageText              nvarchar(1000)    = null											-- not a base table column (default ignored)
	,@MessageTextUpdateTime    datetimeoffset(7) = null											-- not a base table column (default ignored)
	,@DefaultText              nvarchar(1000)    = null											-- not a base table column (default ignored)
	,@DefaultTextUpdateTime    datetimeoffset(7) = null											-- not a base table column (default ignored)
	,@MessageRowGUID           uniqueidentifier  = null											-- not a base table column (default ignored)
	,@IsDeleteEnabled          bit               = null											-- not a base table column (default ignored)
	,@IsMandatory              bit               = null											-- not a base table column (default ignored)
	,@SchemaName               nvarchar(128)     = null											-- not a base table column (default ignored)
	,@TableName                nvarchar(128)     = null											-- not a base table column (default ignored)
	,@TableObjectID            int               = null											-- not a base table column (default ignored)
	,@IsNewStatusOn            bit               = null											-- not a base table column (default ignored)
	,@RuleStatusLabel          nvarchar(15)      = null											-- not a base table column (default ignored)
	,@DataStatusLabel          nvarchar(15)      = null											-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pBusinessRule#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pBusinessRule#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pBusinessRule#Insert
			 @ApplicationEntitySID     = @ApplicationEntitySID
			,@MessageSID               = @MessageSID
			,@ColumnName               = @ColumnName
			,@BusinessRuleStatus       = @BusinessRuleStatus
			,@UserDefinedColumns       = @UserDefinedColumns
			,@BusinessRuleXID          = @BusinessRuleXID
			,@LegacyKey                = @LegacyKey
			,@CreateUser               = @CreateUser
			,@IsReselected             = @IsReselected
			,@zContext                 = @zContext
			,@ApplicationEntitySCD     = @ApplicationEntitySCD
			,@ApplicationEntityName    = @ApplicationEntityName
			,@IsMergeDataSource        = @IsMergeDataSource
			,@ApplicationEntityRowGUID = @ApplicationEntityRowGUID
			,@MessageSCD               = @MessageSCD
			,@MessageName              = @MessageName
			,@MessageText              = @MessageText
			,@MessageTextUpdateTime    = @MessageTextUpdateTime
			,@DefaultText              = @DefaultText
			,@DefaultTextUpdateTime    = @DefaultTextUpdateTime
			,@MessageRowGUID           = @MessageRowGUID
			,@IsDeleteEnabled          = @IsDeleteEnabled
			,@IsMandatory              = @IsMandatory
			,@SchemaName               = @SchemaName
			,@TableName                = @TableName
			,@TableObjectID            = @TableObjectID
			,@IsNewStatusOn            = @IsNewStatusOn
			,@RuleStatusLabel          = @RuleStatusLabel
			,@DataStatusLabel          = @DataStatusLabel

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
