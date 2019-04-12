SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPAPTransaction#Insert]
	 @PAPTransactionSID               int               = null output				-- identity value assigned to the new record
	,@PAPBatchSID                     int               = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pPAPTransaction#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PAPTransaction table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PAPTransaction table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPAPTransaction entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPAPTransaction procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

Business rule compliance is checked through a table constraint which calls fPAPTransactionCheck to test all rules.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@errorText                                    nvarchar(4000)					-- message text (for business rule errors)
		,@rowsAffected                                 int = 0								-- tracks rows impacted by the operation (error check)
		,@recordSID                                    int										-- tracks primary key value for clearing current default
		,@ON                                           bit = cast(1 as bit)		-- constant for bit comparison and assignments
		,@OFF                                          bit = cast(0 as bit)		-- constant for bit comparison and assignments

	set @PAPTransactionSID = null																						-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @AccountNo = ltrim(rtrim(@AccountNo))
		set @InstitutionNo = ltrim(rtrim(@InstitutionNo))
		set @TransitNo = ltrim(rtrim(@TransitNo))
		set @PAPTransactionXID = ltrim(rtrim(@PAPTransactionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @BatchID = ltrim(rtrim(@BatchID))
		set @PAPSubscriptionInstitutionNo = ltrim(rtrim(@PAPSubscriptionInstitutionNo))
		set @PAPSubscriptionTransitNo = ltrim(rtrim(@PAPSubscriptionTransitNo))
		set @PAPSubscriptionAccountNo = ltrim(rtrim(@PAPSubscriptionAccountNo))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @Reference = ltrim(rtrim(@Reference))
		set @NameOnCard = ltrim(rtrim(@NameOnCard))
		set @PaymentCard = ltrim(rtrim(@PaymentCard))
		set @TransactionID = ltrim(rtrim(@TransactionID))
		set @LastResponseCode = ltrim(rtrim(@LastResponseCode))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @DisplayName = ltrim(rtrim(@DisplayName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@AccountNo) = 0 set @AccountNo = null
		if len(@InstitutionNo) = 0 set @InstitutionNo = null
		if len(@TransitNo) = 0 set @TransitNo = null
		if len(@PAPTransactionXID) = 0 set @PAPTransactionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@BatchID) = 0 set @BatchID = null
		if len(@PAPSubscriptionInstitutionNo) = 0 set @PAPSubscriptionInstitutionNo = null
		if len(@PAPSubscriptionTransitNo) = 0 set @PAPSubscriptionTransitNo = null
		if len(@PAPSubscriptionAccountNo) = 0 set @PAPSubscriptionAccountNo = null
		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@Reference) = 0 set @Reference = null
		if len(@NameOnCard) = 0 set @NameOnCard = null
		if len(@PaymentCard) = 0 set @PaymentCard = null
		if len(@TransactionID) = 0 set @TransactionID = null
		if len(@LastResponseCode) = 0 set @LastResponseCode = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@DisplayName) = 0 set @DisplayName = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsRejected = isnull(@IsRejected,(0))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pPAPTransaction'
		)
		begin
		
			exec @errorNo = ext.pPAPTransaction
				 @Mode                            = 'insert.pre'
				,@PAPBatchSID                     = @PAPBatchSID output
				,@PAPSubscriptionSID              = @PAPSubscriptionSID output
				,@AccountNo                       = @AccountNo output
				,@InstitutionNo                   = @InstitutionNo output
				,@TransitNo                       = @TransitNo output
				,@WithdrawalAmount                = @WithdrawalAmount output
				,@IsRejected                      = @IsRejected output
				,@PaymentSID                      = @PaymentSID output
				,@UserDefinedColumns              = @UserDefinedColumns output
				,@PAPTransactionXID               = @PAPTransactionXID output
				,@LegacyKey                       = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.PAPTransaction
		(
			 PAPBatchSID
			,PAPSubscriptionSID
			,AccountNo
			,InstitutionNo
			,TransitNo
			,WithdrawalAmount
			,IsRejected
			,PaymentSID
			,UserDefinedColumns
			,PAPTransactionXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PAPBatchSID
			,@PAPSubscriptionSID
			,@AccountNo
			,@InstitutionNo
			,@TransitNo
			,@WithdrawalAmount
			,@IsRejected
			,@PaymentSID
			,@UserDefinedColumns
			,@PAPTransactionXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected      = @@rowcount
			,@PAPTransactionSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PAPTransaction'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PAPTransactionSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pPAPTransaction'
		)
		begin
		
			exec @errorNo = ext.pPAPTransaction
				 @Mode                            = 'insert.post'
				,@PAPTransactionSID               = @PAPTransactionSID
				,@PAPBatchSID                     = @PAPBatchSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PAPTransactionSID
			from
				dbo.vPAPTransaction ent
			where
				ent.PAPTransactionSID = @PAPTransactionSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PAPTransactionSID
				,ent.PAPBatchSID
				,ent.PAPSubscriptionSID
				,ent.AccountNo
				,ent.InstitutionNo
				,ent.TransitNo
				,ent.WithdrawalAmount
				,ent.IsRejected
				,ent.PaymentSID
				,ent.UserDefinedColumns
				,ent.PAPTransactionXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.BatchID
				,ent.BatchSequence
				,ent.WithdrawalDate
				,ent.LockedTime
				,ent.ProcessedTime
				,ent.PAPBatchRowGUID
				,ent.PAPSubscriptionPersonSID
				,ent.PAPSubscriptionInstitutionNo
				,ent.PAPSubscriptionTransitNo
				,ent.PAPSubscriptionAccountNo
				,ent.PAPSubscriptionWithdrawalAmount
				,ent.EffectiveTime
				,ent.PAPSubscriptionCancelledTime
				,ent.PAPSubscriptionRowGUID
				,ent.PaymentPersonSID
				,ent.PaymentTypeSID
				,ent.PaymentStatusSID
				,ent.GLAccountCode
				,ent.GLPostingDate
				,ent.DepositDate
				,ent.AmountPaid
				,ent.Reference
				,ent.NameOnCard
				,ent.PaymentCard
				,ent.TransactionID
				,ent.LastResponseCode
				,ent.VerifiedTime
				,ent.PaymentCancelledTime
				,ent.ReasonSID
				,ent.PaymentRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantNo
				,ent.DisplayName
				,ent.TotalApplied
			from
				dbo.vPAPTransaction ent
			where
				ent.PAPTransactionSID = @PAPTransactionSID

		end

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
