SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantExamProfile#Insert]
	 @RegistrantExamProfileSID       int               = null output				-- identity value assigned to the new record
	,@ImportFileSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : stg.pRegistrantExamProfile#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the stg.RegistrantExamProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.RegistrantExamProfile table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantExamProfile entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantExamProfile procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantExamProfileCheck to test all rules.

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

	set @RegistrantExamProfileSID = null																		-- initialize output parameter

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
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @LastName = ltrim(rtrim(@LastName))
		set @ExamIdentifier = ltrim(rtrim(@ExamIdentifier))
		set @OrgLabel = ltrim(rtrim(@OrgLabel))
		set @AssignedLocation = ltrim(rtrim(@AssignedLocation))
		set @ExamReference = ltrim(rtrim(@ExamReference))
		set @ProcessingComments = ltrim(rtrim(@ProcessingComments))
		set @RegistrantExamProfileXID = ltrim(rtrim(@RegistrantExamProfileXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @FileName = ltrim(rtrim(@FileName))
		set @MessageText = ltrim(rtrim(@MessageText))
		set @ProcessingStatusSCD = ltrim(rtrim(@ProcessingStatusSCD))
		set @ProcessingStatusLabel = ltrim(rtrim(@ProcessingStatusLabel))
		set @PersonFirstName = ltrim(rtrim(@PersonFirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @PersonLastName = ltrim(rtrim(@PersonLastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ExamName = ltrim(rtrim(@ExamName))
		set @ExamCategory = ltrim(rtrim(@ExamCategory))
		set @VendorExamID = ltrim(rtrim(@VendorExamID))
		set @VendorExamOfferingID = ltrim(rtrim(@VendorExamOfferingID))
		set @OrgName = ltrim(rtrim(@OrgName))
		set @OrgOrgLabel = ltrim(rtrim(@OrgOrgLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @Phone = ltrim(rtrim(@Phone))
		set @Fax = ltrim(rtrim(@Fax))
		set @WebSite = ltrim(rtrim(@WebSite))
		set @OrgEmailAddress = ltrim(rtrim(@OrgEmailAddress))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))
		set @RegistrantRegistrantNo = ltrim(rtrim(@RegistrantRegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@LastName) = 0 set @LastName = null
		if len(@ExamIdentifier) = 0 set @ExamIdentifier = null
		if len(@OrgLabel) = 0 set @OrgLabel = null
		if len(@AssignedLocation) = 0 set @AssignedLocation = null
		if len(@ExamReference) = 0 set @ExamReference = null
		if len(@ProcessingComments) = 0 set @ProcessingComments = null
		if len(@RegistrantExamProfileXID) = 0 set @RegistrantExamProfileXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@FileName) = 0 set @FileName = null
		if len(@MessageText) = 0 set @MessageText = null
		if len(@ProcessingStatusSCD) = 0 set @ProcessingStatusSCD = null
		if len(@ProcessingStatusLabel) = 0 set @ProcessingStatusLabel = null
		if len(@PersonFirstName) = 0 set @PersonFirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@PersonLastName) = 0 set @PersonLastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ExamName) = 0 set @ExamName = null
		if len(@ExamCategory) = 0 set @ExamCategory = null
		if len(@VendorExamID) = 0 set @VendorExamID = null
		if len(@VendorExamOfferingID) = 0 set @VendorExamOfferingID = null
		if len(@OrgName) = 0 set @OrgName = null
		if len(@OrgOrgLabel) = 0 set @OrgOrgLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@Phone) = 0 set @Phone = null
		if len(@Fax) = 0 set @Fax = null
		if len(@WebSite) = 0 set @WebSite = null
		if len(@OrgEmailAddress) = 0 set @OrgEmailAddress = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null
		if len(@RegistrantRegistrantNo) = 0 set @RegistrantRegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected             = isnull(@IsReselected            ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ProcessingStatusSCD is not null
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @ProcessingStatusSID  is null select @ProcessingStatusSID  = x.ProcessingStatusSID from sf.ProcessingStatus  x where x.IsDefault = @ON

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
				r.RoutineName = 'stg#pRegistrantExamProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantExamProfile
				 @Mode                           = 'insert.pre'
				,@ImportFileSID                  = @ImportFileSID output
				,@ProcessingStatusSID            = @ProcessingStatusSID output
				,@RegistrantNo                   = @RegistrantNo output
				,@EmailAddress                   = @EmailAddress output
				,@FirstName                      = @FirstName output
				,@LastName                       = @LastName output
				,@BirthDate                      = @BirthDate output
				,@ExamIdentifier                 = @ExamIdentifier output
				,@ExamDate                       = @ExamDate output
				,@ExamTime                       = @ExamTime output
				,@OrgLabel                       = @OrgLabel output
				,@ExamResultDate                 = @ExamResultDate output
				,@PassingScore                   = @PassingScore output
				,@Score                          = @Score output
				,@AssignedLocation               = @AssignedLocation output
				,@ExamReference                  = @ExamReference output
				,@PersonSID                      = @PersonSID output
				,@RegistrantSID                  = @RegistrantSID output
				,@OrgSID                         = @OrgSID output
				,@ExamSID                        = @ExamSID output
				,@ExamOfferingSID                = @ExamOfferingSID output
				,@ProcessingComments             = @ProcessingComments output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantExamProfileXID       = @RegistrantExamProfileXID output
				,@LegacyKey                      = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			stg.RegistrantExamProfile
		(
			 ImportFileSID
			,ProcessingStatusSID
			,RegistrantNo
			,EmailAddress
			,FirstName
			,LastName
			,BirthDate
			,ExamIdentifier
			,ExamDate
			,ExamTime
			,OrgLabel
			,ExamResultDate
			,PassingScore
			,Score
			,AssignedLocation
			,ExamReference
			,PersonSID
			,RegistrantSID
			,OrgSID
			,ExamSID
			,ExamOfferingSID
			,ProcessingComments
			,UserDefinedColumns
			,RegistrantExamProfileXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @ImportFileSID
			,@ProcessingStatusSID
			,@RegistrantNo
			,@EmailAddress
			,@FirstName
			,@LastName
			,@BirthDate
			,@ExamIdentifier
			,@ExamDate
			,@ExamTime
			,@OrgLabel
			,@ExamResultDate
			,@PassingScore
			,@Score
			,@AssignedLocation
			,@ExamReference
			,@PersonSID
			,@RegistrantSID
			,@OrgSID
			,@ExamSID
			,@ExamOfferingSID
			,@ProcessingComments
			,@UserDefinedColumns
			,@RegistrantExamProfileXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected             = @@rowcount
			,@RegistrantExamProfileSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'stg.RegistrantExamProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantExamProfileSID
			
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
				r.RoutineName = 'stg#pRegistrantExamProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantExamProfile
				 @Mode                           = 'insert.post'
				,@RegistrantExamProfileSID       = @RegistrantExamProfileSID
				,@ImportFileSID                  = @ImportFileSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantExamProfileSID
			from
				stg.vRegistrantExamProfile ent
			where
				ent.RegistrantExamProfileSID = @RegistrantExamProfileSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantExamProfileSID
				,ent.ImportFileSID
				,ent.ProcessingStatusSID
				,ent.RegistrantNo
				,ent.EmailAddress
				,ent.FirstName
				,ent.LastName
				,ent.BirthDate
				,ent.ExamIdentifier
				,ent.ExamDate
				,ent.ExamTime
				,ent.OrgLabel
				,ent.ExamResultDate
				,ent.PassingScore
				,ent.Score
				,ent.AssignedLocation
				,ent.ExamReference
				,ent.PersonSID
				,ent.RegistrantSID
				,ent.OrgSID
				,ent.ExamSID
				,ent.ExamOfferingSID
				,ent.ProcessingComments
				,ent.UserDefinedColumns
				,ent.RegistrantExamProfileXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.FileFormatSID
				,ent.ApplicationEntitySID
				,ent.FileName
				,ent.LoadStartTime
				,ent.LoadEndTime
				,ent.IsFailed
				,ent.MessageText
				,ent.ImportFileRowGUID
				,ent.ProcessingStatusSCD
				,ent.ProcessingStatusLabel
				,ent.IsClosedStatus
				,ent.ProcessingStatusIsActive
				,ent.ProcessingStatusIsDefault
				,ent.ProcessingStatusRowGUID
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.PersonFirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.PersonLastName
				,ent.PersonBirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.ExamName
				,ent.ExamCategory
				,ent.ExamPassingScore
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsOnlineExam
				,ent.IsEnabledOnPortal
				,ent.Sequence
				,ent.CultureSID
				,ent.ExamLastVerifiedTime
				,ent.MinLagDaysBetweenAttempts
				,ent.MaxAttemptsPerYear
				,ent.VendorExamID
				,ent.ExamRowGUID
				,ent.ExamOfferingExamSID
				,ent.ExamOfferingOrgSID
				,ent.ExamOfferingExamTime
				,ent.SeatingCapacity
				,ent.CatalogItemSID
				,ent.BookingCutOffDate
				,ent.VendorExamOfferingID
				,ent.ExamOfferingRowGUID
				,ent.ParentOrgSID
				,ent.OrgTypeSID
				,ent.OrgName
				,ent.OrgOrgLabel
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.Phone
				,ent.Fax
				,ent.WebSite
				,ent.OrgEmailAddress
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.OrgIsActive
				,ent.IsAdminReviewRequired
				,ent.OrgLastVerifiedTime
				,ent.OrgRowGUID
				,ent.RegistrantPersonSID
				,ent.RegistrantRegistrantNo
				,ent.YearOfInitialEmployment
				,ent.IsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
			from
				stg.vRegistrantExamProfile ent
			where
				ent.RegistrantExamProfileSID = @RegistrantExamProfileSID

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
