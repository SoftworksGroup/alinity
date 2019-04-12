SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPAPTransaction#EFInsert]
	 @PAPBatchSID                     int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PAPSubscriptionSID              int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@AccountNo                       varchar(15)       = null							-- required! if not passed value must be set in custom logic prior to insert
	,@InstitutionNo                   varchar(3)        = null							-- required! if not passed value must be set in custom logic prior to insert
	,@TransitNo                       varchar(5)        = null							-- required! if not passed value must be set in custom logic prior to insert
	,@WithdrawalAmount                decimal(11,2)     = null							-- required! if not passed value must be set in custom logic prior to insert
	,@IsRejected                      bit               = null							-- default: (0)
	,@PaymentSID                      int               = null							
	,@UserDefinedColumns              xml               = null							
	,@PAPTransactionXID               varchar(150)      = null							
	,@LegacyKey                       nvarchar(50)      = null							
	,@CreateUser                      nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                    tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                        xml               = null							-- other values defining context for the insert (if any)
	,@BatchID                         varchar(12)       = null							-- not a base table column (default ignored)
	,@BatchSequence                   int               = null							-- not a base table column (default ignored)
	,@WithdrawalDate                  date              = null							-- not a base table column (default ignored)
	,@LockedTime                      datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ProcessedTime                   datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@PAPBatchRowGUID                 uniqueidentifier  = null							-- not a base table column (default ignored)
	,@PAPSubscriptionPersonSID        int               = null							-- not a base table column (default ignored)
	,@PAPSubscriptionInstitutionNo    varchar(3)        = null							-- not a base table column (default ignored)
	,@PAPSubscriptionTransitNo        varchar(5)        = null							-- not a base table column (default ignored)
	,@PAPSubscriptionAccountNo        varchar(15)       = null							-- not a base table column (default ignored)
	,@PAPSubscriptionWithdrawalAmount decimal(11,2)     = null							-- not a base table column (default ignored)
	,@EffectiveTime                   datetime          = null							-- not a base table column (default ignored)
	,@PAPSubscriptionCancelledTime    datetime          = null							-- not a base table column (default ignored)
	,@PAPSubscriptionRowGUID          uniqueidentifier  = null							-- not a base table column (default ignored)
	,@PaymentPersonSID                int               = null							-- not a base table column (default ignored)
	,@PaymentTypeSID                  int               = null							-- not a base table column (default ignored)
	,@PaymentStatusSID                int               = null							-- not a base table column (default ignored)
	,@GLAccountCode                   varchar(50)       = null							-- not a base table column (default ignored)
	,@GLPostingDate                   date              = null							-- not a base table column (default ignored)
	,@DepositDate                     date              = null							-- not a base table column (default ignored)
	,@AmountPaid                      decimal(11,2)     = null							-- not a base table column (default ignored)
	,@Reference                       varchar(25)       = null							-- not a base table column (default ignored)
	,@NameOnCard                      nvarchar(150)     = null							-- not a base table column (default ignored)
	,@PaymentCard                     varchar(20)       = null							-- not a base table column (default ignored)
	,@TransactionID                   varchar(50)       = null							-- not a base table column (default ignored)
	,@LastResponseCode                varchar(50)       = null							-- not a base table column (default ignored)
	,@VerifiedTime                    datetime          = null							-- not a base table column (default ignored)
	,@PaymentCancelledTime            datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ReasonSID                       int               = null							-- not a base table column (default ignored)
	,@PaymentRowGUID                  uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                 bit               = null							-- not a base table column (default ignored)
	,@RegistrantNo                    varchar(50)       = null							-- not a base table column (default ignored)
	,@DisplayName                     nvarchar(65)      = null							-- not a base table column (default ignored)
	,@TotalApplied                    decimal(11,2)     = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPAPTransaction#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPAPTransaction#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pPAPTransaction#Insert
			 @PAPBatchSID                     = @PAPBatchSID
			,@PAPSubscriptionSID              = @PAPSubscriptionSID
			,@AccountNo                       = @AccountNo
			,@InstitutionNo                   = @InstitutionNo
			,@TransitNo                       = @TransitNo
			,@WithdrawalAmount                = @WithdrawalAmount
			,@IsRejected                      = @IsRejected
			,@PaymentSID                      = @PaymentSID
			,@UserDefinedColumns              = @UserDefinedColumns
			,@PAPTransactionXID               = @PAPTransactionXID
			,@LegacyKey                       = @LegacyKey
			,@CreateUser                      = @CreateUser
			,@IsReselected                    = @IsReselected
			,@zContext                        = @zContext
			,@BatchID                         = @BatchID
			,@BatchSequence                   = @BatchSequence
			,@WithdrawalDate                  = @WithdrawalDate
			,@LockedTime                      = @LockedTime
			,@ProcessedTime                   = @ProcessedTime
			,@PAPBatchRowGUID                 = @PAPBatchRowGUID
			,@PAPSubscriptionPersonSID        = @PAPSubscriptionPersonSID
			,@PAPSubscriptionInstitutionNo    = @PAPSubscriptionInstitutionNo
			,@PAPSubscriptionTransitNo        = @PAPSubscriptionTransitNo
			,@PAPSubscriptionAccountNo        = @PAPSubscriptionAccountNo
			,@PAPSubscriptionWithdrawalAmount = @PAPSubscriptionWithdrawalAmount
			,@EffectiveTime                   = @EffectiveTime
			,@PAPSubscriptionCancelledTime    = @PAPSubscriptionCancelledTime
			,@PAPSubscriptionRowGUID          = @PAPSubscriptionRowGUID
			,@PaymentPersonSID                = @PaymentPersonSID
			,@PaymentTypeSID                  = @PaymentTypeSID
			,@PaymentStatusSID                = @PaymentStatusSID
			,@GLAccountCode                   = @GLAccountCode
			,@GLPostingDate                   = @GLPostingDate
			,@DepositDate                     = @DepositDate
			,@AmountPaid                      = @AmountPaid
			,@Reference                       = @Reference
			,@NameOnCard                      = @NameOnCard
			,@PaymentCard                     = @PaymentCard
			,@TransactionID                   = @TransactionID
			,@LastResponseCode                = @LastResponseCode
			,@VerifiedTime                    = @VerifiedTime
			,@PaymentCancelledTime            = @PaymentCancelledTime
			,@ReasonSID                       = @ReasonSID
			,@PaymentRowGUID                  = @PaymentRowGUID
			,@IsDeleteEnabled                 = @IsDeleteEnabled
			,@RegistrantNo                    = @RegistrantNo
			,@DisplayName                     = @DisplayName
			,@TotalApplied                    = @TotalApplied

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
