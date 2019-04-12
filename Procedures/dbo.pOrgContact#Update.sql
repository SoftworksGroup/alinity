SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrgContact#Update]
	 @OrgContactSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@OrgSID                         int               = null -- table column values to update:
	,@PersonSID                      int               = null
	,@EffectiveTime                  datetime          = null
	,@ExpiryTime                     datetime          = null
	,@IsReviewAdmin                  bit               = null
	,@Title                          nvarchar(65)      = null
	,@DirectPhone                    varchar(25)       = null
	,@IsAdminContact                 bit               = null
	,@OwnershipPercentage            smallint          = null
	,@TagList                        xml               = null
	,@ChangeLog                      xml               = null
	,@UserDefinedColumns             xml               = null
	,@OrgContactXID                  varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
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
	,@IsActive                       bit               = null -- not a base table column
	,@IsPending                      bit               = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsOwner                        bit               = null -- not a base table column
	,@RegistrantEmploymentSID        int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pOrgContact#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.OrgContact table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.OrgContact table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vOrgContact entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pOrgContact procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fOrgContactCheck to test all rules.

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

		if @OrgContactSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@OrgContactSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @Title = ltrim(rtrim(@Title))
		set @DirectPhone = ltrim(rtrim(@DirectPhone))
		set @OrgContactXID = ltrim(rtrim(@OrgContactXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))

		-- set zero length strings to null to avoid storing them in the record

		if len(@Title) = 0 set @Title = null
		if len(@DirectPhone) = 0 set @DirectPhone = null
		if len(@OrgContactXID) = 0 set @OrgContactXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
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
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @OrgSID                         = isnull(@OrgSID,oc.OrgSID)
				,@PersonSID                      = isnull(@PersonSID,oc.PersonSID)
				,@EffectiveTime                  = isnull(@EffectiveTime,oc.EffectiveTime)
				,@ExpiryTime                     = isnull(@ExpiryTime,oc.ExpiryTime)
				,@IsReviewAdmin                  = isnull(@IsReviewAdmin,oc.IsReviewAdmin)
				,@Title                          = isnull(@Title,oc.Title)
				,@DirectPhone                    = isnull(@DirectPhone,oc.DirectPhone)
				,@IsAdminContact                 = isnull(@IsAdminContact,oc.IsAdminContact)
				,@OwnershipPercentage            = isnull(@OwnershipPercentage,oc.OwnershipPercentage)
				,@TagList                        = isnull(@TagList,oc.TagList)
				,@ChangeLog                      = isnull(@ChangeLog,oc.ChangeLog)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,oc.UserDefinedColumns)
				,@OrgContactXID                  = isnull(@OrgContactXID,oc.OrgContactXID)
				,@LegacyKey                      = isnull(@LegacyKey,oc.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,oc.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,oc.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,oc.IsNullApplied)
				,@zContext                       = isnull(@zContext,oc.zContext)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,oc.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,oc.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,oc.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,oc.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,oc.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,oc.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,oc.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,oc.CitySID)
				,@PostalCode                     = isnull(@PostalCode,oc.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,oc.RegionSID)
				,@Phone                          = isnull(@Phone,oc.Phone)
				,@Fax                            = isnull(@Fax,oc.Fax)
				,@WebSite                        = isnull(@WebSite,oc.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,oc.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,oc.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,oc.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,oc.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,oc.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,oc.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,oc.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,oc.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,oc.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,oc.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,oc.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,oc.LastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,oc.OrgRowGUID)
				,@GenderSID                      = isnull(@GenderSID,oc.GenderSID)
				,@NamePrefixSID                  = isnull(@NamePrefixSID,oc.NamePrefixSID)
				,@FirstName                      = isnull(@FirstName,oc.FirstName)
				,@CommonName                     = isnull(@CommonName,oc.CommonName)
				,@MiddleNames                    = isnull(@MiddleNames,oc.MiddleNames)
				,@LastName                       = isnull(@LastName,oc.LastName)
				,@BirthDate                      = isnull(@BirthDate,oc.BirthDate)
				,@DeathDate                      = isnull(@DeathDate,oc.DeathDate)
				,@HomePhone                      = isnull(@HomePhone,oc.HomePhone)
				,@MobilePhone                    = isnull(@MobilePhone,oc.MobilePhone)
				,@IsTextMessagingEnabled         = isnull(@IsTextMessagingEnabled,oc.IsTextMessagingEnabled)
				,@ImportBatch                    = isnull(@ImportBatch,oc.ImportBatch)
				,@PersonRowGUID                  = isnull(@PersonRowGUID,oc.PersonRowGUID)
				,@IsActive                       = isnull(@IsActive,oc.IsActive)
				,@IsPending                      = isnull(@IsPending,oc.IsPending)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,oc.IsDeleteEnabled)
				,@IsOwner                        = isnull(@IsOwner,oc.IsOwner)
				,@RegistrantEmploymentSID        = isnull(@RegistrantEmploymentSID,oc.RegistrantEmploymentSID)
			from
				dbo.vOrgContact oc
			where
				oc.OrgContactSID = @OrgContactSID

		end
		
		set @DirectPhone = sf.fFormatPhone(@DirectPhone)											-- format phone numbers to standard
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the new tags applied (if any)

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.OrgSID from dbo.OrgContact x where x.OrgContactSID = @OrgContactSID) <> @OrgSID
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
				r.RoutineName = 'pOrgContact'
		)
		begin
		
			exec @errorNo = ext.pOrgContact
				 @Mode                           = 'update.pre'
				,@OrgContactSID                  = @OrgContactSID
				,@OrgSID                         = @OrgSID output
				,@PersonSID                      = @PersonSID output
				,@EffectiveTime                  = @EffectiveTime output
				,@ExpiryTime                     = @ExpiryTime output
				,@IsReviewAdmin                  = @IsReviewAdmin output
				,@Title                          = @Title output
				,@DirectPhone                    = @DirectPhone output
				,@IsAdminContact                 = @IsAdminContact output
				,@OwnershipPercentage            = @OwnershipPercentage output
				,@TagList                        = @TagList output
				,@ChangeLog                      = @ChangeLog output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@OrgContactXID                  = @OrgContactXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
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
				,@IsActive                       = @IsActive
				,@IsPending                      = @IsPending
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsOwner                        = @IsOwner
				,@RegistrantEmploymentSID        = @RegistrantEmploymentSID
		
		end

		-- update the record

		update
			dbo.OrgContact
		set
			 OrgSID = @OrgSID
			,PersonSID = @PersonSID
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,IsReviewAdmin = @IsReviewAdmin
			,Title = @Title
			,DirectPhone = @DirectPhone
			,IsAdminContact = @IsAdminContact
			,OwnershipPercentage = @OwnershipPercentage
			,TagList = @TagList
			,ChangeLog = @ChangeLog
			,UserDefinedColumns = @UserDefinedColumns
			,OrgContactXID = @OrgContactXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			OrgContactSID = @OrgContactSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.OrgContact where OrgContactSID = @orgContactSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.OrgContact'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.OrgContact'
					,@Arg2        = @orgContactSID
				
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
				,@Arg2        = 'dbo.OrgContact'
				,@Arg3        = @rowsAffected
				,@Arg4        = @orgContactSID
			
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
				r.RoutineName = 'pOrgContact'
		)
		begin
		
			exec @errorNo = ext.pOrgContact
				 @Mode                           = 'update.post'
				,@OrgContactSID                  = @OrgContactSID
				,@OrgSID                         = @OrgSID
				,@PersonSID                      = @PersonSID
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@IsReviewAdmin                  = @IsReviewAdmin
				,@Title                          = @Title
				,@DirectPhone                    = @DirectPhone
				,@IsAdminContact                 = @IsAdminContact
				,@OwnershipPercentage            = @OwnershipPercentage
				,@TagList                        = @TagList
				,@ChangeLog                      = @ChangeLog
				,@UserDefinedColumns             = @UserDefinedColumns
				,@OrgContactXID                  = @OrgContactXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
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
				,@IsActive                       = @IsActive
				,@IsPending                      = @IsPending
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsOwner                        = @IsOwner
				,@RegistrantEmploymentSID        = @RegistrantEmploymentSID
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.OrgContactSID
			from
				dbo.vOrgContact ent
			where
				ent.OrgContactSID = @OrgContactSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.OrgContactSID
				,ent.OrgSID
				,ent.PersonSID
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsReviewAdmin
				,ent.Title
				,ent.DirectPhone
				,ent.IsAdminContact
				,ent.OwnershipPercentage
				,ent.TagList
				,ent.ChangeLog
				,ent.UserDefinedColumns
				,ent.OrgContactXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
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
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsOwner
				,ent.RegistrantEmploymentSID
			from
				dbo.vOrgContact ent
			where
				ent.OrgContactSID = @OrgContactSID

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
