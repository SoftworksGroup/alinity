SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pIdentifierType#Insert]
	 @IdentifierTypeSID              int               = null output				-- identity value assigned to the new record
	,@OrgSID                         int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@IdentifierTypeLabel            nvarchar(35)      = null								-- required! if not passed value must be set in custom logic prior to insert
	,@IdentifierTypeCategory         nvarchar(65)      = null								
	,@IsOtherRegistration            bit               = null								-- default: CONVERT(bit,(1))
	,@DisplayRank                    tinyint           = null								-- default: (5)
	,@EditMask                       varchar(50)       = null								-- required! if not passed value must be set in custom logic prior to insert
	,@IdentifierCode                 varchar(15)       = null								-- required! if not passed value must be set in custom logic prior to insert
	,@IsDefault                      bit               = null								-- default: (0)
	,@UserDefinedColumns             xml               = null								
	,@IdentifierTypeXID              varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
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
	,@InsurancePolicyNo              varchar(25)       = null								-- not a base table column (default ignored)
	,@InsuranceAmount                decimal(11,2)     = null								-- not a base table column (default ignored)
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
	,@OrgTypeCode                    varchar(20)       = null								-- not a base table column (default ignored)
	,@OrgTypeName                    nvarchar(50)      = null								-- not a base table column (default ignored)
	,@OrgTypeCategory                nvarchar(65)      = null								-- not a base table column (default ignored)
	,@OrgTypeIsDefault               bit               = null								-- not a base table column (default ignored)
	,@OrgCitySID                     int               = null								-- not a base table column (default ignored)
	,@OrgCityName                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@OrgCountrySID                  int               = null								-- not a base table column (default ignored)
	,@OrgCountryName                 nvarchar(50)      = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pIdentifierType#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.IdentifierType table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.IdentifierType table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vIdentifierType entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pIdentifierType procedure. The extended procedure is only called
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

	set @IdentifierTypeSID = null																						-- initialize output parameter

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

		set @IdentifierTypeLabel = ltrim(rtrim(@IdentifierTypeLabel))
		set @IdentifierTypeCategory = ltrim(rtrim(@IdentifierTypeCategory))
		set @EditMask = ltrim(rtrim(@EditMask))
		set @IdentifierCode = ltrim(rtrim(@IdentifierCode))
		set @IdentifierTypeXID = ltrim(rtrim(@IdentifierTypeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsOtherRegistration = isnull(@IsOtherRegistration,CONVERT(bit,(1)))
		set @DisplayRank = isnull(@DisplayRank,(5))
		set @IsDefault = isnull(@IsDefault,(0))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected           = isnull(@IsReselected          ,(0))
		
		-- unset previous default if record is being inserted as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.IdentifierTypeSID from dbo.IdentifierType x where x.IsDefault = @ON
			
			if @recordSID is not null
			begin
			
				update
					dbo.IdentifierType
				set
					 IsDefault  = @OFF
					,UpdateUser = @CreateUser
					,UpdateTime = sysdatetimeoffset()
				where
					IdentifierTypeSID = @recordSID																	-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
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
				r.RoutineName = 'pIdentifierType'
		)
		begin
		
			exec @errorNo = ext.pIdentifierType
				 @Mode                           = 'insert.pre'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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

		-- insert the record

		insert
			dbo.IdentifierType
		(
			 OrgSID
			,IdentifierTypeLabel
			,IdentifierTypeCategory
			,IsOtherRegistration
			,DisplayRank
			,EditMask
			,IdentifierCode
			,IsDefault
			,UserDefinedColumns
			,IdentifierTypeXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @OrgSID
			,@IdentifierTypeLabel
			,@IdentifierTypeCategory
			,@IsOtherRegistration
			,@DisplayRank
			,@EditMask
			,@IdentifierCode
			,@IsDefault
			,@UserDefinedColumns
			,@IdentifierTypeXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected      = @@rowcount
			,@IdentifierTypeSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.IdentifierType'
				,@Arg3        = @rowsAffected
				,@Arg4        = @IdentifierTypeSID
			
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
				r.RoutineName = 'pIdentifierType'
		)
		begin
		
			exec @errorNo = ext.pIdentifierType
				 @Mode                           = 'insert.post'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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
