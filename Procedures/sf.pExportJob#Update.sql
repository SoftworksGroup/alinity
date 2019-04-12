SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pExportJob#Update]
	 @ExportJobSID          int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ExportJobName         nvarchar(65)      = null -- table column values to update:
	,@ExportJobCode         varchar(15)       = null
	,@QuerySQL              nvarchar(max)     = null
	,@QueryParameters       xml               = null
	,@FileFormatSID         int               = null
	,@BodySpecification     nvarchar(max)     = null
	,@LineSpecification     nvarchar(max)     = null
	,@XMLTransformation     xml               = null
	,@JobScheduleSID        int               = null
	,@EndPoint              xml               = null
	,@LastExecuteTime       datetimeoffset(7) = null
	,@LastExecuteUser       nvarchar(75)      = null
	,@ExecuteCount          int               = null
	,@UserDefinedColumns    xml               = null
	,@ExportJobXID          varchar(150)      = null
	,@LegacyKey             nvarchar(50)      = null
	,@UpdateUser            nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp              timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected          tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied         bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext              xml               = null -- other values defining context for the update (if any)
	,@FileFormatSCD         varchar(10)       = null -- not a base table column
	,@FileFormatLabel       nvarchar(35)      = null -- not a base table column
	,@FileFormatIsDefault   bit               = null -- not a base table column
	,@FileFormatRowGUID     uniqueidentifier  = null -- not a base table column
	,@JobScheduleLabel      nvarchar(35)      = null -- not a base table column
	,@IsEnabled             bit               = null -- not a base table column
	,@IsRunMonday           bit               = null -- not a base table column
	,@IsRunTuesday          bit               = null -- not a base table column
	,@IsRunWednesday        bit               = null -- not a base table column
	,@IsRunThursday         bit               = null -- not a base table column
	,@IsRunFriday           bit               = null -- not a base table column
	,@IsRunSaturday         bit               = null -- not a base table column
	,@IsRunSunday           bit               = null -- not a base table column
	,@RepeatIntervalMinutes smallint          = null -- not a base table column
	,@StartTime             time(0)           = null -- not a base table column
	,@EndTime               time(0)           = null -- not a base table column
	,@StartDate             date              = null -- not a base table column
	,@EndDate               date              = null -- not a base table column
	,@JobScheduleRowGUID    uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled       bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pExportJob#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.ExportJob table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.ExportJob table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vExportJob entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pExportJob procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Business rule compliance is checked through a table constraint which calls fExportJobCheck to test all rules.

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

		-- check parameters

		if @ExportJobSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ExportJobSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ExportJobName = ltrim(rtrim(@ExportJobName))
		set @ExportJobCode = ltrim(rtrim(@ExportJobCode))
		set @QuerySQL = ltrim(rtrim(@QuerySQL))
		set @BodySpecification = ltrim(rtrim(@BodySpecification))
		set @LineSpecification = ltrim(rtrim(@LineSpecification))
		set @LastExecuteUser = ltrim(rtrim(@LastExecuteUser))
		set @ExportJobXID = ltrim(rtrim(@ExportJobXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FileFormatSCD = ltrim(rtrim(@FileFormatSCD))
		set @FileFormatLabel = ltrim(rtrim(@FileFormatLabel))
		set @JobScheduleLabel = ltrim(rtrim(@JobScheduleLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ExportJobName) = 0 set @ExportJobName = null
		if len(@ExportJobCode) = 0 set @ExportJobCode = null
		if len(@QuerySQL) = 0 set @QuerySQL = null
		if len(@BodySpecification) = 0 set @BodySpecification = null
		if len(@LineSpecification) = 0 set @LineSpecification = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@ExportJobXID) = 0 set @ExportJobXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FileFormatSCD) = 0 set @FileFormatSCD = null
		if len(@FileFormatLabel) = 0 set @FileFormatLabel = null
		if len(@JobScheduleLabel) = 0 set @JobScheduleLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ExportJobName         = isnull(@ExportJobName,ej.ExportJobName)
				,@ExportJobCode         = isnull(@ExportJobCode,ej.ExportJobCode)
				,@QuerySQL              = isnull(@QuerySQL,ej.QuerySQL)
				,@QueryParameters       = isnull(@QueryParameters,ej.QueryParameters)
				,@FileFormatSID         = isnull(@FileFormatSID,ej.FileFormatSID)
				,@BodySpecification     = isnull(@BodySpecification,ej.BodySpecification)
				,@LineSpecification     = isnull(@LineSpecification,ej.LineSpecification)
				,@XMLTransformation     = isnull(@XMLTransformation,ej.XMLTransformation)
				,@JobScheduleSID        = isnull(@JobScheduleSID,ej.JobScheduleSID)
				,@EndPoint              = isnull(@EndPoint,ej.EndPoint)
				,@LastExecuteTime       = isnull(@LastExecuteTime,ej.LastExecuteTime)
				,@LastExecuteUser       = isnull(@LastExecuteUser,ej.LastExecuteUser)
				,@ExecuteCount          = isnull(@ExecuteCount,ej.ExecuteCount)
				,@UserDefinedColumns    = isnull(@UserDefinedColumns,ej.UserDefinedColumns)
				,@ExportJobXID          = isnull(@ExportJobXID,ej.ExportJobXID)
				,@LegacyKey             = isnull(@LegacyKey,ej.LegacyKey)
				,@UpdateUser            = isnull(@UpdateUser,ej.UpdateUser)
				,@IsReselected          = isnull(@IsReselected,ej.IsReselected)
				,@IsNullApplied         = isnull(@IsNullApplied,ej.IsNullApplied)
				,@zContext              = isnull(@zContext,ej.zContext)
				,@FileFormatSCD         = isnull(@FileFormatSCD,ej.FileFormatSCD)
				,@FileFormatLabel       = isnull(@FileFormatLabel,ej.FileFormatLabel)
				,@FileFormatIsDefault   = isnull(@FileFormatIsDefault,ej.FileFormatIsDefault)
				,@FileFormatRowGUID     = isnull(@FileFormatRowGUID,ej.FileFormatRowGUID)
				,@JobScheduleLabel      = isnull(@JobScheduleLabel,ej.JobScheduleLabel)
				,@IsEnabled             = isnull(@IsEnabled,ej.IsEnabled)
				,@IsRunMonday           = isnull(@IsRunMonday,ej.IsRunMonday)
				,@IsRunTuesday          = isnull(@IsRunTuesday,ej.IsRunTuesday)
				,@IsRunWednesday        = isnull(@IsRunWednesday,ej.IsRunWednesday)
				,@IsRunThursday         = isnull(@IsRunThursday,ej.IsRunThursday)
				,@IsRunFriday           = isnull(@IsRunFriday,ej.IsRunFriday)
				,@IsRunSaturday         = isnull(@IsRunSaturday,ej.IsRunSaturday)
				,@IsRunSunday           = isnull(@IsRunSunday,ej.IsRunSunday)
				,@RepeatIntervalMinutes = isnull(@RepeatIntervalMinutes,ej.RepeatIntervalMinutes)
				,@StartTime             = isnull(@StartTime,ej.StartTime)
				,@EndTime               = isnull(@EndTime,ej.EndTime)
				,@StartDate             = isnull(@StartDate,ej.StartDate)
				,@EndDate               = isnull(@EndDate,ej.EndDate)
				,@JobScheduleRowGUID    = isnull(@JobScheduleRowGUID,ej.JobScheduleRowGUID)
				,@IsDeleteEnabled       = isnull(@IsDeleteEnabled,ej.IsDeleteEnabled)
			from
				sf.vExportJob ej
			where
				ej.ExportJobSID = @ExportJobSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @FileFormatSCD is not null and @FileFormatSID = (select x.FileFormatSID from sf.ExportJob x where x.ExportJobSID = @ExportJobSID)
		begin
		
			select
				@FileFormatSID = x.FileFormatSID
			from
				sf.FileFormat x
			where
				x.FileFormatSCD = @FileFormatSCD
		
		end
		
		-- prevent system code values from being modified
		
		if exists(select 1 from sf.ExportJob x where x.ExportJobSID = @ExportJobSID and left(x.ExportJobCode, 2) = 'S!' and x.ExportJobCode <> @ExportJobCode)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  	= 'SystemCodeEdit'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'This code value is required by the application. The code cannot be edited.'
		
			raiserror(@errorText, 16, 1)
		
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>

		-- update the record

		update
			sf.ExportJob
		set
			 ExportJobName = @ExportJobName
			,ExportJobCode = @ExportJobCode
			,QuerySQL = @QuerySQL
			,QueryParameters = @QueryParameters
			,FileFormatSID = @FileFormatSID
			,BodySpecification = @BodySpecification
			,LineSpecification = @LineSpecification
			,XMLTransformation = @XMLTransformation
			,JobScheduleSID = @JobScheduleSID
			,EndPoint = @EndPoint
			,LastExecuteTime = @LastExecuteTime
			,LastExecuteUser = @LastExecuteUser
			,ExecuteCount = @ExecuteCount
			,UserDefinedColumns = @UserDefinedColumns
			,ExportJobXID = @ExportJobXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ExportJobSID = @ExportJobSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.ExportJob where ExportJobSID = @exportJobSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.ExportJob'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.ExportJob'
					,@Arg2        = @exportJobSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'sf.ExportJob'
				,@Arg3        = @rowsAffected
				,@Arg4        = @exportJobSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ExportJobSID
			from
				sf.vExportJob ent
			where
				ent.ExportJobSID = @ExportJobSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ExportJobSID
				,ent.ExportJobName
				,ent.ExportJobCode
				,ent.QuerySQL
				,ent.QueryParameters
				,ent.FileFormatSID
				,ent.BodySpecification
				,ent.LineSpecification
				,ent.XMLTransformation
				,ent.JobScheduleSID
				,ent.EndPoint
				,ent.LastExecuteTime
				,ent.LastExecuteUser
				,ent.ExecuteCount
				,ent.UserDefinedColumns
				,ent.ExportJobXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.FileFormatSCD
				,ent.FileFormatLabel
				,ent.FileFormatIsDefault
				,ent.FileFormatRowGUID
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
			from
				sf.vExportJob ent
			where
				ent.ExportJobSID = @ExportJobSID

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