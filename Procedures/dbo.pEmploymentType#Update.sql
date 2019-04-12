SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pEmploymentType#Update]
	 @EmploymentTypeSID      int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@EmploymentTypeName     nvarchar(50)      = null -- table column values to update:
	,@EmploymentTypeCode     varchar(20)       = null
	,@EmploymentTypeCategory nvarchar(65)      = null
	,@IsDefault              bit               = null
	,@IsActive               bit               = null
	,@UserDefinedColumns     xml               = null
	,@EmploymentTypeXID      varchar(150)      = null
	,@LegacyKey              nvarchar(50)      = null
	,@UpdateUser             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected           tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied          bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext               xml               = null -- other values defining context for the update (if any)
	,@IsDeleteEnabled        bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pEmploymentType#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.EmploymentType table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.EmploymentType table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vEmploymentType entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pEmploymentType procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fEmploymentTypeCheck to test all rules.

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

		if @EmploymentTypeSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@EmploymentTypeSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @EmploymentTypeName = ltrim(rtrim(@EmploymentTypeName))
		set @EmploymentTypeCode = ltrim(rtrim(@EmploymentTypeCode))
		set @EmploymentTypeCategory = ltrim(rtrim(@EmploymentTypeCategory))
		set @EmploymentTypeXID = ltrim(rtrim(@EmploymentTypeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))

		-- set zero length strings to null to avoid storing them in the record

		if len(@EmploymentTypeName) = 0 set @EmploymentTypeName = null
		if len(@EmploymentTypeCode) = 0 set @EmploymentTypeCode = null
		if len(@EmploymentTypeCategory) = 0 set @EmploymentTypeCategory = null
		if len(@EmploymentTypeXID) = 0 set @EmploymentTypeXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @EmploymentTypeName     = isnull(@EmploymentTypeName,etype.EmploymentTypeName)
				,@EmploymentTypeCode     = isnull(@EmploymentTypeCode,etype.EmploymentTypeCode)
				,@EmploymentTypeCategory = isnull(@EmploymentTypeCategory,etype.EmploymentTypeCategory)
				,@IsDefault              = isnull(@IsDefault,etype.IsDefault)
				,@IsActive               = isnull(@IsActive,etype.IsActive)
				,@UserDefinedColumns     = isnull(@UserDefinedColumns,etype.UserDefinedColumns)
				,@EmploymentTypeXID      = isnull(@EmploymentTypeXID,etype.EmploymentTypeXID)
				,@LegacyKey              = isnull(@LegacyKey,etype.LegacyKey)
				,@UpdateUser             = isnull(@UpdateUser,etype.UpdateUser)
				,@IsReselected           = isnull(@IsReselected,etype.IsReselected)
				,@IsNullApplied          = isnull(@IsNullApplied,etype.IsNullApplied)
				,@zContext               = isnull(@zContext,etype.zContext)
				,@IsDeleteEnabled        = isnull(@IsDeleteEnabled,etype.IsDeleteEnabled)
			from
				dbo.vEmploymentType etype
			where
				etype.EmploymentTypeSID = @EmploymentTypeSID

		end
		
		-- prevent system code values from being modified
		
		if exists(select 1 from dbo.EmploymentType x where x.EmploymentTypeSID = @EmploymentTypeSID and left(x.EmploymentTypeCode, 2) = 'S!' and x.EmploymentTypeCode <> @EmploymentTypeCode)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  	= 'SystemCodeEdit'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'This code value is required by the application. The code cannot be edited.'
		
			raiserror(@errorText, 16, 1)
		
		end
		
		-- unset previous default if record is being marked as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.EmploymentTypeSID from dbo.EmploymentType x where x.IsDefault = @ON and x.EmploymentTypeSID <> @EmploymentTypeSID
			
			if @recordSID is not null
			begin
			
				update
					dbo.EmploymentType
				set
					 IsDefault  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					EmploymentTypeSID = @recordSID																	-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pEmploymentType'
		)
		begin
		
			exec @errorNo = ext.pEmploymentType
				 @Mode                   = 'update.pre'
				,@EmploymentTypeSID      = @EmploymentTypeSID
				,@EmploymentTypeName     = @EmploymentTypeName output
				,@EmploymentTypeCode     = @EmploymentTypeCode output
				,@EmploymentTypeCategory = @EmploymentTypeCategory output
				,@IsDefault              = @IsDefault output
				,@IsActive               = @IsActive output
				,@UserDefinedColumns     = @UserDefinedColumns output
				,@EmploymentTypeXID      = @EmploymentTypeXID output
				,@LegacyKey              = @LegacyKey output
				,@UpdateUser             = @UpdateUser
				,@RowStamp               = @RowStamp
				,@IsReselected           = @IsReselected
				,@IsNullApplied          = @IsNullApplied
				,@zContext               = @zContext
				,@IsDeleteEnabled        = @IsDeleteEnabled
		
		end

		-- update the record

		update
			dbo.EmploymentType
		set
			 EmploymentTypeName = @EmploymentTypeName
			,EmploymentTypeCode = @EmploymentTypeCode
			,EmploymentTypeCategory = @EmploymentTypeCategory
			,IsDefault = @IsDefault
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,EmploymentTypeXID = @EmploymentTypeXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			EmploymentTypeSID = @EmploymentTypeSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.EmploymentType where EmploymentTypeSID = @employmentTypeSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.EmploymentType'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.EmploymentType'
					,@Arg2        = @employmentTypeSID
				
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
				,@Arg2        = 'dbo.EmploymentType'
				,@Arg3        = @rowsAffected
				,@Arg4        = @employmentTypeSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
		
		-- ensure a default record is identified on the table
		
		if not exists
		(
			select 1 from	dbo.EmploymentType x where x.IsDefault = @ON
		)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'MissingDefault'
				,@MessageText = @errorText output
				,@DefaultText = N'A default %1 record is required by the application. (Setting another record as the new default automatically un-sets the previous one.)'
				,@Arg1        = 'Employment Type'
			
			raiserror(@errorText, 16, 1)
		end
	
		-- call the extended version of the procedure for update.post - if it exists
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pEmploymentType'
		)
		begin
		
			exec @errorNo = ext.pEmploymentType
				 @Mode                   = 'update.post'
				,@EmploymentTypeSID      = @EmploymentTypeSID
				,@EmploymentTypeName     = @EmploymentTypeName
				,@EmploymentTypeCode     = @EmploymentTypeCode
				,@EmploymentTypeCategory = @EmploymentTypeCategory
				,@IsDefault              = @IsDefault
				,@IsActive               = @IsActive
				,@UserDefinedColumns     = @UserDefinedColumns
				,@EmploymentTypeXID      = @EmploymentTypeXID
				,@LegacyKey              = @LegacyKey
				,@UpdateUser             = @UpdateUser
				,@RowStamp               = @RowStamp
				,@IsReselected           = @IsReselected
				,@IsNullApplied          = @IsNullApplied
				,@zContext               = @zContext
				,@IsDeleteEnabled        = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.EmploymentTypeSID
			from
				dbo.vEmploymentType ent
			where
				ent.EmploymentTypeSID = @EmploymentTypeSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.EmploymentTypeSID
				,ent.EmploymentTypeName
				,ent.EmploymentTypeCode
				,ent.EmploymentTypeCategory
				,ent.IsDefault
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.EmploymentTypeXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vEmploymentType ent
			where
				ent.EmploymentTypeSID = @EmploymentTypeSID

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