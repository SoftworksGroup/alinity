SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationProfile#Insert]
	 @RegistrationProfileSID                                    int               = null output				-- identity value assigned to the new record
	,@RegistrationSnapshotSID                                   int               = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistrationProfile#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrationProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationProfile table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrationProfile entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationProfile procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

Business rule compliance is checked through a table constraint which calls fRegistrationProfileCheck to test all rules.

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

	set @RegistrationProfileSID = null																			-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @GenderSCD = ltrim(rtrim(@GenderSCD))
		set @ResidencePostalCode = ltrim(rtrim(@ResidencePostalCode))
		set @Education1CredentialCode = ltrim(rtrim(@Education1CredentialCode))
		set @Education2CredentialCode = ltrim(rtrim(@Education2CredentialCode))
		set @Education3CredentialCode = ltrim(rtrim(@Education3CredentialCode))
		set @EmploymentStatusCode = ltrim(rtrim(@EmploymentStatusCode))
		set @Employment1TypeCode = ltrim(rtrim(@Employment1TypeCode))
		set @Employment1PostalCode = ltrim(rtrim(@Employment1PostalCode))
		set @Employment1OrgTypeCode = ltrim(rtrim(@Employment1OrgTypeCode))
		set @Employment1PracticeAreaCode = ltrim(rtrim(@Employment1PracticeAreaCode))
		set @Employment1PracticeScopeCode = ltrim(rtrim(@Employment1PracticeScopeCode))
		set @Employment1RoleCode = ltrim(rtrim(@Employment1RoleCode))
		set @Employment2TypeCode = ltrim(rtrim(@Employment2TypeCode))
		set @Employment2PostalCode = ltrim(rtrim(@Employment2PostalCode))
		set @Employment2OrgTypeCode = ltrim(rtrim(@Employment2OrgTypeCode))
		set @Employment2PracticeAreaCode = ltrim(rtrim(@Employment2PracticeAreaCode))
		set @Employment2PracticeScopeCode = ltrim(rtrim(@Employment2PracticeScopeCode))
		set @Employment2RoleCode = ltrim(rtrim(@Employment2RoleCode))
		set @Employment3TypeCode = ltrim(rtrim(@Employment3TypeCode))
		set @Employment3PostalCode = ltrim(rtrim(@Employment3PostalCode))
		set @Employment3OrgTypeCode = ltrim(rtrim(@Employment3OrgTypeCode))
		set @Employment3PracticeAreaCode = ltrim(rtrim(@Employment3PracticeAreaCode))
		set @Employment3PracticeScopeCode = ltrim(rtrim(@Employment3PracticeScopeCode))
		set @Employment3RoleCode = ltrim(rtrim(@Employment3RoleCode))
		set @MessageText = ltrim(rtrim(@MessageText))
		set @RegistrationProfileXID = ltrim(rtrim(@RegistrationProfileXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @RegistrantRegistrantNo = ltrim(rtrim(@RegistrantRegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @RegistrationSnapshotLabel = ltrim(rtrim(@RegistrationSnapshotLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @RegistrantCredentialEducation1ProgramName = ltrim(rtrim(@RegistrantCredentialEducation1ProgramName))
		set @RegistrantCredentialEducation2ProgramName = ltrim(rtrim(@RegistrantCredentialEducation2ProgramName))
		set @RegistrantCredentialEducation3ProgramName = ltrim(rtrim(@RegistrantCredentialEducation3ProgramName))
		set @RegistrantEmploymentEmployment1Phone = ltrim(rtrim(@RegistrantEmploymentEmployment1Phone))
		set @RegistrantEmploymentEmployment1SiteLocation = ltrim(rtrim(@RegistrantEmploymentEmployment1SiteLocation))
		set @RegistrantEmploymentEmployment1InsurancePolicyNo = ltrim(rtrim(@RegistrantEmploymentEmployment1InsurancePolicyNo))
		set @RegistrantEmploymentEmployment2Phone = ltrim(rtrim(@RegistrantEmploymentEmployment2Phone))
		set @RegistrantEmploymentEmployment2SiteLocation = ltrim(rtrim(@RegistrantEmploymentEmployment2SiteLocation))
		set @RegistrantEmploymentEmployment2InsurancePolicyNo = ltrim(rtrim(@RegistrantEmploymentEmployment2InsurancePolicyNo))
		set @RegistrantEmploymentEmployment3Phone = ltrim(rtrim(@RegistrantEmploymentEmployment3Phone))
		set @RegistrantEmploymentEmployment3SiteLocation = ltrim(rtrim(@RegistrantEmploymentEmployment3SiteLocation))
		set @RegistrantEmploymentEmployment3InsurancePolicyNo = ltrim(rtrim(@RegistrantEmploymentEmployment3InsurancePolicyNo))
		set @OtherJurisdiction = ltrim(rtrim(@OtherJurisdiction))
		set @RegistrantPracticeInsurancePolicyNo = ltrim(rtrim(@RegistrantPracticeInsurancePolicyNo))
		set @InsuranceCertificateNo = ltrim(rtrim(@InsuranceCertificateNo))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @CIHIGenderCD = ltrim(rtrim(@CIHIGenderCD))
		set @CIHIEducation1CredentialCode = ltrim(rtrim(@CIHIEducation1CredentialCode))
		set @CIHIEducation2CredentialCode = ltrim(rtrim(@CIHIEducation2CredentialCode))
		set @CIHIEducation3CredentialCode = ltrim(rtrim(@CIHIEducation3CredentialCode))
		set @CIHIEmploymentStatusCode = ltrim(rtrim(@CIHIEmploymentStatusCode))
		set @CIHIEmployment1TypeCode = ltrim(rtrim(@CIHIEmployment1TypeCode))
		set @CIHIMultipleEmploymentStatus = ltrim(rtrim(@CIHIMultipleEmploymentStatus))
		set @CIHIEmployment1OrgTypeCode = ltrim(rtrim(@CIHIEmployment1OrgTypeCode))
		set @CIHIEmployment1PracticeAreaCode = ltrim(rtrim(@CIHIEmployment1PracticeAreaCode))
		set @CIHIEmployment1PracticeScopeCode = ltrim(rtrim(@CIHIEmployment1PracticeScopeCode))
		set @CIHIEmployment1RoleCode = ltrim(rtrim(@CIHIEmployment1RoleCode))
		set @CIHIResidencePostalCode = ltrim(rtrim(@CIHIResidencePostalCode))
		set @CIHIEmployment1PostalCode = ltrim(rtrim(@CIHIEmployment1PostalCode))
		set @CIHIRegistrationYearMonth = ltrim(rtrim(@CIHIRegistrationYearMonth))
		set @CIHIEmployment2PostalCode = ltrim(rtrim(@CIHIEmployment2PostalCode))
		set @CIHIEmployment2OrgTypeCode = ltrim(rtrim(@CIHIEmployment2OrgTypeCode))
		set @CIHIEmployment2PracticeAreaCode = ltrim(rtrim(@CIHIEmployment2PracticeAreaCode))
		set @CIHIEmployment2PracticeScopeCode = ltrim(rtrim(@CIHIEmployment2PracticeScopeCode))
		set @CIHIEmployment2RoleCode = ltrim(rtrim(@CIHIEmployment2RoleCode))
		set @CIHIEmployment3PostalCode = ltrim(rtrim(@CIHIEmployment3PostalCode))
		set @CIHIEmployment3OrgTypeCode = ltrim(rtrim(@CIHIEmployment3OrgTypeCode))
		set @CIHIEmployment3PracticeAreaCode = ltrim(rtrim(@CIHIEmployment3PracticeAreaCode))
		set @CIHIEmployment3PracticeScopeCode = ltrim(rtrim(@CIHIEmployment3PracticeScopeCode))
		set @CIHIEmployment3RoleCode = ltrim(rtrim(@CIHIEmployment3RoleCode))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@GenderSCD) = 0 set @GenderSCD = null
		if len(@ResidencePostalCode) = 0 set @ResidencePostalCode = null
		if len(@Education1CredentialCode) = 0 set @Education1CredentialCode = null
		if len(@Education2CredentialCode) = 0 set @Education2CredentialCode = null
		if len(@Education3CredentialCode) = 0 set @Education3CredentialCode = null
		if len(@EmploymentStatusCode) = 0 set @EmploymentStatusCode = null
		if len(@Employment1TypeCode) = 0 set @Employment1TypeCode = null
		if len(@Employment1PostalCode) = 0 set @Employment1PostalCode = null
		if len(@Employment1OrgTypeCode) = 0 set @Employment1OrgTypeCode = null
		if len(@Employment1PracticeAreaCode) = 0 set @Employment1PracticeAreaCode = null
		if len(@Employment1PracticeScopeCode) = 0 set @Employment1PracticeScopeCode = null
		if len(@Employment1RoleCode) = 0 set @Employment1RoleCode = null
		if len(@Employment2TypeCode) = 0 set @Employment2TypeCode = null
		if len(@Employment2PostalCode) = 0 set @Employment2PostalCode = null
		if len(@Employment2OrgTypeCode) = 0 set @Employment2OrgTypeCode = null
		if len(@Employment2PracticeAreaCode) = 0 set @Employment2PracticeAreaCode = null
		if len(@Employment2PracticeScopeCode) = 0 set @Employment2PracticeScopeCode = null
		if len(@Employment2RoleCode) = 0 set @Employment2RoleCode = null
		if len(@Employment3TypeCode) = 0 set @Employment3TypeCode = null
		if len(@Employment3PostalCode) = 0 set @Employment3PostalCode = null
		if len(@Employment3OrgTypeCode) = 0 set @Employment3OrgTypeCode = null
		if len(@Employment3PracticeAreaCode) = 0 set @Employment3PracticeAreaCode = null
		if len(@Employment3PracticeScopeCode) = 0 set @Employment3PracticeScopeCode = null
		if len(@Employment3RoleCode) = 0 set @Employment3RoleCode = null
		if len(@MessageText) = 0 set @MessageText = null
		if len(@RegistrationProfileXID) = 0 set @RegistrationProfileXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@RegistrantRegistrantNo) = 0 set @RegistrantRegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@RegistrationSnapshotLabel) = 0 set @RegistrationSnapshotLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@RegistrantCredentialEducation1ProgramName) = 0 set @RegistrantCredentialEducation1ProgramName = null
		if len(@RegistrantCredentialEducation2ProgramName) = 0 set @RegistrantCredentialEducation2ProgramName = null
		if len(@RegistrantCredentialEducation3ProgramName) = 0 set @RegistrantCredentialEducation3ProgramName = null
		if len(@RegistrantEmploymentEmployment1Phone) = 0 set @RegistrantEmploymentEmployment1Phone = null
		if len(@RegistrantEmploymentEmployment1SiteLocation) = 0 set @RegistrantEmploymentEmployment1SiteLocation = null
		if len(@RegistrantEmploymentEmployment1InsurancePolicyNo) = 0 set @RegistrantEmploymentEmployment1InsurancePolicyNo = null
		if len(@RegistrantEmploymentEmployment2Phone) = 0 set @RegistrantEmploymentEmployment2Phone = null
		if len(@RegistrantEmploymentEmployment2SiteLocation) = 0 set @RegistrantEmploymentEmployment2SiteLocation = null
		if len(@RegistrantEmploymentEmployment2InsurancePolicyNo) = 0 set @RegistrantEmploymentEmployment2InsurancePolicyNo = null
		if len(@RegistrantEmploymentEmployment3Phone) = 0 set @RegistrantEmploymentEmployment3Phone = null
		if len(@RegistrantEmploymentEmployment3SiteLocation) = 0 set @RegistrantEmploymentEmployment3SiteLocation = null
		if len(@RegistrantEmploymentEmployment3InsurancePolicyNo) = 0 set @RegistrantEmploymentEmployment3InsurancePolicyNo = null
		if len(@OtherJurisdiction) = 0 set @OtherJurisdiction = null
		if len(@RegistrantPracticeInsurancePolicyNo) = 0 set @RegistrantPracticeInsurancePolicyNo = null
		if len(@InsuranceCertificateNo) = 0 set @InsuranceCertificateNo = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@CIHIGenderCD) = 0 set @CIHIGenderCD = null
		if len(@CIHIEducation1CredentialCode) = 0 set @CIHIEducation1CredentialCode = null
		if len(@CIHIEducation2CredentialCode) = 0 set @CIHIEducation2CredentialCode = null
		if len(@CIHIEducation3CredentialCode) = 0 set @CIHIEducation3CredentialCode = null
		if len(@CIHIEmploymentStatusCode) = 0 set @CIHIEmploymentStatusCode = null
		if len(@CIHIEmployment1TypeCode) = 0 set @CIHIEmployment1TypeCode = null
		if len(@CIHIMultipleEmploymentStatus) = 0 set @CIHIMultipleEmploymentStatus = null
		if len(@CIHIEmployment1OrgTypeCode) = 0 set @CIHIEmployment1OrgTypeCode = null
		if len(@CIHIEmployment1PracticeAreaCode) = 0 set @CIHIEmployment1PracticeAreaCode = null
		if len(@CIHIEmployment1PracticeScopeCode) = 0 set @CIHIEmployment1PracticeScopeCode = null
		if len(@CIHIEmployment1RoleCode) = 0 set @CIHIEmployment1RoleCode = null
		if len(@CIHIResidencePostalCode) = 0 set @CIHIResidencePostalCode = null
		if len(@CIHIEmployment1PostalCode) = 0 set @CIHIEmployment1PostalCode = null
		if len(@CIHIRegistrationYearMonth) = 0 set @CIHIRegistrationYearMonth = null
		if len(@CIHIEmployment2PostalCode) = 0 set @CIHIEmployment2PostalCode = null
		if len(@CIHIEmployment2OrgTypeCode) = 0 set @CIHIEmployment2OrgTypeCode = null
		if len(@CIHIEmployment2PracticeAreaCode) = 0 set @CIHIEmployment2PracticeAreaCode = null
		if len(@CIHIEmployment2PracticeScopeCode) = 0 set @CIHIEmployment2PracticeScopeCode = null
		if len(@CIHIEmployment2RoleCode) = 0 set @CIHIEmployment2RoleCode = null
		if len(@CIHIEmployment3PostalCode) = 0 set @CIHIEmployment3PostalCode = null
		if len(@CIHIEmployment3OrgTypeCode) = 0 set @CIHIEmployment3OrgTypeCode = null
		if len(@CIHIEmployment3PracticeAreaCode) = 0 set @CIHIEmployment3PracticeAreaCode = null
		if len(@CIHIEmployment3PracticeScopeCode) = 0 set @CIHIEmployment3PracticeScopeCode = null
		if len(@CIHIEmployment3RoleCode) = 0 set @CIHIEmployment3RoleCode = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @ResidenceIsDefaultCountry = isnull(@ResidenceIsDefaultCountry,CONVERT(bit,(0)))
		set @IsActivePractice = isnull(@IsActivePractice,(0))
		set @Education1IsDefaultCountry = isnull(@Education1IsDefaultCountry,CONVERT(bit,(0)))
		set @Education2IsDefaultCountry = isnull(@Education2IsDefaultCountry,CONVERT(bit,(0)))
		set @Education3IsDefaultCountry = isnull(@Education3IsDefaultCountry,CONVERT(bit,(0)))
		set @PracticeHours = isnull(@PracticeHours,(0))
		set @Employment1IsDefaultCountry = isnull(@Employment1IsDefaultCountry,CONVERT(bit,(0)))
		set @Employment2IsDefaultCountry = isnull(@Employment2IsDefaultCountry,CONVERT(bit,(0)))
		set @Employment3IsDefaultCountry = isnull(@Employment3IsDefaultCountry,CONVERT(bit,(0)))
		set @IsInvalid = isnull(@IsInvalid,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                       = isnull(@IsReselected                      ,(0))
		
		set @ResidencePostalCode   = sf.fFormatPostalCode(@ResidencePostalCode)													-- format postal codes to standard
		set @Employment1PostalCode = sf.fFormatPostalCode(@Employment1PostalCode)
		set @Employment2PostalCode = sf.fFormatPostalCode(@Employment2PostalCode)
		set @Employment3PostalCode = sf.fFormatPostalCode(@Employment3PostalCode)

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrationProfile'
		)
		begin
		
			exec @errorNo = ext.pRegistrationProfile
				 @Mode                                                      = 'insert.pre'
				,@RegistrationSnapshotSID                                   = @RegistrationSnapshotSID output
				,@JursidictionStateProvinceISONumber                        = @JursidictionStateProvinceISONumber output
				,@RegistrantSID                                             = @RegistrantSID output
				,@RegistrantNo                                              = @RegistrantNo output
				,@GenderSCD                                                 = @GenderSCD output
				,@BirthDate                                                 = @BirthDate output
				,@PersonMailingAddressSID                                   = @PersonMailingAddressSID output
				,@ResidenceStateProvinceISONumber                           = @ResidenceStateProvinceISONumber output
				,@ResidencePostalCode                                       = @ResidencePostalCode output
				,@ResidenceCountryISONumber                                 = @ResidenceCountryISONumber output
				,@ResidenceIsDefaultCountry                                 = @ResidenceIsDefaultCountry output
				,@RegistrationSID                                           = @RegistrationSID output
				,@IsActivePractice                                          = @IsActivePractice output
				,@Education1RegistrantCredentialSID                         = @Education1RegistrantCredentialSID output
				,@Education1CredentialCode                                  = @Education1CredentialCode output
				,@Education1GraduationYear                                  = @Education1GraduationYear output
				,@Education1StateProvinceISONumber                          = @Education1StateProvinceISONumber output
				,@Education1CountryISONumber                                = @Education1CountryISONumber output
				,@Education1IsDefaultCountry                                = @Education1IsDefaultCountry output
				,@Education2RegistrantCredentialSID                         = @Education2RegistrantCredentialSID output
				,@Education2CredentialCode                                  = @Education2CredentialCode output
				,@Education2GraduationYear                                  = @Education2GraduationYear output
				,@Education2StateProvinceISONumber                          = @Education2StateProvinceISONumber output
				,@Education2CountryISONumber                                = @Education2CountryISONumber output
				,@Education2IsDefaultCountry                                = @Education2IsDefaultCountry output
				,@Education3RegistrantCredentialSID                         = @Education3RegistrantCredentialSID output
				,@Education3CredentialCode                                  = @Education3CredentialCode output
				,@Education3GraduationYear                                  = @Education3GraduationYear output
				,@Education3StateProvinceISONumber                          = @Education3StateProvinceISONumber output
				,@Education3CountryISONumber                                = @Education3CountryISONumber output
				,@Education3IsDefaultCountry                                = @Education3IsDefaultCountry output
				,@RegistrantPracticeSID                                     = @RegistrantPracticeSID output
				,@EmploymentStatusCode                                      = @EmploymentStatusCode output
				,@EmploymentCount                                           = @EmploymentCount output
				,@PracticeHours                                             = @PracticeHours output
				,@Employment1RegistrantEmploymentSID                        = @Employment1RegistrantEmploymentSID output
				,@Employment1TypeCode                                       = @Employment1TypeCode output
				,@Employment1StateProvinceISONumber                         = @Employment1StateProvinceISONumber output
				,@Employment1CountryISONumber                               = @Employment1CountryISONumber output
				,@Employment1IsDefaultCountry                               = @Employment1IsDefaultCountry output
				,@Employment1PostalCode                                     = @Employment1PostalCode output
				,@Employment1OrgTypeCode                                    = @Employment1OrgTypeCode output
				,@Employment1PracticeAreaCode                               = @Employment1PracticeAreaCode output
				,@Employment1PracticeScopeCode                              = @Employment1PracticeScopeCode output
				,@Employment1RoleCode                                       = @Employment1RoleCode output
				,@Employment2RegistrantEmploymentSID                        = @Employment2RegistrantEmploymentSID output
				,@Employment2TypeCode                                       = @Employment2TypeCode output
				,@Employment2StateProvinceISONumber                         = @Employment2StateProvinceISONumber output
				,@Employment2IsDefaultCountry                               = @Employment2IsDefaultCountry output
				,@Employment2CountryISONumber                               = @Employment2CountryISONumber output
				,@Employment2PostalCode                                     = @Employment2PostalCode output
				,@Employment2OrgTypeCode                                    = @Employment2OrgTypeCode output
				,@Employment2PracticeAreaCode                               = @Employment2PracticeAreaCode output
				,@Employment2PracticeScopeCode                              = @Employment2PracticeScopeCode output
				,@Employment2RoleCode                                       = @Employment2RoleCode output
				,@Employment3RegistrantEmploymentSID                        = @Employment3RegistrantEmploymentSID output
				,@Employment3TypeCode                                       = @Employment3TypeCode output
				,@Employment3StateProvinceISONumber                         = @Employment3StateProvinceISONumber output
				,@Employment3CountryISONumber                               = @Employment3CountryISONumber output
				,@Employment3IsDefaultCountry                               = @Employment3IsDefaultCountry output
				,@Employment3PostalCode                                     = @Employment3PostalCode output
				,@Employment3OrgTypeCode                                    = @Employment3OrgTypeCode output
				,@Employment3PracticeAreaCode                               = @Employment3PracticeAreaCode output
				,@Employment3PracticeScopeCode                              = @Employment3PracticeScopeCode output
				,@Employment3RoleCode                                       = @Employment3RoleCode output
				,@IsInvalid                                                 = @IsInvalid output
				,@MessageText                                               = @MessageText output
				,@CheckSumOnLastExport                                      = @CheckSumOnLastExport output
				,@UserDefinedColumns                                        = @UserDefinedColumns output
				,@RegistrationProfileXID                                    = @RegistrationProfileXID output
				,@LegacyKey                                                 = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.RegistrationProfile
		(
			 RegistrationSnapshotSID
			,JursidictionStateProvinceISONumber
			,RegistrantSID
			,RegistrantNo
			,GenderSCD
			,BirthDate
			,PersonMailingAddressSID
			,ResidenceStateProvinceISONumber
			,ResidencePostalCode
			,ResidenceCountryISONumber
			,ResidenceIsDefaultCountry
			,RegistrationSID
			,IsActivePractice
			,Education1RegistrantCredentialSID
			,Education1CredentialCode
			,Education1GraduationYear
			,Education1StateProvinceISONumber
			,Education1CountryISONumber
			,Education1IsDefaultCountry
			,Education2RegistrantCredentialSID
			,Education2CredentialCode
			,Education2GraduationYear
			,Education2StateProvinceISONumber
			,Education2CountryISONumber
			,Education2IsDefaultCountry
			,Education3RegistrantCredentialSID
			,Education3CredentialCode
			,Education3GraduationYear
			,Education3StateProvinceISONumber
			,Education3CountryISONumber
			,Education3IsDefaultCountry
			,RegistrantPracticeSID
			,EmploymentStatusCode
			,EmploymentCount
			,PracticeHours
			,Employment1RegistrantEmploymentSID
			,Employment1TypeCode
			,Employment1StateProvinceISONumber
			,Employment1CountryISONumber
			,Employment1IsDefaultCountry
			,Employment1PostalCode
			,Employment1OrgTypeCode
			,Employment1PracticeAreaCode
			,Employment1PracticeScopeCode
			,Employment1RoleCode
			,Employment2RegistrantEmploymentSID
			,Employment2TypeCode
			,Employment2StateProvinceISONumber
			,Employment2IsDefaultCountry
			,Employment2CountryISONumber
			,Employment2PostalCode
			,Employment2OrgTypeCode
			,Employment2PracticeAreaCode
			,Employment2PracticeScopeCode
			,Employment2RoleCode
			,Employment3RegistrantEmploymentSID
			,Employment3TypeCode
			,Employment3StateProvinceISONumber
			,Employment3CountryISONumber
			,Employment3IsDefaultCountry
			,Employment3PostalCode
			,Employment3OrgTypeCode
			,Employment3PracticeAreaCode
			,Employment3PracticeScopeCode
			,Employment3RoleCode
			,IsInvalid
			,MessageText
			,CheckSumOnLastExport
			,UserDefinedColumns
			,RegistrationProfileXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationSnapshotSID
			,@JursidictionStateProvinceISONumber
			,@RegistrantSID
			,@RegistrantNo
			,@GenderSCD
			,@BirthDate
			,@PersonMailingAddressSID
			,@ResidenceStateProvinceISONumber
			,@ResidencePostalCode
			,@ResidenceCountryISONumber
			,@ResidenceIsDefaultCountry
			,@RegistrationSID
			,@IsActivePractice
			,@Education1RegistrantCredentialSID
			,@Education1CredentialCode
			,@Education1GraduationYear
			,@Education1StateProvinceISONumber
			,@Education1CountryISONumber
			,@Education1IsDefaultCountry
			,@Education2RegistrantCredentialSID
			,@Education2CredentialCode
			,@Education2GraduationYear
			,@Education2StateProvinceISONumber
			,@Education2CountryISONumber
			,@Education2IsDefaultCountry
			,@Education3RegistrantCredentialSID
			,@Education3CredentialCode
			,@Education3GraduationYear
			,@Education3StateProvinceISONumber
			,@Education3CountryISONumber
			,@Education3IsDefaultCountry
			,@RegistrantPracticeSID
			,@EmploymentStatusCode
			,@EmploymentCount
			,@PracticeHours
			,@Employment1RegistrantEmploymentSID
			,@Employment1TypeCode
			,@Employment1StateProvinceISONumber
			,@Employment1CountryISONumber
			,@Employment1IsDefaultCountry
			,@Employment1PostalCode
			,@Employment1OrgTypeCode
			,@Employment1PracticeAreaCode
			,@Employment1PracticeScopeCode
			,@Employment1RoleCode
			,@Employment2RegistrantEmploymentSID
			,@Employment2TypeCode
			,@Employment2StateProvinceISONumber
			,@Employment2IsDefaultCountry
			,@Employment2CountryISONumber
			,@Employment2PostalCode
			,@Employment2OrgTypeCode
			,@Employment2PracticeAreaCode
			,@Employment2PracticeScopeCode
			,@Employment2RoleCode
			,@Employment3RegistrantEmploymentSID
			,@Employment3TypeCode
			,@Employment3StateProvinceISONumber
			,@Employment3CountryISONumber
			,@Employment3IsDefaultCountry
			,@Employment3PostalCode
			,@Employment3OrgTypeCode
			,@Employment3PracticeAreaCode
			,@Employment3PracticeScopeCode
			,@Employment3RoleCode
			,@IsInvalid
			,@MessageText
			,@CheckSumOnLastExport
			,@UserDefinedColumns
			,@RegistrationProfileXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected           = @@rowcount
			,@RegistrationProfileSID = scope_identity()													-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrationProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationProfileSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrationProfile'
		)
		begin
		
			exec @errorNo = ext.pRegistrationProfile
				 @Mode                                                      = 'insert.post'
				,@RegistrationProfileSID                                    = @RegistrationProfileSID
				,@RegistrationSnapshotSID                                   = @RegistrationSnapshotSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationProfileSID
			from
				dbo.vRegistrationProfile ent
			where
				ent.RegistrationProfileSID = @RegistrationProfileSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationProfileSID
				,ent.RegistrationSnapshotSID
				,ent.JursidictionStateProvinceISONumber
				,ent.RegistrantSID
				,ent.RegistrantNo
				,ent.GenderSCD
				,ent.BirthDate
				,ent.PersonMailingAddressSID
				,ent.ResidenceStateProvinceISONumber
				,ent.ResidencePostalCode
				,ent.ResidenceCountryISONumber
				,ent.ResidenceIsDefaultCountry
				,ent.RegistrationSID
				,ent.IsActivePractice
				,ent.Education1RegistrantCredentialSID
				,ent.Education1CredentialCode
				,ent.Education1GraduationYear
				,ent.Education1StateProvinceISONumber
				,ent.Education1CountryISONumber
				,ent.Education1IsDefaultCountry
				,ent.Education2RegistrantCredentialSID
				,ent.Education2CredentialCode
				,ent.Education2GraduationYear
				,ent.Education2StateProvinceISONumber
				,ent.Education2CountryISONumber
				,ent.Education2IsDefaultCountry
				,ent.Education3RegistrantCredentialSID
				,ent.Education3CredentialCode
				,ent.Education3GraduationYear
				,ent.Education3StateProvinceISONumber
				,ent.Education3CountryISONumber
				,ent.Education3IsDefaultCountry
				,ent.RegistrantPracticeSID
				,ent.EmploymentStatusCode
				,ent.EmploymentCount
				,ent.PracticeHours
				,ent.Employment1RegistrantEmploymentSID
				,ent.Employment1TypeCode
				,ent.Employment1StateProvinceISONumber
				,ent.Employment1CountryISONumber
				,ent.Employment1IsDefaultCountry
				,ent.Employment1PostalCode
				,ent.Employment1OrgTypeCode
				,ent.Employment1PracticeAreaCode
				,ent.Employment1PracticeScopeCode
				,ent.Employment1RoleCode
				,ent.Employment2RegistrantEmploymentSID
				,ent.Employment2TypeCode
				,ent.Employment2StateProvinceISONumber
				,ent.Employment2IsDefaultCountry
				,ent.Employment2CountryISONumber
				,ent.Employment2PostalCode
				,ent.Employment2OrgTypeCode
				,ent.Employment2PracticeAreaCode
				,ent.Employment2PracticeScopeCode
				,ent.Employment2RoleCode
				,ent.Employment3RegistrantEmploymentSID
				,ent.Employment3TypeCode
				,ent.Employment3StateProvinceISONumber
				,ent.Employment3CountryISONumber
				,ent.Employment3IsDefaultCountry
				,ent.Employment3PostalCode
				,ent.Employment3OrgTypeCode
				,ent.Employment3PracticeAreaCode
				,ent.Employment3PracticeScopeCode
				,ent.Employment3RoleCode
				,ent.IsInvalid
				,ent.MessageText
				,ent.CheckSumOnLastExport
				,ent.UserDefinedColumns
				,ent.RegistrationProfileXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrantPersonSID
				,ent.RegistrantRegistrantNo
				,ent.YearOfInitialEmployment
				,ent.RegistrantIsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.RegistrationRegistrantSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationNo
				,ent.RegistrationRegistrationYear
				,ent.RegistrationEffectiveTime
				,ent.RegistrationExpiryTime
				,ent.CardPrintedTime
				,ent.InvoiceSID
				,ent.ReasonSID
				,ent.FormGUID
				,ent.RegistrationRowGUID
				,ent.RegistrationSnapshotTypeSID
				,ent.RegistrationSnapshotLabel
				,ent.RegistrationSnapshotRegistrationYear
				,ent.QueuedTime
				,ent.LockedTime
				,ent.LastCodeUpdateTime
				,ent.RegistrationSnapshotLastVerifiedTime
				,ent.JobRunSID
				,ent.RegistrationSnapshotRowGUID
				,ent.PersonMailingAddressPersonSID
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.PersonMailingAddressEffectiveTime
				,ent.IsAdminReviewRequired
				,ent.PersonMailingAddressLastVerifiedTime
				,ent.PersonMailingAddressRowGUID
				,ent.RegistrantCredentialEducation1RegistrantSID
				,ent.RegistrantCredentialEducation1CredentialSID
				,ent.RegistrantCredentialEducation1OrgSID
				,ent.RegistrantCredentialEducation1ProgramName
				,ent.RegistrantCredentialEducation1ProgramStartDate
				,ent.RegistrantCredentialEducation1ProgramTargetCompletionDate
				,ent.RegistrantCredentialEducation1EffectiveTime
				,ent.RegistrantCredentialEducation1ExpiryTime
				,ent.RegistrantCredentialEducation1FieldOfStudySID
				,ent.RegistrantCredentialEducation1RowGUID
				,ent.RegistrantCredentialEducation2RegistrantSID
				,ent.RegistrantCredentialEducation2CredentialSID
				,ent.RegistrantCredentialEducation2OrgSID
				,ent.RegistrantCredentialEducation2ProgramName
				,ent.RegistrantCredentialEducation2ProgramStartDate
				,ent.RegistrantCredentialEducation2ProgramTargetCompletionDate
				,ent.RegistrantCredentialEducation2EffectiveTime
				,ent.RegistrantCredentialEducation2ExpiryTime
				,ent.RegistrantCredentialEducation2FieldOfStudySID
				,ent.RegistrantCredentialEducation2RowGUID
				,ent.RegistrantCredentialEducation3RegistrantSID
				,ent.RegistrantCredentialEducation3CredentialSID
				,ent.RegistrantCredentialEducation3OrgSID
				,ent.RegistrantCredentialEducation3ProgramName
				,ent.RegistrantCredentialEducation3ProgramStartDate
				,ent.RegistrantCredentialEducation3ProgramTargetCompletionDate
				,ent.RegistrantCredentialEducation3EffectiveTime
				,ent.RegistrantCredentialEducation3ExpiryTime
				,ent.RegistrantCredentialEducation3FieldOfStudySID
				,ent.RegistrantCredentialEducation3RowGUID
				,ent.RegistrantEmploymentEmployment1RegistrantSID
				,ent.RegistrantEmploymentEmployment1OrgSID
				,ent.RegistrantEmploymentEmployment1RegistrationYear
				,ent.RegistrantEmploymentEmployment1EmploymentTypeSID
				,ent.RegistrantEmploymentEmployment1EmploymentRoleSID
				,ent.RegistrantEmploymentEmployment1PracticeHours
				,ent.RegistrantEmploymentEmployment1PracticeScopeSID
				,ent.RegistrantEmploymentEmployment1AgeRangeSID
				,ent.RegistrantEmploymentEmployment1IsOnPublicRegistry
				,ent.RegistrantEmploymentEmployment1Phone
				,ent.RegistrantEmploymentEmployment1SiteLocation
				,ent.RegistrantEmploymentEmployment1EffectiveTime
				,ent.RegistrantEmploymentEmployment1ExpiryTime
				,ent.RegistrantEmploymentEmployment1Rank
				,ent.RegistrantEmploymentEmployment1OwnershipPercentage
				,ent.RegistrantEmploymentEmployment1IsEmployerInsurance
				,ent.RegistrantEmploymentEmployment1InsuranceOrgSID
				,ent.RegistrantEmploymentEmployment1InsurancePolicyNo
				,ent.RegistrantEmploymentEmployment1InsuranceAmount
				,ent.RegistrantEmploymentEmployment1RowGUID
				,ent.RegistrantEmploymentEmployment2RegistrantSID
				,ent.RegistrantEmploymentEmployment2OrgSID
				,ent.RegistrantEmploymentEmployment2RegistrationYear
				,ent.RegistrantEmploymentEmployment2EmploymentTypeSID
				,ent.RegistrantEmploymentEmployment2EmploymentRoleSID
				,ent.RegistrantEmploymentEmployment2PracticeHours
				,ent.RegistrantEmploymentEmployment2PracticeScopeSID
				,ent.RegistrantEmploymentEmployment2AgeRangeSID
				,ent.RegistrantEmploymentEmployment2IsOnPublicRegistry
				,ent.RegistrantEmploymentEmployment2Phone
				,ent.RegistrantEmploymentEmployment2SiteLocation
				,ent.RegistrantEmploymentEmployment2EffectiveTime
				,ent.RegistrantEmploymentEmployment2ExpiryTime
				,ent.RegistrantEmploymentEmployment2Rank
				,ent.RegistrantEmploymentEmployment2OwnershipPercentage
				,ent.RegistrantEmploymentEmployment2IsEmployerInsurance
				,ent.RegistrantEmploymentEmployment2InsuranceOrgSID
				,ent.RegistrantEmploymentEmployment2InsurancePolicyNo
				,ent.RegistrantEmploymentEmployment2InsuranceAmount
				,ent.RegistrantEmploymentEmployment2RowGUID
				,ent.RegistrantEmploymentEmployment3RegistrantSID
				,ent.RegistrantEmploymentEmployment3OrgSID
				,ent.RegistrantEmploymentEmployment3RegistrationYear
				,ent.RegistrantEmploymentEmployment3EmploymentTypeSID
				,ent.RegistrantEmploymentEmployment3EmploymentRoleSID
				,ent.RegistrantEmploymentEmployment3PracticeHours
				,ent.RegistrantEmploymentEmployment3PracticeScopeSID
				,ent.RegistrantEmploymentEmployment3AgeRangeSID
				,ent.RegistrantEmploymentEmployment3IsOnPublicRegistry
				,ent.RegistrantEmploymentEmployment3Phone
				,ent.RegistrantEmploymentEmployment3SiteLocation
				,ent.RegistrantEmploymentEmployment3EffectiveTime
				,ent.RegistrantEmploymentEmployment3ExpiryTime
				,ent.RegistrantEmploymentEmployment3Rank
				,ent.RegistrantEmploymentEmployment3OwnershipPercentage
				,ent.RegistrantEmploymentEmployment3IsEmployerInsurance
				,ent.RegistrantEmploymentEmployment3InsuranceOrgSID
				,ent.RegistrantEmploymentEmployment3InsurancePolicyNo
				,ent.RegistrantEmploymentEmployment3InsuranceAmount
				,ent.RegistrantEmploymentEmployment3RowGUID
				,ent.RegistrantPracticeRegistrantSID
				,ent.RegistrantPracticeRegistrationYear
				,ent.EmploymentStatusSID
				,ent.PlannedRetirementDate
				,ent.OtherJurisdiction
				,ent.OtherJurisdictionHours
				,ent.TotalPracticeHours
				,ent.RegistrantPracticeOrgSID
				,ent.RegistrantPracticeInsurancePolicyNo
				,ent.RegistrantPracticeInsuranceAmount
				,ent.InsuranceCertificateNo
				,ent.RegistrantPracticeRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsValid
				,ent.CIHIGenderCD
				,ent.CIHIBirthYear
				,ent.CIHIEducation1CredentialCode
				,ent.CIHIEducation1GraduationYear
				,ent.CIHIEducation1Location
				,ent.CIHIEducation2CredentialCode
				,ent.CIHIEducation3CredentialCode
				,ent.CIHIEmploymentStatusCode
				,ent.CIHIEmployment1TypeCode
				,ent.CIHIMultipleEmploymentStatus
				,ent.CIHIEmployment1Location
				,ent.CIHIEmployment1OrgTypeCode
				,ent.CIHIEmployment1PracticeAreaCode
				,ent.CIHIEmployment1PracticeScopeCode
				,ent.CIHIEmployment1RoleCode
				,ent.CIHIResidenceLocation
				,ent.CIHIResidencePostalCode
				,ent.CIHIEmployment1PostalCode
				,ent.CIHIRegistrationYearMonth
				,ent.CIHIEmployment2PostalCode
				,ent.CIHIEmployment2Location
				,ent.CIHIEmployment2OrgTypeCode
				,ent.CIHIEmployment2PracticeAreaCode
				,ent.CIHIEmployment2PracticeScopeCode
				,ent.CIHIEmployment2RoleCode
				,ent.CIHIEmployment3PostalCode
				,ent.CIHIEmployment3Location
				,ent.CIHIEmployment3OrgTypeCode
				,ent.CIHIEmployment3PracticeAreaCode
				,ent.CIHIEmployment3PracticeScopeCode
				,ent.CIHIEmployment3RoleCode
				,ent.CurrentCheckSum
				,ent.IsModified
			from
				dbo.vRegistrationProfile ent
			where
				ent.RegistrationProfileSID = @RegistrationProfileSID

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
