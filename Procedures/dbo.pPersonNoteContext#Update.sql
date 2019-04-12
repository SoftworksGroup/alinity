SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonNoteContext#Update]
	 @PersonNoteContextSID     int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonNoteSID            int               = null -- table column values to update:
	,@ApplicationEntitySID     int               = null
	,@EntitySID                int               = null
	,@UserDefinedColumns       xml               = null
	,@PersonNoteContextXID     varchar(150)      = null
	,@LegacyKey                nvarchar(50)      = null
	,@UpdateUser               nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                 timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected             tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied            bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                 xml               = null -- other values defining context for the update (if any)
	,@PersonSID                int               = null -- not a base table column
	,@PersonNoteTypeSID        int               = null -- not a base table column
	,@NoteTitle                nvarchar(65)      = null -- not a base table column
	,@ShowToRegistrant         bit               = null -- not a base table column
	,@ApplicationGrantSID      int               = null -- not a base table column
	,@PersonNoteRowGUID        uniqueidentifier  = null -- not a base table column
	,@ApplicationEntitySCD     varchar(50)       = null -- not a base table column
	,@ApplicationEntityName    nvarchar(50)      = null -- not a base table column
	,@IsMergeDataSource        bit               = null -- not a base table column
	,@ApplicationEntityRowGUID uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled          bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonNoteContext#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PersonNoteContext table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PersonNoteContext table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonNoteContext entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonNoteContext procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonNoteContextCheck to test all rules.

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

		if @PersonNoteContextSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonNoteContextSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PersonNoteContextXID = ltrim(rtrim(@PersonNoteContextXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @NoteTitle = ltrim(rtrim(@NoteTitle))
		set @ApplicationEntitySCD = ltrim(rtrim(@ApplicationEntitySCD))
		set @ApplicationEntityName = ltrim(rtrim(@ApplicationEntityName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PersonNoteContextXID) = 0 set @PersonNoteContextXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@NoteTitle) = 0 set @NoteTitle = null
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
				 @PersonNoteSID            = isnull(@PersonNoteSID,pnc.PersonNoteSID)
				,@ApplicationEntitySID     = isnull(@ApplicationEntitySID,pnc.ApplicationEntitySID)
				,@EntitySID                = isnull(@EntitySID,pnc.EntitySID)
				,@UserDefinedColumns       = isnull(@UserDefinedColumns,pnc.UserDefinedColumns)
				,@PersonNoteContextXID     = isnull(@PersonNoteContextXID,pnc.PersonNoteContextXID)
				,@LegacyKey                = isnull(@LegacyKey,pnc.LegacyKey)
				,@UpdateUser               = isnull(@UpdateUser,pnc.UpdateUser)
				,@IsReselected             = isnull(@IsReselected,pnc.IsReselected)
				,@IsNullApplied            = isnull(@IsNullApplied,pnc.IsNullApplied)
				,@zContext                 = isnull(@zContext,pnc.zContext)
				,@PersonSID                = isnull(@PersonSID,pnc.PersonSID)
				,@PersonNoteTypeSID        = isnull(@PersonNoteTypeSID,pnc.PersonNoteTypeSID)
				,@NoteTitle                = isnull(@NoteTitle,pnc.NoteTitle)
				,@ShowToRegistrant         = isnull(@ShowToRegistrant,pnc.ShowToRegistrant)
				,@ApplicationGrantSID      = isnull(@ApplicationGrantSID,pnc.ApplicationGrantSID)
				,@PersonNoteRowGUID        = isnull(@PersonNoteRowGUID,pnc.PersonNoteRowGUID)
				,@ApplicationEntitySCD     = isnull(@ApplicationEntitySCD,pnc.ApplicationEntitySCD)
				,@ApplicationEntityName    = isnull(@ApplicationEntityName,pnc.ApplicationEntityName)
				,@IsMergeDataSource        = isnull(@IsMergeDataSource,pnc.IsMergeDataSource)
				,@ApplicationEntityRowGUID = isnull(@ApplicationEntityRowGUID,pnc.ApplicationEntityRowGUID)
				,@IsDeleteEnabled          = isnull(@IsDeleteEnabled,pnc.IsDeleteEnabled)
			from
				dbo.vPersonNoteContext pnc
			where
				pnc.PersonNoteContextSID = @PersonNoteContextSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ApplicationEntitySCD is not null and @ApplicationEntitySID = (select x.ApplicationEntitySID from dbo.PersonNoteContext x where x.PersonNoteContextSID = @PersonNoteContextSID)
		begin
		
			select
				@ApplicationEntitySID = x.ApplicationEntitySID
			from
				sf.ApplicationEntity x
			where
				x.ApplicationEntitySCD = @ApplicationEntitySCD
		
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
				r.RoutineName = 'pPersonNoteContext'
		)
		begin
		
			exec @errorNo = ext.pPersonNoteContext
				 @Mode                     = 'update.pre'
				,@PersonNoteContextSID     = @PersonNoteContextSID
				,@PersonNoteSID            = @PersonNoteSID output
				,@ApplicationEntitySID     = @ApplicationEntitySID output
				,@EntitySID                = @EntitySID output
				,@UserDefinedColumns       = @UserDefinedColumns output
				,@PersonNoteContextXID     = @PersonNoteContextXID output
				,@LegacyKey                = @LegacyKey output
				,@UpdateUser               = @UpdateUser
				,@RowStamp                 = @RowStamp
				,@IsReselected             = @IsReselected
				,@IsNullApplied            = @IsNullApplied
				,@zContext                 = @zContext
				,@PersonSID                = @PersonSID
				,@PersonNoteTypeSID        = @PersonNoteTypeSID
				,@NoteTitle                = @NoteTitle
				,@ShowToRegistrant         = @ShowToRegistrant
				,@ApplicationGrantSID      = @ApplicationGrantSID
				,@PersonNoteRowGUID        = @PersonNoteRowGUID
				,@ApplicationEntitySCD     = @ApplicationEntitySCD
				,@ApplicationEntityName    = @ApplicationEntityName
				,@IsMergeDataSource        = @IsMergeDataSource
				,@ApplicationEntityRowGUID = @ApplicationEntityRowGUID
				,@IsDeleteEnabled          = @IsDeleteEnabled
		
		end

		-- update the record

		update
			dbo.PersonNoteContext
		set
			 PersonNoteSID = @PersonNoteSID
			,ApplicationEntitySID = @ApplicationEntitySID
			,EntitySID = @EntitySID
			,UserDefinedColumns = @UserDefinedColumns
			,PersonNoteContextXID = @PersonNoteContextXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonNoteContextSID = @PersonNoteContextSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PersonNoteContext where PersonNoteContextSID = @personNoteContextSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PersonNoteContext'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PersonNoteContext'
					,@Arg2        = @personNoteContextSID
				
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
				,@Arg2        = 'dbo.PersonNoteContext'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personNoteContextSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
	
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
				r.RoutineName = 'pPersonNoteContext'
		)
		begin
		
			exec @errorNo = ext.pPersonNoteContext
				 @Mode                     = 'update.post'
				,@PersonNoteContextSID     = @PersonNoteContextSID
				,@PersonNoteSID            = @PersonNoteSID
				,@ApplicationEntitySID     = @ApplicationEntitySID
				,@EntitySID                = @EntitySID
				,@UserDefinedColumns       = @UserDefinedColumns
				,@PersonNoteContextXID     = @PersonNoteContextXID
				,@LegacyKey                = @LegacyKey
				,@UpdateUser               = @UpdateUser
				,@RowStamp                 = @RowStamp
				,@IsReselected             = @IsReselected
				,@IsNullApplied            = @IsNullApplied
				,@zContext                 = @zContext
				,@PersonSID                = @PersonSID
				,@PersonNoteTypeSID        = @PersonNoteTypeSID
				,@NoteTitle                = @NoteTitle
				,@ShowToRegistrant         = @ShowToRegistrant
				,@ApplicationGrantSID      = @ApplicationGrantSID
				,@PersonNoteRowGUID        = @PersonNoteRowGUID
				,@ApplicationEntitySCD     = @ApplicationEntitySCD
				,@ApplicationEntityName    = @ApplicationEntityName
				,@IsMergeDataSource        = @IsMergeDataSource
				,@ApplicationEntityRowGUID = @ApplicationEntityRowGUID
				,@IsDeleteEnabled          = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PersonNoteContextSID
			from
				dbo.vPersonNoteContext ent
			where
				ent.PersonNoteContextSID = @PersonNoteContextSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonNoteContextSID
				,ent.PersonNoteSID
				,ent.ApplicationEntitySID
				,ent.EntitySID
				,ent.UserDefinedColumns
				,ent.PersonNoteContextXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonSID
				,ent.PersonNoteTypeSID
				,ent.NoteTitle
				,ent.ShowToRegistrant
				,ent.ApplicationGrantSID
				,ent.PersonNoteRowGUID
				,ent.ApplicationEntitySCD
				,ent.ApplicationEntityName
				,ent.IsMergeDataSource
				,ent.ApplicationEntityRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vPersonNoteContext ent
			where
				ent.PersonNoteContextSID = @PersonNoteContextSID

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
