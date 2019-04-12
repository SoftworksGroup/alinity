SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pComplaintEvent#Default]
	 @zContext                    xml               = null                               -- default values provided from client-tier (if any)
	,@SetFKDefaults               bit               = 0                                  -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pComplaintEvent#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.ComplaintEvent records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.ComplaintEvent table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vComplaintEvent entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pComplaintEvent
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pComplaintEvent of the context of the call. All other parameters are also passed, however, only those parameters eligible
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
		,@ON                          bit = cast(1 as bit)										-- constant for bit comparisons
		,@OFF                         bit = cast(0 as bit)										-- constant for bit comparisons
		,@complaintEventSID           int               = -1									-- specific default required by EF - do not override
		,@complaintSID                int               = null								-- no default provided from DB constraint - OK to override
		,@complaintEventTypeSID       int               = null								-- no default provided from DB constraint - OK to override
		,@description                 nvarchar(500)     = null								-- no default provided from DB constraint - OK to override
		,@dueDate                     date              = null								-- no default provided from DB constraint - OK to override
		,@completeTime                datetime          = null								-- no default provided from DB constraint - OK to override
		,@userDefinedColumns          xml               = null								-- no default provided from DB constraint - OK to override
		,@complaintEventXID           varchar(150)      = null								-- no default provided from DB constraint - OK to override
		,@legacyKey                   nvarchar(50)      = null								-- no default provided from DB constraint - OK to override
		,@isDeleted                   bit               = (0)									-- default provided from DB constraint - OK to override
		,@createUser                  nvarchar(75)      = suser_sname()				-- default value ignored (value set by UI)
		,@createTime                  datetimeoffset(7) = sysdatetimeoffset()	-- default value ignored (set to system time)
		,@updateUser                  nvarchar(75)      = suser_sname()				-- default value ignored (value set by UI)
		,@updateTime                  datetimeoffset(7) = sysdatetimeoffset()	-- default value ignored (set to system time)
		,@rowGUID                     uniqueidentifier  = newid()							-- default value ignored (value set by system)
		,@rowStamp                    timestamp         = null								-- default value ignored (value set by system)
		,@complaintNo                 varchar(50)       = '?'									-- not a base table column (default ignored)
		,@registrantSID               int               = 0										-- not a base table column (default ignored)
		,@complaintTypeSID            int               = 0										-- not a base table column (default ignored)
		,@complainantTypeSID          int               = 0										-- not a base table column (default ignored)
		,@applicationUserSID          int               = 0										-- not a base table column (default ignored)
		,@openedDate                  date              = convert(date, sysdatetimeoffset())						-- not a base table column (default ignored)
		,@conductStartDate            date              = convert(date, sysdatetimeoffset())						-- not a base table column (default ignored)
		,@conductEndDate              date              = convert(date, sysdatetimeoffset())						-- not a base table column (default ignored)
		,@complaintSeveritySID        int               = 0										-- not a base table column (default ignored)
		,@isDisplayedOnPublicRegistry bit               = 0										-- not a base table column (default ignored)
		,@closedDate                  date																		-- not a base table column (default ignored)
		,@dismissedDate               date																		-- not a base table column (default ignored)
		,@reasonSID                   int																			-- not a base table column (default ignored)
		,@fileExtension               varchar(5)        = '?'									-- not a base table column (default ignored)
		,@complaintRowGUID            uniqueidentifier  = newid()							-- not a base table column (default ignored)
		,@complaintEventTypeSCD       varchar(20)       = '?'									-- not a base table column (default ignored)
		,@complaintEventTypeLabel     nvarchar(35)      = N'?'								-- not a base table column (default ignored)
		,@complaintEventTypeIsDefault bit               = 0										-- not a base table column (default ignored)
		,@complaintEventTypeRowGUID   uniqueidentifier  = newid()							-- not a base table column (default ignored)
		,@isDeleteEnabled             bit																			-- not a base table column (default ignored)
		,@isReselected                tinyint           = 1										-- specific default required by EF - do not override
		,@isNullApplied               bit               = 1										-- specific default required by EF - do not override
		,@isOverdue                   bit																			-- not a base table column (default ignored)
		,@isComplete                  bit																			-- not a base table column (default ignored)

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
			set @complaintSID = -1
			set @complaintEventTypeSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @complaintSID           = isnull(context.node.value('@ComplaintSID'         ,'int'          ),@complaintSID)
			,@complaintEventTypeSID  = isnull(context.node.value('@ComplaintEventTypeSID','int'          ),@complaintEventTypeSID)
			,@description            = isnull(context.node.value('@Description'          ,'nvarchar(500)'),@description)
			,@dueDate                = isnull(context.node.value('@DueDate'              ,'date'         ),@dueDate)
			,@completeTime           = isnull(context.node.value('@CompleteTime'         ,'datetime'     ),@completeTime)
			,@complaintEventXID      = isnull(context.node.value('@ComplaintEventXID'    ,'varchar(150)' ),@complaintEventXID)
			,@legacyKey              = isnull(context.node.value('@LegacyKey'            ,'nvarchar(50)' ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		
		-- set default value on foreign keys where configured
		-- and where no DB or literal value was passed for it
		
		if isnull(@complaintEventTypeSID,0) = 0 select @complaintEventTypeSID = x.ComplaintEventTypeSID from dbo.ComplaintEventType x where x.IsDefault = @ON

		--! <Overrides>
		-- Tim Edlund | Jan 2019
		-- If no due date is passed, default it to 1 week after the
		-- previous event is due, or 1 week from today if no previous
		-- event exists
		
		if @dueDate is null
		begin

			select
				@dueDate = lag(ce.DueDate) over (order by ce.DueDate)
			from
				dbo.ComplaintEvent ce
			where
				ce.ComplaintSID = @complaintSID;

			set @dueDate = dateadd(week, 1, isnull(@dueDate, sf.fToday()));

		end;
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
				r.RoutineName = 'pComplaintEvent'
		)
		begin
		
			exec @errorNo = ext.pComplaintEvent
				 @Mode                        = 'default.pre'
				,@ComplaintEventSID = @complaintEventSID
				,@ComplaintSID = @complaintSID output
				,@ComplaintEventTypeSID = @complaintEventTypeSID output
				,@Description = @description output
				,@DueDate = @dueDate output
				,@CompleteTime = @completeTime output
				,@UserDefinedColumns = @userDefinedColumns output
				,@ComplaintEventXID = @complaintEventXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@ComplaintNo = @complaintNo
				,@RegistrantSID = @registrantSID
				,@ComplaintTypeSID = @complaintTypeSID
				,@ComplainantTypeSID = @complainantTypeSID
				,@ApplicationUserSID = @applicationUserSID
				,@OpenedDate = @openedDate
				,@ConductStartDate = @conductStartDate
				,@ConductEndDate = @conductEndDate
				,@ComplaintSeveritySID = @complaintSeveritySID
				,@IsDisplayedOnPublicRegistry = @isDisplayedOnPublicRegistry
				,@ClosedDate = @closedDate
				,@DismissedDate = @dismissedDate
				,@ReasonSID = @reasonSID
				,@FileExtension = @fileExtension
				,@ComplaintRowGUID = @complaintRowGUID
				,@ComplaintEventTypeSCD = @complaintEventTypeSCD
				,@ComplaintEventTypeLabel = @complaintEventTypeLabel
				,@ComplaintEventTypeIsDefault = @complaintEventTypeIsDefault
				,@ComplaintEventTypeRowGUID = @complaintEventTypeRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
				,@IsOverdue = @isOverdue
				,@IsComplete = @isComplete
		
		end

		select
			 @complaintEventSID ComplaintEventSID
			,@complaintSID ComplaintSID
			,@complaintEventTypeSID ComplaintEventTypeSID
			,@description Description
			,@dueDate DueDate
			,@completeTime CompleteTime
			,@userDefinedColumns UserDefinedColumns
			,@complaintEventXID ComplaintEventXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@complaintNo ComplaintNo
			,@registrantSID RegistrantSID
			,@complaintTypeSID ComplaintTypeSID
			,@complainantTypeSID ComplainantTypeSID
			,@applicationUserSID ApplicationUserSID
			,@openedDate OpenedDate
			,@conductStartDate ConductStartDate
			,@conductEndDate ConductEndDate
			,@complaintSeveritySID ComplaintSeveritySID
			,@isDisplayedOnPublicRegistry IsDisplayedOnPublicRegistry
			,@closedDate ClosedDate
			,@dismissedDate DismissedDate
			,@reasonSID ReasonSID
			,@fileExtension FileExtension
			,@complaintRowGUID ComplaintRowGUID
			,@complaintEventTypeSCD ComplaintEventTypeSCD
			,@complaintEventTypeLabel ComplaintEventTypeLabel
			,@complaintEventTypeIsDefault ComplaintEventTypeIsDefault
			,@complaintEventTypeRowGUID ComplaintEventTypeRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@isOverdue IsOverdue
			,@isComplete IsComplete

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