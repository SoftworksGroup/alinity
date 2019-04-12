SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#EFInsert]
	 @RegistrantSID                     int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                  smallint          = null						-- required! if not passed value must be set in custom logic prior to insert
	,@LearningModelSID                  int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@FormVersionSID                    int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@LastValidateTime                  datetimeoffset(7) = null						
	,@FormResponseDraft                 xml               = null						-- default: CONVERT(xml,N'<FormResponses />')
	,@AdminComments                     xml               = null						-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp                      date              = null						
	,@ConfirmationDraft                 nvarchar(max)     = null						
	,@ReasonSID                         int               = null						
	,@IsAutoApprovalEnabled             bit               = null						-- default: CONVERT(bit,(0))
	,@ReviewReasonList                  xml               = null						
	,@ParentRowGUID                     uniqueidentifier  = null						
	,@UserDefinedColumns                xml               = null						
	,@RegistrantLearningPlanXID         varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@LearningModelSCD                  varchar(15)       = null						-- not a base table column (default ignored)
	,@LearningModelLabel                nvarchar(35)      = null						-- not a base table column (default ignored)
	,@LearningModelIsDefault            bit               = null						-- not a base table column (default ignored)
	,@UnitTypeSID                       int               = null						-- not a base table column (default ignored)
	,@CycleLengthYears                  smallint          = null						-- not a base table column (default ignored)
	,@IsCycleStartedYear1               bit               = null						-- not a base table column (default ignored)
	,@MaximumCarryOver                  decimal(5,2)      = null						-- not a base table column (default ignored)
	,@LearningModelRowGUID              uniqueidentifier  = null						-- not a base table column (default ignored)
	,@PersonSID                         int               = null						-- not a base table column (default ignored)
	,@RegistrantNo                      varchar(50)       = null						-- not a base table column (default ignored)
	,@YearOfInitialEmployment           smallint          = null						-- not a base table column (default ignored)
	,@IsOnPublicRegistry                bit               = null						-- not a base table column (default ignored)
	,@CityNameOfBirth                   nvarchar(30)      = null						-- not a base table column (default ignored)
	,@CountrySID                        int               = null						-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence       smallint          = null						-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours    smallint          = null						-- not a base table column (default ignored)
	,@LateFeeExclusionYear              smallint          = null						-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked      bit               = null						-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime        datetime          = null						-- not a base table column (default ignored)
	,@ArchivedTime                      datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@RegistrantRowGUID                 uniqueidentifier  = null						-- not a base table column (default ignored)
	,@FormSID                           int               = null						-- not a base table column (default ignored)
	,@VersionNo                         smallint          = null						-- not a base table column (default ignored)
	,@RevisionNo                        smallint          = null						-- not a base table column (default ignored)
	,@IsSaveDisplayed                   bit               = null						-- not a base table column (default ignored)
	,@ApprovedTime                      datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@FormVersionRowGUID                uniqueidentifier  = null						-- not a base table column (default ignored)
	,@ReasonGroupSID                    int               = null						-- not a base table column (default ignored)
	,@ReasonName                        nvarchar(50)      = null						-- not a base table column (default ignored)
	,@ReasonCode                        varchar(25)       = null						-- not a base table column (default ignored)
	,@ReasonSequence                    smallint          = null						-- not a base table column (default ignored)
	,@ToolTip                           nvarchar(500)     = null						-- not a base table column (default ignored)
	,@ReasonIsActive                    bit               = null						-- not a base table column (default ignored)
	,@ReasonRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsViewEnabled                     bit               = null						-- not a base table column (default ignored)
	,@IsEditEnabled                     bit               = null						-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed                bit               = null						-- not a base table column (default ignored)
	,@IsApproveEnabled                  bit               = null						-- not a base table column (default ignored)
	,@IsRejectEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsUnlockEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsWithdrawalEnabled               bit               = null						-- not a base table column (default ignored)
	,@IsInProgress                      bit               = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanStatusSID   int               = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanStatusSCD   varchar(25)       = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanStatusLabel nvarchar(35)      = null						-- not a base table column (default ignored)
	,@LastStatusChangeUser              nvarchar(75)      = null						-- not a base table column (default ignored)
	,@LastStatusChangeTime              datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@FormOwnerSCD                      varchar(25)       = null						-- not a base table column (default ignored)
	,@FormOwnerLabel                    nvarchar(35)      = null						-- not a base table column (default ignored)
	,@FormOwnerSID                      int               = null						-- not a base table column (default ignored)
	,@IsPDFDisplayed                    bit               = null						-- not a base table column (default ignored)
	,@PersonDocSID                      int               = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanLabel       nvarchar(80)      = null						-- not a base table column (default ignored)
	,@RegistrationYearLabel             nvarchar(9)       = null						-- not a base table column (default ignored)
	,@CycleEndRegistrationYear          smallint          = null						-- not a base table column (default ignored)
	,@CycleRegistrationYearLabel        nvarchar(21)      = null						-- not a base table column (default ignored)
	,@NewFormStatusSCD                  varchar(25)       = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantLearningPlan#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantLearningPlan#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantLearningPlan#Insert
			 @RegistrantSID                     = @RegistrantSID
			,@RegistrationYear                  = @RegistrationYear
			,@LearningModelSID                  = @LearningModelSID
			,@FormVersionSID                    = @FormVersionSID
			,@LastValidateTime                  = @LastValidateTime
			,@FormResponseDraft                 = @FormResponseDraft
			,@AdminComments                     = @AdminComments
			,@NextFollowUp                      = @NextFollowUp
			,@ConfirmationDraft                 = @ConfirmationDraft
			,@ReasonSID                         = @ReasonSID
			,@IsAutoApprovalEnabled             = @IsAutoApprovalEnabled
			,@ReviewReasonList                  = @ReviewReasonList
			,@ParentRowGUID                     = @ParentRowGUID
			,@UserDefinedColumns                = @UserDefinedColumns
			,@RegistrantLearningPlanXID         = @RegistrantLearningPlanXID
			,@LegacyKey                         = @LegacyKey
			,@CreateUser                        = @CreateUser
			,@IsReselected                      = @IsReselected
			,@zContext                          = @zContext
			,@LearningModelSCD                  = @LearningModelSCD
			,@LearningModelLabel                = @LearningModelLabel
			,@LearningModelIsDefault            = @LearningModelIsDefault
			,@UnitTypeSID                       = @UnitTypeSID
			,@CycleLengthYears                  = @CycleLengthYears
			,@IsCycleStartedYear1               = @IsCycleStartedYear1
			,@MaximumCarryOver                  = @MaximumCarryOver
			,@LearningModelRowGUID              = @LearningModelRowGUID
			,@PersonSID                         = @PersonSID
			,@RegistrantNo                      = @RegistrantNo
			,@YearOfInitialEmployment           = @YearOfInitialEmployment
			,@IsOnPublicRegistry                = @IsOnPublicRegistry
			,@CityNameOfBirth                   = @CityNameOfBirth
			,@CountrySID                        = @CountrySID
			,@DirectedAuditYearCompetence       = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours    = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear              = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked      = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime        = @RenewalExtensionExpiryTime
			,@ArchivedTime                      = @ArchivedTime
			,@RegistrantRowGUID                 = @RegistrantRowGUID
			,@FormSID                           = @FormSID
			,@VersionNo                         = @VersionNo
			,@RevisionNo                        = @RevisionNo
			,@IsSaveDisplayed                   = @IsSaveDisplayed
			,@ApprovedTime                      = @ApprovedTime
			,@FormVersionRowGUID                = @FormVersionRowGUID
			,@ReasonGroupSID                    = @ReasonGroupSID
			,@ReasonName                        = @ReasonName
			,@ReasonCode                        = @ReasonCode
			,@ReasonSequence                    = @ReasonSequence
			,@ToolTip                           = @ToolTip
			,@ReasonIsActive                    = @ReasonIsActive
			,@ReasonRowGUID                     = @ReasonRowGUID
			,@IsDeleteEnabled                   = @IsDeleteEnabled
			,@IsViewEnabled                     = @IsViewEnabled
			,@IsEditEnabled                     = @IsEditEnabled
			,@IsSaveBtnDisplayed                = @IsSaveBtnDisplayed
			,@IsApproveEnabled                  = @IsApproveEnabled
			,@IsRejectEnabled                   = @IsRejectEnabled
			,@IsUnlockEnabled                   = @IsUnlockEnabled
			,@IsWithdrawalEnabled               = @IsWithdrawalEnabled
			,@IsInProgress                      = @IsInProgress
			,@RegistrantLearningPlanStatusSID   = @RegistrantLearningPlanStatusSID
			,@RegistrantLearningPlanStatusSCD   = @RegistrantLearningPlanStatusSCD
			,@RegistrantLearningPlanStatusLabel = @RegistrantLearningPlanStatusLabel
			,@LastStatusChangeUser              = @LastStatusChangeUser
			,@LastStatusChangeTime              = @LastStatusChangeTime
			,@FormOwnerSCD                      = @FormOwnerSCD
			,@FormOwnerLabel                    = @FormOwnerLabel
			,@FormOwnerSID                      = @FormOwnerSID
			,@IsPDFDisplayed                    = @IsPDFDisplayed
			,@PersonDocSID                      = @PersonDocSID
			,@RegistrantLearningPlanLabel       = @RegistrantLearningPlanLabel
			,@RegistrationYearLabel             = @RegistrationYearLabel
			,@CycleEndRegistrationYear          = @CycleEndRegistrationYear
			,@CycleRegistrationYearLabel        = @CycleRegistrationYearLabel
			,@NewFormStatusSCD                  = @NewFormStatusSCD

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
