SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailTrigger#Update]
	 @EmailTriggerSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@EmailTriggerLabel                nvarchar(35)      = null -- table column values to update:
	,@EmailTemplateSID                 int               = null
	,@QuerySID                         int               = null
	,@MinDaysToRepeat                  int               = null
	,@ApplicationUserSID               int               = null
	,@JobScheduleSID                   int               = null
	,@LastStartTime                    datetimeoffset(7) = null
	,@LastEndTime                      datetimeoffset(7) = null
	,@EarliestSelectionDate            date              = null
	,@IsActive                         bit               = null
	,@UserDefinedColumns               xml               = null
	,@EmailTriggerXID                  varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@EmailTemplateLabel               nvarchar(35)      = null -- not a base table column
	,@PriorityLevel                    tinyint           = null -- not a base table column
	,@Subject                          nvarchar(120)     = null -- not a base table column
	,@IsApplicationUserRequired        bit               = null -- not a base table column
	,@LinkExpiryHours                  int               = null -- not a base table column
	,@ApplicationEntitySID             int               = null -- not a base table column
	,@ApplicationGrantSID              int               = null -- not a base table column
	,@EmailTemplateRowGUID             uniqueidentifier  = null -- not a base table column
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
Procedure : sf.pEmailTrigger#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.EmailTrigger table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.EmailTrigger table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vEmailTrigger entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pEmailTrigger procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fEmailTriggerCheck to test all rules.

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

		if @EmailTriggerSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@EmailTriggerSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @EmailTriggerLabel = ltrim(rtrim(@EmailTriggerLabel))
		set @EmailTriggerXID = ltrim(rtrim(@EmailTriggerXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @EmailTemplateLabel = ltrim(rtrim(@EmailTemplateLabel))
		set @Subject = ltrim(rtrim(@Subject))
		set @QueryLabel = ltrim(rtrim(@QueryLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @LastExecuteUser = ltrim(rtrim(@LastExecuteUser))
		set @QueryCode = ltrim(rtrim(@QueryCode))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @JobScheduleLabel = ltrim(rtrim(@JobScheduleLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@EmailTriggerLabel) = 0 set @EmailTriggerLabel = null
		if len(@EmailTriggerXID) = 0 set @EmailTriggerXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@EmailTemplateLabel) = 0 set @EmailTemplateLabel = null
		if len(@Subject) = 0 set @Subject = null
		if len(@QueryLabel) = 0 set @QueryLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@QueryCode) = 0 set @QueryCode = null
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
				 @EmailTriggerLabel                = isnull(@EmailTriggerLabel,emltgr.EmailTriggerLabel)
				,@EmailTemplateSID                 = isnull(@EmailTemplateSID,emltgr.EmailTemplateSID)
				,@QuerySID                         = isnull(@QuerySID,emltgr.QuerySID)
				,@MinDaysToRepeat                  = isnull(@MinDaysToRepeat,emltgr.MinDaysToRepeat)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,emltgr.ApplicationUserSID)
				,@JobScheduleSID                   = isnull(@JobScheduleSID,emltgr.JobScheduleSID)
				,@LastStartTime                    = isnull(@LastStartTime,emltgr.LastStartTime)
				,@LastEndTime                      = isnull(@LastEndTime,emltgr.LastEndTime)
				,@EarliestSelectionDate            = isnull(@EarliestSelectionDate,emltgr.EarliestSelectionDate)
				,@IsActive                         = isnull(@IsActive,emltgr.IsActive)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,emltgr.UserDefinedColumns)
				,@EmailTriggerXID                  = isnull(@EmailTriggerXID,emltgr.EmailTriggerXID)
				,@LegacyKey                        = isnull(@LegacyKey,emltgr.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,emltgr.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,emltgr.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,emltgr.IsNullApplied)
				,@zContext                         = isnull(@zContext,emltgr.zContext)
				,@EmailTemplateLabel               = isnull(@EmailTemplateLabel,emltgr.EmailTemplateLabel)
				,@PriorityLevel                    = isnull(@PriorityLevel,emltgr.PriorityLevel)
				,@Subject                          = isnull(@Subject,emltgr.Subject)
				,@IsApplicationUserRequired        = isnull(@IsApplicationUserRequired,emltgr.IsApplicationUserRequired)
				,@LinkExpiryHours                  = isnull(@LinkExpiryHours,emltgr.LinkExpiryHours)
				,@ApplicationEntitySID             = isnull(@ApplicationEntitySID,emltgr.ApplicationEntitySID)
				,@ApplicationGrantSID              = isnull(@ApplicationGrantSID,emltgr.ApplicationGrantSID)
				,@EmailTemplateRowGUID             = isnull(@EmailTemplateRowGUID,emltgr.EmailTemplateRowGUID)
				,@QueryCategorySID                 = isnull(@QueryCategorySID,emltgr.QueryCategorySID)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,emltgr.ApplicationPageSID)
				,@QueryLabel                       = isnull(@QueryLabel,emltgr.QueryLabel)
				,@ToolTip                          = isnull(@ToolTip,emltgr.ToolTip)
				,@LastExecuteTime                  = isnull(@LastExecuteTime,emltgr.LastExecuteTime)
				,@LastExecuteUser                  = isnull(@LastExecuteUser,emltgr.LastExecuteUser)
				,@ExecuteCount                     = isnull(@ExecuteCount,emltgr.ExecuteCount)
				,@QueryCode                        = isnull(@QueryCode,emltgr.QueryCode)
				,@QueryIsActive                    = isnull(@QueryIsActive,emltgr.QueryIsActive)
				,@IsApplicationPageDefault         = isnull(@IsApplicationPageDefault,emltgr.IsApplicationPageDefault)
				,@QueryRowGUID                     = isnull(@QueryRowGUID,emltgr.QueryRowGUID)
				,@PersonSID                        = isnull(@PersonSID,emltgr.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,emltgr.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,emltgr.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,emltgr.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,emltgr.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,emltgr.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,emltgr.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,emltgr.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,emltgr.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,emltgr.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,emltgr.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,emltgr.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,emltgr.ApplicationUserRowGUID)
				,@JobScheduleLabel                 = isnull(@JobScheduleLabel,emltgr.JobScheduleLabel)
				,@IsEnabled                        = isnull(@IsEnabled,emltgr.IsEnabled)
				,@IsRunMonday                      = isnull(@IsRunMonday,emltgr.IsRunMonday)
				,@IsRunTuesday                     = isnull(@IsRunTuesday,emltgr.IsRunTuesday)
				,@IsRunWednesday                   = isnull(@IsRunWednesday,emltgr.IsRunWednesday)
				,@IsRunThursday                    = isnull(@IsRunThursday,emltgr.IsRunThursday)
				,@IsRunFriday                      = isnull(@IsRunFriday,emltgr.IsRunFriday)
				,@IsRunSaturday                    = isnull(@IsRunSaturday,emltgr.IsRunSaturday)
				,@IsRunSunday                      = isnull(@IsRunSunday,emltgr.IsRunSunday)
				,@RepeatIntervalMinutes            = isnull(@RepeatIntervalMinutes,emltgr.RepeatIntervalMinutes)
				,@StartTime                        = isnull(@StartTime,emltgr.StartTime)
				,@EndTime                          = isnull(@EndTime,emltgr.EndTime)
				,@StartDate                        = isnull(@StartDate,emltgr.StartDate)
				,@EndDate                          = isnull(@EndDate,emltgr.EndDate)
				,@JobScheduleRowGUID               = isnull(@JobScheduleRowGUID,emltgr.JobScheduleRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,emltgr.IsDeleteEnabled)
				,@LastDurationMinutes              = isnull(@LastDurationMinutes,emltgr.LastDurationMinutes)
				,@IsRunning                        = isnull(@IsRunning,emltgr.IsRunning)
				,@LastStartTimeClientTZ            = isnull(@LastStartTimeClientTZ,emltgr.LastStartTimeClientTZ)
				,@LastEndTimeClientTZ              = isnull(@LastEndTimeClientTZ,emltgr.LastEndTimeClientTZ)
				,@NextScheduledTime                = isnull(@NextScheduledTime,emltgr.NextScheduledTime)
				,@NextScheduledTimeServerTZ        = isnull(@NextScheduledTimeServerTZ,emltgr.NextScheduledTimeServerTZ)
			from
				sf.vEmailTrigger emltgr
			where
				emltgr.EmailTriggerSID = @EmailTriggerSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.EmailTrigger x where x.EmailTriggerSID = @EmailTriggerSID) <> @ApplicationUserSID
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
		
		if (select x.QuerySID from sf.EmailTrigger x where x.EmailTriggerSID = @EmailTriggerSID) <> @QuerySID
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
		-- Tim Edlund | Jul 2018
		-- When a trigger is being activated set the last start
		-- and end times to the current time unless a new
		-- @SelectionDate was provided

		if @IsActive = @ON and exists
		(
			select
				1
			from
				sf.EmailTrigger et
			where
				et.EmailTriggerSID = @EmailTriggerSID and et.IsActive = @OFF
		)
		begin
			set @LastStartTime = sysdatetimeoffset();
			set @LastEndTime = @LastStartTime;
		end;
	
		-- Cory Ng | Jun 2016
    -- Ensure the query selected returns 2 columns, first one being the
		-- record SID which is used to merge content for the email. The
		-- second being the person SID the email is going to.

		declare
			@test table
			(
				 RecordSID int null
				,PersonSID int null
			)

		if not exists																													-- only check if query has changed
		(
			select
				1
			from
				sf.EmailTrigger et
			where
				et.EmailTriggerSID = @EmailTriggerSID
			and
				et.QuerySID	= @QuerySID
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
				,@Arg1        = 'email'
				
				raiserror(@errorText, 18, 1)

			end catch

		end

		--! </PreUpdate>

		-- update the record

		update
			sf.EmailTrigger
		set
			 EmailTriggerLabel = @EmailTriggerLabel
			,EmailTemplateSID = @EmailTemplateSID
			,QuerySID = @QuerySID
			,MinDaysToRepeat = @MinDaysToRepeat
			,ApplicationUserSID = @ApplicationUserSID
			,JobScheduleSID = @JobScheduleSID
			,LastStartTime = @LastStartTime
			,LastEndTime = @LastEndTime
			,EarliestSelectionDate = @EarliestSelectionDate
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,EmailTriggerXID = @EmailTriggerXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			EmailTriggerSID = @EmailTriggerSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.EmailTrigger where EmailTriggerSID = @emailTriggerSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.EmailTrigger'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.EmailTrigger'
					,@Arg2        = @emailTriggerSID
				
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
				,@Arg2        = 'sf.EmailTrigger'
				,@Arg3        = @rowsAffected
				,@Arg4        = @emailTriggerSID
			
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
				 ent.EmailTriggerSID
			from
				sf.vEmailTrigger ent
			where
				ent.EmailTriggerSID = @EmailTriggerSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.EmailTriggerSID
				,ent.EmailTriggerLabel
				,ent.EmailTemplateSID
				,ent.QuerySID
				,ent.MinDaysToRepeat
				,ent.ApplicationUserSID
				,ent.JobScheduleSID
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.EarliestSelectionDate
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.EmailTriggerXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.EmailTemplateLabel
				,ent.PriorityLevel
				,ent.Subject
				,ent.IsApplicationUserRequired
				,ent.LinkExpiryHours
				,ent.ApplicationEntitySID
				,ent.ApplicationGrantSID
				,ent.EmailTemplateRowGUID
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
				sf.vEmailTrigger ent
			where
				ent.EmailTriggerSID = @EmailTriggerSID

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
