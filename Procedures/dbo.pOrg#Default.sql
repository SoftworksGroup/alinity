SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrg#Default]
	 @zContext                       xml               = null                       -- default values provided from client-tier (if any)
	,@SetFKDefaults                  bit               = 0                          -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pOrg#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.Org records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Org table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vOrg entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pOrg
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pOrg of the context of the call. All other parameters are also passed, however, only those parameters eligible
for default setting are passed for "output". All parameters corresponding to entity view columns are returned through a SELECT statement.

In order to simplify working with the XML parameter values, logic in the procedure parses the XML and assigns values to variables where
the variable name matches the column name in the XML (assumes single row).  The variables are then available to the table-specific and
client-specific logic.  The @zContext parameter is also passed, unmodified, to the extended procedure to support situations where values
are passed that are not mapped to column names.


-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@ON                             bit = cast(1 as bit)									-- constant for bit comparisons
		,@OFF                            bit = cast(0 as bit)									-- constant for bit comparisons
		,@orgSID                         int               = -1								-- specific default required by EF - do not override
		,@parentOrgSID                   int               = null							-- no default provided from DB constraint - OK to override
		,@orgTypeSID                     int               = null							-- no default provided from DB constraint - OK to override
		,@orgName                        nvarchar(150)     = null							-- no default provided from DB constraint - OK to override
		,@orgLabel                       nvarchar(35)      = null							-- no default provided from DB constraint - OK to override
		,@streetAddress1                 nvarchar(75)      = null							-- no default provided from DB constraint - OK to override
		,@streetAddress2                 nvarchar(75)      = null							-- no default provided from DB constraint - OK to override
		,@streetAddress3                 nvarchar(75)      = null							-- no default provided from DB constraint - OK to override
		,@citySID                        int               = null							-- no default provided from DB constraint - OK to override
		,@postalCode                     varchar(10)       = null							-- no default provided from DB constraint - OK to override
		,@regionSID                      int               = null							-- no default provided from DB constraint - OK to override
		,@phone                          varchar(25)       = null							-- no default provided from DB constraint - OK to override
		,@fax                            varchar(25)       = null							-- no default provided from DB constraint - OK to override
		,@webSite                        varchar(250)      = null							-- no default provided from DB constraint - OK to override
		,@emailAddress                   varchar(150)      = null							-- no default provided from DB constraint - OK to override
		,@insuranceOrgSID                int               = null							-- no default provided from DB constraint - OK to override
		,@insurancePolicyNo              varchar(25)       = null							-- no default provided from DB constraint - OK to override
		,@insuranceAmount                decimal(11,2)     = null							-- no default provided from DB constraint - OK to override
		,@isEmployer                     bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@isCredentialAuthority          bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@isInsurer                      bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@isInsuranceCertificateRequired bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@isPublic                       nchar(10)         = null							-- no default provided from DB constraint - OK to override
		,@comments                       nvarchar(max)     = null							-- no default provided from DB constraint - OK to override
		,@tagList                        xml               = CONVERT(xml,N'<Tags/>')										-- default provided from DB constraint - OK to override
		,@isActive                       bit               = (1)							-- default provided from DB constraint - OK to override
		,@isAdminReviewRequired          bit               = CONVERT(bit,(0))	-- default provided from DB constraint - OK to override
		,@lastVerifiedTime               datetimeoffset(7) = null							-- no default provided from DB constraint - OK to override
		,@changeLog                      xml               = CONVERT(xml,'<Changes />')									-- default provided from DB constraint - OK to override
		,@userDefinedColumns             xml               = null							-- no default provided from DB constraint - OK to override
		,@orgXID                         varchar(150)      = null							-- no default provided from DB constraint - OK to override
		,@legacyKey                      nvarchar(50)      = null							-- no default provided from DB constraint - OK to override
		,@isDeleted                      bit               = (0)							-- default provided from DB constraint - OK to override
		,@createUser                     nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@createTime                     datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@updateUser                     nvarchar(75)      = suser_sname()		-- default value ignored (value set by UI)
		,@updateTime                     datetimeoffset(7) = sysdatetimeoffset()												-- default value ignored (set to system time)
		,@rowGUID                        uniqueidentifier  = newid()					-- default value ignored (value set by system)
		,@rowStamp                       timestamp         = null							-- default value ignored (value set by system)
		,@cityName                       nvarchar(30)      = N'?'							-- not a base table column (default ignored)
		,@stateProvinceSID               int               = 0								-- not a base table column (default ignored)
		,@cityIsDefault                  bit               = 0								-- not a base table column (default ignored)
		,@cityIsActive                   bit               = 0								-- not a base table column (default ignored)
		,@cityIsAdminReviewRequired      bit               = 0								-- not a base table column (default ignored)
		,@cityRowGUID                    uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@orgTypeName                    nvarchar(50)      = N'?'							-- not a base table column (default ignored)
		,@orgTypeCode                    varchar(20)       = '?'							-- not a base table column (default ignored)
		,@sectorCode                     varchar(5)														-- not a base table column (default ignored)
		,@orgTypeCategory                nvarchar(65)													-- not a base table column (default ignored)
		,@orgTypeIsDefault               bit               = 0								-- not a base table column (default ignored)
		,@orgTypeIsActive                bit               = 0								-- not a base table column (default ignored)
		,@orgTypeRowGUID                 uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@regionLabel                    nvarchar(35)      = N'?'							-- not a base table column (default ignored)
		,@regionName                     nvarchar(50)      = N'?'							-- not a base table column (default ignored)
		,@regionIsDefault                bit               = 0								-- not a base table column (default ignored)
		,@regionIsActive                 bit               = 0								-- not a base table column (default ignored)
		,@regionRowGUID                  uniqueidentifier  = newid()					-- not a base table column (default ignored)
		,@isDeleteEnabled                bit																	-- not a base table column (default ignored)
		,@isReselected                   tinyint           = 1								-- specific default required by EF - do not override
		,@isNullApplied                  bit               = 1								-- specific default required by EF - do not override
		,@fullOrgLabel                   nvarchar(max)												-- not a base table column (default ignored)
		,@stateProvinceName              nvarchar(30)      = N'?'							-- not a base table column (default ignored)
		,@stateProvinceCode              nvarchar(5)       = N'?'							-- not a base table column (default ignored)
		,@countrySID                     int               = 0								-- not a base table column (default ignored)
		,@countryName                    nvarchar(50)      = N'?'							-- not a base table column (default ignored)
		,@credentialCount                int																	-- not a base table column (default ignored)
		,@qualifiedCredentialCount       int																	-- not a base table column (default ignored)
		,@employmentCount                int																	-- not a base table column (default ignored)
		,@nextReviewTime                 smalldatetime												-- not a base table column (default ignored)
		,@isNextReviewDue                bit																	-- not a base table column (default ignored)
		,@isInsuranceEnabled             bit               = 0								-- not a base table column (default ignored)
		,@orgNameEffectiveDate           date																	-- not a base table column (default ignored)

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
		-- set mandatory FK values to -1 where requested
		
		if @SetFKDefaults = @ON
		begin
			set @orgTypeSID = -1
			set @citySID = -1
			set @regionSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @parentOrgSID                    = isnull(context.node.value('@ParentOrgSID'                  ,'int'              ),@parentOrgSID)
			,@orgTypeSID                      = isnull(context.node.value('@OrgTypeSID'                    ,'int'              ),@orgTypeSID)
			,@orgName                         = isnull(context.node.value('@OrgName'                       ,'nvarchar(150)'    ),@orgName)
			,@orgLabel                        = isnull(context.node.value('@OrgLabel'                      ,'nvarchar(35)'     ),@orgLabel)
			,@streetAddress1                  = isnull(context.node.value('@StreetAddress1'                ,'nvarchar(75)'     ),@streetAddress1)
			,@streetAddress2                  = isnull(context.node.value('@StreetAddress2'                ,'nvarchar(75)'     ),@streetAddress2)
			,@streetAddress3                  = isnull(context.node.value('@StreetAddress3'                ,'nvarchar(75)'     ),@streetAddress3)
			,@citySID                         = isnull(context.node.value('@CitySID'                       ,'int'              ),@citySID)
			,@postalCode                      = isnull(context.node.value('@PostalCode'                    ,'varchar(10)'      ),@postalCode)
			,@regionSID                       = isnull(context.node.value('@RegionSID'                     ,'int'              ),@regionSID)
			,@phone                           = isnull(context.node.value('@Phone'                         ,'varchar(25)'      ),@phone)
			,@fax                             = isnull(context.node.value('@Fax'                           ,'varchar(25)'      ),@fax)
			,@webSite                         = isnull(context.node.value('@WebSite'                       ,'varchar(250)'     ),@webSite)
			,@emailAddress                    = isnull(context.node.value('@EmailAddress'                  ,'varchar(150)'     ),@emailAddress)
			,@insuranceOrgSID                 = isnull(context.node.value('@InsuranceOrgSID'               ,'int'              ),@insuranceOrgSID)
			,@insurancePolicyNo               = isnull(context.node.value('@InsurancePolicyNo'             ,'varchar(25)'      ),@insurancePolicyNo)
			,@insuranceAmount                 = isnull(context.node.value('@InsuranceAmount'               ,'decimal(11,2)'    ),@insuranceAmount)
			,@isEmployer                      = isnull(context.node.value('@IsEmployer'                    ,'bit'              ),@isEmployer)
			,@isCredentialAuthority           = isnull(context.node.value('@IsCredentialAuthority'         ,'bit'              ),@isCredentialAuthority)
			,@isInsurer                       = isnull(context.node.value('@IsInsurer'                     ,'bit'              ),@isInsurer)
			,@isInsuranceCertificateRequired  = isnull(context.node.value('@IsInsuranceCertificateRequired','bit'              ),@isInsuranceCertificateRequired)
			,@isPublic                        = isnull(context.node.value('@IsPublic'                      ,'nchar(10)'        ),@isPublic)
			,@comments                        = isnull(context.node.value('@Comments'                      ,'nvarchar(max)'    ),@comments)
			,@isActive                        = isnull(context.node.value('@IsActive'                      ,'bit'              ),@isActive)
			,@isAdminReviewRequired           = isnull(context.node.value('@IsAdminReviewRequired'         ,'bit'              ),@isAdminReviewRequired)
			,@lastVerifiedTime                = isnull(context.node.value('@LastVerifiedTime'              ,'datetimeoffset(7)'),@lastVerifiedTime)
			,@orgXID                          = isnull(context.node.value('@OrgXID'                        ,'varchar(150)'     ),@orgXID)
			,@legacyKey                       = isnull(context.node.value('@LegacyKey'                     ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		
		-- set default value on foreign keys where configured
		-- and where no DB or literal value was passed for it
		
		if isnull(@citySID   ,0) = 0 select @citySID    = x.CitySID    from dbo.City    x where x.IsDefault = @ON
		if isnull(@orgTypeSID,0) = 0 select @orgTypeSID = x.OrgTypeSID from dbo.OrgType x where x.IsDefault = @ON
		if isnull(@regionSID ,0) = 0 select @regionSID  = x.RegionSID  from dbo.Region  x where x.IsDefault = @ON

		--! <Overrides>
		--  insert default value logic here ...
		--! </Overrides>
	
		-- call the extended version of the procedure (if it exists) for "default.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pOrg'
		)
		begin
		
			exec @errorNo = ext.pOrg
				 @Mode                           = 'default.pre'
				,@OrgSID = @orgSID
				,@ParentOrgSID = @parentOrgSID output
				,@OrgTypeSID = @orgTypeSID output
				,@OrgName = @orgName output
				,@OrgLabel = @orgLabel output
				,@StreetAddress1 = @streetAddress1 output
				,@StreetAddress2 = @streetAddress2 output
				,@StreetAddress3 = @streetAddress3 output
				,@CitySID = @citySID output
				,@PostalCode = @postalCode output
				,@RegionSID = @regionSID output
				,@Phone = @phone output
				,@Fax = @fax output
				,@WebSite = @webSite output
				,@EmailAddress = @emailAddress output
				,@InsuranceOrgSID = @insuranceOrgSID output
				,@InsurancePolicyNo = @insurancePolicyNo output
				,@InsuranceAmount = @insuranceAmount output
				,@IsEmployer = @isEmployer output
				,@IsCredentialAuthority = @isCredentialAuthority output
				,@IsInsurer = @isInsurer output
				,@IsInsuranceCertificateRequired = @isInsuranceCertificateRequired output
				,@IsPublic = @isPublic output
				,@Comments = @comments output
				,@TagList = @tagList output
				,@IsActive = @isActive output
				,@IsAdminReviewRequired = @isAdminReviewRequired output
				,@LastVerifiedTime = @lastVerifiedTime output
				,@ChangeLog = @changeLog output
				,@UserDefinedColumns = @userDefinedColumns output
				,@OrgXID = @orgXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@CityName = @cityName
				,@StateProvinceSID = @stateProvinceSID
				,@CityIsDefault = @cityIsDefault
				,@CityIsActive = @cityIsActive
				,@CityIsAdminReviewRequired = @cityIsAdminReviewRequired
				,@CityRowGUID = @cityRowGUID
				,@OrgTypeName = @orgTypeName
				,@OrgTypeCode = @orgTypeCode
				,@SectorCode = @sectorCode
				,@OrgTypeCategory = @orgTypeCategory
				,@OrgTypeIsDefault = @orgTypeIsDefault
				,@OrgTypeIsActive = @orgTypeIsActive
				,@OrgTypeRowGUID = @orgTypeRowGUID
				,@RegionLabel = @regionLabel
				,@RegionName = @regionName
				,@RegionIsDefault = @regionIsDefault
				,@RegionIsActive = @regionIsActive
				,@RegionRowGUID = @regionRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
				,@FullOrgLabel = @fullOrgLabel
				,@StateProvinceName = @stateProvinceName
				,@StateProvinceCode = @stateProvinceCode
				,@CountrySID = @countrySID
				,@CountryName = @countryName
				,@CredentialCount = @credentialCount
				,@QualifiedCredentialCount = @qualifiedCredentialCount
				,@EmploymentCount = @employmentCount
				,@NextReviewTime = @nextReviewTime
				,@IsNextReviewDue = @isNextReviewDue
				,@IsInsuranceEnabled = @isInsuranceEnabled
				,@OrgNameEffectiveDate = @orgNameEffectiveDate
		
		end

		select
			 @orgSID OrgSID
			,@parentOrgSID ParentOrgSID
			,@orgTypeSID OrgTypeSID
			,@orgName OrgName
			,@orgLabel OrgLabel
			,@streetAddress1 StreetAddress1
			,@streetAddress2 StreetAddress2
			,@streetAddress3 StreetAddress3
			,@citySID CitySID
			,@postalCode PostalCode
			,@regionSID RegionSID
			,@phone Phone
			,@fax Fax
			,@webSite WebSite
			,@emailAddress EmailAddress
			,@insuranceOrgSID InsuranceOrgSID
			,@insurancePolicyNo InsurancePolicyNo
			,@insuranceAmount InsuranceAmount
			,@isEmployer IsEmployer
			,@isCredentialAuthority IsCredentialAuthority
			,@isInsurer IsInsurer
			,@isInsuranceCertificateRequired IsInsuranceCertificateRequired
			,@isPublic IsPublic
			,@comments Comments
			,@tagList TagList
			,@isActive IsActive
			,@isAdminReviewRequired IsAdminReviewRequired
			,@lastVerifiedTime LastVerifiedTime
			,@changeLog ChangeLog
			,@userDefinedColumns UserDefinedColumns
			,@orgXID OrgXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@cityName CityName
			,@stateProvinceSID StateProvinceSID
			,@cityIsDefault CityIsDefault
			,@cityIsActive CityIsActive
			,@cityIsAdminReviewRequired CityIsAdminReviewRequired
			,@cityRowGUID CityRowGUID
			,@orgTypeName OrgTypeName
			,@orgTypeCode OrgTypeCode
			,@sectorCode SectorCode
			,@orgTypeCategory OrgTypeCategory
			,@orgTypeIsDefault OrgTypeIsDefault
			,@orgTypeIsActive OrgTypeIsActive
			,@orgTypeRowGUID OrgTypeRowGUID
			,@regionLabel RegionLabel
			,@regionName RegionName
			,@regionIsDefault RegionIsDefault
			,@regionIsActive RegionIsActive
			,@regionRowGUID RegionRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@fullOrgLabel FullOrgLabel
			,@stateProvinceName StateProvinceName
			,@stateProvinceCode StateProvinceCode
			,@countrySID CountrySID
			,@countryName CountryName
			,@credentialCount CredentialCount
			,@qualifiedCredentialCount QualifiedCredentialCount
			,@employmentCount EmploymentCount
			,@nextReviewTime NextReviewTime
			,@isNextReviewDue IsNextReviewDue
			,@isInsuranceEnabled IsInsuranceEnabled
			,@orgNameEffectiveDate OrgNameEffectiveDate

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