SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPAPSubscription#Insert]
	 @PAPSubscriptionSID     int               = null output								-- identity value assigned to the new record
	,@PersonSID              int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@InstitutionNo          varchar(3)        = null												-- required! if not passed value must be set in custom logic prior to insert
	,@TransitNo              varchar(5)        = null												-- required! if not passed value must be set in custom logic prior to insert
	,@AccountNo              varchar(15)       = null												-- required! if not passed value must be set in custom logic prior to insert
	,@WithdrawalAmount       decimal(11,2)     = null												-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime          datetime          = null												-- required! if not passed value must be set in custom logic prior to insert
	,@CancelledTime          datetime          = null												
	,@UserDefinedColumns     xml               = null												
	,@PAPSubscriptionXID     varchar(150)      = null												
	,@LegacyKey              nvarchar(50)      = null												
	,@CreateUser             nvarchar(75)      = null												-- default: suser_sname()
	,@IsReselected           tinyint           = null												-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext               xml               = null												-- other values defining context for the insert (if any)
	,@GenderSID              int               = null												-- not a base table column (default ignored)
	,@NamePrefixSID          int               = null												-- not a base table column (default ignored)
	,@FirstName              nvarchar(30)      = null												-- not a base table column (default ignored)
	,@CommonName             nvarchar(30)      = null												-- not a base table column (default ignored)
	,@MiddleNames            nvarchar(30)      = null												-- not a base table column (default ignored)
	,@LastName               nvarchar(35)      = null												-- not a base table column (default ignored)
	,@BirthDate              date              = null												-- not a base table column (default ignored)
	,@DeathDate              date              = null												-- not a base table column (default ignored)
	,@HomePhone              varchar(25)       = null												-- not a base table column (default ignored)
	,@MobilePhone            varchar(25)       = null												-- not a base table column (default ignored)
	,@IsTextMessagingEnabled bit               = null												-- not a base table column (default ignored)
	,@ImportBatch            nvarchar(100)     = null												-- not a base table column (default ignored)
	,@PersonRowGUID          uniqueidentifier  = null												-- not a base table column (default ignored)
	,@IsDeleteEnabled        bit               = null												-- not a base table column (default ignored)
	,@RegistrantNo           varchar(50)       = null												-- not a base table column (default ignored)
	,@RegistrantLabel        nvarchar(75)      = null												-- not a base table column (default ignored)
	,@FileAsName             nvarchar(65)      = null												-- not a base table column (default ignored)
	,@DisplayName            nvarchar(65)      = null												-- not a base table column (default ignored)
	,@IsActiveSubscription   bit               = null												-- not a base table column (default ignored)
	,@HasRejectedTrxs        bit               = null												-- not a base table column (default ignored)
	,@HasUnappliedAmount     bit               = null												-- not a base table column (default ignored)
	,@EmailAddress           varchar(150)      = null												-- not a base table column (default ignored)
	,@TrxCount               int               = null												-- not a base table column (default ignored)
	,@RejectedTrxCount       int               = null												-- not a base table column (default ignored)
	,@TotalUnapplied         decimal(38,2)     = null												-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPAPSubscription#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PAPSubscription table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PAPSubscription table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPAPSubscription entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPAPSubscription procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPAPSubscriptionCheck to test all rules.

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

	set @PAPSubscriptionSID = null																					-- initialize output parameter

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

		set @InstitutionNo = ltrim(rtrim(@InstitutionNo))
		set @TransitNo = ltrim(rtrim(@TransitNo))
		set @AccountNo = ltrim(rtrim(@AccountNo))
		set @PAPSubscriptionXID = ltrim(rtrim(@PAPSubscriptionXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @DisplayName = ltrim(rtrim(@DisplayName))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))

		-- set zero length strings to null to avoid storing them in the record

		if len(@InstitutionNo) = 0 set @InstitutionNo = null
		if len(@TransitNo) = 0 set @TransitNo = null
		if len(@AccountNo) = 0 set @AccountNo = null
		if len(@PAPSubscriptionXID) = 0 set @PAPSubscriptionXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@DisplayName) = 0 set @DisplayName = null
		if len(@EmailAddress) = 0 set @EmailAddress = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected       = isnull(@IsReselected      ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
		
		exec sf.pEffectiveExpiry#Set																					-- ensure effective time has start of day time component or current time if today
		   @EffectiveTime = @EffectiveTime output
	
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
				r.RoutineName = 'pPAPSubscription'
		)
		begin
		
			exec @errorNo = ext.pPAPSubscription
				 @Mode                   = 'insert.pre'
				,@PersonSID              = @PersonSID output
				,@InstitutionNo          = @InstitutionNo output
				,@TransitNo              = @TransitNo output
				,@AccountNo              = @AccountNo output
				,@WithdrawalAmount       = @WithdrawalAmount output
				,@EffectiveTime          = @EffectiveTime output
				,@CancelledTime          = @CancelledTime output
				,@UserDefinedColumns     = @UserDefinedColumns output
				,@PAPSubscriptionXID     = @PAPSubscriptionXID output
				,@LegacyKey              = @LegacyKey output
				,@CreateUser             = @CreateUser
				,@IsReselected           = @IsReselected
				,@zContext               = @zContext
				,@GenderSID              = @GenderSID
				,@NamePrefixSID          = @NamePrefixSID
				,@FirstName              = @FirstName
				,@CommonName             = @CommonName
				,@MiddleNames            = @MiddleNames
				,@LastName               = @LastName
				,@BirthDate              = @BirthDate
				,@DeathDate              = @DeathDate
				,@HomePhone              = @HomePhone
				,@MobilePhone            = @MobilePhone
				,@IsTextMessagingEnabled = @IsTextMessagingEnabled
				,@ImportBatch            = @ImportBatch
				,@PersonRowGUID          = @PersonRowGUID
				,@IsDeleteEnabled        = @IsDeleteEnabled
				,@RegistrantNo           = @RegistrantNo
				,@RegistrantLabel        = @RegistrantLabel
				,@FileAsName             = @FileAsName
				,@DisplayName            = @DisplayName
				,@IsActiveSubscription   = @IsActiveSubscription
				,@HasRejectedTrxs        = @HasRejectedTrxs
				,@HasUnappliedAmount     = @HasUnappliedAmount
				,@EmailAddress           = @EmailAddress
				,@TrxCount               = @TrxCount
				,@RejectedTrxCount       = @RejectedTrxCount
				,@TotalUnapplied         = @TotalUnapplied
		
		end

		-- insert the record

		insert
			dbo.PAPSubscription
		(
			 PersonSID
			,InstitutionNo
			,TransitNo
			,AccountNo
			,WithdrawalAmount
			,EffectiveTime
			,CancelledTime
			,UserDefinedColumns
			,PAPSubscriptionXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@InstitutionNo
			,@TransitNo
			,@AccountNo
			,@WithdrawalAmount
			,@EffectiveTime
			,@CancelledTime
			,@UserDefinedColumns
			,@PAPSubscriptionXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected       = @@rowcount
			,@PAPSubscriptionSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PAPSubscription'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PAPSubscriptionSID
			
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
				r.RoutineName = 'pPAPSubscription'
		)
		begin
		
			exec @errorNo = ext.pPAPSubscription
				 @Mode                   = 'insert.post'
				,@PAPSubscriptionSID     = @PAPSubscriptionSID
				,@PersonSID              = @PersonSID
				,@InstitutionNo          = @InstitutionNo
				,@TransitNo              = @TransitNo
				,@AccountNo              = @AccountNo
				,@WithdrawalAmount       = @WithdrawalAmount
				,@EffectiveTime          = @EffectiveTime
				,@CancelledTime          = @CancelledTime
				,@UserDefinedColumns     = @UserDefinedColumns
				,@PAPSubscriptionXID     = @PAPSubscriptionXID
				,@LegacyKey              = @LegacyKey
				,@CreateUser             = @CreateUser
				,@IsReselected           = @IsReselected
				,@zContext               = @zContext
				,@GenderSID              = @GenderSID
				,@NamePrefixSID          = @NamePrefixSID
				,@FirstName              = @FirstName
				,@CommonName             = @CommonName
				,@MiddleNames            = @MiddleNames
				,@LastName               = @LastName
				,@BirthDate              = @BirthDate
				,@DeathDate              = @DeathDate
				,@HomePhone              = @HomePhone
				,@MobilePhone            = @MobilePhone
				,@IsTextMessagingEnabled = @IsTextMessagingEnabled
				,@ImportBatch            = @ImportBatch
				,@PersonRowGUID          = @PersonRowGUID
				,@IsDeleteEnabled        = @IsDeleteEnabled
				,@RegistrantNo           = @RegistrantNo
				,@RegistrantLabel        = @RegistrantLabel
				,@FileAsName             = @FileAsName
				,@DisplayName            = @DisplayName
				,@IsActiveSubscription   = @IsActiveSubscription
				,@HasRejectedTrxs        = @HasRejectedTrxs
				,@HasUnappliedAmount     = @HasUnappliedAmount
				,@EmailAddress           = @EmailAddress
				,@TrxCount               = @TrxCount
				,@RejectedTrxCount       = @RejectedTrxCount
				,@TotalUnapplied         = @TotalUnapplied
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PAPSubscriptionSID
			from
				dbo.vPAPSubscription ent
			where
				ent.PAPSubscriptionSID = @PAPSubscriptionSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PAPSubscriptionSID
				,ent.PersonSID
				,ent.InstitutionNo
				,ent.TransitNo
				,ent.AccountNo
				,ent.WithdrawalAmount
				,ent.EffectiveTime
				,ent.CancelledTime
				,ent.UserDefinedColumns
				,ent.PAPSubscriptionXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.BirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantNo
				,ent.RegistrantLabel
				,ent.FileAsName
				,ent.DisplayName
				,ent.IsActiveSubscription
				,ent.HasRejectedTrxs
				,ent.HasUnappliedAmount
				,ent.EmailAddress
				,ent.TrxCount
				,ent.RejectedTrxCount
				,ent.TotalUnapplied
			from
				dbo.vPAPSubscription ent
			where
				ent.PAPSubscriptionSID = @PAPSubscriptionSID

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