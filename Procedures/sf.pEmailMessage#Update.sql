SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#Update]
	 @EmailMessageSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@SenderEmailAddress               varchar(150)      = null -- table column values to update:
	,@SenderDisplayName                nvarchar(75)      = null
	,@PriorityLevel                    tinyint           = null
	,@Subject                          nvarchar(120)     = null
	,@Body                             varbinary(max)    = null
	,@FileTypeSCD                      varchar(8)        = null
	,@FileTypeSID                      int               = null
	,@RecipientList                    xml               = null
	,@IsApplicationUserRequired        bit               = null
	,@ApplicationUserSID               int               = null
	,@MessageLinkSID                   int               = null
	,@LinkExpiryHours                  int               = null
	,@ApplicationEntitySID             int               = null
	,@ApplicationGrantSID              int               = null
	,@IsGenerateOnly                   bit               = null
	,@MergedTime                       datetimeoffset(7) = null
	,@QueuedTime                       datetimeoffset(7) = null
	,@CancelledTime                    datetimeoffset(7) = null
	,@ArchivedTime                     datetimeoffset(7) = null
	,@PurgedTime                       datetimeoffset(7) = null
	,@UserDefinedColumns               xml               = null
	,@EmailMessageXID                  varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@FileTypeFileTypeSCD              varchar(8)        = null -- not a base table column
	,@FileTypeLabel                    nvarchar(35)      = null -- not a base table column
	,@MimeType                         varchar(255)      = null -- not a base table column
	,@IsInline                         bit               = null -- not a base table column
	,@FileTypeIsActive                 bit               = null -- not a base table column
	,@FileTypeRowGUID                  uniqueidentifier  = null -- not a base table column
	,@MessageLinkSCD                   varchar(30)       = null -- not a base table column
	,@MessageLinkLabel                 nvarchar(35)      = null -- not a base table column
	,@ApplicationPageSID               int               = null -- not a base table column
	,@MessageLinkRowGUID               uniqueidentifier  = null -- not a base table column
	,@ApplicationEntitySCD             varchar(50)       = null -- not a base table column
	,@ApplicationEntityName            nvarchar(50)      = null -- not a base table column
	,@IsMergeDataSource                bit               = null -- not a base table column
	,@ApplicationEntityRowGUID         uniqueidentifier  = null -- not a base table column
	,@ApplicationGrantSCD              varchar(30)       = null -- not a base table column
	,@ApplicationGrantName             nvarchar(150)     = null -- not a base table column
	,@ApplicationGrantIsDefault        bit               = null -- not a base table column
	,@ApplicationGrantRowGUID          uniqueidentifier  = null -- not a base table column
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
	,@IsDeleteEnabled                  bit               = null -- not a base table column
	,@LinkURI                          varchar(150)      = null -- not a base table column
	,@MessageStatusSCD                 varchar(10)       = null -- not a base table column
	,@MessageStatusLabel               nvarchar(35)      = null -- not a base table column
	,@RecipientCount                   int               = null -- not a base table column
	,@NotReceivedCount                 int               = null -- not a base table column
	,@IsQueued                         bit               = null -- not a base table column
	,@IsSent                           bit               = null -- not a base table column
	,@IsCancelled                      bit               = null -- not a base table column
	,@IsCancelEnabled                  bit               = null -- not a base table column
	,@IsArchived                       bit               = null -- not a base table column
	,@IsPurged                         bit               = null -- not a base table column
	,@SentTime                         datetimeoffset(7) = null -- not a base table column
	,@SentTimeLast                     datetimeoffset(7) = null -- not a base table column
	,@SentCount                        int               = null -- not a base table column
	,@NotSentCount                     int               = null -- not a base table column
	,@IsEditEnabled                    bit               = null -- not a base table column
	,@IsLinkEmbedded                   bit               = null -- not a base table column
	,@QueuingTime                      datetimeoffset(7) = null -- not a base table column
	,@RecipientPersonSID               int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pEmailMessage#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.EmailMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.EmailMessage table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vEmailMessage entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pEmailMessage procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fEmailMessageCheck to test all rules.

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

		if @EmailMessageSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@EmailMessageSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @SenderEmailAddress = ltrim(rtrim(@SenderEmailAddress))
		set @SenderDisplayName = ltrim(rtrim(@SenderDisplayName))
		set @Subject = ltrim(rtrim(@Subject))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @EmailMessageXID = ltrim(rtrim(@EmailMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FileTypeFileTypeSCD = ltrim(rtrim(@FileTypeFileTypeSCD))
		set @FileTypeLabel = ltrim(rtrim(@FileTypeLabel))
		set @MimeType = ltrim(rtrim(@MimeType))
		set @MessageLinkSCD = ltrim(rtrim(@MessageLinkSCD))
		set @MessageLinkLabel = ltrim(rtrim(@MessageLinkLabel))
		set @ApplicationEntitySCD = ltrim(rtrim(@ApplicationEntitySCD))
		set @ApplicationEntityName = ltrim(rtrim(@ApplicationEntityName))
		set @ApplicationGrantSCD = ltrim(rtrim(@ApplicationGrantSCD))
		set @ApplicationGrantName = ltrim(rtrim(@ApplicationGrantName))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @LinkURI = ltrim(rtrim(@LinkURI))
		set @MessageStatusSCD = ltrim(rtrim(@MessageStatusSCD))
		set @MessageStatusLabel = ltrim(rtrim(@MessageStatusLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@SenderEmailAddress) = 0 set @SenderEmailAddress = null
		if len(@SenderDisplayName) = 0 set @SenderDisplayName = null
		if len(@Subject) = 0 set @Subject = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@EmailMessageXID) = 0 set @EmailMessageXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FileTypeFileTypeSCD) = 0 set @FileTypeFileTypeSCD = null
		if len(@FileTypeLabel) = 0 set @FileTypeLabel = null
		if len(@MimeType) = 0 set @MimeType = null
		if len(@MessageLinkSCD) = 0 set @MessageLinkSCD = null
		if len(@MessageLinkLabel) = 0 set @MessageLinkLabel = null
		if len(@ApplicationEntitySCD) = 0 set @ApplicationEntitySCD = null
		if len(@ApplicationEntityName) = 0 set @ApplicationEntityName = null
		if len(@ApplicationGrantSCD) = 0 set @ApplicationGrantSCD = null
		if len(@ApplicationGrantName) = 0 set @ApplicationGrantName = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@LinkURI) = 0 set @LinkURI = null
		if len(@MessageStatusSCD) = 0 set @MessageStatusSCD = null
		if len(@MessageStatusLabel) = 0 set @MessageStatusLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @SenderEmailAddress               = isnull(@SenderEmailAddress,em.SenderEmailAddress)
				,@SenderDisplayName                = isnull(@SenderDisplayName,em.SenderDisplayName)
				,@PriorityLevel                    = isnull(@PriorityLevel,em.PriorityLevel)
				,@Subject                          = isnull(@Subject,em.Subject)
				,@Body                             = isnull(@Body,em.Body)
				,@FileTypeSCD                      = isnull(@FileTypeSCD,em.FileTypeSCD)
				,@FileTypeSID                      = isnull(@FileTypeSID,em.FileTypeSID)
				,@RecipientList                    = isnull(@RecipientList,em.RecipientList)
				,@IsApplicationUserRequired        = isnull(@IsApplicationUserRequired,em.IsApplicationUserRequired)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,em.ApplicationUserSID)
				,@MessageLinkSID                   = isnull(@MessageLinkSID,em.MessageLinkSID)
				,@LinkExpiryHours                  = isnull(@LinkExpiryHours,em.LinkExpiryHours)
				,@ApplicationEntitySID             = isnull(@ApplicationEntitySID,em.ApplicationEntitySID)
				,@ApplicationGrantSID              = isnull(@ApplicationGrantSID,em.ApplicationGrantSID)
				,@IsGenerateOnly                   = isnull(@IsGenerateOnly,em.IsGenerateOnly)
				,@MergedTime                       = isnull(@MergedTime,em.MergedTime)
				,@QueuedTime                       = isnull(@QueuedTime,em.QueuedTime)
				,@CancelledTime                    = isnull(@CancelledTime,em.CancelledTime)
				,@ArchivedTime                     = isnull(@ArchivedTime,em.ArchivedTime)
				,@PurgedTime                       = isnull(@PurgedTime,em.PurgedTime)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,em.UserDefinedColumns)
				,@EmailMessageXID                  = isnull(@EmailMessageXID,em.EmailMessageXID)
				,@LegacyKey                        = isnull(@LegacyKey,em.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,em.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,em.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,em.IsNullApplied)
				,@zContext                         = isnull(@zContext,em.zContext)
				,@FileTypeFileTypeSCD              = isnull(@FileTypeFileTypeSCD,em.FileTypeFileTypeSCD)
				,@FileTypeLabel                    = isnull(@FileTypeLabel,em.FileTypeLabel)
				,@MimeType                         = isnull(@MimeType,em.MimeType)
				,@IsInline                         = isnull(@IsInline,em.IsInline)
				,@FileTypeIsActive                 = isnull(@FileTypeIsActive,em.FileTypeIsActive)
				,@FileTypeRowGUID                  = isnull(@FileTypeRowGUID,em.FileTypeRowGUID)
				,@MessageLinkSCD                   = isnull(@MessageLinkSCD,em.MessageLinkSCD)
				,@MessageLinkLabel                 = isnull(@MessageLinkLabel,em.MessageLinkLabel)
				,@ApplicationPageSID               = isnull(@ApplicationPageSID,em.ApplicationPageSID)
				,@MessageLinkRowGUID               = isnull(@MessageLinkRowGUID,em.MessageLinkRowGUID)
				,@ApplicationEntitySCD             = isnull(@ApplicationEntitySCD,em.ApplicationEntitySCD)
				,@ApplicationEntityName            = isnull(@ApplicationEntityName,em.ApplicationEntityName)
				,@IsMergeDataSource                = isnull(@IsMergeDataSource,em.IsMergeDataSource)
				,@ApplicationEntityRowGUID         = isnull(@ApplicationEntityRowGUID,em.ApplicationEntityRowGUID)
				,@ApplicationGrantSCD              = isnull(@ApplicationGrantSCD,em.ApplicationGrantSCD)
				,@ApplicationGrantName             = isnull(@ApplicationGrantName,em.ApplicationGrantName)
				,@ApplicationGrantIsDefault        = isnull(@ApplicationGrantIsDefault,em.ApplicationGrantIsDefault)
				,@ApplicationGrantRowGUID          = isnull(@ApplicationGrantRowGUID,em.ApplicationGrantRowGUID)
				,@PersonSID                        = isnull(@PersonSID,em.PersonSID)
				,@CultureSID                       = isnull(@CultureSID,em.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,em.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,em.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,em.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,em.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,em.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,em.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,em.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,em.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,em.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,em.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,em.ApplicationUserRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,em.IsDeleteEnabled)
				,@LinkURI                          = isnull(@LinkURI,em.LinkURI)
				,@MessageStatusSCD                 = isnull(@MessageStatusSCD,em.MessageStatusSCD)
				,@MessageStatusLabel               = isnull(@MessageStatusLabel,em.MessageStatusLabel)
				,@RecipientCount                   = isnull(@RecipientCount,em.RecipientCount)
				,@NotReceivedCount                 = isnull(@NotReceivedCount,em.NotReceivedCount)
				,@IsQueued                         = isnull(@IsQueued,em.IsQueued)
				,@IsSent                           = isnull(@IsSent,em.IsSent)
				,@IsCancelled                      = isnull(@IsCancelled,em.IsCancelled)
				,@IsCancelEnabled                  = isnull(@IsCancelEnabled,em.IsCancelEnabled)
				,@IsArchived                       = isnull(@IsArchived,em.IsArchived)
				,@IsPurged                         = isnull(@IsPurged,em.IsPurged)
				,@SentTime                         = isnull(@SentTime,em.SentTime)
				,@SentTimeLast                     = isnull(@SentTimeLast,em.SentTimeLast)
				,@SentCount                        = isnull(@SentCount,em.SentCount)
				,@NotSentCount                     = isnull(@NotSentCount,em.NotSentCount)
				,@IsEditEnabled                    = isnull(@IsEditEnabled,em.IsEditEnabled)
				,@IsLinkEmbedded                   = isnull(@IsLinkEmbedded,em.IsLinkEmbedded)
				,@QueuingTime                      = isnull(@QueuingTime,em.QueuingTime)
				,@RecipientPersonSID               = isnull(@RecipientPersonSID,em.RecipientPersonSID)
			from
				sf.vEmailMessage em
			where
				em.EmailMessageSID = @EmailMessageSID

		end
		
		if @IsArchived  = @ON and @ArchivedTime  is null set @ArchivedTime  = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()
		if @IsPurged    = @ON and @PurgedTime    is null set @PurgedTime    = sysdatetimeoffset()
		if @IsQueued    = @ON and @QueuedTime    is null set @QueuedTime    = sysdatetimeoffset()
		
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
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ApplicationEntitySCD is not null and @ApplicationEntitySID = (select x.ApplicationEntitySID from sf.EmailMessage x where x.EmailMessageSID = @EmailMessageSID)
		begin
		
			select
				@ApplicationEntitySID = x.ApplicationEntitySID
			from
				sf.ApplicationEntity x
			where
				x.ApplicationEntitySCD = @ApplicationEntitySCD
		
		end
		
		if @ApplicationGrantSCD is not null and @ApplicationGrantSID = (select x.ApplicationGrantSID from sf.EmailMessage x where x.EmailMessageSID = @EmailMessageSID)
		begin
		
			select
				@ApplicationGrantSID = x.ApplicationGrantSID
			from
				sf.ApplicationGrant x
			where
				x.ApplicationGrantSCD = @ApplicationGrantSCD
		
		end
		
		if @MessageLinkSCD is not null and @MessageLinkSID = (select x.MessageLinkSID from sf.EmailMessage x where x.EmailMessageSID = @EmailMessageSID)
		begin
		
			select
				@MessageLinkSID = x.MessageLinkSID
			from
				sf.MessageLink x
			where
				x.MessageLinkSCD = @MessageLinkSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from sf.EmailMessage x where x.EmailMessageSID = @EmailMessageSID) <> @ApplicationUserSID
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
		
		if (select x.FileTypeSID from sf.EmailMessage x where x.EmailMessageSID = @EmailMessageSID) <> @FileTypeSID
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
    -- Tim Edlund | Mar 2017
    -- If the message is being cancelled, then cancel all child
    -- rows of the message to prevent them from sending

    if @CancelledTime is not null and exists(select 1 from sf.EmailMessage em where em.EmailMessageSID = @EmailMessageSID and em.CancelledTime is null)
    begin

      update
        sf.PersonEmailMessage
      set
         CancelledTime = sysdatetimeoffset()
        ,UpdateUser   = @UpdateUser
        ,UpdateTime   = sysdatetimeoffset()
      where
        EmailMessageSID = @EmailMessageSID

    end

		-- Cory Ng | Feb 2017
		-- Queue time buffer as queue time is cleared out to pass BR during update
		-- the scheduled time is passed to the #Queue sproc after the update

		declare
			@scheduledTime			datetimeoffset(7)																

		-- Tim Edlund | April 2015
		-- Validate the sending email address before it hits the check constraint
		-- in order to make it clear the error is from the configuration.

		if @SenderEmailAddress is not null and sf.fIsValidEmail(@SenderEmailAddress) = @OFF	and @IsCancelled = @OFF
		begin

			exec sf.pMessage#Get
				 @MessageSCD = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'Sender Email Address'

			raiserror(@errorText, 17, 1)

		end

		-- Tim Edlund | Apr 2015
		-- If the queued bit is set but the message has already been queued then
		-- unset the @IsQueued bit. When the bit remains set, it causes the email
		-- queuing procedure to be called in the post logic. If no queued time
		-- is set in the DB, avoid setting it on initial update (let queuing
		-- sproc set it after all BR's have passed)

		if @IsQueued = @ON and @IsCancelled = @OFF
		begin			
			if exists (select 1 from sf.EmailMessage em where em.EmailMessageSID = @EmailMessageSID and em.QueuedTime is not null) or @QueuingTime is not null
			begin
				set @IsQueued = @OFF																							-- turn off queuing action - already queued, or is being processed
			end
			else
			begin
				set @QueuedTime = null																						-- don't set date in this sproc; set in #Queue sproc
			end

		end

		-- Cory Ng | Feb 2017
		-- If @IsQueued is not passed as ON then the queued time passed is
		-- a scheduled time. Store time in a variable so that the queuing sproc
		-- will set it

		if @QueuedTime is not null and @IsCancelled = @OFF
		begin
			set @scheduledTime = @QueuedTime
			set @QueuedTime = null
		end

		--! </PreUpdate>

		-- update the record

		update
			sf.EmailMessage
		set
			 SenderEmailAddress = @SenderEmailAddress
			,SenderDisplayName = @SenderDisplayName
			,PriorityLevel = @PriorityLevel
			,Subject = @Subject
			,Body = @Body
			,FileTypeSCD = @FileTypeSCD
			,FileTypeSID = @FileTypeSID
			,RecipientList = @RecipientList
			,IsApplicationUserRequired = @IsApplicationUserRequired
			,ApplicationUserSID = @ApplicationUserSID
			,MessageLinkSID = @MessageLinkSID
			,LinkExpiryHours = @LinkExpiryHours
			,ApplicationEntitySID = @ApplicationEntitySID
			,ApplicationGrantSID = @ApplicationGrantSID
			,IsGenerateOnly = @IsGenerateOnly
			,MergedTime = @MergedTime
			,QueuedTime = @QueuedTime
			,CancelledTime = @CancelledTime
			,ArchivedTime = @ArchivedTime
			,PurgedTime = @PurgedTime
			,UserDefinedColumns = @UserDefinedColumns
			,EmailMessageXID = @EmailMessageXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			EmailMessageSID = @EmailMessageSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.EmailMessage where EmailMessageSID = @emailMessageSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.EmailMessage'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.EmailMessage'
					,@Arg2        = @emailMessageSID
				
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
				,@Arg2        = 'sf.EmailMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @emailMessageSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Oct 2018
		-- If single recipient value is populated, and the person
		-- has an email address then assign the message and queue
		-- it for sending

		if @RecipientPersonSID is not null
		begin

			declare
				@targetEmailAddress varchar(150)

			select
				@targetEmailAddress = pea.EmailAddress
			from
				sf.PersonEmailAddress pea
			where
				pea.PersonSID = @RecipientPersonSID and pea.IsPrimary = @ON

			-- also ensure person is not already in the recipient list

			if @targetEmailAddress is not null
			and not exists(select 1 from sf.PersonEmailMessage pem where pem.EmailMessageSID = @EmailMessageSID and pem.PersonSID = @RecipientPersonSID)
			begin

				exec sf.pPersonEmailMessage#Insert																-- use EF sproc to insert person identified as recipient
					 @PersonSID				= @RecipientPersonSID
					,@EmailMessageSID = @EmailMessageSID
					,@EmailAddress		= @targetEmailAddress
					,@MergeKey				= @RecipientPersonSID

				set @IsQueued = @ON																								-- turn on queuing - calls sproc below to merge and send

			end

		end
		-- Richard K | Sept 2015		
		-- If the queued flag is on, call the EmailMessage#Queue job to process
		-- the merging of the PersonEmailMessage body text asynchronous. The
		-- Queued Time is not set here, but is updated when the job has completed
		-- processing successfully.

		if @IsQueued = @ON or @scheduledTime is not null
		begin

			if not exists (select 1 from sf.Job where JobSCD = 'sf.pEmailMessage#Queue')
			begin

				exec sf.pMessage#Get
				 @MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'email message queue job'

				raiserror(@errorText, 17, 1)

			end
			else
			begin
			
				declare
					 @jobSCD				varchar(128)	= 'sf.pEmailMessage#Queue'
					,@parameters		xml						= cast(N'<Parameters p1="' + cast(@EmailMessageSID as nvarchar(10)) + '" p2="' + coalesce('''' + cast(@scheduledTime as nvarchar(40)) + '''', 'null') +'"/>' as xml) 			-- parameters for the job call
				
				exec sf.pJob#Call
					 @JobSCD							= @jobSCD
					,@Parameters					= @parameters

			end

		end
		--! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.EmailMessageSID
			from
				sf.vEmailMessage ent
			where
				ent.EmailMessageSID = @EmailMessageSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.EmailMessageSID
				,ent.SenderEmailAddress
				,ent.SenderDisplayName
				,ent.PriorityLevel
				,ent.Subject
				,ent.Body
				,ent.FileTypeSCD
				,ent.FileTypeSID
				,ent.RecipientList
				,ent.IsApplicationUserRequired
				,ent.ApplicationUserSID
				,ent.MessageLinkSID
				,ent.LinkExpiryHours
				,ent.ApplicationEntitySID
				,ent.ApplicationGrantSID
				,ent.IsGenerateOnly
				,ent.MergedTime
				,ent.QueuedTime
				,ent.CancelledTime
				,ent.ArchivedTime
				,ent.PurgedTime
				,ent.UserDefinedColumns
				,ent.EmailMessageXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.FileTypeFileTypeSCD
				,ent.FileTypeLabel
				,ent.MimeType
				,ent.IsInline
				,ent.FileTypeIsActive
				,ent.FileTypeRowGUID
				,ent.MessageLinkSCD
				,ent.MessageLinkLabel
				,ent.ApplicationPageSID
				,ent.MessageLinkRowGUID
				,ent.ApplicationEntitySCD
				,ent.ApplicationEntityName
				,ent.IsMergeDataSource
				,ent.ApplicationEntityRowGUID
				,ent.ApplicationGrantSCD
				,ent.ApplicationGrantName
				,ent.ApplicationGrantIsDefault
				,ent.ApplicationGrantRowGUID
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
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.LinkURI
				,ent.MessageStatusSCD
				,ent.MessageStatusLabel
				,ent.RecipientCount
				,ent.NotReceivedCount
				,ent.IsQueued
				,ent.IsSent
				,ent.IsCancelled
				,ent.IsCancelEnabled
				,ent.IsArchived
				,ent.IsPurged
				,ent.SentTime
				,ent.SentTimeLast
				,ent.SentCount
				,ent.NotSentCount
				,ent.IsEditEnabled
				,ent.IsLinkEmbedded
				,ent.QueuingTime
				,ent.RecipientPersonSID
			from
				sf.vEmailMessage ent
			where
				ent.EmailMessageSID = @EmailMessageSID

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
