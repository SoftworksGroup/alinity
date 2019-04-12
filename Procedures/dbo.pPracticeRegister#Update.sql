SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegister#Update]
	 @PracticeRegisterSID                      int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PracticeRegisterTypeSID                  int               = null -- table column values to update:
	,@RegistrationScheduleSID                  int               = null
	,@PracticeRegisterName                     nvarchar(65)      = null
	,@PracticeRegisterLabel                    nvarchar(35)      = null
	,@IsActivePractice                         bit               = null
	,@IsPublicRegistryEnabled                  bit               = null
	,@IsRenewalEnabled                         bit               = null
	,@IsLearningPlanEnabled                    bit               = null
	,@IsNextCEFormAutoAdded                    bit               = null
	,@IsEligibleSupervisor                     bit               = null
	,@IsSupervisionRequired                    bit               = null
	,@IsEmploymentTerminated                   bit               = null
	,@IsGroupMembershipTerminated              bit               = null
	,@TermPermitDays                           int               = null
	,@RegisterRank                             smallint          = null
	,@LearningModelSID                         int               = null
	,@ReasonGroupSID                           int               = null
	,@IsDefault                                bit               = null
	,@IsDefaultInactivePractice                bit               = null
	,@Description                              varbinary(max)    = null
	,@IsActive                                 bit               = null
	,@UserDefinedColumns                       xml               = null
	,@PracticeRegisterXID                      varchar(150)      = null
	,@LegacyKey                                nvarchar(50)      = null
	,@UpdateUser                               nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                 timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                             tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                            bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                 xml               = null -- other values defining context for the update (if any)
	,@PracticeRegisterTypeSCD                  varchar(15)       = null -- not a base table column
	,@PracticeRegisterTypeLabel                nvarchar(35)      = null -- not a base table column
	,@PracticeRegisterTypeCategory             nvarchar(65)      = null -- not a base table column
	,@PracticeRegisterTypeIsDefault            bit               = null -- not a base table column
	,@PracticeRegisterTypeIsActive             bit               = null -- not a base table column
	,@PracticeRegisterTypeRowGUID              uniqueidentifier  = null -- not a base table column
	,@RegistrationScheduleLabel                nvarchar(35)      = null -- not a base table column
	,@RegistrationScheduleIsDefault            bit               = null -- not a base table column
	,@RegistrationScheduleIsActive             bit               = null -- not a base table column
	,@RegistrationScheduleRowGUID              uniqueidentifier  = null -- not a base table column
	,@LearningModelSCD                         varchar(15)       = null -- not a base table column
	,@LearningModelLabel                       nvarchar(35)      = null -- not a base table column
	,@LearningModelIsDefault                   bit               = null -- not a base table column
	,@UnitTypeSID                              int               = null -- not a base table column
	,@CycleLengthYears                         smallint          = null -- not a base table column
	,@IsCycleStartedYear1                      bit               = null -- not a base table column
	,@MaximumCarryOver                         decimal(5,2)      = null -- not a base table column
	,@LearningModelRowGUID                     uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSCD                           varchar(20)       = null -- not a base table column
	,@ReasonGroupLabel                         nvarchar(35)      = null -- not a base table column
	,@IsLockedGroup                            bit               = null -- not a base table column
	,@ReasonGroupRowGUID                       uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                          bit               = null -- not a base table column
	,@RegistrantAppFormVersionSID              int               = null -- not a base table column
	,@RegistrantAppVerificationFormVersionSID  int               = null -- not a base table column
	,@RegistrantRenewalFormVersionSID          int               = null -- not a base table column
	,@RegistrantRenewalReviewFormVersionSID    int               = null -- not a base table column
	,@CompetenceReviewFormVersionSID           int               = null -- not a base table column
	,@CompetenceReviewAssessmentFormVersionSID int               = null -- not a base table column
	,@CurrentRegistrationYear                  smallint          = null -- not a base table column
	,@CurrentRenewalYear                       smallint          = null -- not a base table column
	,@CurrentReinstatementYear                 smallint          = null -- not a base table column
	,@NextReinstatementYear                    smallint          = null -- not a base table column
	,@IsCurrentUserVerifier                    bit               = null -- not a base table column
	,@IsLearningModelApplied                   bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegister#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PracticeRegister table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PracticeRegister table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPracticeRegister entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPracticeRegister procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPracticeRegisterCheck to test all rules.

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

		if @PracticeRegisterSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PracticeRegisterSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRegisterXID = ltrim(rtrim(@PracticeRegisterXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PracticeRegisterTypeSCD = ltrim(rtrim(@PracticeRegisterTypeSCD))
		set @PracticeRegisterTypeLabel = ltrim(rtrim(@PracticeRegisterTypeLabel))
		set @PracticeRegisterTypeCategory = ltrim(rtrim(@PracticeRegisterTypeCategory))
		set @RegistrationScheduleLabel = ltrim(rtrim(@RegistrationScheduleLabel))
		set @LearningModelSCD = ltrim(rtrim(@LearningModelSCD))
		set @LearningModelLabel = ltrim(rtrim(@LearningModelLabel))
		set @ReasonGroupSCD = ltrim(rtrim(@ReasonGroupSCD))
		set @ReasonGroupLabel = ltrim(rtrim(@ReasonGroupLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRegisterXID) = 0 set @PracticeRegisterXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PracticeRegisterTypeSCD) = 0 set @PracticeRegisterTypeSCD = null
		if len(@PracticeRegisterTypeLabel) = 0 set @PracticeRegisterTypeLabel = null
		if len(@PracticeRegisterTypeCategory) = 0 set @PracticeRegisterTypeCategory = null
		if len(@RegistrationScheduleLabel) = 0 set @RegistrationScheduleLabel = null
		if len(@LearningModelSCD) = 0 set @LearningModelSCD = null
		if len(@LearningModelLabel) = 0 set @LearningModelLabel = null
		if len(@ReasonGroupSCD) = 0 set @ReasonGroupSCD = null
		if len(@ReasonGroupLabel) = 0 set @ReasonGroupLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PracticeRegisterTypeSID                  = isnull(@PracticeRegisterTypeSID,pr.PracticeRegisterTypeSID)
				,@RegistrationScheduleSID                  = isnull(@RegistrationScheduleSID,pr.RegistrationScheduleSID)
				,@PracticeRegisterName                     = isnull(@PracticeRegisterName,pr.PracticeRegisterName)
				,@PracticeRegisterLabel                    = isnull(@PracticeRegisterLabel,pr.PracticeRegisterLabel)
				,@IsActivePractice                         = isnull(@IsActivePractice,pr.IsActivePractice)
				,@IsPublicRegistryEnabled                  = isnull(@IsPublicRegistryEnabled,pr.IsPublicRegistryEnabled)
				,@IsRenewalEnabled                         = isnull(@IsRenewalEnabled,pr.IsRenewalEnabled)
				,@IsLearningPlanEnabled                    = isnull(@IsLearningPlanEnabled,pr.IsLearningPlanEnabled)
				,@IsNextCEFormAutoAdded                    = isnull(@IsNextCEFormAutoAdded,pr.IsNextCEFormAutoAdded)
				,@IsEligibleSupervisor                     = isnull(@IsEligibleSupervisor,pr.IsEligibleSupervisor)
				,@IsSupervisionRequired                    = isnull(@IsSupervisionRequired,pr.IsSupervisionRequired)
				,@IsEmploymentTerminated                   = isnull(@IsEmploymentTerminated,pr.IsEmploymentTerminated)
				,@IsGroupMembershipTerminated              = isnull(@IsGroupMembershipTerminated,pr.IsGroupMembershipTerminated)
				,@TermPermitDays                           = isnull(@TermPermitDays,pr.TermPermitDays)
				,@RegisterRank                             = isnull(@RegisterRank,pr.RegisterRank)
				,@LearningModelSID                         = isnull(@LearningModelSID,pr.LearningModelSID)
				,@ReasonGroupSID                           = isnull(@ReasonGroupSID,pr.ReasonGroupSID)
				,@IsDefault                                = isnull(@IsDefault,pr.IsDefault)
				,@IsDefaultInactivePractice                = isnull(@IsDefaultInactivePractice,pr.IsDefaultInactivePractice)
				,@Description                              = isnull(@Description,pr.Description)
				,@IsActive                                 = isnull(@IsActive,pr.IsActive)
				,@UserDefinedColumns                       = isnull(@UserDefinedColumns,pr.UserDefinedColumns)
				,@PracticeRegisterXID                      = isnull(@PracticeRegisterXID,pr.PracticeRegisterXID)
				,@LegacyKey                                = isnull(@LegacyKey,pr.LegacyKey)
				,@UpdateUser                               = isnull(@UpdateUser,pr.UpdateUser)
				,@IsReselected                             = isnull(@IsReselected,pr.IsReselected)
				,@IsNullApplied                            = isnull(@IsNullApplied,pr.IsNullApplied)
				,@zContext                                 = isnull(@zContext,pr.zContext)
				,@PracticeRegisterTypeSCD                  = isnull(@PracticeRegisterTypeSCD,pr.PracticeRegisterTypeSCD)
				,@PracticeRegisterTypeLabel                = isnull(@PracticeRegisterTypeLabel,pr.PracticeRegisterTypeLabel)
				,@PracticeRegisterTypeCategory             = isnull(@PracticeRegisterTypeCategory,pr.PracticeRegisterTypeCategory)
				,@PracticeRegisterTypeIsDefault            = isnull(@PracticeRegisterTypeIsDefault,pr.PracticeRegisterTypeIsDefault)
				,@PracticeRegisterTypeIsActive             = isnull(@PracticeRegisterTypeIsActive,pr.PracticeRegisterTypeIsActive)
				,@PracticeRegisterTypeRowGUID              = isnull(@PracticeRegisterTypeRowGUID,pr.PracticeRegisterTypeRowGUID)
				,@RegistrationScheduleLabel                = isnull(@RegistrationScheduleLabel,pr.RegistrationScheduleLabel)
				,@RegistrationScheduleIsDefault            = isnull(@RegistrationScheduleIsDefault,pr.RegistrationScheduleIsDefault)
				,@RegistrationScheduleIsActive             = isnull(@RegistrationScheduleIsActive,pr.RegistrationScheduleIsActive)
				,@RegistrationScheduleRowGUID              = isnull(@RegistrationScheduleRowGUID,pr.RegistrationScheduleRowGUID)
				,@LearningModelSCD                         = isnull(@LearningModelSCD,pr.LearningModelSCD)
				,@LearningModelLabel                       = isnull(@LearningModelLabel,pr.LearningModelLabel)
				,@LearningModelIsDefault                   = isnull(@LearningModelIsDefault,pr.LearningModelIsDefault)
				,@UnitTypeSID                              = isnull(@UnitTypeSID,pr.UnitTypeSID)
				,@CycleLengthYears                         = isnull(@CycleLengthYears,pr.CycleLengthYears)
				,@IsCycleStartedYear1                      = isnull(@IsCycleStartedYear1,pr.IsCycleStartedYear1)
				,@MaximumCarryOver                         = isnull(@MaximumCarryOver,pr.MaximumCarryOver)
				,@LearningModelRowGUID                     = isnull(@LearningModelRowGUID,pr.LearningModelRowGUID)
				,@ReasonGroupSCD                           = isnull(@ReasonGroupSCD,pr.ReasonGroupSCD)
				,@ReasonGroupLabel                         = isnull(@ReasonGroupLabel,pr.ReasonGroupLabel)
				,@IsLockedGroup                            = isnull(@IsLockedGroup,pr.IsLockedGroup)
				,@ReasonGroupRowGUID                       = isnull(@ReasonGroupRowGUID,pr.ReasonGroupRowGUID)
				,@IsDeleteEnabled                          = isnull(@IsDeleteEnabled,pr.IsDeleteEnabled)
				,@RegistrantAppFormVersionSID              = isnull(@RegistrantAppFormVersionSID,pr.RegistrantAppFormVersionSID)
				,@RegistrantAppVerificationFormVersionSID  = isnull(@RegistrantAppVerificationFormVersionSID,pr.RegistrantAppVerificationFormVersionSID)
				,@RegistrantRenewalFormVersionSID          = isnull(@RegistrantRenewalFormVersionSID,pr.RegistrantRenewalFormVersionSID)
				,@RegistrantRenewalReviewFormVersionSID    = isnull(@RegistrantRenewalReviewFormVersionSID,pr.RegistrantRenewalReviewFormVersionSID)
				,@CompetenceReviewFormVersionSID           = isnull(@CompetenceReviewFormVersionSID,pr.CompetenceReviewFormVersionSID)
				,@CompetenceReviewAssessmentFormVersionSID = isnull(@CompetenceReviewAssessmentFormVersionSID,pr.CompetenceReviewAssessmentFormVersionSID)
				,@CurrentRegistrationYear                  = isnull(@CurrentRegistrationYear,pr.CurrentRegistrationYear)
				,@CurrentRenewalYear                       = isnull(@CurrentRenewalYear,pr.CurrentRenewalYear)
				,@CurrentReinstatementYear                 = isnull(@CurrentReinstatementYear,pr.CurrentReinstatementYear)
				,@NextReinstatementYear                    = isnull(@NextReinstatementYear,pr.NextReinstatementYear)
				,@IsCurrentUserVerifier                    = isnull(@IsCurrentUserVerifier,pr.IsCurrentUserVerifier)
				,@IsLearningModelApplied                   = isnull(@IsLearningModelApplied,pr.IsLearningModelApplied)
			from
				dbo.vPracticeRegister pr
			where
				pr.PracticeRegisterSID = @PracticeRegisterSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @LearningModelSCD is not null and @LearningModelSID = (select x.LearningModelSID from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID)
		begin
		
			select
				@LearningModelSID = x.LearningModelSID
			from
				dbo.LearningModel x
			where
				x.LearningModelSCD = @LearningModelSCD
		
		end
		
		if @PracticeRegisterTypeSCD is not null and @PracticeRegisterTypeSID = (select x.PracticeRegisterTypeSID from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID)
		begin
		
			select
				@PracticeRegisterTypeSID = x.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType x
			where
				x.PracticeRegisterTypeSCD = @PracticeRegisterTypeSCD
		
		end
		
		if @ReasonGroupSCD is not null and @ReasonGroupSID = (select x.ReasonGroupSID from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID)
		begin
		
			select
				@ReasonGroupSID = x.ReasonGroupSID
			from
				dbo.ReasonGroup x
			where
				x.ReasonGroupSCD = @ReasonGroupSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.PracticeRegisterTypeSID from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID) <> @PracticeRegisterTypeSID
		begin
			if (select x.IsActive from dbo.PracticeRegisterType x where x.PracticeRegisterTypeSID = @PracticeRegisterTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'practice register type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.RegistrationScheduleSID from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID) <> @RegistrationScheduleSID
		begin
			if (select x.IsActive from dbo.RegistrationSchedule x where x.RegistrationScheduleSID = @RegistrationScheduleSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'registration schedule'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		-- unset previous default if record is being marked as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.PracticeRegisterSID from dbo.PracticeRegister x where x.IsDefault = @ON and x.PracticeRegisterSID <> @PracticeRegisterSID
			
			if @recordSID is not null
			begin
			
				update
					dbo.PracticeRegister
				set
					 IsDefault  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PracticeRegisterSID = @recordSID																-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Oct 2017
		-- If this register does not allow renewal, then ensure no fees for the register
		-- are enabled for renewal. This must be done before update to prevent BR errors
		-- arising from the check constraint.

		if @IsRenewalEnabled = @OFF
		begin

			update
				dbo.PracticeRegisterCatalogItem
			set
				IsAppliedOnRenewal = @OFF
			 ,UpdateUser = @UpdateUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				PracticeRegisterSID = @PracticeRegisterSID and IsAppliedOnRenewal = @ON;

		end;
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
				r.RoutineName = 'pPracticeRegister'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegister
				 @Mode                                     = 'update.pre'
				,@PracticeRegisterSID                      = @PracticeRegisterSID
				,@PracticeRegisterTypeSID                  = @PracticeRegisterTypeSID output
				,@RegistrationScheduleSID                  = @RegistrationScheduleSID output
				,@PracticeRegisterName                     = @PracticeRegisterName output
				,@PracticeRegisterLabel                    = @PracticeRegisterLabel output
				,@IsActivePractice                         = @IsActivePractice output
				,@IsPublicRegistryEnabled                  = @IsPublicRegistryEnabled output
				,@IsRenewalEnabled                         = @IsRenewalEnabled output
				,@IsLearningPlanEnabled                    = @IsLearningPlanEnabled output
				,@IsNextCEFormAutoAdded                    = @IsNextCEFormAutoAdded output
				,@IsEligibleSupervisor                     = @IsEligibleSupervisor output
				,@IsSupervisionRequired                    = @IsSupervisionRequired output
				,@IsEmploymentTerminated                   = @IsEmploymentTerminated output
				,@IsGroupMembershipTerminated              = @IsGroupMembershipTerminated output
				,@TermPermitDays                           = @TermPermitDays output
				,@RegisterRank                             = @RegisterRank output
				,@LearningModelSID                         = @LearningModelSID output
				,@ReasonGroupSID                           = @ReasonGroupSID output
				,@IsDefault                                = @IsDefault output
				,@IsDefaultInactivePractice                = @IsDefaultInactivePractice output
				,@Description                              = @Description output
				,@IsActive                                 = @IsActive output
				,@UserDefinedColumns                       = @UserDefinedColumns output
				,@PracticeRegisterXID                      = @PracticeRegisterXID output
				,@LegacyKey                                = @LegacyKey output
				,@UpdateUser                               = @UpdateUser
				,@RowStamp                                 = @RowStamp
				,@IsReselected                             = @IsReselected
				,@IsNullApplied                            = @IsNullApplied
				,@zContext                                 = @zContext
				,@PracticeRegisterTypeSCD                  = @PracticeRegisterTypeSCD
				,@PracticeRegisterTypeLabel                = @PracticeRegisterTypeLabel
				,@PracticeRegisterTypeCategory             = @PracticeRegisterTypeCategory
				,@PracticeRegisterTypeIsDefault            = @PracticeRegisterTypeIsDefault
				,@PracticeRegisterTypeIsActive             = @PracticeRegisterTypeIsActive
				,@PracticeRegisterTypeRowGUID              = @PracticeRegisterTypeRowGUID
				,@RegistrationScheduleLabel                = @RegistrationScheduleLabel
				,@RegistrationScheduleIsDefault            = @RegistrationScheduleIsDefault
				,@RegistrationScheduleIsActive             = @RegistrationScheduleIsActive
				,@RegistrationScheduleRowGUID              = @RegistrationScheduleRowGUID
				,@LearningModelSCD                         = @LearningModelSCD
				,@LearningModelLabel                       = @LearningModelLabel
				,@LearningModelIsDefault                   = @LearningModelIsDefault
				,@UnitTypeSID                              = @UnitTypeSID
				,@CycleLengthYears                         = @CycleLengthYears
				,@IsCycleStartedYear1                      = @IsCycleStartedYear1
				,@MaximumCarryOver                         = @MaximumCarryOver
				,@LearningModelRowGUID                     = @LearningModelRowGUID
				,@ReasonGroupSCD                           = @ReasonGroupSCD
				,@ReasonGroupLabel                         = @ReasonGroupLabel
				,@IsLockedGroup                            = @IsLockedGroup
				,@ReasonGroupRowGUID                       = @ReasonGroupRowGUID
				,@IsDeleteEnabled                          = @IsDeleteEnabled
				,@RegistrantAppFormVersionSID              = @RegistrantAppFormVersionSID
				,@RegistrantAppVerificationFormVersionSID  = @RegistrantAppVerificationFormVersionSID
				,@RegistrantRenewalFormVersionSID          = @RegistrantRenewalFormVersionSID
				,@RegistrantRenewalReviewFormVersionSID    = @RegistrantRenewalReviewFormVersionSID
				,@CompetenceReviewFormVersionSID           = @CompetenceReviewFormVersionSID
				,@CompetenceReviewAssessmentFormVersionSID = @CompetenceReviewAssessmentFormVersionSID
				,@CurrentRegistrationYear                  = @CurrentRegistrationYear
				,@CurrentRenewalYear                       = @CurrentRenewalYear
				,@CurrentReinstatementYear                 = @CurrentReinstatementYear
				,@NextReinstatementYear                    = @NextReinstatementYear
				,@IsCurrentUserVerifier                    = @IsCurrentUserVerifier
				,@IsLearningModelApplied                   = @IsLearningModelApplied
		
		end

		-- update the record

		update
			dbo.PracticeRegister
		set
			 PracticeRegisterTypeSID = @PracticeRegisterTypeSID
			,RegistrationScheduleSID = @RegistrationScheduleSID
			,PracticeRegisterName = @PracticeRegisterName
			,PracticeRegisterLabel = @PracticeRegisterLabel
			,IsActivePractice = @IsActivePractice
			,IsPublicRegistryEnabled = @IsPublicRegistryEnabled
			,IsRenewalEnabled = @IsRenewalEnabled
			,IsLearningPlanEnabled = @IsLearningPlanEnabled
			,IsNextCEFormAutoAdded = @IsNextCEFormAutoAdded
			,IsEligibleSupervisor = @IsEligibleSupervisor
			,IsSupervisionRequired = @IsSupervisionRequired
			,IsEmploymentTerminated = @IsEmploymentTerminated
			,IsGroupMembershipTerminated = @IsGroupMembershipTerminated
			,TermPermitDays = @TermPermitDays
			,RegisterRank = @RegisterRank
			,LearningModelSID = @LearningModelSID
			,ReasonGroupSID = @ReasonGroupSID
			,IsDefault = @IsDefault
			,IsDefaultInactivePractice = @IsDefaultInactivePractice
			,Description = @Description
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,PracticeRegisterXID = @PracticeRegisterXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PracticeRegisterSID = @PracticeRegisterSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PracticeRegister where PracticeRegisterSID = @practiceRegisterSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PracticeRegister'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PracticeRegister'
					,@Arg2        = @practiceRegisterSID
				
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
				,@Arg2        = 'dbo.PracticeRegister'
				,@Arg3        = @rowsAffected
				,@Arg4        = @practiceRegisterSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
		
		-- ensure a default record is identified on the table
		
		if not exists
		(
			select 1 from	dbo.PracticeRegister x where x.IsDefault = @ON
		)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'MissingDefault'
				,@MessageText = @errorText output
				,@DefaultText = N'A default %1 record is required by the application. (Setting another record as the new default automatically un-sets the previous one.)'
				,@Arg1        = 'Practice Register'
			
			raiserror(@errorText, 16, 1)
		end
	
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
				r.RoutineName = 'pPracticeRegister'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegister
				 @Mode                                     = 'update.post'
				,@PracticeRegisterSID                      = @PracticeRegisterSID
				,@PracticeRegisterTypeSID                  = @PracticeRegisterTypeSID
				,@RegistrationScheduleSID                  = @RegistrationScheduleSID
				,@PracticeRegisterName                     = @PracticeRegisterName
				,@PracticeRegisterLabel                    = @PracticeRegisterLabel
				,@IsActivePractice                         = @IsActivePractice
				,@IsPublicRegistryEnabled                  = @IsPublicRegistryEnabled
				,@IsRenewalEnabled                         = @IsRenewalEnabled
				,@IsLearningPlanEnabled                    = @IsLearningPlanEnabled
				,@IsNextCEFormAutoAdded                    = @IsNextCEFormAutoAdded
				,@IsEligibleSupervisor                     = @IsEligibleSupervisor
				,@IsSupervisionRequired                    = @IsSupervisionRequired
				,@IsEmploymentTerminated                   = @IsEmploymentTerminated
				,@IsGroupMembershipTerminated              = @IsGroupMembershipTerminated
				,@TermPermitDays                           = @TermPermitDays
				,@RegisterRank                             = @RegisterRank
				,@LearningModelSID                         = @LearningModelSID
				,@ReasonGroupSID                           = @ReasonGroupSID
				,@IsDefault                                = @IsDefault
				,@IsDefaultInactivePractice                = @IsDefaultInactivePractice
				,@Description                              = @Description
				,@IsActive                                 = @IsActive
				,@UserDefinedColumns                       = @UserDefinedColumns
				,@PracticeRegisterXID                      = @PracticeRegisterXID
				,@LegacyKey                                = @LegacyKey
				,@UpdateUser                               = @UpdateUser
				,@RowStamp                                 = @RowStamp
				,@IsReselected                             = @IsReselected
				,@IsNullApplied                            = @IsNullApplied
				,@zContext                                 = @zContext
				,@PracticeRegisterTypeSCD                  = @PracticeRegisterTypeSCD
				,@PracticeRegisterTypeLabel                = @PracticeRegisterTypeLabel
				,@PracticeRegisterTypeCategory             = @PracticeRegisterTypeCategory
				,@PracticeRegisterTypeIsDefault            = @PracticeRegisterTypeIsDefault
				,@PracticeRegisterTypeIsActive             = @PracticeRegisterTypeIsActive
				,@PracticeRegisterTypeRowGUID              = @PracticeRegisterTypeRowGUID
				,@RegistrationScheduleLabel                = @RegistrationScheduleLabel
				,@RegistrationScheduleIsDefault            = @RegistrationScheduleIsDefault
				,@RegistrationScheduleIsActive             = @RegistrationScheduleIsActive
				,@RegistrationScheduleRowGUID              = @RegistrationScheduleRowGUID
				,@LearningModelSCD                         = @LearningModelSCD
				,@LearningModelLabel                       = @LearningModelLabel
				,@LearningModelIsDefault                   = @LearningModelIsDefault
				,@UnitTypeSID                              = @UnitTypeSID
				,@CycleLengthYears                         = @CycleLengthYears
				,@IsCycleStartedYear1                      = @IsCycleStartedYear1
				,@MaximumCarryOver                         = @MaximumCarryOver
				,@LearningModelRowGUID                     = @LearningModelRowGUID
				,@ReasonGroupSCD                           = @ReasonGroupSCD
				,@ReasonGroupLabel                         = @ReasonGroupLabel
				,@IsLockedGroup                            = @IsLockedGroup
				,@ReasonGroupRowGUID                       = @ReasonGroupRowGUID
				,@IsDeleteEnabled                          = @IsDeleteEnabled
				,@RegistrantAppFormVersionSID              = @RegistrantAppFormVersionSID
				,@RegistrantAppVerificationFormVersionSID  = @RegistrantAppVerificationFormVersionSID
				,@RegistrantRenewalFormVersionSID          = @RegistrantRenewalFormVersionSID
				,@RegistrantRenewalReviewFormVersionSID    = @RegistrantRenewalReviewFormVersionSID
				,@CompetenceReviewFormVersionSID           = @CompetenceReviewFormVersionSID
				,@CompetenceReviewAssessmentFormVersionSID = @CompetenceReviewAssessmentFormVersionSID
				,@CurrentRegistrationYear                  = @CurrentRegistrationYear
				,@CurrentRenewalYear                       = @CurrentRenewalYear
				,@CurrentReinstatementYear                 = @CurrentReinstatementYear
				,@NextReinstatementYear                    = @NextReinstatementYear
				,@IsCurrentUserVerifier                    = @IsCurrentUserVerifier
				,@IsLearningModelApplied                   = @IsLearningModelApplied
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PracticeRegisterSID
			from
				dbo.vPracticeRegister ent
			where
				ent.PracticeRegisterSID = @PracticeRegisterSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PracticeRegisterSID
				,ent.PracticeRegisterTypeSID
				,ent.RegistrationScheduleSID
				,ent.PracticeRegisterName
				,ent.PracticeRegisterLabel
				,ent.IsActivePractice
				,ent.IsPublicRegistryEnabled
				,ent.IsRenewalEnabled
				,ent.IsLearningPlanEnabled
				,ent.IsNextCEFormAutoAdded
				,ent.IsEligibleSupervisor
				,ent.IsSupervisionRequired
				,ent.IsEmploymentTerminated
				,ent.IsGroupMembershipTerminated
				,ent.TermPermitDays
				,ent.RegisterRank
				,ent.LearningModelSID
				,ent.ReasonGroupSID
				,ent.IsDefault
				,ent.IsDefaultInactivePractice
				,ent.Description
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.PracticeRegisterXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PracticeRegisterTypeSCD
				,ent.PracticeRegisterTypeLabel
				,ent.PracticeRegisterTypeCategory
				,ent.PracticeRegisterTypeIsDefault
				,ent.PracticeRegisterTypeIsActive
				,ent.PracticeRegisterTypeRowGUID
				,ent.RegistrationScheduleLabel
				,ent.RegistrationScheduleIsDefault
				,ent.RegistrationScheduleIsActive
				,ent.RegistrationScheduleRowGUID
				,ent.LearningModelSCD
				,ent.LearningModelLabel
				,ent.LearningModelIsDefault
				,ent.UnitTypeSID
				,ent.CycleLengthYears
				,ent.IsCycleStartedYear1
				,ent.MaximumCarryOver
				,ent.LearningModelRowGUID
				,ent.ReasonGroupSCD
				,ent.ReasonGroupLabel
				,ent.IsLockedGroup
				,ent.ReasonGroupRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantAppFormVersionSID
				,ent.RegistrantAppVerificationFormVersionSID
				,ent.RegistrantRenewalFormVersionSID
				,ent.RegistrantRenewalReviewFormVersionSID
				,ent.CompetenceReviewFormVersionSID
				,ent.CompetenceReviewAssessmentFormVersionSID
				,ent.CurrentRegistrationYear
				,ent.CurrentRenewalYear
				,ent.CurrentReinstatementYear
				,ent.NextReinstatementYear
				,ent.IsCurrentUserVerifier
				,ent.IsLearningModelApplied
			from
				dbo.vPracticeRegister ent
			where
				ent.PracticeRegisterSID = @PracticeRegisterSID

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
