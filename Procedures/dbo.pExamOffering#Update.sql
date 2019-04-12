SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pExamOffering#Update]
	 @ExamOfferingSID                int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ExamSID                        int               = null -- table column values to update:
	,@OrgSID                         int               = null
	,@ExamTime                       datetime          = null
	,@SeatingCapacity                int               = null
	,@CatalogItemSID                 int               = null
	,@BookingCutOffDate              date              = null
	,@VendorExamOfferingID           varchar(25)       = null
	,@UserDefinedColumns             xml               = null
	,@ExamOfferingXID                varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@ExamName                       nvarchar(50)      = null -- not a base table column
	,@ExamCategory                   nvarchar(65)      = null -- not a base table column
	,@PassingScore                   int               = null -- not a base table column
	,@ExamEffectiveTime              datetime          = null -- not a base table column
	,@ExamExpiryTime                 datetime          = null -- not a base table column
	,@IsOnlineExam                   bit               = null -- not a base table column
	,@IsEnabledOnPortal              bit               = null -- not a base table column
	,@Sequence                       int               = null -- not a base table column
	,@CultureSID                     int               = null -- not a base table column
	,@ExamLastVerifiedTime           datetimeoffset(7) = null -- not a base table column
	,@MinLagDaysBetweenAttempts      smallint          = null -- not a base table column
	,@MaxAttemptsPerYear             tinyint           = null -- not a base table column
	,@VendorExamID                   varchar(25)       = null -- not a base table column
	,@ExamRowGUID                    uniqueidentifier  = null -- not a base table column
	,@ParentOrgSID                   int               = null -- not a base table column
	,@OrgTypeSID                     int               = null -- not a base table column
	,@OrgName                        nvarchar(150)     = null -- not a base table column
	,@OrgLabel                       nvarchar(35)      = null -- not a base table column
	,@StreetAddress1                 nvarchar(75)      = null -- not a base table column
	,@StreetAddress2                 nvarchar(75)      = null -- not a base table column
	,@StreetAddress3                 nvarchar(75)      = null -- not a base table column
	,@CitySID                        int               = null -- not a base table column
	,@PostalCode                     varchar(10)       = null -- not a base table column
	,@RegionSID                      int               = null -- not a base table column
	,@Phone                          varchar(25)       = null -- not a base table column
	,@Fax                            varchar(25)       = null -- not a base table column
	,@WebSite                        varchar(250)      = null -- not a base table column
	,@EmailAddress                   varchar(150)      = null -- not a base table column
	,@InsuranceOrgSID                int               = null -- not a base table column
	,@InsurancePolicyNo              varchar(25)       = null -- not a base table column
	,@InsuranceAmount                decimal(11,2)     = null -- not a base table column
	,@IsEmployer                     bit               = null -- not a base table column
	,@IsCredentialAuthority          bit               = null -- not a base table column
	,@IsInsurer                      bit               = null -- not a base table column
	,@IsInsuranceCertificateRequired bit               = null -- not a base table column
	,@IsPublic                       nchar(10)         = null -- not a base table column
	,@OrgIsActive                    bit               = null -- not a base table column
	,@IsAdminReviewRequired          bit               = null -- not a base table column
	,@OrgLastVerifiedTime            datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                     uniqueidentifier  = null -- not a base table column
	,@CatalogItemLabel               nvarchar(35)      = null -- not a base table column
	,@InvoiceItemDescription         nvarchar(500)     = null -- not a base table column
	,@IsLateFee                      bit               = null -- not a base table column
	,@ImageAlternateText             nvarchar(50)      = null -- not a base table column
	,@IsAvailableOnClientPortal      bit               = null -- not a base table column
	,@IsComplaintPenalty             bit               = null -- not a base table column
	,@GLAccountSID                   int               = null -- not a base table column
	,@IsTaxRate1Applied              bit               = null -- not a base table column
	,@IsTaxRate2Applied              bit               = null -- not a base table column
	,@IsTaxRate3Applied              bit               = null -- not a base table column
	,@IsTaxDeductible                bit               = null -- not a base table column
	,@CatalogItemEffectiveTime       datetime          = null -- not a base table column
	,@CatalogItemExpiryTime          datetime          = null -- not a base table column
	,@FileTypeSCD                    varchar(8)        = null -- not a base table column
	,@FileTypeSID                    int               = null -- not a base table column
	,@CatalogItemRowGUID             uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsDetailedOffering             bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pExamOffering#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.ExamOffering table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.ExamOffering table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vExamOffering entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pExamOffering procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fExamOfferingCheck to test all rules.

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

		if @ExamOfferingSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ExamOfferingSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @VendorExamOfferingID = ltrim(rtrim(@VendorExamOfferingID))
		set @ExamOfferingXID = ltrim(rtrim(@ExamOfferingXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ExamName = ltrim(rtrim(@ExamName))
		set @ExamCategory = ltrim(rtrim(@ExamCategory))
		set @VendorExamID = ltrim(rtrim(@VendorExamID))
		set @OrgName = ltrim(rtrim(@OrgName))
		set @OrgLabel = ltrim(rtrim(@OrgLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @Phone = ltrim(rtrim(@Phone))
		set @Fax = ltrim(rtrim(@Fax))
		set @WebSite = ltrim(rtrim(@WebSite))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))
		set @CatalogItemLabel = ltrim(rtrim(@CatalogItemLabel))
		set @InvoiceItemDescription = ltrim(rtrim(@InvoiceItemDescription))
		set @ImageAlternateText = ltrim(rtrim(@ImageAlternateText))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@VendorExamOfferingID) = 0 set @VendorExamOfferingID = null
		if len(@ExamOfferingXID) = 0 set @ExamOfferingXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ExamName) = 0 set @ExamName = null
		if len(@ExamCategory) = 0 set @ExamCategory = null
		if len(@VendorExamID) = 0 set @VendorExamID = null
		if len(@OrgName) = 0 set @OrgName = null
		if len(@OrgLabel) = 0 set @OrgLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@Phone) = 0 set @Phone = null
		if len(@Fax) = 0 set @Fax = null
		if len(@WebSite) = 0 set @WebSite = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null
		if len(@CatalogItemLabel) = 0 set @CatalogItemLabel = null
		if len(@InvoiceItemDescription) = 0 set @InvoiceItemDescription = null
		if len(@ImageAlternateText) = 0 set @ImageAlternateText = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ExamSID                        = isnull(@ExamSID,eo.ExamSID)
				,@OrgSID                         = isnull(@OrgSID,eo.OrgSID)
				,@ExamTime                       = isnull(@ExamTime,eo.ExamTime)
				,@SeatingCapacity                = isnull(@SeatingCapacity,eo.SeatingCapacity)
				,@CatalogItemSID                 = isnull(@CatalogItemSID,eo.CatalogItemSID)
				,@BookingCutOffDate              = isnull(@BookingCutOffDate,eo.BookingCutOffDate)
				,@VendorExamOfferingID           = isnull(@VendorExamOfferingID,eo.VendorExamOfferingID)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,eo.UserDefinedColumns)
				,@ExamOfferingXID                = isnull(@ExamOfferingXID,eo.ExamOfferingXID)
				,@LegacyKey                      = isnull(@LegacyKey,eo.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,eo.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,eo.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,eo.IsNullApplied)
				,@zContext                       = isnull(@zContext,eo.zContext)
				,@ExamName                       = isnull(@ExamName,eo.ExamName)
				,@ExamCategory                   = isnull(@ExamCategory,eo.ExamCategory)
				,@PassingScore                   = isnull(@PassingScore,eo.PassingScore)
				,@ExamEffectiveTime              = isnull(@ExamEffectiveTime,eo.ExamEffectiveTime)
				,@ExamExpiryTime                 = isnull(@ExamExpiryTime,eo.ExamExpiryTime)
				,@IsOnlineExam                   = isnull(@IsOnlineExam,eo.IsOnlineExam)
				,@IsEnabledOnPortal              = isnull(@IsEnabledOnPortal,eo.IsEnabledOnPortal)
				,@Sequence                       = isnull(@Sequence,eo.Sequence)
				,@CultureSID                     = isnull(@CultureSID,eo.CultureSID)
				,@ExamLastVerifiedTime           = isnull(@ExamLastVerifiedTime,eo.ExamLastVerifiedTime)
				,@MinLagDaysBetweenAttempts      = isnull(@MinLagDaysBetweenAttempts,eo.MinLagDaysBetweenAttempts)
				,@MaxAttemptsPerYear             = isnull(@MaxAttemptsPerYear,eo.MaxAttemptsPerYear)
				,@VendorExamID                   = isnull(@VendorExamID,eo.VendorExamID)
				,@ExamRowGUID                    = isnull(@ExamRowGUID,eo.ExamRowGUID)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,eo.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,eo.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,eo.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,eo.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,eo.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,eo.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,eo.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,eo.CitySID)
				,@PostalCode                     = isnull(@PostalCode,eo.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,eo.RegionSID)
				,@Phone                          = isnull(@Phone,eo.Phone)
				,@Fax                            = isnull(@Fax,eo.Fax)
				,@WebSite                        = isnull(@WebSite,eo.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,eo.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,eo.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,eo.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,eo.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,eo.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,eo.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,eo.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,eo.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,eo.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,eo.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,eo.IsAdminReviewRequired)
				,@OrgLastVerifiedTime            = isnull(@OrgLastVerifiedTime,eo.OrgLastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,eo.OrgRowGUID)
				,@CatalogItemLabel               = isnull(@CatalogItemLabel,eo.CatalogItemLabel)
				,@InvoiceItemDescription         = isnull(@InvoiceItemDescription,eo.InvoiceItemDescription)
				,@IsLateFee                      = isnull(@IsLateFee,eo.IsLateFee)
				,@ImageAlternateText             = isnull(@ImageAlternateText,eo.ImageAlternateText)
				,@IsAvailableOnClientPortal      = isnull(@IsAvailableOnClientPortal,eo.IsAvailableOnClientPortal)
				,@IsComplaintPenalty             = isnull(@IsComplaintPenalty,eo.IsComplaintPenalty)
				,@GLAccountSID                   = isnull(@GLAccountSID,eo.GLAccountSID)
				,@IsTaxRate1Applied              = isnull(@IsTaxRate1Applied,eo.IsTaxRate1Applied)
				,@IsTaxRate2Applied              = isnull(@IsTaxRate2Applied,eo.IsTaxRate2Applied)
				,@IsTaxRate3Applied              = isnull(@IsTaxRate3Applied,eo.IsTaxRate3Applied)
				,@IsTaxDeductible                = isnull(@IsTaxDeductible,eo.IsTaxDeductible)
				,@CatalogItemEffectiveTime       = isnull(@CatalogItemEffectiveTime,eo.CatalogItemEffectiveTime)
				,@CatalogItemExpiryTime          = isnull(@CatalogItemExpiryTime,eo.CatalogItemExpiryTime)
				,@FileTypeSCD                    = isnull(@FileTypeSCD,eo.FileTypeSCD)
				,@FileTypeSID                    = isnull(@FileTypeSID,eo.FileTypeSID)
				,@CatalogItemRowGUID             = isnull(@CatalogItemRowGUID,eo.CatalogItemRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,eo.IsDeleteEnabled)
				,@IsDetailedOffering             = isnull(@IsDetailedOffering,eo.IsDetailedOffering)
			from
				dbo.vExamOffering eo
			where
				eo.ExamOfferingSID = @ExamOfferingSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.OrgSID from dbo.ExamOffering x where x.ExamOfferingSID = @ExamOfferingSID) <> @OrgSID
		begin
			if (select x.IsActive from dbo.Org x where x.OrgSID = @OrgSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'org'
				
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
				r.RoutineName = 'pExamOffering'
		)
		begin
		
			exec @errorNo = ext.pExamOffering
				 @Mode                           = 'update.pre'
				,@ExamOfferingSID                = @ExamOfferingSID
				,@ExamSID                        = @ExamSID output
				,@OrgSID                         = @OrgSID output
				,@ExamTime                       = @ExamTime output
				,@SeatingCapacity                = @SeatingCapacity output
				,@CatalogItemSID                 = @CatalogItemSID output
				,@BookingCutOffDate              = @BookingCutOffDate output
				,@VendorExamOfferingID           = @VendorExamOfferingID output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@ExamOfferingXID                = @ExamOfferingXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@ExamName                       = @ExamName
				,@ExamCategory                   = @ExamCategory
				,@PassingScore                   = @PassingScore
				,@ExamEffectiveTime              = @ExamEffectiveTime
				,@ExamExpiryTime                 = @ExamExpiryTime
				,@IsOnlineExam                   = @IsOnlineExam
				,@IsEnabledOnPortal              = @IsEnabledOnPortal
				,@Sequence                       = @Sequence
				,@CultureSID                     = @CultureSID
				,@ExamLastVerifiedTime           = @ExamLastVerifiedTime
				,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
				,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
				,@VendorExamID                   = @VendorExamID
				,@ExamRowGUID                    = @ExamRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@PostalCode                     = @PostalCode
				,@RegionSID                      = @RegionSID
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@OrgIsActive                    = @OrgIsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@OrgLastVerifiedTime            = @OrgLastVerifiedTime
				,@OrgRowGUID                     = @OrgRowGUID
				,@CatalogItemLabel               = @CatalogItemLabel
				,@InvoiceItemDescription         = @InvoiceItemDescription
				,@IsLateFee                      = @IsLateFee
				,@ImageAlternateText             = @ImageAlternateText
				,@IsAvailableOnClientPortal      = @IsAvailableOnClientPortal
				,@IsComplaintPenalty             = @IsComplaintPenalty
				,@GLAccountSID                   = @GLAccountSID
				,@IsTaxRate1Applied              = @IsTaxRate1Applied
				,@IsTaxRate2Applied              = @IsTaxRate2Applied
				,@IsTaxRate3Applied              = @IsTaxRate3Applied
				,@IsTaxDeductible                = @IsTaxDeductible
				,@CatalogItemEffectiveTime       = @CatalogItemEffectiveTime
				,@CatalogItemExpiryTime          = @CatalogItemExpiryTime
				,@FileTypeSCD                    = @FileTypeSCD
				,@FileTypeSID                    = @FileTypeSID
				,@CatalogItemRowGUID             = @CatalogItemRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsDetailedOffering             = @IsDetailedOffering
		
		end

		-- update the record

		update
			dbo.ExamOffering
		set
			 ExamSID = @ExamSID
			,OrgSID = @OrgSID
			,ExamTime = @ExamTime
			,SeatingCapacity = @SeatingCapacity
			,CatalogItemSID = @CatalogItemSID
			,BookingCutOffDate = @BookingCutOffDate
			,VendorExamOfferingID = @VendorExamOfferingID
			,UserDefinedColumns = @UserDefinedColumns
			,ExamOfferingXID = @ExamOfferingXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ExamOfferingSID = @ExamOfferingSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.ExamOffering where ExamOfferingSID = @examOfferingSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.ExamOffering'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.ExamOffering'
					,@Arg2        = @examOfferingSID
				
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
				,@Arg2        = 'dbo.ExamOffering'
				,@Arg3        = @rowsAffected
				,@Arg4        = @examOfferingSID
			
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
				r.RoutineName = 'pExamOffering'
		)
		begin
		
			exec @errorNo = ext.pExamOffering
				 @Mode                           = 'update.post'
				,@ExamOfferingSID                = @ExamOfferingSID
				,@ExamSID                        = @ExamSID
				,@OrgSID                         = @OrgSID
				,@ExamTime                       = @ExamTime
				,@SeatingCapacity                = @SeatingCapacity
				,@CatalogItemSID                 = @CatalogItemSID
				,@BookingCutOffDate              = @BookingCutOffDate
				,@VendorExamOfferingID           = @VendorExamOfferingID
				,@UserDefinedColumns             = @UserDefinedColumns
				,@ExamOfferingXID                = @ExamOfferingXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@ExamName                       = @ExamName
				,@ExamCategory                   = @ExamCategory
				,@PassingScore                   = @PassingScore
				,@ExamEffectiveTime              = @ExamEffectiveTime
				,@ExamExpiryTime                 = @ExamExpiryTime
				,@IsOnlineExam                   = @IsOnlineExam
				,@IsEnabledOnPortal              = @IsEnabledOnPortal
				,@Sequence                       = @Sequence
				,@CultureSID                     = @CultureSID
				,@ExamLastVerifiedTime           = @ExamLastVerifiedTime
				,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
				,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
				,@VendorExamID                   = @VendorExamID
				,@ExamRowGUID                    = @ExamRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@PostalCode                     = @PostalCode
				,@RegionSID                      = @RegionSID
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@OrgIsActive                    = @OrgIsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@OrgLastVerifiedTime            = @OrgLastVerifiedTime
				,@OrgRowGUID                     = @OrgRowGUID
				,@CatalogItemLabel               = @CatalogItemLabel
				,@InvoiceItemDescription         = @InvoiceItemDescription
				,@IsLateFee                      = @IsLateFee
				,@ImageAlternateText             = @ImageAlternateText
				,@IsAvailableOnClientPortal      = @IsAvailableOnClientPortal
				,@IsComplaintPenalty             = @IsComplaintPenalty
				,@GLAccountSID                   = @GLAccountSID
				,@IsTaxRate1Applied              = @IsTaxRate1Applied
				,@IsTaxRate2Applied              = @IsTaxRate2Applied
				,@IsTaxRate3Applied              = @IsTaxRate3Applied
				,@IsTaxDeductible                = @IsTaxDeductible
				,@CatalogItemEffectiveTime       = @CatalogItemEffectiveTime
				,@CatalogItemExpiryTime          = @CatalogItemExpiryTime
				,@FileTypeSCD                    = @FileTypeSCD
				,@FileTypeSID                    = @FileTypeSID
				,@CatalogItemRowGUID             = @CatalogItemRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsDetailedOffering             = @IsDetailedOffering
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ExamOfferingSID
			from
				dbo.vExamOffering ent
			where
				ent.ExamOfferingSID = @ExamOfferingSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ExamOfferingSID
				,ent.ExamSID
				,ent.OrgSID
				,ent.ExamTime
				,ent.SeatingCapacity
				,ent.CatalogItemSID
				,ent.BookingCutOffDate
				,ent.VendorExamOfferingID
				,ent.UserDefinedColumns
				,ent.ExamOfferingXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ExamName
				,ent.ExamCategory
				,ent.PassingScore
				,ent.ExamEffectiveTime
				,ent.ExamExpiryTime
				,ent.IsOnlineExam
				,ent.IsEnabledOnPortal
				,ent.Sequence
				,ent.CultureSID
				,ent.ExamLastVerifiedTime
				,ent.MinLagDaysBetweenAttempts
				,ent.MaxAttemptsPerYear
				,ent.VendorExamID
				,ent.ExamRowGUID
				,ent.ParentOrgSID
				,ent.OrgTypeSID
				,ent.OrgName
				,ent.OrgLabel
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.Phone
				,ent.Fax
				,ent.WebSite
				,ent.EmailAddress
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.OrgIsActive
				,ent.IsAdminReviewRequired
				,ent.OrgLastVerifiedTime
				,ent.OrgRowGUID
				,ent.CatalogItemLabel
				,ent.InvoiceItemDescription
				,ent.IsLateFee
				,ent.ImageAlternateText
				,ent.IsAvailableOnClientPortal
				,ent.IsComplaintPenalty
				,ent.GLAccountSID
				,ent.IsTaxRate1Applied
				,ent.IsTaxRate2Applied
				,ent.IsTaxRate3Applied
				,ent.IsTaxDeductible
				,ent.CatalogItemEffectiveTime
				,ent.CatalogItemExpiryTime
				,ent.FileTypeSCD
				,ent.FileTypeSID
				,ent.CatalogItemRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsDetailedOffering
			from
				dbo.vExamOffering ent
			where
				ent.ExamOfferingSID = @ExamOfferingSID

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
