SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAuditReviewResponse#EFInsert]
	 @RegistrantAuditReviewSID         int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormOwnerSID                     int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@FormResponse                     xml               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns               xml               = null							
	,@RegistrantAuditReviewResponseXID varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@RegistrantAuditSID               int               = null							-- not a base table column (default ignored)
	,@FormVersionSID                   int               = null							-- not a base table column (default ignored)
	,@PersonSID                        int               = null							-- not a base table column (default ignored)
	,@ReasonSID                        int               = null							-- not a base table column (default ignored)
	,@RecommendationSID                int               = null							-- not a base table column (default ignored)
	,@LastValidateTime                 datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@IsAutoApprovalEnabled            bit               = null							-- not a base table column (default ignored)
	,@RegistrantAuditReviewRowGUID     uniqueidentifier  = null							-- not a base table column (default ignored)
	,@FormOwnerSCD                     varchar(25)       = null							-- not a base table column (default ignored)
	,@FormOwnerLabel                   nvarchar(35)      = null							-- not a base table column (default ignored)
	,@IsAssignee                       bit               = null							-- not a base table column (default ignored)
	,@FormOwnerRowGUID                 uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAuditReviewResponse#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantAuditReviewResponse#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
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

		exec @errorNo = dbo.pRegistrantAuditReviewResponse#Insert
			 @RegistrantAuditReviewSID         = @RegistrantAuditReviewSID
			,@FormOwnerSID                     = @FormOwnerSID
			,@FormResponse                     = @FormResponse
			,@UserDefinedColumns               = @UserDefinedColumns
			,@RegistrantAuditReviewResponseXID = @RegistrantAuditReviewResponseXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@RegistrantAuditSID               = @RegistrantAuditSID
			,@FormVersionSID                   = @FormVersionSID
			,@PersonSID                        = @PersonSID
			,@ReasonSID                        = @ReasonSID
			,@RecommendationSID                = @RecommendationSID
			,@LastValidateTime                 = @LastValidateTime
			,@IsAutoApprovalEnabled            = @IsAutoApprovalEnabled
			,@RegistrantAuditReviewRowGUID     = @RegistrantAuditReviewRowGUID
			,@FormOwnerSCD                     = @FormOwnerSCD
			,@FormOwnerLabel                   = @FormOwnerLabel
			,@IsAssignee                       = @IsAssignee
			,@FormOwnerRowGUID                 = @FormOwnerRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled

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
