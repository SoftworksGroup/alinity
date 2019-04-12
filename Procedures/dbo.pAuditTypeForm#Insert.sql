SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pAuditTypeForm#Insert]
	 @AuditTypeFormSID   int               = null output										-- identity value assigned to the new record
	,@AuditTypeSID       int               = null														-- required! if not passed value must be set in custom logic prior to insert
	,@FormSID            int               = null														-- required! if not passed value must be set in custom logic prior to insert
	,@IsReviewForm       bit               = null														-- default: CONVERT(bit,(0))
	,@UserDefinedColumns xml               = null														
	,@AuditTypeFormXID   varchar(150)      = null														
	,@LegacyKey          nvarchar(50)      = null														
	,@CreateUser         nvarchar(75)      = null														-- default: suser_sname()
	,@IsReselected       tinyint           = null														-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext           xml               = null														-- other values defining context for the insert (if any)
	,@AuditTypeLabel     nvarchar(35)      = null														-- not a base table column (default ignored)
	,@AuditTypeCategory  nvarchar(65)      = null														-- not a base table column (default ignored)
	,@AuditTypeIsDefault bit               = null														-- not a base table column (default ignored)
	,@AuditTypeIsActive  bit               = null														-- not a base table column (default ignored)
	,@AuditTypeRowGUID   uniqueidentifier  = null														-- not a base table column (default ignored)
	,@FormTypeSID        int               = null														-- not a base table column (default ignored)
	,@FormName           nvarchar(65)      = null														-- not a base table column (default ignored)
	,@FormLabel          nvarchar(35)      = null														-- not a base table column (default ignored)
	,@FormContext        varchar(25)       = null														-- not a base table column (default ignored)
	,@AuthorCredit       nvarchar(500)     = null														-- not a base table column (default ignored)
	,@FormIsActive       bit               = null														-- not a base table column (default ignored)
	,@ApplicationUserSID int               = null														-- not a base table column (default ignored)
	,@FormRowGUID        uniqueidentifier  = null														-- not a base table column (default ignored)
	,@IsDeleteEnabled    bit               = null														-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pAuditTypeForm#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.AuditTypeForm table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.AuditTypeForm table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vAuditTypeForm entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pAuditTypeForm procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fAuditTypeFormCheck to test all rules.

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

	set @AuditTypeFormSID = null																						-- initialize output parameter

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

		set @AuditTypeFormXID = ltrim(rtrim(@AuditTypeFormXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @AuditTypeLabel = ltrim(rtrim(@AuditTypeLabel))
		set @AuditTypeCategory = ltrim(rtrim(@AuditTypeCategory))
		set @FormName = ltrim(rtrim(@FormName))
		set @FormLabel = ltrim(rtrim(@FormLabel))
		set @FormContext = ltrim(rtrim(@FormContext))
		set @AuthorCredit = ltrim(rtrim(@AuthorCredit))

		-- set zero length strings to null to avoid storing them in the record

		if len(@AuditTypeFormXID) = 0 set @AuditTypeFormXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@AuditTypeLabel) = 0 set @AuditTypeLabel = null
		if len(@AuditTypeCategory) = 0 set @AuditTypeCategory = null
		if len(@FormName) = 0 set @FormName = null
		if len(@FormLabel) = 0 set @FormLabel = null
		if len(@FormContext) = 0 set @FormContext = null
		if len(@AuthorCredit) = 0 set @AuthorCredit = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsReviewForm = isnull(@IsReviewForm,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @AuditTypeSID  is null select @AuditTypeSID  = x.AuditTypeSID from dbo.AuditType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pAuditTypeForm'
		)
		begin
		
			exec @errorNo = ext.pAuditTypeForm
				 @Mode               = 'insert.pre'
				,@AuditTypeSID       = @AuditTypeSID output
				,@FormSID            = @FormSID output
				,@IsReviewForm       = @IsReviewForm output
				,@UserDefinedColumns = @UserDefinedColumns output
				,@AuditTypeFormXID   = @AuditTypeFormXID output
				,@LegacyKey          = @LegacyKey output
				,@CreateUser         = @CreateUser
				,@IsReselected       = @IsReselected
				,@zContext           = @zContext
				,@AuditTypeLabel     = @AuditTypeLabel
				,@AuditTypeCategory  = @AuditTypeCategory
				,@AuditTypeIsDefault = @AuditTypeIsDefault
				,@AuditTypeIsActive  = @AuditTypeIsActive
				,@AuditTypeRowGUID   = @AuditTypeRowGUID
				,@FormTypeSID        = @FormTypeSID
				,@FormName           = @FormName
				,@FormLabel          = @FormLabel
				,@FormContext        = @FormContext
				,@AuthorCredit       = @AuthorCredit
				,@FormIsActive       = @FormIsActive
				,@ApplicationUserSID = @ApplicationUserSID
				,@FormRowGUID        = @FormRowGUID
				,@IsDeleteEnabled    = @IsDeleteEnabled
		
		end

		-- insert the record

		insert
			dbo.AuditTypeForm
		(
			 AuditTypeSID
			,FormSID
			,IsReviewForm
			,UserDefinedColumns
			,AuditTypeFormXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @AuditTypeSID
			,@FormSID
			,@IsReviewForm
			,@UserDefinedColumns
			,@AuditTypeFormXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected     = @@rowcount
			,@AuditTypeFormSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.AuditTypeForm'
				,@Arg3        = @rowsAffected
				,@Arg4        = @AuditTypeFormSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pAuditTypeForm'
		)
		begin
		
			exec @errorNo = ext.pAuditTypeForm
				 @Mode               = 'insert.post'
				,@AuditTypeFormSID   = @AuditTypeFormSID
				,@AuditTypeSID       = @AuditTypeSID
				,@FormSID            = @FormSID
				,@IsReviewForm       = @IsReviewForm
				,@UserDefinedColumns = @UserDefinedColumns
				,@AuditTypeFormXID   = @AuditTypeFormXID
				,@LegacyKey          = @LegacyKey
				,@CreateUser         = @CreateUser
				,@IsReselected       = @IsReselected
				,@zContext           = @zContext
				,@AuditTypeLabel     = @AuditTypeLabel
				,@AuditTypeCategory  = @AuditTypeCategory
				,@AuditTypeIsDefault = @AuditTypeIsDefault
				,@AuditTypeIsActive  = @AuditTypeIsActive
				,@AuditTypeRowGUID   = @AuditTypeRowGUID
				,@FormTypeSID        = @FormTypeSID
				,@FormName           = @FormName
				,@FormLabel          = @FormLabel
				,@FormContext        = @FormContext
				,@AuthorCredit       = @AuthorCredit
				,@FormIsActive       = @FormIsActive
				,@ApplicationUserSID = @ApplicationUserSID
				,@FormRowGUID        = @FormRowGUID
				,@IsDeleteEnabled    = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.AuditTypeFormSID
			from
				dbo.vAuditTypeForm ent
			where
				ent.AuditTypeFormSID = @AuditTypeFormSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.AuditTypeFormSID
				,ent.AuditTypeSID
				,ent.FormSID
				,ent.IsReviewForm
				,ent.UserDefinedColumns
				,ent.AuditTypeFormXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.AuditTypeLabel
				,ent.AuditTypeCategory
				,ent.AuditTypeIsDefault
				,ent.AuditTypeIsActive
				,ent.AuditTypeRowGUID
				,ent.FormTypeSID
				,ent.FormName
				,ent.FormLabel
				,ent.FormContext
				,ent.AuthorCredit
				,ent.FormIsActive
				,ent.ApplicationUserSID
				,ent.FormRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vAuditTypeForm ent
			where
				ent.AuditTypeFormSID = @AuditTypeFormSID

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
