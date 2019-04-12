SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAudit#Update]
	 @RegistrantAuditSID             int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                  int               = null -- table column values to update:
	,@AuditTypeSID                   int               = null
	,@RegistrationYear               smallint          = null
	,@FormVersionSID                 int               = null
	,@FormResponseDraft              xml               = null
	,@LastValidateTime               datetimeoffset(7) = null
	,@AdminComments                  xml               = null
	,@NextFollowUp                   date              = null
	,@PendingReviewers               xml               = null
	,@ReasonSID                      int               = null
	,@ConfirmationDraft              nvarchar(max)     = null
	,@IsAutoApprovalEnabled          bit               = null
	,@ReviewReasonList               xml               = null
	,@UserDefinedColumns             xml               = null
	,@RegistrantAuditXID             varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@AuditTypeLabel                 nvarchar(35)      = null -- not a base table column
	,@AuditTypeCategory              nvarchar(65)      = null -- not a base table column
	,@AuditTypeIsDefault             bit               = null -- not a base table column
	,@AuditTypeIsActive              bit               = null -- not a base table column
	,@AuditTypeRowGUID               uniqueidentifier  = null -- not a base table column
	,@PersonSID                      int               = null -- not a base table column
	,@RegistrantNo                   varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment        smallint          = null -- not a base table column
	,@IsOnPublicRegistry             bit               = null -- not a base table column
	,@CityNameOfBirth                nvarchar(30)      = null -- not a base table column
	,@CountrySID                     int               = null -- not a base table column
	,@DirectedAuditYearCompetence    smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours smallint          = null -- not a base table column
	,@LateFeeExclusionYear           smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked   bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime     datetime          = null -- not a base table column
	,@ArchivedTime                   datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID              uniqueidentifier  = null -- not a base table column
	,@FormSID                        int               = null -- not a base table column
	,@VersionNo                      smallint          = null -- not a base table column
	,@RevisionNo                     smallint          = null -- not a base table column
	,@IsSaveDisplayed                bit               = null -- not a base table column
	,@ApprovedTime                   datetimeoffset(7) = null -- not a base table column
	,@FormVersionRowGUID             uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                 int               = null -- not a base table column
	,@ReasonName                     nvarchar(50)      = null -- not a base table column
	,@ReasonCode                     varchar(25)       = null -- not a base table column
	,@ReasonSequence                 smallint          = null -- not a base table column
	,@ToolTip                        nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                 bit               = null -- not a base table column
	,@ReasonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@IsViewEnabled                  bit               = null -- not a base table column
	,@IsEditEnabled                  bit               = null -- not a base table column
	,@IsSaveBtnDisplayed             bit               = null -- not a base table column
	,@IsApproveEnabled               bit               = null -- not a base table column
	,@IsRejectEnabled                bit               = null -- not a base table column
	,@IsUnlockEnabled                bit               = null -- not a base table column
	,@IsWithdrawalEnabled            bit               = null -- not a base table column
	,@IsInProgress                   bit               = null -- not a base table column
	,@IsReviewRequired               bit               = null -- not a base table column
	,@FormStatusSID                  int               = null -- not a base table column
	,@FormStatusSCD                  varchar(25)       = null -- not a base table column
	,@FormStatusLabel                nvarchar(35)      = null -- not a base table column
	,@LastStatusChangeUser           nvarchar(75)      = null -- not a base table column
	,@LastStatusChangeTime           datetimeoffset(7) = null -- not a base table column
	,@FormOwnerSID                   int               = null -- not a base table column
	,@FormOwnerSCD                   varchar(25)       = null -- not a base table column
	,@FormOwnerLabel                 nvarchar(35)      = null -- not a base table column
	,@IsPDFDisplayed                 bit               = null -- not a base table column
	,@PersonDocSID                   int               = null -- not a base table column
	,@PersonMailingAddressSID        int               = null -- not a base table column
	,@PersonStreetAddress1           nvarchar(75)      = null -- not a base table column
	,@PersonStreetAddress2           nvarchar(75)      = null -- not a base table column
	,@PersonStreetAddress3           nvarchar(75)      = null -- not a base table column
	,@PersonCityName                 nvarchar(30)      = null -- not a base table column
	,@PersonStateProvinceName        nvarchar(30)      = null -- not a base table column
	,@PersonPostalCode               nvarchar(10)      = null -- not a base table column
	,@PersonCountryName              nvarchar(50)      = null -- not a base table column
	,@PersonCitySID                  int               = null -- not a base table column
	,@RegistrationYearLabel          varchar(9)        = null -- not a base table column
	,@RegistrantAuditLabel           nvarchar(80)      = null -- not a base table column
	,@IsSendForReviewEnabled         bit               = null -- not a base table column
	,@IsReviewInProgress             bit               = null -- not a base table column
	,@IsReviewFormConfigured         bit               = null -- not a base table column
	,@RecommendationLabel            nvarchar(20)      = null -- not a base table column
	,@NewFormStatusSCD               varchar(25)       = null -- not a base table column
	,@Reviewers                      xml               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAudit#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantAudit table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantAudit table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantAudit entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantAudit procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

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

		-- check parameters

		if @RegistrantAuditSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantAuditSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrantAuditXID = ltrim(rtrim(@RegistrantAuditXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                  = isnull(@RegistrantSID,ra.RegistrantSID)
				,@AuditTypeSID                   = isnull(@AuditTypeSID,ra.AuditTypeSID)
				,@RegistrationYear               = isnull(@RegistrationYear,ra.RegistrationYear)
				,@FormVersionSID                 = isnull(@FormVersionSID,ra.FormVersionSID)
				,@FormResponseDraft              = isnull(@FormResponseDraft,ra.FormResponseDraft)
				,@LastValidateTime               = isnull(@LastValidateTime,ra.LastValidateTime)
				,@AdminComments                  = isnull(@AdminComments,ra.AdminComments)
				,@NextFollowUp                   = isnull(@NextFollowUp,ra.NextFollowUp)
				,@PendingReviewers               = isnull(@PendingReviewers,ra.PendingReviewers)
				,@ReasonSID                      = isnull(@ReasonSID,ra.ReasonSID)
				,@ConfirmationDraft              = isnull(@ConfirmationDraft,ra.ConfirmationDraft)
				,@IsAutoApprovalEnabled          = isnull(@IsAutoApprovalEnabled,ra.IsAutoApprovalEnabled)
				,@ReviewReasonList               = isnull(@ReviewReasonList,ra.ReviewReasonList)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,ra.UserDefinedColumns)
				,@RegistrantAuditXID             = isnull(@RegistrantAuditXID,ra.RegistrantAuditXID)
				,@LegacyKey                      = isnull(@LegacyKey,ra.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,ra.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,ra.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,ra.IsNullApplied)
				,@zContext                       = isnull(@zContext,ra.zContext)
				,@AuditTypeLabel                 = isnull(@AuditTypeLabel,ra.AuditTypeLabel)
				,@AuditTypeCategory              = isnull(@AuditTypeCategory,ra.AuditTypeCategory)
				,@AuditTypeIsDefault             = isnull(@AuditTypeIsDefault,ra.AuditTypeIsDefault)
				,@AuditTypeIsActive              = isnull(@AuditTypeIsActive,ra.AuditTypeIsActive)
				,@AuditTypeRowGUID               = isnull(@AuditTypeRowGUID,ra.AuditTypeRowGUID)
				,@PersonSID                      = isnull(@PersonSID,ra.PersonSID)
				,@RegistrantNo                   = isnull(@RegistrantNo,ra.RegistrantNo)
				,@YearOfInitialEmployment        = isnull(@YearOfInitialEmployment,ra.YearOfInitialEmployment)
				,@IsOnPublicRegistry             = isnull(@IsOnPublicRegistry,ra.IsOnPublicRegistry)
				,@CityNameOfBirth                = isnull(@CityNameOfBirth,ra.CityNameOfBirth)
				,@CountrySID                     = isnull(@CountrySID,ra.CountrySID)
				,@DirectedAuditYearCompetence    = isnull(@DirectedAuditYearCompetence,ra.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours = isnull(@DirectedAuditYearPracticeHours,ra.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear           = isnull(@LateFeeExclusionYear,ra.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked   = isnull(@IsRenewalAutoApprovalBlocked,ra.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime     = isnull(@RenewalExtensionExpiryTime,ra.RenewalExtensionExpiryTime)
				,@ArchivedTime                   = isnull(@ArchivedTime,ra.ArchivedTime)
				,@RegistrantRowGUID              = isnull(@RegistrantRowGUID,ra.RegistrantRowGUID)
				,@FormSID                        = isnull(@FormSID,ra.FormSID)
				,@VersionNo                      = isnull(@VersionNo,ra.VersionNo)
				,@RevisionNo                     = isnull(@RevisionNo,ra.RevisionNo)
				,@IsSaveDisplayed                = isnull(@IsSaveDisplayed,ra.IsSaveDisplayed)
				,@ApprovedTime                   = isnull(@ApprovedTime,ra.ApprovedTime)
				,@FormVersionRowGUID             = isnull(@FormVersionRowGUID,ra.FormVersionRowGUID)
				,@ReasonGroupSID                 = isnull(@ReasonGroupSID,ra.ReasonGroupSID)
				,@ReasonName                     = isnull(@ReasonName,ra.ReasonName)
				,@ReasonCode                     = isnull(@ReasonCode,ra.ReasonCode)
				,@ReasonSequence                 = isnull(@ReasonSequence,ra.ReasonSequence)
				,@ToolTip                        = isnull(@ToolTip,ra.ToolTip)
				,@ReasonIsActive                 = isnull(@ReasonIsActive,ra.ReasonIsActive)
				,@ReasonRowGUID                  = isnull(@ReasonRowGUID,ra.ReasonRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,ra.IsDeleteEnabled)
				,@IsViewEnabled                  = isnull(@IsViewEnabled,ra.IsViewEnabled)
				,@IsEditEnabled                  = isnull(@IsEditEnabled,ra.IsEditEnabled)
				,@IsSaveBtnDisplayed             = isnull(@IsSaveBtnDisplayed,ra.IsSaveBtnDisplayed)
				,@IsApproveEnabled               = isnull(@IsApproveEnabled,ra.IsApproveEnabled)
				,@IsRejectEnabled                = isnull(@IsRejectEnabled,ra.IsRejectEnabled)
				,@IsUnlockEnabled                = isnull(@IsUnlockEnabled,ra.IsUnlockEnabled)
				,@IsWithdrawalEnabled            = isnull(@IsWithdrawalEnabled,ra.IsWithdrawalEnabled)
				,@IsInProgress                   = isnull(@IsInProgress,ra.IsInProgress)
				,@IsReviewRequired               = isnull(@IsReviewRequired,ra.IsReviewRequired)
				,@FormStatusSID                  = isnull(@FormStatusSID,ra.FormStatusSID)
				,@FormStatusSCD                  = isnull(@FormStatusSCD,ra.FormStatusSCD)
				,@FormStatusLabel                = isnull(@FormStatusLabel,ra.FormStatusLabel)
				,@LastStatusChangeUser           = isnull(@LastStatusChangeUser,ra.LastStatusChangeUser)
				,@LastStatusChangeTime           = isnull(@LastStatusChangeTime,ra.LastStatusChangeTime)
				,@FormOwnerSID                   = isnull(@FormOwnerSID,ra.FormOwnerSID)
				,@FormOwnerSCD                   = isnull(@FormOwnerSCD,ra.FormOwnerSCD)
				,@FormOwnerLabel                 = isnull(@FormOwnerLabel,ra.FormOwnerLabel)
				,@IsPDFDisplayed                 = isnull(@IsPDFDisplayed,ra.IsPDFDisplayed)
				,@PersonDocSID                   = isnull(@PersonDocSID,ra.PersonDocSID)
				,@PersonMailingAddressSID        = isnull(@PersonMailingAddressSID,ra.PersonMailingAddressSID)
				,@PersonStreetAddress1           = isnull(@PersonStreetAddress1,ra.PersonStreetAddress1)
				,@PersonStreetAddress2           = isnull(@PersonStreetAddress2,ra.PersonStreetAddress2)
				,@PersonStreetAddress3           = isnull(@PersonStreetAddress3,ra.PersonStreetAddress3)
				,@PersonCityName                 = isnull(@PersonCityName,ra.PersonCityName)
				,@PersonStateProvinceName        = isnull(@PersonStateProvinceName,ra.PersonStateProvinceName)
				,@PersonPostalCode               = isnull(@PersonPostalCode,ra.PersonPostalCode)
				,@PersonCountryName              = isnull(@PersonCountryName,ra.PersonCountryName)
				,@PersonCitySID                  = isnull(@PersonCitySID,ra.PersonCitySID)
				,@RegistrationYearLabel          = isnull(@RegistrationYearLabel,ra.RegistrationYearLabel)
				,@RegistrantAuditLabel           = isnull(@RegistrantAuditLabel,ra.RegistrantAuditLabel)
				,@IsSendForReviewEnabled         = isnull(@IsSendForReviewEnabled,ra.IsSendForReviewEnabled)
				,@IsReviewInProgress             = isnull(@IsReviewInProgress,ra.IsReviewInProgress)
				,@IsReviewFormConfigured         = isnull(@IsReviewFormConfigured,ra.IsReviewFormConfigured)
				,@RecommendationLabel            = isnull(@RecommendationLabel,ra.RecommendationLabel)
				,@NewFormStatusSCD               = isnull(@NewFormStatusSCD,ra.NewFormStatusSCD)
				,@Reviewers                      = isnull(@Reviewers,ra.Reviewers)
			from
				dbo.vRegistrantAudit ra
			where
				ra.RegistrantAuditSID = @RegistrantAuditSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.AuditTypeSID from dbo.RegistrantAudit x where x.RegistrantAuditSID = @RegistrantAuditSID) <> @AuditTypeSID
		begin
			if (select x.IsActive from dbo.AuditType x where x.AuditTypeSID = @AuditTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'audit type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ReasonSID from dbo.RegistrantAudit x where x.RegistrantAuditSID = @RegistrantAuditSID) <> @ReasonSID
		begin
			if (select x.IsActive from dbo.Reason x where x.ReasonSID = @ReasonSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'reason'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Sep 2018
		-- Set the last validated time on the
		-- status changes/save that executed it
		-- if returned set last validated to null

		if @NewFormStatusSCD in ('VALIDATED', 'SUBMITTED', 'APPROVED')
		begin
			set @LastValidateTime = sysdatetimeoffset()
		end
		else if @NewFormStatusSCD = 'RETURNED'
		begin
			set @LastValidateTime = null
		end

		-- Tim Edlund | Oct 2018
		-- If the form is not withdrawn and the reason list
		-- is blank where an individual reason key exists,
		-- the put the value in the XML document (for UI display)

		if @NewFormStatusSCD <> 'WITHDRAWN' and @ReviewReasonList is null and @ReasonSID is not null --and @FormStatusSCD <> 'WITHDRAWN'
		begin
			set @ReviewReasonList = cast(N'<Reasons><Reason SID="' + ltrim(@ReasonSID) + '"/></Reasons>' as xml)
		end
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
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
				 @Mode                           = 'update.pre'
				,@RegistrantAuditSID             = @RegistrantAuditSID
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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

		-- update the record

		update
			dbo.RegistrantAudit
		set
			 RegistrantSID = @RegistrantSID
			,AuditTypeSID = @AuditTypeSID
			,RegistrationYear = @RegistrationYear
			,FormVersionSID = @FormVersionSID
			,FormResponseDraft = @FormResponseDraft
			,LastValidateTime = @LastValidateTime
			,AdminComments = @AdminComments
			,NextFollowUp = @NextFollowUp
			,PendingReviewers = @PendingReviewers
			,ReasonSID = @ReasonSID
			,ConfirmationDraft = @ConfirmationDraft
			,IsAutoApprovalEnabled = @IsAutoApprovalEnabled
			,ReviewReasonList = @ReviewReasonList
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantAuditXID = @RegistrantAuditXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantAuditSID = @RegistrantAuditSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantAudit where RegistrantAuditSID = @registrantAuditSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantAudit'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantAudit'
					,@Arg2        = @registrantAuditSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'dbo.RegistrantAudit'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantAuditSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Sep 2018
		-- VALIDATED status saved the record with the LastValidateTime updated
		-- but should not change underlying status - set back to NULL to
		-- avoid inserting new status record

		if @NewFormStatusSCD = 'VALIDATED'
		begin
			set @NewFormStatusSCD = null
		end

		-- Tim Edlund | Mar 2017
		-- Save the new status value and then store the draft content of the
		-- form into the response history table as long as the change has been
		-- made in the response document. Note that if no previous history
		-- record exists, the form is NEW and the response must be saved
		-- if the status is returned or unlocked set all forms in the form set
		-- to the same status

		declare
			@formDefinition xml

		if @NewFormStatusSCD is not null																			-- if just saving in place (save and continue) pass this as NULL!
		begin

			declare
				@rowGUID		uniqueidentifier

			select
				@rowGUID = ra.RowGUID
			from
				dbo.RegistrantAudit ra
			cross apply
				dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) cs
			where
				ra.RegistrantAuditSID = @RegistrantAuditSID
			and
				cs.FormStatusSCD <> @NewFormStatusSCD

			if @rowGUID is not null
			begin

				set @recordSID		= null
				select @recordSID = fs.FormStatusSID from sf.FormStatus fs where fs.FormStatusSCD = @NewFormStatusSCD

				if @recordSID is null
				begin

					exec sf.pMessage#Get
						 @MessageSCD = 'RecordNotFound'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
						,@Arg1        = 'sf.FormStatus'
						,@Arg2        = @NewFormStatusSCD
									
					raiserror(@errorText, 18, 1)

				end

				exec dbo.pRegistrantAuditStatus#Insert
					 @RegistrantAuditSID  = @RegistrantAuditSID
					,@FormStatusSID				= @recordSID

				if @NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD = 'UNLOCKED'
				begin

						exec dbo.pFormSet#SetStatus	
							 @ParentRowGUID = @rowGUID
							,@FormStatusSCD = @NewFormStatusSCD
							,@IsParentSet		= @ON

				end

			end

			set @recordSID		= null
			select @recordSID = max(rar.RegistrantAuditResponseSID) from dbo.RegistrantAuditResponse rar where rar.RegistrantAuditSID = @RegistrantAuditSID

			if @recordSID is null or (select checksum(cast(rar.FormResponse as nvarchar(max))) from dbo.RegistrantAuditResponse rar where rar.RegistrantAuditResponseSID = @recordSID)
			<> checksum(cast(@FormResponseDraft as nvarchar(max)))							-- if no saved version of form found, OR if current value is changed from latest copy
			begin

				exec dbo.pRegistrantAuditResponse#Insert
					 @RegistrantAuditSID	= @RegistrantAuditSID
					,@FormOwnerSID				= @FormOwnerSID
					,@FormResponse				= @FormResponseDraft

			end

			-- Tim Edlund | Jun 2017
			-- When a list of reviewers is passed in, call the procedure to assign the
			-- review records (do not allow if in a final status)

			if @Reviewers is not null																			
			begin

				declare
					@audits	xml

				if @NewFormStatusSCD <> 'INREVIEW'
				begin

					exec sf.pMessage#Get
						 @MessageSCD  = 'CannotAssignReviewers'
						,@MessageText = @errorText output
						,@DefaultText = N'Reviewers cannot be assigned because the form status has not been set to "%1".'
						,@Arg1        = 'INREVIEW'
									
					raiserror(@errorText, 18, 1)

				end

				set @audits = N'<Audits><RegistrantAudit SID="' + ltrim(@RegistrantAuditSID) + '"/></Audits>'

				exec dbo.pRegistrantAuditReview#Set
						@Audits			= @audits
					,	@Reviewers	= @Reviewers

			end;
			else if @NewFormStatusSCD = 'APPROVED'
			begin

				exec dbo.pRegistrantAudit#Approve
					 @RegistrantAuditSID	= @RegistrantAuditSID
					,@FormResponseDraft		= @FormResponseDraft
					,@FormVersionSID			= @FormVersionSID

			end;
			else if @NewFormStatusSCD in ('CORRECTED','RETURNED') and exists -- if edited by admin and form was previously submitted, call the form post action
					 (
						select
							1
						from
							dbo.RegistrantAuditStatus x
						join
							sf.FormStatus										 fs on x.FormStatusSID = fs.FormStatusSID
						where
							x.RegistrantAuditSID = @RegistrantAuditSID and fs.FormStatusSCD = 'SUBMITTED'
					 )
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.RegistrantAudit rlp
				join
					sf.FormVersion						 fv on rlp.FormVersionSID = fv.FormVersionSID
				where
					rlp.RegistrantAuditSID = @RegistrantAuditSID;

				exec sf.pForm#Post
					@FormRecordSID = @RegistrantAuditSID
				 ,@FormActionCode = 'SUBMIT'
				 ,@FormSchemaName = 'dbo'
				 ,@FormTableName = 'RegistrantAudit'
				 ,@FormDefinition = @formDefinition
				 ,@Response = @FormResponseDraft;

			end;
			else if @NewFormStatusSCD = 'WITHDRAWN'
			begin

				exec dbo.pRegistrantAudit#Withdraw
					@RegistrantAuditSID = @RegistrantAuditSID

			end;
		end
		--! </PostUpdate>
	
		-- call the extended version of the procedure for update.post - if it exists
		
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
				 @Mode                           = 'update.post'
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
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
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
