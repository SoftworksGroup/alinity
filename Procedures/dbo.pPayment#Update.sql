SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPayment#Update]
	 @PaymentSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                   int               = null -- table column values to update:
	,@PaymentTypeSID              int               = null
	,@PaymentStatusSID            int               = null
	,@GLAccountCode               varchar(50)       = null
	,@GLPostingDate               date              = null
	,@DepositDate                 date              = null
	,@AmountPaid                  decimal(11,2)     = null
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
	,@UpdateUser                  nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                    timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied               bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                    xml               = null -- other values defining context for the update (if any)
	,@PaymentStatusSCD            varchar(25)       = null -- not a base table column
	,@PaymentStatusLabel          nvarchar(35)      = null -- not a base table column
	,@IsPaid                      bit               = null -- not a base table column
	,@PaymentStatusSequence       int               = null -- not a base table column
	,@PaymentStatusRowGUID        uniqueidentifier  = null -- not a base table column
	,@PaymentTypeSCD              varchar(15)       = null -- not a base table column
	,@PaymentTypeLabel            nvarchar(35)      = null -- not a base table column
	,@PaymentTypeCategory         nvarchar(65)      = null -- not a base table column
	,@GLAccountSID                int               = null -- not a base table column
	,@PaymentTypePaymentStatusSID int               = null -- not a base table column
	,@IsReferenceRequired         bit               = null -- not a base table column
	,@DepositDateLagDays          smallint          = null -- not a base table column
	,@IsRefundExcludedFromGL      bit               = null -- not a base table column
	,@ExcludeDepositFromGLBefore  date              = null -- not a base table column
	,@PaymentTypeIsDefault        bit               = null -- not a base table column
	,@PaymentTypeIsActive         bit               = null -- not a base table column
	,@PaymentTypeRowGUID          uniqueidentifier  = null -- not a base table column
	,@GenderSID                   int               = null -- not a base table column
	,@NamePrefixSID               int               = null -- not a base table column
	,@FirstName                   nvarchar(30)      = null -- not a base table column
	,@CommonName                  nvarchar(30)      = null -- not a base table column
	,@MiddleNames                 nvarchar(30)      = null -- not a base table column
	,@LastName                    nvarchar(35)      = null -- not a base table column
	,@BirthDate                   date              = null -- not a base table column
	,@DeathDate                   date              = null -- not a base table column
	,@HomePhone                   varchar(25)       = null -- not a base table column
	,@MobilePhone                 varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled      bit               = null -- not a base table column
	,@ImportBatch                 nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID               uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID              int               = null -- not a base table column
	,@ReasonName                  nvarchar(50)      = null -- not a base table column
	,@ReasonCode                  varchar(25)       = null -- not a base table column
	,@ReasonSequence              smallint          = null -- not a base table column
	,@ToolTip                     nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive              bit               = null -- not a base table column
	,@ReasonRowGUID               uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled             bit               = null -- not a base table column
	,@PaymentLabel                nvarchar(4000)    = null -- not a base table column
	,@PaymentShortLabel           nvarchar(4000)    = null -- not a base table column
	,@RegistrantLabel             nvarchar(75)      = null -- not a base table column
	,@IsOnlinePayment             bit               = null -- not a base table column
	,@TotalApplied                decimal(11,2)     = null -- not a base table column
	,@TotalUnapplied              decimal(11,2)     = null -- not a base table column
	,@IsFullyApplied              bit               = null -- not a base table column
	,@IsNotApplied                bit               = null -- not a base table column
	,@IsPartiallyApplied          bit               = null -- not a base table column
	,@IsOverApplied               bit               = null -- not a base table column
	,@IsCancelled                 bit               = null -- not a base table column
	,@IsCancelEnabled             bit               = null -- not a base table column
	,@IsEditEnabled               bit               = null -- not a base table column
	,@GLCheckSum                  int               = null -- not a base table column
	,@LatestTransactionID         varchar(50)       = null -- not a base table column
	,@LatestChargeTotal           decimal(11,2)     = null -- not a base table column
	,@LatestResponseCode          int               = null -- not a base table column
	,@LatestMessage               varchar(8000)     = null -- not a base table column
	,@LatestApprovalCode          varchar(25)       = null -- not a base table column
	,@LatestIsPaid                bit               = null -- not a base table column
	,@LatestVerifiedTime          datetime          = null -- not a base table column
	,@IsRetryEnabled              bit               = null -- not a base table column
	,@IsReapplyEnabled            bit               = null -- not a base table column
	,@TransactionIDReference      nvarchar(150)     = null -- not a base table column
	,@VerifiedTimeComponent       time(7)           = null -- not a base table column
	,@InvoiceSID                  int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPayment#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Payment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Payment table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPayment entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPayment procedure. The extended procedure is only called
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

		if @PaymentSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PaymentSID'

			raiserror(@errorText, 18, 1)
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
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                   = isnull(@PersonSID,payment.PersonSID)
				,@PaymentTypeSID              = isnull(@PaymentTypeSID,payment.PaymentTypeSID)
				,@PaymentStatusSID            = isnull(@PaymentStatusSID,payment.PaymentStatusSID)
				,@GLAccountCode               = isnull(@GLAccountCode,payment.GLAccountCode)
				,@GLPostingDate               = isnull(@GLPostingDate,payment.GLPostingDate)
				,@DepositDate                 = isnull(@DepositDate,payment.DepositDate)
				,@AmountPaid                  = isnull(@AmountPaid,payment.AmountPaid)
				,@Reference                   = isnull(@Reference,payment.Reference)
				,@NameOnCard                  = isnull(@NameOnCard,payment.NameOnCard)
				,@PaymentCard                 = isnull(@PaymentCard,payment.PaymentCard)
				,@TransactionID               = isnull(@TransactionID,payment.TransactionID)
				,@LastResponseCode            = isnull(@LastResponseCode,payment.LastResponseCode)
				,@LastResponseMessage         = isnull(@LastResponseMessage,payment.LastResponseMessage)
				,@VerifiedTime                = isnull(@VerifiedTime,payment.VerifiedTime)
				,@CancelledTime               = isnull(@CancelledTime,payment.CancelledTime)
				,@ReasonSID                   = isnull(@ReasonSID,payment.ReasonSID)
				,@UserDefinedColumns          = isnull(@UserDefinedColumns,payment.UserDefinedColumns)
				,@PaymentXID                  = isnull(@PaymentXID,payment.PaymentXID)
				,@LegacyKey                   = isnull(@LegacyKey,payment.LegacyKey)
				,@UpdateUser                  = isnull(@UpdateUser,payment.UpdateUser)
				,@IsReselected                = isnull(@IsReselected,payment.IsReselected)
				,@IsNullApplied               = isnull(@IsNullApplied,payment.IsNullApplied)
				,@zContext                    = isnull(@zContext,payment.zContext)
				,@PaymentStatusSCD            = isnull(@PaymentStatusSCD,payment.PaymentStatusSCD)
				,@PaymentStatusLabel          = isnull(@PaymentStatusLabel,payment.PaymentStatusLabel)
				,@IsPaid                      = isnull(@IsPaid,payment.IsPaid)
				,@PaymentStatusSequence       = isnull(@PaymentStatusSequence,payment.PaymentStatusSequence)
				,@PaymentStatusRowGUID        = isnull(@PaymentStatusRowGUID,payment.PaymentStatusRowGUID)
				,@PaymentTypeSCD              = isnull(@PaymentTypeSCD,payment.PaymentTypeSCD)
				,@PaymentTypeLabel            = isnull(@PaymentTypeLabel,payment.PaymentTypeLabel)
				,@PaymentTypeCategory         = isnull(@PaymentTypeCategory,payment.PaymentTypeCategory)
				,@GLAccountSID                = isnull(@GLAccountSID,payment.GLAccountSID)
				,@PaymentTypePaymentStatusSID = isnull(@PaymentTypePaymentStatusSID,payment.PaymentTypePaymentStatusSID)
				,@IsReferenceRequired         = isnull(@IsReferenceRequired,payment.IsReferenceRequired)
				,@DepositDateLagDays          = isnull(@DepositDateLagDays,payment.DepositDateLagDays)
				,@IsRefundExcludedFromGL      = isnull(@IsRefundExcludedFromGL,payment.IsRefundExcludedFromGL)
				,@ExcludeDepositFromGLBefore  = isnull(@ExcludeDepositFromGLBefore,payment.ExcludeDepositFromGLBefore)
				,@PaymentTypeIsDefault        = isnull(@PaymentTypeIsDefault,payment.PaymentTypeIsDefault)
				,@PaymentTypeIsActive         = isnull(@PaymentTypeIsActive,payment.PaymentTypeIsActive)
				,@PaymentTypeRowGUID          = isnull(@PaymentTypeRowGUID,payment.PaymentTypeRowGUID)
				,@GenderSID                   = isnull(@GenderSID,payment.GenderSID)
				,@NamePrefixSID               = isnull(@NamePrefixSID,payment.NamePrefixSID)
				,@FirstName                   = isnull(@FirstName,payment.FirstName)
				,@CommonName                  = isnull(@CommonName,payment.CommonName)
				,@MiddleNames                 = isnull(@MiddleNames,payment.MiddleNames)
				,@LastName                    = isnull(@LastName,payment.LastName)
				,@BirthDate                   = isnull(@BirthDate,payment.BirthDate)
				,@DeathDate                   = isnull(@DeathDate,payment.DeathDate)
				,@HomePhone                   = isnull(@HomePhone,payment.HomePhone)
				,@MobilePhone                 = isnull(@MobilePhone,payment.MobilePhone)
				,@IsTextMessagingEnabled      = isnull(@IsTextMessagingEnabled,payment.IsTextMessagingEnabled)
				,@ImportBatch                 = isnull(@ImportBatch,payment.ImportBatch)
				,@PersonRowGUID               = isnull(@PersonRowGUID,payment.PersonRowGUID)
				,@ReasonGroupSID              = isnull(@ReasonGroupSID,payment.ReasonGroupSID)
				,@ReasonName                  = isnull(@ReasonName,payment.ReasonName)
				,@ReasonCode                  = isnull(@ReasonCode,payment.ReasonCode)
				,@ReasonSequence              = isnull(@ReasonSequence,payment.ReasonSequence)
				,@ToolTip                     = isnull(@ToolTip,payment.ToolTip)
				,@ReasonIsActive              = isnull(@ReasonIsActive,payment.ReasonIsActive)
				,@ReasonRowGUID               = isnull(@ReasonRowGUID,payment.ReasonRowGUID)
				,@IsDeleteEnabled             = isnull(@IsDeleteEnabled,payment.IsDeleteEnabled)
				,@PaymentLabel                = isnull(@PaymentLabel,payment.PaymentLabel)
				,@PaymentShortLabel           = isnull(@PaymentShortLabel,payment.PaymentShortLabel)
				,@RegistrantLabel             = isnull(@RegistrantLabel,payment.RegistrantLabel)
				,@IsOnlinePayment             = isnull(@IsOnlinePayment,payment.IsOnlinePayment)
				,@TotalApplied                = isnull(@TotalApplied,payment.TotalApplied)
				,@TotalUnapplied              = isnull(@TotalUnapplied,payment.TotalUnapplied)
				,@IsFullyApplied              = isnull(@IsFullyApplied,payment.IsFullyApplied)
				,@IsNotApplied                = isnull(@IsNotApplied,payment.IsNotApplied)
				,@IsPartiallyApplied          = isnull(@IsPartiallyApplied,payment.IsPartiallyApplied)
				,@IsOverApplied               = isnull(@IsOverApplied,payment.IsOverApplied)
				,@IsCancelled                 = isnull(@IsCancelled,payment.IsCancelled)
				,@IsCancelEnabled             = isnull(@IsCancelEnabled,payment.IsCancelEnabled)
				,@IsEditEnabled               = isnull(@IsEditEnabled,payment.IsEditEnabled)
				,@GLCheckSum                  = isnull(@GLCheckSum,payment.GLCheckSum)
				,@LatestTransactionID         = isnull(@LatestTransactionID,payment.LatestTransactionID)
				,@LatestChargeTotal           = isnull(@LatestChargeTotal,payment.LatestChargeTotal)
				,@LatestResponseCode          = isnull(@LatestResponseCode,payment.LatestResponseCode)
				,@LatestMessage               = isnull(@LatestMessage,payment.LatestMessage)
				,@LatestApprovalCode          = isnull(@LatestApprovalCode,payment.LatestApprovalCode)
				,@LatestIsPaid                = isnull(@LatestIsPaid,payment.LatestIsPaid)
				,@LatestVerifiedTime          = isnull(@LatestVerifiedTime,payment.LatestVerifiedTime)
				,@IsRetryEnabled              = isnull(@IsRetryEnabled,payment.IsRetryEnabled)
				,@IsReapplyEnabled            = isnull(@IsReapplyEnabled,payment.IsReapplyEnabled)
				,@TransactionIDReference      = isnull(@TransactionIDReference,payment.TransactionIDReference)
				,@VerifiedTimeComponent       = isnull(@VerifiedTimeComponent,payment.VerifiedTimeComponent)
				,@InvoiceSID                  = isnull(@InvoiceSID,payment.InvoiceSID)
			from
				dbo.vPayment payment
			where
				payment.PaymentSID = @PaymentSID

		end
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @PaymentStatusSCD is not null and @PaymentStatusSID = (select x.PaymentStatusSID from dbo.Payment x where x.PaymentSID = @PaymentSID)
		begin
		
			select
				@PaymentStatusSID = x.PaymentStatusSID
			from
				dbo.PaymentStatus x
			where
				x.PaymentStatusSCD = @PaymentStatusSCD
		
		end
		
		if @PaymentTypeSCD is not null and @PaymentTypeSID = (select x.PaymentTypeSID from dbo.Payment x where x.PaymentSID = @PaymentSID)
		begin
		
			select
				@PaymentTypeSID = x.PaymentTypeSID
			from
				dbo.PaymentType x
			where
				x.PaymentTypeSCD = @PaymentTypeSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.PaymentTypeSID from dbo.Payment x where x.PaymentSID = @PaymentSID) <> @PaymentTypeSID
		begin
			if (select x.IsActive from dbo.PaymentType x where x.PaymentTypeSID = @PaymentTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'payment type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ReasonSID from dbo.Payment x where x.PaymentSID = @PaymentSID) <> @ReasonSID
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
		-- Tim Edlund | Nov 2018
		-- If the GL Posting date is being modified, ensure the new date is not
		-- back-dated into a closed accounting period as set in configuration.

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

		-- Tim Edlund | Nov 2017
		-- Ensure payment type and payment status codes are looked up to simplify
		-- other logic.
		
		if @PaymentStatusSID	is not null select @PaymentStatusSCD = ps.PaymentStatusSCD from dbo.PaymentStatus ps where ps.PaymentStatusSID = @PaymentStatusSID
		if @PaymentTypeSID		is not null select @PaymentTypeSCD = ps.PaymentTypeSCD from dbo.PaymentType ps where ps.PaymentTypeSID = @PaymentTypeSID

		-- Tim Edlund | Oct 2017
		-- Combine time components with dates where the user has entered
		-- values into them.

		if @VerifiedTimeComponent is not null and @VerifiedTime is not null
		begin
			set @VerifiedTime = cast(cast(@VerifiedTime as date) as datetime) + cast(@VerifiedTimeComponent as datetime);
		end;

		-- Tim Edlund | Oct 2017
		-- If the GL Posting date is not the same day as the verification
		-- time, update it.  This will trigger reposting of the payment.

		if @VerifiedTime is not null
		begin
		 if @GLPostingDate is null or sf.fIsDifferent(cast(@VerifiedTime as date), @GLPostingDate	) = @ON set @GLPostingDate = cast(@VerifiedTime as date)

			select	-- since posting date may have changed, automatically update deposit date
				@DepositDate = dateadd(day, pt.DepositDateLagDays, @GLPostingDate)
			from
				dbo.PaymentType pt
			where
				pt.PaymentTypeSID = @PaymentTypeSID;

		end

		-- Tim Edlund | Nov 2017
		-- If a verified time is provided, ensure the current status
		-- of the payment is approved

		if @VerifiedTime is not null
		begin
			select @PaymentStatusSID = ps.PaymentStatusSID from dbo.PaymentStatus ps where ps.PaymentStatusSCD = 'APPROVED'
			set @PaymentStatusSCD = 'APPROVED'
		end

		-- Tim Edlund | Nov 2017
		-- If the payment is in a paid status and no GL Posting date is provided, default it
		-- to the create date for POS payments, and the current date for others; note that
		-- for online payments the VerifiedTime should have been provided above to set it!

		if @GLPostingDate is null and @PaymentStatusSID is not null
		begin
		
			if @PaymentStatusSCD = 'APPROVED'
			begin

				if @PaymentTypeSCD = 'POS'
				begin
					select @GLPostingDate = cast(p.CreateTime as date) from dbo.Payment p where p.PaymentSID = @PaymentSID
				end
				else
				begin
					set @GLPostingDate = sf.fToday()
				end

			end

		end

		-- Tim Edlund | Nov 2017
		-- If this is a credit card payment that is being approved but the card holder
		-- name or card number are not provided (manual entry of processor message), look
		-- them up from the latest non-manual processor message

		if left(@PaymentTypeSCD, 3) = 'PP.' and @PaymentStatusSCD = 'APPROVED' and (@NameOnCard is null or @PaymentCard is null)
		begin

			if exists(select 1 from dbo.Payment p where p.PaymentSID = @PaymentSID and p.PaymentStatusSID <> @PaymentStatusSID) -- status is changing
			begin

				select top 1
					@NameOnCard	 = isnull(pprd.NameOnCard, @NameOnCard)
				 ,@PaymentCard = isnull(pprd.PaymentCard, @PaymentCard)
				from
					dbo.vPaymentProcessorResponse#Detail pprd
				where
					pprd.PaymentSID = @PaymentSID and pprd.ResponseSource <> 'MANUAL' and pprd.NameOnCard is not null and pprd.PaymentCard is not null
				order by
					pprd.ResponseTime desc
				 ,pprd.PaymentProcessorResponseSID desc;

			end

		end;

		-- Tim Edlund | Oct 2017
		-- Cancelling a payment requires that any amounts that are applied
		-- from it must be set to 0 first.

		if @CancelledTime is not null
		begin

			declare @now datetimeoffset(7) = sysdatetimeoffset();

			set @recordSID = -1;

			while @recordSID is not null
			begin

				set @recordSID = null;

				select
					@recordSID = ip.InvoicePaymentSID
				from
					dbo.InvoicePayment ip
				where
					ip.PaymentSID = @PaymentSID and (ip.AmountApplied <> 0.00 or ip.CancelledTime is null)

				if @recordSID is not null
				begin

					exec dbo.pInvoicePayment#Update
						@InvoicePaymentSID = @recordSID
					 ,@AmountApplied = 0.00
					 ,@CancelledTime = @now;

				end;
			end;

			-- Tim Edlund | Oct 2017
			-- When the cancelled time is being set, reset the status to
			-- cancelled as well and reduce the amount to 0.00.

			select
				@PaymentStatusSCD = ps.PaymentStatusSCD
			 ,@PaymentStatusSID = ps.PaymentStatusSID
			 ,@AmountPaid				= 0.00
			from
				dbo.PaymentStatus ps
			where
				ps.PaymentStatusSCD = 'CANCELLED';

		end;
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
				r.RoutineName = 'pPayment'
		)
		begin
		
			exec @errorNo = ext.pPayment
				 @Mode                        = 'update.pre'
				,@PaymentSID                  = @PaymentSID
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
				,@UpdateUser                  = @UpdateUser
				,@RowStamp                    = @RowStamp
				,@IsReselected                = @IsReselected
				,@IsNullApplied               = @IsNullApplied
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

		-- update the record

		update
			dbo.Payment
		set
			 PersonSID = @PersonSID
			,PaymentTypeSID = @PaymentTypeSID
			,PaymentStatusSID = @PaymentStatusSID
			,GLAccountCode = @GLAccountCode
			,GLPostingDate = @GLPostingDate
			,DepositDate = @DepositDate
			,AmountPaid = @AmountPaid
			,Reference = @Reference
			,NameOnCard = @NameOnCard
			,PaymentCard = @PaymentCard
			,TransactionID = @TransactionID
			,LastResponseCode = @LastResponseCode
			,LastResponseMessage = @LastResponseMessage
			,VerifiedTime = @VerifiedTime
			,CancelledTime = @CancelledTime
			,ReasonSID = @ReasonSID
			,UserDefinedColumns = @UserDefinedColumns
			,PaymentXID = @PaymentXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PaymentSID = @PaymentSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Payment where PaymentSID = @paymentSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Payment'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Payment'
					,@Arg2        = @paymentSID
				
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
				,@Arg2        = 'dbo.Payment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @paymentSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Nov 2017
		-- Ensure that the amount of the payment agrees with the amount applied on
		-- invoices for the payment (unless cancelled). If the amount of the payment
		-- was edited adjustments may be required (see also doc in subroutine)

		set @recordSID = null

		if @CancelledTime is null
		begin

			exec dbo.pPayment#ReApply
				@PaymentSID = @PaymentSID
			 ,@Adjustments = @recordSID output;

			if @recordSID > 0 set @GLCheckSum = -1 -- force GL repost if adjustments were made

		end;

		-- Tim Edlund | Oct 2017
		-- Record the GL entry for the updated payment. Any updates required to the postings for related
		-- invoice-payments are handled through this procedure call. For example, if the payment has now
		-- changed status.

		if not exists (select 1 from dbo.GLTransaction gt	where gt.PaymentSID = @PaymentSID)
		begin
			set @GLCheckSum = -1; -- if no GL transactions exist force the call to #post
		end;
		else if @recordSID is null
		begin

			select
				@recordSID = px.GLCheckSum
			from
				dbo.vPayment#Ext px
			where
				px.PaymentSID = @PaymentSID;

		end;

		if sf.fIsDifferent(@GLCheckSum, @recordSID) = @ON
		begin

			-- if the payment status has changed to non-paid the call to #post
			-- is required to reverse prior entries; a posting date is required
			-- in the call signature but will not result in new trx's

			if @GLPostingDate is null set @GLPostingDate = sf.fToday()	

			exec dbo.pGLTransaction#PostPayment
				@PaymentSID = @PaymentSID
				,@ActionCode = 'UPDATE'
				,@PreviousCheckSum = @GLCheckSum
				,@PostingDate = @GLPostingDate;

		end;

		-- Tim Edlund | Apr 2018
		-- If the payment is against one or more invoices related to registration
		-- forms (Application, Renewal, Reinstatement or Registration Change)
		-- then a Registration is created for them if the invoice is fully paid
		-- and the form APPROVED. These conditions are checked and action
		-- performed through a separate procedure call.

		exec dbo.pRegistration#SetOnPaid
			@PaymentSID = @PaymentSID
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
				r.RoutineName = 'pPayment'
		)
		begin
		
			exec @errorNo = ext.pPayment
				 @Mode                        = 'update.post'
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
				,@UpdateUser                  = @UpdateUser
				,@RowStamp                    = @RowStamp
				,@IsReselected                = @IsReselected
				,@IsNullApplied               = @IsNullApplied
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
