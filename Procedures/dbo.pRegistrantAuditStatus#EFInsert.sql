SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAuditStatus#EFInsert]
	 @RegistrantAuditSID       int               = null											-- required! if not passed value must be set in custom logic prior to insert
	,@FormStatusSID            int               = null											-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns       xml               = null											
	,@RegistrantAuditStatusXID varchar(150)      = null											
	,@LegacyKey                nvarchar(50)      = null											
	,@CreateUser               nvarchar(75)      = null											-- default: suser_sname()
	,@IsReselected             tinyint           = null											-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                 xml               = null											-- other values defining context for the insert (if any)
	,@RegistrantSID            int               = null											-- not a base table column (default ignored)
	,@AuditTypeSID             int               = null											-- not a base table column (default ignored)
	,@RegistrationYear         smallint          = null											-- not a base table column (default ignored)
	,@FormVersionSID           int               = null											-- not a base table column (default ignored)
	,@LastValidateTime         datetimeoffset(7) = null											-- not a base table column (default ignored)
	,@NextFollowUp             date              = null											-- not a base table column (default ignored)
	,@ReasonSID                int               = null											-- not a base table column (default ignored)
	,@IsAutoApprovalEnabled    bit               = null											-- not a base table column (default ignored)
	,@RegistrantAuditRowGUID   uniqueidentifier  = null											-- not a base table column (default ignored)
	,@FormStatusSCD            varchar(25)       = null											-- not a base table column (default ignored)
	,@FormStatusLabel          nvarchar(35)      = null											-- not a base table column (default ignored)
	,@IsFinal                  bit               = null											-- not a base table column (default ignored)
	,@FormStatusIsDefault      bit               = null											-- not a base table column (default ignored)
	,@FormStatusSequence       int               = null											-- not a base table column (default ignored)
	,@FormOwnerSID             int               = null											-- not a base table column (default ignored)
	,@FormStatusRowGUID        uniqueidentifier  = null											-- not a base table column (default ignored)
	,@IsDeleteEnabled          bit               = null											-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAuditStatus#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantAuditStatus#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantAuditStatus#Insert
			 @RegistrantAuditSID       = @RegistrantAuditSID
			,@FormStatusSID            = @FormStatusSID
			,@UserDefinedColumns       = @UserDefinedColumns
			,@RegistrantAuditStatusXID = @RegistrantAuditStatusXID
			,@LegacyKey                = @LegacyKey
			,@CreateUser               = @CreateUser
			,@IsReselected             = @IsReselected
			,@zContext                 = @zContext
			,@RegistrantSID            = @RegistrantSID
			,@AuditTypeSID             = @AuditTypeSID
			,@RegistrationYear         = @RegistrationYear
			,@FormVersionSID           = @FormVersionSID
			,@LastValidateTime         = @LastValidateTime
			,@NextFollowUp             = @NextFollowUp
			,@ReasonSID                = @ReasonSID
			,@IsAutoApprovalEnabled    = @IsAutoApprovalEnabled
			,@RegistrantAuditRowGUID   = @RegistrantAuditRowGUID
			,@FormStatusSCD            = @FormStatusSCD
			,@FormStatusLabel          = @FormStatusLabel
			,@IsFinal                  = @IsFinal
			,@FormStatusIsDefault      = @FormStatusIsDefault
			,@FormStatusSequence       = @FormStatusSequence
			,@FormOwnerSID             = @FormOwnerSID
			,@FormStatusRowGUID        = @FormStatusRowGUID
			,@IsDeleteEnabled          = @IsDeleteEnabled

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
