SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#Insert]
	 @EmailMessageSID                  int               = null output			-- identity value assigned to the new record
	,@SenderEmailAddress               varchar(150)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@SenderDisplayName                nvarchar(75)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PriorityLevel                    tinyint           = null							-- default: (5)
	,@Subject                          nvarchar(120)     = null							-- required! if not passed value must be set in custom logic prior to insert
	,@Body                             varbinary(max)    = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FileTypeSCD                      varchar(8)        = null							-- default: '.HTML'
	,@FileTypeSID                      int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@RecipientList                    xml               = null							-- default: CONVERT(xml,N'<Recipients />')
	,@IsApplicationUserRequired        bit               = null							-- default: (0)
	,@ApplicationUserSID               int               = null							
	,@MessageLinkSID                   int               = null							
	,@LinkExpiryHours                  int               = null							-- default: (24)
	,@ApplicationEntitySID             int               = null							
	,@ApplicationGrantSID              int               = null							
	,@IsGenerateOnly                   bit               = null							-- default: CONVERT(bit,(0))
	,@MergedTime                       datetimeoffset(7) = null							
	,@QueuedTime                       datetimeoffset(7) = null							
	,@CancelledTime                    datetimeoffset(7) = null							
	,@ArchivedTime                     datetimeoffset(7) = null							
	,@PurgedTime                       datetimeoffset(7) = null							
	,@UserDefinedColumns               xml               = null							
	,@EmailMessageXID                  varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@FileTypeFileTypeSCD              varchar(8)        = null							-- not a base table column (default ignored)
	,@FileTypeLabel                    nvarchar(35)      = null							-- not a base table column (default ignored)
	,@MimeType                         varchar(255)      = null							-- not a base table column (default ignored)
	,@IsInline                         bit               = null							-- not a base table column (default ignored)
	,@FileTypeIsActive                 bit               = null							-- not a base table column (default ignored)
	,@FileTypeRowGUID                  uniqueidentifier  = null							-- not a base table column (default ignored)
	,@MessageLinkSCD                   varchar(30)       = null							-- not a base table column (default ignored)
	,@MessageLinkLabel                 nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ApplicationPageSID               int               = null							-- not a base table column (default ignored)
	,@MessageLinkRowGUID               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ApplicationEntitySCD             varchar(50)       = null							-- not a base table column (default ignored)
	,@ApplicationEntityName            nvarchar(50)      = null							-- not a base table column (default ignored)
	,@IsMergeDataSource                bit               = null							-- not a base table column (default ignored)
	,@ApplicationEntityRowGUID         uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ApplicationGrantSCD              varchar(30)       = null							-- not a base table column (default ignored)
	,@ApplicationGrantName             nvarchar(150)     = null							-- not a base table column (default ignored)
	,@ApplicationGrantIsDefault        bit               = null							-- not a base table column (default ignored)
	,@ApplicationGrantRowGUID          uniqueidentifier  = null							-- not a base table column (default ignored)
	,@PersonSID                        int               = null							-- not a base table column (default ignored)
	,@CultureSID                       int               = null							-- not a base table column (default ignored)
	,@AuthenticationAuthoritySID       int               = null							-- not a base table column (default ignored)
	,@UserName                         nvarchar(75)      = null							-- not a base table column (default ignored)
	,@LastReviewTime                   datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastReviewUser                   nvarchar(75)      = null							-- not a base table column (default ignored)
	,@IsPotentialDuplicate             bit               = null							-- not a base table column (default ignored)
	,@IsTemplate                       bit               = null							-- not a base table column (default ignored)
	,@GlassBreakPassword               varbinary(8000)   = null							-- not a base table column (default ignored)
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserIsActive          bit               = null							-- not a base table column (default ignored)
	,@AuthenticationSystemID           nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ApplicationUserRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@LinkURI                          varchar(150)      = null							-- not a base table column (default ignored)
	,@MessageStatusSCD                 varchar(10)       = null							-- not a base table column (default ignored)
	,@MessageStatusLabel               nvarchar(35)      = null							-- not a base table column (default ignored)
	,@RecipientCount                   int               = null							-- not a base table column (default ignored)
	,@NotReceivedCount                 int               = null							-- not a base table column (default ignored)
	,@IsQueued                         bit               = null							-- not a base table column (default ignored)
	,@IsSent                           bit               = null							-- not a base table column (default ignored)
	,@IsCancelled                      bit               = null							-- not a base table column (default ignored)
	,@IsCancelEnabled                  bit               = null							-- not a base table column (default ignored)
	,@IsArchived                       bit               = null							-- not a base table column (default ignored)
	,@IsPurged                         bit               = null							-- not a base table column (default ignored)
	,@SentTime                         datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@SentTimeLast                     datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@SentCount                        int               = null							-- not a base table column (default ignored)
	,@NotSentCount                     int               = null							-- not a base table column (default ignored)
	,@IsEditEnabled                    bit               = null							-- not a base table column (default ignored)
	,@IsLinkEmbedded                   bit               = null							-- not a base table column (default ignored)
	,@QueuingTime                      datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@RecipientPersonSID               int               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pEmailMessage#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.EmailMessage table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.EmailMessage table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vEmailMessage entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pEmailMessage procedure. The extended procedure is only called
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

	set @EmailMessageSID = null																							-- initialize output parameter

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

		set @SenderEmailAddress = ltrim(rtrim(@SenderEmailAddress))
		set @SenderDisplayName = ltrim(rtrim(@SenderDisplayName))
		set @Subject = ltrim(rtrim(@Subject))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @EmailMessageXID = ltrim(rtrim(@EmailMessageXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @PriorityLevel = isnull(@PriorityLevel,(5))
		set @FileTypeSCD = isnull(@FileTypeSCD,'.HTML')
		set @RecipientList = isnull(@RecipientList,CONVERT(xml,N'<Recipients />'))
		set @IsApplicationUserRequired = isnull(@IsApplicationUserRequired,(0))
		set @LinkExpiryHours = isnull(@LinkExpiryHours,(24))
		set @IsGenerateOnly = isnull(@IsGenerateOnly,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected              = isnull(@IsReselected             ,(0))
		
		if @IsArchived  = @ON and @ArchivedTime  is null set @ArchivedTime  = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()
		if @IsPurged    = @ON and @PurgedTime    is null set @PurgedTime    = sysdatetimeoffset()
		if @IsQueued    = @ON and @QueuedTime    is null set @QueuedTime    = sysdatetimeoffset()
		
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
		
		if @ApplicationGrantSCD is not null
		begin
		
			select
				@ApplicationGrantSID = x.ApplicationGrantSID
			from
				sf.ApplicationGrant x
			where
				x.ApplicationGrantSCD = @ApplicationGrantSCD
		
		end
		
		if @MessageLinkSCD is not null
		begin
		
			select
				@MessageLinkSID = x.MessageLinkSID
			from
				sf.MessageLink x
			where
				x.MessageLinkSCD = @MessageLinkSCD
		
		end

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>

		-- Cory Ng | Feb 2017
		-- Queue time buffer as queue time is cleared out to pass BR during update
		-- the scheduled time is passed to the #Queue sproc after the update

		declare
			@scheduledTime datetimeoffset(7)

		-- Tim Edlund | June 2015
		-- The sending email defaults to the value defined in the Email Sender
		-- table where not already set.  If missing or invalid, block the
		-- insert (more understandable error message than in check constraint).

		if @SenderEmailAddress is null
		begin
			
			select
			 	 @SenderEmailAddress = es.SenderEmailAddress
				,@SenderDisplayName = es.SenderDisplayName
			from
				sf.EmailSender es
			where
				es.IsDefault = @ON

			if @SenderEmailAddress is null or @SenderEmailAddress like '%?%'
			begin

				exec sf.pMessage#Get
					 @MessageSCD = 'ConfigurationNotComplete'
					,@MessageText = @errorText output
					,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
					,@Arg1        = 'Sender Email Address'

				raiserror(@errorText, 17, 1)

			end

		end

		-- Tim Edlund | July 2015
		-- If no display name is provided, look it up based on the
		-- email address (which is a UK in the sender table)

		if @SenderDisplayName is null and @SenderEmailAddress is not null
		begin
			select @SenderDisplayName = es.SenderDisplayName from sf.EmailSender es where es.SenderEmailAddress = @SenderEmailAddress
		end

		-- Tim Edlund | June 2015
		-- If a email link was specified, but no link expiry was entered, set it
		-- to 24 hours

		if @MessageLinkSID is not null and @LinkExpiryHours = 0 set @LinkExpiryHours = 24

		-- Tim Edlund | May 2015
		-- If the queued bit is set it causes the email queuing procedure to
		-- be called in the post logic. Unset the time (set by generated code
		-- above) so that queuing sproc sets this time after all BR have passed

		if @IsQueued = @ON	set @QueuedTime = null

		-- Cory Ng | Feb 2017
		-- If @IsQueued is not passed in as ON then the queued time passed is
		-- a scheduled time. Store time in a variable so that the queuing sproc
		-- will set it.

		if @QueuedTime is not null
		begin
			set @scheduledTime = @QueuedTime		-- note that this is a USER timezone value!
			set @QueuedTime = null
		end

		--! </PreInsert>

		-- insert the record

		insert
			sf.EmailMessage
		(
			 SenderEmailAddress
			,SenderDisplayName
			,PriorityLevel
			,Subject
			,Body
			,FileTypeSCD
			,FileTypeSID
			,RecipientList
			,IsApplicationUserRequired
			,ApplicationUserSID
			,MessageLinkSID
			,LinkExpiryHours
			,ApplicationEntitySID
			,ApplicationGrantSID
			,IsGenerateOnly
			,MergedTime
			,QueuedTime
			,CancelledTime
			,ArchivedTime
			,PurgedTime
			,UserDefinedColumns
			,EmailMessageXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @SenderEmailAddress
			,@SenderDisplayName
			,@PriorityLevel
			,@Subject
			,@Body
			,@FileTypeSCD
			,@FileTypeSID
			,@RecipientList
			,@IsApplicationUserRequired
			,@ApplicationUserSID
			,@MessageLinkSID
			,@LinkExpiryHours
			,@ApplicationEntitySID
			,@ApplicationGrantSID
			,@IsGenerateOnly
			,@MergedTime
			,@QueuedTime
			,@CancelledTime
			,@ArchivedTime
			,@PurgedTime
			,@UserDefinedColumns
			,@EmailMessageXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected    = @@rowcount
			,@EmailMessageSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.EmailMessage'
				,@Arg3        = @rowsAffected
				,@Arg4        = @EmailMessageSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Sep 2018
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

			if @targetEmailAddress is not null
			begin

				exec sf.pPersonEmailMessage#Insert																-- use EF sproc to insert person identified as recipient
					 @PersonSID				= @RecipientPersonSID
					,@EmailMessageSID = @EmailMessageSID
					,@EmailAddress		= @targetEmailAddress					,@MergeKey				= @RecipientPersonSID

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
					 @JobSCD			= @jobSCD
					,@Parameters	= @parameters

			end

		end

		--! </PostInsert>

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
