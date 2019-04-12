SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistration#Update]
	 @RegistrationSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                    int               = null -- table column values to update:
	,@PracticeRegisterSectionSID       int               = null
	,@RegistrationNo                   nvarchar(50)      = null
	,@RegistrationYear                 smallint          = null
	,@EffectiveTime                    datetime          = null
	,@ExpiryTime                       datetime          = null
	,@CardPrintedTime                  datetime          = null
	,@InvoiceSID                       int               = null
	,@ReasonSID                        int               = null
	,@FormGUID                         uniqueidentifier  = null
	,@UserDefinedColumns               xml               = null
	,@RegistrationXID                  varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@PracticeRegisterSID              int               = null -- not a base table column
	,@PracticeRegisterSectionLabel     nvarchar(35)      = null -- not a base table column
	,@PracticeRegisterSectionIsDefault bit               = null -- not a base table column
	,@IsDisplayedOnLicense             bit               = null -- not a base table column
	,@PracticeRegisterSectionIsActive  bit               = null -- not a base table column
	,@PracticeRegisterSectionRowGUID   uniqueidentifier  = null -- not a base table column
	,@RegistrantPersonSID              int               = null -- not a base table column
	,@RegistrantNo                     varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment          smallint          = null -- not a base table column
	,@IsOnPublicRegistry               bit               = null -- not a base table column
	,@CityNameOfBirth                  nvarchar(30)      = null -- not a base table column
	,@CountrySID                       int               = null -- not a base table column
	,@DirectedAuditYearCompetence      smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours   smallint          = null -- not a base table column
	,@LateFeeExclusionYear             smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked     bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime       datetime          = null -- not a base table column
	,@ArchivedTime                     datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                uniqueidentifier  = null -- not a base table column
	,@InvoicePersonSID                 int               = null -- not a base table column
	,@InvoiceDate                      date              = null -- not a base table column
	,@Tax1Label                        nvarchar(8)       = null -- not a base table column
	,@Tax1Rate                         decimal(4,4)      = null -- not a base table column
	,@Tax1GLAccountCode                varchar(50)       = null -- not a base table column
	,@Tax2Label                        nvarchar(8)       = null -- not a base table column
	,@Tax2Rate                         decimal(4,4)      = null -- not a base table column
	,@Tax2GLAccountCode                varchar(50)       = null -- not a base table column
	,@Tax3Label                        nvarchar(8)       = null -- not a base table column
	,@Tax3Rate                         decimal(4,4)      = null -- not a base table column
	,@Tax3GLAccountCode                varchar(50)       = null -- not a base table column
	,@InvoiceRegistrationYear          smallint          = null -- not a base table column
	,@CancelledTime                    datetimeoffset(7) = null -- not a base table column
	,@InvoiceReasonSID                 int               = null -- not a base table column
	,@IsRefund                         bit               = null -- not a base table column
	,@ComplaintSID                     int               = null -- not a base table column
	,@InvoiceRowGUID                   uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                   int               = null -- not a base table column
	,@ReasonName                       nvarchar(50)      = null -- not a base table column
	,@ReasonCode                       varchar(25)       = null -- not a base table column
	,@ReasonSequence                   smallint          = null -- not a base table column
	,@ToolTip                          nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                   bit               = null -- not a base table column
	,@ReasonRowGUID                    uniqueidentifier  = null -- not a base table column
	,@IsActive                         bit               = null -- not a base table column
	,@IsPending                        bit               = null -- not a base table column
	,@IsDeleteEnabled                  bit               = null -- not a base table column
	,@RegistrantLabel                  nvarchar(75)      = null -- not a base table column
	,@RegistrationYearLabel            varchar(25)       = null -- not a base table column
	,@PracticeRegisterName             nvarchar(65)      = null -- not a base table column
	,@PracticeRegisterLabel            nvarchar(35)      = null -- not a base table column
	,@RegistrationLabel                nvarchar(85)      = null -- not a base table column
	,@IsReadEnabled                    bit               = null -- not a base table column
	,@FirstName                        nvarchar(30)      = null -- not a base table column
	,@MiddleNames                      nvarchar(30)      = null -- not a base table column
	,@LastName                         nvarchar(35)      = null -- not a base table column
	,@AddressBlockForPrint             nvarchar(512)     = null -- not a base table column
	,@AddressBlockForHTML              nvarchar(512)     = null -- not a base table column
	,@FutureRegistrationLabel          nvarchar(85)      = null -- not a base table column
	,@FutureRegistrationYear           smallint          = null -- not a base table column
	,@FuturePracticeRegisterSID        int               = null -- not a base table column
	,@FuturePracticeRegisterLabel      nvarchar(35)      = null -- not a base table column
	,@FuturePracticeRegisterSectionSID int               = null -- not a base table column
	,@FutureRegisterSectionLabel       nvarchar(35)      = null -- not a base table column
	,@FutureEffectiveTime              datetime          = null -- not a base table column
	,@FutureExpiryTime                 datetime          = null -- not a base table column
	,@FutureCardPrintedTime            datetime          = null -- not a base table column
	,@FutureInvoiceSID                 int               = null -- not a base table column
	,@FutureReasonSID                  int               = null -- not a base table column
	,@FutureFormGUID                   uniqueidentifier  = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistration#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Registration table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Registration table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistration entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistration procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationCheck to test all rules.

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

		if @RegistrationSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @RegistrationXID = ltrim(rtrim(@RegistrationXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @RegistrationLabel = ltrim(rtrim(@RegistrationLabel))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @AddressBlockForPrint = ltrim(rtrim(@AddressBlockForPrint))
		set @AddressBlockForHTML = ltrim(rtrim(@AddressBlockForHTML))
		set @FutureRegistrationLabel = ltrim(rtrim(@FutureRegistrationLabel))
		set @FuturePracticeRegisterLabel = ltrim(rtrim(@FuturePracticeRegisterLabel))
		set @FutureRegisterSectionLabel = ltrim(rtrim(@FutureRegisterSectionLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@RegistrationXID) = 0 set @RegistrationXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@RegistrationLabel) = 0 set @RegistrationLabel = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@AddressBlockForPrint) = 0 set @AddressBlockForPrint = null
		if len(@AddressBlockForHTML) = 0 set @AddressBlockForHTML = null
		if len(@FutureRegistrationLabel) = 0 set @FutureRegistrationLabel = null
		if len(@FuturePracticeRegisterLabel) = 0 set @FuturePracticeRegisterLabel = null
		if len(@FutureRegisterSectionLabel) = 0 set @FutureRegisterSectionLabel = null
		
		if @EffectiveTime is not null	set @EffectiveTime = cast(cast(@EffectiveTime as date) as datetime)																			-- ensure Effective value has start-of-day time component
		if @ExpiryTime is not null		set @ExpiryTime = cast(convert(varchar(8), cast(@ExpiryTime as date), 112) + ' 23:59:59.99' as datetime)-- ensure Expiry value has end-of-day time component

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)													-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()																-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                    = isnull(@RegistrantSID,reg.RegistrantSID)
				,@PracticeRegisterSectionSID       = isnull(@PracticeRegisterSectionSID,reg.PracticeRegisterSectionSID)
				,@RegistrationNo                   = isnull(@RegistrationNo,reg.RegistrationNo)
				,@RegistrationYear                 = isnull(@RegistrationYear,reg.RegistrationYear)
				,@EffectiveTime                    = isnull(@EffectiveTime,reg.EffectiveTime)
				,@ExpiryTime                       = isnull(@ExpiryTime,reg.ExpiryTime)
				,@CardPrintedTime                  = isnull(@CardPrintedTime,reg.CardPrintedTime)
				,@InvoiceSID                       = isnull(@InvoiceSID,reg.InvoiceSID)
				,@ReasonSID                        = isnull(@ReasonSID,reg.ReasonSID)
				,@FormGUID                         = isnull(@FormGUID,reg.FormGUID)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,reg.UserDefinedColumns)
				,@RegistrationXID                  = isnull(@RegistrationXID,reg.RegistrationXID)
				,@LegacyKey                        = isnull(@LegacyKey,reg.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,reg.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,reg.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,reg.IsNullApplied)
				,@zContext                         = isnull(@zContext,reg.zContext)
				,@PracticeRegisterSID              = isnull(@PracticeRegisterSID,reg.PracticeRegisterSID)
				,@PracticeRegisterSectionLabel     = isnull(@PracticeRegisterSectionLabel,reg.PracticeRegisterSectionLabel)
				,@PracticeRegisterSectionIsDefault = isnull(@PracticeRegisterSectionIsDefault,reg.PracticeRegisterSectionIsDefault)
				,@IsDisplayedOnLicense             = isnull(@IsDisplayedOnLicense,reg.IsDisplayedOnLicense)
				,@PracticeRegisterSectionIsActive  = isnull(@PracticeRegisterSectionIsActive,reg.PracticeRegisterSectionIsActive)
				,@PracticeRegisterSectionRowGUID   = isnull(@PracticeRegisterSectionRowGUID,reg.PracticeRegisterSectionRowGUID)
				,@RegistrantPersonSID              = isnull(@RegistrantPersonSID,reg.RegistrantPersonSID)
				,@RegistrantNo                     = isnull(@RegistrantNo,reg.RegistrantNo)
				,@YearOfInitialEmployment          = isnull(@YearOfInitialEmployment,reg.YearOfInitialEmployment)
				,@IsOnPublicRegistry               = isnull(@IsOnPublicRegistry,reg.IsOnPublicRegistry)
				,@CityNameOfBirth                  = isnull(@CityNameOfBirth,reg.CityNameOfBirth)
				,@CountrySID                       = isnull(@CountrySID,reg.CountrySID)
				,@DirectedAuditYearCompetence      = isnull(@DirectedAuditYearCompetence,reg.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours   = isnull(@DirectedAuditYearPracticeHours,reg.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear             = isnull(@LateFeeExclusionYear,reg.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked     = isnull(@IsRenewalAutoApprovalBlocked,reg.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime       = isnull(@RenewalExtensionExpiryTime,reg.RenewalExtensionExpiryTime)
				,@ArchivedTime                     = isnull(@ArchivedTime,reg.ArchivedTime)
				,@RegistrantRowGUID                = isnull(@RegistrantRowGUID,reg.RegistrantRowGUID)
				,@InvoicePersonSID                 = isnull(@InvoicePersonSID,reg.InvoicePersonSID)
				,@InvoiceDate                      = isnull(@InvoiceDate,reg.InvoiceDate)
				,@Tax1Label                        = isnull(@Tax1Label,reg.Tax1Label)
				,@Tax1Rate                         = isnull(@Tax1Rate,reg.Tax1Rate)
				,@Tax1GLAccountCode                = isnull(@Tax1GLAccountCode,reg.Tax1GLAccountCode)
				,@Tax2Label                        = isnull(@Tax2Label,reg.Tax2Label)
				,@Tax2Rate                         = isnull(@Tax2Rate,reg.Tax2Rate)
				,@Tax2GLAccountCode                = isnull(@Tax2GLAccountCode,reg.Tax2GLAccountCode)
				,@Tax3Label                        = isnull(@Tax3Label,reg.Tax3Label)
				,@Tax3Rate                         = isnull(@Tax3Rate,reg.Tax3Rate)
				,@Tax3GLAccountCode                = isnull(@Tax3GLAccountCode,reg.Tax3GLAccountCode)
				,@InvoiceRegistrationYear          = isnull(@InvoiceRegistrationYear,reg.InvoiceRegistrationYear)
				,@CancelledTime                    = isnull(@CancelledTime,reg.CancelledTime)
				,@InvoiceReasonSID                 = isnull(@InvoiceReasonSID,reg.InvoiceReasonSID)
				,@IsRefund                         = isnull(@IsRefund,reg.IsRefund)
				,@ComplaintSID                     = isnull(@ComplaintSID,reg.ComplaintSID)
				,@InvoiceRowGUID                   = isnull(@InvoiceRowGUID,reg.InvoiceRowGUID)
				,@ReasonGroupSID                   = isnull(@ReasonGroupSID,reg.ReasonGroupSID)
				,@ReasonName                       = isnull(@ReasonName,reg.ReasonName)
				,@ReasonCode                       = isnull(@ReasonCode,reg.ReasonCode)
				,@ReasonSequence                   = isnull(@ReasonSequence,reg.ReasonSequence)
				,@ToolTip                          = isnull(@ToolTip,reg.ToolTip)
				,@ReasonIsActive                   = isnull(@ReasonIsActive,reg.ReasonIsActive)
				,@ReasonRowGUID                    = isnull(@ReasonRowGUID,reg.ReasonRowGUID)
				,@IsActive                         = isnull(@IsActive,reg.IsActive)
				,@IsPending                        = isnull(@IsPending,reg.IsPending)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,reg.IsDeleteEnabled)
				,@RegistrantLabel                  = isnull(@RegistrantLabel,reg.RegistrantLabel)
				,@RegistrationYearLabel            = isnull(@RegistrationYearLabel,reg.RegistrationYearLabel)
				,@PracticeRegisterName             = isnull(@PracticeRegisterName,reg.PracticeRegisterName)
				,@PracticeRegisterLabel            = isnull(@PracticeRegisterLabel,reg.PracticeRegisterLabel)
				,@RegistrationLabel                = isnull(@RegistrationLabel,reg.RegistrationLabel)
				,@IsReadEnabled                    = isnull(@IsReadEnabled,reg.IsReadEnabled)
				,@FirstName                        = isnull(@FirstName,reg.FirstName)
				,@MiddleNames                      = isnull(@MiddleNames,reg.MiddleNames)
				,@LastName                         = isnull(@LastName,reg.LastName)
				,@AddressBlockForPrint             = isnull(@AddressBlockForPrint,reg.AddressBlockForPrint)
				,@AddressBlockForHTML              = isnull(@AddressBlockForHTML,reg.AddressBlockForHTML)
				,@FutureRegistrationLabel          = isnull(@FutureRegistrationLabel,reg.FutureRegistrationLabel)
				,@FutureRegistrationYear           = isnull(@FutureRegistrationYear,reg.FutureRegistrationYear)
				,@FuturePracticeRegisterSID        = isnull(@FuturePracticeRegisterSID,reg.FuturePracticeRegisterSID)
				,@FuturePracticeRegisterLabel      = isnull(@FuturePracticeRegisterLabel,reg.FuturePracticeRegisterLabel)
				,@FuturePracticeRegisterSectionSID = isnull(@FuturePracticeRegisterSectionSID,reg.FuturePracticeRegisterSectionSID)
				,@FutureRegisterSectionLabel       = isnull(@FutureRegisterSectionLabel,reg.FutureRegisterSectionLabel)
				,@FutureEffectiveTime              = isnull(@FutureEffectiveTime,reg.FutureEffectiveTime)
				,@FutureExpiryTime                 = isnull(@FutureExpiryTime,reg.FutureExpiryTime)
				,@FutureCardPrintedTime            = isnull(@FutureCardPrintedTime,reg.FutureCardPrintedTime)
				,@FutureInvoiceSID                 = isnull(@FutureInvoiceSID,reg.FutureInvoiceSID)
				,@FutureReasonSID                  = isnull(@FutureReasonSID,reg.FutureReasonSID)
				,@FutureFormGUID                   = isnull(@FutureFormGUID,reg.FutureFormGUID)
			from
				dbo.vRegistration reg
			where
				reg.RegistrationSID = @RegistrationSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRegisterSectionSID from dbo.Registration x where x.RegistrationSID = @RegistrationSID) <> @PracticeRegisterSectionSID
			begin
			
				if (select x.IsActive from dbo.PracticeRegisterSection x where x.PracticeRegisterSectionSID = @PracticeRegisterSectionSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice register section'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.ReasonSID from dbo.Registration x where x.RegistrationSID = @RegistrationSID) <> @ReasonSID
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
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Feb 2018
		-- Ensure the effective times for these records are set
		-- to the beginning of the day only. (Overwrites default above.)

		set @EffectiveTime = cast((convert(varchar(8), @EffectiveTime, 112)) + ' 00:00:00.00' as datetime);		

		-- Tim Edlund | Feb 2019
		-- Ensure the registration year matches the effective time
		-- which is editable and may need re-aligning

		set @RegistrationYear = dbo.fRegistrationYear(@EffectiveTime)
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
				r.RoutineName = 'pRegistration'
		)
		begin
		
			exec @errorNo = ext.pRegistration
				 @Mode                             = 'update.pre'
				,@RegistrationSID                  = @RegistrationSID
				,@RegistrantSID                    = @RegistrantSID output
				,@PracticeRegisterSectionSID       = @PracticeRegisterSectionSID output
				,@RegistrationNo                   = @RegistrationNo output
				,@RegistrationYear                 = @RegistrationYear output
				,@EffectiveTime                    = @EffectiveTime output
				,@ExpiryTime                       = @ExpiryTime output
				,@CardPrintedTime                  = @CardPrintedTime output
				,@InvoiceSID                       = @InvoiceSID output
				,@ReasonSID                        = @ReasonSID output
				,@FormGUID                         = @FormGUID output
				,@UserDefinedColumns               = @UserDefinedColumns output
				,@RegistrationXID                  = @RegistrationXID output
				,@LegacyKey                        = @LegacyKey output
				,@UpdateUser                       = @UpdateUser
				,@RowStamp                         = @RowStamp
				,@IsReselected                     = @IsReselected
				,@IsNullApplied                    = @IsNullApplied
				,@zContext                         = @zContext
				,@PracticeRegisterSID              = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel     = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense             = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive  = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID   = @PracticeRegisterSectionRowGUID
				,@RegistrantPersonSID              = @RegistrantPersonSID
				,@RegistrantNo                     = @RegistrantNo
				,@YearOfInitialEmployment          = @YearOfInitialEmployment
				,@IsOnPublicRegistry               = @IsOnPublicRegistry
				,@CityNameOfBirth                  = @CityNameOfBirth
				,@CountrySID                       = @CountrySID
				,@DirectedAuditYearCompetence      = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours   = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear             = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked     = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime       = @RenewalExtensionExpiryTime
				,@ArchivedTime                     = @ArchivedTime
				,@RegistrantRowGUID                = @RegistrantRowGUID
				,@InvoicePersonSID                 = @InvoicePersonSID
				,@InvoiceDate                      = @InvoiceDate
				,@Tax1Label                        = @Tax1Label
				,@Tax1Rate                         = @Tax1Rate
				,@Tax1GLAccountCode                = @Tax1GLAccountCode
				,@Tax2Label                        = @Tax2Label
				,@Tax2Rate                         = @Tax2Rate
				,@Tax2GLAccountCode                = @Tax2GLAccountCode
				,@Tax3Label                        = @Tax3Label
				,@Tax3Rate                         = @Tax3Rate
				,@Tax3GLAccountCode                = @Tax3GLAccountCode
				,@InvoiceRegistrationYear          = @InvoiceRegistrationYear
				,@CancelledTime                    = @CancelledTime
				,@InvoiceReasonSID                 = @InvoiceReasonSID
				,@IsRefund                         = @IsRefund
				,@ComplaintSID                     = @ComplaintSID
				,@InvoiceRowGUID                   = @InvoiceRowGUID
				,@ReasonGroupSID                   = @ReasonGroupSID
				,@ReasonName                       = @ReasonName
				,@ReasonCode                       = @ReasonCode
				,@ReasonSequence                   = @ReasonSequence
				,@ToolTip                          = @ToolTip
				,@ReasonIsActive                   = @ReasonIsActive
				,@ReasonRowGUID                    = @ReasonRowGUID
				,@IsActive                         = @IsActive
				,@IsPending                        = @IsPending
				,@IsDeleteEnabled                  = @IsDeleteEnabled
				,@RegistrantLabel                  = @RegistrantLabel
				,@RegistrationYearLabel            = @RegistrationYearLabel
				,@PracticeRegisterName             = @PracticeRegisterName
				,@PracticeRegisterLabel            = @PracticeRegisterLabel
				,@RegistrationLabel                = @RegistrationLabel
				,@IsReadEnabled                    = @IsReadEnabled
				,@FirstName                        = @FirstName
				,@MiddleNames                      = @MiddleNames
				,@LastName                         = @LastName
				,@AddressBlockForPrint             = @AddressBlockForPrint
				,@AddressBlockForHTML              = @AddressBlockForHTML
				,@FutureRegistrationLabel          = @FutureRegistrationLabel
				,@FutureRegistrationYear           = @FutureRegistrationYear
				,@FuturePracticeRegisterSID        = @FuturePracticeRegisterSID
				,@FuturePracticeRegisterLabel      = @FuturePracticeRegisterLabel
				,@FuturePracticeRegisterSectionSID = @FuturePracticeRegisterSectionSID
				,@FutureRegisterSectionLabel       = @FutureRegisterSectionLabel
				,@FutureEffectiveTime              = @FutureEffectiveTime
				,@FutureExpiryTime                 = @FutureExpiryTime
				,@FutureCardPrintedTime            = @FutureCardPrintedTime
				,@FutureInvoiceSID                 = @FutureInvoiceSID
				,@FutureReasonSID                  = @FutureReasonSID
				,@FutureFormGUID                   = @FutureFormGUID
		
		end

		-- update the record

		update
			dbo.Registration
		set
			 RegistrantSID = @RegistrantSID
			,PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			,RegistrationNo = @RegistrationNo
			,RegistrationYear = @RegistrationYear
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,CardPrintedTime = @CardPrintedTime
			,InvoiceSID = @InvoiceSID
			,ReasonSID = @ReasonSID
			,FormGUID = @FormGUID
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrationXID = @RegistrationXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationSID = @RegistrationSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Registration where RegistrationSID = @registrationSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Registration'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Registration'
					,@Arg2        = @registrationSID
				
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
				,@Arg2        = 'dbo.Registration'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationSID
			
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
				r.RoutineName = 'pRegistration'
		)
		begin
		
			exec @errorNo = ext.pRegistration
				 @Mode                             = 'update.post'
				,@RegistrationSID                  = @RegistrationSID
				,@RegistrantSID                    = @RegistrantSID
				,@PracticeRegisterSectionSID       = @PracticeRegisterSectionSID
				,@RegistrationNo                   = @RegistrationNo
				,@RegistrationYear                 = @RegistrationYear
				,@EffectiveTime                    = @EffectiveTime
				,@ExpiryTime                       = @ExpiryTime
				,@CardPrintedTime                  = @CardPrintedTime
				,@InvoiceSID                       = @InvoiceSID
				,@ReasonSID                        = @ReasonSID
				,@FormGUID                         = @FormGUID
				,@UserDefinedColumns               = @UserDefinedColumns
				,@RegistrationXID                  = @RegistrationXID
				,@LegacyKey                        = @LegacyKey
				,@UpdateUser                       = @UpdateUser
				,@RowStamp                         = @RowStamp
				,@IsReselected                     = @IsReselected
				,@IsNullApplied                    = @IsNullApplied
				,@zContext                         = @zContext
				,@PracticeRegisterSID              = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel     = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense             = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive  = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID   = @PracticeRegisterSectionRowGUID
				,@RegistrantPersonSID              = @RegistrantPersonSID
				,@RegistrantNo                     = @RegistrantNo
				,@YearOfInitialEmployment          = @YearOfInitialEmployment
				,@IsOnPublicRegistry               = @IsOnPublicRegistry
				,@CityNameOfBirth                  = @CityNameOfBirth
				,@CountrySID                       = @CountrySID
				,@DirectedAuditYearCompetence      = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours   = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear             = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked     = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime       = @RenewalExtensionExpiryTime
				,@ArchivedTime                     = @ArchivedTime
				,@RegistrantRowGUID                = @RegistrantRowGUID
				,@InvoicePersonSID                 = @InvoicePersonSID
				,@InvoiceDate                      = @InvoiceDate
				,@Tax1Label                        = @Tax1Label
				,@Tax1Rate                         = @Tax1Rate
				,@Tax1GLAccountCode                = @Tax1GLAccountCode
				,@Tax2Label                        = @Tax2Label
				,@Tax2Rate                         = @Tax2Rate
				,@Tax2GLAccountCode                = @Tax2GLAccountCode
				,@Tax3Label                        = @Tax3Label
				,@Tax3Rate                         = @Tax3Rate
				,@Tax3GLAccountCode                = @Tax3GLAccountCode
				,@InvoiceRegistrationYear          = @InvoiceRegistrationYear
				,@CancelledTime                    = @CancelledTime
				,@InvoiceReasonSID                 = @InvoiceReasonSID
				,@IsRefund                         = @IsRefund
				,@ComplaintSID                     = @ComplaintSID
				,@InvoiceRowGUID                   = @InvoiceRowGUID
				,@ReasonGroupSID                   = @ReasonGroupSID
				,@ReasonName                       = @ReasonName
				,@ReasonCode                       = @ReasonCode
				,@ReasonSequence                   = @ReasonSequence
				,@ToolTip                          = @ToolTip
				,@ReasonIsActive                   = @ReasonIsActive
				,@ReasonRowGUID                    = @ReasonRowGUID
				,@IsActive                         = @IsActive
				,@IsPending                        = @IsPending
				,@IsDeleteEnabled                  = @IsDeleteEnabled
				,@RegistrantLabel                  = @RegistrantLabel
				,@RegistrationYearLabel            = @RegistrationYearLabel
				,@PracticeRegisterName             = @PracticeRegisterName
				,@PracticeRegisterLabel            = @PracticeRegisterLabel
				,@RegistrationLabel                = @RegistrationLabel
				,@IsReadEnabled                    = @IsReadEnabled
				,@FirstName                        = @FirstName
				,@MiddleNames                      = @MiddleNames
				,@LastName                         = @LastName
				,@AddressBlockForPrint             = @AddressBlockForPrint
				,@AddressBlockForHTML              = @AddressBlockForHTML
				,@FutureRegistrationLabel          = @FutureRegistrationLabel
				,@FutureRegistrationYear           = @FutureRegistrationYear
				,@FuturePracticeRegisterSID        = @FuturePracticeRegisterSID
				,@FuturePracticeRegisterLabel      = @FuturePracticeRegisterLabel
				,@FuturePracticeRegisterSectionSID = @FuturePracticeRegisterSectionSID
				,@FutureRegisterSectionLabel       = @FutureRegisterSectionLabel
				,@FutureEffectiveTime              = @FutureEffectiveTime
				,@FutureExpiryTime                 = @FutureExpiryTime
				,@FutureCardPrintedTime            = @FutureCardPrintedTime
				,@FutureInvoiceSID                 = @FutureInvoiceSID
				,@FutureReasonSID                  = @FutureReasonSID
				,@FutureFormGUID                   = @FutureFormGUID
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationSID
			from
				dbo.vRegistration ent
			where
				ent.RegistrationSID = @RegistrationSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationSID
				,ent.RegistrantSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationNo
				,ent.RegistrationYear
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.CardPrintedTime
				,ent.InvoiceSID
				,ent.ReasonSID
				,ent.FormGUID
				,ent.UserDefinedColumns
				,ent.RegistrationXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PracticeRegisterSID
				,ent.PracticeRegisterSectionLabel
				,ent.PracticeRegisterSectionIsDefault
				,ent.IsDisplayedOnLicense
				,ent.PracticeRegisterSectionIsActive
				,ent.PracticeRegisterSectionRowGUID
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
				,ent.InvoiceRegistrationYear
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
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
				,ent.RegistrationYearLabel
				,ent.PracticeRegisterName
				,ent.PracticeRegisterLabel
				,ent.RegistrationLabel
				,ent.IsReadEnabled
				,ent.FirstName
				,ent.MiddleNames
				,ent.LastName
				,ent.AddressBlockForPrint
				,ent.AddressBlockForHTML
				,ent.FutureRegistrationLabel
				,ent.FutureRegistrationYear
				,ent.FuturePracticeRegisterSID
				,ent.FuturePracticeRegisterLabel
				,ent.FuturePracticeRegisterSectionSID
				,ent.FutureRegisterSectionLabel
				,ent.FutureEffectiveTime
				,ent.FutureExpiryTime
				,ent.FutureCardPrintedTime
				,ent.FutureInvoiceSID
				,ent.FutureReasonSID
				,ent.FutureFormGUID
			from
				dbo.vRegistration ent
			where
				ent.RegistrationSID = @RegistrationSID

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
