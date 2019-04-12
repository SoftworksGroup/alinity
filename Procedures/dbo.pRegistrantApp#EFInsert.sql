SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantApp#EFInsert]
	 @RegistrationSID                        int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterSectionSID             int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                       smallint          = null				-- default: dbo.fRegistrationYear#Current()
	,@FormVersionSID                         int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@OrgSID                                 int               = null				
	,@FormResponseDraft                      xml               = null				-- default: CONVERT(xml,N'<FormResponses />')
	,@LastValidateTime                       datetimeoffset(7) = null				
	,@AdminComments                          xml               = null				-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp                           date              = null				
	,@PendingReviewers                       xml               = null				
	,@RegistrationEffective                  date              = null				
	,@ConfirmationDraft                      nvarchar(max)     = null				
	,@IsAutoApprovalEnabled                  bit               = null				-- default: CONVERT(bit,(0))
	,@ReasonSID                              int               = null				
	,@InvoiceSID                             int               = null				
	,@ReviewReasonList                       xml               = null				
	,@UserDefinedColumns                     xml               = null				
	,@RegistrantAppXID                       varchar(150)      = null				
	,@LegacyKey                              nvarchar(50)      = null				
	,@CreateUser                             nvarchar(75)      = null				-- default: suser_sname()
	,@IsReselected                           tinyint           = null				-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                               xml               = null				-- other values defining context for the insert (if any)
	,@PracticeRegisterSID                    int               = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel           nvarchar(35)      = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDefault       bit               = null				-- not a base table column (default ignored)
	,@IsDisplayedOnLicense                   bit               = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsActive        bit               = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionRowGUID         uniqueidentifier  = null				-- not a base table column (default ignored)
	,@RegistrantSID                          int               = null				-- not a base table column (default ignored)
	,@RegistrationPracticeRegisterSectionSID int               = null				-- not a base table column (default ignored)
	,@RegistrationNo                         nvarchar(50)      = null				-- not a base table column (default ignored)
	,@RegistrationRegistrationYear           smallint          = null				-- not a base table column (default ignored)
	,@EffectiveTime                          datetime          = null				-- not a base table column (default ignored)
	,@ExpiryTime                             datetime          = null				-- not a base table column (default ignored)
	,@CardPrintedTime                        datetime          = null				-- not a base table column (default ignored)
	,@RegistrationInvoiceSID                 int               = null				-- not a base table column (default ignored)
	,@RegistrationReasonSID                  int               = null				-- not a base table column (default ignored)
	,@FormGUID                               uniqueidentifier  = null				-- not a base table column (default ignored)
	,@RegistrationRowGUID                    uniqueidentifier  = null				-- not a base table column (default ignored)
	,@FormSID                                int               = null				-- not a base table column (default ignored)
	,@VersionNo                              smallint          = null				-- not a base table column (default ignored)
	,@RevisionNo                             smallint          = null				-- not a base table column (default ignored)
	,@IsSaveDisplayed                        bit               = null				-- not a base table column (default ignored)
	,@ApprovedTime                           datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@FormVersionRowGUID                     uniqueidentifier  = null				-- not a base table column (default ignored)
	,@ReasonGroupSID                         int               = null				-- not a base table column (default ignored)
	,@ReasonName                             nvarchar(50)      = null				-- not a base table column (default ignored)
	,@ReasonCode                             varchar(25)       = null				-- not a base table column (default ignored)
	,@ReasonSequence                         smallint          = null				-- not a base table column (default ignored)
	,@ToolTip                                nvarchar(500)     = null				-- not a base table column (default ignored)
	,@ReasonIsActive                         bit               = null				-- not a base table column (default ignored)
	,@ReasonRowGUID                          uniqueidentifier  = null				-- not a base table column (default ignored)
	,@PersonSID                              int               = null				-- not a base table column (default ignored)
	,@InvoiceDate                            date              = null				-- not a base table column (default ignored)
	,@Tax1Label                              nvarchar(8)       = null				-- not a base table column (default ignored)
	,@Tax1Rate                               decimal(4,4)      = null				-- not a base table column (default ignored)
	,@Tax1GLAccountCode                      varchar(50)       = null				-- not a base table column (default ignored)
	,@Tax2Label                              nvarchar(8)       = null				-- not a base table column (default ignored)
	,@Tax2Rate                               decimal(4,4)      = null				-- not a base table column (default ignored)
	,@Tax2GLAccountCode                      varchar(50)       = null				-- not a base table column (default ignored)
	,@Tax3Label                              nvarchar(8)       = null				-- not a base table column (default ignored)
	,@Tax3Rate                               decimal(4,4)      = null				-- not a base table column (default ignored)
	,@Tax3GLAccountCode                      varchar(50)       = null				-- not a base table column (default ignored)
	,@InvoiceRegistrationYear                smallint          = null				-- not a base table column (default ignored)
	,@CancelledTime                          datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@InvoiceReasonSID                       int               = null				-- not a base table column (default ignored)
	,@IsRefund                               bit               = null				-- not a base table column (default ignored)
	,@ComplaintSID                           int               = null				-- not a base table column (default ignored)
	,@InvoiceRowGUID                         uniqueidentifier  = null				-- not a base table column (default ignored)
	,@ParentOrgSID                           int               = null				-- not a base table column (default ignored)
	,@OrgTypeSID                             int               = null				-- not a base table column (default ignored)
	,@OrgName                                nvarchar(150)     = null				-- not a base table column (default ignored)
	,@OrgLabel                               nvarchar(35)      = null				-- not a base table column (default ignored)
	,@StreetAddress1                         nvarchar(75)      = null				-- not a base table column (default ignored)
	,@StreetAddress2                         nvarchar(75)      = null				-- not a base table column (default ignored)
	,@StreetAddress3                         nvarchar(75)      = null				-- not a base table column (default ignored)
	,@CitySID                                int               = null				-- not a base table column (default ignored)
	,@PostalCode                             varchar(10)       = null				-- not a base table column (default ignored)
	,@RegionSID                              int               = null				-- not a base table column (default ignored)
	,@Phone                                  varchar(25)       = null				-- not a base table column (default ignored)
	,@Fax                                    varchar(25)       = null				-- not a base table column (default ignored)
	,@WebSite                                varchar(250)      = null				-- not a base table column (default ignored)
	,@EmailAddress                           varchar(150)      = null				-- not a base table column (default ignored)
	,@InsuranceOrgSID                        int               = null				-- not a base table column (default ignored)
	,@InsurancePolicyNo                      varchar(25)       = null				-- not a base table column (default ignored)
	,@InsuranceAmount                        decimal(11,2)     = null				-- not a base table column (default ignored)
	,@IsEmployer                             bit               = null				-- not a base table column (default ignored)
	,@IsCredentialAuthority                  bit               = null				-- not a base table column (default ignored)
	,@IsInsurer                              bit               = null				-- not a base table column (default ignored)
	,@IsInsuranceCertificateRequired         bit               = null				-- not a base table column (default ignored)
	,@IsPublic                               nchar(10)         = null				-- not a base table column (default ignored)
	,@OrgIsActive                            bit               = null				-- not a base table column (default ignored)
	,@IsAdminReviewRequired                  bit               = null				-- not a base table column (default ignored)
	,@LastVerifiedTime                       datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@OrgRowGUID                             uniqueidentifier  = null				-- not a base table column (default ignored)
	,@IsDeleteEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsViewEnabled                          bit               = null				-- not a base table column (default ignored)
	,@IsEditEnabled                          bit               = null				-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed                     bit               = null				-- not a base table column (default ignored)
	,@IsApproveEnabled                       bit               = null				-- not a base table column (default ignored)
	,@IsRejectEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsUnlockEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsWithdrawalEnabled                    bit               = null				-- not a base table column (default ignored)
	,@IsInProgress                           bit               = null				-- not a base table column (default ignored)
	,@IsReviewRequired                       bit               = null				-- not a base table column (default ignored)
	,@FormStatusSID                          int               = null				-- not a base table column (default ignored)
	,@FormStatusSCD                          varchar(25)       = null				-- not a base table column (default ignored)
	,@FormStatusLabel                        nvarchar(35)      = null				-- not a base table column (default ignored)
	,@LastStatusChangeUser                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@LastStatusChangeTime                   datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@FormOwnerSID                           int               = null				-- not a base table column (default ignored)
	,@FormOwnerSCD                           varchar(25)       = null				-- not a base table column (default ignored)
	,@FormOwnerLabel                         nvarchar(35)      = null				-- not a base table column (default ignored)
	,@IsPDFDisplayed                         bit               = null				-- not a base table column (default ignored)
	,@PersonDocSID                           int               = null				-- not a base table column (default ignored)
	,@TotalDue                               decimal(11,2)     = null				-- not a base table column (default ignored)
	,@IsUnPaid                               bit               = null				-- not a base table column (default ignored)
	,@PersonStreetAddress1                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@PersonStreetAddress2                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@PersonStreetAddress3                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@PersonCityName                         nvarchar(30)      = null				-- not a base table column (default ignored)
	,@PersonStateProvinceName                nvarchar(30)      = null				-- not a base table column (default ignored)
	,@PersonPostalCode                       nvarchar(10)      = null				-- not a base table column (default ignored)
	,@PersonCountryName                      nvarchar(50)      = null				-- not a base table column (default ignored)
	,@PersonCitySID                          int               = null				-- not a base table column (default ignored)
	,@RegistrantPersonSID                    int               = null				-- not a base table column (default ignored)
	,@RegistrationYearLabel                  varchar(9)        = null				-- not a base table column (default ignored)
	,@PracticeRegisterLabel                  nvarchar(35)      = null				-- not a base table column (default ignored)
	,@PracticeRegisterName                   nvarchar(65)      = null				-- not a base table column (default ignored)
	,@RegistrantAppLabel                     nvarchar(80)      = null				-- not a base table column (default ignored)
	,@IsSendForReviewEnabled                 bit               = null				-- not a base table column (default ignored)
	,@IsReviewInProgress                     bit               = null				-- not a base table column (default ignored)
	,@IsReviewFormConfigured                 bit               = null				-- not a base table column (default ignored)
	,@RecommendationLabel                    nvarchar(20)      = null				-- not a base table column (default ignored)
	,@NewFormStatusSCD                       varchar(25)       = null				-- not a base table column (default ignored)
	,@ReasonSIDOnApprove                     int               = null				-- not a base table column (default ignored)
	,@Reviewers                              xml               = null				-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantApp#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantApp#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

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

		-- call the main procedure

		exec @errorNo = dbo.pRegistrantApp#Insert
			 @RegistrationSID                        = @RegistrationSID
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
			,@CreateUser                             = @CreateUser
			,@IsReselected                           = @IsReselected
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
