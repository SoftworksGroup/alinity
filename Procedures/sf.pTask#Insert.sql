SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTask#Insert]
	 @TaskSID                          int               = null output			-- identity value assigned to the new record
	,@TaskTitle                        nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@TaskQueueSID                     int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@TargetRowGUID                    uniqueidentifier  = null							
	,@TaskDescription                  varbinary(max)    = null							
	,@IsAlert                          bit               = null							-- default: (0)
	,@PriorityLevel                    tinyint           = null							-- default: (3)
	,@ApplicationUserSID               int               = null							
	,@TaskStatusSID                    int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@AssignedTime                     datetimeoffset(7) = null							
	,@DueDate                          date              = null							-- required! if not passed value must be set in custom logic prior to insert
	,@NextFollowUpDate                 date              = null							
	,@ClosedTime                       datetimeoffset(7) = null							
	,@ApplicationPageSID               int               = null							
	,@TaskTriggerSID                   int               = null							
	,@RecipientList                    xml               = null							-- default: CONVERT(xml,N'<Recipients />',(0))
	,@TagList                          xml               = null							-- default: CONVERT(xml,N'<Tags/>',(0))
	,@FileExtension                    varchar(5)        = null							-- default: '.html'
	,@UserDefinedColumns               xml               = null							
	,@TaskXID                          varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@TaskQueueLabel                   nvarchar(35)      = null							-- not a base table column (default ignored)
	,@TaskQueueCode                    varchar(30)       = null							-- not a base table column (default ignored)
	,@IsAutoAssigned                   bit               = null							-- not a base table column (default ignored)
	,@IsOpenSubscription               bit               = null							-- not a base table column (default ignored)
	,@TaskQueueApplicationUserSID      int               = null							-- not a base table column (default ignored)
	,@TaskQueueIsActive                bit               = null							-- not a base table column (default ignored)
	,@TaskQueueIsDefault               bit               = null							-- not a base table column (default ignored)
	,@TaskQueueRowGUID                 uniqueidentifier  = null							-- not a base table column (default ignored)
	,@TaskStatusSCD                    varchar(10)       = null							-- not a base table column (default ignored)
	,@TaskStatusLabel                  nvarchar(35)      = null							-- not a base table column (default ignored)
	,@TaskStatusSequence               int               = null							-- not a base table column (default ignored)
	,@IsDerived                        bit               = null							-- not a base table column (default ignored)
	,@IsClosedStatus                   bit               = null							-- not a base table column (default ignored)
	,@TaskStatusIsActive               bit               = null							-- not a base table column (default ignored)
	,@TaskStatusIsDefault              bit               = null							-- not a base table column (default ignored)
	,@TaskStatusRowGUID                uniqueidentifier  = null							-- not a base table column (default ignored)
	,@TaskTriggerLabel                 nvarchar(35)      = null							-- not a base table column (default ignored)
	,@TaskTitleTemplate                nvarchar(65)      = null							-- not a base table column (default ignored)
	,@QuerySID                         int               = null							-- not a base table column (default ignored)
	,@TaskTriggerTaskQueueSID          int               = null							-- not a base table column (default ignored)
	,@TaskTriggerApplicationUserSID    int               = null							-- not a base table column (default ignored)
	,@TaskTriggerIsAlert               bit               = null							-- not a base table column (default ignored)
	,@TaskTriggerPriorityLevel         tinyint           = null							-- not a base table column (default ignored)
	,@TargetCompletionDays             smallint          = null							-- not a base table column (default ignored)
	,@OpenTaskLimit                    int               = null							-- not a base table column (default ignored)
	,@IsRegeneratedIfClosed            bit               = null							-- not a base table column (default ignored)
	,@ApplicationAction                varchar(75)       = null							-- not a base table column (default ignored)
	,@JobScheduleSID                   int               = null							-- not a base table column (default ignored)
	,@LastStartTime                    datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastEndTime                      datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@TaskTriggerIsActive              bit               = null							-- not a base table column (default ignored)
	,@TaskTriggerRowGUID               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ApplicationPageLabel             nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ApplicationPageURI               varchar(150)      = null							-- not a base table column (default ignored)
	,@ApplicationRoute                 varchar(150)      = null							-- not a base table column (default ignored)
	,@IsSearchPage                     bit               = null							-- not a base table column (default ignored)
	,@ApplicationEntitySID             int               = null							-- not a base table column (default ignored)
	,@ApplicationPageRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
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
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@IsOverdue                        bit               = null							-- not a base table column (default ignored)
	,@IsOpen                           bit               = null							-- not a base table column (default ignored)
	,@IsCancelled                      bit               = null							-- not a base table column (default ignored)
	,@IsClosed                         bit               = null							-- not a base table column (default ignored)
	,@IsTaskTakeOverEnabled            bit               = null							-- not a base table column (default ignored)
	,@IsCloseEnabled                   bit               = null							-- not a base table column (default ignored)
	,@IsUpdateEnabled                  bit               = null							-- not a base table column (default ignored)
	,@IsClosedWithinADay               bit               = null							-- not a base table column (default ignored)
	,@EntityLabel                      nvarchar(250)     = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pTask#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.Task table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.Task table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vTask entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTask procedure. The extended procedure is only called
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

	set @TaskSID = null																											-- initialize output parameter

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

		set @TaskTitle = ltrim(rtrim(@TaskTitle))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @TaskXID = ltrim(rtrim(@TaskXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsAlert = isnull(@IsAlert,(0))
		set @PriorityLevel = isnull(@PriorityLevel,(3))
		set @RecipientList = isnull(@RecipientList,CONVERT(xml,N'<Recipients />',(0)))
		set @TagList = isnull(@TagList,CONVERT(xml,N'<Tags/>',(0)))
		set @FileExtension = isnull(@FileExtension,'.html')
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))
		
		if @IsClosed = @ON and @ClosedTime is null set @ClosedTime = sysdatetimeoffset()								-- set column when null and extended view bit is passed to set it
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @TaskStatusSCD is not null
		begin
		
			select
				@TaskStatusSID = x.TaskStatusSID
			from
				sf.TaskStatus x
			where
				x.TaskStatusSCD = @TaskStatusSCD
		
		end
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the tags applied (if any)
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @TaskQueueSID   is null select @TaskQueueSID   = x.TaskQueueSID  from sf.TaskQueue   x where x.IsDefault = @ON
		if @TaskStatusSID  is null select @TaskStatusSID  = x.TaskStatusSID from sf.TaskStatus  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Cory Ng | June 2013
    -- When the task is assigned to a application user automatically set the assigned time

		if @ApplicationUserSID is not null
		begin
			set @AssignedTime = sysdatetimeoffset()
		end
		--! </PreInsert>

		-- insert the record

		insert
			sf.Task
		(
			 TaskTitle
			,TaskQueueSID
			,TargetRowGUID
			,TaskDescription
			,IsAlert
			,PriorityLevel
			,ApplicationUserSID
			,TaskStatusSID
			,AssignedTime
			,DueDate
			,NextFollowUpDate
			,ClosedTime
			,ApplicationPageSID
			,TaskTriggerSID
			,RecipientList
			,TagList
			,FileExtension
			,UserDefinedColumns
			,TaskXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @TaskTitle
			,@TaskQueueSID
			,@TargetRowGUID
			,@TaskDescription
			,@IsAlert
			,@PriorityLevel
			,@ApplicationUserSID
			,@TaskStatusSID
			,@AssignedTime
			,@DueDate
			,@NextFollowUpDate
			,@ClosedTime
			,@ApplicationPageSID
			,@TaskTriggerSID
			,@RecipientList
			,@TagList
			,@FileExtension
			,@UserDefinedColumns
			,@TaskXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@TaskSID = scope_identity()																				-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.Task'
				,@Arg3        = @rowsAffected
				,@Arg4        = @TaskSID
			
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
