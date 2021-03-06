SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pLearningPlanActivity#Delete]
	 @LearningPlanActivitySID        int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@RegistrantLearningPlanSID      int               = null
	,@CompetenceTypeActivitySID      int               = null
	,@UnitValue                      decimal(5,2)      = null
	,@CarryOverUnitValue             decimal(5,2)      = null
	,@ActivityDate                   date              = null
	,@LearningClaimTypeSID           int               = null
	,@LearningPlanActivityCategory   nvarchar(65)      = null
	,@ActivityDescription            nvarchar(max)     = null
	,@PlannedCompletion              date              = null
	,@OrgSID                         int               = null
	,@IsSubjectToReview              bit               = null
	,@IsArchived                     bit               = null
	,@UserDefinedColumns             xml               = null
	,@LearningPlanActivityXID        varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@IsDeleted                      bit               = null
	,@CreateUser                     nvarchar(75)      = null
	,@CreateTime                     datetimeoffset(7) = null
	,@UpdateTime                     datetimeoffset(7) = null
	,@RowGUID                        uniqueidentifier  = null
	,@CompetenceTypeSID              int               = null
	,@CompetenceActivitySID          int               = null
	,@EffectiveTime                  datetime          = null
	,@ExpiryTime                     datetime          = null
	,@CompetenceTypeActivityRowGUID  uniqueidentifier  = null
	,@LearningClaimTypeLabel         nvarchar(35)      = null
	,@LearningClaimTypeCategory      nvarchar(65)      = null
	,@IsValidForRenewal              bit               = null
	,@IsComplete                     bit               = null
	,@IsWithdrawn                    bit               = null
	,@LearningClaimTypeIsDefault     bit               = null
	,@LearningClaimTypeIsActive      bit               = null
	,@LearningClaimTypeRowGUID       uniqueidentifier  = null
	,@RegistrantSID                  int               = null
	,@RegistrationYear               smallint          = null
	,@LearningModelSID               int               = null
	,@FormVersionSID                 int               = null
	,@LastValidateTime               datetimeoffset(7) = null
	,@NextFollowUp                   date              = null
	,@ReasonSID                      int               = null
	,@IsAutoApprovalEnabled          bit               = null
	,@ParentRowGUID                  uniqueidentifier  = null
	,@RegistrantLearningPlanRowGUID  uniqueidentifier  = null
	,@ParentOrgSID                   int               = null
	,@OrgTypeSID                     int               = null
	,@OrgName                        nvarchar(150)     = null
	,@OrgLabel                       nvarchar(35)      = null
	,@StreetAddress1                 nvarchar(75)      = null
	,@StreetAddress2                 nvarchar(75)      = null
	,@StreetAddress3                 nvarchar(75)      = null
	,@CitySID                        int               = null
	,@PostalCode                     varchar(10)       = null
	,@RegionSID                      int               = null
	,@Phone                          varchar(25)       = null
	,@Fax                            varchar(25)       = null
	,@WebSite                        varchar(250)      = null
	,@EmailAddress                   varchar(150)      = null
	,@InsuranceOrgSID                int               = null
	,@InsurancePolicyNo              varchar(25)       = null
	,@InsuranceAmount                decimal(11,2)     = null
	,@IsEmployer                     bit               = null
	,@IsCredentialAuthority          bit               = null
	,@IsInsurer                      bit               = null
	,@IsInsuranceCertificateRequired bit               = null
	,@IsPublic                       nchar(10)         = null
	,@OrgIsActive                    bit               = null
	,@IsAdminReviewRequired          bit               = null
	,@LastVerifiedTime               datetimeoffset(7) = null
	,@OrgRowGUID                     uniqueidentifier  = null
	,@IsDeleteEnabled                bit               = null
	,@zContext                       xml               = null -- other values defining context for the delete (if any)
as
/*********************************************************************************************************************************
Procedure : dbo.pLearningPlanActivity#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the dbo.LearningPlanActivity table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.LearningPlanActivity table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pLearningPlanActivity procedure. The extended procedure is only called
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
and in the ext.pLearningPlanActivity procedure for client-specific deletion rules.

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

		if @LearningPlanActivitySID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@LearningPlanActivitySID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from dbo.LearningPlanActivity x where x.LearningPlanActivitySID = @LearningPlanActivitySID

		-- apply the table-specific pre-delete logic (if any)

		--! <PreDelete>
		--  insert pre-delete logic here ...
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
				r.RoutineName = 'pLearningPlanActivity'
		)
		begin
		
			exec @errorNo = ext.pLearningPlanActivity
				 @Mode                           = 'delete.pre'
				,@LearningPlanActivitySID        = @LearningPlanActivitySID
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
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
				,@IsDeleted                      = @IsDeleted
				,@CreateUser                     = @CreateUser
				,@CreateTime                     = @CreateTime
				,@UpdateTime                     = @UpdateTime
				,@RowGUID                        = @RowGUID
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
				,@zContext                       = @zContext
		
		end

		update																																-- update "IsDeleted" column to trap audit information
			dbo.LearningPlanActivity
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			LearningPlanActivitySID = @LearningPlanActivitySID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				dbo.LearningPlanActivity
			where
				LearningPlanActivitySID = @LearningPlanActivitySID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.LearningPlanActivity where LearningPlanActivitySID = @learningPlanActivitySID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.LearningPlanActivity'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.LearningPlanActivity'
					,@Arg2        = @learningPlanActivitySID
				
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
				,@Arg2        = 'dbo.LearningPlanActivity'
				,@Arg3        = @rowsAffected
				,@Arg4        = @learningPlanActivitySID
			
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
				r.RoutineName = 'pLearningPlanActivity'
		)
		begin
		
			exec @errorNo = ext.pLearningPlanActivity
				 @Mode                           = 'delete.post'
				,@LearningPlanActivitySID        = @LearningPlanActivitySID
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
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
				,@IsDeleted                      = @IsDeleted
				,@CreateUser                     = @CreateUser
				,@CreateTime                     = @CreateTime
				,@UpdateTime                     = @UpdateTime
				,@RowGUID                        = @RowGUID
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
				,@zContext                       = @zContext
		
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
