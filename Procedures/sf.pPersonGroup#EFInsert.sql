SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroup#EFInsert]
	 @PersonGroupName                  nvarchar(65)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PersonGroupLabel                 nvarchar(35)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PersonGroupCategory              nvarchar(65)      = null							
	,@Description                      nvarchar(500)     = null							
	,@ApplicationUserSID               int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@IsPreference                     bit               = null							-- default: CONVERT(bit,(0))
	,@IsDocumentLibraryEnabled         bit               = null							-- default: (0)
	,@QuerySID                         int               = null							
	,@LastReviewUser                   nvarchar(75)      = null							-- default: suser_sname()
	,@LastReviewTime                   datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@TagList                          xml               = null							-- default: CONVERT(xml,N'<Tags/>')
	,@SmartGroupCount                  int               = null							-- default: (0)
	,@SmartGroupCountTime              datetimeoffset(7) = null							-- default: sysdatetimeoffset()
	,@IsActive                         bit               = null							-- default: (1)
	,@UserDefinedColumns               xml               = null							
	,@PersonGroupXID                   varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@PersonSID                        int               = null							-- not a base table column (default ignored)
	,@CultureSID                       int               = null							-- not a base table column (default ignored)
	,@AuthenticationAuthoritySID       int               = null							-- not a base table column (default ignored)
	,@UserName                         nvarchar(75)      = null							-- not a base table column (default ignored)
	,@ApplicationUserLastReviewTime    datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserLastReviewUser    nvarchar(75)      = null							-- not a base table column (default ignored)
	,@IsPotentialDuplicate             bit               = null							-- not a base table column (default ignored)
	,@IsTemplate                       bit               = null							-- not a base table column (default ignored)
	,@GlassBreakPassword               varbinary(8000)   = null							-- not a base table column (default ignored)
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserIsActive          bit               = null							-- not a base table column (default ignored)
	,@AuthenticationSystemID           nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ApplicationUserRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
	,@QueryCategorySID                 int               = null							-- not a base table column (default ignored)
	,@ApplicationPageSID               int               = null							-- not a base table column (default ignored)
	,@QueryLabel                       nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ToolTip                          nvarchar(250)     = null							-- not a base table column (default ignored)
	,@LastExecuteTime                  datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastExecuteUser                  nvarchar(75)      = null							-- not a base table column (default ignored)
	,@ExecuteCount                     int               = null							-- not a base table column (default ignored)
	,@QueryCode                        varchar(30)       = null							-- not a base table column (default ignored)
	,@QueryIsActive                    bit               = null							-- not a base table column (default ignored)
	,@IsApplicationPageDefault         bit               = null							-- not a base table column (default ignored)
	,@QueryRowGUID                     uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@IsSmartGroup                     bit               = null							-- not a base table column (default ignored)
	,@NextReviewDueDate                smalldatetime     = null							-- not a base table column (default ignored)
	,@TotalActive                      int               = null							-- not a base table column (default ignored)
	,@TotalPending                     int               = null							-- not a base table column (default ignored)
	,@TotalRequiringReplacement        int               = null							-- not a base table column (default ignored)
	,@IsNextReviewOverdue              bit               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroup#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonGroup#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pPersonGroup#Insert
			 @PersonGroupName                  = @PersonGroupName
			,@PersonGroupLabel                 = @PersonGroupLabel
			,@PersonGroupCategory              = @PersonGroupCategory
			,@Description                      = @Description
			,@ApplicationUserSID               = @ApplicationUserSID
			,@IsPreference                     = @IsPreference
			,@IsDocumentLibraryEnabled         = @IsDocumentLibraryEnabled
			,@QuerySID                         = @QuerySID
			,@LastReviewUser                   = @LastReviewUser
			,@LastReviewTime                   = @LastReviewTime
			,@TagList                          = @TagList
			,@SmartGroupCount                  = @SmartGroupCount
			,@SmartGroupCountTime              = @SmartGroupCountTime
			,@IsActive                         = @IsActive
			,@UserDefinedColumns               = @UserDefinedColumns
			,@PersonGroupXID                   = @PersonGroupXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@PersonSID                        = @PersonSID
			,@CultureSID                       = @CultureSID
			,@AuthenticationAuthoritySID       = @AuthenticationAuthoritySID
			,@UserName                         = @UserName
			,@ApplicationUserLastReviewTime    = @ApplicationUserLastReviewTime
			,@ApplicationUserLastReviewUser    = @ApplicationUserLastReviewUser
			,@IsPotentialDuplicate             = @IsPotentialDuplicate
			,@IsTemplate                       = @IsTemplate
			,@GlassBreakPassword               = @GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime = @LastGlassBreakPasswordChangeTime
			,@ApplicationUserIsActive          = @ApplicationUserIsActive
			,@AuthenticationSystemID           = @AuthenticationSystemID
			,@ApplicationUserRowGUID           = @ApplicationUserRowGUID
			,@QueryCategorySID                 = @QueryCategorySID
			,@ApplicationPageSID               = @ApplicationPageSID
			,@QueryLabel                       = @QueryLabel
			,@ToolTip                          = @ToolTip
			,@LastExecuteTime                  = @LastExecuteTime
			,@LastExecuteUser                  = @LastExecuteUser
			,@ExecuteCount                     = @ExecuteCount
			,@QueryCode                        = @QueryCode
			,@QueryIsActive                    = @QueryIsActive
			,@IsApplicationPageDefault         = @IsApplicationPageDefault
			,@QueryRowGUID                     = @QueryRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@IsSmartGroup                     = @IsSmartGroup
			,@NextReviewDueDate                = @NextReviewDueDate
			,@TotalActive                      = @TotalActive
			,@TotalPending                     = @TotalPending
			,@TotalRequiringReplacement        = @TotalRequiringReplacement
			,@IsNextReviewOverdue              = @IsNextReviewOverdue

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
