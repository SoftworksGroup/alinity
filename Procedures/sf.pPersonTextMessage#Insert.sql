SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonTextMessage#Insert]
	 @PersonTextMessageSID          int               = null output					-- identity value assigned to the new record
	,@PersonSID                     int               = null								-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pPersonTextMessage#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.PersonTextMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.PersonTextMessage table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonTextMessage entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonTextMessage procedure. The extended procedure is only called
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

	set @PersonTextMessageSID = null																				-- initialize output parameter

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

		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @Body = ltrim(rtrim(@Body))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @ServiceMessageID = ltrim(rtrim(@ServiceMessageID))
		set @PersonTextMessageXID = ltrim(rtrim(@PersonTextMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected          = isnull(@IsReselected         ,(0))
		
		set @MobilePhone = sf.fFormatPhone(@MobilePhone)											-- format phone numbers to standard
		
		-- call a function to format the comment for the auditing column (where passed)
		
		if @ChangeReason is not null set @ChangeAudit = sf.fChangeAudit#Comment(@ChangeReason, null)
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		if @IsConfirmed = @ON and @ConfirmedTime is null set @ConfirmedTime = sysdatetimeoffset()

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | June 2016
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
		--! </PreInsert>

		-- insert the record

		insert
			sf.PersonTextMessage
		(
			 PersonSID
			,TextMessageSID
			,MobilePhone
			,SentTime
			,Body
			,NotReceivedNoticeTime
			,ConfirmedTime
			,CancelledTime
			,DeliveredTime
			,ChangeAudit
			,MergeKey
			,TextTriggerSID
			,ServiceMessageID
			,UserDefinedColumns
			,PersonTextMessageXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@TextMessageSID
			,@MobilePhone
			,@SentTime
			,@Body
			,@NotReceivedNoticeTime
			,@ConfirmedTime
			,@CancelledTime
			,@DeliveredTime
			,@ChangeAudit
			,@MergeKey
			,@TextTriggerSID
			,@ServiceMessageID
			,@UserDefinedColumns
			,@PersonTextMessageXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected         = @@rowcount
			,@PersonTextMessageSID = scope_identity()														-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.PersonTextMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonTextMessageSID
			
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
