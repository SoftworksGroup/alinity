SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegister#Insert]
	 @PracticeRegisterSID                      int               = null output												-- identity value assigned to the new record
	,@PracticeRegisterTypeSID                  int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationScheduleSID                  int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterName                     nvarchar(65)      = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterLabel                    nvarchar(35)      = null			-- required! if not passed value must be set in custom logic prior to insert
	,@IsActivePractice                         bit               = null			-- default: (1)
	,@IsPublicRegistryEnabled                  bit               = null			-- default: (1)
	,@IsRenewalEnabled                         bit               = null			-- default: (1)
	,@IsLearningPlanEnabled                    bit               = null			-- default: (0)
	,@IsNextCEFormAutoAdded                    bit               = null			-- default: CONVERT(bit,(1))
	,@IsEligibleSupervisor                     bit               = null			-- default: CONVERT(bit,(0))
	,@IsSupervisionRequired                    bit               = null			-- default: CONVERT(bit,(0))
	,@IsEmploymentTerminated                   bit               = null			-- default: CONVERT(bit,(0))
	,@IsGroupMembershipTerminated              bit               = null			-- default: CONVERT(bit,(0))
	,@TermPermitDays                           int               = null			-- default: (0)
	,@RegisterRank                             smallint          = null			-- default: (500)
	,@LearningModelSID                         int               = null			
	,@ReasonGroupSID                           int               = null			
	,@IsDefault                                bit               = null			-- default: (0)
	,@IsDefaultInactivePractice                bit               = null			-- default: CONVERT(bit,(0))
	,@Description                              varbinary(max)    = null			
	,@IsActive                                 bit               = null			-- default: (1)
	,@UserDefinedColumns                       xml               = null			
	,@PracticeRegisterXID                      varchar(150)      = null			
	,@LegacyKey                                nvarchar(50)      = null			
	,@CreateUser                               nvarchar(75)      = null			-- default: suser_sname()
	,@IsReselected                             tinyint           = null			-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                 xml               = null			-- other values defining context for the insert (if any)
	,@PracticeRegisterTypeSCD                  varchar(15)       = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeLabel                nvarchar(35)      = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeCategory             nvarchar(65)      = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeIsDefault            bit               = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeIsActive             bit               = null			-- not a base table column (default ignored)
	,@PracticeRegisterTypeRowGUID              uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RegistrationScheduleLabel                nvarchar(35)      = null			-- not a base table column (default ignored)
	,@RegistrationScheduleIsDefault            bit               = null			-- not a base table column (default ignored)
	,@RegistrationScheduleIsActive             bit               = null			-- not a base table column (default ignored)
	,@RegistrationScheduleRowGUID              uniqueidentifier  = null			-- not a base table column (default ignored)
	,@LearningModelSCD                         varchar(15)       = null			-- not a base table column (default ignored)
	,@LearningModelLabel                       nvarchar(35)      = null			-- not a base table column (default ignored)
	,@LearningModelIsDefault                   bit               = null			-- not a base table column (default ignored)
	,@UnitTypeSID                              int               = null			-- not a base table column (default ignored)
	,@CycleLengthYears                         smallint          = null			-- not a base table column (default ignored)
	,@IsCycleStartedYear1                      bit               = null			-- not a base table column (default ignored)
	,@MaximumCarryOver                         decimal(5,2)      = null			-- not a base table column (default ignored)
	,@LearningModelRowGUID                     uniqueidentifier  = null			-- not a base table column (default ignored)
	,@ReasonGroupSCD                           varchar(20)       = null			-- not a base table column (default ignored)
	,@ReasonGroupLabel                         nvarchar(35)      = null			-- not a base table column (default ignored)
	,@IsLockedGroup                            bit               = null			-- not a base table column (default ignored)
	,@ReasonGroupRowGUID                       uniqueidentifier  = null			-- not a base table column (default ignored)
	,@IsDeleteEnabled                          bit               = null			-- not a base table column (default ignored)
	,@RegistrantAppFormVersionSID              int               = null			-- not a base table column (default ignored)
	,@RegistrantAppVerificationFormVersionSID  int               = null			-- not a base table column (default ignored)
	,@RegistrantRenewalFormVersionSID          int               = null			-- not a base table column (default ignored)
	,@RegistrantRenewalReviewFormVersionSID    int               = null			-- not a base table column (default ignored)
	,@CompetenceReviewFormVersionSID           int               = null			-- not a base table column (default ignored)
	,@CompetenceReviewAssessmentFormVersionSID int               = null			-- not a base table column (default ignored)
	,@CurrentRegistrationYear                  smallint          = null			-- not a base table column (default ignored)
	,@CurrentRenewalYear                       smallint          = null			-- not a base table column (default ignored)
	,@CurrentReinstatementYear                 smallint          = null			-- not a base table column (default ignored)
	,@NextReinstatementYear                    smallint          = null			-- not a base table column (default ignored)
	,@IsCurrentUserVerifier                    bit               = null			-- not a base table column (default ignored)
	,@IsLearningModelApplied                   bit               = null			-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegister#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PracticeRegister table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PracticeRegister table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPracticeRegister entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPracticeRegister procedure. The extended procedure is only called
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

	set @PracticeRegisterSID = null																					-- initialize output parameter

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

		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRegisterXID = ltrim(rtrim(@PracticeRegisterXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PracticeRegisterTypeSCD) = 0 set @PracticeRegisterTypeSCD = null
		if len(@PracticeRegisterTypeLabel) = 0 set @PracticeRegisterTypeLabel = null
		if len(@PracticeRegisterTypeCategory) = 0 set @PracticeRegisterTypeCategory = null
		if len(@RegistrationScheduleLabel) = 0 set @RegistrationScheduleLabel = null
		if len(@LearningModelSCD) = 0 set @LearningModelSCD = null
		if len(@LearningModelLabel) = 0 set @LearningModelLabel = null
		if len(@ReasonGroupSCD) = 0 set @ReasonGroupSCD = null
		if len(@ReasonGroupLabel) = 0 set @ReasonGroupLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsActivePractice = isnull(@IsActivePractice,(1))
		set @IsPublicRegistryEnabled = isnull(@IsPublicRegistryEnabled,(1))
		set @IsRenewalEnabled = isnull(@IsRenewalEnabled,(1))
		set @IsLearningPlanEnabled = isnull(@IsLearningPlanEnabled,(0))
		set @IsNextCEFormAutoAdded = isnull(@IsNextCEFormAutoAdded,CONVERT(bit,(1)))
		set @IsEligibleSupervisor = isnull(@IsEligibleSupervisor,CONVERT(bit,(0)))
		set @IsSupervisionRequired = isnull(@IsSupervisionRequired,CONVERT(bit,(0)))
		set @IsEmploymentTerminated = isnull(@IsEmploymentTerminated,CONVERT(bit,(0)))
		set @IsGroupMembershipTerminated = isnull(@IsGroupMembershipTerminated,CONVERT(bit,(0)))
		set @TermPermitDays = isnull(@TermPermitDays,(0))
		set @RegisterRank = isnull(@RegisterRank,(500))
		set @IsDefault = isnull(@IsDefault,(0))
		set @IsDefaultInactivePractice = isnull(@IsDefaultInactivePractice,CONVERT(bit,(0)))
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                = isnull(@IsReselected               ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @LearningModelSCD is not null
		begin
		
			select
				@LearningModelSID = x.LearningModelSID
			from
				dbo.LearningModel x
			where
				x.LearningModelSCD = @LearningModelSCD
		
		end
		
		if @PracticeRegisterTypeSCD is not null
		begin
		
			select
				@PracticeRegisterTypeSID = x.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType x
			where
				x.PracticeRegisterTypeSCD = @PracticeRegisterTypeSCD
		
		end
		
		if @ReasonGroupSCD is not null
		begin
		
			select
				@ReasonGroupSID = x.ReasonGroupSID
			from
				dbo.ReasonGroup x
			where
				x.ReasonGroupSCD = @ReasonGroupSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @PracticeRegisterTypeSID  is null select @PracticeRegisterTypeSID  = x.PracticeRegisterTypeSID from dbo.PracticeRegisterType x where x.IsDefault = @ON
		if @RegistrationScheduleSID  is null select @RegistrationScheduleSID  = x.RegistrationScheduleSID from dbo.RegistrationSchedule x where x.IsDefault = @ON
		
		-- unset previous default if record is being inserted as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.PracticeRegisterSID from dbo.PracticeRegister x where x.IsDefault = @ON
			
			if @recordSID is not null
			begin
			
				update
					dbo.PracticeRegister
				set
					 IsDefault  = @OFF
					,UpdateUser = @CreateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PracticeRegisterSID = @recordSID																-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Apr 2018
		-- Unset previous default in active practice register when a new
		-- one is set
		
		if @IsDefaultInactivePractice = @ON
		begin
		
			select @recordSID = x.PracticeRegisterSID from dbo.PracticeRegister x where x.IsDefaultInactivePractice = @ON
			
			if @recordSID is not null
			begin
			
				update
					dbo.PracticeRegister
				set
					 IsDefaultInactivePractice  = @OFF
					,UpdateUser = @CreateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PracticeRegisterSID = @recordSID																-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- Tim Edlund | Jul 2018
		-- On new records where active-practice is indicated
		-- force the learning plan to be enabled. Learning
		-- plans must be enabled for active-practice (see
		-- also check function)

		if @IsActivePractice = @ON
		begin
			set @IsLearningPlanEnabled = @ON
		end

		-- Tim Edlund | Sep 2018
		-- If continuing education reporting is not enabled for this
		-- register force automatic adding of the next year CE form OFF

		if @IsLearningPlanEnabled = @OFF
		begin
			set @IsNextCEFormAutoAdded = @OFF
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
				r.RoutineName = 'pPracticeRegister'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegister
				 @Mode                                     = 'insert.pre'
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
				,@CreateUser                               = @CreateUser
				,@IsReselected                             = @IsReselected
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

		-- insert the record

		insert
			dbo.PracticeRegister
		(
			 PracticeRegisterTypeSID
			,RegistrationScheduleSID
			,PracticeRegisterName
			,PracticeRegisterLabel
			,IsActivePractice
			,IsPublicRegistryEnabled
			,IsRenewalEnabled
			,IsLearningPlanEnabled
			,IsNextCEFormAutoAdded
			,IsEligibleSupervisor
			,IsSupervisionRequired
			,IsEmploymentTerminated
			,IsGroupMembershipTerminated
			,TermPermitDays
			,RegisterRank
			,LearningModelSID
			,ReasonGroupSID
			,IsDefault
			,IsDefaultInactivePractice
			,Description
			,IsActive
			,UserDefinedColumns
			,PracticeRegisterXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PracticeRegisterTypeSID
			,@RegistrationScheduleSID
			,@PracticeRegisterName
			,@PracticeRegisterLabel
			,@IsActivePractice
			,@IsPublicRegistryEnabled
			,@IsRenewalEnabled
			,@IsLearningPlanEnabled
			,@IsNextCEFormAutoAdded
			,@IsEligibleSupervisor
			,@IsSupervisionRequired
			,@IsEmploymentTerminated
			,@IsGroupMembershipTerminated
			,@TermPermitDays
			,@RegisterRank
			,@LearningModelSID
			,@ReasonGroupSID
			,@IsDefault
			,@IsDefaultInactivePractice
			,@Description
			,@IsActive
			,@UserDefinedColumns
			,@PracticeRegisterXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected        = @@rowcount
			,@PracticeRegisterSID = scope_identity()														-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PracticeRegister'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PracticeRegisterSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Sep 2017
		-- When adding a practice register, automatically create 1
		-- default section (a section is required for any registration
		-- assignments). Updated June 2018 to include parent label text.

		insert
			dbo.PracticeRegisterSection
		(
			PracticeRegisterSID
		 ,PracticeRegisterSectionLabel
		 ,IsDefault
		)
		values
		(
			@PracticeRegisterSID, @PracticeRegisterLabel + ' Default', @ON
		);
			
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
				r.RoutineName = 'pPracticeRegister'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegister
				 @Mode                                     = 'insert.post'
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
				,@CreateUser                               = @CreateUser
				,@IsReselected                             = @IsReselected
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
