SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantIdentifier#Insert]
	 @RegistrantIdentifierSID        int               = null output				-- identity value assigned to the new record
	,@RegistrantSID                  int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@IdentifierValue                varchar(50)       = null								-- required! if not passed value must be set in custom logic prior to insert
	,@IdentifierTypeSID              int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveDate                  date              = null								
	,@ExpiryDate                     date              = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantIdentifierXID        varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@OrgSID                         int               = null								-- not a base table column (default ignored)
	,@IdentifierTypeLabel            nvarchar(35)      = null								-- not a base table column (default ignored)
	,@IdentifierTypeCategory         nvarchar(65)      = null								-- not a base table column (default ignored)
	,@IsOtherRegistration            bit               = null								-- not a base table column (default ignored)
	,@DisplayRank                    tinyint           = null								-- not a base table column (default ignored)
	,@EditMask                       varchar(50)       = null								-- not a base table column (default ignored)
	,@IdentifierCode                 varchar(15)       = null								-- not a base table column (default ignored)
	,@IdentifierTypeIsDefault        bit               = null								-- not a base table column (default ignored)
	,@IdentifierTypeRowGUID          uniqueidentifier  = null								-- not a base table column (default ignored)
	,@PersonSID                      int               = null								-- not a base table column (default ignored)
	,@RegistrantNo                   varchar(50)       = null								-- not a base table column (default ignored)
	,@YearOfInitialEmployment        smallint          = null								-- not a base table column (default ignored)
	,@IsOnPublicRegistry             bit               = null								-- not a base table column (default ignored)
	,@CityNameOfBirth                nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CountrySID                     int               = null								-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence    smallint          = null								-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours smallint          = null								-- not a base table column (default ignored)
	,@LateFeeExclusionYear           smallint          = null								-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked   bit               = null								-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime     datetime          = null								-- not a base table column (default ignored)
	,@ArchivedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@RegistrantRowGUID              uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantIdentifier#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantIdentifier table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantIdentifier table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantIdentifier entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantIdentifier procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantIdentifierCheck to test all rules.

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

	set @RegistrantIdentifierSID = null																			-- initialize output parameter

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

		set @IdentifierValue = ltrim(rtrim(@IdentifierValue))
		set @RegistrantIdentifierXID = ltrim(rtrim(@RegistrantIdentifierXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @IdentifierTypeLabel = ltrim(rtrim(@IdentifierTypeLabel))
		set @IdentifierTypeCategory = ltrim(rtrim(@IdentifierTypeCategory))
		set @EditMask = ltrim(rtrim(@EditMask))
		set @IdentifierCode = ltrim(rtrim(@IdentifierCode))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))

		-- set zero length strings to null to avoid storing them in the record

		if len(@IdentifierValue) = 0 set @IdentifierValue = null
		if len(@RegistrantIdentifierXID) = 0 set @RegistrantIdentifierXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@IdentifierTypeLabel) = 0 set @IdentifierTypeLabel = null
		if len(@IdentifierTypeCategory) = 0 set @IdentifierTypeCategory = null
		if len(@EditMask) = 0 set @EditMask = null
		if len(@IdentifierCode) = 0 set @IdentifierCode = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @IdentifierTypeSID  is null select @IdentifierTypeSID  = x.IdentifierTypeSID from dbo.IdentifierType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Cory Ng | Jan 2018
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

		-- Tim Edlund | Mar 2019
		-- If the identifier is a registration and an expiry
		-- is entered without an effective date, assume a
		-- 1 year term.

		if @IsOtherRegistration = @ON and @EffectiveDate is null and @ExpiryDate is not null
		begin
			set @EffectiveDate = dateadd(day, 1, dateadd(year, -1, @ExpiryDate));
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
				r.RoutineName = 'pRegistrantIdentifier'
		)
		begin
		
			exec @errorNo = ext.pRegistrantIdentifier
				 @Mode                           = 'insert.pre'
				,@RegistrantSID                  = @RegistrantSID output
				,@IdentifierValue                = @IdentifierValue output
				,@IdentifierTypeSID              = @IdentifierTypeSID output
				,@EffectiveDate                  = @EffectiveDate output
				,@ExpiryDate                     = @ExpiryDate output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantIdentifierXID        = @RegistrantIdentifierXID output
				,@LegacyKey                      = @LegacyKey output
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@OrgSID                         = @OrgSID
				,@IdentifierTypeLabel            = @IdentifierTypeLabel
				,@IdentifierTypeCategory         = @IdentifierTypeCategory
				,@IsOtherRegistration            = @IsOtherRegistration
				,@DisplayRank                    = @DisplayRank
				,@EditMask                       = @EditMask
				,@IdentifierCode                 = @IdentifierCode
				,@IdentifierTypeIsDefault        = @IdentifierTypeIsDefault
				,@IdentifierTypeRowGUID          = @IdentifierTypeRowGUID
				,@PersonSID                      = @PersonSID
				,@RegistrantNo                   = @RegistrantNo
				,@YearOfInitialEmployment        = @YearOfInitialEmployment
				,@IsOnPublicRegistry             = @IsOnPublicRegistry
				,@CityNameOfBirth                = @CityNameOfBirth
				,@CountrySID                     = @CountrySID
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear           = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
				,@ArchivedTime                   = @ArchivedTime
				,@RegistrantRowGUID              = @RegistrantRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
		
		end

		-- insert the record

		insert
			dbo.RegistrantIdentifier
		(
			 RegistrantSID
			,IdentifierValue
			,IdentifierTypeSID
			,EffectiveDate
			,ExpiryDate
			,UserDefinedColumns
			,RegistrantIdentifierXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantSID
			,@IdentifierValue
			,@IdentifierTypeSID
			,@EffectiveDate
			,@ExpiryDate
			,@UserDefinedColumns
			,@RegistrantIdentifierXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@RegistrantIdentifierSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantIdentifier'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantIdentifierSID
			
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
				r.RoutineName = 'pRegistrantIdentifier'
		)
		begin
		
			exec @errorNo = ext.pRegistrantIdentifier
				 @Mode                           = 'insert.post'
				,@RegistrantIdentifierSID        = @RegistrantIdentifierSID
				,@RegistrantSID                  = @RegistrantSID
				,@IdentifierValue                = @IdentifierValue
				,@IdentifierTypeSID              = @IdentifierTypeSID
				,@EffectiveDate                  = @EffectiveDate
				,@ExpiryDate                     = @ExpiryDate
				,@UserDefinedColumns             = @UserDefinedColumns
				,@RegistrantIdentifierXID        = @RegistrantIdentifierXID
				,@LegacyKey                      = @LegacyKey
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@OrgSID                         = @OrgSID
				,@IdentifierTypeLabel            = @IdentifierTypeLabel
				,@IdentifierTypeCategory         = @IdentifierTypeCategory
				,@IsOtherRegistration            = @IsOtherRegistration
				,@DisplayRank                    = @DisplayRank
				,@EditMask                       = @EditMask
				,@IdentifierCode                 = @IdentifierCode
				,@IdentifierTypeIsDefault        = @IdentifierTypeIsDefault
				,@IdentifierTypeRowGUID          = @IdentifierTypeRowGUID
				,@PersonSID                      = @PersonSID
				,@RegistrantNo                   = @RegistrantNo
				,@YearOfInitialEmployment        = @YearOfInitialEmployment
				,@IsOnPublicRegistry             = @IsOnPublicRegistry
				,@CityNameOfBirth                = @CityNameOfBirth
				,@CountrySID                     = @CountrySID
				,@DirectedAuditYearCompetence    = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear           = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked   = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime     = @RenewalExtensionExpiryTime
				,@ArchivedTime                   = @ArchivedTime
				,@RegistrantRowGUID              = @RegistrantRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantIdentifierSID
			from
				dbo.vRegistrantIdentifier ent
			where
				ent.RegistrantIdentifierSID = @RegistrantIdentifierSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantIdentifierSID
				,ent.RegistrantSID
				,ent.IdentifierValue
				,ent.IdentifierTypeSID
				,ent.EffectiveDate
				,ent.ExpiryDate
				,ent.UserDefinedColumns
				,ent.RegistrantIdentifierXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.OrgSID
				,ent.IdentifierTypeLabel
				,ent.IdentifierTypeCategory
				,ent.IsOtherRegistration
				,ent.DisplayRank
				,ent.EditMask
				,ent.IdentifierCode
				,ent.IdentifierTypeIsDefault
				,ent.IdentifierTypeRowGUID
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
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vRegistrantIdentifier ent
			where
				ent.RegistrantIdentifierSID = @RegistrantIdentifierSID

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
