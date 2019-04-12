SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoicePayment#Update]
	 @InvoicePaymentSID    int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@InvoiceSID           int               = null -- table column values to update:
	,@PaymentSID           int               = null
	,@AmountApplied        decimal(11,2)     = null
	,@AppliedDate          date              = null
	,@GLPostingDate        date              = null
	,@CancelledTime        datetimeoffset(7) = null
	,@ReasonSID            int               = null
	,@UserDefinedColumns   xml               = null
	,@InvoicePaymentXID    varchar(150)      = null
	,@LegacyKey            nvarchar(50)      = null
	,@UpdateUser           nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp             timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected         tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied        bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext             xml               = null -- other values defining context for the update (if any)
	,@InvoicePersonSID     int               = null -- not a base table column
	,@InvoiceDate          date              = null -- not a base table column
	,@Tax1Label            nvarchar(8)       = null -- not a base table column
	,@Tax1Rate             decimal(4,4)      = null -- not a base table column
	,@Tax1GLAccountCode    varchar(50)       = null -- not a base table column
	,@Tax2Label            nvarchar(8)       = null -- not a base table column
	,@Tax2Rate             decimal(4,4)      = null -- not a base table column
	,@Tax2GLAccountCode    varchar(50)       = null -- not a base table column
	,@Tax3Label            nvarchar(8)       = null -- not a base table column
	,@Tax3Rate             decimal(4,4)      = null -- not a base table column
	,@Tax3GLAccountCode    varchar(50)       = null -- not a base table column
	,@RegistrationYear     smallint          = null -- not a base table column
	,@InvoiceCancelledTime datetimeoffset(7) = null -- not a base table column
	,@InvoiceReasonSID     int               = null -- not a base table column
	,@IsRefund             bit               = null -- not a base table column
	,@ComplaintSID         int               = null -- not a base table column
	,@InvoiceRowGUID       uniqueidentifier  = null -- not a base table column
	,@PaymentPersonSID     int               = null -- not a base table column
	,@PaymentTypeSID       int               = null -- not a base table column
	,@PaymentStatusSID     int               = null -- not a base table column
	,@GLAccountCode        varchar(50)       = null -- not a base table column
	,@PaymentGLPostingDate date              = null -- not a base table column
	,@DepositDate          date              = null -- not a base table column
	,@AmountPaid           decimal(11,2)     = null -- not a base table column
	,@Reference            varchar(25)       = null -- not a base table column
	,@NameOnCard           nvarchar(150)     = null -- not a base table column
	,@PaymentCard          varchar(20)       = null -- not a base table column
	,@TransactionID        varchar(50)       = null -- not a base table column
	,@LastResponseCode     varchar(50)       = null -- not a base table column
	,@VerifiedTime         datetime          = null -- not a base table column
	,@PaymentCancelledTime datetimeoffset(7) = null -- not a base table column
	,@PaymentReasonSID     int               = null -- not a base table column
	,@PaymentRowGUID       uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID       int               = null -- not a base table column
	,@ReasonName           nvarchar(50)      = null -- not a base table column
	,@ReasonCode           varchar(25)       = null -- not a base table column
	,@ReasonSequence       smallint          = null -- not a base table column
	,@ToolTip              nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive       bit               = null -- not a base table column
	,@ReasonRowGUID        uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled      bit               = null -- not a base table column
	,@IsCancelled          bit               = null -- not a base table column
	,@IsEditEnabled        bit               = null -- not a base table column
	,@GLCheckSum           int               = null -- not a base table column
	,@IsPaid               bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoicePayment#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.InvoicePayment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.InvoicePayment table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vInvoicePayment entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pInvoicePayment procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

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

		-- check parameters

		if @InvoicePaymentSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@InvoicePaymentSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @InvoicePaymentXID = ltrim(rtrim(@InvoicePaymentXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @InvoiceSID           = isnull(@InvoiceSID,ip.InvoiceSID)
				,@PaymentSID           = isnull(@PaymentSID,ip.PaymentSID)
				,@AmountApplied        = isnull(@AmountApplied,ip.AmountApplied)
				,@AppliedDate          = isnull(@AppliedDate,ip.AppliedDate)
				,@GLPostingDate        = isnull(@GLPostingDate,ip.GLPostingDate)
				,@CancelledTime        = isnull(@CancelledTime,ip.CancelledTime)
				,@ReasonSID            = isnull(@ReasonSID,ip.ReasonSID)
				,@UserDefinedColumns   = isnull(@UserDefinedColumns,ip.UserDefinedColumns)
				,@InvoicePaymentXID    = isnull(@InvoicePaymentXID,ip.InvoicePaymentXID)
				,@LegacyKey            = isnull(@LegacyKey,ip.LegacyKey)
				,@UpdateUser           = isnull(@UpdateUser,ip.UpdateUser)
				,@IsReselected         = isnull(@IsReselected,ip.IsReselected)
				,@IsNullApplied        = isnull(@IsNullApplied,ip.IsNullApplied)
				,@zContext             = isnull(@zContext,ip.zContext)
				,@InvoicePersonSID     = isnull(@InvoicePersonSID,ip.InvoicePersonSID)
				,@InvoiceDate          = isnull(@InvoiceDate,ip.InvoiceDate)
				,@Tax1Label            = isnull(@Tax1Label,ip.Tax1Label)
				,@Tax1Rate             = isnull(@Tax1Rate,ip.Tax1Rate)
				,@Tax1GLAccountCode    = isnull(@Tax1GLAccountCode,ip.Tax1GLAccountCode)
				,@Tax2Label            = isnull(@Tax2Label,ip.Tax2Label)
				,@Tax2Rate             = isnull(@Tax2Rate,ip.Tax2Rate)
				,@Tax2GLAccountCode    = isnull(@Tax2GLAccountCode,ip.Tax2GLAccountCode)
				,@Tax3Label            = isnull(@Tax3Label,ip.Tax3Label)
				,@Tax3Rate             = isnull(@Tax3Rate,ip.Tax3Rate)
				,@Tax3GLAccountCode    = isnull(@Tax3GLAccountCode,ip.Tax3GLAccountCode)
				,@RegistrationYear     = isnull(@RegistrationYear,ip.RegistrationYear)
				,@InvoiceCancelledTime = isnull(@InvoiceCancelledTime,ip.InvoiceCancelledTime)
				,@InvoiceReasonSID     = isnull(@InvoiceReasonSID,ip.InvoiceReasonSID)
				,@IsRefund             = isnull(@IsRefund,ip.IsRefund)
				,@ComplaintSID         = isnull(@ComplaintSID,ip.ComplaintSID)
				,@InvoiceRowGUID       = isnull(@InvoiceRowGUID,ip.InvoiceRowGUID)
				,@PaymentPersonSID     = isnull(@PaymentPersonSID,ip.PaymentPersonSID)
				,@PaymentTypeSID       = isnull(@PaymentTypeSID,ip.PaymentTypeSID)
				,@PaymentStatusSID     = isnull(@PaymentStatusSID,ip.PaymentStatusSID)
				,@GLAccountCode        = isnull(@GLAccountCode,ip.GLAccountCode)
				,@PaymentGLPostingDate = isnull(@PaymentGLPostingDate,ip.PaymentGLPostingDate)
				,@DepositDate          = isnull(@DepositDate,ip.DepositDate)
				,@AmountPaid           = isnull(@AmountPaid,ip.AmountPaid)
				,@Reference            = isnull(@Reference,ip.Reference)
				,@NameOnCard           = isnull(@NameOnCard,ip.NameOnCard)
				,@PaymentCard          = isnull(@PaymentCard,ip.PaymentCard)
				,@TransactionID        = isnull(@TransactionID,ip.TransactionID)
				,@LastResponseCode     = isnull(@LastResponseCode,ip.LastResponseCode)
				,@VerifiedTime         = isnull(@VerifiedTime,ip.VerifiedTime)
				,@PaymentCancelledTime = isnull(@PaymentCancelledTime,ip.PaymentCancelledTime)
				,@PaymentReasonSID     = isnull(@PaymentReasonSID,ip.PaymentReasonSID)
				,@PaymentRowGUID       = isnull(@PaymentRowGUID,ip.PaymentRowGUID)
				,@ReasonGroupSID       = isnull(@ReasonGroupSID,ip.ReasonGroupSID)
				,@ReasonName           = isnull(@ReasonName,ip.ReasonName)
				,@ReasonCode           = isnull(@ReasonCode,ip.ReasonCode)
				,@ReasonSequence       = isnull(@ReasonSequence,ip.ReasonSequence)
				,@ToolTip              = isnull(@ToolTip,ip.ToolTip)
				,@ReasonIsActive       = isnull(@ReasonIsActive,ip.ReasonIsActive)
				,@ReasonRowGUID        = isnull(@ReasonRowGUID,ip.ReasonRowGUID)
				,@IsDeleteEnabled      = isnull(@IsDeleteEnabled,ip.IsDeleteEnabled)
				,@IsCancelled          = isnull(@IsCancelled,ip.IsCancelled)
				,@IsEditEnabled        = isnull(@IsEditEnabled,ip.IsEditEnabled)
				,@GLCheckSum           = isnull(@GLCheckSum,ip.GLCheckSum)
				,@IsPaid               = isnull(@IsPaid,ip.IsPaid)
			from
				dbo.vInvoicePayment ip
			where
				ip.InvoicePaymentSID = @InvoicePaymentSID

		end
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ReasonSID from dbo.InvoicePayment x where x.InvoicePaymentSID = @InvoicePaymentSID) <> @ReasonSID
		begin
			if (select x.IsActive from dbo.Reason x where x.ReasonSID = @ReasonSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'reason'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Oct 2018
		-- Return a GL Posting date for the invoice payment.

		exec dbo.pInvoicePayment#GetGLPostingDate
			@PaymentSID = @PaymentSID
		 ,@UpdateUser = @UpdateUser
		 ,@GLPostingDate = @GLPostingDate output;

		-- Tim Edlund | Nov 2018
		-- If the GL Posting date is being modified, ensure the new date is not
		-- back-dated into a closed accounting period as set in configuration.
		-- This is an additional check of logic in the sproc above to ensure changes
		-- do not violate this rule.

		declare
			@acctgTrxLockedDate date

		if @GLPostingDate is not null and not exists(select 1 from dbo.Payment pmt where pmt.PaymentSID = @PaymentSID and pmt.GLPostingDate = @GLPostingDate)
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
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
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
				 @Mode                 = 'update.pre'
				,@InvoicePaymentSID    = @InvoicePaymentSID
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
				,@UpdateUser           = @UpdateUser
				,@RowStamp             = @RowStamp
				,@IsReselected         = @IsReselected
				,@IsNullApplied        = @IsNullApplied
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

		-- update the record

		update
			dbo.InvoicePayment
		set
			 InvoiceSID = @InvoiceSID
			,PaymentSID = @PaymentSID
			,AmountApplied = @AmountApplied
			,AppliedDate = @AppliedDate
			,GLPostingDate = @GLPostingDate
			,CancelledTime = @CancelledTime
			,ReasonSID = @ReasonSID
			,UserDefinedColumns = @UserDefinedColumns
			,InvoicePaymentXID = @InvoicePaymentXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			InvoicePaymentSID = @InvoicePaymentSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.InvoicePayment where InvoicePaymentSID = @invoicePaymentSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.InvoicePayment'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.InvoicePayment'
					,@Arg2        = @invoicePaymentSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'dbo.InvoicePayment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @invoicePaymentSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Oct 2017
		-- Record the GL entry for the updated applied payment.

		if not exists (select 1 from dbo.GLTransaction gt	where gt.PaymentSID = @PaymentSID)
		begin
			set @GLCheckSum = -1; -- if no GL transactions exist force the call to #post
		end;
		else
		begin

			select
				@recordSID = ipx.GLCheckSum
			from
				dbo.vInvoicePayment#Ext ipx
			where
				ipx.InvoicePaymentSID = @InvoicePaymentSID;

		end;

		if sf.fIsDifferent(@GLCheckSum, @recordSID) = @ON
		begin

			exec dbo.pGLTransaction#PostInvoicePayment
				@InvoicePaymentSID = @InvoicePaymentSID
			 ,@ActionCode = 'UPDATE'
			 ,@PreviousCheckSum = @GLCheckSum
			 ,@PostingDate = @GLPostingDate

		end;

		-- Tim Edlund | Apr 2018
		-- If the applied payment is against an invoice related to a registration
		-- form (Application, Renewal, Reinstatement or Registration Change) then
		-- a Registration is created for it if the invoice is fully paid and the
		-- form APPROVED. These conditions are checked and action performed through
		-- a separate procedure call.

		exec dbo.pRegistration#SetOnPaid
			@InvoicePaymentSID = @InvoicePaymentSID
		--! </PostUpdate>
	
		-- call the extended version of the procedure for update.post - if it exists
		
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
				 @Mode                 = 'update.post'
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
				,@UpdateUser           = @UpdateUser
				,@RowStamp             = @RowStamp
				,@IsReselected         = @IsReselected
				,@IsNullApplied        = @IsNullApplied
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
