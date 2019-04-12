SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pProfileUpdate#Insert]
	 @ProfileUpdateSID       int               = null output								-- identity value assigned to the new record
	,@PersonSID              int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear       int               = null												-- default: dbo.fRegistrationYear#Current()
	,@FormVersionSID         int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@FormResponseDraft      xml               = null												-- default: CONVERT(xml,N'<FormResponses />')
	,@LastValidateTime       datetimeoffset(7) = null												
	,@AdminComments          xml               = null												-- default: CONVERT(xml,'<Comments />')
	,@NextFollowUp           date              = null												
	,@ConfirmationDraft      nvarchar(max)     = null												
	,@IsAutoApprovalEnabled  bit               = null												-- default: CONVERT(bit,(0))
	,@ReasonSID              int               = null												
	,@ReviewReasonList       xml               = null												
	,@ParentRowGUID          uniqueidentifier  = null												
	,@UserDefinedColumns     xml               = null												
	,@ProfileUpdateXID       varchar(150)      = null												
	,@LegacyKey              nvarchar(50)      = null												
	,@CreateUser             nvarchar(75)      = null												-- default: suser_sname()
	,@IsReselected           tinyint           = null												-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext               xml               = null												-- other values defining context for the insert (if any)
	,@FormSID                int               = null												-- not a base table column (default ignored)
	,@VersionNo              smallint          = null												-- not a base table column (default ignored)
	,@RevisionNo             smallint          = null												-- not a base table column (default ignored)
	,@IsSaveDisplayed        bit               = null												-- not a base table column (default ignored)
	,@ApprovedTime           datetimeoffset(7) = null												-- not a base table column (default ignored)
	,@FormVersionRowGUID     uniqueidentifier  = null												-- not a base table column (default ignored)
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
	,@ReasonGroupSID         int               = null												-- not a base table column (default ignored)
	,@ReasonName             nvarchar(50)      = null												-- not a base table column (default ignored)
	,@ReasonCode             varchar(25)       = null												-- not a base table column (default ignored)
	,@ReasonSequence         smallint          = null												-- not a base table column (default ignored)
	,@ToolTip                nvarchar(500)     = null												-- not a base table column (default ignored)
	,@ReasonIsActive         bit               = null												-- not a base table column (default ignored)
	,@ReasonRowGUID          uniqueidentifier  = null												-- not a base table column (default ignored)
	,@IsDeleteEnabled        bit               = null												-- not a base table column (default ignored)
	,@ProfileUpdateLabel     nvarchar(80)      = null												-- not a base table column (default ignored)
	,@IsViewEnabled          bit               = null												-- not a base table column (default ignored)
	,@IsEditEnabled          bit               = null												-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed     bit               = null												-- not a base table column (default ignored)
	,@IsApproveEnabled       bit               = null												-- not a base table column (default ignored)
	,@IsRejectEnabled        bit               = null												-- not a base table column (default ignored)
	,@IsUnlockEnabled        bit               = null												-- not a base table column (default ignored)
	,@IsWithdrawalEnabled    bit               = null												-- not a base table column (default ignored)
	,@IsInProgress           bit               = null												-- not a base table column (default ignored)
	,@IsReviewRequired       bit               = null												-- not a base table column (default ignored)
	,@FormStatusSID          int               = null												-- not a base table column (default ignored)
	,@FormStatusSCD          varchar(25)       = null												-- not a base table column (default ignored)
	,@FormStatusLabel        nvarchar(35)      = null												-- not a base table column (default ignored)
	,@FormOwnerSID           int               = null												-- not a base table column (default ignored)
	,@FormOwnerSCD           varchar(25)       = null												-- not a base table column (default ignored)
	,@FormOwnerLabel         nvarchar(35)      = null												-- not a base table column (default ignored)
	,@LastStatusChangeUser   nvarchar(75)      = null												-- not a base table column (default ignored)
	,@LastStatusChangeTime   datetimeoffset(7) = null												-- not a base table column (default ignored)
	,@IsPDFDisplayed         bit               = null												-- not a base table column (default ignored)
	,@PersonDocSID           int               = null												-- not a base table column (default ignored)
	,@NewFormStatusSCD       varchar(25)       = null												-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pProfileUpdate#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.ProfileUpdate table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.ProfileUpdate table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vProfileUpdate entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pProfileUpdate procedure. The extended procedure is only called
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

	set @ProfileUpdateSID = null																						-- initialize output parameter

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

		set @ConfirmationDraft = ltrim(rtrim(@ConfirmationDraft))
		set @ProfileUpdateXID = ltrim(rtrim(@ProfileUpdateXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RegistrationYear = isnull(@RegistrationYear,dbo.fRegistrationYear#Current())
		set @FormResponseDraft = isnull(@FormResponseDraft,CONVERT(xml,N'<FormResponses />'))
		set @AdminComments = isnull(@AdminComments,CONVERT(xml,'<Comments />'))
		set @IsAutoApprovalEnabled = isnull(@IsAutoApprovalEnabled,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected          = isnull(@IsReselected         ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Jan 2018
		-- If a form version is not provided, default it to the latest published form of the		-- correct type. Context sub-selections (using the sf.form.FormContext column) do NOT
		-- apply for profile updates since this form is only completed for a single year at
		-- a time. If a FormContext is provided it is ignored.

		if isnull(@FormVersionSID, 0) = 0
		begin

			select
				@FormVersionSID = max(fv.FormVersionSID)
			from
				sf.Form				 f
			join
				sf.FormType		 ft on f.FormTypeSID = ft.FormTypeSID and ft.FormTypeSCD = 'PROFILE.UPDATE' -- only include profile update forms
			join
				sf.FormVersion fv on f.FormSID		 = fv.FormSID and fv.VersionNo > 0; -- filter out non-published versions

		end;

		-- Tim Edlund | Jan 2018
		-- If a form version could not be derived, raise an error to highlight the
		-- problem to the configurator with language more descriptive than the
		-- standard "NOT NULL" error that would otherwise be raised.

		if @FormVersionSID is null
		begin

			exec sf.pMessage#Get
					@MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'Profile Update (published)'

			raiserror(@errorText, 17, 1)
			
		end
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
				r.RoutineName = 'pProfileUpdate'
		)
		begin
		
			exec @errorNo = ext.pProfileUpdate
				 @Mode                   = 'insert.pre'
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
				,@CreateUser             = @CreateUser
				,@IsReselected           = @IsReselected
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

		-- insert the record

		insert
			dbo.ProfileUpdate
		(
			 PersonSID
			,RegistrationYear
			,FormVersionSID
			,FormResponseDraft
			,LastValidateTime
			,AdminComments
			,NextFollowUp
			,ConfirmationDraft
			,IsAutoApprovalEnabled
			,ReasonSID
			,ReviewReasonList
			,ParentRowGUID
			,UserDefinedColumns
			,ProfileUpdateXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@RegistrationYear
			,@FormVersionSID
			,@FormResponseDraft
			,@LastValidateTime
			,@AdminComments
			,@NextFollowUp
			,@ConfirmationDraft
			,@IsAutoApprovalEnabled
			,@ReasonSID
			,@ReviewReasonList
			,@ParentRowGUID
			,@UserDefinedColumns
			,@ProfileUpdateXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected     = @@rowcount
			,@ProfileUpdateSID = scope_identity()																-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.ProfileUpdate'
				,@Arg3        = @rowsAffected
				,@Arg4        = @ProfileUpdateSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Jan 2018
		-- Create the initial status for the form applying the
		-- default status (expected to be "NEW" or similar)

		insert
			dbo.ProfileUpdateStatus
		(
			 ProfileUpdateSID
			,FormStatusSID
			,CreateUser
			,UpdateUser
		)
		select
			 @ProfileUpdateSID
			,fs.FormStatusSID
			,@CreateUser
			,@CreateUser
		from
			sf.FormStatus fs
		where
			fs.IsDefault = @ON

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
				r.RoutineName = 'pProfileUpdate'
		)
		begin
		
			exec @errorNo = ext.pProfileUpdate
				 @Mode                   = 'insert.post'
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
				,@CreateUser             = @CreateUser
				,@IsReselected           = @IsReselected
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
