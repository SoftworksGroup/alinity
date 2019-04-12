SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCatalogItem#EFInsert]
	 @CatalogItemLabel          nvarchar(35)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@InvoiceItemDescription    nvarchar(500)     = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsLateFee                 bit               = null										-- default: CONVERT(bit,(0))
	,@ItemDetailedDescription   varbinary(max)    = null										
	,@ItemSmallImage            varbinary(max)    = null										
	,@ItemLargeImage            varbinary(max)    = null										
	,@ImageAlternateText        nvarchar(50)      = null										
	,@IsAvailableOnClientPortal bit               = null										-- default: CONVERT(bit,(0))
	,@IsComplaintPenalty        bit               = null										-- default: CONVERT(bit,(0))
	,@GLAccountSID              int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxRate1Applied         bit               = null										-- default: (0)
	,@IsTaxRate2Applied         bit               = null										-- default: (0)
	,@IsTaxRate3Applied         bit               = null										-- default: (0)
	,@IsTaxDeductible           bit               = null										-- default: (1)
	,@EffectiveTime             datetime          = null										-- default: CONVERT(datetime,sf.fToday())
	,@ExpiryTime                datetime          = null										
	,@FileTypeSCD               varchar(8)        = null										-- default: '.HTML'
	,@FileTypeSID               int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns        xml               = null										
	,@CatalogItemXID            varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@GLAccountCode             varchar(50)       = null										-- not a base table column (default ignored)
	,@GLAccountLabel            nvarchar(35)      = null										-- not a base table column (default ignored)
	,@IsRevenueAccount          bit               = null										-- not a base table column (default ignored)
	,@IsBankAccount             bit               = null										-- not a base table column (default ignored)
	,@IsTaxAccount              bit               = null										-- not a base table column (default ignored)
	,@IsPAPAccount              bit               = null										-- not a base table column (default ignored)
	,@IsUnappliedPaymentAccount bit               = null										-- not a base table column (default ignored)
	,@DeferredGLAccountCode     varchar(50)       = null										-- not a base table column (default ignored)
	,@GLAccountIsActive         bit               = null										-- not a base table column (default ignored)
	,@GLAccountRowGUID          uniqueidentifier  = null										-- not a base table column (default ignored)
	,@FileTypeFileTypeSCD       varchar(8)        = null										-- not a base table column (default ignored)
	,@FileTypeLabel             nvarchar(35)      = null										-- not a base table column (default ignored)
	,@MimeType                  varchar(255)      = null										-- not a base table column (default ignored)
	,@IsInline                  bit               = null										-- not a base table column (default ignored)
	,@FileTypeIsActive          bit               = null										-- not a base table column (default ignored)
	,@FileTypeRowGUID           uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsActive                  bit               = null										-- not a base table column (default ignored)
	,@IsPending                 bit               = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
	,@CurrentPrice              decimal(11,2)     = null										-- not a base table column (default ignored)
	,@Tax1Label                 nvarchar(8)       = null										-- not a base table column (default ignored)
	,@Tax1Rate                  decimal(4,4)      = null										-- not a base table column (default ignored)
	,@Tax1GLAccountSID          int               = null										-- not a base table column (default ignored)
	,@Tax1Amount                decimal(11,2)     = null										-- not a base table column (default ignored)
	,@Tax2Label                 nvarchar(8)       = null										-- not a base table column (default ignored)
	,@Tax2Rate                  decimal(4,4)      = null										-- not a base table column (default ignored)
	,@Tax2GLAccountSID          int               = null										-- not a base table column (default ignored)
	,@Tax2Amount                decimal(11,2)     = null										-- not a base table column (default ignored)
	,@Tax3Label                 nvarchar(8)       = null										-- not a base table column (default ignored)
	,@Tax3Rate                  decimal(4,4)      = null										-- not a base table column (default ignored)
	,@Tax3GLAccountSID          int               = null										-- not a base table column (default ignored)
	,@Tax3Amount                decimal(11,2)     = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pCatalogItem#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pCatalogItem#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pCatalogItem#Insert
			 @CatalogItemLabel          = @CatalogItemLabel
			,@InvoiceItemDescription    = @InvoiceItemDescription
			,@IsLateFee                 = @IsLateFee
			,@ItemDetailedDescription   = @ItemDetailedDescription
			,@ItemSmallImage            = @ItemSmallImage
			,@ItemLargeImage            = @ItemLargeImage
			,@ImageAlternateText        = @ImageAlternateText
			,@IsAvailableOnClientPortal = @IsAvailableOnClientPortal
			,@IsComplaintPenalty        = @IsComplaintPenalty
			,@GLAccountSID              = @GLAccountSID
			,@IsTaxRate1Applied         = @IsTaxRate1Applied
			,@IsTaxRate2Applied         = @IsTaxRate2Applied
			,@IsTaxRate3Applied         = @IsTaxRate3Applied
			,@IsTaxDeductible           = @IsTaxDeductible
			,@EffectiveTime             = @EffectiveTime
			,@ExpiryTime                = @ExpiryTime
			,@FileTypeSCD               = @FileTypeSCD
			,@FileTypeSID               = @FileTypeSID
			,@UserDefinedColumns        = @UserDefinedColumns
			,@CatalogItemXID            = @CatalogItemXID
			,@LegacyKey                 = @LegacyKey
			,@CreateUser                = @CreateUser
			,@IsReselected              = @IsReselected
			,@zContext                  = @zContext
			,@GLAccountCode             = @GLAccountCode
			,@GLAccountLabel            = @GLAccountLabel
			,@IsRevenueAccount          = @IsRevenueAccount
			,@IsBankAccount             = @IsBankAccount
			,@IsTaxAccount              = @IsTaxAccount
			,@IsPAPAccount              = @IsPAPAccount
			,@IsUnappliedPaymentAccount = @IsUnappliedPaymentAccount
			,@DeferredGLAccountCode     = @DeferredGLAccountCode
			,@GLAccountIsActive         = @GLAccountIsActive
			,@GLAccountRowGUID          = @GLAccountRowGUID
			,@FileTypeFileTypeSCD       = @FileTypeFileTypeSCD
			,@FileTypeLabel             = @FileTypeLabel
			,@MimeType                  = @MimeType
			,@IsInline                  = @IsInline
			,@FileTypeIsActive          = @FileTypeIsActive
			,@FileTypeRowGUID           = @FileTypeRowGUID
			,@IsActive                  = @IsActive
			,@IsPending                 = @IsPending
			,@IsDeleteEnabled           = @IsDeleteEnabled
			,@CurrentPrice              = @CurrentPrice
			,@Tax1Label                 = @Tax1Label
			,@Tax1Rate                  = @Tax1Rate
			,@Tax1GLAccountSID          = @Tax1GLAccountSID
			,@Tax1Amount                = @Tax1Amount
			,@Tax2Label                 = @Tax2Label
			,@Tax2Rate                  = @Tax2Rate
			,@Tax2GLAccountSID          = @Tax2GLAccountSID
			,@Tax2Amount                = @Tax2Amount
			,@Tax3Label                 = @Tax3Label
			,@Tax3Rate                  = @Tax3Rate
			,@Tax3GLAccountSID          = @Tax3GLAccountSID
			,@Tax3Amount                = @Tax3Amount

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
