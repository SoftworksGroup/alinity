SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegister#EFInsert]
	 @PracticeRegisterTypeSID                  int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationScheduleSID                  int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterName                     nvarchar(65)      = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterLabel                    nvarchar(35)      = null			-- required! if not passed value must be set in custom logic prior to insert
	,@IsActivePractice                         bit               = null			-- default: (1)
	,@IsPublicRegistryEnabled                  bit               = null			-- default: (1)
	,@IsRenewalEnabled                         bit               = null			-- default: (1)
	,@IsLearningPlanEnabled                    bit               = null			-- default: (0)
	,@IsNextCEFormAutoAdded                    bit               = null			-- default: CONVERT(bit,(1))
	,@IsEligibleSupervisor                     bit               = null			-- default: CONVERT(bit,(0))
	,@IsSupervisionRequired                    bit               = null			-- default: CONVERT(bit,(0))
	,@IsEmploymentTerminated                   bit               = null			-- default: CONVERT(bit,(0))
	,@IsGroupMembershipTerminated              bit               = null			-- default: CONVERT(bit,(0))
	,@TermPermitDays                           int               = null			-- default: (0)
	,@RegisterRank                             smallint          = null			-- default: (500)
	,@LearningModelSID                         int               = null			
	,@ReasonGroupSID                           int               = null			
	,@IsDefault                                bit               = null			-- default: (0)
	,@IsDefaultInactivePractice                bit               = null			-- default: CONVERT(bit,(0))
	,@Description                              varbinary(max)    = null			
	,@IsActive                                 bit               = null			-- default: (1)
	,@UserDefinedColumns                       xml               = null			
	,@PracticeRegisterXID                      varchar(150)      = null			
	,@LegacyKey                                nvarchar(50)      = null			
	,@CreateUser                               nvarchar(75)      = null			-- default: suser_sname()
	,@IsReselected                             tinyint           = null			-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                 xml               = null			-- other values defining context for the insert (if any)
	,@PracticeRegisterTypeSCD                  varchar(15)       = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeLabel                nvarchar(35)      = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeCategory             nvarchar(65)      = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeIsDefault            bit               = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeIsActive             bit               = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeRowGUID              uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RegistrationScheduleLabel                nvarchar(35)      = null			-- not a base table column (default ignored)
	,@RegistrationScheduleIsDefault            bit               = null			-- not a base table column (default ignored)
	,@RegistrationScheduleIsActive             bit               = null			-- not a base table column (default ignored)
	,@RegistrationScheduleRowGUID              uniqueidentifier  = null			-- not a base table column (default ignored)
	,@LearningModelSCD                         varchar(15)       = null			-- not a base table column (default ignored)
	,@LearningModelLabel                       nvarchar(35)      = null			-- not a base table column (default ignored)
	,@LearningModelIsDefault                   bit               = null			-- not a base table column (default ignored)
	,@UnitTypeSID                              int               = null			-- not a base table column (default ignored)
	,@CycleLengthYears                         smallint          = null			-- not a base table column (default ignored)
	,@IsCycleStartedYear1                      bit               = null			-- not a base table column (default ignored)
	,@MaximumCarryOver                         decimal(5,2)      = null			-- not a base table column (default ignored)
	,@LearningModelRowGUID                     uniqueidentifier  = null			-- not a base table column (default ignored)
	,@ReasonGroupSCD                           varchar(20)       = null			-- not a base table column (default ignored)
	,@ReasonGroupLabel                         nvarchar(35)      = null			-- not a base table column (default ignored)
	,@IsLockedGroup                            bit               = null			-- not a base table column (default ignored)
	,@ReasonGroupRowGUID                       uniqueidentifier  = null			-- not a base table column (default ignored)
	,@IsDeleteEnabled                          bit               = null			-- not a base table column (default ignored)
	,@RegistrantAppFormVersionSID              int               = null			-- not a base table column (default ignored)
	,@RegistrantAppVerificationFormVersionSID  int               = null			-- not a base table column (default ignored)
	,@RegistrantRenewalFormVersionSID          int               = null			-- not a base table column (default ignored)
	,@RegistrantRenewalReviewFormVersionSID    int               = null			-- not a base table column (default ignored)
	,@CompetenceReviewFormVersionSID           int               = null			-- not a base table column (default ignored)
	,@CompetenceReviewAssessmentFormVersionSID int               = null			-- not a base table column (default ignored)
	,@CurrentRegistrationYear                  smallint          = null			-- not a base table column (default ignored)
	,@CurrentRenewalYear                       smallint          = null			-- not a base table column (default ignored)
	,@CurrentReinstatementYear                 smallint          = null			-- not a base table column (default ignored)
	,@NextReinstatementYear                    smallint          = null			-- not a base table column (default ignored)
	,@IsCurrentUserVerifier                    bit               = null			-- not a base table column (default ignored)
	,@IsLearningModelApplied                   bit               = null			-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegister#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPracticeRegister#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pPracticeRegister#Insert
			 @PracticeRegisterTypeSID                  = @PracticeRegisterTypeSID
			,@RegistrationScheduleSID                  = @RegistrationScheduleSID
			,@PracticeRegisterName                     = @PracticeRegisterName
			,@PracticeRegisterLabel                    = @PracticeRegisterLabel
			,@IsActivePractice                         = @IsActivePractice
			,@IsPublicRegistryEnabled                  = @IsPublicRegistryEnabled
			,@IsRenewalEnabled                         = @IsRenewalEnabled
			,@IsLearningPlanEnabled                    = @IsLearningPlanEnabled
			,@IsNextCEFormAutoAdded                    = @IsNextCEFormAutoAdded
			,@IsEligibleSupervisor                     = @IsEligibleSupervisor
			,@IsSupervisionRequired                    = @IsSupervisionRequired
			,@IsEmploymentTerminated                   = @IsEmploymentTerminated
			,@IsGroupMembershipTerminated              = @IsGroupMembershipTerminated
			,@TermPermitDays                           = @TermPermitDays
			,@RegisterRank                             = @RegisterRank
			,@LearningModelSID                         = @LearningModelSID
			,@ReasonGroupSID                           = @ReasonGroupSID
			,@IsDefault                                = @IsDefault
			,@IsDefaultInactivePractice                = @IsDefaultInactivePractice
			,@Description                              = @Description
			,@IsActive                                 = @IsActive
			,@UserDefinedColumns                       = @UserDefinedColumns
			,@PracticeRegisterXID                      = @PracticeRegisterXID
			,@LegacyKey                                = @LegacyKey
			,@CreateUser                               = @CreateUser
			,@IsReselected                             = @IsReselected
			,@zContext                                 = @zContext
			,@PracticeRegisterTypeSCD                  = @PracticeRegisterTypeSCD
			,@PracticeRegisterTypeLabel                = @PracticeRegisterTypeLabel
			,@PracticeRegisterTypeCategory             = @PracticeRegisterTypeCategory
			,@PracticeRegisterTypeIsDefault            = @PracticeRegisterTypeIsDefault
			,@PracticeRegisterTypeIsActive             = @PracticeRegisterTypeIsActive
			,@PracticeRegisterTypeRowGUID              = @PracticeRegisterTypeRowGUID
			,@RegistrationScheduleLabel                = @RegistrationScheduleLabel
			,@RegistrationScheduleIsDefault            = @RegistrationScheduleIsDefault
			,@RegistrationScheduleIsActive             = @RegistrationScheduleIsActive
			,@RegistrationScheduleRowGUID              = @RegistrationScheduleRowGUID
			,@LearningModelSCD                         = @LearningModelSCD
			,@LearningModelLabel                       = @LearningModelLabel
			,@LearningModelIsDefault                   = @LearningModelIsDefault
			,@UnitTypeSID                              = @UnitTypeSID
			,@CycleLengthYears                         = @CycleLengthYears
			,@IsCycleStartedYear1                      = @IsCycleStartedYear1
			,@MaximumCarryOver                         = @MaximumCarryOver
			,@LearningModelRowGUID                     = @LearningModelRowGUID
			,@ReasonGroupSCD                           = @ReasonGroupSCD
			,@ReasonGroupLabel                         = @ReasonGroupLabel
			,@IsLockedGroup                            = @IsLockedGroup
			,@ReasonGroupRowGUID                       = @ReasonGroupRowGUID
			,@IsDeleteEnabled                          = @IsDeleteEnabled
			,@RegistrantAppFormVersionSID              = @RegistrantAppFormVersionSID
			,@RegistrantAppVerificationFormVersionSID  = @RegistrantAppVerificationFormVersionSID
			,@RegistrantRenewalFormVersionSID          = @RegistrantRenewalFormVersionSID
			,@RegistrantRenewalReviewFormVersionSID    = @RegistrantRenewalReviewFormVersionSID
			,@CompetenceReviewFormVersionSID           = @CompetenceReviewFormVersionSID
			,@CompetenceReviewAssessmentFormVersionSID = @CompetenceReviewAssessmentFormVersionSID
			,@CurrentRegistrationYear                  = @CurrentRegistrationYear
			,@CurrentRenewalYear                       = @CurrentRenewalYear
			,@CurrentReinstatementYear                 = @CurrentReinstatementYear
			,@NextReinstatementYear                    = @NextReinstatementYear
			,@IsCurrentUserVerifier                    = @IsCurrentUserVerifier
			,@IsLearningModelApplied                   = @IsLearningModelApplied

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
