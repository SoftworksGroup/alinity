SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pLearningPlanActivity#EFInsert]
	 @RegistrantLearningPlanSID      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@CompetenceTypeActivitySID      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@UnitValue                      decimal(5,2)      = null								-- default: (1.0)
	,@CarryOverUnitValue             decimal(5,2)      = null								-- default: (0.0)
	,@ActivityDate                   date              = null								
	,@LearningClaimTypeSID           int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@LearningPlanActivityCategory   nvarchar(65)      = null								
	,@ActivityDescription            nvarchar(max)     = null								
	,@PlannedCompletion              date              = null								
	,@OrgSID                         int               = null								
	,@IsSubjectToReview              bit               = null								-- default: CONVERT(bit,(0))
	,@IsArchived                     bit               = null								-- default: CONVERT(bit,(0))
	,@UserDefinedColumns             xml               = null								
	,@LearningPlanActivityXID        varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@CompetenceTypeSID              int               = null								-- not a base table column (default ignored)
	,@CompetenceActivitySID          int               = null								-- not a base table column (default ignored)
	,@EffectiveTime                  datetime          = null								-- not a base table column (default ignored)
	,@ExpiryTime                     datetime          = null								-- not a base table column (default ignored)
	,@CompetenceTypeActivityRowGUID  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@LearningClaimTypeLabel         nvarchar(35)      = null								-- not a base table column (default ignored)
	,@LearningClaimTypeCategory      nvarchar(65)      = null								-- not a base table column (default ignored)
	,@IsValidForRenewal              bit               = null								-- not a base table column (default ignored)
	,@IsComplete                     bit               = null								-- not a base table column (default ignored)
	,@IsWithdrawn                    bit               = null								-- not a base table column (default ignored)
	,@LearningClaimTypeIsDefault     bit               = null								-- not a base table column (default ignored)
	,@LearningClaimTypeIsActive      bit               = null								-- not a base table column (default ignored)
	,@LearningClaimTypeRowGUID       uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegistrantSID                  int               = null								-- not a base table column (default ignored)
	,@RegistrationYear               smallint          = null								-- not a base table column (default ignored)
	,@LearningModelSID               int               = null								-- not a base table column (default ignored)
	,@FormVersionSID                 int               = null								-- not a base table column (default ignored)
	,@LastValidateTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@NextFollowUp                   date              = null								-- not a base table column (default ignored)
	,@ReasonSID                      int               = null								-- not a base table column (default ignored)
	,@IsAutoApprovalEnabled          bit               = null								-- not a base table column (default ignored)
	,@ParentRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegistrantLearningPlanRowGUID  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ParentOrgSID                   int               = null								-- not a base table column (default ignored)
	,@OrgTypeSID                     int               = null								-- not a base table column (default ignored)
	,@OrgName                        nvarchar(150)     = null								-- not a base table column (default ignored)
	,@OrgLabel                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@StreetAddress1                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress2                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress3                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@CitySID                        int               = null								-- not a base table column (default ignored)
	,@PostalCode                     varchar(10)       = null								-- not a base table column (default ignored)
	,@RegionSID                      int               = null								-- not a base table column (default ignored)
	,@Phone                          varchar(25)       = null								-- not a base table column (default ignored)
	,@Fax                            varchar(25)       = null								-- not a base table column (default ignored)
	,@WebSite                        varchar(250)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@InsuranceOrgSID                int               = null								-- not a base table column (default ignored)
	,@InsurancePolicyNo              varchar(25)       = null								-- not a base table column (default ignored)
	,@InsuranceAmount                decimal(11,2)     = null								-- not a base table column (default ignored)
	,@IsEmployer                     bit               = null								-- not a base table column (default ignored)
	,@IsCredentialAuthority          bit               = null								-- not a base table column (default ignored)
	,@IsInsurer                      bit               = null								-- not a base table column (default ignored)
	,@IsInsuranceCertificateRequired bit               = null								-- not a base table column (default ignored)
	,@IsPublic                       nchar(10)         = null								-- not a base table column (default ignored)
	,@OrgIsActive                    bit               = null								-- not a base table column (default ignored)
	,@IsAdminReviewRequired          bit               = null								-- not a base table column (default ignored)
	,@LastVerifiedTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@OrgRowGUID                     uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pLearningPlanActivity#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pLearningPlanActivity#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pLearningPlanActivity#Insert
			 @RegistrantLearningPlanSID      = @RegistrantLearningPlanSID
			,@CompetenceTypeActivitySID      = @CompetenceTypeActivitySID
			,@UnitValue                      = @UnitValue
			,@CarryOverUnitValue             = @CarryOverUnitValue
			,@ActivityDate                   = @ActivityDate
			,@LearningClaimTypeSID           = @LearningClaimTypeSID
			,@LearningPlanActivityCategory   = @LearningPlanActivityCategory
			,@ActivityDescription            = @ActivityDescription
			,@PlannedCompletion              = @PlannedCompletion
			,@OrgSID                         = @OrgSID
			,@IsSubjectToReview              = @IsSubjectToReview
			,@IsArchived                     = @IsArchived
			,@UserDefinedColumns             = @UserDefinedColumns
			,@LearningPlanActivityXID        = @LearningPlanActivityXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@CompetenceTypeSID              = @CompetenceTypeSID
			,@CompetenceActivitySID          = @CompetenceActivitySID
			,@EffectiveTime                  = @EffectiveTime
			,@ExpiryTime                     = @ExpiryTime
			,@CompetenceTypeActivityRowGUID  = @CompetenceTypeActivityRowGUID
			,@LearningClaimTypeLabel         = @LearningClaimTypeLabel
			,@LearningClaimTypeCategory      = @LearningClaimTypeCategory
			,@IsValidForRenewal              = @IsValidForRenewal
			,@IsComplete                     = @IsComplete
			,@IsWithdrawn                    = @IsWithdrawn
			,@LearningClaimTypeIsDefault     = @LearningClaimTypeIsDefault
			,@LearningClaimTypeIsActive      = @LearningClaimTypeIsActive
			,@LearningClaimTypeRowGUID       = @LearningClaimTypeRowGUID
			,@RegistrantSID                  = @RegistrantSID
			,@RegistrationYear               = @RegistrationYear
			,@LearningModelSID               = @LearningModelSID
			,@FormVersionSID                 = @FormVersionSID
			,@LastValidateTime               = @LastValidateTime
			,@NextFollowUp                   = @NextFollowUp
			,@ReasonSID                      = @ReasonSID
			,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
			,@ParentRowGUID                  = @ParentRowGUID
			,@RegistrantLearningPlanRowGUID  = @RegistrantLearningPlanRowGUID
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
			,@LastVerifiedTime               = @LastVerifiedTime
			,@OrgRowGUID                     = @OrgRowGUID
			,@IsDeleteEnabled                = @IsDeleteEnabled

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
