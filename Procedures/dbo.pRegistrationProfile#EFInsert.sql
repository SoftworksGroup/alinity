SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationProfile#EFInsert]
	 @RegistrationSnapshotSID                                   int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@JursidictionStateProvinceISONumber                        smallint          = null							-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrantSID                                             int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrantNo                                              varchar(50)       = null							-- required! if not passed value must be set in custom logic prior to insert
	,@GenderSCD                                                 char(1)           = null							-- required! if not passed value must be set in custom logic prior to insert
	,@BirthDate                                                 date              = null							
	,@PersonMailingAddressSID                                   int               = null							
	,@ResidenceStateProvinceISONumber                           smallint          = null							
	,@ResidencePostalCode                                       varchar(10)       = null							
	,@ResidenceCountryISONumber                                 smallint          = null							
	,@ResidenceIsDefaultCountry                                 bit               = null							-- default: CONVERT(bit,(0))
	,@RegistrationSID                                           int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@IsActivePractice                                          bit               = null							-- default: (0)
	,@Education1RegistrantCredentialSID                         int               = null							
	,@Education1CredentialCode                                  varchar(15)       = null							
	,@Education1GraduationYear                                  smallint          = null							
	,@Education1StateProvinceISONumber                          smallint          = null							
	,@Education1CountryISONumber                                smallint          = null							
	,@Education1IsDefaultCountry                                bit               = null							-- default: CONVERT(bit,(0))
	,@Education2RegistrantCredentialSID                         int               = null							
	,@Education2CredentialCode                                  varchar(15)       = null							
	,@Education2GraduationYear                                  smallint          = null							
	,@Education2StateProvinceISONumber                          smallint          = null							
	,@Education2CountryISONumber                                smallint          = null							
	,@Education2IsDefaultCountry                                bit               = null							-- default: CONVERT(bit,(0))
	,@Education3RegistrantCredentialSID                         int               = null							
	,@Education3CredentialCode                                  varchar(15)       = null							
	,@Education3GraduationYear                                  smallint          = null							
	,@Education3StateProvinceISONumber                          smallint          = null							
	,@Education3CountryISONumber                                smallint          = null							
	,@Education3IsDefaultCountry                                bit               = null							-- default: CONVERT(bit,(0))
	,@RegistrantPracticeSID                                     int               = null							
	,@EmploymentStatusCode                                      varchar(20)       = null							
	,@EmploymentCount                                           smallint          = null							
	,@PracticeHours                                             smallint          = null							-- default: (0)
	,@Employment1RegistrantEmploymentSID                        int               = null							
	,@Employment1TypeCode                                       varchar(20)       = null							
	,@Employment1StateProvinceISONumber                         smallint          = null							
	,@Employment1CountryISONumber                               smallint          = null							
	,@Employment1IsDefaultCountry                               bit               = null							-- default: CONVERT(bit,(0))
	,@Employment1PostalCode                                     varchar(10)       = null							
	,@Employment1OrgTypeCode                                    varchar(20)       = null							
	,@Employment1PracticeAreaCode                               varchar(20)       = null							
	,@Employment1PracticeScopeCode                              varchar(20)       = null							
	,@Employment1RoleCode                                       varchar(20)       = null							
	,@Employment2RegistrantEmploymentSID                        int               = null							
	,@Employment2TypeCode                                       varchar(20)       = null							
	,@Employment2StateProvinceISONumber                         smallint          = null							
	,@Employment2IsDefaultCountry                               bit               = null							-- default: CONVERT(bit,(0))
	,@Employment2CountryISONumber                               smallint          = null							
	,@Employment2PostalCode                                     varchar(10)       = null							
	,@Employment2OrgTypeCode                                    varchar(20)       = null							
	,@Employment2PracticeAreaCode                               varchar(20)       = null							
	,@Employment2PracticeScopeCode                              varchar(20)       = null							
	,@Employment2RoleCode                                       varchar(20)       = null							
	,@Employment3RegistrantEmploymentSID                        int               = null							
	,@Employment3TypeCode                                       varchar(20)       = null							
	,@Employment3StateProvinceISONumber                         smallint          = null							
	,@Employment3CountryISONumber                               smallint          = null							
	,@Employment3IsDefaultCountry                               bit               = null							-- default: CONVERT(bit,(0))
	,@Employment3PostalCode                                     varchar(10)       = null							
	,@Employment3OrgTypeCode                                    varchar(20)       = null							
	,@Employment3PracticeAreaCode                               varchar(20)       = null							
	,@Employment3PracticeScopeCode                              varchar(20)       = null							
	,@Employment3RoleCode                                       varchar(20)       = null							
	,@IsInvalid                                                 bit               = null							-- default: CONVERT(bit,(0))
	,@MessageText                                               nvarchar(4000)    = null							
	,@CheckSumOnLastExport                                      int               = null							
	,@UserDefinedColumns                                        xml               = null							
	,@RegistrationProfileXID                                    varchar(150)      = null							
	,@LegacyKey                                                 nvarchar(50)      = null							
	,@CreateUser                                                nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                                              tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                                  xml               = null							-- other values defining context for the insert (if any)
	,@RegistrantPersonSID                                       int               = null							-- not a base table column (default ignored)
	,@RegistrantRegistrantNo                                    varchar(50)       = null							-- not a base table column (default ignored)
	,@YearOfInitialEmployment                                   smallint          = null							-- not a base table column (default ignored)
	,@RegistrantIsOnPublicRegistry                              bit               = null							-- not a base table column (default ignored)
	,@CityNameOfBirth                                           nvarchar(30)      = null							-- not a base table column (default ignored)
	,@CountrySID                                                int               = null							-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence                               smallint          = null							-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours                            smallint          = null							-- not a base table column (default ignored)
	,@LateFeeExclusionYear                                      smallint          = null							-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked                              bit               = null							-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime                                datetime          = null							-- not a base table column (default ignored)
	,@ArchivedTime                                              datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@RegistrantRowGUID                                         uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrationRegistrantSID                                 int               = null							-- not a base table column (default ignored)
	,@PracticeRegisterSectionSID                                int               = null							-- not a base table column (default ignored)
	,@RegistrationNo                                            nvarchar(50)      = null							-- not a base table column (default ignored)
	,@RegistrationRegistrationYear                              smallint          = null							-- not a base table column (default ignored)
	,@RegistrationEffectiveTime                                 datetime          = null							-- not a base table column (default ignored)
	,@RegistrationExpiryTime                                    datetime          = null							-- not a base table column (default ignored)
	,@CardPrintedTime                                           datetime          = null							-- not a base table column (default ignored)
	,@InvoiceSID                                                int               = null							-- not a base table column (default ignored)
	,@ReasonSID                                                 int               = null							-- not a base table column (default ignored)
	,@FormGUID                                                  uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrationRowGUID                                       uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrationSnapshotTypeSID                               int               = null							-- not a base table column (default ignored)
	,@RegistrationSnapshotLabel                                 nvarchar(35)      = null							-- not a base table column (default ignored)
	,@RegistrationSnapshotRegistrationYear                      smallint          = null							-- not a base table column (default ignored)
	,@QueuedTime                                                datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LockedTime                                                datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastCodeUpdateTime                                        datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@RegistrationSnapshotLastVerifiedTime                      datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@JobRunSID                                                 int               = null							-- not a base table column (default ignored)
	,@RegistrationSnapshotRowGUID                               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@PersonMailingAddressPersonSID                             int               = null							-- not a base table column (default ignored)
	,@StreetAddress1                                            nvarchar(75)      = null							-- not a base table column (default ignored)
	,@StreetAddress2                                            nvarchar(75)      = null							-- not a base table column (default ignored)
	,@StreetAddress3                                            nvarchar(75)      = null							-- not a base table column (default ignored)
	,@CitySID                                                   int               = null							-- not a base table column (default ignored)
	,@PostalCode                                                varchar(10)       = null							-- not a base table column (default ignored)
	,@RegionSID                                                 int               = null							-- not a base table column (default ignored)
	,@PersonMailingAddressEffectiveTime                         datetime          = null							-- not a base table column (default ignored)
	,@IsAdminReviewRequired                                     bit               = null							-- not a base table column (default ignored)
	,@PersonMailingAddressLastVerifiedTime                      datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@PersonMailingAddressRowGUID                               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1RegistrantSID               int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1CredentialSID               int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1OrgSID                      int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1ProgramName                 nvarchar(65)      = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1ProgramStartDate            date              = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1ProgramTargetCompletionDate date              = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1EffectiveTime               datetime          = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1ExpiryTime                  datetime          = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1FieldOfStudySID             int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation1RowGUID                     uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2RegistrantSID               int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2CredentialSID               int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2OrgSID                      int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2ProgramName                 nvarchar(65)      = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2ProgramStartDate            date              = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2ProgramTargetCompletionDate date              = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2EffectiveTime               datetime          = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2ExpiryTime                  datetime          = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2FieldOfStudySID             int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation2RowGUID                     uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3RegistrantSID               int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3CredentialSID               int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3OrgSID                      int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3ProgramName                 nvarchar(65)      = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3ProgramStartDate            date              = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3ProgramTargetCompletionDate date              = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3EffectiveTime               datetime          = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3ExpiryTime                  datetime          = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3FieldOfStudySID             int               = null							-- not a base table column (default ignored)
	,@RegistrantCredentialEducation3RowGUID                     uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1RegistrantSID              int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1OrgSID                     int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1RegistrationYear           smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1EmploymentTypeSID          int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1EmploymentRoleSID          int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1PracticeHours              int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1PracticeScopeSID           int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1AgeRangeSID                int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1IsOnPublicRegistry         bit               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1Phone                      varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1SiteLocation               nvarchar(50)      = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1EffectiveTime              datetime          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1ExpiryTime                 datetime          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1Rank                       smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1OwnershipPercentage        smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1IsEmployerInsurance        bit               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1InsuranceOrgSID            int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1InsurancePolicyNo          varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1InsuranceAmount            decimal(11,2)     = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment1RowGUID                    uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2RegistrantSID              int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2OrgSID                     int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2RegistrationYear           smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2EmploymentTypeSID          int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2EmploymentRoleSID          int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2PracticeHours              int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2PracticeScopeSID           int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2AgeRangeSID                int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2IsOnPublicRegistry         bit               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2Phone                      varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2SiteLocation               nvarchar(50)      = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2EffectiveTime              datetime          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2ExpiryTime                 datetime          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2Rank                       smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2OwnershipPercentage        smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2IsEmployerInsurance        bit               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2InsuranceOrgSID            int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2InsurancePolicyNo          varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2InsuranceAmount            decimal(11,2)     = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment2RowGUID                    uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3RegistrantSID              int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3OrgSID                     int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3RegistrationYear           smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3EmploymentTypeSID          int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3EmploymentRoleSID          int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3PracticeHours              int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3PracticeScopeSID           int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3AgeRangeSID                int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3IsOnPublicRegistry         bit               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3Phone                      varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3SiteLocation               nvarchar(50)      = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3EffectiveTime              datetime          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3ExpiryTime                 datetime          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3Rank                       smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3OwnershipPercentage        smallint          = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3IsEmployerInsurance        bit               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3InsuranceOrgSID            int               = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3InsurancePolicyNo          varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3InsuranceAmount            decimal(11,2)     = null							-- not a base table column (default ignored)
	,@RegistrantEmploymentEmployment3RowGUID                    uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantPracticeRegistrantSID                           int               = null							-- not a base table column (default ignored)
	,@RegistrantPracticeRegistrationYear                        smallint          = null							-- not a base table column (default ignored)
	,@EmploymentStatusSID                                       int               = null							-- not a base table column (default ignored)
	,@PlannedRetirementDate                                     date              = null							-- not a base table column (default ignored)
	,@OtherJurisdiction                                         nvarchar(100)     = null							-- not a base table column (default ignored)
	,@OtherJurisdictionHours                                    int               = null							-- not a base table column (default ignored)
	,@TotalPracticeHours                                        int               = null							-- not a base table column (default ignored)
	,@RegistrantPracticeOrgSID                                  int               = null							-- not a base table column (default ignored)
	,@RegistrantPracticeInsurancePolicyNo                       varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantPracticeInsuranceAmount                         decimal(11,2)     = null							-- not a base table column (default ignored)
	,@InsuranceCertificateNo                                    varchar(25)       = null							-- not a base table column (default ignored)
	,@RegistrantPracticeRowGUID                                 uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                                           bit               = null							-- not a base table column (default ignored)
	,@RegistrantLabel                                           nvarchar(75)      = null							-- not a base table column (default ignored)
	,@FirstName                                                 nvarchar(30)      = null							-- not a base table column (default ignored)
	,@CommonName                                                nvarchar(30)      = null							-- not a base table column (default ignored)
	,@MiddleNames                                               nvarchar(30)      = null							-- not a base table column (default ignored)
	,@LastName                                                  nvarchar(35)      = null							-- not a base table column (default ignored)
	,@DeathDate                                                 date              = null							-- not a base table column (default ignored)
	,@HomePhone                                                 varchar(25)       = null							-- not a base table column (default ignored)
	,@MobilePhone                                               varchar(25)       = null							-- not a base table column (default ignored)
	,@IsValid                                                   bit               = null							-- not a base table column (default ignored)
	,@CIHIGenderCD                                              char(1)           = null							-- not a base table column (default ignored)
	,@CIHIBirthYear                                             int               = null							-- not a base table column (default ignored)
	,@CIHIEducation1CredentialCode                              varchar(15)       = null							-- not a base table column (default ignored)
	,@CIHIEducation1GraduationYear                              smallint          = null							-- not a base table column (default ignored)
	,@CIHIEducation1Location                                    smallint          = null							-- not a base table column (default ignored)
	,@CIHIEducation2CredentialCode                              varchar(15)       = null							-- not a base table column (default ignored)
	,@CIHIEducation3CredentialCode                              varchar(15)       = null							-- not a base table column (default ignored)
	,@CIHIEmploymentStatusCode                                  varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment1TypeCode                                   varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIMultipleEmploymentStatus                              char(1)           = null							-- not a base table column (default ignored)
	,@CIHIEmployment1Location                                   smallint          = null							-- not a base table column (default ignored)
	,@CIHIEmployment1OrgTypeCode                                varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment1PracticeAreaCode                           varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment1PracticeScopeCode                          varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment1RoleCode                                   varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIResidenceLocation                                     smallint          = null							-- not a base table column (default ignored)
	,@CIHIResidencePostalCode                                   varchar(8000)     = null							-- not a base table column (default ignored)
	,@CIHIEmployment1PostalCode                                 varchar(8000)     = null							-- not a base table column (default ignored)
	,@CIHIRegistrationYearMonth                                 char(6)           = null							-- not a base table column (default ignored)
	,@CIHIEmployment2PostalCode                                 varchar(8000)     = null							-- not a base table column (default ignored)
	,@CIHIEmployment2Location                                   smallint          = null							-- not a base table column (default ignored)
	,@CIHIEmployment2OrgTypeCode                                varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment2PracticeAreaCode                           varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment2PracticeScopeCode                          varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment2RoleCode                                   varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment3PostalCode                                 varchar(8000)     = null							-- not a base table column (default ignored)
	,@CIHIEmployment3Location                                   smallint          = null							-- not a base table column (default ignored)
	,@CIHIEmployment3OrgTypeCode                                varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment3PracticeAreaCode                           varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment3PracticeScopeCode                          varchar(20)       = null							-- not a base table column (default ignored)
	,@CIHIEmployment3RoleCode                                   varchar(20)       = null							-- not a base table column (default ignored)
	,@CurrentCheckSum                                           int               = null							-- not a base table column (default ignored)
	,@IsModified                                                bit               = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationProfile#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrationProfile#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrationProfile#Insert
			 @RegistrationSnapshotSID                                   = @RegistrationSnapshotSID
			,@JursidictionStateProvinceISONumber                        = @JursidictionStateProvinceISONumber
			,@RegistrantSID                                             = @RegistrantSID
			,@RegistrantNo                                              = @RegistrantNo
			,@GenderSCD                                                 = @GenderSCD
			,@BirthDate                                                 = @BirthDate
			,@PersonMailingAddressSID                                   = @PersonMailingAddressSID
			,@ResidenceStateProvinceISONumber                           = @ResidenceStateProvinceISONumber
			,@ResidencePostalCode                                       = @ResidencePostalCode
			,@ResidenceCountryISONumber                                 = @ResidenceCountryISONumber
			,@ResidenceIsDefaultCountry                                 = @ResidenceIsDefaultCountry
			,@RegistrationSID                                           = @RegistrationSID
			,@IsActivePractice                                          = @IsActivePractice
			,@Education1RegistrantCredentialSID                         = @Education1RegistrantCredentialSID
			,@Education1CredentialCode                                  = @Education1CredentialCode
			,@Education1GraduationYear                                  = @Education1GraduationYear
			,@Education1StateProvinceISONumber                          = @Education1StateProvinceISONumber
			,@Education1CountryISONumber                                = @Education1CountryISONumber
			,@Education1IsDefaultCountry                                = @Education1IsDefaultCountry
			,@Education2RegistrantCredentialSID                         = @Education2RegistrantCredentialSID
			,@Education2CredentialCode                                  = @Education2CredentialCode
			,@Education2GraduationYear                                  = @Education2GraduationYear
			,@Education2StateProvinceISONumber                          = @Education2StateProvinceISONumber
			,@Education2CountryISONumber                                = @Education2CountryISONumber
			,@Education2IsDefaultCountry                                = @Education2IsDefaultCountry
			,@Education3RegistrantCredentialSID                         = @Education3RegistrantCredentialSID
			,@Education3CredentialCode                                  = @Education3CredentialCode
			,@Education3GraduationYear                                  = @Education3GraduationYear
			,@Education3StateProvinceISONumber                          = @Education3StateProvinceISONumber
			,@Education3CountryISONumber                                = @Education3CountryISONumber
			,@Education3IsDefaultCountry                                = @Education3IsDefaultCountry
			,@RegistrantPracticeSID                                     = @RegistrantPracticeSID
			,@EmploymentStatusCode                                      = @EmploymentStatusCode
			,@EmploymentCount                                           = @EmploymentCount
			,@PracticeHours                                             = @PracticeHours
			,@Employment1RegistrantEmploymentSID                        = @Employment1RegistrantEmploymentSID
			,@Employment1TypeCode                                       = @Employment1TypeCode
			,@Employment1StateProvinceISONumber                         = @Employment1StateProvinceISONumber
			,@Employment1CountryISONumber                               = @Employment1CountryISONumber
			,@Employment1IsDefaultCountry                               = @Employment1IsDefaultCountry
			,@Employment1PostalCode                                     = @Employment1PostalCode
			,@Employment1OrgTypeCode                                    = @Employment1OrgTypeCode
			,@Employment1PracticeAreaCode                               = @Employment1PracticeAreaCode
			,@Employment1PracticeScopeCode                              = @Employment1PracticeScopeCode
			,@Employment1RoleCode                                       = @Employment1RoleCode
			,@Employment2RegistrantEmploymentSID                        = @Employment2RegistrantEmploymentSID
			,@Employment2TypeCode                                       = @Employment2TypeCode
			,@Employment2StateProvinceISONumber                         = @Employment2StateProvinceISONumber
			,@Employment2IsDefaultCountry                               = @Employment2IsDefaultCountry
			,@Employment2CountryISONumber                               = @Employment2CountryISONumber
			,@Employment2PostalCode                                     = @Employment2PostalCode
			,@Employment2OrgTypeCode                                    = @Employment2OrgTypeCode
			,@Employment2PracticeAreaCode                               = @Employment2PracticeAreaCode
			,@Employment2PracticeScopeCode                              = @Employment2PracticeScopeCode
			,@Employment2RoleCode                                       = @Employment2RoleCode
			,@Employment3RegistrantEmploymentSID                        = @Employment3RegistrantEmploymentSID
			,@Employment3TypeCode                                       = @Employment3TypeCode
			,@Employment3StateProvinceISONumber                         = @Employment3StateProvinceISONumber
			,@Employment3CountryISONumber                               = @Employment3CountryISONumber
			,@Employment3IsDefaultCountry                               = @Employment3IsDefaultCountry
			,@Employment3PostalCode                                     = @Employment3PostalCode
			,@Employment3OrgTypeCode                                    = @Employment3OrgTypeCode
			,@Employment3PracticeAreaCode                               = @Employment3PracticeAreaCode
			,@Employment3PracticeScopeCode                              = @Employment3PracticeScopeCode
			,@Employment3RoleCode                                       = @Employment3RoleCode
			,@IsInvalid                                                 = @IsInvalid
			,@MessageText                                               = @MessageText
			,@CheckSumOnLastExport                                      = @CheckSumOnLastExport
			,@UserDefinedColumns                                        = @UserDefinedColumns
			,@RegistrationProfileXID                                    = @RegistrationProfileXID
			,@LegacyKey                                                 = @LegacyKey
			,@CreateUser                                                = @CreateUser
			,@IsReselected                                              = @IsReselected
			,@zContext                                                  = @zContext
			,@RegistrantPersonSID                                       = @RegistrantPersonSID
			,@RegistrantRegistrantNo                                    = @RegistrantRegistrantNo
			,@YearOfInitialEmployment                                   = @YearOfInitialEmployment
			,@RegistrantIsOnPublicRegistry                              = @RegistrantIsOnPublicRegistry
			,@CityNameOfBirth                                           = @CityNameOfBirth
			,@CountrySID                                                = @CountrySID
			,@DirectedAuditYearCompetence                               = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours                            = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear                                      = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked                              = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime                                = @RenewalExtensionExpiryTime
			,@ArchivedTime                                              = @ArchivedTime
			,@RegistrantRowGUID                                         = @RegistrantRowGUID
			,@RegistrationRegistrantSID                                 = @RegistrationRegistrantSID
			,@PracticeRegisterSectionSID                                = @PracticeRegisterSectionSID
			,@RegistrationNo                                            = @RegistrationNo
			,@RegistrationRegistrationYear                              = @RegistrationRegistrationYear
			,@RegistrationEffectiveTime                                 = @RegistrationEffectiveTime
			,@RegistrationExpiryTime                                    = @RegistrationExpiryTime
			,@CardPrintedTime                                           = @CardPrintedTime
			,@InvoiceSID                                                = @InvoiceSID
			,@ReasonSID                                                 = @ReasonSID
			,@FormGUID                                                  = @FormGUID
			,@RegistrationRowGUID                                       = @RegistrationRowGUID
			,@RegistrationSnapshotTypeSID                               = @RegistrationSnapshotTypeSID
			,@RegistrationSnapshotLabel                                 = @RegistrationSnapshotLabel
			,@RegistrationSnapshotRegistrationYear                      = @RegistrationSnapshotRegistrationYear
			,@QueuedTime                                                = @QueuedTime
			,@LockedTime                                                = @LockedTime
			,@LastCodeUpdateTime                                        = @LastCodeUpdateTime
			,@RegistrationSnapshotLastVerifiedTime                      = @RegistrationSnapshotLastVerifiedTime
			,@JobRunSID                                                 = @JobRunSID
			,@RegistrationSnapshotRowGUID                               = @RegistrationSnapshotRowGUID
			,@PersonMailingAddressPersonSID                             = @PersonMailingAddressPersonSID
			,@StreetAddress1                                            = @StreetAddress1
			,@StreetAddress2                                            = @StreetAddress2
			,@StreetAddress3                                            = @StreetAddress3
			,@CitySID                                                   = @CitySID
			,@PostalCode                                                = @PostalCode
			,@RegionSID                                                 = @RegionSID
			,@PersonMailingAddressEffectiveTime                         = @PersonMailingAddressEffectiveTime
			,@IsAdminReviewRequired                                     = @IsAdminReviewRequired
			,@PersonMailingAddressLastVerifiedTime                      = @PersonMailingAddressLastVerifiedTime
			,@PersonMailingAddressRowGUID                               = @PersonMailingAddressRowGUID
			,@RegistrantCredentialEducation1RegistrantSID               = @RegistrantCredentialEducation1RegistrantSID
			,@RegistrantCredentialEducation1CredentialSID               = @RegistrantCredentialEducation1CredentialSID
			,@RegistrantCredentialEducation1OrgSID                      = @RegistrantCredentialEducation1OrgSID
			,@RegistrantCredentialEducation1ProgramName                 = @RegistrantCredentialEducation1ProgramName
			,@RegistrantCredentialEducation1ProgramStartDate            = @RegistrantCredentialEducation1ProgramStartDate
			,@RegistrantCredentialEducation1ProgramTargetCompletionDate = @RegistrantCredentialEducation1ProgramTargetCompletionDate
			,@RegistrantCredentialEducation1EffectiveTime               = @RegistrantCredentialEducation1EffectiveTime
			,@RegistrantCredentialEducation1ExpiryTime                  = @RegistrantCredentialEducation1ExpiryTime
			,@RegistrantCredentialEducation1FieldOfStudySID             = @RegistrantCredentialEducation1FieldOfStudySID
			,@RegistrantCredentialEducation1RowGUID                     = @RegistrantCredentialEducation1RowGUID
			,@RegistrantCredentialEducation2RegistrantSID               = @RegistrantCredentialEducation2RegistrantSID
			,@RegistrantCredentialEducation2CredentialSID               = @RegistrantCredentialEducation2CredentialSID
			,@RegistrantCredentialEducation2OrgSID                      = @RegistrantCredentialEducation2OrgSID
			,@RegistrantCredentialEducation2ProgramName                 = @RegistrantCredentialEducation2ProgramName
			,@RegistrantCredentialEducation2ProgramStartDate            = @RegistrantCredentialEducation2ProgramStartDate
			,@RegistrantCredentialEducation2ProgramTargetCompletionDate = @RegistrantCredentialEducation2ProgramTargetCompletionDate
			,@RegistrantCredentialEducation2EffectiveTime               = @RegistrantCredentialEducation2EffectiveTime
			,@RegistrantCredentialEducation2ExpiryTime                  = @RegistrantCredentialEducation2ExpiryTime
			,@RegistrantCredentialEducation2FieldOfStudySID             = @RegistrantCredentialEducation2FieldOfStudySID
			,@RegistrantCredentialEducation2RowGUID                     = @RegistrantCredentialEducation2RowGUID
			,@RegistrantCredentialEducation3RegistrantSID               = @RegistrantCredentialEducation3RegistrantSID
			,@RegistrantCredentialEducation3CredentialSID               = @RegistrantCredentialEducation3CredentialSID
			,@RegistrantCredentialEducation3OrgSID                      = @RegistrantCredentialEducation3OrgSID
			,@RegistrantCredentialEducation3ProgramName                 = @RegistrantCredentialEducation3ProgramName
			,@RegistrantCredentialEducation3ProgramStartDate            = @RegistrantCredentialEducation3ProgramStartDate
			,@RegistrantCredentialEducation3ProgramTargetCompletionDate = @RegistrantCredentialEducation3ProgramTargetCompletionDate
			,@RegistrantCredentialEducation3EffectiveTime               = @RegistrantCredentialEducation3EffectiveTime
			,@RegistrantCredentialEducation3ExpiryTime                  = @RegistrantCredentialEducation3ExpiryTime
			,@RegistrantCredentialEducation3FieldOfStudySID             = @RegistrantCredentialEducation3FieldOfStudySID
			,@RegistrantCredentialEducation3RowGUID                     = @RegistrantCredentialEducation3RowGUID
			,@RegistrantEmploymentEmployment1RegistrantSID              = @RegistrantEmploymentEmployment1RegistrantSID
			,@RegistrantEmploymentEmployment1OrgSID                     = @RegistrantEmploymentEmployment1OrgSID
			,@RegistrantEmploymentEmployment1RegistrationYear           = @RegistrantEmploymentEmployment1RegistrationYear
			,@RegistrantEmploymentEmployment1EmploymentTypeSID          = @RegistrantEmploymentEmployment1EmploymentTypeSID
			,@RegistrantEmploymentEmployment1EmploymentRoleSID          = @RegistrantEmploymentEmployment1EmploymentRoleSID
			,@RegistrantEmploymentEmployment1PracticeHours              = @RegistrantEmploymentEmployment1PracticeHours
			,@RegistrantEmploymentEmployment1PracticeScopeSID           = @RegistrantEmploymentEmployment1PracticeScopeSID
			,@RegistrantEmploymentEmployment1AgeRangeSID                = @RegistrantEmploymentEmployment1AgeRangeSID
			,@RegistrantEmploymentEmployment1IsOnPublicRegistry         = @RegistrantEmploymentEmployment1IsOnPublicRegistry
			,@RegistrantEmploymentEmployment1Phone                      = @RegistrantEmploymentEmployment1Phone
			,@RegistrantEmploymentEmployment1SiteLocation               = @RegistrantEmploymentEmployment1SiteLocation
			,@RegistrantEmploymentEmployment1EffectiveTime              = @RegistrantEmploymentEmployment1EffectiveTime
			,@RegistrantEmploymentEmployment1ExpiryTime                 = @RegistrantEmploymentEmployment1ExpiryTime
			,@RegistrantEmploymentEmployment1Rank                       = @RegistrantEmploymentEmployment1Rank
			,@RegistrantEmploymentEmployment1OwnershipPercentage        = @RegistrantEmploymentEmployment1OwnershipPercentage
			,@RegistrantEmploymentEmployment1IsEmployerInsurance        = @RegistrantEmploymentEmployment1IsEmployerInsurance
			,@RegistrantEmploymentEmployment1InsuranceOrgSID            = @RegistrantEmploymentEmployment1InsuranceOrgSID
			,@RegistrantEmploymentEmployment1InsurancePolicyNo          = @RegistrantEmploymentEmployment1InsurancePolicyNo
			,@RegistrantEmploymentEmployment1InsuranceAmount            = @RegistrantEmploymentEmployment1InsuranceAmount
			,@RegistrantEmploymentEmployment1RowGUID                    = @RegistrantEmploymentEmployment1RowGUID
			,@RegistrantEmploymentEmployment2RegistrantSID              = @RegistrantEmploymentEmployment2RegistrantSID
			,@RegistrantEmploymentEmployment2OrgSID                     = @RegistrantEmploymentEmployment2OrgSID
			,@RegistrantEmploymentEmployment2RegistrationYear           = @RegistrantEmploymentEmployment2RegistrationYear
			,@RegistrantEmploymentEmployment2EmploymentTypeSID          = @RegistrantEmploymentEmployment2EmploymentTypeSID
			,@RegistrantEmploymentEmployment2EmploymentRoleSID          = @RegistrantEmploymentEmployment2EmploymentRoleSID
			,@RegistrantEmploymentEmployment2PracticeHours              = @RegistrantEmploymentEmployment2PracticeHours
			,@RegistrantEmploymentEmployment2PracticeScopeSID           = @RegistrantEmploymentEmployment2PracticeScopeSID
			,@RegistrantEmploymentEmployment2AgeRangeSID                = @RegistrantEmploymentEmployment2AgeRangeSID
			,@RegistrantEmploymentEmployment2IsOnPublicRegistry         = @RegistrantEmploymentEmployment2IsOnPublicRegistry
			,@RegistrantEmploymentEmployment2Phone                      = @RegistrantEmploymentEmployment2Phone
			,@RegistrantEmploymentEmployment2SiteLocation               = @RegistrantEmploymentEmployment2SiteLocation
			,@RegistrantEmploymentEmployment2EffectiveTime              = @RegistrantEmploymentEmployment2EffectiveTime
			,@RegistrantEmploymentEmployment2ExpiryTime                 = @RegistrantEmploymentEmployment2ExpiryTime
			,@RegistrantEmploymentEmployment2Rank                       = @RegistrantEmploymentEmployment2Rank
			,@RegistrantEmploymentEmployment2OwnershipPercentage        = @RegistrantEmploymentEmployment2OwnershipPercentage
			,@RegistrantEmploymentEmployment2IsEmployerInsurance        = @RegistrantEmploymentEmployment2IsEmployerInsurance
			,@RegistrantEmploymentEmployment2InsuranceOrgSID            = @RegistrantEmploymentEmployment2InsuranceOrgSID
			,@RegistrantEmploymentEmployment2InsurancePolicyNo          = @RegistrantEmploymentEmployment2InsurancePolicyNo
			,@RegistrantEmploymentEmployment2InsuranceAmount            = @RegistrantEmploymentEmployment2InsuranceAmount
			,@RegistrantEmploymentEmployment2RowGUID                    = @RegistrantEmploymentEmployment2RowGUID
			,@RegistrantEmploymentEmployment3RegistrantSID              = @RegistrantEmploymentEmployment3RegistrantSID
			,@RegistrantEmploymentEmployment3OrgSID                     = @RegistrantEmploymentEmployment3OrgSID
			,@RegistrantEmploymentEmployment3RegistrationYear           = @RegistrantEmploymentEmployment3RegistrationYear
			,@RegistrantEmploymentEmployment3EmploymentTypeSID          = @RegistrantEmploymentEmployment3EmploymentTypeSID
			,@RegistrantEmploymentEmployment3EmploymentRoleSID          = @RegistrantEmploymentEmployment3EmploymentRoleSID
			,@RegistrantEmploymentEmployment3PracticeHours              = @RegistrantEmploymentEmployment3PracticeHours
			,@RegistrantEmploymentEmployment3PracticeScopeSID           = @RegistrantEmploymentEmployment3PracticeScopeSID
			,@RegistrantEmploymentEmployment3AgeRangeSID                = @RegistrantEmploymentEmployment3AgeRangeSID
			,@RegistrantEmploymentEmployment3IsOnPublicRegistry         = @RegistrantEmploymentEmployment3IsOnPublicRegistry
			,@RegistrantEmploymentEmployment3Phone                      = @RegistrantEmploymentEmployment3Phone
			,@RegistrantEmploymentEmployment3SiteLocation               = @RegistrantEmploymentEmployment3SiteLocation
			,@RegistrantEmploymentEmployment3EffectiveTime              = @RegistrantEmploymentEmployment3EffectiveTime
			,@RegistrantEmploymentEmployment3ExpiryTime                 = @RegistrantEmploymentEmployment3ExpiryTime
			,@RegistrantEmploymentEmployment3Rank                       = @RegistrantEmploymentEmployment3Rank
			,@RegistrantEmploymentEmployment3OwnershipPercentage        = @RegistrantEmploymentEmployment3OwnershipPercentage
			,@RegistrantEmploymentEmployment3IsEmployerInsurance        = @RegistrantEmploymentEmployment3IsEmployerInsurance
			,@RegistrantEmploymentEmployment3InsuranceOrgSID            = @RegistrantEmploymentEmployment3InsuranceOrgSID
			,@RegistrantEmploymentEmployment3InsurancePolicyNo          = @RegistrantEmploymentEmployment3InsurancePolicyNo
			,@RegistrantEmploymentEmployment3InsuranceAmount            = @RegistrantEmploymentEmployment3InsuranceAmount
			,@RegistrantEmploymentEmployment3RowGUID                    = @RegistrantEmploymentEmployment3RowGUID
			,@RegistrantPracticeRegistrantSID                           = @RegistrantPracticeRegistrantSID
			,@RegistrantPracticeRegistrationYear                        = @RegistrantPracticeRegistrationYear
			,@EmploymentStatusSID                                       = @EmploymentStatusSID
			,@PlannedRetirementDate                                     = @PlannedRetirementDate
			,@OtherJurisdiction                                         = @OtherJurisdiction
			,@OtherJurisdictionHours                                    = @OtherJurisdictionHours
			,@TotalPracticeHours                                        = @TotalPracticeHours
			,@RegistrantPracticeOrgSID                                  = @RegistrantPracticeOrgSID
			,@RegistrantPracticeInsurancePolicyNo                       = @RegistrantPracticeInsurancePolicyNo
			,@RegistrantPracticeInsuranceAmount                         = @RegistrantPracticeInsuranceAmount
			,@InsuranceCertificateNo                                    = @InsuranceCertificateNo
			,@RegistrantPracticeRowGUID                                 = @RegistrantPracticeRowGUID
			,@IsDeleteEnabled                                           = @IsDeleteEnabled
			,@RegistrantLabel                                           = @RegistrantLabel
			,@FirstName                                                 = @FirstName
			,@CommonName                                                = @CommonName
			,@MiddleNames                                               = @MiddleNames
			,@LastName                                                  = @LastName
			,@DeathDate                                                 = @DeathDate
			,@HomePhone                                                 = @HomePhone
			,@MobilePhone                                               = @MobilePhone
			,@IsValid                                                   = @IsValid
			,@CIHIGenderCD                                              = @CIHIGenderCD
			,@CIHIBirthYear                                             = @CIHIBirthYear
			,@CIHIEducation1CredentialCode                              = @CIHIEducation1CredentialCode
			,@CIHIEducation1GraduationYear                              = @CIHIEducation1GraduationYear
			,@CIHIEducation1Location                                    = @CIHIEducation1Location
			,@CIHIEducation2CredentialCode                              = @CIHIEducation2CredentialCode
			,@CIHIEducation3CredentialCode                              = @CIHIEducation3CredentialCode
			,@CIHIEmploymentStatusCode                                  = @CIHIEmploymentStatusCode
			,@CIHIEmployment1TypeCode                                   = @CIHIEmployment1TypeCode
			,@CIHIMultipleEmploymentStatus                              = @CIHIMultipleEmploymentStatus
			,@CIHIEmployment1Location                                   = @CIHIEmployment1Location
			,@CIHIEmployment1OrgTypeCode                                = @CIHIEmployment1OrgTypeCode
			,@CIHIEmployment1PracticeAreaCode                           = @CIHIEmployment1PracticeAreaCode
			,@CIHIEmployment1PracticeScopeCode                          = @CIHIEmployment1PracticeScopeCode
			,@CIHIEmployment1RoleCode                                   = @CIHIEmployment1RoleCode
			,@CIHIResidenceLocation                                     = @CIHIResidenceLocation
			,@CIHIResidencePostalCode                                   = @CIHIResidencePostalCode
			,@CIHIEmployment1PostalCode                                 = @CIHIEmployment1PostalCode
			,@CIHIRegistrationYearMonth                                 = @CIHIRegistrationYearMonth
			,@CIHIEmployment2PostalCode                                 = @CIHIEmployment2PostalCode
			,@CIHIEmployment2Location                                   = @CIHIEmployment2Location
			,@CIHIEmployment2OrgTypeCode                                = @CIHIEmployment2OrgTypeCode
			,@CIHIEmployment2PracticeAreaCode                           = @CIHIEmployment2PracticeAreaCode
			,@CIHIEmployment2PracticeScopeCode                          = @CIHIEmployment2PracticeScopeCode
			,@CIHIEmployment2RoleCode                                   = @CIHIEmployment2RoleCode
			,@CIHIEmployment3PostalCode                                 = @CIHIEmployment3PostalCode
			,@CIHIEmployment3Location                                   = @CIHIEmployment3Location
			,@CIHIEmployment3OrgTypeCode                                = @CIHIEmployment3OrgTypeCode
			,@CIHIEmployment3PracticeAreaCode                           = @CIHIEmployment3PracticeAreaCode
			,@CIHIEmployment3PracticeScopeCode                          = @CIHIEmployment3PracticeScopeCode
			,@CIHIEmployment3RoleCode                                   = @CIHIEmployment3RoleCode
			,@CurrentCheckSum                                           = @CurrentCheckSum
			,@IsModified                                                = @IsModified

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
