SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pQualifyingCredentialOrg#Update]
	 @QualifyingCredentialOrgSID     int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@CredentialSID                  int               = null -- table column values to update:
	,@OrgSID                         int               = null
	,@IsActive                       bit               = null
	,@UserDefinedColumns             xml               = null
	,@QualifyingCredentialOrgXID     varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@CredentialTypeSID              int               = null -- not a base table column
	,@CredentialLabel                nvarchar(35)      = null -- not a base table column
	,@ToolTip                        nvarchar(500)     = null -- not a base table column
	,@IsRelatedToProfession          bit               = null -- not a base table column
	,@IsProgramRequired              bit               = null -- not a base table column
	,@IsSpecialization               bit               = null -- not a base table column
	,@CredentialIsActive             bit               = null -- not a base table column
	,@CredentialCode                 varchar(15)       = null -- not a base table column
	,@CredentialRowGUID              uniqueidentifier  = null -- not a base table column
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
as
/*********************************************************************************************************************************
Procedure : dbo.pQualifyingCredentialOrg#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.QualifyingCredentialOrg table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.QualifyingCredentialOrg table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vQualifyingCredentialOrg entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pQualifyingCredentialOrg procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fQualifyingCredentialOrgCheck to test all rules.

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

		if @QualifyingCredentialOrgSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@QualifyingCredentialOrgSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @QualifyingCredentialOrgXID = ltrim(rtrim(@QualifyingCredentialOrgXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @CredentialLabel = ltrim(rtrim(@CredentialLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @CredentialCode = ltrim(rtrim(@CredentialCode))
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

		if len(@QualifyingCredentialOrgXID) = 0 set @QualifyingCredentialOrgXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@CredentialLabel) = 0 set @CredentialLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@CredentialCode) = 0 set @CredentialCode = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @CredentialSID                  = isnull(@CredentialSID,qco.CredentialSID)
				,@OrgSID                         = isnull(@OrgSID,qco.OrgSID)
				,@IsActive                       = isnull(@IsActive,qco.IsActive)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,qco.UserDefinedColumns)
				,@QualifyingCredentialOrgXID     = isnull(@QualifyingCredentialOrgXID,qco.QualifyingCredentialOrgXID)
				,@LegacyKey                      = isnull(@LegacyKey,qco.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,qco.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,qco.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,qco.IsNullApplied)
				,@zContext                       = isnull(@zContext,qco.zContext)
				,@CredentialTypeSID              = isnull(@CredentialTypeSID,qco.CredentialTypeSID)
				,@CredentialLabel                = isnull(@CredentialLabel,qco.CredentialLabel)
				,@ToolTip                        = isnull(@ToolTip,qco.ToolTip)
				,@IsRelatedToProfession          = isnull(@IsRelatedToProfession,qco.IsRelatedToProfession)
				,@IsProgramRequired              = isnull(@IsProgramRequired,qco.IsProgramRequired)
				,@IsSpecialization               = isnull(@IsSpecialization,qco.IsSpecialization)
				,@CredentialIsActive             = isnull(@CredentialIsActive,qco.CredentialIsActive)
				,@CredentialCode                 = isnull(@CredentialCode,qco.CredentialCode)
				,@CredentialRowGUID              = isnull(@CredentialRowGUID,qco.CredentialRowGUID)
				,@ParentOrgSID                   = isnull(@ParentOrgSID,qco.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,qco.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,qco.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,qco.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,qco.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,qco.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,qco.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,qco.CitySID)
				,@PostalCode                     = isnull(@PostalCode,qco.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,qco.RegionSID)
				,@Phone                          = isnull(@Phone,qco.Phone)
				,@Fax                            = isnull(@Fax,qco.Fax)
				,@WebSite                        = isnull(@WebSite,qco.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,qco.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,qco.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,qco.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,qco.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,qco.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,qco.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,qco.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,qco.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,qco.IsPublic)
				,@OrgIsActive                    = isnull(@OrgIsActive,qco.OrgIsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,qco.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,qco.LastVerifiedTime)
				,@OrgRowGUID                     = isnull(@OrgRowGUID,qco.OrgRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,qco.IsDeleteEnabled)
			from
				dbo.vQualifyingCredentialOrg qco
			where
				qco.QualifyingCredentialOrgSID = @QualifyingCredentialOrgSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.CredentialSID from dbo.QualifyingCredentialOrg x where x.QualifyingCredentialOrgSID = @QualifyingCredentialOrgSID) <> @CredentialSID
		begin
			if (select x.IsActive from dbo.Credential x where x.CredentialSID = @CredentialSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'credential'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.OrgSID from dbo.QualifyingCredentialOrg x where x.QualifyingCredentialOrgSID = @QualifyingCredentialOrgSID) <> @OrgSID
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
				r.RoutineName = 'pQualifyingCredentialOrg'
		)
		begin
		
			exec @errorNo = ext.pQualifyingCredentialOrg
				 @Mode                           = 'update.pre'
				,@QualifyingCredentialOrgSID     = @QualifyingCredentialOrgSID
				,@CredentialSID                  = @CredentialSID output
				,@OrgSID                         = @OrgSID output
				,@IsActive                       = @IsActive output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@QualifyingCredentialOrgXID     = @QualifyingCredentialOrgXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
		
		end

		-- update the record

		update
			dbo.QualifyingCredentialOrg
		set
			 CredentialSID = @CredentialSID
			,OrgSID = @OrgSID
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,QualifyingCredentialOrgXID = @QualifyingCredentialOrgXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			QualifyingCredentialOrgSID = @QualifyingCredentialOrgSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.QualifyingCredentialOrg where QualifyingCredentialOrgSID = @qualifyingCredentialOrgSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.QualifyingCredentialOrg'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.QualifyingCredentialOrg'
					,@Arg2        = @qualifyingCredentialOrgSID
				
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
				,@Arg2        = 'dbo.QualifyingCredentialOrg'
				,@Arg3        = @rowsAffected
				,@Arg4        = @qualifyingCredentialOrgSID
			
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
				r.RoutineName = 'pQualifyingCredentialOrg'
		)
		begin
		
			exec @errorNo = ext.pQualifyingCredentialOrg
				 @Mode                           = 'update.post'
				,@QualifyingCredentialOrgSID     = @QualifyingCredentialOrgSID
				,@CredentialSID                  = @CredentialSID
				,@OrgSID                         = @OrgSID
				,@IsActive                       = @IsActive
				,@UserDefinedColumns             = @UserDefinedColumns
				,@QualifyingCredentialOrgXID     = @QualifyingCredentialOrgXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.QualifyingCredentialOrgSID
			from
				dbo.vQualifyingCredentialOrg ent
			where
				ent.QualifyingCredentialOrgSID = @QualifyingCredentialOrgSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.QualifyingCredentialOrgSID
				,ent.CredentialSID
				,ent.OrgSID
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.QualifyingCredentialOrgXID
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
			from
				dbo.vQualifyingCredentialOrg ent
			where
				ent.QualifyingCredentialOrgSID = @QualifyingCredentialOrgSID

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