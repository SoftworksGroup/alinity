SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoice#Update]
	 @InvoiceSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                   int               = null -- table column values to update:
	,@InvoiceDate                 date              = null
	,@Tax1Label                   nvarchar(8)       = null
	,@Tax1Rate                    decimal(4,4)      = null
	,@Tax1GLAccountCode           varchar(50)       = null
	,@Tax2Label                   nvarchar(8)       = null
	,@Tax2Rate                    decimal(4,4)      = null
	,@Tax2GLAccountCode           varchar(50)       = null
	,@Tax3Label                   nvarchar(8)       = null
	,@Tax3Rate                    decimal(4,4)      = null
	,@Tax3GLAccountCode           varchar(50)       = null
	,@RegistrationYear            smallint          = null
	,@CancelledTime               datetimeoffset(7) = null
	,@ReasonSID                   int               = null
	,@IsRefund                    bit               = null
	,@ComplaintSID                int               = null
	,@UserDefinedColumns          xml               = null
	,@InvoiceXID                  varchar(150)      = null
	,@LegacyKey                   nvarchar(50)      = null
	,@UpdateUser                  nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                    timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied               bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                    xml               = null -- other values defining context for the update (if any)
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
	,@ComplaintNo                 varchar(50)       = null -- not a base table column
	,@RegistrantSID               int               = null -- not a base table column
	,@ComplaintTypeSID            int               = null -- not a base table column
	,@ComplainantTypeSID          int               = null -- not a base table column
	,@ApplicationUserSID          int               = null -- not a base table column
	,@OpenedDate                  date              = null -- not a base table column
	,@ConductStartDate            date              = null -- not a base table column
	,@ConductEndDate              date              = null -- not a base table column
	,@ComplaintSeveritySID        int               = null -- not a base table column
	,@IsDisplayedOnPublicRegistry bit               = null -- not a base table column
	,@ClosedDate                  date              = null -- not a base table column
	,@DismissedDate               date              = null -- not a base table column
	,@ComplaintReasonSID          int               = null -- not a base table column
	,@FileExtension               varchar(5)        = null -- not a base table column
	,@ComplaintRowGUID            uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID              int               = null -- not a base table column
	,@ReasonName                  nvarchar(50)      = null -- not a base table column
	,@ReasonCode                  varchar(25)       = null -- not a base table column
	,@ReasonSequence              smallint          = null -- not a base table column
	,@ToolTip                     nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive              bit               = null -- not a base table column
	,@ReasonRowGUID               uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled             bit               = null -- not a base table column
	,@InvoiceLabel                nvarchar(4000)    = null -- not a base table column
	,@InvoiceShortLabel           nvarchar(4000)    = null -- not a base table column
	,@TotalBeforeTax              decimal(11,2)     = null -- not a base table column
	,@Tax1Total                   decimal(11,2)     = null -- not a base table column
	,@Tax2Total                   decimal(11,2)     = null -- not a base table column
	,@Tax3Total                   decimal(11,2)     = null -- not a base table column
	,@TotalAdjustment             decimal(11,2)     = null -- not a base table column
	,@TotalAfterTax               decimal(11,2)     = null -- not a base table column
	,@TotalPaid                   decimal(11,2)     = null -- not a base table column
	,@TotalDue                    decimal(11,2)     = null -- not a base table column
	,@IsUnPaid                    bit               = null -- not a base table column
	,@IsPaid                      bit               = null -- not a base table column
	,@IsOverPaid                  bit               = null -- not a base table column
	,@IsOverDue                   bit               = null -- not a base table column
	,@Tax1GLAccountLabel          nvarchar(35)      = null -- not a base table column
	,@Tax1IsTaxAccount            bit               = null -- not a base table column
	,@Tax2GLAccountLabel          nvarchar(35)      = null -- not a base table column
	,@Tax2IsTaxAccount            bit               = null -- not a base table column
	,@Tax3GLAccountLabel          nvarchar(35)      = null -- not a base table column
	,@Tax3IsTaxAccount            bit               = null -- not a base table column
	,@IsDeferred                  bit               = null -- not a base table column
	,@IsCancelled                 bit               = null -- not a base table column
	,@IsEditEnabled               bit               = null -- not a base table column
	,@IsPAPSubscriber             bit               = null -- not a base table column
	,@IsPAPEnabled                bit               = null -- not a base table column
	,@AddressBlockForPrint        nvarchar(512)     = null -- not a base table column
	,@AddressBlockForHTML         nvarchar(512)     = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoice#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Invoice table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Invoice table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vInvoice entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pInvoice procedure. The extended procedure is only called
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

		if @InvoiceSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@InvoiceSID'

			raiserror(@errorText, 18, 1)
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
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                   = isnull(@PersonSID,i.PersonSID)
				,@InvoiceDate                 = isnull(@InvoiceDate,i.InvoiceDate)
				,@Tax1Label                   = isnull(@Tax1Label,i.Tax1Label)
				,@Tax1Rate                    = isnull(@Tax1Rate,i.Tax1Rate)
				,@Tax1GLAccountCode           = isnull(@Tax1GLAccountCode,i.Tax1GLAccountCode)
				,@Tax2Label                   = isnull(@Tax2Label,i.Tax2Label)
				,@Tax2Rate                    = isnull(@Tax2Rate,i.Tax2Rate)
				,@Tax2GLAccountCode           = isnull(@Tax2GLAccountCode,i.Tax2GLAccountCode)
				,@Tax3Label                   = isnull(@Tax3Label,i.Tax3Label)
				,@Tax3Rate                    = isnull(@Tax3Rate,i.Tax3Rate)
				,@Tax3GLAccountCode           = isnull(@Tax3GLAccountCode,i.Tax3GLAccountCode)
				,@RegistrationYear            = isnull(@RegistrationYear,i.RegistrationYear)
				,@CancelledTime               = isnull(@CancelledTime,i.CancelledTime)
				,@ReasonSID                   = isnull(@ReasonSID,i.ReasonSID)
				,@IsRefund                    = isnull(@IsRefund,i.IsRefund)
				,@ComplaintSID                = isnull(@ComplaintSID,i.ComplaintSID)
				,@UserDefinedColumns          = isnull(@UserDefinedColumns,i.UserDefinedColumns)
				,@InvoiceXID                  = isnull(@InvoiceXID,i.InvoiceXID)
				,@LegacyKey                   = isnull(@LegacyKey,i.LegacyKey)
				,@UpdateUser                  = isnull(@UpdateUser,i.UpdateUser)
				,@IsReselected                = isnull(@IsReselected,i.IsReselected)
				,@IsNullApplied               = isnull(@IsNullApplied,i.IsNullApplied)
				,@zContext                    = isnull(@zContext,i.zContext)
				,@GenderSID                   = isnull(@GenderSID,i.GenderSID)
				,@NamePrefixSID               = isnull(@NamePrefixSID,i.NamePrefixSID)
				,@FirstName                   = isnull(@FirstName,i.FirstName)
				,@CommonName                  = isnull(@CommonName,i.CommonName)
				,@MiddleNames                 = isnull(@MiddleNames,i.MiddleNames)
				,@LastName                    = isnull(@LastName,i.LastName)
				,@BirthDate                   = isnull(@BirthDate,i.BirthDate)
				,@DeathDate                   = isnull(@DeathDate,i.DeathDate)
				,@HomePhone                   = isnull(@HomePhone,i.HomePhone)
				,@MobilePhone                 = isnull(@MobilePhone,i.MobilePhone)
				,@IsTextMessagingEnabled      = isnull(@IsTextMessagingEnabled,i.IsTextMessagingEnabled)
				,@ImportBatch                 = isnull(@ImportBatch,i.ImportBatch)
				,@PersonRowGUID               = isnull(@PersonRowGUID,i.PersonRowGUID)
				,@ComplaintNo                 = isnull(@ComplaintNo,i.ComplaintNo)
				,@RegistrantSID               = isnull(@RegistrantSID,i.RegistrantSID)
				,@ComplaintTypeSID            = isnull(@ComplaintTypeSID,i.ComplaintTypeSID)
				,@ComplainantTypeSID          = isnull(@ComplainantTypeSID,i.ComplainantTypeSID)
				,@ApplicationUserSID          = isnull(@ApplicationUserSID,i.ApplicationUserSID)
				,@OpenedDate                  = isnull(@OpenedDate,i.OpenedDate)
				,@ConductStartDate            = isnull(@ConductStartDate,i.ConductStartDate)
				,@ConductEndDate              = isnull(@ConductEndDate,i.ConductEndDate)
				,@ComplaintSeveritySID        = isnull(@ComplaintSeveritySID,i.ComplaintSeveritySID)
				,@IsDisplayedOnPublicRegistry = isnull(@IsDisplayedOnPublicRegistry,i.IsDisplayedOnPublicRegistry)
				,@ClosedDate                  = isnull(@ClosedDate,i.ClosedDate)
				,@DismissedDate               = isnull(@DismissedDate,i.DismissedDate)
				,@ComplaintReasonSID          = isnull(@ComplaintReasonSID,i.ComplaintReasonSID)
				,@FileExtension               = isnull(@FileExtension,i.FileExtension)
				,@ComplaintRowGUID            = isnull(@ComplaintRowGUID,i.ComplaintRowGUID)
				,@ReasonGroupSID              = isnull(@ReasonGroupSID,i.ReasonGroupSID)
				,@ReasonName                  = isnull(@ReasonName,i.ReasonName)
				,@ReasonCode                  = isnull(@ReasonCode,i.ReasonCode)
				,@ReasonSequence              = isnull(@ReasonSequence,i.ReasonSequence)
				,@ToolTip                     = isnull(@ToolTip,i.ToolTip)
				,@ReasonIsActive              = isnull(@ReasonIsActive,i.ReasonIsActive)
				,@ReasonRowGUID               = isnull(@ReasonRowGUID,i.ReasonRowGUID)
				,@IsDeleteEnabled             = isnull(@IsDeleteEnabled,i.IsDeleteEnabled)
				,@InvoiceLabel                = isnull(@InvoiceLabel,i.InvoiceLabel)
				,@InvoiceShortLabel           = isnull(@InvoiceShortLabel,i.InvoiceShortLabel)
				,@TotalBeforeTax              = isnull(@TotalBeforeTax,i.TotalBeforeTax)
				,@Tax1Total                   = isnull(@Tax1Total,i.Tax1Total)
				,@Tax2Total                   = isnull(@Tax2Total,i.Tax2Total)
				,@Tax3Total                   = isnull(@Tax3Total,i.Tax3Total)
				,@TotalAdjustment             = isnull(@TotalAdjustment,i.TotalAdjustment)
				,@TotalAfterTax               = isnull(@TotalAfterTax,i.TotalAfterTax)
				,@TotalPaid                   = isnull(@TotalPaid,i.TotalPaid)
				,@TotalDue                    = isnull(@TotalDue,i.TotalDue)
				,@IsUnPaid                    = isnull(@IsUnPaid,i.IsUnPaid)
				,@IsPaid                      = isnull(@IsPaid,i.IsPaid)
				,@IsOverPaid                  = isnull(@IsOverPaid,i.IsOverPaid)
				,@IsOverDue                   = isnull(@IsOverDue,i.IsOverDue)
				,@Tax1GLAccountLabel          = isnull(@Tax1GLAccountLabel,i.Tax1GLAccountLabel)
				,@Tax1IsTaxAccount            = isnull(@Tax1IsTaxAccount,i.Tax1IsTaxAccount)
				,@Tax2GLAccountLabel          = isnull(@Tax2GLAccountLabel,i.Tax2GLAccountLabel)
				,@Tax2IsTaxAccount            = isnull(@Tax2IsTaxAccount,i.Tax2IsTaxAccount)
				,@Tax3GLAccountLabel          = isnull(@Tax3GLAccountLabel,i.Tax3GLAccountLabel)
				,@Tax3IsTaxAccount            = isnull(@Tax3IsTaxAccount,i.Tax3IsTaxAccount)
				,@IsDeferred                  = isnull(@IsDeferred,i.IsDeferred)
				,@IsCancelled                 = isnull(@IsCancelled,i.IsCancelled)
				,@IsEditEnabled               = isnull(@IsEditEnabled,i.IsEditEnabled)
				,@IsPAPSubscriber             = isnull(@IsPAPSubscriber,i.IsPAPSubscriber)
				,@IsPAPEnabled                = isnull(@IsPAPEnabled,i.IsPAPEnabled)
				,@AddressBlockForPrint        = isnull(@AddressBlockForPrint,i.AddressBlockForPrint)
				,@AddressBlockForHTML         = isnull(@AddressBlockForHTML,i.AddressBlockForHTML)
			from
				dbo.vInvoice i
			where
				i.InvoiceSID = @InvoiceSID

		end
		
		if @IsCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()				-- set column when null and extended view bit is passed to set it

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ReasonSID from dbo.Invoice x where x.InvoiceSID = @InvoiceSID) <> @ReasonSID
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
				r.RoutineName = 'pInvoice'
		)
		begin
		
			exec @errorNo = ext.pInvoice
				 @Mode                        = 'update.pre'
				,@InvoiceSID                  = @InvoiceSID
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
				,@UpdateUser                  = @UpdateUser
				,@RowStamp                    = @RowStamp
				,@IsReselected                = @IsReselected
				,@IsNullApplied               = @IsNullApplied
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

		-- update the record

		update
			dbo.Invoice
		set
			 PersonSID = @PersonSID
			,InvoiceDate = @InvoiceDate
			,Tax1Label = @Tax1Label
			,Tax1Rate = @Tax1Rate
			,Tax1GLAccountCode = @Tax1GLAccountCode
			,Tax2Label = @Tax2Label
			,Tax2Rate = @Tax2Rate
			,Tax2GLAccountCode = @Tax2GLAccountCode
			,Tax3Label = @Tax3Label
			,Tax3Rate = @Tax3Rate
			,Tax3GLAccountCode = @Tax3GLAccountCode
			,RegistrationYear = @RegistrationYear
			,CancelledTime = @CancelledTime
			,ReasonSID = @ReasonSID
			,IsRefund = @IsRefund
			,ComplaintSID = @ComplaintSID
			,UserDefinedColumns = @UserDefinedColumns
			,InvoiceXID = @InvoiceXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			InvoiceSID = @InvoiceSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Invoice where InvoiceSID = @invoiceSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Invoice'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Invoice'
					,@Arg2        = @invoiceSID
				
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
				,@Arg2        = 'dbo.Invoice'
				,@Arg3        = @rowsAffected
				,@Arg4        = @invoiceSID
			
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
				r.RoutineName = 'pInvoice'
		)
		begin
		
			exec @errorNo = ext.pInvoice
				 @Mode                        = 'update.post'
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
				,@UpdateUser                  = @UpdateUser
				,@RowStamp                    = @RowStamp
				,@IsReselected                = @IsReselected
				,@IsNullApplied               = @IsNullApplied
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
