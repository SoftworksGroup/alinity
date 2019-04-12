SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantCredential#Insert]
	 @RegistrantCredentialSID        int               = null output				-- identity value assigned to the new record
	,@RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistrantCredential#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantCredential table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantCredential table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantCredential entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantCredential procedure. The extended procedure is only called
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

	set @RegistrantCredentialSID = null																			-- initialize output parameter

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

		set @ProgramName = ltrim(rtrim(@ProgramName))
		set @RegistrantCredentialXID = ltrim(rtrim(@RegistrantCredentialXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                = isnull(@IsReselected               ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @FieldOfStudySID  is null select @FieldOfStudySID  = x.FieldOfStudySID from dbo.FieldOfStudy x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		
		-- Cory Ng | Jan 2018
		-- Lookup the RegistrantSID if its not passed and the
		-- PersonSID is passed

		if @PersonSID is not null and @RegistrantSID is null
		begin

			select				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID

		end

		-- Tim Edlund | Jun 2018
		-- If no organization is provided with the credential
		-- and only 1 qualifying org exists for it, default it

		if @OrgSID is null and @CredentialSID is not null
		begin

			if
			(
				select
					count(1)
				from
					dbo.QualifyingCredentialOrg qco
				where
					qco.CredentialSID = @CredentialSID
			) = 1
			begin

				select
					@OrgSID = qco.OrgSID
				from
					dbo.QualifyingCredentialOrg qco
				where
					qco.CredentialSID = @CredentialSID;

			end;

		end;

		--! </PreInsert>
		
		exec sf.pEffectiveExpiry#Set																					-- ensure values have start/end of day time components or current time if today
		   @EffectiveTime = @EffectiveTime output
		  ,@ExpiryTime    = @ExpiryTime    output
	
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
				r.RoutineName = 'pRegistrantCredential'
		)
		begin
		
			exec @errorNo = ext.pRegistrantCredential
				 @Mode                           = 'insert.pre'
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
		
		end

		-- insert the record

		insert
			dbo.RegistrantCredential
		(
			 RegistrantSID
			,CredentialSID
			,OrgSID
			,ProgramName
			,ProgramStartDate
			,ProgramTargetCompletionDate
			,EffectiveTime
			,ExpiryTime
			,FieldOfStudySID
			,UserDefinedColumns
			,RegistrantCredentialXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@CredentialSID
			,@OrgSID
			,@ProgramName
			,@ProgramStartDate
			,@ProgramTargetCompletionDate
			,@EffectiveTime
			,@ExpiryTime
			,@FieldOfStudySID
			,@UserDefinedColumns
			,@RegistrantCredentialXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@RegistrantCredentialSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantCredential'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantCredentialSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>

		-- Tim Edlund | Jul 2017
		-- If the organization associated with the new credential is not already
		-- marked as a credentialling authority, mark it now.
		
		exec dbo.pOrg#SetBaseTypes
			@OrgSID = @OrgSID
		 ,@UpdateUser = @CreateUser
		
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
				r.RoutineName = 'pRegistrantCredential'
		)
		begin
		
			exec @errorNo = ext.pRegistrantCredential
				 @Mode                           = 'insert.post'
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
