SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pLearningPlanActivity#Insert]
	 @LearningPlanActivitySID        int               = null output				-- identity value assigned to the new record
	,@RegistrantLearningPlanSID      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@CompetenceTypeActivitySID      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@UnitValue                      decimal(5,2)      = null								-- default: (1.0)
	,@CarryOverUnitValue             decimal(5,2)      = null								-- default: (0.0)
	,@ActivityDate                   date              = null								
	,@LearningClaimTypeSID           int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@LearningPlanActivityCategory   nvarchar(65)      = null								
	,@ActivityDescription            nvarchar(max)     = null								
	,@PlannedCompletion              date              = null								
	,@OrgSID                         int               = null								
	,@IsSubjectToReview              bit               = null								-- default: CONVERT(bit,(0))
	,@IsArchived                     bit               = null								-- default: CONVERT(bit,(0))
	,@UserDefinedColumns             xml               = null								
	,@LearningPlanActivityXID        varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@CompetenceTypeSID              int               = null								-- not a base table column (default ignored)
	,@CompetenceActivitySID          int               = null								-- not a base table column (default ignored)
	,@EffectiveTime                  datetime          = null								-- not a base table column (default ignored)
	,@ExpiryTime                     datetime          = null								-- not a base table column (default ignored)
	,@CompetenceTypeActivityRowGUID  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@LearningClaimTypeLabel         nvarchar(35)      = null								-- not a base table column (default ignored)
	,@LearningClaimTypeCategory      nvarchar(65)      = null								-- not a base table column (default ignored)
	,@IsValidForRenewal              bit               = null								-- not a base table column (default ignored)
	,@IsComplete                     bit               = null								-- not a base table column (default ignored)
	,@IsWithdrawn                    bit               = null								-- not a base table column (default ignored)
	,@LearningClaimTypeIsDefault     bit               = null								-- not a base table column (default ignored)
	,@LearningClaimTypeIsActive      bit               = null								-- not a base table column (default ignored)
	,@LearningClaimTypeRowGUID       uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegistrantSID                  int               = null								-- not a base table column (default ignored)
	,@RegistrationYear               smallint          = null								-- not a base table column (default ignored)
	,@LearningModelSID               int               = null								-- not a base table column (default ignored)
	,@FormVersionSID                 int               = null								-- not a base table column (default ignored)
	,@LastValidateTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@NextFollowUp                   date              = null								-- not a base table column (default ignored)
	,@ReasonSID                      int               = null								-- not a base table column (default ignored)
	,@IsAutoApprovalEnabled          bit               = null								-- not a base table column (default ignored)
	,@ParentRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RegistrantLearningPlanRowGUID  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ParentOrgSID                   int               = null								-- not a base table column (default ignored)
	,@OrgTypeSID                     int               = null								-- not a base table column (default ignored)
	,@OrgName                        nvarchar(150)     = null								-- not a base table column (default ignored)
	,@OrgLabel                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@StreetAddress1                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress2                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@StreetAddress3                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@CitySID                        int               = null								-- not a base table column (default ignored)
	,@PostalCode                     varchar(10)       = null								-- not a base table column (default ignored)
	,@RegionSID                      int               = null								-- not a base table column (default ignored)
	,@Phone                          varchar(25)       = null								-- not a base table column (default ignored)
	,@Fax                            varchar(25)       = null								-- not a base table column (default ignored)
	,@WebSite                        varchar(250)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@InsuranceOrgSID                int               = null								-- not a base table column (default ignored)
	,@InsurancePolicyNo              varchar(25)       = null								-- not a base table column (default ignored)
	,@InsuranceAmount                decimal(11,2)     = null								-- not a base table column (default ignored)
	,@IsEmployer                     bit               = null								-- not a base table column (default ignored)
	,@IsCredentialAuthority          bit               = null								-- not a base table column (default ignored)
	,@IsInsurer                      bit               = null								-- not a base table column (default ignored)
	,@IsInsuranceCertificateRequired bit               = null								-- not a base table column (default ignored)
	,@IsPublic                       nchar(10)         = null								-- not a base table column (default ignored)
	,@OrgIsActive                    bit               = null								-- not a base table column (default ignored)
	,@IsAdminReviewRequired          bit               = null								-- not a base table column (default ignored)
	,@LastVerifiedTime               datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@OrgRowGUID                     uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pLearningPlanActivity#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.LearningPlanActivity table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.LearningPlanActivity table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vLearningPlanActivity entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pLearningPlanActivity procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fLearningPlanActivityCheck to test all rules.

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

	set @LearningPlanActivitySID = null																			-- initialize output parameter

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

		set @LearningPlanActivityCategory = ltrim(rtrim(@LearningPlanActivityCategory))
		set @ActivityDescription = ltrim(rtrim(@ActivityDescription))
		set @LearningPlanActivityXID = ltrim(rtrim(@LearningPlanActivityXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @LearningClaimTypeLabel = ltrim(rtrim(@LearningClaimTypeLabel))
		set @LearningClaimTypeCategory = ltrim(rtrim(@LearningClaimTypeCategory))
		set @OrgName = ltrim(rtrim(@OrgName))
		set @OrgLabel = ltrim(rtrim(@OrgLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @Phone = ltrim(rtrim(@Phone))
		set @Fax = ltrim(rtrim(@Fax))
		set @WebSite = ltrim(rtrim(@WebSite))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))

		-- set zero length strings to null to avoid storing them in the record

		if len(@LearningPlanActivityCategory) = 0 set @LearningPlanActivityCategory = null
		if len(@ActivityDescription) = 0 set @ActivityDescription = null
		if len(@LearningPlanActivityXID) = 0 set @LearningPlanActivityXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@LearningClaimTypeLabel) = 0 set @LearningClaimTypeLabel = null
		if len(@LearningClaimTypeCategory) = 0 set @LearningClaimTypeCategory = null
		if len(@OrgName) = 0 set @OrgName = null
		if len(@OrgLabel) = 0 set @OrgLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@Phone) = 0 set @Phone = null
		if len(@Fax) = 0 set @Fax = null
		if len(@WebSite) = 0 set @WebSite = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @UnitValue = isnull(@UnitValue,(1.0))
		set @CarryOverUnitValue = isnull(@CarryOverUnitValue,(0.0))
		set @IsSubjectToReview = isnull(@IsSubjectToReview,CONVERT(bit,(0)))
		set @IsArchived = isnull(@IsArchived,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                 = isnull(@IsReselected                ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @LearningClaimTypeSID  is null select @LearningClaimTypeSID  = x.LearningClaimTypeSID from dbo.LearningClaimType x where x.IsDefault = @ON

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
				r.RoutineName = 'pLearningPlanActivity'
		)
		begin
		
			exec @errorNo = ext.pLearningPlanActivity
				 @Mode                           = 'insert.pre'
				,@RegistrantLearningPlanSID      = @RegistrantLearningPlanSID output
				,@CompetenceTypeActivitySID      = @CompetenceTypeActivitySID output
				,@UnitValue                      = @UnitValue output
				,@CarryOverUnitValue             = @CarryOverUnitValue output
				,@ActivityDate                   = @ActivityDate output
				,@LearningClaimTypeSID           = @LearningClaimTypeSID output
				,@LearningPlanActivityCategory   = @LearningPlanActivityCategory output
				,@ActivityDescription            = @ActivityDescription output
				,@PlannedCompletion              = @PlannedCompletion output
				,@OrgSID                         = @OrgSID output
				,@IsSubjectToReview              = @IsSubjectToReview output
				,@IsArchived                     = @IsArchived output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@LearningPlanActivityXID        = @LearningPlanActivityXID output
				,@LegacyKey                      = @LegacyKey output
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@CompetenceTypeSID              = @CompetenceTypeSID
				,@CompetenceActivitySID          = @CompetenceActivitySID
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@CompetenceTypeActivityRowGUID  = @CompetenceTypeActivityRowGUID
				,@LearningClaimTypeLabel         = @LearningClaimTypeLabel
				,@LearningClaimTypeCategory      = @LearningClaimTypeCategory
				,@IsValidForRenewal              = @IsValidForRenewal
				,@IsComplete                     = @IsComplete
				,@IsWithdrawn                    = @IsWithdrawn
				,@LearningClaimTypeIsDefault     = @LearningClaimTypeIsDefault
				,@LearningClaimTypeIsActive      = @LearningClaimTypeIsActive
				,@LearningClaimTypeRowGUID       = @LearningClaimTypeRowGUID
				,@RegistrantSID                  = @RegistrantSID
				,@RegistrationYear               = @RegistrationYear
				,@LearningModelSID               = @LearningModelSID
				,@FormVersionSID                 = @FormVersionSID
				,@LastValidateTime               = @LastValidateTime
				,@NextFollowUp                   = @NextFollowUp
				,@ReasonSID                      = @ReasonSID
				,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
				,@ParentRowGUID                  = @ParentRowGUID
				,@RegistrantLearningPlanRowGUID  = @RegistrantLearningPlanRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@PostalCode                     = @PostalCode
				,@RegionSID                      = @RegionSID
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@OrgIsActive                    = @OrgIsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@LastVerifiedTime               = @LastVerifiedTime
				,@OrgRowGUID                     = @OrgRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
		
		end

		-- insert the record

		insert
			dbo.LearningPlanActivity
		(
			 RegistrantLearningPlanSID
			,CompetenceTypeActivitySID
			,UnitValue
			,CarryOverUnitValue
			,ActivityDate
			,LearningClaimTypeSID
			,LearningPlanActivityCategory
			,ActivityDescription
			,PlannedCompletion
			,OrgSID
			,IsSubjectToReview
			,IsArchived
			,UserDefinedColumns
			,LearningPlanActivityXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantLearningPlanSID
			,@CompetenceTypeActivitySID
			,@UnitValue
			,@CarryOverUnitValue
			,@ActivityDate
			,@LearningClaimTypeSID
			,@LearningPlanActivityCategory
			,@ActivityDescription
			,@PlannedCompletion
			,@OrgSID
			,@IsSubjectToReview
			,@IsArchived
			,@UserDefinedColumns
			,@LearningPlanActivityXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@LearningPlanActivitySID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.LearningPlanActivity'
				,@Arg3        = @rowsAffected
				,@Arg4        = @LearningPlanActivitySID
			
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
				r.RoutineName = 'pLearningPlanActivity'
		)
		begin
		
			exec @errorNo = ext.pLearningPlanActivity
				 @Mode                           = 'insert.post'
				,@LearningPlanActivitySID        = @LearningPlanActivitySID
				,@RegistrantLearningPlanSID      = @RegistrantLearningPlanSID
				,@CompetenceTypeActivitySID      = @CompetenceTypeActivitySID
				,@UnitValue                      = @UnitValue
				,@CarryOverUnitValue             = @CarryOverUnitValue
				,@ActivityDate                   = @ActivityDate
				,@LearningClaimTypeSID           = @LearningClaimTypeSID
				,@LearningPlanActivityCategory   = @LearningPlanActivityCategory
				,@ActivityDescription            = @ActivityDescription
				,@PlannedCompletion              = @PlannedCompletion
				,@OrgSID                         = @OrgSID
				,@IsSubjectToReview              = @IsSubjectToReview
				,@IsArchived                     = @IsArchived
				,@UserDefinedColumns             = @UserDefinedColumns
				,@LearningPlanActivityXID        = @LearningPlanActivityXID
				,@LegacyKey                      = @LegacyKey
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
				,@zContext                       = @zContext
				,@CompetenceTypeSID              = @CompetenceTypeSID
				,@CompetenceActivitySID          = @CompetenceActivitySID
				,@EffectiveTime                  = @EffectiveTime
				,@ExpiryTime                     = @ExpiryTime
				,@CompetenceTypeActivityRowGUID  = @CompetenceTypeActivityRowGUID
				,@LearningClaimTypeLabel         = @LearningClaimTypeLabel
				,@LearningClaimTypeCategory      = @LearningClaimTypeCategory
				,@IsValidForRenewal              = @IsValidForRenewal
				,@IsComplete                     = @IsComplete
				,@IsWithdrawn                    = @IsWithdrawn
				,@LearningClaimTypeIsDefault     = @LearningClaimTypeIsDefault
				,@LearningClaimTypeIsActive      = @LearningClaimTypeIsActive
				,@LearningClaimTypeRowGUID       = @LearningClaimTypeRowGUID
				,@RegistrantSID                  = @RegistrantSID
				,@RegistrationYear               = @RegistrationYear
				,@LearningModelSID               = @LearningModelSID
				,@FormVersionSID                 = @FormVersionSID
				,@LastValidateTime               = @LastValidateTime
				,@NextFollowUp                   = @NextFollowUp
				,@ReasonSID                      = @ReasonSID
				,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
				,@ParentRowGUID                  = @ParentRowGUID
				,@RegistrantLearningPlanRowGUID  = @RegistrantLearningPlanRowGUID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@PostalCode                     = @PostalCode
				,@RegionSID                      = @RegionSID
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@OrgIsActive                    = @OrgIsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@LastVerifiedTime               = @LastVerifiedTime
				,@OrgRowGUID                     = @OrgRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.LearningPlanActivitySID
			from
				dbo.vLearningPlanActivity ent
			where
				ent.LearningPlanActivitySID = @LearningPlanActivitySID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.LearningPlanActivitySID
				,ent.RegistrantLearningPlanSID
				,ent.CompetenceTypeActivitySID
				,ent.UnitValue
				,ent.CarryOverUnitValue
				,ent.ActivityDate
				,ent.LearningClaimTypeSID
				,ent.LearningPlanActivityCategory
				,ent.ActivityDescription
				,ent.PlannedCompletion
				,ent.OrgSID
				,ent.IsSubjectToReview
				,ent.IsArchived
				,ent.UserDefinedColumns
				,ent.LearningPlanActivityXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.CompetenceTypeSID
				,ent.CompetenceActivitySID
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.CompetenceTypeActivityRowGUID
				,ent.LearningClaimTypeLabel
				,ent.LearningClaimTypeCategory
				,ent.IsValidForRenewal
				,ent.IsComplete
				,ent.IsWithdrawn
				,ent.LearningClaimTypeIsDefault
				,ent.LearningClaimTypeIsActive
				,ent.LearningClaimTypeRowGUID
				,ent.RegistrantSID
				,ent.RegistrationYear
				,ent.LearningModelSID
				,ent.FormVersionSID
				,ent.LastValidateTime
				,ent.NextFollowUp
				,ent.ReasonSID
				,ent.IsAutoApprovalEnabled
				,ent.ParentRowGUID
				,ent.RegistrantLearningPlanRowGUID
				,ent.ParentOrgSID
				,ent.OrgTypeSID
				,ent.OrgName
				,ent.OrgLabel
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.Phone
				,ent.Fax
				,ent.WebSite
				,ent.EmailAddress
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.OrgIsActive
				,ent.IsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.OrgRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vLearningPlanActivity ent
			where
				ent.LearningPlanActivitySID = @LearningPlanActivitySID

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
