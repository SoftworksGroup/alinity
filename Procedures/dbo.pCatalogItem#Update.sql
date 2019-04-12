SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCatalogItem#Update]
	 @CatalogItemSID            int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@CatalogItemLabel          nvarchar(35)      = null -- table column values to update:
	,@InvoiceItemDescription    nvarchar(500)     = null
	,@IsLateFee                 bit               = null
	,@ItemDetailedDescription   varbinary(max)    = null
	,@ItemSmallImage            varbinary(max)    = null
	,@ItemLargeImage            varbinary(max)    = null
	,@ImageAlternateText        nvarchar(50)      = null
	,@IsAvailableOnClientPortal bit               = null
	,@IsComplaintPenalty        bit               = null
	,@GLAccountSID              int               = null
	,@IsTaxRate1Applied         bit               = null
	,@IsTaxRate2Applied         bit               = null
	,@IsTaxRate3Applied         bit               = null
	,@IsTaxDeductible           bit               = null
	,@EffectiveTime             datetime          = null
	,@ExpiryTime                datetime          = null
	,@FileTypeSCD               varchar(8)        = null
	,@FileTypeSID               int               = null
	,@UserDefinedColumns        xml               = null
	,@CatalogItemXID            varchar(150)      = null
	,@LegacyKey                 nvarchar(50)      = null
	,@UpdateUser                nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                  timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected              tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied             bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                  xml               = null -- other values defining context for the update (if any)
	,@GLAccountCode             varchar(50)       = null -- not a base table column
	,@GLAccountLabel            nvarchar(35)      = null -- not a base table column
	,@IsRevenueAccount          bit               = null -- not a base table column
	,@IsBankAccount             bit               = null -- not a base table column
	,@IsTaxAccount              bit               = null -- not a base table column
	,@IsPAPAccount              bit               = null -- not a base table column
	,@IsUnappliedPaymentAccount bit               = null -- not a base table column
	,@DeferredGLAccountCode     varchar(50)       = null -- not a base table column
	,@GLAccountIsActive         bit               = null -- not a base table column
	,@GLAccountRowGUID          uniqueidentifier  = null -- not a base table column
	,@FileTypeFileTypeSCD       varchar(8)        = null -- not a base table column
	,@FileTypeLabel             nvarchar(35)      = null -- not a base table column
	,@MimeType                  varchar(255)      = null -- not a base table column
	,@IsInline                  bit               = null -- not a base table column
	,@FileTypeIsActive          bit               = null -- not a base table column
	,@FileTypeRowGUID           uniqueidentifier  = null -- not a base table column
	,@IsActive                  bit               = null -- not a base table column
	,@IsPending                 bit               = null -- not a base table column
	,@IsDeleteEnabled           bit               = null -- not a base table column
	,@CurrentPrice              decimal(11,2)     = null -- not a base table column
	,@Tax1Label                 nvarchar(8)       = null -- not a base table column
	,@Tax1Rate                  decimal(4,4)      = null -- not a base table column
	,@Tax1GLAccountSID          int               = null -- not a base table column
	,@Tax1Amount                decimal(11,2)     = null -- not a base table column
	,@Tax2Label                 nvarchar(8)       = null -- not a base table column
	,@Tax2Rate                  decimal(4,4)      = null -- not a base table column
	,@Tax2GLAccountSID          int               = null -- not a base table column
	,@Tax2Amount                decimal(11,2)     = null -- not a base table column
	,@Tax3Label                 nvarchar(8)       = null -- not a base table column
	,@Tax3Rate                  decimal(4,4)      = null -- not a base table column
	,@Tax3GLAccountSID          int               = null -- not a base table column
	,@Tax3Amount                decimal(11,2)     = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pCatalogItem#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.CatalogItem table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.CatalogItem table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vCatalogItem entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pCatalogItem procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fCatalogItemCheck to test all rules.

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

		if @CatalogItemSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CatalogItemSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @CatalogItemLabel = ltrim(rtrim(@CatalogItemLabel))
		set @InvoiceItemDescription = ltrim(rtrim(@InvoiceItemDescription))
		set @ImageAlternateText = ltrim(rtrim(@ImageAlternateText))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @CatalogItemXID = ltrim(rtrim(@CatalogItemXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @GLAccountLabel = ltrim(rtrim(@GLAccountLabel))
		set @DeferredGLAccountCode = ltrim(rtrim(@DeferredGLAccountCode))
		set @FileTypeFileTypeSCD = ltrim(rtrim(@FileTypeFileTypeSCD))
		set @FileTypeLabel = ltrim(rtrim(@FileTypeLabel))
		set @MimeType = ltrim(rtrim(@MimeType))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))

		-- set zero length strings to null to avoid storing them in the record

		if len(@CatalogItemLabel) = 0 set @CatalogItemLabel = null
		if len(@InvoiceItemDescription) = 0 set @InvoiceItemDescription = null
		if len(@ImageAlternateText) = 0 set @ImageAlternateText = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@CatalogItemXID) = 0 set @CatalogItemXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@GLAccountLabel) = 0 set @GLAccountLabel = null
		if len(@DeferredGLAccountCode) = 0 set @DeferredGLAccountCode = null
		if len(@FileTypeFileTypeSCD) = 0 set @FileTypeFileTypeSCD = null
		if len(@FileTypeLabel) = 0 set @FileTypeLabel = null
		if len(@MimeType) = 0 set @MimeType = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax3Label) = 0 set @Tax3Label = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @CatalogItemLabel          = isnull(@CatalogItemLabel,ci.CatalogItemLabel)
				,@InvoiceItemDescription    = isnull(@InvoiceItemDescription,ci.InvoiceItemDescription)
				,@IsLateFee                 = isnull(@IsLateFee,ci.IsLateFee)
				,@ItemDetailedDescription   = isnull(@ItemDetailedDescription,ci.ItemDetailedDescription)
				,@ItemSmallImage            = isnull(@ItemSmallImage,ci.ItemSmallImage)
				,@ItemLargeImage            = isnull(@ItemLargeImage,ci.ItemLargeImage)
				,@ImageAlternateText        = isnull(@ImageAlternateText,ci.ImageAlternateText)
				,@IsAvailableOnClientPortal = isnull(@IsAvailableOnClientPortal,ci.IsAvailableOnClientPortal)
				,@IsComplaintPenalty        = isnull(@IsComplaintPenalty,ci.IsComplaintPenalty)
				,@GLAccountSID              = isnull(@GLAccountSID,ci.GLAccountSID)
				,@IsTaxRate1Applied         = isnull(@IsTaxRate1Applied,ci.IsTaxRate1Applied)
				,@IsTaxRate2Applied         = isnull(@IsTaxRate2Applied,ci.IsTaxRate2Applied)
				,@IsTaxRate3Applied         = isnull(@IsTaxRate3Applied,ci.IsTaxRate3Applied)
				,@IsTaxDeductible           = isnull(@IsTaxDeductible,ci.IsTaxDeductible)
				,@EffectiveTime             = isnull(@EffectiveTime,ci.EffectiveTime)
				,@ExpiryTime                = isnull(@ExpiryTime,ci.ExpiryTime)
				,@FileTypeSCD               = isnull(@FileTypeSCD,ci.FileTypeSCD)
				,@FileTypeSID               = isnull(@FileTypeSID,ci.FileTypeSID)
				,@UserDefinedColumns        = isnull(@UserDefinedColumns,ci.UserDefinedColumns)
				,@CatalogItemXID            = isnull(@CatalogItemXID,ci.CatalogItemXID)
				,@LegacyKey                 = isnull(@LegacyKey,ci.LegacyKey)
				,@UpdateUser                = isnull(@UpdateUser,ci.UpdateUser)
				,@IsReselected              = isnull(@IsReselected,ci.IsReselected)
				,@IsNullApplied             = isnull(@IsNullApplied,ci.IsNullApplied)
				,@zContext                  = isnull(@zContext,ci.zContext)
				,@GLAccountCode             = isnull(@GLAccountCode,ci.GLAccountCode)
				,@GLAccountLabel            = isnull(@GLAccountLabel,ci.GLAccountLabel)
				,@IsRevenueAccount          = isnull(@IsRevenueAccount,ci.IsRevenueAccount)
				,@IsBankAccount             = isnull(@IsBankAccount,ci.IsBankAccount)
				,@IsTaxAccount              = isnull(@IsTaxAccount,ci.IsTaxAccount)
				,@IsPAPAccount              = isnull(@IsPAPAccount,ci.IsPAPAccount)
				,@IsUnappliedPaymentAccount = isnull(@IsUnappliedPaymentAccount,ci.IsUnappliedPaymentAccount)
				,@DeferredGLAccountCode     = isnull(@DeferredGLAccountCode,ci.DeferredGLAccountCode)
				,@GLAccountIsActive         = isnull(@GLAccountIsActive,ci.GLAccountIsActive)
				,@GLAccountRowGUID          = isnull(@GLAccountRowGUID,ci.GLAccountRowGUID)
				,@FileTypeFileTypeSCD       = isnull(@FileTypeFileTypeSCD,ci.FileTypeFileTypeSCD)
				,@FileTypeLabel             = isnull(@FileTypeLabel,ci.FileTypeLabel)
				,@MimeType                  = isnull(@MimeType,ci.MimeType)
				,@IsInline                  = isnull(@IsInline,ci.IsInline)
				,@FileTypeIsActive          = isnull(@FileTypeIsActive,ci.FileTypeIsActive)
				,@FileTypeRowGUID           = isnull(@FileTypeRowGUID,ci.FileTypeRowGUID)
				,@IsActive                  = isnull(@IsActive,ci.IsActive)
				,@IsPending                 = isnull(@IsPending,ci.IsPending)
				,@IsDeleteEnabled           = isnull(@IsDeleteEnabled,ci.IsDeleteEnabled)
				,@CurrentPrice              = isnull(@CurrentPrice,ci.CurrentPrice)
				,@Tax1Label                 = isnull(@Tax1Label,ci.Tax1Label)
				,@Tax1Rate                  = isnull(@Tax1Rate,ci.Tax1Rate)
				,@Tax1GLAccountSID          = isnull(@Tax1GLAccountSID,ci.Tax1GLAccountSID)
				,@Tax1Amount                = isnull(@Tax1Amount,ci.Tax1Amount)
				,@Tax2Label                 = isnull(@Tax2Label,ci.Tax2Label)
				,@Tax2Rate                  = isnull(@Tax2Rate,ci.Tax2Rate)
				,@Tax2GLAccountSID          = isnull(@Tax2GLAccountSID,ci.Tax2GLAccountSID)
				,@Tax2Amount                = isnull(@Tax2Amount,ci.Tax2Amount)
				,@Tax3Label                 = isnull(@Tax3Label,ci.Tax3Label)
				,@Tax3Rate                  = isnull(@Tax3Rate,ci.Tax3Rate)
				,@Tax3GLAccountSID          = isnull(@Tax3GLAccountSID,ci.Tax3GLAccountSID)
				,@Tax3Amount                = isnull(@Tax3Amount,ci.Tax3Amount)
			from
				dbo.vCatalogItem ci
			where
				ci.CatalogItemSID = @CatalogItemSID

		end
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control
		
		-- ensure the file type SID value matches the code being set; a trigger
		-- enforces the rule for updates outside of the EF sprocs
		
		select
			@FileTypeSID = ft.FileTypeSID
		from
			sf.FileType ft
		where
			ft.FileTypeSCD = @FileTypeSCD
		and
			ft.IsActive = @ON
		
		if @@rowcount = 0
		begin
		
			exec sf.pMessage#Get
				@MessageSCD  = 'FileTypeNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The file type "%1" is not supported. Upload a different file or ask your administrator if this type can be added to the configuration.'
				,@Arg1        = @FileTypeSCD
		
			raiserror(@errorText, 16, 1)
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.FileTypeSID from dbo.CatalogItem x where x.CatalogItemSID = @CatalogItemSID) <> @FileTypeSID
			begin
			
				if (select x.IsActive from sf.FileType x where x.FileTypeSID = @FileTypeSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'file type'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.GLAccountSID from dbo.CatalogItem x where x.CatalogItemSID = @CatalogItemSID) <> @GLAccountSID
			begin
			
				if (select x.IsActive from dbo.GLAccount x where x.GLAccountSID = @GLAccountSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'glaccount'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
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
				r.RoutineName = 'pCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pCatalogItem
				 @Mode                      = 'update.pre'
				,@CatalogItemSID            = @CatalogItemSID
				,@CatalogItemLabel          = @CatalogItemLabel output
				,@InvoiceItemDescription    = @InvoiceItemDescription output
				,@IsLateFee                 = @IsLateFee output
				,@ItemDetailedDescription   = @ItemDetailedDescription output
				,@ItemSmallImage            = @ItemSmallImage output
				,@ItemLargeImage            = @ItemLargeImage output
				,@ImageAlternateText        = @ImageAlternateText output
				,@IsAvailableOnClientPortal = @IsAvailableOnClientPortal output
				,@IsComplaintPenalty        = @IsComplaintPenalty output
				,@GLAccountSID              = @GLAccountSID output
				,@IsTaxRate1Applied         = @IsTaxRate1Applied output
				,@IsTaxRate2Applied         = @IsTaxRate2Applied output
				,@IsTaxRate3Applied         = @IsTaxRate3Applied output
				,@IsTaxDeductible           = @IsTaxDeductible output
				,@EffectiveTime             = @EffectiveTime output
				,@ExpiryTime                = @ExpiryTime output
				,@FileTypeSCD               = @FileTypeSCD output
				,@FileTypeSID               = @FileTypeSID output
				,@UserDefinedColumns        = @UserDefinedColumns output
				,@CatalogItemXID            = @CatalogItemXID output
				,@LegacyKey                 = @LegacyKey output
				,@UpdateUser                = @UpdateUser
				,@RowStamp                  = @RowStamp
				,@IsReselected              = @IsReselected
				,@IsNullApplied             = @IsNullApplied
				,@zContext                  = @zContext
				,@GLAccountCode             = @GLAccountCode
				,@GLAccountLabel            = @GLAccountLabel
				,@IsRevenueAccount          = @IsRevenueAccount
				,@IsBankAccount             = @IsBankAccount
				,@IsTaxAccount              = @IsTaxAccount
				,@IsPAPAccount              = @IsPAPAccount
				,@IsUnappliedPaymentAccount = @IsUnappliedPaymentAccount
				,@DeferredGLAccountCode     = @DeferredGLAccountCode
				,@GLAccountIsActive         = @GLAccountIsActive
				,@GLAccountRowGUID          = @GLAccountRowGUID
				,@FileTypeFileTypeSCD       = @FileTypeFileTypeSCD
				,@FileTypeLabel             = @FileTypeLabel
				,@MimeType                  = @MimeType
				,@IsInline                  = @IsInline
				,@FileTypeIsActive          = @FileTypeIsActive
				,@FileTypeRowGUID           = @FileTypeRowGUID
				,@IsActive                  = @IsActive
				,@IsPending                 = @IsPending
				,@IsDeleteEnabled           = @IsDeleteEnabled
				,@CurrentPrice              = @CurrentPrice
				,@Tax1Label                 = @Tax1Label
				,@Tax1Rate                  = @Tax1Rate
				,@Tax1GLAccountSID          = @Tax1GLAccountSID
				,@Tax1Amount                = @Tax1Amount
				,@Tax2Label                 = @Tax2Label
				,@Tax2Rate                  = @Tax2Rate
				,@Tax2GLAccountSID          = @Tax2GLAccountSID
				,@Tax2Amount                = @Tax2Amount
				,@Tax3Label                 = @Tax3Label
				,@Tax3Rate                  = @Tax3Rate
				,@Tax3GLAccountSID          = @Tax3GLAccountSID
				,@Tax3Amount                = @Tax3Amount
		
		end

		-- update the record

		update
			dbo.CatalogItem
		set
			 CatalogItemLabel = @CatalogItemLabel
			,InvoiceItemDescription = @InvoiceItemDescription
			,IsLateFee = @IsLateFee
			,ItemDetailedDescription = @ItemDetailedDescription
			,ItemSmallImage = @ItemSmallImage
			,ItemLargeImage = @ItemLargeImage
			,ImageAlternateText = @ImageAlternateText
			,IsAvailableOnClientPortal = @IsAvailableOnClientPortal
			,IsComplaintPenalty = @IsComplaintPenalty
			,GLAccountSID = @GLAccountSID
			,IsTaxRate1Applied = @IsTaxRate1Applied
			,IsTaxRate2Applied = @IsTaxRate2Applied
			,IsTaxRate3Applied = @IsTaxRate3Applied
			,IsTaxDeductible = @IsTaxDeductible
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,FileTypeSCD = @FileTypeSCD
			,FileTypeSID = @FileTypeSID
			,UserDefinedColumns = @UserDefinedColumns
			,CatalogItemXID = @CatalogItemXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			CatalogItemSID = @CatalogItemSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.CatalogItem where CatalogItemSID = @catalogItemSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.CatalogItem'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.CatalogItem'
					,@Arg2        = @catalogItemSID
				
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
				,@Arg2        = 'dbo.CatalogItem'
				,@Arg3        = @rowsAffected
				,@Arg4        = @catalogItemSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
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
				r.RoutineName = 'pCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pCatalogItem
				 @Mode                      = 'update.post'
				,@CatalogItemSID            = @CatalogItemSID
				,@CatalogItemLabel          = @CatalogItemLabel
				,@InvoiceItemDescription    = @InvoiceItemDescription
				,@IsLateFee                 = @IsLateFee
				,@ItemDetailedDescription   = @ItemDetailedDescription
				,@ItemSmallImage            = @ItemSmallImage
				,@ItemLargeImage            = @ItemLargeImage
				,@ImageAlternateText        = @ImageAlternateText
				,@IsAvailableOnClientPortal = @IsAvailableOnClientPortal
				,@IsComplaintPenalty        = @IsComplaintPenalty
				,@GLAccountSID              = @GLAccountSID
				,@IsTaxRate1Applied         = @IsTaxRate1Applied
				,@IsTaxRate2Applied         = @IsTaxRate2Applied
				,@IsTaxRate3Applied         = @IsTaxRate3Applied
				,@IsTaxDeductible           = @IsTaxDeductible
				,@EffectiveTime             = @EffectiveTime
				,@ExpiryTime                = @ExpiryTime
				,@FileTypeSCD               = @FileTypeSCD
				,@FileTypeSID               = @FileTypeSID
				,@UserDefinedColumns        = @UserDefinedColumns
				,@CatalogItemXID            = @CatalogItemXID
				,@LegacyKey                 = @LegacyKey
				,@UpdateUser                = @UpdateUser
				,@RowStamp                  = @RowStamp
				,@IsReselected              = @IsReselected
				,@IsNullApplied             = @IsNullApplied
				,@zContext                  = @zContext
				,@GLAccountCode             = @GLAccountCode
				,@GLAccountLabel            = @GLAccountLabel
				,@IsRevenueAccount          = @IsRevenueAccount
				,@IsBankAccount             = @IsBankAccount
				,@IsTaxAccount              = @IsTaxAccount
				,@IsPAPAccount              = @IsPAPAccount
				,@IsUnappliedPaymentAccount = @IsUnappliedPaymentAccount
				,@DeferredGLAccountCode     = @DeferredGLAccountCode
				,@GLAccountIsActive         = @GLAccountIsActive
				,@GLAccountRowGUID          = @GLAccountRowGUID
				,@FileTypeFileTypeSCD       = @FileTypeFileTypeSCD
				,@FileTypeLabel             = @FileTypeLabel
				,@MimeType                  = @MimeType
				,@IsInline                  = @IsInline
				,@FileTypeIsActive          = @FileTypeIsActive
				,@FileTypeRowGUID           = @FileTypeRowGUID
				,@IsActive                  = @IsActive
				,@IsPending                 = @IsPending
				,@IsDeleteEnabled           = @IsDeleteEnabled
				,@CurrentPrice              = @CurrentPrice
				,@Tax1Label                 = @Tax1Label
				,@Tax1Rate                  = @Tax1Rate
				,@Tax1GLAccountSID          = @Tax1GLAccountSID
				,@Tax1Amount                = @Tax1Amount
				,@Tax2Label                 = @Tax2Label
				,@Tax2Rate                  = @Tax2Rate
				,@Tax2GLAccountSID          = @Tax2GLAccountSID
				,@Tax2Amount                = @Tax2Amount
				,@Tax3Label                 = @Tax3Label
				,@Tax3Rate                  = @Tax3Rate
				,@Tax3GLAccountSID          = @Tax3GLAccountSID
				,@Tax3Amount                = @Tax3Amount
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.CatalogItemSID
			from
				dbo.vCatalogItem ent
			where
				ent.CatalogItemSID = @CatalogItemSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.CatalogItemSID
				,ent.CatalogItemLabel
				,ent.InvoiceItemDescription
				,ent.IsLateFee
				,ent.ItemDetailedDescription
				,ent.ItemSmallImage
				,ent.ItemLargeImage
				,ent.ImageAlternateText
				,ent.IsAvailableOnClientPortal
				,ent.IsComplaintPenalty
				,ent.GLAccountSID
				,ent.IsTaxRate1Applied
				,ent.IsTaxRate2Applied
				,ent.IsTaxRate3Applied
				,ent.IsTaxDeductible
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.FileTypeSCD
				,ent.FileTypeSID
				,ent.UserDefinedColumns
				,ent.CatalogItemXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.GLAccountCode
				,ent.GLAccountLabel
				,ent.IsRevenueAccount
				,ent.IsBankAccount
				,ent.IsTaxAccount
				,ent.IsPAPAccount
				,ent.IsUnappliedPaymentAccount
				,ent.DeferredGLAccountCode
				,ent.GLAccountIsActive
				,ent.GLAccountRowGUID
				,ent.FileTypeFileTypeSCD
				,ent.FileTypeLabel
				,ent.MimeType
				,ent.IsInline
				,ent.FileTypeIsActive
				,ent.FileTypeRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.CurrentPrice
				,ent.Tax1Label
				,ent.Tax1Rate
				,ent.Tax1GLAccountSID
				,ent.Tax1Amount
				,ent.Tax2Label
				,ent.Tax2Rate
				,ent.Tax2GLAccountSID
				,ent.Tax2Amount
				,ent.Tax3Label
				,ent.Tax3Rate
				,ent.Tax3GLAccountSID
				,ent.Tax3Amount
			from
				dbo.vCatalogItem ent
			where
				ent.CatalogItemSID = @CatalogItemSID

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
