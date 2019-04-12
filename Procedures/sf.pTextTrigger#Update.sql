SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextTrigger#Update]
	 @TextTriggerSID                   int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@TextTriggerLabel                 nvarchar(35)      = null -- table column values to update:
	,@TextTemplateSID                  int               = null
	,@QuerySID                         int               = null
	,@MinDaysToRepeat                  int               = null
	,@ApplicationUserSID               int               = null
	,@JobScheduleSID                   int               = null
	,@LastStartTime                    datetimeoffset(7) = null
	,@LastEndTime                      datetimeoffset(7) = null
	,@IsActive                         bit               = null
	,@UserDefinedColumns               xml               = null
	,@TextTriggerXID                   varchar(150)      = null
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
	,@TextTemplateLabel                nvarchar(35)      = null -- not a base table column
	,@PriorityLevel                    tinyint           = null -- not a base table column
	,@Body                             nvarchar(1600)    = null -- not a base table column
	,@IsApplicationUserRequired        bit               = null -- not a base table column
	,@LinkExpiryHours                  int               = null -- not a base table column
	,@ApplicationEntitySID             int               = null -- not a base table column
	,@TextTemplateRowGUID              uniqueidentifier  = null -- not a base table column
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
Procedure : sf.pTextTrigger#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.TextTrigger table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.TextTrigger table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vTextTrigger entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTextTrigger procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fTextTriggerCheck to test all rules.

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

		if @TextTriggerSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@TextTriggerSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @TextTriggerLabel = ltrim(rtrim(@TextTriggerLabel))
		set @TextTriggerXID = ltrim(rtrim(@TextTriggerXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @QueryLabel = ltrim(rtrim(@QueryLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @LastExecuteUser = ltrim(rtrim(@LastExecuteUser))
		set @QueryCode = ltrim(rtrim(@QueryCode))
		set @TextTemplateLabel = ltrim(rtrim(@TextTemplateLabel))
		set @Body = ltrim(rtrim(@Body))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @JobScheduleLabel = ltrim(rtrim(@JobScheduleLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@TextTriggerLabel) = 0 set @TextTriggerLabel = null
		if len(@TextTriggerXID) = 0 set @TextTriggerXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@QueryLabel) = 0 set @QueryLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@QueryCode) = 0 set @QueryCode = null
		if len(@TextTemplateLabel) = 0 set @TextTemplateLabel = null
		if len(@Body) = 0 set @Body = null
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
				 @TextTriggerLabel                 = isnull(@TextTriggerLabel,ttgr.TextTriggerLabel)
				,@TextTemplateSID                  = isnull(@TextTemplateSID,ttgr.TextTemplateSID)
				,@QuerySID                         = isnull(@QuerySID,ttgr.QuerySID)
				,@MinDaysToRepeat                  = isnull(@MinDaysToRepeat,ttgr.MinDaysToRepeat)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,ttgr.ApplicationUserSID)
				,@JobScheduleSID                   = isnull(@JobScheduleSID,ttgr.JobScheduleSID)
				,@LastStartTime                    = isnull(@LastStartTime,ttgr.LastStartTime)
				,@LastEndTime                      = isnull(@LastEndTime,ttgr.LastEndTime)
				,@IsActive                         = isnull(@IsActive,ttgr.IsActive)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,ttgr.UserDefinedColumns)
				,@TextTriggerXID                   = isnull(@TextTriggerXID,ttgr.TextTriggerXID)
				,@LegacyKey                        = isnull(@LegacyKey,ttgr.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,ttgr.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,ttgr.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,ttgr.IsNullApplied)
				,@zContext                         = isnull(@zContext,ttgr.zContext)
				,@QueryCategorySID                 = isnull(@QueryCategorySID,ttgr.QueryCategorySID)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,ttgr.ApplicationPageSID)
				,@QueryLabel                       = isnull(@QueryLabel,ttgr.QueryLabel)
				,@ToolTip                          = isnull(@ToolTip,ttgr.ToolTip)
				,@LastExecuteTime                  = isnull(@LastExecuteTime,ttgr.LastExecuteTime)
				,@LastExecuteUser                  = isnull(@LastExecuteUser,ttgr.LastExecuteUser)
				,@ExecuteCount                     = isnull(@ExecuteCount,ttgr.ExecuteCount)
				,@QueryCode                        = isnull(@QueryCode,ttgr.QueryCode)
				,@QueryIsActive                    = isnull(@QueryIsActive,ttgr.QueryIsActive)
				,@IsApplicationPageDefault         = isnull(@IsApplicationPageDefault,ttgr.IsApplicationPageDefault)
				,@QueryRowGUID                     = isnull(@QueryRowGUID,ttgr.QueryRowGUID)
				,@TextTemplateLabel                = isnull(@TextTemplateLabel,ttgr.TextTemplateLabel)
				,@PriorityLevel                    = isnull(@PriorityLevel,ttgr.PriorityLevel)
				,@Body                             = isnull(@Body,ttgr.Body)
				,@IsApplicationUserRequired        = isnull(@IsApplicationUserRequired,ttgr.IsApplicationUserRequired)
				,@LinkExpiryHours                  = isnull(@LinkExpiryHours,ttgr.LinkExpiryHours)
				,@ApplicationEntitySID             = isnull(@ApplicationEntitySID,ttgr.ApplicationEntitySID)
				,@TextTemplateRowGUID              = isnull(@TextTemplateRowGUID,ttgr.TextTemplateRowGUID)
				,@PersonSID                        = isnull(@PersonSID,ttgr.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,ttgr.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,ttgr.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,ttgr.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,ttgr.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,ttgr.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,ttgr.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,ttgr.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,ttgr.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,ttgr.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,ttgr.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,ttgr.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,ttgr.ApplicationUserRowGUID)
				,@JobScheduleLabel                 = isnull(@JobScheduleLabel,ttgr.JobScheduleLabel)
				,@IsEnabled                        = isnull(@IsEnabled,ttgr.IsEnabled)
				,@IsRunMonday                      = isnull(@IsRunMonday,ttgr.IsRunMonday)
				,@IsRunTuesday                     = isnull(@IsRunTuesday,ttgr.IsRunTuesday)
				,@IsRunWednesday                   = isnull(@IsRunWednesday,ttgr.IsRunWednesday)
				,@IsRunThursday                    = isnull(@IsRunThursday,ttgr.IsRunThursday)
				,@IsRunFriday                      = isnull(@IsRunFriday,ttgr.IsRunFriday)
				,@IsRunSaturday                    = isnull(@IsRunSaturday,ttgr.IsRunSaturday)
				,@IsRunSunday                      = isnull(@IsRunSunday,ttgr.IsRunSunday)
				,@RepeatIntervalMinutes            = isnull(@RepeatIntervalMinutes,ttgr.RepeatIntervalMinutes)
				,@StartTime                        = isnull(@StartTime,ttgr.StartTime)
				,@EndTime                          = isnull(@EndTime,ttgr.EndTime)
				,@StartDate                        = isnull(@StartDate,ttgr.StartDate)
				,@EndDate                          = isnull(@EndDate,ttgr.EndDate)
				,@JobScheduleRowGUID               = isnull(@JobScheduleRowGUID,ttgr.JobScheduleRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,ttgr.IsDeleteEnabled)
				,@LastDurationMinutes              = isnull(@LastDurationMinutes,ttgr.LastDurationMinutes)
				,@IsRunning                        = isnull(@IsRunning,ttgr.IsRunning)
				,@LastStartTimeClientTZ            = isnull(@LastStartTimeClientTZ,ttgr.LastStartTimeClientTZ)
				,@LastEndTimeClientTZ              = isnull(@LastEndTimeClientTZ,ttgr.LastEndTimeClientTZ)
				,@NextScheduledTime                = isnull(@NextScheduledTime,ttgr.NextScheduledTime)
				,@NextScheduledTimeServerTZ        = isnull(@NextScheduledTimeServerTZ,ttgr.NextScheduledTimeServerTZ)
			from
				sf.vTextTrigger ttgr
			where
				ttgr.TextTriggerSID = @TextTriggerSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.TextTrigger x where x.TextTriggerSID = @TextTriggerSID) <> @ApplicationUserSID
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
		
		if (select x.QuerySID from sf.TextTrigger x where x.TextTriggerSID = @TextTriggerSID) <> @QuerySID
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

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		
		-- Cory Ng | Jun 2016
    -- Ensure the query selected returns 2 columns, first one being the
		-- record SID which is used to merge content for the text. The
		-- second being the person SID the text message is going to.

		declare
			@test table
			(
				 RecordSID int
				,PersonSID int			)

		if not exists																													-- only check if query has changed
		(
			select
				1
			from
				sf.TextTrigger tt
			where
				tt.TextTriggerSID = @TextTriggerSID
			and
				tt.QuerySID	= @QuerySID
		)
		begin

			begin try

				insert
					@test
					(
						 RecordSID
						,PersonSID
					)
				exec sf.pQuery#Execute
					@QuerySID = @QuerySID

			end try
			begin catch
				
				exec sf.pMessage#Get
				 @MessageSCD  = 'TriggerPersonSIDExpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The query must return two values to be used with the %1 trigger. The first being the record system ID and the second must be the %1 recipient person system ID.'
				,@Arg1 = 'text message'
				
				raiserror(@errorText, 18, 1)

			end catch

		end

		--! </PreUpdate>

		-- update the record

		update
			sf.TextTrigger
		set
			 TextTriggerLabel = @TextTriggerLabel
			,TextTemplateSID = @TextTemplateSID
			,QuerySID = @QuerySID
			,MinDaysToRepeat = @MinDaysToRepeat
			,ApplicationUserSID = @ApplicationUserSID
			,JobScheduleSID = @JobScheduleSID
			,LastStartTime = @LastStartTime
			,LastEndTime = @LastEndTime
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,TextTriggerXID = @TextTriggerXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			TextTriggerSID = @TextTriggerSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.TextTrigger where TextTriggerSID = @textTriggerSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.TextTrigger'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.TextTrigger'
					,@Arg2        = @textTriggerSID
				
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
				,@Arg2        = 'sf.TextTrigger'
				,@Arg3        = @rowsAffected
				,@Arg4        = @textTriggerSID
			
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
				 ent.TextTriggerSID
			from
				sf.vTextTrigger ent
			where
				ent.TextTriggerSID = @TextTriggerSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.TextTriggerSID
				,ent.TextTriggerLabel
				,ent.TextTemplateSID
				,ent.QuerySID
				,ent.MinDaysToRepeat
				,ent.ApplicationUserSID
				,ent.JobScheduleSID
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.TextTriggerXID
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
				,ent.TextTemplateLabel
				,ent.PriorityLevel
				,ent.Body
				,ent.IsApplicationUserRequired
				,ent.LinkExpiryHours
				,ent.ApplicationEntitySID
				,ent.TextTemplateRowGUID
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
				sf.vTextTrigger ent
			where
				ent.TextTriggerSID = @TextTriggerSID

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
