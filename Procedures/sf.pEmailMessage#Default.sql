SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#Default]
	 @zContext                         xml               = null                           -- default values provided from client-tier (if any)
	,@SetFKDefaults                    bit               = 0                              -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : sf.pEmailMessage#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" sf.EmailMessage records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.EmailMessage table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vEmailMessage entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pEmailMessage
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pEmailMessage of the context of the call. All other parameters are also passed, however, only those parameters eligible
for default setting are passed for "output". All parameters corresponding to entity view columns are returned through a SELECT statement.

In order to simplify working with the XML parameter values, logic in the procedure parses the XML and assigns values to variables where
the variable name matches the column name in the XML (assumes single row).  The variables are then available to the table-specific and
client-specific logic.  The @zContext parameter is also passed, unmodified, to the extended procedure to support situations where values
are passed that are not mapped to column names.


-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@ON                               bit = cast(1 as bit)								-- constant for bit comparisons
		,@OFF                              bit = cast(0 as bit)								-- constant for bit comparisons
		,@emailMessageSID                  int               = -1							-- specific default required by EF - do not override
		,@senderEmailAddress               varchar(150)      = null						-- no default provided from DB constraint - OK to override
		,@senderDisplayName                nvarchar(75)      = null						-- no default provided from DB constraint - OK to override
		,@priorityLevel                    tinyint           = (5)						-- default provided from DB constraint - OK to override
		,@subject                          nvarchar(120)     = null						-- no default provided from DB constraint - OK to override
		,@body                             varbinary(max)    = null						-- no default provided from DB constraint - OK to override
		,@fileTypeSCD                      varchar(8)        = '.HTML'				-- default provided from DB constraint - OK to override
		,@fileTypeSID                      int               = null						-- no default provided from DB constraint - OK to override
		,@recipientList                    xml               = CONVERT(xml,N'<Recipients />')						-- default provided from DB constraint - OK to override
		,@isApplicationUserRequired        bit               = (0)						-- default provided from DB constraint - OK to override
		,@applicationUserSID               int               = null						-- no default provided from DB constraint - OK to override
		,@messageLinkSID                   int               = null						-- no default provided from DB constraint - OK to override
		,@linkExpiryHours                  int               = (24)						-- default provided from DB constraint - OK to override
		,@applicationEntitySID             int               = null						-- no default provided from DB constraint - OK to override
		,@applicationGrantSID              int               = null						-- no default provided from DB constraint - OK to override
		,@isGenerateOnly                   bit               = CONVERT(bit,(0))													-- default provided from DB constraint - OK to override
		,@mergedTime                       datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@queuedTime                       datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@cancelledTime                    datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@archivedTime                     datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@purgedTime                       datetimeoffset(7) = null						-- no default provided from DB constraint - OK to override
		,@userDefinedColumns               xml               = null						-- no default provided from DB constraint - OK to override
		,@emailMessageXID                  varchar(150)      = null						-- no default provided from DB constraint - OK to override
		,@legacyKey                        nvarchar(50)      = null						-- no default provided from DB constraint - OK to override
		,@isDeleted                        bit               = (0)						-- default provided from DB constraint - OK to override
		,@createUser                       nvarchar(75)      = suser_sname()	-- default value ignored (value set by UI)
		,@createTime                       datetimeoffset(7) = sysdatetimeoffset()											-- default value ignored (set to system time)
		,@updateUser                       nvarchar(75)      = suser_sname()	-- default value ignored (value set by UI)
		,@updateTime                       datetimeoffset(7) = sysdatetimeoffset()											-- default value ignored (set to system time)
		,@rowGUID                          uniqueidentifier  = newid()				-- default value ignored (value set by system)
		,@rowStamp                         timestamp         = null						-- default value ignored (value set by system)
		,@fileTypeFileTypeSCD              varchar(8)        = '?'						-- not a base table column (default ignored)
		,@fileTypeLabel                    nvarchar(35)      = N'?'						-- not a base table column (default ignored)
		,@mimeType                         varchar(255)      = '?'						-- not a base table column (default ignored)
		,@isInline                         bit               = 0							-- not a base table column (default ignored)
		,@fileTypeIsActive                 bit               = 0							-- not a base table column (default ignored)
		,@fileTypeRowGUID                  uniqueidentifier  = newid()				-- not a base table column (default ignored)
		,@messageLinkSCD                   varchar(30)												-- not a base table column (default ignored)
		,@messageLinkLabel                 nvarchar(35)												-- not a base table column (default ignored)
		,@applicationPageSID               int																-- not a base table column (default ignored)
		,@messageLinkRowGUID               uniqueidentifier										-- not a base table column (default ignored)
		,@applicationEntitySCD             varchar(50)												-- not a base table column (default ignored)
		,@applicationEntityName            nvarchar(50)												-- not a base table column (default ignored)
		,@isMergeDataSource                bit																-- not a base table column (default ignored)
		,@applicationEntityRowGUID         uniqueidentifier										-- not a base table column (default ignored)
		,@applicationGrantSCD              varchar(30)												-- not a base table column (default ignored)
		,@applicationGrantName             nvarchar(150)											-- not a base table column (default ignored)
		,@applicationGrantIsDefault        bit																-- not a base table column (default ignored)
		,@applicationGrantRowGUID          uniqueidentifier										-- not a base table column (default ignored)
		,@personSID                        int																-- not a base table column (default ignored)
		,@cultureSID                       int																-- not a base table column (default ignored)
		,@authenticationAuthoritySID       int																-- not a base table column (default ignored)
		,@userName                         nvarchar(75)												-- not a base table column (default ignored)
		,@lastReviewTime                   datetimeoffset(7)									-- not a base table column (default ignored)
		,@lastReviewUser                   nvarchar(75)												-- not a base table column (default ignored)
		,@isPotentialDuplicate             bit																-- not a base table column (default ignored)
		,@isTemplate                       bit																-- not a base table column (default ignored)
		,@glassBreakPassword               varbinary(8000)										-- not a base table column (default ignored)
		,@lastGlassBreakPasswordChangeTime datetimeoffset(7)									-- not a base table column (default ignored)
		,@applicationUserIsActive          bit																-- not a base table column (default ignored)
		,@authenticationSystemID           nvarchar(50)												-- not a base table column (default ignored)
		,@applicationUserRowGUID           uniqueidentifier										-- not a base table column (default ignored)
		,@isDeleteEnabled                  bit																-- not a base table column (default ignored)
		,@isReselected                     tinyint           = 1							-- specific default required by EF - do not override
		,@isNullApplied                    bit               = 1							-- specific default required by EF - do not override
		,@linkURI                          varchar(150)												-- not a base table column (default ignored)
		,@messageStatusSCD                 varchar(10)												-- not a base table column (default ignored)
		,@messageStatusLabel               nvarchar(35)												-- not a base table column (default ignored)
		,@recipientCount                   int																-- not a base table column (default ignored)
		,@notReceivedCount                 int																-- not a base table column (default ignored)
		,@isQueued                         bit               = 0							-- not a base table column (default ignored)
		,@isSent                           bit               = 0							-- not a base table column (default ignored)
		,@isCancelled                      bit               = 0							-- not a base table column (default ignored)
		,@isCancelEnabled                  bit               = 0							-- not a base table column (default ignored)
		,@isArchived                       bit               = 0							-- not a base table column (default ignored)
		,@isPurged                         bit               = 0							-- not a base table column (default ignored)
		,@sentTime                         datetimeoffset(7)									-- not a base table column (default ignored)
		,@sentTimeLast                     datetimeoffset(7)									-- not a base table column (default ignored)
		,@sentCount                        int																-- not a base table column (default ignored)
		,@notSentCount                     int																-- not a base table column (default ignored)
		,@isEditEnabled                    bit               = 0							-- not a base table column (default ignored)
		,@isLinkEmbedded                   bit               = 0							-- not a base table column (default ignored)
		,@queuingTime                      datetimeoffset(7)									-- not a base table column (default ignored)
		,@recipientPersonSID               int																-- not a base table column (default ignored)

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
		-- set mandatory FK values to -1 where requested
		
		if @SetFKDefaults = @ON
		begin
			set @fileTypeSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @senderEmailAddress         = isnull(context.node.value('@SenderEmailAddress'       ,'varchar(150)'     ),@senderEmailAddress)
			,@senderDisplayName          = isnull(context.node.value('@SenderDisplayName'        ,'nvarchar(75)'     ),@senderDisplayName)
			,@priorityLevel              = isnull(context.node.value('@PriorityLevel'            ,'tinyint'          ),@priorityLevel)
			,@subject                    = isnull(context.node.value('@Subject'                  ,'nvarchar(120)'    ),@subject)
			,@body                       = isnull(context.node.value('@Body'                     ,'varbinary(max)'   ),@body)
			,@fileTypeSCD                = isnull(context.node.value('@FileTypeSCD'              ,'varchar(8)'       ),@fileTypeSCD)
			,@fileTypeSID                = isnull(context.node.value('@FileTypeSID'              ,'int'              ),@fileTypeSID)
			,@isApplicationUserRequired  = isnull(context.node.value('@IsApplicationUserRequired','bit'              ),@isApplicationUserRequired)
			,@applicationUserSID         = isnull(context.node.value('@ApplicationUserSID'       ,'int'              ),@applicationUserSID)
			,@messageLinkSID             = isnull(context.node.value('@MessageLinkSID'           ,'int'              ),@messageLinkSID)
			,@linkExpiryHours            = isnull(context.node.value('@LinkExpiryHours'          ,'int'              ),@linkExpiryHours)
			,@applicationEntitySID       = isnull(context.node.value('@ApplicationEntitySID'     ,'int'              ),@applicationEntitySID)
			,@applicationGrantSID        = isnull(context.node.value('@ApplicationGrantSID'      ,'int'              ),@applicationGrantSID)
			,@isGenerateOnly             = isnull(context.node.value('@IsGenerateOnly'           ,'bit'              ),@isGenerateOnly)
			,@mergedTime                 = isnull(context.node.value('@MergedTime'               ,'datetimeoffset(7)'),@mergedTime)
			,@queuedTime                 = isnull(context.node.value('@QueuedTime'               ,'datetimeoffset(7)'),@queuedTime)
			,@cancelledTime              = isnull(context.node.value('@CancelledTime'            ,'datetimeoffset(7)'),@cancelledTime)
			,@archivedTime               = isnull(context.node.value('@ArchivedTime'             ,'datetimeoffset(7)'),@archivedTime)
			,@purgedTime                 = isnull(context.node.value('@PurgedTime'               ,'datetimeoffset(7)'),@purgedTime)
			,@emailMessageXID            = isnull(context.node.value('@EmailMessageXID'          ,'varchar(150)'     ),@emailMessageXID)
			,@legacyKey                  = isnull(context.node.value('@LegacyKey'                ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		
		-- set default value on foreign keys where configured
		-- and where no DB or literal value was passed for it
		
		if isnull(@applicationGrantSID,0) = 0 select @applicationGrantSID = x.ApplicationGrantSID from sf.ApplicationGrant  x where x.IsDefault = @ON

		--! <Overrides>
		-- Tim Edlund | April 2015
		-- Where an email template is specified, copy across default
		-- values from it.

		select
			 @priorityLevel						= isnull(et.PriorityLevel						, @priorityLevel						)
			,@subject									= isnull(et.[Subject]								, @subject									)
			,@body										= isnull(et.Body										, @body											)
		from
			sf.EmailTemplate et
		join
		(
			select
				context.node.value('@EmailTemplateSID','int') EmailTemplateSID
			from
				@zContext.nodes('Parameters') as context(node)
		) x on et.EmailTemplateSID = x.EmailTemplateSID

		-- Tim Edlund | April 2015
		-- The sending email defaults to the value defined in the Email Sender
		-- table as the default.

		select
			 @senderEmailAddress	= es.SenderEmailAddress
			,@senderDisplayName		= es.SenderDisplayName
		from
			sf.EmailSender es
		where
			es.IsDefault = @ON
		--! </Overrides>

		select
			 @emailMessageSID EmailMessageSID
			,@senderEmailAddress SenderEmailAddress
			,@senderDisplayName SenderDisplayName
			,@priorityLevel PriorityLevel
			,@subject Subject
			,@body Body
			,@fileTypeSCD FileTypeSCD
			,@fileTypeSID FileTypeSID
			,@recipientList RecipientList
			,@isApplicationUserRequired IsApplicationUserRequired
			,@applicationUserSID ApplicationUserSID
			,@messageLinkSID MessageLinkSID
			,@linkExpiryHours LinkExpiryHours
			,@applicationEntitySID ApplicationEntitySID
			,@applicationGrantSID ApplicationGrantSID
			,@isGenerateOnly IsGenerateOnly
			,@mergedTime MergedTime
			,@queuedTime QueuedTime
			,@cancelledTime CancelledTime
			,@archivedTime ArchivedTime
			,@purgedTime PurgedTime
			,@userDefinedColumns UserDefinedColumns
			,@emailMessageXID EmailMessageXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@fileTypeFileTypeSCD FileTypeFileTypeSCD
			,@fileTypeLabel FileTypeLabel
			,@mimeType MimeType
			,@isInline IsInline
			,@fileTypeIsActive FileTypeIsActive
			,@fileTypeRowGUID FileTypeRowGUID
			,@messageLinkSCD MessageLinkSCD
			,@messageLinkLabel MessageLinkLabel
			,@applicationPageSID ApplicationPageSID
			,@messageLinkRowGUID MessageLinkRowGUID
			,@applicationEntitySCD ApplicationEntitySCD
			,@applicationEntityName ApplicationEntityName
			,@isMergeDataSource IsMergeDataSource
			,@applicationEntityRowGUID ApplicationEntityRowGUID
			,@applicationGrantSCD ApplicationGrantSCD
			,@applicationGrantName ApplicationGrantName
			,@applicationGrantIsDefault ApplicationGrantIsDefault
			,@applicationGrantRowGUID ApplicationGrantRowGUID
			,@personSID PersonSID
			,@cultureSID CultureSID
			,@authenticationAuthoritySID AuthenticationAuthoritySID
			,@userName UserName
			,@lastReviewTime LastReviewTime
			,@lastReviewUser LastReviewUser
			,@isPotentialDuplicate IsPotentialDuplicate
			,@isTemplate IsTemplate
			,@glassBreakPassword GlassBreakPassword
			,@lastGlassBreakPasswordChangeTime LastGlassBreakPasswordChangeTime
			,@applicationUserIsActive ApplicationUserIsActive
			,@authenticationSystemID AuthenticationSystemID
			,@applicationUserRowGUID ApplicationUserRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@linkURI LinkURI
			,@messageStatusSCD MessageStatusSCD
			,@messageStatusLabel MessageStatusLabel
			,@recipientCount RecipientCount
			,@notReceivedCount NotReceivedCount
			,@isQueued IsQueued
			,@isSent IsSent
			,@isCancelled IsCancelled
			,@isCancelEnabled IsCancelEnabled
			,@isArchived IsArchived
			,@isPurged IsPurged
			,@sentTime SentTime
			,@sentTimeLast SentTimeLast
			,@sentCount SentCount
			,@notSentCount NotSentCount
			,@isEditEnabled IsEditEnabled
			,@isLinkEmbedded IsLinkEmbedded
			,@queuingTime QueuingTime
			,@recipientPersonSID RecipientPersonSID

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
