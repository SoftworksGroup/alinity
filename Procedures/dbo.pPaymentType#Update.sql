SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPaymentType#Update]
	 @PaymentTypeSID             int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PaymentTypeSCD             varchar(15)       = null -- table column values to update:
	,@PaymentTypeLabel           nvarchar(35)      = null
	,@PaymentTypeCategory        nvarchar(65)      = null
	,@GLAccountSID               int               = null
	,@PaymentStatusSID           int               = null
	,@IsReferenceRequired        bit               = null
	,@DepositDateLagDays         smallint          = null
	,@IsRefundExcludedFromGL     bit               = null
	,@ExcludeDepositFromGLBefore date              = null
	,@IsDefault                  bit               = null
	,@IsActive                   bit               = null
	,@UserDefinedColumns         xml               = null
	,@PaymentTypeXID             varchar(150)      = null
	,@LegacyKey                  nvarchar(50)      = null
	,@UpdateUser                 nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                   timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected               tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied              bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                   xml               = null -- other values defining context for the update (if any)
	,@GLAccountCode              varchar(50)       = null -- not a base table column
	,@GLAccountLabel             nvarchar(35)      = null -- not a base table column
	,@IsRevenueAccount           bit               = null -- not a base table column
	,@IsBankAccount              bit               = null -- not a base table column
	,@IsTaxAccount               bit               = null -- not a base table column
	,@IsPAPAccount               bit               = null -- not a base table column
	,@IsUnappliedPaymentAccount  bit               = null -- not a base table column
	,@DeferredGLAccountCode      varchar(50)       = null -- not a base table column
	,@GLAccountIsActive          bit               = null -- not a base table column
	,@GLAccountRowGUID           uniqueidentifier  = null -- not a base table column
	,@PaymentStatusSCD           varchar(25)       = null -- not a base table column
	,@PaymentStatusLabel         nvarchar(35)      = null -- not a base table column
	,@IsPaid                     bit               = null -- not a base table column
	,@PaymentStatusSequence      int               = null -- not a base table column
	,@PaymentStatusRowGUID       uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled            bit               = null -- not a base table column
	,@DepositDate                date              = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPaymentType#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PaymentType table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PaymentType table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPaymentType entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPaymentType procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPaymentTypeCheck to test all rules.

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

		if @PaymentTypeSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PaymentTypeSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PaymentTypeSCD = ltrim(rtrim(@PaymentTypeSCD))
		set @PaymentTypeLabel = ltrim(rtrim(@PaymentTypeLabel))
		set @PaymentTypeCategory = ltrim(rtrim(@PaymentTypeCategory))
		set @PaymentTypeXID = ltrim(rtrim(@PaymentTypeXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @GLAccountCode = ltrim(rtrim(@GLAccountCode))
		set @GLAccountLabel = ltrim(rtrim(@GLAccountLabel))
		set @DeferredGLAccountCode = ltrim(rtrim(@DeferredGLAccountCode))
		set @PaymentStatusSCD = ltrim(rtrim(@PaymentStatusSCD))
		set @PaymentStatusLabel = ltrim(rtrim(@PaymentStatusLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PaymentTypeSCD) = 0 set @PaymentTypeSCD = null
		if len(@PaymentTypeLabel) = 0 set @PaymentTypeLabel = null
		if len(@PaymentTypeCategory) = 0 set @PaymentTypeCategory = null
		if len(@PaymentTypeXID) = 0 set @PaymentTypeXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@GLAccountCode) = 0 set @GLAccountCode = null
		if len(@GLAccountLabel) = 0 set @GLAccountLabel = null
		if len(@DeferredGLAccountCode) = 0 set @DeferredGLAccountCode = null
		if len(@PaymentStatusSCD) = 0 set @PaymentStatusSCD = null
		if len(@PaymentStatusLabel) = 0 set @PaymentStatusLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PaymentTypeSCD             = isnull(@PaymentTypeSCD,ptype.PaymentTypeSCD)
				,@PaymentTypeLabel           = isnull(@PaymentTypeLabel,ptype.PaymentTypeLabel)
				,@PaymentTypeCategory        = isnull(@PaymentTypeCategory,ptype.PaymentTypeCategory)
				,@GLAccountSID               = isnull(@GLAccountSID,ptype.GLAccountSID)
				,@PaymentStatusSID           = isnull(@PaymentStatusSID,ptype.PaymentStatusSID)
				,@IsReferenceRequired        = isnull(@IsReferenceRequired,ptype.IsReferenceRequired)
				,@DepositDateLagDays         = isnull(@DepositDateLagDays,ptype.DepositDateLagDays)
				,@IsRefundExcludedFromGL     = isnull(@IsRefundExcludedFromGL,ptype.IsRefundExcludedFromGL)
				,@ExcludeDepositFromGLBefore = isnull(@ExcludeDepositFromGLBefore,ptype.ExcludeDepositFromGLBefore)
				,@IsDefault                  = isnull(@IsDefault,ptype.IsDefault)
				,@IsActive                   = isnull(@IsActive,ptype.IsActive)
				,@UserDefinedColumns         = isnull(@UserDefinedColumns,ptype.UserDefinedColumns)
				,@PaymentTypeXID             = isnull(@PaymentTypeXID,ptype.PaymentTypeXID)
				,@LegacyKey                  = isnull(@LegacyKey,ptype.LegacyKey)
				,@UpdateUser                 = isnull(@UpdateUser,ptype.UpdateUser)
				,@IsReselected               = isnull(@IsReselected,ptype.IsReselected)
				,@IsNullApplied              = isnull(@IsNullApplied,ptype.IsNullApplied)
				,@zContext                   = isnull(@zContext,ptype.zContext)
				,@GLAccountCode              = isnull(@GLAccountCode,ptype.GLAccountCode)
				,@GLAccountLabel             = isnull(@GLAccountLabel,ptype.GLAccountLabel)
				,@IsRevenueAccount           = isnull(@IsRevenueAccount,ptype.IsRevenueAccount)
				,@IsBankAccount              = isnull(@IsBankAccount,ptype.IsBankAccount)
				,@IsTaxAccount               = isnull(@IsTaxAccount,ptype.IsTaxAccount)
				,@IsPAPAccount               = isnull(@IsPAPAccount,ptype.IsPAPAccount)
				,@IsUnappliedPaymentAccount  = isnull(@IsUnappliedPaymentAccount,ptype.IsUnappliedPaymentAccount)
				,@DeferredGLAccountCode      = isnull(@DeferredGLAccountCode,ptype.DeferredGLAccountCode)
				,@GLAccountIsActive          = isnull(@GLAccountIsActive,ptype.GLAccountIsActive)
				,@GLAccountRowGUID           = isnull(@GLAccountRowGUID,ptype.GLAccountRowGUID)
				,@PaymentStatusSCD           = isnull(@PaymentStatusSCD,ptype.PaymentStatusSCD)
				,@PaymentStatusLabel         = isnull(@PaymentStatusLabel,ptype.PaymentStatusLabel)
				,@IsPaid                     = isnull(@IsPaid,ptype.IsPaid)
				,@PaymentStatusSequence      = isnull(@PaymentStatusSequence,ptype.PaymentStatusSequence)
				,@PaymentStatusRowGUID       = isnull(@PaymentStatusRowGUID,ptype.PaymentStatusRowGUID)
				,@IsDeleteEnabled            = isnull(@IsDeleteEnabled,ptype.IsDeleteEnabled)
				,@DepositDate                = isnull(@DepositDate,ptype.DepositDate)
			from
				dbo.vPaymentType ptype
			where
				ptype.PaymentTypeSID = @PaymentTypeSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @PaymentStatusSCD is not null and @PaymentStatusSID = (select x.PaymentStatusSID from dbo.PaymentType x where x.PaymentTypeSID = @PaymentTypeSID)
		begin
		
			select
				@PaymentStatusSID = x.PaymentStatusSID
			from
				dbo.PaymentStatus x
			where
				x.PaymentStatusSCD = @PaymentStatusSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.GLAccountSID from dbo.PaymentType x where x.PaymentTypeSID = @PaymentTypeSID) <> @GLAccountSID
		begin
			if (select x.IsActive from dbo.GLAccount x where x.GLAccountSID = @GLAccountSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'glaccount'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		-- unset previous default if record is being marked as the new default
		
		if @IsDefault = @ON
		begin
		
			select @recordSID = x.PaymentTypeSID from dbo.PaymentType x where x.IsDefault = @ON and x.PaymentTypeSID <> @PaymentTypeSID
			
			if @recordSID is not null
			begin
			
				update
					dbo.PaymentType
				set
					 IsDefault  = @OFF
					,UpdateUser = @UpdateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PaymentTypeSID = @recordSID																			-- unique index ensures only 1 record needs to be unset
				
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
				r.RoutineName = 'pPaymentType'
		)
		begin
		
			exec @errorNo = ext.pPaymentType
				 @Mode                       = 'update.pre'
				,@PaymentTypeSID             = @PaymentTypeSID
				,@PaymentTypeSCD             = @PaymentTypeSCD output
				,@PaymentTypeLabel           = @PaymentTypeLabel output
				,@PaymentTypeCategory        = @PaymentTypeCategory output
				,@GLAccountSID               = @GLAccountSID output
				,@PaymentStatusSID           = @PaymentStatusSID output
				,@IsReferenceRequired        = @IsReferenceRequired output
				,@DepositDateLagDays         = @DepositDateLagDays output
				,@IsRefundExcludedFromGL     = @IsRefundExcludedFromGL output
				,@ExcludeDepositFromGLBefore = @ExcludeDepositFromGLBefore output
				,@IsDefault                  = @IsDefault output
				,@IsActive                   = @IsActive output
				,@UserDefinedColumns         = @UserDefinedColumns output
				,@PaymentTypeXID             = @PaymentTypeXID output
				,@LegacyKey                  = @LegacyKey output
				,@UpdateUser                 = @UpdateUser
				,@RowStamp                   = @RowStamp
				,@IsReselected               = @IsReselected
				,@IsNullApplied              = @IsNullApplied
				,@zContext                   = @zContext
				,@GLAccountCode              = @GLAccountCode
				,@GLAccountLabel             = @GLAccountLabel
				,@IsRevenueAccount           = @IsRevenueAccount
				,@IsBankAccount              = @IsBankAccount
				,@IsTaxAccount               = @IsTaxAccount
				,@IsPAPAccount               = @IsPAPAccount
				,@IsUnappliedPaymentAccount  = @IsUnappliedPaymentAccount
				,@DeferredGLAccountCode      = @DeferredGLAccountCode
				,@GLAccountIsActive          = @GLAccountIsActive
				,@GLAccountRowGUID           = @GLAccountRowGUID
				,@PaymentStatusSCD           = @PaymentStatusSCD
				,@PaymentStatusLabel         = @PaymentStatusLabel
				,@IsPaid                     = @IsPaid
				,@PaymentStatusSequence      = @PaymentStatusSequence
				,@PaymentStatusRowGUID       = @PaymentStatusRowGUID
				,@IsDeleteEnabled            = @IsDeleteEnabled
				,@DepositDate                = @DepositDate
		
		end

		-- update the record

		update
			dbo.PaymentType
		set
			 PaymentTypeSCD = @PaymentTypeSCD
			,PaymentTypeLabel = @PaymentTypeLabel
			,PaymentTypeCategory = @PaymentTypeCategory
			,GLAccountSID = @GLAccountSID
			,PaymentStatusSID = @PaymentStatusSID
			,IsReferenceRequired = @IsReferenceRequired
			,DepositDateLagDays = @DepositDateLagDays
			,IsRefundExcludedFromGL = @IsRefundExcludedFromGL
			,ExcludeDepositFromGLBefore = @ExcludeDepositFromGLBefore
			,IsDefault = @IsDefault
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,PaymentTypeXID = @PaymentTypeXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PaymentTypeSID = @PaymentTypeSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PaymentType where PaymentTypeSID = @paymentTypeSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PaymentType'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PaymentType'
					,@Arg2        = @paymentTypeSID
				
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
				,@Arg2        = 'dbo.PaymentType'
				,@Arg3        = @rowsAffected
				,@Arg4        = @paymentTypeSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
		
		-- ensure a default record is identified on the table
		
		if not exists
		(
			select 1 from	dbo.PaymentType x where x.IsDefault = @ON
		)
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'MissingDefault'
				,@MessageText = @errorText output
				,@DefaultText = N'A default %1 record is required by the application. (Setting another record as the new default automatically un-sets the previous one.)'
				,@Arg1        = 'Payment Type'
			
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
				r.RoutineName = 'pPaymentType'
		)
		begin
		
			exec @errorNo = ext.pPaymentType
				 @Mode                       = 'update.post'
				,@PaymentTypeSID             = @PaymentTypeSID
				,@PaymentTypeSCD             = @PaymentTypeSCD
				,@PaymentTypeLabel           = @PaymentTypeLabel
				,@PaymentTypeCategory        = @PaymentTypeCategory
				,@GLAccountSID               = @GLAccountSID
				,@PaymentStatusSID           = @PaymentStatusSID
				,@IsReferenceRequired        = @IsReferenceRequired
				,@DepositDateLagDays         = @DepositDateLagDays
				,@IsRefundExcludedFromGL     = @IsRefundExcludedFromGL
				,@ExcludeDepositFromGLBefore = @ExcludeDepositFromGLBefore
				,@IsDefault                  = @IsDefault
				,@IsActive                   = @IsActive
				,@UserDefinedColumns         = @UserDefinedColumns
				,@PaymentTypeXID             = @PaymentTypeXID
				,@LegacyKey                  = @LegacyKey
				,@UpdateUser                 = @UpdateUser
				,@RowStamp                   = @RowStamp
				,@IsReselected               = @IsReselected
				,@IsNullApplied              = @IsNullApplied
				,@zContext                   = @zContext
				,@GLAccountCode              = @GLAccountCode
				,@GLAccountLabel             = @GLAccountLabel
				,@IsRevenueAccount           = @IsRevenueAccount
				,@IsBankAccount              = @IsBankAccount
				,@IsTaxAccount               = @IsTaxAccount
				,@IsPAPAccount               = @IsPAPAccount
				,@IsUnappliedPaymentAccount  = @IsUnappliedPaymentAccount
				,@DeferredGLAccountCode      = @DeferredGLAccountCode
				,@GLAccountIsActive          = @GLAccountIsActive
				,@GLAccountRowGUID           = @GLAccountRowGUID
				,@PaymentStatusSCD           = @PaymentStatusSCD
				,@PaymentStatusLabel         = @PaymentStatusLabel
				,@IsPaid                     = @IsPaid
				,@PaymentStatusSequence      = @PaymentStatusSequence
				,@PaymentStatusRowGUID       = @PaymentStatusRowGUID
				,@IsDeleteEnabled            = @IsDeleteEnabled
				,@DepositDate                = @DepositDate
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PaymentTypeSID
			from
				dbo.vPaymentType ent
			where
				ent.PaymentTypeSID = @PaymentTypeSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PaymentTypeSID
				,ent.PaymentTypeSCD
				,ent.PaymentTypeLabel
				,ent.PaymentTypeCategory
				,ent.GLAccountSID
				,ent.PaymentStatusSID
				,ent.IsReferenceRequired
				,ent.DepositDateLagDays
				,ent.IsRefundExcludedFromGL
				,ent.ExcludeDepositFromGLBefore
				,ent.IsDefault
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.PaymentTypeXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.GLAccountCode
				,ent.GLAccountLabel
				,ent.IsRevenueAccount
				,ent.IsBankAccount
				,ent.IsTaxAccount
				,ent.IsPAPAccount
				,ent.IsUnappliedPaymentAccount
				,ent.DeferredGLAccountCode
				,ent.GLAccountIsActive
				,ent.GLAccountRowGUID
				,ent.PaymentStatusSCD
				,ent.PaymentStatusLabel
				,ent.IsPaid
				,ent.PaymentStatusSequence
				,ent.PaymentStatusRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.DepositDate
			from
				dbo.vPaymentType ent
			where
				ent.PaymentTypeSID = @PaymentTypeSID

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
