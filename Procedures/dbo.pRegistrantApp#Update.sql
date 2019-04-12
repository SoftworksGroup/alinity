SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantApp#Update]
	 @RegistrantAppSID                       int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationSID                        int               = null -- table column values to update:
	,@PracticeRegisterSectionSID             int               = null
	,@RegistrationYear                       smallint          = null
	,@FormVersionSID                         int               = null
	,@OrgSID                                 int               = null
	,@FormResponseDraft                      xml               = null
	,@LastValidateTime                       datetimeoffset(7) = null
	,@AdminComments                          xml               = null
	,@NextFollowUp                           date              = null
	,@PendingReviewers                       xml               = null
	,@RegistrationEffective                  date              = null
	,@ConfirmationDraft                      nvarchar(max)     = null
	,@IsAutoApprovalEnabled                  bit               = null
	,@ReasonSID                              int               = null
	,@InvoiceSID                             int               = null
	,@ReviewReasonList                       xml               = null
	,@UserDefinedColumns                     xml               = null
	,@RegistrantAppXID                       varchar(150)      = null
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
	,@ParentOrgSID                           int               = null -- not a base table column
	,@OrgTypeSID                             int               = null -- not a base table column
	,@OrgName                                nvarchar(150)     = null -- not a base table column
	,@OrgLabel                               nvarchar(35)      = null -- not a base table column
	,@StreetAddress1                         nvarchar(75)      = null -- not a base table column
	,@StreetAddress2                         nvarchar(75)      = null -- not a base table column
	,@StreetAddress3                         nvarchar(75)      = null -- not a base table column
	,@CitySID                                int               = null -- not a base table column
	,@PostalCode                             varchar(10)       = null -- not a base table column
	,@RegionSID                              int               = null -- not a base table column
	,@Phone                                  varchar(25)       = null -- not a base table column
	,@Fax                                    varchar(25)       = null -- not a base table column
	,@WebSite                                varchar(250)      = null -- not a base table column
	,@EmailAddress                           varchar(150)      = null -- not a base table column
	,@InsuranceOrgSID                        int               = null -- not a base table column
	,@InsurancePolicyNo                      varchar(25)       = null -- not a base table column
	,@InsuranceAmount                        decimal(11,2)     = null -- not a base table column
	,@IsEmployer                             bit               = null -- not a base table column
	,@IsCredentialAuthority                  bit               = null -- not a base table column
	,@IsInsurer                              bit               = null -- not a base table column
	,@IsInsuranceCertificateRequired         bit               = null -- not a base table column
	,@IsPublic                               nchar(10)         = null -- not a base table column
	,@OrgIsActive                            bit               = null -- not a base table column
	,@IsAdminReviewRequired                  bit               = null -- not a base table column
	,@LastVerifiedTime                       datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                             uniqueidentifier  = null -- not a base table column
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
	,@RegistrantAppLabel                     nvarchar(80)      = null -- not a base table column
	,@IsSendForReviewEnabled                 bit               = null -- not a base table column
	,@IsReviewInProgress                     bit               = null -- not a base table column
	,@IsReviewFormConfigured                 bit               = null -- not a base table column
	,@RecommendationLabel                    nvarchar(20)      = null -- not a base table column
	,@NewFormStatusSCD                       varchar(25)       = null -- not a base table column
	,@ReasonSIDOnApprove                     int               = null -- not a base table column
	,@Reviewers                              xml               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantApp#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantApp table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantApp table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantApp entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantApp procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantAppCheck to test all rules.

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

		if @RegistrantAppSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantAppSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrantAppXID = ltrim(rtrim(@RegistrantAppXID))
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
		set @RegistrantAppLabel = ltrim(rtrim(@RegistrantAppLabel))
		set @RecommendationLabel = ltrim(rtrim(@RecommendationLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrantAppXID) = 0 set @RegistrantAppXID = null
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
		if len(@RegistrantAppLabel) = 0 set @RegistrantAppLabel = null
		if len(@RecommendationLabel) = 0 set @RecommendationLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationSID                        = isnull(@RegistrationSID,ra.RegistrationSID)
				,@PracticeRegisterSectionSID             = isnull(@PracticeRegisterSectionSID,ra.PracticeRegisterSectionSID)
				,@RegistrationYear                       = isnull(@RegistrationYear,ra.RegistrationYear)
				,@FormVersionSID                         = isnull(@FormVersionSID,ra.FormVersionSID)
				,@OrgSID                                 = isnull(@OrgSID,ra.OrgSID)
				,@FormResponseDraft                      = isnull(@FormResponseDraft,ra.FormResponseDraft)
				,@LastValidateTime                       = isnull(@LastValidateTime,ra.LastValidateTime)
				,@AdminComments                          = isnull(@AdminComments,ra.AdminComments)
				,@NextFollowUp                           = isnull(@NextFollowUp,ra.NextFollowUp)
				,@PendingReviewers                       = isnull(@PendingReviewers,ra.PendingReviewers)
				,@RegistrationEffective                  = isnull(@RegistrationEffective,ra.RegistrationEffective)
				,@ConfirmationDraft                      = isnull(@ConfirmationDraft,ra.ConfirmationDraft)
				,@IsAutoApprovalEnabled                  = isnull(@IsAutoApprovalEnabled,ra.IsAutoApprovalEnabled)
				,@ReasonSID                              = isnull(@ReasonSID,ra.ReasonSID)
				,@InvoiceSID                             = isnull(@InvoiceSID,ra.InvoiceSID)
				,@ReviewReasonList                       = isnull(@ReviewReasonList,ra.ReviewReasonList)
				,@UserDefinedColumns                     = isnull(@UserDefinedColumns,ra.UserDefinedColumns)
				,@RegistrantAppXID                       = isnull(@RegistrantAppXID,ra.RegistrantAppXID)
				,@LegacyKey                              = isnull(@LegacyKey,ra.LegacyKey)
				,@UpdateUser                             = isnull(@UpdateUser,ra.UpdateUser)
				,@IsReselected                           = isnull(@IsReselected,ra.IsReselected)
				,@IsNullApplied                          = isnull(@IsNullApplied,ra.IsNullApplied)
				,@zContext                               = isnull(@zContext,ra.zContext)
				,@PracticeRegisterSID                    = isnull(@PracticeRegisterSID,ra.PracticeRegisterSID)
				,@PracticeRegisterSectionLabel           = isnull(@PracticeRegisterSectionLabel,ra.PracticeRegisterSectionLabel)
				,@PracticeRegisterSectionIsDefault       = isnull(@PracticeRegisterSectionIsDefault,ra.PracticeRegisterSectionIsDefault)
				,@IsDisplayedOnLicense                   = isnull(@IsDisplayedOnLicense,ra.IsDisplayedOnLicense)
				,@PracticeRegisterSectionIsActive        = isnull(@PracticeRegisterSectionIsActive,ra.PracticeRegisterSectionIsActive)
				,@PracticeRegisterSectionRowGUID         = isnull(@PracticeRegisterSectionRowGUID,ra.PracticeRegisterSectionRowGUID)
				,@RegistrantSID                          = isnull(@RegistrantSID,ra.RegistrantSID)
				,@RegistrationPracticeRegisterSectionSID = isnull(@RegistrationPracticeRegisterSectionSID,ra.RegistrationPracticeRegisterSectionSID)
				,@RegistrationNo                         = isnull(@RegistrationNo,ra.RegistrationNo)
				,@RegistrationRegistrationYear           = isnull(@RegistrationRegistrationYear,ra.RegistrationRegistrationYear)
				,@EffectiveTime                          = isnull(@EffectiveTime,ra.EffectiveTime)
				,@ExpiryTime                             = isnull(@ExpiryTime,ra.ExpiryTime)
				,@CardPrintedTime                        = isnull(@CardPrintedTime,ra.CardPrintedTime)
				,@RegistrationInvoiceSID                 = isnull(@RegistrationInvoiceSID,ra.RegistrationInvoiceSID)
				,@RegistrationReasonSID                  = isnull(@RegistrationReasonSID,ra.RegistrationReasonSID)
				,@FormGUID                               = isnull(@FormGUID,ra.FormGUID)
				,@RegistrationRowGUID                    = isnull(@RegistrationRowGUID,ra.RegistrationRowGUID)
				,@FormSID                                = isnull(@FormSID,ra.FormSID)
				,@VersionNo                              = isnull(@VersionNo,ra.VersionNo)
				,@RevisionNo                             = isnull(@RevisionNo,ra.RevisionNo)
				,@IsSaveDisplayed                        = isnull(@IsSaveDisplayed,ra.IsSaveDisplayed)
				,@ApprovedTime                           = isnull(@ApprovedTime,ra.ApprovedTime)
				,@FormVersionRowGUID                     = isnull(@FormVersionRowGUID,ra.FormVersionRowGUID)
				,@ReasonGroupSID                         = isnull(@ReasonGroupSID,ra.ReasonGroupSID)
				,@ReasonName                             = isnull(@ReasonName,ra.ReasonName)
				,@ReasonCode                             = isnull(@ReasonCode,ra.ReasonCode)
				,@ReasonSequence                         = isnull(@ReasonSequence,ra.ReasonSequence)
				,@ToolTip                                = isnull(@ToolTip,ra.ToolTip)
				,@ReasonIsActive                         = isnull(@ReasonIsActive,ra.ReasonIsActive)
				,@ReasonRowGUID                          = isnull(@ReasonRowGUID,ra.ReasonRowGUID)
				,@PersonSID                              = isnull(@PersonSID,ra.PersonSID)
				,@InvoiceDate                            = isnull(@InvoiceDate,ra.InvoiceDate)
				,@Tax1Label                              = isnull(@Tax1Label,ra.Tax1Label)
				,@Tax1Rate                               = isnull(@Tax1Rate,ra.Tax1Rate)
				,@Tax1GLAccountCode                      = isnull(@Tax1GLAccountCode,ra.Tax1GLAccountCode)
				,@Tax2Label                              = isnull(@Tax2Label,ra.Tax2Label)
				,@Tax2Rate                               = isnull(@Tax2Rate,ra.Tax2Rate)
				,@Tax2GLAccountCode                      = isnull(@Tax2GLAccountCode,ra.Tax2GLAccountCode)
				,@Tax3Label                              = isnull(@Tax3Label,ra.Tax3Label)
				,@Tax3Rate                               = isnull(@Tax3Rate,ra.Tax3Rate)
				,@Tax3GLAccountCode                      = isnull(@Tax3GLAccountCode,ra.Tax3GLAccountCode)
				,@InvoiceRegistrationYear                = isnull(@InvoiceRegistrationYear,ra.InvoiceRegistrationYear)
				,@CancelledTime                          = isnull(@CancelledTime,ra.CancelledTime)
				,@InvoiceReasonSID                       = isnull(@InvoiceReasonSID,ra.InvoiceReasonSID)
				,@IsRefund                               = isnull(@IsRefund,ra.IsRefund)
				,@ComplaintSID                           = isnull(@ComplaintSID,ra.ComplaintSID)
				,@InvoiceRowGUID                         = isnull(@InvoiceRowGUID,ra.InvoiceRowGUID)
				,@ParentOrgSID                           = isnull(@ParentOrgSID,ra.ParentOrgSID)
				,@OrgTypeSID                             = isnull(@OrgTypeSID,ra.OrgTypeSID)
				,@OrgName                                = isnull(@OrgName,ra.OrgName)
				,@OrgLabel                               = isnull(@OrgLabel,ra.OrgLabel)
				,@StreetAddress1                         = isnull(@StreetAddress1,ra.StreetAddress1)
				,@StreetAddress2                         = isnull(@StreetAddress2,ra.StreetAddress2)
				,@StreetAddress3                         = isnull(@StreetAddress3,ra.StreetAddress3)
				,@CitySID                                = isnull(@CitySID,ra.CitySID)
				,@PostalCode                             = isnull(@PostalCode,ra.PostalCode)
				,@RegionSID                              = isnull(@RegionSID,ra.RegionSID)
				,@Phone                                  = isnull(@Phone,ra.Phone)
				,@Fax                                    = isnull(@Fax,ra.Fax)
				,@WebSite                                = isnull(@WebSite,ra.WebSite)
				,@EmailAddress                           = isnull(@EmailAddress,ra.EmailAddress)
				,@InsuranceOrgSID                        = isnull(@InsuranceOrgSID,ra.InsuranceOrgSID)
				,@InsurancePolicyNo                      = isnull(@InsurancePolicyNo,ra.InsurancePolicyNo)
				,@InsuranceAmount                        = isnull(@InsuranceAmount,ra.InsuranceAmount)
				,@IsEmployer                             = isnull(@IsEmployer,ra.IsEmployer)
				,@IsCredentialAuthority                  = isnull(@IsCredentialAuthority,ra.IsCredentialAuthority)
				,@IsInsurer                              = isnull(@IsInsurer,ra.IsInsurer)
				,@IsInsuranceCertificateRequired         = isnull(@IsInsuranceCertificateRequired,ra.IsInsuranceCertificateRequired)
				,@IsPublic                               = isnull(@IsPublic,ra.IsPublic)
				,@OrgIsActive                            = isnull(@OrgIsActive,ra.OrgIsActive)
				,@IsAdminReviewRequired                  = isnull(@IsAdminReviewRequired,ra.IsAdminReviewRequired)
				,@LastVerifiedTime                       = isnull(@LastVerifiedTime,ra.LastVerifiedTime)
				,@OrgRowGUID                             = isnull(@OrgRowGUID,ra.OrgRowGUID)
				,@IsDeleteEnabled                        = isnull(@IsDeleteEnabled,ra.IsDeleteEnabled)
				,@IsViewEnabled                          = isnull(@IsViewEnabled,ra.IsViewEnabled)
				,@IsEditEnabled                          = isnull(@IsEditEnabled,ra.IsEditEnabled)
				,@IsSaveBtnDisplayed                     = isnull(@IsSaveBtnDisplayed,ra.IsSaveBtnDisplayed)
				,@IsApproveEnabled                       = isnull(@IsApproveEnabled,ra.IsApproveEnabled)
				,@IsRejectEnabled                        = isnull(@IsRejectEnabled,ra.IsRejectEnabled)
				,@IsUnlockEnabled                        = isnull(@IsUnlockEnabled,ra.IsUnlockEnabled)
				,@IsWithdrawalEnabled                    = isnull(@IsWithdrawalEnabled,ra.IsWithdrawalEnabled)
				,@IsInProgress                           = isnull(@IsInProgress,ra.IsInProgress)
				,@IsReviewRequired                       = isnull(@IsReviewRequired,ra.IsReviewRequired)
				,@FormStatusSID                          = isnull(@FormStatusSID,ra.FormStatusSID)
				,@FormStatusSCD                          = isnull(@FormStatusSCD,ra.FormStatusSCD)
				,@FormStatusLabel                        = isnull(@FormStatusLabel,ra.FormStatusLabel)
				,@LastStatusChangeUser                   = isnull(@LastStatusChangeUser,ra.LastStatusChangeUser)
				,@LastStatusChangeTime                   = isnull(@LastStatusChangeTime,ra.LastStatusChangeTime)
				,@FormOwnerSID                           = isnull(@FormOwnerSID,ra.FormOwnerSID)
				,@FormOwnerSCD                           = isnull(@FormOwnerSCD,ra.FormOwnerSCD)
				,@FormOwnerLabel                         = isnull(@FormOwnerLabel,ra.FormOwnerLabel)
				,@IsPDFDisplayed                         = isnull(@IsPDFDisplayed,ra.IsPDFDisplayed)
				,@PersonDocSID                           = isnull(@PersonDocSID,ra.PersonDocSID)
				,@TotalDue                               = isnull(@TotalDue,ra.TotalDue)
				,@IsUnPaid                               = isnull(@IsUnPaid,ra.IsUnPaid)
				,@PersonStreetAddress1                   = isnull(@PersonStreetAddress1,ra.PersonStreetAddress1)
				,@PersonStreetAddress2                   = isnull(@PersonStreetAddress2,ra.PersonStreetAddress2)
				,@PersonStreetAddress3                   = isnull(@PersonStreetAddress3,ra.PersonStreetAddress3)
				,@PersonCityName                         = isnull(@PersonCityName,ra.PersonCityName)
				,@PersonStateProvinceName                = isnull(@PersonStateProvinceName,ra.PersonStateProvinceName)
				,@PersonPostalCode                       = isnull(@PersonPostalCode,ra.PersonPostalCode)
				,@PersonCountryName                      = isnull(@PersonCountryName,ra.PersonCountryName)
				,@PersonCitySID                          = isnull(@PersonCitySID,ra.PersonCitySID)
				,@RegistrantPersonSID                    = isnull(@RegistrantPersonSID,ra.RegistrantPersonSID)
				,@RegistrationYearLabel                  = isnull(@RegistrationYearLabel,ra.RegistrationYearLabel)
				,@PracticeRegisterLabel                  = isnull(@PracticeRegisterLabel,ra.PracticeRegisterLabel)
				,@PracticeRegisterName                   = isnull(@PracticeRegisterName,ra.PracticeRegisterName)
				,@RegistrantAppLabel                     = isnull(@RegistrantAppLabel,ra.RegistrantAppLabel)
				,@IsSendForReviewEnabled                 = isnull(@IsSendForReviewEnabled,ra.IsSendForReviewEnabled)
				,@IsReviewInProgress                     = isnull(@IsReviewInProgress,ra.IsReviewInProgress)
				,@IsReviewFormConfigured                 = isnull(@IsReviewFormConfigured,ra.IsReviewFormConfigured)
				,@RecommendationLabel                    = isnull(@RecommendationLabel,ra.RecommendationLabel)
				,@NewFormStatusSCD                       = isnull(@NewFormStatusSCD,ra.NewFormStatusSCD)
				,@ReasonSIDOnApprove                     = isnull(@ReasonSIDOnApprove,ra.ReasonSIDOnApprove)
				,@Reviewers                              = isnull(@Reviewers,ra.Reviewers)
			from
				dbo.vRegistrantApp ra
			where
				ra.RegistrantAppSID = @RegistrantAppSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.OrgSID from dbo.RegistrantApp x where x.RegistrantAppSID = @RegistrantAppSID) <> @OrgSID
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
		
		if (select x.PracticeRegisterSectionSID from dbo.RegistrantApp x where x.RegistrantAppSID = @RegistrantAppSID) <> @PracticeRegisterSectionSID
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
		
		if (select x.ReasonSID from dbo.RegistrantApp x where x.RegistrantAppSID = @RegistrantAppSID) <> @ReasonSID
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
				dbo.RegistrantApp parent
			join
				dbo.ProfileUpdate			child on parent.RowGUID = child.ParentRowGUID -- PROFILE-UPDATE
			where
				parent.RegistrantAppSID = @RegistrantAppSID and child.LastValidateTime is not null;

			-- learning plans are not expected to be associated with
			-- applications so an update is not made for them

		end;

		-- Tim Edlund | Oct 2018
		-- If the form is not withdrawn and the reason list
		-- is blank where an individual reason key exists,
		-- the put the value in the XML document (for UI display)

		if @NewFormStatusSCD <> 'WITHDRAWN' and @FormStatusSCD <> 'WITHDRAWN' and @ReviewReasonList is null and @ReasonSID is not null
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
				r.RoutineName = 'pRegistrantApp'
		)
		begin
		
			exec @errorNo = ext.pRegistrantApp
				 @Mode                                   = 'update.pre'
				,@RegistrantAppSID                       = @RegistrantAppSID
				,@RegistrationSID                        = @RegistrationSID output
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID output
				,@RegistrationYear                       = @RegistrationYear output
				,@FormVersionSID                         = @FormVersionSID output
				,@OrgSID                                 = @OrgSID output
				,@FormResponseDraft                      = @FormResponseDraft output
				,@LastValidateTime                       = @LastValidateTime output
				,@AdminComments                          = @AdminComments output
				,@NextFollowUp                           = @NextFollowUp output
				,@PendingReviewers                       = @PendingReviewers output
				,@RegistrationEffective                  = @RegistrationEffective output
				,@ConfirmationDraft                      = @ConfirmationDraft output
				,@IsAutoApprovalEnabled                  = @IsAutoApprovalEnabled output
				,@ReasonSID                              = @ReasonSID output
				,@InvoiceSID                             = @InvoiceSID output
				,@ReviewReasonList                       = @ReviewReasonList output
				,@UserDefinedColumns                     = @UserDefinedColumns output
				,@RegistrantAppXID                       = @RegistrantAppXID output
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
				,@ParentOrgSID                           = @ParentOrgSID
				,@OrgTypeSID                             = @OrgTypeSID
				,@OrgName                                = @OrgName
				,@OrgLabel                               = @OrgLabel
				,@StreetAddress1                         = @StreetAddress1
				,@StreetAddress2                         = @StreetAddress2
				,@StreetAddress3                         = @StreetAddress3
				,@CitySID                                = @CitySID
				,@PostalCode                             = @PostalCode
				,@RegionSID                              = @RegionSID
				,@Phone                                  = @Phone
				,@Fax                                    = @Fax
				,@WebSite                                = @WebSite
				,@EmailAddress                           = @EmailAddress
				,@InsuranceOrgSID                        = @InsuranceOrgSID
				,@InsurancePolicyNo                      = @InsurancePolicyNo
				,@InsuranceAmount                        = @InsuranceAmount
				,@IsEmployer                             = @IsEmployer
				,@IsCredentialAuthority                  = @IsCredentialAuthority
				,@IsInsurer                              = @IsInsurer
				,@IsInsuranceCertificateRequired         = @IsInsuranceCertificateRequired
				,@IsPublic                               = @IsPublic
				,@OrgIsActive                            = @OrgIsActive
				,@IsAdminReviewRequired                  = @IsAdminReviewRequired
				,@LastVerifiedTime                       = @LastVerifiedTime
				,@OrgRowGUID                             = @OrgRowGUID
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
				,@RegistrantAppLabel                     = @RegistrantAppLabel
				,@IsSendForReviewEnabled                 = @IsSendForReviewEnabled
				,@IsReviewInProgress                     = @IsReviewInProgress
				,@IsReviewFormConfigured                 = @IsReviewFormConfigured
				,@RecommendationLabel                    = @RecommendationLabel
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
				,@Reviewers                              = @Reviewers
		
		end

		-- update the record

		update
			dbo.RegistrantApp
		set
			 RegistrationSID = @RegistrationSID
			,PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			,RegistrationYear = @RegistrationYear
			,FormVersionSID = @FormVersionSID
			,OrgSID = @OrgSID
			,FormResponseDraft = @FormResponseDraft
			,LastValidateTime = @LastValidateTime
			,AdminComments = @AdminComments
			,NextFollowUp = @NextFollowUp
			,PendingReviewers = @PendingReviewers
			,RegistrationEffective = @RegistrationEffective
			,ConfirmationDraft = @ConfirmationDraft
			,IsAutoApprovalEnabled = @IsAutoApprovalEnabled
			,ReasonSID = @ReasonSID
			,InvoiceSID = @InvoiceSID
			,ReviewReasonList = @ReviewReasonList
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantAppXID = @RegistrantAppXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantAppSID = @RegistrantAppSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantApp where RegistrantAppSID = @registrantAppSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantApp'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantApp'
					,@Arg2        = @registrantAppSID
				
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
				,@Arg2        = 'dbo.RegistrantApp'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantAppSID
			
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

		-- Tim Edlund | Aug 2017 (Updated Oct 2017 for invoice support)
		-- Save the new status value and then store the draft content of the
		-- form into the response history table as long as the change has been
		-- made in the response document. Note that if no previous history
		-- record exists, the form is NEW and the response must be saved
		-- if the status is returned or unlocked set all forms in the form set
		-- to the same status

		declare
			@formDefinition xml

		if @NewFormStatusSCD is not null -- if just saving in place (save and continue) pass this as NULL!
		begin
			
			declare
				@rowGUID		uniqueidentifier

			select
				@rowGUID = ra.RowGUID
			from
				dbo.RegistrantApp ra
			cross apply
				dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) cs
			where
				ra.RegistrantAppSID = @RegistrantAppSID
			and
				cs.FormStatusSCD <> @NewFormStatusSCD

			if @rowGUID is not null
			begin

				set @recordSID = null;

				select
					@recordSID = fs.FormStatusSID
				from
					sf.FormStatus fs
				where
					fs.FormStatusSCD = @NewFormStatusSCD;

				if @recordSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'sf.FormStatus'
					 ,@Arg2 = @NewFormStatusSCD;

					raiserror(@errorText, 18, 1);

				end;

				exec dbo.pRegistrantAppStatus#Insert
					@RegistrantAppSID = @RegistrantAppSID
				 ,@FormStatusSID = @recordSID;

				if @NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD = 'UNLOCKED'
				begin

						exec dbo.pFormSet#SetStatus								 @ParentRowGUID = @rowGUID							,@FormStatusSCD = @NewFormStatusSCD
							,@IsParentSet		= @ON

				end

			end

			set @recordSID = null;

			select
				@recordSID = max(rar.RegistrantAppResponseSID)
			from
				dbo.RegistrantAppResponse rar
			where
				rar.RegistrantAppSID = @RegistrantAppSID;

			if @recordSID is null or
														(
															select
																checksum(cast(rar.FormResponse as nvarchar(max)))
															from
																dbo.RegistrantAppResponse rar
															where
																rar.RegistrantAppResponseSID = @recordSID
														) <> checksum(cast(@FormResponseDraft as nvarchar(max))) -- if no saved version of form found, OR if current value is changed from latest copy
			begin

				exec dbo.pRegistrantAppResponse#Insert
					@RegistrantAppSID = @RegistrantAppSID
				 ,@FormOwnerSID = @FormOwnerSID
				 ,@FormResponse = @FormResponseDraft;
			end;

			-- post values to the main profile as required for
			-- the SUBMIT and APPROVE form actions

			if @NewFormStatusSCD = 'SUBMITTED'
			begin

				exec dbo.pRegistrantApp#Submit
					@RegistrantAppSID = @RegistrantAppSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID

			end;
			else if @NewFormStatusSCD = 'APPROVED'
			begin

				exec dbo.pRegistrantApp#Approve
					@RegistrantAppSID = @RegistrantAppSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID

			end;
			else if @NewFormStatusSCD in ('CORRECTED','RETURNED') and exists -- if edited by admin and form was previously submitted, call the form post action
					 (
						select
							1
						from
							dbo.RegistrantAppStatus x
						join
							sf.FormStatus										 fs on x.FormStatusSID = fs.FormStatusSID
						where
							x.RegistrantAppSID = @RegistrantAppSID and fs.FormStatusSCD = 'SUBMITTED'
					 )
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.RegistrantApp x
				join
					sf.FormVersion						 fv on x.FormVersionSID = fv.FormVersionSID
				where
					x.RegistrantAppSID = @RegistrantAppSID;

				exec sf.pForm#Post
					@FormRecordSID = @RegistrantAppSID
				 ,@FormActionCode = 'SUBMIT'
				 ,@FormSchemaName = 'dbo'
				 ,@FormTableName = 'RegistrantApp'
				 ,@FormDefinition = @formDefinition
				 ,@Response = @FormResponseDraft;

			end;
			else if @NewFormStatusSCD = 'WITHDRAWN' and @InvoiceSID is not null
			begin

				if
				(
					select
						sum(i.TotalPaid)
					from
						dbo.vInvoice i
					where
						i.InvoiceSID = @InvoiceSID
				) > 0.00
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'WithdrawalOnPaid'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 cannot be withdrawn if paid.  Remove (un-apply) the payment from the invoice and cancel any associated registrations and try again.'
					 ,@Arg1 = 'application';

					raiserror(@errorText, 16, 1);

				end;

				-- cancel the invoice - first setting quantity to zero

				update
					dbo.InvoiceItem
				set
					Quantity = 0
				where
					InvoiceSID = @InvoiceSID;

				update
					dbo.Invoice
				set
					CancelledTime = sysdatetimeoffset()
				where
					InvoiceSID = @InvoiceSID;

			end;
			else if @Reviewers is not null
			begin

				-- Tim Edlund | Jun 2017
				-- When a list of reviewers is passed in, call the procedure to assign the
				-- review records (do not allow if in a final status)				
				
				declare @Apps xml;

				if @NewFormStatusSCD <> 'INREVIEW'
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'CannotAssignReviewers'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'Reviewers cannot be assigned because the form status has not been set to "%1".'
					 ,@Arg1 = 'INREVIEW';

					raiserror(@errorText, 18, 1);

				end;

				set @Apps = N'<Apps><RegistrantApp SID="' + ltrim(@RegistrantAppSID) + '"/></Apps>';

				exec dbo.pRegistrantAppReview#Set
					@Apps = @Apps
				 ,@Reviewers = @Reviewers;

			end;
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
				r.RoutineName = 'pRegistrantApp'
		)
		begin
		
			exec @errorNo = ext.pRegistrantApp
				 @Mode                                   = 'update.post'
				,@RegistrantAppSID                       = @RegistrantAppSID
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@FormVersionSID                         = @FormVersionSID
				,@OrgSID                                 = @OrgSID
				,@FormResponseDraft                      = @FormResponseDraft
				,@LastValidateTime                       = @LastValidateTime
				,@AdminComments                          = @AdminComments
				,@NextFollowUp                           = @NextFollowUp
				,@PendingReviewers                       = @PendingReviewers
				,@RegistrationEffective                  = @RegistrationEffective
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@IsAutoApprovalEnabled                  = @IsAutoApprovalEnabled
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ReviewReasonList                       = @ReviewReasonList
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@RegistrantAppXID                       = @RegistrantAppXID
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
				,@ParentOrgSID                           = @ParentOrgSID
				,@OrgTypeSID                             = @OrgTypeSID
				,@OrgName                                = @OrgName
				,@OrgLabel                               = @OrgLabel
				,@StreetAddress1                         = @StreetAddress1
				,@StreetAddress2                         = @StreetAddress2
				,@StreetAddress3                         = @StreetAddress3
				,@CitySID                                = @CitySID
				,@PostalCode                             = @PostalCode
				,@RegionSID                              = @RegionSID
				,@Phone                                  = @Phone
				,@Fax                                    = @Fax
				,@WebSite                                = @WebSite
				,@EmailAddress                           = @EmailAddress
				,@InsuranceOrgSID                        = @InsuranceOrgSID
				,@InsurancePolicyNo                      = @InsurancePolicyNo
				,@InsuranceAmount                        = @InsuranceAmount
				,@IsEmployer                             = @IsEmployer
				,@IsCredentialAuthority                  = @IsCredentialAuthority
				,@IsInsurer                              = @IsInsurer
				,@IsInsuranceCertificateRequired         = @IsInsuranceCertificateRequired
				,@IsPublic                               = @IsPublic
				,@OrgIsActive                            = @OrgIsActive
				,@IsAdminReviewRequired                  = @IsAdminReviewRequired
				,@LastVerifiedTime                       = @LastVerifiedTime
				,@OrgRowGUID                             = @OrgRowGUID
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
				,@RegistrantAppLabel                     = @RegistrantAppLabel
				,@IsSendForReviewEnabled                 = @IsSendForReviewEnabled
				,@IsReviewInProgress                     = @IsReviewInProgress
				,@IsReviewFormConfigured                 = @IsReviewFormConfigured
				,@RecommendationLabel                    = @RecommendationLabel
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
				,@Reviewers                              = @Reviewers
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantAppSID
			from
				dbo.vRegistrantApp ent
			where
				ent.RegistrantAppSID = @RegistrantAppSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantAppSID
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.FormVersionSID
				,ent.OrgSID
				,ent.FormResponseDraft
				,ent.LastValidateTime
				,ent.AdminComments
				,ent.NextFollowUp
				,ent.PendingReviewers
				,ent.RegistrationEffective
				,ent.ConfirmationDraft
				,ent.IsAutoApprovalEnabled
				,ent.ReasonSID
				,ent.InvoiceSID
				,ent.ReviewReasonList
				,ent.UserDefinedColumns
				,ent.RegistrantAppXID
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
				,ent.LastVerifiedTime
				,ent.OrgRowGUID
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
				,ent.RegistrantAppLabel
				,ent.IsSendForReviewEnabled
				,ent.IsReviewInProgress
				,ent.IsReviewFormConfigured
				,ent.RecommendationLabel
				,ent.NewFormStatusSCD
				,ent.ReasonSIDOnApprove
				,ent.Reviewers
			from
				dbo.vRegistrantApp ent
			where
				ent.RegistrantAppSID = @RegistrantAppSID

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
