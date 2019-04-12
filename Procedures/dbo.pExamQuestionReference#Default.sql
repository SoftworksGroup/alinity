SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pExamQuestionReference#Default]
	 @zContext                 xml               = null                -- default values provided from client-tier (if any)
	,@SetFKDefaults            bit               = 0                   -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pExamQuestionReference#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.ExamQuestionReference records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.ExamQuestionReference table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vExamQuestionReference entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pExamQuestionReference
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pExamQuestionReference of the context of the call. All other parameters are also passed, however, only those parameters eligible
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
		,@ON                       bit = cast(1 as bit)												-- constant for bit comparisons
		,@OFF                      bit = cast(0 as bit)												-- constant for bit comparisons
		,@examQuestionReferenceSID int               = -1											-- specific default required by EF - do not override
		,@examQuestionSID          int               = null										-- no default provided from DB constraint - OK to override
		,@referenceTitle           nvarchar(125)     = null										-- no default provided from DB constraint - OK to override
		,@referenceURL             varchar(250)      = null										-- no default provided from DB constraint - OK to override
		,@userDefinedColumns       xml               = null										-- no default provided from DB constraint - OK to override
		,@examQuestionReferenceXID varchar(150)      = null										-- no default provided from DB constraint - OK to override
		,@legacyKey                nvarchar(50)      = null										-- no default provided from DB constraint - OK to override
		,@isDeleted                bit               = (0)										-- default provided from DB constraint - OK to override
		,@createUser               nvarchar(75)      = suser_sname()					-- default value ignored (value set by UI)
		,@createTime               datetimeoffset(7) = sysdatetimeoffset()		-- default value ignored (set to system time)
		,@updateUser               nvarchar(75)      = suser_sname()					-- default value ignored (value set by UI)
		,@updateTime               datetimeoffset(7) = sysdatetimeoffset()		-- default value ignored (set to system time)
		,@rowGUID                  uniqueidentifier  = newid()								-- default value ignored (value set by system)
		,@rowStamp                 timestamp         = null										-- default value ignored (value set by system)
		,@examSectionSID           int               = 0											-- not a base table column (default ignored)
		,@sequence                 smallint          = 0											-- not a base table column (default ignored)
		,@attemptsAllowed          tinyint           = 0											-- not a base table column (default ignored)
		,@knowledgeDomainSID       int               = 0											-- not a base table column (default ignored)
		,@examQuestionIsActive     bit               = 0											-- not a base table column (default ignored)
		,@examQuestionRowGUID      uniqueidentifier  = newid()								-- not a base table column (default ignored)
		,@isDeleteEnabled          bit																				-- not a base table column (default ignored)
		,@isReselected             tinyint           = 1											-- specific default required by EF - do not override
		,@isNullApplied            bit               = 1											-- specific default required by EF - do not override

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
			set @examQuestionSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @examQuestionSID           = isnull(context.node.value('@ExamQuestionSID'         ,'int'          ),@examQuestionSID)
			,@referenceTitle            = isnull(context.node.value('@ReferenceTitle'          ,'nvarchar(125)'),@referenceTitle)
			,@referenceURL              = isnull(context.node.value('@ReferenceURL'            ,'varchar(250)' ),@referenceURL)
			,@examQuestionReferenceXID  = isnull(context.node.value('@ExamQuestionReferenceXID','varchar(150)' ),@examQuestionReferenceXID)
			,@legacyKey                 = isnull(context.node.value('@LegacyKey'               ,'nvarchar(50)' ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		

		--! <Overrides>
		--  insert default value logic here ...
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
				r.RoutineName = 'pExamQuestionReference'
		)
		begin
		
			exec @errorNo = ext.pExamQuestionReference
				 @Mode                     = 'default.pre'
				,@ExamQuestionReferenceSID = @examQuestionReferenceSID
				,@ExamQuestionSID = @examQuestionSID output
				,@ReferenceTitle = @referenceTitle output
				,@ReferenceURL = @referenceURL output
				,@UserDefinedColumns = @userDefinedColumns output
				,@ExamQuestionReferenceXID = @examQuestionReferenceXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@ExamSectionSID = @examSectionSID
				,@Sequence = @sequence
				,@AttemptsAllowed = @attemptsAllowed
				,@KnowledgeDomainSID = @knowledgeDomainSID
				,@ExamQuestionIsActive = @examQuestionIsActive
				,@ExamQuestionRowGUID = @examQuestionRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
		
		end

		select
			 @examQuestionReferenceSID ExamQuestionReferenceSID
			,@examQuestionSID ExamQuestionSID
			,@referenceTitle ReferenceTitle
			,@referenceURL ReferenceURL
			,@userDefinedColumns UserDefinedColumns
			,@examQuestionReferenceXID ExamQuestionReferenceXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@examSectionSID ExamSectionSID
			,@sequence Sequence
			,@attemptsAllowed AttemptsAllowed
			,@knowledgeDomainSID KnowledgeDomainSID
			,@examQuestionIsActive ExamQuestionIsActive
			,@examQuestionRowGUID ExamQuestionRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext

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
