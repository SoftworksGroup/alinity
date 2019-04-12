SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoiceItem#Insert]
	 @InvoiceItemSID                    int               = null output			-- identity value assigned to the new record
	,@InvoiceSID                        int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@InvoiceItemDescription            nvarchar(500)     = null						-- required! if not passed value must be set in custom logic prior to insert
	,@Price                             decimal(11,2)     = null						-- required! if not passed value must be set in custom logic prior to insert
	,@Quantity                          int               = null						-- default: (1)
	,@Adjustment                        decimal(11,2)     = null						-- default: (0.00)
	,@ReasonSID                         int               = null						
	,@IsTaxRate1Applied                 bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxRate2Applied                 bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxRate3Applied                 bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxDeductible                   bit               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@GLAccountCode                     varchar(50)       = null						-- required! if not passed value must be set in custom logic prior to insert
	,@CatalogItemSID                    int               = null						
	,@UserDefinedColumns                xml               = null						
	,@InvoiceItemXID                    varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@PersonSID                         int               = null						-- not a base table column (default ignored)
	,@InvoiceDate                       date              = null						-- not a base table column (default ignored)
	,@Tax1Label                         nvarchar(8)       = null						-- not a base table column (default ignored)
	,@Tax1Rate                          decimal(4,4)      = null						-- not a base table column (default ignored)
	,@Tax1GLAccountCode                 varchar(50)       = null						-- not a base table column (default ignored)
	,@Tax2Label                         nvarchar(8)       = null						-- not a base table column (default ignored)
	,@Tax2Rate                          decimal(4,4)      = null						-- not a base table column (default ignored)
	,@Tax2GLAccountCode                 varchar(50)       = null						-- not a base table column (default ignored)
	,@Tax3Label                         nvarchar(8)       = null						-- not a base table column (default ignored)
	,@Tax3Rate                          decimal(4,4)      = null						-- not a base table column (default ignored)
	,@Tax3GLAccountCode                 varchar(50)       = null						-- not a base table column (default ignored)
	,@RegistrationYear                  smallint          = null						-- not a base table column (default ignored)
	,@CancelledTime                     datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@InvoiceReasonSID                  int               = null						-- not a base table column (default ignored)
	,@IsRefund                          bit               = null						-- not a base table column (default ignored)
	,@ComplaintSID                      int               = null						-- not a base table column (default ignored)
	,@InvoiceRowGUID                    uniqueidentifier  = null						-- not a base table column (default ignored)
	,@ReasonGroupSID                    int               = null						-- not a base table column (default ignored)
	,@ReasonName                        nvarchar(50)      = null						-- not a base table column (default ignored)
	,@ReasonCode                        varchar(25)       = null						-- not a base table column (default ignored)
	,@ReasonSequence                    smallint          = null						-- not a base table column (default ignored)
	,@ToolTip                           nvarchar(500)     = null						-- not a base table column (default ignored)
	,@ReasonIsActive                    bit               = null						-- not a base table column (default ignored)
	,@ReasonRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@CatalogItemLabel                  nvarchar(35)      = null						-- not a base table column (default ignored)
	,@CatalogItemInvoiceItemDescription nvarchar(500)     = null						-- not a base table column (default ignored)
	,@IsLateFee                         bit               = null						-- not a base table column (default ignored)
	,@ImageAlternateText                nvarchar(50)      = null						-- not a base table column (default ignored)
	,@IsAvailableOnClientPortal         bit               = null						-- not a base table column (default ignored)
	,@IsComplaintPenalty                bit               = null						-- not a base table column (default ignored)
	,@GLAccountSID                      int               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxRate1Applied      bit               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxRate2Applied      bit               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxRate3Applied      bit               = null						-- not a base table column (default ignored)
	,@CatalogItemIsTaxDeductible        bit               = null						-- not a base table column (default ignored)
	,@EffectiveTime                     datetime          = null						-- not a base table column (default ignored)
	,@ExpiryTime                        datetime          = null						-- not a base table column (default ignored)
	,@FileTypeSCD                       varchar(8)        = null						-- not a base table column (default ignored)
	,@FileTypeSID                       int               = null						-- not a base table column (default ignored)
	,@CatalogItemRowGUID                uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@AmountBeforeAdjustment            decimal(11,2)     = null						-- not a base table column (default ignored)
	,@AmountBeforeTax                   decimal(11,2)     = null						-- not a base table column (default ignored)
	,@Tax1Amount                        decimal(11,2)     = null						-- not a base table column (default ignored)
	,@Tax2Amount                        decimal(11,2)     = null						-- not a base table column (default ignored)
	,@Tax3Amount                        decimal(11,2)     = null						-- not a base table column (default ignored)
	,@AmountAfterTax                    decimal(11,2)     = null						-- not a base table column (default ignored)
	,@IsAdjusted                        bit               = null						-- not a base table column (default ignored)
	,@GLAccountLabel                    nvarchar(35)      = null						-- not a base table column (default ignored)
	,@IsRevenueAccount                  bit               = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoiceItem#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.InvoiceItem table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.InvoiceItem table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vInvoiceItem entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pInvoiceItem procedure. The extended procedure is only called
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

	set @InvoiceItemSID = null																							-- initialize output parameter

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

		set @InvoiceItemDescription = ltrim(rtrim(@InvoiceItemDescription))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @InvoiceItemXID = ltrim(rtrim(@InvoiceItemXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @Quantity = isnull(@Quantity,(1))
		set @Adjustment = isnull(@Adjustment,(0.00))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected           = isnull(@IsReselected          ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Mar 2018
		-- If no GLAccount code, price or description was provided but a
		-- catalog item has, lookup the missing values

		declare
			@isDeffered					bit																	-- indicates the revenue is collected for a later registration year	
		 ,@applicationUserSID int;																-- user who is assigned to the invoice

		if (
				 @GLAccountCode is null or @Price is null or @InvoiceItemDescription is null
			 ) and @CatalogItemSID is not null
		begin

			select
				@isDeffered					= case
																when dbo.fRegistrationYear(sf.fDTOffsetToClientDateTime(i.CreateTime)) < i.RegistrationYear then @ON
																else @OFF
															end
			 ,@applicationUserSID = au.ApplicationUserSID
			from
				dbo.Invoice				 i
			left outer join
				sf.ApplicationUser au on i.PersonSID = au.PersonSID
			where
				i.InvoiceSID = @InvoiceSID;

			select
				@InvoiceItemDescription =
				isnull( @InvoiceItemDescription
							 ,case
									when @applicationUserSID is null then ci.InvoiceItemDescription
									else sf.fAltLanguage#Field(ci.RowGUID, 'InvoiceItemDescription', ci.InvoiceItemDescription, @applicationUserSID)
								end
							)
			 ,@Price									= isnull(@Price, cicp.Price)
			 ,@GLAccountCode					= isnull(@GLAccountCode, (case when @isDeffered = @ON then isnull(gla.DeferredGLAccountCode, gla.GLAccountCode) else gla.GLAccountCode end))
			 ,@IsTaxDeductible				= isnull(@IsTaxDeductible, ci.IsTaxDeductible)
			 ,@IsTaxRate1Applied			= isnull(@IsTaxRate1Applied, ci.IsTaxRate1Applied)
			 ,@IsTaxRate2Applied			= isnull(@IsTaxRate2Applied, ci.IsTaxRate2Applied)
			 ,@IsTaxRate3Applied			= isnull(@IsTaxRate3Applied, ci.IsTaxRate3Applied)
			from
				dbo.PracticeRegisterCatalogItem																							 prci
			join
				dbo.CatalogItem																															 ci on prci.CatalogItemSID = ci.CatalogItemSID
			join
				dbo.GLAccount																																 gla on ci.GLAccountSID = gla.GLAccountSID
			cross apply dbo.fCatalogItem#CurrentPrice(prci.CatalogItemSID, @EffectiveTime) cicp
			where
				prci.CatalogItemSID = @CatalogItemSID;

		end;

		if @Price is null
		begin

			select @CatalogItemLabel = ci.CatalogItemLabel from dbo.CatalogItem ci where ci.CatalogItemSID = @CatalogItemSID;

			exec sf.pMessage#Get
				@MessageSCD = 'InvoiceItemCatalogPriceNotEffective'
				,@MessageText = @errorText output
				,@DefaultText = N'Catalog item "%1" does not have a price that is effective at %2. Please adjust the price effective time.'
				,@Arg1 = @CatalogItemLabel
				,@Arg2 = @EffectiveTime;

			raiserror(@errorText, 16, 1);

		end;

		-- tax application columns are NOT NULL with no default
		-- so set here if not set above

		set @IsTaxRate1Applied = isnull(@IsTaxRate1Applied,(0))
		set @IsTaxRate2Applied = isnull(@IsTaxRate2Applied,(0))
		set @IsTaxRate3Applied = isnull(@IsTaxRate3Applied,(0))
		set @IsTaxDeductible = isnull(@IsTaxDeductible,(0))

		-- Tim Edlund | Oct 2017
		-- Process replacement values that may be in the invoice item description

		if @RegistrationYear is not null
		begin

			select
				@InvoiceItemDescription = replace(@InvoiceItemDescription, '[@RegYear]', dbo.fRegistrationYearLabel(rsy.YearStartTime))
			from
				dbo.RegistrationScheduleYear rsy
			join
				dbo.RegistrationSchedule		 rs on rsy.RegistrationScheduleSID = rs.RegistrationScheduleSID
			where
				rs.IsDefault = @ON and rsy.RegistrationYear = @RegistrationYear;		end;
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
				r.RoutineName = 'pInvoiceItem'
		)
		begin
		
			exec @errorNo = ext.pInvoiceItem
				 @Mode                              = 'insert.pre'
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
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
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

		-- insert the record

		insert
			dbo.InvoiceItem
		(
			 InvoiceSID
			,InvoiceItemDescription
			,Price
			,Quantity
			,Adjustment
			,ReasonSID
			,IsTaxRate1Applied
			,IsTaxRate2Applied
			,IsTaxRate3Applied
			,IsTaxDeductible
			,GLAccountCode
			,CatalogItemSID
			,UserDefinedColumns
			,InvoiceItemXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @InvoiceSID
			,@InvoiceItemDescription
			,@Price
			,@Quantity
			,@Adjustment
			,@ReasonSID
			,@IsTaxRate1Applied
			,@IsTaxRate2Applied
			,@IsTaxRate3Applied
			,@IsTaxDeductible
			,@GLAccountCode
			,@CatalogItemSID
			,@UserDefinedColumns
			,@InvoiceItemXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected   = @@rowcount
			,@InvoiceItemSID = scope_identity()																	-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.InvoiceItem'
				,@Arg3        = @rowsAffected
				,@Arg4        = @InvoiceItemSID
			
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
				r.RoutineName = 'pInvoiceItem'
		)
		begin
		
			exec @errorNo = ext.pInvoiceItem
				 @Mode                              = 'insert.post'
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
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
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
