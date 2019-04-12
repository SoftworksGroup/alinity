SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTask#EFInsert]
	 @TaskTitle                        nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pTask#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pTask#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
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

		exec @errorNo = sf.pTask#Insert
			 @TaskTitle                        = @TaskTitle
			,@TaskQueueSID                     = @TaskQueueSID
			,@TargetRowGUID                    = @TargetRowGUID
			,@TaskDescription                  = @TaskDescription
			,@IsAlert                          = @IsAlert
			,@PriorityLevel                    = @PriorityLevel
			,@ApplicationUserSID               = @ApplicationUserSID
			,@TaskStatusSID                    = @TaskStatusSID
			,@AssignedTime                     = @AssignedTime
			,@DueDate                          = @DueDate
			,@NextFollowUpDate                 = @NextFollowUpDate
			,@ClosedTime                       = @ClosedTime
			,@ApplicationPageSID               = @ApplicationPageSID
			,@TaskTriggerSID                   = @TaskTriggerSID
			,@RecipientList                    = @RecipientList
			,@TagList                          = @TagList
			,@FileExtension                    = @FileExtension
			,@UserDefinedColumns               = @UserDefinedColumns
			,@TaskXID                          = @TaskXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@TaskQueueLabel                   = @TaskQueueLabel
			,@TaskQueueCode                    = @TaskQueueCode
			,@IsAutoAssigned                   = @IsAutoAssigned
			,@IsOpenSubscription               = @IsOpenSubscription
			,@TaskQueueApplicationUserSID      = @TaskQueueApplicationUserSID
			,@TaskQueueIsActive                = @TaskQueueIsActive
			,@TaskQueueIsDefault               = @TaskQueueIsDefault
			,@TaskQueueRowGUID                 = @TaskQueueRowGUID
			,@TaskStatusSCD                    = @TaskStatusSCD
			,@TaskStatusLabel                  = @TaskStatusLabel
			,@TaskStatusSequence               = @TaskStatusSequence
			,@IsDerived                        = @IsDerived
			,@IsClosedStatus                   = @IsClosedStatus
			,@TaskStatusIsActive               = @TaskStatusIsActive
			,@TaskStatusIsDefault              = @TaskStatusIsDefault
			,@TaskStatusRowGUID                = @TaskStatusRowGUID
			,@TaskTriggerLabel                 = @TaskTriggerLabel
			,@TaskTitleTemplate                = @TaskTitleTemplate
			,@QuerySID                         = @QuerySID
			,@TaskTriggerTaskQueueSID          = @TaskTriggerTaskQueueSID
			,@TaskTriggerApplicationUserSID    = @TaskTriggerApplicationUserSID
			,@TaskTriggerIsAlert               = @TaskTriggerIsAlert
			,@TaskTriggerPriorityLevel         = @TaskTriggerPriorityLevel
			,@TargetCompletionDays             = @TargetCompletionDays
			,@OpenTaskLimit                    = @OpenTaskLimit
			,@IsRegeneratedIfClosed            = @IsRegeneratedIfClosed
			,@ApplicationAction                = @ApplicationAction
			,@JobScheduleSID                   = @JobScheduleSID
			,@LastStartTime                    = @LastStartTime
			,@LastEndTime                      = @LastEndTime
			,@TaskTriggerIsActive              = @TaskTriggerIsActive
			,@TaskTriggerRowGUID               = @TaskTriggerRowGUID
			,@ApplicationPageLabel             = @ApplicationPageLabel
			,@ApplicationPageURI               = @ApplicationPageURI
			,@ApplicationRoute                 = @ApplicationRoute
			,@IsSearchPage                     = @IsSearchPage
			,@ApplicationEntitySID             = @ApplicationEntitySID
			,@ApplicationPageRowGUID           = @ApplicationPageRowGUID
			,@PersonSID                        = @PersonSID
			,@CultureSID                       = @CultureSID
			,@AuthenticationAuthoritySID       = @AuthenticationAuthoritySID
			,@UserName                         = @UserName
			,@LastReviewTime                   = @LastReviewTime
			,@LastReviewUser                   = @LastReviewUser
			,@IsPotentialDuplicate             = @IsPotentialDuplicate
			,@IsTemplate                       = @IsTemplate
			,@GlassBreakPassword               = @GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime = @LastGlassBreakPasswordChangeTime
			,@ApplicationUserIsActive          = @ApplicationUserIsActive
			,@AuthenticationSystemID           = @AuthenticationSystemID
			,@ApplicationUserRowGUID           = @ApplicationUserRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@IsOverdue                        = @IsOverdue
			,@IsOpen                           = @IsOpen
			,@IsCancelled                      = @IsCancelled
			,@IsClosed                         = @IsClosed
			,@IsTaskTakeOverEnabled            = @IsTaskTakeOverEnabled
			,@IsCloseEnabled                   = @IsCloseEnabled
			,@IsUpdateEnabled                  = @IsUpdateEnabled
			,@IsClosedWithinADay               = @IsClosedWithinADay
			,@EntityLabel                      = @EntityLabel

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
