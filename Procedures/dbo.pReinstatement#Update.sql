SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pReinstatement#Update]
	 @ReinstatementSID                       int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationSID                        int               = null -- table column values to update:
	,@PracticeRegisterSectionSID             int               = null
	,@RegistrationYear                       int               = null
	,@FormVersionSID                         int               = null
	,@FormResponseDraft                      xml               = null
	,@LastValidateTime                       datetimeoffset(7) = null
	,@AdminComments                          xml               = null
	,@NextFollowUp                           date              = null
	,@RegistrationEffective                  date              = null
	,@ConfirmationDraft                      nvarchar(max)     = null
	,@IsAutoApprovalEnabled                  bit               = null
	,@ReasonSID                              int               = null
	,@InvoiceSID                             int               = null
	,@ReviewReasonList                       xml               = null
	,@UserDefinedColumns                     xml               = null
	,@ReinstatementXID                       varchar(150)      = null
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
	,@RegistrantSID                          int               = null -- not a base table column
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
	,@FormSID                                int               = null -- not a base table column
	,@VersionNo                              smallint          = null -- not a base table column
	,@RevisionNo                             smallint          = null -- not a base table column
	,@IsSaveDisplayed                        bit               = null -- not a base table column
	,@ApprovedTime                           datetimeoffset(7) = null -- not a base table column
	,@FormVersionRowGUID                     uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                         int               = null -- not a base table column
	,@ReasonName                             nvarchar(50)      = null -- not a base table column
	,@ReasonCode                             varchar(25)       = null -- not a base table column
	,@ReasonSequence                         smallint          = null -- not a base table column
	,@ToolTip                                nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                         bit               = null -- not a base table column
	,@ReasonRowGUID                          uniqueidentifier  = null -- not a base table column
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
	,@ComplaintSID                           int               = null -- not a base table column
	,@InvoiceRowGUID                         uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                        bit               = null -- not a base table column
	,@IsViewEnabled                          bit               = null -- not a base table column
	,@IsEditEnabled                          bit               = null -- not a base table column
	,@IsSaveBtnDisplayed                     bit               = null -- not a base table column
	,@IsApproveEnabled                       bit               = null -- not a base table column
	,@IsRejectEnabled                        bit               = null -- not a base table column
	,@IsUnlockEnabled                        bit               = null -- not a base table column
	,@IsWithdrawalEnabled                    bit               = null -- not a base table column
	,@IsInProgress                           bit               = null -- not a base table column
	,@IsReviewRequired                       bit               = null -- not a base table column
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
	,@ReinstatementLabel                     nvarchar(80)      = null -- not a base table column
	,@IsRegisterChange                       bit               = null -- not a base table column
	,@HasOpenAudit                           bit               = null -- not a base table column
	,@IsReinstatementOpen                    bit               = null -- not a base table column
	,@NewFormStatusSCD                       varchar(25)       = null -- not a base table column
	,@ReasonSIDOnApprove                     int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pReinstatement#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Reinstatement table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Reinstatement table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vReinstatement entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pReinstatement procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fReinstatementCheck to test all rules.

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

		if @ReinstatementSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ReinstatementSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @ReinstatementXID = ltrim(rtrim(@ReinstatementXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
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
		set @ReinstatementLabel = ltrim(rtrim(@ReinstatementLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@ReinstatementXID) = 0 set @ReinstatementXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
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
		if len(@ReinstatementLabel) = 0 set @ReinstatementLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationSID                        = isnull(@RegistrationSID,rin.RegistrationSID)
				,@PracticeRegisterSectionSID             = isnull(@PracticeRegisterSectionSID,rin.PracticeRegisterSectionSID)
				,@RegistrationYear                       = isnull(@RegistrationYear,rin.RegistrationYear)
				,@FormVersionSID                         = isnull(@FormVersionSID,rin.FormVersionSID)
				,@FormResponseDraft                      = isnull(@FormResponseDraft,rin.FormResponseDraft)
				,@LastValidateTime                       = isnull(@LastValidateTime,rin.LastValidateTime)
				,@AdminComments                          = isnull(@AdminComments,rin.AdminComments)
				,@NextFollowUp                           = isnull(@NextFollowUp,rin.NextFollowUp)
				,@RegistrationEffective                  = isnull(@RegistrationEffective,rin.RegistrationEffective)
				,@ConfirmationDraft                      = isnull(@ConfirmationDraft,rin.ConfirmationDraft)
				,@IsAutoApprovalEnabled                  = isnull(@IsAutoApprovalEnabled,rin.IsAutoApprovalEnabled)
				,@ReasonSID                              = isnull(@ReasonSID,rin.ReasonSID)
				,@InvoiceSID                             = isnull(@InvoiceSID,rin.InvoiceSID)
				,@ReviewReasonList                       = isnull(@ReviewReasonList,rin.ReviewReasonList)
				,@UserDefinedColumns                     = isnull(@UserDefinedColumns,rin.UserDefinedColumns)
				,@ReinstatementXID                       = isnull(@ReinstatementXID,rin.ReinstatementXID)
				,@LegacyKey                              = isnull(@LegacyKey,rin.LegacyKey)
				,@UpdateUser                             = isnull(@UpdateUser,rin.UpdateUser)
				,@IsReselected                           = isnull(@IsReselected,rin.IsReselected)
				,@IsNullApplied                          = isnull(@IsNullApplied,rin.IsNullApplied)
				,@zContext                               = isnull(@zContext,rin.zContext)
				,@PracticeRegisterSID                    = isnull(@PracticeRegisterSID,rin.PracticeRegisterSID)
				,@PracticeRegisterSectionLabel           = isnull(@PracticeRegisterSectionLabel,rin.PracticeRegisterSectionLabel)
				,@PracticeRegisterSectionIsDefault       = isnull(@PracticeRegisterSectionIsDefault,rin.PracticeRegisterSectionIsDefault)
				,@IsDisplayedOnLicense                   = isnull(@IsDisplayedOnLicense,rin.IsDisplayedOnLicense)
				,@PracticeRegisterSectionIsActive        = isnull(@PracticeRegisterSectionIsActive,rin.PracticeRegisterSectionIsActive)
				,@PracticeRegisterSectionRowGUID         = isnull(@PracticeRegisterSectionRowGUID,rin.PracticeRegisterSectionRowGUID)
				,@RegistrantSID                          = isnull(@RegistrantSID,rin.RegistrantSID)
				,@RegistrationPracticeRegisterSectionSID = isnull(@RegistrationPracticeRegisterSectionSID,rin.RegistrationPracticeRegisterSectionSID)
				,@RegistrationNo                         = isnull(@RegistrationNo,rin.RegistrationNo)
				,@RegistrationRegistrationYear           = isnull(@RegistrationRegistrationYear,rin.RegistrationRegistrationYear)
				,@EffectiveTime                          = isnull(@EffectiveTime,rin.EffectiveTime)
				,@ExpiryTime                             = isnull(@ExpiryTime,rin.ExpiryTime)
				,@CardPrintedTime                        = isnull(@CardPrintedTime,rin.CardPrintedTime)
				,@RegistrationInvoiceSID                 = isnull(@RegistrationInvoiceSID,rin.RegistrationInvoiceSID)
				,@RegistrationReasonSID                  = isnull(@RegistrationReasonSID,rin.RegistrationReasonSID)
				,@FormGUID                               = isnull(@FormGUID,rin.FormGUID)
				,@RegistrationRowGUID                    = isnull(@RegistrationRowGUID,rin.RegistrationRowGUID)
				,@FormSID                                = isnull(@FormSID,rin.FormSID)
				,@VersionNo                              = isnull(@VersionNo,rin.VersionNo)
				,@RevisionNo                             = isnull(@RevisionNo,rin.RevisionNo)
				,@IsSaveDisplayed                        = isnull(@IsSaveDisplayed,rin.IsSaveDisplayed)
				,@ApprovedTime                           = isnull(@ApprovedTime,rin.ApprovedTime)
				,@FormVersionRowGUID                     = isnull(@FormVersionRowGUID,rin.FormVersionRowGUID)
				,@ReasonGroupSID                         = isnull(@ReasonGroupSID,rin.ReasonGroupSID)
				,@ReasonName                             = isnull(@ReasonName,rin.ReasonName)
				,@ReasonCode                             = isnull(@ReasonCode,rin.ReasonCode)
				,@ReasonSequence                         = isnull(@ReasonSequence,rin.ReasonSequence)
				,@ToolTip                                = isnull(@ToolTip,rin.ToolTip)
				,@ReasonIsActive                         = isnull(@ReasonIsActive,rin.ReasonIsActive)
				,@ReasonRowGUID                          = isnull(@ReasonRowGUID,rin.ReasonRowGUID)
				,@PersonSID                              = isnull(@PersonSID,rin.PersonSID)
				,@InvoiceDate                            = isnull(@InvoiceDate,rin.InvoiceDate)
				,@Tax1Label                              = isnull(@Tax1Label,rin.Tax1Label)
				,@Tax1Rate                               = isnull(@Tax1Rate,rin.Tax1Rate)
				,@Tax1GLAccountCode                      = isnull(@Tax1GLAccountCode,rin.Tax1GLAccountCode)
				,@Tax2Label                              = isnull(@Tax2Label,rin.Tax2Label)
				,@Tax2Rate                               = isnull(@Tax2Rate,rin.Tax2Rate)
				,@Tax2GLAccountCode                      = isnull(@Tax2GLAccountCode,rin.Tax2GLAccountCode)
				,@Tax3Label                              = isnull(@Tax3Label,rin.Tax3Label)
				,@Tax3Rate                               = isnull(@Tax3Rate,rin.Tax3Rate)
				,@Tax3GLAccountCode                      = isnull(@Tax3GLAccountCode,rin.Tax3GLAccountCode)
				,@InvoiceRegistrationYear                = isnull(@InvoiceRegistrationYear,rin.InvoiceRegistrationYear)
				,@CancelledTime                          = isnull(@CancelledTime,rin.CancelledTime)
				,@InvoiceReasonSID                       = isnull(@InvoiceReasonSID,rin.InvoiceReasonSID)
				,@IsRefund                               = isnull(@IsRefund,rin.IsRefund)
				,@ComplaintSID                           = isnull(@ComplaintSID,rin.ComplaintSID)
				,@InvoiceRowGUID                         = isnull(@InvoiceRowGUID,rin.InvoiceRowGUID)
				,@IsDeleteEnabled                        = isnull(@IsDeleteEnabled,rin.IsDeleteEnabled)
				,@IsViewEnabled                          = isnull(@IsViewEnabled,rin.IsViewEnabled)
				,@IsEditEnabled                          = isnull(@IsEditEnabled,rin.IsEditEnabled)
				,@IsSaveBtnDisplayed                     = isnull(@IsSaveBtnDisplayed,rin.IsSaveBtnDisplayed)
				,@IsApproveEnabled                       = isnull(@IsApproveEnabled,rin.IsApproveEnabled)
				,@IsRejectEnabled                        = isnull(@IsRejectEnabled,rin.IsRejectEnabled)
				,@IsUnlockEnabled                        = isnull(@IsUnlockEnabled,rin.IsUnlockEnabled)
				,@IsWithdrawalEnabled                    = isnull(@IsWithdrawalEnabled,rin.IsWithdrawalEnabled)
				,@IsInProgress                           = isnull(@IsInProgress,rin.IsInProgress)
				,@IsReviewRequired                       = isnull(@IsReviewRequired,rin.IsReviewRequired)
				,@FormStatusSID                          = isnull(@FormStatusSID,rin.FormStatusSID)
				,@FormStatusSCD                          = isnull(@FormStatusSCD,rin.FormStatusSCD)
				,@FormStatusLabel                        = isnull(@FormStatusLabel,rin.FormStatusLabel)
				,@LastStatusChangeUser                   = isnull(@LastStatusChangeUser,rin.LastStatusChangeUser)
				,@LastStatusChangeTime                   = isnull(@LastStatusChangeTime,rin.LastStatusChangeTime)
				,@FormOwnerSID                           = isnull(@FormOwnerSID,rin.FormOwnerSID)
				,@FormOwnerSCD                           = isnull(@FormOwnerSCD,rin.FormOwnerSCD)
				,@FormOwnerLabel                         = isnull(@FormOwnerLabel,rin.FormOwnerLabel)
				,@IsPDFDisplayed                         = isnull(@IsPDFDisplayed,rin.IsPDFDisplayed)
				,@PersonDocSID                           = isnull(@PersonDocSID,rin.PersonDocSID)
				,@TotalDue                               = isnull(@TotalDue,rin.TotalDue)
				,@IsUnPaid                               = isnull(@IsUnPaid,rin.IsUnPaid)
				,@PersonMailingAddressSID                = isnull(@PersonMailingAddressSID,rin.PersonMailingAddressSID)
				,@PersonStreetAddress1                   = isnull(@PersonStreetAddress1,rin.PersonStreetAddress1)
				,@PersonStreetAddress2                   = isnull(@PersonStreetAddress2,rin.PersonStreetAddress2)
				,@PersonStreetAddress3                   = isnull(@PersonStreetAddress3,rin.PersonStreetAddress3)
				,@PersonCityName                         = isnull(@PersonCityName,rin.PersonCityName)
				,@PersonStateProvinceName                = isnull(@PersonStateProvinceName,rin.PersonStateProvinceName)
				,@PersonPostalCode                       = isnull(@PersonPostalCode,rin.PersonPostalCode)
				,@PersonCountryName                      = isnull(@PersonCountryName,rin.PersonCountryName)
				,@PersonCitySID                          = isnull(@PersonCitySID,rin.PersonCitySID)
				,@RegistrantPersonSID                    = isnull(@RegistrantPersonSID,rin.RegistrantPersonSID)
				,@RegistrationYearLabel                  = isnull(@RegistrationYearLabel,rin.RegistrationYearLabel)
				,@PracticeRegisterLabel                  = isnull(@PracticeRegisterLabel,rin.PracticeRegisterLabel)
				,@PracticeRegisterName                   = isnull(@PracticeRegisterName,rin.PracticeRegisterName)
				,@ReinstatementLabel                     = isnull(@ReinstatementLabel,rin.ReinstatementLabel)
				,@IsRegisterChange                       = isnull(@IsRegisterChange,rin.IsRegisterChange)
				,@HasOpenAudit                           = isnull(@HasOpenAudit,rin.HasOpenAudit)
				,@IsReinstatementOpen                    = isnull(@IsReinstatementOpen,rin.IsReinstatementOpen)
				,@NewFormStatusSCD                       = isnull(@NewFormStatusSCD,rin.NewFormStatusSCD)
				,@ReasonSIDOnApprove                     = isnull(@ReasonSIDOnApprove,rin.ReasonSIDOnApprove)
			from
				dbo.vReinstatement rin
			where
				rin.ReinstatementSID = @ReinstatementSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.PracticeRegisterSectionSID from dbo.Reinstatement x where x.ReinstatementSID = @ReinstatementSID) <> @PracticeRegisterSectionSID
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
		
		if (select x.ReasonSID from dbo.Reinstatement x where x.ReinstatementSID = @ReinstatementSID) <> @ReasonSID
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
		-- Tim Edlund | Jan 2019
		-- Set the last validated time on statuses that executed the checks but
		-- clear it when the form is being RETURNED or where no status is set
		-- in which case the form is only being saved in place

		if @NewFormStatusSCD in ('VALIDATED', 'SUBMITTED', 'APPROVED')
		begin
			set @LastValidateTime = sysdatetimeoffset()
		end
		else if @NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD is null
		begin
			set @LastValidateTime = null
		end

		if @LastValidateTime is null -- where validation is cleared on parent, clear on child forms
		begin

			update
				child
			set
				child.LastValidateTime = null
			 ,child.UpdateTime = sysdatetimeoffset()
			 ,child.UpdateUser = @UpdateUser
			from
				dbo.Reinstatement parent
			join
				dbo.ProfileUpdate			child on parent.RowGUID = child.ParentRowGUID -- PROFILE-UPDATE
			where
				parent.ReinstatementSID = @ReinstatementSID and child.LastValidateTime is not null;

			update
				child
			set
				child.LastValidateTime = null
			 ,child.UpdateTime = sysdatetimeoffset()
			 ,child.UpdateUser = @UpdateUser
			from
				dbo.Reinstatement			 parent
			join
				dbo.RegistrantLearningPlan child on parent.RowGUID = child.ParentRowGUID	-- LEARNING-PLAN
			where
				parent.ReinstatementSID = @ReinstatementSID and child.LastValidateTime is not null;

		end;

		-- Tim Edlund | Oct 2018
		-- If the form is not withdrawn and the reason list
		-- is blank where an individual reason key exists,
		-- the put the value in the XML document (for UI display)

		if @NewFormStatusSCD <> 'WITHDRAWN' and @ReviewReasonList is null and @ReasonSID is not null --and @FormStatusSCD <> 'WITHDRAWN'
		begin
			set @ReviewReasonList = cast(N'<Reasons><Reason SID="' + ltrim(@ReasonSID) + '"/></Reasons>' as xml)
		end
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
				r.RoutineName = 'pReinstatement'
		)
		begin
		
			exec @errorNo = ext.pReinstatement
				 @Mode                                   = 'update.pre'
				,@ReinstatementSID                       = @ReinstatementSID
				,@RegistrationSID                        = @RegistrationSID output
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID output
				,@RegistrationYear                       = @RegistrationYear output
				,@FormVersionSID                         = @FormVersionSID output
				,@FormResponseDraft                      = @FormResponseDraft output
				,@LastValidateTime                       = @LastValidateTime output
				,@AdminComments                          = @AdminComments output
				,@NextFollowUp                           = @NextFollowUp output
				,@RegistrationEffective                  = @RegistrationEffective output
				,@ConfirmationDraft                      = @ConfirmationDraft output
				,@IsAutoApprovalEnabled                  = @IsAutoApprovalEnabled output
				,@ReasonSID                              = @ReasonSID output
				,@InvoiceSID                             = @InvoiceSID output
				,@ReviewReasonList                       = @ReviewReasonList output
				,@UserDefinedColumns                     = @UserDefinedColumns output
				,@ReinstatementXID                       = @ReinstatementXID output
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
				,@RegistrantSID                          = @RegistrantSID
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
				,@FormSID                                = @FormSID
				,@VersionNo                              = @VersionNo
				,@RevisionNo                             = @RevisionNo
				,@IsSaveDisplayed                        = @IsSaveDisplayed
				,@ApprovedTime                           = @ApprovedTime
				,@FormVersionRowGUID                     = @FormVersionRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
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
				,@ComplaintSID                           = @ComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsSaveBtnDisplayed                     = @IsSaveBtnDisplayed
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@IsReviewRequired                       = @IsReviewRequired
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
				,@ReinstatementLabel                     = @ReinstatementLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@IsReinstatementOpen                    = @IsReinstatementOpen
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end

		-- update the record

		update
			dbo.Reinstatement
		set
			 RegistrationSID = @RegistrationSID
			,PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			,RegistrationYear = @RegistrationYear
			,FormVersionSID = @FormVersionSID
			,FormResponseDraft = @FormResponseDraft
			,LastValidateTime = @LastValidateTime
			,AdminComments = @AdminComments
			,NextFollowUp = @NextFollowUp
			,RegistrationEffective = @RegistrationEffective
			,ConfirmationDraft = @ConfirmationDraft
			,IsAutoApprovalEnabled = @IsAutoApprovalEnabled
			,ReasonSID = @ReasonSID
			,InvoiceSID = @InvoiceSID
			,ReviewReasonList = @ReviewReasonList
			,UserDefinedColumns = @UserDefinedColumns
			,ReinstatementXID = @ReinstatementXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ReinstatementSID = @ReinstatementSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Reinstatement where ReinstatementSID = @reinstatementSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Reinstatement'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Reinstatement'
					,@Arg2        = @reinstatementSID
				
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
				,@Arg2        = 'dbo.Reinstatement'
				,@Arg3        = @rowsAffected
				,@Arg4        = @reinstatementSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Sep 2018
		-- VALIDATED status saved the record with the LastValidateTime updated
		-- but should not change underlying status - set back to NULL to
		-- avoid inserting new status record

		if @NewFormStatusSCD = 'VALIDATED'
		begin
			set @NewFormStatusSCD = null
		end

		-- Tim Edlund | Apr 2018
		-- Call the subroutine to save any changes in status along with
		-- the current version of the form content. Note - if saving
		-- in place (Save and Continue) pass @NewFormStatusSCD as NULL

		if @NewFormStatusSCD is not null
		begin

			exec dbo.pReinstatement#Update$Status
				@ReinstatementSID = @ReinstatementSID
			 ,@NewFormStatusSCD = @NewFormStatusSCD
			 ,@FormResponseDraft = @FormResponseDraft
			 ,@FormOwnerSID = @FormOwnerSID
			 ,@InvoiceSID = @InvoiceSID;

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
				r.RoutineName = 'pReinstatement'
		)
		begin
		
			exec @errorNo = ext.pReinstatement
				 @Mode                                   = 'update.post'
				,@ReinstatementSID                       = @ReinstatementSID
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@FormVersionSID                         = @FormVersionSID
				,@FormResponseDraft                      = @FormResponseDraft
				,@LastValidateTime                       = @LastValidateTime
				,@AdminComments                          = @AdminComments
				,@NextFollowUp                           = @NextFollowUp
				,@RegistrationEffective                  = @RegistrationEffective
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@IsAutoApprovalEnabled                  = @IsAutoApprovalEnabled
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ReviewReasonList                       = @ReviewReasonList
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@ReinstatementXID                       = @ReinstatementXID
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
				,@RegistrantSID                          = @RegistrantSID
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
				,@FormSID                                = @FormSID
				,@VersionNo                              = @VersionNo
				,@RevisionNo                             = @RevisionNo
				,@IsSaveDisplayed                        = @IsSaveDisplayed
				,@ApprovedTime                           = @ApprovedTime
				,@FormVersionRowGUID                     = @FormVersionRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
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
				,@ComplaintSID                           = @ComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsSaveBtnDisplayed                     = @IsSaveBtnDisplayed
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@IsReviewRequired                       = @IsReviewRequired
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
				,@ReinstatementLabel                     = @ReinstatementLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@IsReinstatementOpen                    = @IsReinstatementOpen
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ReinstatementSID
			from
				dbo.vReinstatement ent
			where
				ent.ReinstatementSID = @ReinstatementSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ReinstatementSID
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.FormVersionSID
				,ent.FormResponseDraft
				,ent.LastValidateTime
				,ent.AdminComments
				,ent.NextFollowUp
				,ent.RegistrationEffective
				,ent.ConfirmationDraft
				,ent.IsAutoApprovalEnabled
				,ent.ReasonSID
				,ent.InvoiceSID
				,ent.ReviewReasonList
				,ent.UserDefinedColumns
				,ent.ReinstatementXID
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
				,ent.RegistrantSID
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
				,ent.FormSID
				,ent.VersionNo
				,ent.RevisionNo
				,ent.IsSaveDisplayed
				,ent.ApprovedTime
				,ent.FormVersionRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
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
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsSaveBtnDisplayed
				,ent.IsApproveEnabled
				,ent.IsRejectEnabled
				,ent.IsUnlockEnabled
				,ent.IsWithdrawalEnabled
				,ent.IsInProgress
				,ent.IsReviewRequired
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
				,ent.ReinstatementLabel
				,ent.IsRegisterChange
				,ent.HasOpenAudit
				,ent.IsReinstatementOpen
				,ent.NewFormStatusSCD
				,ent.ReasonSIDOnApprove
			from
				dbo.vReinstatement ent
			where
				ent.ReinstatementSID = @ReinstatementSID

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
