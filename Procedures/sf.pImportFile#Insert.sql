SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pImportFile#Insert]
	 @ImportFileSID            int               = null output							-- identity value assigned to the new record
	,@FileFormatSID            int               = null											-- required! if not passed value must be set in custom logic prior to insert
	,@ApplicationEntitySID     int               = null											-- required! if not passed value must be set in custom logic prior to insert
	,@FileName                 nvarchar(100)     = null											-- required! if not passed value must be set in custom logic prior to insert
	,@FileContent              varbinary(max)    = null											
	,@LoadStartTime            datetimeoffset(7) = null											
	,@LoadEndTime              datetimeoffset(7) = null											
	,@IsFailed                 bit               = null											-- default: (0)
	,@MessageText              nvarchar(4000)    = null											
	,@UserDefinedColumns       xml               = null											
	,@ImportFileXID            varchar(150)      = null											
	,@LegacyKey                nvarchar(50)      = null											
	,@CreateUser               nvarchar(75)      = null											-- default: suser_sname()
	,@IsReselected             tinyint           = null											-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                 xml               = null											-- other values defining context for the insert (if any)
	,@ApplicationEntitySCD     varchar(50)       = null											-- not a base table column (default ignored)
	,@ApplicationEntityName    nvarchar(50)      = null											-- not a base table column (default ignored)
	,@IsMergeDataSource        bit               = null											-- not a base table column (default ignored)
	,@ApplicationEntityRowGUID uniqueidentifier  = null											-- not a base table column (default ignored)
	,@FileFormatSCD            varchar(10)       = null											-- not a base table column (default ignored)
	,@FileFormatLabel          nvarchar(35)      = null											-- not a base table column (default ignored)
	,@FileFormatIsDefault      bit               = null											-- not a base table column (default ignored)
	,@FileFormatRowGUID        uniqueidentifier  = null											-- not a base table column (default ignored)
	,@IsDeleteEnabled          bit               = null											-- not a base table column (default ignored)
	,@IsComplete               bit               = null											-- not a base table column (default ignored)
	,@IsInProcess              bit               = null											-- not a base table column (default ignored)
	,@MinutesInProcess         int               = null											-- not a base table column (default ignored)
	,@FileLength               bigint            = null											-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pImportFile#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.ImportFile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.ImportFile table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vImportFile entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pImportFile procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fImportFileCheck to test all rules.

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

	set @ImportFileSID = null																								-- initialize output parameter

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

		set @FileName = ltrim(rtrim(@FileName))
		set @MessageText = ltrim(rtrim(@MessageText))
		set @ImportFileXID = ltrim(rtrim(@ImportFileXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @ApplicationEntitySCD = ltrim(rtrim(@ApplicationEntitySCD))
		set @ApplicationEntityName = ltrim(rtrim(@ApplicationEntityName))
		set @FileFormatSCD = ltrim(rtrim(@FileFormatSCD))
		set @FileFormatLabel = ltrim(rtrim(@FileFormatLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@FileName) = 0 set @FileName = null
		if len(@MessageText) = 0 set @MessageText = null
		if len(@ImportFileXID) = 0 set @ImportFileXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@ApplicationEntitySCD) = 0 set @ApplicationEntitySCD = null
		if len(@ApplicationEntityName) = 0 set @ApplicationEntityName = null
		if len(@FileFormatSCD) = 0 set @FileFormatSCD = null
		if len(@FileFormatLabel) = 0 set @FileFormatLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsFailed = isnull(@IsFailed,(0))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected         = isnull(@IsReselected        ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ApplicationEntitySCD is not null
		begin
		
			select
				@ApplicationEntitySID = x.ApplicationEntitySID
			from
				sf.ApplicationEntity x
			where
				x.ApplicationEntitySCD = @ApplicationEntitySCD
		
		end
		
		if @FileFormatSCD is not null
		begin
		
			select
				@FileFormatSID = x.FileFormatSID
			from
				sf.FileFormat x
			where
				x.FileFormatSCD = @FileFormatSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @FileFormatSID  is null select @FileFormatSID  = x.FileFormatSID from sf.FileFormat  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>

		-- insert the record

		insert
			sf.ImportFile
		(
			 FileFormatSID
			,ApplicationEntitySID
			,FileName
			,FileContent
			,LoadStartTime
			,LoadEndTime
			,IsFailed
			,MessageText
			,UserDefinedColumns
			,ImportFileXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @FileFormatSID
			,@ApplicationEntitySID
			,@FileName
			,@FileContent
			,@LoadStartTime
			,@LoadEndTime
			,@IsFailed
			,@MessageText
			,@UserDefinedColumns
			,@ImportFileXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected  = @@rowcount
			,@ImportFileSID = scope_identity()																	-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.ImportFile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @ImportFileSID
			
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
				 ent.ImportFileSID
			from
				sf.vImportFile ent
			where
				ent.ImportFileSID = @ImportFileSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ImportFileSID
				,ent.FileFormatSID
				,ent.ApplicationEntitySID
				,ent.FileName
				,ent.FileContent
				,ent.LoadStartTime
				,ent.LoadEndTime
				,ent.IsFailed
				,ent.MessageText
				,ent.UserDefinedColumns
				,ent.ImportFileXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ApplicationEntitySCD
				,ent.ApplicationEntityName
				,ent.IsMergeDataSource
				,ent.ApplicationEntityRowGUID
				,ent.FileFormatSCD
				,ent.FileFormatLabel
				,ent.FileFormatIsDefault
				,ent.FileFormatRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsComplete
				,ent.IsInProcess
				,ent.MinutesInProcess
				,ent.FileLength
			from
				sf.vImportFile ent
			where
				ent.ImportFileSID = @ImportFileSID

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
