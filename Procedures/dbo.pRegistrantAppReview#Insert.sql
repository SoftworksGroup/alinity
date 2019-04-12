SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAppReview#Insert]
	 @RegistrantAppReviewSID         int               = null output				-- identity value assigned to the new record
	,@RegistrantAppSID               int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@FormVersionSID                 int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@ReasonSID                      int               = null								
	,@RecommendationSID              int               = null								
	,@FormResponseDraft              xml               = null								-- default: CONVERT(xml,N'<FormResponses />')
	,@LastValidateTime               datetimeoffset(7) = null								
	,@ReviewerComments               xml               = null								
	,@ConfirmationDraft              nvarchar(max)     = null								
	,@UserDefinedColumns             xml               = null								
	,@RegistrantAppReviewXID         varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@RegistrationSID                int               = null								-- not a base table column (default ignored)
	,@PracticeRegisterSectionSID     int               = null								-- not a base table column (default ignored)
	,@RegistrationYear               smallint          = null								-- not a base table column (default ignored)
	,@RegistrantAppFormVersionSID    int               = null								-- not a base table column (default ignored)
	,@OrgSID                         int               = null								-- not a base table column (default ignored)
	,@RegistrantAppLastValidateTime  datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@NextFollowUp                   date              = null								-- not a base table column (default ignored)
	,@RegistrationEffective          date              = null								-- not a base table column (default ignored)
	,@IsAutoApprovalEnabled          bit               = null								-- not a base table column (default ignored)
	,@RegistrantAppReasonSID         int               = null								-- not a base table column (default ignored)
	,@InvoiceSID                     int               = null								-- not a base table column (default ignored)
	,@RegistrantAppRowGUID           uniqueidentifier  = null								-- not a base table column (default ignored)
	,@FormSID                        int               = null								-- not a base table column (default ignored)
	,@VersionNo                      smallint          = null								-- not a base table column (default ignored)
	,@RevisionNo                     smallint          = null								-- not a base table column (default ignored)
	,@IsSaveDisplayed                bit               = null								-- not a base table column (default ignored)
	,@ApprovedTime                   datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@FormVersionRowGUID             uniqueidentifier  = null								-- not a base table column (default ignored)
	,@GenderSID                      int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                  int               = null								-- not a base table column (default ignored)
	,@FirstName                      nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                      date              = null								-- not a base table column (default ignored)
	,@DeathDate                      date              = null								-- not a base table column (default ignored)
	,@HomePhone                      varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled         bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                    nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@ReasonGroupSID                 int               = null								-- not a base table column (default ignored)
	,@ReasonName                     nvarchar(50)      = null								-- not a base table column (default ignored)
	,@ReasonCode                     varchar(25)       = null								-- not a base table column (default ignored)
	,@ReasonSequence                 smallint          = null								-- not a base table column (default ignored)
	,@ReasonToolTip                  nvarchar(500)     = null								-- not a base table column (default ignored)
	,@ReasonIsActive                 bit               = null								-- not a base table column (default ignored)
	,@ReasonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@RecommendationGroupSID         int               = null								-- not a base table column (default ignored)
	,@ButtonLabel                    nvarchar(20)      = null								-- not a base table column (default ignored)
	,@RecommendationSequence         smallint          = null								-- not a base table column (default ignored)
	,@RecommendationToolTip          nvarchar(500)     = null								-- not a base table column (default ignored)
	,@RecommendationIsActive         bit               = null								-- not a base table column (default ignored)
	,@RecommendationRowGUID          uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@ReviewerInitials               nchar(2)          = null								-- not a base table column (default ignored)
	,@RegistrantLabel                nvarchar(75)      = null								-- not a base table column (default ignored)
	,@RegistrantPersonSID            int               = null								-- not a base table column (default ignored)
	,@IsViewEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsEditEnabled                  bit               = null								-- not a base table column (default ignored)
	,@IsSaveBtnDisplayed             bit               = null								-- not a base table column (default ignored)
	,@IsUnlockEnabled                bit               = null								-- not a base table column (default ignored)
	,@IsInProgress                   bit               = null								-- not a base table column (default ignored)
	,@RegistrantAppReviewStatusSID   int               = null								-- not a base table column (default ignored)
	,@RegistrantAppReviewStatusSCD   varchar(25)       = null								-- not a base table column (default ignored)
	,@RegistrantAppReviewStatusLabel nvarchar(35)      = null								-- not a base table column (default ignored)
	,@LastStatusChangeUser           nvarchar(75)      = null								-- not a base table column (default ignored)
	,@LastStatusChangeTime           datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@FormOwnerSCD                   varchar(25)       = null								-- not a base table column (default ignored)
	,@FormOwnerLabel                 nvarchar(35)      = null								-- not a base table column (default ignored)
	,@FormOwnerSID                   int               = null								-- not a base table column (default ignored)
	,@NewFormStatusSCD               varchar(25)       = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantAppReview#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrantAppReview table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantAppReview table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantAppReview entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantAppReview procedure. The extended procedure is only called
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

	set @RegistrantAppReviewSID = null																			-- initialize output parameter

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
		set @RegistrantAppReviewXID = ltrim(rtrim(@RegistrantAppReviewXID))
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @FormResponseDraft = isnull(@FormResponseDraft,CONVERT(xml,N'<FormResponses />'))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected           = isnull(@IsReselected          ,(0))

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Mar 2017
		-- If a form version was not set, default it to the latest approved version
		-- of the application review form for the given practice-register. The
		-- parent key MUST be passed.

		if @FormVersionSID is null
		begin
		
			select
				@FormVersionSID = max(fv.FormVersionSID)
			from
				dbo.RegistrantApp											ra
			join
				dbo.PracticeRegisterSection						prs	on ra.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegisterForm              prf	on prs.PracticeRegisterSID = prf.PracticeRegisterSID
			join
				sf.Form                               f   on prf.FormSID = f.FormSID
			join
				sf.FormType                           ft  on f.FormTypeSID = ft.FormTypeSID and ft.FormTypeSCD = 'APPLICATION.REVIEW'			-- only include application review forms
			join
				sf.FormVersion                        fv  on f.FormSID = fv.FormSID and fv.VersionNo > 0																	-- filter out non-published versions
			where
				ra.RegistrantAppSID = @RegistrantAppSID

			if @FormVersionSID is null
			begin

				exec sf.pMessage#Get
						@MessageSCD  = 'ConfigurationNotComplete'
					,@MessageText = @errorText output
					,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'					,@Arg1        = 'Application Review Form: (This) Practice Register'

				raiserror(@errorText, 17, 1)
			
			end

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
				r.RoutineName = 'pRegistrantAppReview'
		)
		begin
		
			exec @errorNo = ext.pRegistrantAppReview
				 @Mode                           = 'insert.pre'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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

		-- insert the record

		insert
			dbo.RegistrantAppReview
		(
			 RegistrantAppSID
			,FormVersionSID
			,PersonSID
			,ReasonSID
			,RecommendationSID
			,FormResponseDraft
			,LastValidateTime
			,ReviewerComments
			,ConfirmationDraft
			,UserDefinedColumns
			,RegistrantAppReviewXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantAppSID
			,@FormVersionSID
			,@PersonSID
			,@ReasonSID
			,@RecommendationSID
			,@FormResponseDraft
			,@LastValidateTime
			,@ReviewerComments
			,@ConfirmationDraft
			,@UserDefinedColumns
			,@RegistrantAppReviewXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected           = @@rowcount
			,@RegistrantAppReviewSID = scope_identity()													-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrantAppReview'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantAppReviewSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Apr 2017
		-- Create the initial status row for the form applying the
		-- default status (expected to be "NEW" or similar)

		insert
			dbo.RegistrantAppReviewStatus
		(
			 RegistrantAppReviewSID
			,FormStatusSID
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrantAppReviewSID
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
				r.RoutineName = 'pRegistrantAppReview'
		)
		begin
		
			exec @errorNo = ext.pRegistrantAppReview
				 @Mode                           = 'insert.post'
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
				,@CreateUser                     = @CreateUser
				,@IsReselected                   = @IsReselected
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
