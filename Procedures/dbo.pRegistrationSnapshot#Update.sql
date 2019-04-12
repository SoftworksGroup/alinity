SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationSnapshot#Update]
	 @RegistrationSnapshotSID           int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationSnapshotTypeSID       int               = null -- table column values to update:
	,@RegistrationSnapshotLabel         nvarchar(35)      = null
	,@RegistrationYear                  smallint          = null
	,@Description                       nvarchar(max)     = null
	,@QueuedTime                        datetimeoffset(7) = null
	,@LockedTime                        datetimeoffset(7) = null
	,@LastCodeUpdateTime                datetimeoffset(7) = null
	,@LastVerifiedTime                  datetimeoffset(7) = null
	,@JobRunSID                         int               = null
	,@UserDefinedColumns                xml               = null
	,@RegistrationSnapshotXID           varchar(150)      = null
	,@LegacyKey                         nvarchar(50)      = null
	,@UpdateUser                        nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                          timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                      tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                     bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                          xml               = null -- other values defining context for the update (if any)
	,@RegistrationSnapshotTypeLabel     nvarchar(35)      = null -- not a base table column
	,@RegistrationSnapshotTypeSCD       varchar(15)       = null -- not a base table column
	,@RegistrationSnapshotLabelTemplate nvarchar(50)      = null -- not a base table column
	,@RegistrationSnapshotTypeIsDefault bit               = null -- not a base table column
	,@RegistrationSnapshotTypeIsActive  bit               = null -- not a base table column
	,@RegistrationSnapshotTypeRowGUID   uniqueidentifier  = null -- not a base table column
	,@JobSID                            int               = null -- not a base table column
	,@ConversationHandle                uniqueidentifier  = null -- not a base table column
	,@StartTime                         datetimeoffset(7) = null -- not a base table column
	,@EndTime                           datetimeoffset(7) = null -- not a base table column
	,@TotalRecords                      int               = null -- not a base table column
	,@TotalErrors                       int               = null -- not a base table column
	,@RecordsProcessed                  int               = null -- not a base table column
	,@CurrentProcessLabel               nvarchar(35)      = null -- not a base table column
	,@IsFailed                          bit               = null -- not a base table column
	,@IsFailureCleared                  bit               = null -- not a base table column
	,@CancellationRequestTime           datetimeoffset(7) = null -- not a base table column
	,@IsCancelled                       bit               = null -- not a base table column
	,@JobRunRowGUID                     uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                   bit               = null -- not a base table column
	,@IsLocked                          bit               = null -- not a base table column
	,@IsLockEnabled                     bit               = null -- not a base table column
	,@IsUnlockEnabled                   bit               = null -- not a base table column
	,@IsUpdateEnabled                   bit               = null -- not a base table column
	,@ProfileCount                      int               = null -- not a base table column
	,@InValidCount                      int               = null -- not a base table column
	,@ModifiedCount                     int               = null -- not a base table column
	,@QueuedDateCTZ                     date              = null -- not a base table column
	,@QueuedTimeCTZ                     time(7)           = null -- not a base table column
	,@QueuedDateTimeCTZ                 datetime          = null -- not a base table column
	,@RegistrationYearLabel             varchar(25)       = null -- not a base table column
	,@SnapshotStatusLabel               nvarchar(35)      = null -- not a base table column
	,@LastCodeUpdateStatus              nvarchar(4000)    = null -- not a base table column
	,@LastVerifiedStatus                nvarchar(4000)    = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationSnapshot#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrationSnapshot table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrationSnapshot table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrationSnapshot entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationSnapshot procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationSnapshotCheck to test all rules.

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

		if @RegistrationSnapshotSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationSnapshotSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrationSnapshotLabel = ltrim(rtrim(@RegistrationSnapshotLabel))
		set @Description = ltrim(rtrim(@Description))
		set @RegistrationSnapshotXID = ltrim(rtrim(@RegistrationSnapshotXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @RegistrationSnapshotTypeLabel = ltrim(rtrim(@RegistrationSnapshotTypeLabel))
		set @RegistrationSnapshotTypeSCD = ltrim(rtrim(@RegistrationSnapshotTypeSCD))
		set @RegistrationSnapshotLabelTemplate = ltrim(rtrim(@RegistrationSnapshotLabelTemplate))
		set @CurrentProcessLabel = ltrim(rtrim(@CurrentProcessLabel))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))
		set @SnapshotStatusLabel = ltrim(rtrim(@SnapshotStatusLabel))
		set @LastCodeUpdateStatus = ltrim(rtrim(@LastCodeUpdateStatus))
		set @LastVerifiedStatus = ltrim(rtrim(@LastVerifiedStatus))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrationSnapshotLabel) = 0 set @RegistrationSnapshotLabel = null
		if len(@Description) = 0 set @Description = null
		if len(@RegistrationSnapshotXID) = 0 set @RegistrationSnapshotXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@RegistrationSnapshotTypeLabel) = 0 set @RegistrationSnapshotTypeLabel = null
		if len(@RegistrationSnapshotTypeSCD) = 0 set @RegistrationSnapshotTypeSCD = null
		if len(@RegistrationSnapshotLabelTemplate) = 0 set @RegistrationSnapshotLabelTemplate = null
		if len(@CurrentProcessLabel) = 0 set @CurrentProcessLabel = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@SnapshotStatusLabel) = 0 set @SnapshotStatusLabel = null
		if len(@LastCodeUpdateStatus) = 0 set @LastCodeUpdateStatus = null
		if len(@LastVerifiedStatus) = 0 set @LastVerifiedStatus = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationSnapshotTypeSID       = isnull(@RegistrationSnapshotTypeSID,rs.RegistrationSnapshotTypeSID)
				,@RegistrationSnapshotLabel         = isnull(@RegistrationSnapshotLabel,rs.RegistrationSnapshotLabel)
				,@RegistrationYear                  = isnull(@RegistrationYear,rs.RegistrationYear)
				,@Description                       = isnull(@Description,rs.Description)
				,@QueuedTime                        = isnull(@QueuedTime,rs.QueuedTime)
				,@LockedTime                        = isnull(@LockedTime,rs.LockedTime)
				,@LastCodeUpdateTime                = isnull(@LastCodeUpdateTime,rs.LastCodeUpdateTime)
				,@LastVerifiedTime                  = isnull(@LastVerifiedTime,rs.LastVerifiedTime)
				,@JobRunSID                         = isnull(@JobRunSID,rs.JobRunSID)
				,@UserDefinedColumns                = isnull(@UserDefinedColumns,rs.UserDefinedColumns)
				,@RegistrationSnapshotXID           = isnull(@RegistrationSnapshotXID,rs.RegistrationSnapshotXID)
				,@LegacyKey                         = isnull(@LegacyKey,rs.LegacyKey)
				,@UpdateUser                        = isnull(@UpdateUser,rs.UpdateUser)
				,@IsReselected                      = isnull(@IsReselected,rs.IsReselected)
				,@IsNullApplied                     = isnull(@IsNullApplied,rs.IsNullApplied)
				,@zContext                          = isnull(@zContext,rs.zContext)
				,@RegistrationSnapshotTypeLabel     = isnull(@RegistrationSnapshotTypeLabel,rs.RegistrationSnapshotTypeLabel)
				,@RegistrationSnapshotTypeSCD       = isnull(@RegistrationSnapshotTypeSCD,rs.RegistrationSnapshotTypeSCD)
				,@RegistrationSnapshotLabelTemplate = isnull(@RegistrationSnapshotLabelTemplate,rs.RegistrationSnapshotLabelTemplate)
				,@RegistrationSnapshotTypeIsDefault = isnull(@RegistrationSnapshotTypeIsDefault,rs.RegistrationSnapshotTypeIsDefault)
				,@RegistrationSnapshotTypeIsActive  = isnull(@RegistrationSnapshotTypeIsActive,rs.RegistrationSnapshotTypeIsActive)
				,@RegistrationSnapshotTypeRowGUID   = isnull(@RegistrationSnapshotTypeRowGUID,rs.RegistrationSnapshotTypeRowGUID)
				,@JobSID                            = isnull(@JobSID,rs.JobSID)
				,@ConversationHandle                = isnull(@ConversationHandle,rs.ConversationHandle)
				,@StartTime                         = isnull(@StartTime,rs.StartTime)
				,@EndTime                           = isnull(@EndTime,rs.EndTime)
				,@TotalRecords                      = isnull(@TotalRecords,rs.TotalRecords)
				,@TotalErrors                       = isnull(@TotalErrors,rs.TotalErrors)
				,@RecordsProcessed                  = isnull(@RecordsProcessed,rs.RecordsProcessed)
				,@CurrentProcessLabel               = isnull(@CurrentProcessLabel,rs.CurrentProcessLabel)
				,@IsFailed                          = isnull(@IsFailed,rs.IsFailed)
				,@IsFailureCleared                  = isnull(@IsFailureCleared,rs.IsFailureCleared)
				,@CancellationRequestTime           = isnull(@CancellationRequestTime,rs.CancellationRequestTime)
				,@IsCancelled                       = isnull(@IsCancelled,rs.IsCancelled)
				,@JobRunRowGUID                     = isnull(@JobRunRowGUID,rs.JobRunRowGUID)
				,@IsDeleteEnabled                   = isnull(@IsDeleteEnabled,rs.IsDeleteEnabled)
				,@IsLocked                          = isnull(@IsLocked,rs.IsLocked)
				,@IsLockEnabled                     = isnull(@IsLockEnabled,rs.IsLockEnabled)
				,@IsUnlockEnabled                   = isnull(@IsUnlockEnabled,rs.IsUnlockEnabled)
				,@IsUpdateEnabled                   = isnull(@IsUpdateEnabled,rs.IsUpdateEnabled)
				,@ProfileCount                      = isnull(@ProfileCount,rs.ProfileCount)
				,@InValidCount                      = isnull(@InValidCount,rs.InValidCount)
				,@ModifiedCount                     = isnull(@ModifiedCount,rs.ModifiedCount)
				,@QueuedDateCTZ                     = isnull(@QueuedDateCTZ,rs.QueuedDateCTZ)
				,@QueuedTimeCTZ                     = isnull(@QueuedTimeCTZ,rs.QueuedTimeCTZ)
				,@QueuedDateTimeCTZ                 = isnull(@QueuedDateTimeCTZ,rs.QueuedDateTimeCTZ)
				,@RegistrationYearLabel             = isnull(@RegistrationYearLabel,rs.RegistrationYearLabel)
				,@SnapshotStatusLabel               = isnull(@SnapshotStatusLabel,rs.SnapshotStatusLabel)
				,@LastCodeUpdateStatus              = isnull(@LastCodeUpdateStatus,rs.LastCodeUpdateStatus)
				,@LastVerifiedStatus                = isnull(@LastVerifiedStatus,rs.LastVerifiedStatus)
			from
				dbo.vRegistrationSnapshot rs
			where
				rs.RegistrationSnapshotSID = @RegistrationSnapshotSID

		end
		
		if @IsLocked = @ON and @LockedTime is null set @LockedTime = sysdatetimeoffset()								-- set column when null and extended view bit is passed to set it
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @RegistrationSnapshotTypeSCD is not null and @RegistrationSnapshotTypeSID = (select x.RegistrationSnapshotTypeSID from dbo.RegistrationSnapshot x where x.RegistrationSnapshotSID = @RegistrationSnapshotSID)
		begin
		
			select
				@RegistrationSnapshotTypeSID = x.RegistrationSnapshotTypeSID
			from
				dbo.RegistrationSnapshotType x
			where
				x.RegistrationSnapshotTypeSCD = @RegistrationSnapshotTypeSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.RegistrationSnapshotTypeSID from dbo.RegistrationSnapshot x where x.RegistrationSnapshotSID = @RegistrationSnapshotSID) <> @RegistrationSnapshotTypeSID
		begin
			if (select x.IsActive from dbo.RegistrationSnapshotType x where x.RegistrationSnapshotTypeSID = @RegistrationSnapshotTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'registration snapshot type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Jul 2018
		-- Ensure the registration year matches the queued time.

		set @RegistrationYear = dbo.fRegistrationYear(sf.fDTOffsetToClientDateTime(@QueuedTime))

		-- Tim Edlund | Jul 2018
		-- Until the snapshot is processed, allow the end user
		-- to edit the queued time with the separate date
		-- and time components

		if @JobRunSID is null and not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID
		)
		begin

			if (
					 @QueuedDateCTZ is not null and @QueuedTimeCTZ is null
				 ) or
					 (
						 @QueuedTimeCTZ is not null and @QueuedDateCTZ is null
					 )
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'BothOrNeither'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Both a %1 and %2 must be provided (or leave both blank).'
				 ,@Arg1 = N'queued date'
				 ,@Arg2 = N'queued time';

				raiserror(@errorText, 16, 1);
			end;

			if @QueuedDateCTZ is not null
			begin
				set @QueuedTime = sf.fClientDateTimeToDTOffset(sf.fDatePlusTimeToDT(@QueuedDateCTZ, @QueuedTimeCTZ));
			end;

			if datediff(minute, @QueuedTime, sysdatetime()) > 1
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NotInThePast'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 cannot be in the past.'
				 ,@Arg1 = N'queued time';

				raiserror(@errorText, 16, 1);

			end;

		end;

		-- Tim Edlund | Jul 2018
		-- The queued time cannot be edited after a job has
		-- been assigned or there are any profile records

		if exists
		(
			select
				1
			from
				dbo.RegistrationSnapshot rs
			where
				rs.RegistrationSnapshotSID																	= @RegistrationSnapshotSID
				and
				(
					sf.fIsDifferent(rs.QueuedTime, @QueuedTime) = @ON
				)
		)
		begin

			if exists
			(
				select
					1
				from
					dbo.RegistrationProfile rp
				where
					rp.RegistrationSnapshotSID = @RegistrationSnapshotSID
			) or @JobRunSID is not null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'EditNotAllowed'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 cannot be edited %2.'
				 ,@Arg1 = N'queued time'
				 ,@Arg2 = N'after the snapshot is created';

				raiserror(@errorText, 16, 1);

			end;

		end;
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrationSnapshot'
		)
		begin
		
			exec @errorNo = ext.pRegistrationSnapshot
				 @Mode                              = 'update.pre'
				,@RegistrationSnapshotSID           = @RegistrationSnapshotSID
				,@RegistrationSnapshotTypeSID       = @RegistrationSnapshotTypeSID output
				,@RegistrationSnapshotLabel         = @RegistrationSnapshotLabel output
				,@RegistrationYear                  = @RegistrationYear output
				,@Description                       = @Description output
				,@QueuedTime                        = @QueuedTime output
				,@LockedTime                        = @LockedTime output
				,@LastCodeUpdateTime                = @LastCodeUpdateTime output
				,@LastVerifiedTime                  = @LastVerifiedTime output
				,@JobRunSID                         = @JobRunSID output
				,@UserDefinedColumns                = @UserDefinedColumns output
				,@RegistrationSnapshotXID           = @RegistrationSnapshotXID output
				,@LegacyKey                         = @LegacyKey output
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
				,@zContext                          = @zContext
				,@RegistrationSnapshotTypeLabel     = @RegistrationSnapshotTypeLabel
				,@RegistrationSnapshotTypeSCD       = @RegistrationSnapshotTypeSCD
				,@RegistrationSnapshotLabelTemplate = @RegistrationSnapshotLabelTemplate
				,@RegistrationSnapshotTypeIsDefault = @RegistrationSnapshotTypeIsDefault
				,@RegistrationSnapshotTypeIsActive  = @RegistrationSnapshotTypeIsActive
				,@RegistrationSnapshotTypeRowGUID   = @RegistrationSnapshotTypeRowGUID
				,@JobSID                            = @JobSID
				,@ConversationHandle                = @ConversationHandle
				,@StartTime                         = @StartTime
				,@EndTime                           = @EndTime
				,@TotalRecords                      = @TotalRecords
				,@TotalErrors                       = @TotalErrors
				,@RecordsProcessed                  = @RecordsProcessed
				,@CurrentProcessLabel               = @CurrentProcessLabel
				,@IsFailed                          = @IsFailed
				,@IsFailureCleared                  = @IsFailureCleared
				,@CancellationRequestTime           = @CancellationRequestTime
				,@IsCancelled                       = @IsCancelled
				,@JobRunRowGUID                     = @JobRunRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@IsLocked                          = @IsLocked
				,@IsLockEnabled                     = @IsLockEnabled
				,@IsUnlockEnabled                   = @IsUnlockEnabled
				,@IsUpdateEnabled                   = @IsUpdateEnabled
				,@ProfileCount                      = @ProfileCount
				,@InValidCount                      = @InValidCount
				,@ModifiedCount                     = @ModifiedCount
				,@QueuedDateCTZ                     = @QueuedDateCTZ
				,@QueuedTimeCTZ                     = @QueuedTimeCTZ
				,@QueuedDateTimeCTZ                 = @QueuedDateTimeCTZ
				,@RegistrationYearLabel             = @RegistrationYearLabel
				,@SnapshotStatusLabel               = @SnapshotStatusLabel
				,@LastCodeUpdateStatus              = @LastCodeUpdateStatus
				,@LastVerifiedStatus                = @LastVerifiedStatus
		
		end

		-- update the record

		update
			dbo.RegistrationSnapshot
		set
			 RegistrationSnapshotTypeSID = @RegistrationSnapshotTypeSID
			,RegistrationSnapshotLabel = @RegistrationSnapshotLabel
			,RegistrationYear = @RegistrationYear
			,Description = @Description
			,QueuedTime = @QueuedTime
			,LockedTime = @LockedTime
			,LastCodeUpdateTime = @LastCodeUpdateTime
			,LastVerifiedTime = @LastVerifiedTime
			,JobRunSID = @JobRunSID
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrationSnapshotXID = @RegistrationSnapshotXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationSnapshotSID = @RegistrationSnapshotSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationSnapshot where RegistrationSnapshotSID = @registrationSnapshotSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationSnapshot'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationSnapshot'
					,@Arg2        = @registrationSnapshotSID
				
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
				,@Arg2        = 'dbo.RegistrationSnapshot'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationSnapshotSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
	
		-- call the extended version of the procedure for update.post - if it exists
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrationSnapshot'
		)
		begin
		
			exec @errorNo = ext.pRegistrationSnapshot
				 @Mode                              = 'update.post'
				,@RegistrationSnapshotSID           = @RegistrationSnapshotSID
				,@RegistrationSnapshotTypeSID       = @RegistrationSnapshotTypeSID
				,@RegistrationSnapshotLabel         = @RegistrationSnapshotLabel
				,@RegistrationYear                  = @RegistrationYear
				,@Description                       = @Description
				,@QueuedTime                        = @QueuedTime
				,@LockedTime                        = @LockedTime
				,@LastCodeUpdateTime                = @LastCodeUpdateTime
				,@LastVerifiedTime                  = @LastVerifiedTime
				,@JobRunSID                         = @JobRunSID
				,@UserDefinedColumns                = @UserDefinedColumns
				,@RegistrationSnapshotXID           = @RegistrationSnapshotXID
				,@LegacyKey                         = @LegacyKey
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
				,@zContext                          = @zContext
				,@RegistrationSnapshotTypeLabel     = @RegistrationSnapshotTypeLabel
				,@RegistrationSnapshotTypeSCD       = @RegistrationSnapshotTypeSCD
				,@RegistrationSnapshotLabelTemplate = @RegistrationSnapshotLabelTemplate
				,@RegistrationSnapshotTypeIsDefault = @RegistrationSnapshotTypeIsDefault
				,@RegistrationSnapshotTypeIsActive  = @RegistrationSnapshotTypeIsActive
				,@RegistrationSnapshotTypeRowGUID   = @RegistrationSnapshotTypeRowGUID
				,@JobSID                            = @JobSID
				,@ConversationHandle                = @ConversationHandle
				,@StartTime                         = @StartTime
				,@EndTime                           = @EndTime
				,@TotalRecords                      = @TotalRecords
				,@TotalErrors                       = @TotalErrors
				,@RecordsProcessed                  = @RecordsProcessed
				,@CurrentProcessLabel               = @CurrentProcessLabel
				,@IsFailed                          = @IsFailed
				,@IsFailureCleared                  = @IsFailureCleared
				,@CancellationRequestTime           = @CancellationRequestTime
				,@IsCancelled                       = @IsCancelled
				,@JobRunRowGUID                     = @JobRunRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@IsLocked                          = @IsLocked
				,@IsLockEnabled                     = @IsLockEnabled
				,@IsUnlockEnabled                   = @IsUnlockEnabled
				,@IsUpdateEnabled                   = @IsUpdateEnabled
				,@ProfileCount                      = @ProfileCount
				,@InValidCount                      = @InValidCount
				,@ModifiedCount                     = @ModifiedCount
				,@QueuedDateCTZ                     = @QueuedDateCTZ
				,@QueuedTimeCTZ                     = @QueuedTimeCTZ
				,@QueuedDateTimeCTZ                 = @QueuedDateTimeCTZ
				,@RegistrationYearLabel             = @RegistrationYearLabel
				,@SnapshotStatusLabel               = @SnapshotStatusLabel
				,@LastCodeUpdateStatus              = @LastCodeUpdateStatus
				,@LastVerifiedStatus                = @LastVerifiedStatus
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationSnapshotSID
			from
				dbo.vRegistrationSnapshot ent
			where
				ent.RegistrationSnapshotSID = @RegistrationSnapshotSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationSnapshotSID
				,ent.RegistrationSnapshotTypeSID
				,ent.RegistrationSnapshotLabel
				,ent.RegistrationYear
				,ent.Description
				,ent.QueuedTime
				,ent.LockedTime
				,ent.LastCodeUpdateTime
				,ent.LastVerifiedTime
				,ent.JobRunSID
				,ent.UserDefinedColumns
				,ent.RegistrationSnapshotXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrationSnapshotTypeLabel
				,ent.RegistrationSnapshotTypeSCD
				,ent.RegistrationSnapshotLabelTemplate
				,ent.RegistrationSnapshotTypeIsDefault
				,ent.RegistrationSnapshotTypeIsActive
				,ent.RegistrationSnapshotTypeRowGUID
				,ent.JobSID
				,ent.ConversationHandle
				,ent.StartTime
				,ent.EndTime
				,ent.TotalRecords
				,ent.TotalErrors
				,ent.RecordsProcessed
				,ent.CurrentProcessLabel
				,ent.IsFailed
				,ent.IsFailureCleared
				,ent.CancellationRequestTime
				,ent.IsCancelled
				,ent.JobRunRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsLocked
				,ent.IsLockEnabled
				,ent.IsUnlockEnabled
				,ent.IsUpdateEnabled
				,ent.ProfileCount
				,ent.InValidCount
				,ent.ModifiedCount
				,ent.QueuedDateCTZ
				,ent.QueuedTimeCTZ
				,ent.QueuedDateTimeCTZ
				,ent.RegistrationYearLabel
				,ent.SnapshotStatusLabel
				,ent.LastCodeUpdateStatus
				,ent.LastVerifiedStatus
			from
				dbo.vRegistrationSnapshot ent
			where
				ent.RegistrationSnapshotSID = @RegistrationSnapshotSID

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
