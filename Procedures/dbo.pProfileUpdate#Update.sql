SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pProfileUpdate#Update]
	 @ProfileUpdateSID       int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID              int               = null -- table column values to update:
	,@RegistrationYear       int               = null
	,@FormVersionSID         int               = null
	,@FormResponseDraft      xml               = null
	,@LastValidateTime       datetimeoffset(7) = null
	,@AdminComments          xml               = null
	,@NextFollowUp           date              = null
	,@ConfirmationDraft      nvarchar(max)     = null
	,@IsAutoApprovalEnabled  bit               = null
	,@ReasonSID              int               = null
	,@ReviewReasonList       xml               = null
	,@ParentRowGUID          uniqueidentifier  = null
	,@UserDefinedColumns     xml               = null
	,@ProfileUpdateXID       varchar(150)      = null
	,@LegacyKey              nvarchar(50)      = null
	,@UpdateUser             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected           tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied          bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext               xml               = null -- other values defining context for the update (if any)
	,@FormSID                int               = null -- not a base table column
	,@VersionNo              smallint          = null -- not a base table column
	,@RevisionNo             smallint          = null -- not a base table column
	,@IsSaveDisplayed        bit               = null -- not a base table column
	,@ApprovedTime           datetimeoffset(7) = null -- not a base table column
	,@FormVersionRowGUID     uniqueidentifier  = null -- not a base table column
	,@GenderSID              int               = null -- not a base table column
	,@NamePrefixSID          int               = null -- not a base table column
	,@FirstName              nvarchar(30)      = null -- not a base table column
	,@CommonName             nvarchar(30)      = null -- not a base table column
	,@MiddleNames            nvarchar(30)      = null -- not a base table column
	,@LastName               nvarchar(35)      = null -- not a base table column
	,@BirthDate              date              = null -- not a base table column
	,@DeathDate              date              = null -- not a base table column
	,@HomePhone              varchar(25)       = null -- not a base table column
	,@MobilePhone            varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled bit               = null -- not a base table column
	,@ImportBatch            nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID          uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID         int               = null -- not a base table column
	,@ReasonName             nvarchar(50)      = null -- not a base table column
	,@ReasonCode             varchar(25)       = null -- not a base table column
	,@ReasonSequence         smallint          = null -- not a base table column
	,@ToolTip                nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive         bit               = null -- not a base table column
	,@ReasonRowGUID          uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled        bit               = null -- not a base table column
	,@ProfileUpdateLabel     nvarchar(80)      = null -- not a base table column
	,@IsViewEnabled          bit               = null -- not a base table column
	,@IsEditEnabled          bit               = null -- not a base table column
	,@IsSaveBtnDisplayed     bit               = null -- not a base table column
	,@IsApproveEnabled       bit               = null -- not a base table column
	,@IsRejectEnabled        bit               = null -- not a base table column
	,@IsUnlockEnabled        bit               = null -- not a base table column
	,@IsWithdrawalEnabled    bit               = null -- not a base table column
	,@IsInProgress           bit               = null -- not a base table column
	,@IsReviewRequired       bit               = null -- not a base table column
	,@FormStatusSID          int               = null -- not a base table column
	,@FormStatusSCD          varchar(25)       = null -- not a base table column
	,@FormStatusLabel        nvarchar(35)      = null -- not a base table column
	,@FormOwnerSID           int               = null -- not a base table column
	,@FormOwnerSCD           varchar(25)       = null -- not a base table column
	,@FormOwnerLabel         nvarchar(35)      = null -- not a base table column
	,@LastStatusChangeUser   nvarchar(75)      = null -- not a base table column
	,@LastStatusChangeTime   datetimeoffset(7) = null -- not a base table column
	,@IsPDFDisplayed         bit               = null -- not a base table column
	,@PersonDocSID           int               = null -- not a base table column
	,@NewFormStatusSCD       varchar(25)       = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pProfileUpdate#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.ProfileUpdate table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.ProfileUpdate table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vProfileUpdate entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pProfileUpdate procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fProfileUpdateCheck to test all rules.

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

		if @ProfileUpdateSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ProfileUpdateSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @ProfileUpdateXID = ltrim(rtrim(@ProfileUpdateXID))
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
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @ProfileUpdateLabel = ltrim(rtrim(@ProfileUpdateLabel))
		set @FormStatusSCD = ltrim(rtrim(@FormStatusSCD))
		set @FormStatusLabel = ltrim(rtrim(@FormStatusLabel))
		set @FormOwnerSCD = ltrim(rtrim(@FormOwnerSCD))
		set @FormOwnerLabel = ltrim(rtrim(@FormOwnerLabel))
		set @LastStatusChangeUser = ltrim(rtrim(@LastStatusChangeUser))
		set @NewFormStatusSCD = ltrim(rtrim(@NewFormStatusSCD))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ConfirmationDraft) = 0 set @ConfirmationDraft = null
		if len(@ProfileUpdateXID) = 0 set @ProfileUpdateXID = null
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
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@ProfileUpdateLabel) = 0 set @ProfileUpdateLabel = null
		if len(@FormStatusSCD) = 0 set @FormStatusSCD = null
		if len(@FormStatusLabel) = 0 set @FormStatusLabel = null
		if len(@FormOwnerSCD) = 0 set @FormOwnerSCD = null
		if len(@FormOwnerLabel) = 0 set @FormOwnerLabel = null
		if len(@LastStatusChangeUser) = 0 set @LastStatusChangeUser = null
		if len(@NewFormStatusSCD) = 0 set @NewFormStatusSCD = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID              = isnull(@PersonSID,pu.PersonSID)
				,@RegistrationYear       = isnull(@RegistrationYear,pu.RegistrationYear)
				,@FormVersionSID         = isnull(@FormVersionSID,pu.FormVersionSID)
				,@FormResponseDraft      = isnull(@FormResponseDraft,pu.FormResponseDraft)
				,@LastValidateTime       = isnull(@LastValidateTime,pu.LastValidateTime)
				,@AdminComments          = isnull(@AdminComments,pu.AdminComments)
				,@NextFollowUp           = isnull(@NextFollowUp,pu.NextFollowUp)
				,@ConfirmationDraft      = isnull(@ConfirmationDraft,pu.ConfirmationDraft)
				,@IsAutoApprovalEnabled  = isnull(@IsAutoApprovalEnabled,pu.IsAutoApprovalEnabled)
				,@ReasonSID              = isnull(@ReasonSID,pu.ReasonSID)
				,@ReviewReasonList       = isnull(@ReviewReasonList,pu.ReviewReasonList)
				,@ParentRowGUID          = isnull(@ParentRowGUID,pu.ParentRowGUID)
				,@UserDefinedColumns     = isnull(@UserDefinedColumns,pu.UserDefinedColumns)
				,@ProfileUpdateXID       = isnull(@ProfileUpdateXID,pu.ProfileUpdateXID)
				,@LegacyKey              = isnull(@LegacyKey,pu.LegacyKey)
				,@UpdateUser             = isnull(@UpdateUser,pu.UpdateUser)
				,@IsReselected           = isnull(@IsReselected,pu.IsReselected)
				,@IsNullApplied          = isnull(@IsNullApplied,pu.IsNullApplied)
				,@zContext               = isnull(@zContext,pu.zContext)
				,@FormSID                = isnull(@FormSID,pu.FormSID)
				,@VersionNo              = isnull(@VersionNo,pu.VersionNo)
				,@RevisionNo             = isnull(@RevisionNo,pu.RevisionNo)
				,@IsSaveDisplayed        = isnull(@IsSaveDisplayed,pu.IsSaveDisplayed)
				,@ApprovedTime           = isnull(@ApprovedTime,pu.ApprovedTime)
				,@FormVersionRowGUID     = isnull(@FormVersionRowGUID,pu.FormVersionRowGUID)
				,@GenderSID              = isnull(@GenderSID,pu.GenderSID)
				,@NamePrefixSID          = isnull(@NamePrefixSID,pu.NamePrefixSID)
				,@FirstName              = isnull(@FirstName,pu.FirstName)
				,@CommonName             = isnull(@CommonName,pu.CommonName)
				,@MiddleNames            = isnull(@MiddleNames,pu.MiddleNames)
				,@LastName               = isnull(@LastName,pu.LastName)
				,@BirthDate              = isnull(@BirthDate,pu.BirthDate)
				,@DeathDate              = isnull(@DeathDate,pu.DeathDate)
				,@HomePhone              = isnull(@HomePhone,pu.HomePhone)
				,@MobilePhone            = isnull(@MobilePhone,pu.MobilePhone)
				,@IsTextMessagingEnabled = isnull(@IsTextMessagingEnabled,pu.IsTextMessagingEnabled)
				,@ImportBatch            = isnull(@ImportBatch,pu.ImportBatch)
				,@PersonRowGUID          = isnull(@PersonRowGUID,pu.PersonRowGUID)
				,@ReasonGroupSID         = isnull(@ReasonGroupSID,pu.ReasonGroupSID)
				,@ReasonName             = isnull(@ReasonName,pu.ReasonName)
				,@ReasonCode             = isnull(@ReasonCode,pu.ReasonCode)
				,@ReasonSequence         = isnull(@ReasonSequence,pu.ReasonSequence)
				,@ToolTip                = isnull(@ToolTip,pu.ToolTip)
				,@ReasonIsActive         = isnull(@ReasonIsActive,pu.ReasonIsActive)
				,@ReasonRowGUID          = isnull(@ReasonRowGUID,pu.ReasonRowGUID)
				,@IsDeleteEnabled        = isnull(@IsDeleteEnabled,pu.IsDeleteEnabled)
				,@ProfileUpdateLabel     = isnull(@ProfileUpdateLabel,pu.ProfileUpdateLabel)
				,@IsViewEnabled          = isnull(@IsViewEnabled,pu.IsViewEnabled)
				,@IsEditEnabled          = isnull(@IsEditEnabled,pu.IsEditEnabled)
				,@IsSaveBtnDisplayed     = isnull(@IsSaveBtnDisplayed,pu.IsSaveBtnDisplayed)
				,@IsApproveEnabled       = isnull(@IsApproveEnabled,pu.IsApproveEnabled)
				,@IsRejectEnabled        = isnull(@IsRejectEnabled,pu.IsRejectEnabled)
				,@IsUnlockEnabled        = isnull(@IsUnlockEnabled,pu.IsUnlockEnabled)
				,@IsWithdrawalEnabled    = isnull(@IsWithdrawalEnabled,pu.IsWithdrawalEnabled)
				,@IsInProgress           = isnull(@IsInProgress,pu.IsInProgress)
				,@IsReviewRequired       = isnull(@IsReviewRequired,pu.IsReviewRequired)
				,@FormStatusSID          = isnull(@FormStatusSID,pu.FormStatusSID)
				,@FormStatusSCD          = isnull(@FormStatusSCD,pu.FormStatusSCD)
				,@FormStatusLabel        = isnull(@FormStatusLabel,pu.FormStatusLabel)
				,@FormOwnerSID           = isnull(@FormOwnerSID,pu.FormOwnerSID)
				,@FormOwnerSCD           = isnull(@FormOwnerSCD,pu.FormOwnerSCD)
				,@FormOwnerLabel         = isnull(@FormOwnerLabel,pu.FormOwnerLabel)
				,@LastStatusChangeUser   = isnull(@LastStatusChangeUser,pu.LastStatusChangeUser)
				,@LastStatusChangeTime   = isnull(@LastStatusChangeTime,pu.LastStatusChangeTime)
				,@IsPDFDisplayed         = isnull(@IsPDFDisplayed,pu.IsPDFDisplayed)
				,@PersonDocSID           = isnull(@PersonDocSID,pu.PersonDocSID)
				,@NewFormStatusSCD       = isnull(@NewFormStatusSCD,pu.NewFormStatusSCD)
			from
				dbo.vProfileUpdate pu
			where
				pu.ProfileUpdateSID = @ProfileUpdateSID

		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ReasonSID from dbo.ProfileUpdate x where x.ProfileUpdateSID = @ProfileUpdateSID) <> @ReasonSID
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

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Jan 2019
		-- Set the last validated time on statuses that executed the checks but
		-- clear it when the form is being RETURNED or where no status is set
		-- in which case the form is only being saved in place

		if @NewFormStatusSCD in ('VALIDATED', 'SUBMITTED', 'APPROVED')
		begin
			set @LastValidateTime = sysdatetimeoffset()
		end
		else if @NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD is null
		begin
			set @LastValidateTime = null
		end

		if @LastValidateTime is null and exists (select (1) from dbo.RegistrantRenewal where RowGUID = @ParentRowGUID and LastValidateTime is not null) -- where validation is cleared on child, clear on parent form
		begin

			update
				dbo.RegistrantRenewal
			set
				LastValidateTime = null
			 ,UpdateTime = sysdatetimeoffset()
			 ,UpdateUser = @UpdateUser
			where
				RowGUID = @ParentRowGUID;

		end;

		-- Tim Edlund | Oct 2018
		-- If the form is not withdrawn and the reason list
		-- is blank where an individual reason key exists,
		-- the put the value in the XML document (for UI display)

		if @NewFormStatusSCD <> 'WITHDRAWN' and @FormStatusSCD <> 'WITHDRAWN' and @ReviewReasonList is null and @ReasonSID is not null
		begin
			set @ReviewReasonList = cast(N'<Reasons><Reason SID="' + ltrim(@ReasonSID) + '"/></Reasons>' as xml)
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
				r.RoutineName = 'pProfileUpdate'
		)
		begin
		
			exec @errorNo = ext.pProfileUpdate
				 @Mode                   = 'update.pre'
				,@ProfileUpdateSID       = @ProfileUpdateSID
				,@PersonSID              = @PersonSID output
				,@RegistrationYear       = @RegistrationYear output
				,@FormVersionSID         = @FormVersionSID output
				,@FormResponseDraft      = @FormResponseDraft output
				,@LastValidateTime       = @LastValidateTime output
				,@AdminComments          = @AdminComments output
				,@NextFollowUp           = @NextFollowUp output
				,@ConfirmationDraft      = @ConfirmationDraft output
				,@IsAutoApprovalEnabled  = @IsAutoApprovalEnabled output
				,@ReasonSID              = @ReasonSID output
				,@ReviewReasonList       = @ReviewReasonList output
				,@ParentRowGUID          = @ParentRowGUID output
				,@UserDefinedColumns     = @UserDefinedColumns output
				,@ProfileUpdateXID       = @ProfileUpdateXID output
				,@LegacyKey              = @LegacyKey output
				,@UpdateUser             = @UpdateUser
				,@RowStamp               = @RowStamp
				,@IsReselected           = @IsReselected
				,@IsNullApplied          = @IsNullApplied
				,@zContext               = @zContext
				,@FormSID                = @FormSID
				,@VersionNo              = @VersionNo
				,@RevisionNo             = @RevisionNo
				,@IsSaveDisplayed        = @IsSaveDisplayed
				,@ApprovedTime           = @ApprovedTime
				,@FormVersionRowGUID     = @FormVersionRowGUID
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
				,@ReasonGroupSID         = @ReasonGroupSID
				,@ReasonName             = @ReasonName
				,@ReasonCode             = @ReasonCode
				,@ReasonSequence         = @ReasonSequence
				,@ToolTip                = @ToolTip
				,@ReasonIsActive         = @ReasonIsActive
				,@ReasonRowGUID          = @ReasonRowGUID
				,@IsDeleteEnabled        = @IsDeleteEnabled
				,@ProfileUpdateLabel     = @ProfileUpdateLabel
				,@IsViewEnabled          = @IsViewEnabled
				,@IsEditEnabled          = @IsEditEnabled
				,@IsSaveBtnDisplayed     = @IsSaveBtnDisplayed
				,@IsApproveEnabled       = @IsApproveEnabled
				,@IsRejectEnabled        = @IsRejectEnabled
				,@IsUnlockEnabled        = @IsUnlockEnabled
				,@IsWithdrawalEnabled    = @IsWithdrawalEnabled
				,@IsInProgress           = @IsInProgress
				,@IsReviewRequired       = @IsReviewRequired
				,@FormStatusSID          = @FormStatusSID
				,@FormStatusSCD          = @FormStatusSCD
				,@FormStatusLabel        = @FormStatusLabel
				,@FormOwnerSID           = @FormOwnerSID
				,@FormOwnerSCD           = @FormOwnerSCD
				,@FormOwnerLabel         = @FormOwnerLabel
				,@LastStatusChangeUser   = @LastStatusChangeUser
				,@LastStatusChangeTime   = @LastStatusChangeTime
				,@IsPDFDisplayed         = @IsPDFDisplayed
				,@PersonDocSID           = @PersonDocSID
				,@NewFormStatusSCD       = @NewFormStatusSCD
		
		end

		-- update the record

		update
			dbo.ProfileUpdate
		set
			 PersonSID = @PersonSID
			,RegistrationYear = @RegistrationYear
			,FormVersionSID = @FormVersionSID
			,FormResponseDraft = @FormResponseDraft
			,LastValidateTime = @LastValidateTime
			,AdminComments = @AdminComments
			,NextFollowUp = @NextFollowUp
			,ConfirmationDraft = @ConfirmationDraft
			,IsAutoApprovalEnabled = @IsAutoApprovalEnabled
			,ReasonSID = @ReasonSID
			,ReviewReasonList = @ReviewReasonList
			,ParentRowGUID = @ParentRowGUID
			,UserDefinedColumns = @UserDefinedColumns
			,ProfileUpdateXID = @ProfileUpdateXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ProfileUpdateSID = @ProfileUpdateSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.ProfileUpdate where ProfileUpdateSID = @profileUpdateSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.ProfileUpdate'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.ProfileUpdate'
					,@Arg2        = @profileUpdateSID
				
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
				,@Arg2        = 'dbo.ProfileUpdate'
				,@Arg3        = @rowsAffected
				,@Arg4        = @profileUpdateSID
			
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
			
		-- Cory Ng | Jan 2018
		-- Save the new status value and then store the draft content of the
		-- form into the response history table as long as the change has been
		-- made in the response document. Note that if no previous history
		-- record exists, the form is NEW and the response must be saved
		-- if the status is returned or unlocked and the profile update is
		-- part of a form set, set all other forms to the same status

		declare
			@formDefinition xml

		if @NewFormStatusSCD is not null -- if just saving in place (save and continue) pass this as NULL!
		begin
			
			if not exists (
				select
					1
				from
					dbo.ProfileUpdate pu
				cross apply
					dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
				where
					pu.ProfileUpdateSID = @ProfileUpdateSID
				and
					cs.FormStatusSCD = @NewFormStatusSCD
			)
			begin
			
				set @recordSID = null;

				select
					@recordSID = fs.FormStatusSID
				from
					sf.FormStatus fs
				where
					fs.FormStatusSCD = @NewFormStatusSCD;

				if @recordSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'sf.FormStatus'
					 ,@Arg2 = @NewFormStatusSCD;

					raiserror(@errorText, 18, 1);

				end;

				exec dbo.pProfileUpdateStatus#Insert
					@ProfileUpdateSID = @ProfileUpdateSID
				 ,@FormStatusSID = @recordSID;

				if (@NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD = 'UNLOCKED') and @ParentRowGUID is not null
				begin

						exec dbo.pFormSet#SetStatus	
							 @ParentRowGUID = @ParentRowGUID
							,@FormStatusSCD = @NewFormStatusSCD
							,@IsParentSet		= @OFF

					end

			end

			set @recordSID = null;

			select
				@recordSID = max(rar.ProfileUpdateResponseSID)
			from
				dbo.ProfileUpdateResponse rar
			where
				rar.ProfileUpdateSID = @ProfileUpdateSID;

			if @recordSID is null or														(
															select
																checksum(cast(rar.FormResponse as nvarchar(max)))
															from
																dbo.ProfileUpdateResponse rar
															where
																rar.ProfileUpdateResponseSID = @recordSID
														) <> checksum(cast(@FormResponseDraft as nvarchar(max))) -- if no saved version of form found, OR if current value is changed from latest copy
			begin

				exec dbo.pProfileUpdateResponse#Insert
					@ProfileUpdateSID = @ProfileUpdateSID
				 ,@FormOwnerSID = @FormOwnerSID
				 ,@FormResponse = @FormResponseDraft;

			end;

			-- post values to the main profile as required for
			-- the SUBMIT and APPROVE form actions

			if @NewFormStatusSCD = 'SUBMITTED'
			begin

				exec dbo.pProfileUpdate#Submit
					@ProfileUpdateSID = @ProfileUpdateSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID

			end;
			else if @NewFormStatusSCD = 'APPROVED'
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.ProfileUpdate pu
				join
					sf.FormVersion		fv on pu.FormVersionSID = fv.FormVersionSID
				where
					pu.ProfileUpdateSID = @ProfileUpdateSID

				exec dbo.pProfileUpdate#Approve
					@ProfileUpdateSID = @ProfileUpdateSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID
				 ,@FormDefinition = @formDefinition;

			end;
			else if @NewFormStatusSCD in ('CORRECTED','RETURNED') and exists -- if edited by admin and form was previously submitted, call the form post action
					 (
						select
							1
						from
							dbo.ProfileUpdateStatus x
						join
							sf.FormStatus										 fs on x.FormStatusSID = fs.FormStatusSID
						where
							x.ProfileUpdateSID = @ProfileUpdateSID and fs.FormStatusSCD = 'SUBMITTED'
					 )
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.ProfileUpdate x
				join
					sf.FormVersion						 fv on x.FormVersionSID = fv.FormVersionSID
				where
					x.ProfileUpdateSID = @ProfileUpdateSID;

				exec sf.pForm#Post
					@FormRecordSID = @ProfileUpdateSID
				 ,@FormActionCode = 'SUBMIT'
				 ,@FormSchemaName = 'dbo'
				 ,@FormTableName = 'ProfileUpdate'
				 ,@FormDefinition = @formDefinition
				 ,@Response = @FormResponseDraft;

			end;
		end
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
				r.RoutineName = 'pProfileUpdate'
		)
		begin
		
			exec @errorNo = ext.pProfileUpdate
				 @Mode                   = 'update.post'
				,@ProfileUpdateSID       = @ProfileUpdateSID
				,@PersonSID              = @PersonSID
				,@RegistrationYear       = @RegistrationYear
				,@FormVersionSID         = @FormVersionSID
				,@FormResponseDraft      = @FormResponseDraft
				,@LastValidateTime       = @LastValidateTime
				,@AdminComments          = @AdminComments
				,@NextFollowUp           = @NextFollowUp
				,@ConfirmationDraft      = @ConfirmationDraft
				,@IsAutoApprovalEnabled  = @IsAutoApprovalEnabled
				,@ReasonSID              = @ReasonSID
				,@ReviewReasonList       = @ReviewReasonList
				,@ParentRowGUID          = @ParentRowGUID
				,@UserDefinedColumns     = @UserDefinedColumns
				,@ProfileUpdateXID       = @ProfileUpdateXID
				,@LegacyKey              = @LegacyKey
				,@UpdateUser             = @UpdateUser
				,@RowStamp               = @RowStamp
				,@IsReselected           = @IsReselected
				,@IsNullApplied          = @IsNullApplied
				,@zContext               = @zContext
				,@FormSID                = @FormSID
				,@VersionNo              = @VersionNo
				,@RevisionNo             = @RevisionNo
				,@IsSaveDisplayed        = @IsSaveDisplayed
				,@ApprovedTime           = @ApprovedTime
				,@FormVersionRowGUID     = @FormVersionRowGUID
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
				,@ReasonGroupSID         = @ReasonGroupSID
				,@ReasonName             = @ReasonName
				,@ReasonCode             = @ReasonCode
				,@ReasonSequence         = @ReasonSequence
				,@ToolTip                = @ToolTip
				,@ReasonIsActive         = @ReasonIsActive
				,@ReasonRowGUID          = @ReasonRowGUID
				,@IsDeleteEnabled        = @IsDeleteEnabled
				,@ProfileUpdateLabel     = @ProfileUpdateLabel
				,@IsViewEnabled          = @IsViewEnabled
				,@IsEditEnabled          = @IsEditEnabled
				,@IsSaveBtnDisplayed     = @IsSaveBtnDisplayed
				,@IsApproveEnabled       = @IsApproveEnabled
				,@IsRejectEnabled        = @IsRejectEnabled
				,@IsUnlockEnabled        = @IsUnlockEnabled
				,@IsWithdrawalEnabled    = @IsWithdrawalEnabled
				,@IsInProgress           = @IsInProgress
				,@IsReviewRequired       = @IsReviewRequired
				,@FormStatusSID          = @FormStatusSID
				,@FormStatusSCD          = @FormStatusSCD
				,@FormStatusLabel        = @FormStatusLabel
				,@FormOwnerSID           = @FormOwnerSID
				,@FormOwnerSCD           = @FormOwnerSCD
				,@FormOwnerLabel         = @FormOwnerLabel
				,@LastStatusChangeUser   = @LastStatusChangeUser
				,@LastStatusChangeTime   = @LastStatusChangeTime
				,@IsPDFDisplayed         = @IsPDFDisplayed
				,@PersonDocSID           = @PersonDocSID
				,@NewFormStatusSCD       = @NewFormStatusSCD
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ProfileUpdateSID
			from
				dbo.vProfileUpdate ent
			where
				ent.ProfileUpdateSID = @ProfileUpdateSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ProfileUpdateSID
				,ent.PersonSID
				,ent.RegistrationYear
				,ent.FormVersionSID
				,ent.FormResponseDraft
				,ent.LastValidateTime
				,ent.AdminComments
				,ent.NextFollowUp
				,ent.ConfirmationDraft
				,ent.IsAutoApprovalEnabled
				,ent.ReasonSID
				,ent.ReviewReasonList
				,ent.ParentRowGUID
				,ent.UserDefinedColumns
				,ent.ProfileUpdateXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
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
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.ProfileUpdateLabel
				,ent.IsViewEnabled
				,ent.IsEditEnabled
				,ent.IsSaveBtnDisplayed
				,ent.IsApproveEnabled
				,ent.IsRejectEnabled
				,ent.IsUnlockEnabled
				,ent.IsWithdrawalEnabled
				,ent.IsInProgress
				,ent.IsReviewRequired
				,ent.FormStatusSID
				,ent.FormStatusSCD
				,ent.FormStatusLabel
				,ent.FormOwnerSID
				,ent.FormOwnerSCD
				,ent.FormOwnerLabel
				,ent.LastStatusChangeUser
				,ent.LastStatusChangeTime
				,ent.IsPDFDisplayed
				,ent.PersonDocSID
				,ent.NewFormStatusSCD
			from
				dbo.vProfileUpdate ent
			where
				ent.ProfileUpdateSID = @ProfileUpdateSID

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
