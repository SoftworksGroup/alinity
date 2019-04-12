SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobRun#Default]
	 @zContext                        xml               = null                 -- default values provided from client-tier (if any)
	,@SetFKDefaults                   bit               = 0                    -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : sf.pJobRun#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" sf.JobRun records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.JobRun table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vJobRun entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pJobRun
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pJobRun of the context of the call. All other parameters are also passed, however, only those parameters eligible
for default setting are passed for "output". All parameters corresponding to entity view columns are returned through a SELECT statement.

In order to simplify working with the XML parameter values, logic in the procedure parses the XML and assigns values to variables where
the variable name matches the column name in the XML (assumes single row).  The variables are then available to the table-specific and
client-specific logic.  The @zContext parameter is also passed, unmodified, to the extended procedure to support situations where values
are passed that are not mapped to column names.


-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@ON                              bit = cast(1 as bit)								-- constant for bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- constant for bit comparisons
		,@jobRunSID                       int               = -1							-- specific default required by EF - do not override
		,@jobSID                          int               = null						-- no default provided from DB constraint - OK to override
		,@conversationHandle              uniqueidentifier  = null						-- no default provided from DB constraint - OK to override
		,@callSyntax                      nvarchar(max)     = null						-- no default provided from DB constraint - OK to override
		,@startTime                       datetimeoffset(7) = sysdatetimeoffset()												-- default provided from DB constraint - OK to override
		,@endTime                         datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@totalRecords                    int               = (0)							-- default provided from DB constraint - OK to override
		,@totalErrors                     int               = (0)							-- default provided from DB constraint - OK to override
		,@recordsProcessed                int               = (0)							-- default provided from DB constraint - OK to override
		,@currentProcessLabel             nvarchar(35)      = null						-- no default provided from DB constraint - OK to override
		,@isFailed                        bit               = CONVERT(bit,(0),(0))											-- default provided from DB constraint - OK to override
		,@isFailureCleared                bit               = (0)							-- default provided from DB constraint - OK to override
		,@cancellationRequestTime         datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@isCancelled                     bit               = CONVERT(bit,(0),(0))											-- default provided from DB constraint - OK to override
		,@resultMessage                   nvarchar(max)     = null						-- no default provided from DB constraint - OK to override
		,@traceLog                        nvarchar(max)     = null						-- no default provided from DB constraint - OK to override
		,@userDefinedColumns              xml               = null						-- no default provided from DB constraint - OK to override
		,@jobRunXID                       varchar(150)      = null						-- no default provided from DB constraint - OK to override
		,@legacyKey                       nvarchar(50)      = null						-- no default provided from DB constraint - OK to override
		,@isDeleted                       bit               = (0)							-- default provided from DB constraint - OK to override
		,@createUser                      nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@createTime                      datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@updateUser                      nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@updateTime                      datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@rowGUID                         uniqueidentifier  = newid()					-- default value ignored (value set by system)
		,@rowStamp                        timestamp         = null						-- default value ignored (value set by system)
		,@jobSCD                          varchar(132)      = '?'							-- not a base table column (default ignored)
		,@jobLabel                        nvarchar(35)      = N'?'						-- not a base table column (default ignored)
		,@isCancelEnabled                 bit               = 0								-- not a base table column (default ignored)
		,@isParallelEnabled               bit               = 0								-- not a base table column (default ignored)
		,@isFullTraceEnabled              bit               = 0								-- not a base table column (default ignored)
		,@isAlertOnSuccessEnabled         bit               = 0								-- not a base table column (default ignored)
		,@jobScheduleSID                  int																	-- not a base table column (default ignored)
		,@jobScheduleSequence             int               = 0								-- not a base table column (default ignored)
		,@isRunAfterPredecessorsOnly      bit               = 0								-- not a base table column (default ignored)
		,@maxErrorRate                    int               = 0								-- not a base table column (default ignored)
		,@maxRetriesOnFailure             tinyint           = 0								-- not a base table column (default ignored)
		,@jobIsActive                     bit               = 0								-- not a base table column (default ignored)
		,@jobRowGUID                      uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@isDeleteEnabled                 bit																	-- not a base table column (default ignored)
		,@isReselected                    tinyint           = 1								-- specific default required by EF - do not override
		,@isNullApplied                   bit               = 1								-- specific default required by EF - do not override
		,@jobStatusSCD                    varchar(35)													-- not a base table column (default ignored)
		,@jobStatusLabel                  nvarchar(35)												-- not a base table column (default ignored)
		,@recordsPerMinute                int																	-- not a base table column (default ignored)
		,@recordsRemaining                int																	-- not a base table column (default ignored)
		,@estimatedMinutesRemaining       int																	-- not a base table column (default ignored)
		,@estimatedEndTime                datetime														-- not a base table column (default ignored)
		,@durationMinutes                 int																	-- not a base table column (default ignored)
		,@startTimeClientTZ               datetime														-- not a base table column (default ignored)
		,@endTimeClientTZ                 datetime														-- not a base table column (default ignored)
		,@cancellationRequestTimeClientTZ datetime														-- not a base table column (default ignored)

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
		-- set mandatory FK values to -1 where requested
		
		if @SetFKDefaults = @ON
		begin
			set @jobSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @jobSID                   = isnull(context.node.value('@JobSID'                 ,'int'              ),@jobSID)
			,@conversationHandle       = isnull(context.node.value('@ConversationHandle'     ,'uniqueidentifier' ),@conversationHandle)
			,@callSyntax               = isnull(context.node.value('@CallSyntax'             ,'nvarchar(max)'    ),@callSyntax)
			,@startTime                = isnull(context.node.value('@StartTime'              ,'datetimeoffset(7)'),@startTime)
			,@endTime                  = isnull(context.node.value('@EndTime'                ,'datetimeoffset(7)'),@endTime)
			,@totalRecords             = isnull(context.node.value('@TotalRecords'           ,'int'              ),@totalRecords)
			,@totalErrors              = isnull(context.node.value('@TotalErrors'            ,'int'              ),@totalErrors)
			,@recordsProcessed         = isnull(context.node.value('@RecordsProcessed'       ,'int'              ),@recordsProcessed)
			,@currentProcessLabel      = isnull(context.node.value('@CurrentProcessLabel'    ,'nvarchar(35)'     ),@currentProcessLabel)
			,@isFailed                 = isnull(context.node.value('@IsFailed'               ,'bit'              ),@isFailed)
			,@isFailureCleared         = isnull(context.node.value('@IsFailureCleared'       ,'bit'              ),@isFailureCleared)
			,@cancellationRequestTime  = isnull(context.node.value('@CancellationRequestTime','datetimeoffset(7)'),@cancellationRequestTime)
			,@isCancelled              = isnull(context.node.value('@IsCancelled'            ,'bit'              ),@isCancelled)
			,@resultMessage            = isnull(context.node.value('@ResultMessage'          ,'nvarchar(max)'    ),@resultMessage)
			,@traceLog                 = isnull(context.node.value('@TraceLog'               ,'nvarchar(max)'    ),@traceLog)
			,@jobRunXID                = isnull(context.node.value('@JobRunXID'              ,'varchar(150)'     ),@jobRunXID)
			,@legacyKey                = isnull(context.node.value('@LegacyKey'              ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		

		--! <Overrides>
		--  insert default value logic here ...
		--! </Overrides>

		select
			 @jobRunSID JobRunSID
			,@jobSID JobSID
			,@conversationHandle ConversationHandle
			,@callSyntax CallSyntax
			,@startTime StartTime
			,@endTime EndTime
			,@totalRecords TotalRecords
			,@totalErrors TotalErrors
			,@recordsProcessed RecordsProcessed
			,@currentProcessLabel CurrentProcessLabel
			,@isFailed IsFailed
			,@isFailureCleared IsFailureCleared
			,@cancellationRequestTime CancellationRequestTime
			,@isCancelled IsCancelled
			,@resultMessage ResultMessage
			,@traceLog TraceLog
			,@userDefinedColumns UserDefinedColumns
			,@jobRunXID JobRunXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@jobSCD JobSCD
			,@jobLabel JobLabel
			,@isCancelEnabled IsCancelEnabled
			,@isParallelEnabled IsParallelEnabled
			,@isFullTraceEnabled IsFullTraceEnabled
			,@isAlertOnSuccessEnabled IsAlertOnSuccessEnabled
			,@jobScheduleSID JobScheduleSID
			,@jobScheduleSequence JobScheduleSequence
			,@isRunAfterPredecessorsOnly IsRunAfterPredecessorsOnly
			,@maxErrorRate MaxErrorRate
			,@maxRetriesOnFailure MaxRetriesOnFailure
			,@jobIsActive JobIsActive
			,@jobRowGUID JobRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@jobStatusSCD JobStatusSCD
			,@jobStatusLabel JobStatusLabel
			,@recordsPerMinute RecordsPerMinute
			,@recordsRemaining RecordsRemaining
			,@estimatedMinutesRemaining EstimatedMinutesRemaining
			,@estimatedEndTime EstimatedEndTime
			,@durationMinutes DurationMinutes
			,@startTimeClientTZ StartTimeClientTZ
			,@endTimeClientTZ EndTimeClientTZ
			,@cancellationRequestTimeClientTZ CancellationRequestTimeClientTZ

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
