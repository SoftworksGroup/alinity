SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pRecordAudit#Default]
	 @zContext                       xml               = null                -- default values provided from client-tier (if any)
	,@SetFKDefaults                  bit               = 0                   -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : sf.pRecordAudit#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" sf.RecordAudit records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.RecordAudit table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vRecordAudit entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pRecordAudit
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pRecordAudit of the context of the call. All other parameters are also passed, however, only those parameters eligible
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
		,@recordAuditSID                 int               = -1								-- specific default required by EF - do not override
		,@applicationUserSessionSID      int               = null							-- no default provided from DB constraint - OK to override
		,@applicationPageSID             int               = null							-- no default provided from DB constraint - OK to override
		,@auditActionSID                 int               = null							-- no default provided from DB constraint - OK to override
		,@isGlassBreak                   bit               = (0)							-- default provided from DB constraint - OK to override
		,@contextGUID                    uniqueidentifier  = null							-- no default provided from DB constraint - OK to override
		,@userDefinedColumns             xml               = null							-- no default provided from DB constraint - OK to override
		,@recordAuditXID                 varchar(150)      = null							-- no default provided from DB constraint - OK to override
		,@legacyKey                      nvarchar(50)      = null							-- no default provided from DB constraint - OK to override
		,@isDeleted                      bit               = (0)							-- default provided from DB constraint - OK to override
		,@createUser                     nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@createTime                     datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@updateUser                     nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@updateTime                     datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@rowGUID                        uniqueidentifier  = newid()					-- default value ignored (value set by system)
		,@rowStamp                       timestamp         = null							-- default value ignored (value set by system)
		,@applicationPageLabel           nvarchar(35)      = N'?'							-- not a base table column (default ignored)
		,@applicationPageURI             varchar(150)      = '?'							-- not a base table column (default ignored)
		,@applicationRoute               varchar(150)      = '?'							-- not a base table column (default ignored)
		,@isSearchPage                   bit               = 0								-- not a base table column (default ignored)
		,@applicationEntitySID           int               = 0								-- not a base table column (default ignored)
		,@applicationPageRowGUID         uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@applicationUserSID             int               = 0								-- not a base table column (default ignored)
		,@applicationUserSessionIsActive bit               = 0								-- not a base table column (default ignored)
		,@iPAddress                      varchar(45)       = '?'							-- not a base table column (default ignored)
		,@applicationUserSessionRowGUID  uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@auditActionSCD                 varchar(25)       = '?'							-- not a base table column (default ignored)
		,@auditActionName                nvarchar(50)      = N'?'							-- not a base table column (default ignored)
		,@auditActionIsDefault           bit               = 0								-- not a base table column (default ignored)
		,@auditActionRowGUID             uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@isDeleteEnabled                bit																	-- not a base table column (default ignored)
		,@isReselected                   tinyint           = 1								-- specific default required by EF - do not override
		,@isNullApplied                  bit               = 1								-- specific default required by EF - do not override
		,@personSID                      int               = 0								-- not a base table column (default ignored)
		,@userName                       nvarchar(75)      = N'?'							-- not a base table column (default ignored)
		,@lastReviewTime                 datetimeoffset(7) = sysdatetimeoffset()												-- not a base table column (default ignored)
		,@lastReviewUser                 nvarchar(75)      = N'?'							-- not a base table column (default ignored)
		,@applicationEntitySCD           varchar(50)       = '?'							-- not a base table column (default ignored)
		,@auditTimeClientTZ              varchar(19)													-- not a base table column (default ignored)

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
			set @applicationUserSessionSID = -1
			set @applicationPageSID = -1
			set @auditActionSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @applicationUserSessionSID  = isnull(context.node.value('@ApplicationUserSessionSID','int'             ),@applicationUserSessionSID)
			,@applicationPageSID         = isnull(context.node.value('@ApplicationPageSID'       ,'int'             ),@applicationPageSID)
			,@auditActionSID             = isnull(context.node.value('@AuditActionSID'           ,'int'             ),@auditActionSID)
			,@isGlassBreak               = isnull(context.node.value('@IsGlassBreak'             ,'bit'             ),@isGlassBreak)
			,@contextGUID                = isnull(context.node.value('@ContextGUID'              ,'uniqueidentifier'),@contextGUID)
			,@recordAuditXID             = isnull(context.node.value('@RecordAuditXID'           ,'varchar(150)'    ),@recordAuditXID)
			,@legacyKey                  = isnull(context.node.value('@LegacyKey'                ,'nvarchar(50)'    ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		
		-- set default value on foreign keys where configured
		-- and where no DB or literal value was passed for it
		
		if isnull(@auditActionSID,0) = 0 select @auditActionSID = x.AuditActionSID from sf.AuditAction  x where x.IsDefault = @ON

    --! <Overrides>
    -- Tim Edlund | Nov 2012
    -- Set FK values to -1 if not already defaulted.  When these values pass through
    -- to the #insert sproc, the final values are looked up based on the page URI.

    if @auditActionSID				is null set @auditActionSID				= -1
		if @applicationPageSID		is null set @applicationPageSID   = -1
    if @applicationEntitySID	is null set @applicationEntitySID = -1
    if @applicationUserSID		is null set @applicationUserSID = sf.fApplicationUserSessionUserSID()	-- current user
    --! </Overrides>

		select
			 @recordAuditSID RecordAuditSID
			,@applicationUserSessionSID ApplicationUserSessionSID
			,@applicationPageSID ApplicationPageSID
			,@auditActionSID AuditActionSID
			,@isGlassBreak IsGlassBreak
			,@contextGUID ContextGUID
			,@userDefinedColumns UserDefinedColumns
			,@recordAuditXID RecordAuditXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@applicationPageLabel ApplicationPageLabel
			,@applicationPageURI ApplicationPageURI
			,@applicationRoute ApplicationRoute
			,@isSearchPage IsSearchPage
			,@applicationEntitySID ApplicationEntitySID
			,@applicationPageRowGUID ApplicationPageRowGUID
			,@applicationUserSID ApplicationUserSID
			,@applicationUserSessionIsActive ApplicationUserSessionIsActive
			,@iPAddress IPAddress
			,@applicationUserSessionRowGUID ApplicationUserSessionRowGUID
			,@auditActionSCD AuditActionSCD
			,@auditActionName AuditActionName
			,@auditActionIsDefault AuditActionIsDefault
			,@auditActionRowGUID AuditActionRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@personSID PersonSID
			,@userName UserName
			,@lastReviewTime LastReviewTime
			,@lastReviewUser LastReviewUser
			,@applicationEntitySCD ApplicationEntitySCD
			,@auditTimeClientTZ AuditTimeClientTZ

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
