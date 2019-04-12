SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistration#Insert]
	 @RegistrationSID                  int               = null output			-- identity value assigned to the new record
	,@RegistrantSID                    int               = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistration#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.Registration table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Registration table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistration entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistration procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationCheck to test all rules.

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

	set @RegistrationSID = null																							-- initialize output parameter

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

		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @RegistrationXID = ltrim(rtrim(@RegistrationXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @RegistrationLabel = ltrim(rtrim(@RegistrationLabel))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @AddressBlockForPrint = ltrim(rtrim(@AddressBlockForPrint))
		set @AddressBlockForHTML = ltrim(rtrim(@AddressBlockForHTML))
		set @FutureRegistrationLabel = ltrim(rtrim(@FutureRegistrationLabel))
		set @FuturePracticeRegisterLabel = ltrim(rtrim(@FuturePracticeRegisterLabel))
		set @FutureRegisterSectionLabel = ltrim(rtrim(@FutureRegisterSectionLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@RegistrationXID) = 0 set @RegistrationXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@RegistrationLabel) = 0 set @RegistrationLabel = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@AddressBlockForPrint) = 0 set @AddressBlockForPrint = null
		if len(@AddressBlockForHTML) = 0 set @AddressBlockForHTML = null
		if len(@FutureRegistrationLabel) = 0 set @FutureRegistrationLabel = null
		if len(@FuturePracticeRegisterLabel) = 0 set @FuturePracticeRegisterLabel = null
		if len(@FutureRegisterSectionLabel) = 0 set @FutureRegisterSectionLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected               = isnull(@IsReselected              ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @PracticeRegisterSectionSID  is null select @PracticeRegisterSectionSID  = x.PracticeRegisterSectionSID from dbo.PracticeRegisterSection x where x.IsDefault = @ON and x.PracticeRegisterSID = @PracticeRegisterSID

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Apr 2018
		-- Call a subroutine to set defaults and expire previous registrations
		-- when moving to/from non-practicing registers.  See subroutine for
		-- details

		if @ExpiryTime is null or @EffectiveTime is null
		begin

			exec dbo.pRegistration#Insert$GetDefaults
				@RegistrantSID = @RegistrantSID output
			 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID output
			 ,@EffectiveTime = @EffectiveTime output
			 ,@ExpiryTime = @ExpiryTime output
			 ,@RegistrationYear = @RegistrationYear output
			 ,@PracticeRegisterSID = @PracticeRegisterSID output
			 ,@PersonSID = @RegistrantPersonSID;

		end;
		else if @EffectiveTime is not null
		begin
			set @RegistrationYear = dbo.fRegistrationYear(@EffectiveTime); -- for term permits expiry may be in different registration year
		end;

		-- Tim Edlund | Sep 2017
		-- The system depends on a specific format for registration numbers
		-- so is overridden here even when provided

		if @RegistrantNo is null and @RegistrantSID is not null
		begin

			select
				@RegistrantNo = r.RegistrantNo
			from
				dbo.Registrant r
			where
				r.RegistrantSID = @RegistrantSID;

		end;

		set @recordSID = 0;

		while (@recordSID = 0 or @@rowcount > 0) and @recordSID < 15
		begin
			set @recordSID += 1;

			select
				@RegistrationNo = r.RegistrantNo + '.' + ltrim(@RegistrationYear) + '.' + ltrim(@recordSID)
			from
				dbo.Registrant r
			where
				r.RegistrantSID = @RegistrantSID;

			select
				@rowsAffected = 1
			from
				dbo.Registration rl
			where
				rl.RegistrationNo = @RegistrationNo;
		end;

		-- Tim Edlund | Nov 2017
		-- Provide a more helpful error message in the situation where another
		-- registration already exists for this effective date for the registrant

		if exists
		(
			select
				1
			from
				dbo.Registration rl
			where
				rl.RegistrantSID = @RegistrantSID and rl.EffectiveTime = @EffectiveTime
		)
		begin

			if @RegistrantNo is null
			begin

				select
					@RegistrantNo = r.RegistrantNo
				from
					dbo.Registrant r
				where
					r.RegistrantSID = @RegistrantSID;

			end;

			exec sf.pMessage#Get
				@MessageSCD = 'Duplicate.Registration'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A registration/license already exists for %1 starting %2. Review registrations for this individual through the "People" option. A previously approved renewal may need to be withdrawn.'
			 ,@Arg1 = @RegistrantNo
			 ,@Arg2 = @EffectiveTime;

			raiserror(@errorText, 16, 1);
		end;
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
				r.RoutineName = 'pRegistration'
		)
		begin
		
			exec @errorNo = ext.pRegistration
				 @Mode                             = 'insert.pre'
				,@RegistrantSID                    = @RegistrantSID output
				,@PracticeRegisterSectionSID       = @PracticeRegisterSectionSID output
				,@RegistrationNo                   = @RegistrationNo output
				,@RegistrationYear                 = @RegistrationYear output
				,@EffectiveTime                    = @EffectiveTime output
				,@ExpiryTime                       = @ExpiryTime output
				,@CardPrintedTime                  = @CardPrintedTime output
				,@InvoiceSID                       = @InvoiceSID output
				,@ReasonSID                        = @ReasonSID output
				,@FormGUID                         = @FormGUID output
				,@UserDefinedColumns               = @UserDefinedColumns output
				,@RegistrationXID                  = @RegistrationXID output
				,@LegacyKey                        = @LegacyKey output
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
		
		end

		-- insert the record

		insert
			dbo.Registration
		(
			 RegistrantSID
			,PracticeRegisterSectionSID
			,RegistrationNo
			,RegistrationYear
			,EffectiveTime
			,ExpiryTime
			,CardPrintedTime
			,InvoiceSID
			,ReasonSID
			,FormGUID
			,UserDefinedColumns
			,RegistrationXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@PracticeRegisterSectionSID
			,@RegistrationNo
			,@RegistrationYear
			,@EffectiveTime
			,@ExpiryTime
			,@CardPrintedTime
			,@InvoiceSID
			,@ReasonSID
			,@FormGUID
			,@UserDefinedColumns
			,@RegistrationXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected    = @@rowcount
			,@RegistrationSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.Registration'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Cory Ng | Dec 2018
		-- If this is the first-active-practice type registration for this member
		-- then assign a new registration number if a separate sequence is used
		-- when members transition from applicant to registrant. This is bypassed
		-- if the previous registration is the default inactive register (eg:
		-- cancelled). If the registration was cancelled the reg # would already
		-- be assigned. This situation will only happen for converted registrants
		-- who do not have an initial active registration.

		if @legacyKey is null
		begin

			declare
				@firstActivePracticeRegistrationSID int
			 ,@currentRegistrantNo								varchar(50)
			 ,@reservedRegistrantNo								varchar(50);

			if not exists																												-- if previous registration is inactive, reg # is already assigned
			(
				select
					1
				from
					(
						select
							 r.RegistrationSID
							,lag(pr.IsDefaultInactivePractice) over (partition by r.RegistrantSID order by r.RegistrationYear) PreviousIsDefaultInactivePractice
						from
							dbo.Registration r
						join
							dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
						join
							dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
						where
							r.RegistrantSID =  @RegistrantSID
					) x
				where
					x.RegistrationSID = @RegistrationSID
				and
					x.PreviousIsDefaultInactivePractice = @ON
			)
			begin

				select
					@firstActivePracticeRegistrationSID = min(reg.RegistrationSID)
				from
					dbo.Registration						reg
				join
					dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID and pr.IsActivePractice = @ON
				where
					reg.RegistrantSID = @RegistrantSID;

				if @RegistrationSID = @firstActivePracticeRegistrationSID
				begin

					select
						@currentRegistrantNo = r.RegistrantNo
					from
						dbo.Registrant r
					where
						r.RegistrantSID = @RegistrantSID;

					select
						@reservedRegistrantNo = rc.ReservedRegistrantNo -- check for reserved# where registration is based on a reg change record
					from
						dbo.RegistrationChange rc
					where
						rc.RowGUID = @FormGUID

					if @reservedRegistrantNo is not null -- use a reserved# (provided by another system) or check for new number
					begin
						set @RegistrantNo = @reservedRegistrantNo
					end
					else
					begin

						exec dbo.pRegistrant#GetNextNo
							@Mode = 'REGISTRANT'
						 ,@RegistrantSID = @RegistrantSID
						 ,@RegistrantNo = @RegistrantNo output;

					end

					if @RegistrantNo <> @currentRegistrantNo
					begin

						update
							dbo.Registrant
						set
							RegistrantNo = @RegistrantNo
						 ,UpdateUser = @CreateUser
						 ,UpdateTime = sysdatetime()
						where
							RegistrantSID = @RegistrantSID;

					end;

				end;

			end

		end;

		-- Tim Edlund | Jul 2018
		-- Terminate employment records if member has moved to a register where
		-- terminations are requested and EffectiveTime values have
		-- been filled out	
			
		declare @now datetime = sf.fNow();

		if exists
		(
			select
				1
			from
				dbo.PracticeRegister pr
			where
				pr.PracticeRegisterSID = @PracticeRegisterSID and pr.IsEmploymentTerminated = @ON
		)
		begin

			update
				dbo.RegistrantEmployment
			set
				ExpiryTime = @now
			 ,UpdateUser = @CreateUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				RegistrantSID													= @RegistrantSID and EffectiveTime is not null -- effective time must be filled out for this action to apply
				and (ExpiryTime is null or ExpiryTime > @now);	-- not already expired or future dated expiry

		end;

		-- Tim Edlund | Sep 2018
		-- Terminate group membership if member has moved to a register
		-- where terminations are requested

		if exists
		(
			select
				1
			from
				dbo.PracticeRegister pr
			where
				pr.PracticeRegisterSID = @PracticeRegisterSID and pr.IsGroupMembershipTerminated = @ON
		)
		begin

			update
				sf.PersonGroupMember
			set
				ExpiryTime = @now
			 ,UpdateUser = @CreateUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				PersonSID = @RegistrantPersonSID and (ExpiryTime is null or ExpiryTime > @now); -- not already expired or future dated expiry

		end;

		-- Tim Edlund | Oct 2018
		-- Withdraw any open learning plans where member has moved to a
		-- register where CE reporting is not required

		if not exists
		(
			select
				1
			from
				dbo.PracticeRegisterSection prs
			join
				dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
			join
				dbo.LearningModel						lm on pr.LearningModelSID			= lm.LearningModelSID
			where
				prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID	-- section on the new registration
			and
				pr.IsLearningPlanEnabled = @ON		
		) -- no reference to a learning model for this register or it is disabled (no requirement for CE reporting)
		begin

			set @recordSID = null;

			select
				@recordSID = max(rlp.RegistrantLearningPlanSID)
			from
				dbo.RegistrantLearningPlan																												 rlp
			cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
			where
				rlp.RegistrantSID = @RegistrantSID and cs.IsInProgress = @ON; -- check for in-progress learning plan for the registrant

			if @recordSID is not null
			begin

				set @ReasonSID = null;

				select
					@ReasonSID = rsn.ReasonSID
				from
					dbo.Reason rsn
				where
					rsn.ReasonCode = 'LPLAN.WITHDRAWN.REGCHG';

				exec dbo.pRegistrantLearningPlan#Update
					@RegistrantLearningPlanSID = @recordSID
				 ,@ReasonSID = @ReasonSID
				 ,@NewFormStatusSCD = 'WITHDRAWN';

			end;
		end;

		-- Tim Edlund | Nov 2018
		-- Assign conditions-on-practice associated with this register
		-- if any.  Conditions may be set at the register level or
		-- at the section level.

		if exists(select 1 from dbo.PracticeRegisterRestriction prr where prr.PracticeRegisterSID = @PracticeRegisterSID)
		begin

			insert -- avoid EF sproc to improve performance
				dbo.RegistrantPracticeRestriction
			(
				RegistrantSID
			 ,PracticeRestrictionSID
			 ,IsDisplayedOnLicense
			 ,CreateUser
			 ,UpdateUser
			)
			select
				@RegistrantSID
				,prr.PracticeRestrictionSID
				,pr.IsDisplayedOnLicense
				,@CreateUser
				,@CreateUser
			from
				dbo.PracticeRegisterRestriction prr
			join
				dbo.PracticeRestriction pr on prr.PracticeRestrictionSID = pr.PracticeRestrictionSID
			where
				prr.PracticeRegisterSID																										 = @PracticeRegisterSID -- must match the register
				and
				(
					prr.PracticeRegisterSectionSID is null or prr.PracticeRegisterSectionSID = @PracticeRegisterSectionSID -- either section matches or is not specified (all sections)
				)
			and
				sf.fIsActive(prr.EffectiveTime, prr.ExpiryTime) = @ON -- ensure condition assignment is in effect

		end
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
				r.RoutineName = 'pRegistration'
		)
		begin
		
			exec @errorNo = ext.pRegistration
				 @Mode                             = 'insert.post'
				,@RegistrationSID                  = @RegistrationSID
				,@RegistrantSID                    = @RegistrantSID
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationSID
			from
				dbo.vRegistration ent
			where
				ent.RegistrationSID = @RegistrationSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationSID
				,ent.RegistrantSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationNo
				,ent.RegistrationYear
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.CardPrintedTime
				,ent.InvoiceSID
				,ent.ReasonSID
				,ent.FormGUID
				,ent.UserDefinedColumns
				,ent.RegistrationXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PracticeRegisterSID
				,ent.PracticeRegisterSectionLabel
				,ent.PracticeRegisterSectionIsDefault
				,ent.IsDisplayedOnLicense
				,ent.PracticeRegisterSectionIsActive
				,ent.PracticeRegisterSectionRowGUID
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
				,ent.InvoiceRegistrationYear
				,ent.CancelledTime
				,ent.InvoiceReasonSID
				,ent.IsRefund
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
				,ent.RegistrationYearLabel
				,ent.PracticeRegisterName
				,ent.PracticeRegisterLabel
				,ent.RegistrationLabel
				,ent.IsReadEnabled
				,ent.FirstName
				,ent.MiddleNames
				,ent.LastName
				,ent.AddressBlockForPrint
				,ent.AddressBlockForHTML
				,ent.FutureRegistrationLabel
				,ent.FutureRegistrationYear
				,ent.FuturePracticeRegisterSID
				,ent.FuturePracticeRegisterLabel
				,ent.FuturePracticeRegisterSectionSID
				,ent.FutureRegisterSectionLabel
				,ent.FutureEffectiveTime
				,ent.FutureExpiryTime
				,ent.FutureCardPrintedTime
				,ent.FutureInvoiceSID
				,ent.FutureReasonSID
				,ent.FutureFormGUID
			from
				dbo.vRegistration ent
			where
				ent.RegistrationSID = @RegistrationSID

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
