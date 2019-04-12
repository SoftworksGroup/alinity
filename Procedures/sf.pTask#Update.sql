SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTask#Update]
	 @TaskSID                          int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@TaskTitle                        nvarchar(65)      = null -- table column values to update:
	,@TaskQueueSID                     int               = null
	,@TargetRowGUID                    uniqueidentifier  = null
	,@TaskDescription                  varbinary(max)    = null
	,@IsAlert                          bit               = null
	,@PriorityLevel                    tinyint           = null
	,@ApplicationUserSID               int               = null
	,@TaskStatusSID                    int               = null
	,@AssignedTime                     datetimeoffset(7) = null
	,@DueDate                          date              = null
	,@NextFollowUpDate                 date              = null
	,@ClosedTime                       datetimeoffset(7) = null
	,@ApplicationPageSID               int               = null
	,@TaskTriggerSID                   int               = null
	,@RecipientList                    xml               = null
	,@TagList                          xml               = null
	,@FileExtension                    varchar(5)        = null
	,@UserDefinedColumns               xml               = null
	,@TaskXID                          varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@TaskQueueLabel                   nvarchar(35)      = null -- not a base table column
	,@TaskQueueCode                    varchar(30)       = null -- not a base table column
	,@IsAutoAssigned                   bit               = null -- not a base table column
	,@IsOpenSubscription               bit               = null -- not a base table column
	,@TaskQueueApplicationUserSID      int               = null -- not a base table column
	,@TaskQueueIsActive                bit               = null -- not a base table column
	,@TaskQueueIsDefault               bit               = null -- not a base table column
	,@TaskQueueRowGUID                 uniqueidentifier  = null -- not a base table column
	,@TaskStatusSCD                    varchar(10)       = null -- not a base table column
	,@TaskStatusLabel                  nvarchar(35)      = null -- not a base table column
	,@TaskStatusSequence               int               = null -- not a base table column
	,@IsDerived                        bit               = null -- not a base table column
	,@IsClosedStatus                   bit               = null -- not a base table column
	,@TaskStatusIsActive               bit               = null -- not a base table column
	,@TaskStatusIsDefault              bit               = null -- not a base table column
	,@TaskStatusRowGUID                uniqueidentifier  = null -- not a base table column
	,@TaskTriggerLabel                 nvarchar(35)      = null -- not a base table column
	,@TaskTitleTemplate                nvarchar(65)      = null -- not a base table column
	,@QuerySID                         int               = null -- not a base table column
	,@TaskTriggerTaskQueueSID          int               = null -- not a base table column
	,@TaskTriggerApplicationUserSID    int               = null -- not a base table column
	,@TaskTriggerIsAlert               bit               = null -- not a base table column
	,@TaskTriggerPriorityLevel         tinyint           = null -- not a base table column
	,@TargetCompletionDays             smallint          = null -- not a base table column
	,@OpenTaskLimit                    int               = null -- not a base table column
	,@IsRegeneratedIfClosed            bit               = null -- not a base table column
	,@ApplicationAction                varchar(75)       = null -- not a base table column
	,@JobScheduleSID                   int               = null -- not a base table column
	,@LastStartTime                    datetimeoffset(7) = null -- not a base table column
	,@LastEndTime                      datetimeoffset(7) = null -- not a base table column
	,@TaskTriggerIsActive              bit               = null -- not a base table column
	,@TaskTriggerRowGUID               uniqueidentifier  = null -- not a base table column
	,@ApplicationPageLabel             nvarchar(35)      = null -- not a base table column
	,@ApplicationPageURI               varchar(150)      = null -- not a base table column
	,@ApplicationRoute                 varchar(150)      = null -- not a base table column
	,@IsSearchPage                     bit               = null -- not a base table column
	,@ApplicationEntitySID             int               = null -- not a base table column
	,@ApplicationPageRowGUID           uniqueidentifier  = null -- not a base table column
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
	,@IsOverdue                        bit               = null -- not a base table column
	,@IsOpen                           bit               = null -- not a base table column
	,@IsCancelled                      bit               = null -- not a base table column
	,@IsClosed                         bit               = null -- not a base table column
	,@IsTaskTakeOverEnabled            bit               = null -- not a base table column
	,@IsCloseEnabled                   bit               = null -- not a base table column
	,@IsUpdateEnabled                  bit               = null -- not a base table column
	,@IsClosedWithinADay               bit               = null -- not a base table column
	,@EntityLabel                      nvarchar(250)     = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pTask#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.Task table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.Task table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vTask entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTask procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fTaskCheck to test all rules.

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

		if @TaskSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@TaskSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @TaskTitle = ltrim(rtrim(@TaskTitle))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @TaskXID = ltrim(rtrim(@TaskXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @TaskQueueLabel = ltrim(rtrim(@TaskQueueLabel))
		set @TaskQueueCode = ltrim(rtrim(@TaskQueueCode))
		set @TaskStatusSCD = ltrim(rtrim(@TaskStatusSCD))
		set @TaskStatusLabel = ltrim(rtrim(@TaskStatusLabel))
		set @TaskTriggerLabel = ltrim(rtrim(@TaskTriggerLabel))
		set @TaskTitleTemplate = ltrim(rtrim(@TaskTitleTemplate))
		set @ApplicationAction = ltrim(rtrim(@ApplicationAction))
		set @ApplicationPageLabel = ltrim(rtrim(@ApplicationPageLabel))
		set @ApplicationPageURI = ltrim(rtrim(@ApplicationPageURI))
		set @ApplicationRoute = ltrim(rtrim(@ApplicationRoute))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @EntityLabel = ltrim(rtrim(@EntityLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@TaskTitle) = 0 set @TaskTitle = null
		if len(@FileExtension) = 0 set @FileExtension = null
		if len(@TaskXID) = 0 set @TaskXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@TaskQueueLabel) = 0 set @TaskQueueLabel = null
		if len(@TaskQueueCode) = 0 set @TaskQueueCode = null
		if len(@TaskStatusSCD) = 0 set @TaskStatusSCD = null
		if len(@TaskStatusLabel) = 0 set @TaskStatusLabel = null
		if len(@TaskTriggerLabel) = 0 set @TaskTriggerLabel = null
		if len(@TaskTitleTemplate) = 0 set @TaskTitleTemplate = null
		if len(@ApplicationAction) = 0 set @ApplicationAction = null
		if len(@ApplicationPageLabel) = 0 set @ApplicationPageLabel = null
		if len(@ApplicationPageURI) = 0 set @ApplicationPageURI = null
		if len(@ApplicationRoute) = 0 set @ApplicationRoute = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@EntityLabel) = 0 set @EntityLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @TaskTitle                        = isnull(@TaskTitle,task.TaskTitle)
				,@TaskQueueSID                     = isnull(@TaskQueueSID,task.TaskQueueSID)
				,@TargetRowGUID                    = isnull(@TargetRowGUID,task.TargetRowGUID)
				,@TaskDescription                  = isnull(@TaskDescription,task.TaskDescription)
				,@IsAlert                          = isnull(@IsAlert,task.IsAlert)
				,@PriorityLevel                    = isnull(@PriorityLevel,task.PriorityLevel)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,task.ApplicationUserSID)
				,@TaskStatusSID                    = isnull(@TaskStatusSID,task.TaskStatusSID)
				,@AssignedTime                     = isnull(@AssignedTime,task.AssignedTime)
				,@DueDate                          = isnull(@DueDate,task.DueDate)
				,@NextFollowUpDate                 = isnull(@NextFollowUpDate,task.NextFollowUpDate)
				,@ClosedTime                       = isnull(@ClosedTime,task.ClosedTime)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,task.ApplicationPageSID)
				,@TaskTriggerSID                   = isnull(@TaskTriggerSID,task.TaskTriggerSID)
				,@RecipientList                    = isnull(@RecipientList,task.RecipientList)
				,@TagList                          = isnull(@TagList,task.TagList)
				,@FileExtension                    = isnull(@FileExtension,task.FileExtension)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,task.UserDefinedColumns)
				,@TaskXID                          = isnull(@TaskXID,task.TaskXID)
				,@LegacyKey                        = isnull(@LegacyKey,task.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,task.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,task.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,task.IsNullApplied)
				,@zContext                         = isnull(@zContext,task.zContext)
				,@TaskQueueLabel                   = isnull(@TaskQueueLabel,task.TaskQueueLabel)
				,@TaskQueueCode                    = isnull(@TaskQueueCode,task.TaskQueueCode)
				,@IsAutoAssigned                   = isnull(@IsAutoAssigned,task.IsAutoAssigned)
				,@IsOpenSubscription               = isnull(@IsOpenSubscription,task.IsOpenSubscription)
				,@TaskQueueApplicationUserSID      = isnull(@TaskQueueApplicationUserSID,task.TaskQueueApplicationUserSID)
				,@TaskQueueIsActive                = isnull(@TaskQueueIsActive,task.TaskQueueIsActive)
				,@TaskQueueIsDefault               = isnull(@TaskQueueIsDefault,task.TaskQueueIsDefault)
				,@TaskQueueRowGUID                 = isnull(@TaskQueueRowGUID,task.TaskQueueRowGUID)
				,@TaskStatusSCD                    = isnull(@TaskStatusSCD,task.TaskStatusSCD)
				,@TaskStatusLabel                  = isnull(@TaskStatusLabel,task.TaskStatusLabel)
				,@TaskStatusSequence               = isnull(@TaskStatusSequence,task.TaskStatusSequence)
				,@IsDerived                        = isnull(@IsDerived,task.IsDerived)
				,@IsClosedStatus                   = isnull(@IsClosedStatus,task.IsClosedStatus)
				,@TaskStatusIsActive               = isnull(@TaskStatusIsActive,task.TaskStatusIsActive)
				,@TaskStatusIsDefault              = isnull(@TaskStatusIsDefault,task.TaskStatusIsDefault)
				,@TaskStatusRowGUID                = isnull(@TaskStatusRowGUID,task.TaskStatusRowGUID)
				,@TaskTriggerLabel                 = isnull(@TaskTriggerLabel,task.TaskTriggerLabel)
				,@TaskTitleTemplate                = isnull(@TaskTitleTemplate,task.TaskTitleTemplate)
				,@QuerySID                         = isnull(@QuerySID,task.QuerySID)
				,@TaskTriggerTaskQueueSID          = isnull(@TaskTriggerTaskQueueSID,task.TaskTriggerTaskQueueSID)
				,@TaskTriggerApplicationUserSID    = isnull(@TaskTriggerApplicationUserSID,task.TaskTriggerApplicationUserSID)
				,@TaskTriggerIsAlert               = isnull(@TaskTriggerIsAlert,task.TaskTriggerIsAlert)
				,@TaskTriggerPriorityLevel         = isnull(@TaskTriggerPriorityLevel,task.TaskTriggerPriorityLevel)
				,@TargetCompletionDays             = isnull(@TargetCompletionDays,task.TargetCompletionDays)
				,@OpenTaskLimit                    = isnull(@OpenTaskLimit,task.OpenTaskLimit)
				,@IsRegeneratedIfClosed            = isnull(@IsRegeneratedIfClosed,task.IsRegeneratedIfClosed)
				,@ApplicationAction                = isnull(@ApplicationAction,task.ApplicationAction)
				,@JobScheduleSID                   = isnull(@JobScheduleSID,task.JobScheduleSID)
				,@LastStartTime                    = isnull(@LastStartTime,task.LastStartTime)
				,@LastEndTime                      = isnull(@LastEndTime,task.LastEndTime)
				,@TaskTriggerIsActive              = isnull(@TaskTriggerIsActive,task.TaskTriggerIsActive)
				,@TaskTriggerRowGUID               = isnull(@TaskTriggerRowGUID,task.TaskTriggerRowGUID)
				,@ApplicationPageLabel             = isnull(@ApplicationPageLabel,task.ApplicationPageLabel)
				,@ApplicationPageURI               = isnull(@ApplicationPageURI,task.ApplicationPageURI)
				,@ApplicationRoute                 = isnull(@ApplicationRoute,task.ApplicationRoute)
				,@IsSearchPage                     = isnull(@IsSearchPage,task.IsSearchPage)
				,@ApplicationEntitySID             = isnull(@ApplicationEntitySID,task.ApplicationEntitySID)
				,@ApplicationPageRowGUID           = isnull(@ApplicationPageRowGUID,task.ApplicationPageRowGUID)
				,@PersonSID                        = isnull(@PersonSID,task.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,task.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,task.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,task.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,task.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,task.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,task.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,task.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,task.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,task.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,task.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,task.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,task.ApplicationUserRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,task.IsDeleteEnabled)
				,@IsOverdue                        = isnull(@IsOverdue,task.IsOverdue)
				,@IsOpen                           = isnull(@IsOpen,task.IsOpen)
				,@IsCancelled                      = isnull(@IsCancelled,task.IsCancelled)
				,@IsClosed                         = isnull(@IsClosed,task.IsClosed)
				,@IsTaskTakeOverEnabled            = isnull(@IsTaskTakeOverEnabled,task.IsTaskTakeOverEnabled)
				,@IsCloseEnabled                   = isnull(@IsCloseEnabled,task.IsCloseEnabled)
				,@IsUpdateEnabled                  = isnull(@IsUpdateEnabled,task.IsUpdateEnabled)
				,@IsClosedWithinADay               = isnull(@IsClosedWithinADay,task.IsClosedWithinADay)
				,@EntityLabel                      = isnull(@EntityLabel,task.EntityLabel)
			from
				sf.vTask task
			where
				task.TaskSID = @TaskSID

		end
		
		if @IsClosed = @ON and @ClosedTime is null set @ClosedTime = sysdatetimeoffset()								-- set column when null and extended view bit is passed to set it
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @TaskStatusSCD is not null and @TaskStatusSID = (select x.TaskStatusSID from sf.Task x where x.TaskSID = @TaskSID)
		begin
		
			select
				@TaskStatusSID = x.TaskStatusSID
			from
				sf.TaskStatus x
			where
				x.TaskStatusSCD = @TaskStatusSCD
		
		end
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the new tags applied (if any)

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.Task x where x.TaskSID = @TaskSID) <> @ApplicationUserSID
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
		
		if (select x.TaskQueueSID from sf.Task x where x.TaskSID = @TaskSID) <> @TaskQueueSID
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
		
		if (select x.TaskStatusSID from sf.Task x where x.TaskSID = @TaskSID) <> @TaskStatusSID
		begin
			if (select x.IsActive from sf.TaskStatus x where x.TaskStatusSID = @TaskStatusSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'task status'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.TaskTriggerSID from sf.Task x where x.TaskSID = @TaskSID) <> @TaskTriggerSID
		begin
			if (select x.IsActive from sf.TaskTrigger x where x.TaskTriggerSID = @TaskTriggerSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'task trigger'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>

		-- Cory Ng | June 2013
    -- When the procedure detects a change to the application user, the assigned time
		-- it set automatically - overriding whatever value was passed

		declare
			 @oldApplicationUserSID						int
			,@oldIsClosedStatus								bit

		select
			 @oldApplicationUserSID = t.ApplicationUserSID
			,@oldIsClosedStatus			= ts.IsClosedStatus
    from
      sf.Task				t
		join
			sf.TaskStatus ts on t.TaskStatusSID = ts.TaskStatusSID
    where
      t.TaskSID = @TaskSID

		if @ApplicationUserSID is null and @AssignedTime is not null					-- if assigned time is filled in but no user assigned, set it back to null
		begin
			set @AssignedTime = null
		end
		else if isnull(@oldApplicationUserSID, -1) <> isnull(@ApplicationUserSID, -1)
		begin
			set @AssignedTime = sysdatetimeoffset()
		end
			
		-- Cory Ng | June 2013
    -- When the procedure detects that the task has been closed, the closed time
		-- column for it is set automatically - overriding whatever value was passed

		select
			@IsClosedStatus = ts.IsClosedStatus
		from
			sf.TaskStatus ts
		where
			ts.TaskStatusSID = @TaskStatusSID

		if @oldIsClosedStatus = @OFF and @IsClosedStatus = @ON
		begin
			set @ClosedTime = sysdatetimeoffset()
		end
		else if @IsClosedStatus = @OFF and @ClosedTime is not null
		begin
			set @ClosedTime = null
		end
			
		--! </PreUpdate>

		-- update the record

		update
			sf.Task
		set
			 TaskTitle = @TaskTitle
			,TaskQueueSID = @TaskQueueSID
			,TargetRowGUID = @TargetRowGUID
			,TaskDescription = @TaskDescription
			,IsAlert = @IsAlert
			,PriorityLevel = @PriorityLevel
			,ApplicationUserSID = @ApplicationUserSID
			,TaskStatusSID = @TaskStatusSID
			,AssignedTime = @AssignedTime
			,DueDate = @DueDate
			,NextFollowUpDate = @NextFollowUpDate
			,ClosedTime = @ClosedTime
			,ApplicationPageSID = @ApplicationPageSID
			,TaskTriggerSID = @TaskTriggerSID
			,RecipientList = @RecipientList
			,TagList = @TagList
			,FileExtension = @FileExtension
			,UserDefinedColumns = @UserDefinedColumns
			,TaskXID = @TaskXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			TaskSID = @TaskSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.Task where TaskSID = @taskSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.Task'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.Task'
					,@Arg2        = @taskSID
				
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
				,@Arg2        = 'sf.Task'
				,@Arg3        = @rowsAffected
				,@Arg4        = @taskSID
			
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
				 ent.TaskSID
			from
				sf.vTask ent
			where
				ent.TaskSID = @TaskSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.TaskSID
				,ent.TaskTitle
				,ent.TaskQueueSID
				,ent.TargetRowGUID
				,ent.TaskDescription
				,ent.IsAlert
				,ent.PriorityLevel
				,ent.ApplicationUserSID
				,ent.TaskStatusSID
				,ent.AssignedTime
				,ent.DueDate
				,ent.NextFollowUpDate
				,ent.ClosedTime
				,ent.ApplicationPageSID
				,ent.TaskTriggerSID
				,ent.RecipientList
				,ent.TagList
				,ent.FileExtension
				,ent.UserDefinedColumns
				,ent.TaskXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.TaskQueueLabel
				,ent.TaskQueueCode
				,ent.IsAutoAssigned
				,ent.IsOpenSubscription
				,ent.TaskQueueApplicationUserSID
				,ent.TaskQueueIsActive
				,ent.TaskQueueIsDefault
				,ent.TaskQueueRowGUID
				,ent.TaskStatusSCD
				,ent.TaskStatusLabel
				,ent.TaskStatusSequence
				,ent.IsDerived
				,ent.IsClosedStatus
				,ent.TaskStatusIsActive
				,ent.TaskStatusIsDefault
				,ent.TaskStatusRowGUID
				,ent.TaskTriggerLabel
				,ent.TaskTitleTemplate
				,ent.QuerySID
				,ent.TaskTriggerTaskQueueSID
				,ent.TaskTriggerApplicationUserSID
				,ent.TaskTriggerIsAlert
				,ent.TaskTriggerPriorityLevel
				,ent.TargetCompletionDays
				,ent.OpenTaskLimit
				,ent.IsRegeneratedIfClosed
				,ent.ApplicationAction
				,ent.JobScheduleSID
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.TaskTriggerIsActive
				,ent.TaskTriggerRowGUID
				,ent.ApplicationPageLabel
				,ent.ApplicationPageURI
				,ent.ApplicationRoute
				,ent.IsSearchPage
				,ent.ApplicationEntitySID
				,ent.ApplicationPageRowGUID
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
				,ent.IsOverdue
				,ent.IsOpen
				,ent.IsCancelled
				,ent.IsClosed
				,ent.IsTaskTakeOverEnabled
				,ent.IsCloseEnabled
				,ent.IsUpdateEnabled
				,ent.IsClosedWithinADay
				,ent.EntityLabel
			from
				sf.vTask ent
			where
				ent.TaskSID = @TaskSID

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
