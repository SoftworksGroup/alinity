SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegisterRestriction#Insert]
	 @PracticeRegisterRestrictionSID              int               = null output											-- identity value assigned to the new record
	,@PracticeRegisterSID                         int               = null	-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRestrictionSID                      int               = null	-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterSectionSID                  int               = null	
	,@EffectiveTime                               datetime          = null	-- default: CONVERT(datetime,sf.fToday())
	,@ExpiryTime                                  datetime          = null	
	,@UserDefinedColumns                          xml               = null	
	,@PracticeRegisterRestrictionXID              varchar(150)      = null	
	,@LegacyKey                                   nvarchar(50)      = null	
	,@CreateUser                                  nvarchar(75)      = null	-- default: suser_sname()
	,@IsReselected                                tinyint           = null	-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                    xml               = null	-- other values defining context for the insert (if any)
	,@PracticeRegisterTypeSID                     int               = null	-- not a base table column (default ignored)
	,@RegistrationScheduleSID                     int               = null	-- not a base table column (default ignored)
	,@PracticeRegisterName                        nvarchar(65)      = null	-- not a base table column (default ignored)
	,@PracticeRegisterLabel                       nvarchar(35)      = null	-- not a base table column (default ignored)
	,@IsActivePractice                            bit               = null	-- not a base table column (default ignored)
	,@IsPublicRegistryEnabled                     bit               = null	-- not a base table column (default ignored)
	,@IsRenewalEnabled                            bit               = null	-- not a base table column (default ignored)
	,@IsLearningPlanEnabled                       bit               = null	-- not a base table column (default ignored)
	,@IsNextCEFormAutoAdded                       bit               = null	-- not a base table column (default ignored)
	,@IsEligibleSupervisor                        bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterIsSupervisionRequired       bit               = null	-- not a base table column (default ignored)
	,@IsEmploymentTerminated                      bit               = null	-- not a base table column (default ignored)
	,@IsGroupMembershipTerminated                 bit               = null	-- not a base table column (default ignored)
	,@TermPermitDays                              int               = null	-- not a base table column (default ignored)
	,@RegisterRank                                smallint          = null	-- not a base table column (default ignored)
	,@LearningModelSID                            int               = null	-- not a base table column (default ignored)
	,@ReasonGroupSID                              int               = null	-- not a base table column (default ignored)
	,@PracticeRegisterIsDefault                   bit               = null	-- not a base table column (default ignored)
	,@IsDefaultInactivePractice                   bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterIsActive                    bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterRowGUID                     uniqueidentifier  = null	-- not a base table column (default ignored)
	,@PracticeRestrictionLabel                    nvarchar(35)      = null	-- not a base table column (default ignored)
	,@PracticeRestrictionIsDisplayedOnLicense     bit               = null	-- not a base table column (default ignored)
	,@PracticeRestrictionIsActive                 bit               = null	-- not a base table column (default ignored)
	,@PracticeRestrictionIsSupervisionRequired    bit               = null	-- not a base table column (default ignored)
	,@PracticeRestrictionRowGUID                  uniqueidentifier  = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionPracticeRegisterSID  int               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel                nvarchar(35)      = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDefault            bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDisplayedOnLicense bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsActive             bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionRowGUID              uniqueidentifier  = null	-- not a base table column (default ignored)
	,@IsActive                                    bit               = null	-- not a base table column (default ignored)
	,@IsPending                                   bit               = null	-- not a base table column (default ignored)
	,@IsDeleteEnabled                             bit               = null	-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegisterRestriction#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PracticeRegisterRestriction table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PracticeRegisterRestriction table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPracticeRegisterRestriction entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPracticeRegisterRestriction procedure. The extended procedure is only called
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

	set @PracticeRegisterRestrictionSID = null															-- initialize output parameter

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

		set @PracticeRegisterRestrictionXID = ltrim(rtrim(@PracticeRegisterRestrictionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRestrictionLabel = ltrim(rtrim(@PracticeRestrictionLabel))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PracticeRegisterRestrictionXID) = 0 set @PracticeRegisterRestrictionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRestrictionLabel) = 0 set @PracticeRestrictionLabel = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @EffectiveTime = isnull(@EffectiveTime,CONVERT(datetime,sf.fToday()))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                   = isnull(@IsReselected                  ,(0))
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @PracticeRegisterSID  is null select @PracticeRegisterSID  = x.PracticeRegisterSID from dbo.PracticeRegister x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
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
				r.RoutineName = 'pPracticeRegisterRestriction'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterRestriction
				 @Mode                                        = 'insert.pre'
				,@PracticeRegisterSID                         = @PracticeRegisterSID output
				,@PracticeRestrictionSID                      = @PracticeRestrictionSID output
				,@PracticeRegisterSectionSID                  = @PracticeRegisterSectionSID output
				,@EffectiveTime                               = @EffectiveTime output
				,@ExpiryTime                                  = @ExpiryTime output
				,@UserDefinedColumns                          = @UserDefinedColumns output
				,@PracticeRegisterRestrictionXID              = @PracticeRegisterRestrictionXID output
				,@LegacyKey                                   = @LegacyKey output
				,@CreateUser                                  = @CreateUser
				,@IsReselected                                = @IsReselected
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

		-- insert the record

		insert
			dbo.PracticeRegisterRestriction
		(
			 PracticeRegisterSID
			,PracticeRestrictionSID
			,PracticeRegisterSectionSID
			,EffectiveTime
			,ExpiryTime
			,UserDefinedColumns
			,PracticeRegisterRestrictionXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PracticeRegisterSID
			,@PracticeRestrictionSID
			,@PracticeRegisterSectionSID
			,@EffectiveTime
			,@ExpiryTime
			,@UserDefinedColumns
			,@PracticeRegisterRestrictionXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected                   = @@rowcount
			,@PracticeRegisterRestrictionSID = scope_identity()									-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PracticeRegisterRestriction'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PracticeRegisterRestrictionSID
			
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
				r.RoutineName = 'pPracticeRegisterRestriction'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterRestriction
				 @Mode                                        = 'insert.post'
				,@PracticeRegisterRestrictionSID              = @PracticeRegisterRestrictionSID
				,@PracticeRegisterSID                         = @PracticeRegisterSID
				,@PracticeRestrictionSID                      = @PracticeRestrictionSID
				,@PracticeRegisterSectionSID                  = @PracticeRegisterSectionSID
				,@EffectiveTime                               = @EffectiveTime
				,@ExpiryTime                                  = @ExpiryTime
				,@UserDefinedColumns                          = @UserDefinedColumns
				,@PracticeRegisterRestrictionXID              = @PracticeRegisterRestrictionXID
				,@LegacyKey                                   = @LegacyKey
				,@CreateUser                                  = @CreateUser
				,@IsReselected                                = @IsReselected
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
