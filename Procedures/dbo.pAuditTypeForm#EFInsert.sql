SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pAuditTypeForm#EFInsert]
	 @AuditTypeSID       int               = null														-- required! if not passed value must be set in custom logic prior to insert
	,@FormSID            int               = null														-- required! if not passed value must be set in custom logic prior to insert
	,@IsReviewForm       bit               = null														-- default: CONVERT(bit,(0))
	,@UserDefinedColumns xml               = null														
	,@AuditTypeFormXID   varchar(150)      = null														
	,@LegacyKey          nvarchar(50)      = null														
	,@CreateUser         nvarchar(75)      = null														-- default: suser_sname()
	,@IsReselected       tinyint           = null														-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext           xml               = null														-- other values defining context for the insert (if any)
	,@AuditTypeLabel     nvarchar(35)      = null														-- not a base table column (default ignored)
	,@AuditTypeCategory  nvarchar(65)      = null														-- not a base table column (default ignored)
	,@AuditTypeIsDefault bit               = null														-- not a base table column (default ignored)
	,@AuditTypeIsActive  bit               = null														-- not a base table column (default ignored)
	,@AuditTypeRowGUID   uniqueidentifier  = null														-- not a base table column (default ignored)
	,@FormTypeSID        int               = null														-- not a base table column (default ignored)
	,@FormName           nvarchar(65)      = null														-- not a base table column (default ignored)
	,@FormLabel          nvarchar(35)      = null														-- not a base table column (default ignored)
	,@FormContext        varchar(25)       = null														-- not a base table column (default ignored)
	,@AuthorCredit       nvarchar(500)     = null														-- not a base table column (default ignored)
	,@FormIsActive       bit               = null														-- not a base table column (default ignored)
	,@ApplicationUserSID int               = null														-- not a base table column (default ignored)
	,@FormRowGUID        uniqueidentifier  = null														-- not a base table column (default ignored)
	,@IsDeleteEnabled    bit               = null														-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pAuditTypeForm#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pAuditTypeForm#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pAuditTypeForm#Insert
			 @AuditTypeSID       = @AuditTypeSID
			,@FormSID            = @FormSID
			,@IsReviewForm       = @IsReviewForm
			,@UserDefinedColumns = @UserDefinedColumns
			,@AuditTypeFormXID   = @AuditTypeFormXID
			,@LegacyKey          = @LegacyKey
			,@CreateUser         = @CreateUser
			,@IsReselected       = @IsReselected
			,@zContext           = @zContext
			,@AuditTypeLabel     = @AuditTypeLabel
			,@AuditTypeCategory  = @AuditTypeCategory
			,@AuditTypeIsDefault = @AuditTypeIsDefault
			,@AuditTypeIsActive  = @AuditTypeIsActive
			,@AuditTypeRowGUID   = @AuditTypeRowGUID
			,@FormTypeSID        = @FormTypeSID
			,@FormName           = @FormName
			,@FormLabel          = @FormLabel
			,@FormContext        = @FormContext
			,@AuthorCredit       = @AuthorCredit
			,@FormIsActive       = @FormIsActive
			,@ApplicationUserSID = @ApplicationUserSID
			,@FormRowGUID        = @FormRowGUID
			,@IsDeleteEnabled    = @IsDeleteEnabled

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
