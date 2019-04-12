SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrg#EFInsert]
	 @ParentOrgSID                   int               = null								
	,@OrgTypeSID                     int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@OrgName                        nvarchar(150)     = null								-- required! if not passed value must be set in custom logic prior to insert
	,@OrgLabel                       nvarchar(35)      = null								-- required! if not passed value must be set in custom logic prior to insert
	,@StreetAddress1                 nvarchar(75)      = null								-- required! if not passed value must be set in custom logic prior to insert
	,@StreetAddress2                 nvarchar(75)      = null								
	,@StreetAddress3                 nvarchar(75)      = null								
	,@CitySID                        int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@PostalCode                     varchar(10)       = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegionSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@Phone                          varchar(25)       = null								
	,@Fax                            varchar(25)       = null								
	,@WebSite                        varchar(250)      = null								
	,@EmailAddress                   varchar(150)      = null								
	,@InsuranceOrgSID                int               = null								
	,@InsurancePolicyNo              varchar(25)       = null								
	,@InsuranceAmount                decimal(11,2)     = null								
	,@IsEmployer                     bit               = null								-- default: CONVERT(bit,(0))
	,@IsCredentialAuthority          bit               = null								-- default: CONVERT(bit,(0))
	,@IsInsurer                      bit               = null								-- default: CONVERT(bit,(0))
	,@IsInsuranceCertificateRequired bit               = null								-- default: CONVERT(bit,(0))
	,@IsPublic                       nchar(10)         = null								
	,@Comments                       nvarchar(max)     = null								
	,@TagList                        xml               = null								-- default: CONVERT(xml,N'<Tags/>')
	,@IsActive                       bit               = null								-- default: (1)
	,@IsAdminReviewRequired          bit               = null								-- default: CONVERT(bit,(0))
	,@LastVerifiedTime               datetimeoffset(7) = null								
	,@ChangeLog                      xml               = null								-- default: CONVERT(xml,'<Changes />')
	,@UserDefinedColumns             xml               = null								
	,@OrgXID                         varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@CityName                       nvarchar(30)      = null								-- not a base table column (default ignored)
	,@StateProvinceSID               int               = null								-- not a base table column (default ignored)
	,@CityIsDefault                  bit               = null								-- not a base table column (default ignored)
	,@CityIsActive                   bit               = null								-- not a base table column (default ignored)
	,@CityIsAdminReviewRequired      bit               = null								-- not a base table column (default ignored)
	,@CityRowGUID                    uniqueidentifier  = null								-- not a base table column (default ignored)
	,@OrgTypeName                    nvarchar(50)      = null								-- not a base table column (default ignored)
	,@OrgTypeCode                    varchar(20)       = null								-- not a base table column (default ignored)
	,@SectorCode                     varchar(5)        = null								-- not a base table column (default ignored)
	,@OrgTypeCategory                nvarchar(65)      = null								-- not a base table column (default ignored)
	,@OrgTypeIsDefault               bit               = null								-- not a base table column (default ignored)
	,@OrgTypeIsActive                bit               = null								-- not a base table column (default ignored)
	,@OrgTypeRowGUID                 uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegionLabel                    nvarchar(35)      = null								-- not a base table column (default ignored)
	,@RegionName                     nvarchar(50)      = null								-- not a base table column (default ignored)
	,@RegionIsDefault                bit               = null								-- not a base table column (default ignored)
	,@RegionIsActive                 bit               = null								-- not a base table column (default ignored)
	,@RegionRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@FullOrgLabel                   nvarchar(max)     = null								-- not a base table column (default ignored)
	,@StateProvinceName              nvarchar(30)      = null								-- not a base table column (default ignored)
	,@StateProvinceCode              nvarchar(5)       = null								-- not a base table column (default ignored)
	,@CountrySID                     int               = null								-- not a base table column (default ignored)
	,@CountryName                    nvarchar(50)      = null								-- not a base table column (default ignored)
	,@CredentialCount                int               = null								-- not a base table column (default ignored)
	,@QualifiedCredentialCount       int               = null								-- not a base table column (default ignored)
	,@EmploymentCount                int               = null								-- not a base table column (default ignored)
	,@NextReviewTime                 smalldatetime     = null								-- not a base table column (default ignored)
	,@IsNextReviewDue                bit               = null								-- not a base table column (default ignored)
	,@IsInsuranceEnabled             bit               = null								-- not a base table column (default ignored)
	,@OrgNameEffectiveDate           date              = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pOrg#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pOrg#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

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

		-- call the main procedure

		exec @errorNo = dbo.pOrg#Insert
			 @ParentOrgSID                   = @ParentOrgSID
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
			,@Comments                       = @Comments
			,@TagList                        = @TagList
			,@IsActive                       = @IsActive
			,@IsAdminReviewRequired          = @IsAdminReviewRequired
			,@LastVerifiedTime               = @LastVerifiedTime
			,@ChangeLog                      = @ChangeLog
			,@UserDefinedColumns             = @UserDefinedColumns
			,@OrgXID                         = @OrgXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@CityName                       = @CityName
			,@StateProvinceSID               = @StateProvinceSID
			,@CityIsDefault                  = @CityIsDefault
			,@CityIsActive                   = @CityIsActive
			,@CityIsAdminReviewRequired      = @CityIsAdminReviewRequired
			,@CityRowGUID                    = @CityRowGUID
			,@OrgTypeName                    = @OrgTypeName
			,@OrgTypeCode                    = @OrgTypeCode
			,@SectorCode                     = @SectorCode
			,@OrgTypeCategory                = @OrgTypeCategory
			,@OrgTypeIsDefault               = @OrgTypeIsDefault
			,@OrgTypeIsActive                = @OrgTypeIsActive
			,@OrgTypeRowGUID                 = @OrgTypeRowGUID
			,@RegionLabel                    = @RegionLabel
			,@RegionName                     = @RegionName
			,@RegionIsDefault                = @RegionIsDefault
			,@RegionIsActive                 = @RegionIsActive
			,@RegionRowGUID                  = @RegionRowGUID
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@FullOrgLabel                   = @FullOrgLabel
			,@StateProvinceName              = @StateProvinceName
			,@StateProvinceCode              = @StateProvinceCode
			,@CountrySID                     = @CountrySID
			,@CountryName                    = @CountryName
			,@CredentialCount                = @CredentialCount
			,@QualifiedCredentialCount       = @QualifiedCredentialCount
			,@EmploymentCount                = @EmploymentCount
			,@NextReviewTime                 = @NextReviewTime
			,@IsNextReviewDue                = @IsNextReviewDue
			,@IsInsuranceEnabled             = @IsInsuranceEnabled
			,@OrgNameEffectiveDate           = @OrgNameEffectiveDate

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
