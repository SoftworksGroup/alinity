SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonTextMessage#EFInsert]
	 @PersonSID                     int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@TextMessageSID                int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@MobilePhone                   varchar(25)       = null								
	,@SentTime                      datetimeoffset(7) = null								
	,@Body                          nvarchar(1600)    = null								
	,@NotReceivedNoticeTime         datetime          = null								
	,@ConfirmedTime                 datetimeoffset(7) = null								
	,@CancelledTime                 datetimeoffset(7) = null								
	,@DeliveredTime                 datetimeoffset(7) = null								
	,@ChangeAudit                   nvarchar(max)     = null								-- required! if not passed value must be set in custom logic prior to insert
	,@MergeKey                      int               = null								
	,@TextTriggerSID                int               = null								
	,@ServiceMessageID              varchar(100)      = null								
	,@UserDefinedColumns            xml               = null								
	,@PersonTextMessageXID          varchar(150)      = null								
	,@LegacyKey                     nvarchar(50)      = null								
	,@CreateUser                    nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                  tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                      xml               = null								-- other values defining context for the insert (if any)
	,@GenderSID                     int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                 int               = null								-- not a base table column (default ignored)
	,@FirstName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                   nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                      nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                     date              = null								-- not a base table column (default ignored)
	,@DeathDate                     date              = null								-- not a base table column (default ignored)
	,@HomePhone                     varchar(25)       = null								-- not a base table column (default ignored)
	,@PersonMobilePhone             varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled        bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                   nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                 uniqueidentifier  = null								-- not a base table column (default ignored)
	,@SenderPhone                   varchar(25)       = null								-- not a base table column (default ignored)
	,@SenderDisplayName             nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PriorityLevel                 tinyint           = null								-- not a base table column (default ignored)
	,@TextMessageBody               nvarchar(1600)    = null								-- not a base table column (default ignored)
	,@IsApplicationUserRequired     bit               = null								-- not a base table column (default ignored)
	,@TextMessageApplicationUserSID int               = null								-- not a base table column (default ignored)
	,@MessageLinkSID                int               = null								-- not a base table column (default ignored)
	,@LinkExpiryHours               int               = null								-- not a base table column (default ignored)
	,@ApplicationEntitySID          int               = null								-- not a base table column (default ignored)
	,@MergedTime                    datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@QueuedTime                    datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@TextMessageCancelledTime      datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@ArchivedTime                  datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@TextMessageRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
	,@TextTriggerLabel              nvarchar(35)      = null								-- not a base table column (default ignored)
	,@TextTemplateSID               int               = null								-- not a base table column (default ignored)
	,@QuerySID                      int               = null								-- not a base table column (default ignored)
	,@MinDaysToRepeat               int               = null								-- not a base table column (default ignored)
	,@TextTriggerApplicationUserSID int               = null								-- not a base table column (default ignored)
	,@JobScheduleSID                int               = null								-- not a base table column (default ignored)
	,@LastStartTime                 datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@LastEndTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@TextTriggerIsActive           bit               = null								-- not a base table column (default ignored)
	,@TextTriggerRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ChangeReason                  nvarchar(4000)    = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled               bit               = null								-- not a base table column (default ignored)
	,@BodySent                      nvarchar(1600)    = null								-- not a base table column (default ignored)
	,@MessageLinkExpiryTime         datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@ConfirmationLagHours          int               = null								-- not a base table column (default ignored)
	,@MessageLinkStatusSCD          varchar(10)       = null								-- not a base table column (default ignored)
	,@MessageLinkStatusLabel        nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsPending                     bit               = null								-- not a base table column (default ignored)
	,@IsConfirmed                   bit               = null								-- not a base table column (default ignored)
	,@IsExpired                     bit               = null								-- not a base table column (default ignored)
	,@IsCancelled                   bit               = null								-- not a base table column (default ignored)
	,@FileAsName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@FullName                      nvarchar(65)      = null								-- not a base table column (default ignored)
	,@DisplayName                   nvarchar(65)      = null								-- not a base table column (default ignored)
	,@AgeInYears                    int               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonTextMessage#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonTextMessage#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
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

		exec @errorNo = sf.pPersonTextMessage#Insert
			 @PersonSID                     = @PersonSID
			,@TextMessageSID                = @TextMessageSID
			,@MobilePhone                   = @MobilePhone
			,@SentTime                      = @SentTime
			,@Body                          = @Body
			,@NotReceivedNoticeTime         = @NotReceivedNoticeTime
			,@ConfirmedTime                 = @ConfirmedTime
			,@CancelledTime                 = @CancelledTime
			,@DeliveredTime                 = @DeliveredTime
			,@ChangeAudit                   = @ChangeAudit
			,@MergeKey                      = @MergeKey
			,@TextTriggerSID                = @TextTriggerSID
			,@ServiceMessageID              = @ServiceMessageID
			,@UserDefinedColumns            = @UserDefinedColumns
			,@PersonTextMessageXID          = @PersonTextMessageXID
			,@LegacyKey                     = @LegacyKey
			,@CreateUser                    = @CreateUser
			,@IsReselected                  = @IsReselected
			,@zContext                      = @zContext
			,@GenderSID                     = @GenderSID
			,@NamePrefixSID                 = @NamePrefixSID
			,@FirstName                     = @FirstName
			,@CommonName                    = @CommonName
			,@MiddleNames                   = @MiddleNames
			,@LastName                      = @LastName
			,@BirthDate                     = @BirthDate
			,@DeathDate                     = @DeathDate
			,@HomePhone                     = @HomePhone
			,@PersonMobilePhone             = @PersonMobilePhone
			,@IsTextMessagingEnabled        = @IsTextMessagingEnabled
			,@ImportBatch                   = @ImportBatch
			,@PersonRowGUID                 = @PersonRowGUID
			,@SenderPhone                   = @SenderPhone
			,@SenderDisplayName             = @SenderDisplayName
			,@PriorityLevel                 = @PriorityLevel
			,@TextMessageBody               = @TextMessageBody
			,@IsApplicationUserRequired     = @IsApplicationUserRequired
			,@TextMessageApplicationUserSID = @TextMessageApplicationUserSID
			,@MessageLinkSID                = @MessageLinkSID
			,@LinkExpiryHours               = @LinkExpiryHours
			,@ApplicationEntitySID          = @ApplicationEntitySID
			,@MergedTime                    = @MergedTime
			,@QueuedTime                    = @QueuedTime
			,@TextMessageCancelledTime      = @TextMessageCancelledTime
			,@ArchivedTime                  = @ArchivedTime
			,@TextMessageRowGUID            = @TextMessageRowGUID
			,@TextTriggerLabel              = @TextTriggerLabel
			,@TextTemplateSID               = @TextTemplateSID
			,@QuerySID                      = @QuerySID
			,@MinDaysToRepeat               = @MinDaysToRepeat
			,@TextTriggerApplicationUserSID = @TextTriggerApplicationUserSID
			,@JobScheduleSID                = @JobScheduleSID
			,@LastStartTime                 = @LastStartTime
			,@LastEndTime                   = @LastEndTime
			,@TextTriggerIsActive           = @TextTriggerIsActive
			,@TextTriggerRowGUID            = @TextTriggerRowGUID
			,@ChangeReason                  = @ChangeReason
			,@IsDeleteEnabled               = @IsDeleteEnabled
			,@BodySent                      = @BodySent
			,@MessageLinkExpiryTime         = @MessageLinkExpiryTime
			,@ConfirmationLagHours          = @ConfirmationLagHours
			,@MessageLinkStatusSCD          = @MessageLinkStatusSCD
			,@MessageLinkStatusLabel        = @MessageLinkStatusLabel
			,@IsPending                     = @IsPending
			,@IsConfirmed                   = @IsConfirmed
			,@IsExpired                     = @IsExpired
			,@IsCancelled                   = @IsCancelled
			,@FileAsName                    = @FileAsName
			,@FullName                      = @FullName
			,@DisplayName                   = @DisplayName
			,@AgeInYears                    = @AgeInYears

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
