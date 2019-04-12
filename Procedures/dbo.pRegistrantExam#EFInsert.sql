SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantExam#EFInsert]
	 @RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ExamSID                        int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ExamDate                       date              = null								
	,@ExamResultDate                 date              = null								
	,@PassingScore                   int               = null								
	,@Score                          int               = null								
	,@ExamStatusSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@SchedulingPreferences          nvarchar(1000)    = null								
	,@AssignedLocation               varchar(15)       = null								
	,@ExamReference                  varchar(25)       = null								
	,@ExamOfferingSID                int               = null								
	,@InvoiceSID                     int               = null								
	,@ConfirmedTime                  datetimeoffset(7) = null								
	,@CancelledTime                  datetimeoffset(7) = null								
	,@ExamConfiguration              xml               = null								
	,@ExamResponses                  xml               = null								
	,@ProcessedTime                  datetimeoffset(7) = null								
	,@ProcessingComments             nvarchar(max)     = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantExamXID              varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@ExamName                       nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ExamCategory                   nvarchar(65)      = null								-- not a base table column (default ignored)
	,@ExamPassingScore               int               = null								-- not a base table column (default ignored)
	,@EffectiveTime                  datetime          = null								-- not a base table column (default ignored)
	,@ExpiryTime                     datetime          = null								-- not a base table column (default ignored)
	,@IsOnlineExam                   bit               = null								-- not a base table column (default ignored)
	,@IsEnabledOnPortal              bit               = null								-- not a base table column (default ignored)
	,@ExamSequence                   int               = null								-- not a base table column (default ignored)
	,@CultureSID                     int               = null								-- not a base table column (default ignored)
	,@LastVerifiedTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@MinLagDaysBetweenAttempts      smallint          = null								-- not a base table column (default ignored)
	,@MaxAttemptsPerYear             tinyint           = null								-- not a base table column (default ignored)
	,@VendorExamID                   varchar(25)       = null								-- not a base table column (default ignored)
	,@ExamRowGUID                    uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ExamStatusSCD                  varchar(15)       = null								-- not a base table column (default ignored)
	,@ExamStatusLabel                nvarchar(35)      = null								-- not a base table column (default ignored)
	,@ExamStatusSequence             int               = null								-- not a base table column (default ignored)
	,@ExamStatusIsDefault            bit               = null								-- not a base table column (default ignored)
	,@ExamStatusRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegistrantPersonSID            int               = null								-- not a base table column (default ignored)
	,@RegistrantNo                   varchar(50)       = null								-- not a base table column (default ignored)
	,@YearOfInitialEmployment        smallint          = null								-- not a base table column (default ignored)
	,@IsOnPublicRegistry             bit               = null								-- not a base table column (default ignored)
	,@CityNameOfBirth                nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CountrySID                     int               = null								-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence    smallint          = null								-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours smallint          = null								-- not a base table column (default ignored)
	,@LateFeeExclusionYear           smallint          = null								-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked   bit               = null								-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime     datetime          = null								-- not a base table column (default ignored)
	,@ArchivedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@RegistrantRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@InvoicePersonSID               int               = null								-- not a base table column (default ignored)
	,@InvoiceDate                    date              = null								-- not a base table column (default ignored)
	,@Tax1Label                      nvarchar(8)       = null								-- not a base table column (default ignored)
	,@Tax1Rate                       decimal(4,4)      = null								-- not a base table column (default ignored)
	,@Tax1GLAccountCode              varchar(50)       = null								-- not a base table column (default ignored)
	,@Tax2Label                      nvarchar(8)       = null								-- not a base table column (default ignored)
	,@Tax2Rate                       decimal(4,4)      = null								-- not a base table column (default ignored)
	,@Tax2GLAccountCode              varchar(50)       = null								-- not a base table column (default ignored)
	,@Tax3Label                      nvarchar(8)       = null								-- not a base table column (default ignored)
	,@Tax3Rate                       decimal(4,4)      = null								-- not a base table column (default ignored)
	,@Tax3GLAccountCode              varchar(50)       = null								-- not a base table column (default ignored)
	,@RegistrationYear               smallint          = null								-- not a base table column (default ignored)
	,@InvoiceCancelledTime           datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@ReasonSID                      int               = null								-- not a base table column (default ignored)
	,@IsRefund                       bit               = null								-- not a base table column (default ignored)
	,@ComplaintSID                   int               = null								-- not a base table column (default ignored)
	,@InvoiceRowGUID                 uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ExamOfferingExamSID            int               = null								-- not a base table column (default ignored)
	,@OrgSID                         int               = null								-- not a base table column (default ignored)
	,@ExamTime                       datetime          = null								-- not a base table column (default ignored)
	,@SeatingCapacity                int               = null								-- not a base table column (default ignored)
	,@CatalogItemSID                 int               = null								-- not a base table column (default ignored)
	,@BookingCutOffDate              date              = null								-- not a base table column (default ignored)
	,@VendorExamOfferingID           varchar(25)       = null								-- not a base table column (default ignored)
	,@ExamOfferingRowGUID            uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsViewEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsEditEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsPDFDisplayed                 bit               = null								-- not a base table column (default ignored)
	,@PersonDocSID                   int               = null								-- not a base table column (default ignored)
	,@ApplicationUserSID             int               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantExam#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantExam#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantExam#Insert
			 @RegistrantSID                  = @RegistrantSID
			,@ExamSID                        = @ExamSID
			,@ExamDate                       = @ExamDate
			,@ExamResultDate                 = @ExamResultDate
			,@PassingScore                   = @PassingScore
			,@Score                          = @Score
			,@ExamStatusSID                  = @ExamStatusSID
			,@SchedulingPreferences          = @SchedulingPreferences
			,@AssignedLocation               = @AssignedLocation
			,@ExamReference                  = @ExamReference
			,@ExamOfferingSID                = @ExamOfferingSID
			,@InvoiceSID                     = @InvoiceSID
			,@ConfirmedTime                  = @ConfirmedTime
			,@CancelledTime                  = @CancelledTime
			,@ExamConfiguration              = @ExamConfiguration
			,@ExamResponses                  = @ExamResponses
			,@ProcessedTime                  = @ProcessedTime
			,@ProcessingComments             = @ProcessingComments
			,@UserDefinedColumns             = @UserDefinedColumns
			,@RegistrantExamXID              = @RegistrantExamXID
			,@LegacyKey                      = @LegacyKey
			,@CreateUser                     = @CreateUser
			,@IsReselected                   = @IsReselected
			,@zContext                       = @zContext
			,@ExamName                       = @ExamName
			,@ExamCategory                   = @ExamCategory
			,@ExamPassingScore               = @ExamPassingScore
			,@EffectiveTime                  = @EffectiveTime
			,@ExpiryTime                     = @ExpiryTime
			,@IsOnlineExam                   = @IsOnlineExam
			,@IsEnabledOnPortal              = @IsEnabledOnPortal
			,@ExamSequence                   = @ExamSequence
			,@CultureSID                     = @CultureSID
			,@LastVerifiedTime               = @LastVerifiedTime
			,@MinLagDaysBetweenAttempts      = @MinLagDaysBetweenAttempts
			,@MaxAttemptsPerYear             = @MaxAttemptsPerYear
			,@VendorExamID                   = @VendorExamID
			,@ExamRowGUID                    = @ExamRowGUID
			,@ExamStatusSCD                  = @ExamStatusSCD
			,@ExamStatusLabel                = @ExamStatusLabel
			,@ExamStatusSequence             = @ExamStatusSequence
			,@ExamStatusIsDefault            = @ExamStatusIsDefault
			,@ExamStatusRowGUID              = @ExamStatusRowGUID
			,@RegistrantPersonSID            = @RegistrantPersonSID
			,@RegistrantNo                   = @RegistrantNo
			,@YearOfInitialEmployment        = @YearOfInitialEmployment
			,@IsOnPublicRegistry             = @IsOnPublicRegistry
			,@CityNameOfBirth                = @CityNameOfBirth
			,@CountrySID                     = @CountrySID
			,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear           = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
			,@ArchivedTime                   = @ArchivedTime
			,@RegistrantRowGUID              = @RegistrantRowGUID
			,@InvoicePersonSID               = @InvoicePersonSID
			,@InvoiceDate                    = @InvoiceDate
			,@Tax1Label                      = @Tax1Label
			,@Tax1Rate                       = @Tax1Rate
			,@Tax1GLAccountCode              = @Tax1GLAccountCode
			,@Tax2Label                      = @Tax2Label
			,@Tax2Rate                       = @Tax2Rate
			,@Tax2GLAccountCode              = @Tax2GLAccountCode
			,@Tax3Label                      = @Tax3Label
			,@Tax3Rate                       = @Tax3Rate
			,@Tax3GLAccountCode              = @Tax3GLAccountCode
			,@RegistrationYear               = @RegistrationYear
			,@InvoiceCancelledTime           = @InvoiceCancelledTime
			,@ReasonSID                      = @ReasonSID
			,@IsRefund                       = @IsRefund
			,@ComplaintSID                   = @ComplaintSID
			,@InvoiceRowGUID                 = @InvoiceRowGUID
			,@ExamOfferingExamSID            = @ExamOfferingExamSID
			,@OrgSID                         = @OrgSID
			,@ExamTime                       = @ExamTime
			,@SeatingCapacity                = @SeatingCapacity
			,@CatalogItemSID                 = @CatalogItemSID
			,@BookingCutOffDate              = @BookingCutOffDate
			,@VendorExamOfferingID           = @VendorExamOfferingID
			,@ExamOfferingRowGUID            = @ExamOfferingRowGUID
			,@IsDeleteEnabled                = @IsDeleteEnabled
			,@IsViewEnabled                  = @IsViewEnabled
			,@IsEditEnabled                  = @IsEditEnabled
			,@IsPDFDisplayed                 = @IsPDFDisplayed
			,@PersonDocSID                   = @PersonDocSID
			,@ApplicationUserSID             = @ApplicationUserSID

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
