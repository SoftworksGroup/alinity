SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pCredentialProfile#Delete]
	 @CredentialProfileSID           int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@ProcessingStatusSID            int               = null
	,@SourceFileName                 nvarchar(100)     = null
	,@ProgramStartDate               date              = null
	,@ProgramTargetCompletionDate    date              = null
	,@EffectiveTime                  date              = null
	,@IsDisplayedOnLicense           bit               = null
	,@ProgramName                    nvarchar(65)      = null
	,@OrgName                        nvarchar(15)      = null
	,@OrgLabel                       nvarchar(35)      = null
	,@StreetAddress1                 nvarchar(75)      = null
	,@StreetAddress2                 nvarchar(75)      = null
	,@StreedAddress3                 nvarchar(75)      = null
	,@CityName                       nvarchar(30)      = null
	,@StateProvinceName              nvarchar(30)      = null
	,@StateProvinceCode              nvarchar(5)       = null
	,@PostalCode                     varchar(10)       = null
	,@CountryName                    nvarchar(50)      = null
	,@CountryISOA3                   char(3)           = null
	,@Phone                          varchar(25)       = null
	,@Fax                            varchar(25)       = null
	,@WebSite                        varchar(250)      = null
	,@RegionLabel                    nvarchar(35)      = null
	,@RegionName                     nvarchar(50)      = null
	,@CredentialTypeLabel            nvarchar(35)      = null
	,@RegistrantSID                  int               = null
	,@CredentialSID                  int               = null
	,@CredentialTypeSID              int               = null
	,@OrgSID                         int               = null
	,@RegionSID                      int               = null
	,@ProcessingComments             nvarchar(max)     = null
	,@UserDefinedColumns             xml               = null
	,@CredentialProfileXID           varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@IsDeleted                      bit               = null
	,@CreateUser                     nvarchar(75)      = null
	,@CreateTime                     datetimeoffset(7) = null
	,@UpdateTime                     datetimeoffset(7) = null
	,@RowGUID                        uniqueidentifier  = null
	,@ProcessingStatusSCD            varchar(10)       = null
	,@ProcessingStatusLabel          nvarchar(35)      = null
	,@IsClosedStatus                 bit               = null
	,@ProcessingStatusIsActive       bit               = null
	,@ProcessingStatusIsDefault      bit               = null
	,@ProcessingStatusRowGUID        uniqueidentifier  = null
	,@CredentialCredentialTypeSID    int               = null
	,@CredentialLabel                nvarchar(35)      = null
	,@ToolTip                        nvarchar(500)     = null
	,@IsRelatedToProfession          bit               = null
	,@IsProgramRequired              bit               = null
	,@IsSpecialization               bit               = null
	,@CredentialIsActive             bit               = null
	,@CredentialCode                 varchar(15)       = null
	,@CredentialRowGUID              uniqueidentifier  = null
	,@ParentOrgSID                   int               = null
	,@OrgTypeSID                     int               = null
	,@OrgOrgName                     nvarchar(150)     = null
	,@OrgOrgLabel                    nvarchar(35)      = null
	,@OrgStreetAddress1              nvarchar(75)      = null
	,@OrgStreetAddress2              nvarchar(75)      = null
	,@StreetAddress3                 nvarchar(75)      = null
	,@CitySID                        int               = null
	,@OrgPostalCode                  varchar(10)       = null
	,@OrgRegionSID                   int               = null
	,@OrgPhone                       varchar(25)       = null
	,@OrgFax                         varchar(25)       = null
	,@OrgWebSite                     varchar(250)      = null
	,@EmailAddress                   varchar(150)      = null
	,@InsuranceOrgSID                int               = null
	,@InsurancePolicyNo              varchar(25)       = null
	,@InsuranceAmount                decimal(11,2)     = null
	,@IsEmployer                     bit               = null
	,@IsCredentialAuthority          bit               = null
	,@IsInsurer                      bit               = null
	,@IsInsuranceCertificateRequired bit               = null
	,@IsPublic                       nchar(10)         = null
	,@OrgIsActive                    bit               = null
	,@IsAdminReviewRequired          bit               = null
	,@LastVerifiedTime               datetimeoffset(7) = null
	,@OrgRowGUID                     uniqueidentifier  = null
	,@RegionRegionLabel              nvarchar(35)      = null
	,@RegionRegionName               nvarchar(50)      = null
	,@RegionIsDefault                bit               = null
	,@RegionIsActive                 bit               = null
	,@RegionRowGUID                  uniqueidentifier  = null
	,@PersonSID                      int               = null
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
	,@ArchivedTime                   datetimeoffset(7) = null
	,@RegistrantRowGUID              uniqueidentifier  = null
	,@IsDeleteEnabled                bit               = null
	,@zContext                       xml               = null -- other values defining context for the delete (if any)
	,@IsQualifying                   bit               = null
as
/*********************************************************************************************************************************
Procedure : stg.pCredentialProfile#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the stg.CredentialProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.CredentialProfile table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pCredentialProfile procedure. The extended procedure is only called
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
and in the ext.pCredentialProfile procedure for client-specific deletion rules.

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

		if @CredentialProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CredentialProfileSID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from stg.CredentialProfile x where x.CredentialProfileSID = @CredentialProfileSID

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
				r.RoutineName = 'stg#pCredentialProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pCredentialProfile
				 @Mode                           = 'delete.pre'
				,@CredentialProfileSID           = @CredentialProfileSID
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@ProcessingStatusSID            = @ProcessingStatusSID
				,@SourceFileName                 = @SourceFileName
				,@ProgramStartDate               = @ProgramStartDate
				,@ProgramTargetCompletionDate    = @ProgramTargetCompletionDate
				,@EffectiveTime                  = @EffectiveTime
				,@IsDisplayedOnLicense           = @IsDisplayedOnLicense
				,@ProgramName                    = @ProgramName
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreedAddress3                 = @StreedAddress3
				,@CityName                       = @CityName
				,@StateProvinceName              = @StateProvinceName
				,@StateProvinceCode              = @StateProvinceCode
				,@PostalCode                     = @PostalCode
				,@CountryName                    = @CountryName
				,@CountryISOA3                   = @CountryISOA3
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@RegionLabel                    = @RegionLabel
				,@RegionName                     = @RegionName
				,@CredentialTypeLabel            = @CredentialTypeLabel
				,@RegistrantSID                  = @RegistrantSID
				,@CredentialSID                  = @CredentialSID
				,@CredentialTypeSID              = @CredentialTypeSID
				,@OrgSID                         = @OrgSID
				,@RegionSID                      = @RegionSID
				,@ProcessingComments             = @ProcessingComments
				,@UserDefinedColumns             = @UserDefinedColumns
				,@CredentialProfileXID           = @CredentialProfileXID
				,@LegacyKey                      = @LegacyKey
				,@IsDeleted                      = @IsDeleted
				,@CreateUser                     = @CreateUser
				,@CreateTime                     = @CreateTime
				,@UpdateTime                     = @UpdateTime
				,@RowGUID                        = @RowGUID
				,@ProcessingStatusSCD            = @ProcessingStatusSCD
				,@ProcessingStatusLabel          = @ProcessingStatusLabel
				,@IsClosedStatus                 = @IsClosedStatus
				,@ProcessingStatusIsActive       = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault      = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID        = @ProcessingStatusRowGUID
				,@CredentialCredentialTypeSID    = @CredentialCredentialTypeSID
				,@CredentialLabel                = @CredentialLabel
				,@ToolTip                        = @ToolTip
				,@IsRelatedToProfession          = @IsRelatedToProfession
				,@IsProgramRequired              = @IsProgramRequired
				,@IsSpecialization               = @IsSpecialization
				,@CredentialIsActive             = @CredentialIsActive
				,@CredentialCode                 = @CredentialCode
				,@CredentialRowGUID              = @CredentialRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgOrgName                     = @OrgOrgName
				,@OrgOrgLabel                    = @OrgOrgLabel
				,@OrgStreetAddress1              = @OrgStreetAddress1
				,@OrgStreetAddress2              = @OrgStreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@OrgPostalCode                  = @OrgPostalCode
				,@OrgRegionSID                   = @OrgRegionSID
				,@OrgPhone                       = @OrgPhone
				,@OrgFax                         = @OrgFax
				,@OrgWebSite                     = @OrgWebSite
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
				,@RegionRegionLabel              = @RegionRegionLabel
				,@RegionRegionName               = @RegionRegionName
				,@RegionIsDefault                = @RegionIsDefault
				,@RegionIsActive                 = @RegionIsActive
				,@RegionRowGUID                  = @RegionRowGUID
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
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@zContext                       = @zContext
				,@IsQualifying                   = @IsQualifying
		
		end

		update																																-- update "IsDeleted" column to trap audit information
			stg.CredentialProfile
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			CredentialProfileSID = @CredentialProfileSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				stg.CredentialProfile
			where
				CredentialProfileSID = @CredentialProfileSID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from stg.CredentialProfile where CredentialProfileSID = @credentialProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'stg.CredentialProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'stg.CredentialProfile'
					,@Arg2        = @credentialProfileSID
				
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
				,@Arg2        = 'stg.CredentialProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @credentialProfileSID
			
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
				r.RoutineName = 'stg#pCredentialProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pCredentialProfile
				 @Mode                           = 'delete.post'
				,@CredentialProfileSID           = @CredentialProfileSID
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@ProcessingStatusSID            = @ProcessingStatusSID
				,@SourceFileName                 = @SourceFileName
				,@ProgramStartDate               = @ProgramStartDate
				,@ProgramTargetCompletionDate    = @ProgramTargetCompletionDate
				,@EffectiveTime                  = @EffectiveTime
				,@IsDisplayedOnLicense           = @IsDisplayedOnLicense
				,@ProgramName                    = @ProgramName
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreedAddress3                 = @StreedAddress3
				,@CityName                       = @CityName
				,@StateProvinceName              = @StateProvinceName
				,@StateProvinceCode              = @StateProvinceCode
				,@PostalCode                     = @PostalCode
				,@CountryName                    = @CountryName
				,@CountryISOA3                   = @CountryISOA3
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@RegionLabel                    = @RegionLabel
				,@RegionName                     = @RegionName
				,@CredentialTypeLabel            = @CredentialTypeLabel
				,@RegistrantSID                  = @RegistrantSID
				,@CredentialSID                  = @CredentialSID
				,@CredentialTypeSID              = @CredentialTypeSID
				,@OrgSID                         = @OrgSID
				,@RegionSID                      = @RegionSID
				,@ProcessingComments             = @ProcessingComments
				,@UserDefinedColumns             = @UserDefinedColumns
				,@CredentialProfileXID           = @CredentialProfileXID
				,@LegacyKey                      = @LegacyKey
				,@IsDeleted                      = @IsDeleted
				,@CreateUser                     = @CreateUser
				,@CreateTime                     = @CreateTime
				,@UpdateTime                     = @UpdateTime
				,@RowGUID                        = @RowGUID
				,@ProcessingStatusSCD            = @ProcessingStatusSCD
				,@ProcessingStatusLabel          = @ProcessingStatusLabel
				,@IsClosedStatus                 = @IsClosedStatus
				,@ProcessingStatusIsActive       = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault      = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID        = @ProcessingStatusRowGUID
				,@CredentialCredentialTypeSID    = @CredentialCredentialTypeSID
				,@CredentialLabel                = @CredentialLabel
				,@ToolTip                        = @ToolTip
				,@IsRelatedToProfession          = @IsRelatedToProfession
				,@IsProgramRequired              = @IsProgramRequired
				,@IsSpecialization               = @IsSpecialization
				,@CredentialIsActive             = @CredentialIsActive
				,@CredentialCode                 = @CredentialCode
				,@CredentialRowGUID              = @CredentialRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgOrgName                     = @OrgOrgName
				,@OrgOrgLabel                    = @OrgOrgLabel
				,@OrgStreetAddress1              = @OrgStreetAddress1
				,@OrgStreetAddress2              = @OrgStreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@OrgPostalCode                  = @OrgPostalCode
				,@OrgRegionSID                   = @OrgRegionSID
				,@OrgPhone                       = @OrgPhone
				,@OrgFax                         = @OrgFax
				,@OrgWebSite                     = @OrgWebSite
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
				,@RegionRegionLabel              = @RegionRegionLabel
				,@RegionRegionName               = @RegionRegionName
				,@RegionIsDefault                = @RegionIsDefault
				,@RegionIsActive                 = @RegionIsActive
				,@RegionRowGUID                  = @RegionRowGUID
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
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@zContext                       = @zContext
				,@IsQualifying                   = @IsQualifying
		
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
