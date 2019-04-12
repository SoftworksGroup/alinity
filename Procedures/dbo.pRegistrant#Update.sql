SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrant#Update]
	 @RegistrantSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                      int               = null -- table column values to update:
	,@RegistrantNo                   varchar(50)       = null
	,@YearOfInitialEmployment        smallint          = null
	,@IsOnPublicRegistry             bit               = null
	,@CityNameOfBirth                nvarchar(30)      = null
	,@CountrySID                     int               = null
	,@DirectedAuditYearCompetence    smallint          = null
	,@DirectedAuditYearPracticeHours smallint          = null
	,@LateFeeExclusionYear           smallint          = null
	,@IsRenewalAutoApprovalBlocked   bit               = null
	,@RenewalExtensionExpiryTime     datetime          = null
	,@PublicDirectoryComment         nvarchar(max)     = null
	,@ArchivedTime                   datetimeoffset(7) = null
	,@UserDefinedColumns             xml               = null
	,@RegistrantXID                  varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@GenderSID                      int               = null -- not a base table column
	,@NamePrefixSID                  int               = null -- not a base table column
	,@FirstName                      nvarchar(30)      = null -- not a base table column
	,@CommonName                     nvarchar(30)      = null -- not a base table column
	,@MiddleNames                    nvarchar(30)      = null -- not a base table column
	,@LastName                       nvarchar(35)      = null -- not a base table column
	,@BirthDate                      date              = null -- not a base table column
	,@DeathDate                      date              = null -- not a base table column
	,@HomePhone                      varchar(25)       = null -- not a base table column
	,@MobilePhone                    varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled         bit               = null -- not a base table column
	,@ImportBatch                    nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@CountryName                    nvarchar(50)      = null -- not a base table column
	,@ISOA2                          char(2)           = null -- not a base table column
	,@ISOA3                          char(3)           = null -- not a base table column
	,@ISONumber                      smallint          = null -- not a base table column
	,@IsStateProvinceRequired        bit               = null -- not a base table column
	,@CountryIsDefault               bit               = null -- not a base table column
	,@CountryIsActive                bit               = null -- not a base table column
	,@CountryRowGUID                 uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@RegistrantLabel                nvarchar(75)      = null -- not a base table column
	,@FileAsName                     nvarchar(65)      = null -- not a base table column
	,@DisplayName                    nvarchar(65)      = null -- not a base table column
	,@EmailAddress                   varchar(150)      = null -- not a base table column
	,@RegistrationSID                int               = null -- not a base table column
	,@RegistrationNo                 nvarchar(50)      = null -- not a base table column
	,@PracticeRegisterSID            int               = null -- not a base table column
	,@PracticeRegisterSectionSID     int               = null -- not a base table column
	,@EffectiveTime                  datetime          = null -- not a base table column
	,@ExpiryTime                     datetime          = null -- not a base table column
	,@PracticeRegisterName           nvarchar(65)      = null -- not a base table column
	,@PracticeRegisterLabel          nvarchar(35)      = null -- not a base table column
	,@IsActivePractice               bit               = null -- not a base table column
	,@PracticeRegisterSectionLabel   nvarchar(35)      = null -- not a base table column
	,@IsSectionDisplayedOnLicense    bit               = null -- not a base table column
	,@LicenseRegistrationYear        smallint          = null -- not a base table column
	,@RenewalRegistrationYear        smallint          = null -- not a base table column
	,@HasOpenAudit                   bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrant#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Registrant table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Registrant table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrant entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrant procedure. The extended procedure is only called
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

		if @RegistrantSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @PublicDirectoryComment = ltrim(rtrim(@PublicDirectoryComment))
		set @RegistrantXID = ltrim(rtrim(@RegistrantXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                      = isnull(@PersonSID,registrant.PersonSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,registrant.RegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,registrant.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,registrant.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,registrant.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,registrant.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,registrant.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,registrant.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,registrant.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,registrant.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,registrant.RenewalExtensionExpiryTime)
				,@PublicDirectoryComment         = isnull(@PublicDirectoryComment,registrant.PublicDirectoryComment)
				,@ArchivedTime                   = isnull(@ArchivedTime,registrant.ArchivedTime)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,registrant.UserDefinedColumns)
				,@RegistrantXID                  = isnull(@RegistrantXID,registrant.RegistrantXID)
				,@LegacyKey                      = isnull(@LegacyKey,registrant.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,registrant.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,registrant.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,registrant.IsNullApplied)
				,@zContext                       = isnull(@zContext,registrant.zContext)
				,@GenderSID                      = isnull(@GenderSID,registrant.GenderSID)
				,@NamePrefixSID                  = isnull(@NamePrefixSID,registrant.NamePrefixSID)
				,@FirstName                      = isnull(@FirstName,registrant.FirstName)
				,@CommonName                     = isnull(@CommonName,registrant.CommonName)
				,@MiddleNames                    = isnull(@MiddleNames,registrant.MiddleNames)
				,@LastName                       = isnull(@LastName,registrant.LastName)
				,@BirthDate                      = isnull(@BirthDate,registrant.BirthDate)
				,@DeathDate                      = isnull(@DeathDate,registrant.DeathDate)
				,@HomePhone                      = isnull(@HomePhone,registrant.HomePhone)
				,@MobilePhone                    = isnull(@MobilePhone,registrant.MobilePhone)
				,@IsTextMessagingEnabled         = isnull(@IsTextMessagingEnabled,registrant.IsTextMessagingEnabled)
				,@ImportBatch                    = isnull(@ImportBatch,registrant.ImportBatch)
				,@PersonRowGUID                  = isnull(@PersonRowGUID,registrant.PersonRowGUID)
				,@CountryName                    = isnull(@CountryName,registrant.CountryName)
				,@ISOA2                          = isnull(@ISOA2,registrant.ISOA2)
				,@ISOA3                          = isnull(@ISOA3,registrant.ISOA3)
				,@ISONumber                      = isnull(@ISONumber,registrant.ISONumber)
				,@IsStateProvinceRequired        = isnull(@IsStateProvinceRequired,registrant.IsStateProvinceRequired)
				,@CountryIsDefault               = isnull(@CountryIsDefault,registrant.CountryIsDefault)
				,@CountryIsActive                = isnull(@CountryIsActive,registrant.CountryIsActive)
				,@CountryRowGUID                 = isnull(@CountryRowGUID,registrant.CountryRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,registrant.IsDeleteEnabled)
				,@RegistrantLabel                = isnull(@RegistrantLabel,registrant.RegistrantLabel)
				,@FileAsName                     = isnull(@FileAsName,registrant.FileAsName)
				,@DisplayName                    = isnull(@DisplayName,registrant.DisplayName)
				,@EmailAddress                   = isnull(@EmailAddress,registrant.EmailAddress)
				,@RegistrationSID                = isnull(@RegistrationSID,registrant.RegistrationSID)
				,@RegistrationNo                 = isnull(@RegistrationNo,registrant.RegistrationNo)
				,@PracticeRegisterSID            = isnull(@PracticeRegisterSID,registrant.PracticeRegisterSID)
				,@PracticeRegisterSectionSID     = isnull(@PracticeRegisterSectionSID,registrant.PracticeRegisterSectionSID)
				,@EffectiveTime                  = isnull(@EffectiveTime,registrant.EffectiveTime)
				,@ExpiryTime                     = isnull(@ExpiryTime,registrant.ExpiryTime)
				,@PracticeRegisterName           = isnull(@PracticeRegisterName,registrant.PracticeRegisterName)
				,@PracticeRegisterLabel          = isnull(@PracticeRegisterLabel,registrant.PracticeRegisterLabel)
				,@IsActivePractice               = isnull(@IsActivePractice,registrant.IsActivePractice)
				,@PracticeRegisterSectionLabel   = isnull(@PracticeRegisterSectionLabel,registrant.PracticeRegisterSectionLabel)
				,@IsSectionDisplayedOnLicense    = isnull(@IsSectionDisplayedOnLicense,registrant.IsSectionDisplayedOnLicense)
				,@LicenseRegistrationYear        = isnull(@LicenseRegistrationYear,registrant.LicenseRegistrationYear)
				,@RenewalRegistrationYear        = isnull(@RenewalRegistrationYear,registrant.RenewalRegistrationYear)
				,@HasOpenAudit                   = isnull(@HasOpenAudit,registrant.HasOpenAudit)
			from
				dbo.vRegistrant registrant
			where
				registrant.RegistrantSID = @RegistrantSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.CountrySID from dbo.Registrant x where x.RegistrantSID = @RegistrantSID) <> @CountrySID
		begin
			if (select x.IsActive from dbo.Country x where x.CountrySID = @CountrySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'country'
				
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
				r.RoutineName = 'pRegistrant'
		)
		begin
		
			exec @errorNo = ext.pRegistrant
				 @Mode                           = 'update.pre'
				,@RegistrantSID                  = @RegistrantSID
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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

		-- update the record

		update
			dbo.Registrant
		set
			 PersonSID = @PersonSID
			,RegistrantNo = @RegistrantNo
			,YearOfInitialEmployment = @YearOfInitialEmployment
			,IsOnPublicRegistry = @IsOnPublicRegistry
			,CityNameOfBirth = @CityNameOfBirth
			,CountrySID = @CountrySID
			,DirectedAuditYearCompetence = @DirectedAuditYearCompetence
			,DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
			,LateFeeExclusionYear = @LateFeeExclusionYear
			,IsRenewalAutoApprovalBlocked = @IsRenewalAutoApprovalBlocked
			,RenewalExtensionExpiryTime = @RenewalExtensionExpiryTime
			,PublicDirectoryComment = @PublicDirectoryComment
			,ArchivedTime = @ArchivedTime
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantXID = @RegistrantXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantSID = @RegistrantSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Registrant where RegistrantSID = @registrantSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Registrant'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Registrant'
					,@Arg2        = @registrantSID
				
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
				,@Arg2        = 'dbo.Registrant'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
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
				,UpdateUser = @UpdateUser
				,UpdateTime = sysdatetimeoffset()
			where				ApplicationUserSID = @recordSID

		end
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
				r.RoutineName = 'pRegistrant'
		)
		begin
		
			exec @errorNo = ext.pRegistrant
				 @Mode                           = 'update.post'
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
