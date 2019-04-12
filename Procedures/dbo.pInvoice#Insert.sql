SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoice#Insert]
	 @InvoiceSID                  int               = null output						-- identity value assigned to the new record
	,@PersonSID                   int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@InvoiceDate                 date              = null									-- default: sf.fToday()
	,@Tax1Label                   nvarchar(8)       = null									-- default: N'N/A'
	,@Tax1Rate                    decimal(4,4)      = null									-- default: (0.0)
	,@Tax1GLAccountCode           varchar(50)       = null									
	,@Tax2Label                   nvarchar(8)       = null									-- default: N'N/A'
	,@Tax2Rate                    decimal(4,4)      = null									-- default: (0.0)
	,@Tax2GLAccountCode           varchar(50)       = null									
	,@Tax3Label                   nvarchar(8)       = null									-- default: N'N/A'
	,@Tax3Rate                    decimal(4,4)      = null									-- default: (0.0)
	,@Tax3GLAccountCode           varchar(50)       = null									
	,@RegistrationYear            smallint          = null									-- required! if not passed value must be set in custom logic prior to insert
	,@CancelledTime               datetimeoffset(7) = null									
	,@ReasonSID                   int               = null									
	,@IsRefund                    bit               = null									-- default: CONVERT(bit,(0))
	,@ComplaintSID                int               = null									
	,@UserDefinedColumns          xml               = null									
	,@InvoiceXID                  varchar(150)      = null									
	,@LegacyKey                   nvarchar(50)      = null									
	,@CreateUser                  nvarchar(75)      = null									-- default: suser_sname()
	,@IsReselected                tinyint           = null									-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                    xml               = null									-- other values defining context for the insert (if any)
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
	,@ComplaintNo                 varchar(50)       = null									-- not a base table column (default ignored)
	,@RegistrantSID               int               = null									-- not a base table column (default ignored)
	,@ComplaintTypeSID            int               = null									-- not a base table column (default ignored)
	,@ComplainantTypeSID          int               = null									-- not a base table column (default ignored)
	,@ApplicationUserSID          int               = null									-- not a base table column (default ignored)
	,@OpenedDate                  date              = null									-- not a base table column (default ignored)
	,@ConductStartDate            date              = null									-- not a base table column (default ignored)
	,@ConductEndDate              date              = null									-- not a base table column (default ignored)
	,@ComplaintSeveritySID        int               = null									-- not a base table column (default ignored)
	,@IsDisplayedOnPublicRegistry bit               = null									-- not a base table column (default ignored)
	,@ClosedDate                  date              = null									-- not a base table column (default ignored)
	,@DismissedDate               date              = null									-- not a base table column (default ignored)
	,@ComplaintReasonSID          int               = null									-- not a base table column (default ignored)
	,@FileExtension               varchar(5)        = null									-- not a base table column (default ignored)
	,@ComplaintRowGUID            uniqueidentifier  = null									-- not a base table column (default ignored)
	,@ReasonGroupSID              int               = null									-- not a base table column (default ignored)
	,@ReasonName                  nvarchar(50)      = null									-- not a base table column (default ignored)
	,@ReasonCode                  varchar(25)       = null									-- not a base table column (default ignored)
	,@ReasonSequence              smallint          = null									-- not a base table column (default ignored)
	,@ToolTip                     nvarchar(500)     = null									-- not a base table column (default ignored)
	,@ReasonIsActive              bit               = null									-- not a base table column (default ignored)
	,@ReasonRowGUID               uniqueidentifier  = null									-- not a base table column (default ignored)
	,@IsDeleteEnabled             bit               = null									-- not a base table column (default ignored)
	,@InvoiceLabel                nvarchar(4000)    = null									-- not a base table column (default ignored)
	,@InvoiceShortLabel           nvarchar(4000)    = null									-- not a base table column (default ignored)
	,@TotalBeforeTax              decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Tax1Total                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Tax2Total                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Tax3Total                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalAdjustment             decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalAfterTax               decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalPaid                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalDue                    decimal(11,2)     = null									-- not a base table column (default ignored)
	,@IsUnPaid                    bit               = null									-- not a base table column (default ignored)
	,@IsPaid                      bit               = null									-- not a base table column (default ignored)
	,@IsOverPaid                  bit               = null									-- not a base table column (default ignored)
	,@IsOverDue                   bit               = null									-- not a base table column (default ignored)
	,@Tax1GLAccountLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@Tax1IsTaxAccount            bit               = null									-- not a base table column (default ignored)
	,@Tax2GLAccountLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@Tax2IsTaxAccount            bit               = null									-- not a base table column (default ignored)
	,@Tax3GLAccountLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@Tax3IsTaxAccount            bit               = null									-- not a base table column (default ignored)
	,@IsDeferred                  bit               = null									-- not a base table column (default ignored)
	,@IsCancelled                 bit               = null									-- not a base table column (default ignored)
	,@IsEditEnabled               bit               = null									-- not a base table column (default ignored)
	,@IsPAPSubscriber             bit               = null									-- not a base table column (default ignored)
	,@IsPAPEnabled                bit               = null									-- not a base table column (default ignored)
	,@AddressBlockForPrint        nvarchar(512)     = null									-- not a base table column (default ignored)
	,@AddressBlockForHTML         nvarchar(512)     = null									-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoice#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.Invoice table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Invoice table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vInvoice entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pInvoice procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fInvoiceCheck to test all rules.

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

	set @InvoiceSID = null																									-- initialize output parameter

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

		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @InvoiceXID = ltrim(rtrim(@InvoiceXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @InvoiceLabel = ltrim(rtrim(@InvoiceLabel))
		set @InvoiceShortLabel = ltrim(rtrim(@InvoiceShortLabel))
		set @Tax1GLAccountLabel = ltrim(rtrim(@Tax1GLAccountLabel))
		set @Tax2GLAccountLabel = ltrim(rtrim(@Tax2GLAccountLabel))
		set @Tax3GLAccountLabel = ltrim(rtrim(@Tax3GLAccountLabel))
		set @AddressBlockForPrint = ltrim(rtrim(@AddressBlockForPrint))
		set @AddressBlockForHTML = ltrim(rtrim(@AddressBlockForHTML))

		-- set zero length strings to null to avoid storing them in the record

		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@InvoiceXID) = 0 set @InvoiceXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@InvoiceLabel) = 0 set @InvoiceLabel = null
		if len(@InvoiceShortLabel) = 0 set @InvoiceShortLabel = null
		if len(@Tax1GLAccountLabel) = 0 set @Tax1GLAccountLabel = null
		if len(@Tax2GLAccountLabel) = 0 set @Tax2GLAccountLabel = null
		if len(@Tax3GLAccountLabel) = 0 set @Tax3GLAccountLabel = null
		if len(@AddressBlockForPrint) = 0 set @AddressBlockForPrint = null
		if len(@AddressBlockForHTML) = 0 set @AddressBlockForHTML = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @InvoiceDate = isnull(@InvoiceDate,sf.fToday())
		set @Tax1Label = isnull(@Tax1Label,N'N/A')
		set @Tax1Rate = isnull(@Tax1Rate,(0.0))
		set @Tax2Label = isnull(@Tax2Label,N'N/A')
		set @Tax2Rate = isnull(@Tax2Rate,(0.0))
		set @Tax3Label = isnull(@Tax3Label,N'N/A')
		set @Tax3Rate = isnull(@Tax3Rate,(0.0))
		set @IsRefund = isnull(@IsRefund,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Sep 2017
		-- Populate tax values if not already filled in.

		select
			@ApplicationUserSID = au.ApplicationUserSID
		from
			sf.ApplicationUser au
		where
			au.PersonSID = @PersonSID;

		if @Tax1Label is null or isnull(@Tax1Rate, 0.0) = 0.0 or @Tax1GLAccountCode is null
		begin

			select
				@Tax1Label				 = sf.fAltLanguage#Field(tcc.TaxRowGUID, 'TaxLabel', tcc.TaxLabel, @ApplicationUserSID)
			 ,@Tax1Rate					 = tcc.TaxRate
			 ,@Tax1GLAccountCode = tcc.GLAccountCode
			from
				dbo.vTaxConfiguration#Current tcc
			where
				tcc.TaxSequence = 1;

		end;

		if @Tax2Label is null or isnull(@Tax2Rate, 0.0) = 0.0 or @Tax2GLAccountCode is null
		begin

			select
				@Tax2Label				 = sf.fAltLanguage#Field(tcc.TaxRowGUID, 'TaxLabel', tcc.TaxLabel, @ApplicationUserSID)
			 ,@Tax2Rate					 = tcc.TaxRate
			 ,@Tax2GLAccountCode = tcc.GLAccountCode
			from
				dbo.vTaxConfiguration#Current tcc
			where
				tcc.TaxSequence = 2;

		end;

		if @Tax3Label is null or isnull(@Tax3Rate, 0.0) = 0.0 or @Tax3GLAccountCode is null
		begin

			select
				@Tax3Label				 = sf.fAltLanguage#Field(tcc.TaxRowGUID, 'TaxLabel', tcc.TaxLabel, @ApplicationUserSID)
			 ,@Tax3Rate					 = tcc.TaxRate
			 ,@Tax3GLAccountCode = tcc.GLAccountCode
			from
				dbo.vTaxConfiguration#Current tcc
			where
				tcc.TaxSequence = 3;

		end;

		-- Tim Edlund | Sep 2017
		-- Populate registration year if not already filled in.

		if @RegistrationYear is null set @RegistrationYear = dbo.fRegistrationYear#Current()

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
				r.RoutineName = 'pInvoice'
		)
		begin
		
			exec @errorNo = ext.pInvoice
				 @Mode                        = 'insert.pre'
				,@PersonSID                   = @PersonSID output
				,@InvoiceDate                 = @InvoiceDate output
				,@Tax1Label                   = @Tax1Label output
				,@Tax1Rate                    = @Tax1Rate output
				,@Tax1GLAccountCode           = @Tax1GLAccountCode output
				,@Tax2Label                   = @Tax2Label output
				,@Tax2Rate                    = @Tax2Rate output
				,@Tax2GLAccountCode           = @Tax2GLAccountCode output
				,@Tax3Label                   = @Tax3Label output
				,@Tax3Rate                    = @Tax3Rate output
				,@Tax3GLAccountCode           = @Tax3GLAccountCode output
				,@RegistrationYear            = @RegistrationYear output
				,@CancelledTime               = @CancelledTime output
				,@ReasonSID                   = @ReasonSID output
				,@IsRefund                    = @IsRefund output
				,@ComplaintSID                = @ComplaintSID output
				,@UserDefinedColumns          = @UserDefinedColumns output
				,@InvoiceXID                  = @InvoiceXID output
				,@LegacyKey                   = @LegacyKey output
				,@CreateUser                  = @CreateUser
				,@IsReselected                = @IsReselected
				,@zContext                    = @zContext
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
				,@ComplaintNo                 = @ComplaintNo
				,@RegistrantSID               = @RegistrantSID
				,@ComplaintTypeSID            = @ComplaintTypeSID
				,@ComplainantTypeSID          = @ComplainantTypeSID
				,@ApplicationUserSID          = @ApplicationUserSID
				,@OpenedDate                  = @OpenedDate
				,@ConductStartDate            = @ConductStartDate
				,@ConductEndDate              = @ConductEndDate
				,@ComplaintSeveritySID        = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry = @IsDisplayedOnPublicRegistry
				,@ClosedDate                  = @ClosedDate
				,@DismissedDate               = @DismissedDate
				,@ComplaintReasonSID          = @ComplaintReasonSID
				,@FileExtension               = @FileExtension
				,@ComplaintRowGUID            = @ComplaintRowGUID
				,@ReasonGroupSID              = @ReasonGroupSID
				,@ReasonName                  = @ReasonName
				,@ReasonCode                  = @ReasonCode
				,@ReasonSequence              = @ReasonSequence
				,@ToolTip                     = @ToolTip
				,@ReasonIsActive              = @ReasonIsActive
				,@ReasonRowGUID               = @ReasonRowGUID
				,@IsDeleteEnabled             = @IsDeleteEnabled
				,@InvoiceLabel                = @InvoiceLabel
				,@InvoiceShortLabel           = @InvoiceShortLabel
				,@TotalBeforeTax              = @TotalBeforeTax
				,@Tax1Total                   = @Tax1Total
				,@Tax2Total                   = @Tax2Total
				,@Tax3Total                   = @Tax3Total
				,@TotalAdjustment             = @TotalAdjustment
				,@TotalAfterTax               = @TotalAfterTax
				,@TotalPaid                   = @TotalPaid
				,@TotalDue                    = @TotalDue
				,@IsUnPaid                    = @IsUnPaid
				,@IsPaid                      = @IsPaid
				,@IsOverPaid                  = @IsOverPaid
				,@IsOverDue                   = @IsOverDue
				,@Tax1GLAccountLabel          = @Tax1GLAccountLabel
				,@Tax1IsTaxAccount            = @Tax1IsTaxAccount
				,@Tax2GLAccountLabel          = @Tax2GLAccountLabel
				,@Tax2IsTaxAccount            = @Tax2IsTaxAccount
				,@Tax3GLAccountLabel          = @Tax3GLAccountLabel
				,@Tax3IsTaxAccount            = @Tax3IsTaxAccount
				,@IsDeferred                  = @IsDeferred
				,@IsCancelled                 = @IsCancelled
				,@IsEditEnabled               = @IsEditEnabled
				,@IsPAPSubscriber             = @IsPAPSubscriber
				,@IsPAPEnabled                = @IsPAPEnabled
				,@AddressBlockForPrint        = @AddressBlockForPrint
				,@AddressBlockForHTML         = @AddressBlockForHTML
		
		end

		-- insert the record

		insert
			dbo.Invoice
		(
			 PersonSID
			,InvoiceDate
			,Tax1Label
			,Tax1Rate
			,Tax1GLAccountCode
			,Tax2Label
			,Tax2Rate
			,Tax2GLAccountCode
			,Tax3Label
			,Tax3Rate
			,Tax3GLAccountCode
			,RegistrationYear
			,CancelledTime
			,ReasonSID
			,IsRefund
			,ComplaintSID
			,UserDefinedColumns
			,InvoiceXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@InvoiceDate
			,@Tax1Label
			,@Tax1Rate
			,@Tax1GLAccountCode
			,@Tax2Label
			,@Tax2Rate
			,@Tax2GLAccountCode
			,@Tax3Label
			,@Tax3Rate
			,@Tax3GLAccountCode
			,@RegistrationYear
			,@CancelledTime
			,@ReasonSID
			,@IsRefund
			,@ComplaintSID
			,@UserDefinedColumns
			,@InvoiceXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@InvoiceSID = scope_identity()																			-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.Invoice'
				,@Arg3        = @rowsAffected
				,@Arg4        = @InvoiceSID
			
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
				r.RoutineName = 'pInvoice'
		)
		begin
		
			exec @errorNo = ext.pInvoice
				 @Mode                        = 'insert.post'
				,@InvoiceSID                  = @InvoiceSID
				,@PersonSID                   = @PersonSID
				,@InvoiceDate                 = @InvoiceDate
				,@Tax1Label                   = @Tax1Label
				,@Tax1Rate                    = @Tax1Rate
				,@Tax1GLAccountCode           = @Tax1GLAccountCode
				,@Tax2Label                   = @Tax2Label
				,@Tax2Rate                    = @Tax2Rate
				,@Tax2GLAccountCode           = @Tax2GLAccountCode
				,@Tax3Label                   = @Tax3Label
				,@Tax3Rate                    = @Tax3Rate
				,@Tax3GLAccountCode           = @Tax3GLAccountCode
				,@RegistrationYear            = @RegistrationYear
				,@CancelledTime               = @CancelledTime
				,@ReasonSID                   = @ReasonSID
				,@IsRefund                    = @IsRefund
				,@ComplaintSID                = @ComplaintSID
				,@UserDefinedColumns          = @UserDefinedColumns
				,@InvoiceXID                  = @InvoiceXID
				,@LegacyKey                   = @LegacyKey
				,@CreateUser                  = @CreateUser
				,@IsReselected                = @IsReselected
				,@zContext                    = @zContext
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
				,@ComplaintNo                 = @ComplaintNo
				,@RegistrantSID               = @RegistrantSID
				,@ComplaintTypeSID            = @ComplaintTypeSID
				,@ComplainantTypeSID          = @ComplainantTypeSID
				,@ApplicationUserSID          = @ApplicationUserSID
				,@OpenedDate                  = @OpenedDate
				,@ConductStartDate            = @ConductStartDate
				,@ConductEndDate              = @ConductEndDate
				,@ComplaintSeveritySID        = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry = @IsDisplayedOnPublicRegistry
				,@ClosedDate                  = @ClosedDate
				,@DismissedDate               = @DismissedDate
				,@ComplaintReasonSID          = @ComplaintReasonSID
				,@FileExtension               = @FileExtension
				,@ComplaintRowGUID            = @ComplaintRowGUID
				,@ReasonGroupSID              = @ReasonGroupSID
				,@ReasonName                  = @ReasonName
				,@ReasonCode                  = @ReasonCode
				,@ReasonSequence              = @ReasonSequence
				,@ToolTip                     = @ToolTip
				,@ReasonIsActive              = @ReasonIsActive
				,@ReasonRowGUID               = @ReasonRowGUID
				,@IsDeleteEnabled             = @IsDeleteEnabled
				,@InvoiceLabel                = @InvoiceLabel
				,@InvoiceShortLabel           = @InvoiceShortLabel
				,@TotalBeforeTax              = @TotalBeforeTax
				,@Tax1Total                   = @Tax1Total
				,@Tax2Total                   = @Tax2Total
				,@Tax3Total                   = @Tax3Total
				,@TotalAdjustment             = @TotalAdjustment
				,@TotalAfterTax               = @TotalAfterTax
				,@TotalPaid                   = @TotalPaid
				,@TotalDue                    = @TotalDue
				,@IsUnPaid                    = @IsUnPaid
				,@IsPaid                      = @IsPaid
				,@IsOverPaid                  = @IsOverPaid
				,@IsOverDue                   = @IsOverDue
				,@Tax1GLAccountLabel          = @Tax1GLAccountLabel
				,@Tax1IsTaxAccount            = @Tax1IsTaxAccount
				,@Tax2GLAccountLabel          = @Tax2GLAccountLabel
				,@Tax2IsTaxAccount            = @Tax2IsTaxAccount
				,@Tax3GLAccountLabel          = @Tax3GLAccountLabel
				,@Tax3IsTaxAccount            = @Tax3IsTaxAccount
				,@IsDeferred                  = @IsDeferred
				,@IsCancelled                 = @IsCancelled
				,@IsEditEnabled               = @IsEditEnabled
				,@IsPAPSubscriber             = @IsPAPSubscriber
				,@IsPAPEnabled                = @IsPAPEnabled
				,@AddressBlockForPrint        = @AddressBlockForPrint
				,@AddressBlockForHTML         = @AddressBlockForHTML
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.InvoiceSID
			from
				dbo.vInvoice ent
			where
				ent.InvoiceSID = @InvoiceSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.InvoiceSID
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
				,ent.ReasonSID
				,ent.IsRefund
				,ent.ComplaintSID
				,ent.UserDefinedColumns
				,ent.InvoiceXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
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
				,ent.ComplaintNo
				,ent.RegistrantSID
				,ent.ComplaintTypeSID
				,ent.ComplainantTypeSID
				,ent.ApplicationUserSID
				,ent.OpenedDate
				,ent.ConductStartDate
				,ent.ConductEndDate
				,ent.ComplaintSeveritySID
				,ent.IsDisplayedOnPublicRegistry
				,ent.ClosedDate
				,ent.DismissedDate
				,ent.ComplaintReasonSID
				,ent.FileExtension
				,ent.ComplaintRowGUID
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
				,ent.InvoiceLabel
				,ent.InvoiceShortLabel
				,ent.TotalBeforeTax
				,ent.Tax1Total
				,ent.Tax2Total
				,ent.Tax3Total
				,ent.TotalAdjustment
				,ent.TotalAfterTax
				,ent.TotalPaid
				,ent.TotalDue
				,ent.IsUnPaid
				,ent.IsPaid
				,ent.IsOverPaid
				,ent.IsOverDue
				,ent.Tax1GLAccountLabel
				,ent.Tax1IsTaxAccount
				,ent.Tax2GLAccountLabel
				,ent.Tax2IsTaxAccount
				,ent.Tax3GLAccountLabel
				,ent.Tax3IsTaxAccount
				,ent.IsDeferred
				,ent.IsCancelled
				,ent.IsEditEnabled
				,ent.IsPAPSubscriber
				,ent.IsPAPEnabled
				,ent.AddressBlockForPrint
				,ent.AddressBlockForHTML
			from
				dbo.vInvoice ent
			where
				ent.InvoiceSID = @InvoiceSID

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
