SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJob#EFInsert]
	 @JobSCD                     varchar(132)      = null										-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pJob#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pJob#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pJob#Insert
			 @JobSCD                     = @JobSCD
			,@JobLabel                   = @JobLabel
			,@JobDescription             = @JobDescription
			,@CallSyntaxTemplate         = @CallSyntaxTemplate
			,@IsCancelEnabled            = @IsCancelEnabled
			,@IsParallelEnabled          = @IsParallelEnabled
			,@IsFullTraceEnabled         = @IsFullTraceEnabled
			,@IsAlertOnSuccessEnabled    = @IsAlertOnSuccessEnabled
			,@JobScheduleSID             = @JobScheduleSID
			,@JobScheduleSequence        = @JobScheduleSequence
			,@IsRunAfterPredecessorsOnly = @IsRunAfterPredecessorsOnly
			,@MaxErrorRate               = @MaxErrorRate
			,@MaxRetriesOnFailure        = @MaxRetriesOnFailure
			,@TraceLog                   = @TraceLog
			,@IsActive                   = @IsActive
			,@UserDefinedColumns         = @UserDefinedColumns
			,@JobXID                     = @JobXID
			,@LegacyKey                  = @LegacyKey
			,@CreateUser                 = @CreateUser
			,@IsReselected               = @IsReselected
			,@zContext                   = @zContext
			,@JobScheduleLabel           = @JobScheduleLabel
			,@IsEnabled                  = @IsEnabled
			,@IsRunMonday                = @IsRunMonday
			,@IsRunTuesday               = @IsRunTuesday
			,@IsRunWednesday             = @IsRunWednesday
			,@IsRunThursday              = @IsRunThursday
			,@IsRunFriday                = @IsRunFriday
			,@IsRunSaturday              = @IsRunSaturday
			,@IsRunSunday                = @IsRunSunday
			,@RepeatIntervalMinutes      = @RepeatIntervalMinutes
			,@StartTime                  = @StartTime
			,@EndTime                    = @EndTime
			,@StartDate                  = @StartDate
			,@EndDate                    = @EndDate
			,@JobScheduleRowGUID         = @JobScheduleRowGUID
			,@IsDeleteEnabled            = @IsDeleteEnabled
			,@LastJobStatusSCD           = @LastJobStatusSCD
			,@LastJobStatusLabel         = @LastJobStatusLabel
			,@LastStartTime              = @LastStartTime
			,@LastEndTime                = @LastEndTime
			,@NextScheduledTime          = @NextScheduledTime
			,@NextScheduledTimeServerTZ  = @NextScheduledTimeServerTZ
			,@MinDuration                = @MinDuration
			,@MaxDuration                = @MaxDuration
			,@AvgDuration                = @AvgDuration
			,@IsTaskTriggerJob           = @IsTaskTriggerJob
			,@LastRunRecords             = @LastRunRecords
			,@LastRunProcessed           = @LastRunProcessed
			,@LastRunErrors              = @LastRunErrors

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
