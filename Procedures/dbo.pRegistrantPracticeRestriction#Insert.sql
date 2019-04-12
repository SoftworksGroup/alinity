SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantPracticeRestriction#Insert]
	 @RegistrantPracticeRestrictionSID        int               = null output													-- identity value assigned to the new record
	,@RegistrantSID                           int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRestrictionSID                  int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime                           datetime          = null			-- default: sf.fNow()
	,@ExpiryTime                              datetime          = null			
	,@IsDisplayedOnLicense                    bit               = null			-- default: (1)
	,@ComplaintSID                            int               = null			
	,@UserDefinedColumns                      xml               = null			
	,@RegistrantPracticeRestrictionXID        varchar(150)      = null			
	,@LegacyKey                               nvarchar(50)      = null			
	,@CreateUser                              nvarchar(75)      = null			-- default: suser_sname()
	,@IsReselected                            tinyint           = null			-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                xml               = null			-- other values defining context for the insert (if any)
	,@PracticeRestrictionLabel                nvarchar(35)      = null			-- not a base table column (default ignored)
	,@PracticeRestrictionIsDisplayedOnLicense bit               = null			-- not a base table column (default ignored)
	,@PracticeRestrictionIsActive             bit               = null			-- not a base table column (default ignored)
	,@IsSupervisionRequired                   bit               = null			-- not a base table column (default ignored)
	,@PracticeRestrictionRowGUID              uniqueidentifier  = null			-- not a base table column (default ignored)
	,@PersonSID                               int               = null			-- not a base table column (default ignored)
	,@RegistrantNo                            varchar(50)       = null			-- not a base table column (default ignored)
	,@YearOfInitialEmployment                 smallint          = null			-- not a base table column (default ignored)
	,@IsOnPublicRegistry                      bit               = null			-- not a base table column (default ignored)
	,@CityNameOfBirth                         nvarchar(30)      = null			-- not a base table column (default ignored)
	,@CountrySID                              int               = null			-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence             smallint          = null			-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours          smallint          = null			-- not a base table column (default ignored)
	,@LateFeeExclusionYear                    smallint          = null			-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked            bit               = null			-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime              datetime          = null			-- not a base table column (default ignored)
	,@ArchivedTime                            datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantRowGUID                       uniqueidentifier  = null			-- not a base table column (default ignored)
	,@ComplaintNo                             varchar(50)       = null			-- not a base table column (default ignored)
	,@ComplaintRegistrantSID                  int               = null			-- not a base table column (default ignored)
	,@ComplaintTypeSID                        int               = null			-- not a base table column (default ignored)
	,@ComplainantTypeSID                      int               = null			-- not a base table column (default ignored)
	,@ApplicationUserSID                      int               = null			-- not a base table column (default ignored)
	,@OpenedDate                              date              = null			-- not a base table column (default ignored)
	,@ConductStartDate                        date              = null			-- not a base table column (default ignored)
	,@ConductEndDate                          date              = null			-- not a base table column (default ignored)
	,@ComplaintSeveritySID                    int               = null			-- not a base table column (default ignored)
	,@IsDisplayedOnPublicRegistry             bit               = null			-- not a base table column (default ignored)
	,@ClosedDate                              date              = null			-- not a base table column (default ignored)
	,@DismissedDate                           date              = null			-- not a base table column (default ignored)
	,@ReasonSID                               int               = null			-- not a base table column (default ignored)
	,@FileExtension                           varchar(5)        = null			-- not a base table column (default ignored)
	,@ComplaintRowGUID                        uniqueidentifier  = null			-- not a base table column (default ignored)
	,@IsActive                                bit               = null			-- not a base table column (default ignored)
	,@IsPending                               bit               = null			-- not a base table column (default ignored)
	,@IsDeleteEnabled                         bit               = null			-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantPracticeRestriction#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantPracticeRestriction table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantPracticeRestriction table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantPracticeRestriction entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantPracticeRestriction procedure. The extended procedure is only called
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

	set @RegistrantPracticeRestrictionSID = null														-- initialize output parameter

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

		set @RegistrantPracticeRestrictionXID = ltrim(rtrim(@RegistrantPracticeRestrictionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @PracticeRestrictionLabel = ltrim(rtrim(@PracticeRestrictionLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrantPracticeRestrictionXID) = 0 set @RegistrantPracticeRestrictionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PracticeRestrictionLabel) = 0 set @PracticeRestrictionLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @EffectiveTime = isnull(@EffectiveTime,sf.fNow())
		set @IsDisplayedOnLicense = isnull(@IsDisplayedOnLicense,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                     = isnull(@IsReselected                    ,(0))
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Feb 2018
		-- Ensure the effective times for these records are set
		-- to the beginning of the day only. (Overwrites default
		-- code above.)

		set @EffectiveTime = cast((convert(varchar(8), isnull(@EffectiveTime, sf.fToday()), 112)) + ' 00:00:00.00' as datetime);

		-- Tim Edlund | Feb 2018
		-- Lookup the RegistrantSID if its not passed and the
		-- PersonSID is passed

		if @PersonSID is not null and @RegistrantSID is null
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID

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
				r.RoutineName = 'pRegistrantPracticeRestriction'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPracticeRestriction
				 @Mode                                    = 'insert.pre'
				,@RegistrantSID                           = @RegistrantSID output
				,@PracticeRestrictionSID                  = @PracticeRestrictionSID output
				,@EffectiveTime                           = @EffectiveTime output
				,@ExpiryTime                              = @ExpiryTime output
				,@IsDisplayedOnLicense                    = @IsDisplayedOnLicense output
				,@ComplaintSID                            = @ComplaintSID output
				,@UserDefinedColumns                      = @UserDefinedColumns output
				,@RegistrantPracticeRestrictionXID        = @RegistrantPracticeRestrictionXID output
				,@LegacyKey                               = @LegacyKey output
				,@CreateUser                              = @CreateUser
				,@IsReselected                            = @IsReselected
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

		-- insert the record

		insert
			dbo.RegistrantPracticeRestriction
		(
			 RegistrantSID
			,PracticeRestrictionSID
			,EffectiveTime
			,ExpiryTime
			,IsDisplayedOnLicense
			,ComplaintSID
			,UserDefinedColumns
			,RegistrantPracticeRestrictionXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@PracticeRestrictionSID
			,@EffectiveTime
			,@ExpiryTime
			,@IsDisplayedOnLicense
			,@ComplaintSID
			,@UserDefinedColumns
			,@RegistrantPracticeRestrictionXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected                     = @@rowcount
			,@RegistrantPracticeRestrictionSID = scope_identity()								-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantPracticeRestriction'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantPracticeRestrictionSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
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
				r.RoutineName = 'pRegistrantPracticeRestriction'
		)
		begin
		
			exec @errorNo = ext.pRegistrantPracticeRestriction
				 @Mode                                    = 'insert.post'
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
				,@CreateUser                              = @CreateUser
				,@IsReselected                            = @IsReselected
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