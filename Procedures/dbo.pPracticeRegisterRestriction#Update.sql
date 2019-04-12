SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegisterRestriction#Update]
	 @PracticeRegisterRestrictionSID              int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PracticeRegisterSID                         int               = null -- table column values to update:
	,@PracticeRestrictionSID                      int               = null
	,@PracticeRegisterSectionSID                  int               = null
	,@EffectiveTime                               datetime          = null
	,@ExpiryTime                                  datetime          = null
	,@UserDefinedColumns                          xml               = null
	,@PracticeRegisterRestrictionXID              varchar(150)      = null
	,@LegacyKey                                   nvarchar(50)      = null
	,@UpdateUser                                  nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                    timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                                tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                               bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                    xml               = null -- other values defining context for the update (if any)
	,@PracticeRegisterTypeSID                     int               = null -- not a base table column
	,@RegistrationScheduleSID                     int               = null -- not a base table column
	,@PracticeRegisterName                        nvarchar(65)      = null -- not a base table column
	,@PracticeRegisterLabel                       nvarchar(35)      = null -- not a base table column
	,@IsActivePractice                            bit               = null -- not a base table column
	,@IsPublicRegistryEnabled                     bit               = null -- not a base table column
	,@IsRenewalEnabled                            bit               = null -- not a base table column
	,@IsLearningPlanEnabled                       bit               = null -- not a base table column
	,@IsNextCEFormAutoAdded                       bit               = null -- not a base table column
	,@IsEligibleSupervisor                        bit               = null -- not a base table column
	,@PracticeRegisterIsSupervisionRequired       bit               = null -- not a base table column
	,@IsEmploymentTerminated                      bit               = null -- not a base table column
	,@IsGroupMembershipTerminated                 bit               = null -- not a base table column
	,@TermPermitDays                              int               = null -- not a base table column
	,@RegisterRank                                smallint          = null -- not a base table column
	,@LearningModelSID                            int               = null -- not a base table column
	,@ReasonGroupSID                              int               = null -- not a base table column
	,@PracticeRegisterIsDefault                   bit               = null -- not a base table column
	,@IsDefaultInactivePractice                   bit               = null -- not a base table column
	,@PracticeRegisterIsActive                    bit               = null -- not a base table column
	,@PracticeRegisterRowGUID                     uniqueidentifier  = null -- not a base table column
	,@PracticeRestrictionLabel                    nvarchar(35)      = null -- not a base table column
	,@PracticeRestrictionIsDisplayedOnLicense     bit               = null -- not a base table column
	,@PracticeRestrictionIsActive                 bit               = null -- not a base table column
	,@PracticeRestrictionIsSupervisionRequired    bit               = null -- not a base table column
	,@PracticeRestrictionRowGUID                  uniqueidentifier  = null -- not a base table column
	,@PracticeRegisterSectionPracticeRegisterSID  int               = null -- not a base table column
	,@PracticeRegisterSectionLabel                nvarchar(35)      = null -- not a base table column
	,@PracticeRegisterSectionIsDefault            bit               = null -- not a base table column
	,@PracticeRegisterSectionIsDisplayedOnLicense bit               = null -- not a base table column
	,@PracticeRegisterSectionIsActive             bit               = null -- not a base table column
	,@PracticeRegisterSectionRowGUID              uniqueidentifier  = null -- not a base table column
	,@IsActive                                    bit               = null -- not a base table column
	,@IsPending                                   bit               = null -- not a base table column
	,@IsDeleteEnabled                             bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegisterRestriction#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PracticeRegisterRestriction table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PracticeRegisterRestriction table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPracticeRegisterRestriction entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPracticeRegisterRestriction procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPracticeRegisterRestrictionCheck to test all rules.

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

		if @PracticeRegisterRestrictionSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PracticeRegisterRestrictionSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PracticeRegisterRestrictionXID = ltrim(rtrim(@PracticeRegisterRestrictionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRestrictionLabel = ltrim(rtrim(@PracticeRestrictionLabel))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PracticeRegisterRestrictionXID) = 0 set @PracticeRegisterRestrictionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRestrictionLabel) = 0 set @PracticeRestrictionLabel = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PracticeRegisterSID                         = isnull(@PracticeRegisterSID,prr.PracticeRegisterSID)
				,@PracticeRestrictionSID                      = isnull(@PracticeRestrictionSID,prr.PracticeRestrictionSID)
				,@PracticeRegisterSectionSID                  = isnull(@PracticeRegisterSectionSID,prr.PracticeRegisterSectionSID)
				,@EffectiveTime                               = isnull(@EffectiveTime,prr.EffectiveTime)
				,@ExpiryTime                                  = isnull(@ExpiryTime,prr.ExpiryTime)
				,@UserDefinedColumns                          = isnull(@UserDefinedColumns,prr.UserDefinedColumns)
				,@PracticeRegisterRestrictionXID              = isnull(@PracticeRegisterRestrictionXID,prr.PracticeRegisterRestrictionXID)
				,@LegacyKey                                   = isnull(@LegacyKey,prr.LegacyKey)
				,@UpdateUser                                  = isnull(@UpdateUser,prr.UpdateUser)
				,@IsReselected                                = isnull(@IsReselected,prr.IsReselected)
				,@IsNullApplied                               = isnull(@IsNullApplied,prr.IsNullApplied)
				,@zContext                                    = isnull(@zContext,prr.zContext)
				,@PracticeRegisterTypeSID                     = isnull(@PracticeRegisterTypeSID,prr.PracticeRegisterTypeSID)
				,@RegistrationScheduleSID                     = isnull(@RegistrationScheduleSID,prr.RegistrationScheduleSID)
				,@PracticeRegisterName                        = isnull(@PracticeRegisterName,prr.PracticeRegisterName)
				,@PracticeRegisterLabel                       = isnull(@PracticeRegisterLabel,prr.PracticeRegisterLabel)
				,@IsActivePractice                            = isnull(@IsActivePractice,prr.IsActivePractice)
				,@IsPublicRegistryEnabled                     = isnull(@IsPublicRegistryEnabled,prr.IsPublicRegistryEnabled)
				,@IsRenewalEnabled                            = isnull(@IsRenewalEnabled,prr.IsRenewalEnabled)
				,@IsLearningPlanEnabled                       = isnull(@IsLearningPlanEnabled,prr.IsLearningPlanEnabled)
				,@IsNextCEFormAutoAdded                       = isnull(@IsNextCEFormAutoAdded,prr.IsNextCEFormAutoAdded)
				,@IsEligibleSupervisor                        = isnull(@IsEligibleSupervisor,prr.IsEligibleSupervisor)
				,@PracticeRegisterIsSupervisionRequired       = isnull(@PracticeRegisterIsSupervisionRequired,prr.PracticeRegisterIsSupervisionRequired)
				,@IsEmploymentTerminated                      = isnull(@IsEmploymentTerminated,prr.IsEmploymentTerminated)
				,@IsGroupMembershipTerminated                 = isnull(@IsGroupMembershipTerminated,prr.IsGroupMembershipTerminated)
				,@TermPermitDays                              = isnull(@TermPermitDays,prr.TermPermitDays)
				,@RegisterRank                                = isnull(@RegisterRank,prr.RegisterRank)
				,@LearningModelSID                            = isnull(@LearningModelSID,prr.LearningModelSID)
				,@ReasonGroupSID                              = isnull(@ReasonGroupSID,prr.ReasonGroupSID)
				,@PracticeRegisterIsDefault                   = isnull(@PracticeRegisterIsDefault,prr.PracticeRegisterIsDefault)
				,@IsDefaultInactivePractice                   = isnull(@IsDefaultInactivePractice,prr.IsDefaultInactivePractice)
				,@PracticeRegisterIsActive                    = isnull(@PracticeRegisterIsActive,prr.PracticeRegisterIsActive)
				,@PracticeRegisterRowGUID                     = isnull(@PracticeRegisterRowGUID,prr.PracticeRegisterRowGUID)
				,@PracticeRestrictionLabel                    = isnull(@PracticeRestrictionLabel,prr.PracticeRestrictionLabel)
				,@PracticeRestrictionIsDisplayedOnLicense     = isnull(@PracticeRestrictionIsDisplayedOnLicense,prr.PracticeRestrictionIsDisplayedOnLicense)
				,@PracticeRestrictionIsActive                 = isnull(@PracticeRestrictionIsActive,prr.PracticeRestrictionIsActive)
				,@PracticeRestrictionIsSupervisionRequired    = isnull(@PracticeRestrictionIsSupervisionRequired,prr.PracticeRestrictionIsSupervisionRequired)
				,@PracticeRestrictionRowGUID                  = isnull(@PracticeRestrictionRowGUID,prr.PracticeRestrictionRowGUID)
				,@PracticeRegisterSectionPracticeRegisterSID  = isnull(@PracticeRegisterSectionPracticeRegisterSID,prr.PracticeRegisterSectionPracticeRegisterSID)
				,@PracticeRegisterSectionLabel                = isnull(@PracticeRegisterSectionLabel,prr.PracticeRegisterSectionLabel)
				,@PracticeRegisterSectionIsDefault            = isnull(@PracticeRegisterSectionIsDefault,prr.PracticeRegisterSectionIsDefault)
				,@PracticeRegisterSectionIsDisplayedOnLicense = isnull(@PracticeRegisterSectionIsDisplayedOnLicense,prr.PracticeRegisterSectionIsDisplayedOnLicense)
				,@PracticeRegisterSectionIsActive             = isnull(@PracticeRegisterSectionIsActive,prr.PracticeRegisterSectionIsActive)
				,@PracticeRegisterSectionRowGUID              = isnull(@PracticeRegisterSectionRowGUID,prr.PracticeRegisterSectionRowGUID)
				,@IsActive                                    = isnull(@IsActive,prr.IsActive)
				,@IsPending                                   = isnull(@IsPending,prr.IsPending)
				,@IsDeleteEnabled                             = isnull(@IsDeleteEnabled,prr.IsDeleteEnabled)
			from
				dbo.vPracticeRegisterRestriction prr
			where
				prr.PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID

		end
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRegisterSectionSID from dbo.PracticeRegisterRestriction x where x.PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID) <> @PracticeRegisterSectionSID
			begin
			
				if (select x.IsActive from dbo.PracticeRegisterSection x where x.PracticeRegisterSectionSID = @PracticeRegisterSectionSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice register section'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRegisterSID from dbo.PracticeRegisterRestriction x where x.PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID) <> @PracticeRegisterSID
			begin
			
				if (select x.IsActive from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice register'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRestrictionSID from dbo.PracticeRegisterRestriction x where x.PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID) <> @PracticeRestrictionSID
			begin
			
				if (select x.IsActive from dbo.PracticeRestriction x where x.PracticeRestrictionSID = @PracticeRestrictionSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice restriction'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
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
				r.RoutineName = 'pPracticeRegisterRestriction'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterRestriction
				 @Mode                                        = 'update.pre'
				,@PracticeRegisterRestrictionSID              = @PracticeRegisterRestrictionSID
				,@PracticeRegisterSID                         = @PracticeRegisterSID output
				,@PracticeRestrictionSID                      = @PracticeRestrictionSID output
				,@PracticeRegisterSectionSID                  = @PracticeRegisterSectionSID output
				,@EffectiveTime                               = @EffectiveTime output
				,@ExpiryTime                                  = @ExpiryTime output
				,@UserDefinedColumns                          = @UserDefinedColumns output
				,@PracticeRegisterRestrictionXID              = @PracticeRegisterRestrictionXID output
				,@LegacyKey                                   = @LegacyKey output
				,@UpdateUser                                  = @UpdateUser
				,@RowStamp                                    = @RowStamp
				,@IsReselected                                = @IsReselected
				,@IsNullApplied                               = @IsNullApplied
				,@zContext                                    = @zContext
				,@PracticeRegisterTypeSID                     = @PracticeRegisterTypeSID
				,@RegistrationScheduleSID                     = @RegistrationScheduleSID
				,@PracticeRegisterName                        = @PracticeRegisterName
				,@PracticeRegisterLabel                       = @PracticeRegisterLabel
				,@IsActivePractice                            = @IsActivePractice
				,@IsPublicRegistryEnabled                     = @IsPublicRegistryEnabled
				,@IsRenewalEnabled                            = @IsRenewalEnabled
				,@IsLearningPlanEnabled                       = @IsLearningPlanEnabled
				,@IsNextCEFormAutoAdded                       = @IsNextCEFormAutoAdded
				,@IsEligibleSupervisor                        = @IsEligibleSupervisor
				,@PracticeRegisterIsSupervisionRequired       = @PracticeRegisterIsSupervisionRequired
				,@IsEmploymentTerminated                      = @IsEmploymentTerminated
				,@IsGroupMembershipTerminated                 = @IsGroupMembershipTerminated
				,@TermPermitDays                              = @TermPermitDays
				,@RegisterRank                                = @RegisterRank
				,@LearningModelSID                            = @LearningModelSID
				,@ReasonGroupSID                              = @ReasonGroupSID
				,@PracticeRegisterIsDefault                   = @PracticeRegisterIsDefault
				,@IsDefaultInactivePractice                   = @IsDefaultInactivePractice
				,@PracticeRegisterIsActive                    = @PracticeRegisterIsActive
				,@PracticeRegisterRowGUID                     = @PracticeRegisterRowGUID
				,@PracticeRestrictionLabel                    = @PracticeRestrictionLabel
				,@PracticeRestrictionIsDisplayedOnLicense     = @PracticeRestrictionIsDisplayedOnLicense
				,@PracticeRestrictionIsActive                 = @PracticeRestrictionIsActive
				,@PracticeRestrictionIsSupervisionRequired    = @PracticeRestrictionIsSupervisionRequired
				,@PracticeRestrictionRowGUID                  = @PracticeRestrictionRowGUID
				,@PracticeRegisterSectionPracticeRegisterSID  = @PracticeRegisterSectionPracticeRegisterSID
				,@PracticeRegisterSectionLabel                = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault            = @PracticeRegisterSectionIsDefault
				,@PracticeRegisterSectionIsDisplayedOnLicense = @PracticeRegisterSectionIsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive             = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID              = @PracticeRegisterSectionRowGUID
				,@IsActive                                    = @IsActive
				,@IsPending                                   = @IsPending
				,@IsDeleteEnabled                             = @IsDeleteEnabled
		
		end

		-- update the record

		update
			dbo.PracticeRegisterRestriction
		set
			 PracticeRegisterSID = @PracticeRegisterSID
			,PracticeRestrictionSID = @PracticeRestrictionSID
			,PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,UserDefinedColumns = @UserDefinedColumns
			,PracticeRegisterRestrictionXID = @PracticeRegisterRestrictionXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PracticeRegisterRestriction where PracticeRegisterRestrictionSID = @practiceRegisterRestrictionSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PracticeRegisterRestriction'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PracticeRegisterRestriction'
					,@Arg2        = @practiceRegisterRestrictionSID
				
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
				,@Arg2        = 'dbo.PracticeRegisterRestriction'
				,@Arg3        = @rowsAffected
				,@Arg4        = @practiceRegisterRestrictionSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
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
				r.RoutineName = 'pPracticeRegisterRestriction'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterRestriction
				 @Mode                                        = 'update.post'
				,@PracticeRegisterRestrictionSID              = @PracticeRegisterRestrictionSID
				,@PracticeRegisterSID                         = @PracticeRegisterSID
				,@PracticeRestrictionSID                      = @PracticeRestrictionSID
				,@PracticeRegisterSectionSID                  = @PracticeRegisterSectionSID
				,@EffectiveTime                               = @EffectiveTime
				,@ExpiryTime                                  = @ExpiryTime
				,@UserDefinedColumns                          = @UserDefinedColumns
				,@PracticeRegisterRestrictionXID              = @PracticeRegisterRestrictionXID
				,@LegacyKey                                   = @LegacyKey
				,@UpdateUser                                  = @UpdateUser
				,@RowStamp                                    = @RowStamp
				,@IsReselected                                = @IsReselected
				,@IsNullApplied                               = @IsNullApplied
				,@zContext                                    = @zContext
				,@PracticeRegisterTypeSID                     = @PracticeRegisterTypeSID
				,@RegistrationScheduleSID                     = @RegistrationScheduleSID
				,@PracticeRegisterName                        = @PracticeRegisterName
				,@PracticeRegisterLabel                       = @PracticeRegisterLabel
				,@IsActivePractice                            = @IsActivePractice
				,@IsPublicRegistryEnabled                     = @IsPublicRegistryEnabled
				,@IsRenewalEnabled                            = @IsRenewalEnabled
				,@IsLearningPlanEnabled                       = @IsLearningPlanEnabled
				,@IsNextCEFormAutoAdded                       = @IsNextCEFormAutoAdded
				,@IsEligibleSupervisor                        = @IsEligibleSupervisor
				,@PracticeRegisterIsSupervisionRequired       = @PracticeRegisterIsSupervisionRequired
				,@IsEmploymentTerminated                      = @IsEmploymentTerminated
				,@IsGroupMembershipTerminated                 = @IsGroupMembershipTerminated
				,@TermPermitDays                              = @TermPermitDays
				,@RegisterRank                                = @RegisterRank
				,@LearningModelSID                            = @LearningModelSID
				,@ReasonGroupSID                              = @ReasonGroupSID
				,@PracticeRegisterIsDefault                   = @PracticeRegisterIsDefault
				,@IsDefaultInactivePractice                   = @IsDefaultInactivePractice
				,@PracticeRegisterIsActive                    = @PracticeRegisterIsActive
				,@PracticeRegisterRowGUID                     = @PracticeRegisterRowGUID
				,@PracticeRestrictionLabel                    = @PracticeRestrictionLabel
				,@PracticeRestrictionIsDisplayedOnLicense     = @PracticeRestrictionIsDisplayedOnLicense
				,@PracticeRestrictionIsActive                 = @PracticeRestrictionIsActive
				,@PracticeRestrictionIsSupervisionRequired    = @PracticeRestrictionIsSupervisionRequired
				,@PracticeRestrictionRowGUID                  = @PracticeRestrictionRowGUID
				,@PracticeRegisterSectionPracticeRegisterSID  = @PracticeRegisterSectionPracticeRegisterSID
				,@PracticeRegisterSectionLabel                = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault            = @PracticeRegisterSectionIsDefault
				,@PracticeRegisterSectionIsDisplayedOnLicense = @PracticeRegisterSectionIsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive             = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID              = @PracticeRegisterSectionRowGUID
				,@IsActive                                    = @IsActive
				,@IsPending                                   = @IsPending
				,@IsDeleteEnabled                             = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PracticeRegisterRestrictionSID
			from
				dbo.vPracticeRegisterRestriction ent
			where
				ent.PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PracticeRegisterRestrictionSID
				,ent.PracticeRegisterSID
				,ent.PracticeRestrictionSID
				,ent.PracticeRegisterSectionSID
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.UserDefinedColumns
				,ent.PracticeRegisterRestrictionXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
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
				,ent.PracticeRegisterIsSupervisionRequired
				,ent.IsEmploymentTerminated
				,ent.IsGroupMembershipTerminated
				,ent.TermPermitDays
				,ent.RegisterRank
				,ent.LearningModelSID
				,ent.ReasonGroupSID
				,ent.PracticeRegisterIsDefault
				,ent.IsDefaultInactivePractice
				,ent.PracticeRegisterIsActive
				,ent.PracticeRegisterRowGUID
				,ent.PracticeRestrictionLabel
				,ent.PracticeRestrictionIsDisplayedOnLicense
				,ent.PracticeRestrictionIsActive
				,ent.PracticeRestrictionIsSupervisionRequired
				,ent.PracticeRestrictionRowGUID
				,ent.PracticeRegisterSectionPracticeRegisterSID
				,ent.PracticeRegisterSectionLabel
				,ent.PracticeRegisterSectionIsDefault
				,ent.PracticeRegisterSectionIsDisplayedOnLicense
				,ent.PracticeRegisterSectionIsActive
				,ent.PracticeRegisterSectionRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vPracticeRegisterRestriction ent
			where
				ent.PracticeRegisterRestrictionSID = @PracticeRegisterRestrictionSID

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
