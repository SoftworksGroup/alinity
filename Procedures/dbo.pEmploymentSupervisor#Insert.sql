SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pEmploymentSupervisor#Insert]
	 @EmploymentSupervisorSID           int               = null output			-- identity value assigned to the new record
	,@RegistrantEmploymentSID           int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@PersonSID                         int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@ExpiryTime                        datetime          = null						
	,@UserDefinedColumns                xml               = null						
	,@EmploymentSupervisorXID           varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@RegistrantSID                     int               = null						-- not a base table column (default ignored)
	,@OrgSID                            int               = null						-- not a base table column (default ignored)
	,@RegistrationYear                  smallint          = null						-- not a base table column (default ignored)
	,@EmploymentTypeSID                 int               = null						-- not a base table column (default ignored)
	,@EmploymentRoleSID                 int               = null						-- not a base table column (default ignored)
	,@PracticeHours                     int               = null						-- not a base table column (default ignored)
	,@PracticeScopeSID                  int               = null						-- not a base table column (default ignored)
	,@AgeRangeSID                       int               = null						-- not a base table column (default ignored)
	,@IsOnPublicRegistry                bit               = null						-- not a base table column (default ignored)
	,@Phone                             varchar(25)       = null						-- not a base table column (default ignored)
	,@SiteLocation                      nvarchar(50)      = null						-- not a base table column (default ignored)
	,@EffectiveTime                     datetime          = null						-- not a base table column (default ignored)
	,@RegistrantEmploymentExpiryTime    datetime          = null						-- not a base table column (default ignored)
	,@Rank                              smallint          = null						-- not a base table column (default ignored)
	,@OwnershipPercentage               smallint          = null						-- not a base table column (default ignored)
	,@IsEmployerInsurance               bit               = null						-- not a base table column (default ignored)
	,@InsuranceOrgSID                   int               = null						-- not a base table column (default ignored)
	,@InsurancePolicyNo                 varchar(25)       = null						-- not a base table column (default ignored)
	,@InsuranceAmount                   decimal(11,2)     = null						-- not a base table column (default ignored)
	,@RegistrantEmploymentRowGUID       uniqueidentifier  = null						-- not a base table column (default ignored)
	,@GenderSID                         int               = null						-- not a base table column (default ignored)
	,@NamePrefixSID                     int               = null						-- not a base table column (default ignored)
	,@FirstName                         nvarchar(30)      = null						-- not a base table column (default ignored)
	,@CommonName                        nvarchar(30)      = null						-- not a base table column (default ignored)
	,@MiddleNames                       nvarchar(30)      = null						-- not a base table column (default ignored)
	,@LastName                          nvarchar(35)      = null						-- not a base table column (default ignored)
	,@BirthDate                         date              = null						-- not a base table column (default ignored)
	,@DeathDate                         date              = null						-- not a base table column (default ignored)
	,@HomePhone                         varchar(25)       = null						-- not a base table column (default ignored)
	,@MobilePhone                       varchar(25)       = null						-- not a base table column (default ignored)
	,@IsTextMessagingEnabled            bit               = null						-- not a base table column (default ignored)
	,@ImportBatch                       nvarchar(100)     = null						-- not a base table column (default ignored)
	,@PersonRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@SupervisorRegistrantLabel         nvarchar(75)      = null						-- not a base table column (default ignored)
	,@IsAgreementValid                  bit               = null						-- not a base table column (default ignored)
	,@AgreementStatusLabel              nvarchar(30)      = null						-- not a base table column (default ignored)
	,@SupervisorRegistrantSID           int               = null						-- not a base table column (default ignored)
	,@SupervisorRegistrantEmploymentSID int               = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pEmploymentSupervisor#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.EmploymentSupervisor table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.EmploymentSupervisor table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vEmploymentSupervisor entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pEmploymentSupervisor procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fEmploymentSupervisorCheck to test all rules.

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

	set @EmploymentSupervisorSID = null																			-- initialize output parameter

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

		set @EmploymentSupervisorXID = ltrim(rtrim(@EmploymentSupervisorXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @Phone = ltrim(rtrim(@Phone))
		set @SiteLocation = ltrim(rtrim(@SiteLocation))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @SupervisorRegistrantLabel = ltrim(rtrim(@SupervisorRegistrantLabel))
		set @AgreementStatusLabel = ltrim(rtrim(@AgreementStatusLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@EmploymentSupervisorXID) = 0 set @EmploymentSupervisorXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@Phone) = 0 set @Phone = null
		if len(@SiteLocation) = 0 set @SiteLocation = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@SupervisorRegistrantLabel) = 0 set @SupervisorRegistrantLabel = null
		if len(@AgreementStatusLabel) = 0 set @AgreementStatusLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))

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
				r.RoutineName = 'pEmploymentSupervisor'
		)
		begin
		
			exec @errorNo = ext.pEmploymentSupervisor
				 @Mode                              = 'insert.pre'
				,@RegistrantEmploymentSID           = @RegistrantEmploymentSID output
				,@PersonSID                         = @PersonSID output
				,@ExpiryTime                        = @ExpiryTime output
				,@UserDefinedColumns                = @UserDefinedColumns output
				,@EmploymentSupervisorXID           = @EmploymentSupervisorXID output
				,@LegacyKey                         = @LegacyKey output
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
				,@zContext                          = @zContext
				,@RegistrantSID                     = @RegistrantSID
				,@OrgSID                            = @OrgSID
				,@RegistrationYear                  = @RegistrationYear
				,@EmploymentTypeSID                 = @EmploymentTypeSID
				,@EmploymentRoleSID                 = @EmploymentRoleSID
				,@PracticeHours                     = @PracticeHours
				,@PracticeScopeSID                  = @PracticeScopeSID
				,@AgeRangeSID                       = @AgeRangeSID
				,@IsOnPublicRegistry                = @IsOnPublicRegistry
				,@Phone                             = @Phone
				,@SiteLocation                      = @SiteLocation
				,@EffectiveTime                     = @EffectiveTime
				,@RegistrantEmploymentExpiryTime    = @RegistrantEmploymentExpiryTime
				,@Rank                              = @Rank
				,@OwnershipPercentage               = @OwnershipPercentage
				,@IsEmployerInsurance               = @IsEmployerInsurance
				,@InsuranceOrgSID                   = @InsuranceOrgSID
				,@InsurancePolicyNo                 = @InsurancePolicyNo
				,@InsuranceAmount                   = @InsuranceAmount
				,@RegistrantEmploymentRowGUID       = @RegistrantEmploymentRowGUID
				,@GenderSID                         = @GenderSID
				,@NamePrefixSID                     = @NamePrefixSID
				,@FirstName                         = @FirstName
				,@CommonName                        = @CommonName
				,@MiddleNames                       = @MiddleNames
				,@LastName                          = @LastName
				,@BirthDate                         = @BirthDate
				,@DeathDate                         = @DeathDate
				,@HomePhone                         = @HomePhone
				,@MobilePhone                       = @MobilePhone
				,@IsTextMessagingEnabled            = @IsTextMessagingEnabled
				,@ImportBatch                       = @ImportBatch
				,@PersonRowGUID                     = @PersonRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@SupervisorRegistrantLabel         = @SupervisorRegistrantLabel
				,@IsAgreementValid                  = @IsAgreementValid
				,@AgreementStatusLabel              = @AgreementStatusLabel
				,@SupervisorRegistrantSID           = @SupervisorRegistrantSID
				,@SupervisorRegistrantEmploymentSID = @SupervisorRegistrantEmploymentSID
		
		end

		-- insert the record

		insert
			dbo.EmploymentSupervisor
		(
			 RegistrantEmploymentSID
			,PersonSID
			,ExpiryTime
			,UserDefinedColumns
			,EmploymentSupervisorXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantEmploymentSID
			,@PersonSID
			,@ExpiryTime
			,@UserDefinedColumns
			,@EmploymentSupervisorXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@EmploymentSupervisorSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.EmploymentSupervisor'
				,@Arg3        = @rowsAffected
				,@Arg4        = @EmploymentSupervisorSID
			
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
				r.RoutineName = 'pEmploymentSupervisor'
		)
		begin
		
			exec @errorNo = ext.pEmploymentSupervisor
				 @Mode                              = 'insert.post'
				,@EmploymentSupervisorSID           = @EmploymentSupervisorSID
				,@RegistrantEmploymentSID           = @RegistrantEmploymentSID
				,@PersonSID                         = @PersonSID
				,@ExpiryTime                        = @ExpiryTime
				,@UserDefinedColumns                = @UserDefinedColumns
				,@EmploymentSupervisorXID           = @EmploymentSupervisorXID
				,@LegacyKey                         = @LegacyKey
				,@CreateUser                        = @CreateUser
				,@IsReselected                      = @IsReselected
				,@zContext                          = @zContext
				,@RegistrantSID                     = @RegistrantSID
				,@OrgSID                            = @OrgSID
				,@RegistrationYear                  = @RegistrationYear
				,@EmploymentTypeSID                 = @EmploymentTypeSID
				,@EmploymentRoleSID                 = @EmploymentRoleSID
				,@PracticeHours                     = @PracticeHours
				,@PracticeScopeSID                  = @PracticeScopeSID
				,@AgeRangeSID                       = @AgeRangeSID
				,@IsOnPublicRegistry                = @IsOnPublicRegistry
				,@Phone                             = @Phone
				,@SiteLocation                      = @SiteLocation
				,@EffectiveTime                     = @EffectiveTime
				,@RegistrantEmploymentExpiryTime    = @RegistrantEmploymentExpiryTime
				,@Rank                              = @Rank
				,@OwnershipPercentage               = @OwnershipPercentage
				,@IsEmployerInsurance               = @IsEmployerInsurance
				,@InsuranceOrgSID                   = @InsuranceOrgSID
				,@InsurancePolicyNo                 = @InsurancePolicyNo
				,@InsuranceAmount                   = @InsuranceAmount
				,@RegistrantEmploymentRowGUID       = @RegistrantEmploymentRowGUID
				,@GenderSID                         = @GenderSID
				,@NamePrefixSID                     = @NamePrefixSID
				,@FirstName                         = @FirstName
				,@CommonName                        = @CommonName
				,@MiddleNames                       = @MiddleNames
				,@LastName                          = @LastName
				,@BirthDate                         = @BirthDate
				,@DeathDate                         = @DeathDate
				,@HomePhone                         = @HomePhone
				,@MobilePhone                       = @MobilePhone
				,@IsTextMessagingEnabled            = @IsTextMessagingEnabled
				,@ImportBatch                       = @ImportBatch
				,@PersonRowGUID                     = @PersonRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@SupervisorRegistrantLabel         = @SupervisorRegistrantLabel
				,@IsAgreementValid                  = @IsAgreementValid
				,@AgreementStatusLabel              = @AgreementStatusLabel
				,@SupervisorRegistrantSID           = @SupervisorRegistrantSID
				,@SupervisorRegistrantEmploymentSID = @SupervisorRegistrantEmploymentSID
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.EmploymentSupervisorSID
			from
				dbo.vEmploymentSupervisor ent
			where
				ent.EmploymentSupervisorSID = @EmploymentSupervisorSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.EmploymentSupervisorSID
				,ent.RegistrantEmploymentSID
				,ent.PersonSID
				,ent.ExpiryTime
				,ent.UserDefinedColumns
				,ent.EmploymentSupervisorXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrantSID
				,ent.OrgSID
				,ent.RegistrationYear
				,ent.EmploymentTypeSID
				,ent.EmploymentRoleSID
				,ent.PracticeHours
				,ent.PracticeScopeSID
				,ent.AgeRangeSID
				,ent.IsOnPublicRegistry
				,ent.Phone
				,ent.SiteLocation
				,ent.EffectiveTime
				,ent.RegistrantEmploymentExpiryTime
				,ent.Rank
				,ent.OwnershipPercentage
				,ent.IsEmployerInsurance
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.RegistrantEmploymentRowGUID
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
				,ent.SupervisorRegistrantLabel
				,ent.IsAgreementValid
				,ent.AgreementStatusLabel
				,ent.SupervisorRegistrantSID
				,ent.SupervisorRegistrantEmploymentSID
			from
				dbo.vEmploymentSupervisor ent
			where
				ent.EmploymentSupervisorSID = @EmploymentSupervisorSID

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
