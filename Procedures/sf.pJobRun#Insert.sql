SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobRun#Insert]
	 @JobRunSID                       int               = null output				-- identity value assigned to the new record
	,@JobSID                          int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ConversationHandle              uniqueidentifier  = null							-- required! if not passed value must be set in custom logic prior to insert
	,@CallSyntax                      nvarchar(max)     = null							-- required! if not passed value must be set in custom logic prior to insert
	,@StartTime                       datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@EndTime                         datetimeoffset(7) = null							
	,@TotalRecords                    int               = null							-- default: (0)
	,@TotalErrors                     int               = null							-- default: (0)
	,@RecordsProcessed                int               = null							-- default: (0)
	,@CurrentProcessLabel             nvarchar(35)      = null							
	,@IsFailed                        bit               = null							-- default: CONVERT(bit,(0),(0))
	,@IsFailureCleared                bit               = null							-- default: (0)
	,@CancellationRequestTime         datetimeoffset(7) = null							
	,@IsCancelled                     bit               = null							-- default: CONVERT(bit,(0),(0))
	,@ResultMessage                   nvarchar(max)     = null							
	,@TraceLog                        nvarchar(max)     = null							
	,@UserDefinedColumns              xml               = null							
	,@JobRunXID                       varchar(150)      = null							
	,@LegacyKey                       nvarchar(50)      = null							
	,@CreateUser                      nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                    tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                        xml               = null							-- other values defining context for the insert (if any)
	,@JobSCD                          varchar(132)      = null							-- not a base table column (default ignored)
	,@JobLabel                        nvarchar(35)      = null							-- not a base table column (default ignored)
	,@IsCancelEnabled                 bit               = null							-- not a base table column (default ignored)
	,@IsParallelEnabled               bit               = null							-- not a base table column (default ignored)
	,@IsFullTraceEnabled              bit               = null							-- not a base table column (default ignored)
	,@IsAlertOnSuccessEnabled         bit               = null							-- not a base table column (default ignored)
	,@JobScheduleSID                  int               = null							-- not a base table column (default ignored)
	,@JobScheduleSequence             int               = null							-- not a base table column (default ignored)
	,@IsRunAfterPredecessorsOnly      bit               = null							-- not a base table column (default ignored)
	,@MaxErrorRate                    int               = null							-- not a base table column (default ignored)
	,@MaxRetriesOnFailure             tinyint           = null							-- not a base table column (default ignored)
	,@JobIsActive                     bit               = null							-- not a base table column (default ignored)
	,@JobRowGUID                      uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                 bit               = null							-- not a base table column (default ignored)
	,@JobStatusSCD                    varchar(35)       = null							-- not a base table column (default ignored)
	,@JobStatusLabel                  nvarchar(35)      = null							-- not a base table column (default ignored)
	,@RecordsPerMinute                int               = null							-- not a base table column (default ignored)
	,@RecordsRemaining                int               = null							-- not a base table column (default ignored)
	,@EstimatedMinutesRemaining       int               = null							-- not a base table column (default ignored)
	,@EstimatedEndTime                datetime          = null							-- not a base table column (default ignored)
	,@DurationMinutes                 int               = null							-- not a base table column (default ignored)
	,@StartTimeClientTZ               datetime          = null							-- not a base table column (default ignored)
	,@EndTimeClientTZ                 datetime          = null							-- not a base table column (default ignored)
	,@CancellationRequestTimeClientTZ datetime          = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pJobRun#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.JobRun table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.JobRun table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vJobRun entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pJobRun procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fJobRunCheck to test all rules.

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

	set @JobRunSID = null																										-- initialize output parameter

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

		set @CallSyntax = ltrim(rtrim(@CallSyntax))
		set @CurrentProcessLabel = ltrim(rtrim(@CurrentProcessLabel))
		set @ResultMessage = ltrim(rtrim(@ResultMessage))
		set @TraceLog = ltrim(rtrim(@TraceLog))
		set @JobRunXID = ltrim(rtrim(@JobRunXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @JobSCD = ltrim(rtrim(@JobSCD))
		set @JobLabel = ltrim(rtrim(@JobLabel))
		set @JobStatusSCD = ltrim(rtrim(@JobStatusSCD))
		set @JobStatusLabel = ltrim(rtrim(@JobStatusLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@CallSyntax) = 0 set @CallSyntax = null
		if len(@CurrentProcessLabel) = 0 set @CurrentProcessLabel = null
		if len(@ResultMessage) = 0 set @ResultMessage = null
		if len(@TraceLog) = 0 set @TraceLog = null
		if len(@JobRunXID) = 0 set @JobRunXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@JobSCD) = 0 set @JobSCD = null
		if len(@JobLabel) = 0 set @JobLabel = null
		if len(@JobStatusSCD) = 0 set @JobStatusSCD = null
		if len(@JobStatusLabel) = 0 set @JobStatusLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @StartTime = isnull(@StartTime,sysdatetimeoffset())
		set @TotalRecords = isnull(@TotalRecords,(0))
		set @TotalErrors = isnull(@TotalErrors,(0))
		set @RecordsProcessed = isnull(@RecordsProcessed,(0))
		set @IsFailed = isnull(@IsFailed,CONVERT(bit,(0),(0)))
		set @IsFailureCleared = isnull(@IsFailureCleared,(0))
		set @IsCancelled = isnull(@IsCancelled,CONVERT(bit,(0),(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @JobSCD is not null
		begin
		
			select
				@JobSID = x.JobSID
			from
				sf.Job x
			where
				x.JobSCD = @JobSCD
		
		end

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Jun 2013
		-- If no process label is provided (and the job is not being inserted as complete), set
		-- the label to the one used for the INPROCESS status from the sf.TermLabel table

		if @CurrentProcessLabel is null and @EndTime is null
		begin

			select
				@CurrentProcessLabel = isnull(tl.TermLabel, tl.DefaultLabel)																-- override text on the label term is supported											
			from
				sf.TermLabel tl
			where
				tl.TermLabelSCD = 'JOBSTATUS.INPROCESS'
	
			if @CurrentProcessLabel is null set @CurrentProcessLabel = N'In Process'											-- if not defined - set default

		end

		--! </PreInsert>

		-- insert the record

		insert
			sf.JobRun
		(
			 JobSID
			,ConversationHandle
			,CallSyntax
			,StartTime
			,EndTime
			,TotalRecords
			,TotalErrors
			,RecordsProcessed
			,CurrentProcessLabel
			,IsFailed
			,IsFailureCleared
			,CancellationRequestTime
			,IsCancelled
			,ResultMessage
			,TraceLog
			,UserDefinedColumns
			,JobRunXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @JobSID
			,@ConversationHandle
			,@CallSyntax
			,@StartTime
			,@EndTime
			,@TotalRecords
			,@TotalErrors
			,@RecordsProcessed
			,@CurrentProcessLabel
			,@IsFailed
			,@IsFailureCleared
			,@CancellationRequestTime
			,@IsCancelled
			,@ResultMessage
			,@TraceLog
			,@UserDefinedColumns
			,@JobRunXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@JobRunSID = scope_identity()																			-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.JobRun'
				,@Arg3        = @rowsAffected
				,@Arg4        = @JobRunSID
			
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
				 ent.JobRunSID
			from
				sf.vJobRun ent
			where
				ent.JobRunSID = @JobRunSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.JobRunSID
				,ent.JobSID
				,ent.ConversationHandle
				,ent.CallSyntax
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
				,ent.ResultMessage
				,ent.TraceLog
				,ent.UserDefinedColumns
				,ent.JobRunXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.JobSCD
				,ent.JobLabel
				,ent.IsCancelEnabled
				,ent.IsParallelEnabled
				,ent.IsFullTraceEnabled
				,ent.IsAlertOnSuccessEnabled
				,ent.JobScheduleSID
				,ent.JobScheduleSequence
				,ent.IsRunAfterPredecessorsOnly
				,ent.MaxErrorRate
				,ent.MaxRetriesOnFailure
				,ent.JobIsActive
				,ent.JobRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.JobStatusSCD
				,ent.JobStatusLabel
				,ent.RecordsPerMinute
				,ent.RecordsRemaining
				,ent.EstimatedMinutesRemaining
				,ent.EstimatedEndTime
				,ent.DurationMinutes
				,ent.StartTimeClientTZ
				,ent.EndTimeClientTZ
				,ent.CancellationRequestTimeClientTZ
			from
				sf.vJobRun ent
			where
				ent.JobRunSID = @JobRunSID

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
