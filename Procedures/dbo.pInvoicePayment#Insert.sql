SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoicePayment#Insert]
	 @InvoicePaymentSID    int               = null output									-- identity value assigned to the new record
	,@InvoiceSID           int               = null													-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pInvoicePayment#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.InvoicePayment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.InvoicePayment table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vInvoicePayment entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pInvoicePayment procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fInvoicePaymentCheck to test all rules.

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

	set @InvoicePaymentSID = null																						-- initialize output parameter

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

		set @InvoicePaymentXID = ltrim(rtrim(@InvoicePaymentXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @Reference = ltrim(rtrim(@Reference))
		set @NameOnCard = ltrim(rtrim(@NameOnCard))
		set @PaymentCard = ltrim(rtrim(@PaymentCard))
		set @TransactionID = ltrim(rtrim(@TransactionID))
		set @LastResponseCode = ltrim(rtrim(@LastResponseCode))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))

		-- set zero length strings to null to avoid storing them in the record

		if len(@InvoicePaymentXID) = 0 set @InvoicePaymentXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@Reference) = 0 set @Reference = null
		if len(@NameOnCard) = 0 set @NameOnCard = null
		if len(@PaymentCard) = 0 set @PaymentCard = null
		if len(@TransactionID) = 0 set @TransactionID = null
		if len(@LastResponseCode) = 0 set @LastResponseCode = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @AmountApplied = isnull(@AmountApplied,(0.00))
		set @AppliedDate = isnull(@AppliedDate,sf.fToday())
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Oct 2018
		-- Return a GL Posting date for the invoice payment.

		exec dbo.pInvoicePayment#GetGLPostingDate
			@PaymentSID = @PaymentSID
		 ,@UpdateUser = @CreateUser
		 ,@GLPostingDate = @GLPostingDate output;

		-- Tim Edlund | Nov 2018
		-- Ensure the GL Posting date provided is not back-dated
		-- into a closed accounting period as set in configuration.
		-- This is an additional check of logic in the sproc above
		-- to ensure changes do not violate this rule.

		declare
			@acctgTrxLockedDate date

		if @GLPostingDate is not null
		begin

			set @acctgTrxLockedDate = cast(isnull(sf.fConfigParam#Value('AcctgTrxLockedDate'), '20000101') as date);

			if @GLPostingDate <= @acctgTrxLockedDate
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'PeriodIsLocked'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 date provided "%2" is invalid because the accounting period is locked. The locked period ends: %3.'
				 ,@Arg1 = 'GL posting'
				 ,@Arg2 = @GLPostingDate
				 ,@Arg3 = @acctgTrxLockedDate;

				raiserror(@errorText, 18, 1);

			end;
		end

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
				r.RoutineName = 'pInvoicePayment'
		)
		begin
		
			exec @errorNo = ext.pInvoicePayment
				 @Mode                 = 'insert.pre'
				,@InvoiceSID           = @InvoiceSID output
				,@PaymentSID           = @PaymentSID output
				,@AmountApplied        = @AmountApplied output
				,@AppliedDate          = @AppliedDate output
				,@GLPostingDate        = @GLPostingDate output
				,@CancelledTime        = @CancelledTime output
				,@ReasonSID            = @ReasonSID output
				,@UserDefinedColumns   = @UserDefinedColumns output
				,@InvoicePaymentXID    = @InvoicePaymentXID output
				,@LegacyKey            = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.InvoicePayment
		(
			 InvoiceSID
			,PaymentSID
			,AmountApplied
			,AppliedDate
			,GLPostingDate
			,CancelledTime
			,ReasonSID
			,UserDefinedColumns
			,InvoicePaymentXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @InvoiceSID
			,@PaymentSID
			,@AmountApplied
			,@AppliedDate
			,@GLPostingDate
			,@CancelledTime
			,@ReasonSID
			,@UserDefinedColumns
			,@InvoicePaymentXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected      = @@rowcount
			,@InvoicePaymentSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.InvoicePayment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @InvoicePaymentSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Record the GL entry for the new payment
		-- where the payment is in a paid status

		if exists
		(
			select
				1
			from
				dbo.InvoicePayment ip
			join
				dbo.Payment				p on ip.PaymentSID = p.PaymentSID
			join
				dbo.PaymentStatus ps on p.PaymentStatusSID = ps.PaymentStatusSID and ps.IsPaid = @ON	-- must be in a paid status!
			where
				ip.InvoicePaymentSID = @InvoicePaymentSID
		)	
		begin

			exec dbo.pGLTransaction#PostInvoicePayment
				 @InvoicePaymentSID = @InvoicePaymentSID
				,@PostingDate = @GLPostingDate																		-- this date is set in the pre-insert logic above
				,@ActionCode = 'INSERT';	

		end;

		-- Tim Edlund | Apr 2018
		-- If the applied payment is against an invoice related to a registration
		-- form (Application, Renewal, Reinstatement or Registration Change) then
		-- a Registration is created for it if the invoice is fully paid and the
		-- form APPROVED. These conditions are checked and action performed through
		-- a separate procedure call.

		exec dbo.pRegistration#SetOnPaid
			@InvoicePaymentSID = @InvoicePaymentSID
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
				r.RoutineName = 'pInvoicePayment'
		)
		begin
		
			exec @errorNo = ext.pInvoicePayment
				 @Mode                 = 'insert.post'
				,@InvoicePaymentSID    = @InvoicePaymentSID
				,@InvoiceSID           = @InvoiceSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.InvoicePaymentSID
			from
				dbo.vInvoicePayment ent
			where
				ent.InvoicePaymentSID = @InvoicePaymentSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.InvoicePaymentSID
				,ent.InvoiceSID
				,ent.PaymentSID
				,ent.AmountApplied
				,ent.AppliedDate
				,ent.GLPostingDate
				,ent.CancelledTime
				,ent.ReasonSID
				,ent.UserDefinedColumns
				,ent.InvoicePaymentXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.InvoicePersonSID
				,ent.InvoiceDate
				,ent.Tax1Label
				,ent.Tax1Rate
				,ent.Tax1GLAccountCode
				,ent.Tax2Label
				,ent.Tax2Rate
				,ent.Tax2GLAccountCode
				,ent.Tax3Label
				,ent.Tax3Rate
				,ent.Tax3GLAccountCode
				,ent.RegistrationYear
				,ent.InvoiceCancelledTime
				,ent.InvoiceReasonSID
				,ent.IsRefund
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
				,ent.PaymentPersonSID
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
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsCancelled
				,ent.IsEditEnabled
				,ent.GLCheckSum
				,ent.IsPaid
			from
				dbo.vInvoicePayment ent
			where
				ent.InvoicePaymentSID = @InvoicePaymentSID

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
