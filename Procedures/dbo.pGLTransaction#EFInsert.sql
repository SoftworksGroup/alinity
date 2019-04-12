SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pGLTransaction#EFInsert]
	 @PaymentSID                  int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@InvoicePaymentSID           int               = null									
	,@DebitGLAccountCode          varchar(50)       = null									-- required! if not passed value must be set in custom logic prior to insert
	,@CreditGLAccountCode         varchar(50)       = null									-- required! if not passed value must be set in custom logic prior to insert
	,@Amount                      decimal(11,2)     = null									-- required! if not passed value must be set in custom logic prior to insert
	,@GLPostingDate               date              = null									-- required! if not passed value must be set in custom logic prior to insert
	,@PaymentCheckSum             int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@InvoicePaymentCheckSum      int               = null									
	,@ReversedGLTransactionSID    int               = null									
	,@IsExcluded                  bit               = null									-- default: CONVERT(bit,(0))
	,@UserDefinedColumns          xml               = null									
	,@GLTransactionXID            varchar(150)      = null									
	,@LegacyKey                   nvarchar(50)      = null									
	,@CreateUser                  nvarchar(75)      = null									-- default: suser_sname()
	,@IsReselected                tinyint           = null									-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                    xml               = null									-- other values defining context for the insert (if any)
	,@PersonSID                   int               = null									-- not a base table column (default ignored)
	,@PaymentTypeSID              int               = null									-- not a base table column (default ignored)
	,@PaymentStatusSID            int               = null									-- not a base table column (default ignored)
	,@GLAccountCode               varchar(50)       = null									-- not a base table column (default ignored)
	,@PaymentGLPostingDate        date              = null									-- not a base table column (default ignored)
	,@DepositDate                 date              = null									-- not a base table column (default ignored)
	,@AmountPaid                  decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Reference                   varchar(25)       = null									-- not a base table column (default ignored)
	,@NameOnCard                  nvarchar(150)     = null									-- not a base table column (default ignored)
	,@PaymentCard                 varchar(20)       = null									-- not a base table column (default ignored)
	,@TransactionID               varchar(50)       = null									-- not a base table column (default ignored)
	,@LastResponseCode            varchar(50)       = null									-- not a base table column (default ignored)
	,@VerifiedTime                datetime          = null									-- not a base table column (default ignored)
	,@PaymentCancelledTime        datetimeoffset(7) = null									-- not a base table column (default ignored)
	,@PaymentReasonSID            int               = null									-- not a base table column (default ignored)
	,@PaymentRowGUID              uniqueidentifier  = null									-- not a base table column (default ignored)
	,@InvoiceSID                  int               = null									-- not a base table column (default ignored)
	,@InvoicePaymentPaymentSID    int               = null									-- not a base table column (default ignored)
	,@AmountApplied               decimal(11,2)     = null									-- not a base table column (default ignored)
	,@AppliedDate                 date              = null									-- not a base table column (default ignored)
	,@InvoicePaymentGLPostingDate date              = null									-- not a base table column (default ignored)
	,@InvoicePaymentCancelledTime datetimeoffset(7) = null									-- not a base table column (default ignored)
	,@InvoicePaymentReasonSID     int               = null									-- not a base table column (default ignored)
	,@InvoicePaymentRowGUID       uniqueidentifier  = null									-- not a base table column (default ignored)
	,@IsDeleteEnabled             bit               = null									-- not a base table column (default ignored)
	,@IsEditEnabled               bit               = null									-- not a base table column (default ignored)
	,@FullDebitAccountLabel       nvarchar(86)      = null									-- not a base table column (default ignored)
	,@FullCreditAccountLabel      nvarchar(86)      = null									-- not a base table column (default ignored)
	,@IsReversing                 bit               = null									-- not a base table column (default ignored)
	,@IsReversed                  bit               = null									-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pGLTransaction#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pGLTransaction#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pGLTransaction#Insert
			 @PaymentSID                  = @PaymentSID
			,@InvoicePaymentSID           = @InvoicePaymentSID
			,@DebitGLAccountCode          = @DebitGLAccountCode
			,@CreditGLAccountCode         = @CreditGLAccountCode
			,@Amount                      = @Amount
			,@GLPostingDate               = @GLPostingDate
			,@PaymentCheckSum             = @PaymentCheckSum
			,@InvoicePaymentCheckSum      = @InvoicePaymentCheckSum
			,@ReversedGLTransactionSID    = @ReversedGLTransactionSID
			,@IsExcluded                  = @IsExcluded
			,@UserDefinedColumns          = @UserDefinedColumns
			,@GLTransactionXID            = @GLTransactionXID
			,@LegacyKey                   = @LegacyKey
			,@CreateUser                  = @CreateUser
			,@IsReselected                = @IsReselected
			,@zContext                    = @zContext
			,@PersonSID                   = @PersonSID
			,@PaymentTypeSID              = @PaymentTypeSID
			,@PaymentStatusSID            = @PaymentStatusSID
			,@GLAccountCode               = @GLAccountCode
			,@PaymentGLPostingDate        = @PaymentGLPostingDate
			,@DepositDate                 = @DepositDate
			,@AmountPaid                  = @AmountPaid
			,@Reference                   = @Reference
			,@NameOnCard                  = @NameOnCard
			,@PaymentCard                 = @PaymentCard
			,@TransactionID               = @TransactionID
			,@LastResponseCode            = @LastResponseCode
			,@VerifiedTime                = @VerifiedTime
			,@PaymentCancelledTime        = @PaymentCancelledTime
			,@PaymentReasonSID            = @PaymentReasonSID
			,@PaymentRowGUID              = @PaymentRowGUID
			,@InvoiceSID                  = @InvoiceSID
			,@InvoicePaymentPaymentSID    = @InvoicePaymentPaymentSID
			,@AmountApplied               = @AmountApplied
			,@AppliedDate                 = @AppliedDate
			,@InvoicePaymentGLPostingDate = @InvoicePaymentGLPostingDate
			,@InvoicePaymentCancelledTime = @InvoicePaymentCancelledTime
			,@InvoicePaymentReasonSID     = @InvoicePaymentReasonSID
			,@InvoicePaymentRowGUID       = @InvoicePaymentRowGUID
			,@IsDeleteEnabled             = @IsDeleteEnabled
			,@IsEditEnabled               = @IsEditEnabled
			,@FullDebitAccountLabel       = @FullDebitAccountLabel
			,@FullCreditAccountLabel      = @FullCreditAccountLabel
			,@IsReversing                 = @IsReversing
			,@IsReversed                  = @IsReversed

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
