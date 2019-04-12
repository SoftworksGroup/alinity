SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDoc#Default]
	 @zContext                  xml               = null                           -- default values provided from client-tier (if any)
	,@SetFKDefaults             bit               = 0                              -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonDoc#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.PersonDoc records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PersonDoc table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vPersonDoc entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pPersonDoc
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pPersonDoc of the context of the call. All other parameters are also passed, however, only those parameters eligible
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
		,@ON                        bit = cast(1 as bit)											-- constant for bit comparisons
		,@OFF                       bit = cast(0 as bit)											-- constant for bit comparisons
		,@personDocSID              int               = -1										-- specific default required by EF - do not override
		,@personSID                 int               = null									-- no default provided from DB constraint - OK to override
		,@personDocTypeSID          int               = null									-- no default provided from DB constraint - OK to override
		,@documentTitle             nvarchar(100)     = null									-- no default provided from DB constraint - OK to override
		,@additionalInfo            nvarchar(50)      = null									-- no default provided from DB constraint - OK to override
		,@documentContent           varbinary(max)    = null									-- no default provided from DB constraint - OK to override
		,@documentHTML              nvarchar(max)     = null									-- no default provided from DB constraint - OK to override
		,@archivedTime              datetimeoffset(7) = null									-- no default provided from DB constraint - OK to override
		,@fileTypeSID               int               = null									-- no default provided from DB constraint - OK to override
		,@fileTypeSCD               varchar(8)        = null									-- no default provided from DB constraint - OK to override
		,@tagList                   xml               = CONVERT(xml,N'<TagList/>',(0))									-- default provided from DB constraint - OK to override
		,@documentNotes             nvarchar(max)     = null									-- no default provided from DB constraint - OK to override
		,@showToRegistrant          bit               = CONVERT(bit,(0))			-- default provided from DB constraint - OK to override
		,@applicationGrantSID       int               = null									-- no default provided from DB constraint - OK to override
		,@isRemoved                 bit               = CONVERT(bit,(0))			-- default provided from DB constraint - OK to override
		,@expiryDate                date              = null									-- no default provided from DB constraint - OK to override
		,@applicationReportSID      int               = null									-- no default provided from DB constraint - OK to override
		,@reportEntitySID           int               = null									-- no default provided from DB constraint - OK to override
		,@cancelledTime             datetimeoffset(7) = null									-- no default provided from DB constraint - OK to override
		,@processedTime             datetimeoffset(7) = null									-- no default provided from DB constraint - OK to override
		,@contextLink               uniqueidentifier  = null									-- no default provided from DB constraint - OK to override
		,@userDefinedColumns        xml               = null									-- no default provided from DB constraint - OK to override
		,@personDocXID              varchar(150)      = null									-- no default provided from DB constraint - OK to override
		,@legacyKey                 nvarchar(50)      = null									-- no default provided from DB constraint - OK to override
		,@isDeleted                 bit               = (0)										-- default provided from DB constraint - OK to override
		,@createUser                nvarchar(75)      = suser_sname()					-- default value ignored (value set by UI)
		,@createTime                datetimeoffset(7) = sysdatetimeoffset()		-- default value ignored (set to system time)
		,@updateUser                nvarchar(75)      = suser_sname()					-- default value ignored (value set by UI)
		,@updateTime                datetimeoffset(7) = sysdatetimeoffset()		-- default value ignored (set to system time)
		,@rowGUID                   uniqueidentifier  = newid()								-- default value ignored (value set by system)
		,@rowStamp                  timestamp         = null									-- default value ignored (value set by system)
		,@personDocTypeSCD          varchar(15)       = '?'										-- not a base table column (default ignored)
		,@personDocTypeLabel        nvarchar(35)      = N'?'									-- not a base table column (default ignored)
		,@personDocTypeCategory     nvarchar(65)															-- not a base table column (default ignored)
		,@personDocTypeIsDefault    bit               = 0											-- not a base table column (default ignored)
		,@personDocTypeIsActive     bit               = 0											-- not a base table column (default ignored)
		,@personDocTypeRowGUID      uniqueidentifier  = newid()								-- not a base table column (default ignored)
		,@fileTypeFileTypeSCD       varchar(8)        = '?'										-- not a base table column (default ignored)
		,@fileTypeLabel             nvarchar(35)      = N'?'									-- not a base table column (default ignored)
		,@mimeType                  varchar(255)      = '?'										-- not a base table column (default ignored)
		,@isInline                  bit               = 0											-- not a base table column (default ignored)
		,@fileTypeIsActive          bit               = 0											-- not a base table column (default ignored)
		,@fileTypeRowGUID           uniqueidentifier  = newid()								-- not a base table column (default ignored)
		,@genderSID                 int               = 0											-- not a base table column (default ignored)
		,@namePrefixSID             int																				-- not a base table column (default ignored)
		,@firstName                 nvarchar(30)      = N'?'									-- not a base table column (default ignored)
		,@commonName                nvarchar(30)															-- not a base table column (default ignored)
		,@middleNames               nvarchar(30)															-- not a base table column (default ignored)
		,@lastName                  nvarchar(35)      = N'?'									-- not a base table column (default ignored)
		,@birthDate                 date																			-- not a base table column (default ignored)
		,@deathDate                 date																			-- not a base table column (default ignored)
		,@homePhone                 varchar(25)																-- not a base table column (default ignored)
		,@mobilePhone               varchar(25)																-- not a base table column (default ignored)
		,@isTextMessagingEnabled    bit               = 0											-- not a base table column (default ignored)
		,@importBatch               nvarchar(100)															-- not a base table column (default ignored)
		,@personRowGUID             uniqueidentifier  = newid()								-- not a base table column (default ignored)
		,@applicationGrantSCD       varchar(30)																-- not a base table column (default ignored)
		,@applicationGrantName      nvarchar(150)															-- not a base table column (default ignored)
		,@applicationGrantIsDefault bit																				-- not a base table column (default ignored)
		,@applicationGrantRowGUID   uniqueidentifier													-- not a base table column (default ignored)
		,@applicationReportName     nvarchar(65)															-- not a base table column (default ignored)
		,@iconFillColor             char(9)																		-- not a base table column (default ignored)
		,@displayRank               tinyint																		-- not a base table column (default ignored)
		,@isCustom                  bit																				-- not a base table column (default ignored)
		,@applicationReportRowGUID  uniqueidentifier													-- not a base table column (default ignored)
		,@isDeleteEnabled           bit																				-- not a base table column (default ignored)
		,@isReselected              tinyint           = 1											-- specific default required by EF - do not override
		,@isNullApplied             bit               = 1											-- specific default required by EF - do not override
		,@isDocReplaced             bit																				-- not a base table column (default ignored)
		,@isReadGranted             bit																				-- not a base table column (default ignored)
		,@isReportPending           bit																				-- not a base table column (default ignored)
		,@isReportCancelled         bit																				-- not a base table column (default ignored)
		,@applicationEntitySID      int																				-- not a base table column (default ignored)
		,@entitySID                 int																				-- not a base table column (default ignored)
		,@isPrimary                 bit																				-- not a base table column (default ignored)

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
			set @personSID = -1
			set @personDocTypeSID = -1
			set @fileTypeSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @personSID             = isnull(context.node.value('@PersonSID'           ,'int'              ),@personSID)
			,@personDocTypeSID      = isnull(context.node.value('@PersonDocTypeSID'    ,'int'              ),@personDocTypeSID)
			,@documentTitle         = isnull(context.node.value('@DocumentTitle'       ,'nvarchar(100)'    ),@documentTitle)
			,@additionalInfo        = isnull(context.node.value('@AdditionalInfo'      ,'nvarchar(50)'     ),@additionalInfo)
			,@documentContent       = isnull(context.node.value('@DocumentContent'     ,'varbinary(max)'   ),@documentContent)
			,@documentHTML          = isnull(context.node.value('@DocumentHTML'        ,'nvarchar(max)'    ),@documentHTML)
			,@archivedTime          = isnull(context.node.value('@ArchivedTime'        ,'datetimeoffset(7)'),@archivedTime)
			,@fileTypeSID           = isnull(context.node.value('@FileTypeSID'         ,'int'              ),@fileTypeSID)
			,@fileTypeSCD           = isnull(context.node.value('@FileTypeSCD'         ,'varchar(8)'       ),@fileTypeSCD)
			,@documentNotes         = isnull(context.node.value('@DocumentNotes'       ,'nvarchar(max)'    ),@documentNotes)
			,@showToRegistrant      = isnull(context.node.value('@ShowToRegistrant'    ,'bit'              ),@showToRegistrant)
			,@applicationGrantSID   = isnull(context.node.value('@ApplicationGrantSID' ,'int'              ),@applicationGrantSID)
			,@isRemoved             = isnull(context.node.value('@IsRemoved'           ,'bit'              ),@isRemoved)
			,@expiryDate            = isnull(context.node.value('@ExpiryDate'          ,'date'             ),@expiryDate)
			,@applicationReportSID  = isnull(context.node.value('@ApplicationReportSID','int'              ),@applicationReportSID)
			,@reportEntitySID       = isnull(context.node.value('@ReportEntitySID'     ,'int'              ),@reportEntitySID)
			,@cancelledTime         = isnull(context.node.value('@CancelledTime'       ,'datetimeoffset(7)'),@cancelledTime)
			,@processedTime         = isnull(context.node.value('@ProcessedTime'       ,'datetimeoffset(7)'),@processedTime)
			,@contextLink           = isnull(context.node.value('@ContextLink'         ,'uniqueidentifier' ),@contextLink)
			,@personDocXID          = isnull(context.node.value('@PersonDocXID'        ,'varchar(150)'     ),@personDocXID)
			,@legacyKey             = isnull(context.node.value('@LegacyKey'           ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		
		-- set default value on foreign keys where configured
		-- and where no DB or literal value was passed for it
		
		if isnull(@personDocTypeSID   ,0) = 0 select @personDocTypeSID    = x.PersonDocTypeSID    from dbo.PersonDocType    x where x.IsDefault = @ON
		if isnull(@applicationGrantSID,0) = 0 select @applicationGrantSID = x.ApplicationGrantSID from sf.ApplicationGrant  x where x.IsDefault = @ON

		--! <Overrides>
		-- Christian T | Mar 2015
		-- Defaults assigned to mandatory text columns to avoid EF error.
		set @fileTypeSCD = '?'
		--! </Overrides>
	
		-- call the extended version of the procedure (if it exists) for "default.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pPersonDoc'
		)
		begin
		
			exec @errorNo = ext.pPersonDoc
				 @Mode                      = 'default.pre'
				,@PersonDocSID = @personDocSID
				,@PersonSID = @personSID output
				,@PersonDocTypeSID = @personDocTypeSID output
				,@DocumentTitle = @documentTitle output
				,@AdditionalInfo = @additionalInfo output
				,@DocumentContent = @documentContent output
				,@DocumentHTML = @documentHTML output
				,@ArchivedTime = @archivedTime output
				,@FileTypeSID = @fileTypeSID output
				,@FileTypeSCD = @fileTypeSCD output
				,@TagList = @tagList output
				,@DocumentNotes = @documentNotes output
				,@ShowToRegistrant = @showToRegistrant output
				,@ApplicationGrantSID = @applicationGrantSID output
				,@IsRemoved = @isRemoved output
				,@ExpiryDate = @expiryDate output
				,@ApplicationReportSID = @applicationReportSID output
				,@ReportEntitySID = @reportEntitySID output
				,@CancelledTime = @cancelledTime output
				,@ProcessedTime = @processedTime output
				,@ContextLink = @contextLink output
				,@UserDefinedColumns = @userDefinedColumns output
				,@PersonDocXID = @personDocXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@PersonDocTypeSCD = @personDocTypeSCD
				,@PersonDocTypeLabel = @personDocTypeLabel
				,@PersonDocTypeCategory = @personDocTypeCategory
				,@PersonDocTypeIsDefault = @personDocTypeIsDefault
				,@PersonDocTypeIsActive = @personDocTypeIsActive
				,@PersonDocTypeRowGUID = @personDocTypeRowGUID
				,@FileTypeFileTypeSCD = @fileTypeFileTypeSCD
				,@FileTypeLabel = @fileTypeLabel
				,@MimeType = @mimeType
				,@IsInline = @isInline
				,@FileTypeIsActive = @fileTypeIsActive
				,@FileTypeRowGUID = @fileTypeRowGUID
				,@GenderSID = @genderSID
				,@NamePrefixSID = @namePrefixSID
				,@FirstName = @firstName
				,@CommonName = @commonName
				,@MiddleNames = @middleNames
				,@LastName = @lastName
				,@BirthDate = @birthDate
				,@DeathDate = @deathDate
				,@HomePhone = @homePhone
				,@MobilePhone = @mobilePhone
				,@IsTextMessagingEnabled = @isTextMessagingEnabled
				,@ImportBatch = @importBatch
				,@PersonRowGUID = @personRowGUID
				,@ApplicationGrantSCD = @applicationGrantSCD
				,@ApplicationGrantName = @applicationGrantName
				,@ApplicationGrantIsDefault = @applicationGrantIsDefault
				,@ApplicationGrantRowGUID = @applicationGrantRowGUID
				,@ApplicationReportName = @applicationReportName
				,@IconFillColor = @iconFillColor
				,@DisplayRank = @displayRank
				,@IsCustom = @isCustom
				,@ApplicationReportRowGUID = @applicationReportRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
				,@IsDocReplaced = @isDocReplaced
				,@IsReadGranted = @isReadGranted
				,@IsReportPending = @isReportPending
				,@IsReportCancelled = @isReportCancelled
				,@ApplicationEntitySID = @applicationEntitySID
				,@EntitySID = @entitySID
				,@IsPrimary = @isPrimary
		
		end

		select
			 @personDocSID PersonDocSID
			,@personSID PersonSID
			,@personDocTypeSID PersonDocTypeSID
			,@documentTitle DocumentTitle
			,@additionalInfo AdditionalInfo
			,@documentContent DocumentContent
			,@documentHTML DocumentHTML
			,@archivedTime ArchivedTime
			,@fileTypeSID FileTypeSID
			,@fileTypeSCD FileTypeSCD
			,@tagList TagList
			,@documentNotes DocumentNotes
			,@showToRegistrant ShowToRegistrant
			,@applicationGrantSID ApplicationGrantSID
			,@isRemoved IsRemoved
			,@expiryDate ExpiryDate
			,@applicationReportSID ApplicationReportSID
			,@reportEntitySID ReportEntitySID
			,@cancelledTime CancelledTime
			,@processedTime ProcessedTime
			,@contextLink ContextLink
			,@userDefinedColumns UserDefinedColumns
			,@personDocXID PersonDocXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@personDocTypeSCD PersonDocTypeSCD
			,@personDocTypeLabel PersonDocTypeLabel
			,@personDocTypeCategory PersonDocTypeCategory
			,@personDocTypeIsDefault PersonDocTypeIsDefault
			,@personDocTypeIsActive PersonDocTypeIsActive
			,@personDocTypeRowGUID PersonDocTypeRowGUID
			,@fileTypeFileTypeSCD FileTypeFileTypeSCD
			,@fileTypeLabel FileTypeLabel
			,@mimeType MimeType
			,@isInline IsInline
			,@fileTypeIsActive FileTypeIsActive
			,@fileTypeRowGUID FileTypeRowGUID
			,@genderSID GenderSID
			,@namePrefixSID NamePrefixSID
			,@firstName FirstName
			,@commonName CommonName
			,@middleNames MiddleNames
			,@lastName LastName
			,@birthDate BirthDate
			,@deathDate DeathDate
			,@homePhone HomePhone
			,@mobilePhone MobilePhone
			,@isTextMessagingEnabled IsTextMessagingEnabled
			,@importBatch ImportBatch
			,@personRowGUID PersonRowGUID
			,@applicationGrantSCD ApplicationGrantSCD
			,@applicationGrantName ApplicationGrantName
			,@applicationGrantIsDefault ApplicationGrantIsDefault
			,@applicationGrantRowGUID ApplicationGrantRowGUID
			,@applicationReportName ApplicationReportName
			,@iconFillColor IconFillColor
			,@displayRank DisplayRank
			,@isCustom IsCustom
			,@applicationReportRowGUID ApplicationReportRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@isDocReplaced IsDocReplaced
			,@isReadGranted IsReadGranted
			,@isReportPending IsReportPending
			,@isReportCancelled IsReportCancelled
			,@applicationEntitySID ApplicationEntitySID
			,@entitySID EntitySID
			,@isPrimary IsPrimary

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