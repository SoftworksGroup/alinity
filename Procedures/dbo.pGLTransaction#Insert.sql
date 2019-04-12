SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pGLTransaction#Insert]
	 @GLTransactionSID            int               = null output						-- identity value assigned to the new record
	,@PaymentSID                  int               = null									-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pGLTransaction#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.GLTransaction table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.GLTransaction table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vGLTransaction entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pGLTransaction procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fGLTransactionCheck to test all rules.

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

	set @GLTransactionSID = null																						-- initialize output parameter

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

		set @DebitGLAccountCode = ltrim(rtrim(@DebitGLAccountCode))
		set @CreditGLAccountCode = ltrim(rtrim(@CreditGLAccountCode))
		set @GLTransactionXID = ltrim(rtrim(@GLTransactionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @Reference = ltrim(rtrim(@Reference))
		set @NameOnCard = ltrim(rtrim(@NameOnCard))
		set @PaymentCard = ltrim(rtrim(@PaymentCard))
		set @TransactionID = ltrim(rtrim(@TransactionID))
		set @LastResponseCode = ltrim(rtrim(@LastResponseCode))
		set @FullDebitAccountLabel = ltrim(rtrim(@FullDebitAccountLabel))
		set @FullCreditAccountLabel = ltrim(rtrim(@FullCreditAccountLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@DebitGLAccountCode) = 0 set @DebitGLAccountCode = null
		if len(@CreditGLAccountCode) = 0 set @CreditGLAccountCode = null
		if len(@GLTransactionXID) = 0 set @GLTransactionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@Reference) = 0 set @Reference = null
		if len(@NameOnCard) = 0 set @NameOnCard = null
		if len(@PaymentCard) = 0 set @PaymentCard = null
		if len(@TransactionID) = 0 set @TransactionID = null
		if len(@LastResponseCode) = 0 set @LastResponseCode = null
		if len(@FullDebitAccountLabel) = 0 set @FullDebitAccountLabel = null
		if len(@FullCreditAccountLabel) = 0 set @FullCreditAccountLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsExcluded = isnull(@IsExcluded,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected             = isnull(@IsReselected            ,(0))

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
				r.RoutineName = 'pGLTransaction'
		)
		begin
		
			exec @errorNo = ext.pGLTransaction
				 @Mode                        = 'insert.pre'
				,@PaymentSID                  = @PaymentSID output
				,@InvoicePaymentSID           = @InvoicePaymentSID output
				,@DebitGLAccountCode          = @DebitGLAccountCode output
				,@CreditGLAccountCode         = @CreditGLAccountCode output
				,@Amount                      = @Amount output
				,@GLPostingDate               = @GLPostingDate output
				,@PaymentCheckSum             = @PaymentCheckSum output
				,@InvoicePaymentCheckSum      = @InvoicePaymentCheckSum output
				,@ReversedGLTransactionSID    = @ReversedGLTransactionSID output
				,@IsExcluded                  = @IsExcluded output
				,@UserDefinedColumns          = @UserDefinedColumns output
				,@GLTransactionXID            = @GLTransactionXID output
				,@LegacyKey                   = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.GLTransaction
		(
			 PaymentSID
			,InvoicePaymentSID
			,DebitGLAccountCode
			,CreditGLAccountCode
			,Amount
			,GLPostingDate
			,PaymentCheckSum
			,InvoicePaymentCheckSum
			,ReversedGLTransactionSID
			,IsExcluded
			,UserDefinedColumns
			,GLTransactionXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PaymentSID
			,@InvoicePaymentSID
			,@DebitGLAccountCode
			,@CreditGLAccountCode
			,@Amount
			,@GLPostingDate
			,@PaymentCheckSum
			,@InvoicePaymentCheckSum
			,@ReversedGLTransactionSID
			,@IsExcluded
			,@UserDefinedColumns
			,@GLTransactionXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected     = @@rowcount
			,@GLTransactionSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.GLTransaction'
				,@Arg3        = @rowsAffected
				,@Arg4        = @GLTransactionSID
			
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
				r.RoutineName = 'pGLTransaction'
		)
		begin
		
			exec @errorNo = ext.pGLTransaction
				 @Mode                        = 'insert.post'
				,@GLTransactionSID            = @GLTransactionSID
				,@PaymentSID                  = @PaymentSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.GLTransactionSID
			from
				dbo.vGLTransaction ent
			where
				ent.GLTransactionSID = @GLTransactionSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.GLTransactionSID
				,ent.PaymentSID
				,ent.InvoicePaymentSID
				,ent.DebitGLAccountCode
				,ent.CreditGLAccountCode
				,ent.Amount
				,ent.GLPostingDate
				,ent.PaymentCheckSum
				,ent.InvoicePaymentCheckSum
				,ent.ReversedGLTransactionSID
				,ent.IsExcluded
				,ent.UserDefinedColumns
				,ent.GLTransactionXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonSID
				,ent.PaymentTypeSID
				,ent.PaymentStatusSID
				,ent.GLAccountCode
				,ent.PaymentGLPostingDate
				,ent.DepositDate
				,ent.AmountPaid
				,ent.Reference
				,ent.NameOnCard
				,ent.PaymentCard
				,ent.TransactionID
				,ent.LastResponseCode
				,ent.VerifiedTime
				,ent.PaymentCancelledTime
				,ent.PaymentReasonSID
				,ent.PaymentRowGUID
				,ent.InvoiceSID
				,ent.InvoicePaymentPaymentSID
				,ent.AmountApplied
				,ent.AppliedDate
				,ent.InvoicePaymentGLPostingDate
				,ent.InvoicePaymentCancelledTime
				,ent.InvoicePaymentReasonSID
				,ent.InvoicePaymentRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsEditEnabled
				,ent.FullDebitAccountLabel
				,ent.FullCreditAccountLabel
				,ent.IsReversing
				,ent.IsReversed
			from
				dbo.vGLTransaction ent
			where
				ent.GLTransactionSID = @GLTransactionSID

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
