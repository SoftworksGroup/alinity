SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#Insert]
	 @RegistrantLearningPlanSID         int               = null output			-- identity value assigned to the new record
	,@RegistrantSID                     int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                  smallint          = null						-- required! if not passed value must be set in custom logic prior to insert
	,@LearningModelSID                  int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@FormVersionSID                    int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@LastValidateTime                  datetimeoffset(7) = null						
	,@FormResponseDraft                 xml               = null						-- default: CONVERT(xml,N'<FormResponses />')
	,@AdminComments                     xml               = null						-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp                      date              = null						
	,@ConfirmationDraft                 nvarchar(max)     = null						
	,@ReasonSID                         int               = null						
	,@IsAutoApprovalEnabled             bit               = null						-- default: CONVERT(bit,(0))
	,@ReviewReasonList                  xml               = null						
	,@ParentRowGUID                     uniqueidentifier  = null						
	,@UserDefinedColumns                xml               = null						
	,@RegistrantLearningPlanXID         varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@LearningModelSCD                  varchar(15)       = null						-- not a base table column (default ignored)
	,@LearningModelLabel                nvarchar(35)      = null						-- not a base table column (default ignored)
	,@LearningModelIsDefault            bit               = null						-- not a base table column (default ignored)
	,@UnitTypeSID                       int               = null						-- not a base table column (default ignored)
	,@CycleLengthYears                  smallint          = null						-- not a base table column (default ignored)
	,@IsCycleStartedYear1               bit               = null						-- not a base table column (default ignored)
	,@MaximumCarryOver                  decimal(5,2)      = null						-- not a base table column (default ignored)
	,@LearningModelRowGUID              uniqueidentifier  = null						-- not a base table column (default ignored)
	,@PersonSID                         int               = null						-- not a base table column (default ignored)
	,@RegistrantNo                      varchar(50)       = null						-- not a base table column (default ignored)
	,@YearOfInitialEmployment           smallint          = null						-- not a base table column (default ignored)
	,@IsOnPublicRegistry                bit               = null						-- not a base table column (default ignored)
	,@CityNameOfBirth                   nvarchar(30)      = null						-- not a base table column (default ignored)
	,@CountrySID                        int               = null						-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence       smallint          = null						-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours    smallint          = null						-- not a base table column (default ignored)
	,@LateFeeExclusionYear              smallint          = null						-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked      bit               = null						-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime        datetime          = null						-- not a base table column (default ignored)
	,@ArchivedTime                      datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@RegistrantRowGUID                 uniqueidentifier  = null						-- not a base table column (default ignored)
	,@FormSID                           int               = null						-- not a base table column (default ignored)
	,@VersionNo                         smallint          = null						-- not a base table column (default ignored)
	,@RevisionNo                        smallint          = null						-- not a base table column (default ignored)
	,@IsSaveDisplayed                   bit               = null						-- not a base table column (default ignored)
	,@ApprovedTime                      datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@FormVersionRowGUID                uniqueidentifier  = null						-- not a base table column (default ignored)
	,@ReasonGroupSID                    int               = null						-- not a base table column (default ignored)
	,@ReasonName                        nvarchar(50)      = null						-- not a base table column (default ignored)
	,@ReasonCode                        varchar(25)       = null						-- not a base table column (default ignored)
	,@ReasonSequence                    smallint          = null						-- not a base table column (default ignored)
	,@ToolTip                           nvarchar(500)     = null						-- not a base table column (default ignored)
	,@ReasonIsActive                    bit               = null						-- not a base table column (default ignored)
	,@ReasonRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsViewEnabled                     bit               = null						-- not a base table column (default ignored)
	,@IsEditEnabled                     bit               = null						-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed                bit               = null						-- not a base table column (default ignored)
	,@IsApproveEnabled                  bit               = null						-- not a base table column (default ignored)
	,@IsRejectEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsUnlockEnabled                   bit               = null						-- not a base table column (default ignored)
	,@IsWithdrawalEnabled               bit               = null						-- not a base table column (default ignored)
	,@IsInProgress                      bit               = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanStatusSID   int               = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanStatusSCD   varchar(25)       = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanStatusLabel nvarchar(35)      = null						-- not a base table column (default ignored)
	,@LastStatusChangeUser              nvarchar(75)      = null						-- not a base table column (default ignored)
	,@LastStatusChangeTime              datetimeoffset(7) = null						-- not a base table column (default ignored)
	,@FormOwnerSCD                      varchar(25)       = null						-- not a base table column (default ignored)
	,@FormOwnerLabel                    nvarchar(35)      = null						-- not a base table column (default ignored)
	,@FormOwnerSID                      int               = null						-- not a base table column (default ignored)
	,@IsPDFDisplayed                    bit               = null						-- not a base table column (default ignored)
	,@PersonDocSID                      int               = null						-- not a base table column (default ignored)
	,@RegistrantLearningPlanLabel       nvarchar(80)      = null						-- not a base table column (default ignored)
	,@RegistrationYearLabel             nvarchar(9)       = null						-- not a base table column (default ignored)
	,@CycleEndRegistrationYear          smallint          = null						-- not a base table column (default ignored)
	,@CycleRegistrationYearLabel        nvarchar(21)      = null						-- not a base table column (default ignored)
	,@NewFormStatusSCD                  varchar(25)       = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantLearningPlan#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantLearningPlan table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantLearningPlan table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantLearningPlan entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantLearningPlan procedure. The extended procedure is only called
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

	set @RegistrantLearningPlanSID = null																		-- initialize output parameter

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
		set @RegistrantLearningPlanXID = ltrim(rtrim(@RegistrantLearningPlanXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @FormResponseDraft = isnull(@FormResponseDraft,CONVERT(xml,N'<FormResponses />'))
		set @AdminComments = isnull(@AdminComments,CONVERT(xml,'<Comments />'))
		set @IsAutoApprovalEnabled = isnull(@IsAutoApprovalEnabled,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected              = isnull(@IsReselected             ,(0))
		
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
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @LearningModelSID  is null select @LearningModelSID  = x.LearningModelSID from dbo.LearningModel x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Jan 2018
		-- If a form version is not provided, default it to the latest published form of the
		-- correct type. The configurator may have established a specific form to apply for
		-- the given registration year (if passed) through the Form-Context column in which
		-- case the latest published version matching that context is set.

		if isnull(@FormVersionSID, 0) = 0 and isnull(@RegistrationYear, 0) <> 0
		begin

			select
				@FormVersionSID = max(fv.FormVersionSID)
			from
				sf.Form				 f
			join
				sf.FormType		 ft on f.FormTypeSID = ft.FormTypeSID and ft.FormTypeSCD = 'LEARNINGPLAN.MAIN'
			join
				sf.FormVersion fv on f.FormSID		 = fv.FormSID and fv.VersionNo > 0												-- filter out non-published versions
			where
				f.FormContext = ltrim(@RegistrationYear);																										-- look for configured context where year is passed

		end;

		if isnull(@FormVersionSID, 0) = 0 -- if no form version provided then assign latest version
		begin

			select
				@FormVersionSID = max(fv.FormVersionSID)
			from
				sf.Form				 f
			join
				sf.FormType		 ft on f.FormTypeSID = ft.FormTypeSID and ft.FormTypeSCD = 'LEARNINGPLAN.MAIN'
			join
				sf.FormVersion fv on f.FormSID		 = fv.FormSID and fv.VersionNo > 0
			and
				f.FormContext is null;

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
				,@Arg1        = 'Learning Plan Form (published)'

			raiserror(@errorText, 17, 1)
			
		end

		-- Tim Edlund | Jun 2018
		-- If a registration year for the plan is not provided,
		-- default it based on their previous plan (if any)
		-- plus the learning model cycle length.

		if @RegistrationYear = -1 set @RegistrationYear = null -- front end passes as -1 since column is not nullable
		if @RegistrationYear is null -- no year provided
			 and
			 (
				 @RegistrantSID is not null or @PersonSID is not null -- person is identified
			 )
		begin

			if @RegistrantSID is null -- lookup registrant based on person key
			begin

				select
					@RegistrantSID = r.RegistrantSID
				from
					dbo.Registrant r
				where
					r.PersonSID = @PersonSID;

			end;

			declare
				@isNextPlanRequired bit

			select
				@RegistrationYear		= rnlp.NextPlanRegistrationYear
			 ,@isNextPlanRequired = rnlp.IsNextPlanRequired
			 ,@CycleLengthYears		= rnlp.CycleLengthYears
			from
				dbo.fRegistrant#NextLearningPlan(@RegistrantSID) rnlp;

			if @isNextPlanRequired = @OFF -- don't allow plan to be created for a future cycle
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'TooEarlyForLearningPlan'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A new learning plan cannot be created because the %1 continuing education cycle initiated for the %2 registration year is still in effect or the member is on an in-active practice register.'
				 ,@Arg1 = @CycleLengthYears
				 ,@Arg2 = @RegistrationYear;

				raiserror(@errorText, 16, 1);

			end;

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
				r.RoutineName = 'pRegistrantLearningPlan'
		)
		begin
		
			exec @errorNo = ext.pRegistrantLearningPlan
				 @Mode                              = 'insert.pre'
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
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
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

		-- insert the record

		insert
			dbo.RegistrantLearningPlan
		(
			 RegistrantSID
			,RegistrationYear
			,LearningModelSID
			,FormVersionSID
			,LastValidateTime
			,FormResponseDraft
			,AdminComments
			,NextFollowUp
			,ConfirmationDraft
			,ReasonSID
			,IsAutoApprovalEnabled
			,ReviewReasonList
			,ParentRowGUID
			,UserDefinedColumns
			,RegistrantLearningPlanXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@RegistrationYear
			,@LearningModelSID
			,@FormVersionSID
			,@LastValidateTime
			,@FormResponseDraft
			,@AdminComments
			,@NextFollowUp
			,@ConfirmationDraft
			,@ReasonSID
			,@IsAutoApprovalEnabled
			,@ReviewReasonList
			,@ParentRowGUID
			,@UserDefinedColumns
			,@RegistrantLearningPlanXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected              = @@rowcount
			,@RegistrantLearningPlanSID = scope_identity()											-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantLearningPlan'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantLearningPlanSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Cory Ng | Dec 2017
		-- Create the initial status row for the form applying the
		-- default status (expected to be "NEW" or similar)

		insert
			dbo.RegistrantLearningPlanStatus
		(
			 RegistrantLearningPlanSID
			,FormStatusSID
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantLearningPlanSID
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
				r.RoutineName = 'pRegistrantLearningPlan'
		)
		begin
		
			exec @errorNo = ext.pRegistrantLearningPlan
				 @Mode                              = 'insert.post'
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
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
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
