SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantPracticeRestriction#Update]
	 @RegistrantPracticeRestrictionSID        int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantSID                           int               = null -- table column values to update:
	,@PracticeRestrictionSID                  int               = null
	,@EffectiveTime                           datetime          = null
	,@ExpiryTime                              datetime          = null
	,@IsDisplayedOnLicense                    bit               = null
	,@ComplaintSID                            int               = null
	,@UserDefinedColumns                      xml               = null
	,@RegistrantPracticeRestrictionXID        varchar(150)      = null
	,@LegacyKey                               nvarchar(50)      = null
	,@UpdateUser                              nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                            tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                           bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                xml               = null -- other values defining context for the update (if any)
	,@PracticeRestrictionLabel                nvarchar(35)      = null -- not a base table column
	,@PracticeRestrictionIsDisplayedOnLicense bit               = null -- not a base table column
	,@PracticeRestrictionIsActive             bit               = null -- not a base table column
	,@IsSupervisionRequired                   bit               = null -- not a base table column
	,@PracticeRestrictionRowGUID              uniqueidentifier  = null -- not a base table column
	,@PersonSID                               int               = null -- not a base table column
	,@RegistrantNo                            varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment                 smallint          = null -- not a base table column
	,@IsOnPublicRegistry                      bit               = null -- not a base table column
	,@CityNameOfBirth                         nvarchar(30)      = null -- not a base table column
	,@CountrySID                              int               = null -- not a base table column
	,@DirectedAuditYearCompetence             smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours          smallint          = null -- not a base table column
	,@LateFeeExclusionYear                    smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked            bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime              datetime          = null -- not a base table column
	,@ArchivedTime                            datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                       uniqueidentifier  = null -- not a base table column
	,@ComplaintNo                             varchar(50)       = null -- not a base table column
	,@ComplaintRegistrantSID                  int               = null -- not a base table column
	,@ComplaintTypeSID                        int               = null -- not a base table column
	,@ComplainantTypeSID                      int               = null -- not a base table column
	,@ApplicationUserSID                      int               = null -- not a base table column
	,@OpenedDate                              date              = null -- not a base table column
	,@ConductStartDate                        date              = null -- not a base table column
	,@ConductEndDate                          date              = null -- not a base table column
	,@ComplaintSeveritySID                    int               = null -- not a base table column
	,@IsDisplayedOnPublicRegistry             bit               = null -- not a base table column
	,@ClosedDate                              date              = null -- not a base table column
	,@DismissedDate                           date              = null -- not a base table column
	,@ReasonSID                               int               = null -- not a base table column
	,@FileExtension                           varchar(5)        = null -- not a base table column
	,@ComplaintRowGUID                        uniqueidentifier  = null -- not a base table column
	,@IsActive                                bit               = null -- not a base table column
	,@IsPending                               bit               = null -- not a base table column
	,@IsDeleteEnabled                         bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantPracticeRestriction#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantPracticeRestriction table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantPracticeRestriction table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantPracticeRestriction entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantPracticeRestriction procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantPracticeRestrictionCheck to test all rules.

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

		if @RegistrantPracticeRestrictionSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantPracticeRestrictionSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrantPracticeRestrictionXID = ltrim(rtrim(@RegistrantPracticeRestrictionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PracticeRestrictionLabel = ltrim(rtrim(@PracticeRestrictionLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrantPracticeRestrictionXID) = 0 set @RegistrantPracticeRestrictionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PracticeRestrictionLabel) = 0 set @PracticeRestrictionLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantSID                           = isnull(@RegistrantSID,rpr.RegistrantSID)
				,@PracticeRestrictionSID                  = isnull(@PracticeRestrictionSID,rpr.PracticeRestrictionSID)
				,@EffectiveTime                           = isnull(@EffectiveTime,rpr.EffectiveTime)
				,@ExpiryTime                              = isnull(@ExpiryTime,rpr.ExpiryTime)
				,@IsDisplayedOnLicense                    = isnull(@IsDisplayedOnLicense,rpr.IsDisplayedOnLicense)
				,@ComplaintSID                            = isnull(@ComplaintSID,rpr.ComplaintSID)
				,@UserDefinedColumns                      = isnull(@UserDefinedColumns,rpr.UserDefinedColumns)
				,@RegistrantPracticeRestrictionXID        = isnull(@RegistrantPracticeRestrictionXID,rpr.RegistrantPracticeRestrictionXID)
				,@LegacyKey                               = isnull(@LegacyKey,rpr.LegacyKey)
				,@UpdateUser                              = isnull(@UpdateUser,rpr.UpdateUser)
				,@IsReselected                            = isnull(@IsReselected,rpr.IsReselected)
				,@IsNullApplied                           = isnull(@IsNullApplied,rpr.IsNullApplied)
				,@zContext                                = isnull(@zContext,rpr.zContext)
				,@PracticeRestrictionLabel                = isnull(@PracticeRestrictionLabel,rpr.PracticeRestrictionLabel)
				,@PracticeRestrictionIsDisplayedOnLicense = isnull(@PracticeRestrictionIsDisplayedOnLicense,rpr.PracticeRestrictionIsDisplayedOnLicense)
				,@PracticeRestrictionIsActive             = isnull(@PracticeRestrictionIsActive,rpr.PracticeRestrictionIsActive)
				,@IsSupervisionRequired                   = isnull(@IsSupervisionRequired,rpr.IsSupervisionRequired)
				,@PracticeRestrictionRowGUID              = isnull(@PracticeRestrictionRowGUID,rpr.PracticeRestrictionRowGUID)
				,@PersonSID                               = isnull(@PersonSID,rpr.PersonSID)
				,@RegistrantNo                            = isnull(@RegistrantNo,rpr.RegistrantNo)
				,@YearOfInitialEmployment                 = isnull(@YearOfInitialEmployment,rpr.YearOfInitialEmployment)
				,@IsOnPublicRegistry                      = isnull(@IsOnPublicRegistry,rpr.IsOnPublicRegistry)
				,@CityNameOfBirth                         = isnull(@CityNameOfBirth,rpr.CityNameOfBirth)
				,@CountrySID                              = isnull(@CountrySID,rpr.CountrySID)
				,@DirectedAuditYearCompetence             = isnull(@DirectedAuditYearCompetence,rpr.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours          = isnull(@DirectedAuditYearPracticeHours,rpr.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear                    = isnull(@LateFeeExclusionYear,rpr.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked            = isnull(@IsRenewalAutoApprovalBlocked,rpr.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime              = isnull(@RenewalExtensionExpiryTime,rpr.RenewalExtensionExpiryTime)
				,@ArchivedTime                            = isnull(@ArchivedTime,rpr.ArchivedTime)
				,@RegistrantRowGUID                       = isnull(@RegistrantRowGUID,rpr.RegistrantRowGUID)
				,@ComplaintNo                             = isnull(@ComplaintNo,rpr.ComplaintNo)
				,@ComplaintRegistrantSID                  = isnull(@ComplaintRegistrantSID,rpr.ComplaintRegistrantSID)
				,@ComplaintTypeSID                        = isnull(@ComplaintTypeSID,rpr.ComplaintTypeSID)
				,@ComplainantTypeSID                      = isnull(@ComplainantTypeSID,rpr.ComplainantTypeSID)
				,@ApplicationUserSID                      = isnull(@ApplicationUserSID,rpr.ApplicationUserSID)
				,@OpenedDate                              = isnull(@OpenedDate,rpr.OpenedDate)
				,@ConductStartDate                        = isnull(@ConductStartDate,rpr.ConductStartDate)
				,@ConductEndDate                          = isnull(@ConductEndDate,rpr.ConductEndDate)
				,@ComplaintSeveritySID                    = isnull(@ComplaintSeveritySID,rpr.ComplaintSeveritySID)
				,@IsDisplayedOnPublicRegistry             = isnull(@IsDisplayedOnPublicRegistry,rpr.IsDisplayedOnPublicRegistry)
				,@ClosedDate                              = isnull(@ClosedDate,rpr.ClosedDate)
				,@DismissedDate                           = isnull(@DismissedDate,rpr.DismissedDate)
				,@ReasonSID                               = isnull(@ReasonSID,rpr.ReasonSID)
				,@FileExtension                           = isnull(@FileExtension,rpr.FileExtension)
				,@ComplaintRowGUID                        = isnull(@ComplaintRowGUID,rpr.ComplaintRowGUID)
				,@IsActive                                = isnull(@IsActive,rpr.IsActive)
				,@IsPending                               = isnull(@IsPending,rpr.IsPending)
				,@IsDeleteEnabled                         = isnull(@IsDeleteEnabled,rpr.IsDeleteEnabled)
			from
				dbo.vRegistrantPracticeRestriction rpr
			where
				rpr.RegistrantPracticeRestrictionSID = @RegistrantPracticeRestrictionSID

		end
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRestrictionSID from dbo.RegistrantPracticeRestriction x where x.RegistrantPracticeRestrictionSID = @RegistrantPracticeRestrictionSID) <> @PracticeRestrictionSID
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
		-- Tim Edlund | Feb 2018
		-- Ensure the effective times for these records are set
		-- to the beginning of the day only. (Overwrites default
		-- code above.)
		set @EffectiveTime = cast((convert(varchar(8), @EffectiveTime, 112)) + ' 00:00:00.00' as datetime);

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
				r.RoutineName = 'pRegistrantPracticeRestriction'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPracticeRestriction
				 @Mode                                    = 'update.pre'
				,@RegistrantPracticeRestrictionSID        = @RegistrantPracticeRestrictionSID
				,@RegistrantSID                           = @RegistrantSID output
				,@PracticeRestrictionSID                  = @PracticeRestrictionSID output
				,@EffectiveTime                           = @EffectiveTime output
				,@ExpiryTime                              = @ExpiryTime output
				,@IsDisplayedOnLicense                    = @IsDisplayedOnLicense output
				,@ComplaintSID                            = @ComplaintSID output
				,@UserDefinedColumns                      = @UserDefinedColumns output
				,@RegistrantPracticeRestrictionXID        = @RegistrantPracticeRestrictionXID output
				,@LegacyKey                               = @LegacyKey output
				,@UpdateUser                              = @UpdateUser
				,@RowStamp                                = @RowStamp
				,@IsReselected                            = @IsReselected
				,@IsNullApplied                           = @IsNullApplied
				,@zContext                                = @zContext
				,@PracticeRestrictionLabel                = @PracticeRestrictionLabel
				,@PracticeRestrictionIsDisplayedOnLicense = @PracticeRestrictionIsDisplayedOnLicense
				,@PracticeRestrictionIsActive             = @PracticeRestrictionIsActive
				,@IsSupervisionRequired                   = @IsSupervisionRequired
				,@PracticeRestrictionRowGUID              = @PracticeRestrictionRowGUID
				,@PersonSID                               = @PersonSID
				,@RegistrantNo                            = @RegistrantNo
				,@YearOfInitialEmployment                 = @YearOfInitialEmployment
				,@IsOnPublicRegistry                      = @IsOnPublicRegistry
				,@CityNameOfBirth                         = @CityNameOfBirth
				,@CountrySID                              = @CountrySID
				,@DirectedAuditYearCompetence             = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours          = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear                    = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked            = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime              = @RenewalExtensionExpiryTime
				,@ArchivedTime                            = @ArchivedTime
				,@RegistrantRowGUID                       = @RegistrantRowGUID
				,@ComplaintNo                             = @ComplaintNo
				,@ComplaintRegistrantSID                  = @ComplaintRegistrantSID
				,@ComplaintTypeSID                        = @ComplaintTypeSID
				,@ComplainantTypeSID                      = @ComplainantTypeSID
				,@ApplicationUserSID                      = @ApplicationUserSID
				,@OpenedDate                              = @OpenedDate
				,@ConductStartDate                        = @ConductStartDate
				,@ConductEndDate                          = @ConductEndDate
				,@ComplaintSeveritySID                    = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry             = @IsDisplayedOnPublicRegistry
				,@ClosedDate                              = @ClosedDate
				,@DismissedDate                           = @DismissedDate
				,@ReasonSID                               = @ReasonSID
				,@FileExtension                           = @FileExtension
				,@ComplaintRowGUID                        = @ComplaintRowGUID
				,@IsActive                                = @IsActive
				,@IsPending                               = @IsPending
				,@IsDeleteEnabled                         = @IsDeleteEnabled
		
		end

		-- update the record

		update
			dbo.RegistrantPracticeRestriction
		set
			 RegistrantSID = @RegistrantSID
			,PracticeRestrictionSID = @PracticeRestrictionSID
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,IsDisplayedOnLicense = @IsDisplayedOnLicense
			,ComplaintSID = @ComplaintSID
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantPracticeRestrictionXID = @RegistrantPracticeRestrictionXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantPracticeRestrictionSID = @RegistrantPracticeRestrictionSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantPracticeRestriction where RegistrantPracticeRestrictionSID = @registrantPracticeRestrictionSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantPracticeRestriction'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantPracticeRestriction'
					,@Arg2        = @registrantPracticeRestrictionSID
				
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
				,@Arg2        = 'dbo.RegistrantPracticeRestriction'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantPracticeRestrictionSID
			
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
				r.RoutineName = 'pRegistrantPracticeRestriction'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPracticeRestriction
				 @Mode                                    = 'update.post'
				,@RegistrantPracticeRestrictionSID        = @RegistrantPracticeRestrictionSID
				,@RegistrantSID                           = @RegistrantSID
				,@PracticeRestrictionSID                  = @PracticeRestrictionSID
				,@EffectiveTime                           = @EffectiveTime
				,@ExpiryTime                              = @ExpiryTime
				,@IsDisplayedOnLicense                    = @IsDisplayedOnLicense
				,@ComplaintSID                            = @ComplaintSID
				,@UserDefinedColumns                      = @UserDefinedColumns
				,@RegistrantPracticeRestrictionXID        = @RegistrantPracticeRestrictionXID
				,@LegacyKey                               = @LegacyKey
				,@UpdateUser                              = @UpdateUser
				,@RowStamp                                = @RowStamp
				,@IsReselected                            = @IsReselected
				,@IsNullApplied                           = @IsNullApplied
				,@zContext                                = @zContext
				,@PracticeRestrictionLabel                = @PracticeRestrictionLabel
				,@PracticeRestrictionIsDisplayedOnLicense = @PracticeRestrictionIsDisplayedOnLicense
				,@PracticeRestrictionIsActive             = @PracticeRestrictionIsActive
				,@IsSupervisionRequired                   = @IsSupervisionRequired
				,@PracticeRestrictionRowGUID              = @PracticeRestrictionRowGUID
				,@PersonSID                               = @PersonSID
				,@RegistrantNo                            = @RegistrantNo
				,@YearOfInitialEmployment                 = @YearOfInitialEmployment
				,@IsOnPublicRegistry                      = @IsOnPublicRegistry
				,@CityNameOfBirth                         = @CityNameOfBirth
				,@CountrySID                              = @CountrySID
				,@DirectedAuditYearCompetence             = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours          = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear                    = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked            = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime              = @RenewalExtensionExpiryTime
				,@ArchivedTime                            = @ArchivedTime
				,@RegistrantRowGUID                       = @RegistrantRowGUID
				,@ComplaintNo                             = @ComplaintNo
				,@ComplaintRegistrantSID                  = @ComplaintRegistrantSID
				,@ComplaintTypeSID                        = @ComplaintTypeSID
				,@ComplainantTypeSID                      = @ComplainantTypeSID
				,@ApplicationUserSID                      = @ApplicationUserSID
				,@OpenedDate                              = @OpenedDate
				,@ConductStartDate                        = @ConductStartDate
				,@ConductEndDate                          = @ConductEndDate
				,@ComplaintSeveritySID                    = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry             = @IsDisplayedOnPublicRegistry
				,@ClosedDate                              = @ClosedDate
				,@DismissedDate                           = @DismissedDate
				,@ReasonSID                               = @ReasonSID
				,@FileExtension                           = @FileExtension
				,@ComplaintRowGUID                        = @ComplaintRowGUID
				,@IsActive                                = @IsActive
				,@IsPending                               = @IsPending
				,@IsDeleteEnabled                         = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantPracticeRestrictionSID
			from
				dbo.vRegistrantPracticeRestriction ent
			where
				ent.RegistrantPracticeRestrictionSID = @RegistrantPracticeRestrictionSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantPracticeRestrictionSID
				,ent.RegistrantSID
				,ent.PracticeRestrictionSID
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsDisplayedOnLicense
				,ent.ComplaintSID
				,ent.UserDefinedColumns
				,ent.RegistrantPracticeRestrictionXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PracticeRestrictionLabel
				,ent.PracticeRestrictionIsDisplayedOnLicense
				,ent.PracticeRestrictionIsActive
				,ent.IsSupervisionRequired
				,ent.PracticeRestrictionRowGUID
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
				,ent.ReasonSID
				,ent.FileExtension
				,ent.ComplaintRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vRegistrantPracticeRestriction ent
			where
				ent.RegistrantPracticeRestrictionSID = @RegistrantPracticeRestrictionSID

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
