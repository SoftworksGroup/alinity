SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#Update]
	 @RegistrantLearningPlanSID         int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                     int               = null -- table column values to update:
	,@RegistrationYear                  smallint          = null
	,@LearningModelSID                  int               = null
	,@FormVersionSID                    int               = null
	,@LastValidateTime                  datetimeoffset(7) = null
	,@FormResponseDraft                 xml               = null
	,@AdminComments                     xml               = null
	,@NextFollowUp                      date              = null
	,@ConfirmationDraft                 nvarchar(max)     = null
	,@ReasonSID                         int               = null
	,@IsAutoApprovalEnabled             bit               = null
	,@ReviewReasonList                  xml               = null
	,@ParentRowGUID                     uniqueidentifier  = null
	,@UserDefinedColumns                xml               = null
	,@RegistrantLearningPlanXID         varchar(150)      = null
	,@LegacyKey                         nvarchar(50)      = null
	,@UpdateUser                        nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                          timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                      tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                     bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                          xml               = null -- other values defining context for the update (if any)
	,@LearningModelSCD                  varchar(15)       = null -- not a base table column
	,@LearningModelLabel                nvarchar(35)      = null -- not a base table column
	,@LearningModelIsDefault            bit               = null -- not a base table column
	,@UnitTypeSID                       int               = null -- not a base table column
	,@CycleLengthYears                  smallint          = null -- not a base table column
	,@IsCycleStartedYear1               bit               = null -- not a base table column
	,@MaximumCarryOver                  decimal(5,2)      = null -- not a base table column
	,@LearningModelRowGUID              uniqueidentifier  = null -- not a base table column
	,@PersonSID                         int               = null -- not a base table column
	,@RegistrantNo                      varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment           smallint          = null -- not a base table column
	,@IsOnPublicRegistry                bit               = null -- not a base table column
	,@CityNameOfBirth                   nvarchar(30)      = null -- not a base table column
	,@CountrySID                        int               = null -- not a base table column
	,@DirectedAuditYearCompetence       smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours    smallint          = null -- not a base table column
	,@LateFeeExclusionYear              smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked      bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime        datetime          = null -- not a base table column
	,@ArchivedTime                      datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                 uniqueidentifier  = null -- not a base table column
	,@FormSID                           int               = null -- not a base table column
	,@VersionNo                         smallint          = null -- not a base table column
	,@RevisionNo                        smallint          = null -- not a base table column
	,@IsSaveDisplayed                   bit               = null -- not a base table column
	,@ApprovedTime                      datetimeoffset(7) = null -- not a base table column
	,@FormVersionRowGUID                uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                    int               = null -- not a base table column
	,@ReasonName                        nvarchar(50)      = null -- not a base table column
	,@ReasonCode                        varchar(25)       = null -- not a base table column
	,@ReasonSequence                    smallint          = null -- not a base table column
	,@ToolTip                           nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                    bit               = null -- not a base table column
	,@ReasonRowGUID                     uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                   bit               = null -- not a base table column
	,@IsViewEnabled                     bit               = null -- not a base table column
	,@IsEditEnabled                     bit               = null -- not a base table column
	,@IsSaveBtnDisplayed                bit               = null -- not a base table column
	,@IsApproveEnabled                  bit               = null -- not a base table column
	,@IsRejectEnabled                   bit               = null -- not a base table column
	,@IsUnlockEnabled                   bit               = null -- not a base table column
	,@IsWithdrawalEnabled               bit               = null -- not a base table column
	,@IsInProgress                      bit               = null -- not a base table column
	,@RegistrantLearningPlanStatusSID   int               = null -- not a base table column
	,@RegistrantLearningPlanStatusSCD   varchar(25)       = null -- not a base table column
	,@RegistrantLearningPlanStatusLabel nvarchar(35)      = null -- not a base table column
	,@LastStatusChangeUser              nvarchar(75)      = null -- not a base table column
	,@LastStatusChangeTime              datetimeoffset(7) = null -- not a base table column
	,@FormOwnerSCD                      varchar(25)       = null -- not a base table column
	,@FormOwnerLabel                    nvarchar(35)      = null -- not a base table column
	,@FormOwnerSID                      int               = null -- not a base table column
	,@IsPDFDisplayed                    bit               = null -- not a base table column
	,@PersonDocSID                      int               = null -- not a base table column
	,@RegistrantLearningPlanLabel       nvarchar(80)      = null -- not a base table column
	,@RegistrationYearLabel             nvarchar(9)       = null -- not a base table column
	,@CycleEndRegistrationYear          smallint          = null -- not a base table column
	,@CycleRegistrationYearLabel        nvarchar(21)      = null -- not a base table column
	,@NewFormStatusSCD                  varchar(25)       = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantLearningPlan#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantLearningPlan table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantLearningPlan table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantLearningPlan entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantLearningPlan procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantLearningPlanCheck to test all rules.

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

		if @RegistrantLearningPlanSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantLearningPlanSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrantLearningPlanXID = ltrim(rtrim(@RegistrantLearningPlanXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @LearningModelSCD = ltrim(rtrim(@LearningModelSCD))
		set @LearningModelLabel = ltrim(rtrim(@LearningModelLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @RegistrantLearningPlanStatusSCD = ltrim(rtrim(@RegistrantLearningPlanStatusSCD))
		set @RegistrantLearningPlanStatusLabel = ltrim(rtrim(@RegistrantLearningPlanStatusLabel))
		set @LastStatusChangeUser = ltrim(rtrim(@LastStatusChangeUser))
		set @FormOwnerSCD = ltrim(rtrim(@FormOwnerSCD))
		set @FormOwnerLabel = ltrim(rtrim(@FormOwnerLabel))
		set @RegistrantLearningPlanLabel = ltrim(rtrim(@RegistrantLearningPlanLabel))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))
		set @CycleRegistrationYearLabel = ltrim(rtrim(@CycleRegistrationYearLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrantLearningPlanXID) = 0 set @RegistrantLearningPlanXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@LearningModelSCD) = 0 set @LearningModelSCD = null
		if len(@LearningModelLabel) = 0 set @LearningModelLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@RegistrantLearningPlanStatusSCD) = 0 set @RegistrantLearningPlanStatusSCD = null
		if len(@RegistrantLearningPlanStatusLabel) = 0 set @RegistrantLearningPlanStatusLabel = null
		if len(@LastStatusChangeUser) = 0 set @LastStatusChangeUser = null
		if len(@FormOwnerSCD) = 0 set @FormOwnerSCD = null
		if len(@FormOwnerLabel) = 0 set @FormOwnerLabel = null
		if len(@RegistrantLearningPlanLabel) = 0 set @RegistrantLearningPlanLabel = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null
		if len(@CycleRegistrationYearLabel) = 0 set @CycleRegistrationYearLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                     = isnull(@RegistrantSID,rlp.RegistrantSID)
				,@RegistrationYear                  = isnull(@RegistrationYear,rlp.RegistrationYear)
				,@LearningModelSID                  = isnull(@LearningModelSID,rlp.LearningModelSID)
				,@FormVersionSID                    = isnull(@FormVersionSID,rlp.FormVersionSID)
				,@LastValidateTime                  = isnull(@LastValidateTime,rlp.LastValidateTime)
				,@FormResponseDraft                 = isnull(@FormResponseDraft,rlp.FormResponseDraft)
				,@AdminComments                     = isnull(@AdminComments,rlp.AdminComments)
				,@NextFollowUp                      = isnull(@NextFollowUp,rlp.NextFollowUp)
				,@ConfirmationDraft                 = isnull(@ConfirmationDraft,rlp.ConfirmationDraft)
				,@ReasonSID                         = isnull(@ReasonSID,rlp.ReasonSID)
				,@IsAutoApprovalEnabled             = isnull(@IsAutoApprovalEnabled,rlp.IsAutoApprovalEnabled)
				,@ReviewReasonList                  = isnull(@ReviewReasonList,rlp.ReviewReasonList)
				,@ParentRowGUID                     = isnull(@ParentRowGUID,rlp.ParentRowGUID)
				,@UserDefinedColumns                = isnull(@UserDefinedColumns,rlp.UserDefinedColumns)
				,@RegistrantLearningPlanXID         = isnull(@RegistrantLearningPlanXID,rlp.RegistrantLearningPlanXID)
				,@LegacyKey                         = isnull(@LegacyKey,rlp.LegacyKey)
				,@UpdateUser                        = isnull(@UpdateUser,rlp.UpdateUser)
				,@IsReselected                      = isnull(@IsReselected,rlp.IsReselected)
				,@IsNullApplied                     = isnull(@IsNullApplied,rlp.IsNullApplied)
				,@zContext                          = isnull(@zContext,rlp.zContext)
				,@LearningModelSCD                  = isnull(@LearningModelSCD,rlp.LearningModelSCD)
				,@LearningModelLabel                = isnull(@LearningModelLabel,rlp.LearningModelLabel)
				,@LearningModelIsDefault            = isnull(@LearningModelIsDefault,rlp.LearningModelIsDefault)
				,@UnitTypeSID                       = isnull(@UnitTypeSID,rlp.UnitTypeSID)
				,@CycleLengthYears                  = isnull(@CycleLengthYears,rlp.CycleLengthYears)
				,@IsCycleStartedYear1               = isnull(@IsCycleStartedYear1,rlp.IsCycleStartedYear1)
				,@MaximumCarryOver                  = isnull(@MaximumCarryOver,rlp.MaximumCarryOver)
				,@LearningModelRowGUID              = isnull(@LearningModelRowGUID,rlp.LearningModelRowGUID)
				,@PersonSID                         = isnull(@PersonSID,rlp.PersonSID)
				,@RegistrantNo                      = isnull(@RegistrantNo,rlp.RegistrantNo)
				,@YearOfInitialEmployment           = isnull(@YearOfInitialEmployment,rlp.YearOfInitialEmployment)
				,@IsOnPublicRegistry                = isnull(@IsOnPublicRegistry,rlp.IsOnPublicRegistry)
				,@CityNameOfBirth                   = isnull(@CityNameOfBirth,rlp.CityNameOfBirth)
				,@CountrySID                        = isnull(@CountrySID,rlp.CountrySID)
				,@DirectedAuditYearCompetence       = isnull(@DirectedAuditYearCompetence,rlp.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours    = isnull(@DirectedAuditYearPracticeHours,rlp.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear              = isnull(@LateFeeExclusionYear,rlp.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked      = isnull(@IsRenewalAutoApprovalBlocked,rlp.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime        = isnull(@RenewalExtensionExpiryTime,rlp.RenewalExtensionExpiryTime)
				,@ArchivedTime                      = isnull(@ArchivedTime,rlp.ArchivedTime)
				,@RegistrantRowGUID                 = isnull(@RegistrantRowGUID,rlp.RegistrantRowGUID)
				,@FormSID                           = isnull(@FormSID,rlp.FormSID)
				,@VersionNo                         = isnull(@VersionNo,rlp.VersionNo)
				,@RevisionNo                        = isnull(@RevisionNo,rlp.RevisionNo)
				,@IsSaveDisplayed                   = isnull(@IsSaveDisplayed,rlp.IsSaveDisplayed)
				,@ApprovedTime                      = isnull(@ApprovedTime,rlp.ApprovedTime)
				,@FormVersionRowGUID                = isnull(@FormVersionRowGUID,rlp.FormVersionRowGUID)
				,@ReasonGroupSID                    = isnull(@ReasonGroupSID,rlp.ReasonGroupSID)
				,@ReasonName                        = isnull(@ReasonName,rlp.ReasonName)
				,@ReasonCode                        = isnull(@ReasonCode,rlp.ReasonCode)
				,@ReasonSequence                    = isnull(@ReasonSequence,rlp.ReasonSequence)
				,@ToolTip                           = isnull(@ToolTip,rlp.ToolTip)
				,@ReasonIsActive                    = isnull(@ReasonIsActive,rlp.ReasonIsActive)
				,@ReasonRowGUID                     = isnull(@ReasonRowGUID,rlp.ReasonRowGUID)
				,@IsDeleteEnabled                   = isnull(@IsDeleteEnabled,rlp.IsDeleteEnabled)
				,@IsViewEnabled                     = isnull(@IsViewEnabled,rlp.IsViewEnabled)
				,@IsEditEnabled                     = isnull(@IsEditEnabled,rlp.IsEditEnabled)
				,@IsSaveBtnDisplayed                = isnull(@IsSaveBtnDisplayed,rlp.IsSaveBtnDisplayed)
				,@IsApproveEnabled                  = isnull(@IsApproveEnabled,rlp.IsApproveEnabled)
				,@IsRejectEnabled                   = isnull(@IsRejectEnabled,rlp.IsRejectEnabled)
				,@IsUnlockEnabled                   = isnull(@IsUnlockEnabled,rlp.IsUnlockEnabled)
				,@IsWithdrawalEnabled               = isnull(@IsWithdrawalEnabled,rlp.IsWithdrawalEnabled)
				,@IsInProgress                      = isnull(@IsInProgress,rlp.IsInProgress)
				,@RegistrantLearningPlanStatusSID   = isnull(@RegistrantLearningPlanStatusSID,rlp.RegistrantLearningPlanStatusSID)
				,@RegistrantLearningPlanStatusSCD   = isnull(@RegistrantLearningPlanStatusSCD,rlp.RegistrantLearningPlanStatusSCD)
				,@RegistrantLearningPlanStatusLabel = isnull(@RegistrantLearningPlanStatusLabel,rlp.RegistrantLearningPlanStatusLabel)
				,@LastStatusChangeUser              = isnull(@LastStatusChangeUser,rlp.LastStatusChangeUser)
				,@LastStatusChangeTime              = isnull(@LastStatusChangeTime,rlp.LastStatusChangeTime)
				,@FormOwnerSCD                      = isnull(@FormOwnerSCD,rlp.FormOwnerSCD)
				,@FormOwnerLabel                    = isnull(@FormOwnerLabel,rlp.FormOwnerLabel)
				,@FormOwnerSID                      = isnull(@FormOwnerSID,rlp.FormOwnerSID)
				,@IsPDFDisplayed                    = isnull(@IsPDFDisplayed,rlp.IsPDFDisplayed)
				,@PersonDocSID                      = isnull(@PersonDocSID,rlp.PersonDocSID)
				,@RegistrantLearningPlanLabel       = isnull(@RegistrantLearningPlanLabel,rlp.RegistrantLearningPlanLabel)
				,@RegistrationYearLabel             = isnull(@RegistrationYearLabel,rlp.RegistrationYearLabel)
				,@CycleEndRegistrationYear          = isnull(@CycleEndRegistrationYear,rlp.CycleEndRegistrationYear)
				,@CycleRegistrationYearLabel        = isnull(@CycleRegistrationYearLabel,rlp.CycleRegistrationYearLabel)
				,@NewFormStatusSCD                  = isnull(@NewFormStatusSCD,rlp.NewFormStatusSCD)
			from
				dbo.vRegistrantLearningPlan rlp
			where
				rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @LearningModelSCD is not null and @LearningModelSID = (select x.LearningModelSID from dbo.RegistrantLearningPlan x where x.RegistrantLearningPlanSID = @RegistrantLearningPlanSID)
		begin
		
			select
				@LearningModelSID = x.LearningModelSID
			from
				dbo.LearningModel x
			where
				x.LearningModelSCD = @LearningModelSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ReasonSID from dbo.RegistrantLearningPlan x where x.RegistrantLearningPlanSID = @RegistrantLearningPlanSID) <> @ReasonSID
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
		-- Tim Edlund | Jan 2019
		-- Set the last validated time on statuses that executed the checks but
		-- clear it when the form is being RETURNED or where no status is set
		-- in which case the form is only being saved in place

		if @NewFormStatusSCD in ('VALIDATED', 'SUBMITTED', 'APPROVED')
		begin
			set @LastValidateTime = sysdatetimeoffset()
		end
		else if @NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD is null
		begin
			set @LastValidateTime = null
		end

		if @LastValidateTime is null and exists (select (1) from dbo.RegistrantRenewal where RowGUID = @ParentRowGUID and LastValidateTime is not null) -- where validation is cleared on child, clear on parent form
		begin

			update
				dbo.RegistrantRenewal
			set
				LastValidateTime = null
			 ,UpdateTime = sysdatetimeoffset()
			 ,UpdateUser = @UpdateUser
			where
				RowGUID = @ParentRowGUID;

		end;

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
				r.RoutineName = 'pRegistrantLearningPlan'
		)
		begin
		
			exec @errorNo = ext.pRegistrantLearningPlan
				 @Mode                              = 'update.pre'
				,@RegistrantLearningPlanSID         = @RegistrantLearningPlanSID
				,@RegistrantSID                     = @RegistrantSID output
				,@RegistrationYear                  = @RegistrationYear output
				,@LearningModelSID                  = @LearningModelSID output
				,@FormVersionSID                    = @FormVersionSID output
				,@LastValidateTime                  = @LastValidateTime output
				,@FormResponseDraft                 = @FormResponseDraft output
				,@AdminComments                     = @AdminComments output
				,@NextFollowUp                      = @NextFollowUp output
				,@ConfirmationDraft                 = @ConfirmationDraft output
				,@ReasonSID                         = @ReasonSID output
				,@IsAutoApprovalEnabled             = @IsAutoApprovalEnabled output
				,@ReviewReasonList                  = @ReviewReasonList output
				,@ParentRowGUID                     = @ParentRowGUID output
				,@UserDefinedColumns                = @UserDefinedColumns output
				,@RegistrantLearningPlanXID         = @RegistrantLearningPlanXID output
				,@LegacyKey                         = @LegacyKey output
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
				,@zContext                          = @zContext
				,@LearningModelSCD                  = @LearningModelSCD
				,@LearningModelLabel                = @LearningModelLabel
				,@LearningModelIsDefault            = @LearningModelIsDefault
				,@UnitTypeSID                       = @UnitTypeSID
				,@CycleLengthYears                  = @CycleLengthYears
				,@IsCycleStartedYear1               = @IsCycleStartedYear1
				,@MaximumCarryOver                  = @MaximumCarryOver
				,@LearningModelRowGUID              = @LearningModelRowGUID
				,@PersonSID                         = @PersonSID
				,@RegistrantNo                      = @RegistrantNo
				,@YearOfInitialEmployment           = @YearOfInitialEmployment
				,@IsOnPublicRegistry                = @IsOnPublicRegistry
				,@CityNameOfBirth                   = @CityNameOfBirth
				,@CountrySID                        = @CountrySID
				,@DirectedAuditYearCompetence       = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours    = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear              = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked      = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime        = @RenewalExtensionExpiryTime
				,@ArchivedTime                      = @ArchivedTime
				,@RegistrantRowGUID                 = @RegistrantRowGUID
				,@FormSID                           = @FormSID
				,@VersionNo                         = @VersionNo
				,@RevisionNo                        = @RevisionNo
				,@IsSaveDisplayed                   = @IsSaveDisplayed
				,@ApprovedTime                      = @ApprovedTime
				,@FormVersionRowGUID                = @FormVersionRowGUID
				,@ReasonGroupSID                    = @ReasonGroupSID
				,@ReasonName                        = @ReasonName
				,@ReasonCode                        = @ReasonCode
				,@ReasonSequence                    = @ReasonSequence
				,@ToolTip                           = @ToolTip
				,@ReasonIsActive                    = @ReasonIsActive
				,@ReasonRowGUID                     = @ReasonRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@IsViewEnabled                     = @IsViewEnabled
				,@IsEditEnabled                     = @IsEditEnabled
				,@IsSaveBtnDisplayed                = @IsSaveBtnDisplayed
				,@IsApproveEnabled                  = @IsApproveEnabled
				,@IsRejectEnabled                   = @IsRejectEnabled
				,@IsUnlockEnabled                   = @IsUnlockEnabled
				,@IsWithdrawalEnabled               = @IsWithdrawalEnabled
				,@IsInProgress                      = @IsInProgress
				,@RegistrantLearningPlanStatusSID   = @RegistrantLearningPlanStatusSID
				,@RegistrantLearningPlanStatusSCD   = @RegistrantLearningPlanStatusSCD
				,@RegistrantLearningPlanStatusLabel = @RegistrantLearningPlanStatusLabel
				,@LastStatusChangeUser              = @LastStatusChangeUser
				,@LastStatusChangeTime              = @LastStatusChangeTime
				,@FormOwnerSCD                      = @FormOwnerSCD
				,@FormOwnerLabel                    = @FormOwnerLabel
				,@FormOwnerSID                      = @FormOwnerSID
				,@IsPDFDisplayed                    = @IsPDFDisplayed
				,@PersonDocSID                      = @PersonDocSID
				,@RegistrantLearningPlanLabel       = @RegistrantLearningPlanLabel
				,@RegistrationYearLabel             = @RegistrationYearLabel
				,@CycleEndRegistrationYear          = @CycleEndRegistrationYear
				,@CycleRegistrationYearLabel        = @CycleRegistrationYearLabel
				,@NewFormStatusSCD                  = @NewFormStatusSCD
		
		end

		-- update the record

		update
			dbo.RegistrantLearningPlan
		set
			 RegistrantSID = @RegistrantSID
			,RegistrationYear = @RegistrationYear
			,LearningModelSID = @LearningModelSID
			,FormVersionSID = @FormVersionSID
			,LastValidateTime = @LastValidateTime
			,FormResponseDraft = @FormResponseDraft
			,AdminComments = @AdminComments
			,NextFollowUp = @NextFollowUp
			,ConfirmationDraft = @ConfirmationDraft
			,ReasonSID = @ReasonSID
			,IsAutoApprovalEnabled = @IsAutoApprovalEnabled
			,ReviewReasonList = @ReviewReasonList
			,ParentRowGUID = @ParentRowGUID
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantLearningPlanXID = @RegistrantLearningPlanXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantLearningPlanSID = @RegistrantLearningPlanSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantLearningPlan where RegistrantLearningPlanSID = @registrantLearningPlanSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantLearningPlan'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantLearningPlan'
					,@Arg2        = @registrantLearningPlanSID
				
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
				,@Arg2        = 'dbo.RegistrantLearningPlan'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantLearningPlanSID
			
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

		-- Cory Ng | Dec 2017
		-- Save the new status value and then store the draft content of the
		-- form into the response history table as long as the change has been
		-- made in the response document. Note that if no previous history
		-- record exists, the form is NEW and the response must be saved
		-- if the status is returned or unlocked and the learning plan is
		-- part of a form set, set all other forms to the same status

		declare
			@formDefinition xml

		if @NewFormStatusSCD is not null -- if just saving in place (save and continue) pass this as NULL!
		begin

			if not exists (
				select
					1
				from
					dbo.RegistrantLearningPlan rlp
				cross apply
					dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
				where
					rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID
				and
					cs.FormStatusSCD = @NewFormStatusSCD
			)
			begin

				set @recordSID = null;

				select
					@recordSID = fs.FormStatusSID
				from
					sf.FormStatus fs
				where
					fs.FormStatusSCD = @NewFormStatusSCD;

				if @recordSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'sf.FormStatus'
					 ,@Arg2 = @NewFormStatusSCD;

					raiserror(@errorText, 18, 1);

				end;

				exec dbo.pRegistrantLearningPlanStatus#Insert
					@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
				 ,@FormStatusSID = @recordSID;

				if (@NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD = 'UNLOCKED') and @ParentRowGUID is not null
				begin

						exec dbo.pFormSet#SetStatus	
							 @ParentRowGUID = @ParentRowGUID
							,@FormStatusSCD = @NewFormStatusSCD
							,@IsParentSet		= @OFF

				end

			end

			set @recordSID = null;

			select
				@recordSID = max(rar.RegistrantLearningPlanResponseSID)
			from
				dbo.RegistrantLearningPlanResponse rar
			where
				rar.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

			if @recordSID is null or
														(
															select
																checksum(cast(rar.FormResponse as nvarchar(max)))
															from
																dbo.RegistrantLearningPlanResponse rar
															where
																rar.RegistrantLearningPlanResponseSID = @recordSID
														) <> checksum(cast(@FormResponseDraft as nvarchar(max))) -- if no saved version of form found, OR if current value is changed from latest copy
			begin

				exec dbo.pRegistrantLearningPlanResponse#Insert
					@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
				 ,@FormOwnerSID = @FormOwnerSID
				 ,@FormResponse = @FormResponseDraft;

			end;

			-- post values to the main profile as required for
			-- the SUBMIT and APPROVE form actions

			if @NewFormStatusSCD = 'SUBMITTED'
			begin

				exec dbo.pRegistrantLearningPlan#Submit
					@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID;

			end;
			else if @NewFormStatusSCD = 'APPROVED'
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.RegistrantLearningPlan rlp
				join
					sf.FormVersion						 fv on rlp.FormVersionSID = fv.FormVersionSID
				where
					rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

				exec dbo.pRegistrantLearningPlan#Approve
					@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID
				 ,@FormDefinition = @formDefinition;

			end;
			else if @NewFormStatusSCD in ('CORRECTED','RETURNED') and exists -- if edited by admin and form was previously submitted, call the form post action
					 (
						select
							1
						from
							dbo.RegistrantLearningPlanStatus x
						join
							sf.FormStatus										 fs on x.FormStatusSID = fs.FormStatusSID
						where
							x.RegistrantLearningPlanSID = @RegistrantLearningPlanSID and fs.FormStatusSCD = 'SUBMITTED'
					 )
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.RegistrantLearningPlan rlp
				join
					sf.FormVersion						 fv on rlp.FormVersionSID = fv.FormVersionSID
				where
					rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

				exec sf.pForm#Post
					@FormRecordSID = @RegistrantLearningPlanSID
				 ,@FormActionCode = 'SUBMIT'
				 ,@FormSchemaName = 'dbo'
				 ,@FormTableName = 'RegistrantLearningPlan'
				 ,@FormDefinition = @formDefinition
				 ,@Response = @FormResponseDraft;

			end;
		end;
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
				r.RoutineName = 'pRegistrantLearningPlan'
		)
		begin
		
			exec @errorNo = ext.pRegistrantLearningPlan
				 @Mode                              = 'update.post'
				,@RegistrantLearningPlanSID         = @RegistrantLearningPlanSID
				,@RegistrantSID                     = @RegistrantSID
				,@RegistrationYear                  = @RegistrationYear
				,@LearningModelSID                  = @LearningModelSID
				,@FormVersionSID                    = @FormVersionSID
				,@LastValidateTime                  = @LastValidateTime
				,@FormResponseDraft                 = @FormResponseDraft
				,@AdminComments                     = @AdminComments
				,@NextFollowUp                      = @NextFollowUp
				,@ConfirmationDraft                 = @ConfirmationDraft
				,@ReasonSID                         = @ReasonSID
				,@IsAutoApprovalEnabled             = @IsAutoApprovalEnabled
				,@ReviewReasonList                  = @ReviewReasonList
				,@ParentRowGUID                     = @ParentRowGUID
				,@UserDefinedColumns                = @UserDefinedColumns
				,@RegistrantLearningPlanXID         = @RegistrantLearningPlanXID
				,@LegacyKey                         = @LegacyKey
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
				,@zContext                          = @zContext
				,@LearningModelSCD                  = @LearningModelSCD
				,@LearningModelLabel                = @LearningModelLabel
				,@LearningModelIsDefault            = @LearningModelIsDefault
				,@UnitTypeSID                       = @UnitTypeSID
				,@CycleLengthYears                  = @CycleLengthYears
				,@IsCycleStartedYear1               = @IsCycleStartedYear1
				,@MaximumCarryOver                  = @MaximumCarryOver
				,@LearningModelRowGUID              = @LearningModelRowGUID
				,@PersonSID                         = @PersonSID
				,@RegistrantNo                      = @RegistrantNo
				,@YearOfInitialEmployment           = @YearOfInitialEmployment
				,@IsOnPublicRegistry                = @IsOnPublicRegistry
				,@CityNameOfBirth                   = @CityNameOfBirth
				,@CountrySID                        = @CountrySID
				,@DirectedAuditYearCompetence       = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours    = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear              = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked      = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime        = @RenewalExtensionExpiryTime
				,@ArchivedTime                      = @ArchivedTime
				,@RegistrantRowGUID                 = @RegistrantRowGUID
				,@FormSID                           = @FormSID
				,@VersionNo                         = @VersionNo
				,@RevisionNo                        = @RevisionNo
				,@IsSaveDisplayed                   = @IsSaveDisplayed
				,@ApprovedTime                      = @ApprovedTime
				,@FormVersionRowGUID                = @FormVersionRowGUID
				,@ReasonGroupSID                    = @ReasonGroupSID
				,@ReasonName                        = @ReasonName
				,@ReasonCode                        = @ReasonCode
				,@ReasonSequence                    = @ReasonSequence
				,@ToolTip                           = @ToolTip
				,@ReasonIsActive                    = @ReasonIsActive
				,@ReasonRowGUID                     = @ReasonRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@IsViewEnabled                     = @IsViewEnabled
				,@IsEditEnabled                     = @IsEditEnabled
				,@IsSaveBtnDisplayed                = @IsSaveBtnDisplayed
				,@IsApproveEnabled                  = @IsApproveEnabled
				,@IsRejectEnabled                   = @IsRejectEnabled
				,@IsUnlockEnabled                   = @IsUnlockEnabled
				,@IsWithdrawalEnabled               = @IsWithdrawalEnabled
				,@IsInProgress                      = @IsInProgress
				,@RegistrantLearningPlanStatusSID   = @RegistrantLearningPlanStatusSID
				,@RegistrantLearningPlanStatusSCD   = @RegistrantLearningPlanStatusSCD
				,@RegistrantLearningPlanStatusLabel = @RegistrantLearningPlanStatusLabel
				,@LastStatusChangeUser              = @LastStatusChangeUser
				,@LastStatusChangeTime              = @LastStatusChangeTime
				,@FormOwnerSCD                      = @FormOwnerSCD
				,@FormOwnerLabel                    = @FormOwnerLabel
				,@FormOwnerSID                      = @FormOwnerSID
				,@IsPDFDisplayed                    = @IsPDFDisplayed
				,@PersonDocSID                      = @PersonDocSID
				,@RegistrantLearningPlanLabel       = @RegistrantLearningPlanLabel
				,@RegistrationYearLabel             = @RegistrationYearLabel
				,@CycleEndRegistrationYear          = @CycleEndRegistrationYear
				,@CycleRegistrationYearLabel        = @CycleRegistrationYearLabel
				,@NewFormStatusSCD                  = @NewFormStatusSCD
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantLearningPlanSID
			from
				dbo.vRegistrantLearningPlan ent
			where
				ent.RegistrantLearningPlanSID = @RegistrantLearningPlanSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantLearningPlanSID
				,ent.RegistrantSID
				,ent.RegistrationYear
				,ent.LearningModelSID
				,ent.FormVersionSID
				,ent.LastValidateTime
				,ent.FormResponseDraft
				,ent.AdminComments
				,ent.NextFollowUp
				,ent.ConfirmationDraft
				,ent.ReasonSID
				,ent.IsAutoApprovalEnabled
				,ent.ReviewReasonList
				,ent.ParentRowGUID
				,ent.UserDefinedColumns
				,ent.RegistrantLearningPlanXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.LearningModelSCD
				,ent.LearningModelLabel
				,ent.LearningModelIsDefault
				,ent.UnitTypeSID
				,ent.CycleLengthYears
				,ent.IsCycleStartedYear1
				,ent.MaximumCarryOver
				,ent.LearningModelRowGUID
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
				,ent.RegistrantLearningPlanStatusSID
				,ent.RegistrantLearningPlanStatusSCD
				,ent.RegistrantLearningPlanStatusLabel
				,ent.LastStatusChangeUser
				,ent.LastStatusChangeTime
				,ent.FormOwnerSCD
				,ent.FormOwnerLabel
				,ent.FormOwnerSID
				,ent.IsPDFDisplayed
				,ent.PersonDocSID
				,ent.RegistrantLearningPlanLabel
				,ent.RegistrationYearLabel
				,ent.CycleEndRegistrationYear
				,ent.CycleRegistrationYearLabel
				,ent.NewFormStatusSCD
			from
				dbo.vRegistrantLearningPlan ent
			where
				ent.RegistrantLearningPlanSID = @RegistrantLearningPlanSID

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
