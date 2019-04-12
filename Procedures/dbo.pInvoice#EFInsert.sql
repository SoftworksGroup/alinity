SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoice#EFInsert]
	 @PersonSID                   int               = null									-- required! if not passed value must be set in custom logic prior to insert
	,@InvoiceDate                 date              = null									-- default: sf.fToday()
	,@Tax1Label                   nvarchar(8)       = null									-- default: N'N/A'
	,@Tax1Rate                    decimal(4,4)      = null									-- default: (0.0)
	,@Tax1GLAccountCode           varchar(50)       = null									
	,@Tax2Label                   nvarchar(8)       = null									-- default: N'N/A'
	,@Tax2Rate                    decimal(4,4)      = null									-- default: (0.0)
	,@Tax2GLAccountCode           varchar(50)       = null									
	,@Tax3Label                   nvarchar(8)       = null									-- default: N'N/A'
	,@Tax3Rate                    decimal(4,4)      = null									-- default: (0.0)
	,@Tax3GLAccountCode           varchar(50)       = null									
	,@RegistrationYear            smallint          = null									-- required! if not passed value must be set in custom logic prior to insert
	,@CancelledTime               datetimeoffset(7) = null									
	,@ReasonSID                   int               = null									
	,@IsRefund                    bit               = null									-- default: CONVERT(bit,(0))
	,@ComplaintSID                int               = null									
	,@UserDefinedColumns          xml               = null									
	,@InvoiceXID                  varchar(150)      = null									
	,@LegacyKey                   nvarchar(50)      = null									
	,@CreateUser                  nvarchar(75)      = null									-- default: suser_sname()
	,@IsReselected                tinyint           = null									-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                    xml               = null									-- other values defining context for the insert (if any)
	,@GenderSID                   int               = null									-- not a base table column (default ignored)
	,@NamePrefixSID               int               = null									-- not a base table column (default ignored)
	,@FirstName                   nvarchar(30)      = null									-- not a base table column (default ignored)
	,@CommonName                  nvarchar(30)      = null									-- not a base table column (default ignored)
	,@MiddleNames                 nvarchar(30)      = null									-- not a base table column (default ignored)
	,@LastName                    nvarchar(35)      = null									-- not a base table column (default ignored)
	,@BirthDate                   date              = null									-- not a base table column (default ignored)
	,@DeathDate                   date              = null									-- not a base table column (default ignored)
	,@HomePhone                   varchar(25)       = null									-- not a base table column (default ignored)
	,@MobilePhone                 varchar(25)       = null									-- not a base table column (default ignored)
	,@IsTextMessagingEnabled      bit               = null									-- not a base table column (default ignored)
	,@ImportBatch                 nvarchar(100)     = null									-- not a base table column (default ignored)
	,@PersonRowGUID               uniqueidentifier  = null									-- not a base table column (default ignored)
	,@ComplaintNo                 varchar(50)       = null									-- not a base table column (default ignored)
	,@RegistrantSID               int               = null									-- not a base table column (default ignored)
	,@ComplaintTypeSID            int               = null									-- not a base table column (default ignored)
	,@ComplainantTypeSID          int               = null									-- not a base table column (default ignored)
	,@ApplicationUserSID          int               = null									-- not a base table column (default ignored)
	,@OpenedDate                  date              = null									-- not a base table column (default ignored)
	,@ConductStartDate            date              = null									-- not a base table column (default ignored)
	,@ConductEndDate              date              = null									-- not a base table column (default ignored)
	,@ComplaintSeveritySID        int               = null									-- not a base table column (default ignored)
	,@IsDisplayedOnPublicRegistry bit               = null									-- not a base table column (default ignored)
	,@ClosedDate                  date              = null									-- not a base table column (default ignored)
	,@DismissedDate               date              = null									-- not a base table column (default ignored)
	,@ComplaintReasonSID          int               = null									-- not a base table column (default ignored)
	,@FileExtension               varchar(5)        = null									-- not a base table column (default ignored)
	,@ComplaintRowGUID            uniqueidentifier  = null									-- not a base table column (default ignored)
	,@ReasonGroupSID              int               = null									-- not a base table column (default ignored)
	,@ReasonName                  nvarchar(50)      = null									-- not a base table column (default ignored)
	,@ReasonCode                  varchar(25)       = null									-- not a base table column (default ignored)
	,@ReasonSequence              smallint          = null									-- not a base table column (default ignored)
	,@ToolTip                     nvarchar(500)     = null									-- not a base table column (default ignored)
	,@ReasonIsActive              bit               = null									-- not a base table column (default ignored)
	,@ReasonRowGUID               uniqueidentifier  = null									-- not a base table column (default ignored)
	,@IsDeleteEnabled             bit               = null									-- not a base table column (default ignored)
	,@InvoiceLabel                nvarchar(4000)    = null									-- not a base table column (default ignored)
	,@InvoiceShortLabel           nvarchar(4000)    = null									-- not a base table column (default ignored)
	,@TotalBeforeTax              decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Tax1Total                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Tax2Total                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@Tax3Total                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalAdjustment             decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalAfterTax               decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalPaid                   decimal(11,2)     = null									-- not a base table column (default ignored)
	,@TotalDue                    decimal(11,2)     = null									-- not a base table column (default ignored)
	,@IsUnPaid                    bit               = null									-- not a base table column (default ignored)
	,@IsPaid                      bit               = null									-- not a base table column (default ignored)
	,@IsOverPaid                  bit               = null									-- not a base table column (default ignored)
	,@IsOverDue                   bit               = null									-- not a base table column (default ignored)
	,@Tax1GLAccountLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@Tax1IsTaxAccount            bit               = null									-- not a base table column (default ignored)
	,@Tax2GLAccountLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@Tax2IsTaxAccount            bit               = null									-- not a base table column (default ignored)
	,@Tax3GLAccountLabel          nvarchar(35)      = null									-- not a base table column (default ignored)
	,@Tax3IsTaxAccount            bit               = null									-- not a base table column (default ignored)
	,@IsDeferred                  bit               = null									-- not a base table column (default ignored)
	,@IsCancelled                 bit               = null									-- not a base table column (default ignored)
	,@IsEditEnabled               bit               = null									-- not a base table column (default ignored)
	,@IsPAPSubscriber             bit               = null									-- not a base table column (default ignored)
	,@IsPAPEnabled                bit               = null									-- not a base table column (default ignored)
	,@AddressBlockForPrint        nvarchar(512)     = null									-- not a base table column (default ignored)
	,@AddressBlockForHTML         nvarchar(512)     = null									-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoice#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pInvoice#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pInvoice#Insert
			 @PersonSID                   = @PersonSID
			,@InvoiceDate                 = @InvoiceDate
			,@Tax1Label                   = @Tax1Label
			,@Tax1Rate                    = @Tax1Rate
			,@Tax1GLAccountCode           = @Tax1GLAccountCode
			,@Tax2Label                   = @Tax2Label
			,@Tax2Rate                    = @Tax2Rate
			,@Tax2GLAccountCode           = @Tax2GLAccountCode
			,@Tax3Label                   = @Tax3Label
			,@Tax3Rate                    = @Tax3Rate
			,@Tax3GLAccountCode           = @Tax3GLAccountCode
			,@RegistrationYear            = @RegistrationYear
			,@CancelledTime               = @CancelledTime
			,@ReasonSID                   = @ReasonSID
			,@IsRefund                    = @IsRefund
			,@ComplaintSID                = @ComplaintSID
			,@UserDefinedColumns          = @UserDefinedColumns
			,@InvoiceXID                  = @InvoiceXID
			,@LegacyKey                   = @LegacyKey
			,@CreateUser                  = @CreateUser
			,@IsReselected                = @IsReselected
			,@zContext                    = @zContext
			,@GenderSID                   = @GenderSID
			,@NamePrefixSID               = @NamePrefixSID
			,@FirstName                   = @FirstName
			,@CommonName                  = @CommonName
			,@MiddleNames                 = @MiddleNames
			,@LastName                    = @LastName
			,@BirthDate                   = @BirthDate
			,@DeathDate                   = @DeathDate
			,@HomePhone                   = @HomePhone
			,@MobilePhone                 = @MobilePhone
			,@IsTextMessagingEnabled      = @IsTextMessagingEnabled
			,@ImportBatch                 = @ImportBatch
			,@PersonRowGUID               = @PersonRowGUID
			,@ComplaintNo                 = @ComplaintNo
			,@RegistrantSID               = @RegistrantSID
			,@ComplaintTypeSID            = @ComplaintTypeSID
			,@ComplainantTypeSID          = @ComplainantTypeSID
			,@ApplicationUserSID          = @ApplicationUserSID
			,@OpenedDate                  = @OpenedDate
			,@ConductStartDate            = @ConductStartDate
			,@ConductEndDate              = @ConductEndDate
			,@ComplaintSeveritySID        = @ComplaintSeveritySID
			,@IsDisplayedOnPublicRegistry = @IsDisplayedOnPublicRegistry
			,@ClosedDate                  = @ClosedDate
			,@DismissedDate               = @DismissedDate
			,@ComplaintReasonSID          = @ComplaintReasonSID
			,@FileExtension               = @FileExtension
			,@ComplaintRowGUID            = @ComplaintRowGUID
			,@ReasonGroupSID              = @ReasonGroupSID
			,@ReasonName                  = @ReasonName
			,@ReasonCode                  = @ReasonCode
			,@ReasonSequence              = @ReasonSequence
			,@ToolTip                     = @ToolTip
			,@ReasonIsActive              = @ReasonIsActive
			,@ReasonRowGUID               = @ReasonRowGUID
			,@IsDeleteEnabled             = @IsDeleteEnabled
			,@InvoiceLabel                = @InvoiceLabel
			,@InvoiceShortLabel           = @InvoiceShortLabel
			,@TotalBeforeTax              = @TotalBeforeTax
			,@Tax1Total                   = @Tax1Total
			,@Tax2Total                   = @Tax2Total
			,@Tax3Total                   = @Tax3Total
			,@TotalAdjustment             = @TotalAdjustment
			,@TotalAfterTax               = @TotalAfterTax
			,@TotalPaid                   = @TotalPaid
			,@TotalDue                    = @TotalDue
			,@IsUnPaid                    = @IsUnPaid
			,@IsPaid                      = @IsPaid
			,@IsOverPaid                  = @IsOverPaid
			,@IsOverDue                   = @IsOverDue
			,@Tax1GLAccountLabel          = @Tax1GLAccountLabel
			,@Tax1IsTaxAccount            = @Tax1IsTaxAccount
			,@Tax2GLAccountLabel          = @Tax2GLAccountLabel
			,@Tax2IsTaxAccount            = @Tax2IsTaxAccount
			,@Tax3GLAccountLabel          = @Tax3GLAccountLabel
			,@Tax3IsTaxAccount            = @Tax3IsTaxAccount
			,@IsDeferred                  = @IsDeferred
			,@IsCancelled                 = @IsCancelled
			,@IsEditEnabled               = @IsEditEnabled
			,@IsPAPSubscriber             = @IsPAPSubscriber
			,@IsPAPEnabled                = @IsPAPEnabled
			,@AddressBlockForPrint        = @AddressBlockForPrint
			,@AddressBlockForHTML         = @AddressBlockForHTML

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
