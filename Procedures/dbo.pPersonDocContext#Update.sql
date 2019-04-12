SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDocContext#Update]
	 @PersonDocContextSID      int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonDocSID             int               = null -- table column values to update:
	,@ApplicationEntitySID     int               = null
	,@EntitySID                int               = null
	,@IsPrimary                bit               = null
	,@UserDefinedColumns       xml               = null
	,@PersonDocContextXID      varchar(150)      = null
	,@LegacyKey                nvarchar(50)      = null
	,@UpdateUser               nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                 timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected             tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied            bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                 xml               = null -- other values defining context for the update (if any)
	,@PersonSID                int               = null -- not a base table column
	,@PersonDocTypeSID         int               = null -- not a base table column
	,@DocumentTitle            nvarchar(100)     = null -- not a base table column
	,@AdditionalInfo           nvarchar(50)      = null -- not a base table column
	,@ArchivedTime             datetimeoffset(7) = null -- not a base table column
	,@FileTypeSID              int               = null -- not a base table column
	,@FileTypeSCD              varchar(8)        = null -- not a base table column
	,@ShowToRegistrant         bit               = null -- not a base table column
	,@ApplicationGrantSID      int               = null -- not a base table column
	,@IsRemoved                bit               = null -- not a base table column
	,@ExpiryDate               date              = null -- not a base table column
	,@ApplicationReportSID     int               = null -- not a base table column
	,@ReportEntitySID          int               = null -- not a base table column
	,@CancelledTime            datetimeoffset(7) = null -- not a base table column
	,@ProcessedTime            datetimeoffset(7) = null -- not a base table column
	,@ContextLink              uniqueidentifier  = null -- not a base table column
	,@PersonDocRowGUID         uniqueidentifier  = null -- not a base table column
	,@ApplicationEntitySCD     varchar(50)       = null -- not a base table column
	,@ApplicationEntityName    nvarchar(50)      = null -- not a base table column
	,@IsMergeDataSource        bit               = null -- not a base table column
	,@ApplicationEntityRowGUID uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled          bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonDocContext#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PersonDocContext table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PersonDocContext table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonDocContext entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonDocContext procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonDocContextCheck to test all rules.

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

		if @PersonDocContextSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonDocContextSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PersonDocContextXID = ltrim(rtrim(@PersonDocContextXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @DocumentTitle = ltrim(rtrim(@DocumentTitle))
		set @AdditionalInfo = ltrim(rtrim(@AdditionalInfo))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @ApplicationEntitySCD = ltrim(rtrim(@ApplicationEntitySCD))
		set @ApplicationEntityName = ltrim(rtrim(@ApplicationEntityName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PersonDocContextXID) = 0 set @PersonDocContextXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@DocumentTitle) = 0 set @DocumentTitle = null
		if len(@AdditionalInfo) = 0 set @AdditionalInfo = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
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
				 @PersonDocSID             = isnull(@PersonDocSID,pdc.PersonDocSID)
				,@ApplicationEntitySID     = isnull(@ApplicationEntitySID,pdc.ApplicationEntitySID)
				,@EntitySID                = isnull(@EntitySID,pdc.EntitySID)
				,@IsPrimary                = isnull(@IsPrimary,pdc.IsPrimary)
				,@UserDefinedColumns       = isnull(@UserDefinedColumns,pdc.UserDefinedColumns)
				,@PersonDocContextXID      = isnull(@PersonDocContextXID,pdc.PersonDocContextXID)
				,@LegacyKey                = isnull(@LegacyKey,pdc.LegacyKey)
				,@UpdateUser               = isnull(@UpdateUser,pdc.UpdateUser)
				,@IsReselected             = isnull(@IsReselected,pdc.IsReselected)
				,@IsNullApplied            = isnull(@IsNullApplied,pdc.IsNullApplied)
				,@zContext                 = isnull(@zContext,pdc.zContext)
				,@PersonSID                = isnull(@PersonSID,pdc.PersonSID)
				,@PersonDocTypeSID         = isnull(@PersonDocTypeSID,pdc.PersonDocTypeSID)
				,@DocumentTitle            = isnull(@DocumentTitle,pdc.DocumentTitle)
				,@AdditionalInfo           = isnull(@AdditionalInfo,pdc.AdditionalInfo)
				,@ArchivedTime             = isnull(@ArchivedTime,pdc.ArchivedTime)
				,@FileTypeSID              = isnull(@FileTypeSID,pdc.FileTypeSID)
				,@FileTypeSCD              = isnull(@FileTypeSCD,pdc.FileTypeSCD)
				,@ShowToRegistrant         = isnull(@ShowToRegistrant,pdc.ShowToRegistrant)
				,@ApplicationGrantSID      = isnull(@ApplicationGrantSID,pdc.ApplicationGrantSID)
				,@IsRemoved                = isnull(@IsRemoved,pdc.IsRemoved)
				,@ExpiryDate               = isnull(@ExpiryDate,pdc.ExpiryDate)
				,@ApplicationReportSID     = isnull(@ApplicationReportSID,pdc.ApplicationReportSID)
				,@ReportEntitySID          = isnull(@ReportEntitySID,pdc.ReportEntitySID)
				,@CancelledTime            = isnull(@CancelledTime,pdc.CancelledTime)
				,@ProcessedTime            = isnull(@ProcessedTime,pdc.ProcessedTime)
				,@ContextLink              = isnull(@ContextLink,pdc.ContextLink)
				,@PersonDocRowGUID         = isnull(@PersonDocRowGUID,pdc.PersonDocRowGUID)
				,@ApplicationEntitySCD     = isnull(@ApplicationEntitySCD,pdc.ApplicationEntitySCD)
				,@ApplicationEntityName    = isnull(@ApplicationEntityName,pdc.ApplicationEntityName)
				,@IsMergeDataSource        = isnull(@IsMergeDataSource,pdc.IsMergeDataSource)
				,@ApplicationEntityRowGUID = isnull(@ApplicationEntityRowGUID,pdc.ApplicationEntityRowGUID)
				,@IsDeleteEnabled          = isnull(@IsDeleteEnabled,pdc.IsDeleteEnabled)
			from
				dbo.vPersonDocContext pdc
			where
				pdc.PersonDocContextSID = @PersonDocContextSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ApplicationEntitySCD is not null and @ApplicationEntitySID = (select x.ApplicationEntitySID from dbo.PersonDocContext x where x.PersonDocContextSID = @PersonDocContextSID)
		begin
		
			select
				@ApplicationEntitySID = x.ApplicationEntitySID
			from
				sf.ApplicationEntity x
			where
				x.ApplicationEntitySCD = @ApplicationEntitySCD
		
		end
		
		-- unset previous primary if record is being marked as the new primary
		
		if @IsPrimary = @ON
		begin
		
			select @recordSID = x.PersonDocContextSID from dbo.PersonDocContext x where x.IsPrimary = @ON and x.ApplicationEntitySID = @ApplicationEntitySID and x.EntitySID = @EntitySID and x.PersonDocContextSID <> @PersonDocContextSID
			
			if @recordSID is not null
			begin
			
				update
					dbo.PersonDocContext
				set
					 IsPrimary  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PersonDocContextSID = @recordSID																-- unique index ensures only 1 record needs to be unset
				
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
				r.RoutineName = 'pPersonDocContext'
		)
		begin
		
			exec @errorNo = ext.pPersonDocContext
				 @Mode                     = 'update.pre'
				,@PersonDocContextSID      = @PersonDocContextSID
				,@PersonDocSID             = @PersonDocSID output
				,@ApplicationEntitySID     = @ApplicationEntitySID output
				,@EntitySID                = @EntitySID output
				,@IsPrimary                = @IsPrimary output
				,@UserDefinedColumns       = @UserDefinedColumns output
				,@PersonDocContextXID      = @PersonDocContextXID output
				,@LegacyKey                = @LegacyKey output
				,@UpdateUser               = @UpdateUser
				,@RowStamp                 = @RowStamp
				,@IsReselected             = @IsReselected
				,@IsNullApplied            = @IsNullApplied
				,@zContext                 = @zContext
				,@PersonSID                = @PersonSID
				,@PersonDocTypeSID         = @PersonDocTypeSID
				,@DocumentTitle            = @DocumentTitle
				,@AdditionalInfo           = @AdditionalInfo
				,@ArchivedTime             = @ArchivedTime
				,@FileTypeSID              = @FileTypeSID
				,@FileTypeSCD              = @FileTypeSCD
				,@ShowToRegistrant         = @ShowToRegistrant
				,@ApplicationGrantSID      = @ApplicationGrantSID
				,@IsRemoved                = @IsRemoved
				,@ExpiryDate               = @ExpiryDate
				,@ApplicationReportSID     = @ApplicationReportSID
				,@ReportEntitySID          = @ReportEntitySID
				,@CancelledTime            = @CancelledTime
				,@ProcessedTime            = @ProcessedTime
				,@ContextLink              = @ContextLink
				,@PersonDocRowGUID         = @PersonDocRowGUID
				,@ApplicationEntitySCD     = @ApplicationEntitySCD
				,@ApplicationEntityName    = @ApplicationEntityName
				,@IsMergeDataSource        = @IsMergeDataSource
				,@ApplicationEntityRowGUID = @ApplicationEntityRowGUID
				,@IsDeleteEnabled          = @IsDeleteEnabled
		
		end

		-- update the record

		update
			dbo.PersonDocContext
		set
			 PersonDocSID = @PersonDocSID
			,ApplicationEntitySID = @ApplicationEntitySID
			,EntitySID = @EntitySID
			,IsPrimary = @IsPrimary
			,UserDefinedColumns = @UserDefinedColumns
			,PersonDocContextXID = @PersonDocContextXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonDocContextSID = @PersonDocContextSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PersonDocContext where PersonDocContextSID = @personDocContextSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PersonDocContext'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PersonDocContext'
					,@Arg2        = @personDocContextSID
				
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
				,@Arg2        = 'dbo.PersonDocContext'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personDocContextSID
			
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
				r.RoutineName = 'pPersonDocContext'
		)
		begin
		
			exec @errorNo = ext.pPersonDocContext
				 @Mode                     = 'update.post'
				,@PersonDocContextSID      = @PersonDocContextSID
				,@PersonDocSID             = @PersonDocSID
				,@ApplicationEntitySID     = @ApplicationEntitySID
				,@EntitySID                = @EntitySID
				,@IsPrimary                = @IsPrimary
				,@UserDefinedColumns       = @UserDefinedColumns
				,@PersonDocContextXID      = @PersonDocContextXID
				,@LegacyKey                = @LegacyKey
				,@UpdateUser               = @UpdateUser
				,@RowStamp                 = @RowStamp
				,@IsReselected             = @IsReselected
				,@IsNullApplied            = @IsNullApplied
				,@zContext                 = @zContext
				,@PersonSID                = @PersonSID
				,@PersonDocTypeSID         = @PersonDocTypeSID
				,@DocumentTitle            = @DocumentTitle
				,@AdditionalInfo           = @AdditionalInfo
				,@ArchivedTime             = @ArchivedTime
				,@FileTypeSID              = @FileTypeSID
				,@FileTypeSCD              = @FileTypeSCD
				,@ShowToRegistrant         = @ShowToRegistrant
				,@ApplicationGrantSID      = @ApplicationGrantSID
				,@IsRemoved                = @IsRemoved
				,@ExpiryDate               = @ExpiryDate
				,@ApplicationReportSID     = @ApplicationReportSID
				,@ReportEntitySID          = @ReportEntitySID
				,@CancelledTime            = @CancelledTime
				,@ProcessedTime            = @ProcessedTime
				,@ContextLink              = @ContextLink
				,@PersonDocRowGUID         = @PersonDocRowGUID
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
				 ent.PersonDocContextSID
			from
				dbo.vPersonDocContext ent
			where
				ent.PersonDocContextSID = @PersonDocContextSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonDocContextSID
				,ent.PersonDocSID
				,ent.ApplicationEntitySID
				,ent.EntitySID
				,ent.IsPrimary
				,ent.UserDefinedColumns
				,ent.PersonDocContextXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonSID
				,ent.PersonDocTypeSID
				,ent.DocumentTitle
				,ent.AdditionalInfo
				,ent.ArchivedTime
				,ent.FileTypeSID
				,ent.FileTypeSCD
				,ent.ShowToRegistrant
				,ent.ApplicationGrantSID
				,ent.IsRemoved
				,ent.ExpiryDate
				,ent.ApplicationReportSID
				,ent.ReportEntitySID
				,ent.CancelledTime
				,ent.ProcessedTime
				,ent.ContextLink
				,ent.PersonDocRowGUID
				,ent.ApplicationEntitySCD
				,ent.ApplicationEntityName
				,ent.IsMergeDataSource
				,ent.ApplicationEntityRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vPersonDocContext ent
			where
				ent.PersonDocContextSID = @PersonDocContextSID

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