SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantExam#Update]
	 @RegistrantExamSID              int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                  int               = null -- table column values to update:
	,@ExamSID                        int               = null
	,@ExamDate                       date              = null
	,@ExamResultDate                 date              = null
	,@PassingScore                   int               = null
	,@Score                          int               = null
	,@ExamStatusSID                  int               = null
	,@SchedulingPreferences          nvarchar(1000)    = null
	,@AssignedLocation               varchar(15)       = null
	,@ExamReference                  varchar(25)       = null
	,@ExamOfferingSID                int               = null
	,@InvoiceSID                     int               = null
	,@ConfirmedTime                  datetimeoffset(7) = null
	,@CancelledTime                  datetimeoffset(7) = null
	,@ExamConfiguration              xml               = null
	,@ExamResponses                  xml               = null
	,@ProcessedTime                  datetimeoffset(7) = null
	,@ProcessingComments             nvarchar(max)     = null
	,@UserDefinedColumns             xml               = null
	,@RegistrantExamXID              varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@ExamName                       nvarchar(50)      = null -- not a base table column
	,@ExamCategory                   nvarchar(65)      = null -- not a base table column
	,@ExamPassingScore               int               = null -- not a base table column
	,@EffectiveTime                  datetime          = null -- not a base table column
	,@ExpiryTime                     datetime          = null -- not a base table column
	,@IsOnlineExam                   bit               = null -- not a base table column
	,@IsEnabledOnPortal              bit               = null -- not a base table column
	,@ExamSequence                   int               = null -- not a base table column
	,@CultureSID                     int               = null -- not a base table column
	,@LastVerifiedTime               datetimeoffset(7) = null -- not a base table column
	,@MinLagDaysBetweenAttempts      smallint          = null -- not a base table column
	,@MaxAttemptsPerYear             tinyint           = null -- not a base table column
	,@VendorExamID                   varchar(25)       = null -- not a base table column
	,@ExamRowGUID                    uniqueidentifier  = null -- not a base table column
	,@ExamStatusSCD                  varchar(15)       = null -- not a base table column
	,@ExamStatusLabel                nvarchar(35)      = null -- not a base table column
	,@ExamStatusSequence             int               = null -- not a base table column
	,@ExamStatusIsDefault            bit               = null -- not a base table column
	,@ExamStatusRowGUID              uniqueidentifier  = null -- not a base table column
	,@RegistrantPersonSID            int               = null -- not a base table column
	,@RegistrantNo                   varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment        smallint          = null -- not a base table column
	,@IsOnPublicRegistry             bit               = null -- not a base table column
	,@CityNameOfBirth                nvarchar(30)      = null -- not a base table column
	,@CountrySID                     int               = null -- not a base table column
	,@DirectedAuditYearCompetence    smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours smallint          = null -- not a base table column
	,@LateFeeExclusionYear           smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked   bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime     datetime          = null -- not a base table column
	,@ArchivedTime                   datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID              uniqueidentifier  = null -- not a base table column
	,@InvoicePersonSID               int               = null -- not a base table column
	,@InvoiceDate                    date              = null -- not a base table column
	,@Tax1Label                      nvarchar(8)       = null -- not a base table column
	,@Tax1Rate                       decimal(4,4)      = null -- not a base table column
	,@Tax1GLAccountCode              varchar(50)       = null -- not a base table column
	,@Tax2Label                      nvarchar(8)       = null -- not a base table column
	,@Tax2Rate                       decimal(4,4)      = null -- not a base table column
	,@Tax2GLAccountCode              varchar(50)       = null -- not a base table column
	,@Tax3Label                      nvarchar(8)       = null -- not a base table column
	,@Tax3Rate                       decimal(4,4)      = null -- not a base table column
	,@Tax3GLAccountCode              varchar(50)       = null -- not a base table column
	,@RegistrationYear               smallint          = null -- not a base table column
	,@InvoiceCancelledTime           datetimeoffset(7) = null -- not a base table column
	,@ReasonSID                      int               = null -- not a base table column
	,@IsRefund                       bit               = null -- not a base table column
	,@ComplaintSID                   int               = null -- not a base table column
	,@InvoiceRowGUID                 uniqueidentifier  = null -- not a base table column
	,@ExamOfferingExamSID            int               = null -- not a base table column
	,@OrgSID                         int               = null -- not a base table column
	,@ExamTime                       datetime          = null -- not a base table column
	,@SeatingCapacity                int               = null -- not a base table column
	,@CatalogItemSID                 int               = null -- not a base table column
	,@BookingCutOffDate              date              = null -- not a base table column
	,@VendorExamOfferingID           varchar(25)       = null -- not a base table column
	,@ExamOfferingRowGUID            uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsViewEnabled                  bit               = null -- not a base table column
	,@IsEditEnabled                  bit               = null -- not a base table column
	,@IsPDFDisplayed                 bit               = null -- not a base table column
	,@PersonDocSID                   int               = null -- not a base table column
	,@ApplicationUserSID             int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantExam#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantExam table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantExam table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantExam entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantExam procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantExamCheck to test all rules.

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

		if @RegistrantExamSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantExamSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @SchedulingPreferences = ltrim(rtrim(@SchedulingPreferences))
		set @AssignedLocation = ltrim(rtrim(@AssignedLocation))
		set @ExamReference = ltrim(rtrim(@ExamReference))
		set @ProcessingComments = ltrim(rtrim(@ProcessingComments))
		set @RegistrantExamXID = ltrim(rtrim(@RegistrantExamXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ExamName = ltrim(rtrim(@ExamName))
		set @ExamCategory = ltrim(rtrim(@ExamCategory))
		set @VendorExamID = ltrim(rtrim(@VendorExamID))
		set @ExamStatusSCD = ltrim(rtrim(@ExamStatusSCD))
		set @ExamStatusLabel = ltrim(rtrim(@ExamStatusLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @VendorExamOfferingID = ltrim(rtrim(@VendorExamOfferingID))

		-- set zero length strings to null to avoid storing them in the record

		if len(@SchedulingPreferences) = 0 set @SchedulingPreferences = null
		if len(@AssignedLocation) = 0 set @AssignedLocation = null
		if len(@ExamReference) = 0 set @ExamReference = null
		if len(@ProcessingComments) = 0 set @ProcessingComments = null
		if len(@RegistrantExamXID) = 0 set @RegistrantExamXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ExamName) = 0 set @ExamName = null
		if len(@ExamCategory) = 0 set @ExamCategory = null
		if len(@VendorExamID) = 0 set @VendorExamID = null
		if len(@ExamStatusSCD) = 0 set @ExamStatusSCD = null
		if len(@ExamStatusLabel) = 0 set @ExamStatusLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@VendorExamOfferingID) = 0 set @VendorExamOfferingID = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                  = isnull(@RegistrantSID,re.RegistrantSID)
				,@ExamSID                        = isnull(@ExamSID,re.ExamSID)
				,@ExamDate                       = isnull(@ExamDate,re.ExamDate)
				,@ExamResultDate                 = isnull(@ExamResultDate,re.ExamResultDate)
				,@PassingScore                   = isnull(@PassingScore,re.PassingScore)
				,@Score                          = isnull(@Score,re.Score)
				,@ExamStatusSID                  = isnull(@ExamStatusSID,re.ExamStatusSID)
				,@SchedulingPreferences          = isnull(@SchedulingPreferences,re.SchedulingPreferences)
				,@AssignedLocation               = isnull(@AssignedLocation,re.AssignedLocation)
				,@ExamReference                  = isnull(@ExamReference,re.ExamReference)
				,@ExamOfferingSID                = isnull(@ExamOfferingSID,re.ExamOfferingSID)
				,@InvoiceSID                     = isnull(@InvoiceSID,re.InvoiceSID)
				,@ConfirmedTime                  = isnull(@ConfirmedTime,re.ConfirmedTime)
				,@CancelledTime                  = isnull(@CancelledTime,re.CancelledTime)
				,@ExamConfiguration              = isnull(@ExamConfiguration,re.ExamConfiguration)
				,@ExamResponses                  = isnull(@ExamResponses,re.ExamResponses)
				,@ProcessedTime                  = isnull(@ProcessedTime,re.ProcessedTime)
				,@ProcessingComments             = isnull(@ProcessingComments,re.ProcessingComments)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,re.UserDefinedColumns)
				,@RegistrantExamXID              = isnull(@RegistrantExamXID,re.RegistrantExamXID)
				,@LegacyKey                      = isnull(@LegacyKey,re.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,re.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,re.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,re.IsNullApplied)
				,@zContext                       = isnull(@zContext,re.zContext)
				,@ExamName                       = isnull(@ExamName,re.ExamName)
				,@ExamCategory                   = isnull(@ExamCategory,re.ExamCategory)
				,@ExamPassingScore               = isnull(@ExamPassingScore,re.ExamPassingScore)
				,@EffectiveTime                  = isnull(@EffectiveTime,re.EffectiveTime)
				,@ExpiryTime                     = isnull(@ExpiryTime,re.ExpiryTime)
				,@IsOnlineExam                   = isnull(@IsOnlineExam,re.IsOnlineExam)
				,@IsEnabledOnPortal              = isnull(@IsEnabledOnPortal,re.IsEnabledOnPortal)
				,@ExamSequence                   = isnull(@ExamSequence,re.ExamSequence)
				,@CultureSID                     = isnull(@CultureSID,re.CultureSID)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,re.LastVerifiedTime)
				,@MinLagDaysBetweenAttempts      = isnull(@MinLagDaysBetweenAttempts,re.MinLagDaysBetweenAttempts)
				,@MaxAttemptsPerYear             = isnull(@MaxAttemptsPerYear,re.MaxAttemptsPerYear)
				,@VendorExamID                   = isnull(@VendorExamID,re.VendorExamID)
				,@ExamRowGUID                    = isnull(@ExamRowGUID,re.ExamRowGUID)
				,@ExamStatusSCD                  = isnull(@ExamStatusSCD,re.ExamStatusSCD)
				,@ExamStatusLabel                = isnull(@ExamStatusLabel,re.ExamStatusLabel)
				,@ExamStatusSequence             = isnull(@ExamStatusSequence,re.ExamStatusSequence)
				,@ExamStatusIsDefault            = isnull(@ExamStatusIsDefault,re.ExamStatusIsDefault)
				,@ExamStatusRowGUID              = isnull(@ExamStatusRowGUID,re.ExamStatusRowGUID)
				,@RegistrantPersonSID            = isnull(@RegistrantPersonSID,re.RegistrantPersonSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,re.RegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,re.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,re.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,re.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,re.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,re.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,re.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,re.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,re.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,re.RenewalExtensionExpiryTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,re.ArchivedTime)
				,@RegistrantRowGUID              = isnull(@RegistrantRowGUID,re.RegistrantRowGUID)
				,@InvoicePersonSID               = isnull(@InvoicePersonSID,re.InvoicePersonSID)
				,@InvoiceDate                    = isnull(@InvoiceDate,re.InvoiceDate)
				,@Tax1Label                      = isnull(@Tax1Label,re.Tax1Label)
				,@Tax1Rate                       = isnull(@Tax1Rate,re.Tax1Rate)
				,@Tax1GLAccountCode              = isnull(@Tax1GLAccountCode,re.Tax1GLAccountCode)
				,@Tax2Label                      = isnull(@Tax2Label,re.Tax2Label)
				,@Tax2Rate                       = isnull(@Tax2Rate,re.Tax2Rate)
				,@Tax2GLAccountCode              = isnull(@Tax2GLAccountCode,re.Tax2GLAccountCode)
				,@Tax3Label                      = isnull(@Tax3Label,re.Tax3Label)
				,@Tax3Rate                       = isnull(@Tax3Rate,re.Tax3Rate)
				,@Tax3GLAccountCode              = isnull(@Tax3GLAccountCode,re.Tax3GLAccountCode)
				,@RegistrationYear               = isnull(@RegistrationYear,re.RegistrationYear)
				,@InvoiceCancelledTime           = isnull(@InvoiceCancelledTime,re.InvoiceCancelledTime)
				,@ReasonSID                      = isnull(@ReasonSID,re.ReasonSID)
				,@IsRefund                       = isnull(@IsRefund,re.IsRefund)
				,@ComplaintSID                   = isnull(@ComplaintSID,re.ComplaintSID)
				,@InvoiceRowGUID                 = isnull(@InvoiceRowGUID,re.InvoiceRowGUID)
				,@ExamOfferingExamSID            = isnull(@ExamOfferingExamSID,re.ExamOfferingExamSID)
				,@OrgSID                         = isnull(@OrgSID,re.OrgSID)
				,@ExamTime                       = isnull(@ExamTime,re.ExamTime)
				,@SeatingCapacity                = isnull(@SeatingCapacity,re.SeatingCapacity)
				,@CatalogItemSID                 = isnull(@CatalogItemSID,re.CatalogItemSID)
				,@BookingCutOffDate              = isnull(@BookingCutOffDate,re.BookingCutOffDate)
				,@VendorExamOfferingID           = isnull(@VendorExamOfferingID,re.VendorExamOfferingID)
				,@ExamOfferingRowGUID            = isnull(@ExamOfferingRowGUID,re.ExamOfferingRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,re.IsDeleteEnabled)
				,@IsViewEnabled                  = isnull(@IsViewEnabled,re.IsViewEnabled)
				,@IsEditEnabled                  = isnull(@IsEditEnabled,re.IsEditEnabled)
				,@IsPDFDisplayed                 = isnull(@IsPDFDisplayed,re.IsPDFDisplayed)
				,@PersonDocSID                   = isnull(@PersonDocSID,re.PersonDocSID)
				,@ApplicationUserSID             = isnull(@ApplicationUserSID,re.ApplicationUserSID)
			from
				dbo.vRegistrantExam re
			where
				re.RegistrantExamSID = @RegistrantExamSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ExamStatusSCD is not null and @ExamStatusSID = (select x.ExamStatusSID from dbo.RegistrantExam x where x.RegistrantExamSID = @RegistrantExamSID)
		begin
		
			select
				@ExamStatusSID = x.ExamStatusSID
			from
				dbo.ExamStatus x
			where
				x.ExamStatusSCD = @ExamStatusSCD
		
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
				r.RoutineName = 'pRegistrantExam'
		)
		begin
		
			exec @errorNo = ext.pRegistrantExam
				 @Mode                           = 'update.pre'
				,@RegistrantExamSID              = @RegistrantExamSID
				,@RegistrantSID                  = @RegistrantSID output
				,@ExamSID                        = @ExamSID output
				,@ExamDate                       = @ExamDate output
				,@ExamResultDate                 = @ExamResultDate output
				,@PassingScore                   = @PassingScore output
				,@Score                          = @Score output
				,@ExamStatusSID                  = @ExamStatusSID output
				,@SchedulingPreferences          = @SchedulingPreferences output
				,@AssignedLocation               = @AssignedLocation output
				,@ExamReference                  = @ExamReference output
				,@ExamOfferingSID                = @ExamOfferingSID output
				,@InvoiceSID                     = @InvoiceSID output
				,@ConfirmedTime                  = @ConfirmedTime output
				,@CancelledTime                  = @CancelledTime output
				,@ExamConfiguration              = @ExamConfiguration output
				,@ExamResponses                  = @ExamResponses output
				,@ProcessedTime                  = @ProcessedTime output
				,@ProcessingComments             = @ProcessingComments output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantExamXID              = @RegistrantExamXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@ExamName                       = @ExamName
				,@ExamCategory                   = @ExamCategory
				,@ExamPassingScore               = @ExamPassingScore
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@IsOnlineExam                   = @IsOnlineExam
				,@IsEnabledOnPortal              = @IsEnabledOnPortal
				,@ExamSequence                   = @ExamSequence
				,@CultureSID                     = @CultureSID
				,@LastVerifiedTime               = @LastVerifiedTime
				,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
				,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
				,@VendorExamID                   = @VendorExamID
				,@ExamRowGUID                    = @ExamRowGUID
				,@ExamStatusSCD                  = @ExamStatusSCD
				,@ExamStatusLabel                = @ExamStatusLabel
				,@ExamStatusSequence             = @ExamStatusSequence
				,@ExamStatusIsDefault            = @ExamStatusIsDefault
				,@ExamStatusRowGUID              = @ExamStatusRowGUID
				,@RegistrantPersonSID            = @RegistrantPersonSID
				,@RegistrantNo                   = @RegistrantNo
				,@YearOfInitialEmployment        = @YearOfInitialEmployment
				,@IsOnPublicRegistry             = @IsOnPublicRegistry
				,@CityNameOfBirth                = @CityNameOfBirth
				,@CountrySID                     = @CountrySID
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear           = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
				,@ArchivedTime                   = @ArchivedTime
				,@RegistrantRowGUID              = @RegistrantRowGUID
				,@InvoicePersonSID               = @InvoicePersonSID
				,@InvoiceDate                    = @InvoiceDate
				,@Tax1Label                      = @Tax1Label
				,@Tax1Rate                       = @Tax1Rate
				,@Tax1GLAccountCode              = @Tax1GLAccountCode
				,@Tax2Label                      = @Tax2Label
				,@Tax2Rate                       = @Tax2Rate
				,@Tax2GLAccountCode              = @Tax2GLAccountCode
				,@Tax3Label                      = @Tax3Label
				,@Tax3Rate                       = @Tax3Rate
				,@Tax3GLAccountCode              = @Tax3GLAccountCode
				,@RegistrationYear               = @RegistrationYear
				,@InvoiceCancelledTime           = @InvoiceCancelledTime
				,@ReasonSID                      = @ReasonSID
				,@IsRefund                       = @IsRefund
				,@ComplaintSID                   = @ComplaintSID
				,@InvoiceRowGUID                 = @InvoiceRowGUID
				,@ExamOfferingExamSID            = @ExamOfferingExamSID
				,@OrgSID                         = @OrgSID
				,@ExamTime                       = @ExamTime
				,@SeatingCapacity                = @SeatingCapacity
				,@CatalogItemSID                 = @CatalogItemSID
				,@BookingCutOffDate              = @BookingCutOffDate
				,@VendorExamOfferingID           = @VendorExamOfferingID
				,@ExamOfferingRowGUID            = @ExamOfferingRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsViewEnabled                  = @IsViewEnabled
				,@IsEditEnabled                  = @IsEditEnabled
				,@IsPDFDisplayed                 = @IsPDFDisplayed
				,@PersonDocSID                   = @PersonDocSID
				,@ApplicationUserSID             = @ApplicationUserSID
		
		end

		-- update the record

		update
			dbo.RegistrantExam
		set
			 RegistrantSID = @RegistrantSID
			,ExamSID = @ExamSID
			,ExamDate = @ExamDate
			,ExamResultDate = @ExamResultDate
			,PassingScore = @PassingScore
			,Score = @Score
			,ExamStatusSID = @ExamStatusSID
			,SchedulingPreferences = @SchedulingPreferences
			,AssignedLocation = @AssignedLocation
			,ExamReference = @ExamReference
			,ExamOfferingSID = @ExamOfferingSID
			,InvoiceSID = @InvoiceSID
			,ConfirmedTime = @ConfirmedTime
			,CancelledTime = @CancelledTime
			,ExamConfiguration = @ExamConfiguration
			,ExamResponses = @ExamResponses
			,ProcessedTime = @ProcessedTime
			,ProcessingComments = @ProcessingComments
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantExamXID = @RegistrantExamXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantExamSID = @RegistrantExamSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantExam where RegistrantExamSID = @registrantExamSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantExam'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantExam'
					,@Arg2        = @registrantExamSID
				
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
				,@Arg2        = 'dbo.RegistrantExam'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantExamSID
			
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
				r.RoutineName = 'pRegistrantExam'
		)
		begin
		
			exec @errorNo = ext.pRegistrantExam
				 @Mode                           = 'update.post'
				,@RegistrantExamSID              = @RegistrantExamSID
				,@RegistrantSID                  = @RegistrantSID
				,@ExamSID                        = @ExamSID
				,@ExamDate                       = @ExamDate
				,@ExamResultDate                 = @ExamResultDate
				,@PassingScore                   = @PassingScore
				,@Score                          = @Score
				,@ExamStatusSID                  = @ExamStatusSID
				,@SchedulingPreferences          = @SchedulingPreferences
				,@AssignedLocation               = @AssignedLocation
				,@ExamReference                  = @ExamReference
				,@ExamOfferingSID                = @ExamOfferingSID
				,@InvoiceSID                     = @InvoiceSID
				,@ConfirmedTime                  = @ConfirmedTime
				,@CancelledTime                  = @CancelledTime
				,@ExamConfiguration              = @ExamConfiguration
				,@ExamResponses                  = @ExamResponses
				,@ProcessedTime                  = @ProcessedTime
				,@ProcessingComments             = @ProcessingComments
				,@UserDefinedColumns             = @UserDefinedColumns
				,@RegistrantExamXID              = @RegistrantExamXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@ExamName                       = @ExamName
				,@ExamCategory                   = @ExamCategory
				,@ExamPassingScore               = @ExamPassingScore
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@IsOnlineExam                   = @IsOnlineExam
				,@IsEnabledOnPortal              = @IsEnabledOnPortal
				,@ExamSequence                   = @ExamSequence
				,@CultureSID                     = @CultureSID
				,@LastVerifiedTime               = @LastVerifiedTime
				,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
				,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
				,@VendorExamID                   = @VendorExamID
				,@ExamRowGUID                    = @ExamRowGUID
				,@ExamStatusSCD                  = @ExamStatusSCD
				,@ExamStatusLabel                = @ExamStatusLabel
				,@ExamStatusSequence             = @ExamStatusSequence
				,@ExamStatusIsDefault            = @ExamStatusIsDefault
				,@ExamStatusRowGUID              = @ExamStatusRowGUID
				,@RegistrantPersonSID            = @RegistrantPersonSID
				,@RegistrantNo                   = @RegistrantNo
				,@YearOfInitialEmployment        = @YearOfInitialEmployment
				,@IsOnPublicRegistry             = @IsOnPublicRegistry
				,@CityNameOfBirth                = @CityNameOfBirth
				,@CountrySID                     = @CountrySID
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear           = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
				,@ArchivedTime                   = @ArchivedTime
				,@RegistrantRowGUID              = @RegistrantRowGUID
				,@InvoicePersonSID               = @InvoicePersonSID
				,@InvoiceDate                    = @InvoiceDate
				,@Tax1Label                      = @Tax1Label
				,@Tax1Rate                       = @Tax1Rate
				,@Tax1GLAccountCode              = @Tax1GLAccountCode
				,@Tax2Label                      = @Tax2Label
				,@Tax2Rate                       = @Tax2Rate
				,@Tax2GLAccountCode              = @Tax2GLAccountCode
				,@Tax3Label                      = @Tax3Label
				,@Tax3Rate                       = @Tax3Rate
				,@Tax3GLAccountCode              = @Tax3GLAccountCode
				,@RegistrationYear               = @RegistrationYear
				,@InvoiceCancelledTime           = @InvoiceCancelledTime
				,@ReasonSID                      = @ReasonSID
				,@IsRefund                       = @IsRefund
				,@ComplaintSID                   = @ComplaintSID
				,@InvoiceRowGUID                 = @InvoiceRowGUID
				,@ExamOfferingExamSID            = @ExamOfferingExamSID
				,@OrgSID                         = @OrgSID
				,@ExamTime                       = @ExamTime
				,@SeatingCapacity                = @SeatingCapacity
				,@CatalogItemSID                 = @CatalogItemSID
				,@BookingCutOffDate              = @BookingCutOffDate
				,@VendorExamOfferingID           = @VendorExamOfferingID
				,@ExamOfferingRowGUID            = @ExamOfferingRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsViewEnabled                  = @IsViewEnabled
				,@IsEditEnabled                  = @IsEditEnabled
				,@IsPDFDisplayed                 = @IsPDFDisplayed
				,@PersonDocSID                   = @PersonDocSID
				,@ApplicationUserSID             = @ApplicationUserSID
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantExamSID
			from
				dbo.vRegistrantExam ent
			where
				ent.RegistrantExamSID = @RegistrantExamSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantExamSID
				,ent.RegistrantSID
				,ent.ExamSID
				,ent.ExamDate
				,ent.ExamResultDate
				,ent.PassingScore
				,ent.Score
				,ent.ExamStatusSID
				,ent.SchedulingPreferences
				,ent.AssignedLocation
				,ent.ExamReference
				,ent.ExamOfferingSID
				,ent.InvoiceSID
				,ent.ConfirmedTime
				,ent.CancelledTime
				,ent.ExamConfiguration
				,ent.ExamResponses
				,ent.ProcessedTime
				,ent.ProcessingComments
				,ent.UserDefinedColumns
				,ent.RegistrantExamXID
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
				,ent.ExamPassingScore
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsOnlineExam
				,ent.IsEnabledOnPortal
				,ent.ExamSequence
				,ent.CultureSID
				,ent.LastVerifiedTime
				,ent.MinLagDaysBetweenAttempts
				,ent.MaxAttemptsPerYear
				,ent.VendorExamID
				,ent.ExamRowGUID
				,ent.ExamStatusSCD
				,ent.ExamStatusLabel
				,ent.ExamStatusSequence
				,ent.ExamStatusIsDefault
				,ent.ExamStatusRowGUID
				,ent.RegistrantPersonSID
				,ent.RegistrantNo
				,ent.YearOfInitialEmployment
				,ent.IsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.InvoicePersonSID
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
				,ent.InvoiceCancelledTime
				,ent.ReasonSID
				,ent.IsRefund
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
				,ent.ExamOfferingExamSID
				,ent.OrgSID
				,ent.ExamTime
				,ent.SeatingCapacity
				,ent.CatalogItemSID
				,ent.BookingCutOffDate
				,ent.VendorExamOfferingID
				,ent.ExamOfferingRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsPDFDisplayed
				,ent.PersonDocSID
				,ent.ApplicationUserSID
			from
				dbo.vRegistrantExam ent
			where
				ent.RegistrantExamSID = @RegistrantExamSID

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
