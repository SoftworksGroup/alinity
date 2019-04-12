SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoiceItem#Update]
	 @InvoiceItemSID                    int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@InvoiceSID                        int               = null -- table column values to update:
	,@InvoiceItemDescription            nvarchar(500)     = null
	,@Price                             decimal(11,2)     = null
	,@Quantity                          int               = null
	,@Adjustment                        decimal(11,2)     = null
	,@ReasonSID                         int               = null
	,@IsTaxRate1Applied                 bit               = null
	,@IsTaxRate2Applied                 bit               = null
	,@IsTaxRate3Applied                 bit               = null
	,@IsTaxDeductible                   bit               = null
	,@GLAccountCode                     varchar(50)       = null
	,@CatalogItemSID                    int               = null
	,@UserDefinedColumns                xml               = null
	,@InvoiceItemXID                    varchar(150)      = null
	,@LegacyKey                         nvarchar(50)      = null
	,@UpdateUser                        nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                          timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                      tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                     bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                          xml               = null -- other values defining context for the update (if any)
	,@PersonSID                         int               = null -- not a base table column
	,@InvoiceDate                       date              = null -- not a base table column
	,@Tax1Label                         nvarchar(8)       = null -- not a base table column
	,@Tax1Rate                          decimal(4,4)      = null -- not a base table column
	,@Tax1GLAccountCode                 varchar(50)       = null -- not a base table column
	,@Tax2Label                         nvarchar(8)       = null -- not a base table column
	,@Tax2Rate                          decimal(4,4)      = null -- not a base table column
	,@Tax2GLAccountCode                 varchar(50)       = null -- not a base table column
	,@Tax3Label                         nvarchar(8)       = null -- not a base table column
	,@Tax3Rate                          decimal(4,4)      = null -- not a base table column
	,@Tax3GLAccountCode                 varchar(50)       = null -- not a base table column
	,@RegistrationYear                  smallint          = null -- not a base table column
	,@CancelledTime                     datetimeoffset(7) = null -- not a base table column
	,@InvoiceReasonSID                  int               = null -- not a base table column
	,@IsRefund                          bit               = null -- not a base table column
	,@ComplaintSID                      int               = null -- not a base table column
	,@InvoiceRowGUID                    uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                    int               = null -- not a base table column
	,@ReasonName                        nvarchar(50)      = null -- not a base table column
	,@ReasonCode                        varchar(25)       = null -- not a base table column
	,@ReasonSequence                    smallint          = null -- not a base table column
	,@ToolTip                           nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                    bit               = null -- not a base table column
	,@ReasonRowGUID                     uniqueidentifier  = null -- not a base table column
	,@CatalogItemLabel                  nvarchar(35)      = null -- not a base table column
	,@CatalogItemInvoiceItemDescription nvarchar(500)     = null -- not a base table column
	,@IsLateFee                         bit               = null -- not a base table column
	,@ImageAlternateText                nvarchar(50)      = null -- not a base table column
	,@IsAvailableOnClientPortal         bit               = null -- not a base table column
	,@IsComplaintPenalty                bit               = null -- not a base table column
	,@GLAccountSID                      int               = null -- not a base table column
	,@CatalogItemIsTaxRate1Applied      bit               = null -- not a base table column
	,@CatalogItemIsTaxRate2Applied      bit               = null -- not a base table column
	,@CatalogItemIsTaxRate3Applied      bit               = null -- not a base table column
	,@CatalogItemIsTaxDeductible        bit               = null -- not a base table column
	,@EffectiveTime                     datetime          = null -- not a base table column
	,@ExpiryTime                        datetime          = null -- not a base table column
	,@FileTypeSCD                       varchar(8)        = null -- not a base table column
	,@FileTypeSID                       int               = null -- not a base table column
	,@CatalogItemRowGUID                uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                   bit               = null -- not a base table column
	,@AmountBeforeAdjustment            decimal(11,2)     = null -- not a base table column
	,@AmountBeforeTax                   decimal(11,2)     = null -- not a base table column
	,@Tax1Amount                        decimal(11,2)     = null -- not a base table column
	,@Tax2Amount                        decimal(11,2)     = null -- not a base table column
	,@Tax3Amount                        decimal(11,2)     = null -- not a base table column
	,@AmountAfterTax                    decimal(11,2)     = null -- not a base table column
	,@IsAdjusted                        bit               = null -- not a base table column
	,@GLAccountLabel                    nvarchar(35)      = null -- not a base table column
	,@IsRevenueAccount                  bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoiceItem#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.InvoiceItem table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.InvoiceItem table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vInvoiceItem entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pInvoiceItem procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fInvoiceItemCheck to test all rules.

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

		if @InvoiceItemSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@InvoiceItemSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @InvoiceItemDescription = ltrim(rtrim(@InvoiceItemDescription))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @InvoiceItemXID = ltrim(rtrim(@InvoiceItemXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @CatalogItemLabel = ltrim(rtrim(@CatalogItemLabel))
		set @CatalogItemInvoiceItemDescription = ltrim(rtrim(@CatalogItemInvoiceItemDescription))
		set @ImageAlternateText = ltrim(rtrim(@ImageAlternateText))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @GLAccountLabel = ltrim(rtrim(@GLAccountLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@InvoiceItemDescription) = 0 set @InvoiceItemDescription = null
		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@InvoiceItemXID) = 0 set @InvoiceItemXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@CatalogItemLabel) = 0 set @CatalogItemLabel = null
		if len(@CatalogItemInvoiceItemDescription) = 0 set @CatalogItemInvoiceItemDescription = null
		if len(@ImageAlternateText) = 0 set @ImageAlternateText = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@GLAccountLabel) = 0 set @GLAccountLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @InvoiceSID                        = isnull(@InvoiceSID,ii.InvoiceSID)
				,@InvoiceItemDescription            = isnull(@InvoiceItemDescription,ii.InvoiceItemDescription)
				,@Price                             = isnull(@Price,ii.Price)
				,@Quantity                          = isnull(@Quantity,ii.Quantity)
				,@Adjustment                        = isnull(@Adjustment,ii.Adjustment)
				,@ReasonSID                         = isnull(@ReasonSID,ii.ReasonSID)
				,@IsTaxRate1Applied                 = isnull(@IsTaxRate1Applied,ii.IsTaxRate1Applied)
				,@IsTaxRate2Applied                 = isnull(@IsTaxRate2Applied,ii.IsTaxRate2Applied)
				,@IsTaxRate3Applied                 = isnull(@IsTaxRate3Applied,ii.IsTaxRate3Applied)
				,@IsTaxDeductible                   = isnull(@IsTaxDeductible,ii.IsTaxDeductible)
				,@GLAccountCode                     = isnull(@GLAccountCode,ii.GLAccountCode)
				,@CatalogItemSID                    = isnull(@CatalogItemSID,ii.CatalogItemSID)
				,@UserDefinedColumns                = isnull(@UserDefinedColumns,ii.UserDefinedColumns)
				,@InvoiceItemXID                    = isnull(@InvoiceItemXID,ii.InvoiceItemXID)
				,@LegacyKey                         = isnull(@LegacyKey,ii.LegacyKey)
				,@UpdateUser                        = isnull(@UpdateUser,ii.UpdateUser)
				,@IsReselected                      = isnull(@IsReselected,ii.IsReselected)
				,@IsNullApplied                     = isnull(@IsNullApplied,ii.IsNullApplied)
				,@zContext                          = isnull(@zContext,ii.zContext)
				,@PersonSID                         = isnull(@PersonSID,ii.PersonSID)
				,@InvoiceDate                       = isnull(@InvoiceDate,ii.InvoiceDate)
				,@Tax1Label                         = isnull(@Tax1Label,ii.Tax1Label)
				,@Tax1Rate                          = isnull(@Tax1Rate,ii.Tax1Rate)
				,@Tax1GLAccountCode                 = isnull(@Tax1GLAccountCode,ii.Tax1GLAccountCode)
				,@Tax2Label                         = isnull(@Tax2Label,ii.Tax2Label)
				,@Tax2Rate                          = isnull(@Tax2Rate,ii.Tax2Rate)
				,@Tax2GLAccountCode                 = isnull(@Tax2GLAccountCode,ii.Tax2GLAccountCode)
				,@Tax3Label                         = isnull(@Tax3Label,ii.Tax3Label)
				,@Tax3Rate                          = isnull(@Tax3Rate,ii.Tax3Rate)
				,@Tax3GLAccountCode                 = isnull(@Tax3GLAccountCode,ii.Tax3GLAccountCode)
				,@RegistrationYear                  = isnull(@RegistrationYear,ii.RegistrationYear)
				,@CancelledTime                     = isnull(@CancelledTime,ii.CancelledTime)
				,@InvoiceReasonSID                  = isnull(@InvoiceReasonSID,ii.InvoiceReasonSID)
				,@IsRefund                          = isnull(@IsRefund,ii.IsRefund)
				,@ComplaintSID                      = isnull(@ComplaintSID,ii.ComplaintSID)
				,@InvoiceRowGUID                    = isnull(@InvoiceRowGUID,ii.InvoiceRowGUID)
				,@ReasonGroupSID                    = isnull(@ReasonGroupSID,ii.ReasonGroupSID)
				,@ReasonName                        = isnull(@ReasonName,ii.ReasonName)
				,@ReasonCode                        = isnull(@ReasonCode,ii.ReasonCode)
				,@ReasonSequence                    = isnull(@ReasonSequence,ii.ReasonSequence)
				,@ToolTip                           = isnull(@ToolTip,ii.ToolTip)
				,@ReasonIsActive                    = isnull(@ReasonIsActive,ii.ReasonIsActive)
				,@ReasonRowGUID                     = isnull(@ReasonRowGUID,ii.ReasonRowGUID)
				,@CatalogItemLabel                  = isnull(@CatalogItemLabel,ii.CatalogItemLabel)
				,@CatalogItemInvoiceItemDescription = isnull(@CatalogItemInvoiceItemDescription,ii.CatalogItemInvoiceItemDescription)
				,@IsLateFee                         = isnull(@IsLateFee,ii.IsLateFee)
				,@ImageAlternateText                = isnull(@ImageAlternateText,ii.ImageAlternateText)
				,@IsAvailableOnClientPortal         = isnull(@IsAvailableOnClientPortal,ii.IsAvailableOnClientPortal)
				,@IsComplaintPenalty                = isnull(@IsComplaintPenalty,ii.IsComplaintPenalty)
				,@GLAccountSID                      = isnull(@GLAccountSID,ii.GLAccountSID)
				,@CatalogItemIsTaxRate1Applied      = isnull(@CatalogItemIsTaxRate1Applied,ii.CatalogItemIsTaxRate1Applied)
				,@CatalogItemIsTaxRate2Applied      = isnull(@CatalogItemIsTaxRate2Applied,ii.CatalogItemIsTaxRate2Applied)
				,@CatalogItemIsTaxRate3Applied      = isnull(@CatalogItemIsTaxRate3Applied,ii.CatalogItemIsTaxRate3Applied)
				,@CatalogItemIsTaxDeductible        = isnull(@CatalogItemIsTaxDeductible,ii.CatalogItemIsTaxDeductible)
				,@EffectiveTime                     = isnull(@EffectiveTime,ii.EffectiveTime)
				,@ExpiryTime                        = isnull(@ExpiryTime,ii.ExpiryTime)
				,@FileTypeSCD                       = isnull(@FileTypeSCD,ii.FileTypeSCD)
				,@FileTypeSID                       = isnull(@FileTypeSID,ii.FileTypeSID)
				,@CatalogItemRowGUID                = isnull(@CatalogItemRowGUID,ii.CatalogItemRowGUID)
				,@IsDeleteEnabled                   = isnull(@IsDeleteEnabled,ii.IsDeleteEnabled)
				,@AmountBeforeAdjustment            = isnull(@AmountBeforeAdjustment,ii.AmountBeforeAdjustment)
				,@AmountBeforeTax                   = isnull(@AmountBeforeTax,ii.AmountBeforeTax)
				,@Tax1Amount                        = isnull(@Tax1Amount,ii.Tax1Amount)
				,@Tax2Amount                        = isnull(@Tax2Amount,ii.Tax2Amount)
				,@Tax3Amount                        = isnull(@Tax3Amount,ii.Tax3Amount)
				,@AmountAfterTax                    = isnull(@AmountAfterTax,ii.AmountAfterTax)
				,@IsAdjusted                        = isnull(@IsAdjusted,ii.IsAdjusted)
				,@GLAccountLabel                    = isnull(@GLAccountLabel,ii.GLAccountLabel)
				,@IsRevenueAccount                  = isnull(@IsRevenueAccount,ii.IsRevenueAccount)
			from
				dbo.vInvoiceItem ii
			where
				ii.InvoiceItemSID = @InvoiceItemSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ReasonSID from dbo.InvoiceItem x where x.InvoiceItemSID = @InvoiceItemSID) <> @ReasonSID
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
		-- Tim Edlund | Nov 2017
		-- If the amount of the line item is changing and GL Postings
		-- exist for the invoice, then reposting will be required in the
		-- POST event

		if @AmountAfterTax <>
		(
			select
				ii.AmountAfterTax
			from
				dbo.vInvoiceItem ii
			where
				ii.InvoiceItemSID = @InvoiceItemSID	-- amount after tax is changing
		)
		begin

			if exists
			(
				select
					1
				from
					dbo.GLTransaction	 gt
				join
					dbo.InvoicePayment ip on gt.InvoicePaymentSID = ip.InvoicePaymentSID
				join
					dbo.InvoiceItem		 ii on ip.InvoiceSID				= ii.InvoiceSID
				where
					ii.InvoiceItemSID = @InvoiceItemSID -- GL transactions exist for the invoice
			)
			begin
				set @GLAccountLabel = '*REPOST*'; -- store value to check in POST event
			end;

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
				r.RoutineName = 'pInvoiceItem'
		)
		begin
		
			exec @errorNo = ext.pInvoiceItem
				 @Mode                              = 'update.pre'
				,@InvoiceItemSID                    = @InvoiceItemSID
				,@InvoiceSID                        = @InvoiceSID output
				,@InvoiceItemDescription            = @InvoiceItemDescription output
				,@Price                             = @Price output
				,@Quantity                          = @Quantity output
				,@Adjustment                        = @Adjustment output
				,@ReasonSID                         = @ReasonSID output
				,@IsTaxRate1Applied                 = @IsTaxRate1Applied output
				,@IsTaxRate2Applied                 = @IsTaxRate2Applied output
				,@IsTaxRate3Applied                 = @IsTaxRate3Applied output
				,@IsTaxDeductible                   = @IsTaxDeductible output
				,@GLAccountCode                     = @GLAccountCode output
				,@CatalogItemSID                    = @CatalogItemSID output
				,@UserDefinedColumns                = @UserDefinedColumns output
				,@InvoiceItemXID                    = @InvoiceItemXID output
				,@LegacyKey                         = @LegacyKey output
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
				,@zContext                          = @zContext
				,@PersonSID                         = @PersonSID
				,@InvoiceDate                       = @InvoiceDate
				,@Tax1Label                         = @Tax1Label
				,@Tax1Rate                          = @Tax1Rate
				,@Tax1GLAccountCode                 = @Tax1GLAccountCode
				,@Tax2Label                         = @Tax2Label
				,@Tax2Rate                          = @Tax2Rate
				,@Tax2GLAccountCode                 = @Tax2GLAccountCode
				,@Tax3Label                         = @Tax3Label
				,@Tax3Rate                          = @Tax3Rate
				,@Tax3GLAccountCode                 = @Tax3GLAccountCode
				,@RegistrationYear                  = @RegistrationYear
				,@CancelledTime                     = @CancelledTime
				,@InvoiceReasonSID                  = @InvoiceReasonSID
				,@IsRefund                          = @IsRefund
				,@ComplaintSID                      = @ComplaintSID
				,@InvoiceRowGUID                    = @InvoiceRowGUID
				,@ReasonGroupSID                    = @ReasonGroupSID
				,@ReasonName                        = @ReasonName
				,@ReasonCode                        = @ReasonCode
				,@ReasonSequence                    = @ReasonSequence
				,@ToolTip                           = @ToolTip
				,@ReasonIsActive                    = @ReasonIsActive
				,@ReasonRowGUID                     = @ReasonRowGUID
				,@CatalogItemLabel                  = @CatalogItemLabel
				,@CatalogItemInvoiceItemDescription = @CatalogItemInvoiceItemDescription
				,@IsLateFee                         = @IsLateFee
				,@ImageAlternateText                = @ImageAlternateText
				,@IsAvailableOnClientPortal         = @IsAvailableOnClientPortal
				,@IsComplaintPenalty                = @IsComplaintPenalty
				,@GLAccountSID                      = @GLAccountSID
				,@CatalogItemIsTaxRate1Applied      = @CatalogItemIsTaxRate1Applied
				,@CatalogItemIsTaxRate2Applied      = @CatalogItemIsTaxRate2Applied
				,@CatalogItemIsTaxRate3Applied      = @CatalogItemIsTaxRate3Applied
				,@CatalogItemIsTaxDeductible        = @CatalogItemIsTaxDeductible
				,@EffectiveTime                     = @EffectiveTime
				,@ExpiryTime                        = @ExpiryTime
				,@FileTypeSCD                       = @FileTypeSCD
				,@FileTypeSID                       = @FileTypeSID
				,@CatalogItemRowGUID                = @CatalogItemRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@AmountBeforeAdjustment            = @AmountBeforeAdjustment
				,@AmountBeforeTax                   = @AmountBeforeTax
				,@Tax1Amount                        = @Tax1Amount
				,@Tax2Amount                        = @Tax2Amount
				,@Tax3Amount                        = @Tax3Amount
				,@AmountAfterTax                    = @AmountAfterTax
				,@IsAdjusted                        = @IsAdjusted
				,@GLAccountLabel                    = @GLAccountLabel
				,@IsRevenueAccount                  = @IsRevenueAccount
		
		end

		-- update the record

		update
			dbo.InvoiceItem
		set
			 InvoiceSID = @InvoiceSID
			,InvoiceItemDescription = @InvoiceItemDescription
			,Price = @Price
			,Quantity = @Quantity
			,Adjustment = @Adjustment
			,ReasonSID = @ReasonSID
			,IsTaxRate1Applied = @IsTaxRate1Applied
			,IsTaxRate2Applied = @IsTaxRate2Applied
			,IsTaxRate3Applied = @IsTaxRate3Applied
			,IsTaxDeductible = @IsTaxDeductible
			,GLAccountCode = @GLAccountCode
			,CatalogItemSID = @CatalogItemSID
			,UserDefinedColumns = @UserDefinedColumns
			,InvoiceItemXID = @InvoiceItemXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			InvoiceItemSID = @InvoiceItemSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.InvoiceItem where InvoiceItemSID = @invoiceItemSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.InvoiceItem'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.InvoiceItem'
					,@Arg2        = @invoiceItemSID
				
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
				,@Arg2        = 'dbo.InvoiceItem'
				,@Arg3        = @rowsAffected
				,@Arg4        = @invoiceItemSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>

		-- Tim Edlund | Apr 2018
		-- If the amount of the invoice was adjusted through this edit and the
		-- result is that the invoice is fully paid, AND, the invoice is
		-- associated with a registration form (Application, Renewal or
		-- Reinstatement), then the Registration can be created for it.
		-- These conditions are checked and action performed through a separate
		-- procedure call.

		exec dbo.pRegistration#SetOnPaid
			@InvoiceSID = @InvoiceSID

		-- Tim Edlund | Nov 2017
		-- If a change in amount for the line item was detected in the PRE event
		-- call the GL Repost action on all payments related to this invoice

		if @GLAccountLabel = '*REPOST*'
		begin

			declare @payments xml;

			set @recordSID = -1;

			while @recordSID is not null
			begin

				select
					@recordSID = p.PaymentSID
				from
					dbo.Payment				 p
				join
					dbo.InvoicePayment ip on p.PaymentSID	 = ip.PaymentSID
				join
					dbo.InvoiceItem		 ii on ip.InvoiceSID = ii.InvoiceSID
				where
					ii.InvoiceItemSID = @InvoiceItemSID and p.PaymentSID > @recordSID
				order by
					p.PaymentSID;

				if @@rowcount = 0
				begin
					set @recordSID = null;
				end;
				else
				begin

					if exists(select 1 from dbo.GLTransaction gt where gt.PaymentSID = @recordSID) -- avoid repost if no pre-existing postings are found
					begin

						set @payments = N'<Payments><Payment SID="' + ltrim(@recordSID) + '" /></Payments>';

						exec dbo.pGLTransaction#Repost
							@Payments = @payments;

					end

				end;

			end;

		end;

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
				r.RoutineName = 'pInvoiceItem'
		)
		begin
		
			exec @errorNo = ext.pInvoiceItem
				 @Mode                              = 'update.post'
				,@InvoiceItemSID                    = @InvoiceItemSID
				,@InvoiceSID                        = @InvoiceSID
				,@InvoiceItemDescription            = @InvoiceItemDescription
				,@Price                             = @Price
				,@Quantity                          = @Quantity
				,@Adjustment                        = @Adjustment
				,@ReasonSID                         = @ReasonSID
				,@IsTaxRate1Applied                 = @IsTaxRate1Applied
				,@IsTaxRate2Applied                 = @IsTaxRate2Applied
				,@IsTaxRate3Applied                 = @IsTaxRate3Applied
				,@IsTaxDeductible                   = @IsTaxDeductible
				,@GLAccountCode                     = @GLAccountCode
				,@CatalogItemSID                    = @CatalogItemSID
				,@UserDefinedColumns                = @UserDefinedColumns
				,@InvoiceItemXID                    = @InvoiceItemXID
				,@LegacyKey                         = @LegacyKey
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
				,@zContext                          = @zContext
				,@PersonSID                         = @PersonSID
				,@InvoiceDate                       = @InvoiceDate
				,@Tax1Label                         = @Tax1Label
				,@Tax1Rate                          = @Tax1Rate
				,@Tax1GLAccountCode                 = @Tax1GLAccountCode
				,@Tax2Label                         = @Tax2Label
				,@Tax2Rate                          = @Tax2Rate
				,@Tax2GLAccountCode                 = @Tax2GLAccountCode
				,@Tax3Label                         = @Tax3Label
				,@Tax3Rate                          = @Tax3Rate
				,@Tax3GLAccountCode                 = @Tax3GLAccountCode
				,@RegistrationYear                  = @RegistrationYear
				,@CancelledTime                     = @CancelledTime
				,@InvoiceReasonSID                  = @InvoiceReasonSID
				,@IsRefund                          = @IsRefund
				,@ComplaintSID                      = @ComplaintSID
				,@InvoiceRowGUID                    = @InvoiceRowGUID
				,@ReasonGroupSID                    = @ReasonGroupSID
				,@ReasonName                        = @ReasonName
				,@ReasonCode                        = @ReasonCode
				,@ReasonSequence                    = @ReasonSequence
				,@ToolTip                           = @ToolTip
				,@ReasonIsActive                    = @ReasonIsActive
				,@ReasonRowGUID                     = @ReasonRowGUID
				,@CatalogItemLabel                  = @CatalogItemLabel
				,@CatalogItemInvoiceItemDescription = @CatalogItemInvoiceItemDescription
				,@IsLateFee                         = @IsLateFee
				,@ImageAlternateText                = @ImageAlternateText
				,@IsAvailableOnClientPortal         = @IsAvailableOnClientPortal
				,@IsComplaintPenalty                = @IsComplaintPenalty
				,@GLAccountSID                      = @GLAccountSID
				,@CatalogItemIsTaxRate1Applied      = @CatalogItemIsTaxRate1Applied
				,@CatalogItemIsTaxRate2Applied      = @CatalogItemIsTaxRate2Applied
				,@CatalogItemIsTaxRate3Applied      = @CatalogItemIsTaxRate3Applied
				,@CatalogItemIsTaxDeductible        = @CatalogItemIsTaxDeductible
				,@EffectiveTime                     = @EffectiveTime
				,@ExpiryTime                        = @ExpiryTime
				,@FileTypeSCD                       = @FileTypeSCD
				,@FileTypeSID                       = @FileTypeSID
				,@CatalogItemRowGUID                = @CatalogItemRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@AmountBeforeAdjustment            = @AmountBeforeAdjustment
				,@AmountBeforeTax                   = @AmountBeforeTax
				,@Tax1Amount                        = @Tax1Amount
				,@Tax2Amount                        = @Tax2Amount
				,@Tax3Amount                        = @Tax3Amount
				,@AmountAfterTax                    = @AmountAfterTax
				,@IsAdjusted                        = @IsAdjusted
				,@GLAccountLabel                    = @GLAccountLabel
				,@IsRevenueAccount                  = @IsRevenueAccount
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.InvoiceItemSID
			from
				dbo.vInvoiceItem ent
			where
				ent.InvoiceItemSID = @InvoiceItemSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.InvoiceItemSID
				,ent.InvoiceSID
				,ent.InvoiceItemDescription
				,ent.Price
				,ent.Quantity
				,ent.Adjustment
				,ent.ReasonSID
				,ent.IsTaxRate1Applied
				,ent.IsTaxRate2Applied
				,ent.IsTaxRate3Applied
				,ent.IsTaxDeductible
				,ent.GLAccountCode
				,ent.CatalogItemSID
				,ent.UserDefinedColumns
				,ent.InvoiceItemXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonSID
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
				,ent.CancelledTime
				,ent.InvoiceReasonSID
				,ent.IsRefund
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.CatalogItemLabel
				,ent.CatalogItemInvoiceItemDescription
				,ent.IsLateFee
				,ent.ImageAlternateText
				,ent.IsAvailableOnClientPortal
				,ent.IsComplaintPenalty
				,ent.GLAccountSID
				,ent.CatalogItemIsTaxRate1Applied
				,ent.CatalogItemIsTaxRate2Applied
				,ent.CatalogItemIsTaxRate3Applied
				,ent.CatalogItemIsTaxDeductible
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.FileTypeSCD
				,ent.FileTypeSID
				,ent.CatalogItemRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.AmountBeforeAdjustment
				,ent.AmountBeforeTax
				,ent.Tax1Amount
				,ent.Tax2Amount
				,ent.Tax3Amount
				,ent.AmountAfterTax
				,ent.IsAdjusted
				,ent.GLAccountLabel
				,ent.IsRevenueAccount
			from
				dbo.vInvoiceItem ent
			where
				ent.InvoiceItemSID = @InvoiceItemSID

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
