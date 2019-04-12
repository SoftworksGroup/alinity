SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonTextMessage#Update]
	 @PersonTextMessageSID          int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                     int               = null -- table column values to update:
	,@TextMessageSID                int               = null
	,@MobilePhone                   varchar(25)       = null
	,@SentTime                      datetimeoffset(7) = null
	,@Body                          nvarchar(1600)    = null
	,@NotReceivedNoticeTime         datetime          = null
	,@ConfirmedTime                 datetimeoffset(7) = null
	,@CancelledTime                 datetimeoffset(7) = null
	,@DeliveredTime                 datetimeoffset(7) = null
	,@ChangeAudit                   nvarchar(max)     = null
	,@MergeKey                      int               = null
	,@TextTriggerSID                int               = null
	,@ServiceMessageID              varchar(100)      = null
	,@UserDefinedColumns            xml               = null
	,@PersonTextMessageXID          varchar(150)      = null
	,@LegacyKey                     nvarchar(50)      = null
	,@UpdateUser                    nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                      timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                  tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                 bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                      xml               = null -- other values defining context for the update (if any)
	,@GenderSID                     int               = null -- not a base table column
	,@NamePrefixSID                 int               = null -- not a base table column
	,@FirstName                     nvarchar(30)      = null -- not a base table column
	,@CommonName                    nvarchar(30)      = null -- not a base table column
	,@MiddleNames                   nvarchar(30)      = null -- not a base table column
	,@LastName                      nvarchar(35)      = null -- not a base table column
	,@BirthDate                     date              = null -- not a base table column
	,@DeathDate                     date              = null -- not a base table column
	,@HomePhone                     varchar(25)       = null -- not a base table column
	,@PersonMobilePhone             varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled        bit               = null -- not a base table column
	,@ImportBatch                   nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                 uniqueidentifier  = null -- not a base table column
	,@SenderPhone                   varchar(25)       = null -- not a base table column
	,@SenderDisplayName             nvarchar(75)      = null -- not a base table column
	,@PriorityLevel                 tinyint           = null -- not a base table column
	,@TextMessageBody               nvarchar(1600)    = null -- not a base table column
	,@IsApplicationUserRequired     bit               = null -- not a base table column
	,@TextMessageApplicationUserSID int               = null -- not a base table column
	,@MessageLinkSID                int               = null -- not a base table column
	,@LinkExpiryHours               int               = null -- not a base table column
	,@ApplicationEntitySID          int               = null -- not a base table column
	,@MergedTime                    datetimeoffset(7) = null -- not a base table column
	,@QueuedTime                    datetimeoffset(7) = null -- not a base table column
	,@TextMessageCancelledTime      datetimeoffset(7) = null -- not a base table column
	,@ArchivedTime                  datetimeoffset(7) = null -- not a base table column
	,@TextMessageRowGUID            uniqueidentifier  = null -- not a base table column
	,@TextTriggerLabel              nvarchar(35)      = null -- not a base table column
	,@TextTemplateSID               int               = null -- not a base table column
	,@QuerySID                      int               = null -- not a base table column
	,@MinDaysToRepeat               int               = null -- not a base table column
	,@TextTriggerApplicationUserSID int               = null -- not a base table column
	,@JobScheduleSID                int               = null -- not a base table column
	,@LastStartTime                 datetimeoffset(7) = null -- not a base table column
	,@LastEndTime                   datetimeoffset(7) = null -- not a base table column
	,@TextTriggerIsActive           bit               = null -- not a base table column
	,@TextTriggerRowGUID            uniqueidentifier  = null -- not a base table column
	,@ChangeReason                  nvarchar(4000)    = null -- not a base table column
	,@IsDeleteEnabled               bit               = null -- not a base table column
	,@BodySent                      nvarchar(1600)    = null -- not a base table column
	,@MessageLinkExpiryTime         datetimeoffset(7) = null -- not a base table column
	,@ConfirmationLagHours          int               = null -- not a base table column
	,@MessageLinkStatusSCD          varchar(10)       = null -- not a base table column
	,@MessageLinkStatusLabel        nvarchar(35)      = null -- not a base table column
	,@IsPending                     bit               = null -- not a base table column
	,@IsConfirmed                   bit               = null -- not a base table column
	,@IsExpired                     bit               = null -- not a base table column
	,@IsCancelled                   bit               = null -- not a base table column
	,@FileAsName                    nvarchar(65)      = null -- not a base table column
	,@FullName                      nvarchar(65)      = null -- not a base table column
	,@DisplayName                   nvarchar(65)      = null -- not a base table column
	,@AgeInYears                    int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pPersonTextMessage#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.PersonTextMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.PersonTextMessage table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonTextMessage entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonTextMessage procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonTextMessageCheck to test all rules.

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

		if @PersonTextMessageSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonTextMessageSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @Body = ltrim(rtrim(@Body))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @ServiceMessageID = ltrim(rtrim(@ServiceMessageID))
		set @PersonTextMessageXID = ltrim(rtrim(@PersonTextMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @PersonMobilePhone = ltrim(rtrim(@PersonMobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @SenderPhone = ltrim(rtrim(@SenderPhone))
		set @SenderDisplayName = ltrim(rtrim(@SenderDisplayName))
		set @TextMessageBody = ltrim(rtrim(@TextMessageBody))
		set @TextTriggerLabel = ltrim(rtrim(@TextTriggerLabel))
		set @ChangeReason = ltrim(rtrim(@ChangeReason))
		set @BodySent = ltrim(rtrim(@BodySent))
		set @MessageLinkStatusSCD = ltrim(rtrim(@MessageLinkStatusSCD))
		set @MessageLinkStatusLabel = ltrim(rtrim(@MessageLinkStatusLabel))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @FullName = ltrim(rtrim(@FullName))
		set @DisplayName = ltrim(rtrim(@DisplayName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@Body) = 0 set @Body = null
		if len(@ChangeAudit) = 0 set @ChangeAudit = null
		if len(@ServiceMessageID) = 0 set @ServiceMessageID = null
		if len(@PersonTextMessageXID) = 0 set @PersonTextMessageXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@PersonMobilePhone) = 0 set @PersonMobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@SenderPhone) = 0 set @SenderPhone = null
		if len(@SenderDisplayName) = 0 set @SenderDisplayName = null
		if len(@TextMessageBody) = 0 set @TextMessageBody = null
		if len(@TextTriggerLabel) = 0 set @TextTriggerLabel = null
		if len(@ChangeReason) = 0 set @ChangeReason = null
		if len(@BodySent) = 0 set @BodySent = null
		if len(@MessageLinkStatusSCD) = 0 set @MessageLinkStatusSCD = null
		if len(@MessageLinkStatusLabel) = 0 set @MessageLinkStatusLabel = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@FullName) = 0 set @FullName = null
		if len(@DisplayName) = 0 set @DisplayName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                     = isnull(@PersonSID,ptm.PersonSID)
				,@TextMessageSID                = isnull(@TextMessageSID,ptm.TextMessageSID)
				,@MobilePhone                   = isnull(@MobilePhone,ptm.MobilePhone)
				,@SentTime                      = isnull(@SentTime,ptm.SentTime)
				,@Body                          = isnull(@Body,ptm.Body)
				,@NotReceivedNoticeTime         = isnull(@NotReceivedNoticeTime,ptm.NotReceivedNoticeTime)
				,@ConfirmedTime                 = isnull(@ConfirmedTime,ptm.ConfirmedTime)
				,@CancelledTime                 = isnull(@CancelledTime,ptm.CancelledTime)
				,@DeliveredTime                 = isnull(@DeliveredTime,ptm.DeliveredTime)
				,@ChangeAudit                   = isnull(@ChangeAudit,ptm.ChangeAudit)
				,@MergeKey                      = isnull(@MergeKey,ptm.MergeKey)
				,@TextTriggerSID                = isnull(@TextTriggerSID,ptm.TextTriggerSID)
				,@ServiceMessageID              = isnull(@ServiceMessageID,ptm.ServiceMessageID)
				,@UserDefinedColumns            = isnull(@UserDefinedColumns,ptm.UserDefinedColumns)
				,@PersonTextMessageXID          = isnull(@PersonTextMessageXID,ptm.PersonTextMessageXID)
				,@LegacyKey                     = isnull(@LegacyKey,ptm.LegacyKey)
				,@UpdateUser                    = isnull(@UpdateUser,ptm.UpdateUser)
				,@IsReselected                  = isnull(@IsReselected,ptm.IsReselected)
				,@IsNullApplied                 = isnull(@IsNullApplied,ptm.IsNullApplied)
				,@zContext                      = isnull(@zContext,ptm.zContext)
				,@GenderSID                     = isnull(@GenderSID,ptm.GenderSID)
				,@NamePrefixSID                 = isnull(@NamePrefixSID,ptm.NamePrefixSID)
				,@FirstName                     = isnull(@FirstName,ptm.FirstName)
				,@CommonName                    = isnull(@CommonName,ptm.CommonName)
				,@MiddleNames                   = isnull(@MiddleNames,ptm.MiddleNames)
				,@LastName                      = isnull(@LastName,ptm.LastName)
				,@BirthDate                     = isnull(@BirthDate,ptm.BirthDate)
				,@DeathDate                     = isnull(@DeathDate,ptm.DeathDate)
				,@HomePhone                     = isnull(@HomePhone,ptm.HomePhone)
				,@PersonMobilePhone             = isnull(@PersonMobilePhone,ptm.PersonMobilePhone)
				,@IsTextMessagingEnabled        = isnull(@IsTextMessagingEnabled,ptm.IsTextMessagingEnabled)
				,@ImportBatch                   = isnull(@ImportBatch,ptm.ImportBatch)
				,@PersonRowGUID                 = isnull(@PersonRowGUID,ptm.PersonRowGUID)
				,@SenderPhone                   = isnull(@SenderPhone,ptm.SenderPhone)
				,@SenderDisplayName             = isnull(@SenderDisplayName,ptm.SenderDisplayName)
				,@PriorityLevel                 = isnull(@PriorityLevel,ptm.PriorityLevel)
				,@TextMessageBody               = isnull(@TextMessageBody,ptm.TextMessageBody)
				,@IsApplicationUserRequired     = isnull(@IsApplicationUserRequired,ptm.IsApplicationUserRequired)
				,@TextMessageApplicationUserSID = isnull(@TextMessageApplicationUserSID,ptm.TextMessageApplicationUserSID)
				,@MessageLinkSID                = isnull(@MessageLinkSID,ptm.MessageLinkSID)
				,@LinkExpiryHours               = isnull(@LinkExpiryHours,ptm.LinkExpiryHours)
				,@ApplicationEntitySID          = isnull(@ApplicationEntitySID,ptm.ApplicationEntitySID)
				,@MergedTime                    = isnull(@MergedTime,ptm.MergedTime)
				,@QueuedTime                    = isnull(@QueuedTime,ptm.QueuedTime)
				,@TextMessageCancelledTime      = isnull(@TextMessageCancelledTime,ptm.TextMessageCancelledTime)
				,@ArchivedTime                  = isnull(@ArchivedTime,ptm.ArchivedTime)
				,@TextMessageRowGUID            = isnull(@TextMessageRowGUID,ptm.TextMessageRowGUID)
				,@TextTriggerLabel              = isnull(@TextTriggerLabel,ptm.TextTriggerLabel)
				,@TextTemplateSID               = isnull(@TextTemplateSID,ptm.TextTemplateSID)
				,@QuerySID                      = isnull(@QuerySID,ptm.QuerySID)
				,@MinDaysToRepeat               = isnull(@MinDaysToRepeat,ptm.MinDaysToRepeat)
				,@TextTriggerApplicationUserSID = isnull(@TextTriggerApplicationUserSID,ptm.TextTriggerApplicationUserSID)
				,@JobScheduleSID                = isnull(@JobScheduleSID,ptm.JobScheduleSID)
				,@LastStartTime                 = isnull(@LastStartTime,ptm.LastStartTime)
				,@LastEndTime                   = isnull(@LastEndTime,ptm.LastEndTime)
				,@TextTriggerIsActive           = isnull(@TextTriggerIsActive,ptm.TextTriggerIsActive)
				,@TextTriggerRowGUID            = isnull(@TextTriggerRowGUID,ptm.TextTriggerRowGUID)
				,@ChangeReason                  = isnull(@ChangeReason,ptm.ChangeReason)
				,@IsDeleteEnabled               = isnull(@IsDeleteEnabled,ptm.IsDeleteEnabled)
				,@BodySent                      = isnull(@BodySent,ptm.BodySent)
				,@MessageLinkExpiryTime         = isnull(@MessageLinkExpiryTime,ptm.MessageLinkExpiryTime)
				,@ConfirmationLagHours          = isnull(@ConfirmationLagHours,ptm.ConfirmationLagHours)
				,@MessageLinkStatusSCD          = isnull(@MessageLinkStatusSCD,ptm.MessageLinkStatusSCD)
				,@MessageLinkStatusLabel        = isnull(@MessageLinkStatusLabel,ptm.MessageLinkStatusLabel)
				,@IsPending                     = isnull(@IsPending,ptm.IsPending)
				,@IsConfirmed                   = isnull(@IsConfirmed,ptm.IsConfirmed)
				,@IsExpired                     = isnull(@IsExpired,ptm.IsExpired)
				,@IsCancelled                   = isnull(@IsCancelled,ptm.IsCancelled)
				,@FileAsName                    = isnull(@FileAsName,ptm.FileAsName)
				,@FullName                      = isnull(@FullName,ptm.FullName)
				,@DisplayName                   = isnull(@DisplayName,ptm.DisplayName)
				,@AgeInYears                    = isnull(@AgeInYears,ptm.AgeInYears)
			from
				sf.vPersonTextMessage ptm
			where
				ptm.PersonTextMessageSID = @PersonTextMessageSID

		end
		
		set @MobilePhone = sf.fFormatPhone(@MobilePhone)											-- format phone numbers to standard
		
		-- update audit column when a change reason is passed
		
		if @ChangeReason is not null set @ChangeAudit = sf.fChangeAudit#Comment(@ChangeReason, @ChangeAudit)
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		if @IsConfirmed = @ON and @ConfirmedTime is null set @ConfirmedTime = sysdatetimeoffset()

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.TextTriggerSID from sf.PersonTextMessage x where x.PersonTextMessageSID = @PersonTextMessageSID) <> @TextTriggerSID
		begin
			if (select x.IsActive from sf.TextTrigger x where x.TextTriggerSID = @TextTriggerSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'text trigger'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		
		--! </PreUpdate>

		-- update the record

		update
			sf.PersonTextMessage
		set
			 PersonSID = @PersonSID
			,TextMessageSID = @TextMessageSID
			,MobilePhone = @MobilePhone
			,SentTime = @SentTime
			,Body = @Body
			,NotReceivedNoticeTime = @NotReceivedNoticeTime
			,ConfirmedTime = @ConfirmedTime
			,CancelledTime = @CancelledTime
			,DeliveredTime = @DeliveredTime
			,ChangeAudit = @ChangeAudit
			,MergeKey = @MergeKey
			,TextTriggerSID = @TextTriggerSID
			,ServiceMessageID = @ServiceMessageID
			,UserDefinedColumns = @UserDefinedColumns
			,PersonTextMessageXID = @PersonTextMessageXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonTextMessageSID = @PersonTextMessageSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.PersonTextMessage where PersonTextMessageSID = @personTextMessageSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.PersonTextMessage'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.PersonTextMessage'
					,@Arg2        = @personTextMessageSID
				
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
				,@Arg2        = 'sf.PersonTextMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personTextMessageSID
			
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
				 ent.PersonTextMessageSID
			from
				sf.vPersonTextMessage ent
			where
				ent.PersonTextMessageSID = @PersonTextMessageSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonTextMessageSID
				,ent.PersonSID
				,ent.TextMessageSID
				,ent.MobilePhone
				,ent.SentTime
				,ent.Body
				,ent.NotReceivedNoticeTime
				,ent.ConfirmedTime
				,ent.CancelledTime
				,ent.DeliveredTime
				,ent.ChangeAudit
				,ent.MergeKey
				,ent.TextTriggerSID
				,ent.ServiceMessageID
				,ent.UserDefinedColumns
				,ent.PersonTextMessageXID
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
				,ent.PersonMobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.SenderPhone
				,ent.SenderDisplayName
				,ent.PriorityLevel
				,ent.TextMessageBody
				,ent.IsApplicationUserRequired
				,ent.TextMessageApplicationUserSID
				,ent.MessageLinkSID
				,ent.LinkExpiryHours
				,ent.ApplicationEntitySID
				,ent.MergedTime
				,ent.QueuedTime
				,ent.TextMessageCancelledTime
				,ent.ArchivedTime
				,ent.TextMessageRowGUID
				,ent.TextTriggerLabel
				,ent.TextTemplateSID
				,ent.QuerySID
				,ent.MinDaysToRepeat
				,ent.TextTriggerApplicationUserSID
				,ent.JobScheduleSID
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.TextTriggerIsActive
				,ent.TextTriggerRowGUID
				,ent.ChangeReason
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.BodySent
				,ent.MessageLinkExpiryTime
				,ent.ConfirmationLagHours
				,ent.MessageLinkStatusSCD
				,ent.MessageLinkStatusLabel
				,ent.IsPending
				,ent.IsConfirmed
				,ent.IsExpired
				,ent.IsCancelled
				,ent.FileAsName
				,ent.FullName
				,ent.DisplayName
				,ent.AgeInYears
			from
				sf.vPersonTextMessage ent
			where
				ent.PersonTextMessageSID = @PersonTextMessageSID

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
