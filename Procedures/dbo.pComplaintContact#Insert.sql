SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pComplaintContact#Insert]
	 @ComplaintContactSID           int               = null output					-- identity value assigned to the new record
	,@ComplaintSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@PersonSID                     int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ComplaintContactRoleSID       int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime                 datetime          = null								-- default: sf.fNow()
	,@ExpiryTime                    datetime          = null								
	,@UserDefinedColumns            xml               = null								
	,@ComplaintContactXID           varchar(150)      = null								
	,@LegacyKey                     nvarchar(50)      = null								
	,@CreateUser                    nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                  tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                      xml               = null								-- other values defining context for the insert (if any)
	,@ComplaintNo                   varchar(50)       = null								-- not a base table column (default ignored)
	,@RegistrantSID                 int               = null								-- not a base table column (default ignored)
	,@ComplaintTypeSID              int               = null								-- not a base table column (default ignored)
	,@ComplainantTypeSID            int               = null								-- not a base table column (default ignored)
	,@ApplicationUserSID            int               = null								-- not a base table column (default ignored)
	,@OpenedDate                    date              = null								-- not a base table column (default ignored)
	,@ConductStartDate              date              = null								-- not a base table column (default ignored)
	,@ConductEndDate                date              = null								-- not a base table column (default ignored)
	,@ComplaintSeveritySID          int               = null								-- not a base table column (default ignored)
	,@IsDisplayedOnPublicRegistry   bit               = null								-- not a base table column (default ignored)
	,@ClosedDate                    date              = null								-- not a base table column (default ignored)
	,@DismissedDate                 date              = null								-- not a base table column (default ignored)
	,@ReasonSID                     int               = null								-- not a base table column (default ignored)
	,@FileExtension                 varchar(5)        = null								-- not a base table column (default ignored)
	,@ComplaintRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ComplaintContactRoleSCD       varchar(20)       = null								-- not a base table column (default ignored)
	,@ComplaintContactRoleName      nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ComplaintContactRoleIsDefault bit               = null								-- not a base table column (default ignored)
	,@ComplaintContactRoleRowGUID   uniqueidentifier  = null								-- not a base table column (default ignored)
	,@GenderSID                     int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                 int               = null								-- not a base table column (default ignored)
	,@FirstName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                   nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                      nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                     date              = null								-- not a base table column (default ignored)
	,@DeathDate                     date              = null								-- not a base table column (default ignored)
	,@HomePhone                     varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                   varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled        bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                   nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                 uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsActive                      bit               = null								-- not a base table column (default ignored)
	,@IsPending                     bit               = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled               bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pComplaintContact#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.ComplaintContact table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.ComplaintContact table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vComplaintContact entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pComplaintContact procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fComplaintContactCheck to test all rules.

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

	set @ComplaintContactSID = null																					-- initialize output parameter

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

		set @ComplaintContactXID = ltrim(rtrim(@ComplaintContactXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @ComplaintContactRoleSCD = ltrim(rtrim(@ComplaintContactRoleSCD))
		set @ComplaintContactRoleName = ltrim(rtrim(@ComplaintContactRoleName))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ComplaintContactXID) = 0 set @ComplaintContactXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null
		if len(@ComplaintContactRoleSCD) = 0 set @ComplaintContactRoleSCD = null
		if len(@ComplaintContactRoleName) = 0 set @ComplaintContactRoleName = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @EffectiveTime = isnull(@EffectiveTime,sf.fNow())
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ComplaintContactRoleSCD is not null
		begin
		
			select
				@ComplaintContactRoleSID = x.ComplaintContactRoleSID
			from
				dbo.ComplaintContactRole x
			where
				x.ComplaintContactRoleSCD = @ComplaintContactRoleSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @ComplaintContactRoleSID  is null select @ComplaintContactRoleSID  = x.ComplaintContactRoleSID from dbo.ComplaintContactRole x where x.IsDefault = @ON

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
				r.RoutineName = 'pComplaintContact'
		)
		begin
		
			exec @errorNo = ext.pComplaintContact
				 @Mode                          = 'insert.pre'
				,@ComplaintSID                  = @ComplaintSID output
				,@PersonSID                     = @PersonSID output
				,@ComplaintContactRoleSID       = @ComplaintContactRoleSID output
				,@EffectiveTime                 = @EffectiveTime output
				,@ExpiryTime                    = @ExpiryTime output
				,@UserDefinedColumns            = @UserDefinedColumns output
				,@ComplaintContactXID           = @ComplaintContactXID output
				,@LegacyKey                     = @LegacyKey output
				,@CreateUser                    = @CreateUser
				,@IsReselected                  = @IsReselected
				,@zContext                      = @zContext
				,@ComplaintNo                   = @ComplaintNo
				,@RegistrantSID                 = @RegistrantSID
				,@ComplaintTypeSID              = @ComplaintTypeSID
				,@ComplainantTypeSID            = @ComplainantTypeSID
				,@ApplicationUserSID            = @ApplicationUserSID
				,@OpenedDate                    = @OpenedDate
				,@ConductStartDate              = @ConductStartDate
				,@ConductEndDate                = @ConductEndDate
				,@ComplaintSeveritySID          = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry   = @IsDisplayedOnPublicRegistry
				,@ClosedDate                    = @ClosedDate
				,@DismissedDate                 = @DismissedDate
				,@ReasonSID                     = @ReasonSID
				,@FileExtension                 = @FileExtension
				,@ComplaintRowGUID              = @ComplaintRowGUID
				,@ComplaintContactRoleSCD       = @ComplaintContactRoleSCD
				,@ComplaintContactRoleName      = @ComplaintContactRoleName
				,@ComplaintContactRoleIsDefault = @ComplaintContactRoleIsDefault
				,@ComplaintContactRoleRowGUID   = @ComplaintContactRoleRowGUID
				,@GenderSID                     = @GenderSID
				,@NamePrefixSID                 = @NamePrefixSID
				,@FirstName                     = @FirstName
				,@CommonName                    = @CommonName
				,@MiddleNames                   = @MiddleNames
				,@LastName                      = @LastName
				,@BirthDate                     = @BirthDate
				,@DeathDate                     = @DeathDate
				,@HomePhone                     = @HomePhone
				,@MobilePhone                   = @MobilePhone
				,@IsTextMessagingEnabled        = @IsTextMessagingEnabled
				,@ImportBatch                   = @ImportBatch
				,@PersonRowGUID                 = @PersonRowGUID
				,@IsActive                      = @IsActive
				,@IsPending                     = @IsPending
				,@IsDeleteEnabled               = @IsDeleteEnabled
		
		end

		-- insert the record

		insert
			dbo.ComplaintContact
		(
			 ComplaintSID
			,PersonSID
			,ComplaintContactRoleSID
			,EffectiveTime
			,ExpiryTime
			,UserDefinedColumns
			,ComplaintContactXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @ComplaintSID
			,@PersonSID
			,@ComplaintContactRoleSID
			,@EffectiveTime
			,@ExpiryTime
			,@UserDefinedColumns
			,@ComplaintContactXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected        = @@rowcount
			,@ComplaintContactSID = scope_identity()														-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.ComplaintContact'
				,@Arg3        = @rowsAffected
				,@Arg4        = @ComplaintContactSID
			
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
				r.RoutineName = 'pComplaintContact'
		)
		begin
		
			exec @errorNo = ext.pComplaintContact
				 @Mode                          = 'insert.post'
				,@ComplaintContactSID           = @ComplaintContactSID
				,@ComplaintSID                  = @ComplaintSID
				,@PersonSID                     = @PersonSID
				,@ComplaintContactRoleSID       = @ComplaintContactRoleSID
				,@EffectiveTime                 = @EffectiveTime
				,@ExpiryTime                    = @ExpiryTime
				,@UserDefinedColumns            = @UserDefinedColumns
				,@ComplaintContactXID           = @ComplaintContactXID
				,@LegacyKey                     = @LegacyKey
				,@CreateUser                    = @CreateUser
				,@IsReselected                  = @IsReselected
				,@zContext                      = @zContext
				,@ComplaintNo                   = @ComplaintNo
				,@RegistrantSID                 = @RegistrantSID
				,@ComplaintTypeSID              = @ComplaintTypeSID
				,@ComplainantTypeSID            = @ComplainantTypeSID
				,@ApplicationUserSID            = @ApplicationUserSID
				,@OpenedDate                    = @OpenedDate
				,@ConductStartDate              = @ConductStartDate
				,@ConductEndDate                = @ConductEndDate
				,@ComplaintSeveritySID          = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry   = @IsDisplayedOnPublicRegistry
				,@ClosedDate                    = @ClosedDate
				,@DismissedDate                 = @DismissedDate
				,@ReasonSID                     = @ReasonSID
				,@FileExtension                 = @FileExtension
				,@ComplaintRowGUID              = @ComplaintRowGUID
				,@ComplaintContactRoleSCD       = @ComplaintContactRoleSCD
				,@ComplaintContactRoleName      = @ComplaintContactRoleName
				,@ComplaintContactRoleIsDefault = @ComplaintContactRoleIsDefault
				,@ComplaintContactRoleRowGUID   = @ComplaintContactRoleRowGUID
				,@GenderSID                     = @GenderSID
				,@NamePrefixSID                 = @NamePrefixSID
				,@FirstName                     = @FirstName
				,@CommonName                    = @CommonName
				,@MiddleNames                   = @MiddleNames
				,@LastName                      = @LastName
				,@BirthDate                     = @BirthDate
				,@DeathDate                     = @DeathDate
				,@HomePhone                     = @HomePhone
				,@MobilePhone                   = @MobilePhone
				,@IsTextMessagingEnabled        = @IsTextMessagingEnabled
				,@ImportBatch                   = @ImportBatch
				,@PersonRowGUID                 = @PersonRowGUID
				,@IsActive                      = @IsActive
				,@IsPending                     = @IsPending
				,@IsDeleteEnabled               = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ComplaintContactSID
			from
				dbo.vComplaintContact ent
			where
				ent.ComplaintContactSID = @ComplaintContactSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ComplaintContactSID
				,ent.ComplaintSID
				,ent.PersonSID
				,ent.ComplaintContactRoleSID
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.UserDefinedColumns
				,ent.ComplaintContactXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ComplaintNo
				,ent.RegistrantSID
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
				,ent.ComplaintContactRoleSCD
				,ent.ComplaintContactRoleName
				,ent.ComplaintContactRoleIsDefault
				,ent.ComplaintContactRoleRowGUID
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
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vComplaintContact ent
			where
				ent.ComplaintContactSID = @ComplaintContactSID

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
