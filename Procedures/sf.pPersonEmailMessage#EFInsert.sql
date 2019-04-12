SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonEmailMessage#EFInsert]
	 @PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pPersonEmailMessage#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonEmailMessage#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

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

		-- call the main procedure

		exec @errorNo = sf.pPersonEmailMessage#Insert
			 @PersonSID                      = @PersonSID
			,@EmailMessageSID                = @EmailMessageSID
			,@EmailAddress                   = @EmailAddress
			,@SelectedTime                   = @SelectedTime
			,@SentTime                       = @SentTime
			,@Subject                        = @Subject
			,@Body                           = @Body
			,@EmailDocument                  = @EmailDocument
			,@FileTypeSID                    = @FileTypeSID
			,@FileTypeSCD                    = @FileTypeSCD
			,@NotReceivedNoticeTime          = @NotReceivedNoticeTime
			,@ConfirmedTime                  = @ConfirmedTime
			,@CancelledTime                  = @CancelledTime
			,@OpenedTime                     = @OpenedTime
			,@ChangeAudit                    = @ChangeAudit
			,@MergeKey                       = @MergeKey
			,@EmailTriggerSID                = @EmailTriggerSID
			,@ServiceMessageID               = @ServiceMessageID
			,@UserDefinedColumns             = @UserDefinedColumns
			,@PersonEmailMessageXID          = @PersonEmailMessageXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@SenderEmailAddress             = @SenderEmailAddress
			,@SenderDisplayName              = @SenderDisplayName
			,@PriorityLevel                  = @PriorityLevel
			,@EmailMessageSubject            = @EmailMessageSubject
			,@EmailMessageFileTypeSCD        = @EmailMessageFileTypeSCD
			,@EmailMessageFileTypeSID        = @EmailMessageFileTypeSID
			,@IsApplicationUserRequired      = @IsApplicationUserRequired
			,@EmailMessageApplicationUserSID = @EmailMessageApplicationUserSID
			,@MessageLinkSID                 = @MessageLinkSID
			,@LinkExpiryHours                = @LinkExpiryHours
			,@ApplicationEntitySID           = @ApplicationEntitySID
			,@ApplicationGrantSID            = @ApplicationGrantSID
			,@IsGenerateOnly                 = @IsGenerateOnly
			,@MergedTime                     = @MergedTime
			,@QueuedTime                     = @QueuedTime
			,@EmailMessageCancelledTime      = @EmailMessageCancelledTime
			,@ArchivedTime                   = @ArchivedTime
			,@PurgedTime                     = @PurgedTime
			,@EmailMessageRowGUID            = @EmailMessageRowGUID
			,@FileTypeFileTypeSCD            = @FileTypeFileTypeSCD
			,@FileTypeLabel                  = @FileTypeLabel
			,@MimeType                       = @MimeType
			,@IsInline                       = @IsInline
			,@FileTypeIsActive               = @FileTypeIsActive
			,@FileTypeRowGUID                = @FileTypeRowGUID
			,@GenderSID                      = @GenderSID
			,@NamePrefixSID                  = @NamePrefixSID
			,@FirstName                      = @FirstName
			,@CommonName                     = @CommonName
			,@MiddleNames                    = @MiddleNames
			,@LastName                       = @LastName
			,@BirthDate                      = @BirthDate
			,@DeathDate                      = @DeathDate
			,@HomePhone                      = @HomePhone
			,@MobilePhone                    = @MobilePhone
			,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
			,@ImportBatch                    = @ImportBatch
			,@PersonRowGUID                  = @PersonRowGUID
			,@EmailTriggerLabel              = @EmailTriggerLabel
			,@EmailTemplateSID               = @EmailTemplateSID
			,@QuerySID                       = @QuerySID
			,@MinDaysToRepeat                = @MinDaysToRepeat
			,@EmailTriggerApplicationUserSID = @EmailTriggerApplicationUserSID
			,@JobScheduleSID                 = @JobScheduleSID
			,@LastStartTime                  = @LastStartTime
			,@LastEndTime                    = @LastEndTime
			,@EarliestSelectionDate          = @EarliestSelectionDate
			,@EmailTriggerIsActive           = @EmailTriggerIsActive
			,@EmailTriggerRowGUID            = @EmailTriggerRowGUID
			,@ChangeReason                   = @ChangeReason
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@IsReadGranted                  = @IsReadGranted
			,@SubjectSent                    = @SubjectSent
			,@BodySent                       = @BodySent
			,@MessageLinkExpiryTime          = @MessageLinkExpiryTime
			,@ConfirmationLagHours           = @ConfirmationLagHours
			,@MessageLinkStatusSCD           = @MessageLinkStatusSCD
			,@MessageLinkStatusLabel         = @MessageLinkStatusLabel
			,@IsPending                      = @IsPending
			,@IsConfirmed                    = @IsConfirmed
			,@IsExpired                      = @IsExpired
			,@IsCancelled                    = @IsCancelled
			,@IsPurged                       = @IsPurged
			,@IsEmailOpenTracked             = @IsEmailOpenTracked
			,@IsNotReceived                  = @IsNotReceived
			,@FileAsName                     = @FileAsName
			,@FullName                       = @FullName
			,@DisplayName                    = @DisplayName
			,@AgeInYears                     = @AgeInYears
			,@CurrentEmailAddress            = @CurrentEmailAddress

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
