SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantRenewalResponse#Update]
	 @RegistrantRenewalResponseSID int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantRenewalSID         int               = null -- table column values to update:
	,@FormOwnerSID                 int               = null
	,@FormResponse                 xml               = null
	,@UserDefinedColumns           xml               = null
	,@RegistrantRenewalResponseXID varchar(150)      = null
	,@LegacyKey                    nvarchar(50)      = null
	,@UpdateUser                   nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                     timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                 tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                     xml               = null -- other values defining context for the update (if any)
	,@RegistrationSID              int               = null -- not a base table column
	,@PracticeRegisterSectionSID   int               = null -- not a base table column
	,@RegistrationYear             smallint          = null -- not a base table column
	,@FormVersionSID               int               = null -- not a base table column
	,@LastValidateTime             datetimeoffset(7) = null -- not a base table column
	,@NextFollowUp                 date              = null -- not a base table column
	,@IsAutoApprovalEnabled        bit               = null -- not a base table column
	,@ReasonSID                    int               = null -- not a base table column
	,@InvoiceSID                   int               = null -- not a base table column
	,@RegistrantRenewalRowGUID     uniqueidentifier  = null -- not a base table column
	,@FormOwnerSCD                 varchar(25)       = null -- not a base table column
	,@FormOwnerLabel               nvarchar(35)      = null -- not a base table column
	,@IsAssignee                   bit               = null -- not a base table column
	,@FormOwnerRowGUID             uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled              bit               = null -- not a base table column
	,@DisplayName                  nvarchar(65)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantRenewalResponse#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantRenewalResponse table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantRenewalResponse table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantRenewalResponse entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantRenewalResponse procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantRenewalResponseCheck to test all rules.

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

		if @RegistrantRenewalResponseSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantRenewalResponseSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrantRenewalResponseXID = ltrim(rtrim(@RegistrantRenewalResponseXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FormOwnerSCD = ltrim(rtrim(@FormOwnerSCD))
		set @FormOwnerLabel = ltrim(rtrim(@FormOwnerLabel))
		set @DisplayName = ltrim(rtrim(@DisplayName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrantRenewalResponseXID) = 0 set @RegistrantRenewalResponseXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FormOwnerSCD) = 0 set @FormOwnerSCD = null
		if len(@FormOwnerLabel) = 0 set @FormOwnerLabel = null
		if len(@DisplayName) = 0 set @DisplayName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantRenewalSID         = isnull(@RegistrantRenewalSID,rrr.RegistrantRenewalSID)
				,@FormOwnerSID                 = isnull(@FormOwnerSID,rrr.FormOwnerSID)
				,@FormResponse                 = isnull(@FormResponse,rrr.FormResponse)
				,@UserDefinedColumns           = isnull(@UserDefinedColumns,rrr.UserDefinedColumns)
				,@RegistrantRenewalResponseXID = isnull(@RegistrantRenewalResponseXID,rrr.RegistrantRenewalResponseXID)
				,@LegacyKey                    = isnull(@LegacyKey,rrr.LegacyKey)
				,@UpdateUser                   = isnull(@UpdateUser,rrr.UpdateUser)
				,@IsReselected                 = isnull(@IsReselected,rrr.IsReselected)
				,@IsNullApplied                = isnull(@IsNullApplied,rrr.IsNullApplied)
				,@zContext                     = isnull(@zContext,rrr.zContext)
				,@RegistrationSID              = isnull(@RegistrationSID,rrr.RegistrationSID)
				,@PracticeRegisterSectionSID   = isnull(@PracticeRegisterSectionSID,rrr.PracticeRegisterSectionSID)
				,@RegistrationYear             = isnull(@RegistrationYear,rrr.RegistrationYear)
				,@FormVersionSID               = isnull(@FormVersionSID,rrr.FormVersionSID)
				,@LastValidateTime             = isnull(@LastValidateTime,rrr.LastValidateTime)
				,@NextFollowUp                 = isnull(@NextFollowUp,rrr.NextFollowUp)
				,@IsAutoApprovalEnabled        = isnull(@IsAutoApprovalEnabled,rrr.IsAutoApprovalEnabled)
				,@ReasonSID                    = isnull(@ReasonSID,rrr.ReasonSID)
				,@InvoiceSID                   = isnull(@InvoiceSID,rrr.InvoiceSID)
				,@RegistrantRenewalRowGUID     = isnull(@RegistrantRenewalRowGUID,rrr.RegistrantRenewalRowGUID)
				,@FormOwnerSCD                 = isnull(@FormOwnerSCD,rrr.FormOwnerSCD)
				,@FormOwnerLabel               = isnull(@FormOwnerLabel,rrr.FormOwnerLabel)
				,@IsAssignee                   = isnull(@IsAssignee,rrr.IsAssignee)
				,@FormOwnerRowGUID             = isnull(@FormOwnerRowGUID,rrr.FormOwnerRowGUID)
				,@IsDeleteEnabled              = isnull(@IsDeleteEnabled,rrr.IsDeleteEnabled)
				,@DisplayName                  = isnull(@DisplayName,rrr.DisplayName)
			from
				dbo.vRegistrantRenewalResponse rrr
			where
				rrr.RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @FormOwnerSCD is not null and @FormOwnerSID = (select x.FormOwnerSID from dbo.RegistrantRenewalResponse x where x.RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID)
		begin
		
			select
				@FormOwnerSID = x.FormOwnerSID
			from
				sf.FormOwner x
			where
				x.FormOwnerSCD = @FormOwnerSCD
		
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
				r.RoutineName = 'pRegistrantRenewalResponse'
		)
		begin
		
			exec @errorNo = ext.pRegistrantRenewalResponse
				 @Mode                         = 'update.pre'
				,@RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID
				,@RegistrantRenewalSID         = @RegistrantRenewalSID output
				,@FormOwnerSID                 = @FormOwnerSID output
				,@FormResponse                 = @FormResponse output
				,@UserDefinedColumns           = @UserDefinedColumns output
				,@RegistrantRenewalResponseXID = @RegistrantRenewalResponseXID output
				,@LegacyKey                    = @LegacyKey output
				,@UpdateUser                   = @UpdateUser
				,@RowStamp                     = @RowStamp
				,@IsReselected                 = @IsReselected
				,@IsNullApplied                = @IsNullApplied
				,@zContext                     = @zContext
				,@RegistrationSID              = @RegistrationSID
				,@PracticeRegisterSectionSID   = @PracticeRegisterSectionSID
				,@RegistrationYear             = @RegistrationYear
				,@FormVersionSID               = @FormVersionSID
				,@LastValidateTime             = @LastValidateTime
				,@NextFollowUp                 = @NextFollowUp
				,@IsAutoApprovalEnabled        = @IsAutoApprovalEnabled
				,@ReasonSID                    = @ReasonSID
				,@InvoiceSID                   = @InvoiceSID
				,@RegistrantRenewalRowGUID     = @RegistrantRenewalRowGUID
				,@FormOwnerSCD                 = @FormOwnerSCD
				,@FormOwnerLabel               = @FormOwnerLabel
				,@IsAssignee                   = @IsAssignee
				,@FormOwnerRowGUID             = @FormOwnerRowGUID
				,@IsDeleteEnabled              = @IsDeleteEnabled
				,@DisplayName                  = @DisplayName
		
		end

		-- update the record

		update
			dbo.RegistrantRenewalResponse
		set
			 RegistrantRenewalSID = @RegistrantRenewalSID
			,FormOwnerSID = @FormOwnerSID
			,FormResponse = @FormResponse
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantRenewalResponseXID = @RegistrantRenewalResponseXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantRenewalResponse where RegistrantRenewalResponseSID = @registrantRenewalResponseSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantRenewalResponse'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantRenewalResponse'
					,@Arg2        = @registrantRenewalResponseSID
				
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
				,@Arg2        = 'dbo.RegistrantRenewalResponse'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantRenewalResponseSID
			
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
				r.RoutineName = 'pRegistrantRenewalResponse'
		)
		begin
		
			exec @errorNo = ext.pRegistrantRenewalResponse
				 @Mode                         = 'update.post'
				,@RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID
				,@RegistrantRenewalSID         = @RegistrantRenewalSID
				,@FormOwnerSID                 = @FormOwnerSID
				,@FormResponse                 = @FormResponse
				,@UserDefinedColumns           = @UserDefinedColumns
				,@RegistrantRenewalResponseXID = @RegistrantRenewalResponseXID
				,@LegacyKey                    = @LegacyKey
				,@UpdateUser                   = @UpdateUser
				,@RowStamp                     = @RowStamp
				,@IsReselected                 = @IsReselected
				,@IsNullApplied                = @IsNullApplied
				,@zContext                     = @zContext
				,@RegistrationSID              = @RegistrationSID
				,@PracticeRegisterSectionSID   = @PracticeRegisterSectionSID
				,@RegistrationYear             = @RegistrationYear
				,@FormVersionSID               = @FormVersionSID
				,@LastValidateTime             = @LastValidateTime
				,@NextFollowUp                 = @NextFollowUp
				,@IsAutoApprovalEnabled        = @IsAutoApprovalEnabled
				,@ReasonSID                    = @ReasonSID
				,@InvoiceSID                   = @InvoiceSID
				,@RegistrantRenewalRowGUID     = @RegistrantRenewalRowGUID
				,@FormOwnerSCD                 = @FormOwnerSCD
				,@FormOwnerLabel               = @FormOwnerLabel
				,@IsAssignee                   = @IsAssignee
				,@FormOwnerRowGUID             = @FormOwnerRowGUID
				,@IsDeleteEnabled              = @IsDeleteEnabled
				,@DisplayName                  = @DisplayName
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantRenewalResponseSID
			from
				dbo.vRegistrantRenewalResponse ent
			where
				ent.RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantRenewalResponseSID
				,ent.RegistrantRenewalSID
				,ent.FormOwnerSID
				,ent.FormResponse
				,ent.UserDefinedColumns
				,ent.RegistrantRenewalResponseXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.FormVersionSID
				,ent.LastValidateTime
				,ent.NextFollowUp
				,ent.IsAutoApprovalEnabled
				,ent.ReasonSID
				,ent.InvoiceSID
				,ent.RegistrantRenewalRowGUID
				,ent.FormOwnerSCD
				,ent.FormOwnerLabel
				,ent.IsAssignee
				,ent.FormOwnerRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.DisplayName
			from
				dbo.vRegistrantRenewalResponse ent
			where
				ent.RegistrantRenewalResponseSID = @RegistrantRenewalResponseSID

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
