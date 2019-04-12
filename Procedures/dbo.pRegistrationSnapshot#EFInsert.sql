SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationSnapshot#EFInsert]
	 @RegistrationSnapshotTypeSID       int               = null						-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistrationSnapshot#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrationSnapshot#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrationSnapshot#Insert
			 @RegistrationSnapshotTypeSID       = @RegistrationSnapshotTypeSID
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
