SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailTrigger#EFInsert]
	 @EmailTriggerLabel                nvarchar(35)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@EmailTemplateSID                 int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@QuerySID                         int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@MinDaysToRepeat                  int               = null							-- default: (0)
	,@ApplicationUserSID               int               = null							
	,@JobScheduleSID                   int               = null							
	,@LastStartTime                    datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@LastEndTime                      datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@EarliestSelectionDate            date              = null							
	,@IsActive                         bit               = null							-- default: (1)
	,@UserDefinedColumns               xml               = null							
	,@EmailTriggerXID                  varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@EmailTemplateLabel               nvarchar(35)      = null							-- not a base table column (default ignored)
	,@PriorityLevel                    tinyint           = null							-- not a base table column (default ignored)
	,@Subject                          nvarchar(120)     = null							-- not a base table column (default ignored)
	,@IsApplicationUserRequired        bit               = null							-- not a base table column (default ignored)
	,@LinkExpiryHours                  int               = null							-- not a base table column (default ignored)
	,@ApplicationEntitySID             int               = null							-- not a base table column (default ignored)
	,@ApplicationGrantSID              int               = null							-- not a base table column (default ignored)
	,@EmailTemplateRowGUID             uniqueidentifier  = null							-- not a base table column (default ignored)
	,@QueryCategorySID                 int               = null							-- not a base table column (default ignored)
	,@ApplicationPageSID               int               = null							-- not a base table column (default ignored)
	,@QueryLabel                       nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ToolTip                          nvarchar(250)     = null							-- not a base table column (default ignored)
	,@LastExecuteTime                  datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastExecuteUser                  nvarchar(75)      = null							-- not a base table column (default ignored)
	,@ExecuteCount                     int               = null							-- not a base table column (default ignored)
	,@QueryCode                        varchar(30)       = null							-- not a base table column (default ignored)
	,@QueryIsActive                    bit               = null							-- not a base table column (default ignored)
	,@IsApplicationPageDefault         bit               = null							-- not a base table column (default ignored)
	,@QueryRowGUID                     uniqueidentifier  = null							-- not a base table column (default ignored)
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
	,@JobScheduleLabel                 nvarchar(35)      = null							-- not a base table column (default ignored)
	,@IsEnabled                        bit               = null							-- not a base table column (default ignored)
	,@IsRunMonday                      bit               = null							-- not a base table column (default ignored)
	,@IsRunTuesday                     bit               = null							-- not a base table column (default ignored)
	,@IsRunWednesday                   bit               = null							-- not a base table column (default ignored)
	,@IsRunThursday                    bit               = null							-- not a base table column (default ignored)
	,@IsRunFriday                      bit               = null							-- not a base table column (default ignored)
	,@IsRunSaturday                    bit               = null							-- not a base table column (default ignored)
	,@IsRunSunday                      bit               = null							-- not a base table column (default ignored)
	,@RepeatIntervalMinutes            smallint          = null							-- not a base table column (default ignored)
	,@StartTime                        time(0)           = null							-- not a base table column (default ignored)
	,@EndTime                          time(0)           = null							-- not a base table column (default ignored)
	,@StartDate                        date              = null							-- not a base table column (default ignored)
	,@EndDate                          date              = null							-- not a base table column (default ignored)
	,@JobScheduleRowGUID               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@LastDurationMinutes              int               = null							-- not a base table column (default ignored)
	,@IsRunning                        bit               = null							-- not a base table column (default ignored)
	,@LastStartTimeClientTZ            datetime          = null							-- not a base table column (default ignored)
	,@LastEndTimeClientTZ              datetime          = null							-- not a base table column (default ignored)
	,@NextScheduledTime                datetime          = null							-- not a base table column (default ignored)
	,@NextScheduledTimeServerTZ        datetimeoffset(7) = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pEmailTrigger#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pEmailTrigger#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pEmailTrigger#Insert
			 @EmailTriggerLabel                = @EmailTriggerLabel
			,@EmailTemplateSID                 = @EmailTemplateSID
			,@QuerySID                         = @QuerySID
			,@MinDaysToRepeat                  = @MinDaysToRepeat
			,@ApplicationUserSID               = @ApplicationUserSID
			,@JobScheduleSID                   = @JobScheduleSID
			,@LastStartTime                    = @LastStartTime
			,@LastEndTime                      = @LastEndTime
			,@EarliestSelectionDate            = @EarliestSelectionDate
			,@IsActive                         = @IsActive
			,@UserDefinedColumns               = @UserDefinedColumns
			,@EmailTriggerXID                  = @EmailTriggerXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@EmailTemplateLabel               = @EmailTemplateLabel
			,@PriorityLevel                    = @PriorityLevel
			,@Subject                          = @Subject
			,@IsApplicationUserRequired        = @IsApplicationUserRequired
			,@LinkExpiryHours                  = @LinkExpiryHours
			,@ApplicationEntitySID             = @ApplicationEntitySID
			,@ApplicationGrantSID              = @ApplicationGrantSID
			,@EmailTemplateRowGUID             = @EmailTemplateRowGUID
			,@QueryCategorySID                 = @QueryCategorySID
			,@ApplicationPageSID               = @ApplicationPageSID
			,@QueryLabel                       = @QueryLabel
			,@ToolTip                          = @ToolTip
			,@LastExecuteTime                  = @LastExecuteTime
			,@LastExecuteUser                  = @LastExecuteUser
			,@ExecuteCount                     = @ExecuteCount
			,@QueryCode                        = @QueryCode
			,@QueryIsActive                    = @QueryIsActive
			,@IsApplicationPageDefault         = @IsApplicationPageDefault
			,@QueryRowGUID                     = @QueryRowGUID
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
			,@JobScheduleLabel                 = @JobScheduleLabel
			,@IsEnabled                        = @IsEnabled
			,@IsRunMonday                      = @IsRunMonday
			,@IsRunTuesday                     = @IsRunTuesday
			,@IsRunWednesday                   = @IsRunWednesday
			,@IsRunThursday                    = @IsRunThursday
			,@IsRunFriday                      = @IsRunFriday
			,@IsRunSaturday                    = @IsRunSaturday
			,@IsRunSunday                      = @IsRunSunday
			,@RepeatIntervalMinutes            = @RepeatIntervalMinutes
			,@StartTime                        = @StartTime
			,@EndTime                          = @EndTime
			,@StartDate                        = @StartDate
			,@EndDate                          = @EndDate
			,@JobScheduleRowGUID               = @JobScheduleRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@LastDurationMinutes              = @LastDurationMinutes
			,@IsRunning                        = @IsRunning
			,@LastStartTimeClientTZ            = @LastStartTimeClientTZ
			,@LastEndTimeClientTZ              = @LastEndTimeClientTZ
			,@NextScheduledTime                = @NextScheduledTime
			,@NextScheduledTimeServerTZ        = @NextScheduledTimeServerTZ

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
