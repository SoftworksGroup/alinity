SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrant#Insert]
	 @RegistrantSID                  int               = null output				-- identity value assigned to the new record
	,@PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrantNo                   varchar(50)       = null								-- required! if not passed value must be set in custom logic prior to insert
	,@YearOfInitialEmployment        smallint          = null								
	,@IsOnPublicRegistry             bit               = null								-- default: CONVERT(bit,(1))
	,@CityNameOfBirth                nvarchar(30)      = null								
	,@CountrySID                     int               = null								
	,@DirectedAuditYearCompetence    smallint          = null								
	,@DirectedAuditYearPracticeHours smallint          = null								
	,@LateFeeExclusionYear           smallint          = null								
	,@IsRenewalAutoApprovalBlocked   bit               = null								-- default: CONVERT(bit,(0))
	,@RenewalExtensionExpiryTime     datetime          = null								
	,@PublicDirectoryComment         nvarchar(max)     = null								
	,@ArchivedTime                   datetimeoffset(7) = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantXID                  varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@GenderSID                      int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                  int               = null								-- not a base table column (default ignored)
	,@FirstName                      nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                      date              = null								-- not a base table column (default ignored)
	,@DeathDate                      date              = null								-- not a base table column (default ignored)
	,@HomePhone                      varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled         bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                    nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@CountryName                    nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ISOA2                          char(2)           = null								-- not a base table column (default ignored)
	,@ISOA3                          char(3)           = null								-- not a base table column (default ignored)
	,@ISONumber                      smallint          = null								-- not a base table column (default ignored)
	,@IsStateProvinceRequired        bit               = null								-- not a base table column (default ignored)
	,@CountryIsDefault               bit               = null								-- not a base table column (default ignored)
	,@CountryIsActive                bit               = null								-- not a base table column (default ignored)
	,@CountryRowGUID                 uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@RegistrantLabel                nvarchar(75)      = null								-- not a base table column (default ignored)
	,@FileAsName                     nvarchar(65)      = null								-- not a base table column (default ignored)
	,@DisplayName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@RegistrationSID                int               = null								-- not a base table column (default ignored)
	,@RegistrationNo                 nvarchar(50)      = null								-- not a base table column (default ignored)
	,@PracticeRegisterSID            int               = null								-- not a base table column (default ignored)
	,@PracticeRegisterSectionSID     int               = null								-- not a base table column (default ignored)
	,@EffectiveTime                  datetime          = null								-- not a base table column (default ignored)
	,@ExpiryTime                     datetime          = null								-- not a base table column (default ignored)
	,@PracticeRegisterName           nvarchar(65)      = null								-- not a base table column (default ignored)
	,@PracticeRegisterLabel          nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsActivePractice               bit               = null								-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel   nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsSectionDisplayedOnLicense    bit               = null								-- not a base table column (default ignored)
	,@LicenseRegistrationYear        smallint          = null								-- not a base table column (default ignored)
	,@RenewalRegistrationYear        smallint          = null								-- not a base table column (default ignored)
	,@HasOpenAudit                   bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrant#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.Registrant table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Registrant table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrant entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrant procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantCheck to test all rules.

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

	set @RegistrantSID = null																								-- initialize output parameter

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
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @PublicDirectoryComment = ltrim(rtrim(@PublicDirectoryComment))
		set @RegistrantXID = ltrim(rtrim(@RegistrantXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @CountryName = ltrim(rtrim(@CountryName))
		set @ISOA2 = ltrim(rtrim(@ISOA2))
		set @ISOA3 = ltrim(rtrim(@ISOA3))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @DisplayName = ltrim(rtrim(@DisplayName))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@PublicDirectoryComment) = 0 set @PublicDirectoryComment = null
		if len(@RegistrantXID) = 0 set @RegistrantXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@CountryName) = 0 set @CountryName = null
		if len(@ISOA2) = 0 set @ISOA2 = null
		if len(@ISOA3) = 0 set @ISOA3 = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@DisplayName) = 0 set @DisplayName = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsOnPublicRegistry = isnull(@IsOnPublicRegistry,CONVERT(bit,(1)))
		set @IsRenewalAutoApprovalBlocked = isnull(@IsRenewalAutoApprovalBlocked,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                   = isnull(@IsReselected                  ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Aug 2018
		-- If the registrant# was not passed or passed as "+", set it to the
		-- next value for the Applicant or Registrant sequence based on configuration

		if @RegistrantNo is null or @RegistrantNo = '+'
		begin

			exec dbo.pRegistrant#GetNextNo
				@Mode = 'APPLICANT'
			 ,@RegistrantSID = @RegistrantSID
			 ,@RegistrantNo = @RegistrantNo output;

		end;
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
				r.RoutineName = 'pRegistrant'
		)
		begin
		
			exec @errorNo = ext.pRegistrant
				 @Mode                           = 'insert.pre'
				,@PersonSID                      = @PersonSID output
				,@RegistrantNo                   = @RegistrantNo output
				,@YearOfInitialEmployment        = @YearOfInitialEmployment output
				,@IsOnPublicRegistry             = @IsOnPublicRegistry output
				,@CityNameOfBirth                = @CityNameOfBirth output
				,@CountrySID                     = @CountrySID output
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence output
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours output
				,@LateFeeExclusionYear           = @LateFeeExclusionYear output
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked output
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime output
				,@PublicDirectoryComment         = @PublicDirectoryComment output
				,@ArchivedTime                   = @ArchivedTime output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantXID                  = @RegistrantXID output
				,@LegacyKey                      = @LegacyKey output
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@GenderSID                      = @GenderSID
				,@NamePrefixSID                  = @NamePrefixSID
				,@FirstName                      = @FirstName
				,@CommonName                     = @CommonName
				,@MiddleNames                    = @MiddleNames
				,@LastName                       = @LastName
				,@BirthDate                      = @BirthDate
				,@DeathDate                      = @DeathDate
				,@HomePhone                      = @HomePhone
				,@MobilePhone                    = @MobilePhone
				,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
				,@ImportBatch                    = @ImportBatch
				,@PersonRowGUID                  = @PersonRowGUID
				,@CountryName                    = @CountryName
				,@ISOA2                          = @ISOA2
				,@ISOA3                          = @ISOA3
				,@ISONumber                      = @ISONumber
				,@IsStateProvinceRequired        = @IsStateProvinceRequired
				,@CountryIsDefault               = @CountryIsDefault
				,@CountryIsActive                = @CountryIsActive
				,@CountryRowGUID                 = @CountryRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@RegistrantLabel                = @RegistrantLabel
				,@FileAsName                     = @FileAsName
				,@DisplayName                    = @DisplayName
				,@EmailAddress                   = @EmailAddress
				,@RegistrationSID                = @RegistrationSID
				,@RegistrationNo                 = @RegistrationNo
				,@PracticeRegisterSID            = @PracticeRegisterSID
				,@PracticeRegisterSectionSID     = @PracticeRegisterSectionSID
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@PracticeRegisterName           = @PracticeRegisterName
				,@PracticeRegisterLabel          = @PracticeRegisterLabel
				,@IsActivePractice               = @IsActivePractice
				,@PracticeRegisterSectionLabel   = @PracticeRegisterSectionLabel
				,@IsSectionDisplayedOnLicense    = @IsSectionDisplayedOnLicense
				,@LicenseRegistrationYear        = @LicenseRegistrationYear
				,@RenewalRegistrationYear        = @RenewalRegistrationYear
				,@HasOpenAudit                   = @HasOpenAudit
		
		end

		-- insert the record

		insert
			dbo.Registrant
		(
			 PersonSID
			,RegistrantNo
			,YearOfInitialEmployment
			,IsOnPublicRegistry
			,CityNameOfBirth
			,CountrySID
			,DirectedAuditYearCompetence
			,DirectedAuditYearPracticeHours
			,LateFeeExclusionYear
			,IsRenewalAutoApprovalBlocked
			,RenewalExtensionExpiryTime
			,PublicDirectoryComment
			,ArchivedTime
			,UserDefinedColumns
			,RegistrantXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@RegistrantNo
			,@YearOfInitialEmployment
			,@IsOnPublicRegistry
			,@CityNameOfBirth
			,@CountrySID
			,@DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime
			,@PublicDirectoryComment
			,@ArchivedTime
			,@UserDefinedColumns
			,@RegistrantXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected  = @@rowcount
			,@RegistrantSID = scope_identity()																	-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.Registrant'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Aug 2018
		-- Unless a legacy key was provided, add the new Registrant to the Application Practice
		-- Register (default register). If the default section is not to be assigned, the caller
		-- must pass it in the supplied parameter.  Note that a not null @LegacyKey indicates this
		-- insert is being executed by a conversion routine which will add registrations in a
		-- later step.

		if @LegacyKey is null -- no legacy key - NOT conversion routine
		begin

			exec dbo.pRegistrant#Insert$ApplicantRegistration
				@RegistrantSID = @RegistrantSID
			 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID

		end;

		-- Tim Edlund | Oct 2017
		-- Check for a user profile and update the authentication system ID
		-- with the RegistrantNo if not already set.  This value is available
		-- as an alternate login ID.

		set @recordSID = null
		select @recordSID = au.ApplicationUserSID from sf.ApplicationUser au where au.PersonSID = @PersonSID and au.AuthenticationSystemID <> @RegistrantNo

		if @recordSID is not null
		begin

			update
				sf.ApplicationUser
			set
				 AuthenticationSystemID = @RegistrantNo
				,UpdateUser = @CreateUser
				,UpdateTime = sysdatetimeoffset()
			where
				ApplicationUserSID = @recordSID

		end
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
				r.RoutineName = 'pRegistrant'
		)
		begin
		
			exec @errorNo = ext.pRegistrant
				 @Mode                           = 'insert.post'
				,@RegistrantSID                  = @RegistrantSID
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
				,@PublicDirectoryComment         = @PublicDirectoryComment
				,@ArchivedTime                   = @ArchivedTime
				,@UserDefinedColumns             = @UserDefinedColumns
				,@RegistrantXID                  = @RegistrantXID
				,@LegacyKey                      = @LegacyKey
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@GenderSID                      = @GenderSID
				,@NamePrefixSID                  = @NamePrefixSID
				,@FirstName                      = @FirstName
				,@CommonName                     = @CommonName
				,@MiddleNames                    = @MiddleNames
				,@LastName                       = @LastName
				,@BirthDate                      = @BirthDate
				,@DeathDate                      = @DeathDate
				,@HomePhone                      = @HomePhone
				,@MobilePhone                    = @MobilePhone
				,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
				,@ImportBatch                    = @ImportBatch
				,@PersonRowGUID                  = @PersonRowGUID
				,@CountryName                    = @CountryName
				,@ISOA2                          = @ISOA2
				,@ISOA3                          = @ISOA3
				,@ISONumber                      = @ISONumber
				,@IsStateProvinceRequired        = @IsStateProvinceRequired
				,@CountryIsDefault               = @CountryIsDefault
				,@CountryIsActive                = @CountryIsActive
				,@CountryRowGUID                 = @CountryRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@RegistrantLabel                = @RegistrantLabel
				,@FileAsName                     = @FileAsName
				,@DisplayName                    = @DisplayName
				,@EmailAddress                   = @EmailAddress
				,@RegistrationSID                = @RegistrationSID
				,@RegistrationNo                 = @RegistrationNo
				,@PracticeRegisterSID            = @PracticeRegisterSID
				,@PracticeRegisterSectionSID     = @PracticeRegisterSectionSID
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@PracticeRegisterName           = @PracticeRegisterName
				,@PracticeRegisterLabel          = @PracticeRegisterLabel
				,@IsActivePractice               = @IsActivePractice
				,@PracticeRegisterSectionLabel   = @PracticeRegisterSectionLabel
				,@IsSectionDisplayedOnLicense    = @IsSectionDisplayedOnLicense
				,@LicenseRegistrationYear        = @LicenseRegistrationYear
				,@RenewalRegistrationYear        = @RenewalRegistrationYear
				,@HasOpenAudit                   = @HasOpenAudit
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantSID
			from
				dbo.vRegistrant ent
			where
				ent.RegistrantSID = @RegistrantSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantSID
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
				,ent.PublicDirectoryComment
				,ent.ArchivedTime
				,ent.UserDefinedColumns
				,ent.RegistrantXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.BirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.CountryName
				,ent.ISOA2
				,ent.ISOA3
				,ent.ISONumber
				,ent.IsStateProvinceRequired
				,ent.CountryIsDefault
				,ent.CountryIsActive
				,ent.CountryRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
				,ent.FileAsName
				,ent.DisplayName
				,ent.EmailAddress
				,ent.RegistrationSID
				,ent.RegistrationNo
				,ent.PracticeRegisterSID
				,ent.PracticeRegisterSectionSID
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.PracticeRegisterName
				,ent.PracticeRegisterLabel
				,ent.IsActivePractice
				,ent.PracticeRegisterSectionLabel
				,ent.IsSectionDisplayedOnLicense
				,ent.LicenseRegistrationYear
				,ent.RenewalRegistrationYear
				,ent.HasOpenAudit
			from
				dbo.vRegistrant ent
			where
				ent.RegistrantSID = @RegistrantSID

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
