SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroupMember#Default]
	 @zContext                       xml               = null                -- default values provided from client-tier (if any)
	,@SetFKDefaults                  bit               = 0                   -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroupMember#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" sf.PersonGroupMember records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.PersonGroupMember table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vPersonGroupMember entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pPersonGroupMember
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pPersonGroupMember of the context of the call. All other parameters are also passed, however, only those parameters eligible
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
		,@ON                             bit = cast(1 as bit)									-- constant for bit comparisons
		,@OFF                            bit = cast(0 as bit)									-- constant for bit comparisons
		,@personGroupMemberSID           int               = -1								-- specific default required by EF - do not override
		,@personGroupSID                 int               = null							-- no default provided from DB constraint - OK to override
		,@personSID                      int               = null							-- no default provided from DB constraint - OK to override
		,@title                          nvarchar(75)      = null							-- no default provided from DB constraint - OK to override
		,@isAdministrator                bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@isContributor                  bit               = CONVERT(bit,(1))	-- default provided from DB constraint - OK to override
		,@effectiveTime                  datetime          = sf.fNow()				-- default provided from DB constraint - OK to override
		,@expiryTime                     datetime          = null							-- no default provided from DB constraint - OK to override
		,@isReplacementRequiredAfterTerm bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@replacementClearedDate         date              = null							-- no default provided from DB constraint - OK to override
		,@userDefinedColumns             xml               = null							-- no default provided from DB constraint - OK to override
		,@personGroupMemberXID           varchar(150)      = null							-- no default provided from DB constraint - OK to override
		,@legacyKey                      nvarchar(50)      = null							-- no default provided from DB constraint - OK to override
		,@isDeleted                      bit               = (0)							-- default provided from DB constraint - OK to override
		,@createUser                     nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@createTime                     datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@updateUser                     nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@updateTime                     datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@rowGUID                        uniqueidentifier  = newid()					-- default value ignored (value set by system)
		,@rowStamp                       timestamp         = null							-- default value ignored (value set by system)
		,@genderSID                      int               = 0								-- not a base table column (default ignored)
		,@namePrefixSID                  int																	-- not a base table column (default ignored)
		,@firstName                      nvarchar(30)      = N'?'							-- not a base table column (default ignored)
		,@commonName                     nvarchar(30)													-- not a base table column (default ignored)
		,@middleNames                    nvarchar(30)													-- not a base table column (default ignored)
		,@lastName                       nvarchar(35)      = N'?'							-- not a base table column (default ignored)
		,@birthDate                      date																	-- not a base table column (default ignored)
		,@deathDate                      date																	-- not a base table column (default ignored)
		,@homePhone                      varchar(25)													-- not a base table column (default ignored)
		,@mobilePhone                    varchar(25)													-- not a base table column (default ignored)
		,@isTextMessagingEnabled         bit               = 0								-- not a base table column (default ignored)
		,@importBatch                    nvarchar(100)												-- not a base table column (default ignored)
		,@personRowGUID                  uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@personGroupName                nvarchar(65)      = N'?'							-- not a base table column (default ignored)
		,@personGroupLabel               nvarchar(35)      = N'?'							-- not a base table column (default ignored)
		,@personGroupCategory            nvarchar(65)													-- not a base table column (default ignored)
		,@description                    nvarchar(500)												-- not a base table column (default ignored)
		,@applicationUserSID             int               = 0								-- not a base table column (default ignored)
		,@isPreference                   bit               = 0								-- not a base table column (default ignored)
		,@isDocumentLibraryEnabled       bit               = 0								-- not a base table column (default ignored)
		,@querySID                       int																	-- not a base table column (default ignored)
		,@lastReviewUser                 nvarchar(75)      = N'?'							-- not a base table column (default ignored)
		,@lastReviewTime                 datetimeoffset(7) = sysdatetimeoffset()												-- not a base table column (default ignored)
		,@smartGroupCount                int               = 0								-- not a base table column (default ignored)
		,@smartGroupCountTime            datetimeoffset(7) = sysdatetimeoffset()												-- not a base table column (default ignored)
		,@personGroupIsActive            bit               = 0								-- not a base table column (default ignored)
		,@personGroupRowGUID             uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@isActive                       bit																	-- not a base table column (default ignored)
		,@isPending                      bit																	-- not a base table column (default ignored)
		,@isDeleteEnabled                bit																	-- not a base table column (default ignored)
		,@isReselected                   tinyint           = 1								-- specific default required by EF - do not override
		,@isNullApplied                  bit               = 1								-- specific default required by EF - do not override
		,@displayName                    nvarchar(65)													-- not a base table column (default ignored)
		,@emailAddress                   varchar(150)													-- not a base table column (default ignored)
		,@phoneNumber                    varchar(25)													-- not a base table column (default ignored)
		,@isTermExpired                  bit																	-- not a base table column (default ignored)
		,@termLabel                      nvarchar(4000)												-- not a base table column (default ignored)
		,@isReplacementRequired          bit																	-- not a base table column (default ignored)

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
			set @personGroupSID = -1
			set @personSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @personGroupSID                  = isnull(context.node.value('@PersonGroupSID'                ,'int'         ),@personGroupSID)
			,@personSID                       = isnull(context.node.value('@PersonSID'                     ,'int'         ),@personSID)
			,@title                           = isnull(context.node.value('@Title'                         ,'nvarchar(75)'),@title)
			,@isAdministrator                 = isnull(context.node.value('@IsAdministrator'               ,'bit'         ),@isAdministrator)
			,@isContributor                   = isnull(context.node.value('@IsContributor'                 ,'bit'         ),@isContributor)
			,@effectiveTime                   = isnull(context.node.value('@EffectiveTime'                 ,'datetime'    ),@effectiveTime)
			,@expiryTime                      = isnull(context.node.value('@ExpiryTime'                    ,'datetime'    ),@expiryTime)
			,@isReplacementRequiredAfterTerm  = isnull(context.node.value('@IsReplacementRequiredAfterTerm','bit'         ),@isReplacementRequiredAfterTerm)
			,@replacementClearedDate          = isnull(context.node.value('@ReplacementClearedDate'        ,'date'        ),@replacementClearedDate)
			,@personGroupMemberXID            = isnull(context.node.value('@PersonGroupMemberXID'          ,'varchar(150)'),@personGroupMemberXID)
			,@legacyKey                       = isnull(context.node.value('@LegacyKey'                     ,'nvarchar(50)'),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		

		--! <Overrides>
		--  insert default value logic here ...
		--! </Overrides>

		select
			 @personGroupMemberSID PersonGroupMemberSID
			,@personGroupSID PersonGroupSID
			,@personSID PersonSID
			,@title Title
			,@isAdministrator IsAdministrator
			,@isContributor IsContributor
			,@effectiveTime EffectiveTime
			,@expiryTime ExpiryTime
			,@isReplacementRequiredAfterTerm IsReplacementRequiredAfterTerm
			,@replacementClearedDate ReplacementClearedDate
			,@userDefinedColumns UserDefinedColumns
			,@personGroupMemberXID PersonGroupMemberXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
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
			,@personGroupName PersonGroupName
			,@personGroupLabel PersonGroupLabel
			,@personGroupCategory PersonGroupCategory
			,@description Description
			,@applicationUserSID ApplicationUserSID
			,@isPreference IsPreference
			,@isDocumentLibraryEnabled IsDocumentLibraryEnabled
			,@querySID QuerySID
			,@lastReviewUser LastReviewUser
			,@lastReviewTime LastReviewTime
			,@smartGroupCount SmartGroupCount
			,@smartGroupCountTime SmartGroupCountTime
			,@personGroupIsActive PersonGroupIsActive
			,@personGroupRowGUID PersonGroupRowGUID
			,@isActive IsActive
			,@isPending IsPending
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@displayName DisplayName
			,@emailAddress EmailAddress
			,@phoneNumber PhoneNumber
			,@isTermExpired IsTermExpired
			,@termLabel TermLabel
			,@isReplacementRequired IsReplacementRequired

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
