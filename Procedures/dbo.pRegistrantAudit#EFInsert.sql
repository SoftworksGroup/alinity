SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAudit#EFInsert]
	 @RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@AuditTypeSID                   int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear               smallint          = null								-- default: sf.fTodayYear()
	,@FormVersionSID                 int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@FormResponseDraft              xml               = null								-- default: CONVERT(xml,N'<FormResponses />')
	,@LastValidateTime               datetimeoffset(7) = null								
	,@AdminComments                  xml               = null								-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp                   date              = null								
	,@PendingReviewers               xml               = null								
	,@ReasonSID                      int               = null								
	,@ConfirmationDraft              nvarchar(max)     = null								
	,@IsAutoApprovalEnabled          bit               = null								-- default: CONVERT(bit,(0))
	,@ReviewReasonList               xml               = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantAuditXID             varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@AuditTypeLabel                 nvarchar(35)      = null								-- not a base table column (default ignored)
	,@AuditTypeCategory              nvarchar(65)      = null								-- not a base table column (default ignored)
	,@AuditTypeIsDefault             bit               = null								-- not a base table column (default ignored)
	,@AuditTypeIsActive              bit               = null								-- not a base table column (default ignored)
	,@AuditTypeRowGUID               uniqueidentifier  = null								-- not a base table column (default ignored)
	,@PersonSID                      int               = null								-- not a base table column (default ignored)
	,@RegistrantNo                   varchar(50)       = null								-- not a base table column (default ignored)
	,@YearOfInitialEmployment        smallint          = null								-- not a base table column (default ignored)
	,@IsOnPublicRegistry             bit               = null								-- not a base table column (default ignored)
	,@CityNameOfBirth                nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CountrySID                     int               = null								-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence    smallint          = null								-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours smallint          = null								-- not a base table column (default ignored)
	,@LateFeeExclusionYear           smallint          = null								-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked   bit               = null								-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime     datetime          = null								-- not a base table column (default ignored)
	,@ArchivedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@RegistrantRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@FormSID                        int               = null								-- not a base table column (default ignored)
	,@VersionNo                      smallint          = null								-- not a base table column (default ignored)
	,@RevisionNo                     smallint          = null								-- not a base table column (default ignored)
	,@IsSaveDisplayed                bit               = null								-- not a base table column (default ignored)
	,@ApprovedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@FormVersionRowGUID             uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ReasonGroupSID                 int               = null								-- not a base table column (default ignored)
	,@ReasonName                     nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ReasonCode                     varchar(25)       = null								-- not a base table column (default ignored)
	,@ReasonSequence                 smallint          = null								-- not a base table column (default ignored)
	,@ToolTip                        nvarchar(500)     = null								-- not a base table column (default ignored)
	,@ReasonIsActive                 bit               = null								-- not a base table column (default ignored)
	,@ReasonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsViewEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsEditEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed             bit               = null								-- not a base table column (default ignored)
	,@IsApproveEnabled               bit               = null								-- not a base table column (default ignored)
	,@IsRejectEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsUnlockEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsWithdrawalEnabled            bit               = null								-- not a base table column (default ignored)
	,@IsInProgress                   bit               = null								-- not a base table column (default ignored)
	,@IsReviewRequired               bit               = null								-- not a base table column (default ignored)
	,@FormStatusSID                  int               = null								-- not a base table column (default ignored)
	,@FormStatusSCD                  varchar(25)       = null								-- not a base table column (default ignored)
	,@FormStatusLabel                nvarchar(35)      = null								-- not a base table column (default ignored)
	,@LastStatusChangeUser           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@LastStatusChangeTime           datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@FormOwnerSID                   int               = null								-- not a base table column (default ignored)
	,@FormOwnerSCD                   varchar(25)       = null								-- not a base table column (default ignored)
	,@FormOwnerLabel                 nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsPDFDisplayed                 bit               = null								-- not a base table column (default ignored)
	,@PersonDocSID                   int               = null								-- not a base table column (default ignored)
	,@PersonMailingAddressSID        int               = null								-- not a base table column (default ignored)
	,@PersonStreetAddress1           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PersonStreetAddress2           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PersonStreetAddress3           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PersonCityName                 nvarchar(30)      = null								-- not a base table column (default ignored)
	,@PersonStateProvinceName        nvarchar(30)      = null								-- not a base table column (default ignored)
	,@PersonPostalCode               nvarchar(10)      = null								-- not a base table column (default ignored)
	,@PersonCountryName              nvarchar(50)      = null								-- not a base table column (default ignored)
	,@PersonCitySID                  int               = null								-- not a base table column (default ignored)
	,@RegistrationYearLabel          varchar(9)        = null								-- not a base table column (default ignored)
	,@RegistrantAuditLabel           nvarchar(80)      = null								-- not a base table column (default ignored)
	,@IsSendForReviewEnabled         bit               = null								-- not a base table column (default ignored)
	,@IsReviewInProgress             bit               = null								-- not a base table column (default ignored)
	,@IsReviewFormConfigured         bit               = null								-- not a base table column (default ignored)
	,@RecommendationLabel            nvarchar(20)      = null								-- not a base table column (default ignored)
	,@NewFormStatusSCD               varchar(25)       = null								-- not a base table column (default ignored)
	,@Reviewers                      xml               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAudit#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantAudit#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantAudit#Insert
			 @RegistrantSID                  = @RegistrantSID
			,@AuditTypeSID                   = @AuditTypeSID
			,@RegistrationYear               = @RegistrationYear
			,@FormVersionSID                 = @FormVersionSID
			,@FormResponseDraft              = @FormResponseDraft
			,@LastValidateTime               = @LastValidateTime
			,@AdminComments                  = @AdminComments
			,@NextFollowUp                   = @NextFollowUp
			,@PendingReviewers               = @PendingReviewers
			,@ReasonSID                      = @ReasonSID
			,@ConfirmationDraft              = @ConfirmationDraft
			,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
			,@ReviewReasonList               = @ReviewReasonList
			,@UserDefinedColumns             = @UserDefinedColumns
			,@RegistrantAuditXID             = @RegistrantAuditXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@AuditTypeLabel                 = @AuditTypeLabel
			,@AuditTypeCategory              = @AuditTypeCategory
			,@AuditTypeIsDefault             = @AuditTypeIsDefault
			,@AuditTypeIsActive              = @AuditTypeIsActive
			,@AuditTypeRowGUID               = @AuditTypeRowGUID
			,@PersonSID                      = @PersonSID
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
			,@FormSID                        = @FormSID
			,@VersionNo                      = @VersionNo
			,@RevisionNo                     = @RevisionNo
			,@IsSaveDisplayed                = @IsSaveDisplayed
			,@ApprovedTime                   = @ApprovedTime
			,@FormVersionRowGUID             = @FormVersionRowGUID
			,@ReasonGroupSID                 = @ReasonGroupSID
			,@ReasonName                     = @ReasonName
			,@ReasonCode                     = @ReasonCode
			,@ReasonSequence                 = @ReasonSequence
			,@ToolTip                        = @ToolTip
			,@ReasonIsActive                 = @ReasonIsActive
			,@ReasonRowGUID                  = @ReasonRowGUID
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@IsViewEnabled                  = @IsViewEnabled
			,@IsEditEnabled                  = @IsEditEnabled
			,@IsSaveBtnDisplayed             = @IsSaveBtnDisplayed
			,@IsApproveEnabled               = @IsApproveEnabled
			,@IsRejectEnabled                = @IsRejectEnabled
			,@IsUnlockEnabled                = @IsUnlockEnabled
			,@IsWithdrawalEnabled            = @IsWithdrawalEnabled
			,@IsInProgress                   = @IsInProgress
			,@IsReviewRequired               = @IsReviewRequired
			,@FormStatusSID                  = @FormStatusSID
			,@FormStatusSCD                  = @FormStatusSCD
			,@FormStatusLabel                = @FormStatusLabel
			,@LastStatusChangeUser           = @LastStatusChangeUser
			,@LastStatusChangeTime           = @LastStatusChangeTime
			,@FormOwnerSID                   = @FormOwnerSID
			,@FormOwnerSCD                   = @FormOwnerSCD
			,@FormOwnerLabel                 = @FormOwnerLabel
			,@IsPDFDisplayed                 = @IsPDFDisplayed
			,@PersonDocSID                   = @PersonDocSID
			,@PersonMailingAddressSID        = @PersonMailingAddressSID
			,@PersonStreetAddress1           = @PersonStreetAddress1
			,@PersonStreetAddress2           = @PersonStreetAddress2
			,@PersonStreetAddress3           = @PersonStreetAddress3
			,@PersonCityName                 = @PersonCityName
			,@PersonStateProvinceName        = @PersonStateProvinceName
			,@PersonPostalCode               = @PersonPostalCode
			,@PersonCountryName              = @PersonCountryName
			,@PersonCitySID                  = @PersonCitySID
			,@RegistrationYearLabel          = @RegistrationYearLabel
			,@RegistrantAuditLabel           = @RegistrantAuditLabel
			,@IsSendForReviewEnabled         = @IsSendForReviewEnabled
			,@IsReviewInProgress             = @IsReviewInProgress
			,@IsReviewFormConfigured         = @IsReviewFormConfigured
			,@RecommendationLabel            = @RecommendationLabel
			,@NewFormStatusSCD               = @NewFormStatusSCD
			,@Reviewers                      = @Reviewers

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
