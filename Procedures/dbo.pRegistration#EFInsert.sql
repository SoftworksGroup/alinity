SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistration#EFInsert]
	 @RegistrantSID                    int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterSectionSID       int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationNo                   nvarchar(50)      = null							-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                 smallint          = null							-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime                    datetime          = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ExpiryTime                       datetime          = null							-- required! if not passed value must be set in custom logic prior to insert
	,@CardPrintedTime                  datetime          = null							
	,@InvoiceSID                       int               = null							
	,@ReasonSID                        int               = null							
	,@FormGUID                         uniqueidentifier  = null							
	,@UserDefinedColumns               xml               = null							
	,@RegistrationXID                  varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@PracticeRegisterSID              int               = null							-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel     nvarchar(35)      = null							-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDefault bit               = null							-- not a base table column (default ignored)
	,@IsDisplayedOnLicense             bit               = null							-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsActive  bit               = null							-- not a base table column (default ignored)
	,@PracticeRegisterSectionRowGUID   uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantPersonSID              int               = null							-- not a base table column (default ignored)
	,@RegistrantNo                     varchar(50)       = null							-- not a base table column (default ignored)
	,@YearOfInitialEmployment          smallint          = null							-- not a base table column (default ignored)
	,@IsOnPublicRegistry               bit               = null							-- not a base table column (default ignored)
	,@CityNameOfBirth                  nvarchar(30)      = null							-- not a base table column (default ignored)
	,@CountrySID                       int               = null							-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence      smallint          = null							-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours   smallint          = null							-- not a base table column (default ignored)
	,@LateFeeExclusionYear             smallint          = null							-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked     bit               = null							-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime       datetime          = null							-- not a base table column (default ignored)
	,@ArchivedTime                     datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@RegistrantRowGUID                uniqueidentifier  = null							-- not a base table column (default ignored)
	,@InvoicePersonSID                 int               = null							-- not a base table column (default ignored)
	,@InvoiceDate                      date              = null							-- not a base table column (default ignored)
	,@Tax1Label                        nvarchar(8)       = null							-- not a base table column (default ignored)
	,@Tax1Rate                         decimal(4,4)      = null							-- not a base table column (default ignored)
	,@Tax1GLAccountCode                varchar(50)       = null							-- not a base table column (default ignored)
	,@Tax2Label                        nvarchar(8)       = null							-- not a base table column (default ignored)
	,@Tax2Rate                         decimal(4,4)      = null							-- not a base table column (default ignored)
	,@Tax2GLAccountCode                varchar(50)       = null							-- not a base table column (default ignored)
	,@Tax3Label                        nvarchar(8)       = null							-- not a base table column (default ignored)
	,@Tax3Rate                         decimal(4,4)      = null							-- not a base table column (default ignored)
	,@Tax3GLAccountCode                varchar(50)       = null							-- not a base table column (default ignored)
	,@InvoiceRegistrationYear          smallint          = null							-- not a base table column (default ignored)
	,@CancelledTime                    datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@InvoiceReasonSID                 int               = null							-- not a base table column (default ignored)
	,@IsRefund                         bit               = null							-- not a base table column (default ignored)
	,@ComplaintSID                     int               = null							-- not a base table column (default ignored)
	,@InvoiceRowGUID                   uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ReasonGroupSID                   int               = null							-- not a base table column (default ignored)
	,@ReasonName                       nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ReasonCode                       varchar(25)       = null							-- not a base table column (default ignored)
	,@ReasonSequence                   smallint          = null							-- not a base table column (default ignored)
	,@ToolTip                          nvarchar(500)     = null							-- not a base table column (default ignored)
	,@ReasonIsActive                   bit               = null							-- not a base table column (default ignored)
	,@ReasonRowGUID                    uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsActive                         bit               = null							-- not a base table column (default ignored)
	,@IsPending                        bit               = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@RegistrantLabel                  nvarchar(75)      = null							-- not a base table column (default ignored)
	,@RegistrationYearLabel            varchar(25)       = null							-- not a base table column (default ignored)
	,@PracticeRegisterName             nvarchar(65)      = null							-- not a base table column (default ignored)
	,@PracticeRegisterLabel            nvarchar(35)      = null							-- not a base table column (default ignored)
	,@RegistrationLabel                nvarchar(85)      = null							-- not a base table column (default ignored)
	,@IsReadEnabled                    bit               = null							-- not a base table column (default ignored)
	,@FirstName                        nvarchar(30)      = null							-- not a base table column (default ignored)
	,@MiddleNames                      nvarchar(30)      = null							-- not a base table column (default ignored)
	,@LastName                         nvarchar(35)      = null							-- not a base table column (default ignored)
	,@AddressBlockForPrint             nvarchar(512)     = null							-- not a base table column (default ignored)
	,@AddressBlockForHTML              nvarchar(512)     = null							-- not a base table column (default ignored)
	,@FutureRegistrationLabel          nvarchar(85)      = null							-- not a base table column (default ignored)
	,@FutureRegistrationYear           smallint          = null							-- not a base table column (default ignored)
	,@FuturePracticeRegisterSID        int               = null							-- not a base table column (default ignored)
	,@FuturePracticeRegisterLabel      nvarchar(35)      = null							-- not a base table column (default ignored)
	,@FuturePracticeRegisterSectionSID int               = null							-- not a base table column (default ignored)
	,@FutureRegisterSectionLabel       nvarchar(35)      = null							-- not a base table column (default ignored)
	,@FutureEffectiveTime              datetime          = null							-- not a base table column (default ignored)
	,@FutureExpiryTime                 datetime          = null							-- not a base table column (default ignored)
	,@FutureCardPrintedTime            datetime          = null							-- not a base table column (default ignored)
	,@FutureInvoiceSID                 int               = null							-- not a base table column (default ignored)
	,@FutureReasonSID                  int               = null							-- not a base table column (default ignored)
	,@FutureFormGUID                   uniqueidentifier  = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistration#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistration#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistration#Insert
			 @RegistrantSID                    = @RegistrantSID
			,@PracticeRegisterSectionSID       = @PracticeRegisterSectionSID
			,@RegistrationNo                   = @RegistrationNo
			,@RegistrationYear                 = @RegistrationYear
			,@EffectiveTime                    = @EffectiveTime
			,@ExpiryTime                       = @ExpiryTime
			,@CardPrintedTime                  = @CardPrintedTime
			,@InvoiceSID                       = @InvoiceSID
			,@ReasonSID                        = @ReasonSID
			,@FormGUID                         = @FormGUID
			,@UserDefinedColumns               = @UserDefinedColumns
			,@RegistrationXID                  = @RegistrationXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@PracticeRegisterSID              = @PracticeRegisterSID
			,@PracticeRegisterSectionLabel     = @PracticeRegisterSectionLabel
			,@PracticeRegisterSectionIsDefault = @PracticeRegisterSectionIsDefault
			,@IsDisplayedOnLicense             = @IsDisplayedOnLicense
			,@PracticeRegisterSectionIsActive  = @PracticeRegisterSectionIsActive
			,@PracticeRegisterSectionRowGUID   = @PracticeRegisterSectionRowGUID
			,@RegistrantPersonSID              = @RegistrantPersonSID
			,@RegistrantNo                     = @RegistrantNo
			,@YearOfInitialEmployment          = @YearOfInitialEmployment
			,@IsOnPublicRegistry               = @IsOnPublicRegistry
			,@CityNameOfBirth                  = @CityNameOfBirth
			,@CountrySID                       = @CountrySID
			,@DirectedAuditYearCompetence      = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours   = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear             = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked     = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime       = @RenewalExtensionExpiryTime
			,@ArchivedTime                     = @ArchivedTime
			,@RegistrantRowGUID                = @RegistrantRowGUID
			,@InvoicePersonSID                 = @InvoicePersonSID
			,@InvoiceDate                      = @InvoiceDate
			,@Tax1Label                        = @Tax1Label
			,@Tax1Rate                         = @Tax1Rate
			,@Tax1GLAccountCode                = @Tax1GLAccountCode
			,@Tax2Label                        = @Tax2Label
			,@Tax2Rate                         = @Tax2Rate
			,@Tax2GLAccountCode                = @Tax2GLAccountCode
			,@Tax3Label                        = @Tax3Label
			,@Tax3Rate                         = @Tax3Rate
			,@Tax3GLAccountCode                = @Tax3GLAccountCode
			,@InvoiceRegistrationYear          = @InvoiceRegistrationYear
			,@CancelledTime                    = @CancelledTime
			,@InvoiceReasonSID                 = @InvoiceReasonSID
			,@IsRefund                         = @IsRefund
			,@ComplaintSID                     = @ComplaintSID
			,@InvoiceRowGUID                   = @InvoiceRowGUID
			,@ReasonGroupSID                   = @ReasonGroupSID
			,@ReasonName                       = @ReasonName
			,@ReasonCode                       = @ReasonCode
			,@ReasonSequence                   = @ReasonSequence
			,@ToolTip                          = @ToolTip
			,@ReasonIsActive                   = @ReasonIsActive
			,@ReasonRowGUID                    = @ReasonRowGUID
			,@IsActive                         = @IsActive
			,@IsPending                        = @IsPending
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@RegistrantLabel                  = @RegistrantLabel
			,@RegistrationYearLabel            = @RegistrationYearLabel
			,@PracticeRegisterName             = @PracticeRegisterName
			,@PracticeRegisterLabel            = @PracticeRegisterLabel
			,@RegistrationLabel                = @RegistrationLabel
			,@IsReadEnabled                    = @IsReadEnabled
			,@FirstName                        = @FirstName
			,@MiddleNames                      = @MiddleNames
			,@LastName                         = @LastName
			,@AddressBlockForPrint             = @AddressBlockForPrint
			,@AddressBlockForHTML              = @AddressBlockForHTML
			,@FutureRegistrationLabel          = @FutureRegistrationLabel
			,@FutureRegistrationYear           = @FutureRegistrationYear
			,@FuturePracticeRegisterSID        = @FuturePracticeRegisterSID
			,@FuturePracticeRegisterLabel      = @FuturePracticeRegisterLabel
			,@FuturePracticeRegisterSectionSID = @FuturePracticeRegisterSectionSID
			,@FutureRegisterSectionLabel       = @FutureRegisterSectionLabel
			,@FutureEffectiveTime              = @FutureEffectiveTime
			,@FutureExpiryTime                 = @FutureExpiryTime
			,@FutureCardPrintedTime            = @FutureCardPrintedTime
			,@FutureInvoiceSID                 = @FutureInvoiceSID
			,@FutureReasonSID                  = @FutureReasonSID
			,@FutureFormGUID                   = @FutureFormGUID

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
