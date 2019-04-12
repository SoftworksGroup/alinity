SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantCredential#EFInsert]
	 @RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@CredentialSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@OrgSID                         int               = null								
	,@ProgramName                    nvarchar(65)      = null								
	,@ProgramStartDate               date              = null								
	,@ProgramTargetCompletionDate    date              = null								
	,@EffectiveTime                  datetime          = null								
	,@ExpiryTime                     datetime          = null								
	,@FieldOfStudySID                int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns             xml               = null								
	,@RegistrantCredentialXID        varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@CredentialTypeSID              int               = null								-- not a base table column (default ignored)
	,@CredentialLabel                nvarchar(35)      = null								-- not a base table column (default ignored)
	,@ToolTip                        nvarchar(500)     = null								-- not a base table column (default ignored)
	,@IsRelatedToProfession          bit               = null								-- not a base table column (default ignored)
	,@IsProgramRequired              bit               = null								-- not a base table column (default ignored)
	,@IsSpecialization               bit               = null								-- not a base table column (default ignored)
	,@CredentialIsActive             bit               = null								-- not a base table column (default ignored)
	,@CredentialCode                 varchar(15)       = null								-- not a base table column (default ignored)
	,@CredentialRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@FieldOfStudyName               nvarchar(50)      = null								-- not a base table column (default ignored)
	,@FieldOfStudyCode               varchar(20)       = null								-- not a base table column (default ignored)
	,@FieldOfStudyCategory           nvarchar(65)      = null								-- not a base table column (default ignored)
	,@FieldOfStudyIsDefault          bit               = null								-- not a base table column (default ignored)
	,@FieldOfStudyIsActive           bit               = null								-- not a base table column (default ignored)
	,@FieldOfStudyRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
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
	,@IsActive                       bit               = null								-- not a base table column (default ignored)
	,@IsPending                      bit               = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsQualifying                   bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantCredential#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantCredential#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantCredential#Insert
			 @RegistrantSID                  = @RegistrantSID
			,@CredentialSID                  = @CredentialSID
			,@OrgSID                         = @OrgSID
			,@ProgramName                    = @ProgramName
			,@ProgramStartDate               = @ProgramStartDate
			,@ProgramTargetCompletionDate    = @ProgramTargetCompletionDate
			,@EffectiveTime                  = @EffectiveTime
			,@ExpiryTime                     = @ExpiryTime
			,@FieldOfStudySID                = @FieldOfStudySID
			,@UserDefinedColumns             = @UserDefinedColumns
			,@RegistrantCredentialXID        = @RegistrantCredentialXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@CredentialTypeSID              = @CredentialTypeSID
			,@CredentialLabel                = @CredentialLabel
			,@ToolTip                        = @ToolTip
			,@IsRelatedToProfession          = @IsRelatedToProfession
			,@IsProgramRequired              = @IsProgramRequired
			,@IsSpecialization               = @IsSpecialization
			,@CredentialIsActive             = @CredentialIsActive
			,@CredentialCode                 = @CredentialCode
			,@CredentialRowGUID              = @CredentialRowGUID
			,@FieldOfStudyName               = @FieldOfStudyName
			,@FieldOfStudyCode               = @FieldOfStudyCode
			,@FieldOfStudyCategory           = @FieldOfStudyCategory
			,@FieldOfStudyIsDefault          = @FieldOfStudyIsDefault
			,@FieldOfStudyIsActive           = @FieldOfStudyIsActive
			,@FieldOfStudyRowGUID            = @FieldOfStudyRowGUID
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
			,@IsActive                       = @IsActive
			,@IsPending                      = @IsPending
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@IsQualifying                   = @IsQualifying

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
