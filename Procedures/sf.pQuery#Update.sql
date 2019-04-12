SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pQuery#Update]
	 @QuerySID                 int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@QueryCategorySID         int               = null -- table column values to update:
	,@ApplicationPageSID       int               = null
	,@QueryLabel               nvarchar(35)      = null
	,@ToolTip                  nvarchar(250)     = null
	,@LastExecuteTime          datetimeoffset(7) = null
	,@LastExecuteUser          nvarchar(75)      = null
	,@ExecuteCount             int               = null
	,@QuerySQL                 nvarchar(max)     = null
	,@QueryParameters          xml               = null
	,@QueryCode                varchar(30)       = null
	,@IsActive                 bit               = null
	,@IsApplicationPageDefault bit               = null
	,@UserDefinedColumns       xml               = null
	,@QueryXID                 varchar(150)      = null
	,@LegacyKey                nvarchar(50)      = null
	,@UpdateUser               nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                 timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected             tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied            bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                 xml               = null -- other values defining context for the update (if any)
	,@ApplicationPageLabel     nvarchar(35)      = null -- not a base table column
	,@ApplicationPageURI       varchar(150)      = null -- not a base table column
	,@ApplicationRoute         varchar(150)      = null -- not a base table column
	,@IsSearchPage             bit               = null -- not a base table column
	,@ApplicationEntitySID     int               = null -- not a base table column
	,@ApplicationPageRowGUID   uniqueidentifier  = null -- not a base table column
	,@QueryCategoryLabel       nvarchar(35)      = null -- not a base table column
	,@QueryCategoryCode        varchar(30)       = null -- not a base table column
	,@DisplayOrder             int               = null -- not a base table column
	,@QueryCategoryIsActive    bit               = null -- not a base table column
	,@QueryCategoryIsDefault   bit               = null -- not a base table column
	,@QueryCategoryRowGUID     uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled          bit               = null -- not a base table column
	,@ApplicationEntitySCD     varchar(50)       = null -- not a base table column
	,@ApplicationEntityName    nvarchar(50)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pQuery#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.Query table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.Query table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vQuery entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pQuery procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fQueryCheck to test all rules.

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

		if @QuerySID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@QuerySID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @QueryLabel = ltrim(rtrim(@QueryLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @LastExecuteUser = ltrim(rtrim(@LastExecuteUser))
		set @QuerySQL = ltrim(rtrim(@QuerySQL))
		set @QueryCode = ltrim(rtrim(@QueryCode))
		set @QueryXID = ltrim(rtrim(@QueryXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ApplicationPageLabel = ltrim(rtrim(@ApplicationPageLabel))
		set @ApplicationPageURI = ltrim(rtrim(@ApplicationPageURI))
		set @ApplicationRoute = ltrim(rtrim(@ApplicationRoute))
		set @QueryCategoryLabel = ltrim(rtrim(@QueryCategoryLabel))
		set @QueryCategoryCode = ltrim(rtrim(@QueryCategoryCode))
		set @ApplicationEntitySCD = ltrim(rtrim(@ApplicationEntitySCD))
		set @ApplicationEntityName = ltrim(rtrim(@ApplicationEntityName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@QueryLabel) = 0 set @QueryLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@QuerySQL) = 0 set @QuerySQL = null
		if len(@QueryCode) = 0 set @QueryCode = null
		if len(@QueryXID) = 0 set @QueryXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ApplicationPageLabel) = 0 set @ApplicationPageLabel = null
		if len(@ApplicationPageURI) = 0 set @ApplicationPageURI = null
		if len(@ApplicationRoute) = 0 set @ApplicationRoute = null
		if len(@QueryCategoryLabel) = 0 set @QueryCategoryLabel = null
		if len(@QueryCategoryCode) = 0 set @QueryCategoryCode = null
		if len(@ApplicationEntitySCD) = 0 set @ApplicationEntitySCD = null
		if len(@ApplicationEntityName) = 0 set @ApplicationEntityName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @QueryCategorySID         = isnull(@QueryCategorySID,qry.QueryCategorySID)
				,@ApplicationPageSID       = isnull(@ApplicationPageSID,qry.ApplicationPageSID)
				,@QueryLabel               = isnull(@QueryLabel,qry.QueryLabel)
				,@ToolTip                  = isnull(@ToolTip,qry.ToolTip)
				,@LastExecuteTime          = isnull(@LastExecuteTime,qry.LastExecuteTime)
				,@LastExecuteUser          = isnull(@LastExecuteUser,qry.LastExecuteUser)
				,@ExecuteCount             = isnull(@ExecuteCount,qry.ExecuteCount)
				,@QuerySQL                 = isnull(@QuerySQL,qry.QuerySQL)
				,@QueryParameters          = isnull(@QueryParameters,qry.QueryParameters)
				,@QueryCode                = isnull(@QueryCode,qry.QueryCode)
				,@IsActive                 = isnull(@IsActive,qry.IsActive)
				,@IsApplicationPageDefault = isnull(@IsApplicationPageDefault,qry.IsApplicationPageDefault)
				,@UserDefinedColumns       = isnull(@UserDefinedColumns,qry.UserDefinedColumns)
				,@QueryXID                 = isnull(@QueryXID,qry.QueryXID)
				,@LegacyKey                = isnull(@LegacyKey,qry.LegacyKey)
				,@UpdateUser               = isnull(@UpdateUser,qry.UpdateUser)
				,@IsReselected             = isnull(@IsReselected,qry.IsReselected)
				,@IsNullApplied            = isnull(@IsNullApplied,qry.IsNullApplied)
				,@zContext                 = isnull(@zContext,qry.zContext)
				,@ApplicationPageLabel     = isnull(@ApplicationPageLabel,qry.ApplicationPageLabel)
				,@ApplicationPageURI       = isnull(@ApplicationPageURI,qry.ApplicationPageURI)
				,@ApplicationRoute         = isnull(@ApplicationRoute,qry.ApplicationRoute)
				,@IsSearchPage             = isnull(@IsSearchPage,qry.IsSearchPage)
				,@ApplicationEntitySID     = isnull(@ApplicationEntitySID,qry.ApplicationEntitySID)
				,@ApplicationPageRowGUID   = isnull(@ApplicationPageRowGUID,qry.ApplicationPageRowGUID)
				,@QueryCategoryLabel       = isnull(@QueryCategoryLabel,qry.QueryCategoryLabel)
				,@QueryCategoryCode        = isnull(@QueryCategoryCode,qry.QueryCategoryCode)
				,@DisplayOrder             = isnull(@DisplayOrder,qry.DisplayOrder)
				,@QueryCategoryIsActive    = isnull(@QueryCategoryIsActive,qry.QueryCategoryIsActive)
				,@QueryCategoryIsDefault   = isnull(@QueryCategoryIsDefault,qry.QueryCategoryIsDefault)
				,@QueryCategoryRowGUID     = isnull(@QueryCategoryRowGUID,qry.QueryCategoryRowGUID)
				,@IsDeleteEnabled          = isnull(@IsDeleteEnabled,qry.IsDeleteEnabled)
				,@ApplicationEntitySCD     = isnull(@ApplicationEntitySCD,qry.ApplicationEntitySCD)
				,@ApplicationEntityName    = isnull(@ApplicationEntityName,qry.ApplicationEntityName)
			from
				sf.vQuery qry
			where
				qry.QuerySID = @QuerySID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.QueryCategorySID from sf.Query x where x.QuerySID = @QuerySID) <> @QueryCategorySID
		begin
			if (select x.IsActive from sf.QueryCategory x where x.QueryCategorySID = @QueryCategorySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'query category'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		-- prevent system code values from being modified
		
		if exists(select 1 from sf.Query x where x.QuerySID = @QuerySID and left(x.QueryCode, 2) = 'S!' and x.QueryCode <> @QueryCode)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  	= 'SystemCodeEdit'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'This code value is required by the application. The code cannot be edited.'
		
			raiserror(@errorText, 16, 1)
		
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | July 2015
		-- Replace tab characters with 2 spaces for improved formatting in HTML
		-- compatible edit windows used in applications.

		set @QuerySQL = replace(@QuerySQL, char(9), N'  ')
		--! </PreUpdate>

		-- update the record

		update
			sf.Query
		set
			 QueryCategorySID = @QueryCategorySID
			,ApplicationPageSID = @ApplicationPageSID
			,QueryLabel = @QueryLabel
			,ToolTip = @ToolTip
			,LastExecuteTime = @LastExecuteTime
			,LastExecuteUser = @LastExecuteUser
			,ExecuteCount = @ExecuteCount
			,QuerySQL = @QuerySQL
			,QueryParameters = @QueryParameters
			,QueryCode = @QueryCode
			,IsActive = @IsActive
			,IsApplicationPageDefault = @IsApplicationPageDefault
			,UserDefinedColumns = @UserDefinedColumns
			,QueryXID = @QueryXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			QuerySID = @QuerySID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.Query where QuerySID = @querySID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.Query'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.Query'
					,@Arg2        = @querySID
				
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
				,@Arg2        = 'sf.Query'
				,@Arg3        = @rowsAffected
				,@Arg4        = @querySID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

    --! <PostUpdate>
		-- Tim Edlund | Mar 2013
		-- Ensure the query syntax is valid before saving it
		-- If an error is detected transaction is rolled back

		if @QuerySQL is not null
		begin

			begin try

				exec sf.pQuery#Execute
					 @QuerySID			= @querySID
					,@ValidateOnly	= 1
					,@BypassCheck		= 1

			end try

			begin catch																														-- add wrapper to error on query syntax and re-throw it
				set @errorText = error_message()

				exec sf.pMessage#Get
					 @MessageSCD  = 'QuerySQLNotValid'
					,@MessageText = @errorText output
					,@DefaultText = N'The query statement is not valid.  The error reported is: "%1"'
					,@Arg1        = @errorText
			
				raiserror(@errorText, 16, 1)

			end catch

		end
    --! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.QuerySID
			from
				sf.vQuery ent
			where
				ent.QuerySID = @QuerySID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.QuerySID
				,ent.QueryCategorySID
				,ent.ApplicationPageSID
				,ent.QueryLabel
				,ent.ToolTip
				,ent.LastExecuteTime
				,ent.LastExecuteUser
				,ent.ExecuteCount
				,ent.QuerySQL
				,ent.QueryParameters
				,ent.QueryCode
				,ent.IsActive
				,ent.IsApplicationPageDefault
				,ent.UserDefinedColumns
				,ent.QueryXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ApplicationPageLabel
				,ent.ApplicationPageURI
				,ent.ApplicationRoute
				,ent.IsSearchPage
				,ent.ApplicationEntitySID
				,ent.ApplicationPageRowGUID
				,ent.QueryCategoryLabel
				,ent.QueryCategoryCode
				,ent.DisplayOrder
				,ent.QueryCategoryIsActive
				,ent.QueryCategoryIsDefault
				,ent.QueryCategoryRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.ApplicationEntitySCD
				,ent.ApplicationEntityName
			from
				sf.vQuery ent
			where
				ent.QuerySID = @QuerySID

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
