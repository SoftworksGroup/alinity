SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobRun#EFInsert]
	 @JobSID                          int               = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pJobRun#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pJobRun#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

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

		-- call the main procedure

		exec @errorNo = sf.pJobRun#Insert
			 @JobSID                          = @JobSID
			,@ConversationHandle              = @ConversationHandle
			,@CallSyntax                      = @CallSyntax
			,@StartTime                       = @StartTime
			,@EndTime                         = @EndTime
			,@TotalRecords                    = @TotalRecords
			,@TotalErrors                     = @TotalErrors
			,@RecordsProcessed                = @RecordsProcessed
			,@CurrentProcessLabel             = @CurrentProcessLabel
			,@IsFailed                        = @IsFailed
			,@IsFailureCleared                = @IsFailureCleared
			,@CancellationRequestTime         = @CancellationRequestTime
			,@IsCancelled                     = @IsCancelled
			,@ResultMessage                   = @ResultMessage
			,@TraceLog                        = @TraceLog
			,@UserDefinedColumns              = @UserDefinedColumns
			,@JobRunXID                       = @JobRunXID
			,@LegacyKey                       = @LegacyKey
			,@CreateUser                      = @CreateUser
			,@IsReselected                    = @IsReselected
			,@zContext                        = @zContext
			,@JobSCD                          = @JobSCD
			,@JobLabel                        = @JobLabel
			,@IsCancelEnabled                 = @IsCancelEnabled
			,@IsParallelEnabled               = @IsParallelEnabled
			,@IsFullTraceEnabled              = @IsFullTraceEnabled
			,@IsAlertOnSuccessEnabled         = @IsAlertOnSuccessEnabled
			,@JobScheduleSID                  = @JobScheduleSID
			,@JobScheduleSequence             = @JobScheduleSequence
			,@IsRunAfterPredecessorsOnly      = @IsRunAfterPredecessorsOnly
			,@MaxErrorRate                    = @MaxErrorRate
			,@MaxRetriesOnFailure             = @MaxRetriesOnFailure
			,@JobIsActive                     = @JobIsActive
			,@JobRowGUID                      = @JobRowGUID
			,@IsDeleteEnabled                 = @IsDeleteEnabled
			,@JobStatusSCD                    = @JobStatusSCD
			,@JobStatusLabel                  = @JobStatusLabel
			,@RecordsPerMinute                = @RecordsPerMinute
			,@RecordsRemaining                = @RecordsRemaining
			,@EstimatedMinutesRemaining       = @EstimatedMinutesRemaining
			,@EstimatedEndTime                = @EstimatedEndTime
			,@DurationMinutes                 = @DurationMinutes
			,@StartTimeClientTZ               = @StartTimeClientTZ
			,@EndTimeClientTZ                 = @EndTimeClientTZ
			,@CancellationRequestTimeClientTZ = @CancellationRequestTimeClientTZ

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
