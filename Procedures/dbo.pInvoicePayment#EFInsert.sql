SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoicePayment#EFInsert]
	 @InvoiceSID           int               = null													-- required! if not passed value must be set in custom logic prior to insert
	,@PaymentSID           int               = null													-- required! if not passed value must be set in custom logic prior to insert
	,@AmountApplied        decimal(11,2)     = null													-- default: (0.00)
	,@AppliedDate          date              = null													-- default: sf.fToday()
	,@GLPostingDate        date              = null													
	,@CancelledTime        datetimeoffset(7) = null													
	,@ReasonSID            int               = null													
	,@UserDefinedColumns   xml               = null													
	,@InvoicePaymentXID    varchar(150)      = null													
	,@LegacyKey            nvarchar(50)      = null													
	,@CreateUser           nvarchar(75)      = null													-- default: suser_sname()
	,@IsReselected         tinyint           = null													-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext             xml               = null													-- other values defining context for the insert (if any)
	,@InvoicePersonSID     int               = null													-- not a base table column (default ignored)
	,@InvoiceDate          date              = null													-- not a base table column (default ignored)
	,@Tax1Label            nvarchar(8)       = null													-- not a base table column (default ignored)
	,@Tax1Rate             decimal(4,4)      = null													-- not a base table column (default ignored)
	,@Tax1GLAccountCode    varchar(50)       = null													-- not a base table column (default ignored)
	,@Tax2Label            nvarchar(8)       = null													-- not a base table column (default ignored)
	,@Tax2Rate             decimal(4,4)      = null													-- not a base table column (default ignored)
	,@Tax2GLAccountCode    varchar(50)       = null													-- not a base table column (default ignored)
	,@Tax3Label            nvarchar(8)       = null													-- not a base table column (default ignored)
	,@Tax3Rate             decimal(4,4)      = null													-- not a base table column (default ignored)
	,@Tax3GLAccountCode    varchar(50)       = null													-- not a base table column (default ignored)
	,@RegistrationYear     smallint          = null													-- not a base table column (default ignored)
	,@InvoiceCancelledTime datetimeoffset(7) = null													-- not a base table column (default ignored)
	,@InvoiceReasonSID     int               = null													-- not a base table column (default ignored)
	,@IsRefund             bit               = null													-- not a base table column (default ignored)
	,@ComplaintSID         int               = null													-- not a base table column (default ignored)
	,@InvoiceRowGUID       uniqueidentifier  = null													-- not a base table column (default ignored)
	,@PaymentPersonSID     int               = null													-- not a base table column (default ignored)
	,@PaymentTypeSID       int               = null													-- not a base table column (default ignored)
	,@PaymentStatusSID     int               = null													-- not a base table column (default ignored)
	,@GLAccountCode        varchar(50)       = null													-- not a base table column (default ignored)
	,@PaymentGLPostingDate date              = null													-- not a base table column (default ignored)
	,@DepositDate          date              = null													-- not a base table column (default ignored)
	,@AmountPaid           decimal(11,2)     = null													-- not a base table column (default ignored)
	,@Reference            varchar(25)       = null													-- not a base table column (default ignored)
	,@NameOnCard           nvarchar(150)     = null													-- not a base table column (default ignored)
	,@PaymentCard          varchar(20)       = null													-- not a base table column (default ignored)
	,@TransactionID        varchar(50)       = null													-- not a base table column (default ignored)
	,@LastResponseCode     varchar(50)       = null													-- not a base table column (default ignored)
	,@VerifiedTime         datetime          = null													-- not a base table column (default ignored)
	,@PaymentCancelledTime datetimeoffset(7) = null													-- not a base table column (default ignored)
	,@PaymentReasonSID     int               = null													-- not a base table column (default ignored)
	,@PaymentRowGUID       uniqueidentifier  = null													-- not a base table column (default ignored)
	,@ReasonGroupSID       int               = null													-- not a base table column (default ignored)
	,@ReasonName           nvarchar(50)      = null													-- not a base table column (default ignored)
	,@ReasonCode           varchar(25)       = null													-- not a base table column (default ignored)
	,@ReasonSequence       smallint          = null													-- not a base table column (default ignored)
	,@ToolTip              nvarchar(500)     = null													-- not a base table column (default ignored)
	,@ReasonIsActive       bit               = null													-- not a base table column (default ignored)
	,@ReasonRowGUID        uniqueidentifier  = null													-- not a base table column (default ignored)
	,@IsDeleteEnabled      bit               = null													-- not a base table column (default ignored)
	,@IsCancelled          bit               = null													-- not a base table column (default ignored)
	,@IsEditEnabled        bit               = null													-- not a base table column (default ignored)
	,@GLCheckSum           int               = null													-- not a base table column (default ignored)
	,@IsPaid               bit               = null													-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoicePayment#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pInvoicePayment#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pInvoicePayment#Insert
			 @InvoiceSID           = @InvoiceSID
			,@PaymentSID           = @PaymentSID
			,@AmountApplied        = @AmountApplied
			,@AppliedDate          = @AppliedDate
			,@GLPostingDate        = @GLPostingDate
			,@CancelledTime        = @CancelledTime
			,@ReasonSID            = @ReasonSID
			,@UserDefinedColumns   = @UserDefinedColumns
			,@InvoicePaymentXID    = @InvoicePaymentXID
			,@LegacyKey            = @LegacyKey
			,@CreateUser           = @CreateUser
			,@IsReselected         = @IsReselected
			,@zContext             = @zContext
			,@InvoicePersonSID     = @InvoicePersonSID
			,@InvoiceDate          = @InvoiceDate
			,@Tax1Label            = @Tax1Label
			,@Tax1Rate             = @Tax1Rate
			,@Tax1GLAccountCode    = @Tax1GLAccountCode
			,@Tax2Label            = @Tax2Label
			,@Tax2Rate             = @Tax2Rate
			,@Tax2GLAccountCode    = @Tax2GLAccountCode
			,@Tax3Label            = @Tax3Label
			,@Tax3Rate             = @Tax3Rate
			,@Tax3GLAccountCode    = @Tax3GLAccountCode
			,@RegistrationYear     = @RegistrationYear
			,@InvoiceCancelledTime = @InvoiceCancelledTime
			,@InvoiceReasonSID     = @InvoiceReasonSID
			,@IsRefund             = @IsRefund
			,@ComplaintSID         = @ComplaintSID
			,@InvoiceRowGUID       = @InvoiceRowGUID
			,@PaymentPersonSID     = @PaymentPersonSID
			,@PaymentTypeSID       = @PaymentTypeSID
			,@PaymentStatusSID     = @PaymentStatusSID
			,@GLAccountCode        = @GLAccountCode
			,@PaymentGLPostingDate = @PaymentGLPostingDate
			,@DepositDate          = @DepositDate
			,@AmountPaid           = @AmountPaid
			,@Reference            = @Reference
			,@NameOnCard           = @NameOnCard
			,@PaymentCard          = @PaymentCard
			,@TransactionID        = @TransactionID
			,@LastResponseCode     = @LastResponseCode
			,@VerifiedTime         = @VerifiedTime
			,@PaymentCancelledTime = @PaymentCancelledTime
			,@PaymentReasonSID     = @PaymentReasonSID
			,@PaymentRowGUID       = @PaymentRowGUID
			,@ReasonGroupSID       = @ReasonGroupSID
			,@ReasonName           = @ReasonName
			,@ReasonCode           = @ReasonCode
			,@ReasonSequence       = @ReasonSequence
			,@ToolTip              = @ToolTip
			,@ReasonIsActive       = @ReasonIsActive
			,@ReasonRowGUID        = @ReasonRowGUID
			,@IsDeleteEnabled      = @IsDeleteEnabled
			,@IsCancelled          = @IsCancelled
			,@IsEditEnabled        = @IsEditEnabled
			,@GLCheckSum           = @GLCheckSum
			,@IsPaid               = @IsPaid

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
