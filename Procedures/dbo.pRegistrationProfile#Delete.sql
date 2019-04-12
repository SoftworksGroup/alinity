SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationProfile#Delete]
	 @RegistrationProfileSID                                    int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                                                nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                                  timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@RegistrationSnapshotSID                                   int               = null
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
	,@IsDeleted                                                 bit               = null
	,@CreateUser                                                nvarchar(75)      = null
	,@CreateTime                                                datetimeoffset(7) = null
	,@UpdateTime                                                datetimeoffset(7) = null
	,@RowGUID                                                   uniqueidentifier  = null
	,@RegistrantPersonSID                                       int               = null
	,@RegistrantRegistrantNo                                    varchar(50)       = null
	,@YearOfInitialEmployment                                   smallint          = null
	,@RegistrantIsOnPublicRegistry                              bit               = null
	,@CityNameOfBirth                                           nvarchar(30)      = null
	,@CountrySID                                                int               = null
	,@DirectedAuditYearCompetence                               smallint          = null
	,@DirectedAuditYearPracticeHours                            smallint          = null
	,@LateFeeExclusionYear                                      smallint          = null
	,@IsRenewalAutoApprovalBlocked                              bit               = null
	,@RenewalExtensionExpiryTime                                datetime          = null
	,@ArchivedTime                                              datetimeoffset(7) = null
	,@RegistrantRowGUID                                         uniqueidentifier  = null
	,@RegistrationRegistrantSID                                 int               = null
	,@PracticeRegisterSectionSID                                int               = null
	,@RegistrationNo                                            nvarchar(50)      = null
	,@RegistrationRegistrationYear                              smallint          = null
	,@RegistrationEffectiveTime                                 datetime          = null
	,@RegistrationExpiryTime                                    datetime          = null
	,@CardPrintedTime                                           datetime          = null
	,@InvoiceSID                                                int               = null
	,@ReasonSID                                                 int               = null
	,@FormGUID                                                  uniqueidentifier  = null
	,@RegistrationRowGUID                                       uniqueidentifier  = null
	,@RegistrationSnapshotTypeSID                               int               = null
	,@RegistrationSnapshotLabel                                 nvarchar(35)      = null
	,@RegistrationSnapshotRegistrationYear                      smallint          = null
	,@QueuedTime                                                datetimeoffset(7) = null
	,@LockedTime                                                datetimeoffset(7) = null
	,@LastCodeUpdateTime                                        datetimeoffset(7) = null
	,@RegistrationSnapshotLastVerifiedTime                      datetimeoffset(7) = null
	,@JobRunSID                                                 int               = null
	,@RegistrationSnapshotRowGUID                               uniqueidentifier  = null
	,@PersonMailingAddressPersonSID                             int               = null
	,@StreetAddress1                                            nvarchar(75)      = null
	,@StreetAddress2                                            nvarchar(75)      = null
	,@StreetAddress3                                            nvarchar(75)      = null
	,@CitySID                                                   int               = null
	,@PostalCode                                                varchar(10)       = null
	,@RegionSID                                                 int               = null
	,@PersonMailingAddressEffectiveTime                         datetime          = null
	,@IsAdminReviewRequired                                     bit               = null
	,@PersonMailingAddressLastVerifiedTime                      datetimeoffset(7) = null
	,@PersonMailingAddressRowGUID                               uniqueidentifier  = null
	,@RegistrantCredentialEducation1RegistrantSID               int               = null
	,@RegistrantCredentialEducation1CredentialSID               int               = null
	,@RegistrantCredentialEducation1OrgSID                      int               = null
	,@RegistrantCredentialEducation1ProgramName                 nvarchar(65)      = null
	,@RegistrantCredentialEducation1ProgramStartDate            date              = null
	,@RegistrantCredentialEducation1ProgramTargetCompletionDate date              = null
	,@RegistrantCredentialEducation1EffectiveTime               datetime          = null
	,@RegistrantCredentialEducation1ExpiryTime                  datetime          = null
	,@RegistrantCredentialEducation1FieldOfStudySID             int               = null
	,@RegistrantCredentialEducation1RowGUID                     uniqueidentifier  = null
	,@RegistrantCredentialEducation2RegistrantSID               int               = null
	,@RegistrantCredentialEducation2CredentialSID               int               = null
	,@RegistrantCredentialEducation2OrgSID                      int               = null
	,@RegistrantCredentialEducation2ProgramName                 nvarchar(65)      = null
	,@RegistrantCredentialEducation2ProgramStartDate            date              = null
	,@RegistrantCredentialEducation2ProgramTargetCompletionDate date              = null
	,@RegistrantCredentialEducation2EffectiveTime               datetime          = null
	,@RegistrantCredentialEducation2ExpiryTime                  datetime          = null
	,@RegistrantCredentialEducation2FieldOfStudySID             int               = null
	,@RegistrantCredentialEducation2RowGUID                     uniqueidentifier  = null
	,@RegistrantCredentialEducation3RegistrantSID               int               = null
	,@RegistrantCredentialEducation3CredentialSID               int               = null
	,@RegistrantCredentialEducation3OrgSID                      int               = null
	,@RegistrantCredentialEducation3ProgramName                 nvarchar(65)      = null
	,@RegistrantCredentialEducation3ProgramStartDate            date              = null
	,@RegistrantCredentialEducation3ProgramTargetCompletionDate date              = null
	,@RegistrantCredentialEducation3EffectiveTime               datetime          = null
	,@RegistrantCredentialEducation3ExpiryTime                  datetime          = null
	,@RegistrantCredentialEducation3FieldOfStudySID             int               = null
	,@RegistrantCredentialEducation3RowGUID                     uniqueidentifier  = null
	,@RegistrantEmploymentEmployment1RegistrantSID              int               = null
	,@RegistrantEmploymentEmployment1OrgSID                     int               = null
	,@RegistrantEmploymentEmployment1RegistrationYear           smallint          = null
	,@RegistrantEmploymentEmployment1EmploymentTypeSID          int               = null
	,@RegistrantEmploymentEmployment1EmploymentRoleSID          int               = null
	,@RegistrantEmploymentEmployment1PracticeHours              int               = null
	,@RegistrantEmploymentEmployment1PracticeScopeSID           int               = null
	,@RegistrantEmploymentEmployment1AgeRangeSID                int               = null
	,@RegistrantEmploymentEmployment1IsOnPublicRegistry         bit               = null
	,@RegistrantEmploymentEmployment1Phone                      varchar(25)       = null
	,@RegistrantEmploymentEmployment1SiteLocation               nvarchar(50)      = null
	,@RegistrantEmploymentEmployment1EffectiveTime              datetime          = null
	,@RegistrantEmploymentEmployment1ExpiryTime                 datetime          = null
	,@RegistrantEmploymentEmployment1Rank                       smallint          = null
	,@RegistrantEmploymentEmployment1OwnershipPercentage        smallint          = null
	,@RegistrantEmploymentEmployment1IsEmployerInsurance        bit               = null
	,@RegistrantEmploymentEmployment1InsuranceOrgSID            int               = null
	,@RegistrantEmploymentEmployment1InsurancePolicyNo          varchar(25)       = null
	,@RegistrantEmploymentEmployment1InsuranceAmount            decimal(11,2)     = null
	,@RegistrantEmploymentEmployment1RowGUID                    uniqueidentifier  = null
	,@RegistrantEmploymentEmployment2RegistrantSID              int               = null
	,@RegistrantEmploymentEmployment2OrgSID                     int               = null
	,@RegistrantEmploymentEmployment2RegistrationYear           smallint          = null
	,@RegistrantEmploymentEmployment2EmploymentTypeSID          int               = null
	,@RegistrantEmploymentEmployment2EmploymentRoleSID          int               = null
	,@RegistrantEmploymentEmployment2PracticeHours              int               = null
	,@RegistrantEmploymentEmployment2PracticeScopeSID           int               = null
	,@RegistrantEmploymentEmployment2AgeRangeSID                int               = null
	,@RegistrantEmploymentEmployment2IsOnPublicRegistry         bit               = null
	,@RegistrantEmploymentEmployment2Phone                      varchar(25)       = null
	,@RegistrantEmploymentEmployment2SiteLocation               nvarchar(50)      = null
	,@RegistrantEmploymentEmployment2EffectiveTime              datetime          = null
	,@RegistrantEmploymentEmployment2ExpiryTime                 datetime          = null
	,@RegistrantEmploymentEmployment2Rank                       smallint          = null
	,@RegistrantEmploymentEmployment2OwnershipPercentage        smallint          = null
	,@RegistrantEmploymentEmployment2IsEmployerInsurance        bit               = null
	,@RegistrantEmploymentEmployment2InsuranceOrgSID            int               = null
	,@RegistrantEmploymentEmployment2InsurancePolicyNo          varchar(25)       = null
	,@RegistrantEmploymentEmployment2InsuranceAmount            decimal(11,2)     = null
	,@RegistrantEmploymentEmployment2RowGUID                    uniqueidentifier  = null
	,@RegistrantEmploymentEmployment3RegistrantSID              int               = null
	,@RegistrantEmploymentEmployment3OrgSID                     int               = null
	,@RegistrantEmploymentEmployment3RegistrationYear           smallint          = null
	,@RegistrantEmploymentEmployment3EmploymentTypeSID          int               = null
	,@RegistrantEmploymentEmployment3EmploymentRoleSID          int               = null
	,@RegistrantEmploymentEmployment3PracticeHours              int               = null
	,@RegistrantEmploymentEmployment3PracticeScopeSID           int               = null
	,@RegistrantEmploymentEmployment3AgeRangeSID                int               = null
	,@RegistrantEmploymentEmployment3IsOnPublicRegistry         bit               = null
	,@RegistrantEmploymentEmployment3Phone                      varchar(25)       = null
	,@RegistrantEmploymentEmployment3SiteLocation               nvarchar(50)      = null
	,@RegistrantEmploymentEmployment3EffectiveTime              datetime          = null
	,@RegistrantEmploymentEmployment3ExpiryTime                 datetime          = null
	,@RegistrantEmploymentEmployment3Rank                       smallint          = null
	,@RegistrantEmploymentEmployment3OwnershipPercentage        smallint          = null
	,@RegistrantEmploymentEmployment3IsEmployerInsurance        bit               = null
	,@RegistrantEmploymentEmployment3InsuranceOrgSID            int               = null
	,@RegistrantEmploymentEmployment3InsurancePolicyNo          varchar(25)       = null
	,@RegistrantEmploymentEmployment3InsuranceAmount            decimal(11,2)     = null
	,@RegistrantEmploymentEmployment3RowGUID                    uniqueidentifier  = null
	,@RegistrantPracticeRegistrantSID                           int               = null
	,@RegistrantPracticeRegistrationYear                        smallint          = null
	,@EmploymentStatusSID                                       int               = null
	,@PlannedRetirementDate                                     date              = null
	,@OtherJurisdiction                                         nvarchar(100)     = null
	,@OtherJurisdictionHours                                    int               = null
	,@TotalPracticeHours                                        int               = null
	,@RegistrantPracticeOrgSID                                  int               = null
	,@RegistrantPracticeInsurancePolicyNo                       varchar(25)       = null
	,@RegistrantPracticeInsuranceAmount                         decimal(11,2)     = null
	,@InsuranceCertificateNo                                    varchar(25)       = null
	,@RegistrantPracticeRowGUID                                 uniqueidentifier  = null
	,@IsDeleteEnabled                                           bit               = null
	,@zContext                                                  xml               = null -- other values defining context for the delete (if any)
	,@RegistrantLabel                                           nvarchar(75)      = null
	,@FirstName                                                 nvarchar(30)      = null
	,@CommonName                                                nvarchar(30)      = null
	,@MiddleNames                                               nvarchar(30)      = null
	,@LastName                                                  nvarchar(35)      = null
	,@DeathDate                                                 date              = null
	,@HomePhone                                                 varchar(25)       = null
	,@MobilePhone                                               varchar(25)       = null
	,@IsValid                                                   bit               = null
	,@CIHIGenderCD                                              char(1)           = null
	,@CIHIBirthYear                                             int               = null
	,@CIHIEducation1CredentialCode                              varchar(15)       = null
	,@CIHIEducation1GraduationYear                              smallint          = null
	,@CIHIEducation1Location                                    smallint          = null
	,@CIHIEducation2CredentialCode                              varchar(15)       = null
	,@CIHIEducation3CredentialCode                              varchar(15)       = null
	,@CIHIEmploymentStatusCode                                  varchar(20)       = null
	,@CIHIEmployment1TypeCode                                   varchar(20)       = null
	,@CIHIMultipleEmploymentStatus                              char(1)           = null
	,@CIHIEmployment1Location                                   smallint          = null
	,@CIHIEmployment1OrgTypeCode                                varchar(20)       = null
	,@CIHIEmployment1PracticeAreaCode                           varchar(20)       = null
	,@CIHIEmployment1PracticeScopeCode                          varchar(20)       = null
	,@CIHIEmployment1RoleCode                                   varchar(20)       = null
	,@CIHIResidenceLocation                                     smallint          = null
	,@CIHIResidencePostalCode                                   varchar(8000)     = null
	,@CIHIEmployment1PostalCode                                 varchar(8000)     = null
	,@CIHIRegistrationYearMonth                                 char(6)           = null
	,@CIHIEmployment2PostalCode                                 varchar(8000)     = null
	,@CIHIEmployment2Location                                   smallint          = null
	,@CIHIEmployment2OrgTypeCode                                varchar(20)       = null
	,@CIHIEmployment2PracticeAreaCode                           varchar(20)       = null
	,@CIHIEmployment2PracticeScopeCode                          varchar(20)       = null
	,@CIHIEmployment2RoleCode                                   varchar(20)       = null
	,@CIHIEmployment3PostalCode                                 varchar(8000)     = null
	,@CIHIEmployment3Location                                   smallint          = null
	,@CIHIEmployment3OrgTypeCode                                varchar(20)       = null
	,@CIHIEmployment3PracticeAreaCode                           varchar(20)       = null
	,@CIHIEmployment3PracticeScopeCode                          varchar(20)       = null
	,@CIHIEmployment3RoleCode                                   varchar(20)       = null
	,@CurrentCheckSum                                           int               = null
	,@IsModified                                                bit               = null
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationProfile#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the dbo.RegistrationProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationProfile table. The procedure requires a primary key value to locate the record
to delete.

If the @UpdateUser parameter is set to the special value "SystemUser", then the system user established in sf.ConfigParam is
applied.  This option is useful for conversion and system generated deletes the user would not recognized as having caused. Any
other setting of @UpdateUser is ignored and the user identity is used for the deletion.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Other parameters are provided to set context of the deletion event for table-specific and client-specific logic.

Table-specific logic can be added through tagged sections (pre and post update) and a call to an extended procedure supports
client-specific logic. Logic implemented within code tags (table-specific logic) is part of the base product and applies to all client
configurations. Calls to the extended procedure occur immediately after the table-specific logic in both "pre-delete" and "post-delete"
contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationProfile procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "delete.pre" or "delete.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

This procedure is constructed to support the "Change Data Capture" (CDC) feature. Capturing the user making deletions requires
that the UpdateUser column be set before the record is deleted.  If this is not done, it is not possible to see which user
made the deletion in the CDC table. To trap audit information, the "$isDeletedColumn" bit is set to 1 in an update first.  Once
the update is complete the delete operation takes place. Both operations are handled in a single transaction so that both rollback
if either is unsuccessful. This ensures no record remains in the table with the $isDeleteColumn$ bit set to 1 (no soft-deletes).

Business rules for deletion cannot be established in constraints so must be created in this procedure for product-based common rules
and in the ext.pRegistrationProfile procedure for client-specific deletion rules.

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

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from dbo.RegistrationProfile x where x.RegistrationProfileSID = @RegistrationProfileSID

		-- apply the table-specific pre-delete logic (if any)

		--! <PreDelete>
		--  insert pre-delete logic here ...
		--! </PreDelete>
	
		-- call the extended version of the procedure (if it exists) for "delete.pre" mode
		
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
				 @Mode                                                      = 'delete.pre'
				,@RegistrationProfileSID                                    = @RegistrationProfileSID
				,@UpdateUser                                                = @UpdateUser
				,@RowStamp                                                  = @RowStamp
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
				,@IsDeleted                                                 = @IsDeleted
				,@CreateUser                                                = @CreateUser
				,@CreateTime                                                = @CreateTime
				,@UpdateTime                                                = @UpdateTime
				,@RowGUID                                                   = @RowGUID
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
				,@zContext                                                  = @zContext
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

		update																																-- update "IsDeleted" column to trap audit information
			dbo.RegistrationProfile
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationProfileSID = @RegistrationProfileSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				dbo.RegistrationProfile
			where
				RegistrationProfileSID = @RegistrationProfileSID
			
			set @rowsAffected = @@rowcount
			
		end

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
				,@Arg1        = 'delete'
				,@Arg2        = 'dbo.RegistrationProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationProfileSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-delete logic (if any)

		--! <PostDelete>
		--  insert post-delete logic here ...
		--! </PostDelete>
	
		-- call the extended version of the procedure for delete.post - if it exists
		
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
				 @Mode                                                      = 'delete.post'
				,@RegistrationProfileSID                                    = @RegistrationProfileSID
				,@UpdateUser                                                = @UpdateUser
				,@RowStamp                                                  = @RowStamp
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
				,@IsDeleted                                                 = @IsDeleted
				,@CreateUser                                                = @CreateUser
				,@CreateTime                                                = @CreateTime
				,@UpdateTime                                                = @UpdateTime
				,@RowGUID                                                   = @RowGUID
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
				,@zContext                                                  = @zContext
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
