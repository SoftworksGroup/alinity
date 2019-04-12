SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJob#Insert]
	 @JobSID                     int               = null output						-- identity value assigned to the new record
	,@JobSCD                     varchar(132)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@JobLabel                   nvarchar(35)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@JobDescription             nvarchar(max)     = null										-- required! if not passed value must be set in custom logic prior to insert
	,@CallSyntaxTemplate         nvarchar(max)     = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsCancelEnabled            bit               = null										-- default: (1)
	,@IsParallelEnabled          bit               = null										-- default: (0)
	,@IsFullTraceEnabled         bit               = null										-- default: (0)
	,@IsAlertOnSuccessEnabled    bit               = null										-- default: (0)
	,@JobScheduleSID             int               = null										
	,@JobScheduleSequence        int               = null										-- default: (50)
	,@IsRunAfterPredecessorsOnly bit               = null										-- default: (0)
	,@MaxErrorRate               int               = null										-- default: (0)
	,@MaxRetriesOnFailure        tinyint           = null										-- default: (0)
	,@TraceLog                   nvarchar(max)     = null										
	,@IsActive                   bit               = null										-- default: (1)
	,@UserDefinedColumns         xml               = null										
	,@JobXID                     varchar(150)      = null										
	,@LegacyKey                  nvarchar(50)      = null										
	,@CreateUser                 nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected               tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                   xml               = null										-- other values defining context for the insert (if any)
	,@JobScheduleLabel           nvarchar(35)      = null										-- not a base table column (default ignored)
	,@IsEnabled                  bit               = null										-- not a base table column (default ignored)
	,@IsRunMonday                bit               = null										-- not a base table column (default ignored)
	,@IsRunTuesday               bit               = null										-- not a base table column (default ignored)
	,@IsRunWednesday             bit               = null										-- not a base table column (default ignored)
	,@IsRunThursday              bit               = null										-- not a base table column (default ignored)
	,@IsRunFriday                bit               = null										-- not a base table column (default ignored)
	,@IsRunSaturday              bit               = null										-- not a base table column (default ignored)
	,@IsRunSunday                bit               = null										-- not a base table column (default ignored)
	,@RepeatIntervalMinutes      smallint          = null										-- not a base table column (default ignored)
	,@StartTime                  time(0)           = null										-- not a base table column (default ignored)
	,@EndTime                    time(0)           = null										-- not a base table column (default ignored)
	,@StartDate                  date              = null										-- not a base table column (default ignored)
	,@EndDate                    date              = null										-- not a base table column (default ignored)
	,@JobScheduleRowGUID         uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled            bit               = null										-- not a base table column (default ignored)
	,@LastJobStatusSCD           varchar(35)       = null										-- not a base table column (default ignored)
	,@LastJobStatusLabel         nvarchar(35)      = null										-- not a base table column (default ignored)
	,@LastStartTime              datetime          = null										-- not a base table column (default ignored)
	,@LastEndTime                datetime          = null										-- not a base table column (default ignored)
	,@NextScheduledTime          datetime          = null										-- not a base table column (default ignored)
	,@NextScheduledTimeServerTZ  datetimeoffset(7) = null										-- not a base table column (default ignored)
	,@MinDuration                int               = null										-- not a base table column (default ignored)
	,@MaxDuration                int               = null										-- not a base table column (default ignored)
	,@AvgDuration                int               = null										-- not a base table column (default ignored)
	,@IsTaskTriggerJob           bit               = null										-- not a base table column (default ignored)
	,@LastRunRecords             int               = null										-- not a base table column (default ignored)
	,@LastRunProcessed           int               = null										-- not a base table column (default ignored)
	,@LastRunErrors              int               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pJob#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.Job table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.Job table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vJob entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pJob procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fJobCheck to test all rules.

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

	set @JobSID = null																											-- initialize output parameter

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

		set @JobSCD = ltrim(rtrim(@JobSCD))
		set @JobLabel = ltrim(rtrim(@JobLabel))
		set @JobDescription = ltrim(rtrim(@JobDescription))
		set @CallSyntaxTemplate = ltrim(rtrim(@CallSyntaxTemplate))
		set @TraceLog = ltrim(rtrim(@TraceLog))
		set @JobXID = ltrim(rtrim(@JobXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @JobScheduleLabel = ltrim(rtrim(@JobScheduleLabel))
		set @LastJobStatusSCD = ltrim(rtrim(@LastJobStatusSCD))
		set @LastJobStatusLabel = ltrim(rtrim(@LastJobStatusLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@JobSCD) = 0 set @JobSCD = null
		if len(@JobLabel) = 0 set @JobLabel = null
		if len(@JobDescription) = 0 set @JobDescription = null
		if len(@CallSyntaxTemplate) = 0 set @CallSyntaxTemplate = null
		if len(@TraceLog) = 0 set @TraceLog = null
		if len(@JobXID) = 0 set @JobXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@JobScheduleLabel) = 0 set @JobScheduleLabel = null
		if len(@LastJobStatusSCD) = 0 set @LastJobStatusSCD = null
		if len(@LastJobStatusLabel) = 0 set @LastJobStatusLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsCancelEnabled = isnull(@IsCancelEnabled,(1))
		set @IsParallelEnabled = isnull(@IsParallelEnabled,(0))
		set @IsFullTraceEnabled = isnull(@IsFullTraceEnabled,(0))
		set @IsAlertOnSuccessEnabled = isnull(@IsAlertOnSuccessEnabled,(0))
		set @JobScheduleSequence = isnull(@JobScheduleSequence,(50))
		set @IsRunAfterPredecessorsOnly = isnull(@IsRunAfterPredecessorsOnly,(0))
		set @MaxErrorRate = isnull(@MaxErrorRate,(0))
		set @MaxRetriesOnFailure = isnull(@MaxRetriesOnFailure,(0))
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected               = isnull(@IsReselected              ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>

		-- insert the record

		insert
			sf.Job
		(
			 JobSCD
			,JobLabel
			,JobDescription
			,CallSyntaxTemplate
			,IsCancelEnabled
			,IsParallelEnabled
			,IsFullTraceEnabled
			,IsAlertOnSuccessEnabled
			,JobScheduleSID
			,JobScheduleSequence
			,IsRunAfterPredecessorsOnly
			,MaxErrorRate
			,MaxRetriesOnFailure
			,TraceLog
			,IsActive
			,UserDefinedColumns
			,JobXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @JobSCD
			,@JobLabel
			,@JobDescription
			,@CallSyntaxTemplate
			,@IsCancelEnabled
			,@IsParallelEnabled
			,@IsFullTraceEnabled
			,@IsAlertOnSuccessEnabled
			,@JobScheduleSID
			,@JobScheduleSequence
			,@IsRunAfterPredecessorsOnly
			,@MaxErrorRate
			,@MaxRetriesOnFailure
			,@TraceLog
			,@IsActive
			,@UserDefinedColumns
			,@JobXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@JobSID = scope_identity()																					-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.Job'
				,@Arg3        = @rowsAffected
				,@Arg4        = @JobSID
			
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
				 ent.JobSID
			from
				sf.vJob ent
			where
				ent.JobSID = @JobSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.JobSID
				,ent.JobSCD
				,ent.JobLabel
				,ent.JobDescription
				,ent.CallSyntaxTemplate
				,ent.IsCancelEnabled
				,ent.IsParallelEnabled
				,ent.IsFullTraceEnabled
				,ent.IsAlertOnSuccessEnabled
				,ent.JobScheduleSID
				,ent.JobScheduleSequence
				,ent.IsRunAfterPredecessorsOnly
				,ent.MaxErrorRate
				,ent.MaxRetriesOnFailure
				,ent.TraceLog
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.JobXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
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
				,ent.LastJobStatusSCD
				,ent.LastJobStatusLabel
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.NextScheduledTime
				,ent.NextScheduledTimeServerTZ
				,ent.MinDuration
				,ent.MaxDuration
				,ent.AvgDuration
				,ent.IsTaskTriggerJob
				,ent.LastRunRecords
				,ent.LastRunProcessed
				,ent.LastRunErrors
			from
				sf.vJob ent
			where
				ent.JobSID = @JobSID

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
