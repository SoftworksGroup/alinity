SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantPractice#Insert]
	 @RegistrantPracticeSID          int               = null output				-- identity value assigned to the new record
	,@RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear               smallint          = null								-- default: sf.fTodayYear()
	,@EmploymentStatusSID            int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@PlannedRetirementDate          date              = null								
	,@OtherJurisdiction              nvarchar(100)     = null								
	,@OtherJurisdictionHours         int               = null								-- default: (0)
	,@TotalPracticeHours             int               = null								-- default: (0)
	,@OrgSID                         int               = null								
	,@InsurancePolicyNo              varchar(25)       = null								
	,@InsuranceAmount                decimal(11,2)     = null								
	,@InsuranceCertificateNo         varchar(25)       = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantPracticeXID          varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@EmploymentStatusName           nvarchar(50)      = null								-- not a base table column (default ignored)
	,@EmploymentStatusCode           varchar(20)       = null								-- not a base table column (default ignored)
	,@EmploymentStatusIsDefault      bit               = null								-- not a base table column (default ignored)
	,@IsEmploymentExpected           bit               = null								-- not a base table column (default ignored)
	,@EmploymentStatusIsActive       bit               = null								-- not a base table column (default ignored)
	,@EmploymentStatusRowGUID        uniqueidentifier  = null								-- not a base table column (default ignored)
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
	,@OrgInsurancePolicyNo           varchar(25)       = null								-- not a base table column (default ignored)
	,@OrgInsuranceAmount             decimal(11,2)     = null								-- not a base table column (default ignored)
	,@IsEmployer                     bit               = null								-- not a base table column (default ignored)
	,@IsCredentialAuthority          bit               = null								-- not a base table column (default ignored)
	,@IsInsurer                      bit               = null								-- not a base table column (default ignored)
	,@IsInsuranceCertificateRequired bit               = null								-- not a base table column (default ignored)
	,@IsPublic                       nchar(10)         = null								-- not a base table column (default ignored)
	,@OrgIsActive                    bit               = null								-- not a base table column (default ignored)
	,@IsAdminReviewRequired          bit               = null								-- not a base table column (default ignored)
	,@LastVerifiedTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@OrgRowGUID                     uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@RegistrantLabel                nvarchar(75)      = null								-- not a base table column (default ignored)
	,@FileAsName                     nvarchar(65)      = null								-- not a base table column (default ignored)
	,@DisplayName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@TotalJurisdictionHours         int               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantPractice#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantPractice table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantPractice table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantPractice entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantPractice procedure. The extended procedure is only called
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

	set @RegistrantPracticeSID = null																				-- initialize output parameter

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

		set @OtherJurisdiction = ltrim(rtrim(@OtherJurisdiction))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @InsuranceCertificateNo = ltrim(rtrim(@InsuranceCertificateNo))
		set @RegistrantPracticeXID = ltrim(rtrim(@RegistrantPracticeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RegistrationYear = isnull(@RegistrationYear,sf.fTodayYear())
		set @OtherJurisdictionHours = isnull(@OtherJurisdictionHours,(0))
		set @TotalPracticeHours = isnull(@TotalPracticeHours,(0))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected           = isnull(@IsReselected          ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @EmploymentStatusSID  is null select @EmploymentStatusSID  = x.EmploymentStatusSID from dbo.EmploymentStatus x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		
		-- Cory Ng | Jan 2018
		-- Lookup the RegistrantSID if its not passed and the
		-- PersonSID is passed
		if @PersonSID is not null and @RegistrantSID is null
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID

		end

		-- Karun Kakulphimp | Mar 2019
		-- Support overwrite of previously filled values with NULL		
		-- when special token passed (even where @IsNullApplied is off)

		if @OrgSID = 0																					set @OrgSID									= null
		if @InsurancePolicyNo				= '[NULL]'									set @InsurancePolicyNo			= null
		if @InsuranceCertificateNo	= '[NULL]'									set @InsuranceCertificateNo = null
		if @InsuranceAmount					= 0													set @InsuranceAmount				= null

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
				r.RoutineName = 'pRegistrantPractice'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPractice
				 @Mode                           = 'insert.pre'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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

		-- insert the record

		insert
			dbo.RegistrantPractice
		(
			 RegistrantSID
			,RegistrationYear
			,EmploymentStatusSID
			,PlannedRetirementDate
			,OtherJurisdiction
			,OtherJurisdictionHours
			,TotalPracticeHours
			,OrgSID
			,InsurancePolicyNo
			,InsuranceAmount
			,InsuranceCertificateNo
			,UserDefinedColumns
			,RegistrantPracticeXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@RegistrationYear
			,@EmploymentStatusSID
			,@PlannedRetirementDate
			,@OtherJurisdiction
			,@OtherJurisdictionHours
			,@TotalPracticeHours
			,@OrgSID
			,@InsurancePolicyNo
			,@InsuranceAmount
			,@InsuranceCertificateNo
			,@UserDefinedColumns
			,@RegistrantPracticeXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected          = @@rowcount
			,@RegistrantPracticeSID = scope_identity()													-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantPractice'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantPracticeSID
			
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
				r.RoutineName = 'pRegistrantPractice'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPractice
				 @Mode                           = 'insert.post'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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
