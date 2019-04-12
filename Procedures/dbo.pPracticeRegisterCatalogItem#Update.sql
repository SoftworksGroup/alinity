SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegisterCatalogItem#Update]
	 @PracticeRegisterCatalogItemSID                   int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PracticeRegisterSID                              int               = null -- table column values to update:
	,@CatalogItemSID                                   int               = null
	,@IsAppliedOnApplication                           bit               = null
	,@IsAppliedOnApplicationApproval                   bit               = null
	,@IsAppliedOnRenewal                               bit               = null
	,@IsAppliedOnReinstatement                         bit               = null
	,@IsAppliedOnRegChange                             bit               = null
	,@IsAppliedToPAPSubscribers                        bit               = null
	,@PracticeRegisterSectionSID                       int               = null
	,@PracticeRegisterChangeSID                        int               = null
	,@FeeSequence                                      smallint          = null
	,@EffectiveTime                                    datetime          = null
	,@ExpiryTime                                       datetime          = null
	,@UserDefinedColumns                               xml               = null
	,@PracticeRegisterCatalogItemXID                   varchar(150)      = null
	,@LegacyKey                                        nvarchar(50)      = null
	,@UpdateUser                                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                         xml               = null -- other values defining context for the update (if any)
	,@CatalogItemLabel                                 nvarchar(35)      = null -- not a base table column
	,@InvoiceItemDescription                           nvarchar(500)     = null -- not a base table column
	,@IsLateFee                                        bit               = null -- not a base table column
	,@ImageAlternateText                               nvarchar(50)      = null -- not a base table column
	,@IsAvailableOnClientPortal                        bit               = null -- not a base table column
	,@IsComplaintPenalty                               bit               = null -- not a base table column
	,@GLAccountSID                                     int               = null -- not a base table column
	,@IsTaxRate1Applied                                bit               = null -- not a base table column
	,@IsTaxRate2Applied                                bit               = null -- not a base table column
	,@IsTaxRate3Applied                                bit               = null -- not a base table column
	,@IsTaxDeductible                                  bit               = null -- not a base table column
	,@CatalogItemEffectiveTime                         datetime          = null -- not a base table column
	,@CatalogItemExpiryTime                            datetime          = null -- not a base table column
	,@FileTypeSCD                                      varchar(8)        = null -- not a base table column
	,@FileTypeSID                                      int               = null -- not a base table column
	,@CatalogItemRowGUID                               uniqueidentifier  = null -- not a base table column
	,@PracticeRegisterTypeSID                          int               = null -- not a base table column
	,@RegistrationScheduleSID                          int               = null -- not a base table column
	,@PracticeRegisterName                             nvarchar(65)      = null -- not a base table column
	,@PracticeRegisterLabel                            nvarchar(35)      = null -- not a base table column
	,@IsActivePractice                                 bit               = null -- not a base table column
	,@IsPublicRegistryEnabled                          bit               = null -- not a base table column
	,@IsRenewalEnabled                                 bit               = null -- not a base table column
	,@IsLearningPlanEnabled                            bit               = null -- not a base table column
	,@IsNextCEFormAutoAdded                            bit               = null -- not a base table column
	,@IsEligibleSupervisor                             bit               = null -- not a base table column
	,@IsSupervisionRequired                            bit               = null -- not a base table column
	,@IsEmploymentTerminated                           bit               = null -- not a base table column
	,@IsGroupMembershipTerminated                      bit               = null -- not a base table column
	,@TermPermitDays                                   int               = null -- not a base table column
	,@RegisterRank                                     smallint          = null -- not a base table column
	,@LearningModelSID                                 int               = null -- not a base table column
	,@ReasonGroupSID                                   int               = null -- not a base table column
	,@PracticeRegisterIsDefault                        bit               = null -- not a base table column
	,@IsDefaultInactivePractice                        bit               = null -- not a base table column
	,@PracticeRegisterIsActive                         bit               = null -- not a base table column
	,@PracticeRegisterRowGUID                          uniqueidentifier  = null -- not a base table column
	,@PracticeRegisterChangePracticeRegisterSID        int               = null -- not a base table column
	,@PracticeRegisterChangePracticeRegisterSectionSID int               = null -- not a base table column
	,@PracticeRegisterChangeIsActive                   bit               = null -- not a base table column
	,@ToolTip                                          nvarchar(500)     = null -- not a base table column
	,@IsEnabledForRegistrant                           bit               = null -- not a base table column
	,@PracticeRegisterChangeRowGUID                    uniqueidentifier  = null -- not a base table column
	,@PracticeRegisterSectionPracticeRegisterSID       int               = null -- not a base table column
	,@PracticeRegisterSectionLabel                     nvarchar(35)      = null -- not a base table column
	,@PracticeRegisterSectionIsDefault                 bit               = null -- not a base table column
	,@IsDisplayedOnLicense                             bit               = null -- not a base table column
	,@PracticeRegisterSectionIsActive                  bit               = null -- not a base table column
	,@PracticeRegisterSectionRowGUID                   uniqueidentifier  = null -- not a base table column
	,@IsActive                                         bit               = null -- not a base table column
	,@IsPending                                        bit               = null -- not a base table column
	,@IsDeleteEnabled                                  bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegisterCatalogItem#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PracticeRegisterCatalogItem table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PracticeRegisterCatalogItem table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPracticeRegisterCatalogItem entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPracticeRegisterCatalogItem procedure. The extended procedure is only called
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

		if @PracticeRegisterCatalogItemSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PracticeRegisterCatalogItemSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @PracticeRegisterCatalogItemXID = ltrim(rtrim(@PracticeRegisterCatalogItemXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@CatalogItemLabel) = 0 set @CatalogItemLabel = null
		if len(@InvoiceItemDescription) = 0 set @InvoiceItemDescription = null
		if len(@ImageAlternateText) = 0 set @ImageAlternateText = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@PracticeRegisterName) = 0 set @PracticeRegisterName = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PracticeRegisterSID                              = isnull(@PracticeRegisterSID,prci.PracticeRegisterSID)
				,@CatalogItemSID                                   = isnull(@CatalogItemSID,prci.CatalogItemSID)
				,@IsAppliedOnApplication                           = isnull(@IsAppliedOnApplication,prci.IsAppliedOnApplication)
				,@IsAppliedOnApplicationApproval                   = isnull(@IsAppliedOnApplicationApproval,prci.IsAppliedOnApplicationApproval)
				,@IsAppliedOnRenewal                               = isnull(@IsAppliedOnRenewal,prci.IsAppliedOnRenewal)
				,@IsAppliedOnReinstatement                         = isnull(@IsAppliedOnReinstatement,prci.IsAppliedOnReinstatement)
				,@IsAppliedOnRegChange                             = isnull(@IsAppliedOnRegChange,prci.IsAppliedOnRegChange)
				,@IsAppliedToPAPSubscribers                        = isnull(@IsAppliedToPAPSubscribers,prci.IsAppliedToPAPSubscribers)
				,@PracticeRegisterSectionSID                       = isnull(@PracticeRegisterSectionSID,prci.PracticeRegisterSectionSID)
				,@PracticeRegisterChangeSID                        = isnull(@PracticeRegisterChangeSID,prci.PracticeRegisterChangeSID)
				,@FeeSequence                                      = isnull(@FeeSequence,prci.FeeSequence)
				,@EffectiveTime                                    = isnull(@EffectiveTime,prci.EffectiveTime)
				,@ExpiryTime                                       = isnull(@ExpiryTime,prci.ExpiryTime)
				,@UserDefinedColumns                               = isnull(@UserDefinedColumns,prci.UserDefinedColumns)
				,@PracticeRegisterCatalogItemXID                   = isnull(@PracticeRegisterCatalogItemXID,prci.PracticeRegisterCatalogItemXID)
				,@LegacyKey                                        = isnull(@LegacyKey,prci.LegacyKey)
				,@UpdateUser                                       = isnull(@UpdateUser,prci.UpdateUser)
				,@IsReselected                                     = isnull(@IsReselected,prci.IsReselected)
				,@IsNullApplied                                    = isnull(@IsNullApplied,prci.IsNullApplied)
				,@zContext                                         = isnull(@zContext,prci.zContext)
				,@CatalogItemLabel                                 = isnull(@CatalogItemLabel,prci.CatalogItemLabel)
				,@InvoiceItemDescription                           = isnull(@InvoiceItemDescription,prci.InvoiceItemDescription)
				,@IsLateFee                                        = isnull(@IsLateFee,prci.IsLateFee)
				,@ImageAlternateText                               = isnull(@ImageAlternateText,prci.ImageAlternateText)
				,@IsAvailableOnClientPortal                        = isnull(@IsAvailableOnClientPortal,prci.IsAvailableOnClientPortal)
				,@IsComplaintPenalty                               = isnull(@IsComplaintPenalty,prci.IsComplaintPenalty)
				,@GLAccountSID                                     = isnull(@GLAccountSID,prci.GLAccountSID)
				,@IsTaxRate1Applied                                = isnull(@IsTaxRate1Applied,prci.IsTaxRate1Applied)
				,@IsTaxRate2Applied                                = isnull(@IsTaxRate2Applied,prci.IsTaxRate2Applied)
				,@IsTaxRate3Applied                                = isnull(@IsTaxRate3Applied,prci.IsTaxRate3Applied)
				,@IsTaxDeductible                                  = isnull(@IsTaxDeductible,prci.IsTaxDeductible)
				,@CatalogItemEffectiveTime                         = isnull(@CatalogItemEffectiveTime,prci.CatalogItemEffectiveTime)
				,@CatalogItemExpiryTime                            = isnull(@CatalogItemExpiryTime,prci.CatalogItemExpiryTime)
				,@FileTypeSCD                                      = isnull(@FileTypeSCD,prci.FileTypeSCD)
				,@FileTypeSID                                      = isnull(@FileTypeSID,prci.FileTypeSID)
				,@CatalogItemRowGUID                               = isnull(@CatalogItemRowGUID,prci.CatalogItemRowGUID)
				,@PracticeRegisterTypeSID                          = isnull(@PracticeRegisterTypeSID,prci.PracticeRegisterTypeSID)
				,@RegistrationScheduleSID                          = isnull(@RegistrationScheduleSID,prci.RegistrationScheduleSID)
				,@PracticeRegisterName                             = isnull(@PracticeRegisterName,prci.PracticeRegisterName)
				,@PracticeRegisterLabel                            = isnull(@PracticeRegisterLabel,prci.PracticeRegisterLabel)
				,@IsActivePractice                                 = isnull(@IsActivePractice,prci.IsActivePractice)
				,@IsPublicRegistryEnabled                          = isnull(@IsPublicRegistryEnabled,prci.IsPublicRegistryEnabled)
				,@IsRenewalEnabled                                 = isnull(@IsRenewalEnabled,prci.IsRenewalEnabled)
				,@IsLearningPlanEnabled                            = isnull(@IsLearningPlanEnabled,prci.IsLearningPlanEnabled)
				,@IsNextCEFormAutoAdded                            = isnull(@IsNextCEFormAutoAdded,prci.IsNextCEFormAutoAdded)
				,@IsEligibleSupervisor                             = isnull(@IsEligibleSupervisor,prci.IsEligibleSupervisor)
				,@IsSupervisionRequired                            = isnull(@IsSupervisionRequired,prci.IsSupervisionRequired)
				,@IsEmploymentTerminated                           = isnull(@IsEmploymentTerminated,prci.IsEmploymentTerminated)
				,@IsGroupMembershipTerminated                      = isnull(@IsGroupMembershipTerminated,prci.IsGroupMembershipTerminated)
				,@TermPermitDays                                   = isnull(@TermPermitDays,prci.TermPermitDays)
				,@RegisterRank                                     = isnull(@RegisterRank,prci.RegisterRank)
				,@LearningModelSID                                 = isnull(@LearningModelSID,prci.LearningModelSID)
				,@ReasonGroupSID                                   = isnull(@ReasonGroupSID,prci.ReasonGroupSID)
				,@PracticeRegisterIsDefault                        = isnull(@PracticeRegisterIsDefault,prci.PracticeRegisterIsDefault)
				,@IsDefaultInactivePractice                        = isnull(@IsDefaultInactivePractice,prci.IsDefaultInactivePractice)
				,@PracticeRegisterIsActive                         = isnull(@PracticeRegisterIsActive,prci.PracticeRegisterIsActive)
				,@PracticeRegisterRowGUID                          = isnull(@PracticeRegisterRowGUID,prci.PracticeRegisterRowGUID)
				,@PracticeRegisterChangePracticeRegisterSID        = isnull(@PracticeRegisterChangePracticeRegisterSID,prci.PracticeRegisterChangePracticeRegisterSID)
				,@PracticeRegisterChangePracticeRegisterSectionSID = isnull(@PracticeRegisterChangePracticeRegisterSectionSID,prci.PracticeRegisterChangePracticeRegisterSectionSID)
				,@PracticeRegisterChangeIsActive                   = isnull(@PracticeRegisterChangeIsActive,prci.PracticeRegisterChangeIsActive)
				,@ToolTip                                          = isnull(@ToolTip,prci.ToolTip)
				,@IsEnabledForRegistrant                           = isnull(@IsEnabledForRegistrant,prci.IsEnabledForRegistrant)
				,@PracticeRegisterChangeRowGUID                    = isnull(@PracticeRegisterChangeRowGUID,prci.PracticeRegisterChangeRowGUID)
				,@PracticeRegisterSectionPracticeRegisterSID       = isnull(@PracticeRegisterSectionPracticeRegisterSID,prci.PracticeRegisterSectionPracticeRegisterSID)
				,@PracticeRegisterSectionLabel                     = isnull(@PracticeRegisterSectionLabel,prci.PracticeRegisterSectionLabel)
				,@PracticeRegisterSectionIsDefault                 = isnull(@PracticeRegisterSectionIsDefault,prci.PracticeRegisterSectionIsDefault)
				,@IsDisplayedOnLicense                             = isnull(@IsDisplayedOnLicense,prci.IsDisplayedOnLicense)
				,@PracticeRegisterSectionIsActive                  = isnull(@PracticeRegisterSectionIsActive,prci.PracticeRegisterSectionIsActive)
				,@PracticeRegisterSectionRowGUID                   = isnull(@PracticeRegisterSectionRowGUID,prci.PracticeRegisterSectionRowGUID)
				,@IsActive                                         = isnull(@IsActive,prci.IsActive)
				,@IsPending                                        = isnull(@IsPending,prci.IsPending)
				,@IsDeleteEnabled                                  = isnull(@IsDeleteEnabled,prci.IsDeleteEnabled)
			from
				dbo.vPracticeRegisterCatalogItem prci
			where
				prci.PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID

		end
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRegisterChangeSID from dbo.PracticeRegisterCatalogItem x where x.PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID) <> @PracticeRegisterChangeSID
			begin
			
				if (select x.IsActive from dbo.PracticeRegisterChange x where x.PracticeRegisterChangeSID = @PracticeRegisterChangeSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice register change'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRegisterSectionSID from dbo.PracticeRegisterCatalogItem x where x.PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID) <> @PracticeRegisterSectionSID
			begin
			
				if (select x.IsActive from dbo.PracticeRegisterSection x where x.PracticeRegisterSectionSID = @PracticeRegisterSectionSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice register section'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PracticeRegisterSID from dbo.PracticeRegisterCatalogItem x where x.PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID) <> @PracticeRegisterSID
			begin
			
				if (select x.IsActive from dbo.PracticeRegister x where x.PracticeRegisterSID = @PracticeRegisterSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'practice register'
					
					raiserror(@errorText, 16, 1)
					
				end
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
				r.RoutineName = 'pPracticeRegisterCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterCatalogItem
				 @Mode                                             = 'update.pre'
				,@PracticeRegisterCatalogItemSID                   = @PracticeRegisterCatalogItemSID
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
				,@UpdateUser                                       = @UpdateUser
				,@RowStamp                                         = @RowStamp
				,@IsReselected                                     = @IsReselected
				,@IsNullApplied                                    = @IsNullApplied
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

		-- update the record

		update
			dbo.PracticeRegisterCatalogItem
		set
			 PracticeRegisterSID = @PracticeRegisterSID
			,CatalogItemSID = @CatalogItemSID
			,IsAppliedOnApplication = @IsAppliedOnApplication
			,IsAppliedOnApplicationApproval = @IsAppliedOnApplicationApproval
			,IsAppliedOnRenewal = @IsAppliedOnRenewal
			,IsAppliedOnReinstatement = @IsAppliedOnReinstatement
			,IsAppliedOnRegChange = @IsAppliedOnRegChange
			,IsAppliedToPAPSubscribers = @IsAppliedToPAPSubscribers
			,PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			,PracticeRegisterChangeSID = @PracticeRegisterChangeSID
			,FeeSequence = @FeeSequence
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,UserDefinedColumns = @UserDefinedColumns
			,PracticeRegisterCatalogItemXID = @PracticeRegisterCatalogItemXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PracticeRegisterCatalogItemSID = @PracticeRegisterCatalogItemSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PracticeRegisterCatalogItem where PracticeRegisterCatalogItemSID = @practiceRegisterCatalogItemSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PracticeRegisterCatalogItem'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PracticeRegisterCatalogItem'
					,@Arg2        = @practiceRegisterCatalogItemSID
				
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
				,@Arg2        = 'dbo.PracticeRegisterCatalogItem'
				,@Arg3        = @rowsAffected
				,@Arg4        = @practiceRegisterCatalogItemSID
			
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
				r.RoutineName = 'pPracticeRegisterCatalogItem'
		)
		begin
		
			exec @errorNo = ext.pPracticeRegisterCatalogItem
				 @Mode                                             = 'update.post'
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
				,@UpdateUser                                       = @UpdateUser
				,@RowStamp                                         = @RowStamp
				,@IsReselected                                     = @IsReselected
				,@IsNullApplied                                    = @IsNullApplied
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
