SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegisterCatalogItem#Insert]
	 @PracticeRegisterCatalogItemSID                   int               = null output								-- identity value assigned to the new record
	,@PracticeRegisterSID                              int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@CatalogItemSID                                   int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@IsAppliedOnApplication                           bit               = null												-- default: CONVERT(bit,(1))
	,@IsAppliedOnApplicationApproval                   bit               = null												-- default: CONVERT(bit,(0))
	,@IsAppliedOnRenewal                               bit               = null												-- default: CONVERT(bit,(0))
	,@IsAppliedOnReinstatement                         bit               = null												-- default: CONVERT(bit,(0))
	,@IsAppliedOnRegChange                             bit               = null												-- default: CONVERT(bit,(0))
	,@IsAppliedToPAPSubscribers                        bit               = null												-- default: (0)
	,@PracticeRegisterSectionSID                       int               = null												
	,@PracticeRegisterChangeSID                        int               = null												
	,@FeeSequence                                      smallint          = null												-- default: (10)
	,@EffectiveTime                                    datetime          = null												-- default: CONVERT(datetime,sf.fToday())
	,@ExpiryTime                                       datetime          = null												
	,@UserDefinedColumns                               xml               = null												
	,@PracticeRegisterCatalogItemXID                   varchar(150)      = null												
	,@LegacyKey                                        nvarchar(50)      = null												
	,@CreateUser                                       nvarchar(75)      = null												-- default: suser_sname()
	,@IsReselected                                     tinyint           = null												-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                         xml               = null												-- other values defining context for the insert (if any)
	,@CatalogItemLabel                                 nvarchar(35)      = null												-- not a base table column (default ignored)
	,@InvoiceItemDescription                           nvarchar(500)     = null												-- not a base table column (default ignored)
	,@IsLateFee                                        bit               = null												-- not a base table column (default ignored)
	,@ImageAlternateText                               nvarchar(50)      = null												-- not a base table column (default ignored)
	,@IsAvailableOnClientPortal                        bit               = null												-- not a base table column (default ignored)
	,@IsComplaintPenalty                               bit               = null												-- not a base table column (default ignored)
	,@GLAccountSID                                     int               = null												-- not a base table column (default ignored)
	,@IsTaxRate1Applied                                bit               = null												-- not a base table column (default ignored)
	,@IsTaxRate2Applied                                bit               = null												-- not a base table column (default ignored)
	,@IsTaxRate3Applied                                bit               = null												-- not a base table column (default ignored)
	,@IsTaxDeductible                                  bit               = null												-- not a base table column (default ignored)
	,@CatalogItemEffectiveTime                         datetime          = null												-- not a base table column (default ignored)
	,@CatalogItemExpiryTime                            datetime          = null												-- not a base table column (default ignored)
	,@FileTypeSCD                                      varchar(8)        = null												-- not a base table column (default ignored)
	,@FileTypeSID                                      int               = null												-- not a base table column (default ignored)
	,@CatalogItemRowGUID                               uniqueidentifier  = null												-- not a base table column (default ignored)
	,@PracticeRegisterTypeSID                          int               = null												-- not a base table column (default ignored)
	,@RegistrationScheduleSID                          int               = null												-- not a base table column (default ignored)
	,@PracticeRegisterName                             nvarchar(65)      = null												-- not a base table column (default ignored)
	,@PracticeRegisterLabel                            nvarchar(35)      = null												-- not a base table column (default ignored)
	,@IsActivePractice                                 bit               = null												-- not a base table column (default ignored)
	,@IsPublicRegistryEnabled                          bit               = null												-- not a base table column (default ignored)
	,@IsRenewalEnabled                                 bit               = null												-- not a base table column (default ignored)
	,@IsLearningPlanEnabled                            bit               = null												-- not a base table column (default ignored)
	,@IsNextCEFormAutoAdded                            bit               = null												-- not a base table column (default ignored)
	,@IsEligibleSupervisor                             bit               = null												-- not a base table column (default ignored)
	,@IsSupervisionRequired                            bit               = null												-- not a base table column (default ignored)
	,@IsEmploymentTerminated                           bit               = null												-- not a base table column (default ignored)
	,@IsGroupMembershipTerminated                      bit               = null												-- not a base table column (default ignored)
	,@TermPermitDays                                   int               = null												-- not a base table column (default ignored)
	,@RegisterRank                                     smallint          = null												-- not a base table column (default ignored)
	,@LearningModelSID                                 int               = null												-- not a base table column (default ignored)
	,@ReasonGroupSID                                   int               = null												-- not a base table column (default ignored)
	,@PracticeRegisterIsDefault                        bit               = null												-- not a base table column (default ignored)
	,@IsDefaultInactivePractice                        bit               = null												-- not a base table column (default ignored)
	,@PracticeRegisterIsActive                         bit               = null												-- not a base table column (default ignored)
	,@PracticeRegisterRowGUID                          uniqueidentifier  = null												-- not a base table column (default ignored)
	,@PracticeRegisterChangePracticeRegisterSID        int               = null												-- not a base table column (default ignored)
	,@PracticeRegisterChangePracticeRegisterSectionSID int               = null												-- not a base table column (default ignored)
	,@PracticeRegisterChangeIsActive                   bit               = null												-- not a base table column (default ignored)
	,@ToolTip                                          nvarchar(500)     = null												-- not a base table column (default ignored)
	,@IsEnabledForRegistrant                           bit               = null												-- not a base table column (default ignored)
	,@PracticeRegisterChangeRowGUID                    uniqueidentifier  = null												-- not a base table column (default ignored)
	,@PracticeRegisterSectionPracticeRegisterSID       int               = null												-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel                     nvarchar(35)      = null												-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDefault                 bit               = null												-- not a base table column (default ignored)
	,@IsDisplayedOnLicense                             bit               = null												-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsActive                  bit               = null												-- not a base table column (default ignored)
	,@PracticeRegisterSectionRowGUID                   uniqueidentifier  = null												-- not a base table column (default ignored)
	,@IsActive                                         bit               = null												-- not a base table column (default ignored)
	,@IsPending                                        bit               = null												-- not a base table column (default ignored)
	,@IsDeleteEnabled                                  bit               = null												-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegisterCatalogItem#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PracticeRegisterCatalogItem table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PracticeRegisterCatalogItem table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPracticeRegisterCatalogItem entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPracticeRegisterCatalogItem procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPracticeRegisterCatalogItemCheck to test all rules.

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

	set @PracticeRegisterCatalogItemSID = null															-- initialize output parameter

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

		set @PracticeRegisterCatalogItemXID = ltrim(rtrim(@PracticeRegisterCatalogItemXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @CatalogItemLabel = ltrim(rtrim(@CatalogItemLabel))
		set @InvoiceItemDescription = ltrim(rtrim(@InvoiceItemDescription))
		set @ImageAlternateText = ltrim(rtrim(@ImageAlternateText))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @PracticeRegisterName = ltrim(rtrim(@PracticeRegisterName))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@PracticeRegisterCatalogItemXID) = 0 set @PracticeRegisterCatalogItemXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@CatalogItemLabel) = 0 set @CatalogItemLabel = null
		if len(@InvoiceItemDescription) = 0 set @InvoiceItemDescription = null
		if len(@ImageAlternateText) = 0 set @ImageAlternateText = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsAppliedOnApplication = isnull(@IsAppliedOnApplication,CONVERT(bit,(1)))
		set @IsAppliedOnApplicationApproval = isnull(@IsAppliedOnApplicationApproval,CONVERT(bit,(0)))
		set @IsAppliedOnRenewal = isnull(@IsAppliedOnRenewal,CONVERT(bit,(0)))
		set @IsAppliedOnReinstatement = isnull(@IsAppliedOnReinstatement,CONVERT(bit,(0)))
		set @IsAppliedOnRegChange = isnull(@IsAppliedOnRegChange,CONVERT(bit,(0)))
		set @IsAppliedToPAPSubscribers = isnull(@IsAppliedToPAPSubscribers,(0))
		set @FeeSequence = isnull(@FeeSequence,(10))
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
				r.RoutineName = 'pPracticeRegisterCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterCatalogItem
				 @Mode                                             = 'insert.pre'
				,@PracticeRegisterSID                              = @PracticeRegisterSID output
				,@CatalogItemSID                                   = @CatalogItemSID output
				,@IsAppliedOnApplication                           = @IsAppliedOnApplication output
				,@IsAppliedOnApplicationApproval                   = @IsAppliedOnApplicationApproval output
				,@IsAppliedOnRenewal                               = @IsAppliedOnRenewal output
				,@IsAppliedOnReinstatement                         = @IsAppliedOnReinstatement output
				,@IsAppliedOnRegChange                             = @IsAppliedOnRegChange output
				,@IsAppliedToPAPSubscribers                        = @IsAppliedToPAPSubscribers output
				,@PracticeRegisterSectionSID                       = @PracticeRegisterSectionSID output
				,@PracticeRegisterChangeSID                        = @PracticeRegisterChangeSID output
				,@FeeSequence                                      = @FeeSequence output
				,@EffectiveTime                                    = @EffectiveTime output
				,@ExpiryTime                                       = @ExpiryTime output
				,@UserDefinedColumns                               = @UserDefinedColumns output
				,@PracticeRegisterCatalogItemXID                   = @PracticeRegisterCatalogItemXID output
				,@LegacyKey                                        = @LegacyKey output
				,@CreateUser                                       = @CreateUser
				,@IsReselected                                     = @IsReselected
				,@zContext                                         = @zContext
				,@CatalogItemLabel                                 = @CatalogItemLabel
				,@InvoiceItemDescription                           = @InvoiceItemDescription
				,@IsLateFee                                        = @IsLateFee
				,@ImageAlternateText                               = @ImageAlternateText
				,@IsAvailableOnClientPortal                        = @IsAvailableOnClientPortal
				,@IsComplaintPenalty                               = @IsComplaintPenalty
				,@GLAccountSID                                     = @GLAccountSID
				,@IsTaxRate1Applied                                = @IsTaxRate1Applied
				,@IsTaxRate2Applied                                = @IsTaxRate2Applied
				,@IsTaxRate3Applied                                = @IsTaxRate3Applied
				,@IsTaxDeductible                                  = @IsTaxDeductible
				,@CatalogItemEffectiveTime                         = @CatalogItemEffectiveTime
				,@CatalogItemExpiryTime                            = @CatalogItemExpiryTime
				,@FileTypeSCD                                      = @FileTypeSCD
				,@FileTypeSID                                      = @FileTypeSID
				,@CatalogItemRowGUID                               = @CatalogItemRowGUID
				,@PracticeRegisterTypeSID                          = @PracticeRegisterTypeSID
				,@RegistrationScheduleSID                          = @RegistrationScheduleSID
				,@PracticeRegisterName                             = @PracticeRegisterName
				,@PracticeRegisterLabel                            = @PracticeRegisterLabel
				,@IsActivePractice                                 = @IsActivePractice
				,@IsPublicRegistryEnabled                          = @IsPublicRegistryEnabled
				,@IsRenewalEnabled                                 = @IsRenewalEnabled
				,@IsLearningPlanEnabled                            = @IsLearningPlanEnabled
				,@IsNextCEFormAutoAdded                            = @IsNextCEFormAutoAdded
				,@IsEligibleSupervisor                             = @IsEligibleSupervisor
				,@IsSupervisionRequired                            = @IsSupervisionRequired
				,@IsEmploymentTerminated                           = @IsEmploymentTerminated
				,@IsGroupMembershipTerminated                      = @IsGroupMembershipTerminated
				,@TermPermitDays                                   = @TermPermitDays
				,@RegisterRank                                     = @RegisterRank
				,@LearningModelSID                                 = @LearningModelSID
				,@ReasonGroupSID                                   = @ReasonGroupSID
				,@PracticeRegisterIsDefault                        = @PracticeRegisterIsDefault
				,@IsDefaultInactivePractice                        = @IsDefaultInactivePractice
				,@PracticeRegisterIsActive                         = @PracticeRegisterIsActive
				,@PracticeRegisterRowGUID                          = @PracticeRegisterRowGUID
				,@PracticeRegisterChangePracticeRegisterSID        = @PracticeRegisterChangePracticeRegisterSID
				,@PracticeRegisterChangePracticeRegisterSectionSID = @PracticeRegisterChangePracticeRegisterSectionSID
				,@PracticeRegisterChangeIsActive                   = @PracticeRegisterChangeIsActive
				,@ToolTip                                          = @ToolTip
				,@IsEnabledForRegistrant                           = @IsEnabledForRegistrant
				,@PracticeRegisterChangeRowGUID                    = @PracticeRegisterChangeRowGUID
				,@PracticeRegisterSectionPracticeRegisterSID       = @PracticeRegisterSectionPracticeRegisterSID
				,@PracticeRegisterSectionLabel                     = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault                 = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                             = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive                  = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID                   = @PracticeRegisterSectionRowGUID
				,@IsActive                                         = @IsActive
				,@IsPending                                        = @IsPending
				,@IsDeleteEnabled                                  = @IsDeleteEnabled
		
		end

		-- insert the record

		insert
			dbo.PracticeRegisterCatalogItem
		(
			 PracticeRegisterSID
			,CatalogItemSID
			,IsAppliedOnApplication
			,IsAppliedOnApplicationApproval
			,IsAppliedOnRenewal
			,IsAppliedOnReinstatement
			,IsAppliedOnRegChange
			,IsAppliedToPAPSubscribers
			,PracticeRegisterSectionSID
			,PracticeRegisterChangeSID
			,FeeSequence
			,EffectiveTime
			,ExpiryTime
			,UserDefinedColumns
			,PracticeRegisterCatalogItemXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PracticeRegisterSID
			,@CatalogItemSID
			,@IsAppliedOnApplication
			,@IsAppliedOnApplicationApproval
			,@IsAppliedOnRenewal
			,@IsAppliedOnReinstatement
			,@IsAppliedOnRegChange
			,@IsAppliedToPAPSubscribers
			,@PracticeRegisterSectionSID
			,@PracticeRegisterChangeSID
			,@FeeSequence
			,@EffectiveTime
			,@ExpiryTime
			,@UserDefinedColumns
			,@PracticeRegisterCatalogItemXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected                   = @@rowcount
			,@PracticeRegisterCatalogItemSID = scope_identity()									-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PracticeRegisterCatalogItem'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PracticeRegisterCatalogItemSID
			
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
				r.RoutineName = 'pPracticeRegisterCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterCatalogItem
				 @Mode                                             = 'insert.post'
				,@PracticeRegisterCatalogItemSID                   = @PracticeRegisterCatalogItemSID
				,@PracticeRegisterSID                              = @PracticeRegisterSID
				,@CatalogItemSID                                   = @CatalogItemSID
				,@IsAppliedOnApplication                           = @IsAppliedOnApplication
				,@IsAppliedOnApplicationApproval                   = @IsAppliedOnApplicationApproval
				,@IsAppliedOnRenewal                               = @IsAppliedOnRenewal
				,@IsAppliedOnReinstatement                         = @IsAppliedOnReinstatement
				,@IsAppliedOnRegChange                             = @IsAppliedOnRegChange
				,@IsAppliedToPAPSubscribers                        = @IsAppliedToPAPSubscribers
				,@PracticeRegisterSectionSID                       = @PracticeRegisterSectionSID
				,@PracticeRegisterChangeSID                        = @PracticeRegisterChangeSID
				,@FeeSequence                                      = @FeeSequence
				,@EffectiveTime                                    = @EffectiveTime
				,@ExpiryTime                                       = @ExpiryTime
				,@UserDefinedColumns                               = @UserDefinedColumns
				,@PracticeRegisterCatalogItemXID                   = @PracticeRegisterCatalogItemXID
				,@LegacyKey                                        = @LegacyKey
				,@CreateUser                                       = @CreateUser
				,@IsReselected                                     = @IsReselected
				,@zContext                                         = @zContext
				,@CatalogItemLabel                                 = @CatalogItemLabel
				,@InvoiceItemDescription                           = @InvoiceItemDescription
				,@IsLateFee                                        = @IsLateFee
				,@ImageAlternateText                               = @ImageAlternateText
				,@IsAvailableOnClientPortal                        = @IsAvailableOnClientPortal
				,@IsComplaintPenalty                               = @IsComplaintPenalty
				,@GLAccountSID                                     = @GLAccountSID
				,@IsTaxRate1Applied                                = @IsTaxRate1Applied
				,@IsTaxRate2Applied                                = @IsTaxRate2Applied
				,@IsTaxRate3Applied                                = @IsTaxRate3Applied
				,@IsTaxDeductible                                  = @IsTaxDeductible
				,@CatalogItemEffectiveTime                         = @CatalogItemEffectiveTime
				,@CatalogItemExpiryTime                            = @CatalogItemExpiryTime
				,@FileTypeSCD                                      = @FileTypeSCD
				,@FileTypeSID                                      = @FileTypeSID
				,@CatalogItemRowGUID                               = @CatalogItemRowGUID
				,@PracticeRegisterTypeSID                          = @PracticeRegisterTypeSID
				,@RegistrationScheduleSID                          = @RegistrationScheduleSID
				,@PracticeRegisterName                             = @PracticeRegisterName
				,@PracticeRegisterLabel                            = @PracticeRegisterLabel
				,@IsActivePractice                                 = @IsActivePractice
				,@IsPublicRegistryEnabled                          = @IsPublicRegistryEnabled
				,@IsRenewalEnabled                                 = @IsRenewalEnabled
				,@IsLearningPlanEnabled                            = @IsLearningPlanEnabled
				,@IsNextCEFormAutoAdded                            = @IsNextCEFormAutoAdded
				,@IsEligibleSupervisor                             = @IsEligibleSupervisor
				,@IsSupervisionRequired                            = @IsSupervisionRequired
				,@IsEmploymentTerminated                           = @IsEmploymentTerminated
				,@IsGroupMembershipTerminated                      = @IsGroupMembershipTerminated
				,@TermPermitDays                                   = @TermPermitDays
				,@RegisterRank                                     = @RegisterRank
				,@LearningModelSID                                 = @LearningModelSID
				,@ReasonGroupSID                                   = @ReasonGroupSID
				,@PracticeRegisterIsDefault                        = @PracticeRegisterIsDefault
				,@IsDefaultInactivePractice                        = @IsDefaultInactivePractice
				,@PracticeRegisterIsActive                         = @PracticeRegisterIsActive
				,@PracticeRegisterRowGUID                          = @PracticeRegisterRowGUID
				,@PracticeRegisterChangePracticeRegisterSID        = @PracticeRegisterChangePracticeRegisterSID
				,@PracticeRegisterChangePracticeRegisterSectionSID = @PracticeRegisterChangePracticeRegisterSectionSID
				,@PracticeRegisterChangeIsActive                   = @PracticeRegisterChangeIsActive
				,@ToolTip                                          = @ToolTip
				,@IsEnabledForRegistrant                           = @IsEnabledForRegistrant
				,@PracticeRegisterChangeRowGUID                    = @PracticeRegisterChangeRowGUID
				,@PracticeRegisterSectionPracticeRegisterSID       = @PracticeRegisterSectionPracticeRegisterSID
				,@PracticeRegisterSectionLabel                     = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault                 = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                             = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive                  = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID                   = @PracticeRegisterSectionRowGUID
				,@IsActive                                         = @IsActive
				,@IsPending                                        = @IsPending
				,@IsDeleteEnabled                                  = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PracticeRegisterCatalogItemSID
			from
				dbo.vPracticeRegisterCatalogItem ent
			where
				ent.PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PracticeRegisterCatalogItemSID
				,ent.PracticeRegisterSID
				,ent.CatalogItemSID
				,ent.IsAppliedOnApplication
				,ent.IsAppliedOnApplicationApproval
				,ent.IsAppliedOnRenewal
				,ent.IsAppliedOnReinstatement
				,ent.IsAppliedOnRegChange
				,ent.IsAppliedToPAPSubscribers
				,ent.PracticeRegisterSectionSID
				,ent.PracticeRegisterChangeSID
				,ent.FeeSequence
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.UserDefinedColumns
				,ent.PracticeRegisterCatalogItemXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.CatalogItemLabel
				,ent.InvoiceItemDescription
				,ent.IsLateFee
				,ent.ImageAlternateText
				,ent.IsAvailableOnClientPortal
				,ent.IsComplaintPenalty
				,ent.GLAccountSID
				,ent.IsTaxRate1Applied
				,ent.IsTaxRate2Applied
				,ent.IsTaxRate3Applied
				,ent.IsTaxDeductible
				,ent.CatalogItemEffectiveTime
				,ent.CatalogItemExpiryTime
				,ent.FileTypeSCD
				,ent.FileTypeSID
				,ent.CatalogItemRowGUID
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
				,ent.IsSupervisionRequired
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
				,ent.PracticeRegisterChangePracticeRegisterSID
				,ent.PracticeRegisterChangePracticeRegisterSectionSID
				,ent.PracticeRegisterChangeIsActive
				,ent.ToolTip
				,ent.IsEnabledForRegistrant
				,ent.PracticeRegisterChangeRowGUID
				,ent.PracticeRegisterSectionPracticeRegisterSID
				,ent.PracticeRegisterSectionLabel
				,ent.PracticeRegisterSectionIsDefault
				,ent.IsDisplayedOnLicense
				,ent.PracticeRegisterSectionIsActive
				,ent.PracticeRegisterSectionRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vPracticeRegisterCatalogItem ent
			where
				ent.PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID

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
