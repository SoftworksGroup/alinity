SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCatalogItem#Insert]
	 @CatalogItemSID            int               = null output							-- identity value assigned to the new record
	,@CatalogItemLabel          nvarchar(35)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@InvoiceItemDescription    nvarchar(500)     = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsLateFee                 bit               = null										-- default: CONVERT(bit,(0))
	,@ItemDetailedDescription   varbinary(max)    = null										
	,@ItemSmallImage            varbinary(max)    = null										
	,@ItemLargeImage            varbinary(max)    = null										
	,@ImageAlternateText        nvarchar(50)      = null										
	,@IsAvailableOnClientPortal bit               = null										-- default: CONVERT(bit,(0))
	,@IsComplaintPenalty        bit               = null										-- default: CONVERT(bit,(0))
	,@GLAccountSID              int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsTaxRate1Applied         bit               = null										-- default: (0)
	,@IsTaxRate2Applied         bit               = null										-- default: (0)
	,@IsTaxRate3Applied         bit               = null										-- default: (0)
	,@IsTaxDeductible           bit               = null										-- default: (1)
	,@EffectiveTime             datetime          = null										-- default: CONVERT(datetime,sf.fToday())
	,@ExpiryTime                datetime          = null										
	,@FileTypeSCD               varchar(8)        = null										-- default: '.HTML'
	,@FileTypeSID               int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns        xml               = null										
	,@CatalogItemXID            varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@GLAccountCode             varchar(50)       = null										-- not a base table column (default ignored)
	,@GLAccountLabel            nvarchar(35)      = null										-- not a base table column (default ignored)
	,@IsRevenueAccount          bit               = null										-- not a base table column (default ignored)
	,@IsBankAccount             bit               = null										-- not a base table column (default ignored)
	,@IsTaxAccount              bit               = null										-- not a base table column (default ignored)
	,@IsPAPAccount              bit               = null										-- not a base table column (default ignored)
	,@IsUnappliedPaymentAccount bit               = null										-- not a base table column (default ignored)
	,@DeferredGLAccountCode     varchar(50)       = null										-- not a base table column (default ignored)
	,@GLAccountIsActive         bit               = null										-- not a base table column (default ignored)
	,@GLAccountRowGUID          uniqueidentifier  = null										-- not a base table column (default ignored)
	,@FileTypeFileTypeSCD       varchar(8)        = null										-- not a base table column (default ignored)
	,@FileTypeLabel             nvarchar(35)      = null										-- not a base table column (default ignored)
	,@MimeType                  varchar(255)      = null										-- not a base table column (default ignored)
	,@IsInline                  bit               = null										-- not a base table column (default ignored)
	,@FileTypeIsActive          bit               = null										-- not a base table column (default ignored)
	,@FileTypeRowGUID           uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsActive                  bit               = null										-- not a base table column (default ignored)
	,@IsPending                 bit               = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
	,@CurrentPrice              decimal(11,2)     = null										-- not a base table column (default ignored)
	,@Tax1Label                 nvarchar(8)       = null										-- not a base table column (default ignored)
	,@Tax1Rate                  decimal(4,4)      = null										-- not a base table column (default ignored)
	,@Tax1GLAccountSID          int               = null										-- not a base table column (default ignored)
	,@Tax1Amount                decimal(11,2)     = null										-- not a base table column (default ignored)
	,@Tax2Label                 nvarchar(8)       = null										-- not a base table column (default ignored)
	,@Tax2Rate                  decimal(4,4)      = null										-- not a base table column (default ignored)
	,@Tax2GLAccountSID          int               = null										-- not a base table column (default ignored)
	,@Tax2Amount                decimal(11,2)     = null										-- not a base table column (default ignored)
	,@Tax3Label                 nvarchar(8)       = null										-- not a base table column (default ignored)
	,@Tax3Rate                  decimal(4,4)      = null										-- not a base table column (default ignored)
	,@Tax3GLAccountSID          int               = null										-- not a base table column (default ignored)
	,@Tax3Amount                decimal(11,2)     = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pCatalogItem#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.CatalogItem table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.CatalogItem table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vCatalogItem entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pCatalogItem procedure. The extended procedure is only called
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

	set @CatalogItemSID = null																							-- initialize output parameter

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

		set @CatalogItemLabel = ltrim(rtrim(@CatalogItemLabel))
		set @InvoiceItemDescription = ltrim(rtrim(@InvoiceItemDescription))
		set @ImageAlternateText = ltrim(rtrim(@ImageAlternateText))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @CatalogItemXID = ltrim(rtrim(@CatalogItemXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsLateFee = isnull(@IsLateFee,CONVERT(bit,(0)))
		set @IsAvailableOnClientPortal = isnull(@IsAvailableOnClientPortal,CONVERT(bit,(0)))
		set @IsComplaintPenalty = isnull(@IsComplaintPenalty,CONVERT(bit,(0)))
		set @IsTaxRate1Applied = isnull(@IsTaxRate1Applied,(0))
		set @IsTaxRate2Applied = isnull(@IsTaxRate2Applied,(0))
		set @IsTaxRate3Applied = isnull(@IsTaxRate3Applied,(0))
		set @IsTaxDeductible = isnull(@IsTaxDeductible,(1))
		set @EffectiveTime = isnull(@EffectiveTime,CONVERT(datetime,sf.fToday()))
		set @FileTypeSCD = isnull(@FileTypeSCD,'.HTML')
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected              = isnull(@IsReselected             ,(0))
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control
		
		-- ensure both the file type code (SCD) and key (SID) are provided - default from the value provided
		
		if @FileTypeSCD is null and @FileTypeSID is not null
		begin
		
			select
				@FileTypeSCD = ft.FileTypeSCD
			from
				sf.FileType ft
			where
				ft.FileTypeSID = @FileTypeSID
			and
				ft.IsActive = @ON
			
		end
		
		if @FileTypeSID is null and @FileTypeSCD is not null
		begin
		
			select
				@FileTypeSID = ft.FileTypeSID
			from
				sf.FileType ft
			where
				ft.FileTypeSCD = @FileTypeSCD
			and
				ft.IsActive = @ON
			
		end
		
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
				r.RoutineName = 'pCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pCatalogItem
				 @Mode                      = 'insert.pre'
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
				,@CreateUser                = @CreateUser
				,@IsReselected              = @IsReselected
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

		-- insert the record

		insert
			dbo.CatalogItem
		(
			 CatalogItemLabel
			,InvoiceItemDescription
			,IsLateFee
			,ItemDetailedDescription
			,ItemSmallImage
			,ItemLargeImage
			,ImageAlternateText
			,IsAvailableOnClientPortal
			,IsComplaintPenalty
			,GLAccountSID
			,IsTaxRate1Applied
			,IsTaxRate2Applied
			,IsTaxRate3Applied
			,IsTaxDeductible
			,EffectiveTime
			,ExpiryTime
			,FileTypeSCD
			,FileTypeSID
			,UserDefinedColumns
			,CatalogItemXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @CatalogItemLabel
			,@InvoiceItemDescription
			,@IsLateFee
			,@ItemDetailedDescription
			,@ItemSmallImage
			,@ItemLargeImage
			,@ImageAlternateText
			,@IsAvailableOnClientPortal
			,@IsComplaintPenalty
			,@GLAccountSID
			,@IsTaxRate1Applied
			,@IsTaxRate2Applied
			,@IsTaxRate3Applied
			,@IsTaxDeductible
			,@EffectiveTime
			,@ExpiryTime
			,@FileTypeSCD
			,@FileTypeSID
			,@UserDefinedColumns
			,@CatalogItemXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected   = @@rowcount
			,@CatalogItemSID = scope_identity()																	-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.CatalogItem'
				,@Arg3        = @rowsAffected
				,@Arg4        = @CatalogItemSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Cory Ng | Mar 2018
		-- Sets the initial price of the catalog item

		if @CurrentPrice is not null
		begin

			exec dbo.pCatalogItemPrice#Insert
					@CatalogItemSID = @CatalogItemSID
				, @Price = @CurrentPrice;

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
				r.RoutineName = 'pCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pCatalogItem
				 @Mode                      = 'insert.post'
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
				,@CreateUser                = @CreateUser
				,@IsReselected              = @IsReselected
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
