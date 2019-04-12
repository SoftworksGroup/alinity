SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantCredential#Update]
	 @RegistrantCredentialSID        int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                  int               = null -- table column values to update:
	,@CredentialSID                  int               = null
	,@OrgSID                         int               = null
	,@ProgramName                    nvarchar(65)      = null
	,@ProgramStartDate               date              = null
	,@ProgramTargetCompletionDate    date              = null
	,@EffectiveTime                  datetime          = null
	,@ExpiryTime                     datetime          = null
	,@FieldOfStudySID                int               = null
	,@UserDefinedColumns             xml               = null
	,@RegistrantCredentialXID        varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@CredentialTypeSID              int               = null -- not a base table column
	,@CredentialLabel                nvarchar(35)      = null -- not a base table column
	,@ToolTip                        nvarchar(500)     = null -- not a base table column
	,@IsRelatedToProfession          bit               = null -- not a base table column
	,@IsProgramRequired              bit               = null -- not a base table column
	,@IsSpecialization               bit               = null -- not a base table column
	,@CredentialIsActive             bit               = null -- not a base table column
	,@CredentialCode                 varchar(15)       = null -- not a base table column
	,@CredentialRowGUID              uniqueidentifier  = null -- not a base table column
	,@FieldOfStudyName               nvarchar(50)      = null -- not a base table column
	,@FieldOfStudyCode               varchar(20)       = null -- not a base table column
	,@FieldOfStudyCategory           nvarchar(65)      = null -- not a base table column
	,@FieldOfStudyIsDefault          bit               = null -- not a base table column
	,@FieldOfStudyIsActive           bit               = null -- not a base table column
	,@FieldOfStudyRowGUID            uniqueidentifier  = null -- not a base table column
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
	,@InsurancePolicyNo              varchar(25)       = null -- not a base table column
	,@InsuranceAmount                decimal(11,2)     = null -- not a base table column
	,@IsEmployer                     bit               = null -- not a base table column
	,@IsCredentialAuthority          bit               = null -- not a base table column
	,@IsInsurer                      bit               = null -- not a base table column
	,@IsInsuranceCertificateRequired bit               = null -- not a base table column
	,@IsPublic                       nchar(10)         = null -- not a base table column
	,@OrgIsActive                    bit               = null -- not a base table column
	,@IsAdminReviewRequired          bit               = null -- not a base table column
	,@LastVerifiedTime               datetimeoffset(7) = null -- not a base table column
	,@OrgRowGUID                     uniqueidentifier  = null -- not a base table column
	,@IsActive                       bit               = null -- not a base table column
	,@IsPending                      bit               = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsQualifying                   bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantCredential#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantCredential table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantCredential table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantCredential entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantCredential procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantCredentialCheck to test all rules.

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

		if @RegistrantCredentialSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantCredentialSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ProgramName = ltrim(rtrim(@ProgramName))
		set @RegistrantCredentialXID = ltrim(rtrim(@RegistrantCredentialXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @CredentialLabel = ltrim(rtrim(@CredentialLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @CredentialCode = ltrim(rtrim(@CredentialCode))
		set @FieldOfStudyName = ltrim(rtrim(@FieldOfStudyName))
		set @FieldOfStudyCode = ltrim(rtrim(@FieldOfStudyCode))
		set @FieldOfStudyCategory = ltrim(rtrim(@FieldOfStudyCategory))
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
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ProgramName) = 0 set @ProgramName = null
		if len(@RegistrantCredentialXID) = 0 set @RegistrantCredentialXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@CredentialLabel) = 0 set @CredentialLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@CredentialCode) = 0 set @CredentialCode = null
		if len(@FieldOfStudyName) = 0 set @FieldOfStudyName = null
		if len(@FieldOfStudyCode) = 0 set @FieldOfStudyCode = null
		if len(@FieldOfStudyCategory) = 0 set @FieldOfStudyCategory = null
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
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null
		
		if @EffectiveTime is not null	set @EffectiveTime = cast(cast(@EffectiveTime as date) as datetime)																			-- ensure Effective value has start-of-day time component
		if @ExpiryTime is not null		set @ExpiryTime = cast(convert(varchar(8), cast(@ExpiryTime as date), 112) + ' 23:59:59.99' as datetime)-- ensure Expiry value has end-of-day time component

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)													-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()																-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                  = isnull(@RegistrantSID,rc.RegistrantSID)
				,@CredentialSID                  = isnull(@CredentialSID,rc.CredentialSID)
				,@OrgSID                         = isnull(@OrgSID,rc.OrgSID)
				,@ProgramName                    = isnull(@ProgramName,rc.ProgramName)
				,@ProgramStartDate               = isnull(@ProgramStartDate,rc.ProgramStartDate)
				,@ProgramTargetCompletionDate    = isnull(@ProgramTargetCompletionDate,rc.ProgramTargetCompletionDate)
				,@EffectiveTime                  = isnull(@EffectiveTime,rc.EffectiveTime)
				,@ExpiryTime                     = isnull(@ExpiryTime,rc.ExpiryTime)
				,@FieldOfStudySID                = isnull(@FieldOfStudySID,rc.FieldOfStudySID)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,rc.UserDefinedColumns)
				,@RegistrantCredentialXID        = isnull(@RegistrantCredentialXID,rc.RegistrantCredentialXID)
				,@LegacyKey                      = isnull(@LegacyKey,rc.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,rc.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,rc.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,rc.IsNullApplied)
				,@zContext                       = isnull(@zContext,rc.zContext)
				,@CredentialTypeSID              = isnull(@CredentialTypeSID,rc.CredentialTypeSID)
				,@CredentialLabel                = isnull(@CredentialLabel,rc.CredentialLabel)
				,@ToolTip                        = isnull(@ToolTip,rc.ToolTip)
				,@IsRelatedToProfession          = isnull(@IsRelatedToProfession,rc.IsRelatedToProfession)
				,@IsProgramRequired              = isnull(@IsProgramRequired,rc.IsProgramRequired)
				,@IsSpecialization               = isnull(@IsSpecialization,rc.IsSpecialization)
				,@CredentialIsActive             = isnull(@CredentialIsActive,rc.CredentialIsActive)
				,@CredentialCode                 = isnull(@CredentialCode,rc.CredentialCode)
				,@CredentialRowGUID              = isnull(@CredentialRowGUID,rc.CredentialRowGUID)
				,@FieldOfStudyName               = isnull(@FieldOfStudyName,rc.FieldOfStudyName)
				,@FieldOfStudyCode               = isnull(@FieldOfStudyCode,rc.FieldOfStudyCode)
				,@FieldOfStudyCategory           = isnull(@FieldOfStudyCategory,rc.FieldOfStudyCategory)
				,@FieldOfStudyIsDefault          = isnull(@FieldOfStudyIsDefault,rc.FieldOfStudyIsDefault)
				,@FieldOfStudyIsActive           = isnull(@FieldOfStudyIsActive,rc.FieldOfStudyIsActive)
				,@FieldOfStudyRowGUID            = isnull(@FieldOfStudyRowGUID,rc.FieldOfStudyRowGUID)
				,@PersonSID                      = isnull(@PersonSID,rc.PersonSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,rc.RegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,rc.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,rc.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,rc.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,rc.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,rc.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,rc.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,rc.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,rc.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,rc.RenewalExtensionExpiryTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,rc.ArchivedTime)
				,@RegistrantRowGUID              = isnull(@RegistrantRowGUID,rc.RegistrantRowGUID)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,rc.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,rc.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,rc.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,rc.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,rc.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,rc.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,rc.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,rc.CitySID)
				,@PostalCode                     = isnull(@PostalCode,rc.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,rc.RegionSID)
				,@Phone                          = isnull(@Phone,rc.Phone)
				,@Fax                            = isnull(@Fax,rc.Fax)
				,@WebSite                        = isnull(@WebSite,rc.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,rc.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,rc.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,rc.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,rc.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,rc.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,rc.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,rc.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,rc.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,rc.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,rc.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,rc.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,rc.LastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,rc.OrgRowGUID)
				,@IsActive                       = isnull(@IsActive,rc.IsActive)
				,@IsPending                      = isnull(@IsPending,rc.IsPending)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,rc.IsDeleteEnabled)
				,@IsQualifying                   = isnull(@IsQualifying,rc.IsQualifying)
			from
				dbo.vRegistrantCredential rc
			where
				rc.RegistrantCredentialSID = @RegistrantCredentialSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.CredentialSID from dbo.RegistrantCredential x where x.RegistrantCredentialSID = @RegistrantCredentialSID) <> @CredentialSID
			begin
			
				if (select x.IsActive from dbo.Credential x where x.CredentialSID = @CredentialSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'credential'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.FieldOfStudySID from dbo.RegistrantCredential x where x.RegistrantCredentialSID = @RegistrantCredentialSID) <> @FieldOfStudySID
			begin
			
				if (select x.IsActive from dbo.FieldOfStudy x where x.FieldOfStudySID = @FieldOfStudySID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'field of study'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.OrgSID from dbo.RegistrantCredential x where x.RegistrantCredentialSID = @RegistrantCredentialSID) <> @OrgSID
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
				r.RoutineName = 'pRegistrantCredential'
		)
		begin
		
			exec @errorNo = ext.pRegistrantCredential
				 @Mode                           = 'update.pre'
				,@RegistrantCredentialSID        = @RegistrantCredentialSID
				,@RegistrantSID                  = @RegistrantSID output
				,@CredentialSID                  = @CredentialSID output
				,@OrgSID                         = @OrgSID output
				,@ProgramName                    = @ProgramName output
				,@ProgramStartDate               = @ProgramStartDate output
				,@ProgramTargetCompletionDate    = @ProgramTargetCompletionDate output
				,@EffectiveTime                  = @EffectiveTime output
				,@ExpiryTime                     = @ExpiryTime output
				,@FieldOfStudySID                = @FieldOfStudySID output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantCredentialXID        = @RegistrantCredentialXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
		
		end

		-- update the record

		update
			dbo.RegistrantCredential
		set
			 RegistrantSID = @RegistrantSID
			,CredentialSID = @CredentialSID
			,OrgSID = @OrgSID
			,ProgramName = @ProgramName
			,ProgramStartDate = @ProgramStartDate
			,ProgramTargetCompletionDate = @ProgramTargetCompletionDate
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,FieldOfStudySID = @FieldOfStudySID
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantCredentialXID = @RegistrantCredentialXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantCredentialSID = @RegistrantCredentialSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantCredential where RegistrantCredentialSID = @registrantCredentialSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantCredential'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantCredential'
					,@Arg2        = @registrantCredentialSID
				
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
				,@Arg2        = 'dbo.RegistrantCredential'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantCredentialSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Jul 2017
		-- If the organization associated with the credential is not already
		-- marked as a credentialling authority, mark it now.
		
		exec dbo.pOrg#SetBaseTypes
			@OrgSID = @OrgSID
		 ,@UpdateUser = @UpdateUser
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
				r.RoutineName = 'pRegistrantCredential'
		)
		begin
		
			exec @errorNo = ext.pRegistrantCredential
				 @Mode                           = 'update.post'
				,@RegistrantCredentialSID        = @RegistrantCredentialSID
				,@RegistrantSID                  = @RegistrantSID
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantCredentialSID
			from
				dbo.vRegistrantCredential ent
			where
				ent.RegistrantCredentialSID = @RegistrantCredentialSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantCredentialSID
				,ent.RegistrantSID
				,ent.CredentialSID
				,ent.OrgSID
				,ent.ProgramName
				,ent.ProgramStartDate
				,ent.ProgramTargetCompletionDate
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.FieldOfStudySID
				,ent.UserDefinedColumns
				,ent.RegistrantCredentialXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.CredentialTypeSID
				,ent.CredentialLabel
				,ent.ToolTip
				,ent.IsRelatedToProfession
				,ent.IsProgramRequired
				,ent.IsSpecialization
				,ent.CredentialIsActive
				,ent.CredentialCode
				,ent.CredentialRowGUID
				,ent.FieldOfStudyName
				,ent.FieldOfStudyCode
				,ent.FieldOfStudyCategory
				,ent.FieldOfStudyIsDefault
				,ent.FieldOfStudyIsActive
				,ent.FieldOfStudyRowGUID
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
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.OrgIsActive
				,ent.IsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.OrgRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsQualifying
			from
				dbo.vRegistrantCredential ent
			where
				ent.RegistrantCredentialSID = @RegistrantCredentialSID

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
