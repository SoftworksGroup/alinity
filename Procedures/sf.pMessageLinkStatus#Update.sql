SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pMessageLinkStatus#Update]
	 @MessageLinkStatusSID   int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@MessageLinkStatusSCD   varchar(10)       = null -- table column values to update:
	,@MessageLinkStatusLabel nvarchar(35)      = null
	,@UsageNotes             nvarchar(max)     = null
	,@IsResendEnabled        bit               = null
	,@IsActive               bit               = null
	,@IsDefault              bit               = null
	,@UserDefinedColumns     xml               = null
	,@MessageLinkStatusXID   varchar(150)      = null
	,@LegacyKey              nvarchar(50)      = null
	,@UpdateUser             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected           tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied          bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext               xml               = null -- other values defining context for the update (if any)
	,@IsDeleteEnabled        bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pMessageLinkStatus#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.MessageLinkStatus table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.MessageLinkStatus table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vMessageLinkStatus entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pMessageLinkStatus procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Business rule compliance is checked through a table constraint which calls fMessageLinkStatusCheck to test all rules.

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

		-- check parameters

		if @MessageLinkStatusSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@MessageLinkStatusSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @MessageLinkStatusSCD = ltrim(rtrim(@MessageLinkStatusSCD))
		set @MessageLinkStatusLabel = ltrim(rtrim(@MessageLinkStatusLabel))
		set @UsageNotes = ltrim(rtrim(@UsageNotes))
		set @MessageLinkStatusXID = ltrim(rtrim(@MessageLinkStatusXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))

		-- set zero length strings to null to avoid storing them in the record

		if len(@MessageLinkStatusSCD) = 0 set @MessageLinkStatusSCD = null
		if len(@MessageLinkStatusLabel) = 0 set @MessageLinkStatusLabel = null
		if len(@UsageNotes) = 0 set @UsageNotes = null
		if len(@MessageLinkStatusXID) = 0 set @MessageLinkStatusXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @MessageLinkStatusSCD   = isnull(@MessageLinkStatusSCD,mls.MessageLinkStatusSCD)
				,@MessageLinkStatusLabel = isnull(@MessageLinkStatusLabel,mls.MessageLinkStatusLabel)
				,@UsageNotes             = isnull(@UsageNotes,mls.UsageNotes)
				,@IsResendEnabled        = isnull(@IsResendEnabled,mls.IsResendEnabled)
				,@IsActive               = isnull(@IsActive,mls.IsActive)
				,@IsDefault              = isnull(@IsDefault,mls.IsDefault)
				,@UserDefinedColumns     = isnull(@UserDefinedColumns,mls.UserDefinedColumns)
				,@MessageLinkStatusXID   = isnull(@MessageLinkStatusXID,mls.MessageLinkStatusXID)
				,@LegacyKey              = isnull(@LegacyKey,mls.LegacyKey)
				,@UpdateUser             = isnull(@UpdateUser,mls.UpdateUser)
				,@IsReselected           = isnull(@IsReselected,mls.IsReselected)
				,@IsNullApplied          = isnull(@IsNullApplied,mls.IsNullApplied)
				,@zContext               = isnull(@zContext,mls.zContext)
				,@IsDeleteEnabled        = isnull(@IsDeleteEnabled,mls.IsDeleteEnabled)
			from
				sf.vMessageLinkStatus mls
			where
				mls.MessageLinkStatusSID = @MessageLinkStatusSID

		end
		
		-- unset previous default if record is being marked as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.MessageLinkStatusSID from sf.MessageLinkStatus x where x.IsDefault = @ON and x.MessageLinkStatusSID <> @MessageLinkStatusSID
			
			if @recordSID is not null
			begin
			
				update
					sf.MessageLinkStatus
				set
					 IsDefault  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					MessageLinkStatusSID = @recordSID																-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>

		-- update the record

		update
			sf.MessageLinkStatus
		set
			 MessageLinkStatusSCD = @MessageLinkStatusSCD
			,MessageLinkStatusLabel = @MessageLinkStatusLabel
			,UsageNotes = @UsageNotes
			,IsResendEnabled = @IsResendEnabled
			,IsActive = @IsActive
			,IsDefault = @IsDefault
			,UserDefinedColumns = @UserDefinedColumns
			,MessageLinkStatusXID = @MessageLinkStatusXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			MessageLinkStatusSID = @MessageLinkStatusSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.MessageLinkStatus where MessageLinkStatusSID = @messageLinkStatusSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.MessageLinkStatus'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.MessageLinkStatus'
					,@Arg2        = @messageLinkStatusSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'sf.MessageLinkStatus'
				,@Arg3        = @rowsAffected
				,@Arg4        = @messageLinkStatusSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
		
		-- ensure a default record is identified on the table
		
		if not exists
		(
			select 1 from	sf.MessageLinkStatus x where x.IsDefault = @ON
		)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'MissingDefault'
				,@MessageText = @errorText output
				,@DefaultText = N'A default %1 record is required by the application. (Setting another record as the new default automatically un-sets the previous one.)'
				,@Arg1        = 'Message Link Status'
			
			raiserror(@errorText, 16, 1)
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.MessageLinkStatusSID
			from
				sf.vMessageLinkStatus ent
			where
				ent.MessageLinkStatusSID = @MessageLinkStatusSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.MessageLinkStatusSID
				,ent.MessageLinkStatusSCD
				,ent.MessageLinkStatusLabel
				,ent.UsageNotes
				,ent.IsResendEnabled
				,ent.IsActive
				,ent.IsDefault
				,ent.UserDefinedColumns
				,ent.MessageLinkStatusXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				sf.vMessageLinkStatus ent
			where
				ent.MessageLinkStatusSID = @MessageLinkStatusSID

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
