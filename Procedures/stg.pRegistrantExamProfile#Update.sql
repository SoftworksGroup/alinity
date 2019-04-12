SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantExamProfile#Update]
	 @RegistrantExamProfileSID       int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ImportFileSID                  int               = null -- table column values to update:
	,@ProcessingStatusSID            int               = null
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
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@FileFormatSID                  int               = null -- not a base table column
	,@ApplicationEntitySID           int               = null -- not a base table column
	,@FileName                       nvarchar(100)     = null -- not a base table column
	,@LoadStartTime                  datetimeoffset(7) = null -- not a base table column
	,@LoadEndTime                    datetimeoffset(7) = null -- not a base table column
	,@IsFailed                       bit               = null -- not a base table column
	,@MessageText                    nvarchar(4000)    = null -- not a base table column
	,@ImportFileRowGUID              uniqueidentifier  = null -- not a base table column
	,@ProcessingStatusSCD            varchar(10)       = null -- not a base table column
	,@ProcessingStatusLabel          nvarchar(35)      = null -- not a base table column
	,@IsClosedStatus                 bit               = null -- not a base table column
	,@ProcessingStatusIsActive       bit               = null -- not a base table column
	,@ProcessingStatusIsDefault      bit               = null -- not a base table column
	,@ProcessingStatusRowGUID        uniqueidentifier  = null -- not a base table column
	,@GenderSID                      int               = null -- not a base table column
	,@NamePrefixSID                  int               = null -- not a base table column
	,@PersonFirstName                nvarchar(30)      = null -- not a base table column
	,@CommonName                     nvarchar(30)      = null -- not a base table column
	,@MiddleNames                    nvarchar(30)      = null -- not a base table column
	,@PersonLastName                 nvarchar(35)      = null -- not a base table column
	,@PersonBirthDate                date              = null -- not a base table column
	,@DeathDate                      date              = null -- not a base table column
	,@HomePhone                      varchar(25)       = null -- not a base table column
	,@MobilePhone                    varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled         bit               = null -- not a base table column
	,@ImportBatch                    nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@ExamName                       nvarchar(50)      = null -- not a base table column
	,@ExamCategory                   nvarchar(65)      = null -- not a base table column
	,@ExamPassingScore               int               = null -- not a base table column
	,@EffectiveTime                  datetime          = null -- not a base table column
	,@ExpiryTime                     datetime          = null -- not a base table column
	,@IsOnlineExam                   bit               = null -- not a base table column
	,@IsEnabledOnPortal              bit               = null -- not a base table column
	,@Sequence                       int               = null -- not a base table column
	,@CultureSID                     int               = null -- not a base table column
	,@ExamLastVerifiedTime           datetimeoffset(7) = null -- not a base table column
	,@MinLagDaysBetweenAttempts      smallint          = null -- not a base table column
	,@MaxAttemptsPerYear             tinyint           = null -- not a base table column
	,@VendorExamID                   varchar(25)       = null -- not a base table column
	,@ExamRowGUID                    uniqueidentifier  = null -- not a base table column
	,@ExamOfferingExamSID            int               = null -- not a base table column
	,@ExamOfferingOrgSID             int               = null -- not a base table column
	,@ExamOfferingExamTime           datetime          = null -- not a base table column
	,@SeatingCapacity                int               = null -- not a base table column
	,@CatalogItemSID                 int               = null -- not a base table column
	,@BookingCutOffDate              date              = null -- not a base table column
	,@VendorExamOfferingID           varchar(25)       = null -- not a base table column
	,@ExamOfferingRowGUID            uniqueidentifier  = null -- not a base table column
	,@ParentOrgSID                   int               = null -- not a base table column
	,@OrgTypeSID                     int               = null -- not a base table column
	,@OrgName                        nvarchar(150)     = null -- not a base table column
	,@OrgOrgLabel                    nvarchar(35)      = null -- not a base table column
	,@StreetAddress1                 nvarchar(75)      = null -- not a base table column
	,@StreetAddress2                 nvarchar(75)      = null -- not a base table column
	,@StreetAddress3                 nvarchar(75)      = null -- not a base table column
	,@CitySID                        int               = null -- not a base table column
	,@PostalCode                     varchar(10)       = null -- not a base table column
	,@RegionSID                      int               = null -- not a base table column
	,@Phone                          varchar(25)       = null -- not a base table column
	,@Fax                            varchar(25)       = null -- not a base table column
	,@WebSite                        varchar(250)      = null -- not a base table column
	,@OrgEmailAddress                varchar(150)      = null -- not a base table column
	,@InsuranceOrgSID                int               = null -- not a base table column
	,@InsurancePolicyNo              varchar(25)       = null -- not a base table column
	,@InsuranceAmount                decimal(11,2)     = null -- not a base table column
	,@IsEmployer                     bit               = null -- not a base table column
	,@IsCredentialAuthority          bit               = null -- not a base table column
	,@IsInsurer                      bit               = null -- not a base table column
	,@IsInsuranceCertificateRequired bit               = null -- not a base table column
	,@IsPublic                       nchar(10)         = null -- not a base table column
	,@OrgIsActive                    bit               = null -- not a base table column
	,@IsAdminReviewRequired          bit               = null -- not a base table column
	,@OrgLastVerifiedTime            datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                     uniqueidentifier  = null -- not a base table column
	,@RegistrantPersonSID            int               = null -- not a base table column
	,@RegistrantRegistrantNo         varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment        smallint          = null -- not a base table column
	,@IsOnPublicRegistry             bit               = null -- not a base table column
	,@CityNameOfBirth                nvarchar(30)      = null -- not a base table column
	,@CountrySID                     int               = null -- not a base table column
	,@DirectedAuditYearCompetence    smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours smallint          = null -- not a base table column
	,@LateFeeExclusionYear           smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked   bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime     datetime          = null -- not a base table column
	,@ArchivedTime                   datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID              uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@RegistrantLabel                nvarchar(75)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantExamProfile#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the stg.RegistrantExamProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the stg.RegistrantExamProfile table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantExamProfile entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantExamProfile procedure. The extended procedure is only called
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

		if @RegistrantExamProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantExamProfileSID'

			raiserror(@errorText, 18, 1)
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
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ImportFileSID                  = isnull(@ImportFileSID,rep.ImportFileSID)
				,@ProcessingStatusSID            = isnull(@ProcessingStatusSID,rep.ProcessingStatusSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,rep.RegistrantNo)
				,@EmailAddress                   = isnull(@EmailAddress,rep.EmailAddress)
				,@FirstName                      = isnull(@FirstName,rep.FirstName)
				,@LastName                       = isnull(@LastName,rep.LastName)
				,@BirthDate                      = isnull(@BirthDate,rep.BirthDate)
				,@ExamIdentifier                 = isnull(@ExamIdentifier,rep.ExamIdentifier)
				,@ExamDate                       = isnull(@ExamDate,rep.ExamDate)
				,@ExamTime                       = isnull(@ExamTime,rep.ExamTime)
				,@OrgLabel                       = isnull(@OrgLabel,rep.OrgLabel)
				,@ExamResultDate                 = isnull(@ExamResultDate,rep.ExamResultDate)
				,@PassingScore                   = isnull(@PassingScore,rep.PassingScore)
				,@Score                          = isnull(@Score,rep.Score)
				,@AssignedLocation               = isnull(@AssignedLocation,rep.AssignedLocation)
				,@ExamReference                  = isnull(@ExamReference,rep.ExamReference)
				,@PersonSID                      = isnull(@PersonSID,rep.PersonSID)
				,@RegistrantSID                  = isnull(@RegistrantSID,rep.RegistrantSID)
				,@OrgSID                         = isnull(@OrgSID,rep.OrgSID)
				,@ExamSID                        = isnull(@ExamSID,rep.ExamSID)
				,@ExamOfferingSID                = isnull(@ExamOfferingSID,rep.ExamOfferingSID)
				,@ProcessingComments             = isnull(@ProcessingComments,rep.ProcessingComments)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,rep.UserDefinedColumns)
				,@RegistrantExamProfileXID       = isnull(@RegistrantExamProfileXID,rep.RegistrantExamProfileXID)
				,@LegacyKey                      = isnull(@LegacyKey,rep.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,rep.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,rep.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,rep.IsNullApplied)
				,@zContext                       = isnull(@zContext,rep.zContext)
				,@FileFormatSID                  = isnull(@FileFormatSID,rep.FileFormatSID)
				,@ApplicationEntitySID           = isnull(@ApplicationEntitySID,rep.ApplicationEntitySID)
				,@FileName                       = isnull(@FileName,rep.FileName)
				,@LoadStartTime                  = isnull(@LoadStartTime,rep.LoadStartTime)
				,@LoadEndTime                    = isnull(@LoadEndTime,rep.LoadEndTime)
				,@IsFailed                       = isnull(@IsFailed,rep.IsFailed)
				,@MessageText                    = isnull(@MessageText,rep.MessageText)
				,@ImportFileRowGUID              = isnull(@ImportFileRowGUID,rep.ImportFileRowGUID)
				,@ProcessingStatusSCD            = isnull(@ProcessingStatusSCD,rep.ProcessingStatusSCD)
				,@ProcessingStatusLabel          = isnull(@ProcessingStatusLabel,rep.ProcessingStatusLabel)
				,@IsClosedStatus                 = isnull(@IsClosedStatus,rep.IsClosedStatus)
				,@ProcessingStatusIsActive       = isnull(@ProcessingStatusIsActive,rep.ProcessingStatusIsActive)
				,@ProcessingStatusIsDefault      = isnull(@ProcessingStatusIsDefault,rep.ProcessingStatusIsDefault)
				,@ProcessingStatusRowGUID        = isnull(@ProcessingStatusRowGUID,rep.ProcessingStatusRowGUID)
				,@GenderSID                      = isnull(@GenderSID,rep.GenderSID)
				,@NamePrefixSID                  = isnull(@NamePrefixSID,rep.NamePrefixSID)
				,@PersonFirstName                = isnull(@PersonFirstName,rep.PersonFirstName)
				,@CommonName                     = isnull(@CommonName,rep.CommonName)
				,@MiddleNames                    = isnull(@MiddleNames,rep.MiddleNames)
				,@PersonLastName                 = isnull(@PersonLastName,rep.PersonLastName)
				,@PersonBirthDate                = isnull(@PersonBirthDate,rep.PersonBirthDate)
				,@DeathDate                      = isnull(@DeathDate,rep.DeathDate)
				,@HomePhone                      = isnull(@HomePhone,rep.HomePhone)
				,@MobilePhone                    = isnull(@MobilePhone,rep.MobilePhone)
				,@IsTextMessagingEnabled         = isnull(@IsTextMessagingEnabled,rep.IsTextMessagingEnabled)
				,@ImportBatch                    = isnull(@ImportBatch,rep.ImportBatch)
				,@PersonRowGUID                  = isnull(@PersonRowGUID,rep.PersonRowGUID)
				,@ExamName                       = isnull(@ExamName,rep.ExamName)
				,@ExamCategory                   = isnull(@ExamCategory,rep.ExamCategory)
				,@ExamPassingScore               = isnull(@ExamPassingScore,rep.ExamPassingScore)
				,@EffectiveTime                  = isnull(@EffectiveTime,rep.EffectiveTime)
				,@ExpiryTime                     = isnull(@ExpiryTime,rep.ExpiryTime)
				,@IsOnlineExam                   = isnull(@IsOnlineExam,rep.IsOnlineExam)
				,@IsEnabledOnPortal              = isnull(@IsEnabledOnPortal,rep.IsEnabledOnPortal)
				,@Sequence                       = isnull(@Sequence,rep.Sequence)
				,@CultureSID                     = isnull(@CultureSID,rep.CultureSID)
				,@ExamLastVerifiedTime           = isnull(@ExamLastVerifiedTime,rep.ExamLastVerifiedTime)
				,@MinLagDaysBetweenAttempts      = isnull(@MinLagDaysBetweenAttempts,rep.MinLagDaysBetweenAttempts)
				,@MaxAttemptsPerYear             = isnull(@MaxAttemptsPerYear,rep.MaxAttemptsPerYear)
				,@VendorExamID                   = isnull(@VendorExamID,rep.VendorExamID)
				,@ExamRowGUID                    = isnull(@ExamRowGUID,rep.ExamRowGUID)
				,@ExamOfferingExamSID            = isnull(@ExamOfferingExamSID,rep.ExamOfferingExamSID)
				,@ExamOfferingOrgSID             = isnull(@ExamOfferingOrgSID,rep.ExamOfferingOrgSID)
				,@ExamOfferingExamTime           = isnull(@ExamOfferingExamTime,rep.ExamOfferingExamTime)
				,@SeatingCapacity                = isnull(@SeatingCapacity,rep.SeatingCapacity)
				,@CatalogItemSID                 = isnull(@CatalogItemSID,rep.CatalogItemSID)
				,@BookingCutOffDate              = isnull(@BookingCutOffDate,rep.BookingCutOffDate)
				,@VendorExamOfferingID           = isnull(@VendorExamOfferingID,rep.VendorExamOfferingID)
				,@ExamOfferingRowGUID            = isnull(@ExamOfferingRowGUID,rep.ExamOfferingRowGUID)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,rep.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,rep.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,rep.OrgName)
				,@OrgOrgLabel                    = isnull(@OrgOrgLabel,rep.OrgOrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,rep.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,rep.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,rep.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,rep.CitySID)
				,@PostalCode                     = isnull(@PostalCode,rep.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,rep.RegionSID)
				,@Phone                          = isnull(@Phone,rep.Phone)
				,@Fax                            = isnull(@Fax,rep.Fax)
				,@WebSite                        = isnull(@WebSite,rep.WebSite)
				,@OrgEmailAddress                = isnull(@OrgEmailAddress,rep.OrgEmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,rep.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,rep.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,rep.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,rep.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,rep.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,rep.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,rep.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,rep.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,rep.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,rep.IsAdminReviewRequired)
				,@OrgLastVerifiedTime            = isnull(@OrgLastVerifiedTime,rep.OrgLastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,rep.OrgRowGUID)
				,@RegistrantPersonSID            = isnull(@RegistrantPersonSID,rep.RegistrantPersonSID)
				,@RegistrantRegistrantNo         = isnull(@RegistrantRegistrantNo,rep.RegistrantRegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,rep.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,rep.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,rep.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,rep.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,rep.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,rep.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,rep.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,rep.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,rep.RenewalExtensionExpiryTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,rep.ArchivedTime)
				,@RegistrantRowGUID              = isnull(@RegistrantRowGUID,rep.RegistrantRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,rep.IsDeleteEnabled)
				,@RegistrantLabel                = isnull(@RegistrantLabel,rep.RegistrantLabel)
			from
				stg.vRegistrantExamProfile rep
			where
				rep.RegistrantExamProfileSID = @RegistrantExamProfileSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ProcessingStatusSCD is not null and @ProcessingStatusSID = (select x.ProcessingStatusSID from stg.RegistrantExamProfile x where x.RegistrantExamProfileSID = @RegistrantExamProfileSID)
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.OrgSID from stg.RegistrantExamProfile x where x.RegistrantExamProfileSID = @RegistrantExamProfileSID) <> @OrgSID
		begin
			if (select x.IsActive from dbo.Org x where x.OrgSID = @OrgSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'org'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ProcessingStatusSID from stg.RegistrantExamProfile x where x.RegistrantExamProfileSID = @RegistrantExamProfileSID) <> @ProcessingStatusSID
		begin
			if (select x.IsActive from sf.ProcessingStatus x where x.ProcessingStatusSID = @ProcessingStatusSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'processing status'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
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
				r.RoutineName = 'stg#pRegistrantExamProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantExamProfile
				 @Mode                           = 'update.pre'
				,@RegistrantExamProfileSID       = @RegistrantExamProfileSID
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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

		-- update the record

		update
			stg.RegistrantExamProfile
		set
			 ImportFileSID = @ImportFileSID
			,ProcessingStatusSID = @ProcessingStatusSID
			,RegistrantNo = @RegistrantNo
			,EmailAddress = @EmailAddress
			,FirstName = @FirstName
			,LastName = @LastName
			,BirthDate = @BirthDate
			,ExamIdentifier = @ExamIdentifier
			,ExamDate = @ExamDate
			,ExamTime = @ExamTime
			,OrgLabel = @OrgLabel
			,ExamResultDate = @ExamResultDate
			,PassingScore = @PassingScore
			,Score = @Score
			,AssignedLocation = @AssignedLocation
			,ExamReference = @ExamReference
			,PersonSID = @PersonSID
			,RegistrantSID = @RegistrantSID
			,OrgSID = @OrgSID
			,ExamSID = @ExamSID
			,ExamOfferingSID = @ExamOfferingSID
			,ProcessingComments = @ProcessingComments
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantExamProfileXID = @RegistrantExamProfileXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantExamProfileSID = @RegistrantExamProfileSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from stg.RegistrantExamProfile where RegistrantExamProfileSID = @registrantExamProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'stg.RegistrantExamProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'stg.RegistrantExamProfile'
					,@Arg2        = @registrantExamProfileSID
				
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
				,@Arg2        = 'stg.RegistrantExamProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantExamProfileSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
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
				r.RoutineName = 'stg#pRegistrantExamProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantExamProfile
				 @Mode                           = 'update.post'
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
