SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAudit#Insert]
	 @RegistrantAuditSID             int               = null output				-- identity value assigned to the new record
	,@RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@AuditTypeSID                   int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear               smallint          = null								-- default: sf.fTodayYear()
	,@FormVersionSID                 int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@FormResponseDraft              xml               = null								-- default: CONVERT(xml,N'<FormResponses />')
	,@LastValidateTime               datetimeoffset(7) = null								
	,@AdminComments                  xml               = null								-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp                   date              = null								
	,@PendingReviewers               xml               = null								
	,@ReasonSID                      int               = null								
	,@ConfirmationDraft              nvarchar(max)     = null								
	,@IsAutoApprovalEnabled          bit               = null								-- default: CONVERT(bit,(0))
	,@ReviewReasonList               xml               = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantAuditXID             varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@AuditTypeLabel                 nvarchar(35)      = null								-- not a base table column (default ignored)
	,@AuditTypeCategory              nvarchar(65)      = null								-- not a base table column (default ignored)
	,@AuditTypeIsDefault             bit               = null								-- not a base table column (default ignored)
	,@AuditTypeIsActive              bit               = null								-- not a base table column (default ignored)
	,@AuditTypeRowGUID               uniqueidentifier  = null								-- not a base table column (default ignored)
	,@PersonSID                      int               = null								-- not a base table column (default ignored)
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
	,@FormSID                        int               = null								-- not a base table column (default ignored)
	,@VersionNo                      smallint          = null								-- not a base table column (default ignored)
	,@RevisionNo                     smallint          = null								-- not a base table column (default ignored)
	,@IsSaveDisplayed                bit               = null								-- not a base table column (default ignored)
	,@ApprovedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@FormVersionRowGUID             uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ReasonGroupSID                 int               = null								-- not a base table column (default ignored)
	,@ReasonName                     nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ReasonCode                     varchar(25)       = null								-- not a base table column (default ignored)
	,@ReasonSequence                 smallint          = null								-- not a base table column (default ignored)
	,@ToolTip                        nvarchar(500)     = null								-- not a base table column (default ignored)
	,@ReasonIsActive                 bit               = null								-- not a base table column (default ignored)
	,@ReasonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsViewEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsEditEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed             bit               = null								-- not a base table column (default ignored)
	,@IsApproveEnabled               bit               = null								-- not a base table column (default ignored)
	,@IsRejectEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsUnlockEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsWithdrawalEnabled            bit               = null								-- not a base table column (default ignored)
	,@IsInProgress                   bit               = null								-- not a base table column (default ignored)
	,@IsReviewRequired               bit               = null								-- not a base table column (default ignored)
	,@FormStatusSID                  int               = null								-- not a base table column (default ignored)
	,@FormStatusSCD                  varchar(25)       = null								-- not a base table column (default ignored)
	,@FormStatusLabel                nvarchar(35)      = null								-- not a base table column (default ignored)
	,@LastStatusChangeUser           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@LastStatusChangeTime           datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@FormOwnerSID                   int               = null								-- not a base table column (default ignored)
	,@FormOwnerSCD                   varchar(25)       = null								-- not a base table column (default ignored)
	,@FormOwnerLabel                 nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IsPDFDisplayed                 bit               = null								-- not a base table column (default ignored)
	,@PersonDocSID                   int               = null								-- not a base table column (default ignored)
	,@PersonMailingAddressSID        int               = null								-- not a base table column (default ignored)
	,@PersonStreetAddress1           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PersonStreetAddress2           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PersonStreetAddress3           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@PersonCityName                 nvarchar(30)      = null								-- not a base table column (default ignored)
	,@PersonStateProvinceName        nvarchar(30)      = null								-- not a base table column (default ignored)
	,@PersonPostalCode               nvarchar(10)      = null								-- not a base table column (default ignored)
	,@PersonCountryName              nvarchar(50)      = null								-- not a base table column (default ignored)
	,@PersonCitySID                  int               = null								-- not a base table column (default ignored)
	,@RegistrationYearLabel          varchar(9)        = null								-- not a base table column (default ignored)
	,@RegistrantAuditLabel           nvarchar(80)      = null								-- not a base table column (default ignored)
	,@IsSendForReviewEnabled         bit               = null								-- not a base table column (default ignored)
	,@IsReviewInProgress             bit               = null								-- not a base table column (default ignored)
	,@IsReviewFormConfigured         bit               = null								-- not a base table column (default ignored)
	,@RecommendationLabel            nvarchar(20)      = null								-- not a base table column (default ignored)
	,@NewFormStatusSCD               varchar(25)       = null								-- not a base table column (default ignored)
	,@Reviewers                      xml               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAudit#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantAudit table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantAudit table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantAudit entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantAudit procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantAuditCheck to test all rules.

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

	set @RegistrantAuditSID = null																					-- initialize output parameter

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
		set @RegistrantAuditXID = ltrim(rtrim(@RegistrantAuditXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @AuditTypeLabel = ltrim(rtrim(@AuditTypeLabel))
		set @AuditTypeCategory = ltrim(rtrim(@AuditTypeCategory))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
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
		set @RegistrantAuditLabel = ltrim(rtrim(@RegistrantAuditLabel))
		set @RecommendationLabel = ltrim(rtrim(@RecommendationLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrantAuditXID) = 0 set @RegistrantAuditXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@AuditTypeLabel) = 0 set @AuditTypeLabel = null
		if len(@AuditTypeCategory) = 0 set @AuditTypeCategory = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
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
		if len(@RegistrantAuditLabel) = 0 set @RegistrantAuditLabel = null
		if len(@RecommendationLabel) = 0 set @RecommendationLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RegistrationYear = isnull(@RegistrationYear,sf.fTodayYear())
		set @FormResponseDraft = isnull(@FormResponseDraft,CONVERT(xml,N'<FormResponses />'))
		set @AdminComments = isnull(@AdminComments,CONVERT(xml,'<Comments />'))
		set @IsAutoApprovalEnabled = isnull(@IsAutoApprovalEnabled,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected          = isnull(@IsReselected         ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @AuditTypeSID  is null select @AuditTypeSID  = x.AuditTypeSID from dbo.AuditType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Jan 2018
		-- If a form version is not provided, default it to the latest published form of the
		-- correct type. Context sub-selections (using the sf.form.FormContext column) do NOT
		-- apply for audits since audit forms are only completed for a single year at a time.
		-- If a FormContext is provided it is ignored.  Note also that a form version cannot
		-- be defaulted unless an audit type has been passed directly or derived from logic
		-- above.

		if isnull(@FormVersionSID, 0) = 0 and isnull(@AuditTypeSID, 0) <> 0
		begin

			select
				@FormVersionSID = max(fv.FormVersionSID)
			from
				dbo.AuditTypeForm atf
			join
				sf.Form						f on atf.FormSID = f.FormSID
			join
				sf.FormVersion		fv on f.FormSID	 = fv.FormSID and fv.VersionNo > 0 -- filter out non-published versions
			where
				atf.AuditTypeSID = @AuditTypeSID and atf.IsReviewForm = @OFF; -- filter out review forms

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
				,@Arg1        = 'Audit Form + Type (published)'

			raiserror(@errorText, 17, 1)
			
		end
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
				r.RoutineName = 'pRegistrantAudit'
		)
		begin
		
			exec @errorNo = ext.pRegistrantAudit
				 @Mode                           = 'insert.pre'
				,@RegistrantSID                  = @RegistrantSID output
				,@AuditTypeSID                   = @AuditTypeSID output
				,@RegistrationYear               = @RegistrationYear output
				,@FormVersionSID                 = @FormVersionSID output
				,@FormResponseDraft              = @FormResponseDraft output
				,@LastValidateTime               = @LastValidateTime output
				,@AdminComments                  = @AdminComments output
				,@NextFollowUp                   = @NextFollowUp output
				,@PendingReviewers               = @PendingReviewers output
				,@ReasonSID                      = @ReasonSID output
				,@ConfirmationDraft              = @ConfirmationDraft output
				,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled output
				,@ReviewReasonList               = @ReviewReasonList output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantAuditXID             = @RegistrantAuditXID output
				,@LegacyKey                      = @LegacyKey output
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@AuditTypeLabel                 = @AuditTypeLabel
				,@AuditTypeCategory              = @AuditTypeCategory
				,@AuditTypeIsDefault             = @AuditTypeIsDefault
				,@AuditTypeIsActive              = @AuditTypeIsActive
				,@AuditTypeRowGUID               = @AuditTypeRowGUID
				,@PersonSID                      = @PersonSID
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
				,@FormSID                        = @FormSID
				,@VersionNo                      = @VersionNo
				,@RevisionNo                     = @RevisionNo
				,@IsSaveDisplayed                = @IsSaveDisplayed
				,@ApprovedTime                   = @ApprovedTime
				,@FormVersionRowGUID             = @FormVersionRowGUID
				,@ReasonGroupSID                 = @ReasonGroupSID
				,@ReasonName                     = @ReasonName
				,@ReasonCode                     = @ReasonCode
				,@ReasonSequence                 = @ReasonSequence
				,@ToolTip                        = @ToolTip
				,@ReasonIsActive                 = @ReasonIsActive
				,@ReasonRowGUID                  = @ReasonRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsViewEnabled                  = @IsViewEnabled
				,@IsEditEnabled                  = @IsEditEnabled
				,@IsSaveBtnDisplayed             = @IsSaveBtnDisplayed
				,@IsApproveEnabled               = @IsApproveEnabled
				,@IsRejectEnabled                = @IsRejectEnabled
				,@IsUnlockEnabled                = @IsUnlockEnabled
				,@IsWithdrawalEnabled            = @IsWithdrawalEnabled
				,@IsInProgress                   = @IsInProgress
				,@IsReviewRequired               = @IsReviewRequired
				,@FormStatusSID                  = @FormStatusSID
				,@FormStatusSCD                  = @FormStatusSCD
				,@FormStatusLabel                = @FormStatusLabel
				,@LastStatusChangeUser           = @LastStatusChangeUser
				,@LastStatusChangeTime           = @LastStatusChangeTime
				,@FormOwnerSID                   = @FormOwnerSID
				,@FormOwnerSCD                   = @FormOwnerSCD
				,@FormOwnerLabel                 = @FormOwnerLabel
				,@IsPDFDisplayed                 = @IsPDFDisplayed
				,@PersonDocSID                   = @PersonDocSID
				,@PersonMailingAddressSID        = @PersonMailingAddressSID
				,@PersonStreetAddress1           = @PersonStreetAddress1
				,@PersonStreetAddress2           = @PersonStreetAddress2
				,@PersonStreetAddress3           = @PersonStreetAddress3
				,@PersonCityName                 = @PersonCityName
				,@PersonStateProvinceName        = @PersonStateProvinceName
				,@PersonPostalCode               = @PersonPostalCode
				,@PersonCountryName              = @PersonCountryName
				,@PersonCitySID                  = @PersonCitySID
				,@RegistrationYearLabel          = @RegistrationYearLabel
				,@RegistrantAuditLabel           = @RegistrantAuditLabel
				,@IsSendForReviewEnabled         = @IsSendForReviewEnabled
				,@IsReviewInProgress             = @IsReviewInProgress
				,@IsReviewFormConfigured         = @IsReviewFormConfigured
				,@RecommendationLabel            = @RecommendationLabel
				,@NewFormStatusSCD               = @NewFormStatusSCD
				,@Reviewers                      = @Reviewers
		
		end

		-- insert the record

		insert
			dbo.RegistrantAudit
		(
			 RegistrantSID
			,AuditTypeSID
			,RegistrationYear
			,FormVersionSID
			,FormResponseDraft
			,LastValidateTime
			,AdminComments
			,NextFollowUp
			,PendingReviewers
			,ReasonSID
			,ConfirmationDraft
			,IsAutoApprovalEnabled
			,ReviewReasonList
			,UserDefinedColumns
			,RegistrantAuditXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@AuditTypeSID
			,@RegistrationYear
			,@FormVersionSID
			,@FormResponseDraft
			,@LastValidateTime
			,@AdminComments
			,@NextFollowUp
			,@PendingReviewers
			,@ReasonSID
			,@ConfirmationDraft
			,@IsAutoApprovalEnabled
			,@ReviewReasonList
			,@UserDefinedColumns
			,@RegistrantAuditXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected       = @@rowcount
			,@RegistrantAuditSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantAudit'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantAuditSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Apr 2017
		-- Create the initial status row for the form applying the
		-- default status (expected to be "NEW" or similar)

		insert
			dbo.RegistrantAuditStatus
		(
			 RegistrantAuditSID
			,FormStatusSID
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantAuditSID
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
				r.RoutineName = 'pRegistrantAudit'
		)
		begin
		
			exec @errorNo = ext.pRegistrantAudit
				 @Mode                           = 'insert.post'
				,@RegistrantAuditSID             = @RegistrantAuditSID
				,@RegistrantSID                  = @RegistrantSID
				,@AuditTypeSID                   = @AuditTypeSID
				,@RegistrationYear               = @RegistrationYear
				,@FormVersionSID                 = @FormVersionSID
				,@FormResponseDraft              = @FormResponseDraft
				,@LastValidateTime               = @LastValidateTime
				,@AdminComments                  = @AdminComments
				,@NextFollowUp                   = @NextFollowUp
				,@PendingReviewers               = @PendingReviewers
				,@ReasonSID                      = @ReasonSID
				,@ConfirmationDraft              = @ConfirmationDraft
				,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
				,@ReviewReasonList               = @ReviewReasonList
				,@UserDefinedColumns             = @UserDefinedColumns
				,@RegistrantAuditXID             = @RegistrantAuditXID
				,@LegacyKey                      = @LegacyKey
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@AuditTypeLabel                 = @AuditTypeLabel
				,@AuditTypeCategory              = @AuditTypeCategory
				,@AuditTypeIsDefault             = @AuditTypeIsDefault
				,@AuditTypeIsActive              = @AuditTypeIsActive
				,@AuditTypeRowGUID               = @AuditTypeRowGUID
				,@PersonSID                      = @PersonSID
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
				,@FormSID                        = @FormSID
				,@VersionNo                      = @VersionNo
				,@RevisionNo                     = @RevisionNo
				,@IsSaveDisplayed                = @IsSaveDisplayed
				,@ApprovedTime                   = @ApprovedTime
				,@FormVersionRowGUID             = @FormVersionRowGUID
				,@ReasonGroupSID                 = @ReasonGroupSID
				,@ReasonName                     = @ReasonName
				,@ReasonCode                     = @ReasonCode
				,@ReasonSequence                 = @ReasonSequence
				,@ToolTip                        = @ToolTip
				,@ReasonIsActive                 = @ReasonIsActive
				,@ReasonRowGUID                  = @ReasonRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@IsViewEnabled                  = @IsViewEnabled
				,@IsEditEnabled                  = @IsEditEnabled
				,@IsSaveBtnDisplayed             = @IsSaveBtnDisplayed
				,@IsApproveEnabled               = @IsApproveEnabled
				,@IsRejectEnabled                = @IsRejectEnabled
				,@IsUnlockEnabled                = @IsUnlockEnabled
				,@IsWithdrawalEnabled            = @IsWithdrawalEnabled
				,@IsInProgress                   = @IsInProgress
				,@IsReviewRequired               = @IsReviewRequired
				,@FormStatusSID                  = @FormStatusSID
				,@FormStatusSCD                  = @FormStatusSCD
				,@FormStatusLabel                = @FormStatusLabel
				,@LastStatusChangeUser           = @LastStatusChangeUser
				,@LastStatusChangeTime           = @LastStatusChangeTime
				,@FormOwnerSID                   = @FormOwnerSID
				,@FormOwnerSCD                   = @FormOwnerSCD
				,@FormOwnerLabel                 = @FormOwnerLabel
				,@IsPDFDisplayed                 = @IsPDFDisplayed
				,@PersonDocSID                   = @PersonDocSID
				,@PersonMailingAddressSID        = @PersonMailingAddressSID
				,@PersonStreetAddress1           = @PersonStreetAddress1
				,@PersonStreetAddress2           = @PersonStreetAddress2
				,@PersonStreetAddress3           = @PersonStreetAddress3
				,@PersonCityName                 = @PersonCityName
				,@PersonStateProvinceName        = @PersonStateProvinceName
				,@PersonPostalCode               = @PersonPostalCode
				,@PersonCountryName              = @PersonCountryName
				,@PersonCitySID                  = @PersonCitySID
				,@RegistrationYearLabel          = @RegistrationYearLabel
				,@RegistrantAuditLabel           = @RegistrantAuditLabel
				,@IsSendForReviewEnabled         = @IsSendForReviewEnabled
				,@IsReviewInProgress             = @IsReviewInProgress
				,@IsReviewFormConfigured         = @IsReviewFormConfigured
				,@RecommendationLabel            = @RecommendationLabel
				,@NewFormStatusSCD               = @NewFormStatusSCD
				,@Reviewers                      = @Reviewers
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantAuditSID
			from
				dbo.vRegistrantAudit ent
			where
				ent.RegistrantAuditSID = @RegistrantAuditSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantAuditSID
				,ent.RegistrantSID
				,ent.AuditTypeSID
				,ent.RegistrationYear
				,ent.FormVersionSID
				,ent.FormResponseDraft
				,ent.LastValidateTime
				,ent.AdminComments
				,ent.NextFollowUp
				,ent.PendingReviewers
				,ent.ReasonSID
				,ent.ConfirmationDraft
				,ent.IsAutoApprovalEnabled
				,ent.ReviewReasonList
				,ent.UserDefinedColumns
				,ent.RegistrantAuditXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.AuditTypeLabel
				,ent.AuditTypeCategory
				,ent.AuditTypeIsDefault
				,ent.AuditTypeIsActive
				,ent.AuditTypeRowGUID
				,ent.PersonSID
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
				,ent.PersonMailingAddressSID
				,ent.PersonStreetAddress1
				,ent.PersonStreetAddress2
				,ent.PersonStreetAddress3
				,ent.PersonCityName
				,ent.PersonStateProvinceName
				,ent.PersonPostalCode
				,ent.PersonCountryName
				,ent.PersonCitySID
				,ent.RegistrationYearLabel
				,ent.RegistrantAuditLabel
				,ent.IsSendForReviewEnabled
				,ent.IsReviewInProgress
				,ent.IsReviewFormConfigured
				,ent.RecommendationLabel
				,ent.NewFormStatusSCD
				,ent.Reviewers
			from
				dbo.vRegistrantAudit ent
			where
				ent.RegistrantAuditSID = @RegistrantAuditSID

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
