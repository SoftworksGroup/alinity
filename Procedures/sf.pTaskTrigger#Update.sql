SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTaskTrigger#Update]
	 @TaskTriggerSID                   int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@TaskTriggerLabel                 nvarchar(35)      = null -- table column values to update:
	,@TaskTitleTemplate                nvarchar(65)      = null
	,@TaskDescriptionTemplate          nvarchar(max)     = null
	,@QuerySID                         int               = null
	,@TaskQueueSID                     int               = null
	,@ApplicationUserSID               int               = null
	,@IsAlert                          bit               = null
	,@PriorityLevel                    tinyint           = null
	,@TargetCompletionDays             smallint          = null
	,@OpenTaskLimit                    int               = null
	,@IsRegeneratedIfClosed            bit               = null
	,@ApplicationAction                varchar(75)       = null
	,@JobScheduleSID                   int               = null
	,@LastStartTime                    datetimeoffset(7) = null
	,@LastEndTime                      datetimeoffset(7) = null
	,@IsActive                         bit               = null
	,@UserDefinedColumns               xml               = null
	,@TaskTriggerXID                   varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@QueryCategorySID                 int               = null -- not a base table column
	,@ApplicationPageSID               int               = null -- not a base table column
	,@QueryLabel                       nvarchar(35)      = null -- not a base table column
	,@ToolTip                          nvarchar(250)     = null -- not a base table column
	,@LastExecuteTime                  datetimeoffset(7) = null -- not a base table column
	,@LastExecuteUser                  nvarchar(75)      = null -- not a base table column
	,@ExecuteCount                     int               = null -- not a base table column
	,@QueryCode                        varchar(30)       = null -- not a base table column
	,@QueryIsActive                    bit               = null -- not a base table column
	,@IsApplicationPageDefault         bit               = null -- not a base table column
	,@QueryRowGUID                     uniqueidentifier  = null -- not a base table column
	,@TaskQueueLabel                   nvarchar(35)      = null -- not a base table column
	,@TaskQueueCode                    varchar(30)       = null -- not a base table column
	,@IsAutoAssigned                   bit               = null -- not a base table column
	,@IsOpenSubscription               bit               = null -- not a base table column
	,@TaskQueueApplicationUserSID      int               = null -- not a base table column
	,@TaskQueueIsActive                bit               = null -- not a base table column
	,@TaskQueueIsDefault               bit               = null -- not a base table column
	,@TaskQueueRowGUID                 uniqueidentifier  = null -- not a base table column
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
	,@JobScheduleLabel                 nvarchar(35)      = null -- not a base table column
	,@IsEnabled                        bit               = null -- not a base table column
	,@IsRunMonday                      bit               = null -- not a base table column
	,@IsRunTuesday                     bit               = null -- not a base table column
	,@IsRunWednesday                   bit               = null -- not a base table column
	,@IsRunThursday                    bit               = null -- not a base table column
	,@IsRunFriday                      bit               = null -- not a base table column
	,@IsRunSaturday                    bit               = null -- not a base table column
	,@IsRunSunday                      bit               = null -- not a base table column
	,@RepeatIntervalMinutes            smallint          = null -- not a base table column
	,@StartTime                        time(0)           = null -- not a base table column
	,@EndTime                          time(0)           = null -- not a base table column
	,@StartDate                        date              = null -- not a base table column
	,@EndDate                          date              = null -- not a base table column
	,@JobScheduleRowGUID               uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                  bit               = null -- not a base table column
	,@LastDurationMinutes              int               = null -- not a base table column
	,@IsRunning                        bit               = null -- not a base table column
	,@LastStartTimeClientTZ            datetime          = null -- not a base table column
	,@LastEndTimeClientTZ              datetime          = null -- not a base table column
	,@NextScheduledTime                datetime          = null -- not a base table column
	,@NextScheduledTimeServerTZ        datetimeoffset(7) = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pTaskTrigger#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.TaskTrigger table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.TaskTrigger table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vTaskTrigger entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTaskTrigger procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fTaskTriggerCheck to test all rules.

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

		if @TaskTriggerSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@TaskTriggerSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @TaskTriggerLabel = ltrim(rtrim(@TaskTriggerLabel))
		set @TaskTitleTemplate = ltrim(rtrim(@TaskTitleTemplate))
		set @TaskDescriptionTemplate = ltrim(rtrim(@TaskDescriptionTemplate))
		set @ApplicationAction = ltrim(rtrim(@ApplicationAction))
		set @TaskTriggerXID = ltrim(rtrim(@TaskTriggerXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @QueryLabel = ltrim(rtrim(@QueryLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @LastExecuteUser = ltrim(rtrim(@LastExecuteUser))
		set @QueryCode = ltrim(rtrim(@QueryCode))
		set @TaskQueueLabel = ltrim(rtrim(@TaskQueueLabel))
		set @TaskQueueCode = ltrim(rtrim(@TaskQueueCode))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @JobScheduleLabel = ltrim(rtrim(@JobScheduleLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@TaskTriggerLabel) = 0 set @TaskTriggerLabel = null
		if len(@TaskTitleTemplate) = 0 set @TaskTitleTemplate = null
		if len(@TaskDescriptionTemplate) = 0 set @TaskDescriptionTemplate = null
		if len(@ApplicationAction) = 0 set @ApplicationAction = null
		if len(@TaskTriggerXID) = 0 set @TaskTriggerXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@QueryLabel) = 0 set @QueryLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@QueryCode) = 0 set @QueryCode = null
		if len(@TaskQueueLabel) = 0 set @TaskQueueLabel = null
		if len(@TaskQueueCode) = 0 set @TaskQueueCode = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@JobScheduleLabel) = 0 set @JobScheduleLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @TaskTriggerLabel                 = isnull(@TaskTriggerLabel,tt.TaskTriggerLabel)
				,@TaskTitleTemplate                = isnull(@TaskTitleTemplate,tt.TaskTitleTemplate)
				,@TaskDescriptionTemplate          = isnull(@TaskDescriptionTemplate,tt.TaskDescriptionTemplate)
				,@QuerySID                         = isnull(@QuerySID,tt.QuerySID)
				,@TaskQueueSID                     = isnull(@TaskQueueSID,tt.TaskQueueSID)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,tt.ApplicationUserSID)
				,@IsAlert                          = isnull(@IsAlert,tt.IsAlert)
				,@PriorityLevel                    = isnull(@PriorityLevel,tt.PriorityLevel)
				,@TargetCompletionDays             = isnull(@TargetCompletionDays,tt.TargetCompletionDays)
				,@OpenTaskLimit                    = isnull(@OpenTaskLimit,tt.OpenTaskLimit)
				,@IsRegeneratedIfClosed            = isnull(@IsRegeneratedIfClosed,tt.IsRegeneratedIfClosed)
				,@ApplicationAction                = isnull(@ApplicationAction,tt.ApplicationAction)
				,@JobScheduleSID                   = isnull(@JobScheduleSID,tt.JobScheduleSID)
				,@LastStartTime                    = isnull(@LastStartTime,tt.LastStartTime)
				,@LastEndTime                      = isnull(@LastEndTime,tt.LastEndTime)
				,@IsActive                         = isnull(@IsActive,tt.IsActive)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,tt.UserDefinedColumns)
				,@TaskTriggerXID                   = isnull(@TaskTriggerXID,tt.TaskTriggerXID)
				,@LegacyKey                        = isnull(@LegacyKey,tt.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,tt.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,tt.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,tt.IsNullApplied)
				,@zContext                         = isnull(@zContext,tt.zContext)
				,@QueryCategorySID                 = isnull(@QueryCategorySID,tt.QueryCategorySID)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,tt.ApplicationPageSID)
				,@QueryLabel                       = isnull(@QueryLabel,tt.QueryLabel)
				,@ToolTip                          = isnull(@ToolTip,tt.ToolTip)
				,@LastExecuteTime                  = isnull(@LastExecuteTime,tt.LastExecuteTime)
				,@LastExecuteUser                  = isnull(@LastExecuteUser,tt.LastExecuteUser)
				,@ExecuteCount                     = isnull(@ExecuteCount,tt.ExecuteCount)
				,@QueryCode                        = isnull(@QueryCode,tt.QueryCode)
				,@QueryIsActive                    = isnull(@QueryIsActive,tt.QueryIsActive)
				,@IsApplicationPageDefault         = isnull(@IsApplicationPageDefault,tt.IsApplicationPageDefault)
				,@QueryRowGUID                     = isnull(@QueryRowGUID,tt.QueryRowGUID)
				,@TaskQueueLabel                   = isnull(@TaskQueueLabel,tt.TaskQueueLabel)
				,@TaskQueueCode                    = isnull(@TaskQueueCode,tt.TaskQueueCode)
				,@IsAutoAssigned                   = isnull(@IsAutoAssigned,tt.IsAutoAssigned)
				,@IsOpenSubscription               = isnull(@IsOpenSubscription,tt.IsOpenSubscription)
				,@TaskQueueApplicationUserSID      = isnull(@TaskQueueApplicationUserSID,tt.TaskQueueApplicationUserSID)
				,@TaskQueueIsActive                = isnull(@TaskQueueIsActive,tt.TaskQueueIsActive)
				,@TaskQueueIsDefault               = isnull(@TaskQueueIsDefault,tt.TaskQueueIsDefault)
				,@TaskQueueRowGUID                 = isnull(@TaskQueueRowGUID,tt.TaskQueueRowGUID)
				,@PersonSID                        = isnull(@PersonSID,tt.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,tt.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,tt.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,tt.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,tt.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,tt.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,tt.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,tt.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,tt.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,tt.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,tt.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,tt.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,tt.ApplicationUserRowGUID)
				,@JobScheduleLabel                 = isnull(@JobScheduleLabel,tt.JobScheduleLabel)
				,@IsEnabled                        = isnull(@IsEnabled,tt.IsEnabled)
				,@IsRunMonday                      = isnull(@IsRunMonday,tt.IsRunMonday)
				,@IsRunTuesday                     = isnull(@IsRunTuesday,tt.IsRunTuesday)
				,@IsRunWednesday                   = isnull(@IsRunWednesday,tt.IsRunWednesday)
				,@IsRunThursday                    = isnull(@IsRunThursday,tt.IsRunThursday)
				,@IsRunFriday                      = isnull(@IsRunFriday,tt.IsRunFriday)
				,@IsRunSaturday                    = isnull(@IsRunSaturday,tt.IsRunSaturday)
				,@IsRunSunday                      = isnull(@IsRunSunday,tt.IsRunSunday)
				,@RepeatIntervalMinutes            = isnull(@RepeatIntervalMinutes,tt.RepeatIntervalMinutes)
				,@StartTime                        = isnull(@StartTime,tt.StartTime)
				,@EndTime                          = isnull(@EndTime,tt.EndTime)
				,@StartDate                        = isnull(@StartDate,tt.StartDate)
				,@EndDate                          = isnull(@EndDate,tt.EndDate)
				,@JobScheduleRowGUID               = isnull(@JobScheduleRowGUID,tt.JobScheduleRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,tt.IsDeleteEnabled)
				,@LastDurationMinutes              = isnull(@LastDurationMinutes,tt.LastDurationMinutes)
				,@IsRunning                        = isnull(@IsRunning,tt.IsRunning)
				,@LastStartTimeClientTZ            = isnull(@LastStartTimeClientTZ,tt.LastStartTimeClientTZ)
				,@LastEndTimeClientTZ              = isnull(@LastEndTimeClientTZ,tt.LastEndTimeClientTZ)
				,@NextScheduledTime                = isnull(@NextScheduledTime,tt.NextScheduledTime)
				,@NextScheduledTimeServerTZ        = isnull(@NextScheduledTimeServerTZ,tt.NextScheduledTimeServerTZ)
			from
				sf.vTaskTrigger tt
			where
				tt.TaskTriggerSID = @TaskTriggerSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.TaskTrigger x where x.TaskTriggerSID = @TaskTriggerSID) <> @ApplicationUserSID
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
		
		if (select x.QuerySID from sf.TaskTrigger x where x.TaskTriggerSID = @TaskTriggerSID) <> @QuerySID
		begin
			if (select x.IsActive from sf.Query x where x.QuerySID = @QuerySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'query'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.TaskQueueSID from sf.TaskTrigger x where x.TaskTriggerSID = @TaskTriggerSID) <> @TaskQueueSID
		begin
			if (select x.IsActive from sf.TaskQueue x where x.TaskQueueSID = @TaskQueueSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'task queue'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  Tim Edlund | July 2013
		-- If the last start time is being updated to a time after the last end time, set the last end
		-- time to NULL so that the trigger is changed to the "IsRunning" status.

		if @LastStartTime > @LastEndTime set @LastEndTime = null
		--! </PreUpdate>

		-- update the record

		update
			sf.TaskTrigger
		set
			 TaskTriggerLabel = @TaskTriggerLabel
			,TaskTitleTemplate = @TaskTitleTemplate
			,TaskDescriptionTemplate = @TaskDescriptionTemplate
			,QuerySID = @QuerySID
			,TaskQueueSID = @TaskQueueSID
			,ApplicationUserSID = @ApplicationUserSID
			,IsAlert = @IsAlert
			,PriorityLevel = @PriorityLevel
			,TargetCompletionDays = @TargetCompletionDays
			,OpenTaskLimit = @OpenTaskLimit
			,IsRegeneratedIfClosed = @IsRegeneratedIfClosed
			,ApplicationAction = @ApplicationAction
			,JobScheduleSID = @JobScheduleSID
			,LastStartTime = @LastStartTime
			,LastEndTime = @LastEndTime
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,TaskTriggerXID = @TaskTriggerXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			TaskTriggerSID = @TaskTriggerSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.TaskTrigger where TaskTriggerSID = @taskTriggerSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.TaskTrigger'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.TaskTrigger'
					,@Arg2        = @taskTriggerSID
				
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
				,@Arg2        = 'sf.TaskTrigger'
				,@Arg3        = @rowsAffected
				,@Arg4        = @taskTriggerSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.TaskTriggerSID
			from
				sf.vTaskTrigger ent
			where
				ent.TaskTriggerSID = @TaskTriggerSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.TaskTriggerSID
				,ent.TaskTriggerLabel
				,ent.TaskTitleTemplate
				,ent.TaskDescriptionTemplate
				,ent.QuerySID
				,ent.TaskQueueSID
				,ent.ApplicationUserSID
				,ent.IsAlert
				,ent.PriorityLevel
				,ent.TargetCompletionDays
				,ent.OpenTaskLimit
				,ent.IsRegeneratedIfClosed
				,ent.ApplicationAction
				,ent.JobScheduleSID
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.TaskTriggerXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.QueryCategorySID
				,ent.ApplicationPageSID
				,ent.QueryLabel
				,ent.ToolTip
				,ent.LastExecuteTime
				,ent.LastExecuteUser
				,ent.ExecuteCount
				,ent.QueryCode
				,ent.QueryIsActive
				,ent.IsApplicationPageDefault
				,ent.QueryRowGUID
				,ent.TaskQueueLabel
				,ent.TaskQueueCode
				,ent.IsAutoAssigned
				,ent.IsOpenSubscription
				,ent.TaskQueueApplicationUserSID
				,ent.TaskQueueIsActive
				,ent.TaskQueueIsDefault
				,ent.TaskQueueRowGUID
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
				,ent.JobScheduleLabel
				,ent.IsEnabled
				,ent.IsRunMonday
				,ent.IsRunTuesday
				,ent.IsRunWednesday
				,ent.IsRunThursday
				,ent.IsRunFriday
				,ent.IsRunSaturday
				,ent.IsRunSunday
				,ent.RepeatIntervalMinutes
				,ent.StartTime
				,ent.EndTime
				,ent.StartDate
				,ent.EndDate
				,ent.JobScheduleRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.LastDurationMinutes
				,ent.IsRunning
				,ent.LastStartTimeClientTZ
				,ent.LastEndTimeClientTZ
				,ent.NextScheduledTime
				,ent.NextScheduledTimeServerTZ
			from
				sf.vTaskTrigger ent
			where
				ent.TaskTriggerSID = @TaskTriggerSID

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
