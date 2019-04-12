SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPayment#EFInsert]
	 @PersonSID                   int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@PaymentTypeSID              int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@PaymentStatusSID            int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@GLAccountCode               varchar(50)       = null									-- required! if not passed value must be set in custom logic prior to insert
	,@GLPostingDate               date              = null									
	,@DepositDate                 date              = null									
	,@AmountPaid                  decimal(11,2)     = null									-- required! if not passed value must be set in custom logic prior to insert
	,@Reference                   varchar(25)       = null									
	,@NameOnCard                  nvarchar(150)     = null									
	,@PaymentCard                 varchar(20)       = null									
	,@TransactionID               varchar(50)       = null									
	,@LastResponseCode            varchar(50)       = null									
	,@LastResponseMessage         nvarchar(max)     = null									
	,@VerifiedTime                datetime          = null									
	,@CancelledTime               datetimeoffset(7) = null									
	,@ReasonSID                   int               = null									
	,@UserDefinedColumns          xml               = null									
	,@PaymentXID                  varchar(150)      = null									
	,@LegacyKey                   nvarchar(50)      = null									
	,@CreateUser                  nvarchar(75)      = null									-- default: suser_sname()
	,@IsReselected                tinyint           = null									-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                    xml               = null									-- other values defining context for the insert (if any)
	,@PaymentStatusSCD            varchar(25)       = null									-- not a base table column (default ignored)
	,@PaymentStatusLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@IsPaid                      bit               = null									-- not a base table column (default ignored)
	,@PaymentStatusSequence       int               = null									-- not a base table column (default ignored)
	,@PaymentStatusRowGUID        uniqueidentifier  = null									-- not a base table column (default ignored)
	,@PaymentTypeSCD              varchar(15)       = null									-- not a base table column (default ignored)
	,@PaymentTypeLabel            nvarchar(35)      = null									-- not a base table column (default ignored)
	,@PaymentTypeCategory         nvarchar(65)      = null									-- not a base table column (default ignored)
	,@GLAccountSID                int               = null									-- not a base table column (default ignored)
	,@PaymentTypePaymentStatusSID int               = null									-- not a base table column (default ignored)
	,@IsReferenceRequired         bit               = null									-- not a base table column (default ignored)
	,@DepositDateLagDays          smallint          = null									-- not a base table column (default ignored)
	,@IsRefundExcludedFromGL      bit               = null									-- not a base table column (default ignored)
	,@ExcludeDepositFromGLBefore  date              = null									-- not a base table column (default ignored)
	,@PaymentTypeIsDefault        bit               = null									-- not a base table column (default ignored)
	,@PaymentTypeIsActive         bit               = null									-- not a base table column (default ignored)
	,@PaymentTypeRowGUID          uniqueidentifier  = null									-- not a base table column (default ignored)
	,@GenderSID                   int               = null									-- not a base table column (default ignored)
	,@NamePrefixSID               int               = null									-- not a base table column (default ignored)
	,@FirstName                   nvarchar(30)      = null									-- not a base table column (default ignored)
	,@CommonName                  nvarchar(30)      = null									-- not a base table column (default ignored)
	,@MiddleNames                 nvarchar(30)      = null									-- not a base table column (default ignored)
	,@LastName                    nvarchar(35)      = null									-- not a base table column (default ignored)
	,@BirthDate                   date              = null									-- not a base table column (default ignored)
	,@DeathDate                   date              = null									-- not a base table column (default ignored)
	,@HomePhone                   varchar(25)       = null									-- not a base table column (default ignored)
	,@MobilePhone                 varchar(25)       = null									-- not a base table column (default ignored)
	,@IsTextMessagingEnabled      bit               = null									-- not a base table column (default ignored)
	,@ImportBatch                 nvarchar(100)     = null									-- not a base table column (default ignored)
	,@PersonRowGUID               uniqueidentifier  = null									-- not a base table column (default ignored)
	,@ReasonGroupSID              int               = null									-- not a base table column (default ignored)
	,@ReasonName                  nvarchar(50)      = null									-- not a base table column (default ignored)
	,@ReasonCode                  varchar(25)       = null									-- not a base table column (default ignored)
	,@ReasonSequence              smallint          = null									-- not a base table column (default ignored)
	,@ToolTip                     nvarchar(500)     = null									-- not a base table column (default ignored)
	,@ReasonIsActive              bit               = null									-- not a base table column (default ignored)
	,@ReasonRowGUID               uniqueidentifier  = null									-- not a base table column (default ignored)
	,@IsDeleteEnabled             bit               = null									-- not a base table column (default ignored)
	,@PaymentLabel                nvarchar(4000)    = null									-- not a base table column (default ignored)
	,@PaymentShortLabel           nvarchar(4000)    = null									-- not a base table column (default ignored)
	,@RegistrantLabel             nvarchar(75)      = null									-- not a base table column (default ignored)
	,@IsOnlinePayment             bit               = null									-- not a base table column (default ignored)
	,@TotalApplied                decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalUnapplied              decimal(11,2)     = null									-- not a base table column (default ignored)
	,@IsFullyApplied              bit               = null									-- not a base table column (default ignored)
	,@IsNotApplied                bit               = null									-- not a base table column (default ignored)
	,@IsPartiallyApplied          bit               = null									-- not a base table column (default ignored)
	,@IsOverApplied               bit               = null									-- not a base table column (default ignored)
	,@IsCancelled                 bit               = null									-- not a base table column (default ignored)
	,@IsCancelEnabled             bit               = null									-- not a base table column (default ignored)
	,@IsEditEnabled               bit               = null									-- not a base table column (default ignored)
	,@GLCheckSum                  int               = null									-- not a base table column (default ignored)
	,@LatestTransactionID         varchar(50)       = null									-- not a base table column (default ignored)
	,@LatestChargeTotal           decimal(11,2)     = null									-- not a base table column (default ignored)
	,@LatestResponseCode          int               = null									-- not a base table column (default ignored)
	,@LatestMessage               varchar(8000)     = null									-- not a base table column (default ignored)
	,@LatestApprovalCode          varchar(25)       = null									-- not a base table column (default ignored)
	,@LatestIsPaid                bit               = null									-- not a base table column (default ignored)
	,@LatestVerifiedTime          datetime          = null									-- not a base table column (default ignored)
	,@IsRetryEnabled              bit               = null									-- not a base table column (default ignored)
	,@IsReapplyEnabled            bit               = null									-- not a base table column (default ignored)
	,@TransactionIDReference      nvarchar(150)     = null									-- not a base table column (default ignored)
	,@VerifiedTimeComponent       time(7)           = null									-- not a base table column (default ignored)
	,@InvoiceSID                  int               = null									-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPayment#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPayment#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pPayment#Insert
			 @PersonSID                   = @PersonSID
			,@PaymentTypeSID              = @PaymentTypeSID
			,@PaymentStatusSID            = @PaymentStatusSID
			,@GLAccountCode               = @GLAccountCode
			,@GLPostingDate               = @GLPostingDate
			,@DepositDate                 = @DepositDate
			,@AmountPaid                  = @AmountPaid
			,@Reference                   = @Reference
			,@NameOnCard                  = @NameOnCard
			,@PaymentCard                 = @PaymentCard
			,@TransactionID               = @TransactionID
			,@LastResponseCode            = @LastResponseCode
			,@LastResponseMessage         = @LastResponseMessage
			,@VerifiedTime                = @VerifiedTime
			,@CancelledTime               = @CancelledTime
			,@ReasonSID                   = @ReasonSID
			,@UserDefinedColumns          = @UserDefinedColumns
			,@PaymentXID                  = @PaymentXID
			,@LegacyKey                   = @LegacyKey
			,@CreateUser                  = @CreateUser
			,@IsReselected                = @IsReselected
			,@zContext                    = @zContext
			,@PaymentStatusSCD            = @PaymentStatusSCD
			,@PaymentStatusLabel          = @PaymentStatusLabel
			,@IsPaid                      = @IsPaid
			,@PaymentStatusSequence       = @PaymentStatusSequence
			,@PaymentStatusRowGUID        = @PaymentStatusRowGUID
			,@PaymentTypeSCD              = @PaymentTypeSCD
			,@PaymentTypeLabel            = @PaymentTypeLabel
			,@PaymentTypeCategory         = @PaymentTypeCategory
			,@GLAccountSID                = @GLAccountSID
			,@PaymentTypePaymentStatusSID = @PaymentTypePaymentStatusSID
			,@IsReferenceRequired         = @IsReferenceRequired
			,@DepositDateLagDays          = @DepositDateLagDays
			,@IsRefundExcludedFromGL      = @IsRefundExcludedFromGL
			,@ExcludeDepositFromGLBefore  = @ExcludeDepositFromGLBefore
			,@PaymentTypeIsDefault        = @PaymentTypeIsDefault
			,@PaymentTypeIsActive         = @PaymentTypeIsActive
			,@PaymentTypeRowGUID          = @PaymentTypeRowGUID
			,@GenderSID                   = @GenderSID
			,@NamePrefixSID               = @NamePrefixSID
			,@FirstName                   = @FirstName
			,@CommonName                  = @CommonName
			,@MiddleNames                 = @MiddleNames
			,@LastName                    = @LastName
			,@BirthDate                   = @BirthDate
			,@DeathDate                   = @DeathDate
			,@HomePhone                   = @HomePhone
			,@MobilePhone                 = @MobilePhone
			,@IsTextMessagingEnabled      = @IsTextMessagingEnabled
			,@ImportBatch                 = @ImportBatch
			,@PersonRowGUID               = @PersonRowGUID
			,@ReasonGroupSID              = @ReasonGroupSID
			,@ReasonName                  = @ReasonName
			,@ReasonCode                  = @ReasonCode
			,@ReasonSequence              = @ReasonSequence
			,@ToolTip                     = @ToolTip
			,@ReasonIsActive              = @ReasonIsActive
			,@ReasonRowGUID               = @ReasonRowGUID
			,@IsDeleteEnabled             = @IsDeleteEnabled
			,@PaymentLabel                = @PaymentLabel
			,@PaymentShortLabel           = @PaymentShortLabel
			,@RegistrantLabel             = @RegistrantLabel
			,@IsOnlinePayment             = @IsOnlinePayment
			,@TotalApplied                = @TotalApplied
			,@TotalUnapplied              = @TotalUnapplied
			,@IsFullyApplied              = @IsFullyApplied
			,@IsNotApplied                = @IsNotApplied
			,@IsPartiallyApplied          = @IsPartiallyApplied
			,@IsOverApplied               = @IsOverApplied
			,@IsCancelled                 = @IsCancelled
			,@IsCancelEnabled             = @IsCancelEnabled
			,@IsEditEnabled               = @IsEditEnabled
			,@GLCheckSum                  = @GLCheckSum
			,@LatestTransactionID         = @LatestTransactionID
			,@LatestChargeTotal           = @LatestChargeTotal
			,@LatestResponseCode          = @LatestResponseCode
			,@LatestMessage               = @LatestMessage
			,@LatestApprovalCode          = @LatestApprovalCode
			,@LatestIsPaid                = @LatestIsPaid
			,@LatestVerifiedTime          = @LatestVerifiedTime
			,@IsRetryEnabled              = @IsRetryEnabled
			,@IsReapplyEnabled            = @IsReapplyEnabled
			,@TransactionIDReference      = @TransactionIDReference
			,@VerifiedTimeComponent       = @VerifiedTimeComponent
			,@InvoiceSID                  = @InvoiceSID

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
