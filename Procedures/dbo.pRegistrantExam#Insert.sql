SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantExam#Insert]
	 @RegistrantExamSID              int               = null output				-- identity value assigned to the new record
	,@RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistrantExam#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantExam table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantExam table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantExam entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantExam procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantExamCheck to test all rules.

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

	set @RegistrantExamSID = null																						-- initialize output parameter

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

		set @SchedulingPreferences = ltrim(rtrim(@SchedulingPreferences))
		set @AssignedLocation = ltrim(rtrim(@AssignedLocation))
		set @ExamReference = ltrim(rtrim(@ExamReference))
		set @ProcessingComments = ltrim(rtrim(@ProcessingComments))
		set @RegistrantExamXID = ltrim(rtrim(@RegistrantExamXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @ExamName = ltrim(rtrim(@ExamName))
		set @ExamCategory = ltrim(rtrim(@ExamCategory))
		set @VendorExamID = ltrim(rtrim(@VendorExamID))
		set @ExamStatusSCD = ltrim(rtrim(@ExamStatusSCD))
		set @ExamStatusLabel = ltrim(rtrim(@ExamStatusLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @VendorExamOfferingID = ltrim(rtrim(@VendorExamOfferingID))

		-- set zero length strings to null to avoid storing them in the record

		if len(@SchedulingPreferences) = 0 set @SchedulingPreferences = null
		if len(@AssignedLocation) = 0 set @AssignedLocation = null
		if len(@ExamReference) = 0 set @ExamReference = null
		if len(@ProcessingComments) = 0 set @ProcessingComments = null
		if len(@RegistrantExamXID) = 0 set @RegistrantExamXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@ExamName) = 0 set @ExamName = null
		if len(@ExamCategory) = 0 set @ExamCategory = null
		if len(@VendorExamID) = 0 set @VendorExamID = null
		if len(@ExamStatusSCD) = 0 set @ExamStatusSCD = null
		if len(@ExamStatusLabel) = 0 set @ExamStatusLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@VendorExamOfferingID) = 0 set @VendorExamOfferingID = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected          = isnull(@IsReselected         ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ExamStatusSCD is not null
		begin
		
			select
				@ExamStatusSID = x.ExamStatusSID
			from
				dbo.ExamStatus x
			where
				x.ExamStatusSCD = @ExamStatusSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @ExamStatusSID  is null select @ExamStatusSID  = x.ExamStatusSID from dbo.ExamStatus x where x.IsDefault = @ON

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
				r.RoutineName = 'pRegistrantExam'
		)
		begin
		
			exec @errorNo = ext.pRegistrantExam
				 @Mode                           = 'insert.pre'
				,@RegistrantSID                  = @RegistrantSID output
				,@ExamSID                        = @ExamSID output
				,@ExamDate                       = @ExamDate output
				,@ExamResultDate                 = @ExamResultDate output
				,@PassingScore                   = @PassingScore output
				,@Score                          = @Score output
				,@ExamStatusSID                  = @ExamStatusSID output
				,@SchedulingPreferences          = @SchedulingPreferences output
				,@AssignedLocation               = @AssignedLocation output
				,@ExamReference                  = @ExamReference output
				,@ExamOfferingSID                = @ExamOfferingSID output
				,@InvoiceSID                     = @InvoiceSID output
				,@ConfirmedTime                  = @ConfirmedTime output
				,@CancelledTime                  = @CancelledTime output
				,@ExamConfiguration              = @ExamConfiguration output
				,@ExamResponses                  = @ExamResponses output
				,@ProcessedTime                  = @ProcessedTime output
				,@ProcessingComments             = @ProcessingComments output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantExamXID              = @RegistrantExamXID output
				,@LegacyKey                      = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.RegistrantExam
		(
			 RegistrantSID
			,ExamSID
			,ExamDate
			,ExamResultDate
			,PassingScore
			,Score
			,ExamStatusSID
			,SchedulingPreferences
			,AssignedLocation
			,ExamReference
			,ExamOfferingSID
			,InvoiceSID
			,ConfirmedTime
			,CancelledTime
			,ExamConfiguration
			,ExamResponses
			,ProcessedTime
			,ProcessingComments
			,UserDefinedColumns
			,RegistrantExamXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@ExamSID
			,@ExamDate
			,@ExamResultDate
			,@PassingScore
			,@Score
			,@ExamStatusSID
			,@SchedulingPreferences
			,@AssignedLocation
			,@ExamReference
			,@ExamOfferingSID
			,@InvoiceSID
			,@ConfirmedTime
			,@CancelledTime
			,@ExamConfiguration
			,@ExamResponses
			,@ProcessedTime
			,@ProcessingComments
			,@UserDefinedColumns
			,@RegistrantExamXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected      = @@rowcount
			,@RegistrantExamSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantExam'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantExamSID
			
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
				r.RoutineName = 'pRegistrantExam'
		)
		begin
		
			exec @errorNo = ext.pRegistrantExam
				 @Mode                           = 'insert.post'
				,@RegistrantExamSID              = @RegistrantExamSID
				,@RegistrantSID                  = @RegistrantSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantExamSID
			from
				dbo.vRegistrantExam ent
			where
				ent.RegistrantExamSID = @RegistrantExamSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantExamSID
				,ent.RegistrantSID
				,ent.ExamSID
				,ent.ExamDate
				,ent.ExamResultDate
				,ent.PassingScore
				,ent.Score
				,ent.ExamStatusSID
				,ent.SchedulingPreferences
				,ent.AssignedLocation
				,ent.ExamReference
				,ent.ExamOfferingSID
				,ent.InvoiceSID
				,ent.ConfirmedTime
				,ent.CancelledTime
				,ent.ExamConfiguration
				,ent.ExamResponses
				,ent.ProcessedTime
				,ent.ProcessingComments
				,ent.UserDefinedColumns
				,ent.RegistrantExamXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ExamName
				,ent.ExamCategory
				,ent.ExamPassingScore
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsOnlineExam
				,ent.IsEnabledOnPortal
				,ent.ExamSequence
				,ent.CultureSID
				,ent.LastVerifiedTime
				,ent.MinLagDaysBetweenAttempts
				,ent.MaxAttemptsPerYear
				,ent.VendorExamID
				,ent.ExamRowGUID
				,ent.ExamStatusSCD
				,ent.ExamStatusLabel
				,ent.ExamStatusSequence
				,ent.ExamStatusIsDefault
				,ent.ExamStatusRowGUID
				,ent.RegistrantPersonSID
				,ent.RegistrantNo
				,ent.YearOfInitialEmployment
				,ent.IsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.InvoicePersonSID
				,ent.InvoiceDate
				,ent.Tax1Label
				,ent.Tax1Rate
				,ent.Tax1GLAccountCode
				,ent.Tax2Label
				,ent.Tax2Rate
				,ent.Tax2GLAccountCode
				,ent.Tax3Label
				,ent.Tax3Rate
				,ent.Tax3GLAccountCode
				,ent.RegistrationYear
				,ent.InvoiceCancelledTime
				,ent.ReasonSID
				,ent.IsRefund
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
				,ent.ExamOfferingExamSID
				,ent.OrgSID
				,ent.ExamTime
				,ent.SeatingCapacity
				,ent.CatalogItemSID
				,ent.BookingCutOffDate
				,ent.VendorExamOfferingID
				,ent.ExamOfferingRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsPDFDisplayed
				,ent.PersonDocSID
				,ent.ApplicationUserSID
			from
				dbo.vRegistrantExam ent
			where
				ent.RegistrantExamSID = @RegistrantExamSID

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
