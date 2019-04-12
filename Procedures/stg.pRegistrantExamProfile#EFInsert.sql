SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantExamProfile#EFInsert]
	 @ImportFileSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ProcessingStatusSID            int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrantNo                   varchar(50)       = null								
	,@EmailAddress                   varchar(150)      = null								
	,@FirstName                      nvarchar(30)      = null								
	,@LastName                       nvarchar(35)      = null								
	,@BirthDate                      date              = null								
	,@ExamIdentifier                 nvarchar(50)      = null								
	,@ExamDate                       date              = null								
	,@ExamTime                       time(0)           = null								
	,@OrgLabel                       nvarchar(35)      = null								
	,@ExamResultDate                 date              = null								
	,@PassingScore                   int               = null								
	,@Score                          int               = null								
	,@AssignedLocation               varchar(15)       = null								
	,@ExamReference                  varchar(25)       = null								
	,@PersonSID                      int               = null								
	,@RegistrantSID                  int               = null								
	,@OrgSID                         int               = null								
	,@ExamSID                        int               = null								
	,@ExamOfferingSID                int               = null								
	,@ProcessingComments             nvarchar(max)     = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantExamProfileXID       varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@FileFormatSID                  int               = null								-- not a base table column (default ignored)
	,@ApplicationEntitySID           int               = null								-- not a base table column (default ignored)
	,@FileName                       nvarchar(100)     = null								-- not a base table column (default ignored)
	,@LoadStartTime                  datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@LoadEndTime                    datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@IsFailed                       bit               = null								-- not a base table column (default ignored)
	,@MessageText                    nvarchar(4000)    = null								-- not a base table column (default ignored)
	,@ImportFileRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ProcessingStatusSCD            varchar(10)       = null								-- not a base table column (default ignored)
	,@ProcessingStatusLabel          nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsClosedStatus                 bit               = null								-- not a base table column (default ignored)
	,@ProcessingStatusIsActive       bit               = null								-- not a base table column (default ignored)
	,@ProcessingStatusIsDefault      bit               = null								-- not a base table column (default ignored)
	,@ProcessingStatusRowGUID        uniqueidentifier  = null								-- not a base table column (default ignored)
	,@GenderSID                      int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                  int               = null								-- not a base table column (default ignored)
	,@PersonFirstName                nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@PersonLastName                 nvarchar(35)      = null								-- not a base table column (default ignored)
	,@PersonBirthDate                date              = null								-- not a base table column (default ignored)
	,@DeathDate                      date              = null								-- not a base table column (default ignored)
	,@HomePhone                      varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled         bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                    nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ExamName                       nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ExamCategory                   nvarchar(65)      = null								-- not a base table column (default ignored)
	,@ExamPassingScore               int               = null								-- not a base table column (default ignored)
	,@EffectiveTime                  datetime          = null								-- not a base table column (default ignored)
	,@ExpiryTime                     datetime          = null								-- not a base table column (default ignored)
	,@IsOnlineExam                   bit               = null								-- not a base table column (default ignored)
	,@IsEnabledOnPortal              bit               = null								-- not a base table column (default ignored)
	,@Sequence                       int               = null								-- not a base table column (default ignored)
	,@CultureSID                     int               = null								-- not a base table column (default ignored)
	,@ExamLastVerifiedTime           datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@MinLagDaysBetweenAttempts      smallint          = null								-- not a base table column (default ignored)
	,@MaxAttemptsPerYear             tinyint           = null								-- not a base table column (default ignored)
	,@VendorExamID                   varchar(25)       = null								-- not a base table column (default ignored)
	,@ExamRowGUID                    uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ExamOfferingExamSID            int               = null								-- not a base table column (default ignored)
	,@ExamOfferingOrgSID             int               = null								-- not a base table column (default ignored)
	,@ExamOfferingExamTime           datetime          = null								-- not a base table column (default ignored)
	,@SeatingCapacity                int               = null								-- not a base table column (default ignored)
	,@CatalogItemSID                 int               = null								-- not a base table column (default ignored)
	,@BookingCutOffDate              date              = null								-- not a base table column (default ignored)
	,@VendorExamOfferingID           varchar(25)       = null								-- not a base table column (default ignored)
	,@ExamOfferingRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ParentOrgSID                   int               = null								-- not a base table column (default ignored)
	,@OrgTypeSID                     int               = null								-- not a base table column (default ignored)
	,@OrgName                        nvarchar(150)     = null								-- not a base table column (default ignored)
	,@OrgOrgLabel                    nvarchar(35)      = null								-- not a base table column (default ignored)
	,@StreetAddress1                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress2                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress3                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@CitySID                        int               = null								-- not a base table column (default ignored)
	,@PostalCode                     varchar(10)       = null								-- not a base table column (default ignored)
	,@RegionSID                      int               = null								-- not a base table column (default ignored)
	,@Phone                          varchar(25)       = null								-- not a base table column (default ignored)
	,@Fax                            varchar(25)       = null								-- not a base table column (default ignored)
	,@WebSite                        varchar(250)      = null								-- not a base table column (default ignored)
	,@OrgEmailAddress                varchar(150)      = null								-- not a base table column (default ignored)
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
	,@OrgLastVerifiedTime            datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@OrgRowGUID                     uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegistrantPersonSID            int               = null								-- not a base table column (default ignored)
	,@RegistrantRegistrantNo         varchar(50)       = null								-- not a base table column (default ignored)
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
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@RegistrantLabel                nvarchar(75)      = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantExamProfile#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantExamProfile#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = stg.pRegistrantExamProfile#Insert
			 @ImportFileSID                  = @ImportFileSID
			,@ProcessingStatusSID            = @ProcessingStatusSID
			,@RegistrantNo                   = @RegistrantNo
			,@EmailAddress                   = @EmailAddress
			,@FirstName                      = @FirstName
			,@LastName                       = @LastName
			,@BirthDate                      = @BirthDate
			,@ExamIdentifier                 = @ExamIdentifier
			,@ExamDate                       = @ExamDate
			,@ExamTime                       = @ExamTime
			,@OrgLabel                       = @OrgLabel
			,@ExamResultDate                 = @ExamResultDate
			,@PassingScore                   = @PassingScore
			,@Score                          = @Score
			,@AssignedLocation               = @AssignedLocation
			,@ExamReference                  = @ExamReference
			,@PersonSID                      = @PersonSID
			,@RegistrantSID                  = @RegistrantSID
			,@OrgSID                         = @OrgSID
			,@ExamSID                        = @ExamSID
			,@ExamOfferingSID                = @ExamOfferingSID
			,@ProcessingComments             = @ProcessingComments
			,@UserDefinedColumns             = @UserDefinedColumns
			,@RegistrantExamProfileXID       = @RegistrantExamProfileXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@FileFormatSID                  = @FileFormatSID
			,@ApplicationEntitySID           = @ApplicationEntitySID
			,@FileName                       = @FileName
			,@LoadStartTime                  = @LoadStartTime
			,@LoadEndTime                    = @LoadEndTime
			,@IsFailed                       = @IsFailed
			,@MessageText                    = @MessageText
			,@ImportFileRowGUID              = @ImportFileRowGUID
			,@ProcessingStatusSCD            = @ProcessingStatusSCD
			,@ProcessingStatusLabel          = @ProcessingStatusLabel
			,@IsClosedStatus                 = @IsClosedStatus
			,@ProcessingStatusIsActive       = @ProcessingStatusIsActive
			,@ProcessingStatusIsDefault      = @ProcessingStatusIsDefault
			,@ProcessingStatusRowGUID        = @ProcessingStatusRowGUID
			,@GenderSID                      = @GenderSID
			,@NamePrefixSID                  = @NamePrefixSID
			,@PersonFirstName                = @PersonFirstName
			,@CommonName                     = @CommonName
			,@MiddleNames                    = @MiddleNames
			,@PersonLastName                 = @PersonLastName
			,@PersonBirthDate                = @PersonBirthDate
			,@DeathDate                      = @DeathDate
			,@HomePhone                      = @HomePhone
			,@MobilePhone                    = @MobilePhone
			,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
			,@ImportBatch                    = @ImportBatch
			,@PersonRowGUID                  = @PersonRowGUID
			,@ExamName                       = @ExamName
			,@ExamCategory                   = @ExamCategory
			,@ExamPassingScore               = @ExamPassingScore
			,@EffectiveTime                  = @EffectiveTime
			,@ExpiryTime                     = @ExpiryTime
			,@IsOnlineExam                   = @IsOnlineExam
			,@IsEnabledOnPortal              = @IsEnabledOnPortal
			,@Sequence                       = @Sequence
			,@CultureSID                     = @CultureSID
			,@ExamLastVerifiedTime           = @ExamLastVerifiedTime
			,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
			,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
			,@VendorExamID                   = @VendorExamID
			,@ExamRowGUID                    = @ExamRowGUID
			,@ExamOfferingExamSID            = @ExamOfferingExamSID
			,@ExamOfferingOrgSID             = @ExamOfferingOrgSID
			,@ExamOfferingExamTime           = @ExamOfferingExamTime
			,@SeatingCapacity                = @SeatingCapacity
			,@CatalogItemSID                 = @CatalogItemSID
			,@BookingCutOffDate              = @BookingCutOffDate
			,@VendorExamOfferingID           = @VendorExamOfferingID
			,@ExamOfferingRowGUID            = @ExamOfferingRowGUID
			,@ParentOrgSID                   = @ParentOrgSID
			,@OrgTypeSID                     = @OrgTypeSID
			,@OrgName                        = @OrgName
			,@OrgOrgLabel                    = @OrgOrgLabel
			,@StreetAddress1                 = @StreetAddress1
			,@StreetAddress2                 = @StreetAddress2
			,@StreetAddress3                 = @StreetAddress3
			,@CitySID                        = @CitySID
			,@PostalCode                     = @PostalCode
			,@RegionSID                      = @RegionSID
			,@Phone                          = @Phone
			,@Fax                            = @Fax
			,@WebSite                        = @WebSite
			,@OrgEmailAddress                = @OrgEmailAddress
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
			,@OrgLastVerifiedTime            = @OrgLastVerifiedTime
			,@OrgRowGUID                     = @OrgRowGUID
			,@RegistrantPersonSID            = @RegistrantPersonSID
			,@RegistrantRegistrantNo         = @RegistrantRegistrantNo
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
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@RegistrantLabel                = @RegistrantLabel

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
