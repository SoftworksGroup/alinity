SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChange#Update]
	 @RegistrationChangeSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationSID                        int               = null -- table column values to update:
	,@PracticeRegisterSectionSID             int               = null
	,@RegistrationYear                       smallint          = null
	,@NextFollowUp                           date              = null
	,@RegistrationEffective                  date              = null
	,@ReservedRegistrantNo                   varchar(50)       = null
	,@ConfirmationDraft                      nvarchar(max)     = null
	,@ReasonSID                              int               = null
	,@InvoiceSID                             int               = null
	,@ComplaintSID                           int               = null
	,@UserDefinedColumns                     xml               = null
	,@RegistrationChangeXID                  varchar(150)      = null
	,@LegacyKey                              nvarchar(50)      = null
	,@UpdateUser                             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                           tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                          bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                               xml               = null -- other values defining context for the update (if any)
	,@PracticeRegisterSID                    int               = null -- not a base table column
	,@PracticeRegisterSectionLabel           nvarchar(35)      = null -- not a base table column
	,@PracticeRegisterSectionIsDefault       bit               = null -- not a base table column
	,@IsDisplayedOnLicense                   bit               = null -- not a base table column
	,@PracticeRegisterSectionIsActive        bit               = null -- not a base table column
	,@PracticeRegisterSectionRowGUID         uniqueidentifier  = null -- not a base table column
	,@RegistrationRegistrantSID              int               = null -- not a base table column
	,@RegistrationPracticeRegisterSectionSID int               = null -- not a base table column
	,@RegistrationNo                         nvarchar(50)      = null -- not a base table column
	,@RegistrationRegistrationYear           smallint          = null -- not a base table column
	,@EffectiveTime                          datetime          = null -- not a base table column
	,@ExpiryTime                             datetime          = null -- not a base table column
	,@CardPrintedTime                        datetime          = null -- not a base table column
	,@RegistrationInvoiceSID                 int               = null -- not a base table column
	,@RegistrationReasonSID                  int               = null -- not a base table column
	,@FormGUID                               uniqueidentifier  = null -- not a base table column
	,@RegistrationRowGUID                    uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                         int               = null -- not a base table column
	,@ReasonName                             nvarchar(50)      = null -- not a base table column
	,@ReasonCode                             varchar(25)       = null -- not a base table column
	,@ReasonSequence                         smallint          = null -- not a base table column
	,@ToolTip                                nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                         bit               = null -- not a base table column
	,@ReasonRowGUID                          uniqueidentifier  = null -- not a base table column
	,@ComplaintNo                            varchar(50)       = null -- not a base table column
	,@ComplaintRegistrantSID                 int               = null -- not a base table column
	,@ComplaintTypeSID                       int               = null -- not a base table column
	,@ComplainantTypeSID                     int               = null -- not a base table column
	,@ApplicationUserSID                     int               = null -- not a base table column
	,@OpenedDate                             date              = null -- not a base table column
	,@ConductStartDate                       date              = null -- not a base table column
	,@ConductEndDate                         date              = null -- not a base table column
	,@ComplaintSeveritySID                   int               = null -- not a base table column
	,@IsDisplayedOnPublicRegistry            bit               = null -- not a base table column
	,@ClosedDate                             date              = null -- not a base table column
	,@DismissedDate                          date              = null -- not a base table column
	,@ComplaintReasonSID                     int               = null -- not a base table column
	,@FileExtension                          varchar(5)        = null -- not a base table column
	,@ComplaintRowGUID                       uniqueidentifier  = null -- not a base table column
	,@PersonSID                              int               = null -- not a base table column
	,@InvoiceDate                            date              = null -- not a base table column
	,@Tax1Label                              nvarchar(8)       = null -- not a base table column
	,@Tax1Rate                               decimal(4,4)      = null -- not a base table column
	,@Tax1GLAccountCode                      varchar(50)       = null -- not a base table column
	,@Tax2Label                              nvarchar(8)       = null -- not a base table column
	,@Tax2Rate                               decimal(4,4)      = null -- not a base table column
	,@Tax2GLAccountCode                      varchar(50)       = null -- not a base table column
	,@Tax3Label                              nvarchar(8)       = null -- not a base table column
	,@Tax3Rate                               decimal(4,4)      = null -- not a base table column
	,@Tax3GLAccountCode                      varchar(50)       = null -- not a base table column
	,@InvoiceRegistrationYear                smallint          = null -- not a base table column
	,@CancelledTime                          datetimeoffset(7) = null -- not a base table column
	,@InvoiceReasonSID                       int               = null -- not a base table column
	,@IsRefund                               bit               = null -- not a base table column
	,@InvoiceComplaintSID                    int               = null -- not a base table column
	,@InvoiceRowGUID                         uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                        bit               = null -- not a base table column
	,@IsViewEnabled                          bit               = null -- not a base table column
	,@IsEditEnabled                          bit               = null -- not a base table column
	,@IsApproveEnabled                       bit               = null -- not a base table column
	,@IsRejectEnabled                        bit               = null -- not a base table column
	,@IsUnlockEnabled                        bit               = null -- not a base table column
	,@IsWithdrawalEnabled                    bit               = null -- not a base table column
	,@IsInProgress                           bit               = null -- not a base table column
	,@FormStatusSID                          int               = null -- not a base table column
	,@FormStatusSCD                          varchar(25)       = null -- not a base table column
	,@FormStatusLabel                        nvarchar(35)      = null -- not a base table column
	,@LastStatusChangeUser                   nvarchar(75)      = null -- not a base table column
	,@LastStatusChangeTime                   datetimeoffset(7) = null -- not a base table column
	,@FormOwnerSID                           int               = null -- not a base table column
	,@FormOwnerSCD                           varchar(25)       = null -- not a base table column
	,@FormOwnerLabel                         nvarchar(35)      = null -- not a base table column
	,@IsPDFDisplayed                         bit               = null -- not a base table column
	,@PersonDocSID                           int               = null -- not a base table column
	,@TotalDue                               decimal(11,2)     = null -- not a base table column
	,@IsUnPaid                               bit               = null -- not a base table column
	,@PersonMailingAddressSID                int               = null -- not a base table column
	,@PersonStreetAddress1                   nvarchar(75)      = null -- not a base table column
	,@PersonStreetAddress2                   nvarchar(75)      = null -- not a base table column
	,@PersonStreetAddress3                   nvarchar(75)      = null -- not a base table column
	,@PersonCityName                         nvarchar(30)      = null -- not a base table column
	,@PersonStateProvinceName                nvarchar(30)      = null -- not a base table column
	,@PersonPostalCode                       nvarchar(10)      = null -- not a base table column
	,@PersonCountryName                      nvarchar(50)      = null -- not a base table column
	,@PersonCitySID                          int               = null -- not a base table column
	,@RegistrantPersonSID                    int               = null -- not a base table column
	,@RegistrationYearLabel                  varchar(9)        = null -- not a base table column
	,@PracticeRegisterLabel                  nvarchar(35)      = null -- not a base table column
	,@PracticeRegisterName                   nvarchar(65)      = null -- not a base table column
	,@RegistrationChangeLabel                nvarchar(100)     = null -- not a base table column
	,@IsRegisterChange                       bit               = null -- not a base table column
	,@HasOpenAudit                           bit               = null -- not a base table column
	,@NewFormStatusSCD                       varchar(25)       = null -- not a base table column
	,@ReasonSIDOnApprove                     int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChange#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrationChange table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrationChange table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrationChange entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationChange procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationChangeCheck to test all rules.

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

		if @RegistrationChangeSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationChangeSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ReservedRegistrantNo = ltrim(rtrim(@ReservedRegistrantNo))
		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrationChangeXID = ltrim(rtrim(@RegistrationChangeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @FormStatusSCD = ltrim(rtrim(@FormStatusSCD))
		set @FormStatusLabel = ltrim(rtrim(@FormStatusLabel))
		set @LastStatusChangeUser = ltrim(rtrim(@LastStatusChangeUser))
		set @FormOwnerSCD = ltrim(rtrim(@FormOwnerSCD))
		set @FormOwnerLabel = ltrim(rtrim(@FormOwnerLabel))
		set @PersonStreetAddress1 = ltrim(rtrim(@PersonStreetAddress1))
		set @PersonStreetAddress2 = ltrim(rtrim(@PersonStreetAddress2))
		set @PersonStreetAddress3 = ltrim(rtrim(@PersonStreetAddress3))
		set @PersonCityName = ltrim(rtrim(@PersonCityName))
		set @PersonStateProvinceName = ltrim(rtrim(@PersonStateProvinceName))
		set @PersonPostalCode = ltrim(rtrim(@PersonPostalCode))
		set @PersonCountryName = ltrim(rtrim(@PersonCountryName))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @RegistrationChangeLabel = ltrim(rtrim(@RegistrationChangeLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ReservedRegistrantNo) = 0 set @ReservedRegistrantNo = null
		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrationChangeXID) = 0 set @RegistrationChangeXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@FormStatusSCD) = 0 set @FormStatusSCD = null
		if len(@FormStatusLabel) = 0 set @FormStatusLabel = null
		if len(@LastStatusChangeUser) = 0 set @LastStatusChangeUser = null
		if len(@FormOwnerSCD) = 0 set @FormOwnerSCD = null
		if len(@FormOwnerLabel) = 0 set @FormOwnerLabel = null
		if len(@PersonStreetAddress1) = 0 set @PersonStreetAddress1 = null
		if len(@PersonStreetAddress2) = 0 set @PersonStreetAddress2 = null
		if len(@PersonStreetAddress3) = 0 set @PersonStreetAddress3 = null
		if len(@PersonCityName) = 0 set @PersonCityName = null
		if len(@PersonStateProvinceName) = 0 set @PersonStateProvinceName = null
		if len(@PersonPostalCode) = 0 set @PersonPostalCode = null
		if len(@PersonCountryName) = 0 set @PersonCountryName = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@RegistrationChangeLabel) = 0 set @RegistrationChangeLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationSID                        = isnull(@RegistrationSID,rc.RegistrationSID)
				,@PracticeRegisterSectionSID             = isnull(@PracticeRegisterSectionSID,rc.PracticeRegisterSectionSID)
				,@RegistrationYear                       = isnull(@RegistrationYear,rc.RegistrationYear)
				,@NextFollowUp                           = isnull(@NextFollowUp,rc.NextFollowUp)
				,@RegistrationEffective                  = isnull(@RegistrationEffective,rc.RegistrationEffective)
				,@ReservedRegistrantNo                   = isnull(@ReservedRegistrantNo,rc.ReservedRegistrantNo)
				,@ConfirmationDraft                      = isnull(@ConfirmationDraft,rc.ConfirmationDraft)
				,@ReasonSID                              = isnull(@ReasonSID,rc.ReasonSID)
				,@InvoiceSID                             = isnull(@InvoiceSID,rc.InvoiceSID)
				,@ComplaintSID                           = isnull(@ComplaintSID,rc.ComplaintSID)
				,@UserDefinedColumns                     = isnull(@UserDefinedColumns,rc.UserDefinedColumns)
				,@RegistrationChangeXID                  = isnull(@RegistrationChangeXID,rc.RegistrationChangeXID)
				,@LegacyKey                              = isnull(@LegacyKey,rc.LegacyKey)
				,@UpdateUser                             = isnull(@UpdateUser,rc.UpdateUser)
				,@IsReselected                           = isnull(@IsReselected,rc.IsReselected)
				,@IsNullApplied                          = isnull(@IsNullApplied,rc.IsNullApplied)
				,@zContext                               = isnull(@zContext,rc.zContext)
				,@PracticeRegisterSID                    = isnull(@PracticeRegisterSID,rc.PracticeRegisterSID)
				,@PracticeRegisterSectionLabel           = isnull(@PracticeRegisterSectionLabel,rc.PracticeRegisterSectionLabel)
				,@PracticeRegisterSectionIsDefault       = isnull(@PracticeRegisterSectionIsDefault,rc.PracticeRegisterSectionIsDefault)
				,@IsDisplayedOnLicense                   = isnull(@IsDisplayedOnLicense,rc.IsDisplayedOnLicense)
				,@PracticeRegisterSectionIsActive        = isnull(@PracticeRegisterSectionIsActive,rc.PracticeRegisterSectionIsActive)
				,@PracticeRegisterSectionRowGUID         = isnull(@PracticeRegisterSectionRowGUID,rc.PracticeRegisterSectionRowGUID)
				,@RegistrationRegistrantSID              = isnull(@RegistrationRegistrantSID,rc.RegistrationRegistrantSID)
				,@RegistrationPracticeRegisterSectionSID = isnull(@RegistrationPracticeRegisterSectionSID,rc.RegistrationPracticeRegisterSectionSID)
				,@RegistrationNo                         = isnull(@RegistrationNo,rc.RegistrationNo)
				,@RegistrationRegistrationYear           = isnull(@RegistrationRegistrationYear,rc.RegistrationRegistrationYear)
				,@EffectiveTime                          = isnull(@EffectiveTime,rc.EffectiveTime)
				,@ExpiryTime                             = isnull(@ExpiryTime,rc.ExpiryTime)
				,@CardPrintedTime                        = isnull(@CardPrintedTime,rc.CardPrintedTime)
				,@RegistrationInvoiceSID                 = isnull(@RegistrationInvoiceSID,rc.RegistrationInvoiceSID)
				,@RegistrationReasonSID                  = isnull(@RegistrationReasonSID,rc.RegistrationReasonSID)
				,@FormGUID                               = isnull(@FormGUID,rc.FormGUID)
				,@RegistrationRowGUID                    = isnull(@RegistrationRowGUID,rc.RegistrationRowGUID)
				,@ReasonGroupSID                         = isnull(@ReasonGroupSID,rc.ReasonGroupSID)
				,@ReasonName                             = isnull(@ReasonName,rc.ReasonName)
				,@ReasonCode                             = isnull(@ReasonCode,rc.ReasonCode)
				,@ReasonSequence                         = isnull(@ReasonSequence,rc.ReasonSequence)
				,@ToolTip                                = isnull(@ToolTip,rc.ToolTip)
				,@ReasonIsActive                         = isnull(@ReasonIsActive,rc.ReasonIsActive)
				,@ReasonRowGUID                          = isnull(@ReasonRowGUID,rc.ReasonRowGUID)
				,@ComplaintNo                            = isnull(@ComplaintNo,rc.ComplaintNo)
				,@ComplaintRegistrantSID                 = isnull(@ComplaintRegistrantSID,rc.ComplaintRegistrantSID)
				,@ComplaintTypeSID                       = isnull(@ComplaintTypeSID,rc.ComplaintTypeSID)
				,@ComplainantTypeSID                     = isnull(@ComplainantTypeSID,rc.ComplainantTypeSID)
				,@ApplicationUserSID                     = isnull(@ApplicationUserSID,rc.ApplicationUserSID)
				,@OpenedDate                             = isnull(@OpenedDate,rc.OpenedDate)
				,@ConductStartDate                       = isnull(@ConductStartDate,rc.ConductStartDate)
				,@ConductEndDate                         = isnull(@ConductEndDate,rc.ConductEndDate)
				,@ComplaintSeveritySID                   = isnull(@ComplaintSeveritySID,rc.ComplaintSeveritySID)
				,@IsDisplayedOnPublicRegistry            = isnull(@IsDisplayedOnPublicRegistry,rc.IsDisplayedOnPublicRegistry)
				,@ClosedDate                             = isnull(@ClosedDate,rc.ClosedDate)
				,@DismissedDate                          = isnull(@DismissedDate,rc.DismissedDate)
				,@ComplaintReasonSID                     = isnull(@ComplaintReasonSID,rc.ComplaintReasonSID)
				,@FileExtension                          = isnull(@FileExtension,rc.FileExtension)
				,@ComplaintRowGUID                       = isnull(@ComplaintRowGUID,rc.ComplaintRowGUID)
				,@PersonSID                              = isnull(@PersonSID,rc.PersonSID)
				,@InvoiceDate                            = isnull(@InvoiceDate,rc.InvoiceDate)
				,@Tax1Label                              = isnull(@Tax1Label,rc.Tax1Label)
				,@Tax1Rate                               = isnull(@Tax1Rate,rc.Tax1Rate)
				,@Tax1GLAccountCode                      = isnull(@Tax1GLAccountCode,rc.Tax1GLAccountCode)
				,@Tax2Label                              = isnull(@Tax2Label,rc.Tax2Label)
				,@Tax2Rate                               = isnull(@Tax2Rate,rc.Tax2Rate)
				,@Tax2GLAccountCode                      = isnull(@Tax2GLAccountCode,rc.Tax2GLAccountCode)
				,@Tax3Label                              = isnull(@Tax3Label,rc.Tax3Label)
				,@Tax3Rate                               = isnull(@Tax3Rate,rc.Tax3Rate)
				,@Tax3GLAccountCode                      = isnull(@Tax3GLAccountCode,rc.Tax3GLAccountCode)
				,@InvoiceRegistrationYear                = isnull(@InvoiceRegistrationYear,rc.InvoiceRegistrationYear)
				,@CancelledTime                          = isnull(@CancelledTime,rc.CancelledTime)
				,@InvoiceReasonSID                       = isnull(@InvoiceReasonSID,rc.InvoiceReasonSID)
				,@IsRefund                               = isnull(@IsRefund,rc.IsRefund)
				,@InvoiceComplaintSID                    = isnull(@InvoiceComplaintSID,rc.InvoiceComplaintSID)
				,@InvoiceRowGUID                         = isnull(@InvoiceRowGUID,rc.InvoiceRowGUID)
				,@IsDeleteEnabled                        = isnull(@IsDeleteEnabled,rc.IsDeleteEnabled)
				,@IsViewEnabled                          = isnull(@IsViewEnabled,rc.IsViewEnabled)
				,@IsEditEnabled                          = isnull(@IsEditEnabled,rc.IsEditEnabled)
				,@IsApproveEnabled                       = isnull(@IsApproveEnabled,rc.IsApproveEnabled)
				,@IsRejectEnabled                        = isnull(@IsRejectEnabled,rc.IsRejectEnabled)
				,@IsUnlockEnabled                        = isnull(@IsUnlockEnabled,rc.IsUnlockEnabled)
				,@IsWithdrawalEnabled                    = isnull(@IsWithdrawalEnabled,rc.IsWithdrawalEnabled)
				,@IsInProgress                           = isnull(@IsInProgress,rc.IsInProgress)
				,@FormStatusSID                          = isnull(@FormStatusSID,rc.FormStatusSID)
				,@FormStatusSCD                          = isnull(@FormStatusSCD,rc.FormStatusSCD)
				,@FormStatusLabel                        = isnull(@FormStatusLabel,rc.FormStatusLabel)
				,@LastStatusChangeUser                   = isnull(@LastStatusChangeUser,rc.LastStatusChangeUser)
				,@LastStatusChangeTime                   = isnull(@LastStatusChangeTime,rc.LastStatusChangeTime)
				,@FormOwnerSID                           = isnull(@FormOwnerSID,rc.FormOwnerSID)
				,@FormOwnerSCD                           = isnull(@FormOwnerSCD,rc.FormOwnerSCD)
				,@FormOwnerLabel                         = isnull(@FormOwnerLabel,rc.FormOwnerLabel)
				,@IsPDFDisplayed                         = isnull(@IsPDFDisplayed,rc.IsPDFDisplayed)
				,@PersonDocSID                           = isnull(@PersonDocSID,rc.PersonDocSID)
				,@TotalDue                               = isnull(@TotalDue,rc.TotalDue)
				,@IsUnPaid                               = isnull(@IsUnPaid,rc.IsUnPaid)
				,@PersonMailingAddressSID                = isnull(@PersonMailingAddressSID,rc.PersonMailingAddressSID)
				,@PersonStreetAddress1                   = isnull(@PersonStreetAddress1,rc.PersonStreetAddress1)
				,@PersonStreetAddress2                   = isnull(@PersonStreetAddress2,rc.PersonStreetAddress2)
				,@PersonStreetAddress3                   = isnull(@PersonStreetAddress3,rc.PersonStreetAddress3)
				,@PersonCityName                         = isnull(@PersonCityName,rc.PersonCityName)
				,@PersonStateProvinceName                = isnull(@PersonStateProvinceName,rc.PersonStateProvinceName)
				,@PersonPostalCode                       = isnull(@PersonPostalCode,rc.PersonPostalCode)
				,@PersonCountryName                      = isnull(@PersonCountryName,rc.PersonCountryName)
				,@PersonCitySID                          = isnull(@PersonCitySID,rc.PersonCitySID)
				,@RegistrantPersonSID                    = isnull(@RegistrantPersonSID,rc.RegistrantPersonSID)
				,@RegistrationYearLabel                  = isnull(@RegistrationYearLabel,rc.RegistrationYearLabel)
				,@PracticeRegisterLabel                  = isnull(@PracticeRegisterLabel,rc.PracticeRegisterLabel)
				,@PracticeRegisterName                   = isnull(@PracticeRegisterName,rc.PracticeRegisterName)
				,@RegistrationChangeLabel                = isnull(@RegistrationChangeLabel,rc.RegistrationChangeLabel)
				,@IsRegisterChange                       = isnull(@IsRegisterChange,rc.IsRegisterChange)
				,@HasOpenAudit                           = isnull(@HasOpenAudit,rc.HasOpenAudit)
				,@NewFormStatusSCD                       = isnull(@NewFormStatusSCD,rc.NewFormStatusSCD)
				,@ReasonSIDOnApprove                     = isnull(@ReasonSIDOnApprove,rc.ReasonSIDOnApprove)
			from
				dbo.vRegistrationChange rc
			where
				rc.RegistrationChangeSID = @RegistrationChangeSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.PracticeRegisterSectionSID from dbo.RegistrationChange x where x.RegistrationChangeSID = @RegistrationChangeSID) <> @PracticeRegisterSectionSID
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
		
		if (select x.ReasonSID from dbo.RegistrationChange x where x.RegistrationChangeSID = @RegistrationChangeSID) <> @ReasonSID
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
				r.RoutineName = 'pRegistrationChange'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChange
				 @Mode                                   = 'update.pre'
				,@RegistrationChangeSID                  = @RegistrationChangeSID
				,@RegistrationSID                        = @RegistrationSID output
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID output
				,@RegistrationYear                       = @RegistrationYear output
				,@NextFollowUp                           = @NextFollowUp output
				,@RegistrationEffective                  = @RegistrationEffective output
				,@ReservedRegistrantNo                   = @ReservedRegistrantNo output
				,@ConfirmationDraft                      = @ConfirmationDraft output
				,@ReasonSID                              = @ReasonSID output
				,@InvoiceSID                             = @InvoiceSID output
				,@ComplaintSID                           = @ComplaintSID output
				,@UserDefinedColumns                     = @UserDefinedColumns output
				,@RegistrationChangeXID                  = @RegistrationChangeXID output
				,@LegacyKey                              = @LegacyKey output
				,@UpdateUser                             = @UpdateUser
				,@RowStamp                               = @RowStamp
				,@IsReselected                           = @IsReselected
				,@IsNullApplied                          = @IsNullApplied
				,@zContext                               = @zContext
				,@PracticeRegisterSID                    = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel           = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault       = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                   = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive        = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID         = @PracticeRegisterSectionRowGUID
				,@RegistrationRegistrantSID              = @RegistrationRegistrantSID
				,@RegistrationPracticeRegisterSectionSID = @RegistrationPracticeRegisterSectionSID
				,@RegistrationNo                         = @RegistrationNo
				,@RegistrationRegistrationYear           = @RegistrationRegistrationYear
				,@EffectiveTime                          = @EffectiveTime
				,@ExpiryTime                             = @ExpiryTime
				,@CardPrintedTime                        = @CardPrintedTime
				,@RegistrationInvoiceSID                 = @RegistrationInvoiceSID
				,@RegistrationReasonSID                  = @RegistrationReasonSID
				,@FormGUID                               = @FormGUID
				,@RegistrationRowGUID                    = @RegistrationRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
				,@ComplaintNo                            = @ComplaintNo
				,@ComplaintRegistrantSID                 = @ComplaintRegistrantSID
				,@ComplaintTypeSID                       = @ComplaintTypeSID
				,@ComplainantTypeSID                     = @ComplainantTypeSID
				,@ApplicationUserSID                     = @ApplicationUserSID
				,@OpenedDate                             = @OpenedDate
				,@ConductStartDate                       = @ConductStartDate
				,@ConductEndDate                         = @ConductEndDate
				,@ComplaintSeveritySID                   = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry            = @IsDisplayedOnPublicRegistry
				,@ClosedDate                             = @ClosedDate
				,@DismissedDate                          = @DismissedDate
				,@ComplaintReasonSID                     = @ComplaintReasonSID
				,@FileExtension                          = @FileExtension
				,@ComplaintRowGUID                       = @ComplaintRowGUID
				,@PersonSID                              = @PersonSID
				,@InvoiceDate                            = @InvoiceDate
				,@Tax1Label                              = @Tax1Label
				,@Tax1Rate                               = @Tax1Rate
				,@Tax1GLAccountCode                      = @Tax1GLAccountCode
				,@Tax2Label                              = @Tax2Label
				,@Tax2Rate                               = @Tax2Rate
				,@Tax2GLAccountCode                      = @Tax2GLAccountCode
				,@Tax3Label                              = @Tax3Label
				,@Tax3Rate                               = @Tax3Rate
				,@Tax3GLAccountCode                      = @Tax3GLAccountCode
				,@InvoiceRegistrationYear                = @InvoiceRegistrationYear
				,@CancelledTime                          = @CancelledTime
				,@InvoiceReasonSID                       = @InvoiceReasonSID
				,@IsRefund                               = @IsRefund
				,@InvoiceComplaintSID                    = @InvoiceComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@FormStatusSID                          = @FormStatusSID
				,@FormStatusSCD                          = @FormStatusSCD
				,@FormStatusLabel                        = @FormStatusLabel
				,@LastStatusChangeUser                   = @LastStatusChangeUser
				,@LastStatusChangeTime                   = @LastStatusChangeTime
				,@FormOwnerSID                           = @FormOwnerSID
				,@FormOwnerSCD                           = @FormOwnerSCD
				,@FormOwnerLabel                         = @FormOwnerLabel
				,@IsPDFDisplayed                         = @IsPDFDisplayed
				,@PersonDocSID                           = @PersonDocSID
				,@TotalDue                               = @TotalDue
				,@IsUnPaid                               = @IsUnPaid
				,@PersonMailingAddressSID                = @PersonMailingAddressSID
				,@PersonStreetAddress1                   = @PersonStreetAddress1
				,@PersonStreetAddress2                   = @PersonStreetAddress2
				,@PersonStreetAddress3                   = @PersonStreetAddress3
				,@PersonCityName                         = @PersonCityName
				,@PersonStateProvinceName                = @PersonStateProvinceName
				,@PersonPostalCode                       = @PersonPostalCode
				,@PersonCountryName                      = @PersonCountryName
				,@PersonCitySID                          = @PersonCitySID
				,@RegistrantPersonSID                    = @RegistrantPersonSID
				,@RegistrationYearLabel                  = @RegistrationYearLabel
				,@PracticeRegisterLabel                  = @PracticeRegisterLabel
				,@PracticeRegisterName                   = @PracticeRegisterName
				,@RegistrationChangeLabel                = @RegistrationChangeLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end

		-- update the record

		update
			dbo.RegistrationChange
		set
			 RegistrationSID = @RegistrationSID
			,PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			,RegistrationYear = @RegistrationYear
			,NextFollowUp = @NextFollowUp
			,RegistrationEffective = @RegistrationEffective
			,ReservedRegistrantNo = @ReservedRegistrantNo
			,ConfirmationDraft = @ConfirmationDraft
			,ReasonSID = @ReasonSID
			,InvoiceSID = @InvoiceSID
			,ComplaintSID = @ComplaintSID
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrationChangeXID = @RegistrationChangeXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationChangeSID = @RegistrationChangeSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationChange where RegistrationChangeSID = @registrationChangeSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationChange'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationChange'
					,@Arg2        = @registrationChangeSID
				
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
				,@Arg2        = 'dbo.RegistrationChange'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationChangeSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Apr 2018
		-- Call the subroutine to save any changes in status and call
		-- subroutines to process the status change were required. If
		-- saving in place (Save and Continue) pass @NewFormStatusSCD as NULL

		if @NewFormStatusSCD is not null
		begin

			exec dbo.pRegistrationChange#Update$Status
				@RegistrationChangeSID = @RegistrationChangeSID
			 ,@NewFormStatusSCD = @NewFormStatusSCD
			 ,@InvoiceSID = @InvoiceSID;

		end;

		if @NewFormStatusSCD = 'WITHDRAWN' and @InvoiceSID is not null
		begin

			exec dbo.pRegistrationChange#Withdraw
				@RegistrationChangeSID = @RegistrationChangeSID

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
				r.RoutineName = 'pRegistrationChange'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChange
				 @Mode                                   = 'update.post'
				,@RegistrationChangeSID                  = @RegistrationChangeSID
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@NextFollowUp                           = @NextFollowUp
				,@RegistrationEffective                  = @RegistrationEffective
				,@ReservedRegistrantNo                   = @ReservedRegistrantNo
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ComplaintSID                           = @ComplaintSID
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@RegistrationChangeXID                  = @RegistrationChangeXID
				,@LegacyKey                              = @LegacyKey
				,@UpdateUser                             = @UpdateUser
				,@RowStamp                               = @RowStamp
				,@IsReselected                           = @IsReselected
				,@IsNullApplied                          = @IsNullApplied
				,@zContext                               = @zContext
				,@PracticeRegisterSID                    = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel           = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault       = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                   = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive        = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID         = @PracticeRegisterSectionRowGUID
				,@RegistrationRegistrantSID              = @RegistrationRegistrantSID
				,@RegistrationPracticeRegisterSectionSID = @RegistrationPracticeRegisterSectionSID
				,@RegistrationNo                         = @RegistrationNo
				,@RegistrationRegistrationYear           = @RegistrationRegistrationYear
				,@EffectiveTime                          = @EffectiveTime
				,@ExpiryTime                             = @ExpiryTime
				,@CardPrintedTime                        = @CardPrintedTime
				,@RegistrationInvoiceSID                 = @RegistrationInvoiceSID
				,@RegistrationReasonSID                  = @RegistrationReasonSID
				,@FormGUID                               = @FormGUID
				,@RegistrationRowGUID                    = @RegistrationRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
				,@ComplaintNo                            = @ComplaintNo
				,@ComplaintRegistrantSID                 = @ComplaintRegistrantSID
				,@ComplaintTypeSID                       = @ComplaintTypeSID
				,@ComplainantTypeSID                     = @ComplainantTypeSID
				,@ApplicationUserSID                     = @ApplicationUserSID
				,@OpenedDate                             = @OpenedDate
				,@ConductStartDate                       = @ConductStartDate
				,@ConductEndDate                         = @ConductEndDate
				,@ComplaintSeveritySID                   = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry            = @IsDisplayedOnPublicRegistry
				,@ClosedDate                             = @ClosedDate
				,@DismissedDate                          = @DismissedDate
				,@ComplaintReasonSID                     = @ComplaintReasonSID
				,@FileExtension                          = @FileExtension
				,@ComplaintRowGUID                       = @ComplaintRowGUID
				,@PersonSID                              = @PersonSID
				,@InvoiceDate                            = @InvoiceDate
				,@Tax1Label                              = @Tax1Label
				,@Tax1Rate                               = @Tax1Rate
				,@Tax1GLAccountCode                      = @Tax1GLAccountCode
				,@Tax2Label                              = @Tax2Label
				,@Tax2Rate                               = @Tax2Rate
				,@Tax2GLAccountCode                      = @Tax2GLAccountCode
				,@Tax3Label                              = @Tax3Label
				,@Tax3Rate                               = @Tax3Rate
				,@Tax3GLAccountCode                      = @Tax3GLAccountCode
				,@InvoiceRegistrationYear                = @InvoiceRegistrationYear
				,@CancelledTime                          = @CancelledTime
				,@InvoiceReasonSID                       = @InvoiceReasonSID
				,@IsRefund                               = @IsRefund
				,@InvoiceComplaintSID                    = @InvoiceComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@FormStatusSID                          = @FormStatusSID
				,@FormStatusSCD                          = @FormStatusSCD
				,@FormStatusLabel                        = @FormStatusLabel
				,@LastStatusChangeUser                   = @LastStatusChangeUser
				,@LastStatusChangeTime                   = @LastStatusChangeTime
				,@FormOwnerSID                           = @FormOwnerSID
				,@FormOwnerSCD                           = @FormOwnerSCD
				,@FormOwnerLabel                         = @FormOwnerLabel
				,@IsPDFDisplayed                         = @IsPDFDisplayed
				,@PersonDocSID                           = @PersonDocSID
				,@TotalDue                               = @TotalDue
				,@IsUnPaid                               = @IsUnPaid
				,@PersonMailingAddressSID                = @PersonMailingAddressSID
				,@PersonStreetAddress1                   = @PersonStreetAddress1
				,@PersonStreetAddress2                   = @PersonStreetAddress2
				,@PersonStreetAddress3                   = @PersonStreetAddress3
				,@PersonCityName                         = @PersonCityName
				,@PersonStateProvinceName                = @PersonStateProvinceName
				,@PersonPostalCode                       = @PersonPostalCode
				,@PersonCountryName                      = @PersonCountryName
				,@PersonCitySID                          = @PersonCitySID
				,@RegistrantPersonSID                    = @RegistrantPersonSID
				,@RegistrationYearLabel                  = @RegistrationYearLabel
				,@PracticeRegisterLabel                  = @PracticeRegisterLabel
				,@PracticeRegisterName                   = @PracticeRegisterName
				,@RegistrationChangeLabel                = @RegistrationChangeLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationChangeSID
			from
				dbo.vRegistrationChange ent
			where
				ent.RegistrationChangeSID = @RegistrationChangeSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationChangeSID
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.NextFollowUp
				,ent.RegistrationEffective
				,ent.ReservedRegistrantNo
				,ent.ConfirmationDraft
				,ent.ReasonSID
				,ent.InvoiceSID
				,ent.ComplaintSID
				,ent.UserDefinedColumns
				,ent.RegistrationChangeXID
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
				,ent.RegistrationRegistrantSID
				,ent.RegistrationPracticeRegisterSectionSID
				,ent.RegistrationNo
				,ent.RegistrationRegistrationYear
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.CardPrintedTime
				,ent.RegistrationInvoiceSID
				,ent.RegistrationReasonSID
				,ent.FormGUID
				,ent.RegistrationRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.ComplaintNo
				,ent.ComplaintRegistrantSID
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
				,ent.InvoiceRegistrationYear
				,ent.CancelledTime
				,ent.InvoiceReasonSID
				,ent.IsRefund
				,ent.InvoiceComplaintSID
				,ent.InvoiceRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsApproveEnabled
				,ent.IsRejectEnabled
				,ent.IsUnlockEnabled
				,ent.IsWithdrawalEnabled
				,ent.IsInProgress
				,ent.FormStatusSID
				,ent.FormStatusSCD
				,ent.FormStatusLabel
				,ent.LastStatusChangeUser
				,ent.LastStatusChangeTime
				,ent.FormOwnerSID
				,ent.FormOwnerSCD
				,ent.FormOwnerLabel
				,ent.IsPDFDisplayed
				,ent.PersonDocSID
				,ent.TotalDue
				,ent.IsUnPaid
				,ent.PersonMailingAddressSID
				,ent.PersonStreetAddress1
				,ent.PersonStreetAddress2
				,ent.PersonStreetAddress3
				,ent.PersonCityName
				,ent.PersonStateProvinceName
				,ent.PersonPostalCode
				,ent.PersonCountryName
				,ent.PersonCitySID
				,ent.RegistrantPersonSID
				,ent.RegistrationYearLabel
				,ent.PracticeRegisterLabel
				,ent.PracticeRegisterName
				,ent.RegistrationChangeLabel
				,ent.IsRegisterChange
				,ent.HasOpenAudit
				,ent.NewFormStatusSCD
				,ent.ReasonSIDOnApprove
			from
				dbo.vRegistrationChange ent
			where
				ent.RegistrationChangeSID = @RegistrationChangeSID

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
