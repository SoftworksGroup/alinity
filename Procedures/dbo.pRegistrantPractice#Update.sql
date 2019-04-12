SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantPractice#Update]
	 @RegistrantPracticeSID          int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                  int               = null -- table column values to update:
	,@RegistrationYear               smallint          = null
	,@EmploymentStatusSID            int               = null
	,@PlannedRetirementDate          date              = null
	,@OtherJurisdiction              nvarchar(100)     = null
	,@OtherJurisdictionHours         int               = null
	,@TotalPracticeHours             int               = null
	,@OrgSID                         int               = null
	,@InsurancePolicyNo              varchar(25)       = null
	,@InsuranceAmount                decimal(11,2)     = null
	,@InsuranceCertificateNo         varchar(25)       = null
	,@UserDefinedColumns             xml               = null
	,@RegistrantPracticeXID          varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@EmploymentStatusName           nvarchar(50)      = null -- not a base table column
	,@EmploymentStatusCode           varchar(20)       = null -- not a base table column
	,@EmploymentStatusIsDefault      bit               = null -- not a base table column
	,@IsEmploymentExpected           bit               = null -- not a base table column
	,@EmploymentStatusIsActive       bit               = null -- not a base table column
	,@EmploymentStatusRowGUID        uniqueidentifier  = null -- not a base table column
	,@PersonSID                      int               = null -- not a base table column
	,@RegistrantNo                   varchar(50)       = null -- not a base table column
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
	,@ParentOrgSID                   int               = null -- not a base table column
	,@OrgTypeSID                     int               = null -- not a base table column
	,@OrgName                        nvarchar(150)     = null -- not a base table column
	,@OrgLabel                       nvarchar(35)      = null -- not a base table column
	,@StreetAddress1                 nvarchar(75)      = null -- not a base table column
	,@StreetAddress2                 nvarchar(75)      = null -- not a base table column
	,@StreetAddress3                 nvarchar(75)      = null -- not a base table column
	,@CitySID                        int               = null -- not a base table column
	,@PostalCode                     varchar(10)       = null -- not a base table column
	,@RegionSID                      int               = null -- not a base table column
	,@Phone                          varchar(25)       = null -- not a base table column
	,@Fax                            varchar(25)       = null -- not a base table column
	,@WebSite                        varchar(250)      = null -- not a base table column
	,@EmailAddress                   varchar(150)      = null -- not a base table column
	,@InsuranceOrgSID                int               = null -- not a base table column
	,@OrgInsurancePolicyNo           varchar(25)       = null -- not a base table column
	,@OrgInsuranceAmount             decimal(11,2)     = null -- not a base table column
	,@IsEmployer                     bit               = null -- not a base table column
	,@IsCredentialAuthority          bit               = null -- not a base table column
	,@IsInsurer                      bit               = null -- not a base table column
	,@IsInsuranceCertificateRequired bit               = null -- not a base table column
	,@IsPublic                       nchar(10)         = null -- not a base table column
	,@OrgIsActive                    bit               = null -- not a base table column
	,@IsAdminReviewRequired          bit               = null -- not a base table column
	,@LastVerifiedTime               datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                     uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@RegistrantLabel                nvarchar(75)      = null -- not a base table column
	,@FileAsName                     nvarchar(65)      = null -- not a base table column
	,@DisplayName                    nvarchar(65)      = null -- not a base table column
	,@TotalJurisdictionHours         int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantPractice#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantPractice table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantPractice table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantPractice entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantPractice procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantPracticeCheck to test all rules.

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

		if @RegistrantPracticeSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantPracticeSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @OtherJurisdiction = ltrim(rtrim(@OtherJurisdiction))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @InsuranceCertificateNo = ltrim(rtrim(@InsuranceCertificateNo))
		set @RegistrantPracticeXID = ltrim(rtrim(@RegistrantPracticeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @EmploymentStatusName = ltrim(rtrim(@EmploymentStatusName))
		set @EmploymentStatusCode = ltrim(rtrim(@EmploymentStatusCode))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @OrgName = ltrim(rtrim(@OrgName))
		set @OrgLabel = ltrim(rtrim(@OrgLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @Phone = ltrim(rtrim(@Phone))
		set @Fax = ltrim(rtrim(@Fax))
		set @WebSite = ltrim(rtrim(@WebSite))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @OrgInsurancePolicyNo = ltrim(rtrim(@OrgInsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @DisplayName = ltrim(rtrim(@DisplayName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@OtherJurisdiction) = 0 set @OtherJurisdiction = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@InsuranceCertificateNo) = 0 set @InsuranceCertificateNo = null
		if len(@RegistrantPracticeXID) = 0 set @RegistrantPracticeXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@EmploymentStatusName) = 0 set @EmploymentStatusName = null
		if len(@EmploymentStatusCode) = 0 set @EmploymentStatusCode = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@OrgName) = 0 set @OrgName = null
		if len(@OrgLabel) = 0 set @OrgLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@Phone) = 0 set @Phone = null
		if len(@Fax) = 0 set @Fax = null
		if len(@WebSite) = 0 set @WebSite = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@OrgInsurancePolicyNo) = 0 set @OrgInsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@DisplayName) = 0 set @DisplayName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                  = isnull(@RegistrantSID,rp.RegistrantSID)
				,@RegistrationYear               = isnull(@RegistrationYear,rp.RegistrationYear)
				,@EmploymentStatusSID            = isnull(@EmploymentStatusSID,rp.EmploymentStatusSID)
				,@PlannedRetirementDate          = isnull(@PlannedRetirementDate,rp.PlannedRetirementDate)
				,@OtherJurisdiction              = isnull(@OtherJurisdiction,rp.OtherJurisdiction)
				,@OtherJurisdictionHours         = isnull(@OtherJurisdictionHours,rp.OtherJurisdictionHours)
				,@TotalPracticeHours             = isnull(@TotalPracticeHours,rp.TotalPracticeHours)
				,@OrgSID                         = isnull(@OrgSID,rp.OrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,rp.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,rp.InsuranceAmount)
				,@InsuranceCertificateNo         = isnull(@InsuranceCertificateNo,rp.InsuranceCertificateNo)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,rp.UserDefinedColumns)
				,@RegistrantPracticeXID          = isnull(@RegistrantPracticeXID,rp.RegistrantPracticeXID)
				,@LegacyKey                      = isnull(@LegacyKey,rp.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,rp.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,rp.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,rp.IsNullApplied)
				,@zContext                       = isnull(@zContext,rp.zContext)
				,@EmploymentStatusName           = isnull(@EmploymentStatusName,rp.EmploymentStatusName)
				,@EmploymentStatusCode           = isnull(@EmploymentStatusCode,rp.EmploymentStatusCode)
				,@EmploymentStatusIsDefault      = isnull(@EmploymentStatusIsDefault,rp.EmploymentStatusIsDefault)
				,@IsEmploymentExpected           = isnull(@IsEmploymentExpected,rp.IsEmploymentExpected)
				,@EmploymentStatusIsActive       = isnull(@EmploymentStatusIsActive,rp.EmploymentStatusIsActive)
				,@EmploymentStatusRowGUID        = isnull(@EmploymentStatusRowGUID,rp.EmploymentStatusRowGUID)
				,@PersonSID                      = isnull(@PersonSID,rp.PersonSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,rp.RegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,rp.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,rp.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,rp.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,rp.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,rp.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,rp.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,rp.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,rp.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,rp.RenewalExtensionExpiryTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,rp.ArchivedTime)
				,@RegistrantRowGUID              = isnull(@RegistrantRowGUID,rp.RegistrantRowGUID)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,rp.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,rp.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,rp.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,rp.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,rp.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,rp.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,rp.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,rp.CitySID)
				,@PostalCode                     = isnull(@PostalCode,rp.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,rp.RegionSID)
				,@Phone                          = isnull(@Phone,rp.Phone)
				,@Fax                            = isnull(@Fax,rp.Fax)
				,@WebSite                        = isnull(@WebSite,rp.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,rp.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,rp.InsuranceOrgSID)
				,@OrgInsurancePolicyNo           = isnull(@OrgInsurancePolicyNo,rp.OrgInsurancePolicyNo)
				,@OrgInsuranceAmount             = isnull(@OrgInsuranceAmount,rp.OrgInsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,rp.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,rp.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,rp.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,rp.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,rp.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,rp.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,rp.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,rp.LastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,rp.OrgRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,rp.IsDeleteEnabled)
				,@RegistrantLabel                = isnull(@RegistrantLabel,rp.RegistrantLabel)
				,@FileAsName                     = isnull(@FileAsName,rp.FileAsName)
				,@DisplayName                    = isnull(@DisplayName,rp.DisplayName)
				,@TotalJurisdictionHours         = isnull(@TotalJurisdictionHours,rp.TotalJurisdictionHours)
			from
				dbo.vRegistrantPractice rp
			where
				rp.RegistrantPracticeSID = @RegistrantPracticeSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.EmploymentStatusSID from dbo.RegistrantPractice x where x.RegistrantPracticeSID = @RegistrantPracticeSID) <> @EmploymentStatusSID
		begin
			if (select x.IsActive from dbo.EmploymentStatus x where x.EmploymentStatusSID = @EmploymentStatusSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'employment status'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.OrgSID from dbo.RegistrantPractice x where x.RegistrantPracticeSID = @RegistrantPracticeSID) <> @OrgSID
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

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Karun Kakulphimp | Mar 2019
		-- Support overwrite of previously filled values with NULL		
		-- when special token passed (even where @IsNullApplied is off)

		if @OrgSID = 0																					set @OrgSID									= null
		if @InsurancePolicyNo				= '[NULL]'									set @InsurancePolicyNo			= null
		if @InsuranceCertificateNo	= '[NULL]'									set @InsuranceCertificateNo = null
		if @InsuranceAmount					= 0													set @InsuranceAmount				= null
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
				r.RoutineName = 'pRegistrantPractice'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPractice
				 @Mode                           = 'update.pre'
				,@RegistrantPracticeSID          = @RegistrantPracticeSID
				,@RegistrantSID                  = @RegistrantSID output
				,@RegistrationYear               = @RegistrationYear output
				,@EmploymentStatusSID            = @EmploymentStatusSID output
				,@PlannedRetirementDate          = @PlannedRetirementDate output
				,@OtherJurisdiction              = @OtherJurisdiction output
				,@OtherJurisdictionHours         = @OtherJurisdictionHours output
				,@TotalPracticeHours             = @TotalPracticeHours output
				,@OrgSID                         = @OrgSID output
				,@InsurancePolicyNo              = @InsurancePolicyNo output
				,@InsuranceAmount                = @InsuranceAmount output
				,@InsuranceCertificateNo         = @InsuranceCertificateNo output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantPracticeXID          = @RegistrantPracticeXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@EmploymentStatusName           = @EmploymentStatusName
				,@EmploymentStatusCode           = @EmploymentStatusCode
				,@EmploymentStatusIsDefault      = @EmploymentStatusIsDefault
				,@IsEmploymentExpected           = @IsEmploymentExpected
				,@EmploymentStatusIsActive       = @EmploymentStatusIsActive
				,@EmploymentStatusRowGUID        = @EmploymentStatusRowGUID
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
				,@OrgInsurancePolicyNo           = @OrgInsurancePolicyNo
				,@OrgInsuranceAmount             = @OrgInsuranceAmount
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
				,@RegistrantLabel                = @RegistrantLabel
				,@FileAsName                     = @FileAsName
				,@DisplayName                    = @DisplayName
				,@TotalJurisdictionHours         = @TotalJurisdictionHours
		
		end

		-- update the record

		update
			dbo.RegistrantPractice
		set
			 RegistrantSID = @RegistrantSID
			,RegistrationYear = @RegistrationYear
			,EmploymentStatusSID = @EmploymentStatusSID
			,PlannedRetirementDate = @PlannedRetirementDate
			,OtherJurisdiction = @OtherJurisdiction
			,OtherJurisdictionHours = @OtherJurisdictionHours
			,TotalPracticeHours = @TotalPracticeHours
			,OrgSID = @OrgSID
			,InsurancePolicyNo = @InsurancePolicyNo
			,InsuranceAmount = @InsuranceAmount
			,InsuranceCertificateNo = @InsuranceCertificateNo
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantPracticeXID = @RegistrantPracticeXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantPracticeSID = @RegistrantPracticeSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantPractice where RegistrantPracticeSID = @registrantPracticeSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantPractice'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantPractice'
					,@Arg2        = @registrantPracticeSID
				
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
				,@Arg2        = 'dbo.RegistrantPractice'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantPracticeSID
			
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
				r.RoutineName = 'pRegistrantPractice'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPractice
				 @Mode                           = 'update.post'
				,@RegistrantPracticeSID          = @RegistrantPracticeSID
				,@RegistrantSID                  = @RegistrantSID
				,@RegistrationYear               = @RegistrationYear
				,@EmploymentStatusSID            = @EmploymentStatusSID
				,@PlannedRetirementDate          = @PlannedRetirementDate
				,@OtherJurisdiction              = @OtherJurisdiction
				,@OtherJurisdictionHours         = @OtherJurisdictionHours
				,@TotalPracticeHours             = @TotalPracticeHours
				,@OrgSID                         = @OrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@InsuranceCertificateNo         = @InsuranceCertificateNo
				,@UserDefinedColumns             = @UserDefinedColumns
				,@RegistrantPracticeXID          = @RegistrantPracticeXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@EmploymentStatusName           = @EmploymentStatusName
				,@EmploymentStatusCode           = @EmploymentStatusCode
				,@EmploymentStatusIsDefault      = @EmploymentStatusIsDefault
				,@IsEmploymentExpected           = @IsEmploymentExpected
				,@EmploymentStatusIsActive       = @EmploymentStatusIsActive
				,@EmploymentStatusRowGUID        = @EmploymentStatusRowGUID
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
				,@OrgInsurancePolicyNo           = @OrgInsurancePolicyNo
				,@OrgInsuranceAmount             = @OrgInsuranceAmount
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
				,@RegistrantLabel                = @RegistrantLabel
				,@FileAsName                     = @FileAsName
				,@DisplayName                    = @DisplayName
				,@TotalJurisdictionHours         = @TotalJurisdictionHours
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantPracticeSID
			from
				dbo.vRegistrantPractice ent
			where
				ent.RegistrantPracticeSID = @RegistrantPracticeSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantPracticeSID
				,ent.RegistrantSID
				,ent.RegistrationYear
				,ent.EmploymentStatusSID
				,ent.PlannedRetirementDate
				,ent.OtherJurisdiction
				,ent.OtherJurisdictionHours
				,ent.TotalPracticeHours
				,ent.OrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.InsuranceCertificateNo
				,ent.UserDefinedColumns
				,ent.RegistrantPracticeXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.EmploymentStatusName
				,ent.EmploymentStatusCode
				,ent.EmploymentStatusIsDefault
				,ent.IsEmploymentExpected
				,ent.EmploymentStatusIsActive
				,ent.EmploymentStatusRowGUID
				,ent.PersonSID
				,ent.RegistrantNo
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
				,ent.ParentOrgSID
				,ent.OrgTypeSID
				,ent.OrgName
				,ent.OrgLabel
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.Phone
				,ent.Fax
				,ent.WebSite
				,ent.EmailAddress
				,ent.InsuranceOrgSID
				,ent.OrgInsurancePolicyNo
				,ent.OrgInsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.OrgIsActive
				,ent.IsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.OrgRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
				,ent.FileAsName
				,ent.DisplayName
				,ent.TotalJurisdictionHours
			from
				dbo.vRegistrantPractice ent
			where
				ent.RegistrantPracticeSID = @RegistrantPracticeSID

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
