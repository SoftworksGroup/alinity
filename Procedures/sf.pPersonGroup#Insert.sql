SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroup#Insert]
	 @PersonGroupSID                   int               = null output			-- identity value assigned to the new record
	,@PersonGroupName                  nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PersonGroupLabel                 nvarchar(35)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PersonGroupCategory              nvarchar(65)      = null							
	,@Description                      nvarchar(500)     = null							
	,@ApplicationUserSID               int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@IsPreference                     bit               = null							-- default: CONVERT(bit,(0))
	,@IsDocumentLibraryEnabled         bit               = null							-- default: (0)
	,@QuerySID                         int               = null							
	,@LastReviewUser                   nvarchar(75)      = null							-- default: suser_sname()
	,@LastReviewTime                   datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@TagList                          xml               = null							-- default: CONVERT(xml,N'<Tags/>')
	,@SmartGroupCount                  int               = null							-- default: (0)
	,@SmartGroupCountTime              datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@IsActive                         bit               = null							-- default: (1)
	,@UserDefinedColumns               xml               = null							
	,@PersonGroupXID                   varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@PersonSID                        int               = null							-- not a base table column (default ignored)
	,@CultureSID                       int               = null							-- not a base table column (default ignored)
	,@AuthenticationAuthoritySID       int               = null							-- not a base table column (default ignored)
	,@UserName                         nvarchar(75)      = null							-- not a base table column (default ignored)
	,@ApplicationUserLastReviewTime    datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserLastReviewUser    nvarchar(75)      = null							-- not a base table column (default ignored)
	,@IsPotentialDuplicate             bit               = null							-- not a base table column (default ignored)
	,@IsTemplate                       bit               = null							-- not a base table column (default ignored)
	,@GlassBreakPassword               varbinary(8000)   = null							-- not a base table column (default ignored)
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserIsActive          bit               = null							-- not a base table column (default ignored)
	,@AuthenticationSystemID           nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ApplicationUserRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
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
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@IsSmartGroup                     bit               = null							-- not a base table column (default ignored)
	,@NextReviewDueDate                smalldatetime     = null							-- not a base table column (default ignored)
	,@TotalActive                      int               = null							-- not a base table column (default ignored)
	,@TotalPending                     int               = null							-- not a base table column (default ignored)
	,@TotalRequiringReplacement        int               = null							-- not a base table column (default ignored)
	,@IsNextReviewOverdue              bit               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroup#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.PersonGroup table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.PersonGroup table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonGroup entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonGroup procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

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

	set @PersonGroupSID = null																							-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @PersonGroupName = ltrim(rtrim(@PersonGroupName))
		set @PersonGroupLabel = ltrim(rtrim(@PersonGroupLabel))
		set @PersonGroupCategory = ltrim(rtrim(@PersonGroupCategory))
		set @Description = ltrim(rtrim(@Description))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @PersonGroupXID = ltrim(rtrim(@PersonGroupXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@UserName) = 0 set @UserName = null
		if len(@ApplicationUserLastReviewUser) = 0 set @ApplicationUserLastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@QueryLabel) = 0 set @QueryLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@LastExecuteUser) = 0 set @LastExecuteUser = null
		if len(@QueryCode) = 0 set @QueryCode = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsPreference = isnull(@IsPreference,CONVERT(bit,(0)))
		set @IsDocumentLibraryEnabled = isnull(@IsDocumentLibraryEnabled,(0))
		set @LastReviewUser = isnull(@LastReviewUser,suser_sname())
		set @LastReviewTime = isnull(@LastReviewTime,sysdatetimeoffset())
		set @TagList = isnull(@TagList,CONVERT(xml,N'<Tags/>'))
		set @SmartGroupCount = isnull(@SmartGroupCount,(0))
		set @SmartGroupCountTime = isnull(@SmartGroupCountTime,sysdatetimeoffset())
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected             = isnull(@IsReselected            ,(0))
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the tags applied (if any)

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>

		-- insert the record

		insert
			sf.PersonGroup
		(
			 PersonGroupName
			,PersonGroupLabel
			,PersonGroupCategory
			,Description
			,ApplicationUserSID
			,IsPreference
			,IsDocumentLibraryEnabled
			,QuerySID
			,LastReviewUser
			,LastReviewTime
			,TagList
			,SmartGroupCount
			,SmartGroupCountTime
			,IsActive
			,UserDefinedColumns
			,PersonGroupXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonGroupName
			,@PersonGroupLabel
			,@PersonGroupCategory
			,@Description
			,@ApplicationUserSID
			,@IsPreference
			,@IsDocumentLibraryEnabled
			,@QuerySID
			,@LastReviewUser
			,@LastReviewTime
			,@TagList
			,@SmartGroupCount
			,@SmartGroupCountTime
			,@IsActive
			,@UserDefinedColumns
			,@PersonGroupXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected   = @@rowcount
			,@PersonGroupSID = scope_identity()																	-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.PersonGroup'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonGroupSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>

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
