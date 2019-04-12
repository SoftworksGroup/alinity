SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroup#Update]
	 @PersonGroupSID                   int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonGroupName                  nvarchar(65)      = null -- table column values to update:
	,@PersonGroupLabel                 nvarchar(35)      = null
	,@PersonGroupCategory              nvarchar(65)      = null
	,@Description                      nvarchar(500)     = null
	,@ApplicationUserSID               int               = null
	,@IsPreference                     bit               = null
	,@IsDocumentLibraryEnabled         bit               = null
	,@QuerySID                         int               = null
	,@LastReviewUser                   nvarchar(75)      = null
	,@LastReviewTime                   datetimeoffset(7) = null
	,@TagList                          xml               = null
	,@SmartGroupCount                  int               = null
	,@SmartGroupCountTime              datetimeoffset(7) = null
	,@IsActive                         bit               = null
	,@UserDefinedColumns               xml               = null
	,@PersonGroupXID                   varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@PersonSID                        int               = null -- not a base table column
	,@CultureSID                       int               = null -- not a base table column
	,@AuthenticationAuthoritySID       int               = null -- not a base table column
	,@UserName                         nvarchar(75)      = null -- not a base table column
	,@ApplicationUserLastReviewTime    datetimeoffset(7) = null -- not a base table column
	,@ApplicationUserLastReviewUser    nvarchar(75)      = null -- not a base table column
	,@IsPotentialDuplicate             bit               = null -- not a base table column
	,@IsTemplate                       bit               = null -- not a base table column
	,@GlassBreakPassword               varbinary(8000)   = null -- not a base table column
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null -- not a base table column
	,@ApplicationUserIsActive          bit               = null -- not a base table column
	,@AuthenticationSystemID           nvarchar(50)      = null -- not a base table column
	,@ApplicationUserRowGUID           uniqueidentifier  = null -- not a base table column
	,@QueryCategorySID                 int               = null -- not a base table column
	,@ApplicationPageSID               int               = null -- not a base table column
	,@QueryLabel                       nvarchar(35)      = null -- not a base table column
	,@ToolTip                          nvarchar(250)     = null -- not a base table column
	,@LastExecuteTime                  datetimeoffset(7) = null -- not a base table column
	,@LastExecuteUser                  nvarchar(75)      = null -- not a base table column
	,@ExecuteCount                     int               = null -- not a base table column
	,@QueryCode                        varchar(30)       = null -- not a base table column
	,@QueryIsActive                    bit               = null -- not a base table column
	,@IsApplicationPageDefault         bit               = null -- not a base table column
	,@QueryRowGUID                     uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                  bit               = null -- not a base table column
	,@IsSmartGroup                     bit               = null -- not a base table column
	,@NextReviewDueDate                smalldatetime     = null -- not a base table column
	,@TotalActive                      int               = null -- not a base table column
	,@TotalPending                     int               = null -- not a base table column
	,@TotalRequiringReplacement        int               = null -- not a base table column
	,@IsNextReviewOverdue              bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroup#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.PersonGroup table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.PersonGroup table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonGroup entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonGroup procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonGroupCheck to test all rules.

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

		if @PersonGroupSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonGroupSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PersonGroupName = ltrim(rtrim(@PersonGroupName))
		set @PersonGroupLabel = ltrim(rtrim(@PersonGroupLabel))
		set @PersonGroupCategory = ltrim(rtrim(@PersonGroupCategory))
		set @Description = ltrim(rtrim(@Description))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @PersonGroupXID = ltrim(rtrim(@PersonGroupXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @UserName = ltrim(rtrim(@UserName))
		set @ApplicationUserLastReviewUser = ltrim(rtrim(@ApplicationUserLastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @QueryLabel = ltrim(rtrim(@QueryLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @LastExecuteUser = ltrim(rtrim(@LastExecuteUser))
		set @QueryCode = ltrim(rtrim(@QueryCode))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PersonGroupName) = 0 set @PersonGroupName = null
		if len(@PersonGroupLabel) = 0 set @PersonGroupLabel = null
		if len(@PersonGroupCategory) = 0 set @PersonGroupCategory = null
		if len(@Description) = 0 set @Description = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@PersonGroupXID) = 0 set @PersonGroupXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@UserName) = 0 set @UserName = null
		if len(@ApplicationUserLastReviewUser) = 0 set @ApplicationUserLastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@QueryLabel) = 0 set @QueryLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@QueryCode) = 0 set @QueryCode = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonGroupName                  = isnull(@PersonGroupName,pg.PersonGroupName)
				,@PersonGroupLabel                 = isnull(@PersonGroupLabel,pg.PersonGroupLabel)
				,@PersonGroupCategory              = isnull(@PersonGroupCategory,pg.PersonGroupCategory)
				,@Description                      = isnull(@Description,pg.Description)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,pg.ApplicationUserSID)
				,@IsPreference                     = isnull(@IsPreference,pg.IsPreference)
				,@IsDocumentLibraryEnabled         = isnull(@IsDocumentLibraryEnabled,pg.IsDocumentLibraryEnabled)
				,@QuerySID                         = isnull(@QuerySID,pg.QuerySID)
				,@LastReviewUser                   = isnull(@LastReviewUser,pg.LastReviewUser)
				,@LastReviewTime                   = isnull(@LastReviewTime,pg.LastReviewTime)
				,@TagList                          = isnull(@TagList,pg.TagList)
				,@SmartGroupCount                  = isnull(@SmartGroupCount,pg.SmartGroupCount)
				,@SmartGroupCountTime              = isnull(@SmartGroupCountTime,pg.SmartGroupCountTime)
				,@IsActive                         = isnull(@IsActive,pg.IsActive)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,pg.UserDefinedColumns)
				,@PersonGroupXID                   = isnull(@PersonGroupXID,pg.PersonGroupXID)
				,@LegacyKey                        = isnull(@LegacyKey,pg.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,pg.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,pg.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,pg.IsNullApplied)
				,@zContext                         = isnull(@zContext,pg.zContext)
				,@PersonSID                        = isnull(@PersonSID,pg.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,pg.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,pg.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,pg.UserName)
				,@ApplicationUserLastReviewTime    = isnull(@ApplicationUserLastReviewTime,pg.ApplicationUserLastReviewTime)
				,@ApplicationUserLastReviewUser    = isnull(@ApplicationUserLastReviewUser,pg.ApplicationUserLastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,pg.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,pg.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,pg.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,pg.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,pg.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,pg.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,pg.ApplicationUserRowGUID)
				,@QueryCategorySID                 = isnull(@QueryCategorySID,pg.QueryCategorySID)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,pg.ApplicationPageSID)
				,@QueryLabel                       = isnull(@QueryLabel,pg.QueryLabel)
				,@ToolTip                          = isnull(@ToolTip,pg.ToolTip)
				,@LastExecuteTime                  = isnull(@LastExecuteTime,pg.LastExecuteTime)
				,@LastExecuteUser                  = isnull(@LastExecuteUser,pg.LastExecuteUser)
				,@ExecuteCount                     = isnull(@ExecuteCount,pg.ExecuteCount)
				,@QueryCode                        = isnull(@QueryCode,pg.QueryCode)
				,@QueryIsActive                    = isnull(@QueryIsActive,pg.QueryIsActive)
				,@IsApplicationPageDefault         = isnull(@IsApplicationPageDefault,pg.IsApplicationPageDefault)
				,@QueryRowGUID                     = isnull(@QueryRowGUID,pg.QueryRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,pg.IsDeleteEnabled)
				,@IsSmartGroup                     = isnull(@IsSmartGroup,pg.IsSmartGroup)
				,@NextReviewDueDate                = isnull(@NextReviewDueDate,pg.NextReviewDueDate)
				,@TotalActive                      = isnull(@TotalActive,pg.TotalActive)
				,@TotalPending                     = isnull(@TotalPending,pg.TotalPending)
				,@TotalRequiringReplacement        = isnull(@TotalRequiringReplacement,pg.TotalRequiringReplacement)
				,@IsNextReviewOverdue              = isnull(@IsNextReviewOverdue,pg.IsNextReviewOverdue)
			from
				sf.vPersonGroup pg
			where
				pg.PersonGroupSID = @PersonGroupSID

		end
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the new tags applied (if any)

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.PersonGroup x where x.PersonGroupSID = @PersonGroupSID) <> @ApplicationUserSID
		begin
			if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'application user'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.QuerySID from sf.PersonGroup x where x.PersonGroupSID = @PersonGroupSID) <> @QuerySID
		begin
			if (select x.IsActive from sf.Query x where x.QuerySID = @QuerySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'query'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>

		-- Tim Edlund | Jun 2017
		-- If the group is being marked inactive, call a procedure to expire
		-- all group member records.

		if @IsActive = @OFF and exists(select 1 from sf.PersonGroup x where x.PersonGroupSID = @PersonGroupSID and x.IsActive = @ON)
		begin

			exec sf.pPersonGroup#SetInactive
				@PersonGroupSID = @PersonGroupSID

		end

		--! </PreUpdate>

		-- update the record

		update
			sf.PersonGroup
		set
			 PersonGroupName = @PersonGroupName
			,PersonGroupLabel = @PersonGroupLabel
			,PersonGroupCategory = @PersonGroupCategory
			,Description = @Description
			,ApplicationUserSID = @ApplicationUserSID
			,IsPreference = @IsPreference
			,IsDocumentLibraryEnabled = @IsDocumentLibraryEnabled
			,QuerySID = @QuerySID
			,LastReviewUser = @LastReviewUser
			,LastReviewTime = @LastReviewTime
			,TagList = @TagList
			,SmartGroupCount = @SmartGroupCount
			,SmartGroupCountTime = @SmartGroupCountTime
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,PersonGroupXID = @PersonGroupXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonGroupSID = @PersonGroupSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.PersonGroup where PersonGroupSID = @personGroupSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.PersonGroup'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.PersonGroup'
					,@Arg2        = @personGroupSID
				
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
				,@Arg2        = 'sf.PersonGroup'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personGroupSID
			
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
				 ent.PersonGroupSID
			from
				sf.vPersonGroup ent
			where
				ent.PersonGroupSID = @PersonGroupSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonGroupSID
				,ent.PersonGroupName
				,ent.PersonGroupLabel
				,ent.PersonGroupCategory
				,ent.Description
				,ent.ApplicationUserSID
				,ent.IsPreference
				,ent.IsDocumentLibraryEnabled
				,ent.QuerySID
				,ent.LastReviewUser
				,ent.LastReviewTime
				,ent.TagList
				,ent.SmartGroupCount
				,ent.SmartGroupCountTime
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.PersonGroupXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonSID
				,ent.CultureSID
				,ent.AuthenticationAuthoritySID
				,ent.UserName
				,ent.ApplicationUserLastReviewTime
				,ent.ApplicationUserLastReviewUser
				,ent.IsPotentialDuplicate
				,ent.IsTemplate
				,ent.GlassBreakPassword
				,ent.LastGlassBreakPasswordChangeTime
				,ent.ApplicationUserIsActive
				,ent.AuthenticationSystemID
				,ent.ApplicationUserRowGUID
				,ent.QueryCategorySID
				,ent.ApplicationPageSID
				,ent.QueryLabel
				,ent.ToolTip
				,ent.LastExecuteTime
				,ent.LastExecuteUser
				,ent.ExecuteCount
				,ent.QueryCode
				,ent.QueryIsActive
				,ent.IsApplicationPageDefault
				,ent.QueryRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsSmartGroup
				,ent.NextReviewDueDate
				,ent.TotalActive
				,ent.TotalPending
				,ent.TotalRequiringReplacement
				,ent.IsNextReviewOverdue
			from
				sf.vPersonGroup ent
			where
				ent.PersonGroupSID = @PersonGroupSID

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
