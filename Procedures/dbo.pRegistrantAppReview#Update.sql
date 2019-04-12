SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAppReview#Update]
	 @RegistrantAppReviewSID         int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrantAppSID               int               = null -- table column values to update:
	,@FormVersionSID                 int               = null
	,@PersonSID                      int               = null
	,@ReasonSID                      int               = null
	,@RecommendationSID              int               = null
	,@FormResponseDraft              xml               = null
	,@LastValidateTime               datetimeoffset(7) = null
	,@ReviewerComments               xml               = null
	,@ConfirmationDraft              nvarchar(max)     = null
	,@UserDefinedColumns             xml               = null
	,@RegistrantAppReviewXID         varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@RegistrationSID                int               = null -- not a base table column
	,@PracticeRegisterSectionSID     int               = null -- not a base table column
	,@RegistrationYear               smallint          = null -- not a base table column
	,@RegistrantAppFormVersionSID    int               = null -- not a base table column
	,@OrgSID                         int               = null -- not a base table column
	,@RegistrantAppLastValidateTime  datetimeoffset(7) = null -- not a base table column
	,@NextFollowUp                   date              = null -- not a base table column
	,@RegistrationEffective          date              = null -- not a base table column
	,@IsAutoApprovalEnabled          bit               = null -- not a base table column
	,@RegistrantAppReasonSID         int               = null -- not a base table column
	,@InvoiceSID                     int               = null -- not a base table column
	,@RegistrantAppRowGUID           uniqueidentifier  = null -- not a base table column
	,@FormSID                        int               = null -- not a base table column
	,@VersionNo                      smallint          = null -- not a base table column
	,@RevisionNo                     smallint          = null -- not a base table column
	,@IsSaveDisplayed                bit               = null -- not a base table column
	,@ApprovedTime                   datetimeoffset(7) = null -- not a base table column
	,@FormVersionRowGUID             uniqueidentifier  = null -- not a base table column
	,@GenderSID                      int               = null -- not a base table column
	,@NamePrefixSID                  int               = null -- not a base table column
	,@FirstName                      nvarchar(30)      = null -- not a base table column
	,@CommonName                     nvarchar(30)      = null -- not a base table column
	,@MiddleNames                    nvarchar(30)      = null -- not a base table column
	,@LastName                       nvarchar(35)      = null -- not a base table column
	,@BirthDate                      date              = null -- not a base table column
	,@DeathDate                      date              = null -- not a base table column
	,@HomePhone                      varchar(25)       = null -- not a base table column
	,@MobilePhone                    varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled         bit               = null -- not a base table column
	,@ImportBatch                    nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                 int               = null -- not a base table column
	,@ReasonName                     nvarchar(50)      = null -- not a base table column
	,@ReasonCode                     varchar(25)       = null -- not a base table column
	,@ReasonSequence                 smallint          = null -- not a base table column
	,@ReasonToolTip                  nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                 bit               = null -- not a base table column
	,@ReasonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@RecommendationGroupSID         int               = null -- not a base table column
	,@ButtonLabel                    nvarchar(20)      = null -- not a base table column
	,@RecommendationSequence         smallint          = null -- not a base table column
	,@RecommendationToolTip          nvarchar(500)     = null -- not a base table column
	,@RecommendationIsActive         bit               = null -- not a base table column
	,@RecommendationRowGUID          uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@ReviewerInitials               nchar(2)          = null -- not a base table column
	,@RegistrantLabel                nvarchar(75)      = null -- not a base table column
	,@RegistrantPersonSID            int               = null -- not a base table column
	,@IsViewEnabled                  bit               = null -- not a base table column
	,@IsEditEnabled                  bit               = null -- not a base table column
	,@IsSaveBtnDisplayed             bit               = null -- not a base table column
	,@IsUnlockEnabled                bit               = null -- not a base table column
	,@IsInProgress                   bit               = null -- not a base table column
	,@RegistrantAppReviewStatusSID   int               = null -- not a base table column
	,@RegistrantAppReviewStatusSCD   varchar(25)       = null -- not a base table column
	,@RegistrantAppReviewStatusLabel nvarchar(35)      = null -- not a base table column
	,@LastStatusChangeUser           nvarchar(75)      = null -- not a base table column
	,@LastStatusChangeTime           datetimeoffset(7) = null -- not a base table column
	,@FormOwnerSCD                   varchar(25)       = null -- not a base table column
	,@FormOwnerLabel                 nvarchar(35)      = null -- not a base table column
	,@FormOwnerSID                   int               = null -- not a base table column
	,@NewFormStatusSCD               varchar(25)       = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAppReview#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrantAppReview table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrantAppReview table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantAppReview entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantAppReview procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantAppReviewCheck to test all rules.

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

		if @RegistrantAppReviewSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantAppReviewSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @RegistrantAppReviewXID = ltrim(rtrim(@RegistrantAppReviewXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ReasonToolTip = ltrim(rtrim(@ReasonToolTip))
		set @ButtonLabel = ltrim(rtrim(@ButtonLabel))
		set @RecommendationToolTip = ltrim(rtrim(@RecommendationToolTip))
		set @ReviewerInitials = ltrim(rtrim(@ReviewerInitials))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))
		set @RegistrantAppReviewStatusSCD = ltrim(rtrim(@RegistrantAppReviewStatusSCD))
		set @RegistrantAppReviewStatusLabel = ltrim(rtrim(@RegistrantAppReviewStatusLabel))
		set @LastStatusChangeUser = ltrim(rtrim(@LastStatusChangeUser))
		set @FormOwnerSCD = ltrim(rtrim(@FormOwnerSCD))
		set @FormOwnerLabel = ltrim(rtrim(@FormOwnerLabel))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@RegistrantAppReviewXID) = 0 set @RegistrantAppReviewXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ReasonToolTip) = 0 set @ReasonToolTip = null
		if len(@ButtonLabel) = 0 set @ButtonLabel = null
		if len(@RecommendationToolTip) = 0 set @RecommendationToolTip = null
		if len(@ReviewerInitials) = 0 set @ReviewerInitials = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null
		if len(@RegistrantAppReviewStatusSCD) = 0 set @RegistrantAppReviewStatusSCD = null
		if len(@RegistrantAppReviewStatusLabel) = 0 set @RegistrantAppReviewStatusLabel = null
		if len(@LastStatusChangeUser) = 0 set @LastStatusChangeUser = null
		if len(@FormOwnerSCD) = 0 set @FormOwnerSCD = null
		if len(@FormOwnerLabel) = 0 set @FormOwnerLabel = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrantAppSID               = isnull(@RegistrantAppSID,rar.RegistrantAppSID)
				,@FormVersionSID                 = isnull(@FormVersionSID,rar.FormVersionSID)
				,@PersonSID                      = isnull(@PersonSID,rar.PersonSID)
				,@ReasonSID                      = isnull(@ReasonSID,rar.ReasonSID)
				,@RecommendationSID              = isnull(@RecommendationSID,rar.RecommendationSID)
				,@FormResponseDraft              = isnull(@FormResponseDraft,rar.FormResponseDraft)
				,@LastValidateTime               = isnull(@LastValidateTime,rar.LastValidateTime)
				,@ReviewerComments               = isnull(@ReviewerComments,rar.ReviewerComments)
				,@ConfirmationDraft              = isnull(@ConfirmationDraft,rar.ConfirmationDraft)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,rar.UserDefinedColumns)
				,@RegistrantAppReviewXID         = isnull(@RegistrantAppReviewXID,rar.RegistrantAppReviewXID)
				,@LegacyKey                      = isnull(@LegacyKey,rar.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,rar.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,rar.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,rar.IsNullApplied)
				,@zContext                       = isnull(@zContext,rar.zContext)
				,@RegistrationSID                = isnull(@RegistrationSID,rar.RegistrationSID)
				,@PracticeRegisterSectionSID     = isnull(@PracticeRegisterSectionSID,rar.PracticeRegisterSectionSID)
				,@RegistrationYear               = isnull(@RegistrationYear,rar.RegistrationYear)
				,@RegistrantAppFormVersionSID    = isnull(@RegistrantAppFormVersionSID,rar.RegistrantAppFormVersionSID)
				,@OrgSID                         = isnull(@OrgSID,rar.OrgSID)
				,@RegistrantAppLastValidateTime  = isnull(@RegistrantAppLastValidateTime,rar.RegistrantAppLastValidateTime)
				,@NextFollowUp                   = isnull(@NextFollowUp,rar.NextFollowUp)
				,@RegistrationEffective          = isnull(@RegistrationEffective,rar.RegistrationEffective)
				,@IsAutoApprovalEnabled          = isnull(@IsAutoApprovalEnabled,rar.IsAutoApprovalEnabled)
				,@RegistrantAppReasonSID         = isnull(@RegistrantAppReasonSID,rar.RegistrantAppReasonSID)
				,@InvoiceSID                     = isnull(@InvoiceSID,rar.InvoiceSID)
				,@RegistrantAppRowGUID           = isnull(@RegistrantAppRowGUID,rar.RegistrantAppRowGUID)
				,@FormSID                        = isnull(@FormSID,rar.FormSID)
				,@VersionNo                      = isnull(@VersionNo,rar.VersionNo)
				,@RevisionNo                     = isnull(@RevisionNo,rar.RevisionNo)
				,@IsSaveDisplayed                = isnull(@IsSaveDisplayed,rar.IsSaveDisplayed)
				,@ApprovedTime                   = isnull(@ApprovedTime,rar.ApprovedTime)
				,@FormVersionRowGUID             = isnull(@FormVersionRowGUID,rar.FormVersionRowGUID)
				,@GenderSID                      = isnull(@GenderSID,rar.GenderSID)
				,@NamePrefixSID                  = isnull(@NamePrefixSID,rar.NamePrefixSID)
				,@FirstName                      = isnull(@FirstName,rar.FirstName)
				,@CommonName                     = isnull(@CommonName,rar.CommonName)
				,@MiddleNames                    = isnull(@MiddleNames,rar.MiddleNames)
				,@LastName                       = isnull(@LastName,rar.LastName)
				,@BirthDate                      = isnull(@BirthDate,rar.BirthDate)
				,@DeathDate                      = isnull(@DeathDate,rar.DeathDate)
				,@HomePhone                      = isnull(@HomePhone,rar.HomePhone)
				,@MobilePhone                    = isnull(@MobilePhone,rar.MobilePhone)
				,@IsTextMessagingEnabled         = isnull(@IsTextMessagingEnabled,rar.IsTextMessagingEnabled)
				,@ImportBatch                    = isnull(@ImportBatch,rar.ImportBatch)
				,@PersonRowGUID                  = isnull(@PersonRowGUID,rar.PersonRowGUID)
				,@ReasonGroupSID                 = isnull(@ReasonGroupSID,rar.ReasonGroupSID)
				,@ReasonName                     = isnull(@ReasonName,rar.ReasonName)
				,@ReasonCode                     = isnull(@ReasonCode,rar.ReasonCode)
				,@ReasonSequence                 = isnull(@ReasonSequence,rar.ReasonSequence)
				,@ReasonToolTip                  = isnull(@ReasonToolTip,rar.ReasonToolTip)
				,@ReasonIsActive                 = isnull(@ReasonIsActive,rar.ReasonIsActive)
				,@ReasonRowGUID                  = isnull(@ReasonRowGUID,rar.ReasonRowGUID)
				,@RecommendationGroupSID         = isnull(@RecommendationGroupSID,rar.RecommendationGroupSID)
				,@ButtonLabel                    = isnull(@ButtonLabel,rar.ButtonLabel)
				,@RecommendationSequence         = isnull(@RecommendationSequence,rar.RecommendationSequence)
				,@RecommendationToolTip          = isnull(@RecommendationToolTip,rar.RecommendationToolTip)
				,@RecommendationIsActive         = isnull(@RecommendationIsActive,rar.RecommendationIsActive)
				,@RecommendationRowGUID          = isnull(@RecommendationRowGUID,rar.RecommendationRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,rar.IsDeleteEnabled)
				,@ReviewerInitials               = isnull(@ReviewerInitials,rar.ReviewerInitials)
				,@RegistrantLabel                = isnull(@RegistrantLabel,rar.RegistrantLabel)
				,@RegistrantPersonSID            = isnull(@RegistrantPersonSID,rar.RegistrantPersonSID)
				,@IsViewEnabled                  = isnull(@IsViewEnabled,rar.IsViewEnabled)
				,@IsEditEnabled                  = isnull(@IsEditEnabled,rar.IsEditEnabled)
				,@IsSaveBtnDisplayed             = isnull(@IsSaveBtnDisplayed,rar.IsSaveBtnDisplayed)
				,@IsUnlockEnabled                = isnull(@IsUnlockEnabled,rar.IsUnlockEnabled)
				,@IsInProgress                   = isnull(@IsInProgress,rar.IsInProgress)
				,@RegistrantAppReviewStatusSID   = isnull(@RegistrantAppReviewStatusSID,rar.RegistrantAppReviewStatusSID)
				,@RegistrantAppReviewStatusSCD   = isnull(@RegistrantAppReviewStatusSCD,rar.RegistrantAppReviewStatusSCD)
				,@RegistrantAppReviewStatusLabel = isnull(@RegistrantAppReviewStatusLabel,rar.RegistrantAppReviewStatusLabel)
				,@LastStatusChangeUser           = isnull(@LastStatusChangeUser,rar.LastStatusChangeUser)
				,@LastStatusChangeTime           = isnull(@LastStatusChangeTime,rar.LastStatusChangeTime)
				,@FormOwnerSCD                   = isnull(@FormOwnerSCD,rar.FormOwnerSCD)
				,@FormOwnerLabel                 = isnull(@FormOwnerLabel,rar.FormOwnerLabel)
				,@FormOwnerSID                   = isnull(@FormOwnerSID,rar.FormOwnerSID)
				,@NewFormStatusSCD               = isnull(@NewFormStatusSCD,rar.NewFormStatusSCD)
			from
				dbo.vRegistrantAppReview rar
			where
				rar.RegistrantAppReviewSID = @RegistrantAppReviewSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ReasonSID from dbo.RegistrantAppReview x where x.RegistrantAppReviewSID = @RegistrantAppReviewSID) <> @ReasonSID
		begin
			if (select x.IsActive from dbo.Reason x where x.ReasonSID = @ReasonSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'reason'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.RecommendationSID from dbo.RegistrantAppReview x where x.RegistrantAppReviewSID = @RegistrantAppReviewSID) <> @RecommendationSID
		begin
			if (select x.IsActive from dbo.Recommendation x where x.RecommendationSID = @RecommendationSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'recommendation'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Sep 2018
		-- Set the last validated time on the
		-- status changes/save that executed it

		if @NewFormStatusSCD in ('VALIDATED', 'SUBMITTED', 'APPROVED')
		begin
			set @LastValidateTime = sysdatetimeoffset()
		end
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
				r.RoutineName = 'pRegistrantAppReview'
		)
		begin
		
			exec @errorNo = ext.pRegistrantAppReview
				 @Mode                           = 'update.pre'
				,@RegistrantAppReviewSID         = @RegistrantAppReviewSID
				,@RegistrantAppSID               = @RegistrantAppSID output
				,@FormVersionSID                 = @FormVersionSID output
				,@PersonSID                      = @PersonSID output
				,@ReasonSID                      = @ReasonSID output
				,@RecommendationSID              = @RecommendationSID output
				,@FormResponseDraft              = @FormResponseDraft output
				,@LastValidateTime               = @LastValidateTime output
				,@ReviewerComments               = @ReviewerComments output
				,@ConfirmationDraft              = @ConfirmationDraft output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@RegistrantAppReviewXID         = @RegistrantAppReviewXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@RegistrationSID                = @RegistrationSID
				,@PracticeRegisterSectionSID     = @PracticeRegisterSectionSID
				,@RegistrationYear               = @RegistrationYear
				,@RegistrantAppFormVersionSID    = @RegistrantAppFormVersionSID
				,@OrgSID                         = @OrgSID
				,@RegistrantAppLastValidateTime  = @RegistrantAppLastValidateTime
				,@NextFollowUp                   = @NextFollowUp
				,@RegistrationEffective          = @RegistrationEffective
				,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
				,@RegistrantAppReasonSID         = @RegistrantAppReasonSID
				,@InvoiceSID                     = @InvoiceSID
				,@RegistrantAppRowGUID           = @RegistrantAppRowGUID
				,@FormSID                        = @FormSID
				,@VersionNo                      = @VersionNo
				,@RevisionNo                     = @RevisionNo
				,@IsSaveDisplayed                = @IsSaveDisplayed
				,@ApprovedTime                   = @ApprovedTime
				,@FormVersionRowGUID             = @FormVersionRowGUID
				,@GenderSID                      = @GenderSID
				,@NamePrefixSID                  = @NamePrefixSID
				,@FirstName                      = @FirstName
				,@CommonName                     = @CommonName
				,@MiddleNames                    = @MiddleNames
				,@LastName                       = @LastName
				,@BirthDate                      = @BirthDate
				,@DeathDate                      = @DeathDate
				,@HomePhone                      = @HomePhone
				,@MobilePhone                    = @MobilePhone
				,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
				,@ImportBatch                    = @ImportBatch
				,@PersonRowGUID                  = @PersonRowGUID
				,@ReasonGroupSID                 = @ReasonGroupSID
				,@ReasonName                     = @ReasonName
				,@ReasonCode                     = @ReasonCode
				,@ReasonSequence                 = @ReasonSequence
				,@ReasonToolTip                  = @ReasonToolTip
				,@ReasonIsActive                 = @ReasonIsActive
				,@ReasonRowGUID                  = @ReasonRowGUID
				,@RecommendationGroupSID         = @RecommendationGroupSID
				,@ButtonLabel                    = @ButtonLabel
				,@RecommendationSequence         = @RecommendationSequence
				,@RecommendationToolTip          = @RecommendationToolTip
				,@RecommendationIsActive         = @RecommendationIsActive
				,@RecommendationRowGUID          = @RecommendationRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@ReviewerInitials               = @ReviewerInitials
				,@RegistrantLabel                = @RegistrantLabel
				,@RegistrantPersonSID            = @RegistrantPersonSID
				,@IsViewEnabled                  = @IsViewEnabled
				,@IsEditEnabled                  = @IsEditEnabled
				,@IsSaveBtnDisplayed             = @IsSaveBtnDisplayed
				,@IsUnlockEnabled                = @IsUnlockEnabled
				,@IsInProgress                   = @IsInProgress
				,@RegistrantAppReviewStatusSID   = @RegistrantAppReviewStatusSID
				,@RegistrantAppReviewStatusSCD   = @RegistrantAppReviewStatusSCD
				,@RegistrantAppReviewStatusLabel = @RegistrantAppReviewStatusLabel
				,@LastStatusChangeUser           = @LastStatusChangeUser
				,@LastStatusChangeTime           = @LastStatusChangeTime
				,@FormOwnerSCD                   = @FormOwnerSCD
				,@FormOwnerLabel                 = @FormOwnerLabel
				,@FormOwnerSID                   = @FormOwnerSID
				,@NewFormStatusSCD               = @NewFormStatusSCD
		
		end

		-- update the record

		update
			dbo.RegistrantAppReview
		set
			 RegistrantAppSID = @RegistrantAppSID
			,FormVersionSID = @FormVersionSID
			,PersonSID = @PersonSID
			,ReasonSID = @ReasonSID
			,RecommendationSID = @RecommendationSID
			,FormResponseDraft = @FormResponseDraft
			,LastValidateTime = @LastValidateTime
			,ReviewerComments = @ReviewerComments
			,ConfirmationDraft = @ConfirmationDraft
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantAppReviewXID = @RegistrantAppReviewXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantAppReviewSID = @RegistrantAppReviewSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantAppReview where RegistrantAppReviewSID = @registrantAppReviewSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantAppReview'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantAppReview'
					,@Arg2        = @registrantAppReviewSID
				
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
				,@Arg2        = 'dbo.RegistrantAppReview'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantAppReviewSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Sep 2018
		-- VALIDATED status saved the record with the LastValidateTime updated
		-- but should not change underlying status - set back to NULL to
		-- avoid inserting new status record

		if @NewFormStatusSCD = 'VALIDATED'
		begin
			set @NewFormStatusSCD = null
		end

		-- Tim Edlund | Apr 2017
		-- Save the new status value and then store the draft content of the
		-- form into the response history table as long as the change has been
		-- made in the response document. Note that if no previous history
		-- record exists, the form is NEW and the response must be saved

		declare
			@formDefinition		xml;

		if @NewFormStatusSCD is not null																			-- if just saving in place (save and continue) pass this as NULL!
		begin

			set @recordSID		= null
			select @recordSID = fs.FormStatusSID from sf.FormStatus fs where fs.FormStatusSCD = @NewFormStatusSCD

			if @recordSID is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.FormStatus'
					,@Arg2        = @NewFormStatusSCD
									
				raiserror(@errorText, 18, 1)

			end

			exec dbo.pRegistrantAppReviewStatus#Insert
				 @RegistrantAppReviewSID  = @RegistrantAppReviewSID
				,@FormStatusSID						= @recordSID

			set @recordSID		= null
			select @recordSID = max(rarr.RegistrantAppReviewResponseSID) from dbo.RegistrantAppReviewResponse rarr where rarr.RegistrantAppReviewSID = @RegistrantAppReviewSID

			if @recordSID is null or (select checksum(cast(rarr.FormResponse as nvarchar(max))) from dbo.RegistrantAppReviewResponse rarr where rarr.RegistrantAppReviewResponseSID = @recordSID)
			<> checksum(cast(@FormResponseDraft as nvarchar(max)))							-- if no saved version of form found, OR if current value is changed from latest copy
			begin

				exec dbo.pRegistrantAppReviewResponse#Insert
					 @RegistrantAppReviewSID	= @RegistrantAppReviewSID
					,@FormOwnerSID						= @FormOwnerSID
					,@FormResponse						= @FormResponseDraft

			end

			-- Tim Edlund | Sept 2018
			-- Transition forms from In Review to "Reviewed" when all reviews
			-- have been submitted for it.

			if @NewFormStatusSCD in ('SUBMITTED', 'APPROVED')
			begin

				-- if all reviews are now complete and the parent form
				-- is in INREVIEW status to REVIEWED

				declare
					@parentFormStatusSCD varchar(25)
				 ,@isReviewSetComplete bit

				select
					@parentFormStatusSCD = cs.FormStatusSCD
				 ,@isReviewSetComplete = cast(case when left(cs.RecommendationLabel, 9) = 'Complete:' then 1 else 0 end as bit)
				from
					dbo.fRegistrantApp#CurrentStatus(@RegistrantAppSID, -1) cs

				if @parentFormStatusSCD = 'INREVIEW' and @isReviewSetComplete = @ON
				begin

					exec dbo.pRegistrantAppStatus#Insert
						@RegistrantAppSID = @registrantAppSID
					 ,@FormStatusSCD = 'REVIEWED';

				end

				-- Russell Poirier & Tim Edlund | Sept 2018
				-- Post any data from the reviewer form marked with PostOnSubmit="True"
				-- e.g. next follow-up date

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.RegistrantAppReview x
				join
					sf.FormVersion					fv on x.FormVersionSID = fv.FormVersionSID
				where
					x.RegistrantAppReviewSID = @RegistrantAppReviewSID; -- retrieve form definition

				if @formDefinition is not null -- review forms may not be configured for all sites
				begin

					if @NewFormStatusSCD = 'SUBMITTED' -- revise status code to form-action code for pass to sproc
					begin
						set @NewFormStatusSCD = 'SUBMIT';
					end;
					else
					begin
						set @NewFormStatusSCD = 'APPROVE';
					end;

					-- Tim Edlund | Nov 2018
					-- Save the HTML version of the form to a document
					-- record (with context) for PDF creation by the
					-- background service

					if @NewFormStatusSCD = 'APPROVE'
					begin

						declare @docTitle nvarchar(100);

						set @docTitle = dbo.fRegistrationYear#Label(@RegistrationYear) + N' Application Review ' + isnull(' (' + @ReviewerInitials + ')', '')

						exec dbo.pForm#Approve$SetPersonDoc
							@PersonSID = @RegistrantPersonSID
						 ,@ConfirmationDraft = @ConfirmationDraft
						 ,@PersonDocTypeSCD = 'APP' -- review forms use the parent record context
						 ,@ApplicationEntitySCD = 'dbo.RegistrantApp'
						 ,@FormRecordSID = @RegistrantAppSID
						 ,@Title = @docTitle
						 ,@IsPrimary = @OFF
						 ,@SubFormRecordSID = @RegistrantAppReviewSID;

					end;

					exec sf.pForm#Post
						@FormRecordSID = @RegistrantAppReviewSID
					 ,@FormActionCode = @NewFormStatusSCD
					 ,@FormSchemaName = 'dbo'
					 ,@FormTableName = 'RegistrantAppReview'
					 ,@FormDefinition = @formDefinition
					 ,@Response = @FormResponseDraft;

				end

			end;

		end;

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
				r.RoutineName = 'pRegistrantAppReview'
		)
		begin
		
			exec @errorNo = ext.pRegistrantAppReview
				 @Mode                           = 'update.post'
				,@RegistrantAppReviewSID         = @RegistrantAppReviewSID
				,@RegistrantAppSID               = @RegistrantAppSID
				,@FormVersionSID                 = @FormVersionSID
				,@PersonSID                      = @PersonSID
				,@ReasonSID                      = @ReasonSID
				,@RecommendationSID              = @RecommendationSID
				,@FormResponseDraft              = @FormResponseDraft
				,@LastValidateTime               = @LastValidateTime
				,@ReviewerComments               = @ReviewerComments
				,@ConfirmationDraft              = @ConfirmationDraft
				,@UserDefinedColumns             = @UserDefinedColumns
				,@RegistrantAppReviewXID         = @RegistrantAppReviewXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@RegistrationSID                = @RegistrationSID
				,@PracticeRegisterSectionSID     = @PracticeRegisterSectionSID
				,@RegistrationYear               = @RegistrationYear
				,@RegistrantAppFormVersionSID    = @RegistrantAppFormVersionSID
				,@OrgSID                         = @OrgSID
				,@RegistrantAppLastValidateTime  = @RegistrantAppLastValidateTime
				,@NextFollowUp                   = @NextFollowUp
				,@RegistrationEffective          = @RegistrationEffective
				,@IsAutoApprovalEnabled          = @IsAutoApprovalEnabled
				,@RegistrantAppReasonSID         = @RegistrantAppReasonSID
				,@InvoiceSID                     = @InvoiceSID
				,@RegistrantAppRowGUID           = @RegistrantAppRowGUID
				,@FormSID                        = @FormSID
				,@VersionNo                      = @VersionNo
				,@RevisionNo                     = @RevisionNo
				,@IsSaveDisplayed                = @IsSaveDisplayed
				,@ApprovedTime                   = @ApprovedTime
				,@FormVersionRowGUID             = @FormVersionRowGUID
				,@GenderSID                      = @GenderSID
				,@NamePrefixSID                  = @NamePrefixSID
				,@FirstName                      = @FirstName
				,@CommonName                     = @CommonName
				,@MiddleNames                    = @MiddleNames
				,@LastName                       = @LastName
				,@BirthDate                      = @BirthDate
				,@DeathDate                      = @DeathDate
				,@HomePhone                      = @HomePhone
				,@MobilePhone                    = @MobilePhone
				,@IsTextMessagingEnabled         = @IsTextMessagingEnabled
				,@ImportBatch                    = @ImportBatch
				,@PersonRowGUID                  = @PersonRowGUID
				,@ReasonGroupSID                 = @ReasonGroupSID
				,@ReasonName                     = @ReasonName
				,@ReasonCode                     = @ReasonCode
				,@ReasonSequence                 = @ReasonSequence
				,@ReasonToolTip                  = @ReasonToolTip
				,@ReasonIsActive                 = @ReasonIsActive
				,@ReasonRowGUID                  = @ReasonRowGUID
				,@RecommendationGroupSID         = @RecommendationGroupSID
				,@ButtonLabel                    = @ButtonLabel
				,@RecommendationSequence         = @RecommendationSequence
				,@RecommendationToolTip          = @RecommendationToolTip
				,@RecommendationIsActive         = @RecommendationIsActive
				,@RecommendationRowGUID          = @RecommendationRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@ReviewerInitials               = @ReviewerInitials
				,@RegistrantLabel                = @RegistrantLabel
				,@RegistrantPersonSID            = @RegistrantPersonSID
				,@IsViewEnabled                  = @IsViewEnabled
				,@IsEditEnabled                  = @IsEditEnabled
				,@IsSaveBtnDisplayed             = @IsSaveBtnDisplayed
				,@IsUnlockEnabled                = @IsUnlockEnabled
				,@IsInProgress                   = @IsInProgress
				,@RegistrantAppReviewStatusSID   = @RegistrantAppReviewStatusSID
				,@RegistrantAppReviewStatusSCD   = @RegistrantAppReviewStatusSCD
				,@RegistrantAppReviewStatusLabel = @RegistrantAppReviewStatusLabel
				,@LastStatusChangeUser           = @LastStatusChangeUser
				,@LastStatusChangeTime           = @LastStatusChangeTime
				,@FormOwnerSCD                   = @FormOwnerSCD
				,@FormOwnerLabel                 = @FormOwnerLabel
				,@FormOwnerSID                   = @FormOwnerSID
				,@NewFormStatusSCD               = @NewFormStatusSCD
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantAppReviewSID
			from
				dbo.vRegistrantAppReview ent
			where
				ent.RegistrantAppReviewSID = @RegistrantAppReviewSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantAppReviewSID
				,ent.RegistrantAppSID
				,ent.FormVersionSID
				,ent.PersonSID
				,ent.ReasonSID
				,ent.RecommendationSID
				,ent.FormResponseDraft
				,ent.LastValidateTime
				,ent.ReviewerComments
				,ent.ConfirmationDraft
				,ent.UserDefinedColumns
				,ent.RegistrantAppReviewXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.RegistrantAppFormVersionSID
				,ent.OrgSID
				,ent.RegistrantAppLastValidateTime
				,ent.NextFollowUp
				,ent.RegistrationEffective
				,ent.IsAutoApprovalEnabled
				,ent.RegistrantAppReasonSID
				,ent.InvoiceSID
				,ent.RegistrantAppRowGUID
				,ent.FormSID
				,ent.VersionNo
				,ent.RevisionNo
				,ent.IsSaveDisplayed
				,ent.ApprovedTime
				,ent.FormVersionRowGUID
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
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ReasonToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.RecommendationGroupSID
				,ent.ButtonLabel
				,ent.RecommendationSequence
				,ent.RecommendationToolTip
				,ent.RecommendationIsActive
				,ent.RecommendationRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.ReviewerInitials
				,ent.RegistrantLabel
				,ent.RegistrantPersonSID
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsSaveBtnDisplayed
				,ent.IsUnlockEnabled
				,ent.IsInProgress
				,ent.RegistrantAppReviewStatusSID
				,ent.RegistrantAppReviewStatusSCD
				,ent.RegistrantAppReviewStatusLabel
				,ent.LastStatusChangeUser
				,ent.LastStatusChangeTime
				,ent.FormOwnerSCD
				,ent.FormOwnerLabel
				,ent.FormOwnerSID
				,ent.NewFormStatusSCD
			from
				dbo.vRegistrantAppReview ent
			where
				ent.RegistrantAppReviewSID = @RegistrantAppReviewSID

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
