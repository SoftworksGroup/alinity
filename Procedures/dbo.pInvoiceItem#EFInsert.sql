SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoiceItem#EFInsert]
	 @InvoiceSID                        int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@InvoiceItemDescription            nvarchar(500)     = null						-- required! if not passed value must be set in custom logic prior to insert
	,@Price                             decimal(11,2)     = null						-- required! if not passed value must be set in custom logic prior to insert
	,@Quantity                          int               = null						-- default: (1)
	,@Adjustment                        decimal(11,2)     = null						-- default: (0.00)
	,@ReasonSID                         int               = null						
	,@IsTaxRate1Applied                 bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxRate2Applied                 bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxRate3Applied                 bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxDeductible                   bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@GLAccountCode                     varchar(50)       = null						-- required! if not passed value must be set in custom logic prior to insert
	,@CatalogItemSID                    int               = null						
	,@UserDefinedColumns                xml               = null						
	,@InvoiceItemXID                    varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@PersonSID                         int               = null						-- not a base table column (default ignored)
	,@InvoiceDate                       date              = null						-- not a base table column (default ignored)
	,@Tax1Label                         nvarchar(8)       = null						-- not a base table column (default ignored)
	,@Tax1Rate                          decimal(4,4)      = null						-- not a base table column (default ignored)
	,@Tax1GLAccountCode                 varchar(50)       = null						-- not a base table column (default ignored)
	,@Tax2Label                         nvarchar(8)       = null						-- not a base table column (default ignored)
	,@Tax2Rate                          decimal(4,4)      = null						-- not a base table column (default ignored)
	,@Tax2GLAccountCode                 varchar(50)       = null						-- not a base table column (default ignored)
	,@Tax3Label                         nvarchar(8)       = null						-- not a base table column (default ignored)
	,@Tax3Rate                          decimal(4,4)      = null						-- not a base table column (default ignored)
	,@Tax3GLAccountCode                 varchar(50)       = null						-- not a base table column (default ignored)
	,@RegistrationYear                  smallint          = null						-- not a base table column (default ignored)
	,@CancelledTime                     datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@InvoiceReasonSID                  int               = null						-- not a base table column (default ignored)
	,@IsRefund                          bit               = null						-- not a base table column (default ignored)
	,@ComplaintSID                      int               = null						-- not a base table column (default ignored)
	,@InvoiceRowGUID                    uniqueidentifier  = null						-- not a base table column (default ignored)
	,@ReasonGroupSID                    int               = null						-- not a base table column (default ignored)
	,@ReasonName                        nvarchar(50)      = null						-- not a base table column (default ignored)
	,@ReasonCode                        varchar(25)       = null						-- not a base table column (default ignored)
	,@ReasonSequence                    smallint          = null						-- not a base table column (default ignored)
	,@ToolTip                           nvarchar(500)     = null						-- not a base table column (default ignored)
	,@ReasonIsActive                    bit               = null						-- not a base table column (default ignored)
	,@ReasonRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@CatalogItemLabel                  nvarchar(35)      = null						-- not a base table column (default ignored)
	,@CatalogItemInvoiceItemDescription nvarchar(500)     = null						-- not a base table column (default ignored)
	,@IsLateFee                         bit               = null						-- not a base table column (default ignored)
	,@ImageAlternateText                nvarchar(50)      = null						-- not a base table column (default ignored)
	,@IsAvailableOnClientPortal         bit               = null						-- not a base table column (default ignored)
	,@IsComplaintPenalty                bit               = null						-- not a base table column (default ignored)
	,@GLAccountSID                      int               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxRate1Applied      bit               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxRate2Applied      bit               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxRate3Applied      bit               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxDeductible        bit               = null						-- not a base table column (default ignored)
	,@EffectiveTime                     datetime          = null						-- not a base table column (default ignored)
	,@ExpiryTime                        datetime          = null						-- not a base table column (default ignored)
	,@FileTypeSCD                       varchar(8)        = null						-- not a base table column (default ignored)
	,@FileTypeSID                       int               = null						-- not a base table column (default ignored)
	,@CatalogItemRowGUID                uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@AmountBeforeAdjustment            decimal(11,2)     = null						-- not a base table column (default ignored)
	,@AmountBeforeTax                   decimal(11,2)     = null						-- not a base table column (default ignored)
	,@Tax1Amount                        decimal(11,2)     = null						-- not a base table column (default ignored)
	,@Tax2Amount                        decimal(11,2)     = null						-- not a base table column (default ignored)
	,@Tax3Amount                        decimal(11,2)     = null						-- not a base table column (default ignored)
	,@AmountAfterTax                    decimal(11,2)     = null						-- not a base table column (default ignored)
	,@IsAdjusted                        bit               = null						-- not a base table column (default ignored)
	,@GLAccountLabel                    nvarchar(35)      = null						-- not a base table column (default ignored)
	,@IsRevenueAccount                  bit               = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoiceItem#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pInvoiceItem#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pInvoiceItem#Insert
			 @InvoiceSID                        = @InvoiceSID
			,@InvoiceItemDescription            = @InvoiceItemDescription
			,@Price                             = @Price
			,@Quantity                          = @Quantity
			,@Adjustment                        = @Adjustment
			,@ReasonSID                         = @ReasonSID
			,@IsTaxRate1Applied                 = @IsTaxRate1Applied
			,@IsTaxRate2Applied                 = @IsTaxRate2Applied
			,@IsTaxRate3Applied                 = @IsTaxRate3Applied
			,@IsTaxDeductible                   = @IsTaxDeductible
			,@GLAccountCode                     = @GLAccountCode
			,@CatalogItemSID                    = @CatalogItemSID
			,@UserDefinedColumns                = @UserDefinedColumns
			,@InvoiceItemXID                    = @InvoiceItemXID
			,@LegacyKey                         = @LegacyKey
			,@CreateUser                        = @CreateUser
			,@IsReselected                      = @IsReselected
			,@zContext                          = @zContext
			,@PersonSID                         = @PersonSID
			,@InvoiceDate                       = @InvoiceDate
			,@Tax1Label                         = @Tax1Label
			,@Tax1Rate                          = @Tax1Rate
			,@Tax1GLAccountCode                 = @Tax1GLAccountCode
			,@Tax2Label                         = @Tax2Label
			,@Tax2Rate                          = @Tax2Rate
			,@Tax2GLAccountCode                 = @Tax2GLAccountCode
			,@Tax3Label                         = @Tax3Label
			,@Tax3Rate                          = @Tax3Rate
			,@Tax3GLAccountCode                 = @Tax3GLAccountCode
			,@RegistrationYear                  = @RegistrationYear
			,@CancelledTime                     = @CancelledTime
			,@InvoiceReasonSID                  = @InvoiceReasonSID
			,@IsRefund                          = @IsRefund
			,@ComplaintSID                      = @ComplaintSID
			,@InvoiceRowGUID                    = @InvoiceRowGUID
			,@ReasonGroupSID                    = @ReasonGroupSID
			,@ReasonName                        = @ReasonName
			,@ReasonCode                        = @ReasonCode
			,@ReasonSequence                    = @ReasonSequence
			,@ToolTip                           = @ToolTip
			,@ReasonIsActive                    = @ReasonIsActive
			,@ReasonRowGUID                     = @ReasonRowGUID
			,@CatalogItemLabel                  = @CatalogItemLabel
			,@CatalogItemInvoiceItemDescription = @CatalogItemInvoiceItemDescription
			,@IsLateFee                         = @IsLateFee
			,@ImageAlternateText                = @ImageAlternateText
			,@IsAvailableOnClientPortal         = @IsAvailableOnClientPortal
			,@IsComplaintPenalty                = @IsComplaintPenalty
			,@GLAccountSID                      = @GLAccountSID
			,@CatalogItemIsTaxRate1Applied      = @CatalogItemIsTaxRate1Applied
			,@CatalogItemIsTaxRate2Applied      = @CatalogItemIsTaxRate2Applied
			,@CatalogItemIsTaxRate3Applied      = @CatalogItemIsTaxRate3Applied
			,@CatalogItemIsTaxDeductible        = @CatalogItemIsTaxDeductible
			,@EffectiveTime                     = @EffectiveTime
			,@ExpiryTime                        = @ExpiryTime
			,@FileTypeSCD                       = @FileTypeSCD
			,@FileTypeSID                       = @FileTypeSID
			,@CatalogItemRowGUID                = @CatalogItemRowGUID
			,@IsDeleteEnabled                   = @IsDeleteEnabled
			,@AmountBeforeAdjustment            = @AmountBeforeAdjustment
			,@AmountBeforeTax                   = @AmountBeforeTax
			,@Tax1Amount                        = @Tax1Amount
			,@Tax2Amount                        = @Tax2Amount
			,@Tax3Amount                        = @Tax3Amount
			,@AmountAfterTax                    = @AmountAfterTax
			,@IsAdjusted                        = @IsAdjusted
			,@GLAccountLabel                    = @GLAccountLabel
			,@IsRevenueAccount                  = @IsRevenueAccount

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
