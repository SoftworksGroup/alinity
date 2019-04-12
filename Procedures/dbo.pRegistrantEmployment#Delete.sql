SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantEmployment#Delete]
	 @RegistrantEmploymentSID                    int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                                 nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                   timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@RegistrantSID                              int               = null
	,@OrgSID                                     int               = null
	,@RegistrationYear                           smallint          = null
	,@EmploymentTypeSID                          int               = null
	,@EmploymentRoleSID                          int               = null
	,@PracticeHours                              int               = null
	,@PracticeScopeSID                           int               = null
	,@AgeRangeSID                                int               = null
	,@IsOnPublicRegistry                         bit               = null
	,@Phone                                      varchar(25)       = null
	,@SiteLocation                               nvarchar(50)      = null
	,@EffectiveTime                              datetime          = null
	,@ExpiryTime                                 datetime          = null
	,@Rank                                       smallint          = null
	,@OwnershipPercentage                        smallint          = null
	,@IsEmployerInsurance                        bit               = null
	,@InsuranceOrgSID                            int               = null
	,@InsurancePolicyNo                          varchar(25)       = null
	,@InsuranceAmount                            decimal(11,2)     = null
	,@UserDefinedColumns                         xml               = null
	,@RegistrantEmploymentXID                    varchar(150)      = null
	,@LegacyKey                                  nvarchar(50)      = null
	,@IsDeleted                                  bit               = null
	,@CreateUser                                 nvarchar(75)      = null
	,@CreateTime                                 datetimeoffset(7) = null
	,@UpdateTime                                 datetimeoffset(7) = null
	,@RowGUID                                    uniqueidentifier  = null
	,@AgeRangeTypeSID                            int               = null
	,@AgeRangeLabel                              nvarchar(35)      = null
	,@StartAge                                   smallint          = null
	,@EndAge                                     smallint          = null
	,@AgeRangeIsDefault                          bit               = null
	,@AgeRangeRowGUID                            uniqueidentifier  = null
	,@EmploymentRoleName                         nvarchar(50)      = null
	,@EmploymentRoleCode                         varchar(20)       = null
	,@EmploymentRoleIsDefault                    bit               = null
	,@EmploymentRoleIsActive                     bit               = null
	,@EmploymentRoleRowGUID                      uniqueidentifier  = null
	,@EmploymentTypeName                         nvarchar(50)      = null
	,@EmploymentTypeCode                         varchar(20)       = null
	,@EmploymentTypeCategory                     nvarchar(65)      = null
	,@EmploymentTypeIsDefault                    bit               = null
	,@EmploymentTypeIsActive                     bit               = null
	,@EmploymentTypeRowGUID                      uniqueidentifier  = null
	,@OrgParentOrgSID                            int               = null
	,@OrgOrgTypeSID                              int               = null
	,@OrgOrgName                                 nvarchar(150)     = null
	,@OrgOrgLabel                                nvarchar(35)      = null
	,@OrgStreetAddress1                          nvarchar(75)      = null
	,@OrgStreetAddress2                          nvarchar(75)      = null
	,@OrgStreetAddress3                          nvarchar(75)      = null
	,@OrgCitySID                                 int               = null
	,@OrgPostalCode                              varchar(10)       = null
	,@OrgRegionSID                               int               = null
	,@OrgPhone                                   varchar(25)       = null
	,@OrgFax                                     varchar(25)       = null
	,@OrgWebSite                                 varchar(250)      = null
	,@OrgEmailAddress                            varchar(150)      = null
	,@OrgInsuranceOrgSID                         int               = null
	,@OrgInsurancePolicyNo                       varchar(25)       = null
	,@OrgInsuranceAmount                         decimal(11,2)     = null
	,@OrgIsEmployer                              bit               = null
	,@OrgIsCredentialAuthority                   bit               = null
	,@OrgIsInsurer                               bit               = null
	,@OrgIsInsuranceCertificateRequired          bit               = null
	,@OrgIsPublic                                nchar(10)         = null
	,@OrgIsActive                                bit               = null
	,@OrgIsAdminReviewRequired                   bit               = null
	,@OrgLastVerifiedTime                        datetimeoffset(7) = null
	,@OrgRowGUID                                 uniqueidentifier  = null
	,@PracticeScopeName                          nvarchar(50)      = null
	,@PracticeScopeCode                          varchar(20)       = null
	,@PracticeScopeIsDefault                     bit               = null
	,@PracticeScopeIsActive                      bit               = null
	,@PracticeScopeRowGUID                       uniqueidentifier  = null
	,@PersonSID                                  int               = null
	,@RegistrantNo                               varchar(50)       = null
	,@YearOfInitialEmployment                    smallint          = null
	,@RegistrantIsOnPublicRegistry               bit               = null
	,@CityNameOfBirth                            nvarchar(30)      = null
	,@CountrySID                                 int               = null
	,@DirectedAuditYearCompetence                smallint          = null
	,@DirectedAuditYearPracticeHours             smallint          = null
	,@LateFeeExclusionYear                       smallint          = null
	,@IsRenewalAutoApprovalBlocked               bit               = null
	,@RenewalExtensionExpiryTime                 datetime          = null
	,@ArchivedTime                               datetimeoffset(7) = null
	,@RegistrantRowGUID                          uniqueidentifier  = null
	,@OrgInsuranceParentOrgSID                   int               = null
	,@OrgInsuranceOrgTypeSID                     int               = null
	,@OrgInsuranceOrgName                        nvarchar(150)     = null
	,@OrgInsuranceOrgLabel                       nvarchar(35)      = null
	,@OrgInsuranceStreetAddress1                 nvarchar(75)      = null
	,@OrgInsuranceStreetAddress2                 nvarchar(75)      = null
	,@OrgInsuranceStreetAddress3                 nvarchar(75)      = null
	,@OrgInsuranceCitySID                        int               = null
	,@OrgInsurancePostalCode                     varchar(10)       = null
	,@OrgInsuranceRegionSID                      int               = null
	,@OrgInsurancePhone                          varchar(25)       = null
	,@OrgInsuranceFax                            varchar(25)       = null
	,@OrgInsuranceWebSite                        varchar(250)      = null
	,@OrgInsuranceEmailAddress                   varchar(150)      = null
	,@OrgInsuranceInsuranceOrgSID                int               = null
	,@OrgInsuranceInsurancePolicyNo              varchar(25)       = null
	,@OrgInsuranceInsuranceAmount                decimal(11,2)     = null
	,@OrgInsuranceIsEmployer                     bit               = null
	,@OrgInsuranceIsCredentialAuthority          bit               = null
	,@OrgInsuranceIsInsurer                      bit               = null
	,@OrgInsuranceIsInsuranceCertificateRequired bit               = null
	,@OrgInsuranceIsPublic                       nchar(10)         = null
	,@OrgInsuranceIsActive                       bit               = null
	,@OrgInsuranceIsAdminReviewRequired          bit               = null
	,@OrgInsuranceLastVerifiedTime               datetimeoffset(7) = null
	,@OrgInsuranceRowGUID                        uniqueidentifier  = null
	,@IsActive                                   bit               = null
	,@IsPending                                  bit               = null
	,@IsDeleteEnabled                            bit               = null
	,@zContext                                   xml               = null -- other values defining context for the delete (if any)
	,@IsSelfEmployed                             bit               = null
	,@EmploymentRankNo                           int               = null
	,@PrimaryPracticeAreaSID                     int               = null
	,@PrimaryPracticeAreaName                    nvarchar(50)      = null
	,@PrimaryPracticeAreaCode                    varchar(20)       = null
	,@IsPracticeScopeRequired                    bit               = null
	,@EmploymentSupervisorSID                    int               = null
	,@SupervisorPersonSID                        int               = null
	,@IsPrivateInsurance                         bit               = null
	,@EffectiveInsuranceProviderName             nvarchar(150)     = null
	,@EffectiveInsurancePolicyNo                 varchar(25)       = null
	,@EffectiveInsuranceAmount                   decimal(11,2)     = null
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantEmployment#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the dbo.RegistrantEmployment table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantEmployment table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pRegistrantEmployment procedure. The extended procedure is only called
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
and in the ext.pRegistrantEmployment procedure for client-specific deletion rules.

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

		if @RegistrantEmploymentSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantEmploymentSID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from dbo.RegistrantEmployment x where x.RegistrantEmploymentSID = @RegistrantEmploymentSID

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
				r.RoutineName = 'pRegistrantEmployment'
		)
		begin
		
			exec @errorNo = ext.pRegistrantEmployment
				 @Mode                                       = 'delete.pre'
				,@RegistrantEmploymentSID                    = @RegistrantEmploymentSID
				,@UpdateUser                                 = @UpdateUser
				,@RowStamp                                   = @RowStamp
				,@RegistrantSID                              = @RegistrantSID
				,@OrgSID                                     = @OrgSID
				,@RegistrationYear                           = @RegistrationYear
				,@EmploymentTypeSID                          = @EmploymentTypeSID
				,@EmploymentRoleSID                          = @EmploymentRoleSID
				,@PracticeHours                              = @PracticeHours
				,@PracticeScopeSID                           = @PracticeScopeSID
				,@AgeRangeSID                                = @AgeRangeSID
				,@IsOnPublicRegistry                         = @IsOnPublicRegistry
				,@Phone                                      = @Phone
				,@SiteLocation                               = @SiteLocation
				,@EffectiveTime                              = @EffectiveTime
				,@ExpiryTime                                 = @ExpiryTime
				,@Rank                                       = @Rank
				,@OwnershipPercentage                        = @OwnershipPercentage
				,@IsEmployerInsurance                        = @IsEmployerInsurance
				,@InsuranceOrgSID                            = @InsuranceOrgSID
				,@InsurancePolicyNo                          = @InsurancePolicyNo
				,@InsuranceAmount                            = @InsuranceAmount
				,@UserDefinedColumns                         = @UserDefinedColumns
				,@RegistrantEmploymentXID                    = @RegistrantEmploymentXID
				,@LegacyKey                                  = @LegacyKey
				,@IsDeleted                                  = @IsDeleted
				,@CreateUser                                 = @CreateUser
				,@CreateTime                                 = @CreateTime
				,@UpdateTime                                 = @UpdateTime
				,@RowGUID                                    = @RowGUID
				,@AgeRangeTypeSID                            = @AgeRangeTypeSID
				,@AgeRangeLabel                              = @AgeRangeLabel
				,@StartAge                                   = @StartAge
				,@EndAge                                     = @EndAge
				,@AgeRangeIsDefault                          = @AgeRangeIsDefault
				,@AgeRangeRowGUID                            = @AgeRangeRowGUID
				,@EmploymentRoleName                         = @EmploymentRoleName
				,@EmploymentRoleCode                         = @EmploymentRoleCode
				,@EmploymentRoleIsDefault                    = @EmploymentRoleIsDefault
				,@EmploymentRoleIsActive                     = @EmploymentRoleIsActive
				,@EmploymentRoleRowGUID                      = @EmploymentRoleRowGUID
				,@EmploymentTypeName                         = @EmploymentTypeName
				,@EmploymentTypeCode                         = @EmploymentTypeCode
				,@EmploymentTypeCategory                     = @EmploymentTypeCategory
				,@EmploymentTypeIsDefault                    = @EmploymentTypeIsDefault
				,@EmploymentTypeIsActive                     = @EmploymentTypeIsActive
				,@EmploymentTypeRowGUID                      = @EmploymentTypeRowGUID
				,@OrgParentOrgSID                            = @OrgParentOrgSID
				,@OrgOrgTypeSID                              = @OrgOrgTypeSID
				,@OrgOrgName                                 = @OrgOrgName
				,@OrgOrgLabel                                = @OrgOrgLabel
				,@OrgStreetAddress1                          = @OrgStreetAddress1
				,@OrgStreetAddress2                          = @OrgStreetAddress2
				,@OrgStreetAddress3                          = @OrgStreetAddress3
				,@OrgCitySID                                 = @OrgCitySID
				,@OrgPostalCode                              = @OrgPostalCode
				,@OrgRegionSID                               = @OrgRegionSID
				,@OrgPhone                                   = @OrgPhone
				,@OrgFax                                     = @OrgFax
				,@OrgWebSite                                 = @OrgWebSite
				,@OrgEmailAddress                            = @OrgEmailAddress
				,@OrgInsuranceOrgSID                         = @OrgInsuranceOrgSID
				,@OrgInsurancePolicyNo                       = @OrgInsurancePolicyNo
				,@OrgInsuranceAmount                         = @OrgInsuranceAmount
				,@OrgIsEmployer                              = @OrgIsEmployer
				,@OrgIsCredentialAuthority                   = @OrgIsCredentialAuthority
				,@OrgIsInsurer                               = @OrgIsInsurer
				,@OrgIsInsuranceCertificateRequired          = @OrgIsInsuranceCertificateRequired
				,@OrgIsPublic                                = @OrgIsPublic
				,@OrgIsActive                                = @OrgIsActive
				,@OrgIsAdminReviewRequired                   = @OrgIsAdminReviewRequired
				,@OrgLastVerifiedTime                        = @OrgLastVerifiedTime
				,@OrgRowGUID                                 = @OrgRowGUID
				,@PracticeScopeName                          = @PracticeScopeName
				,@PracticeScopeCode                          = @PracticeScopeCode
				,@PracticeScopeIsDefault                     = @PracticeScopeIsDefault
				,@PracticeScopeIsActive                      = @PracticeScopeIsActive
				,@PracticeScopeRowGUID                       = @PracticeScopeRowGUID
				,@PersonSID                                  = @PersonSID
				,@RegistrantNo                               = @RegistrantNo
				,@YearOfInitialEmployment                    = @YearOfInitialEmployment
				,@RegistrantIsOnPublicRegistry               = @RegistrantIsOnPublicRegistry
				,@CityNameOfBirth                            = @CityNameOfBirth
				,@CountrySID                                 = @CountrySID
				,@DirectedAuditYearCompetence                = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours             = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear                       = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked               = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime                 = @RenewalExtensionExpiryTime
				,@ArchivedTime                               = @ArchivedTime
				,@RegistrantRowGUID                          = @RegistrantRowGUID
				,@OrgInsuranceParentOrgSID                   = @OrgInsuranceParentOrgSID
				,@OrgInsuranceOrgTypeSID                     = @OrgInsuranceOrgTypeSID
				,@OrgInsuranceOrgName                        = @OrgInsuranceOrgName
				,@OrgInsuranceOrgLabel                       = @OrgInsuranceOrgLabel
				,@OrgInsuranceStreetAddress1                 = @OrgInsuranceStreetAddress1
				,@OrgInsuranceStreetAddress2                 = @OrgInsuranceStreetAddress2
				,@OrgInsuranceStreetAddress3                 = @OrgInsuranceStreetAddress3
				,@OrgInsuranceCitySID                        = @OrgInsuranceCitySID
				,@OrgInsurancePostalCode                     = @OrgInsurancePostalCode
				,@OrgInsuranceRegionSID                      = @OrgInsuranceRegionSID
				,@OrgInsurancePhone                          = @OrgInsurancePhone
				,@OrgInsuranceFax                            = @OrgInsuranceFax
				,@OrgInsuranceWebSite                        = @OrgInsuranceWebSite
				,@OrgInsuranceEmailAddress                   = @OrgInsuranceEmailAddress
				,@OrgInsuranceInsuranceOrgSID                = @OrgInsuranceInsuranceOrgSID
				,@OrgInsuranceInsurancePolicyNo              = @OrgInsuranceInsurancePolicyNo
				,@OrgInsuranceInsuranceAmount                = @OrgInsuranceInsuranceAmount
				,@OrgInsuranceIsEmployer                     = @OrgInsuranceIsEmployer
				,@OrgInsuranceIsCredentialAuthority          = @OrgInsuranceIsCredentialAuthority
				,@OrgInsuranceIsInsurer                      = @OrgInsuranceIsInsurer
				,@OrgInsuranceIsInsuranceCertificateRequired = @OrgInsuranceIsInsuranceCertificateRequired
				,@OrgInsuranceIsPublic                       = @OrgInsuranceIsPublic
				,@OrgInsuranceIsActive                       = @OrgInsuranceIsActive
				,@OrgInsuranceIsAdminReviewRequired          = @OrgInsuranceIsAdminReviewRequired
				,@OrgInsuranceLastVerifiedTime               = @OrgInsuranceLastVerifiedTime
				,@OrgInsuranceRowGUID                        = @OrgInsuranceRowGUID
				,@IsActive                                   = @IsActive
				,@IsPending                                  = @IsPending
				,@IsDeleteEnabled                            = @IsDeleteEnabled
				,@zContext                                   = @zContext
				,@IsSelfEmployed                             = @IsSelfEmployed
				,@EmploymentRankNo                           = @EmploymentRankNo
				,@PrimaryPracticeAreaSID                     = @PrimaryPracticeAreaSID
				,@PrimaryPracticeAreaName                    = @PrimaryPracticeAreaName
				,@PrimaryPracticeAreaCode                    = @PrimaryPracticeAreaCode
				,@IsPracticeScopeRequired                    = @IsPracticeScopeRequired
				,@EmploymentSupervisorSID                    = @EmploymentSupervisorSID
				,@SupervisorPersonSID                        = @SupervisorPersonSID
				,@IsPrivateInsurance                         = @IsPrivateInsurance
				,@EffectiveInsuranceProviderName             = @EffectiveInsuranceProviderName
				,@EffectiveInsurancePolicyNo                 = @EffectiveInsurancePolicyNo
				,@EffectiveInsuranceAmount                   = @EffectiveInsuranceAmount
		
		end

		update																																-- update "IsDeleted" column to trap audit information
			dbo.RegistrantEmployment
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantEmploymentSID = @RegistrantEmploymentSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				dbo.RegistrantEmployment
			where
				RegistrantEmploymentSID = @RegistrantEmploymentSID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantEmployment where RegistrantEmploymentSID = @registrantEmploymentSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantEmployment'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantEmployment'
					,@Arg2        = @registrantEmploymentSID
				
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
				,@Arg2        = 'dbo.RegistrantEmployment'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantEmploymentSID
			
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
				r.RoutineName = 'pRegistrantEmployment'
		)
		begin
		
			exec @errorNo = ext.pRegistrantEmployment
				 @Mode                                       = 'delete.post'
				,@RegistrantEmploymentSID                    = @RegistrantEmploymentSID
				,@UpdateUser                                 = @UpdateUser
				,@RowStamp                                   = @RowStamp
				,@RegistrantSID                              = @RegistrantSID
				,@OrgSID                                     = @OrgSID
				,@RegistrationYear                           = @RegistrationYear
				,@EmploymentTypeSID                          = @EmploymentTypeSID
				,@EmploymentRoleSID                          = @EmploymentRoleSID
				,@PracticeHours                              = @PracticeHours
				,@PracticeScopeSID                           = @PracticeScopeSID
				,@AgeRangeSID                                = @AgeRangeSID
				,@IsOnPublicRegistry                         = @IsOnPublicRegistry
				,@Phone                                      = @Phone
				,@SiteLocation                               = @SiteLocation
				,@EffectiveTime                              = @EffectiveTime
				,@ExpiryTime                                 = @ExpiryTime
				,@Rank                                       = @Rank
				,@OwnershipPercentage                        = @OwnershipPercentage
				,@IsEmployerInsurance                        = @IsEmployerInsurance
				,@InsuranceOrgSID                            = @InsuranceOrgSID
				,@InsurancePolicyNo                          = @InsurancePolicyNo
				,@InsuranceAmount                            = @InsuranceAmount
				,@UserDefinedColumns                         = @UserDefinedColumns
				,@RegistrantEmploymentXID                    = @RegistrantEmploymentXID
				,@LegacyKey                                  = @LegacyKey
				,@IsDeleted                                  = @IsDeleted
				,@CreateUser                                 = @CreateUser
				,@CreateTime                                 = @CreateTime
				,@UpdateTime                                 = @UpdateTime
				,@RowGUID                                    = @RowGUID
				,@AgeRangeTypeSID                            = @AgeRangeTypeSID
				,@AgeRangeLabel                              = @AgeRangeLabel
				,@StartAge                                   = @StartAge
				,@EndAge                                     = @EndAge
				,@AgeRangeIsDefault                          = @AgeRangeIsDefault
				,@AgeRangeRowGUID                            = @AgeRangeRowGUID
				,@EmploymentRoleName                         = @EmploymentRoleName
				,@EmploymentRoleCode                         = @EmploymentRoleCode
				,@EmploymentRoleIsDefault                    = @EmploymentRoleIsDefault
				,@EmploymentRoleIsActive                     = @EmploymentRoleIsActive
				,@EmploymentRoleRowGUID                      = @EmploymentRoleRowGUID
				,@EmploymentTypeName                         = @EmploymentTypeName
				,@EmploymentTypeCode                         = @EmploymentTypeCode
				,@EmploymentTypeCategory                     = @EmploymentTypeCategory
				,@EmploymentTypeIsDefault                    = @EmploymentTypeIsDefault
				,@EmploymentTypeIsActive                     = @EmploymentTypeIsActive
				,@EmploymentTypeRowGUID                      = @EmploymentTypeRowGUID
				,@OrgParentOrgSID                            = @OrgParentOrgSID
				,@OrgOrgTypeSID                              = @OrgOrgTypeSID
				,@OrgOrgName                                 = @OrgOrgName
				,@OrgOrgLabel                                = @OrgOrgLabel
				,@OrgStreetAddress1                          = @OrgStreetAddress1
				,@OrgStreetAddress2                          = @OrgStreetAddress2
				,@OrgStreetAddress3                          = @OrgStreetAddress3
				,@OrgCitySID                                 = @OrgCitySID
				,@OrgPostalCode                              = @OrgPostalCode
				,@OrgRegionSID                               = @OrgRegionSID
				,@OrgPhone                                   = @OrgPhone
				,@OrgFax                                     = @OrgFax
				,@OrgWebSite                                 = @OrgWebSite
				,@OrgEmailAddress                            = @OrgEmailAddress
				,@OrgInsuranceOrgSID                         = @OrgInsuranceOrgSID
				,@OrgInsurancePolicyNo                       = @OrgInsurancePolicyNo
				,@OrgInsuranceAmount                         = @OrgInsuranceAmount
				,@OrgIsEmployer                              = @OrgIsEmployer
				,@OrgIsCredentialAuthority                   = @OrgIsCredentialAuthority
				,@OrgIsInsurer                               = @OrgIsInsurer
				,@OrgIsInsuranceCertificateRequired          = @OrgIsInsuranceCertificateRequired
				,@OrgIsPublic                                = @OrgIsPublic
				,@OrgIsActive                                = @OrgIsActive
				,@OrgIsAdminReviewRequired                   = @OrgIsAdminReviewRequired
				,@OrgLastVerifiedTime                        = @OrgLastVerifiedTime
				,@OrgRowGUID                                 = @OrgRowGUID
				,@PracticeScopeName                          = @PracticeScopeName
				,@PracticeScopeCode                          = @PracticeScopeCode
				,@PracticeScopeIsDefault                     = @PracticeScopeIsDefault
				,@PracticeScopeIsActive                      = @PracticeScopeIsActive
				,@PracticeScopeRowGUID                       = @PracticeScopeRowGUID
				,@PersonSID                                  = @PersonSID
				,@RegistrantNo                               = @RegistrantNo
				,@YearOfInitialEmployment                    = @YearOfInitialEmployment
				,@RegistrantIsOnPublicRegistry               = @RegistrantIsOnPublicRegistry
				,@CityNameOfBirth                            = @CityNameOfBirth
				,@CountrySID                                 = @CountrySID
				,@DirectedAuditYearCompetence                = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours             = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear                       = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked               = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime                 = @RenewalExtensionExpiryTime
				,@ArchivedTime                               = @ArchivedTime
				,@RegistrantRowGUID                          = @RegistrantRowGUID
				,@OrgInsuranceParentOrgSID                   = @OrgInsuranceParentOrgSID
				,@OrgInsuranceOrgTypeSID                     = @OrgInsuranceOrgTypeSID
				,@OrgInsuranceOrgName                        = @OrgInsuranceOrgName
				,@OrgInsuranceOrgLabel                       = @OrgInsuranceOrgLabel
				,@OrgInsuranceStreetAddress1                 = @OrgInsuranceStreetAddress1
				,@OrgInsuranceStreetAddress2                 = @OrgInsuranceStreetAddress2
				,@OrgInsuranceStreetAddress3                 = @OrgInsuranceStreetAddress3
				,@OrgInsuranceCitySID                        = @OrgInsuranceCitySID
				,@OrgInsurancePostalCode                     = @OrgInsurancePostalCode
				,@OrgInsuranceRegionSID                      = @OrgInsuranceRegionSID
				,@OrgInsurancePhone                          = @OrgInsurancePhone
				,@OrgInsuranceFax                            = @OrgInsuranceFax
				,@OrgInsuranceWebSite                        = @OrgInsuranceWebSite
				,@OrgInsuranceEmailAddress                   = @OrgInsuranceEmailAddress
				,@OrgInsuranceInsuranceOrgSID                = @OrgInsuranceInsuranceOrgSID
				,@OrgInsuranceInsurancePolicyNo              = @OrgInsuranceInsurancePolicyNo
				,@OrgInsuranceInsuranceAmount                = @OrgInsuranceInsuranceAmount
				,@OrgInsuranceIsEmployer                     = @OrgInsuranceIsEmployer
				,@OrgInsuranceIsCredentialAuthority          = @OrgInsuranceIsCredentialAuthority
				,@OrgInsuranceIsInsurer                      = @OrgInsuranceIsInsurer
				,@OrgInsuranceIsInsuranceCertificateRequired = @OrgInsuranceIsInsuranceCertificateRequired
				,@OrgInsuranceIsPublic                       = @OrgInsuranceIsPublic
				,@OrgInsuranceIsActive                       = @OrgInsuranceIsActive
				,@OrgInsuranceIsAdminReviewRequired          = @OrgInsuranceIsAdminReviewRequired
				,@OrgInsuranceLastVerifiedTime               = @OrgInsuranceLastVerifiedTime
				,@OrgInsuranceRowGUID                        = @OrgInsuranceRowGUID
				,@IsActive                                   = @IsActive
				,@IsPending                                  = @IsPending
				,@IsDeleteEnabled                            = @IsDeleteEnabled
				,@zContext                                   = @zContext
				,@IsSelfEmployed                             = @IsSelfEmployed
				,@EmploymentRankNo                           = @EmploymentRankNo
				,@PrimaryPracticeAreaSID                     = @PrimaryPracticeAreaSID
				,@PrimaryPracticeAreaName                    = @PrimaryPracticeAreaName
				,@PrimaryPracticeAreaCode                    = @PrimaryPracticeAreaCode
				,@IsPracticeScopeRequired                    = @IsPracticeScopeRequired
				,@EmploymentSupervisorSID                    = @EmploymentSupervisorSID
				,@SupervisorPersonSID                        = @SupervisorPersonSID
				,@IsPrivateInsurance                         = @IsPrivateInsurance
				,@EffectiveInsuranceProviderName             = @EffectiveInsuranceProviderName
				,@EffectiveInsurancePolicyNo                 = @EffectiveInsurancePolicyNo
				,@EffectiveInsuranceAmount                   = @EffectiveInsuranceAmount
		
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
