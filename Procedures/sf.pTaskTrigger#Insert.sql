SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTaskTrigger#Insert]
	 @TaskTriggerSID                   int               = null output			-- identity value assigned to the new record
	,@TaskTriggerLabel                 nvarchar(35)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@TaskTitleTemplate                nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@TaskDescriptionTemplate          nvarchar(max)     = null							-- required! if not passed value must be set in custom logic prior to insert
	,@QuerySID                         int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@TaskQueueSID                     int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ApplicationUserSID               int               = null							
	,@IsAlert                          bit               = null							-- default: (0)
	,@PriorityLevel                    tinyint           = null							-- default: (3)
	,@TargetCompletionDays             smallint          = null							-- default: (7)
	,@OpenTaskLimit                    int               = null							-- default: (100)
	,@IsRegeneratedIfClosed            bit               = null							-- default: (0)
	,@ApplicationAction                varchar(75)       = null							
	,@JobScheduleSID                   int               = null							
	,@LastStartTime                    datetimeoffset(7) = null							
	,@LastEndTime                      datetimeoffset(7) = null							
	,@IsActive                         bit               = null							-- default: (1)
	,@UserDefinedColumns               xml               = null							
	,@TaskTriggerXID                   varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@QueryCategorySID                 int               = null							-- not a base table column (default ignored)
	,@ApplicationPageSID               int               = null							-- not a base table column (default ignored)
	,@QueryLabel                       nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ToolTip                          nvarchar(250)     = null							-- not a base table column (default ignored)
	,@LastExecuteTime                  datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastExecuteUser                  nvarchar(75)      = null							-- not a base table column (default ignored)
	,@ExecuteCount                     int               = null							-- not a base table column (default ignored)
	,@QueryCode                        varchar(30)       = null							-- not a base table column (default ignored)
	,@QueryIsActive                    bit               = null							-- not a base table column (default ignored)
	,@IsApplicationPageDefault         bit               = null							-- not a base table column (default ignored)
	,@QueryRowGUID                     uniqueidentifier  = null							-- not a base table column (default ignored)
	,@TaskQueueLabel                   nvarchar(35)      = null							-- not a base table column (default ignored)
	,@TaskQueueCode                    varchar(30)       = null							-- not a base table column (default ignored)
	,@IsAutoAssigned                   bit               = null							-- not a base table column (default ignored)
	,@IsOpenSubscription               bit               = null							-- not a base table column (default ignored)
	,@TaskQueueApplicationUserSID      int               = null							-- not a base table column (default ignored)
	,@TaskQueueIsActive                bit               = null							-- not a base table column (default ignored)
	,@TaskQueueIsDefault               bit               = null							-- not a base table column (default ignored)
	,@TaskQueueRowGUID                 uniqueidentifier  = null							-- not a base table column (default ignored)
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
	,@JobScheduleLabel                 nvarchar(35)      = null							-- not a base table column (default ignored)
	,@IsEnabled                        bit               = null							-- not a base table column (default ignored)
	,@IsRunMonday                      bit               = null							-- not a base table column (default ignored)
	,@IsRunTuesday                     bit               = null							-- not a base table column (default ignored)
	,@IsRunWednesday                   bit               = null							-- not a base table column (default ignored)
	,@IsRunThursday                    bit               = null							-- not a base table column (default ignored)
	,@IsRunFriday                      bit               = null							-- not a base table column (default ignored)
	,@IsRunSaturday                    bit               = null							-- not a base table column (default ignored)
	,@IsRunSunday                      bit               = null							-- not a base table column (default ignored)
	,@RepeatIntervalMinutes            smallint          = null							-- not a base table column (default ignored)
	,@StartTime                        time(0)           = null							-- not a base table column (default ignored)
	,@EndTime                          time(0)           = null							-- not a base table column (default ignored)
	,@StartDate                        date              = null							-- not a base table column (default ignored)
	,@EndDate                          date              = null							-- not a base table column (default ignored)
	,@JobScheduleRowGUID               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@LastDurationMinutes              int               = null							-- not a base table column (default ignored)
	,@IsRunning                        bit               = null							-- not a base table column (default ignored)
	,@LastStartTimeClientTZ            datetime          = null							-- not a base table column (default ignored)
	,@LastEndTimeClientTZ              datetime          = null							-- not a base table column (default ignored)
	,@NextScheduledTime                datetime          = null							-- not a base table column (default ignored)
	,@NextScheduledTimeServerTZ        datetimeoffset(7) = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pTaskTrigger#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.TaskTrigger table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.TaskTrigger table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vTaskTrigger entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTaskTrigger procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

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

	set @TaskTriggerSID = null																							-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @TaskTriggerLabel = ltrim(rtrim(@TaskTriggerLabel))
		set @TaskTitleTemplate = ltrim(rtrim(@TaskTitleTemplate))
		set @TaskDescriptionTemplate = ltrim(rtrim(@TaskDescriptionTemplate))
		set @ApplicationAction = ltrim(rtrim(@ApplicationAction))
		set @TaskTriggerXID = ltrim(rtrim(@TaskTriggerXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsAlert = isnull(@IsAlert,(0))
		set @PriorityLevel = isnull(@PriorityLevel,(3))
		set @TargetCompletionDays = isnull(@TargetCompletionDays,(7))
		set @OpenTaskLimit = isnull(@OpenTaskLimit,(100))
		set @IsRegeneratedIfClosed = isnull(@IsRegeneratedIfClosed,(0))
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @TaskQueueSID  is null select @TaskQueueSID  = x.TaskQueueSID from sf.TaskQueue  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>

		-- insert the record

		insert
			sf.TaskTrigger
		(
			 TaskTriggerLabel
			,TaskTitleTemplate
			,TaskDescriptionTemplate
			,QuerySID
			,TaskQueueSID
			,ApplicationUserSID
			,IsAlert
			,PriorityLevel
			,TargetCompletionDays
			,OpenTaskLimit
			,IsRegeneratedIfClosed
			,ApplicationAction
			,JobScheduleSID
			,LastStartTime
			,LastEndTime
			,IsActive
			,UserDefinedColumns
			,TaskTriggerXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @TaskTriggerLabel
			,@TaskTitleTemplate
			,@TaskDescriptionTemplate
			,@QuerySID
			,@TaskQueueSID
			,@ApplicationUserSID
			,@IsAlert
			,@PriorityLevel
			,@TargetCompletionDays
			,@OpenTaskLimit
			,@IsRegeneratedIfClosed
			,@ApplicationAction
			,@JobScheduleSID
			,@LastStartTime
			,@LastEndTime
			,@IsActive
			,@UserDefinedColumns
			,@TaskTriggerXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected   = @@rowcount
			,@TaskTriggerSID = scope_identity()																	-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.TaskTrigger'
				,@Arg3        = @rowsAffected
				,@Arg4        = @TaskTriggerSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>

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
