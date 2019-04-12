SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationProfile#Update]
	 @RegistrationProfileSID                                    int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationSnapshotSID                                   int               = null -- table column values to update:
	,@JursidictionStateProvinceISONumber                        smallint          = null
	,@RegistrantSID                                             int               = null
	,@RegistrantNo                                              varchar(50)       = null
	,@GenderSCD                                                 char(1)           = null
	,@BirthDate                                                 date              = null
	,@PersonMailingAddressSID                                   int               = null
	,@ResidenceStateProvinceISONumber                           smallint          = null
	,@ResidencePostalCode                                       varchar(10)       = null
	,@ResidenceCountryISONumber                                 smallint          = null
	,@ResidenceIsDefaultCountry                                 bit               = null
	,@RegistrationSID                                           int               = null
	,@IsActivePractice                                          bit               = null
	,@Education1RegistrantCredentialSID                         int               = null
	,@Education1CredentialCode                                  varchar(15)       = null
	,@Education1GraduationYear                                  smallint          = null
	,@Education1StateProvinceISONumber                          smallint          = null
	,@Education1CountryISONumber                                smallint          = null
	,@Education1IsDefaultCountry                                bit               = null
	,@Education2RegistrantCredentialSID                         int               = null
	,@Education2CredentialCode                                  varchar(15)       = null
	,@Education2GraduationYear                                  smallint          = null
	,@Education2StateProvinceISONumber                          smallint          = null
	,@Education2CountryISONumber                                smallint          = null
	,@Education2IsDefaultCountry                                bit               = null
	,@Education3RegistrantCredentialSID                         int               = null
	,@Education3CredentialCode                                  varchar(15)       = null
	,@Education3GraduationYear                                  smallint          = null
	,@Education3StateProvinceISONumber                          smallint          = null
	,@Education3CountryISONumber                                smallint          = null
	,@Education3IsDefaultCountry                                bit               = null
	,@RegistrantPracticeSID                                     int               = null
	,@EmploymentStatusCode                                      varchar(20)       = null
	,@EmploymentCount                                           smallint          = null
	,@PracticeHours                                             smallint          = null
	,@Employment1RegistrantEmploymentSID                        int               = null
	,@Employment1TypeCode                                       varchar(20)       = null
	,@Employment1StateProvinceISONumber                         smallint          = null
	,@Employment1CountryISONumber                               smallint          = null
	,@Employment1IsDefaultCountry                               bit               = null
	,@Employment1PostalCode                                     varchar(10)       = null
	,@Employment1OrgTypeCode                                    varchar(20)       = null
	,@Employment1PracticeAreaCode                               varchar(20)       = null
	,@Employment1PracticeScopeCode                              varchar(20)       = null
	,@Employment1RoleCode                                       varchar(20)       = null
	,@Employment2RegistrantEmploymentSID                        int               = null
	,@Employment2TypeCode                                       varchar(20)       = null
	,@Employment2StateProvinceISONumber                         smallint          = null
	,@Employment2IsDefaultCountry                               bit               = null
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
	,@Employment3IsDefaultCountry                               bit               = null
	,@Employment3PostalCode                                     varchar(10)       = null
	,@Employment3OrgTypeCode                                    varchar(20)       = null
	,@Employment3PracticeAreaCode                               varchar(20)       = null
	,@Employment3PracticeScopeCode                              varchar(20)       = null
	,@Employment3RoleCode                                       varchar(20)       = null
	,@IsInvalid                                                 bit               = null
	,@MessageText                                               nvarchar(4000)    = null
	,@CheckSumOnLastExport                                      int               = null
	,@UserDefinedColumns                                        xml               = null
	,@RegistrationProfileXID                                    varchar(150)      = null
	,@LegacyKey                                                 nvarchar(50)      = null
	,@UpdateUser                                                nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                                  timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                                              tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                                             bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                                  xml               = null -- other values defining context for the update (if any)
	,@RegistrantPersonSID                                       int               = null -- not a base table column
	,@RegistrantRegistrantNo                                    varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment                                   smallint          = null -- not a base table column
	,@RegistrantIsOnPublicRegistry                              bit               = null -- not a base table column
	,@CityNameOfBirth                                           nvarchar(30)      = null -- not a base table column
	,@CountrySID                                                int               = null -- not a base table column
	,@DirectedAuditYearCompetence                               smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours                            smallint          = null -- not a base table column
	,@LateFeeExclusionYear                                      smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked                              bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime                                datetime          = null -- not a base table column
	,@ArchivedTime                                              datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                                         uniqueidentifier  = null -- not a base table column
	,@RegistrationRegistrantSID                                 int               = null -- not a base table column
	,@PracticeRegisterSectionSID                                int               = null -- not a base table column
	,@RegistrationNo                                            nvarchar(50)      = null -- not a base table column
	,@RegistrationRegistrationYear                              smallint          = null -- not a base table column
	,@RegistrationEffectiveTime                                 datetime          = null -- not a base table column
	,@RegistrationExpiryTime                                    datetime          = null -- not a base table column
	,@CardPrintedTime                                           datetime          = null -- not a base table column
	,@InvoiceSID                                                int               = null -- not a base table column
	,@ReasonSID                                                 int               = null -- not a base table column
	,@FormGUID                                                  uniqueidentifier  = null -- not a base table column
	,@RegistrationRowGUID                                       uniqueidentifier  = null -- not a base table column
	,@RegistrationSnapshotTypeSID                               int               = null -- not a base table column
	,@RegistrationSnapshotLabel                                 nvarchar(35)      = null -- not a base table column
	,@RegistrationSnapshotRegistrationYear                      smallint          = null -- not a base table column
	,@QueuedTime                                                datetimeoffset(7) = null -- not a base table column
	,@LockedTime                                                datetimeoffset(7) = null -- not a base table column
	,@LastCodeUpdateTime                                        datetimeoffset(7) = null -- not a base table column
	,@RegistrationSnapshotLastVerifiedTime                      datetimeoffset(7) = null -- not a base table column
	,@JobRunSID                                                 int               = null -- not a base table column
	,@RegistrationSnapshotRowGUID                               uniqueidentifier  = null -- not a base table column
	,@PersonMailingAddressPersonSID                             int               = null -- not a base table column
	,@StreetAddress1                                            nvarchar(75)      = null -- not a base table column
	,@StreetAddress2                                            nvarchar(75)      = null -- not a base table column
	,@StreetAddress3                                            nvarchar(75)      = null -- not a base table column
	,@CitySID                                                   int               = null -- not a base table column
	,@PostalCode                                                varchar(10)       = null -- not a base table column
	,@RegionSID                                                 int               = null -- not a base table column
	,@PersonMailingAddressEffectiveTime                         datetime          = null -- not a base table column
	,@IsAdminReviewRequired                                     bit               = null -- not a base table column
	,@PersonMailingAddressLastVerifiedTime                      datetimeoffset(7) = null -- not a base table column
	,@PersonMailingAddressRowGUID                               uniqueidentifier  = null -- not a base table column
	,@RegistrantCredentialEducation1RegistrantSID               int               = null -- not a base table column
	,@RegistrantCredentialEducation1CredentialSID               int               = null -- not a base table column
	,@RegistrantCredentialEducation1OrgSID                      int               = null -- not a base table column
	,@RegistrantCredentialEducation1ProgramName                 nvarchar(65)      = null -- not a base table column
	,@RegistrantCredentialEducation1ProgramStartDate            date              = null -- not a base table column
	,@RegistrantCredentialEducation1ProgramTargetCompletionDate date              = null -- not a base table column
	,@RegistrantCredentialEducation1EffectiveTime               datetime          = null -- not a base table column
	,@RegistrantCredentialEducation1ExpiryTime                  datetime          = null -- not a base table column
	,@RegistrantCredentialEducation1FieldOfStudySID             int               = null -- not a base table column
	,@RegistrantCredentialEducation1RowGUID                     uniqueidentifier  = null -- not a base table column
	,@RegistrantCredentialEducation2RegistrantSID               int               = null -- not a base table column
	,@RegistrantCredentialEducation2CredentialSID               int               = null -- not a base table column
	,@RegistrantCredentialEducation2OrgSID                      int               = null -- not a base table column
	,@RegistrantCredentialEducation2ProgramName                 nvarchar(65)      = null -- not a base table column
	,@RegistrantCredentialEducation2ProgramStartDate            date              = null -- not a base table column
	,@RegistrantCredentialEducation2ProgramTargetCompletionDate date              = null -- not a base table column
	,@RegistrantCredentialEducation2EffectiveTime               datetime          = null -- not a base table column
	,@RegistrantCredentialEducation2ExpiryTime                  datetime          = null -- not a base table column
	,@RegistrantCredentialEducation2FieldOfStudySID             int               = null -- not a base table column
	,@RegistrantCredentialEducation2RowGUID                     uniqueidentifier  = null -- not a base table column
	,@RegistrantCredentialEducation3RegistrantSID               int               = null -- not a base table column
	,@RegistrantCredentialEducation3CredentialSID               int               = null -- not a base table column
	,@RegistrantCredentialEducation3OrgSID                      int               = null -- not a base table column
	,@RegistrantCredentialEducation3ProgramName                 nvarchar(65)      = null -- not a base table column
	,@RegistrantCredentialEducation3ProgramStartDate            date              = null -- not a base table column
	,@RegistrantCredentialEducation3ProgramTargetCompletionDate date              = null -- not a base table column
	,@RegistrantCredentialEducation3EffectiveTime               datetime          = null -- not a base table column
	,@RegistrantCredentialEducation3ExpiryTime                  datetime          = null -- not a base table column
	,@RegistrantCredentialEducation3FieldOfStudySID             int               = null -- not a base table column
	,@RegistrantCredentialEducation3RowGUID                     uniqueidentifier  = null -- not a base table column
	,@RegistrantEmploymentEmployment1RegistrantSID              int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1OrgSID                     int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1RegistrationYear           smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment1EmploymentTypeSID          int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1EmploymentRoleSID          int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1PracticeHours              int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1PracticeScopeSID           int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1AgeRangeSID                int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1IsOnPublicRegistry         bit               = null -- not a base table column
	,@RegistrantEmploymentEmployment1Phone                      varchar(25)       = null -- not a base table column
	,@RegistrantEmploymentEmployment1SiteLocation               nvarchar(50)      = null -- not a base table column
	,@RegistrantEmploymentEmployment1EffectiveTime              datetime          = null -- not a base table column
	,@RegistrantEmploymentEmployment1ExpiryTime                 datetime          = null -- not a base table column
	,@RegistrantEmploymentEmployment1Rank                       smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment1OwnershipPercentage        smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment1IsEmployerInsurance        bit               = null -- not a base table column
	,@RegistrantEmploymentEmployment1InsuranceOrgSID            int               = null -- not a base table column
	,@RegistrantEmploymentEmployment1InsurancePolicyNo          varchar(25)       = null -- not a base table column
	,@RegistrantEmploymentEmployment1InsuranceAmount            decimal(11,2)     = null -- not a base table column
	,@RegistrantEmploymentEmployment1RowGUID                    uniqueidentifier  = null -- not a base table column
	,@RegistrantEmploymentEmployment2RegistrantSID              int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2OrgSID                     int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2RegistrationYear           smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment2EmploymentTypeSID          int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2EmploymentRoleSID          int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2PracticeHours              int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2PracticeScopeSID           int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2AgeRangeSID                int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2IsOnPublicRegistry         bit               = null -- not a base table column
	,@RegistrantEmploymentEmployment2Phone                      varchar(25)       = null -- not a base table column
	,@RegistrantEmploymentEmployment2SiteLocation               nvarchar(50)      = null -- not a base table column
	,@RegistrantEmploymentEmployment2EffectiveTime              datetime          = null -- not a base table column
	,@RegistrantEmploymentEmployment2ExpiryTime                 datetime          = null -- not a base table column
	,@RegistrantEmploymentEmployment2Rank                       smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment2OwnershipPercentage        smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment2IsEmployerInsurance        bit               = null -- not a base table column
	,@RegistrantEmploymentEmployment2InsuranceOrgSID            int               = null -- not a base table column
	,@RegistrantEmploymentEmployment2InsurancePolicyNo          varchar(25)       = null -- not a base table column
	,@RegistrantEmploymentEmployment2InsuranceAmount            decimal(11,2)     = null -- not a base table column
	,@RegistrantEmploymentEmployment2RowGUID                    uniqueidentifier  = null -- not a base table column
	,@RegistrantEmploymentEmployment3RegistrantSID              int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3OrgSID                     int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3RegistrationYear           smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment3EmploymentTypeSID          int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3EmploymentRoleSID          int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3PracticeHours              int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3PracticeScopeSID           int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3AgeRangeSID                int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3IsOnPublicRegistry         bit               = null -- not a base table column
	,@RegistrantEmploymentEmployment3Phone                      varchar(25)       = null -- not a base table column
	,@RegistrantEmploymentEmployment3SiteLocation               nvarchar(50)      = null -- not a base table column
	,@RegistrantEmploymentEmployment3EffectiveTime              datetime          = null -- not a base table column
	,@RegistrantEmploymentEmployment3ExpiryTime                 datetime          = null -- not a base table column
	,@RegistrantEmploymentEmployment3Rank                       smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment3OwnershipPercentage        smallint          = null -- not a base table column
	,@RegistrantEmploymentEmployment3IsEmployerInsurance        bit               = null -- not a base table column
	,@RegistrantEmploymentEmployment3InsuranceOrgSID            int               = null -- not a base table column
	,@RegistrantEmploymentEmployment3InsurancePolicyNo          varchar(25)       = null -- not a base table column
	,@RegistrantEmploymentEmployment3InsuranceAmount            decimal(11,2)     = null -- not a base table column
	,@RegistrantEmploymentEmployment3RowGUID                    uniqueidentifier  = null -- not a base table column
	,@RegistrantPracticeRegistrantSID                           int               = null -- not a base table column
	,@RegistrantPracticeRegistrationYear                        smallint          = null -- not a base table column
	,@EmploymentStatusSID                                       int               = null -- not a base table column
	,@PlannedRetirementDate                                     date              = null -- not a base table column
	,@OtherJurisdiction                                         nvarchar(100)     = null -- not a base table column
	,@OtherJurisdictionHours                                    int               = null -- not a base table column
	,@TotalPracticeHours                                        int               = null -- not a base table column
	,@RegistrantPracticeOrgSID                                  int               = null -- not a base table column
	,@RegistrantPracticeInsurancePolicyNo                       varchar(25)       = null -- not a base table column
	,@RegistrantPracticeInsuranceAmount                         decimal(11,2)     = null -- not a base table column
	,@InsuranceCertificateNo                                    varchar(25)       = null -- not a base table column
	,@RegistrantPracticeRowGUID                                 uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                                           bit               = null -- not a base table column
	,@RegistrantLabel                                           nvarchar(75)      = null -- not a base table column
	,@FirstName                                                 nvarchar(30)      = null -- not a base table column
	,@CommonName                                                nvarchar(30)      = null -- not a base table column
	,@MiddleNames                                               nvarchar(30)      = null -- not a base table column
	,@LastName                                                  nvarchar(35)      = null -- not a base table column
	,@DeathDate                                                 date              = null -- not a base table column
	,@HomePhone                                                 varchar(25)       = null -- not a base table column
	,@MobilePhone                                               varchar(25)       = null -- not a base table column
	,@IsValid                                                   bit               = null -- not a base table column
	,@CIHIGenderCD                                              char(1)           = null -- not a base table column
	,@CIHIBirthYear                                             int               = null -- not a base table column
	,@CIHIEducation1CredentialCode                              varchar(15)       = null -- not a base table column
	,@CIHIEducation1GraduationYear                              smallint          = null -- not a base table column
	,@CIHIEducation1Location                                    smallint          = null -- not a base table column
	,@CIHIEducation2CredentialCode                              varchar(15)       = null -- not a base table column
	,@CIHIEducation3CredentialCode                              varchar(15)       = null -- not a base table column
	,@CIHIEmploymentStatusCode                                  varchar(20)       = null -- not a base table column
	,@CIHIEmployment1TypeCode                                   varchar(20)       = null -- not a base table column
	,@CIHIMultipleEmploymentStatus                              char(1)           = null -- not a base table column
	,@CIHIEmployment1Location                                   smallint          = null -- not a base table column
	,@CIHIEmployment1OrgTypeCode                                varchar(20)       = null -- not a base table column
	,@CIHIEmployment1PracticeAreaCode                           varchar(20)       = null -- not a base table column
	,@CIHIEmployment1PracticeScopeCode                          varchar(20)       = null -- not a base table column
	,@CIHIEmployment1RoleCode                                   varchar(20)       = null -- not a base table column
	,@CIHIResidenceLocation                                     smallint          = null -- not a base table column
	,@CIHIResidencePostalCode                                   varchar(8000)     = null -- not a base table column
	,@CIHIEmployment1PostalCode                                 varchar(8000)     = null -- not a base table column
	,@CIHIRegistrationYearMonth                                 char(6)           = null -- not a base table column
	,@CIHIEmployment2PostalCode                                 varchar(8000)     = null -- not a base table column
	,@CIHIEmployment2Location                                   smallint          = null -- not a base table column
	,@CIHIEmployment2OrgTypeCode                                varchar(20)       = null -- not a base table column
	,@CIHIEmployment2PracticeAreaCode                           varchar(20)       = null -- not a base table column
	,@CIHIEmployment2PracticeScopeCode                          varchar(20)       = null -- not a base table column
	,@CIHIEmployment2RoleCode                                   varchar(20)       = null -- not a base table column
	,@CIHIEmployment3PostalCode                                 varchar(8000)     = null -- not a base table column
	,@CIHIEmployment3Location                                   smallint          = null -- not a base table column
	,@CIHIEmployment3OrgTypeCode                                varchar(20)       = null -- not a base table column
	,@CIHIEmployment3PracticeAreaCode                           varchar(20)       = null -- not a base table column
	,@CIHIEmployment3PracticeScopeCode                          varchar(20)       = null -- not a base table column
	,@CIHIEmployment3RoleCode                                   varchar(20)       = null -- not a base table column
	,@CurrentCheckSum                                           int               = null -- not a base table column
	,@IsModified                                                bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationProfile#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrationProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrationProfile table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrationProfile entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationProfile procedure. The extended procedure is only called
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

		if @RegistrationProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationProfileSID'

			raiserror(@errorText, 18, 1)
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
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationSnapshotSID                                   = isnull(@RegistrationSnapshotSID,rp.RegistrationSnapshotSID)
				,@JursidictionStateProvinceISONumber                        = isnull(@JursidictionStateProvinceISONumber,rp.JursidictionStateProvinceISONumber)
				,@RegistrantSID                                             = isnull(@RegistrantSID,rp.RegistrantSID)
				,@RegistrantNo                                              = isnull(@RegistrantNo,rp.RegistrantNo)
				,@GenderSCD                                                 = isnull(@GenderSCD,rp.GenderSCD)
				,@BirthDate                                                 = isnull(@BirthDate,rp.BirthDate)
				,@PersonMailingAddressSID                                   = isnull(@PersonMailingAddressSID,rp.PersonMailingAddressSID)
				,@ResidenceStateProvinceISONumber                           = isnull(@ResidenceStateProvinceISONumber,rp.ResidenceStateProvinceISONumber)
				,@ResidencePostalCode                                       = isnull(@ResidencePostalCode,rp.ResidencePostalCode)
				,@ResidenceCountryISONumber                                 = isnull(@ResidenceCountryISONumber,rp.ResidenceCountryISONumber)
				,@ResidenceIsDefaultCountry                                 = isnull(@ResidenceIsDefaultCountry,rp.ResidenceIsDefaultCountry)
				,@RegistrationSID                                           = isnull(@RegistrationSID,rp.RegistrationSID)
				,@IsActivePractice                                          = isnull(@IsActivePractice,rp.IsActivePractice)
				,@Education1RegistrantCredentialSID                         = isnull(@Education1RegistrantCredentialSID,rp.Education1RegistrantCredentialSID)
				,@Education1CredentialCode                                  = isnull(@Education1CredentialCode,rp.Education1CredentialCode)
				,@Education1GraduationYear                                  = isnull(@Education1GraduationYear,rp.Education1GraduationYear)
				,@Education1StateProvinceISONumber                          = isnull(@Education1StateProvinceISONumber,rp.Education1StateProvinceISONumber)
				,@Education1CountryISONumber                                = isnull(@Education1CountryISONumber,rp.Education1CountryISONumber)
				,@Education1IsDefaultCountry                                = isnull(@Education1IsDefaultCountry,rp.Education1IsDefaultCountry)
				,@Education2RegistrantCredentialSID                         = isnull(@Education2RegistrantCredentialSID,rp.Education2RegistrantCredentialSID)
				,@Education2CredentialCode                                  = isnull(@Education2CredentialCode,rp.Education2CredentialCode)
				,@Education2GraduationYear                                  = isnull(@Education2GraduationYear,rp.Education2GraduationYear)
				,@Education2StateProvinceISONumber                          = isnull(@Education2StateProvinceISONumber,rp.Education2StateProvinceISONumber)
				,@Education2CountryISONumber                                = isnull(@Education2CountryISONumber,rp.Education2CountryISONumber)
				,@Education2IsDefaultCountry                                = isnull(@Education2IsDefaultCountry,rp.Education2IsDefaultCountry)
				,@Education3RegistrantCredentialSID                         = isnull(@Education3RegistrantCredentialSID,rp.Education3RegistrantCredentialSID)
				,@Education3CredentialCode                                  = isnull(@Education3CredentialCode,rp.Education3CredentialCode)
				,@Education3GraduationYear                                  = isnull(@Education3GraduationYear,rp.Education3GraduationYear)
				,@Education3StateProvinceISONumber                          = isnull(@Education3StateProvinceISONumber,rp.Education3StateProvinceISONumber)
				,@Education3CountryISONumber                                = isnull(@Education3CountryISONumber,rp.Education3CountryISONumber)
				,@Education3IsDefaultCountry                                = isnull(@Education3IsDefaultCountry,rp.Education3IsDefaultCountry)
				,@RegistrantPracticeSID                                     = isnull(@RegistrantPracticeSID,rp.RegistrantPracticeSID)
				,@EmploymentStatusCode                                      = isnull(@EmploymentStatusCode,rp.EmploymentStatusCode)
				,@EmploymentCount                                           = isnull(@EmploymentCount,rp.EmploymentCount)
				,@PracticeHours                                             = isnull(@PracticeHours,rp.PracticeHours)
				,@Employment1RegistrantEmploymentSID                        = isnull(@Employment1RegistrantEmploymentSID,rp.Employment1RegistrantEmploymentSID)
				,@Employment1TypeCode                                       = isnull(@Employment1TypeCode,rp.Employment1TypeCode)
				,@Employment1StateProvinceISONumber                         = isnull(@Employment1StateProvinceISONumber,rp.Employment1StateProvinceISONumber)
				,@Employment1CountryISONumber                               = isnull(@Employment1CountryISONumber,rp.Employment1CountryISONumber)
				,@Employment1IsDefaultCountry                               = isnull(@Employment1IsDefaultCountry,rp.Employment1IsDefaultCountry)
				,@Employment1PostalCode                                     = isnull(@Employment1PostalCode,rp.Employment1PostalCode)
				,@Employment1OrgTypeCode                                    = isnull(@Employment1OrgTypeCode,rp.Employment1OrgTypeCode)
				,@Employment1PracticeAreaCode                               = isnull(@Employment1PracticeAreaCode,rp.Employment1PracticeAreaCode)
				,@Employment1PracticeScopeCode                              = isnull(@Employment1PracticeScopeCode,rp.Employment1PracticeScopeCode)
				,@Employment1RoleCode                                       = isnull(@Employment1RoleCode,rp.Employment1RoleCode)
				,@Employment2RegistrantEmploymentSID                        = isnull(@Employment2RegistrantEmploymentSID,rp.Employment2RegistrantEmploymentSID)
				,@Employment2TypeCode                                       = isnull(@Employment2TypeCode,rp.Employment2TypeCode)
				,@Employment2StateProvinceISONumber                         = isnull(@Employment2StateProvinceISONumber,rp.Employment2StateProvinceISONumber)
				,@Employment2IsDefaultCountry                               = isnull(@Employment2IsDefaultCountry,rp.Employment2IsDefaultCountry)
				,@Employment2CountryISONumber                               = isnull(@Employment2CountryISONumber,rp.Employment2CountryISONumber)
				,@Employment2PostalCode                                     = isnull(@Employment2PostalCode,rp.Employment2PostalCode)
				,@Employment2OrgTypeCode                                    = isnull(@Employment2OrgTypeCode,rp.Employment2OrgTypeCode)
				,@Employment2PracticeAreaCode                               = isnull(@Employment2PracticeAreaCode,rp.Employment2PracticeAreaCode)
				,@Employment2PracticeScopeCode                              = isnull(@Employment2PracticeScopeCode,rp.Employment2PracticeScopeCode)
				,@Employment2RoleCode                                       = isnull(@Employment2RoleCode,rp.Employment2RoleCode)
				,@Employment3RegistrantEmploymentSID                        = isnull(@Employment3RegistrantEmploymentSID,rp.Employment3RegistrantEmploymentSID)
				,@Employment3TypeCode                                       = isnull(@Employment3TypeCode,rp.Employment3TypeCode)
				,@Employment3StateProvinceISONumber                         = isnull(@Employment3StateProvinceISONumber,rp.Employment3StateProvinceISONumber)
				,@Employment3CountryISONumber                               = isnull(@Employment3CountryISONumber,rp.Employment3CountryISONumber)
				,@Employment3IsDefaultCountry                               = isnull(@Employment3IsDefaultCountry,rp.Employment3IsDefaultCountry)
				,@Employment3PostalCode                                     = isnull(@Employment3PostalCode,rp.Employment3PostalCode)
				,@Employment3OrgTypeCode                                    = isnull(@Employment3OrgTypeCode,rp.Employment3OrgTypeCode)
				,@Employment3PracticeAreaCode                               = isnull(@Employment3PracticeAreaCode,rp.Employment3PracticeAreaCode)
				,@Employment3PracticeScopeCode                              = isnull(@Employment3PracticeScopeCode,rp.Employment3PracticeScopeCode)
				,@Employment3RoleCode                                       = isnull(@Employment3RoleCode,rp.Employment3RoleCode)
				,@IsInvalid                                                 = isnull(@IsInvalid,rp.IsInvalid)
				,@MessageText                                               = isnull(@MessageText,rp.MessageText)
				,@CheckSumOnLastExport                                      = isnull(@CheckSumOnLastExport,rp.CheckSumOnLastExport)
				,@UserDefinedColumns                                        = isnull(@UserDefinedColumns,rp.UserDefinedColumns)
				,@RegistrationProfileXID                                    = isnull(@RegistrationProfileXID,rp.RegistrationProfileXID)
				,@LegacyKey                                                 = isnull(@LegacyKey,rp.LegacyKey)
				,@UpdateUser                                                = isnull(@UpdateUser,rp.UpdateUser)
				,@IsReselected                                              = isnull(@IsReselected,rp.IsReselected)
				,@IsNullApplied                                             = isnull(@IsNullApplied,rp.IsNullApplied)
				,@zContext                                                  = isnull(@zContext,rp.zContext)
				,@RegistrantPersonSID                                       = isnull(@RegistrantPersonSID,rp.RegistrantPersonSID)
				,@RegistrantRegistrantNo                                    = isnull(@RegistrantRegistrantNo,rp.RegistrantRegistrantNo)
				,@YearOfInitialEmployment                                   = isnull(@YearOfInitialEmployment,rp.YearOfInitialEmployment)
				,@RegistrantIsOnPublicRegistry                              = isnull(@RegistrantIsOnPublicRegistry,rp.RegistrantIsOnPublicRegistry)
				,@CityNameOfBirth                                           = isnull(@CityNameOfBirth,rp.CityNameOfBirth)
				,@CountrySID                                                = isnull(@CountrySID,rp.CountrySID)
				,@DirectedAuditYearCompetence                               = isnull(@DirectedAuditYearCompetence,rp.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours                            = isnull(@DirectedAuditYearPracticeHours,rp.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear                                      = isnull(@LateFeeExclusionYear,rp.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked                              = isnull(@IsRenewalAutoApprovalBlocked,rp.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime                                = isnull(@RenewalExtensionExpiryTime,rp.RenewalExtensionExpiryTime)
				,@ArchivedTime                                              = isnull(@ArchivedTime,rp.ArchivedTime)
				,@RegistrantRowGUID                                         = isnull(@RegistrantRowGUID,rp.RegistrantRowGUID)
				,@RegistrationRegistrantSID                                 = isnull(@RegistrationRegistrantSID,rp.RegistrationRegistrantSID)
				,@PracticeRegisterSectionSID                                = isnull(@PracticeRegisterSectionSID,rp.PracticeRegisterSectionSID)
				,@RegistrationNo                                            = isnull(@RegistrationNo,rp.RegistrationNo)
				,@RegistrationRegistrationYear                              = isnull(@RegistrationRegistrationYear,rp.RegistrationRegistrationYear)
				,@RegistrationEffectiveTime                                 = isnull(@RegistrationEffectiveTime,rp.RegistrationEffectiveTime)
				,@RegistrationExpiryTime                                    = isnull(@RegistrationExpiryTime,rp.RegistrationExpiryTime)
				,@CardPrintedTime                                           = isnull(@CardPrintedTime,rp.CardPrintedTime)
				,@InvoiceSID                                                = isnull(@InvoiceSID,rp.InvoiceSID)
				,@ReasonSID                                                 = isnull(@ReasonSID,rp.ReasonSID)
				,@FormGUID                                                  = isnull(@FormGUID,rp.FormGUID)
				,@RegistrationRowGUID                                       = isnull(@RegistrationRowGUID,rp.RegistrationRowGUID)
				,@RegistrationSnapshotTypeSID                               = isnull(@RegistrationSnapshotTypeSID,rp.RegistrationSnapshotTypeSID)
				,@RegistrationSnapshotLabel                                 = isnull(@RegistrationSnapshotLabel,rp.RegistrationSnapshotLabel)
				,@RegistrationSnapshotRegistrationYear                      = isnull(@RegistrationSnapshotRegistrationYear,rp.RegistrationSnapshotRegistrationYear)
				,@QueuedTime                                                = isnull(@QueuedTime,rp.QueuedTime)
				,@LockedTime                                                = isnull(@LockedTime,rp.LockedTime)
				,@LastCodeUpdateTime                                        = isnull(@LastCodeUpdateTime,rp.LastCodeUpdateTime)
				,@RegistrationSnapshotLastVerifiedTime                      = isnull(@RegistrationSnapshotLastVerifiedTime,rp.RegistrationSnapshotLastVerifiedTime)
				,@JobRunSID                                                 = isnull(@JobRunSID,rp.JobRunSID)
				,@RegistrationSnapshotRowGUID                               = isnull(@RegistrationSnapshotRowGUID,rp.RegistrationSnapshotRowGUID)
				,@PersonMailingAddressPersonSID                             = isnull(@PersonMailingAddressPersonSID,rp.PersonMailingAddressPersonSID)
				,@StreetAddress1                                            = isnull(@StreetAddress1,rp.StreetAddress1)
				,@StreetAddress2                                            = isnull(@StreetAddress2,rp.StreetAddress2)
				,@StreetAddress3                                            = isnull(@StreetAddress3,rp.StreetAddress3)
				,@CitySID                                                   = isnull(@CitySID,rp.CitySID)
				,@PostalCode                                                = isnull(@PostalCode,rp.PostalCode)
				,@RegionSID                                                 = isnull(@RegionSID,rp.RegionSID)
				,@PersonMailingAddressEffectiveTime                         = isnull(@PersonMailingAddressEffectiveTime,rp.PersonMailingAddressEffectiveTime)
				,@IsAdminReviewRequired                                     = isnull(@IsAdminReviewRequired,rp.IsAdminReviewRequired)
				,@PersonMailingAddressLastVerifiedTime                      = isnull(@PersonMailingAddressLastVerifiedTime,rp.PersonMailingAddressLastVerifiedTime)
				,@PersonMailingAddressRowGUID                               = isnull(@PersonMailingAddressRowGUID,rp.PersonMailingAddressRowGUID)
				,@RegistrantCredentialEducation1RegistrantSID               = isnull(@RegistrantCredentialEducation1RegistrantSID,rp.RegistrantCredentialEducation1RegistrantSID)
				,@RegistrantCredentialEducation1CredentialSID               = isnull(@RegistrantCredentialEducation1CredentialSID,rp.RegistrantCredentialEducation1CredentialSID)
				,@RegistrantCredentialEducation1OrgSID                      = isnull(@RegistrantCredentialEducation1OrgSID,rp.RegistrantCredentialEducation1OrgSID)
				,@RegistrantCredentialEducation1ProgramName                 = isnull(@RegistrantCredentialEducation1ProgramName,rp.RegistrantCredentialEducation1ProgramName)
				,@RegistrantCredentialEducation1ProgramStartDate            = isnull(@RegistrantCredentialEducation1ProgramStartDate,rp.RegistrantCredentialEducation1ProgramStartDate)
				,@RegistrantCredentialEducation1ProgramTargetCompletionDate = isnull(@RegistrantCredentialEducation1ProgramTargetCompletionDate,rp.RegistrantCredentialEducation1ProgramTargetCompletionDate)
				,@RegistrantCredentialEducation1EffectiveTime               = isnull(@RegistrantCredentialEducation1EffectiveTime,rp.RegistrantCredentialEducation1EffectiveTime)
				,@RegistrantCredentialEducation1ExpiryTime                  = isnull(@RegistrantCredentialEducation1ExpiryTime,rp.RegistrantCredentialEducation1ExpiryTime)
				,@RegistrantCredentialEducation1FieldOfStudySID             = isnull(@RegistrantCredentialEducation1FieldOfStudySID,rp.RegistrantCredentialEducation1FieldOfStudySID)
				,@RegistrantCredentialEducation1RowGUID                     = isnull(@RegistrantCredentialEducation1RowGUID,rp.RegistrantCredentialEducation1RowGUID)
				,@RegistrantCredentialEducation2RegistrantSID               = isnull(@RegistrantCredentialEducation2RegistrantSID,rp.RegistrantCredentialEducation2RegistrantSID)
				,@RegistrantCredentialEducation2CredentialSID               = isnull(@RegistrantCredentialEducation2CredentialSID,rp.RegistrantCredentialEducation2CredentialSID)
				,@RegistrantCredentialEducation2OrgSID                      = isnull(@RegistrantCredentialEducation2OrgSID,rp.RegistrantCredentialEducation2OrgSID)
				,@RegistrantCredentialEducation2ProgramName                 = isnull(@RegistrantCredentialEducation2ProgramName,rp.RegistrantCredentialEducation2ProgramName)
				,@RegistrantCredentialEducation2ProgramStartDate            = isnull(@RegistrantCredentialEducation2ProgramStartDate,rp.RegistrantCredentialEducation2ProgramStartDate)
				,@RegistrantCredentialEducation2ProgramTargetCompletionDate = isnull(@RegistrantCredentialEducation2ProgramTargetCompletionDate,rp.RegistrantCredentialEducation2ProgramTargetCompletionDate)
				,@RegistrantCredentialEducation2EffectiveTime               = isnull(@RegistrantCredentialEducation2EffectiveTime,rp.RegistrantCredentialEducation2EffectiveTime)
				,@RegistrantCredentialEducation2ExpiryTime                  = isnull(@RegistrantCredentialEducation2ExpiryTime,rp.RegistrantCredentialEducation2ExpiryTime)
				,@RegistrantCredentialEducation2FieldOfStudySID             = isnull(@RegistrantCredentialEducation2FieldOfStudySID,rp.RegistrantCredentialEducation2FieldOfStudySID)
				,@RegistrantCredentialEducation2RowGUID                     = isnull(@RegistrantCredentialEducation2RowGUID,rp.RegistrantCredentialEducation2RowGUID)
				,@RegistrantCredentialEducation3RegistrantSID               = isnull(@RegistrantCredentialEducation3RegistrantSID,rp.RegistrantCredentialEducation3RegistrantSID)
				,@RegistrantCredentialEducation3CredentialSID               = isnull(@RegistrantCredentialEducation3CredentialSID,rp.RegistrantCredentialEducation3CredentialSID)
				,@RegistrantCredentialEducation3OrgSID                      = isnull(@RegistrantCredentialEducation3OrgSID,rp.RegistrantCredentialEducation3OrgSID)
				,@RegistrantCredentialEducation3ProgramName                 = isnull(@RegistrantCredentialEducation3ProgramName,rp.RegistrantCredentialEducation3ProgramName)
				,@RegistrantCredentialEducation3ProgramStartDate            = isnull(@RegistrantCredentialEducation3ProgramStartDate,rp.RegistrantCredentialEducation3ProgramStartDate)
				,@RegistrantCredentialEducation3ProgramTargetCompletionDate = isnull(@RegistrantCredentialEducation3ProgramTargetCompletionDate,rp.RegistrantCredentialEducation3ProgramTargetCompletionDate)
				,@RegistrantCredentialEducation3EffectiveTime               = isnull(@RegistrantCredentialEducation3EffectiveTime,rp.RegistrantCredentialEducation3EffectiveTime)
				,@RegistrantCredentialEducation3ExpiryTime                  = isnull(@RegistrantCredentialEducation3ExpiryTime,rp.RegistrantCredentialEducation3ExpiryTime)
				,@RegistrantCredentialEducation3FieldOfStudySID             = isnull(@RegistrantCredentialEducation3FieldOfStudySID,rp.RegistrantCredentialEducation3FieldOfStudySID)
				,@RegistrantCredentialEducation3RowGUID                     = isnull(@RegistrantCredentialEducation3RowGUID,rp.RegistrantCredentialEducation3RowGUID)
				,@RegistrantEmploymentEmployment1RegistrantSID              = isnull(@RegistrantEmploymentEmployment1RegistrantSID,rp.RegistrantEmploymentEmployment1RegistrantSID)
				,@RegistrantEmploymentEmployment1OrgSID                     = isnull(@RegistrantEmploymentEmployment1OrgSID,rp.RegistrantEmploymentEmployment1OrgSID)
				,@RegistrantEmploymentEmployment1RegistrationYear           = isnull(@RegistrantEmploymentEmployment1RegistrationYear,rp.RegistrantEmploymentEmployment1RegistrationYear)
				,@RegistrantEmploymentEmployment1EmploymentTypeSID          = isnull(@RegistrantEmploymentEmployment1EmploymentTypeSID,rp.RegistrantEmploymentEmployment1EmploymentTypeSID)
				,@RegistrantEmploymentEmployment1EmploymentRoleSID          = isnull(@RegistrantEmploymentEmployment1EmploymentRoleSID,rp.RegistrantEmploymentEmployment1EmploymentRoleSID)
				,@RegistrantEmploymentEmployment1PracticeHours              = isnull(@RegistrantEmploymentEmployment1PracticeHours,rp.RegistrantEmploymentEmployment1PracticeHours)
				,@RegistrantEmploymentEmployment1PracticeScopeSID           = isnull(@RegistrantEmploymentEmployment1PracticeScopeSID,rp.RegistrantEmploymentEmployment1PracticeScopeSID)
				,@RegistrantEmploymentEmployment1AgeRangeSID                = isnull(@RegistrantEmploymentEmployment1AgeRangeSID,rp.RegistrantEmploymentEmployment1AgeRangeSID)
				,@RegistrantEmploymentEmployment1IsOnPublicRegistry         = isnull(@RegistrantEmploymentEmployment1IsOnPublicRegistry,rp.RegistrantEmploymentEmployment1IsOnPublicRegistry)
				,@RegistrantEmploymentEmployment1Phone                      = isnull(@RegistrantEmploymentEmployment1Phone,rp.RegistrantEmploymentEmployment1Phone)
				,@RegistrantEmploymentEmployment1SiteLocation               = isnull(@RegistrantEmploymentEmployment1SiteLocation,rp.RegistrantEmploymentEmployment1SiteLocation)
				,@RegistrantEmploymentEmployment1EffectiveTime              = isnull(@RegistrantEmploymentEmployment1EffectiveTime,rp.RegistrantEmploymentEmployment1EffectiveTime)
				,@RegistrantEmploymentEmployment1ExpiryTime                 = isnull(@RegistrantEmploymentEmployment1ExpiryTime,rp.RegistrantEmploymentEmployment1ExpiryTime)
				,@RegistrantEmploymentEmployment1Rank                       = isnull(@RegistrantEmploymentEmployment1Rank,rp.RegistrantEmploymentEmployment1Rank)
				,@RegistrantEmploymentEmployment1OwnershipPercentage        = isnull(@RegistrantEmploymentEmployment1OwnershipPercentage,rp.RegistrantEmploymentEmployment1OwnershipPercentage)
				,@RegistrantEmploymentEmployment1IsEmployerInsurance        = isnull(@RegistrantEmploymentEmployment1IsEmployerInsurance,rp.RegistrantEmploymentEmployment1IsEmployerInsurance)
				,@RegistrantEmploymentEmployment1InsuranceOrgSID            = isnull(@RegistrantEmploymentEmployment1InsuranceOrgSID,rp.RegistrantEmploymentEmployment1InsuranceOrgSID)
				,@RegistrantEmploymentEmployment1InsurancePolicyNo          = isnull(@RegistrantEmploymentEmployment1InsurancePolicyNo,rp.RegistrantEmploymentEmployment1InsurancePolicyNo)
				,@RegistrantEmploymentEmployment1InsuranceAmount            = isnull(@RegistrantEmploymentEmployment1InsuranceAmount,rp.RegistrantEmploymentEmployment1InsuranceAmount)
				,@RegistrantEmploymentEmployment1RowGUID                    = isnull(@RegistrantEmploymentEmployment1RowGUID,rp.RegistrantEmploymentEmployment1RowGUID)
				,@RegistrantEmploymentEmployment2RegistrantSID              = isnull(@RegistrantEmploymentEmployment2RegistrantSID,rp.RegistrantEmploymentEmployment2RegistrantSID)
				,@RegistrantEmploymentEmployment2OrgSID                     = isnull(@RegistrantEmploymentEmployment2OrgSID,rp.RegistrantEmploymentEmployment2OrgSID)
				,@RegistrantEmploymentEmployment2RegistrationYear           = isnull(@RegistrantEmploymentEmployment2RegistrationYear,rp.RegistrantEmploymentEmployment2RegistrationYear)
				,@RegistrantEmploymentEmployment2EmploymentTypeSID          = isnull(@RegistrantEmploymentEmployment2EmploymentTypeSID,rp.RegistrantEmploymentEmployment2EmploymentTypeSID)
				,@RegistrantEmploymentEmployment2EmploymentRoleSID          = isnull(@RegistrantEmploymentEmployment2EmploymentRoleSID,rp.RegistrantEmploymentEmployment2EmploymentRoleSID)
				,@RegistrantEmploymentEmployment2PracticeHours              = isnull(@RegistrantEmploymentEmployment2PracticeHours,rp.RegistrantEmploymentEmployment2PracticeHours)
				,@RegistrantEmploymentEmployment2PracticeScopeSID           = isnull(@RegistrantEmploymentEmployment2PracticeScopeSID,rp.RegistrantEmploymentEmployment2PracticeScopeSID)
				,@RegistrantEmploymentEmployment2AgeRangeSID                = isnull(@RegistrantEmploymentEmployment2AgeRangeSID,rp.RegistrantEmploymentEmployment2AgeRangeSID)
				,@RegistrantEmploymentEmployment2IsOnPublicRegistry         = isnull(@RegistrantEmploymentEmployment2IsOnPublicRegistry,rp.RegistrantEmploymentEmployment2IsOnPublicRegistry)
				,@RegistrantEmploymentEmployment2Phone                      = isnull(@RegistrantEmploymentEmployment2Phone,rp.RegistrantEmploymentEmployment2Phone)
				,@RegistrantEmploymentEmployment2SiteLocation               = isnull(@RegistrantEmploymentEmployment2SiteLocation,rp.RegistrantEmploymentEmployment2SiteLocation)
				,@RegistrantEmploymentEmployment2EffectiveTime              = isnull(@RegistrantEmploymentEmployment2EffectiveTime,rp.RegistrantEmploymentEmployment2EffectiveTime)
				,@RegistrantEmploymentEmployment2ExpiryTime                 = isnull(@RegistrantEmploymentEmployment2ExpiryTime,rp.RegistrantEmploymentEmployment2ExpiryTime)
				,@RegistrantEmploymentEmployment2Rank                       = isnull(@RegistrantEmploymentEmployment2Rank,rp.RegistrantEmploymentEmployment2Rank)
				,@RegistrantEmploymentEmployment2OwnershipPercentage        = isnull(@RegistrantEmploymentEmployment2OwnershipPercentage,rp.RegistrantEmploymentEmployment2OwnershipPercentage)
				,@RegistrantEmploymentEmployment2IsEmployerInsurance        = isnull(@RegistrantEmploymentEmployment2IsEmployerInsurance,rp.RegistrantEmploymentEmployment2IsEmployerInsurance)
				,@RegistrantEmploymentEmployment2InsuranceOrgSID            = isnull(@RegistrantEmploymentEmployment2InsuranceOrgSID,rp.RegistrantEmploymentEmployment2InsuranceOrgSID)
				,@RegistrantEmploymentEmployment2InsurancePolicyNo          = isnull(@RegistrantEmploymentEmployment2InsurancePolicyNo,rp.RegistrantEmploymentEmployment2InsurancePolicyNo)
				,@RegistrantEmploymentEmployment2InsuranceAmount            = isnull(@RegistrantEmploymentEmployment2InsuranceAmount,rp.RegistrantEmploymentEmployment2InsuranceAmount)
				,@RegistrantEmploymentEmployment2RowGUID                    = isnull(@RegistrantEmploymentEmployment2RowGUID,rp.RegistrantEmploymentEmployment2RowGUID)
				,@RegistrantEmploymentEmployment3RegistrantSID              = isnull(@RegistrantEmploymentEmployment3RegistrantSID,rp.RegistrantEmploymentEmployment3RegistrantSID)
				,@RegistrantEmploymentEmployment3OrgSID                     = isnull(@RegistrantEmploymentEmployment3OrgSID,rp.RegistrantEmploymentEmployment3OrgSID)
				,@RegistrantEmploymentEmployment3RegistrationYear           = isnull(@RegistrantEmploymentEmployment3RegistrationYear,rp.RegistrantEmploymentEmployment3RegistrationYear)
				,@RegistrantEmploymentEmployment3EmploymentTypeSID          = isnull(@RegistrantEmploymentEmployment3EmploymentTypeSID,rp.RegistrantEmploymentEmployment3EmploymentTypeSID)
				,@RegistrantEmploymentEmployment3EmploymentRoleSID          = isnull(@RegistrantEmploymentEmployment3EmploymentRoleSID,rp.RegistrantEmploymentEmployment3EmploymentRoleSID)
				,@RegistrantEmploymentEmployment3PracticeHours              = isnull(@RegistrantEmploymentEmployment3PracticeHours,rp.RegistrantEmploymentEmployment3PracticeHours)
				,@RegistrantEmploymentEmployment3PracticeScopeSID           = isnull(@RegistrantEmploymentEmployment3PracticeScopeSID,rp.RegistrantEmploymentEmployment3PracticeScopeSID)
				,@RegistrantEmploymentEmployment3AgeRangeSID                = isnull(@RegistrantEmploymentEmployment3AgeRangeSID,rp.RegistrantEmploymentEmployment3AgeRangeSID)
				,@RegistrantEmploymentEmployment3IsOnPublicRegistry         = isnull(@RegistrantEmploymentEmployment3IsOnPublicRegistry,rp.RegistrantEmploymentEmployment3IsOnPublicRegistry)
				,@RegistrantEmploymentEmployment3Phone                      = isnull(@RegistrantEmploymentEmployment3Phone,rp.RegistrantEmploymentEmployment3Phone)
				,@RegistrantEmploymentEmployment3SiteLocation               = isnull(@RegistrantEmploymentEmployment3SiteLocation,rp.RegistrantEmploymentEmployment3SiteLocation)
				,@RegistrantEmploymentEmployment3EffectiveTime              = isnull(@RegistrantEmploymentEmployment3EffectiveTime,rp.RegistrantEmploymentEmployment3EffectiveTime)
				,@RegistrantEmploymentEmployment3ExpiryTime                 = isnull(@RegistrantEmploymentEmployment3ExpiryTime,rp.RegistrantEmploymentEmployment3ExpiryTime)
				,@RegistrantEmploymentEmployment3Rank                       = isnull(@RegistrantEmploymentEmployment3Rank,rp.RegistrantEmploymentEmployment3Rank)
				,@RegistrantEmploymentEmployment3OwnershipPercentage        = isnull(@RegistrantEmploymentEmployment3OwnershipPercentage,rp.RegistrantEmploymentEmployment3OwnershipPercentage)
				,@RegistrantEmploymentEmployment3IsEmployerInsurance        = isnull(@RegistrantEmploymentEmployment3IsEmployerInsurance,rp.RegistrantEmploymentEmployment3IsEmployerInsurance)
				,@RegistrantEmploymentEmployment3InsuranceOrgSID            = isnull(@RegistrantEmploymentEmployment3InsuranceOrgSID,rp.RegistrantEmploymentEmployment3InsuranceOrgSID)
				,@RegistrantEmploymentEmployment3InsurancePolicyNo          = isnull(@RegistrantEmploymentEmployment3InsurancePolicyNo,rp.RegistrantEmploymentEmployment3InsurancePolicyNo)
				,@RegistrantEmploymentEmployment3InsuranceAmount            = isnull(@RegistrantEmploymentEmployment3InsuranceAmount,rp.RegistrantEmploymentEmployment3InsuranceAmount)
				,@RegistrantEmploymentEmployment3RowGUID                    = isnull(@RegistrantEmploymentEmployment3RowGUID,rp.RegistrantEmploymentEmployment3RowGUID)
				,@RegistrantPracticeRegistrantSID                           = isnull(@RegistrantPracticeRegistrantSID,rp.RegistrantPracticeRegistrantSID)
				,@RegistrantPracticeRegistrationYear                        = isnull(@RegistrantPracticeRegistrationYear,rp.RegistrantPracticeRegistrationYear)
				,@EmploymentStatusSID                                       = isnull(@EmploymentStatusSID,rp.EmploymentStatusSID)
				,@PlannedRetirementDate                                     = isnull(@PlannedRetirementDate,rp.PlannedRetirementDate)
				,@OtherJurisdiction                                         = isnull(@OtherJurisdiction,rp.OtherJurisdiction)
				,@OtherJurisdictionHours                                    = isnull(@OtherJurisdictionHours,rp.OtherJurisdictionHours)
				,@TotalPracticeHours                                        = isnull(@TotalPracticeHours,rp.TotalPracticeHours)
				,@RegistrantPracticeOrgSID                                  = isnull(@RegistrantPracticeOrgSID,rp.RegistrantPracticeOrgSID)
				,@RegistrantPracticeInsurancePolicyNo                       = isnull(@RegistrantPracticeInsurancePolicyNo,rp.RegistrantPracticeInsurancePolicyNo)
				,@RegistrantPracticeInsuranceAmount                         = isnull(@RegistrantPracticeInsuranceAmount,rp.RegistrantPracticeInsuranceAmount)
				,@InsuranceCertificateNo                                    = isnull(@InsuranceCertificateNo,rp.InsuranceCertificateNo)
				,@RegistrantPracticeRowGUID                                 = isnull(@RegistrantPracticeRowGUID,rp.RegistrantPracticeRowGUID)
				,@IsDeleteEnabled                                           = isnull(@IsDeleteEnabled,rp.IsDeleteEnabled)
				,@RegistrantLabel                                           = isnull(@RegistrantLabel,rp.RegistrantLabel)
				,@FirstName                                                 = isnull(@FirstName,rp.FirstName)
				,@CommonName                                                = isnull(@CommonName,rp.CommonName)
				,@MiddleNames                                               = isnull(@MiddleNames,rp.MiddleNames)
				,@LastName                                                  = isnull(@LastName,rp.LastName)
				,@DeathDate                                                 = isnull(@DeathDate,rp.DeathDate)
				,@HomePhone                                                 = isnull(@HomePhone,rp.HomePhone)
				,@MobilePhone                                               = isnull(@MobilePhone,rp.MobilePhone)
				,@IsValid                                                   = isnull(@IsValid,rp.IsValid)
				,@CIHIGenderCD                                              = isnull(@CIHIGenderCD,rp.CIHIGenderCD)
				,@CIHIBirthYear                                             = isnull(@CIHIBirthYear,rp.CIHIBirthYear)
				,@CIHIEducation1CredentialCode                              = isnull(@CIHIEducation1CredentialCode,rp.CIHIEducation1CredentialCode)
				,@CIHIEducation1GraduationYear                              = isnull(@CIHIEducation1GraduationYear,rp.CIHIEducation1GraduationYear)
				,@CIHIEducation1Location                                    = isnull(@CIHIEducation1Location,rp.CIHIEducation1Location)
				,@CIHIEducation2CredentialCode                              = isnull(@CIHIEducation2CredentialCode,rp.CIHIEducation2CredentialCode)
				,@CIHIEducation3CredentialCode                              = isnull(@CIHIEducation3CredentialCode,rp.CIHIEducation3CredentialCode)
				,@CIHIEmploymentStatusCode                                  = isnull(@CIHIEmploymentStatusCode,rp.CIHIEmploymentStatusCode)
				,@CIHIEmployment1TypeCode                                   = isnull(@CIHIEmployment1TypeCode,rp.CIHIEmployment1TypeCode)
				,@CIHIMultipleEmploymentStatus                              = isnull(@CIHIMultipleEmploymentStatus,rp.CIHIMultipleEmploymentStatus)
				,@CIHIEmployment1Location                                   = isnull(@CIHIEmployment1Location,rp.CIHIEmployment1Location)
				,@CIHIEmployment1OrgTypeCode                                = isnull(@CIHIEmployment1OrgTypeCode,rp.CIHIEmployment1OrgTypeCode)
				,@CIHIEmployment1PracticeAreaCode                           = isnull(@CIHIEmployment1PracticeAreaCode,rp.CIHIEmployment1PracticeAreaCode)
				,@CIHIEmployment1PracticeScopeCode                          = isnull(@CIHIEmployment1PracticeScopeCode,rp.CIHIEmployment1PracticeScopeCode)
				,@CIHIEmployment1RoleCode                                   = isnull(@CIHIEmployment1RoleCode,rp.CIHIEmployment1RoleCode)
				,@CIHIResidenceLocation                                     = isnull(@CIHIResidenceLocation,rp.CIHIResidenceLocation)
				,@CIHIResidencePostalCode                                   = isnull(@CIHIResidencePostalCode,rp.CIHIResidencePostalCode)
				,@CIHIEmployment1PostalCode                                 = isnull(@CIHIEmployment1PostalCode,rp.CIHIEmployment1PostalCode)
				,@CIHIRegistrationYearMonth                                 = isnull(@CIHIRegistrationYearMonth,rp.CIHIRegistrationYearMonth)
				,@CIHIEmployment2PostalCode                                 = isnull(@CIHIEmployment2PostalCode,rp.CIHIEmployment2PostalCode)
				,@CIHIEmployment2Location                                   = isnull(@CIHIEmployment2Location,rp.CIHIEmployment2Location)
				,@CIHIEmployment2OrgTypeCode                                = isnull(@CIHIEmployment2OrgTypeCode,rp.CIHIEmployment2OrgTypeCode)
				,@CIHIEmployment2PracticeAreaCode                           = isnull(@CIHIEmployment2PracticeAreaCode,rp.CIHIEmployment2PracticeAreaCode)
				,@CIHIEmployment2PracticeScopeCode                          = isnull(@CIHIEmployment2PracticeScopeCode,rp.CIHIEmployment2PracticeScopeCode)
				,@CIHIEmployment2RoleCode                                   = isnull(@CIHIEmployment2RoleCode,rp.CIHIEmployment2RoleCode)
				,@CIHIEmployment3PostalCode                                 = isnull(@CIHIEmployment3PostalCode,rp.CIHIEmployment3PostalCode)
				,@CIHIEmployment3Location                                   = isnull(@CIHIEmployment3Location,rp.CIHIEmployment3Location)
				,@CIHIEmployment3OrgTypeCode                                = isnull(@CIHIEmployment3OrgTypeCode,rp.CIHIEmployment3OrgTypeCode)
				,@CIHIEmployment3PracticeAreaCode                           = isnull(@CIHIEmployment3PracticeAreaCode,rp.CIHIEmployment3PracticeAreaCode)
				,@CIHIEmployment3PracticeScopeCode                          = isnull(@CIHIEmployment3PracticeScopeCode,rp.CIHIEmployment3PracticeScopeCode)
				,@CIHIEmployment3RoleCode                                   = isnull(@CIHIEmployment3RoleCode,rp.CIHIEmployment3RoleCode)
				,@CurrentCheckSum                                           = isnull(@CurrentCheckSum,rp.CurrentCheckSum)
				,@IsModified                                                = isnull(@IsModified,rp.IsModified)
			from
				dbo.vRegistrationProfile rp
			where
				rp.RegistrationProfileSID = @RegistrationProfileSID

		end
		
		set @ResidencePostalCode   = sf.fFormatPostalCode(@ResidencePostalCode)													-- format postal codes to standard
		set @Employment1PostalCode = sf.fFormatPostalCode(@Employment1PostalCode)
		set @Employment2PostalCode = sf.fFormatPostalCode(@Employment2PostalCode)
		set @Employment3PostalCode = sf.fFormatPostalCode(@Employment3PostalCode)

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Jul 2018
		-- Call subroutine to manage setting of column values based on
		-- changes in foreign key values, and when "refresh" option is
		-- selected in UI (sets code value(s) to -1)

		exec dbo.[pRegistrationProfile#Update$Refresh]
			@RegistrationProfileSID = @RegistrationProfileSID
		 ,@RegistrationSnapshotSID = @RegistrationSnapshotSID
		 ,@RegistrantSID = @RegistrantSID
		 ,@RegistrantNo = @RegistrantNo output
		 ,@GenderSCD = @GenderSCD output
		 ,@BirthDate = @BirthDate output
		 ,@PersonMailingAddressSID = @PersonMailingAddressSID output
		 ,@ResidenceStateProvinceISONumber = @ResidenceStateProvinceISONumber output
		 ,@ResidencePostalCode = @ResidencePostalCode output
		 ,@ResidenceCountryISONumber = @ResidenceCountryISONumber output
		 ,@ResidenceIsDefaultCountry = @ResidenceIsDefaultCountry output
		 ,@IsActivePractice = @IsActivePractice output
		 ,@Education1RegistrantCredentialSID = @Education1RegistrantCredentialSID output
		 ,@Education1CredentialCode = @Education1CredentialCode output
		 ,@Education1GraduationYear = @Education1GraduationYear output
		 ,@Education1StateProvinceISONumber = @Education1StateProvinceISONumber output
		 ,@Education1CountryISONumber = @Education1CountryISONumber output
		 ,@Education1IsDefaultCountry = @Education1IsDefaultCountry output
		 ,@Education2RegistrantCredentialSID = @Education2RegistrantCredentialSID output
		 ,@Education2CredentialCode = @Education2CredentialCode output
		 ,@Education2GraduationYear = @Education2GraduationYear output
		 ,@Education2StateProvinceISONumber = @Education2StateProvinceISONumber output
		 ,@Education2CountryISONumber = @Education2CountryISONumber output
		 ,@Education2IsDefaultCountry = @Education2IsDefaultCountry output
		 ,@Education3RegistrantCredentialSID = @Education3RegistrantCredentialSID output
		 ,@Education3CredentialCode = @Education3CredentialCode output
		 ,@Education3GraduationYear = @Education3GraduationYear output
		 ,@Education3StateProvinceISONumber = @Education3StateProvinceISONumber output
		 ,@Education3CountryISONumber = @Education3CountryISONumber output
		 ,@Education3IsDefaultCountry = @Education3IsDefaultCountry output
		 ,@RegistrantPracticeSID = @RegistrantPracticeSID output
		 ,@EmploymentStatusCode = @EmploymentStatusCode output
		 ,@EmploymentCount = @EmploymentCount output
		 ,@PracticeHours = @PracticeHours output
		 ,@Employment1RegistrantEmploymentSID = @Employment1RegistrantEmploymentSID output
		 ,@Employment1TypeCode = @Employment1TypeCode output
		 ,@Employment1StateProvinceISONumber = @Employment1StateProvinceISONumber output
		 ,@Employment1PostalCode = @Employment1PostalCode output
		 ,@Employment1OrgTypeCode = @Employment1OrgTypeCode output
		 ,@Employment1PracticeScopeCode = @Employment1PracticeScopeCode output
		 ,@Employment1RoleCode = @Employment1RoleCode output
		 ,@Employment2RegistrantEmploymentSID = @Employment2RegistrantEmploymentSID output
		 ,@Employment2TypeCode = @Employment2TypeCode output
		 ,@Employment2StateProvinceISONumber = @Employment2StateProvinceISONumber output
		 ,@Employment2PostalCode = @Employment2PostalCode output
		 ,@Employment2OrgTypeCode = @Employment2OrgTypeCode output
		 ,@Employment2PracticeScopeCode = @Employment2PracticeScopeCode output
		 ,@Employment2RoleCode = @Employment2RoleCode output
		 ,@Employment3RegistrantEmploymentSID = @Employment3RegistrantEmploymentSID output
		 ,@Employment3TypeCode = @Employment3TypeCode output
		 ,@Employment3StateProvinceISONumber = @Employment3StateProvinceISONumber output
		 ,@Employment3PostalCode = @Employment3PostalCode output
		 ,@Employment3OrgTypeCode = @Employment3OrgTypeCode output
		 ,@Employment3PracticeScopeCode = @Employment3PracticeScopeCode output
		 ,@Employment3RoleCode = @Employment3RoleCode output;

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
				r.RoutineName = 'pRegistrationProfile'
		)
		begin
		
			exec @errorNo = ext.pRegistrationProfile
				 @Mode                                                      = 'update.pre'
				,@RegistrationProfileSID                                    = @RegistrationProfileSID
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
				,@UpdateUser                                                = @UpdateUser
				,@RowStamp                                                  = @RowStamp
				,@IsReselected                                              = @IsReselected
				,@IsNullApplied                                             = @IsNullApplied
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

		-- update the record

		update
			dbo.RegistrationProfile
		set
			 RegistrationSnapshotSID = @RegistrationSnapshotSID
			,JursidictionStateProvinceISONumber = @JursidictionStateProvinceISONumber
			,RegistrantSID = @RegistrantSID
			,RegistrantNo = @RegistrantNo
			,GenderSCD = @GenderSCD
			,BirthDate = @BirthDate
			,PersonMailingAddressSID = @PersonMailingAddressSID
			,ResidenceStateProvinceISONumber = @ResidenceStateProvinceISONumber
			,ResidencePostalCode = @ResidencePostalCode
			,ResidenceCountryISONumber = @ResidenceCountryISONumber
			,ResidenceIsDefaultCountry = @ResidenceIsDefaultCountry
			,RegistrationSID = @RegistrationSID
			,IsActivePractice = @IsActivePractice
			,Education1RegistrantCredentialSID = @Education1RegistrantCredentialSID
			,Education1CredentialCode = @Education1CredentialCode
			,Education1GraduationYear = @Education1GraduationYear
			,Education1StateProvinceISONumber = @Education1StateProvinceISONumber
			,Education1CountryISONumber = @Education1CountryISONumber
			,Education1IsDefaultCountry = @Education1IsDefaultCountry
			,Education2RegistrantCredentialSID = @Education2RegistrantCredentialSID
			,Education2CredentialCode = @Education2CredentialCode
			,Education2GraduationYear = @Education2GraduationYear
			,Education2StateProvinceISONumber = @Education2StateProvinceISONumber
			,Education2CountryISONumber = @Education2CountryISONumber
			,Education2IsDefaultCountry = @Education2IsDefaultCountry
			,Education3RegistrantCredentialSID = @Education3RegistrantCredentialSID
			,Education3CredentialCode = @Education3CredentialCode
			,Education3GraduationYear = @Education3GraduationYear
			,Education3StateProvinceISONumber = @Education3StateProvinceISONumber
			,Education3CountryISONumber = @Education3CountryISONumber
			,Education3IsDefaultCountry = @Education3IsDefaultCountry
			,RegistrantPracticeSID = @RegistrantPracticeSID
			,EmploymentStatusCode = @EmploymentStatusCode
			,EmploymentCount = @EmploymentCount
			,PracticeHours = @PracticeHours
			,Employment1RegistrantEmploymentSID = @Employment1RegistrantEmploymentSID
			,Employment1TypeCode = @Employment1TypeCode
			,Employment1StateProvinceISONumber = @Employment1StateProvinceISONumber
			,Employment1CountryISONumber = @Employment1CountryISONumber
			,Employment1IsDefaultCountry = @Employment1IsDefaultCountry
			,Employment1PostalCode = @Employment1PostalCode
			,Employment1OrgTypeCode = @Employment1OrgTypeCode
			,Employment1PracticeAreaCode = @Employment1PracticeAreaCode
			,Employment1PracticeScopeCode = @Employment1PracticeScopeCode
			,Employment1RoleCode = @Employment1RoleCode
			,Employment2RegistrantEmploymentSID = @Employment2RegistrantEmploymentSID
			,Employment2TypeCode = @Employment2TypeCode
			,Employment2StateProvinceISONumber = @Employment2StateProvinceISONumber
			,Employment2IsDefaultCountry = @Employment2IsDefaultCountry
			,Employment2CountryISONumber = @Employment2CountryISONumber
			,Employment2PostalCode = @Employment2PostalCode
			,Employment2OrgTypeCode = @Employment2OrgTypeCode
			,Employment2PracticeAreaCode = @Employment2PracticeAreaCode
			,Employment2PracticeScopeCode = @Employment2PracticeScopeCode
			,Employment2RoleCode = @Employment2RoleCode
			,Employment3RegistrantEmploymentSID = @Employment3RegistrantEmploymentSID
			,Employment3TypeCode = @Employment3TypeCode
			,Employment3StateProvinceISONumber = @Employment3StateProvinceISONumber
			,Employment3CountryISONumber = @Employment3CountryISONumber
			,Employment3IsDefaultCountry = @Employment3IsDefaultCountry
			,Employment3PostalCode = @Employment3PostalCode
			,Employment3OrgTypeCode = @Employment3OrgTypeCode
			,Employment3PracticeAreaCode = @Employment3PracticeAreaCode
			,Employment3PracticeScopeCode = @Employment3PracticeScopeCode
			,Employment3RoleCode = @Employment3RoleCode
			,IsInvalid = @IsInvalid
			,MessageText = @MessageText
			,CheckSumOnLastExport = @CheckSumOnLastExport
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrationProfileXID = @RegistrationProfileXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationProfileSID = @RegistrationProfileSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationProfile where RegistrationProfileSID = @registrationProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationProfile'
					,@Arg2        = @registrationProfileSID
				
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
				,@Arg2        = 'dbo.RegistrationProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationProfileSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Jul 2018
		-- Revalidate the edited record.

		exec dbo.pRegistrationSnapshot#CIHIValidate
			@RegistrationProfileSID = @registrationProfileSID
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
				r.RoutineName = 'pRegistrationProfile'
		)
		begin
		
			exec @errorNo = ext.pRegistrationProfile
				 @Mode                                                      = 'update.post'
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
				,@UpdateUser                                                = @UpdateUser
				,@RowStamp                                                  = @RowStamp
				,@IsReselected                                              = @IsReselected
				,@IsNullApplied                                             = @IsNullApplied
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
