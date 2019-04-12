SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPayment#Insert]
	 @PaymentSID                  int               = null output						-- identity value assigned to the new record
	,@PersonSID                   int               = null									-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pPayment#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.Payment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Payment table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPayment entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPayment procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPaymentCheck to test all rules.

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

	set @PaymentSID = null																									-- initialize output parameter

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

		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @Reference = ltrim(rtrim(@Reference))
		set @NameOnCard = ltrim(rtrim(@NameOnCard))
		set @PaymentCard = ltrim(rtrim(@PaymentCard))
		set @TransactionID = ltrim(rtrim(@TransactionID))
		set @LastResponseCode = ltrim(rtrim(@LastResponseCode))
		set @LastResponseMessage = ltrim(rtrim(@LastResponseMessage))
		set @PaymentXID = ltrim(rtrim(@PaymentXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @PaymentStatusSCD = ltrim(rtrim(@PaymentStatusSCD))
		set @PaymentStatusLabel = ltrim(rtrim(@PaymentStatusLabel))
		set @PaymentTypeSCD = ltrim(rtrim(@PaymentTypeSCD))
		set @PaymentTypeLabel = ltrim(rtrim(@PaymentTypeLabel))
		set @PaymentTypeCategory = ltrim(rtrim(@PaymentTypeCategory))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @PaymentLabel = ltrim(rtrim(@PaymentLabel))
		set @PaymentShortLabel = ltrim(rtrim(@PaymentShortLabel))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @LatestTransactionID = ltrim(rtrim(@LatestTransactionID))
		set @LatestMessage = ltrim(rtrim(@LatestMessage))
		set @LatestApprovalCode = ltrim(rtrim(@LatestApprovalCode))
		set @TransactionIDReference = ltrim(rtrim(@TransactionIDReference))

		-- set zero length strings to null to avoid storing them in the record

		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@Reference) = 0 set @Reference = null
		if len(@NameOnCard) = 0 set @NameOnCard = null
		if len(@PaymentCard) = 0 set @PaymentCard = null
		if len(@TransactionID) = 0 set @TransactionID = null
		if len(@LastResponseCode) = 0 set @LastResponseCode = null
		if len(@LastResponseMessage) = 0 set @LastResponseMessage = null
		if len(@PaymentXID) = 0 set @PaymentXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PaymentStatusSCD) = 0 set @PaymentStatusSCD = null
		if len(@PaymentStatusLabel) = 0 set @PaymentStatusLabel = null
		if len(@PaymentTypeSCD) = 0 set @PaymentTypeSCD = null
		if len(@PaymentTypeLabel) = 0 set @PaymentTypeLabel = null
		if len(@PaymentTypeCategory) = 0 set @PaymentTypeCategory = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@PaymentLabel) = 0 set @PaymentLabel = null
		if len(@PaymentShortLabel) = 0 set @PaymentShortLabel = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@LatestTransactionID) = 0 set @LatestTransactionID = null
		if len(@LatestMessage) = 0 set @LatestMessage = null
		if len(@LatestApprovalCode) = 0 set @LatestApprovalCode = null
		if len(@TransactionIDReference) = 0 set @TransactionIDReference = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected        = isnull(@IsReselected       ,(0))
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @PaymentStatusSCD is not null
		begin
		
			select
				@PaymentStatusSID = x.PaymentStatusSID
			from
				dbo.PaymentStatus x
			where
				x.PaymentStatusSCD = @PaymentStatusSCD
		
		end
		
		if @PaymentTypeSCD is not null
		begin
		
			select
				@PaymentTypeSID = x.PaymentTypeSID
			from
				dbo.PaymentType x
			where
				x.PaymentTypeSCD = @PaymentTypeSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @PaymentTypeSID  is null select @PaymentTypeSID  = x.PaymentTypeSID from dbo.PaymentType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Nov 2018
		-- Ensure the GL Posting date provided is not back-dated
		-- into a closed accounting period as set in configuration.

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

		-- Tim Edlund | Oct 2017
		-- Combine time components with dates where the user has entered
		-- values into them.

		if @VerifiedTimeComponent is not null and @VerifiedTime is not null
		begin
			set @VerifiedTime = cast(cast(@VerifiedTime as date) as datetime) + cast(@VerifiedTimeComponent as datetime);
		end;

		-- Tim Edlund | Sep 2017
		-- The initial status of the payment is driven by the type of
		-- payment if not provided from manual entry

		if @PaymentStatusSID is null
		begin

			select
				@PaymentStatusSID = pt.PaymentStatusSID
			from
				dbo.PaymentType pt
			where
				pt.PaymentTypeSID = @PaymentTypeSID

		end

		-- Tim Edlund | Nov 2017
		-- If no posting date is provided but the status of the
		-- payment is paid, then set it to the verified time when
		-- provided, otherwise current date. Required for GL posting.

		if @GLPostingDate is null and @PaymentStatusSID is not null
		begin

			if exists ( select
										1
									from
										dbo.PaymentStatus ps
									where
										ps.PaymentStatusSID = @PaymentStatusSID and ps.IsPaid = @ON)
			begin
				set @GLPostingDate = isnull(@VerifiedTime, sf.fToday());
			end;

		end;

		-- Tim Edlund | Sep 2017
		-- Where an invoice key is passed in and no person key is provided
		-- set it to the person associated with the invoice.

		if @InvoiceSID is not null and (@PersonSID is null)
		begin

			select
				@PersonSID = i.PersonSID
			from
				dbo.Invoice i
			where
				i.InvoiceSID = @InvoiceSID;

		end;

		-- Tim Edlund | Sep 2017
		-- If a card number is provided without being masked, mask it
		-- before storage. Applies mostly in conversion situations.

		if charindex('XXXX', @PaymentCard) = 0
		begin
			set @PaymentCard = left(@PaymentCard, 4) + replicate('X', len(@PaymentCard) - 8) + right(@PaymentCard, 4)
		end

		-- Tim Edlund | Sep 2017
		-- If no deposit date was provided, set it based on the lag defined
		-- for the payment type.  The Deposit Date is the date the transaction
		-- is expected to be displayed on the bank statement.

		if datediff(day, @DepositDate, sf.fToday()) > 30 set @DepositDate = null -- work around for a .NET behaviour that sets not null dates to 0001/01/01

		if @DepositDate is null and @PaymentTypeSID is not null
		begin
			select
				@DepositDate = dateadd(day, pt.DepositDateLagDays, isnull(cast(@VerifiedTime as date), sf.fToday()))
			from
				dbo.PaymentType pt
			where
				pt.PaymentTypeSID = @PaymentTypeSID

		end

		-- Tim Edlund | Jan 2019
		-- Where a new payment is being backdated, typically
		-- because it was not captured from CC processing and
		-- is being added later, then reset the default GL
		-- posting date to match the deposit

		if @DepositDate < @GLPostingDate
		begin
			set @GLPostingDate = @DepositDate
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
				r.RoutineName = 'pPayment'
		)
		begin
		
			exec @errorNo = ext.pPayment
				 @Mode                        = 'insert.pre'
				,@PersonSID                   = @PersonSID output
				,@PaymentTypeSID              = @PaymentTypeSID output
				,@PaymentStatusSID            = @PaymentStatusSID output
				,@GLAccountCode               = @GLAccountCode output
				,@GLPostingDate               = @GLPostingDate output
				,@DepositDate                 = @DepositDate output
				,@AmountPaid                  = @AmountPaid output
				,@Reference                   = @Reference output
				,@NameOnCard                  = @NameOnCard output
				,@PaymentCard                 = @PaymentCard output
				,@TransactionID               = @TransactionID output
				,@LastResponseCode            = @LastResponseCode output
				,@LastResponseMessage         = @LastResponseMessage output
				,@VerifiedTime                = @VerifiedTime output
				,@CancelledTime               = @CancelledTime output
				,@ReasonSID                   = @ReasonSID output
				,@UserDefinedColumns          = @UserDefinedColumns output
				,@PaymentXID                  = @PaymentXID output
				,@LegacyKey                   = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.Payment
		(
			 PersonSID
			,PaymentTypeSID
			,PaymentStatusSID
			,GLAccountCode
			,GLPostingDate
			,DepositDate
			,AmountPaid
			,Reference
			,NameOnCard
			,PaymentCard
			,TransactionID
			,LastResponseCode
			,LastResponseMessage
			,VerifiedTime
			,CancelledTime
			,ReasonSID
			,UserDefinedColumns
			,PaymentXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@PaymentTypeSID
			,@PaymentStatusSID
			,@GLAccountCode
			,@GLPostingDate
			,@DepositDate
			,@AmountPaid
			,@Reference
			,@NameOnCard
			,@PaymentCard
			,@TransactionID
			,@LastResponseCode
			,@LastResponseMessage
			,@VerifiedTime
			,@CancelledTime
			,@ReasonSID
			,@UserDefinedColumns
			,@PaymentXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@PaymentSID = scope_identity()																			-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.Payment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PaymentSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Oct 2017
		-- Record the GL entry for the new payment

		if exists
		(
			select
				1
			from
				dbo.Payment				p
			join
				dbo.PaymentStatus ps on p.PaymentStatusSID = ps.PaymentStatusSID and ps.IsPaid = @ON	-- must be in a paid status!
			where
				p.PaymentSID = @PaymentSID
		)	
		begin

			exec dbo.pGLTransaction#PostPayment
				 @PaymentSID = @PaymentSID
				,@ActionCode = 'INSERT'
				,@PostingDate = @GLPostingDate;

		end;

		-- Tim Edlund | Sep 2017
		-- Where an invoice key is passed in automatically apply the payment
		-- to that invoice.  Limit the amount of payment applied to the amount
		-- owing on the invoice.

		if @InvoiceSID is not null
		begin
			declare @amountApplied decimal(11, 2);

			select
				@amountApplied = (case when i.TotalDue < @AmountPaid then i.TotalDue else @AmountPaid end)
			from
				dbo.vInvoice i
			where
				i.InvoiceSID = @InvoiceSID and i.TotalDue > 0.00; -- avoid paying invoices with $0 owing!

			if @amountApplied > cast(0.00 as decimal(11, 2))
			begin

				exec dbo.pInvoicePayment#Insert
					@InvoiceSID = @InvoiceSID
				 ,@PaymentSID = @PaymentSID
				 ,@AmountApplied = @amountApplied;

			end;

		end;
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
				r.RoutineName = 'pPayment'
		)
		begin
		
			exec @errorNo = ext.pPayment
				 @Mode                        = 'insert.post'
				,@PaymentSID                  = @PaymentSID
				,@PersonSID                   = @PersonSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PaymentSID
			from
				dbo.vPayment ent
			where
				ent.PaymentSID = @PaymentSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PaymentSID
				,ent.PersonSID
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
				,ent.LastResponseMessage
				,ent.VerifiedTime
				,ent.CancelledTime
				,ent.ReasonSID
				,ent.UserDefinedColumns
				,ent.PaymentXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PaymentStatusSCD
				,ent.PaymentStatusLabel
				,ent.IsPaid
				,ent.PaymentStatusSequence
				,ent.PaymentStatusRowGUID
				,ent.PaymentTypeSCD
				,ent.PaymentTypeLabel
				,ent.PaymentTypeCategory
				,ent.GLAccountSID
				,ent.PaymentTypePaymentStatusSID
				,ent.IsReferenceRequired
				,ent.DepositDateLagDays
				,ent.IsRefundExcludedFromGL
				,ent.ExcludeDepositFromGLBefore
				,ent.PaymentTypeIsDefault
				,ent.PaymentTypeIsActive
				,ent.PaymentTypeRowGUID
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.BirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
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
				,ent.PaymentLabel
				,ent.PaymentShortLabel
				,ent.RegistrantLabel
				,ent.IsOnlinePayment
				,ent.TotalApplied
				,ent.TotalUnapplied
				,ent.IsFullyApplied
				,ent.IsNotApplied
				,ent.IsPartiallyApplied
				,ent.IsOverApplied
				,ent.IsCancelled
				,ent.IsCancelEnabled
				,ent.IsEditEnabled
				,ent.GLCheckSum
				,ent.LatestTransactionID
				,ent.LatestChargeTotal
				,ent.LatestResponseCode
				,ent.LatestMessage
				,ent.LatestApprovalCode
				,ent.LatestIsPaid
				,ent.LatestVerifiedTime
				,ent.IsRetryEnabled
				,ent.IsReapplyEnabled
				,ent.TransactionIDReference
				,ent.VerifiedTimeComponent
				,ent.InvoiceSID
			from
				dbo.vPayment ent
			where
				ent.PaymentSID = @PaymentSID

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
