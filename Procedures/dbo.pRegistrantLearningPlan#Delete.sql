SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#Delete]
	 @RegistrantLearningPlanSID         int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                        nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                          timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@RegistrantSID                     int               = null
	,@RegistrationYear                  smallint          = null
	,@LearningModelSID                  int               = null
	,@FormVersionSID                    int               = null
	,@LastValidateTime                  datetimeoffset(7) = null
	,@FormResponseDraft                 xml               = null
	,@AdminComments                     xml               = null
	,@NextFollowUp                      date              = null
	,@ConfirmationDraft                 nvarchar(max)     = null
	,@ReasonSID                         int               = null
	,@IsAutoApprovalEnabled             bit               = null
	,@ReviewReasonList                  xml               = null
	,@ParentRowGUID                     uniqueidentifier  = null
	,@UserDefinedColumns                xml               = null
	,@RegistrantLearningPlanXID         varchar(150)      = null
	,@LegacyKey                         nvarchar(50)      = null
	,@IsDeleted                         bit               = null
	,@CreateUser                        nvarchar(75)      = null
	,@CreateTime                        datetimeoffset(7) = null
	,@UpdateTime                        datetimeoffset(7) = null
	,@RowGUID                           uniqueidentifier  = null
	,@LearningModelSCD                  varchar(15)       = null
	,@LearningModelLabel                nvarchar(35)      = null
	,@LearningModelIsDefault            bit               = null
	,@UnitTypeSID                       int               = null
	,@CycleLengthYears                  smallint          = null
	,@IsCycleStartedYear1               bit               = null
	,@MaximumCarryOver                  decimal(5,2)      = null
	,@LearningModelRowGUID              uniqueidentifier  = null
	,@PersonSID                         int               = null
	,@RegistrantNo                      varchar(50)       = null
	,@YearOfInitialEmployment           smallint          = null
	,@IsOnPublicRegistry                bit               = null
	,@CityNameOfBirth                   nvarchar(30)      = null
	,@CountrySID                        int               = null
	,@DirectedAuditYearCompetence       smallint          = null
	,@DirectedAuditYearPracticeHours    smallint          = null
	,@LateFeeExclusionYear              smallint          = null
	,@IsRenewalAutoApprovalBlocked      bit               = null
	,@RenewalExtensionExpiryTime        datetime          = null
	,@ArchivedTime                      datetimeoffset(7) = null
	,@RegistrantRowGUID                 uniqueidentifier  = null
	,@FormSID                           int               = null
	,@VersionNo                         smallint          = null
	,@RevisionNo                        smallint          = null
	,@IsSaveDisplayed                   bit               = null
	,@ApprovedTime                      datetimeoffset(7) = null
	,@FormVersionRowGUID                uniqueidentifier  = null
	,@ReasonGroupSID                    int               = null
	,@ReasonName                        nvarchar(50)      = null
	,@ReasonCode                        varchar(25)       = null
	,@ReasonSequence                    smallint          = null
	,@ToolTip                           nvarchar(500)     = null
	,@ReasonIsActive                    bit               = null
	,@ReasonRowGUID                     uniqueidentifier  = null
	,@IsDeleteEnabled                   bit               = null
	,@zContext                          xml               = null -- other values defining context for the delete (if any)
	,@IsViewEnabled                     bit               = null
	,@IsEditEnabled                     bit               = null
	,@IsSaveBtnDisplayed                bit               = null
	,@IsApproveEnabled                  bit               = null
	,@IsRejectEnabled                   bit               = null
	,@IsUnlockEnabled                   bit               = null
	,@IsWithdrawalEnabled               bit               = null
	,@IsInProgress                      bit               = null
	,@RegistrantLearningPlanStatusSID   int               = null
	,@RegistrantLearningPlanStatusSCD   varchar(25)       = null
	,@RegistrantLearningPlanStatusLabel nvarchar(35)      = null
	,@LastStatusChangeUser              nvarchar(75)      = null
	,@LastStatusChangeTime              datetimeoffset(7) = null
	,@FormOwnerSCD                      varchar(25)       = null
	,@FormOwnerLabel                    nvarchar(35)      = null
	,@FormOwnerSID                      int               = null
	,@IsPDFDisplayed                    bit               = null
	,@PersonDocSID                      int               = null
	,@RegistrantLearningPlanLabel       nvarchar(80)      = null
	,@RegistrationYearLabel             nvarchar(9)       = null
	,@CycleEndRegistrationYear          smallint          = null
	,@CycleRegistrationYearLabel        nvarchar(21)      = null
	,@NewFormStatusSCD                  varchar(25)       = null
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantLearningPlan#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the dbo.RegistrantLearningPlan table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrantLearningPlan table. The procedure requires a primary key value to locate the record
to delete.

If the @UpdateUser parameter is set to the special value "SystemUser", then the system user established in sf.ConfigParam is
applied.  This option is useful for conversion and system generated deletes the user would not recognized as having caused. Any
other setting of @UpdateUser is ignored and the user identity is used for the deletion.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Other parameters are provided to set context of the deletion event for table-specific and client-specific logic.

Table-specific logic can be added through tagged sections (pre and post update) and a call to an extended procedure supports
client-specific logic. Logic implemented within code tags (table-specific logic) is part of the base product and applies to all client
configurations. Calls to the extended procedure occur immediately after the table-specific logic in both "pre-delete" and "post-delete"
contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantLearningPlan procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "delete.pre" or "delete.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

This procedure is constructed to support the "Change Data Capture" (CDC) feature. Capturing the user making deletions requires
that the UpdateUser column be set before the record is deleted.  If this is not done, it is not possible to see which user
made the deletion in the CDC table. To trap audit information, the "$isDeletedColumn" bit is set to 1 in an update first.  Once
the update is complete the delete operation takes place. Both operations are handled in a single transaction so that both rollback
if either is unsuccessful. This ensures no record remains in the table with the $isDeleteColumn$ bit set to 1 (no soft-deletes).

Business rules for deletion cannot be established in constraints so must be created in this procedure for product-based common rules
and in the ext.pRegistrantLearningPlan procedure for client-specific deletion rules.

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

		if @RegistrantLearningPlanSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantLearningPlanSID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from dbo.RegistrantLearningPlan x where x.RegistrantLearningPlanSID = @RegistrantLearningPlanSID

		-- apply the table-specific pre-delete logic (if any)

		--! <PreDelete>
		-- Tim Edlund | Nov 2018
		-- Before deleting the form record, first delete any document contexts
		-- related to it and the document itself if no additional contexts remain.		

		exec dbo.pForm#Delete$PersonDoc
			 @FormRecordSID = @RegistrantLearningPlanSID
			,@ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'

		--! </PreDelete>
	
		-- call the extended version of the procedure (if it exists) for "delete.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrantLearningPlan'
		)
		begin
		
			exec @errorNo = ext.pRegistrantLearningPlan
				 @Mode                              = 'delete.pre'
				,@RegistrantLearningPlanSID         = @RegistrantLearningPlanSID
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@RegistrantSID                     = @RegistrantSID
				,@RegistrationYear                  = @RegistrationYear
				,@LearningModelSID                  = @LearningModelSID
				,@FormVersionSID                    = @FormVersionSID
				,@LastValidateTime                  = @LastValidateTime
				,@FormResponseDraft                 = @FormResponseDraft
				,@AdminComments                     = @AdminComments
				,@NextFollowUp                      = @NextFollowUp
				,@ConfirmationDraft                 = @ConfirmationDraft
				,@ReasonSID                         = @ReasonSID
				,@IsAutoApprovalEnabled             = @IsAutoApprovalEnabled
				,@ReviewReasonList                  = @ReviewReasonList
				,@ParentRowGUID                     = @ParentRowGUID
				,@UserDefinedColumns                = @UserDefinedColumns
				,@RegistrantLearningPlanXID         = @RegistrantLearningPlanXID
				,@LegacyKey                         = @LegacyKey
				,@IsDeleted                         = @IsDeleted
				,@CreateUser                        = @CreateUser
				,@CreateTime                        = @CreateTime
				,@UpdateTime                        = @UpdateTime
				,@RowGUID                           = @RowGUID
				,@LearningModelSCD                  = @LearningModelSCD
				,@LearningModelLabel                = @LearningModelLabel
				,@LearningModelIsDefault            = @LearningModelIsDefault
				,@UnitTypeSID                       = @UnitTypeSID
				,@CycleLengthYears                  = @CycleLengthYears
				,@IsCycleStartedYear1               = @IsCycleStartedYear1
				,@MaximumCarryOver                  = @MaximumCarryOver
				,@LearningModelRowGUID              = @LearningModelRowGUID
				,@PersonSID                         = @PersonSID
				,@RegistrantNo                      = @RegistrantNo
				,@YearOfInitialEmployment           = @YearOfInitialEmployment
				,@IsOnPublicRegistry                = @IsOnPublicRegistry
				,@CityNameOfBirth                   = @CityNameOfBirth
				,@CountrySID                        = @CountrySID
				,@DirectedAuditYearCompetence       = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours    = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear              = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked      = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime        = @RenewalExtensionExpiryTime
				,@ArchivedTime                      = @ArchivedTime
				,@RegistrantRowGUID                 = @RegistrantRowGUID
				,@FormSID                           = @FormSID
				,@VersionNo                         = @VersionNo
				,@RevisionNo                        = @RevisionNo
				,@IsSaveDisplayed                   = @IsSaveDisplayed
				,@ApprovedTime                      = @ApprovedTime
				,@FormVersionRowGUID                = @FormVersionRowGUID
				,@ReasonGroupSID                    = @ReasonGroupSID
				,@ReasonName                        = @ReasonName
				,@ReasonCode                        = @ReasonCode
				,@ReasonSequence                    = @ReasonSequence
				,@ToolTip                           = @ToolTip
				,@ReasonIsActive                    = @ReasonIsActive
				,@ReasonRowGUID                     = @ReasonRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@zContext                          = @zContext
				,@IsViewEnabled                     = @IsViewEnabled
				,@IsEditEnabled                     = @IsEditEnabled
				,@IsSaveBtnDisplayed                = @IsSaveBtnDisplayed
				,@IsApproveEnabled                  = @IsApproveEnabled
				,@IsRejectEnabled                   = @IsRejectEnabled
				,@IsUnlockEnabled                   = @IsUnlockEnabled
				,@IsWithdrawalEnabled               = @IsWithdrawalEnabled
				,@IsInProgress                      = @IsInProgress
				,@RegistrantLearningPlanStatusSID   = @RegistrantLearningPlanStatusSID
				,@RegistrantLearningPlanStatusSCD   = @RegistrantLearningPlanStatusSCD
				,@RegistrantLearningPlanStatusLabel = @RegistrantLearningPlanStatusLabel
				,@LastStatusChangeUser              = @LastStatusChangeUser
				,@LastStatusChangeTime              = @LastStatusChangeTime
				,@FormOwnerSCD                      = @FormOwnerSCD
				,@FormOwnerLabel                    = @FormOwnerLabel
				,@FormOwnerSID                      = @FormOwnerSID
				,@IsPDFDisplayed                    = @IsPDFDisplayed
				,@PersonDocSID                      = @PersonDocSID
				,@RegistrantLearningPlanLabel       = @RegistrantLearningPlanLabel
				,@RegistrationYearLabel             = @RegistrationYearLabel
				,@CycleEndRegistrationYear          = @CycleEndRegistrationYear
				,@CycleRegistrationYearLabel        = @CycleRegistrationYearLabel
				,@NewFormStatusSCD                  = @NewFormStatusSCD
		
		end
		
		update																																-- set audit details on dbo.LearningPlanActivity rows that will delete through CASCADE
			dbo.LearningPlanActivity
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			RegistrantLearningPlanSID = @RegistrantLearningPlanSID
		
		update																																-- set audit details on dbo.RegistrantLearningPlanResponse rows that will delete through CASCADE
			dbo.RegistrantLearningPlanResponse
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			RegistrantLearningPlanSID = @RegistrantLearningPlanSID
		
		update																																-- set audit details on dbo.RegistrantLearningPlanStatus rows that will delete through CASCADE
			dbo.RegistrantLearningPlanStatus
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			RegistrantLearningPlanSID = @RegistrantLearningPlanSID

		update																																-- update "IsDeleted" column to trap audit information
			dbo.RegistrantLearningPlan
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantLearningPlanSID = @RegistrantLearningPlanSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				dbo.RegistrantLearningPlan
			where
				RegistrantLearningPlanSID = @RegistrantLearningPlanSID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrantLearningPlan where RegistrantLearningPlanSID = @registrantLearningPlanSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrantLearningPlan'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrantLearningPlan'
					,@Arg2        = @registrantLearningPlanSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'delete'
				,@Arg2        = 'dbo.RegistrantLearningPlan'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantLearningPlanSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-delete logic (if any)

		--! <PostDelete>
		--  insert post-delete logic here ...
		--! </PostDelete>
	
		-- call the extended version of the procedure for delete.post - if it exists
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrantLearningPlan'
		)
		begin
		
			exec @errorNo = ext.pRegistrantLearningPlan
				 @Mode                              = 'delete.post'
				,@RegistrantLearningPlanSID         = @RegistrantLearningPlanSID
				,@UpdateUser                        = @UpdateUser
				,@RowStamp                          = @RowStamp
				,@RegistrantSID                     = @RegistrantSID
				,@RegistrationYear                  = @RegistrationYear
				,@LearningModelSID                  = @LearningModelSID
				,@FormVersionSID                    = @FormVersionSID
				,@LastValidateTime                  = @LastValidateTime
				,@FormResponseDraft                 = @FormResponseDraft
				,@AdminComments                     = @AdminComments
				,@NextFollowUp                      = @NextFollowUp
				,@ConfirmationDraft                 = @ConfirmationDraft
				,@ReasonSID                         = @ReasonSID
				,@IsAutoApprovalEnabled             = @IsAutoApprovalEnabled
				,@ReviewReasonList                  = @ReviewReasonList
				,@ParentRowGUID                     = @ParentRowGUID
				,@UserDefinedColumns                = @UserDefinedColumns
				,@RegistrantLearningPlanXID         = @RegistrantLearningPlanXID
				,@LegacyKey                         = @LegacyKey
				,@IsDeleted                         = @IsDeleted
				,@CreateUser                        = @CreateUser
				,@CreateTime                        = @CreateTime
				,@UpdateTime                        = @UpdateTime
				,@RowGUID                           = @RowGUID
				,@LearningModelSCD                  = @LearningModelSCD
				,@LearningModelLabel                = @LearningModelLabel
				,@LearningModelIsDefault            = @LearningModelIsDefault
				,@UnitTypeSID                       = @UnitTypeSID
				,@CycleLengthYears                  = @CycleLengthYears
				,@IsCycleStartedYear1               = @IsCycleStartedYear1
				,@MaximumCarryOver                  = @MaximumCarryOver
				,@LearningModelRowGUID              = @LearningModelRowGUID
				,@PersonSID                         = @PersonSID
				,@RegistrantNo                      = @RegistrantNo
				,@YearOfInitialEmployment           = @YearOfInitialEmployment
				,@IsOnPublicRegistry                = @IsOnPublicRegistry
				,@CityNameOfBirth                   = @CityNameOfBirth
				,@CountrySID                        = @CountrySID
				,@DirectedAuditYearCompetence       = @DirectedAuditYearCompetence
				,@DirectedAuditYearPracticeHours    = @DirectedAuditYearPracticeHours
				,@LateFeeExclusionYear              = @LateFeeExclusionYear
				,@IsRenewalAutoApprovalBlocked      = @IsRenewalAutoApprovalBlocked
				,@RenewalExtensionExpiryTime        = @RenewalExtensionExpiryTime
				,@ArchivedTime                      = @ArchivedTime
				,@RegistrantRowGUID                 = @RegistrantRowGUID
				,@FormSID                           = @FormSID
				,@VersionNo                         = @VersionNo
				,@RevisionNo                        = @RevisionNo
				,@IsSaveDisplayed                   = @IsSaveDisplayed
				,@ApprovedTime                      = @ApprovedTime
				,@FormVersionRowGUID                = @FormVersionRowGUID
				,@ReasonGroupSID                    = @ReasonGroupSID
				,@ReasonName                        = @ReasonName
				,@ReasonCode                        = @ReasonCode
				,@ReasonSequence                    = @ReasonSequence
				,@ToolTip                           = @ToolTip
				,@ReasonIsActive                    = @ReasonIsActive
				,@ReasonRowGUID                     = @ReasonRowGUID
				,@IsDeleteEnabled                   = @IsDeleteEnabled
				,@zContext                          = @zContext
				,@IsViewEnabled                     = @IsViewEnabled
				,@IsEditEnabled                     = @IsEditEnabled
				,@IsSaveBtnDisplayed                = @IsSaveBtnDisplayed
				,@IsApproveEnabled                  = @IsApproveEnabled
				,@IsRejectEnabled                   = @IsRejectEnabled
				,@IsUnlockEnabled                   = @IsUnlockEnabled
				,@IsWithdrawalEnabled               = @IsWithdrawalEnabled
				,@IsInProgress                      = @IsInProgress
				,@RegistrantLearningPlanStatusSID   = @RegistrantLearningPlanStatusSID
				,@RegistrantLearningPlanStatusSCD   = @RegistrantLearningPlanStatusSCD
				,@RegistrantLearningPlanStatusLabel = @RegistrantLearningPlanStatusLabel
				,@LastStatusChangeUser              = @LastStatusChangeUser
				,@LastStatusChangeTime              = @LastStatusChangeTime
				,@FormOwnerSCD                      = @FormOwnerSCD
				,@FormOwnerLabel                    = @FormOwnerLabel
				,@FormOwnerSID                      = @FormOwnerSID
				,@IsPDFDisplayed                    = @IsPDFDisplayed
				,@PersonDocSID                      = @PersonDocSID
				,@RegistrantLearningPlanLabel       = @RegistrantLearningPlanLabel
				,@RegistrationYearLabel             = @RegistrationYearLabel
				,@CycleEndRegistrationYear          = @CycleEndRegistrationYear
				,@CycleRegistrationYearLabel        = @CycleRegistrationYearLabel
				,@NewFormStatusSCD                  = @NewFormStatusSCD
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

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
