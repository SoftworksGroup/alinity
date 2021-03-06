SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pExportJob#EFInsert]
	 @ExportJobName         nvarchar(65)      = null												-- required! if not passed value must be set in custom logic prior to insert
	,@ExportJobCode         varchar(15)       = null												-- required! if not passed value must be set in custom logic prior to insert
	,@QuerySQL              nvarchar(max)     = null												-- required! if not passed value must be set in custom logic prior to insert
	,@QueryParameters       xml               = null												
	,@FileFormatSID         int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@BodySpecification     nvarchar(max)     = null												
	,@LineSpecification     nvarchar(max)     = null												
	,@XMLTransformation     xml               = null												
	,@JobScheduleSID        int               = null												
	,@EndPoint              xml               = null												
	,@LastExecuteTime       datetimeoffset(7) = null												-- default: sysdatetimeoffset()
	,@LastExecuteUser       nvarchar(75)      = null												-- default: suser_sname()
	,@ExecuteCount          int               = null												-- default: (0)
	,@UserDefinedColumns    xml               = null												
	,@ExportJobXID          varchar(150)      = null												
	,@LegacyKey             nvarchar(50)      = null												
	,@CreateUser            nvarchar(75)      = null												-- default: suser_sname()
	,@IsReselected          tinyint           = null												-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext              xml               = null												-- other values defining context for the insert (if any)
	,@FileFormatSCD         varchar(10)       = null												-- not a base table column (default ignored)
	,@FileFormatLabel       nvarchar(35)      = null												-- not a base table column (default ignored)
	,@FileFormatIsDefault   bit               = null												-- not a base table column (default ignored)
	,@FileFormatRowGUID     uniqueidentifier  = null												-- not a base table column (default ignored)
	,@JobScheduleLabel      nvarchar(35)      = null												-- not a base table column (default ignored)
	,@IsEnabled             bit               = null												-- not a base table column (default ignored)
	,@IsRunMonday           bit               = null												-- not a base table column (default ignored)
	,@IsRunTuesday          bit               = null												-- not a base table column (default ignored)
	,@IsRunWednesday        bit               = null												-- not a base table column (default ignored)
	,@IsRunThursday         bit               = null												-- not a base table column (default ignored)
	,@IsRunFriday           bit               = null												-- not a base table column (default ignored)
	,@IsRunSaturday         bit               = null												-- not a base table column (default ignored)
	,@IsRunSunday           bit               = null												-- not a base table column (default ignored)
	,@RepeatIntervalMinutes smallint          = null												-- not a base table column (default ignored)
	,@StartTime             time(0)           = null												-- not a base table column (default ignored)
	,@EndTime               time(0)           = null												-- not a base table column (default ignored)
	,@StartDate             date              = null												-- not a base table column (default ignored)
	,@EndDate               date              = null												-- not a base table column (default ignored)
	,@JobScheduleRowGUID    uniqueidentifier  = null												-- not a base table column (default ignored)
	,@IsDeleteEnabled       bit               = null												-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pExportJob#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pExportJob#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pExportJob#Insert
			 @ExportJobName         = @ExportJobName
			,@ExportJobCode         = @ExportJobCode
			,@QuerySQL              = @QuerySQL
			,@QueryParameters       = @QueryParameters
			,@FileFormatSID         = @FileFormatSID
			,@BodySpecification     = @BodySpecification
			,@LineSpecification     = @LineSpecification
			,@XMLTransformation     = @XMLTransformation
			,@JobScheduleSID        = @JobScheduleSID
			,@EndPoint              = @EndPoint
			,@LastExecuteTime       = @LastExecuteTime
			,@LastExecuteUser       = @LastExecuteUser
			,@ExecuteCount          = @ExecuteCount
			,@UserDefinedColumns    = @UserDefinedColumns
			,@ExportJobXID          = @ExportJobXID
			,@LegacyKey             = @LegacyKey
			,@CreateUser            = @CreateUser
			,@IsReselected          = @IsReselected
			,@zContext              = @zContext
			,@FileFormatSCD         = @FileFormatSCD
			,@FileFormatLabel       = @FileFormatLabel
			,@FileFormatIsDefault   = @FileFormatIsDefault
			,@FileFormatRowGUID     = @FileFormatRowGUID
			,@JobScheduleLabel      = @JobScheduleLabel
			,@IsEnabled             = @IsEnabled
			,@IsRunMonday           = @IsRunMonday
			,@IsRunTuesday          = @IsRunTuesday
			,@IsRunWednesday        = @IsRunWednesday
			,@IsRunThursday         = @IsRunThursday
			,@IsRunFriday           = @IsRunFriday
			,@IsRunSaturday         = @IsRunSaturday
			,@IsRunSunday           = @IsRunSunday
			,@RepeatIntervalMinutes = @RepeatIntervalMinutes
			,@StartTime             = @StartTime
			,@EndTime               = @EndTime
			,@StartDate             = @StartDate
			,@EndDate               = @EndDate
			,@JobScheduleRowGUID    = @JobScheduleRowGUID
			,@IsDeleteEnabled       = @IsDeleteEnabled

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
