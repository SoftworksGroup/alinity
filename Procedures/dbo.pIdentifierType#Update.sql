SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pIdentifierType#Update]
	 @IdentifierTypeSID              int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@OrgSID                         int               = null -- table column values to update:
	,@IdentifierTypeLabel            nvarchar(35)      = null
	,@IdentifierTypeCategory         nvarchar(65)      = null
	,@IsOtherRegistration            bit               = null
	,@DisplayRank                    tinyint           = null
	,@EditMask                       varchar(50)       = null
	,@IdentifierCode                 varchar(15)       = null
	,@IsDefault                      bit               = null
	,@UserDefinedColumns             xml               = null
	,@IdentifierTypeXID              varchar(150)      = null
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
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@OrgTypeCode                    varchar(20)       = null -- not a base table column
	,@OrgTypeName                    nvarchar(50)      = null -- not a base table column
	,@OrgTypeCategory                nvarchar(65)      = null -- not a base table column
	,@OrgTypeIsDefault               bit               = null -- not a base table column
	,@OrgCitySID                     int               = null -- not a base table column
	,@OrgCityName                    nvarchar(30)      = null -- not a base table column
	,@OrgCountrySID                  int               = null -- not a base table column
	,@OrgCountryName                 nvarchar(50)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pIdentifierType#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.IdentifierType table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.IdentifierType table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vIdentifierType entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pIdentifierType procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fIdentifierTypeCheck to test all rules.

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

		if @IdentifierTypeSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@IdentifierTypeSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @IdentifierTypeLabel = ltrim(rtrim(@IdentifierTypeLabel))
		set @IdentifierTypeCategory = ltrim(rtrim(@IdentifierTypeCategory))
		set @EditMask = ltrim(rtrim(@EditMask))
		set @IdentifierCode = ltrim(rtrim(@IdentifierCode))
		set @IdentifierTypeXID = ltrim(rtrim(@IdentifierTypeXID))
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
		set @OrgTypeCode = ltrim(rtrim(@OrgTypeCode))
		set @OrgTypeName = ltrim(rtrim(@OrgTypeName))
		set @OrgTypeCategory = ltrim(rtrim(@OrgTypeCategory))
		set @OrgCityName = ltrim(rtrim(@OrgCityName))
		set @OrgCountryName = ltrim(rtrim(@OrgCountryName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@IdentifierTypeLabel) = 0 set @IdentifierTypeLabel = null
		if len(@IdentifierTypeCategory) = 0 set @IdentifierTypeCategory = null
		if len(@EditMask) = 0 set @EditMask = null
		if len(@IdentifierCode) = 0 set @IdentifierCode = null
		if len(@IdentifierTypeXID) = 0 set @IdentifierTypeXID = null
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
		if len(@OrgTypeCode) = 0 set @OrgTypeCode = null
		if len(@OrgTypeName) = 0 set @OrgTypeName = null
		if len(@OrgTypeCategory) = 0 set @OrgTypeCategory = null
		if len(@OrgCityName) = 0 set @OrgCityName = null
		if len(@OrgCountryName) = 0 set @OrgCountryName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @OrgSID                         = isnull(@OrgSID,itype.OrgSID)
				,@IdentifierTypeLabel            = isnull(@IdentifierTypeLabel,itype.IdentifierTypeLabel)
				,@IdentifierTypeCategory         = isnull(@IdentifierTypeCategory,itype.IdentifierTypeCategory)
				,@IsOtherRegistration            = isnull(@IsOtherRegistration,itype.IsOtherRegistration)
				,@DisplayRank                    = isnull(@DisplayRank,itype.DisplayRank)
				,@EditMask                       = isnull(@EditMask,itype.EditMask)
				,@IdentifierCode                 = isnull(@IdentifierCode,itype.IdentifierCode)
				,@IsDefault                      = isnull(@IsDefault,itype.IsDefault)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,itype.UserDefinedColumns)
				,@IdentifierTypeXID              = isnull(@IdentifierTypeXID,itype.IdentifierTypeXID)
				,@LegacyKey                      = isnull(@LegacyKey,itype.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,itype.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,itype.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,itype.IsNullApplied)
				,@zContext                       = isnull(@zContext,itype.zContext)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,itype.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,itype.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,itype.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,itype.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,itype.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,itype.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,itype.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,itype.CitySID)
				,@PostalCode                     = isnull(@PostalCode,itype.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,itype.RegionSID)
				,@Phone                          = isnull(@Phone,itype.Phone)
				,@Fax                            = isnull(@Fax,itype.Fax)
				,@WebSite                        = isnull(@WebSite,itype.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,itype.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,itype.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,itype.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,itype.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,itype.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,itype.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,itype.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,itype.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,itype.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,itype.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,itype.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,itype.LastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,itype.OrgRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,itype.IsDeleteEnabled)
				,@OrgTypeCode                    = isnull(@OrgTypeCode,itype.OrgTypeCode)
				,@OrgTypeName                    = isnull(@OrgTypeName,itype.OrgTypeName)
				,@OrgTypeCategory                = isnull(@OrgTypeCategory,itype.OrgTypeCategory)
				,@OrgTypeIsDefault               = isnull(@OrgTypeIsDefault,itype.OrgTypeIsDefault)
				,@OrgCitySID                     = isnull(@OrgCitySID,itype.OrgCitySID)
				,@OrgCityName                    = isnull(@OrgCityName,itype.OrgCityName)
				,@OrgCountrySID                  = isnull(@OrgCountrySID,itype.OrgCountrySID)
				,@OrgCountryName                 = isnull(@OrgCountryName,itype.OrgCountryName)
			from
				dbo.vIdentifierType itype
			where
				itype.IdentifierTypeSID = @IdentifierTypeSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.OrgSID from dbo.IdentifierType x where x.IdentifierTypeSID = @IdentifierTypeSID) <> @OrgSID
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
		
		-- unset previous default if record is being marked as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.IdentifierTypeSID from dbo.IdentifierType x where x.IsDefault = @ON and x.IdentifierTypeSID <> @IdentifierTypeSID
			
			if @recordSID is not null
			begin
			
				update
					dbo.IdentifierType
				set
					 IsDefault  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					IdentifierTypeSID = @recordSID																	-- unique index ensures only 1 record needs to be unset
				
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
				r.RoutineName = 'pIdentifierType'
		)
		begin
		
			exec @errorNo = ext.pIdentifierType
				 @Mode                           = 'update.pre'
				,@IdentifierTypeSID              = @IdentifierTypeSID
				,@OrgSID                         = @OrgSID output
				,@IdentifierTypeLabel            = @IdentifierTypeLabel output
				,@IdentifierTypeCategory         = @IdentifierTypeCategory output
				,@IsOtherRegistration            = @IsOtherRegistration output
				,@DisplayRank                    = @DisplayRank output
				,@EditMask                       = @EditMask output
				,@IdentifierCode                 = @IdentifierCode output
				,@IsDefault                      = @IsDefault output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@IdentifierTypeXID              = @IdentifierTypeXID output
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
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@OrgTypeCode                    = @OrgTypeCode
				,@OrgTypeName                    = @OrgTypeName
				,@OrgTypeCategory                = @OrgTypeCategory
				,@OrgTypeIsDefault               = @OrgTypeIsDefault
				,@OrgCitySID                     = @OrgCitySID
				,@OrgCityName                    = @OrgCityName
				,@OrgCountrySID                  = @OrgCountrySID
				,@OrgCountryName                 = @OrgCountryName
		
		end

		-- update the record

		update
			dbo.IdentifierType
		set
			 OrgSID = @OrgSID
			,IdentifierTypeLabel = @IdentifierTypeLabel
			,IdentifierTypeCategory = @IdentifierTypeCategory
			,IsOtherRegistration = @IsOtherRegistration
			,DisplayRank = @DisplayRank
			,EditMask = @EditMask
			,IdentifierCode = @IdentifierCode
			,IsDefault = @IsDefault
			,UserDefinedColumns = @UserDefinedColumns
			,IdentifierTypeXID = @IdentifierTypeXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			IdentifierTypeSID = @IdentifierTypeSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.IdentifierType where IdentifierTypeSID = @identifierTypeSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.IdentifierType'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.IdentifierType'
					,@Arg2        = @identifierTypeSID
				
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
				,@Arg2        = 'dbo.IdentifierType'
				,@Arg3        = @rowsAffected
				,@Arg4        = @identifierTypeSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
		
		-- ensure a default record is identified on the table
		
		if not exists
		(
			select 1 from	dbo.IdentifierType x where x.IsDefault = @ON
		)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'MissingDefault'
				,@MessageText = @errorText output
				,@DefaultText = N'A default %1 record is required by the application. (Setting another record as the new default automatically un-sets the previous one.)'
				,@Arg1        = 'Identifier Type'
			
			raiserror(@errorText, 16, 1)
		end
	
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
				r.RoutineName = 'pIdentifierType'
		)
		begin
		
			exec @errorNo = ext.pIdentifierType
				 @Mode                           = 'update.post'
				,@IdentifierTypeSID              = @IdentifierTypeSID
				,@OrgSID                         = @OrgSID
				,@IdentifierTypeLabel            = @IdentifierTypeLabel
				,@IdentifierTypeCategory         = @IdentifierTypeCategory
				,@IsOtherRegistration            = @IsOtherRegistration
				,@DisplayRank                    = @DisplayRank
				,@EditMask                       = @EditMask
				,@IdentifierCode                 = @IdentifierCode
				,@IsDefault                      = @IsDefault
				,@UserDefinedColumns             = @UserDefinedColumns
				,@IdentifierTypeXID              = @IdentifierTypeXID
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
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@OrgTypeCode                    = @OrgTypeCode
				,@OrgTypeName                    = @OrgTypeName
				,@OrgTypeCategory                = @OrgTypeCategory
				,@OrgTypeIsDefault               = @OrgTypeIsDefault
				,@OrgCitySID                     = @OrgCitySID
				,@OrgCityName                    = @OrgCityName
				,@OrgCountrySID                  = @OrgCountrySID
				,@OrgCountryName                 = @OrgCountryName
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.IdentifierTypeSID
			from
				dbo.vIdentifierType ent
			where
				ent.IdentifierTypeSID = @IdentifierTypeSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.IdentifierTypeSID
				,ent.OrgSID
				,ent.IdentifierTypeLabel
				,ent.IdentifierTypeCategory
				,ent.IsOtherRegistration
				,ent.DisplayRank
				,ent.EditMask
				,ent.IdentifierCode
				,ent.IsDefault
				,ent.UserDefinedColumns
				,ent.IdentifierTypeXID
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
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.OrgTypeCode
				,ent.OrgTypeName
				,ent.OrgTypeCategory
				,ent.OrgTypeIsDefault
				,ent.OrgCitySID
				,ent.OrgCityName
				,ent.OrgCountrySID
				,ent.OrgCountryName
			from
				dbo.vIdentifierType ent
			where
				ent.IdentifierTypeSID = @IdentifierTypeSID

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
