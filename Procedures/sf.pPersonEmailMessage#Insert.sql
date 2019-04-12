SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonEmailMessage#Insert]
	 @PersonEmailMessageSID          int               = null output				-- identity value assigned to the new record
	,@PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@EmailMessageSID                int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@EmailAddress                   varchar(150)      = null								
	,@SelectedTime                   datetimeoffset(7) = null								
	,@SentTime                       datetimeoffset(7) = null								
	,@Subject                        nvarchar(120)     = null								
	,@Body                           nvarchar(max)     = null								
	,@EmailDocument                  varbinary(max)    = null								
	,@FileTypeSID                    int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@FileTypeSCD                    varchar(8)        = null								-- default: '.PDF'
	,@NotReceivedNoticeTime          datetime          = null								
	,@ConfirmedTime                  datetimeoffset(7) = null								
	,@CancelledTime                  datetimeoffset(7) = null								
	,@OpenedTime                     datetimeoffset(7) = null								
	,@ChangeAudit                    nvarchar(max)     = null								-- required! if not passed value must be set in custom logic prior to insert
	,@MergeKey                       int               = null								
	,@EmailTriggerSID                int               = null								
	,@ServiceMessageID               varchar(100)      = null								
	,@UserDefinedColumns             xml               = null								
	,@PersonEmailMessageXID          varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@SenderEmailAddress             varchar(150)      = null								-- not a base table column (default ignored)
	,@SenderDisplayName              nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PriorityLevel                  tinyint           = null								-- not a base table column (default ignored)
	,@EmailMessageSubject            nvarchar(120)     = null								-- not a base table column (default ignored)
	,@EmailMessageFileTypeSCD        varchar(8)        = null								-- not a base table column (default ignored)
	,@EmailMessageFileTypeSID        int               = null								-- not a base table column (default ignored)
	,@IsApplicationUserRequired      bit               = null								-- not a base table column (default ignored)
	,@EmailMessageApplicationUserSID int               = null								-- not a base table column (default ignored)
	,@MessageLinkSID                 int               = null								-- not a base table column (default ignored)
	,@LinkExpiryHours                int               = null								-- not a base table column (default ignored)
	,@ApplicationEntitySID           int               = null								-- not a base table column (default ignored)
	,@ApplicationGrantSID            int               = null								-- not a base table column (default ignored)
	,@IsGenerateOnly                 bit               = null								-- not a base table column (default ignored)
	,@MergedTime                     datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@QueuedTime                     datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@EmailMessageCancelledTime      datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@ArchivedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@PurgedTime                     datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@EmailMessageRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
	,@FileTypeFileTypeSCD            varchar(8)        = null								-- not a base table column (default ignored)
	,@FileTypeLabel                  nvarchar(35)      = null								-- not a base table column (default ignored)
	,@MimeType                       varchar(255)      = null								-- not a base table column (default ignored)
	,@IsInline                       bit               = null								-- not a base table column (default ignored)
	,@FileTypeIsActive               bit               = null								-- not a base table column (default ignored)
	,@FileTypeRowGUID                uniqueidentifier  = null								-- not a base table column (default ignored)
	,@GenderSID                      int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                  int               = null								-- not a base table column (default ignored)
	,@FirstName                      nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                      date              = null								-- not a base table column (default ignored)
	,@DeathDate                      date              = null								-- not a base table column (default ignored)
	,@HomePhone                      varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled         bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                    nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@EmailTriggerLabel              nvarchar(35)      = null								-- not a base table column (default ignored)
	,@EmailTemplateSID               int               = null								-- not a base table column (default ignored)
	,@QuerySID                       int               = null								-- not a base table column (default ignored)
	,@MinDaysToRepeat                int               = null								-- not a base table column (default ignored)
	,@EmailTriggerApplicationUserSID int               = null								-- not a base table column (default ignored)
	,@JobScheduleSID                 int               = null								-- not a base table column (default ignored)
	,@LastStartTime                  datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@LastEndTime                    datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@EarliestSelectionDate          date              = null								-- not a base table column (default ignored)
	,@EmailTriggerIsActive           bit               = null								-- not a base table column (default ignored)
	,@EmailTriggerRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ChangeReason                   nvarchar(4000)    = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsReadGranted                  bit               = null								-- not a base table column (default ignored)
	,@SubjectSent                    nvarchar(120)     = null								-- not a base table column (default ignored)
	,@BodySent                       nvarchar(max)     = null								-- not a base table column (default ignored)
	,@MessageLinkExpiryTime          datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@ConfirmationLagHours           int               = null								-- not a base table column (default ignored)
	,@MessageLinkStatusSCD           varchar(10)       = null								-- not a base table column (default ignored)
	,@MessageLinkStatusLabel         nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsPending                      bit               = null								-- not a base table column (default ignored)
	,@IsConfirmed                    bit               = null								-- not a base table column (default ignored)
	,@IsExpired                      bit               = null								-- not a base table column (default ignored)
	,@IsCancelled                    bit               = null								-- not a base table column (default ignored)
	,@IsPurged                       bit               = null								-- not a base table column (default ignored)
	,@IsEmailOpenTracked             bit               = null								-- not a base table column (default ignored)
	,@IsNotReceived                  bit               = null								-- not a base table column (default ignored)
	,@FileAsName                     nvarchar(65)      = null								-- not a base table column (default ignored)
	,@FullName                       nvarchar(65)      = null								-- not a base table column (default ignored)
	,@DisplayName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@AgeInYears                     int               = null								-- not a base table column (default ignored)
	,@CurrentEmailAddress            varchar(150)      = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonEmailMessage#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.PersonEmailMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.PersonEmailMessage table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonEmailMessage entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonEmailMessage procedure. The extended procedure is only called
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

	set @PersonEmailMessageSID = null																				-- initialize output parameter

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

		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @Subject = ltrim(rtrim(@Subject))
		set @Body = ltrim(rtrim(@Body))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @ServiceMessageID = ltrim(rtrim(@ServiceMessageID))
		set @PersonEmailMessageXID = ltrim(rtrim(@PersonEmailMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @FileTypeSCD = isnull(@FileTypeSCD,'.PDF')
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected          = isnull(@IsReselected         ,(0))
		
		-- call a function to format the comment for the auditing column (where passed)
		
		if @ChangeReason is not null set @ChangeAudit = sf.fChangeAudit#Comment(@ChangeReason, null)
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		if @IsConfirmed = @ON and @ConfirmedTime is null set @ConfirmedTime = sysdatetimeoffset()
		
		-- ensure both the file type code (SCD) and key (SID) are provided - default from the value provided
		
		if @FileTypeSCD is null and @FileTypeSID is not null
		begin
		
			select
				@FileTypeSCD = ft.FileTypeSCD
			from
				sf.FileType ft
			where
				ft.FileTypeSID = @FileTypeSID
			and
				ft.IsActive = @ON
			
		end
		
		if @FileTypeSID is null and @FileTypeSCD is not null
		begin
		
			select
				@FileTypeSID = ft.FileTypeSID
			from
				sf.FileType ft
			where
				ft.FileTypeSCD = @FileTypeSCD
			and
				ft.IsActive = @ON
			
		end
		
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

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Apr 2015
		-- Record an original entry in the change audit column
		-- if one is not already provided by the UI.

		if @ChangeAudit is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'SelectedAsRecipient'								-- avoid hard-coding the text
				,@MessageText = @ChangeReason output
				,@DefaultText = N'Selected as recipient'

			set @ChangeAudit = sf.fChangeAudit#Comment(@ChangeReason, null)
		end

		-- Tim Edlund | Oct 2018
		-- Where the email document is being provided, the
		-- Body text (HTML) can be set to null to conserve
		-- disk space.  (Re-sending email uses the parent
		-- email-message Body template.)

		if @EmailDocument is not null -- this is an edge case for INSERT; can occur on conversion routines
		begin
			set @Body = null
		end
		--! </PreInsert>

		-- insert the record

		insert
			sf.PersonEmailMessage
		(
			 PersonSID
			,EmailMessageSID
			,EmailAddress
			,SelectedTime
			,SentTime
			,Subject
			,Body
			,EmailDocument
			,FileTypeSID
			,FileTypeSCD
			,NotReceivedNoticeTime
			,ConfirmedTime
			,CancelledTime
			,OpenedTime
			,ChangeAudit
			,MergeKey
			,EmailTriggerSID
			,ServiceMessageID
			,UserDefinedColumns
			,PersonEmailMessageXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@EmailMessageSID
			,@EmailAddress
			,@SelectedTime
			,@SentTime
			,@Subject
			,@Body
			,@EmailDocument
			,@FileTypeSID
			,@FileTypeSCD
			,@NotReceivedNoticeTime
			,@ConfirmedTime
			,@CancelledTime
			,@OpenedTime
			,@ChangeAudit
			,@MergeKey
			,@EmailTriggerSID
			,@ServiceMessageID
			,@UserDefinedColumns
			,@PersonEmailMessageXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected          = @@rowcount
			,@PersonEmailMessageSID = scope_identity()													-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.PersonEmailMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonEmailMessageSID
			
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
