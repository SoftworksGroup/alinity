SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTaskQueue#Update]
	 @TaskQueueSID                     int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@TaskQueueLabel                   nvarchar(35)      = null -- table column values to update:
	,@TaskQueueCode                    varchar(30)       = null
	,@UsageNotes                       nvarchar(max)     = null
	,@IsAutoAssigned                   bit               = null
	,@IsOpenSubscription               bit               = null
	,@ApplicationUserSID               int               = null
	,@IsActive                         bit               = null
	,@IsDefault                        bit               = null
	,@UserDefinedColumns               xml               = null
	,@TaskQueueXID                     varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@PersonSID                        int               = null -- not a base table column
	,@CultureSID                       int               = null -- not a base table column
	,@AuthenticationAuthoritySID       int               = null -- not a base table column
	,@UserName                         nvarchar(75)      = null -- not a base table column
	,@LastReviewTime                   datetimeoffset(7) = null -- not a base table column
	,@LastReviewUser                   nvarchar(75)      = null -- not a base table column
	,@IsPotentialDuplicate             bit               = null -- not a base table column
	,@IsTemplate                       bit               = null -- not a base table column
	,@GlassBreakPassword               varbinary(8000)   = null -- not a base table column
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null -- not a base table column
	,@ApplicationUserIsActive          bit               = null -- not a base table column
	,@AuthenticationSystemID           nvarchar(50)      = null -- not a base table column
	,@ApplicationUserRowGUID           uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                  bit               = null -- not a base table column
	,@ApplicationUserDisplayName       nvarchar(65)      = null -- not a base table column
	,@SubscriberCount                  int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pTaskQueue#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.TaskQueue table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.TaskQueue table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vTaskQueue entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTaskQueue procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fTaskQueueCheck to test all rules.

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

		if @TaskQueueSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@TaskQueueSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @TaskQueueLabel = ltrim(rtrim(@TaskQueueLabel))
		set @TaskQueueCode = ltrim(rtrim(@TaskQueueCode))
		set @UsageNotes = ltrim(rtrim(@UsageNotes))
		set @TaskQueueXID = ltrim(rtrim(@TaskQueueXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @ApplicationUserDisplayName = ltrim(rtrim(@ApplicationUserDisplayName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@TaskQueueLabel) = 0 set @TaskQueueLabel = null
		if len(@TaskQueueCode) = 0 set @TaskQueueCode = null
		if len(@UsageNotes) = 0 set @UsageNotes = null
		if len(@TaskQueueXID) = 0 set @TaskQueueXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@ApplicationUserDisplayName) = 0 set @ApplicationUserDisplayName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @TaskQueueLabel                   = isnull(@TaskQueueLabel,tq.TaskQueueLabel)
				,@TaskQueueCode                    = isnull(@TaskQueueCode,tq.TaskQueueCode)
				,@UsageNotes                       = isnull(@UsageNotes,tq.UsageNotes)
				,@IsAutoAssigned                   = isnull(@IsAutoAssigned,tq.IsAutoAssigned)
				,@IsOpenSubscription               = isnull(@IsOpenSubscription,tq.IsOpenSubscription)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,tq.ApplicationUserSID)
				,@IsActive                         = isnull(@IsActive,tq.IsActive)
				,@IsDefault                        = isnull(@IsDefault,tq.IsDefault)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,tq.UserDefinedColumns)
				,@TaskQueueXID                     = isnull(@TaskQueueXID,tq.TaskQueueXID)
				,@LegacyKey                        = isnull(@LegacyKey,tq.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,tq.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,tq.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,tq.IsNullApplied)
				,@zContext                         = isnull(@zContext,tq.zContext)
				,@PersonSID                        = isnull(@PersonSID,tq.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,tq.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,tq.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,tq.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,tq.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,tq.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,tq.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,tq.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,tq.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,tq.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,tq.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,tq.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,tq.ApplicationUserRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,tq.IsDeleteEnabled)
				,@ApplicationUserDisplayName       = isnull(@ApplicationUserDisplayName,tq.ApplicationUserDisplayName)
				,@SubscriberCount                  = isnull(@SubscriberCount,tq.SubscriberCount)
			from
				sf.vTaskQueue tq
			where
				tq.TaskQueueSID = @TaskQueueSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.TaskQueue x where x.TaskQueueSID = @TaskQueueSID) <> @ApplicationUserSID
		begin
			if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'application user'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		-- prevent system code values from being modified
		
		if exists(select 1 from sf.TaskQueue x where x.TaskQueueSID = @TaskQueueSID and left(x.TaskQueueCode, 2) = 'S!' and x.TaskQueueCode <> @TaskQueueCode)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  	= 'SystemCodeEdit'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'This code value is required by the application. The code cannot be edited.'
		
			raiserror(@errorText, 16, 1)
		
		end
		
		-- unset previous default if record is being marked as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.TaskQueueSID from sf.TaskQueue x where x.IsDefault = @ON and x.TaskQueueSID <> @TaskQueueSID
			
			if @recordSID is not null
			begin
			
				update
					sf.TaskQueue
				set
					 IsDefault  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					TaskQueueSID = @recordSID																				-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>

		-- update the record

		update
			sf.TaskQueue
		set
			 TaskQueueLabel = @TaskQueueLabel
			,TaskQueueCode = @TaskQueueCode
			,UsageNotes = @UsageNotes
			,IsAutoAssigned = @IsAutoAssigned
			,IsOpenSubscription = @IsOpenSubscription
			,ApplicationUserSID = @ApplicationUserSID
			,IsActive = @IsActive
			,IsDefault = @IsDefault
			,UserDefinedColumns = @UserDefinedColumns
			,TaskQueueXID = @TaskQueueXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			TaskQueueSID = @TaskQueueSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.TaskQueue where TaskQueueSID = @taskQueueSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.TaskQueue'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.TaskQueue'
					,@Arg2        = @taskQueueSID
				
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
				,@Arg2        = 'sf.TaskQueue'
				,@Arg3        = @rowsAffected
				,@Arg4        = @taskQueueSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
		
		-- ensure a default record is identified on the table
		
		if not exists
		(
			select 1 from	sf.TaskQueue x where x.IsDefault = @ON
		)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'MissingDefault'
				,@MessageText = @errorText output
				,@DefaultText = N'A default %1 record is required by the application. (Setting another record as the new default automatically un-sets the previous one.)'
				,@Arg1        = 'Task Queue'
			
			raiserror(@errorText, 16, 1)
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.TaskQueueSID
			from
				sf.vTaskQueue ent
			where
				ent.TaskQueueSID = @TaskQueueSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.TaskQueueSID
				,ent.TaskQueueLabel
				,ent.TaskQueueCode
				,ent.UsageNotes
				,ent.IsAutoAssigned
				,ent.IsOpenSubscription
				,ent.ApplicationUserSID
				,ent.IsActive
				,ent.IsDefault
				,ent.UserDefinedColumns
				,ent.TaskQueueXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonSID
				,ent.CultureSID
				,ent.AuthenticationAuthoritySID
				,ent.UserName
				,ent.LastReviewTime
				,ent.LastReviewUser
				,ent.IsPotentialDuplicate
				,ent.IsTemplate
				,ent.GlassBreakPassword
				,ent.LastGlassBreakPasswordChangeTime
				,ent.ApplicationUserIsActive
				,ent.AuthenticationSystemID
				,ent.ApplicationUserRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.ApplicationUserDisplayName
				,ent.SubscriberCount
			from
				sf.vTaskQueue ent
			where
				ent.TaskQueueSID = @TaskQueueSID

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