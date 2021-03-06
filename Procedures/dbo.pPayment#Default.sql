SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPayment#Default]
	 @zContext                    xml               = null                -- default values provided from client-tier (if any)
	,@SetFKDefaults               bit               = 0                   -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pPayment#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.Payment records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Payment table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vPayment entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pPayment
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pPayment of the context of the call. All other parameters are also passed, however, only those parameters eligible
for default setting are passed for "output". All parameters corresponding to entity view columns are returned through a SELECT statement.

In order to simplify working with the XML parameter values, logic in the procedure parses the XML and assigns values to variables where
the variable name matches the column name in the XML (assumes single row).  The variables are then available to the table-specific and
client-specific logic.  The @zContext parameter is also passed, unmodified, to the extended procedure to support situations where values
are passed that are not mapped to column names.


-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@ON                          bit = cast(1 as bit)										-- constant for bit comparisons
		,@OFF                         bit = cast(0 as bit)										-- constant for bit comparisons
		,@paymentSID                  int               = -1									-- specific default required by EF - do not override
		,@personSID                   int               = null								-- no default provided from DB constraint - OK to override
		,@paymentTypeSID              int               = null								-- no default provided from DB constraint - OK to override
		,@paymentStatusSID            int               = null								-- no default provided from DB constraint - OK to override
		,@gLAccountCode               varchar(50)       = null								-- no default provided from DB constraint - OK to override
		,@gLPostingDate               date              = null								-- no default provided from DB constraint - OK to override
		,@depositDate                 date              = null								-- no default provided from DB constraint - OK to override
		,@amountPaid                  decimal(11,2)     = null								-- no default provided from DB constraint - OK to override
		,@reference                   varchar(25)       = null								-- no default provided from DB constraint - OK to override
		,@nameOnCard                  nvarchar(150)     = null								-- no default provided from DB constraint - OK to override
		,@paymentCard                 varchar(20)       = null								-- no default provided from DB constraint - OK to override
		,@transactionID               varchar(50)       = null								-- no default provided from DB constraint - OK to override
		,@lastResponseCode            varchar(50)       = null								-- no default provided from DB constraint - OK to override
		,@lastResponseMessage         nvarchar(max)     = null								-- no default provided from DB constraint - OK to override
		,@verifiedTime                datetime          = null								-- no default provided from DB constraint - OK to override
		,@cancelledTime               datetimeoffset(7) = null								-- no default provided from DB constraint - OK to override
		,@reasonSID                   int               = null								-- no default provided from DB constraint - OK to override
		,@userDefinedColumns          xml               = null								-- no default provided from DB constraint - OK to override
		,@paymentXID                  varchar(150)      = null								-- no default provided from DB constraint - OK to override
		,@legacyKey                   nvarchar(50)      = null								-- no default provided from DB constraint - OK to override
		,@isDeleted                   bit               = (0)									-- default provided from DB constraint - OK to override
		,@createUser                  nvarchar(75)      = suser_sname()				-- default value ignored (value set by UI)
		,@createTime                  datetimeoffset(7) = sysdatetimeoffset()	-- default value ignored (set to system time)
		,@updateUser                  nvarchar(75)      = suser_sname()				-- default value ignored (value set by UI)
		,@updateTime                  datetimeoffset(7) = sysdatetimeoffset()	-- default value ignored (set to system time)
		,@rowGUID                     uniqueidentifier  = newid()							-- default value ignored (value set by system)
		,@rowStamp                    timestamp         = null								-- default value ignored (value set by system)
		,@paymentStatusSCD            varchar(25)       = '?'									-- not a base table column (default ignored)
		,@paymentStatusLabel          nvarchar(35)      = N'?'								-- not a base table column (default ignored)
		,@isPaid                      bit               = 0										-- not a base table column (default ignored)
		,@paymentStatusSequence       int               = 0										-- not a base table column (default ignored)
		,@paymentStatusRowGUID        uniqueidentifier  = newid()							-- not a base table column (default ignored)
		,@paymentTypeSCD              varchar(15)       = '?'									-- not a base table column (default ignored)
		,@paymentTypeLabel            nvarchar(35)      = N'?'								-- not a base table column (default ignored)
		,@paymentTypeCategory         nvarchar(65)														-- not a base table column (default ignored)
		,@gLAccountSID                int               = 0										-- not a base table column (default ignored)
		,@paymentTypePaymentStatusSID int               = 0										-- not a base table column (default ignored)
		,@isReferenceRequired         bit               = 0										-- not a base table column (default ignored)
		,@depositDateLagDays          smallint          = 0										-- not a base table column (default ignored)
		,@isRefundExcludedFromGL      bit               = 0										-- not a base table column (default ignored)
		,@excludeDepositFromGLBefore  date																		-- not a base table column (default ignored)
		,@paymentTypeIsDefault        bit               = 0										-- not a base table column (default ignored)
		,@paymentTypeIsActive         bit               = 0										-- not a base table column (default ignored)
		,@paymentTypeRowGUID          uniqueidentifier  = newid()							-- not a base table column (default ignored)
		,@genderSID                   int               = 0										-- not a base table column (default ignored)
		,@namePrefixSID               int																			-- not a base table column (default ignored)
		,@firstName                   nvarchar(30)      = N'?'								-- not a base table column (default ignored)
		,@commonName                  nvarchar(30)														-- not a base table column (default ignored)
		,@middleNames                 nvarchar(30)														-- not a base table column (default ignored)
		,@lastName                    nvarchar(35)      = N'?'								-- not a base table column (default ignored)
		,@birthDate                   date																		-- not a base table column (default ignored)
		,@deathDate                   date																		-- not a base table column (default ignored)
		,@homePhone                   varchar(25)															-- not a base table column (default ignored)
		,@mobilePhone                 varchar(25)															-- not a base table column (default ignored)
		,@isTextMessagingEnabled      bit               = 0										-- not a base table column (default ignored)
		,@importBatch                 nvarchar(100)														-- not a base table column (default ignored)
		,@personRowGUID               uniqueidentifier  = newid()							-- not a base table column (default ignored)
		,@reasonGroupSID              int																			-- not a base table column (default ignored)
		,@reasonName                  nvarchar(50)														-- not a base table column (default ignored)
		,@reasonCode                  varchar(25)															-- not a base table column (default ignored)
		,@reasonSequence              smallint																-- not a base table column (default ignored)
		,@toolTip                     nvarchar(500)														-- not a base table column (default ignored)
		,@reasonIsActive              bit																			-- not a base table column (default ignored)
		,@reasonRowGUID               uniqueidentifier												-- not a base table column (default ignored)
		,@isDeleteEnabled             bit																			-- not a base table column (default ignored)
		,@isReselected                tinyint           = 1										-- specific default required by EF - do not override
		,@isNullApplied               bit               = 1										-- specific default required by EF - do not override
		,@paymentLabel                nvarchar(4000)													-- not a base table column (default ignored)
		,@paymentShortLabel           nvarchar(4000)													-- not a base table column (default ignored)
		,@registrantLabel             nvarchar(75)														-- not a base table column (default ignored)
		,@isOnlinePayment             bit																			-- not a base table column (default ignored)
		,@totalApplied                decimal(11,2)														-- not a base table column (default ignored)
		,@totalUnapplied              decimal(11,2)														-- not a base table column (default ignored)
		,@isFullyApplied              bit																			-- not a base table column (default ignored)
		,@isNotApplied                bit																			-- not a base table column (default ignored)
		,@isPartiallyApplied          bit																			-- not a base table column (default ignored)
		,@isOverApplied               bit																			-- not a base table column (default ignored)
		,@isCancelled                 bit																			-- not a base table column (default ignored)
		,@isCancelEnabled             bit																			-- not a base table column (default ignored)
		,@isEditEnabled               bit																			-- not a base table column (default ignored)
		,@gLCheckSum                  int																			-- not a base table column (default ignored)
		,@latestTransactionID         varchar(50)															-- not a base table column (default ignored)
		,@latestChargeTotal           decimal(11,2)														-- not a base table column (default ignored)
		,@latestResponseCode          int																			-- not a base table column (default ignored)
		,@latestMessage               varchar(8000)														-- not a base table column (default ignored)
		,@latestApprovalCode          varchar(25)															-- not a base table column (default ignored)
		,@latestIsPaid                bit																			-- not a base table column (default ignored)
		,@latestVerifiedTime          datetime																-- not a base table column (default ignored)
		,@isRetryEnabled              bit																			-- not a base table column (default ignored)
		,@isReapplyEnabled            bit																			-- not a base table column (default ignored)
		,@transactionIDReference      nvarchar(150)														-- not a base table column (default ignored)
		,@verifiedTimeComponent       time(7)																	-- not a base table column (default ignored)
		,@invoiceSID                  int																			-- not a base table column (default ignored)

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
		-- set mandatory FK values to -1 where requested
		
		if @SetFKDefaults = @ON
		begin
			set @personSID = -1
			set @paymentTypeSID = -1
			set @paymentStatusSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @personSID            = isnull(context.node.value('@PersonSID'          ,'int'              ),@personSID)
			,@paymentTypeSID       = isnull(context.node.value('@PaymentTypeSID'     ,'int'              ),@paymentTypeSID)
			,@paymentStatusSID     = isnull(context.node.value('@PaymentStatusSID'   ,'int'              ),@paymentStatusSID)
			,@gLAccountCode        = isnull(context.node.value('@GLAccountCode'      ,'varchar(50)'      ),@gLAccountCode)
			,@gLPostingDate        = isnull(context.node.value('@GLPostingDate'      ,'date'             ),@gLPostingDate)
			,@depositDate          = isnull(context.node.value('@DepositDate'        ,'date'             ),@depositDate)
			,@amountPaid           = isnull(context.node.value('@AmountPaid'         ,'decimal(11,2)'    ),@amountPaid)
			,@reference            = isnull(context.node.value('@Reference'          ,'varchar(25)'      ),@reference)
			,@nameOnCard           = isnull(context.node.value('@NameOnCard'         ,'nvarchar(150)'    ),@nameOnCard)
			,@paymentCard          = isnull(context.node.value('@PaymentCard'        ,'varchar(20)'      ),@paymentCard)
			,@transactionID        = isnull(context.node.value('@TransactionID'      ,'varchar(50)'      ),@transactionID)
			,@lastResponseCode     = isnull(context.node.value('@LastResponseCode'   ,'varchar(50)'      ),@lastResponseCode)
			,@lastResponseMessage  = isnull(context.node.value('@LastResponseMessage','nvarchar(max)'    ),@lastResponseMessage)
			,@verifiedTime         = isnull(context.node.value('@VerifiedTime'       ,'datetime'         ),@verifiedTime)
			,@cancelledTime        = isnull(context.node.value('@CancelledTime'      ,'datetimeoffset(7)'),@cancelledTime)
			,@reasonSID            = isnull(context.node.value('@ReasonSID'          ,'int'              ),@reasonSID)
			,@paymentXID           = isnull(context.node.value('@PaymentXID'         ,'varchar(150)'     ),@paymentXID)
			,@legacyKey            = isnull(context.node.value('@LegacyKey'          ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		
		-- set default value on foreign keys where configured
		-- and where no DB or literal value was passed for it
		
		if isnull(@paymentTypeSID,0) = 0 select @paymentTypeSID = x.PaymentTypeSID from dbo.PaymentType x where x.IsDefault = @ON

		--! <Overrides>
		-- Tim Edlund | Sep 2017
		-- Check if an invoice is provided in context. If it is, then
		-- default the person SID and amount.

		select
			@invoiceSID = isnull(context.node.value('@InvoiceSID', 'int'), @invoiceSID)
		from
			@zContext.nodes('Parameters') as context(node);

		if @invoiceSID is not null
		begin
			select
				@amountPaid = i.TotalDue
			 ,@personSID	= i.PersonSID
			from
				dbo.vInvoice i
			where
				i.InvoiceSID = @invoiceSID;
		end;

		if @paymentTypeSID is null
		begin

			select
				@paymentTypeSID = pt.PaymentTypeSID
			from
				dbo.PaymentType pt
			where
				pt.IsDefault = @ON;
		end

		-- Tim Edlund | Sep 2017
		-- If no deposit date was provided, set it based on the lag
		-- defined for the payment type.  The Deposit Date is the
		-- date the transaction is expected to be displayed on the
		-- bank statement.

		if @depositDate is null and @paymentTypeSID is not null
		begin
			select
				@depositDate = dateadd(day, pt.DepositDateLagDays, sf.fToday())
			from
				dbo.PaymentType pt
			where
				pt.PaymentTypeSID = @paymentTypeSID;
		end;
		--! </Overrides>
	
		-- call the extended version of the procedure (if it exists) for "default.pre" mode
		
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
				 @Mode                        = 'default.pre'
				,@PaymentSID = @paymentSID
				,@PersonSID = @personSID output
				,@PaymentTypeSID = @paymentTypeSID output
				,@PaymentStatusSID = @paymentStatusSID output
				,@GLAccountCode = @gLAccountCode output
				,@GLPostingDate = @gLPostingDate output
				,@DepositDate = @depositDate output
				,@AmountPaid = @amountPaid output
				,@Reference = @reference output
				,@NameOnCard = @nameOnCard output
				,@PaymentCard = @paymentCard output
				,@TransactionID = @transactionID output
				,@LastResponseCode = @lastResponseCode output
				,@LastResponseMessage = @lastResponseMessage output
				,@VerifiedTime = @verifiedTime output
				,@CancelledTime = @cancelledTime output
				,@ReasonSID = @reasonSID output
				,@UserDefinedColumns = @userDefinedColumns output
				,@PaymentXID = @paymentXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@PaymentStatusSCD = @paymentStatusSCD
				,@PaymentStatusLabel = @paymentStatusLabel
				,@IsPaid = @isPaid
				,@PaymentStatusSequence = @paymentStatusSequence
				,@PaymentStatusRowGUID = @paymentStatusRowGUID
				,@PaymentTypeSCD = @paymentTypeSCD
				,@PaymentTypeLabel = @paymentTypeLabel
				,@PaymentTypeCategory = @paymentTypeCategory
				,@GLAccountSID = @gLAccountSID
				,@PaymentTypePaymentStatusSID = @paymentTypePaymentStatusSID
				,@IsReferenceRequired = @isReferenceRequired
				,@DepositDateLagDays = @depositDateLagDays
				,@IsRefundExcludedFromGL = @isRefundExcludedFromGL
				,@ExcludeDepositFromGLBefore = @excludeDepositFromGLBefore
				,@PaymentTypeIsDefault = @paymentTypeIsDefault
				,@PaymentTypeIsActive = @paymentTypeIsActive
				,@PaymentTypeRowGUID = @paymentTypeRowGUID
				,@GenderSID = @genderSID
				,@NamePrefixSID = @namePrefixSID
				,@FirstName = @firstName
				,@CommonName = @commonName
				,@MiddleNames = @middleNames
				,@LastName = @lastName
				,@BirthDate = @birthDate
				,@DeathDate = @deathDate
				,@HomePhone = @homePhone
				,@MobilePhone = @mobilePhone
				,@IsTextMessagingEnabled = @isTextMessagingEnabled
				,@ImportBatch = @importBatch
				,@PersonRowGUID = @personRowGUID
				,@ReasonGroupSID = @reasonGroupSID
				,@ReasonName = @reasonName
				,@ReasonCode = @reasonCode
				,@ReasonSequence = @reasonSequence
				,@ToolTip = @toolTip
				,@ReasonIsActive = @reasonIsActive
				,@ReasonRowGUID = @reasonRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
				,@PaymentLabel = @paymentLabel
				,@PaymentShortLabel = @paymentShortLabel
				,@RegistrantLabel = @registrantLabel
				,@IsOnlinePayment = @isOnlinePayment
				,@TotalApplied = @totalApplied
				,@TotalUnapplied = @totalUnapplied
				,@IsFullyApplied = @isFullyApplied
				,@IsNotApplied = @isNotApplied
				,@IsPartiallyApplied = @isPartiallyApplied
				,@IsOverApplied = @isOverApplied
				,@IsCancelled = @isCancelled
				,@IsCancelEnabled = @isCancelEnabled
				,@IsEditEnabled = @isEditEnabled
				,@GLCheckSum = @gLCheckSum
				,@LatestTransactionID = @latestTransactionID
				,@LatestChargeTotal = @latestChargeTotal
				,@LatestResponseCode = @latestResponseCode
				,@LatestMessage = @latestMessage
				,@LatestApprovalCode = @latestApprovalCode
				,@LatestIsPaid = @latestIsPaid
				,@LatestVerifiedTime = @latestVerifiedTime
				,@IsRetryEnabled = @isRetryEnabled
				,@IsReapplyEnabled = @isReapplyEnabled
				,@TransactionIDReference = @transactionIDReference
				,@VerifiedTimeComponent = @verifiedTimeComponent
				,@InvoiceSID = @invoiceSID
		
		end

		select
			 @paymentSID PaymentSID
			,@personSID PersonSID
			,@paymentTypeSID PaymentTypeSID
			,@paymentStatusSID PaymentStatusSID
			,@gLAccountCode GLAccountCode
			,@gLPostingDate GLPostingDate
			,@depositDate DepositDate
			,@amountPaid AmountPaid
			,@reference Reference
			,@nameOnCard NameOnCard
			,@paymentCard PaymentCard
			,@transactionID TransactionID
			,@lastResponseCode LastResponseCode
			,@lastResponseMessage LastResponseMessage
			,@verifiedTime VerifiedTime
			,@cancelledTime CancelledTime
			,@reasonSID ReasonSID
			,@userDefinedColumns UserDefinedColumns
			,@paymentXID PaymentXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@paymentStatusSCD PaymentStatusSCD
			,@paymentStatusLabel PaymentStatusLabel
			,@isPaid IsPaid
			,@paymentStatusSequence PaymentStatusSequence
			,@paymentStatusRowGUID PaymentStatusRowGUID
			,@paymentTypeSCD PaymentTypeSCD
			,@paymentTypeLabel PaymentTypeLabel
			,@paymentTypeCategory PaymentTypeCategory
			,@gLAccountSID GLAccountSID
			,@paymentTypePaymentStatusSID PaymentTypePaymentStatusSID
			,@isReferenceRequired IsReferenceRequired
			,@depositDateLagDays DepositDateLagDays
			,@isRefundExcludedFromGL IsRefundExcludedFromGL
			,@excludeDepositFromGLBefore ExcludeDepositFromGLBefore
			,@paymentTypeIsDefault PaymentTypeIsDefault
			,@paymentTypeIsActive PaymentTypeIsActive
			,@paymentTypeRowGUID PaymentTypeRowGUID
			,@genderSID GenderSID
			,@namePrefixSID NamePrefixSID
			,@firstName FirstName
			,@commonName CommonName
			,@middleNames MiddleNames
			,@lastName LastName
			,@birthDate BirthDate
			,@deathDate DeathDate
			,@homePhone HomePhone
			,@mobilePhone MobilePhone
			,@isTextMessagingEnabled IsTextMessagingEnabled
			,@importBatch ImportBatch
			,@personRowGUID PersonRowGUID
			,@reasonGroupSID ReasonGroupSID
			,@reasonName ReasonName
			,@reasonCode ReasonCode
			,@reasonSequence ReasonSequence
			,@toolTip ToolTip
			,@reasonIsActive ReasonIsActive
			,@reasonRowGUID ReasonRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@paymentLabel PaymentLabel
			,@paymentShortLabel PaymentShortLabel
			,@registrantLabel RegistrantLabel
			,@isOnlinePayment IsOnlinePayment
			,@totalApplied TotalApplied
			,@totalUnapplied TotalUnapplied
			,@isFullyApplied IsFullyApplied
			,@isNotApplied IsNotApplied
			,@isPartiallyApplied IsPartiallyApplied
			,@isOverApplied IsOverApplied
			,@isCancelled IsCancelled
			,@isCancelEnabled IsCancelEnabled
			,@isEditEnabled IsEditEnabled
			,@gLCheckSum GLCheckSum
			,@latestTransactionID LatestTransactionID
			,@latestChargeTotal LatestChargeTotal
			,@latestResponseCode LatestResponseCode
			,@latestMessage LatestMessage
			,@latestApprovalCode LatestApprovalCode
			,@latestIsPaid LatestIsPaid
			,@latestVerifiedTime LatestVerifiedTime
			,@isRetryEnabled IsRetryEnabled
			,@isReapplyEnabled IsReapplyEnabled
			,@transactionIDReference TransactionIDReference
			,@verifiedTimeComponent VerifiedTimeComponent
			,@invoiceSID InvoiceSID

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
