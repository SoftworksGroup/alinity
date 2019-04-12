SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#EFInsert]
	 @SenderEmailAddress               varchar(150)      = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pEmailMessage#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pEmailMessage#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pEmailMessage#Insert
			 @SenderEmailAddress               = @SenderEmailAddress
			,@SenderDisplayName                = @SenderDisplayName
			,@PriorityLevel                    = @PriorityLevel
			,@Subject                          = @Subject
			,@Body                             = @Body
			,@FileTypeSCD                      = @FileTypeSCD
			,@FileTypeSID                      = @FileTypeSID
			,@RecipientList                    = @RecipientList
			,@IsApplicationUserRequired        = @IsApplicationUserRequired
			,@ApplicationUserSID               = @ApplicationUserSID
			,@MessageLinkSID                   = @MessageLinkSID
			,@LinkExpiryHours                  = @LinkExpiryHours
			,@ApplicationEntitySID             = @ApplicationEntitySID
			,@ApplicationGrantSID              = @ApplicationGrantSID
			,@IsGenerateOnly                   = @IsGenerateOnly
			,@MergedTime                       = @MergedTime
			,@QueuedTime                       = @QueuedTime
			,@CancelledTime                    = @CancelledTime
			,@ArchivedTime                     = @ArchivedTime
			,@PurgedTime                       = @PurgedTime
			,@UserDefinedColumns               = @UserDefinedColumns
			,@EmailMessageXID                  = @EmailMessageXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@FileTypeFileTypeSCD              = @FileTypeFileTypeSCD
			,@FileTypeLabel                    = @FileTypeLabel
			,@MimeType                         = @MimeType
			,@IsInline                         = @IsInline
			,@FileTypeIsActive                 = @FileTypeIsActive
			,@FileTypeRowGUID                  = @FileTypeRowGUID
			,@MessageLinkSCD                   = @MessageLinkSCD
			,@MessageLinkLabel                 = @MessageLinkLabel
			,@ApplicationPageSID               = @ApplicationPageSID
			,@MessageLinkRowGUID               = @MessageLinkRowGUID
			,@ApplicationEntitySCD             = @ApplicationEntitySCD
			,@ApplicationEntityName            = @ApplicationEntityName
			,@IsMergeDataSource                = @IsMergeDataSource
			,@ApplicationEntityRowGUID         = @ApplicationEntityRowGUID
			,@ApplicationGrantSCD              = @ApplicationGrantSCD
			,@ApplicationGrantName             = @ApplicationGrantName
			,@ApplicationGrantIsDefault        = @ApplicationGrantIsDefault
			,@ApplicationGrantRowGUID          = @ApplicationGrantRowGUID
			,@PersonSID                        = @PersonSID
			,@CultureSID                       = @CultureSID
			,@AuthenticationAuthoritySID       = @AuthenticationAuthoritySID
			,@UserName                         = @UserName
			,@LastReviewTime                   = @LastReviewTime
			,@LastReviewUser                   = @LastReviewUser
			,@IsPotentialDuplicate             = @IsPotentialDuplicate
			,@IsTemplate                       = @IsTemplate
			,@GlassBreakPassword               = @GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime = @LastGlassBreakPasswordChangeTime
			,@ApplicationUserIsActive          = @ApplicationUserIsActive
			,@AuthenticationSystemID           = @AuthenticationSystemID
			,@ApplicationUserRowGUID           = @ApplicationUserRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@LinkURI                          = @LinkURI
			,@MessageStatusSCD                 = @MessageStatusSCD
			,@MessageStatusLabel               = @MessageStatusLabel
			,@RecipientCount                   = @RecipientCount
			,@NotReceivedCount                 = @NotReceivedCount
			,@IsQueued                         = @IsQueued
			,@IsSent                           = @IsSent
			,@IsCancelled                      = @IsCancelled
			,@IsCancelEnabled                  = @IsCancelEnabled
			,@IsArchived                       = @IsArchived
			,@IsPurged                         = @IsPurged
			,@SentTime                         = @SentTime
			,@SentTimeLast                     = @SentTimeLast
			,@SentCount                        = @SentCount
			,@NotSentCount                     = @NotSentCount
			,@IsEditEnabled                    = @IsEditEnabled
			,@IsLinkEmbedded                   = @IsLinkEmbedded
			,@QueuingTime                      = @QueuingTime
			,@RecipientPersonSID               = @RecipientPersonSID

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
