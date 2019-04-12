SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pEmploymentSupervisor#Update]
	 @EmploymentSupervisorSID           int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantEmploymentSID           int               = null -- table column values to update:
	,@PersonSID                         int               = null
	,@ExpiryTime                        datetime          = null
	,@UserDefinedColumns                xml               = null
	,@EmploymentSupervisorXID           varchar(150)      = null
	,@LegacyKey                         nvarchar(50)      = null
	,@UpdateUser                        nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                          timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                      tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                     bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                          xml               = null -- other values defining context for the update (if any)
	,@RegistrantSID                     int               = null -- not a base table column
	,@OrgSID                            int               = null -- not a base table column
	,@RegistrationYear                  smallint          = null -- not a base table column
	,@EmploymentTypeSID                 int               = null -- not a base table column
	,@EmploymentRoleSID                 int               = null -- not a base table column
	,@PracticeHours                     int               = null -- not a base table column
	,@PracticeScopeSID                  int               = null -- not a base table column
	,@AgeRangeSID                       int               = null -- not a base table column
	,@IsOnPublicRegistry                bit               = null -- not a base table column
	,@Phone                             varchar(25)       = null -- not a base table column
	,@SiteLocation                      nvarchar(50)      = null -- not a base table column
	,@EffectiveTime                     datetime          = null -- not a base table column
	,@RegistrantEmploymentExpiryTime    datetime          = null -- not a base table column
	,@Rank                              smallint          = null -- not a base table column
	,@OwnershipPercentage               smallint          = null -- not a base table column
	,@IsEmployerInsurance               bit               = null -- not a base table column
	,@InsuranceOrgSID                   int               = null -- not a base table column
	,@InsurancePolicyNo                 varchar(25)       = null -- not a base table column
	,@InsuranceAmount                   decimal(11,2)     = null -- not a base table column
	,@RegistrantEmploymentRowGUID       uniqueidentifier  = null -- not a base table column
	,@GenderSID                         int               = null -- not a base table column
	,@NamePrefixSID                     int               = null -- not a base table column
	,@FirstName                         nvarchar(30)      = null -- not a base table column
	,@CommonName                        nvarchar(30)      = null -- not a base table column
	,@MiddleNames                       nvarchar(30)      = null -- not a base table column
	,@LastName                          nvarchar(35)      = null -- not a base table column
	,@BirthDate                         date              = null -- not a base table column
	,@DeathDate                         date              = null -- not a base table column
	,@HomePhone                         varchar(25)       = null -- not a base table column
	,@MobilePhone                       varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled            bit               = null -- not a base table column
	,@ImportBatch                       nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                     uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                   bit               = null -- not a base table column
	,@SupervisorRegistrantLabel         nvarchar(75)      = null -- not a base table column
	,@IsAgreementValid                  bit               = null -- not a base table column
	,@AgreementStatusLabel              nvarchar(30)      = null -- not a base table column
	,@SupervisorRegistrantSID           int               = null -- not a base table column
	,@SupervisorRegistrantEmploymentSID int               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pEmploymentSupervisor#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.EmploymentSupervisor table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.EmploymentSupervisor table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vEmploymentSupervisor entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pEmploymentSupervisor procedure. The extended procedure is only called
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

		if @EmploymentSupervisorSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@EmploymentSupervisorSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @EmploymentSupervisorXID = ltrim(rtrim(@EmploymentSupervisorXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantEmploymentSID           = isnull(@RegistrantEmploymentSID,es.RegistrantEmploymentSID)
				,@PersonSID                         = isnull(@PersonSID,es.PersonSID)
				,@ExpiryTime                        = isnull(@ExpiryTime,es.ExpiryTime)
				,@UserDefinedColumns                = isnull(@UserDefinedColumns,es.UserDefinedColumns)
				,@EmploymentSupervisorXID           = isnull(@EmploymentSupervisorXID,es.EmploymentSupervisorXID)
				,@LegacyKey                         = isnull(@LegacyKey,es.LegacyKey)
				,@UpdateUser                        = isnull(@UpdateUser,es.UpdateUser)
				,@IsReselected                      = isnull(@IsReselected,es.IsReselected)
				,@IsNullApplied                     = isnull(@IsNullApplied,es.IsNullApplied)
				,@zContext                          = isnull(@zContext,es.zContext)
				,@RegistrantSID                     = isnull(@RegistrantSID,es.RegistrantSID)
				,@OrgSID                            = isnull(@OrgSID,es.OrgSID)
				,@RegistrationYear                  = isnull(@RegistrationYear,es.RegistrationYear)
				,@EmploymentTypeSID                 = isnull(@EmploymentTypeSID,es.EmploymentTypeSID)
				,@EmploymentRoleSID                 = isnull(@EmploymentRoleSID,es.EmploymentRoleSID)
				,@PracticeHours                     = isnull(@PracticeHours,es.PracticeHours)
				,@PracticeScopeSID                  = isnull(@PracticeScopeSID,es.PracticeScopeSID)
				,@AgeRangeSID                       = isnull(@AgeRangeSID,es.AgeRangeSID)
				,@IsOnPublicRegistry                = isnull(@IsOnPublicRegistry,es.IsOnPublicRegistry)
				,@Phone                             = isnull(@Phone,es.Phone)
				,@SiteLocation                      = isnull(@SiteLocation,es.SiteLocation)
				,@EffectiveTime                     = isnull(@EffectiveTime,es.EffectiveTime)
				,@RegistrantEmploymentExpiryTime    = isnull(@RegistrantEmploymentExpiryTime,es.RegistrantEmploymentExpiryTime)
				,@Rank                              = isnull(@Rank,es.Rank)
				,@OwnershipPercentage               = isnull(@OwnershipPercentage,es.OwnershipPercentage)
				,@IsEmployerInsurance               = isnull(@IsEmployerInsurance,es.IsEmployerInsurance)
				,@InsuranceOrgSID                   = isnull(@InsuranceOrgSID,es.InsuranceOrgSID)
				,@InsurancePolicyNo                 = isnull(@InsurancePolicyNo,es.InsurancePolicyNo)
				,@InsuranceAmount                   = isnull(@InsuranceAmount,es.InsuranceAmount)
				,@RegistrantEmploymentRowGUID       = isnull(@RegistrantEmploymentRowGUID,es.RegistrantEmploymentRowGUID)
				,@GenderSID                         = isnull(@GenderSID,es.GenderSID)
				,@NamePrefixSID                     = isnull(@NamePrefixSID,es.NamePrefixSID)
				,@FirstName                         = isnull(@FirstName,es.FirstName)
				,@CommonName                        = isnull(@CommonName,es.CommonName)
				,@MiddleNames                       = isnull(@MiddleNames,es.MiddleNames)
				,@LastName                          = isnull(@LastName,es.LastName)
				,@BirthDate                         = isnull(@BirthDate,es.BirthDate)
				,@DeathDate                         = isnull(@DeathDate,es.DeathDate)
				,@HomePhone                         = isnull(@HomePhone,es.HomePhone)
				,@MobilePhone                       = isnull(@MobilePhone,es.MobilePhone)
				,@IsTextMessagingEnabled            = isnull(@IsTextMessagingEnabled,es.IsTextMessagingEnabled)
				,@ImportBatch                       = isnull(@ImportBatch,es.ImportBatch)
				,@PersonRowGUID                     = isnull(@PersonRowGUID,es.PersonRowGUID)
				,@IsDeleteEnabled                   = isnull(@IsDeleteEnabled,es.IsDeleteEnabled)
				,@SupervisorRegistrantLabel         = isnull(@SupervisorRegistrantLabel,es.SupervisorRegistrantLabel)
				,@IsAgreementValid                  = isnull(@IsAgreementValid,es.IsAgreementValid)
				,@AgreementStatusLabel              = isnull(@AgreementStatusLabel,es.AgreementStatusLabel)
				,@SupervisorRegistrantSID           = isnull(@SupervisorRegistrantSID,es.SupervisorRegistrantSID)
				,@SupervisorRegistrantEmploymentSID = isnull(@SupervisorRegistrantEmploymentSID,es.SupervisorRegistrantEmploymentSID)
			from
				dbo.vEmploymentSupervisor es
			where
				es.EmploymentSupervisorSID = @EmploymentSupervisorSID

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
				r.RoutineName = 'pEmploymentSupervisor'
		)
		begin
		
			exec @errorNo = ext.pEmploymentSupervisor
				 @Mode                              = 'update.pre'
				,@EmploymentSupervisorSID           = @EmploymentSupervisorSID
				,@RegistrantEmploymentSID           = @RegistrantEmploymentSID output
				,@PersonSID                         = @PersonSID output
				,@ExpiryTime                        = @ExpiryTime output
				,@UserDefinedColumns                = @UserDefinedColumns output
				,@EmploymentSupervisorXID           = @EmploymentSupervisorXID output
				,@LegacyKey                         = @LegacyKey output
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
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

		-- update the record

		update
			dbo.EmploymentSupervisor
		set
			 RegistrantEmploymentSID = @RegistrantEmploymentSID
			,PersonSID = @PersonSID
			,ExpiryTime = @ExpiryTime
			,UserDefinedColumns = @UserDefinedColumns
			,EmploymentSupervisorXID = @EmploymentSupervisorXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			EmploymentSupervisorSID = @EmploymentSupervisorSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.EmploymentSupervisor where EmploymentSupervisorSID = @employmentSupervisorSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.EmploymentSupervisor'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.EmploymentSupervisor'
					,@Arg2        = @employmentSupervisorSID
				
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
				,@Arg2        = 'dbo.EmploymentSupervisor'
				,@Arg3        = @rowsAffected
				,@Arg4        = @employmentSupervisorSID
			
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
				r.RoutineName = 'pEmploymentSupervisor'
		)
		begin
		
			exec @errorNo = ext.pEmploymentSupervisor
				 @Mode                              = 'update.post'
				,@EmploymentSupervisorSID           = @EmploymentSupervisorSID
				,@RegistrantEmploymentSID           = @RegistrantEmploymentSID
				,@PersonSID                         = @PersonSID
				,@ExpiryTime                        = @ExpiryTime
				,@UserDefinedColumns                = @UserDefinedColumns
				,@EmploymentSupervisorXID           = @EmploymentSupervisorXID
				,@LegacyKey                         = @LegacyKey
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@IsReselected                      = @IsReselected
				,@IsNullApplied                     = @IsNullApplied
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
