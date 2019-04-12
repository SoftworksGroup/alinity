SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantProfile#Delete]
	 @RegistrantProfileSID            int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                      nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                        timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@ImportFileSID                   int               = null
	,@ProcessingStatusSID             int               = null
	,@LastName                        nvarchar(35)      = null
	,@FirstName                       nvarchar(30)      = null
	,@CommonName                      nvarchar(30)      = null
	,@MiddleNames                     nvarchar(30)      = null
	,@EmailAddress                    varchar(150)      = null
	,@HomePhone                       varchar(25)       = null
	,@MobilePhone                     varchar(25)       = null
	,@IsTextMessagingEnabled          bit               = null
	,@GenderLabel                     nvarchar(35)      = null
	,@NamePrefixLabel                 nvarchar(35)      = null
	,@BirthDate                       date              = null
	,@DeathDate                       date              = null
	,@UserName                        nvarchar(75)      = null
	,@SubDomain                       varchar(63)       = null
	,@Password                        nvarchar(50)      = null
	,@StreetAddress1                  nvarchar(75)      = null
	,@StreetAddress2                  nvarchar(75)      = null
	,@StreetAddress3                  nvarchar(75)      = null
	,@CityName                        nvarchar(30)      = null
	,@StateProvinceName               nvarchar(30)      = null
	,@PostalCode                      varchar(10)       = null
	,@CountryName                     nvarchar(50)      = null
	,@RegionLabel                     nvarchar(35)      = null
	,@RegistrantNo                    varchar(50)       = null
	,@PersonGroupLabel1               nvarchar(35)      = null
	,@PersonGroupTitle1               nvarchar(75)      = null
	,@PersonGroupIsAdministrator1     bit               = null
	,@PersonGroupEffectiveDate1       date              = null
	,@PersonGroupExpiryDate1          date              = null
	,@PersonGroupLabel2               nvarchar(35)      = null
	,@PersonGroupTitle2               nvarchar(75)      = null
	,@PersonGroupIsAdministrator2     bit               = null
	,@PersonGroupEffectiveDate2       date              = null
	,@PersonGroupExpiryDate2          date              = null
	,@PersonGroupLabel3               nvarchar(35)      = null
	,@PersonGroupTitle3               nvarchar(75)      = null
	,@PersonGroupIsAdministrator3     bit               = null
	,@PersonGroupEffectiveDate3       date              = null
	,@PersonGroupExpiryDate3          date              = null
	,@PersonGroupLabel4               nvarchar(35)      = null
	,@PersonGroupTitle4               nvarchar(75)      = null
	,@PersonGroupIsAdministrator4     bit               = null
	,@PersonGroupEffectiveDate4       date              = null
	,@PersonGroupExpiryDate4          date              = null
	,@PersonGroupLabel5               nvarchar(35)      = null
	,@PersonGroupTitle5               nvarchar(75)      = null
	,@PersonGroupIsAdministrator5     bit               = null
	,@PersonGroupEffectiveDate5       date              = null
	,@PersonGroupExpiryDate5          date              = null
	,@PracticeRegisterLabel           nvarchar(35)      = null
	,@PracticeRegisterSectionLabel    nvarchar(35)      = null
	,@RegistrationEffectiveDate       date              = null
	,@QualifyingCredentialLabel       nvarchar(35)      = null
	,@QualifyingCredentialOrgLabel    nvarchar(35)      = null
	,@QualifyingProgramName           nvarchar(65)      = null
	,@QualifyingProgramStartDate      date              = null
	,@QualifyingProgramCompletionDate date              = null
	,@QualifyingFieldOfStudyName      nvarchar(50)      = null
	,@CredentialLabel1                nvarchar(35)      = null
	,@CredentialOrgLabel1             nvarchar(35)      = null
	,@CredentialProgramName1          nvarchar(65)      = null
	,@CredentialFieldOfStudyName1     nvarchar(50)      = null
	,@CredentialEffectiveDate1        date              = null
	,@CredentialExpiryDate1           date              = null
	,@CredentialLabel2                nvarchar(35)      = null
	,@CredentialOrgLabel2             nvarchar(35)      = null
	,@CredentialProgramName2          nvarchar(65)      = null
	,@CredentialFieldOfStudyName2     nvarchar(50)      = null
	,@CredentialEffectiveDate2        date              = null
	,@CredentialExpiryDate2           date              = null
	,@CredentialLabel3                nvarchar(35)      = null
	,@CredentialOrgLabel3             nvarchar(35)      = null
	,@CredentialProgramName3          nvarchar(65)      = null
	,@CredentialFieldOfStudyName3     nvarchar(50)      = null
	,@CredentialEffectiveDate3        date              = null
	,@CredentialExpiryDate3           date              = null
	,@CredentialLabel4                nvarchar(35)      = null
	,@CredentialOrgLabel4             nvarchar(35)      = null
	,@CredentialProgramName4          nvarchar(65)      = null
	,@CredentialFieldOfStudyName4     nvarchar(50)      = null
	,@CredentialEffectiveDate4        date              = null
	,@CredentialExpiryDate4           date              = null
	,@CredentialLabel5                nvarchar(35)      = null
	,@CredentialOrgLabel5             nvarchar(35)      = null
	,@CredentialProgramName5          nvarchar(65)      = null
	,@CredentialFieldOfStudyName5     nvarchar(50)      = null
	,@CredentialEffectiveDate5        date              = null
	,@CredentialExpiryDate5           date              = null
	,@CredentialLabel6                nvarchar(35)      = null
	,@CredentialOrgLabel6             nvarchar(35)      = null
	,@CredentialProgramName6          nvarchar(65)      = null
	,@CredentialFieldOfStudyName6     nvarchar(50)      = null
	,@CredentialEffectiveDate6        date              = null
	,@CredentialExpiryDate6           date              = null
	,@CredentialLabel7                nvarchar(35)      = null
	,@CredentialOrgLabel7             nvarchar(35)      = null
	,@CredentialProgramName7          nvarchar(65)      = null
	,@CredentialFieldOfStudyName7     nvarchar(50)      = null
	,@CredentialEffectiveDate7        date              = null
	,@CredentialExpiryDate7           date              = null
	,@CredentialLabel8                nvarchar(35)      = null
	,@CredentialOrgLabel8             nvarchar(35)      = null
	,@CredentialProgramName8          nvarchar(65)      = null
	,@CredentialFieldOfStudyName8     nvarchar(50)      = null
	,@CredentialEffectiveDate8        date              = null
	,@CredentialExpiryDate8           date              = null
	,@CredentialLabel9                nvarchar(35)      = null
	,@CredentialOrgLabel9             nvarchar(35)      = null
	,@CredentialProgramName9          nvarchar(65)      = null
	,@CredentialFieldOfStudyName9     nvarchar(50)      = null
	,@CredentialEffectiveDate9        date              = null
	,@CredentialExpiryDate9           date              = null
	,@PersonSID                       int               = null
	,@PersonEmailAddressSID           int               = null
	,@ApplicationUserSID              int               = null
	,@PersonMailingAddressSID         int               = null
	,@RegionSID                       int               = null
	,@NamePrefixSID                   int               = null
	,@GenderSID                       int               = null
	,@CitySID                         int               = null
	,@StateProvinceSID                int               = null
	,@CountrySID                      int               = null
	,@RegistrantSID                   int               = null
	,@ProcessingComments              nvarchar(max)     = null
	,@UserDefinedColumns              xml               = null
	,@RegistrantProfileXID            varchar(150)      = null
	,@LegacyKey                       nvarchar(50)      = null
	,@IsDeleted                       bit               = null
	,@CreateUser                      nvarchar(75)      = null
	,@CreateTime                      datetimeoffset(7) = null
	,@UpdateTime                      datetimeoffset(7) = null
	,@RowGUID                         uniqueidentifier  = null
	,@FileFormatSID                   int               = null
	,@ApplicationEntitySID            int               = null
	,@FileName                        nvarchar(100)     = null
	,@LoadStartTime                   datetimeoffset(7) = null
	,@LoadEndTime                     datetimeoffset(7) = null
	,@IsFailed                        bit               = null
	,@MessageText                     nvarchar(4000)    = null
	,@ImportFileRowGUID               uniqueidentifier  = null
	,@ProcessingStatusSCD             varchar(10)       = null
	,@ProcessingStatusLabel           nvarchar(35)      = null
	,@IsClosedStatus                  bit               = null
	,@ProcessingStatusIsActive        bit               = null
	,@ProcessingStatusIsDefault       bit               = null
	,@ProcessingStatusRowGUID         uniqueidentifier  = null
	,@PersonEmailAddressPersonSID     int               = null
	,@PersonEmailAddressEmailAddress  varchar(150)      = null
	,@IsPrimary                       bit               = null
	,@PersonEmailAddressIsActive      bit               = null
	,@PersonEmailAddressRowGUID       uniqueidentifier  = null
	,@IsDeleteEnabled                 bit               = null
	,@zContext                        xml               = null -- other values defining context for the delete (if any)
	,@RegistrantLabel                 nvarchar(75)      = null
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantProfile#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the stg.RegistrantProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.RegistrantProfile table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pRegistrantProfile procedure. The extended procedure is only called
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
and in the ext.pRegistrantProfile procedure for client-specific deletion rules.

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

		if @RegistrantProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantProfileSID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from stg.RegistrantProfile x where x.RegistrantProfileSID = @RegistrantProfileSID

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
				r.RoutineName = 'stg#pRegistrantProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantProfile
				 @Mode                            = 'delete.pre'
				,@RegistrantProfileSID            = @RegistrantProfileSID
				,@UpdateUser                      = @UpdateUser
				,@RowStamp                        = @RowStamp
				,@ImportFileSID                   = @ImportFileSID
				,@ProcessingStatusSID             = @ProcessingStatusSID
				,@LastName                        = @LastName
				,@FirstName                       = @FirstName
				,@CommonName                      = @CommonName
				,@MiddleNames                     = @MiddleNames
				,@EmailAddress                    = @EmailAddress
				,@HomePhone                       = @HomePhone
				,@MobilePhone                     = @MobilePhone
				,@IsTextMessagingEnabled          = @IsTextMessagingEnabled
				,@GenderLabel                     = @GenderLabel
				,@NamePrefixLabel                 = @NamePrefixLabel
				,@BirthDate                       = @BirthDate
				,@DeathDate                       = @DeathDate
				,@UserName                        = @UserName
				,@SubDomain                       = @SubDomain
				,@Password                        = @Password
				,@StreetAddress1                  = @StreetAddress1
				,@StreetAddress2                  = @StreetAddress2
				,@StreetAddress3                  = @StreetAddress3
				,@CityName                        = @CityName
				,@StateProvinceName               = @StateProvinceName
				,@PostalCode                      = @PostalCode
				,@CountryName                     = @CountryName
				,@RegionLabel                     = @RegionLabel
				,@RegistrantNo                    = @RegistrantNo
				,@PersonGroupLabel1               = @PersonGroupLabel1
				,@PersonGroupTitle1               = @PersonGroupTitle1
				,@PersonGroupIsAdministrator1     = @PersonGroupIsAdministrator1
				,@PersonGroupEffectiveDate1       = @PersonGroupEffectiveDate1
				,@PersonGroupExpiryDate1          = @PersonGroupExpiryDate1
				,@PersonGroupLabel2               = @PersonGroupLabel2
				,@PersonGroupTitle2               = @PersonGroupTitle2
				,@PersonGroupIsAdministrator2     = @PersonGroupIsAdministrator2
				,@PersonGroupEffectiveDate2       = @PersonGroupEffectiveDate2
				,@PersonGroupExpiryDate2          = @PersonGroupExpiryDate2
				,@PersonGroupLabel3               = @PersonGroupLabel3
				,@PersonGroupTitle3               = @PersonGroupTitle3
				,@PersonGroupIsAdministrator3     = @PersonGroupIsAdministrator3
				,@PersonGroupEffectiveDate3       = @PersonGroupEffectiveDate3
				,@PersonGroupExpiryDate3          = @PersonGroupExpiryDate3
				,@PersonGroupLabel4               = @PersonGroupLabel4
				,@PersonGroupTitle4               = @PersonGroupTitle4
				,@PersonGroupIsAdministrator4     = @PersonGroupIsAdministrator4
				,@PersonGroupEffectiveDate4       = @PersonGroupEffectiveDate4
				,@PersonGroupExpiryDate4          = @PersonGroupExpiryDate4
				,@PersonGroupLabel5               = @PersonGroupLabel5
				,@PersonGroupTitle5               = @PersonGroupTitle5
				,@PersonGroupIsAdministrator5     = @PersonGroupIsAdministrator5
				,@PersonGroupEffectiveDate5       = @PersonGroupEffectiveDate5
				,@PersonGroupExpiryDate5          = @PersonGroupExpiryDate5
				,@PracticeRegisterLabel           = @PracticeRegisterLabel
				,@PracticeRegisterSectionLabel    = @PracticeRegisterSectionLabel
				,@RegistrationEffectiveDate       = @RegistrationEffectiveDate
				,@QualifyingCredentialLabel       = @QualifyingCredentialLabel
				,@QualifyingCredentialOrgLabel    = @QualifyingCredentialOrgLabel
				,@QualifyingProgramName           = @QualifyingProgramName
				,@QualifyingProgramStartDate      = @QualifyingProgramStartDate
				,@QualifyingProgramCompletionDate = @QualifyingProgramCompletionDate
				,@QualifyingFieldOfStudyName      = @QualifyingFieldOfStudyName
				,@CredentialLabel1                = @CredentialLabel1
				,@CredentialOrgLabel1             = @CredentialOrgLabel1
				,@CredentialProgramName1          = @CredentialProgramName1
				,@CredentialFieldOfStudyName1     = @CredentialFieldOfStudyName1
				,@CredentialEffectiveDate1        = @CredentialEffectiveDate1
				,@CredentialExpiryDate1           = @CredentialExpiryDate1
				,@CredentialLabel2                = @CredentialLabel2
				,@CredentialOrgLabel2             = @CredentialOrgLabel2
				,@CredentialProgramName2          = @CredentialProgramName2
				,@CredentialFieldOfStudyName2     = @CredentialFieldOfStudyName2
				,@CredentialEffectiveDate2        = @CredentialEffectiveDate2
				,@CredentialExpiryDate2           = @CredentialExpiryDate2
				,@CredentialLabel3                = @CredentialLabel3
				,@CredentialOrgLabel3             = @CredentialOrgLabel3
				,@CredentialProgramName3          = @CredentialProgramName3
				,@CredentialFieldOfStudyName3     = @CredentialFieldOfStudyName3
				,@CredentialEffectiveDate3        = @CredentialEffectiveDate3
				,@CredentialExpiryDate3           = @CredentialExpiryDate3
				,@CredentialLabel4                = @CredentialLabel4
				,@CredentialOrgLabel4             = @CredentialOrgLabel4
				,@CredentialProgramName4          = @CredentialProgramName4
				,@CredentialFieldOfStudyName4     = @CredentialFieldOfStudyName4
				,@CredentialEffectiveDate4        = @CredentialEffectiveDate4
				,@CredentialExpiryDate4           = @CredentialExpiryDate4
				,@CredentialLabel5                = @CredentialLabel5
				,@CredentialOrgLabel5             = @CredentialOrgLabel5
				,@CredentialProgramName5          = @CredentialProgramName5
				,@CredentialFieldOfStudyName5     = @CredentialFieldOfStudyName5
				,@CredentialEffectiveDate5        = @CredentialEffectiveDate5
				,@CredentialExpiryDate5           = @CredentialExpiryDate5
				,@CredentialLabel6                = @CredentialLabel6
				,@CredentialOrgLabel6             = @CredentialOrgLabel6
				,@CredentialProgramName6          = @CredentialProgramName6
				,@CredentialFieldOfStudyName6     = @CredentialFieldOfStudyName6
				,@CredentialEffectiveDate6        = @CredentialEffectiveDate6
				,@CredentialExpiryDate6           = @CredentialExpiryDate6
				,@CredentialLabel7                = @CredentialLabel7
				,@CredentialOrgLabel7             = @CredentialOrgLabel7
				,@CredentialProgramName7          = @CredentialProgramName7
				,@CredentialFieldOfStudyName7     = @CredentialFieldOfStudyName7
				,@CredentialEffectiveDate7        = @CredentialEffectiveDate7
				,@CredentialExpiryDate7           = @CredentialExpiryDate7
				,@CredentialLabel8                = @CredentialLabel8
				,@CredentialOrgLabel8             = @CredentialOrgLabel8
				,@CredentialProgramName8          = @CredentialProgramName8
				,@CredentialFieldOfStudyName8     = @CredentialFieldOfStudyName8
				,@CredentialEffectiveDate8        = @CredentialEffectiveDate8
				,@CredentialExpiryDate8           = @CredentialExpiryDate8
				,@CredentialLabel9                = @CredentialLabel9
				,@CredentialOrgLabel9             = @CredentialOrgLabel9
				,@CredentialProgramName9          = @CredentialProgramName9
				,@CredentialFieldOfStudyName9     = @CredentialFieldOfStudyName9
				,@CredentialEffectiveDate9        = @CredentialEffectiveDate9
				,@CredentialExpiryDate9           = @CredentialExpiryDate9
				,@PersonSID                       = @PersonSID
				,@PersonEmailAddressSID           = @PersonEmailAddressSID
				,@ApplicationUserSID              = @ApplicationUserSID
				,@PersonMailingAddressSID         = @PersonMailingAddressSID
				,@RegionSID                       = @RegionSID
				,@NamePrefixSID                   = @NamePrefixSID
				,@GenderSID                       = @GenderSID
				,@CitySID                         = @CitySID
				,@StateProvinceSID                = @StateProvinceSID
				,@CountrySID                      = @CountrySID
				,@RegistrantSID                   = @RegistrantSID
				,@ProcessingComments              = @ProcessingComments
				,@UserDefinedColumns              = @UserDefinedColumns
				,@RegistrantProfileXID            = @RegistrantProfileXID
				,@LegacyKey                       = @LegacyKey
				,@IsDeleted                       = @IsDeleted
				,@CreateUser                      = @CreateUser
				,@CreateTime                      = @CreateTime
				,@UpdateTime                      = @UpdateTime
				,@RowGUID                         = @RowGUID
				,@FileFormatSID                   = @FileFormatSID
				,@ApplicationEntitySID            = @ApplicationEntitySID
				,@FileName                        = @FileName
				,@LoadStartTime                   = @LoadStartTime
				,@LoadEndTime                     = @LoadEndTime
				,@IsFailed                        = @IsFailed
				,@MessageText                     = @MessageText
				,@ImportFileRowGUID               = @ImportFileRowGUID
				,@ProcessingStatusSCD             = @ProcessingStatusSCD
				,@ProcessingStatusLabel           = @ProcessingStatusLabel
				,@IsClosedStatus                  = @IsClosedStatus
				,@ProcessingStatusIsActive        = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault       = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID         = @ProcessingStatusRowGUID
				,@PersonEmailAddressPersonSID     = @PersonEmailAddressPersonSID
				,@PersonEmailAddressEmailAddress  = @PersonEmailAddressEmailAddress
				,@IsPrimary                       = @IsPrimary
				,@PersonEmailAddressIsActive      = @PersonEmailAddressIsActive
				,@PersonEmailAddressRowGUID       = @PersonEmailAddressRowGUID
				,@IsDeleteEnabled                 = @IsDeleteEnabled
				,@zContext                        = @zContext
				,@RegistrantLabel                 = @RegistrantLabel
		
		end

		update																																-- update "IsDeleted" column to trap audit information
			stg.RegistrantProfile
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantProfileSID = @RegistrantProfileSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				stg.RegistrantProfile
			where
				RegistrantProfileSID = @RegistrantProfileSID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from stg.RegistrantProfile where RegistrantProfileSID = @registrantProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'stg.RegistrantProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'stg.RegistrantProfile'
					,@Arg2        = @registrantProfileSID
				
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
				,@Arg2        = 'stg.RegistrantProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantProfileSID
			
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
				r.RoutineName = 'stg#pRegistrantProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantProfile
				 @Mode                            = 'delete.post'
				,@RegistrantProfileSID            = @RegistrantProfileSID
				,@UpdateUser                      = @UpdateUser
				,@RowStamp                        = @RowStamp
				,@ImportFileSID                   = @ImportFileSID
				,@ProcessingStatusSID             = @ProcessingStatusSID
				,@LastName                        = @LastName
				,@FirstName                       = @FirstName
				,@CommonName                      = @CommonName
				,@MiddleNames                     = @MiddleNames
				,@EmailAddress                    = @EmailAddress
				,@HomePhone                       = @HomePhone
				,@MobilePhone                     = @MobilePhone
				,@IsTextMessagingEnabled          = @IsTextMessagingEnabled
				,@GenderLabel                     = @GenderLabel
				,@NamePrefixLabel                 = @NamePrefixLabel
				,@BirthDate                       = @BirthDate
				,@DeathDate                       = @DeathDate
				,@UserName                        = @UserName
				,@SubDomain                       = @SubDomain
				,@Password                        = @Password
				,@StreetAddress1                  = @StreetAddress1
				,@StreetAddress2                  = @StreetAddress2
				,@StreetAddress3                  = @StreetAddress3
				,@CityName                        = @CityName
				,@StateProvinceName               = @StateProvinceName
				,@PostalCode                      = @PostalCode
				,@CountryName                     = @CountryName
				,@RegionLabel                     = @RegionLabel
				,@RegistrantNo                    = @RegistrantNo
				,@PersonGroupLabel1               = @PersonGroupLabel1
				,@PersonGroupTitle1               = @PersonGroupTitle1
				,@PersonGroupIsAdministrator1     = @PersonGroupIsAdministrator1
				,@PersonGroupEffectiveDate1       = @PersonGroupEffectiveDate1
				,@PersonGroupExpiryDate1          = @PersonGroupExpiryDate1
				,@PersonGroupLabel2               = @PersonGroupLabel2
				,@PersonGroupTitle2               = @PersonGroupTitle2
				,@PersonGroupIsAdministrator2     = @PersonGroupIsAdministrator2
				,@PersonGroupEffectiveDate2       = @PersonGroupEffectiveDate2
				,@PersonGroupExpiryDate2          = @PersonGroupExpiryDate2
				,@PersonGroupLabel3               = @PersonGroupLabel3
				,@PersonGroupTitle3               = @PersonGroupTitle3
				,@PersonGroupIsAdministrator3     = @PersonGroupIsAdministrator3
				,@PersonGroupEffectiveDate3       = @PersonGroupEffectiveDate3
				,@PersonGroupExpiryDate3          = @PersonGroupExpiryDate3
				,@PersonGroupLabel4               = @PersonGroupLabel4
				,@PersonGroupTitle4               = @PersonGroupTitle4
				,@PersonGroupIsAdministrator4     = @PersonGroupIsAdministrator4
				,@PersonGroupEffectiveDate4       = @PersonGroupEffectiveDate4
				,@PersonGroupExpiryDate4          = @PersonGroupExpiryDate4
				,@PersonGroupLabel5               = @PersonGroupLabel5
				,@PersonGroupTitle5               = @PersonGroupTitle5
				,@PersonGroupIsAdministrator5     = @PersonGroupIsAdministrator5
				,@PersonGroupEffectiveDate5       = @PersonGroupEffectiveDate5
				,@PersonGroupExpiryDate5          = @PersonGroupExpiryDate5
				,@PracticeRegisterLabel           = @PracticeRegisterLabel
				,@PracticeRegisterSectionLabel    = @PracticeRegisterSectionLabel
				,@RegistrationEffectiveDate       = @RegistrationEffectiveDate
				,@QualifyingCredentialLabel       = @QualifyingCredentialLabel
				,@QualifyingCredentialOrgLabel    = @QualifyingCredentialOrgLabel
				,@QualifyingProgramName           = @QualifyingProgramName
				,@QualifyingProgramStartDate      = @QualifyingProgramStartDate
				,@QualifyingProgramCompletionDate = @QualifyingProgramCompletionDate
				,@QualifyingFieldOfStudyName      = @QualifyingFieldOfStudyName
				,@CredentialLabel1                = @CredentialLabel1
				,@CredentialOrgLabel1             = @CredentialOrgLabel1
				,@CredentialProgramName1          = @CredentialProgramName1
				,@CredentialFieldOfStudyName1     = @CredentialFieldOfStudyName1
				,@CredentialEffectiveDate1        = @CredentialEffectiveDate1
				,@CredentialExpiryDate1           = @CredentialExpiryDate1
				,@CredentialLabel2                = @CredentialLabel2
				,@CredentialOrgLabel2             = @CredentialOrgLabel2
				,@CredentialProgramName2          = @CredentialProgramName2
				,@CredentialFieldOfStudyName2     = @CredentialFieldOfStudyName2
				,@CredentialEffectiveDate2        = @CredentialEffectiveDate2
				,@CredentialExpiryDate2           = @CredentialExpiryDate2
				,@CredentialLabel3                = @CredentialLabel3
				,@CredentialOrgLabel3             = @CredentialOrgLabel3
				,@CredentialProgramName3          = @CredentialProgramName3
				,@CredentialFieldOfStudyName3     = @CredentialFieldOfStudyName3
				,@CredentialEffectiveDate3        = @CredentialEffectiveDate3
				,@CredentialExpiryDate3           = @CredentialExpiryDate3
				,@CredentialLabel4                = @CredentialLabel4
				,@CredentialOrgLabel4             = @CredentialOrgLabel4
				,@CredentialProgramName4          = @CredentialProgramName4
				,@CredentialFieldOfStudyName4     = @CredentialFieldOfStudyName4
				,@CredentialEffectiveDate4        = @CredentialEffectiveDate4
				,@CredentialExpiryDate4           = @CredentialExpiryDate4
				,@CredentialLabel5                = @CredentialLabel5
				,@CredentialOrgLabel5             = @CredentialOrgLabel5
				,@CredentialProgramName5          = @CredentialProgramName5
				,@CredentialFieldOfStudyName5     = @CredentialFieldOfStudyName5
				,@CredentialEffectiveDate5        = @CredentialEffectiveDate5
				,@CredentialExpiryDate5           = @CredentialExpiryDate5
				,@CredentialLabel6                = @CredentialLabel6
				,@CredentialOrgLabel6             = @CredentialOrgLabel6
				,@CredentialProgramName6          = @CredentialProgramName6
				,@CredentialFieldOfStudyName6     = @CredentialFieldOfStudyName6
				,@CredentialEffectiveDate6        = @CredentialEffectiveDate6
				,@CredentialExpiryDate6           = @CredentialExpiryDate6
				,@CredentialLabel7                = @CredentialLabel7
				,@CredentialOrgLabel7             = @CredentialOrgLabel7
				,@CredentialProgramName7          = @CredentialProgramName7
				,@CredentialFieldOfStudyName7     = @CredentialFieldOfStudyName7
				,@CredentialEffectiveDate7        = @CredentialEffectiveDate7
				,@CredentialExpiryDate7           = @CredentialExpiryDate7
				,@CredentialLabel8                = @CredentialLabel8
				,@CredentialOrgLabel8             = @CredentialOrgLabel8
				,@CredentialProgramName8          = @CredentialProgramName8
				,@CredentialFieldOfStudyName8     = @CredentialFieldOfStudyName8
				,@CredentialEffectiveDate8        = @CredentialEffectiveDate8
				,@CredentialExpiryDate8           = @CredentialExpiryDate8
				,@CredentialLabel9                = @CredentialLabel9
				,@CredentialOrgLabel9             = @CredentialOrgLabel9
				,@CredentialProgramName9          = @CredentialProgramName9
				,@CredentialFieldOfStudyName9     = @CredentialFieldOfStudyName9
				,@CredentialEffectiveDate9        = @CredentialEffectiveDate9
				,@CredentialExpiryDate9           = @CredentialExpiryDate9
				,@PersonSID                       = @PersonSID
				,@PersonEmailAddressSID           = @PersonEmailAddressSID
				,@ApplicationUserSID              = @ApplicationUserSID
				,@PersonMailingAddressSID         = @PersonMailingAddressSID
				,@RegionSID                       = @RegionSID
				,@NamePrefixSID                   = @NamePrefixSID
				,@GenderSID                       = @GenderSID
				,@CitySID                         = @CitySID
				,@StateProvinceSID                = @StateProvinceSID
				,@CountrySID                      = @CountrySID
				,@RegistrantSID                   = @RegistrantSID
				,@ProcessingComments              = @ProcessingComments
				,@UserDefinedColumns              = @UserDefinedColumns
				,@RegistrantProfileXID            = @RegistrantProfileXID
				,@LegacyKey                       = @LegacyKey
				,@IsDeleted                       = @IsDeleted
				,@CreateUser                      = @CreateUser
				,@CreateTime                      = @CreateTime
				,@UpdateTime                      = @UpdateTime
				,@RowGUID                         = @RowGUID
				,@FileFormatSID                   = @FileFormatSID
				,@ApplicationEntitySID            = @ApplicationEntitySID
				,@FileName                        = @FileName
				,@LoadStartTime                   = @LoadStartTime
				,@LoadEndTime                     = @LoadEndTime
				,@IsFailed                        = @IsFailed
				,@MessageText                     = @MessageText
				,@ImportFileRowGUID               = @ImportFileRowGUID
				,@ProcessingStatusSCD             = @ProcessingStatusSCD
				,@ProcessingStatusLabel           = @ProcessingStatusLabel
				,@IsClosedStatus                  = @IsClosedStatus
				,@ProcessingStatusIsActive        = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault       = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID         = @ProcessingStatusRowGUID
				,@PersonEmailAddressPersonSID     = @PersonEmailAddressPersonSID
				,@PersonEmailAddressEmailAddress  = @PersonEmailAddressEmailAddress
				,@IsPrimary                       = @IsPrimary
				,@PersonEmailAddressIsActive      = @PersonEmailAddressIsActive
				,@PersonEmailAddressRowGUID       = @PersonEmailAddressRowGUID
				,@IsDeleteEnabled                 = @IsDeleteEnabled
				,@zContext                        = @zContext
				,@RegistrantLabel                 = @RegistrantLabel
		
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
