SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextMessage#Update]
	 @TextMessageSID                   int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@SenderPhone                      varchar(25)       = null -- table column values to update:
	,@SenderDisplayName                nvarchar(75)      = null
	,@PriorityLevel                    tinyint           = null
	,@Body                             nvarchar(1600)    = null
	,@RecipientList                    xml               = null
	,@IsApplicationUserRequired        bit               = null
	,@ApplicationUserSID               int               = null
	,@MessageLinkSID                   int               = null
	,@LinkExpiryHours                  int               = null
	,@ApplicationEntitySID             int               = null
	,@MergedTime                       datetimeoffset(7) = null
	,@QueuedTime                       datetimeoffset(7) = null
	,@CancelledTime                    datetimeoffset(7) = null
	,@ArchivedTime                     datetimeoffset(7) = null
	,@UserDefinedColumns               xml               = null
	,@TextMessageXID                   varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@ApplicationEntitySCD             varchar(50)       = null -- not a base table column
	,@ApplicationEntityName            nvarchar(50)      = null -- not a base table column
	,@IsMergeDataSource                bit               = null -- not a base table column
	,@ApplicationEntityRowGUID         uniqueidentifier  = null -- not a base table column
	,@PersonSID                        int               = null -- not a base table column
	,@CultureSID                       int               = null -- not a base table column
	,@AuthenticationAuthoritySID       int               = null -- not a base table column
	,@UserName                         nvarchar(75)      = null -- not a base table column
	,@LastReviewTime                   datetimeoffset(7) = null -- not a base table column
	,@LastReviewUser                   nvarchar(75)      = null -- not a base table column
	,@IsPotentialDuplicate             bit               = null -- not a base table column
	,@IsTemplate                       bit               = null -- not a base table column
	,@GlassBreakPassword               varbinary(8000)   = null -- not a base table column
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null -- not a base table column
	,@ApplicationUserIsActive          bit               = null -- not a base table column
	,@AuthenticationSystemID           nvarchar(50)      = null -- not a base table column
	,@ApplicationUserRowGUID           uniqueidentifier  = null -- not a base table column
	,@MessageLinkSCD                   varchar(30)       = null -- not a base table column
	,@MessageLinkLabel                 nvarchar(35)      = null -- not a base table column
	,@ApplicationPageSID               int               = null -- not a base table column
	,@MessageLinkRowGUID               uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                  bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pTextMessage#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.TextMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.TextMessage table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vTextMessage entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pTextMessage procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fTextMessageCheck to test all rules.

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

		if @TextMessageSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@TextMessageSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @SenderPhone = ltrim(rtrim(@SenderPhone))
		set @SenderDisplayName = ltrim(rtrim(@SenderDisplayName))
		set @Body = ltrim(rtrim(@Body))
		set @TextMessageXID = ltrim(rtrim(@TextMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ApplicationEntitySCD = ltrim(rtrim(@ApplicationEntitySCD))
		set @ApplicationEntityName = ltrim(rtrim(@ApplicationEntityName))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @MessageLinkSCD = ltrim(rtrim(@MessageLinkSCD))
		set @MessageLinkLabel = ltrim(rtrim(@MessageLinkLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@SenderPhone) = 0 set @SenderPhone = null
		if len(@SenderDisplayName) = 0 set @SenderDisplayName = null
		if len(@Body) = 0 set @Body = null
		if len(@TextMessageXID) = 0 set @TextMessageXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ApplicationEntitySCD) = 0 set @ApplicationEntitySCD = null
		if len(@ApplicationEntityName) = 0 set @ApplicationEntityName = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@MessageLinkSCD) = 0 set @MessageLinkSCD = null
		if len(@MessageLinkLabel) = 0 set @MessageLinkLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @SenderPhone                      = isnull(@SenderPhone,tm.SenderPhone)
				,@SenderDisplayName                = isnull(@SenderDisplayName,tm.SenderDisplayName)
				,@PriorityLevel                    = isnull(@PriorityLevel,tm.PriorityLevel)
				,@Body                             = isnull(@Body,tm.Body)
				,@RecipientList                    = isnull(@RecipientList,tm.RecipientList)
				,@IsApplicationUserRequired        = isnull(@IsApplicationUserRequired,tm.IsApplicationUserRequired)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,tm.ApplicationUserSID)
				,@MessageLinkSID                   = isnull(@MessageLinkSID,tm.MessageLinkSID)
				,@LinkExpiryHours                  = isnull(@LinkExpiryHours,tm.LinkExpiryHours)
				,@ApplicationEntitySID             = isnull(@ApplicationEntitySID,tm.ApplicationEntitySID)
				,@MergedTime                       = isnull(@MergedTime,tm.MergedTime)
				,@QueuedTime                       = isnull(@QueuedTime,tm.QueuedTime)
				,@CancelledTime                    = isnull(@CancelledTime,tm.CancelledTime)
				,@ArchivedTime                     = isnull(@ArchivedTime,tm.ArchivedTime)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,tm.UserDefinedColumns)
				,@TextMessageXID                   = isnull(@TextMessageXID,tm.TextMessageXID)
				,@LegacyKey                        = isnull(@LegacyKey,tm.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,tm.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,tm.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,tm.IsNullApplied)
				,@zContext                         = isnull(@zContext,tm.zContext)
				,@ApplicationEntitySCD             = isnull(@ApplicationEntitySCD,tm.ApplicationEntitySCD)
				,@ApplicationEntityName            = isnull(@ApplicationEntityName,tm.ApplicationEntityName)
				,@IsMergeDataSource                = isnull(@IsMergeDataSource,tm.IsMergeDataSource)
				,@ApplicationEntityRowGUID         = isnull(@ApplicationEntityRowGUID,tm.ApplicationEntityRowGUID)
				,@PersonSID                        = isnull(@PersonSID,tm.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,tm.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,tm.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,tm.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,tm.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,tm.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,tm.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,tm.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,tm.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,tm.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,tm.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,tm.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,tm.ApplicationUserRowGUID)
				,@MessageLinkSCD                   = isnull(@MessageLinkSCD,tm.MessageLinkSCD)
				,@MessageLinkLabel                 = isnull(@MessageLinkLabel,tm.MessageLinkLabel)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,tm.ApplicationPageSID)
				,@MessageLinkRowGUID               = isnull(@MessageLinkRowGUID,tm.MessageLinkRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,tm.IsDeleteEnabled)
			from
				sf.vTextMessage tm
			where
				tm.TextMessageSID = @TextMessageSID

		end
		
		set @SenderPhone = sf.fFormatPhone(@SenderPhone)											-- format phone numbers to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ApplicationEntitySCD is not null and @ApplicationEntitySID = (select x.ApplicationEntitySID from sf.TextMessage x where x.TextMessageSID = @TextMessageSID)
		begin
		
			select
				@ApplicationEntitySID = x.ApplicationEntitySID
			from
				sf.ApplicationEntity x
			where
				x.ApplicationEntitySCD = @ApplicationEntitySCD
		
		end
		
		if @MessageLinkSCD is not null and @MessageLinkSID = (select x.MessageLinkSID from sf.TextMessage x where x.TextMessageSID = @TextMessageSID)
		begin
		
			select
				@MessageLinkSID = x.MessageLinkSID
			from
				sf.MessageLink x
			where
				x.MessageLinkSCD = @MessageLinkSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.TextMessage x where x.TextMessageSID = @TextMessageSID) <> @ApplicationUserSID
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

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>

		-- update the record

		update
			sf.TextMessage
		set
			 SenderPhone = @SenderPhone
			,SenderDisplayName = @SenderDisplayName
			,PriorityLevel = @PriorityLevel
			,Body = @Body
			,RecipientList = @RecipientList
			,IsApplicationUserRequired = @IsApplicationUserRequired
			,ApplicationUserSID = @ApplicationUserSID
			,MessageLinkSID = @MessageLinkSID
			,LinkExpiryHours = @LinkExpiryHours
			,ApplicationEntitySID = @ApplicationEntitySID
			,MergedTime = @MergedTime
			,QueuedTime = @QueuedTime
			,CancelledTime = @CancelledTime
			,ArchivedTime = @ArchivedTime
			,UserDefinedColumns = @UserDefinedColumns
			,TextMessageXID = @TextMessageXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			TextMessageSID = @TextMessageSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.TextMessage where TextMessageSID = @textMessageSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.TextMessage'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.TextMessage'
					,@Arg2        = @textMessageSID
				
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
				,@Arg2        = 'sf.TextMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @textMessageSID
			
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
				 ent.TextMessageSID
			from
				sf.vTextMessage ent
			where
				ent.TextMessageSID = @TextMessageSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.TextMessageSID
				,ent.SenderPhone
				,ent.SenderDisplayName
				,ent.PriorityLevel
				,ent.Body
				,ent.RecipientList
				,ent.IsApplicationUserRequired
				,ent.ApplicationUserSID
				,ent.MessageLinkSID
				,ent.LinkExpiryHours
				,ent.ApplicationEntitySID
				,ent.MergedTime
				,ent.QueuedTime
				,ent.CancelledTime
				,ent.ArchivedTime
				,ent.UserDefinedColumns
				,ent.TextMessageXID
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
				,ent.MessageLinkSCD
				,ent.MessageLinkLabel
				,ent.ApplicationPageSID
				,ent.MessageLinkRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				sf.vTextMessage ent
			where
				ent.TextMessageSID = @TextMessageSID

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
