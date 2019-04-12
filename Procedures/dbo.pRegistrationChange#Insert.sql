SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChange#Insert]
	 @RegistrationChangeSID                  int               = null output-- identity value assigned to the new record
	,@RegistrationSID                        int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterSectionSID             int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                       smallint          = null				-- required! if not passed value must be set in custom logic prior to insert
	,@NextFollowUp                           date              = null				
	,@RegistrationEffective                  date              = null				
	,@ReservedRegistrantNo                   varchar(50)       = null				
	,@ConfirmationDraft                      nvarchar(max)     = null				
	,@ReasonSID                              int               = null				
	,@InvoiceSID                             int               = null				
	,@ComplaintSID                           int               = null				
	,@UserDefinedColumns                     xml               = null				
	,@RegistrationChangeXID                  varchar(150)      = null				
	,@LegacyKey                              nvarchar(50)      = null				
	,@CreateUser                             nvarchar(75)      = null				-- default: suser_sname()
	,@IsReselected                           tinyint           = null				-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                               xml               = null				-- other values defining context for the insert (if any)
	,@PracticeRegisterSID                    int               = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel           nvarchar(35)      = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDefault       bit               = null				-- not a base table column (default ignored)
	,@IsDisplayedOnLicense                   bit               = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsActive        bit               = null				-- not a base table column (default ignored)
	,@PracticeRegisterSectionRowGUID         uniqueidentifier  = null				-- not a base table column (default ignored)
	,@RegistrationRegistrantSID              int               = null				-- not a base table column (default ignored)
	,@RegistrationPracticeRegisterSectionSID int               = null				-- not a base table column (default ignored)
	,@RegistrationNo                         nvarchar(50)      = null				-- not a base table column (default ignored)
	,@RegistrationRegistrationYear           smallint          = null				-- not a base table column (default ignored)
	,@EffectiveTime                          datetime          = null				-- not a base table column (default ignored)
	,@ExpiryTime                             datetime          = null				-- not a base table column (default ignored)
	,@CardPrintedTime                        datetime          = null				-- not a base table column (default ignored)
	,@RegistrationInvoiceSID                 int               = null				-- not a base table column (default ignored)
	,@RegistrationReasonSID                  int               = null				-- not a base table column (default ignored)
	,@FormGUID                               uniqueidentifier  = null				-- not a base table column (default ignored)
	,@RegistrationRowGUID                    uniqueidentifier  = null				-- not a base table column (default ignored)
	,@ReasonGroupSID                         int               = null				-- not a base table column (default ignored)
	,@ReasonName                             nvarchar(50)      = null				-- not a base table column (default ignored)
	,@ReasonCode                             varchar(25)       = null				-- not a base table column (default ignored)
	,@ReasonSequence                         smallint          = null				-- not a base table column (default ignored)
	,@ToolTip                                nvarchar(500)     = null				-- not a base table column (default ignored)
	,@ReasonIsActive                         bit               = null				-- not a base table column (default ignored)
	,@ReasonRowGUID                          uniqueidentifier  = null				-- not a base table column (default ignored)
	,@ComplaintNo                            varchar(50)       = null				-- not a base table column (default ignored)
	,@ComplaintRegistrantSID                 int               = null				-- not a base table column (default ignored)
	,@ComplaintTypeSID                       int               = null				-- not a base table column (default ignored)
	,@ComplainantTypeSID                     int               = null				-- not a base table column (default ignored)
	,@ApplicationUserSID                     int               = null				-- not a base table column (default ignored)
	,@OpenedDate                             date              = null				-- not a base table column (default ignored)
	,@ConductStartDate                       date              = null				-- not a base table column (default ignored)
	,@ConductEndDate                         date              = null				-- not a base table column (default ignored)
	,@ComplaintSeveritySID                   int               = null				-- not a base table column (default ignored)
	,@IsDisplayedOnPublicRegistry            bit               = null				-- not a base table column (default ignored)
	,@ClosedDate                             date              = null				-- not a base table column (default ignored)
	,@DismissedDate                          date              = null				-- not a base table column (default ignored)
	,@ComplaintReasonSID                     int               = null				-- not a base table column (default ignored)
	,@FileExtension                          varchar(5)        = null				-- not a base table column (default ignored)
	,@ComplaintRowGUID                       uniqueidentifier  = null				-- not a base table column (default ignored)
	,@PersonSID                              int               = null				-- not a base table column (default ignored)
	,@InvoiceDate                            date              = null				-- not a base table column (default ignored)
	,@Tax1Label                              nvarchar(8)       = null				-- not a base table column (default ignored)
	,@Tax1Rate                               decimal(4,4)      = null				-- not a base table column (default ignored)
	,@Tax1GLAccountCode                      varchar(50)       = null				-- not a base table column (default ignored)
	,@Tax2Label                              nvarchar(8)       = null				-- not a base table column (default ignored)
	,@Tax2Rate                               decimal(4,4)      = null				-- not a base table column (default ignored)
	,@Tax2GLAccountCode                      varchar(50)       = null				-- not a base table column (default ignored)
	,@Tax3Label                              nvarchar(8)       = null				-- not a base table column (default ignored)
	,@Tax3Rate                               decimal(4,4)      = null				-- not a base table column (default ignored)
	,@Tax3GLAccountCode                      varchar(50)       = null				-- not a base table column (default ignored)
	,@InvoiceRegistrationYear                smallint          = null				-- not a base table column (default ignored)
	,@CancelledTime                          datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@InvoiceReasonSID                       int               = null				-- not a base table column (default ignored)
	,@IsRefund                               bit               = null				-- not a base table column (default ignored)
	,@InvoiceComplaintSID                    int               = null				-- not a base table column (default ignored)
	,@InvoiceRowGUID                         uniqueidentifier  = null				-- not a base table column (default ignored)
	,@IsDeleteEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsViewEnabled                          bit               = null				-- not a base table column (default ignored)
	,@IsEditEnabled                          bit               = null				-- not a base table column (default ignored)
	,@IsApproveEnabled                       bit               = null				-- not a base table column (default ignored)
	,@IsRejectEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsUnlockEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsWithdrawalEnabled                    bit               = null				-- not a base table column (default ignored)
	,@IsInProgress                           bit               = null				-- not a base table column (default ignored)
	,@FormStatusSID                          int               = null				-- not a base table column (default ignored)
	,@FormStatusSCD                          varchar(25)       = null				-- not a base table column (default ignored)
	,@FormStatusLabel                        nvarchar(35)      = null				-- not a base table column (default ignored)
	,@LastStatusChangeUser                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@LastStatusChangeTime                   datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@FormOwnerSID                           int               = null				-- not a base table column (default ignored)
	,@FormOwnerSCD                           varchar(25)       = null				-- not a base table column (default ignored)
	,@FormOwnerLabel                         nvarchar(35)      = null				-- not a base table column (default ignored)
	,@IsPDFDisplayed                         bit               = null				-- not a base table column (default ignored)
	,@PersonDocSID                           int               = null				-- not a base table column (default ignored)
	,@TotalDue                               decimal(11,2)     = null				-- not a base table column (default ignored)
	,@IsUnPaid                               bit               = null				-- not a base table column (default ignored)
	,@PersonMailingAddressSID                int               = null				-- not a base table column (default ignored)
	,@PersonStreetAddress1                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@PersonStreetAddress2                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@PersonStreetAddress3                   nvarchar(75)      = null				-- not a base table column (default ignored)
	,@PersonCityName                         nvarchar(30)      = null				-- not a base table column (default ignored)
	,@PersonStateProvinceName                nvarchar(30)      = null				-- not a base table column (default ignored)
	,@PersonPostalCode                       nvarchar(10)      = null				-- not a base table column (default ignored)
	,@PersonCountryName                      nvarchar(50)      = null				-- not a base table column (default ignored)
	,@PersonCitySID                          int               = null				-- not a base table column (default ignored)
	,@RegistrantPersonSID                    int               = null				-- not a base table column (default ignored)
	,@RegistrationYearLabel                  varchar(9)        = null				-- not a base table column (default ignored)
	,@PracticeRegisterLabel                  nvarchar(35)      = null				-- not a base table column (default ignored)
	,@PracticeRegisterName                   nvarchar(65)      = null				-- not a base table column (default ignored)
	,@RegistrationChangeLabel                nvarchar(100)     = null				-- not a base table column (default ignored)
	,@IsRegisterChange                       bit               = null				-- not a base table column (default ignored)
	,@HasOpenAudit                           bit               = null				-- not a base table column (default ignored)
	,@NewFormStatusSCD                       varchar(25)       = null				-- not a base table column (default ignored)
	,@ReasonSIDOnApprove                     int               = null				-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChange#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrationChange table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationChange table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrationChange entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationChange procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationChangeCheck to test all rules.

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

	set @RegistrationChangeSID = null																				-- initialize output parameter

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

		set @ReservedRegistrantNo = ltrim(rtrim(@ReservedRegistrantNo))
		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrationChangeXID = ltrim(rtrim(@RegistrationChangeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
		set @FormStatusSCD = ltrim(rtrim(@FormStatusSCD))
		set @FormStatusLabel = ltrim(rtrim(@FormStatusLabel))
		set @LastStatusChangeUser = ltrim(rtrim(@LastStatusChangeUser))
		set @FormOwnerSCD = ltrim(rtrim(@FormOwnerSCD))
		set @FormOwnerLabel = ltrim(rtrim(@FormOwnerLabel))
		set @PersonStreetAddress1 = ltrim(rtrim(@PersonStreetAddress1))
		set @PersonStreetAddress2 = ltrim(rtrim(@PersonStreetAddress2))
		set @PersonStreetAddress3 = ltrim(rtrim(@PersonStreetAddress3))
		set @PersonCityName = ltrim(rtrim(@PersonCityName))
		set @PersonStateProvinceName = ltrim(rtrim(@PersonStateProvinceName))
		set @PersonPostalCode = ltrim(rtrim(@PersonPostalCode))
		set @PersonCountryName = ltrim(rtrim(@PersonCountryName))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @RegistrationChangeLabel = ltrim(rtrim(@RegistrationChangeLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ReservedRegistrantNo) = 0 set @ReservedRegistrantNo = null
		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrationChangeXID) = 0 set @RegistrationChangeXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
		if len(@FormStatusSCD) = 0 set @FormStatusSCD = null
		if len(@FormStatusLabel) = 0 set @FormStatusLabel = null
		if len(@LastStatusChangeUser) = 0 set @LastStatusChangeUser = null
		if len(@FormOwnerSCD) = 0 set @FormOwnerSCD = null
		if len(@FormOwnerLabel) = 0 set @FormOwnerLabel = null
		if len(@PersonStreetAddress1) = 0 set @PersonStreetAddress1 = null
		if len(@PersonStreetAddress2) = 0 set @PersonStreetAddress2 = null
		if len(@PersonStreetAddress3) = 0 set @PersonStreetAddress3 = null
		if len(@PersonCityName) = 0 set @PersonCityName = null
		if len(@PersonStateProvinceName) = 0 set @PersonStateProvinceName = null
		if len(@PersonPostalCode) = 0 set @PersonPostalCode = null
		if len(@PersonCountryName) = 0 set @PersonCountryName = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@RegistrationChangeLabel) = 0 set @RegistrationChangeLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

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
		-- The registration year defaults to the current one.

		if @RegistrationYear is null
		begin
			set @RegistrationYear = dbo.fRegistrationYear#Current();
		end;

		-- Tim Edlund | Apr 2018
		-- Block insert if another change form is
		-- open for the same registration

		if @RegistrationSID is not null
		begin

			exec dbo.pRegistration#CheckPending
				@RegistrationSID = @RegistrationSID
			 ,@FormTypeCode = 'REGCHANGE';

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
				r.RoutineName = 'pRegistrationChange'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChange
				 @Mode                                   = 'insert.pre'
				,@RegistrationSID                        = @RegistrationSID output
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID output
				,@RegistrationYear                       = @RegistrationYear output
				,@NextFollowUp                           = @NextFollowUp output
				,@RegistrationEffective                  = @RegistrationEffective output
				,@ReservedRegistrantNo                   = @ReservedRegistrantNo output
				,@ConfirmationDraft                      = @ConfirmationDraft output
				,@ReasonSID                              = @ReasonSID output
				,@InvoiceSID                             = @InvoiceSID output
				,@ComplaintSID                           = @ComplaintSID output
				,@UserDefinedColumns                     = @UserDefinedColumns output
				,@RegistrationChangeXID                  = @RegistrationChangeXID output
				,@LegacyKey                              = @LegacyKey output
				,@CreateUser                             = @CreateUser
				,@IsReselected                           = @IsReselected
				,@zContext                               = @zContext
				,@PracticeRegisterSID                    = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel           = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault       = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                   = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive        = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID         = @PracticeRegisterSectionRowGUID
				,@RegistrationRegistrantSID              = @RegistrationRegistrantSID
				,@RegistrationPracticeRegisterSectionSID = @RegistrationPracticeRegisterSectionSID
				,@RegistrationNo                         = @RegistrationNo
				,@RegistrationRegistrationYear           = @RegistrationRegistrationYear
				,@EffectiveTime                          = @EffectiveTime
				,@ExpiryTime                             = @ExpiryTime
				,@CardPrintedTime                        = @CardPrintedTime
				,@RegistrationInvoiceSID                 = @RegistrationInvoiceSID
				,@RegistrationReasonSID                  = @RegistrationReasonSID
				,@FormGUID                               = @FormGUID
				,@RegistrationRowGUID                    = @RegistrationRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
				,@ComplaintNo                            = @ComplaintNo
				,@ComplaintRegistrantSID                 = @ComplaintRegistrantSID
				,@ComplaintTypeSID                       = @ComplaintTypeSID
				,@ComplainantTypeSID                     = @ComplainantTypeSID
				,@ApplicationUserSID                     = @ApplicationUserSID
				,@OpenedDate                             = @OpenedDate
				,@ConductStartDate                       = @ConductStartDate
				,@ConductEndDate                         = @ConductEndDate
				,@ComplaintSeveritySID                   = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry            = @IsDisplayedOnPublicRegistry
				,@ClosedDate                             = @ClosedDate
				,@DismissedDate                          = @DismissedDate
				,@ComplaintReasonSID                     = @ComplaintReasonSID
				,@FileExtension                          = @FileExtension
				,@ComplaintRowGUID                       = @ComplaintRowGUID
				,@PersonSID                              = @PersonSID
				,@InvoiceDate                            = @InvoiceDate
				,@Tax1Label                              = @Tax1Label
				,@Tax1Rate                               = @Tax1Rate
				,@Tax1GLAccountCode                      = @Tax1GLAccountCode
				,@Tax2Label                              = @Tax2Label
				,@Tax2Rate                               = @Tax2Rate
				,@Tax2GLAccountCode                      = @Tax2GLAccountCode
				,@Tax3Label                              = @Tax3Label
				,@Tax3Rate                               = @Tax3Rate
				,@Tax3GLAccountCode                      = @Tax3GLAccountCode
				,@InvoiceRegistrationYear                = @InvoiceRegistrationYear
				,@CancelledTime                          = @CancelledTime
				,@InvoiceReasonSID                       = @InvoiceReasonSID
				,@IsRefund                               = @IsRefund
				,@InvoiceComplaintSID                    = @InvoiceComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@FormStatusSID                          = @FormStatusSID
				,@FormStatusSCD                          = @FormStatusSCD
				,@FormStatusLabel                        = @FormStatusLabel
				,@LastStatusChangeUser                   = @LastStatusChangeUser
				,@LastStatusChangeTime                   = @LastStatusChangeTime
				,@FormOwnerSID                           = @FormOwnerSID
				,@FormOwnerSCD                           = @FormOwnerSCD
				,@FormOwnerLabel                         = @FormOwnerLabel
				,@IsPDFDisplayed                         = @IsPDFDisplayed
				,@PersonDocSID                           = @PersonDocSID
				,@TotalDue                               = @TotalDue
				,@IsUnPaid                               = @IsUnPaid
				,@PersonMailingAddressSID                = @PersonMailingAddressSID
				,@PersonStreetAddress1                   = @PersonStreetAddress1
				,@PersonStreetAddress2                   = @PersonStreetAddress2
				,@PersonStreetAddress3                   = @PersonStreetAddress3
				,@PersonCityName                         = @PersonCityName
				,@PersonStateProvinceName                = @PersonStateProvinceName
				,@PersonPostalCode                       = @PersonPostalCode
				,@PersonCountryName                      = @PersonCountryName
				,@PersonCitySID                          = @PersonCitySID
				,@RegistrantPersonSID                    = @RegistrantPersonSID
				,@RegistrationYearLabel                  = @RegistrationYearLabel
				,@PracticeRegisterLabel                  = @PracticeRegisterLabel
				,@PracticeRegisterName                   = @PracticeRegisterName
				,@RegistrationChangeLabel                = @RegistrationChangeLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end

		-- insert the record

		insert
			dbo.RegistrationChange
		(
			 RegistrationSID
			,PracticeRegisterSectionSID
			,RegistrationYear
			,NextFollowUp
			,RegistrationEffective
			,ReservedRegistrantNo
			,ConfirmationDraft
			,ReasonSID
			,InvoiceSID
			,ComplaintSID
			,UserDefinedColumns
			,RegistrationChangeXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationSID
			,@PracticeRegisterSectionSID
			,@RegistrationYear
			,@NextFollowUp
			,@RegistrationEffective
			,@ReservedRegistrantNo
			,@ConfirmationDraft
			,@ReasonSID
			,@InvoiceSID
			,@ComplaintSID
			,@UserDefinedColumns
			,@RegistrationChangeXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected          = @@rowcount
			,@RegistrationChangeSID = scope_identity()													-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrationChange'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationChangeSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Apr 2018
		-- Create the initial status for the record applying the
		-- default status (expected to be "NEW" or similar)

		insert
			dbo.RegistrationChangeStatus
		(
			 RegistrationChangeSID
			,FormStatusSID
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationChangeSID
			,fs.FormStatusSID
			,@CreateUser
			,@CreateUser
		from
			sf.FormStatus fs
		where
			fs.IsDefault = @ON

		-- Cory Ng | Mar 2019
		-- Insert the requirements associated with this registration change
		-- from the template table (if any).  The EF sproc is avoided to
		-- improve performance. Only requirements that aren't declarations
		-- are pulled

		insert
			dbo.RegistrationChangeRequirement
		(
			RegistrationChangeSID
		 ,RegistrationRequirementSID
		 ,ExpiryMonths
		 ,RequirementStatusSID
		 ,RequirementSequence
		)
		select
			rc.RegistrationChangeSID
		 ,prcr.RegistrationRequirementSID
		 ,prcr.ExpiryMonths
		 ,rs.RequirementStatusSID
		 ,prcr.RequirementSequence
		from
			dbo.RegistrationChange								rc
		join
			dbo.Registration									rlFR on rc.RegistrationSID								= rlFR.RegistrationSID
		join
			dbo.PracticeRegisterSection						prsFR on rlFR.PracticeRegisterSectionSID			= prsFR.PracticeRegisterSectionSID
		join
			dbo.PracticeRegisterChange			prcm on prsFR.PracticeRegisterSID							= prcm.PracticeRegisterSID
																										and rc.PracticeRegisterSectionSID			= prcm.PracticeRegisterSectionSID
		join
			dbo.PracticeRegisterChangeRequirement prcr on prcm.PracticeRegisterChangeSID = prcr.PracticeRegisterChangeSID
		join
			dbo.RegistrationRequirement rr on prcr.RegistrationRequirementSID = rr.RegistrationRequirementSID
		join
			dbo.RegistrationRequirementType rrt on rr.RegistrationRequirementTypeSID = rrt.RegistrationRequirementTypeSID
		join
			dbo.RequirementStatus									rs on rs.IsDefault														= @ON
		where
			rc.RegistrationChangeSID = @RegistrationChangeSID
		and
			rrt.RegistrationRequirementTypeCode not like 'S!%.DEC'
		order by
			prcr.RequirementSequence
		 ,prcr.PracticeRegisterChangeSID;
		
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
				r.RoutineName = 'pRegistrationChange'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChange
				 @Mode                                   = 'insert.post'
				,@RegistrationChangeSID                  = @RegistrationChangeSID
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@NextFollowUp                           = @NextFollowUp
				,@RegistrationEffective                  = @RegistrationEffective
				,@ReservedRegistrantNo                   = @ReservedRegistrantNo
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ComplaintSID                           = @ComplaintSID
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@RegistrationChangeXID                  = @RegistrationChangeXID
				,@LegacyKey                              = @LegacyKey
				,@CreateUser                             = @CreateUser
				,@IsReselected                           = @IsReselected
				,@zContext                               = @zContext
				,@PracticeRegisterSID                    = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel           = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault       = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                   = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive        = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID         = @PracticeRegisterSectionRowGUID
				,@RegistrationRegistrantSID              = @RegistrationRegistrantSID
				,@RegistrationPracticeRegisterSectionSID = @RegistrationPracticeRegisterSectionSID
				,@RegistrationNo                         = @RegistrationNo
				,@RegistrationRegistrationYear           = @RegistrationRegistrationYear
				,@EffectiveTime                          = @EffectiveTime
				,@ExpiryTime                             = @ExpiryTime
				,@CardPrintedTime                        = @CardPrintedTime
				,@RegistrationInvoiceSID                 = @RegistrationInvoiceSID
				,@RegistrationReasonSID                  = @RegistrationReasonSID
				,@FormGUID                               = @FormGUID
				,@RegistrationRowGUID                    = @RegistrationRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
				,@ComplaintNo                            = @ComplaintNo
				,@ComplaintRegistrantSID                 = @ComplaintRegistrantSID
				,@ComplaintTypeSID                       = @ComplaintTypeSID
				,@ComplainantTypeSID                     = @ComplainantTypeSID
				,@ApplicationUserSID                     = @ApplicationUserSID
				,@OpenedDate                             = @OpenedDate
				,@ConductStartDate                       = @ConductStartDate
				,@ConductEndDate                         = @ConductEndDate
				,@ComplaintSeveritySID                   = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry            = @IsDisplayedOnPublicRegistry
				,@ClosedDate                             = @ClosedDate
				,@DismissedDate                          = @DismissedDate
				,@ComplaintReasonSID                     = @ComplaintReasonSID
				,@FileExtension                          = @FileExtension
				,@ComplaintRowGUID                       = @ComplaintRowGUID
				,@PersonSID                              = @PersonSID
				,@InvoiceDate                            = @InvoiceDate
				,@Tax1Label                              = @Tax1Label
				,@Tax1Rate                               = @Tax1Rate
				,@Tax1GLAccountCode                      = @Tax1GLAccountCode
				,@Tax2Label                              = @Tax2Label
				,@Tax2Rate                               = @Tax2Rate
				,@Tax2GLAccountCode                      = @Tax2GLAccountCode
				,@Tax3Label                              = @Tax3Label
				,@Tax3Rate                               = @Tax3Rate
				,@Tax3GLAccountCode                      = @Tax3GLAccountCode
				,@InvoiceRegistrationYear                = @InvoiceRegistrationYear
				,@CancelledTime                          = @CancelledTime
				,@InvoiceReasonSID                       = @InvoiceReasonSID
				,@IsRefund                               = @IsRefund
				,@InvoiceComplaintSID                    = @InvoiceComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@FormStatusSID                          = @FormStatusSID
				,@FormStatusSCD                          = @FormStatusSCD
				,@FormStatusLabel                        = @FormStatusLabel
				,@LastStatusChangeUser                   = @LastStatusChangeUser
				,@LastStatusChangeTime                   = @LastStatusChangeTime
				,@FormOwnerSID                           = @FormOwnerSID
				,@FormOwnerSCD                           = @FormOwnerSCD
				,@FormOwnerLabel                         = @FormOwnerLabel
				,@IsPDFDisplayed                         = @IsPDFDisplayed
				,@PersonDocSID                           = @PersonDocSID
				,@TotalDue                               = @TotalDue
				,@IsUnPaid                               = @IsUnPaid
				,@PersonMailingAddressSID                = @PersonMailingAddressSID
				,@PersonStreetAddress1                   = @PersonStreetAddress1
				,@PersonStreetAddress2                   = @PersonStreetAddress2
				,@PersonStreetAddress3                   = @PersonStreetAddress3
				,@PersonCityName                         = @PersonCityName
				,@PersonStateProvinceName                = @PersonStateProvinceName
				,@PersonPostalCode                       = @PersonPostalCode
				,@PersonCountryName                      = @PersonCountryName
				,@PersonCitySID                          = @PersonCitySID
				,@RegistrantPersonSID                    = @RegistrantPersonSID
				,@RegistrationYearLabel                  = @RegistrationYearLabel
				,@PracticeRegisterLabel                  = @PracticeRegisterLabel
				,@PracticeRegisterName                   = @PracticeRegisterName
				,@RegistrationChangeLabel                = @RegistrationChangeLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationChangeSID
			from
				dbo.vRegistrationChange ent
			where
				ent.RegistrationChangeSID = @RegistrationChangeSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationChangeSID
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.NextFollowUp
				,ent.RegistrationEffective
				,ent.ReservedRegistrantNo
				,ent.ConfirmationDraft
				,ent.ReasonSID
				,ent.InvoiceSID
				,ent.ComplaintSID
				,ent.UserDefinedColumns
				,ent.RegistrationChangeXID
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
				,ent.RegistrationRegistrantSID
				,ent.RegistrationPracticeRegisterSectionSID
				,ent.RegistrationNo
				,ent.RegistrationRegistrationYear
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.CardPrintedTime
				,ent.RegistrationInvoiceSID
				,ent.RegistrationReasonSID
				,ent.FormGUID
				,ent.RegistrationRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.ComplaintNo
				,ent.ComplaintRegistrantSID
				,ent.ComplaintTypeSID
				,ent.ComplainantTypeSID
				,ent.ApplicationUserSID
				,ent.OpenedDate
				,ent.ConductStartDate
				,ent.ConductEndDate
				,ent.ComplaintSeveritySID
				,ent.IsDisplayedOnPublicRegistry
				,ent.ClosedDate
				,ent.DismissedDate
				,ent.ComplaintReasonSID
				,ent.FileExtension
				,ent.ComplaintRowGUID
				,ent.PersonSID
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
				,ent.InvoiceComplaintSID
				,ent.InvoiceRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsApproveEnabled
				,ent.IsRejectEnabled
				,ent.IsUnlockEnabled
				,ent.IsWithdrawalEnabled
				,ent.IsInProgress
				,ent.FormStatusSID
				,ent.FormStatusSCD
				,ent.FormStatusLabel
				,ent.LastStatusChangeUser
				,ent.LastStatusChangeTime
				,ent.FormOwnerSID
				,ent.FormOwnerSCD
				,ent.FormOwnerLabel
				,ent.IsPDFDisplayed
				,ent.PersonDocSID
				,ent.TotalDue
				,ent.IsUnPaid
				,ent.PersonMailingAddressSID
				,ent.PersonStreetAddress1
				,ent.PersonStreetAddress2
				,ent.PersonStreetAddress3
				,ent.PersonCityName
				,ent.PersonStateProvinceName
				,ent.PersonPostalCode
				,ent.PersonCountryName
				,ent.PersonCitySID
				,ent.RegistrantPersonSID
				,ent.RegistrationYearLabel
				,ent.PracticeRegisterLabel
				,ent.PracticeRegisterName
				,ent.RegistrationChangeLabel
				,ent.IsRegisterChange
				,ent.HasOpenAudit
				,ent.NewFormStatusSCD
				,ent.ReasonSIDOnApprove
			from
				dbo.vRegistrationChange ent
			where
				ent.RegistrationChangeSID = @RegistrationChangeSID

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
