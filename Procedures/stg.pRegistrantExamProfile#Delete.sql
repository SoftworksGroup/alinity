SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantExamProfile#Delete]
	 @RegistrantExamProfileSID       int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@ImportFileSID                  int               = null
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
	,@IsDeleted                      bit               = null
	,@CreateUser                     nvarchar(75)      = null
	,@CreateTime                     datetimeoffset(7) = null
	,@UpdateTime                     datetimeoffset(7) = null
	,@RowGUID                        uniqueidentifier  = null
	,@FileFormatSID                  int               = null
	,@ApplicationEntitySID           int               = null
	,@FileName                       nvarchar(100)     = null
	,@LoadStartTime                  datetimeoffset(7) = null
	,@LoadEndTime                    datetimeoffset(7) = null
	,@IsFailed                       bit               = null
	,@MessageText                    nvarchar(4000)    = null
	,@ImportFileRowGUID              uniqueidentifier  = null
	,@ProcessingStatusSCD            varchar(10)       = null
	,@ProcessingStatusLabel          nvarchar(35)      = null
	,@IsClosedStatus                 bit               = null
	,@ProcessingStatusIsActive       bit               = null
	,@ProcessingStatusIsDefault      bit               = null
	,@ProcessingStatusRowGUID        uniqueidentifier  = null
	,@GenderSID                      int               = null
	,@NamePrefixSID                  int               = null
	,@PersonFirstName                nvarchar(30)      = null
	,@CommonName                     nvarchar(30)      = null
	,@MiddleNames                    nvarchar(30)      = null
	,@PersonLastName                 nvarchar(35)      = null
	,@PersonBirthDate                date              = null
	,@DeathDate                      date              = null
	,@HomePhone                      varchar(25)       = null
	,@MobilePhone                    varchar(25)       = null
	,@IsTextMessagingEnabled         bit               = null
	,@ImportBatch                    nvarchar(100)     = null
	,@PersonRowGUID                  uniqueidentifier  = null
	,@ExamName                       nvarchar(50)      = null
	,@ExamCategory                   nvarchar(65)      = null
	,@ExamPassingScore               int               = null
	,@EffectiveTime                  datetime          = null
	,@ExpiryTime                     datetime          = null
	,@IsOnlineExam                   bit               = null
	,@IsEnabledOnPortal              bit               = null
	,@Sequence                       int               = null
	,@CultureSID                     int               = null
	,@ExamLastVerifiedTime           datetimeoffset(7) = null
	,@MinLagDaysBetweenAttempts      smallint          = null
	,@MaxAttemptsPerYear             tinyint           = null
	,@VendorExamID                   varchar(25)       = null
	,@ExamRowGUID                    uniqueidentifier  = null
	,@ExamOfferingExamSID            int               = null
	,@ExamOfferingOrgSID             int               = null
	,@ExamOfferingExamTime           datetime          = null
	,@SeatingCapacity                int               = null
	,@CatalogItemSID                 int               = null
	,@BookingCutOffDate              date              = null
	,@VendorExamOfferingID           varchar(25)       = null
	,@ExamOfferingRowGUID            uniqueidentifier  = null
	,@ParentOrgSID                   int               = null
	,@OrgTypeSID                     int               = null
	,@OrgName                        nvarchar(150)     = null
	,@OrgOrgLabel                    nvarchar(35)      = null
	,@StreetAddress1                 nvarchar(75)      = null
	,@StreetAddress2                 nvarchar(75)      = null
	,@StreetAddress3                 nvarchar(75)      = null
	,@CitySID                        int               = null
	,@PostalCode                     varchar(10)       = null
	,@RegionSID                      int               = null
	,@Phone                          varchar(25)       = null
	,@Fax                            varchar(25)       = null
	,@WebSite                        varchar(250)      = null
	,@OrgEmailAddress                varchar(150)      = null
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
	,@OrgLastVerifiedTime            datetimeoffset(7) = null
	,@OrgRowGUID                     uniqueidentifier  = null
	,@RegistrantPersonSID            int               = null
	,@RegistrantRegistrantNo         varchar(50)       = null
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
	,@RegistrantLabel                nvarchar(75)      = null
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantExamProfile#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the stg.RegistrantExamProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.RegistrantExamProfile table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pRegistrantExamProfile procedure. The extended procedure is only called
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
and in the ext.pRegistrantExamProfile procedure for client-specific deletion rules.

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

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from stg.RegistrantExamProfile x where x.RegistrantExamProfileSID = @RegistrantExamProfileSID

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
				r.RoutineName = 'stg#pRegistrantExamProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantExamProfile
				 @Mode                           = 'delete.pre'
				,@RegistrantExamProfileSID       = @RegistrantExamProfileSID
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
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
				,@IsDeleted                      = @IsDeleted
				,@CreateUser                     = @CreateUser
				,@CreateTime                     = @CreateTime
				,@UpdateTime                     = @UpdateTime
				,@RowGUID                        = @RowGUID
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
				,@zContext                       = @zContext
				,@RegistrantLabel                = @RegistrantLabel
		
		end

		update																																-- update "IsDeleted" column to trap audit information
			stg.RegistrantExamProfile
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantExamProfileSID = @RegistrantExamProfileSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				stg.RegistrantExamProfile
			where
				RegistrantExamProfileSID = @RegistrantExamProfileSID
			
			set @rowsAffected = @@rowcount
			
		end

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
				,@Arg1        = 'delete'
				,@Arg2        = 'stg.RegistrantExamProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantExamProfileSID
			
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
				r.RoutineName = 'stg#pRegistrantExamProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantExamProfile
				 @Mode                           = 'delete.post'
				,@RegistrantExamProfileSID       = @RegistrantExamProfileSID
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
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
				,@IsDeleted                      = @IsDeleted
				,@CreateUser                     = @CreateUser
				,@CreateTime                     = @CreateTime
				,@UpdateTime                     = @UpdateTime
				,@RowGUID                        = @RowGUID
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
				,@zContext                       = @zContext
				,@RegistrantLabel                = @RegistrantLabel
		
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
