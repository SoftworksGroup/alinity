SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pExamOffering#EFInsert]
	 @ExamSID                        int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@OrgSID                         int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ExamTime                       datetime          = null								
	,@SeatingCapacity                int               = null								
	,@CatalogItemSID                 int               = null								
	,@BookingCutOffDate              date              = null								
	,@VendorExamOfferingID           varchar(25)       = null								
	,@UserDefinedColumns             xml               = null								
	,@ExamOfferingXID                varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@ExamName                       nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ExamCategory                   nvarchar(65)      = null								-- not a base table column (default ignored)
	,@PassingScore                   int               = null								-- not a base table column (default ignored)
	,@ExamEffectiveTime              datetime          = null								-- not a base table column (default ignored)
	,@ExamExpiryTime                 datetime          = null								-- not a base table column (default ignored)
	,@IsOnlineExam                   bit               = null								-- not a base table column (default ignored)
	,@IsEnabledOnPortal              bit               = null								-- not a base table column (default ignored)
	,@Sequence                       int               = null								-- not a base table column (default ignored)
	,@CultureSID                     int               = null								-- not a base table column (default ignored)
	,@ExamLastVerifiedTime           datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@MinLagDaysBetweenAttempts      smallint          = null								-- not a base table column (default ignored)
	,@MaxAttemptsPerYear             tinyint           = null								-- not a base table column (default ignored)
	,@VendorExamID                   varchar(25)       = null								-- not a base table column (default ignored)
	,@ExamRowGUID                    uniqueidentifier  = null								-- not a base table column (default ignored)
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
	,@OrgLastVerifiedTime            datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@OrgRowGUID                     uniqueidentifier  = null								-- not a base table column (default ignored)
	,@CatalogItemLabel               nvarchar(35)      = null								-- not a base table column (default ignored)
	,@InvoiceItemDescription         nvarchar(500)     = null								-- not a base table column (default ignored)
	,@IsLateFee                      bit               = null								-- not a base table column (default ignored)
	,@ImageAlternateText             nvarchar(50)      = null								-- not a base table column (default ignored)
	,@IsAvailableOnClientPortal      bit               = null								-- not a base table column (default ignored)
	,@IsComplaintPenalty             bit               = null								-- not a base table column (default ignored)
	,@GLAccountSID                   int               = null								-- not a base table column (default ignored)
	,@IsTaxRate1Applied              bit               = null								-- not a base table column (default ignored)
	,@IsTaxRate2Applied              bit               = null								-- not a base table column (default ignored)
	,@IsTaxRate3Applied              bit               = null								-- not a base table column (default ignored)
	,@IsTaxDeductible                bit               = null								-- not a base table column (default ignored)
	,@CatalogItemEffectiveTime       datetime          = null								-- not a base table column (default ignored)
	,@CatalogItemExpiryTime          datetime          = null								-- not a base table column (default ignored)
	,@FileTypeSCD                    varchar(8)        = null								-- not a base table column (default ignored)
	,@FileTypeSID                    int               = null								-- not a base table column (default ignored)
	,@CatalogItemRowGUID             uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsDetailedOffering             bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pExamOffering#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pExamOffering#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pExamOffering#Insert
			 @ExamSID                        = @ExamSID
			,@OrgSID                         = @OrgSID
			,@ExamTime                       = @ExamTime
			,@SeatingCapacity                = @SeatingCapacity
			,@CatalogItemSID                 = @CatalogItemSID
			,@BookingCutOffDate              = @BookingCutOffDate
			,@VendorExamOfferingID           = @VendorExamOfferingID
			,@UserDefinedColumns             = @UserDefinedColumns
			,@ExamOfferingXID                = @ExamOfferingXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@ExamName                       = @ExamName
			,@ExamCategory                   = @ExamCategory
			,@PassingScore                   = @PassingScore
			,@ExamEffectiveTime              = @ExamEffectiveTime
			,@ExamExpiryTime                 = @ExamExpiryTime
			,@IsOnlineExam                   = @IsOnlineExam
			,@IsEnabledOnPortal              = @IsEnabledOnPortal
			,@Sequence                       = @Sequence
			,@CultureSID                     = @CultureSID
			,@ExamLastVerifiedTime           = @ExamLastVerifiedTime
			,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
			,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
			,@VendorExamID                   = @VendorExamID
			,@ExamRowGUID                    = @ExamRowGUID
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
			,@OrgLastVerifiedTime            = @OrgLastVerifiedTime
			,@OrgRowGUID                     = @OrgRowGUID
			,@CatalogItemLabel               = @CatalogItemLabel
			,@InvoiceItemDescription         = @InvoiceItemDescription
			,@IsLateFee                      = @IsLateFee
			,@ImageAlternateText             = @ImageAlternateText
			,@IsAvailableOnClientPortal      = @IsAvailableOnClientPortal
			,@IsComplaintPenalty             = @IsComplaintPenalty
			,@GLAccountSID                   = @GLAccountSID
			,@IsTaxRate1Applied              = @IsTaxRate1Applied
			,@IsTaxRate2Applied              = @IsTaxRate2Applied
			,@IsTaxRate3Applied              = @IsTaxRate3Applied
			,@IsTaxDeductible                = @IsTaxDeductible
			,@CatalogItemEffectiveTime       = @CatalogItemEffectiveTime
			,@CatalogItemExpiryTime          = @CatalogItemExpiryTime
			,@FileTypeSCD                    = @FileTypeSCD
			,@FileTypeSID                    = @FileTypeSID
			,@CatalogItemRowGUID             = @CatalogItemRowGUID
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@IsDetailedOffering             = @IsDetailedOffering

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
