SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonEmailMessage#Update]
	 @PersonEmailMessageSID          int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                      int               = null -- table column values to update:
	,@EmailMessageSID                int               = null
	,@EmailAddress                   varchar(150)      = null
	,@SelectedTime                   datetimeoffset(7) = null
	,@SentTime                       datetimeoffset(7) = null
	,@Subject                        nvarchar(120)     = null
	,@Body                           nvarchar(max)     = null
	,@EmailDocument                  varbinary(max)    = null
	,@FileTypeSID                    int               = null
	,@FileTypeSCD                    varchar(8)        = null
	,@NotReceivedNoticeTime          datetime          = null
	,@ConfirmedTime                  datetimeoffset(7) = null
	,@CancelledTime                  datetimeoffset(7) = null
	,@OpenedTime                     datetimeoffset(7) = null
	,@ChangeAudit                    nvarchar(max)     = null
	,@MergeKey                       int               = null
	,@EmailTriggerSID                int               = null
	,@ServiceMessageID               varchar(100)      = null
	,@UserDefinedColumns             xml               = null
	,@PersonEmailMessageXID          varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@SenderEmailAddress             varchar(150)      = null -- not a base table column
	,@SenderDisplayName              nvarchar(75)      = null -- not a base table column
	,@PriorityLevel                  tinyint           = null -- not a base table column
	,@EmailMessageSubject            nvarchar(120)     = null -- not a base table column
	,@EmailMessageFileTypeSCD        varchar(8)        = null -- not a base table column
	,@EmailMessageFileTypeSID        int               = null -- not a base table column
	,@IsApplicationUserRequired      bit               = null -- not a base table column
	,@EmailMessageApplicationUserSID int               = null -- not a base table column
	,@MessageLinkSID                 int               = null -- not a base table column
	,@LinkExpiryHours                int               = null -- not a base table column
	,@ApplicationEntitySID           int               = null -- not a base table column
	,@ApplicationGrantSID            int               = null -- not a base table column
	,@IsGenerateOnly                 bit               = null -- not a base table column
	,@MergedTime                     datetimeoffset(7) = null -- not a base table column
	,@QueuedTime                     datetimeoffset(7) = null -- not a base table column
	,@EmailMessageCancelledTime      datetimeoffset(7) = null -- not a base table column
	,@ArchivedTime                   datetimeoffset(7) = null -- not a base table column
	,@PurgedTime                     datetimeoffset(7) = null -- not a base table column
	,@EmailMessageRowGUID            uniqueidentifier  = null -- not a base table column
	,@FileTypeFileTypeSCD            varchar(8)        = null -- not a base table column
	,@FileTypeLabel                  nvarchar(35)      = null -- not a base table column
	,@MimeType                       varchar(255)      = null -- not a base table column
	,@IsInline                       bit               = null -- not a base table column
	,@FileTypeIsActive               bit               = null -- not a base table column
	,@FileTypeRowGUID                uniqueidentifier  = null -- not a base table column
	,@GenderSID                      int               = null -- not a base table column
	,@NamePrefixSID                  int               = null -- not a base table column
	,@FirstName                      nvarchar(30)      = null -- not a base table column
	,@CommonName                     nvarchar(30)      = null -- not a base table column
	,@MiddleNames                    nvarchar(30)      = null -- not a base table column
	,@LastName                       nvarchar(35)      = null -- not a base table column
	,@BirthDate                      date              = null -- not a base table column
	,@DeathDate                      date              = null -- not a base table column
	,@HomePhone                      varchar(25)       = null -- not a base table column
	,@MobilePhone                    varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled         bit               = null -- not a base table column
	,@ImportBatch                    nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@EmailTriggerLabel              nvarchar(35)      = null -- not a base table column
	,@EmailTemplateSID               int               = null -- not a base table column
	,@QuerySID                       int               = null -- not a base table column
	,@MinDaysToRepeat                int               = null -- not a base table column
	,@EmailTriggerApplicationUserSID int               = null -- not a base table column
	,@JobScheduleSID                 int               = null -- not a base table column
	,@LastStartTime                  datetimeoffset(7) = null -- not a base table column
	,@LastEndTime                    datetimeoffset(7) = null -- not a base table column
	,@EarliestSelectionDate          date              = null -- not a base table column
	,@EmailTriggerIsActive           bit               = null -- not a base table column
	,@EmailTriggerRowGUID            uniqueidentifier  = null -- not a base table column
	,@ChangeReason                   nvarchar(4000)    = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsReadGranted                  bit               = null -- not a base table column
	,@SubjectSent                    nvarchar(120)     = null -- not a base table column
	,@BodySent                       nvarchar(max)     = null -- not a base table column
	,@MessageLinkExpiryTime          datetimeoffset(7) = null -- not a base table column
	,@ConfirmationLagHours           int               = null -- not a base table column
	,@MessageLinkStatusSCD           varchar(10)       = null -- not a base table column
	,@MessageLinkStatusLabel         nvarchar(35)      = null -- not a base table column
	,@IsPending                      bit               = null -- not a base table column
	,@IsConfirmed                    bit               = null -- not a base table column
	,@IsExpired                      bit               = null -- not a base table column
	,@IsCancelled                    bit               = null -- not a base table column
	,@IsPurged                       bit               = null -- not a base table column
	,@IsEmailOpenTracked             bit               = null -- not a base table column
	,@IsNotReceived                  bit               = null -- not a base table column
	,@FileAsName                     nvarchar(65)      = null -- not a base table column
	,@FullName                       nvarchar(65)      = null -- not a base table column
	,@DisplayName                    nvarchar(65)      = null -- not a base table column
	,@AgeInYears                     int               = null -- not a base table column
	,@CurrentEmailAddress            varchar(150)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pPersonEmailMessage#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.PersonEmailMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.PersonEmailMessage table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonEmailMessage entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonEmailMessage procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonEmailMessageCheck to test all rules.

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

		if @PersonEmailMessageSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonEmailMessageSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @Subject = ltrim(rtrim(@Subject))
		set @Body = ltrim(rtrim(@Body))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @ServiceMessageID = ltrim(rtrim(@ServiceMessageID))
		set @PersonEmailMessageXID = ltrim(rtrim(@PersonEmailMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @SenderEmailAddress = ltrim(rtrim(@SenderEmailAddress))
		set @SenderDisplayName = ltrim(rtrim(@SenderDisplayName))
		set @EmailMessageSubject = ltrim(rtrim(@EmailMessageSubject))
		set @EmailMessageFileTypeSCD = ltrim(rtrim(@EmailMessageFileTypeSCD))
		set @FileTypeFileTypeSCD = ltrim(rtrim(@FileTypeFileTypeSCD))
		set @FileTypeLabel = ltrim(rtrim(@FileTypeLabel))
		set @MimeType = ltrim(rtrim(@MimeType))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @EmailTriggerLabel = ltrim(rtrim(@EmailTriggerLabel))
		set @ChangeReason = ltrim(rtrim(@ChangeReason))
		set @SubjectSent = ltrim(rtrim(@SubjectSent))
		set @BodySent = ltrim(rtrim(@BodySent))
		set @MessageLinkStatusSCD = ltrim(rtrim(@MessageLinkStatusSCD))
		set @MessageLinkStatusLabel = ltrim(rtrim(@MessageLinkStatusLabel))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @FullName = ltrim(rtrim(@FullName))
		set @DisplayName = ltrim(rtrim(@DisplayName))
		set @CurrentEmailAddress = ltrim(rtrim(@CurrentEmailAddress))

		-- set zero length strings to null to avoid storing them in the record

		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@Subject) = 0 set @Subject = null
		if len(@Body) = 0 set @Body = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@ChangeAudit) = 0 set @ChangeAudit = null
		if len(@ServiceMessageID) = 0 set @ServiceMessageID = null
		if len(@PersonEmailMessageXID) = 0 set @PersonEmailMessageXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@SenderEmailAddress) = 0 set @SenderEmailAddress = null
		if len(@SenderDisplayName) = 0 set @SenderDisplayName = null
		if len(@EmailMessageSubject) = 0 set @EmailMessageSubject = null
		if len(@EmailMessageFileTypeSCD) = 0 set @EmailMessageFileTypeSCD = null
		if len(@FileTypeFileTypeSCD) = 0 set @FileTypeFileTypeSCD = null
		if len(@FileTypeLabel) = 0 set @FileTypeLabel = null
		if len(@MimeType) = 0 set @MimeType = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@EmailTriggerLabel) = 0 set @EmailTriggerLabel = null
		if len(@ChangeReason) = 0 set @ChangeReason = null
		if len(@SubjectSent) = 0 set @SubjectSent = null
		if len(@BodySent) = 0 set @BodySent = null
		if len(@MessageLinkStatusSCD) = 0 set @MessageLinkStatusSCD = null
		if len(@MessageLinkStatusLabel) = 0 set @MessageLinkStatusLabel = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@FullName) = 0 set @FullName = null
		if len(@DisplayName) = 0 set @DisplayName = null
		if len(@CurrentEmailAddress) = 0 set @CurrentEmailAddress = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                      = isnull(@PersonSID,pem.PersonSID)
				,@EmailMessageSID                = isnull(@EmailMessageSID,pem.EmailMessageSID)
				,@EmailAddress                   = isnull(@EmailAddress,pem.EmailAddress)
				,@SelectedTime                   = isnull(@SelectedTime,pem.SelectedTime)
				,@SentTime                       = isnull(@SentTime,pem.SentTime)
				,@Subject                        = isnull(@Subject,pem.Subject)
				,@Body                           = isnull(@Body,pem.Body)
				,@EmailDocument                  = isnull(@EmailDocument,pem.EmailDocument)
				,@FileTypeSID                    = isnull(@FileTypeSID,pem.FileTypeSID)
				,@FileTypeSCD                    = isnull(@FileTypeSCD,pem.FileTypeSCD)
				,@NotReceivedNoticeTime          = isnull(@NotReceivedNoticeTime,pem.NotReceivedNoticeTime)
				,@ConfirmedTime                  = isnull(@ConfirmedTime,pem.ConfirmedTime)
				,@CancelledTime                  = isnull(@CancelledTime,pem.CancelledTime)
				,@OpenedTime                     = isnull(@OpenedTime,pem.OpenedTime)
				,@ChangeAudit                    = isnull(@ChangeAudit,pem.ChangeAudit)
				,@MergeKey                       = isnull(@MergeKey,pem.MergeKey)
				,@EmailTriggerSID                = isnull(@EmailTriggerSID,pem.EmailTriggerSID)
				,@ServiceMessageID               = isnull(@ServiceMessageID,pem.ServiceMessageID)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,pem.UserDefinedColumns)
				,@PersonEmailMessageXID          = isnull(@PersonEmailMessageXID,pem.PersonEmailMessageXID)
				,@LegacyKey                      = isnull(@LegacyKey,pem.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,pem.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,pem.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,pem.IsNullApplied)
				,@zContext                       = isnull(@zContext,pem.zContext)
				,@SenderEmailAddress             = isnull(@SenderEmailAddress,pem.SenderEmailAddress)
				,@SenderDisplayName              = isnull(@SenderDisplayName,pem.SenderDisplayName)
				,@PriorityLevel                  = isnull(@PriorityLevel,pem.PriorityLevel)
				,@EmailMessageSubject            = isnull(@EmailMessageSubject,pem.EmailMessageSubject)
				,@EmailMessageFileTypeSCD        = isnull(@EmailMessageFileTypeSCD,pem.EmailMessageFileTypeSCD)
				,@EmailMessageFileTypeSID        = isnull(@EmailMessageFileTypeSID,pem.EmailMessageFileTypeSID)
				,@IsApplicationUserRequired      = isnull(@IsApplicationUserRequired,pem.IsApplicationUserRequired)
				,@EmailMessageApplicationUserSID = isnull(@EmailMessageApplicationUserSID,pem.EmailMessageApplicationUserSID)
				,@MessageLinkSID                 = isnull(@MessageLinkSID,pem.MessageLinkSID)
				,@LinkExpiryHours                = isnull(@LinkExpiryHours,pem.LinkExpiryHours)
				,@ApplicationEntitySID           = isnull(@ApplicationEntitySID,pem.ApplicationEntitySID)
				,@ApplicationGrantSID            = isnull(@ApplicationGrantSID,pem.ApplicationGrantSID)
				,@IsGenerateOnly                 = isnull(@IsGenerateOnly,pem.IsGenerateOnly)
				,@MergedTime                     = isnull(@MergedTime,pem.MergedTime)
				,@QueuedTime                     = isnull(@QueuedTime,pem.QueuedTime)
				,@EmailMessageCancelledTime      = isnull(@EmailMessageCancelledTime,pem.EmailMessageCancelledTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,pem.ArchivedTime)
				,@PurgedTime                     = isnull(@PurgedTime,pem.PurgedTime)
				,@EmailMessageRowGUID            = isnull(@EmailMessageRowGUID,pem.EmailMessageRowGUID)
				,@FileTypeFileTypeSCD            = isnull(@FileTypeFileTypeSCD,pem.FileTypeFileTypeSCD)
				,@FileTypeLabel                  = isnull(@FileTypeLabel,pem.FileTypeLabel)
				,@MimeType                       = isnull(@MimeType,pem.MimeType)
				,@IsInline                       = isnull(@IsInline,pem.IsInline)
				,@FileTypeIsActive               = isnull(@FileTypeIsActive,pem.FileTypeIsActive)
				,@FileTypeRowGUID                = isnull(@FileTypeRowGUID,pem.FileTypeRowGUID)
				,@GenderSID                      = isnull(@GenderSID,pem.GenderSID)
				,@NamePrefixSID                  = isnull(@NamePrefixSID,pem.NamePrefixSID)
				,@FirstName                      = isnull(@FirstName,pem.FirstName)
				,@CommonName                     = isnull(@CommonName,pem.CommonName)
				,@MiddleNames                    = isnull(@MiddleNames,pem.MiddleNames)
				,@LastName                       = isnull(@LastName,pem.LastName)
				,@BirthDate                      = isnull(@BirthDate,pem.BirthDate)
				,@DeathDate                      = isnull(@DeathDate,pem.DeathDate)
				,@HomePhone                      = isnull(@HomePhone,pem.HomePhone)
				,@MobilePhone                    = isnull(@MobilePhone,pem.MobilePhone)
				,@IsTextMessagingEnabled         = isnull(@IsTextMessagingEnabled,pem.IsTextMessagingEnabled)
				,@ImportBatch                    = isnull(@ImportBatch,pem.ImportBatch)
				,@PersonRowGUID                  = isnull(@PersonRowGUID,pem.PersonRowGUID)
				,@EmailTriggerLabel              = isnull(@EmailTriggerLabel,pem.EmailTriggerLabel)
				,@EmailTemplateSID               = isnull(@EmailTemplateSID,pem.EmailTemplateSID)
				,@QuerySID                       = isnull(@QuerySID,pem.QuerySID)
				,@MinDaysToRepeat                = isnull(@MinDaysToRepeat,pem.MinDaysToRepeat)
				,@EmailTriggerApplicationUserSID = isnull(@EmailTriggerApplicationUserSID,pem.EmailTriggerApplicationUserSID)
				,@JobScheduleSID                 = isnull(@JobScheduleSID,pem.JobScheduleSID)
				,@LastStartTime                  = isnull(@LastStartTime,pem.LastStartTime)
				,@LastEndTime                    = isnull(@LastEndTime,pem.LastEndTime)
				,@EarliestSelectionDate          = isnull(@EarliestSelectionDate,pem.EarliestSelectionDate)
				,@EmailTriggerIsActive           = isnull(@EmailTriggerIsActive,pem.EmailTriggerIsActive)
				,@EmailTriggerRowGUID            = isnull(@EmailTriggerRowGUID,pem.EmailTriggerRowGUID)
				,@ChangeReason                   = isnull(@ChangeReason,pem.ChangeReason)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,pem.IsDeleteEnabled)
				,@IsReadGranted                  = isnull(@IsReadGranted,pem.IsReadGranted)
				,@SubjectSent                    = isnull(@SubjectSent,pem.SubjectSent)
				,@BodySent                       = isnull(@BodySent,pem.BodySent)
				,@MessageLinkExpiryTime          = isnull(@MessageLinkExpiryTime,pem.MessageLinkExpiryTime)
				,@ConfirmationLagHours           = isnull(@ConfirmationLagHours,pem.ConfirmationLagHours)
				,@MessageLinkStatusSCD           = isnull(@MessageLinkStatusSCD,pem.MessageLinkStatusSCD)
				,@MessageLinkStatusLabel         = isnull(@MessageLinkStatusLabel,pem.MessageLinkStatusLabel)
				,@IsPending                      = isnull(@IsPending,pem.IsPending)
				,@IsConfirmed                    = isnull(@IsConfirmed,pem.IsConfirmed)
				,@IsExpired                      = isnull(@IsExpired,pem.IsExpired)
				,@IsCancelled                    = isnull(@IsCancelled,pem.IsCancelled)
				,@IsPurged                       = isnull(@IsPurged,pem.IsPurged)
				,@IsEmailOpenTracked             = isnull(@IsEmailOpenTracked,pem.IsEmailOpenTracked)
				,@IsNotReceived                  = isnull(@IsNotReceived,pem.IsNotReceived)
				,@FileAsName                     = isnull(@FileAsName,pem.FileAsName)
				,@FullName                       = isnull(@FullName,pem.FullName)
				,@DisplayName                    = isnull(@DisplayName,pem.DisplayName)
				,@AgeInYears                     = isnull(@AgeInYears,pem.AgeInYears)
				,@CurrentEmailAddress            = isnull(@CurrentEmailAddress,pem.CurrentEmailAddress)
			from
				sf.vPersonEmailMessage pem
			where
				pem.PersonEmailMessageSID = @PersonEmailMessageSID

		end
		
		-- update audit column when a change reason is passed
		
		if @ChangeReason is not null set @ChangeAudit = sf.fChangeAudit#Comment(@ChangeReason, @ChangeAudit)
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		if @IsConfirmed = @ON and @ConfirmedTime is null set @ConfirmedTime = sysdatetimeoffset()
		
		-- ensure the file type SID value matches the code being set; a trigger
		-- enforces the rule for updates outside of the EF sprocs
		
		select
			@FileTypeSID = ft.FileTypeSID
		from
			sf.FileType ft
		where
			ft.FileTypeSCD = @FileTypeSCD
		and
			ft.IsActive = @ON
		
		if @@rowcount = 0
		begin
		
			exec sf.pMessage#Get
				@MessageSCD  = 'FileTypeNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The file type "%1" is not supported. Upload a different file or ask your administrator if this type can be added to the configuration.'
				,@Arg1        = @FileTypeSCD
		
			raiserror(@errorText, 16, 1)
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.EmailTriggerSID from sf.PersonEmailMessage x where x.PersonEmailMessageSID = @PersonEmailMessageSID) <> @EmailTriggerSID
		begin
			if (select x.IsActive from sf.EmailTrigger x where x.EmailTriggerSID = @EmailTriggerSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'email trigger'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.FileTypeSID from sf.PersonEmailMessage x where x.PersonEmailMessageSID = @PersonEmailMessageSID) <> @FileTypeSID
		begin
			if (select x.IsActive from sf.FileType x where x.FileTypeSID = @FileTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'file type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Kris Dawson | Mar 2018		
		if @IsNotReceived = @ON and @NotReceivedNoticeTime is null
		begin
			set @NotReceivedNoticeTime = sysdatetimeoffset()
		end

		-- Tim Edlund | Oct 2018
		-- Where the email document is being provided, the
		-- Body text (HTML) can be set to null to conserve
		-- disk space.  (Re-sending email uses the parent
		-- email-message Body template.)

		if @EmailDocument is not null
		begin
			set @Body = null
		end
		--! </PreUpdate>

		-- update the record

		update
			sf.PersonEmailMessage
		set
			 PersonSID = @PersonSID
			,EmailMessageSID = @EmailMessageSID
			,EmailAddress = @EmailAddress
			,SelectedTime = @SelectedTime
			,SentTime = @SentTime
			,Subject = @Subject
			,Body = @Body
			,EmailDocument = @EmailDocument
			,FileTypeSID = @FileTypeSID
			,FileTypeSCD = @FileTypeSCD
			,NotReceivedNoticeTime = @NotReceivedNoticeTime
			,ConfirmedTime = @ConfirmedTime
			,CancelledTime = @CancelledTime
			,OpenedTime = @OpenedTime
			,ChangeAudit = @ChangeAudit
			,MergeKey = @MergeKey
			,EmailTriggerSID = @EmailTriggerSID
			,ServiceMessageID = @ServiceMessageID
			,UserDefinedColumns = @UserDefinedColumns
			,PersonEmailMessageXID = @PersonEmailMessageXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonEmailMessageSID = @PersonEmailMessageSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.PersonEmailMessage where PersonEmailMessageSID = @personEmailMessageSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.PersonEmailMessage'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.PersonEmailMessage'
					,@Arg2        = @personEmailMessageSID
				
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
				,@Arg2        = 'sf.PersonEmailMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personEmailMessageSID
			
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
				 ent.PersonEmailMessageSID
			from
				sf.vPersonEmailMessage ent
			where
				ent.PersonEmailMessageSID = @PersonEmailMessageSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonEmailMessageSID
				,ent.PersonSID
				,ent.EmailMessageSID
				,ent.EmailAddress
				,ent.SelectedTime
				,ent.SentTime
				,ent.Subject
				,ent.Body
				,ent.EmailDocument
				,ent.FileTypeSID
				,ent.FileTypeSCD
				,ent.NotReceivedNoticeTime
				,ent.ConfirmedTime
				,ent.CancelledTime
				,ent.OpenedTime
				,ent.ChangeAudit
				,ent.MergeKey
				,ent.EmailTriggerSID
				,ent.ServiceMessageID
				,ent.UserDefinedColumns
				,ent.PersonEmailMessageXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.SenderEmailAddress
				,ent.SenderDisplayName
				,ent.PriorityLevel
				,ent.EmailMessageSubject
				,ent.EmailMessageFileTypeSCD
				,ent.EmailMessageFileTypeSID
				,ent.IsApplicationUserRequired
				,ent.EmailMessageApplicationUserSID
				,ent.MessageLinkSID
				,ent.LinkExpiryHours
				,ent.ApplicationEntitySID
				,ent.ApplicationGrantSID
				,ent.IsGenerateOnly
				,ent.MergedTime
				,ent.QueuedTime
				,ent.EmailMessageCancelledTime
				,ent.ArchivedTime
				,ent.PurgedTime
				,ent.EmailMessageRowGUID
				,ent.FileTypeFileTypeSCD
				,ent.FileTypeLabel
				,ent.MimeType
				,ent.IsInline
				,ent.FileTypeIsActive
				,ent.FileTypeRowGUID
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
				,ent.EmailTriggerLabel
				,ent.EmailTemplateSID
				,ent.QuerySID
				,ent.MinDaysToRepeat
				,ent.EmailTriggerApplicationUserSID
				,ent.JobScheduleSID
				,ent.LastStartTime
				,ent.LastEndTime
				,ent.EarliestSelectionDate
				,ent.EmailTriggerIsActive
				,ent.EmailTriggerRowGUID
				,ent.ChangeReason
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsReadGranted
				,ent.SubjectSent
				,ent.BodySent
				,ent.MessageLinkExpiryTime
				,ent.ConfirmationLagHours
				,ent.MessageLinkStatusSCD
				,ent.MessageLinkStatusLabel
				,ent.IsPending
				,ent.IsConfirmed
				,ent.IsExpired
				,ent.IsCancelled
				,ent.IsPurged
				,ent.IsEmailOpenTracked
				,ent.IsNotReceived
				,ent.FileAsName
				,ent.FullName
				,ent.DisplayName
				,ent.AgeInYears
				,ent.CurrentEmailAddress
			from
				sf.vPersonEmailMessage ent
			where
				ent.PersonEmailMessageSID = @PersonEmailMessageSID

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
