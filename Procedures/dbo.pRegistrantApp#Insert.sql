SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantApp#Insert]
	 @RegistrantAppSID                       int               = null output-- identity value assigned to the new record
	,@RegistrationSID                        int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterSectionSID             int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                       smallint          = null				-- default: dbo.fRegistrationYear#Current()
	,@FormVersionSID                         int               = null				-- required! if not passed value must be set in custom logic prior to insert
	,@OrgSID                                 int               = null				
	,@FormResponseDraft                      xml               = null				-- default: CONVERT(xml,N'<FormResponses />')
	,@LastValidateTime                       datetimeoffset(7) = null				
	,@AdminComments                          xml               = null				-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp                           date              = null				
	,@PendingReviewers                       xml               = null				
	,@RegistrationEffective                  date              = null				
	,@ConfirmationDraft                      nvarchar(max)     = null				
	,@IsAutoApprovalEnabled                  bit               = null				-- default: CONVERT(bit,(0))
	,@ReasonSID                              int               = null				
	,@InvoiceSID                             int               = null				
	,@ReviewReasonList                       xml               = null				
	,@UserDefinedColumns                     xml               = null				
	,@RegistrantAppXID                       varchar(150)      = null				
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
	,@RegistrantSID                          int               = null				-- not a base table column (default ignored)
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
	,@FormSID                                int               = null				-- not a base table column (default ignored)
	,@VersionNo                              smallint          = null				-- not a base table column (default ignored)
	,@RevisionNo                             smallint          = null				-- not a base table column (default ignored)
	,@IsSaveDisplayed                        bit               = null				-- not a base table column (default ignored)
	,@ApprovedTime                           datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@FormVersionRowGUID                     uniqueidentifier  = null				-- not a base table column (default ignored)
	,@ReasonGroupSID                         int               = null				-- not a base table column (default ignored)
	,@ReasonName                             nvarchar(50)      = null				-- not a base table column (default ignored)
	,@ReasonCode                             varchar(25)       = null				-- not a base table column (default ignored)
	,@ReasonSequence                         smallint          = null				-- not a base table column (default ignored)
	,@ToolTip                                nvarchar(500)     = null				-- not a base table column (default ignored)
	,@ReasonIsActive                         bit               = null				-- not a base table column (default ignored)
	,@ReasonRowGUID                          uniqueidentifier  = null				-- not a base table column (default ignored)
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
	,@ComplaintSID                           int               = null				-- not a base table column (default ignored)
	,@InvoiceRowGUID                         uniqueidentifier  = null				-- not a base table column (default ignored)
	,@ParentOrgSID                           int               = null				-- not a base table column (default ignored)
	,@OrgTypeSID                             int               = null				-- not a base table column (default ignored)
	,@OrgName                                nvarchar(150)     = null				-- not a base table column (default ignored)
	,@OrgLabel                               nvarchar(35)      = null				-- not a base table column (default ignored)
	,@StreetAddress1                         nvarchar(75)      = null				-- not a base table column (default ignored)
	,@StreetAddress2                         nvarchar(75)      = null				-- not a base table column (default ignored)
	,@StreetAddress3                         nvarchar(75)      = null				-- not a base table column (default ignored)
	,@CitySID                                int               = null				-- not a base table column (default ignored)
	,@PostalCode                             varchar(10)       = null				-- not a base table column (default ignored)
	,@RegionSID                              int               = null				-- not a base table column (default ignored)
	,@Phone                                  varchar(25)       = null				-- not a base table column (default ignored)
	,@Fax                                    varchar(25)       = null				-- not a base table column (default ignored)
	,@WebSite                                varchar(250)      = null				-- not a base table column (default ignored)
	,@EmailAddress                           varchar(150)      = null				-- not a base table column (default ignored)
	,@InsuranceOrgSID                        int               = null				-- not a base table column (default ignored)
	,@InsurancePolicyNo                      varchar(25)       = null				-- not a base table column (default ignored)
	,@InsuranceAmount                        decimal(11,2)     = null				-- not a base table column (default ignored)
	,@IsEmployer                             bit               = null				-- not a base table column (default ignored)
	,@IsCredentialAuthority                  bit               = null				-- not a base table column (default ignored)
	,@IsInsurer                              bit               = null				-- not a base table column (default ignored)
	,@IsInsuranceCertificateRequired         bit               = null				-- not a base table column (default ignored)
	,@IsPublic                               nchar(10)         = null				-- not a base table column (default ignored)
	,@OrgIsActive                            bit               = null				-- not a base table column (default ignored)
	,@IsAdminReviewRequired                  bit               = null				-- not a base table column (default ignored)
	,@LastVerifiedTime                       datetimeoffset(7) = null				-- not a base table column (default ignored)
	,@OrgRowGUID                             uniqueidentifier  = null				-- not a base table column (default ignored)
	,@IsDeleteEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsViewEnabled                          bit               = null				-- not a base table column (default ignored)
	,@IsEditEnabled                          bit               = null				-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed                     bit               = null				-- not a base table column (default ignored)
	,@IsApproveEnabled                       bit               = null				-- not a base table column (default ignored)
	,@IsRejectEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsUnlockEnabled                        bit               = null				-- not a base table column (default ignored)
	,@IsWithdrawalEnabled                    bit               = null				-- not a base table column (default ignored)
	,@IsInProgress                           bit               = null				-- not a base table column (default ignored)
	,@IsReviewRequired                       bit               = null				-- not a base table column (default ignored)
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
	,@RegistrantAppLabel                     nvarchar(80)      = null				-- not a base table column (default ignored)
	,@IsSendForReviewEnabled                 bit               = null				-- not a base table column (default ignored)
	,@IsReviewInProgress                     bit               = null				-- not a base table column (default ignored)
	,@IsReviewFormConfigured                 bit               = null				-- not a base table column (default ignored)
	,@RecommendationLabel                    nvarchar(20)      = null				-- not a base table column (default ignored)
	,@NewFormStatusSCD                       varchar(25)       = null				-- not a base table column (default ignored)
	,@ReasonSIDOnApprove                     int               = null				-- not a base table column (default ignored)
	,@Reviewers                              xml               = null				-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantApp#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantApp table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantApp table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantApp entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantApp procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantAppCheck to test all rules.

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

	set @RegistrantAppSID = null																						-- initialize output parameter

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

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrantAppXID = ltrim(rtrim(@RegistrantAppXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @RegistrationNo = ltrim(rtrim(@RegistrationNo))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @Tax1Label = ltrim(rtrim(@Tax1Label))
		set @Tax1GLAccountCode = ltrim(rtrim(@Tax1GLAccountCode))
		set @Tax2Label = ltrim(rtrim(@Tax2Label))
		set @Tax2GLAccountCode = ltrim(rtrim(@Tax2GLAccountCode))
		set @Tax3Label = ltrim(rtrim(@Tax3Label))
		set @Tax3GLAccountCode = ltrim(rtrim(@Tax3GLAccountCode))
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
		set @RegistrantAppLabel = ltrim(rtrim(@RegistrantAppLabel))
		set @RecommendationLabel = ltrim(rtrim(@RecommendationLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrantAppXID) = 0 set @RegistrantAppXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@RegistrationNo) = 0 set @RegistrationNo = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@Tax1Label) = 0 set @Tax1Label = null
		if len(@Tax1GLAccountCode) = 0 set @Tax1GLAccountCode = null
		if len(@Tax2Label) = 0 set @Tax2Label = null
		if len(@Tax2GLAccountCode) = 0 set @Tax2GLAccountCode = null
		if len(@Tax3Label) = 0 set @Tax3Label = null
		if len(@Tax3GLAccountCode) = 0 set @Tax3GLAccountCode = null
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
		if len(@RegistrantAppLabel) = 0 set @RegistrantAppLabel = null
		if len(@RecommendationLabel) = 0 set @RecommendationLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RegistrationYear = isnull(@RegistrationYear,dbo.fRegistrationYear#Current())
		set @FormResponseDraft = isnull(@FormResponseDraft,CONVERT(xml,N'<FormResponses />'))
		set @AdminComments = isnull(@AdminComments,CONVERT(xml,'<Comments />'))
		set @IsAutoApprovalEnabled = isnull(@IsAutoApprovalEnabled,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected               = isnull(@IsReselected              ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @PracticeRegisterSectionSID  is null select @PracticeRegisterSectionSID  = x.PracticeRegisterSectionSID from dbo.PracticeRegisterSection x where x.IsDefault = @ON and x.PracticeRegisterSID = @PracticeRegisterSID

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Jan 2018
		-- A practice register is required to default the form version. If no
		-- practice register was passed directly through @Context, deriving it
		-- based on the section which would also have to be passed in context;
		-- otherwise look for a default

		if isnull(@PracticeRegisterSID, 0) = 0
		begin

			select
				@PracticeRegisterSID = prs.PracticeRegisterSID
			from
				dbo.PracticeRegisterSection prs
			where
				prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		end;

		if isnull(@PracticeRegisterSID, 0) = 0
		begin

			select
				@PracticeRegisterSID
			from
				dbo.PracticeRegister as pr
			where
				pr.IsDefault = @ON;

		end;

		-- Tim Edlund | Jan 2018
		-- If a form version is not provided, default it to the latest published form of the
		-- correct type. Context sub-selections (using the sf.form.FormContext column) do NOT
		-- apply for applications since application forms are only completed for a single year
		-- at a time. If a FormContext is provided it is ignored.  Note also that a form
		-- version cannot be defaulted unless a register has been passed directly or derived
		-- from logic above.

		if isnull(@FormVersionSID, 0) = 0 and isnull(@PracticeRegisterSID, 0) <> 0
		begin

			select
				@FormVersionSID = max(fv.FormVersionSID)
			from
				dbo.PracticeRegisterForm prf
			join
				sf.Form									 f on prf.FormSID		 = f.FormSID
			join
				sf.FormType							 ft on f.FormTypeSID = ft.FormTypeSID and ft.FormTypeSCD = 'APPLICATION.MAIN'
			join
				sf.FormVersion					 fv on f.FormSID		 = fv.FormSID and fv.VersionNo > 0 -- filter out non-published versions
			where
				prf.PracticeRegisterSID = @PracticeRegisterSID;

		end;

		-- Tim Edlund | Jan 2018
		-- If a form version could not be derived, raise an error to highlight the
		-- problem to the configurator with language more descriptive than the
		-- standard "NOT NULL" error that would otherwise be raised.

		if @FormVersionSID is null
		begin

			exec sf.pMessage#Get
					@MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'Application Form (published)'

			raiserror(@errorText, 17, 1)
			
		end

		-- Tim Edlund | Oct 2018
		-- Block insert if another change form is
		-- open for the same registration

		set @errorText = dbo.fRegistration#Pending(@RegistrationSID, 'APPLICATION');

		if @errorText is not null
		begin
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
				r.RoutineName = 'pRegistrantApp'
		)
		begin
		
			exec @errorNo = ext.pRegistrantApp
				 @Mode                                   = 'insert.pre'
				,@RegistrationSID                        = @RegistrationSID output
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID output
				,@RegistrationYear                       = @RegistrationYear output
				,@FormVersionSID                         = @FormVersionSID output
				,@OrgSID                                 = @OrgSID output
				,@FormResponseDraft                      = @FormResponseDraft output
				,@LastValidateTime                       = @LastValidateTime output
				,@AdminComments                          = @AdminComments output
				,@NextFollowUp                           = @NextFollowUp output
				,@PendingReviewers                       = @PendingReviewers output
				,@RegistrationEffective                  = @RegistrationEffective output
				,@ConfirmationDraft                      = @ConfirmationDraft output
				,@IsAutoApprovalEnabled                  = @IsAutoApprovalEnabled output
				,@ReasonSID                              = @ReasonSID output
				,@InvoiceSID                             = @InvoiceSID output
				,@ReviewReasonList                       = @ReviewReasonList output
				,@UserDefinedColumns                     = @UserDefinedColumns output
				,@RegistrantAppXID                       = @RegistrantAppXID output
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
				,@RegistrantSID                          = @RegistrantSID
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
				,@FormSID                                = @FormSID
				,@VersionNo                              = @VersionNo
				,@RevisionNo                             = @RevisionNo
				,@IsSaveDisplayed                        = @IsSaveDisplayed
				,@ApprovedTime                           = @ApprovedTime
				,@FormVersionRowGUID                     = @FormVersionRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
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
				,@ComplaintSID                           = @ComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@ParentOrgSID                           = @ParentOrgSID
				,@OrgTypeSID                             = @OrgTypeSID
				,@OrgName                                = @OrgName
				,@OrgLabel                               = @OrgLabel
				,@StreetAddress1                         = @StreetAddress1
				,@StreetAddress2                         = @StreetAddress2
				,@StreetAddress3                         = @StreetAddress3
				,@CitySID                                = @CitySID
				,@PostalCode                             = @PostalCode
				,@RegionSID                              = @RegionSID
				,@Phone                                  = @Phone
				,@Fax                                    = @Fax
				,@WebSite                                = @WebSite
				,@EmailAddress                           = @EmailAddress
				,@InsuranceOrgSID                        = @InsuranceOrgSID
				,@InsurancePolicyNo                      = @InsurancePolicyNo
				,@InsuranceAmount                        = @InsuranceAmount
				,@IsEmployer                             = @IsEmployer
				,@IsCredentialAuthority                  = @IsCredentialAuthority
				,@IsInsurer                              = @IsInsurer
				,@IsInsuranceCertificateRequired         = @IsInsuranceCertificateRequired
				,@IsPublic                               = @IsPublic
				,@OrgIsActive                            = @OrgIsActive
				,@IsAdminReviewRequired                  = @IsAdminReviewRequired
				,@LastVerifiedTime                       = @LastVerifiedTime
				,@OrgRowGUID                             = @OrgRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsSaveBtnDisplayed                     = @IsSaveBtnDisplayed
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@IsReviewRequired                       = @IsReviewRequired
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
				,@RegistrantAppLabel                     = @RegistrantAppLabel
				,@IsSendForReviewEnabled                 = @IsSendForReviewEnabled
				,@IsReviewInProgress                     = @IsReviewInProgress
				,@IsReviewFormConfigured                 = @IsReviewFormConfigured
				,@RecommendationLabel                    = @RecommendationLabel
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
				,@Reviewers                              = @Reviewers
		
		end

		-- insert the record

		insert
			dbo.RegistrantApp
		(
			 RegistrationSID
			,PracticeRegisterSectionSID
			,RegistrationYear
			,FormVersionSID
			,OrgSID
			,FormResponseDraft
			,LastValidateTime
			,AdminComments
			,NextFollowUp
			,PendingReviewers
			,RegistrationEffective
			,ConfirmationDraft
			,IsAutoApprovalEnabled
			,ReasonSID
			,InvoiceSID
			,ReviewReasonList
			,UserDefinedColumns
			,RegistrantAppXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationSID
			,@PracticeRegisterSectionSID
			,@RegistrationYear
			,@FormVersionSID
			,@OrgSID
			,@FormResponseDraft
			,@LastValidateTime
			,@AdminComments
			,@NextFollowUp
			,@PendingReviewers
			,@RegistrationEffective
			,@ConfirmationDraft
			,@IsAutoApprovalEnabled
			,@ReasonSID
			,@InvoiceSID
			,@ReviewReasonList
			,@UserDefinedColumns
			,@RegistrantAppXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected     = @@rowcount
			,@RegistrantAppSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantApp'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantAppSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Mar 2017
		-- Create the initial status row for the form applying the
		-- default status (expected to be "NEW" or similar)

		insert			dbo.RegistrantAppStatus
		(
			 RegistrantAppSID			,FormStatusSID
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantAppSID
			,fs.FormStatusSID
			,@CreateUser
			,@CreateUser
		from
			sf.FormStatus fs
		where
			fs.IsDefault = @ON
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
				r.RoutineName = 'pRegistrantApp'
		)
		begin
		
			exec @errorNo = ext.pRegistrantApp
				 @Mode                                   = 'insert.post'
				,@RegistrantAppSID                       = @RegistrantAppSID
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@FormVersionSID                         = @FormVersionSID
				,@OrgSID                                 = @OrgSID
				,@FormResponseDraft                      = @FormResponseDraft
				,@LastValidateTime                       = @LastValidateTime
				,@AdminComments                          = @AdminComments
				,@NextFollowUp                           = @NextFollowUp
				,@PendingReviewers                       = @PendingReviewers
				,@RegistrationEffective                  = @RegistrationEffective
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@IsAutoApprovalEnabled                  = @IsAutoApprovalEnabled
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ReviewReasonList                       = @ReviewReasonList
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@RegistrantAppXID                       = @RegistrantAppXID
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
				,@RegistrantSID                          = @RegistrantSID
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
				,@FormSID                                = @FormSID
				,@VersionNo                              = @VersionNo
				,@RevisionNo                             = @RevisionNo
				,@IsSaveDisplayed                        = @IsSaveDisplayed
				,@ApprovedTime                           = @ApprovedTime
				,@FormVersionRowGUID                     = @FormVersionRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
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
				,@ComplaintSID                           = @ComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@ParentOrgSID                           = @ParentOrgSID
				,@OrgTypeSID                             = @OrgTypeSID
				,@OrgName                                = @OrgName
				,@OrgLabel                               = @OrgLabel
				,@StreetAddress1                         = @StreetAddress1
				,@StreetAddress2                         = @StreetAddress2
				,@StreetAddress3                         = @StreetAddress3
				,@CitySID                                = @CitySID
				,@PostalCode                             = @PostalCode
				,@RegionSID                              = @RegionSID
				,@Phone                                  = @Phone
				,@Fax                                    = @Fax
				,@WebSite                                = @WebSite
				,@EmailAddress                           = @EmailAddress
				,@InsuranceOrgSID                        = @InsuranceOrgSID
				,@InsurancePolicyNo                      = @InsurancePolicyNo
				,@InsuranceAmount                        = @InsuranceAmount
				,@IsEmployer                             = @IsEmployer
				,@IsCredentialAuthority                  = @IsCredentialAuthority
				,@IsInsurer                              = @IsInsurer
				,@IsInsuranceCertificateRequired         = @IsInsuranceCertificateRequired
				,@IsPublic                               = @IsPublic
				,@OrgIsActive                            = @OrgIsActive
				,@IsAdminReviewRequired                  = @IsAdminReviewRequired
				,@LastVerifiedTime                       = @LastVerifiedTime
				,@OrgRowGUID                             = @OrgRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsSaveBtnDisplayed                     = @IsSaveBtnDisplayed
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@IsReviewRequired                       = @IsReviewRequired
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
				,@RegistrantAppLabel                     = @RegistrantAppLabel
				,@IsSendForReviewEnabled                 = @IsSendForReviewEnabled
				,@IsReviewInProgress                     = @IsReviewInProgress
				,@IsReviewFormConfigured                 = @IsReviewFormConfigured
				,@RecommendationLabel                    = @RecommendationLabel
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
				,@Reviewers                              = @Reviewers
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantAppSID
			from
				dbo.vRegistrantApp ent
			where
				ent.RegistrantAppSID = @RegistrantAppSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantAppSID
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.FormVersionSID
				,ent.OrgSID
				,ent.FormResponseDraft
				,ent.LastValidateTime
				,ent.AdminComments
				,ent.NextFollowUp
				,ent.PendingReviewers
				,ent.RegistrationEffective
				,ent.ConfirmationDraft
				,ent.IsAutoApprovalEnabled
				,ent.ReasonSID
				,ent.InvoiceSID
				,ent.ReviewReasonList
				,ent.UserDefinedColumns
				,ent.RegistrantAppXID
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
				,ent.RegistrantSID
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
				,ent.FormSID
				,ent.VersionNo
				,ent.RevisionNo
				,ent.IsSaveDisplayed
				,ent.ApprovedTime
				,ent.FormVersionRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
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
				,ent.ComplaintSID
				,ent.InvoiceRowGUID
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
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsSaveBtnDisplayed
				,ent.IsApproveEnabled
				,ent.IsRejectEnabled
				,ent.IsUnlockEnabled
				,ent.IsWithdrawalEnabled
				,ent.IsInProgress
				,ent.IsReviewRequired
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
				,ent.RegistrantAppLabel
				,ent.IsSendForReviewEnabled
				,ent.IsReviewInProgress
				,ent.IsReviewFormConfigured
				,ent.RecommendationLabel
				,ent.NewFormStatusSCD
				,ent.ReasonSIDOnApprove
				,ent.Reviewers
			from
				dbo.vRegistrantApp ent
			where
				ent.RegistrantAppSID = @RegistrantAppSID

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
