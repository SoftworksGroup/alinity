SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonEmailAddress#Insert]
	 @PersonEmailAddressSID  int               = null output								-- identity value assigned to the new record
	,@PersonSID              int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@EmailAddress           varchar(150)      = null												-- required! if not passed value must be set in custom logic prior to insert
	,@IsPrimary              bit               = null												-- default: (1)
	,@IsActive               bit               = null												-- default: (1)
	,@ChangeAudit            nvarchar(max)     = null												-- default: 'Activated by '+suser_sname()
	,@UserDefinedColumns     xml               = null												
	,@PersonEmailAddressXID  varchar(150)      = null												
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
	,@ChangeReason           nvarchar(4000)    = null												-- not a base table column (default ignored)
	,@IsDeleteEnabled        bit               = null												-- not a base table column (default ignored)
	,@IsEmailUsedForLogin    bit               = null												-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonEmailAddress#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.PersonEmailAddress table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.PersonEmailAddress table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonEmailAddress entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonEmailAddress procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonEmailAddressCheck to test all rules.

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

	set @PersonEmailAddressSID = null																				-- initialize output parameter

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

		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @PersonEmailAddressXID = ltrim(rtrim(@PersonEmailAddressXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ChangeReason = ltrim(rtrim(@ChangeReason))

		-- set zero length strings to null to avoid storing them in the record

		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@ChangeAudit) = 0 set @ChangeAudit = null
		if len(@PersonEmailAddressXID) = 0 set @PersonEmailAddressXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ChangeReason) = 0 set @ChangeReason = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsPrimary = isnull(@IsPrimary,(1))
		set @IsActive = isnull(@IsActive,(1))
		set @ChangeAudit = isnull(@ChangeAudit,'Activated by '+suser_sname())
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected          = isnull(@IsReselected         ,(0))
		
		-- call a function to format the comment for the auditing column
		
		set @ChangeAudit = sf.fChangeAudit#Active(@IsActive, @ChangeReason, null)
		
		-- unset previous primary if record is being inserted as the new primary
		
		if @IsPrimary = @ON
		begin
		
			select @recordSID = x.PersonEmailAddressSID from sf.PersonEmailAddress x where x.IsPrimary = @ON and x.PersonSID = @PersonSID
			
			if @recordSID is not null
			begin
			
				update
					sf.PersonEmailAddress
				set
					 IsPrimary  = @OFF
					,UpdateUser = @CreateUser
					,UpdateTime = sysdatetimeoffset()
				where
					PersonEmailAddressSID = @recordSID															-- unique index ensures only 1 record needs to be unset
				
			end
		end

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Apr 2015
		-- Avoid letting error on duplicate email to be raised
		-- by unique key - handle with message more appropriate
		-- for end-users.

		if exists(select 1 from sf.PersonEmailAddress pea where pea.EmailAddress = @EmailAddress)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'DuplicateEmailAddress'
				,@MessageText = @errorText output
				,@DefaultText = N'The email address "%1" is already assigned to another person.'
				,@Arg1        = @EmailAddress
			
			raiserror(@errorText, 16, 1)

		end

		-- Tim Edlund | July 2018
		-- Mark this record as primary if no other record for the person
		-- is currently marked primary.

		if @IsPrimary = @OFF
		begin

			if not exists(select 1 from sf.PersonEmailAddress pea where pea.PersonSID = @PersonSID and @IsPrimary = @ON)
			begin
				set @IsPrimary = @ON
			end

		end
		--! </PreInsert>

		-- insert the record

		insert
			sf.PersonEmailAddress
		(
			 PersonSID
			,EmailAddress
			,IsPrimary
			,IsActive
			,ChangeAudit
			,UserDefinedColumns
			,PersonEmailAddressXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@EmailAddress
			,@IsPrimary
			,@IsActive
			,@ChangeAudit
			,@UserDefinedColumns
			,@PersonEmailAddressXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected          = @@rowcount
			,@PersonEmailAddressSID = scope_identity()													-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.PersonEmailAddress'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonEmailAddressSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PersonEmailAddressSID
			from
				sf.vPersonEmailAddress ent
			where
				ent.PersonEmailAddressSID = @PersonEmailAddressSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonEmailAddressSID
				,ent.PersonSID
				,ent.EmailAddress
				,ent.IsPrimary
				,ent.IsActive
				,ent.ChangeAudit
				,ent.UserDefinedColumns
				,ent.PersonEmailAddressXID
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
				,ent.ChangeReason
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsEmailUsedForLogin
			from
				sf.vPersonEmailAddress ent
			where
				ent.PersonEmailAddressSID = @PersonEmailAddressSID

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
