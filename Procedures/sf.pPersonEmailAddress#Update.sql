SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonEmailAddress#Update]
	 @PersonEmailAddressSID  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID              int               = null -- table column values to update:
	,@EmailAddress           varchar(150)      = null
	,@IsPrimary              bit               = null
	,@IsActive               bit               = null
	,@ChangeAudit            nvarchar(max)     = null
	,@UserDefinedColumns     xml               = null
	,@PersonEmailAddressXID  varchar(150)      = null
	,@LegacyKey              nvarchar(50)      = null
	,@UpdateUser             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected           tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied          bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext               xml               = null -- other values defining context for the update (if any)
	,@GenderSID              int               = null -- not a base table column
	,@NamePrefixSID          int               = null -- not a base table column
	,@FirstName              nvarchar(30)      = null -- not a base table column
	,@CommonName             nvarchar(30)      = null -- not a base table column
	,@MiddleNames            nvarchar(30)      = null -- not a base table column
	,@LastName               nvarchar(35)      = null -- not a base table column
	,@BirthDate              date              = null -- not a base table column
	,@DeathDate              date              = null -- not a base table column
	,@HomePhone              varchar(25)       = null -- not a base table column
	,@MobilePhone            varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled bit               = null -- not a base table column
	,@ImportBatch            nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID          uniqueidentifier  = null -- not a base table column
	,@ChangeReason           nvarchar(4000)    = null -- not a base table column
	,@IsDeleteEnabled        bit               = null -- not a base table column
	,@IsEmailUsedForLogin    bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pPersonEmailAddress#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.PersonEmailAddress table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.PersonEmailAddress table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonEmailAddress entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonEmailAddress procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonEmailAddressCheck to test all rules.

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

		if @PersonEmailAddressSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonEmailAddressSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @PersonEmailAddressXID = ltrim(rtrim(@PersonEmailAddressXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ChangeReason = ltrim(rtrim(@ChangeReason))

		-- set zero length strings to null to avoid storing them in the record

		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@ChangeAudit) = 0 set @ChangeAudit = null
		if len(@PersonEmailAddressXID) = 0 set @PersonEmailAddressXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ChangeReason) = 0 set @ChangeReason = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID              = isnull(@PersonSID,pea.PersonSID)
				,@EmailAddress           = isnull(@EmailAddress,pea.EmailAddress)
				,@IsPrimary              = isnull(@IsPrimary,pea.IsPrimary)
				,@IsActive               = isnull(@IsActive,pea.IsActive)
				,@ChangeAudit            = isnull(@ChangeAudit,pea.ChangeAudit)
				,@UserDefinedColumns     = isnull(@UserDefinedColumns,pea.UserDefinedColumns)
				,@PersonEmailAddressXID  = isnull(@PersonEmailAddressXID,pea.PersonEmailAddressXID)
				,@LegacyKey              = isnull(@LegacyKey,pea.LegacyKey)
				,@UpdateUser             = isnull(@UpdateUser,pea.UpdateUser)
				,@IsReselected           = isnull(@IsReselected,pea.IsReselected)
				,@IsNullApplied          = isnull(@IsNullApplied,pea.IsNullApplied)
				,@zContext               = isnull(@zContext,pea.zContext)
				,@GenderSID              = isnull(@GenderSID,pea.GenderSID)
				,@NamePrefixSID          = isnull(@NamePrefixSID,pea.NamePrefixSID)
				,@FirstName              = isnull(@FirstName,pea.FirstName)
				,@CommonName             = isnull(@CommonName,pea.CommonName)
				,@MiddleNames            = isnull(@MiddleNames,pea.MiddleNames)
				,@LastName               = isnull(@LastName,pea.LastName)
				,@BirthDate              = isnull(@BirthDate,pea.BirthDate)
				,@DeathDate              = isnull(@DeathDate,pea.DeathDate)
				,@HomePhone              = isnull(@HomePhone,pea.HomePhone)
				,@MobilePhone            = isnull(@MobilePhone,pea.MobilePhone)
				,@IsTextMessagingEnabled = isnull(@IsTextMessagingEnabled,pea.IsTextMessagingEnabled)
				,@ImportBatch            = isnull(@ImportBatch,pea.ImportBatch)
				,@PersonRowGUID          = isnull(@PersonRowGUID,pea.PersonRowGUID)
				,@ChangeReason           = isnull(@ChangeReason,pea.ChangeReason)
				,@IsDeleteEnabled        = isnull(@IsDeleteEnabled,pea.IsDeleteEnabled)
				,@IsEmailUsedForLogin    = isnull(@IsEmailUsedForLogin,pea.IsEmailUsedForLogin)
			from
				sf.vPersonEmailAddress pea
			where
				pea.PersonEmailAddressSID = @PersonEmailAddressSID

		end
		
		-- update audit column when a change to the status of the record is detected
		
		if not exists
		(
			select
				1
			from
				sf.PersonEmailAddress x
			where
				x.PersonEmailAddressSID = @PersonEmailAddressSID									-- search for same record
			and
				x.IsActive = @IsActive																						-- with active bit value as passed
		)
		begin
			set @ChangeAudit = sf.fChangeAudit#Active(@IsActive, @ChangeReason, @ChangeAudit)
		end
		
		-- unset previous primary if record is being marked as the new primary
		
		if @IsPrimary = @ON
		begin
		
			select @recordSID = x.PersonEmailAddressSID from sf.PersonEmailAddress x where x.IsPrimary = @ON and x.PersonSID = @PersonSID and x.PersonEmailAddressSID <> @PersonEmailAddressSID
			
			if @recordSID is not null
			begin
			
				update
					sf.PersonEmailAddress
				set
					 IsPrimary  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PersonEmailAddressSID = @recordSID															-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...

		--check if the member had this email previously in their email history
		--if found, overwrite the @PersonEmailAddressSID so that we reactivate that old record
		set @recordSID = null

		select
			@recordSID = pea.PersonEmailAddressSID
		from
			sf.PersonEmailAddress pea
		where
			pea.PersonSID = @PersonSID
		and
			pea.EmailAddress = @EmailAddress
		and
			pea.IsPrimary = @OFF

		if @recordSID is not null
		begin

			update
				sf.PersonEmailAddress
			set
				 IsPrimary  = @OFF
				,UpdateUser = @UpdateUser
				,UpdateTime = sysdatetimeoffset()
			where
				PersonEmailAddressSID = @PersonEmailAddressSID

			set @PersonEmailAddressSID = @recordSID

		end

		--! </PreUpdate>

		-- update the record

		update
			sf.PersonEmailAddress
		set
			 PersonSID = @PersonSID
			,EmailAddress = @EmailAddress
			,IsPrimary = @IsPrimary
			,IsActive = @IsActive
			,ChangeAudit = @ChangeAudit
			,UserDefinedColumns = @UserDefinedColumns
			,PersonEmailAddressXID = @PersonEmailAddressXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonEmailAddressSID = @PersonEmailAddressSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.PersonEmailAddress where PersonEmailAddressSID = @personEmailAddressSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.PersonEmailAddress'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.PersonEmailAddress'
					,@Arg2        = @personEmailAddressSID
				
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
				,@Arg2        = 'sf.PersonEmailAddress'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personEmailAddressSID
			
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
				 ent.PersonEmailAddressSID
			from
				sf.vPersonEmailAddress ent
			where
				ent.PersonEmailAddressSID = @PersonEmailAddressSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonEmailAddressSID
				,ent.PersonSID
				,ent.EmailAddress
				,ent.IsPrimary
				,ent.IsActive
				,ent.ChangeAudit
				,ent.UserDefinedColumns
				,ent.PersonEmailAddressXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.BirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.ChangeReason
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsEmailUsedForLogin
			from
				sf.vPersonEmailAddress ent
			where
				ent.PersonEmailAddressSID = @PersonEmailAddressSID

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
