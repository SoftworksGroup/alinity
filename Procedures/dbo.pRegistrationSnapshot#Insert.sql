SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationSnapshot#Insert]
	 @RegistrationSnapshotSID           int               = null output			-- identity value assigned to the new record
	,@RegistrationSnapshotTypeSID       int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationSnapshotLabel         nvarchar(35)      = null						-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                  smallint          = null						-- default: dbo.fRegistrationYear#Current()
	,@Description                       nvarchar(max)     = null						
	,@QueuedTime                        datetimeoffset(7) = null						-- default: sysdatetimeoffset()
	,@LockedTime                        datetimeoffset(7) = null						
	,@LastCodeUpdateTime                datetimeoffset(7) = null						
	,@LastVerifiedTime                  datetimeoffset(7) = null						
	,@JobRunSID                         int               = null						
	,@UserDefinedColumns                xml               = null						
	,@RegistrationSnapshotXID           varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@RegistrationSnapshotTypeLabel     nvarchar(35)      = null						-- not a base table column (default ignored)
	,@RegistrationSnapshotTypeSCD       varchar(15)       = null						-- not a base table column (default ignored)
	,@RegistrationSnapshotLabelTemplate nvarchar(50)      = null						-- not a base table column (default ignored)
	,@RegistrationSnapshotTypeIsDefault bit               = null						-- not a base table column (default ignored)
	,@RegistrationSnapshotTypeIsActive  bit               = null						-- not a base table column (default ignored)
	,@RegistrationSnapshotTypeRowGUID   uniqueidentifier  = null						-- not a base table column (default ignored)
	,@JobSID                            int               = null						-- not a base table column (default ignored)
	,@ConversationHandle                uniqueidentifier  = null						-- not a base table column (default ignored)
	,@StartTime                         datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@EndTime                           datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@TotalRecords                      int               = null						-- not a base table column (default ignored)
	,@TotalErrors                       int               = null						-- not a base table column (default ignored)
	,@RecordsProcessed                  int               = null						-- not a base table column (default ignored)
	,@CurrentProcessLabel               nvarchar(35)      = null						-- not a base table column (default ignored)
	,@IsFailed                          bit               = null						-- not a base table column (default ignored)
	,@IsFailureCleared                  bit               = null						-- not a base table column (default ignored)
	,@CancellationRequestTime           datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@IsCancelled                       bit               = null						-- not a base table column (default ignored)
	,@JobRunRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsLocked                          bit               = null						-- not a base table column (default ignored)
	,@IsLockEnabled                     bit               = null						-- not a base table column (default ignored)
	,@IsUnlockEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsUpdateEnabled                   bit               = null						-- not a base table column (default ignored)
	,@ProfileCount                      int               = null						-- not a base table column (default ignored)
	,@InValidCount                      int               = null						-- not a base table column (default ignored)
	,@ModifiedCount                     int               = null						-- not a base table column (default ignored)
	,@QueuedDateCTZ                     date              = null						-- not a base table column (default ignored)
	,@QueuedTimeCTZ                     time(7)           = null						-- not a base table column (default ignored)
	,@QueuedDateTimeCTZ                 datetime          = null						-- not a base table column (default ignored)
	,@RegistrationYearLabel             varchar(25)       = null						-- not a base table column (default ignored)
	,@SnapshotStatusLabel               nvarchar(35)      = null						-- not a base table column (default ignored)
	,@LastCodeUpdateStatus              nvarchar(4000)    = null						-- not a base table column (default ignored)
	,@LastVerifiedStatus                nvarchar(4000)    = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationSnapshot#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrationSnapshot table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationSnapshot table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrationSnapshot entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationSnapshot procedure. The extended procedure is only called
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

	set @RegistrationSnapshotSID = null																			-- initialize output parameter

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

		set @RegistrationSnapshotLabel = ltrim(rtrim(@RegistrationSnapshotLabel))
		set @Description = ltrim(rtrim(@Description))
		set @RegistrationSnapshotXID = ltrim(rtrim(@RegistrationSnapshotXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@RegistrationSnapshotTypeLabel) = 0 set @RegistrationSnapshotTypeLabel = null
		if len(@RegistrationSnapshotTypeSCD) = 0 set @RegistrationSnapshotTypeSCD = null
		if len(@RegistrationSnapshotLabelTemplate) = 0 set @RegistrationSnapshotLabelTemplate = null
		if len(@CurrentProcessLabel) = 0 set @CurrentProcessLabel = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@SnapshotStatusLabel) = 0 set @SnapshotStatusLabel = null
		if len(@LastCodeUpdateStatus) = 0 set @LastCodeUpdateStatus = null
		if len(@LastVerifiedStatus) = 0 set @LastVerifiedStatus = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RegistrationYear = isnull(@RegistrationYear,dbo.fRegistrationYear#Current())
		set @QueuedTime = isnull(@QueuedTime,sysdatetimeoffset())
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                = isnull(@IsReselected               ,(0))
		
		if @IsLocked = @ON and @LockedTime is null set @LockedTime = sysdatetimeoffset()								-- set column when null and extended view bit is passed to set it
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @RegistrationSnapshotTypeSCD is not null
		begin
		
			select
				@RegistrationSnapshotTypeSID = x.RegistrationSnapshotTypeSID
			from
				dbo.RegistrationSnapshotType x
			where
				x.RegistrationSnapshotTypeSCD = @RegistrationSnapshotTypeSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @RegistrationSnapshotTypeSID  is null select @RegistrationSnapshotTypeSID  = x.RegistrationSnapshotTypeSID from dbo.RegistrationSnapshotType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Jul 2018
		-- The queued time defaults to the current time

		if @QueuedTime is null
		begin
			set @QueuedTime = sysdatetimeoffset()
		end

		-- Tim Edlund | Jul 2018
		-- Always set the registration year to the current year
		-- even where provided - it must match the queued time

		set @RegistrationYear = dbo.fRegistrationYear(sf.fDTOffsetToClientDateTime(@QueuedTime))

		-- Tim Edlund | Jul 2018
		-- Set the queued time to the date + time components
		-- where provided by the UI

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

		-- Tim Edlund | Jul 2018
		-- Default the label based on the template if
		-- specified for this type.  The queued time
		-- is used as a replacement for "{DATE}"

		declare
			@i int = 1
		 ,@j int;

		if @RegistrationSnapshotLabel is null
		begin

			select
				@RegistrationSnapshotLabel = replace(rst.RegistrationSnapshotLabelTemplate, '{DATE}', format(sf.fDTOffsetToClientDate(@QueuedTime), 'yyyyMMdd'))
			from
				dbo.RegistrationSnapshotType rst
			where
				rst.RegistrationSnapshotTypeSID = @RegistrationSnapshotTypeSID;

		end
		else 			-- replace current date on label with new queued time date where found
		begin
			set @RegistrationSnapshotLabel = replace(@RegistrationSnapshotLabel, format(sf.fToday(), 'yyyyMMdd'), format(sf.fDTOffsetToClientDate(@QueuedTime), 'yyyyMMdd'))
			set @j = charindex('(', @RegistrationSnapshotLabel);
			if @j - 1 > 0 set @RegistrationSnapshotLabel = left(@RegistrationSnapshotLabel, @j - 1)
		end

		-- Tim Edlund | Jul 2018
		-- If the label exists - extend with a counter

		while exists
					(
						select
							1
						from
							dbo.RegistrationSnapshot rs
						where
							rs.RegistrationSnapshotLabel = @RegistrationSnapshotLabel
					) and @i < 100
		begin

			set @i += 1;
			set @j = charindex('(', @RegistrationSnapshotLabel);

			if @j - 1 > 0
			begin
				set @RegistrationSnapshotLabel = left(@RegistrationSnapshotLabel, @j - 1);
			end;

			set @RegistrationSnapshotLabel = ltrim(rtrim(@RegistrationSnapshotLabel)) + ' (' + ltrim(@i) + ')';

		end;
		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
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
				 @Mode                              = 'insert.pre'
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
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
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

		-- insert the record

		insert
			dbo.RegistrationSnapshot
		(
			 RegistrationSnapshotTypeSID
			,RegistrationSnapshotLabel
			,RegistrationYear
			,Description
			,QueuedTime
			,LockedTime
			,LastCodeUpdateTime
			,LastVerifiedTime
			,JobRunSID
			,UserDefinedColumns
			,RegistrationSnapshotXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationSnapshotTypeSID
			,@RegistrationSnapshotLabel
			,@RegistrationYear
			,@Description
			,@QueuedTime
			,@LockedTime
			,@LastCodeUpdateTime
			,@LastVerifiedTime
			,@JobRunSID
			,@UserDefinedColumns
			,@RegistrationSnapshotXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@RegistrationSnapshotSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrationSnapshot'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationSnapshotSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | JUl 2018
		-- If the queued time is now, call the creation
		-- job asynchronously as long as the service
		-- has not already picked it up (assigns JobRunSID)

		if @QueuedTime <= sysdatetimeoffset() and isnull(@Description, '') not like 'This is a test%' -- description used for test cases and debugging avoids call
		and exists
		(
			select
				1
			from
				dbo.RegistrationSnapshot rs
			where
				rs.RegistrationSnapshotSID = @RegistrationSnapshotSID and rs.JobRunSID is null
		)
		begin

			declare @parameters xml = cast(N'<Parameters p1="' + ltrim(@RegistrationSnapshotSID) + '"/>' as xml);

			exec sf.pJob#Call
				@JobSCD = 'dbo.pRegistrationSnapshot#CIHICreate'
				,@Parameters = @parameters;

		end;
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
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
				 @Mode                              = 'insert.post'
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
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
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
