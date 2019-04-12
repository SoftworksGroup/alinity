SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pForm#Insert]
	 @FormSID                          int               = null output			-- identity value assigned to the new record
	,@FormTypeSID                      int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormName                         nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormLabel                        nvarchar(35)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormContext                      varchar(25)       = null							
	,@AuthorCredit                     nvarchar(500)     = null							-- default: (('Anonymous Work'+char((13)))+char((10)))+'See https://commons.wikimedia.org/wiki/Anonymous_works'
	,@IsActive                         bit               = null							-- default: (1)
	,@UsageTerms                       nvarchar(max)     = null							
	,@ApplicationUserSID               int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@UsageNotes                       nvarchar(max)     = null							
	,@FormInstructions                 nvarchar(max)     = null							
	,@VersionHistory                   xml               = null							
	,@UserDefinedColumns               xml               = null							
	,@FormXID                          varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
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
	,@FormTypeSCD                      varchar(25)       = null							-- not a base table column (default ignored)
	,@FormTypeLabel                    nvarchar(35)      = null							-- not a base table column (default ignored)
	,@FormOwnerSID                     int               = null							-- not a base table column (default ignored)
	,@FormTypeIsDefault                bit               = null							-- not a base table column (default ignored)
	,@FormTypeRowGUID                  uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@LatestVersionNo                  smallint          = null							-- not a base table column (default ignored)
	,@LatestRevisionNo                 smallint          = null							-- not a base table column (default ignored)
	,@LatestVersionFormVersionSID      int               = null							-- not a base table column (default ignored)
	,@LatestRevisionFormVersionSID     int               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pForm#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.Form table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.Form table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vForm entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pForm procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fFormCheck to test all rules.

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

	set @FormSID = null																											-- initialize output parameter

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

		set @FormName = ltrim(rtrim(@FormName))
		set @FormLabel = ltrim(rtrim(@FormLabel))
		set @FormContext = ltrim(rtrim(@FormContext))
		set @AuthorCredit = ltrim(rtrim(@AuthorCredit))
		set @UsageTerms = ltrim(rtrim(@UsageTerms))
		set @UsageNotes = ltrim(rtrim(@UsageNotes))
		set @FormInstructions = ltrim(rtrim(@FormInstructions))
		set @FormXID = ltrim(rtrim(@FormXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @FormTypeSCD = ltrim(rtrim(@FormTypeSCD))
		set @FormTypeLabel = ltrim(rtrim(@FormTypeLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@FormName) = 0 set @FormName = null
		if len(@FormLabel) = 0 set @FormLabel = null
		if len(@FormContext) = 0 set @FormContext = null
		if len(@AuthorCredit) = 0 set @AuthorCredit = null
		if len(@UsageTerms) = 0 set @UsageTerms = null
		if len(@UsageNotes) = 0 set @UsageNotes = null
		if len(@FormInstructions) = 0 set @FormInstructions = null
		if len(@FormXID) = 0 set @FormXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@FormTypeSCD) = 0 set @FormTypeSCD = null
		if len(@FormTypeLabel) = 0 set @FormTypeLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @AuthorCredit = isnull(@AuthorCredit,(('Anonymous Work'+char((13)))+char((10)))+'See https://commons.wikimedia.org/wiki/Anonymous_works')
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @FormTypeSCD is not null
		begin
		
			select
				@FormTypeSID = x.FormTypeSID
			from
				sf.FormType x
			where
				x.FormTypeSCD = @FormTypeSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @FormTypeSID  is null select @FormTypeSID  = x.FormTypeSID from sf.FormType  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>

		-- insert the record

		insert
			sf.Form
		(
			 FormTypeSID
			,FormName
			,FormLabel
			,FormContext
			,AuthorCredit
			,IsActive
			,UsageTerms
			,ApplicationUserSID
			,UsageNotes
			,FormInstructions
			,VersionHistory
			,UserDefinedColumns
			,FormXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @FormTypeSID
			,@FormName
			,@FormLabel
			,@FormContext
			,@AuthorCredit
			,@IsActive
			,@UsageTerms
			,@ApplicationUserSID
			,@UsageNotes
			,@FormInstructions
			,@VersionHistory
			,@UserDefinedColumns
			,@FormXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@FormSID = scope_identity()																				-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.Form'
				,@Arg3        = @rowsAffected
				,@Arg4        = @FormSID
			
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
				 ent.FormSID
			from
				sf.vForm ent
			where
				ent.FormSID = @FormSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.FormSID
				,ent.FormTypeSID
				,ent.FormName
				,ent.FormLabel
				,ent.FormContext
				,ent.AuthorCredit
				,ent.IsActive
				,ent.UsageTerms
				,ent.ApplicationUserSID
				,ent.UsageNotes
				,ent.FormInstructions
				,ent.VersionHistory
				,ent.UserDefinedColumns
				,ent.FormXID
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
				,ent.LastReviewTime
				,ent.LastReviewUser
				,ent.IsPotentialDuplicate
				,ent.IsTemplate
				,ent.GlassBreakPassword
				,ent.LastGlassBreakPasswordChangeTime
				,ent.ApplicationUserIsActive
				,ent.AuthenticationSystemID
				,ent.ApplicationUserRowGUID
				,ent.FormTypeSCD
				,ent.FormTypeLabel
				,ent.FormOwnerSID
				,ent.FormTypeIsDefault
				,ent.FormTypeRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.LatestVersionNo
				,ent.LatestRevisionNo
				,ent.LatestVersionFormVersionSID
				,ent.LatestRevisionFormVersionSID
			from
				sf.vForm ent
			where
				ent.FormSID = @FormSID

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