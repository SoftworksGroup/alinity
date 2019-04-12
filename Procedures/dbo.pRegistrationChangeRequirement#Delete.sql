SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChangeRequirement#Delete]
	 @RegistrationChangeRequirementSID        int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                              nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@RegistrationChangeSID                   int               = null
	,@RegistrationRequirementSID              int               = null
	,@PersonDocSID                            int               = null
	,@RegistrantExamSID                       int               = null
	,@ExpiryMonths                            smallint          = null
	,@RequirementStatusSID                    int               = null
	,@RequirementSequence                     int               = null
	,@UserDefinedColumns                      xml               = null
	,@RegistrationChangeRequirementXID        varchar(150)      = null
	,@LegacyKey                               nvarchar(50)      = null
	,@IsDeleted                               bit               = null
	,@CreateUser                              nvarchar(75)      = null
	,@CreateTime                              datetimeoffset(7) = null
	,@UpdateTime                              datetimeoffset(7) = null
	,@RowGUID                                 uniqueidentifier  = null
	,@RegistrationSID                         int               = null
	,@PracticeRegisterSectionSID              int               = null
	,@RegistrationYear                        smallint          = null
	,@NextFollowUp                            date              = null
	,@RegistrationEffective                   date              = null
	,@ReservedRegistrantNo                    varchar(50)       = null
	,@ReasonSID                               int               = null
	,@RegistrationChangeInvoiceSID            int               = null
	,@ComplaintSID                            int               = null
	,@RegistrationChangeRowGUID               uniqueidentifier  = null
	,@RegistrationRequirementTypeSID          int               = null
	,@RegistrationRequirementLabel            nvarchar(35)      = null
	,@RegistrationRequirementPersonDocTypeSID int               = null
	,@RegistrationRequirementExamSID          int               = null
	,@RegistrationRequirementExpiryMonths     smallint          = null
	,@RegistrationRequirementIsActive         bit               = null
	,@RegistrationRequirementRowGUID          uniqueidentifier  = null
	,@RequirementStatusSCD                    varchar(10)       = null
	,@RequirementStatusLabel                  nvarchar(35)      = null
	,@IsFinal                                 bit               = null
	,@RequirementStatusSequence               int               = null
	,@RequirementStatusIsDefault              bit               = null
	,@RequirementStatusRowGUID                uniqueidentifier  = null
	,@PersonSID                               int               = null
	,@PersonDocPersonDocTypeSID               int               = null
	,@DocumentTitle                           nvarchar(100)     = null
	,@AdditionalInfo                          nvarchar(50)      = null
	,@ArchivedTime                            datetimeoffset(7) = null
	,@FileTypeSID                             int               = null
	,@FileTypeSCD                             varchar(8)        = null
	,@ShowToRegistrant                        bit               = null
	,@ApplicationGrantSID                     int               = null
	,@IsRemoved                               bit               = null
	,@ExpiryDate                              date              = null
	,@ApplicationReportSID                    int               = null
	,@ReportEntitySID                         int               = null
	,@PersonDocCancelledTime                  datetimeoffset(7) = null
	,@PersonDocProcessedTime                  datetimeoffset(7) = null
	,@ContextLink                             uniqueidentifier  = null
	,@PersonDocRowGUID                        uniqueidentifier  = null
	,@RegistrantSID                           int               = null
	,@RegistrantExamExamSID                   int               = null
	,@ExamDate                                date              = null
	,@ExamResultDate                          date              = null
	,@PassingScore                            int               = null
	,@Score                                   int               = null
	,@ExamStatusSID                           int               = null
	,@SchedulingPreferences                   nvarchar(1000)    = null
	,@AssignedLocation                        varchar(15)       = null
	,@ExamReference                           varchar(25)       = null
	,@ExamOfferingSID                         int               = null
	,@RegistrantExamInvoiceSID                int               = null
	,@ConfirmedTime                           datetimeoffset(7) = null
	,@RegistrantExamCancelledTime             datetimeoffset(7) = null
	,@RegistrantExamProcessedTime             datetimeoffset(7) = null
	,@RegistrantExamRowGUID                   uniqueidentifier  = null
	,@IsDeleteEnabled                         bit               = null
	,@zContext                                xml               = null -- other values defining context for the delete (if any)
	,@IsMandatory                             bit               = null
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChangeRequirement#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the dbo.RegistrationChangeRequirement table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationChangeRequirement table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pRegistrationChangeRequirement procedure. The extended procedure is only called
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
and in the ext.pRegistrationChangeRequirement procedure for client-specific deletion rules.

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

		if @RegistrationChangeRequirementSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationChangeRequirementSID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from dbo.RegistrationChangeRequirement x where x.RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID

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
				r.RoutineName = 'pRegistrationChangeRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChangeRequirement
				 @Mode                                    = 'delete.pre'
				,@RegistrationChangeRequirementSID        = @RegistrationChangeRequirementSID
				,@UpdateUser                              = @UpdateUser
				,@RowStamp                                = @RowStamp
				,@RegistrationChangeSID                   = @RegistrationChangeSID
				,@RegistrationRequirementSID              = @RegistrationRequirementSID
				,@PersonDocSID                            = @PersonDocSID
				,@RegistrantExamSID                       = @RegistrantExamSID
				,@ExpiryMonths                            = @ExpiryMonths
				,@RequirementStatusSID                    = @RequirementStatusSID
				,@RequirementSequence                     = @RequirementSequence
				,@UserDefinedColumns                      = @UserDefinedColumns
				,@RegistrationChangeRequirementXID        = @RegistrationChangeRequirementXID
				,@LegacyKey                               = @LegacyKey
				,@IsDeleted                               = @IsDeleted
				,@CreateUser                              = @CreateUser
				,@CreateTime                              = @CreateTime
				,@UpdateTime                              = @UpdateTime
				,@RowGUID                                 = @RowGUID
				,@RegistrationSID                         = @RegistrationSID
				,@PracticeRegisterSectionSID              = @PracticeRegisterSectionSID
				,@RegistrationYear                        = @RegistrationYear
				,@NextFollowUp                            = @NextFollowUp
				,@RegistrationEffective                   = @RegistrationEffective
				,@ReservedRegistrantNo                    = @ReservedRegistrantNo
				,@ReasonSID                               = @ReasonSID
				,@RegistrationChangeInvoiceSID            = @RegistrationChangeInvoiceSID
				,@ComplaintSID                            = @ComplaintSID
				,@RegistrationChangeRowGUID               = @RegistrationChangeRowGUID
				,@RegistrationRequirementTypeSID          = @RegistrationRequirementTypeSID
				,@RegistrationRequirementLabel            = @RegistrationRequirementLabel
				,@RegistrationRequirementPersonDocTypeSID = @RegistrationRequirementPersonDocTypeSID
				,@RegistrationRequirementExamSID          = @RegistrationRequirementExamSID
				,@RegistrationRequirementExpiryMonths     = @RegistrationRequirementExpiryMonths
				,@RegistrationRequirementIsActive         = @RegistrationRequirementIsActive
				,@RegistrationRequirementRowGUID          = @RegistrationRequirementRowGUID
				,@RequirementStatusSCD                    = @RequirementStatusSCD
				,@RequirementStatusLabel                  = @RequirementStatusLabel
				,@IsFinal                                 = @IsFinal
				,@RequirementStatusSequence               = @RequirementStatusSequence
				,@RequirementStatusIsDefault              = @RequirementStatusIsDefault
				,@RequirementStatusRowGUID                = @RequirementStatusRowGUID
				,@PersonSID                               = @PersonSID
				,@PersonDocPersonDocTypeSID               = @PersonDocPersonDocTypeSID
				,@DocumentTitle                           = @DocumentTitle
				,@AdditionalInfo                          = @AdditionalInfo
				,@ArchivedTime                            = @ArchivedTime
				,@FileTypeSID                             = @FileTypeSID
				,@FileTypeSCD                             = @FileTypeSCD
				,@ShowToRegistrant                        = @ShowToRegistrant
				,@ApplicationGrantSID                     = @ApplicationGrantSID
				,@IsRemoved                               = @IsRemoved
				,@ExpiryDate                              = @ExpiryDate
				,@ApplicationReportSID                    = @ApplicationReportSID
				,@ReportEntitySID                         = @ReportEntitySID
				,@PersonDocCancelledTime                  = @PersonDocCancelledTime
				,@PersonDocProcessedTime                  = @PersonDocProcessedTime
				,@ContextLink                             = @ContextLink
				,@PersonDocRowGUID                        = @PersonDocRowGUID
				,@RegistrantSID                           = @RegistrantSID
				,@RegistrantExamExamSID                   = @RegistrantExamExamSID
				,@ExamDate                                = @ExamDate
				,@ExamResultDate                          = @ExamResultDate
				,@PassingScore                            = @PassingScore
				,@Score                                   = @Score
				,@ExamStatusSID                           = @ExamStatusSID
				,@SchedulingPreferences                   = @SchedulingPreferences
				,@AssignedLocation                        = @AssignedLocation
				,@ExamReference                           = @ExamReference
				,@ExamOfferingSID                         = @ExamOfferingSID
				,@RegistrantExamInvoiceSID                = @RegistrantExamInvoiceSID
				,@ConfirmedTime                           = @ConfirmedTime
				,@RegistrantExamCancelledTime             = @RegistrantExamCancelledTime
				,@RegistrantExamProcessedTime             = @RegistrantExamProcessedTime
				,@RegistrantExamRowGUID                   = @RegistrantExamRowGUID
				,@IsDeleteEnabled                         = @IsDeleteEnabled
				,@zContext                                = @zContext
				,@IsMandatory                             = @IsMandatory
		
		end

		update																																-- update "IsDeleted" column to trap audit information
			dbo.RegistrationChangeRequirement
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				dbo.RegistrationChangeRequirement
			where
				RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationChangeRequirement where RegistrationChangeRequirementSID = @registrationChangeRequirementSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationChangeRequirement'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationChangeRequirement'
					,@Arg2        = @registrationChangeRequirementSID
				
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
				,@Arg2        = 'dbo.RegistrationChangeRequirement'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationChangeRequirementSID
			
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
				r.RoutineName = 'pRegistrationChangeRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChangeRequirement
				 @Mode                                    = 'delete.post'
				,@RegistrationChangeRequirementSID        = @RegistrationChangeRequirementSID
				,@UpdateUser                              = @UpdateUser
				,@RowStamp                                = @RowStamp
				,@RegistrationChangeSID                   = @RegistrationChangeSID
				,@RegistrationRequirementSID              = @RegistrationRequirementSID
				,@PersonDocSID                            = @PersonDocSID
				,@RegistrantExamSID                       = @RegistrantExamSID
				,@ExpiryMonths                            = @ExpiryMonths
				,@RequirementStatusSID                    = @RequirementStatusSID
				,@RequirementSequence                     = @RequirementSequence
				,@UserDefinedColumns                      = @UserDefinedColumns
				,@RegistrationChangeRequirementXID        = @RegistrationChangeRequirementXID
				,@LegacyKey                               = @LegacyKey
				,@IsDeleted                               = @IsDeleted
				,@CreateUser                              = @CreateUser
				,@CreateTime                              = @CreateTime
				,@UpdateTime                              = @UpdateTime
				,@RowGUID                                 = @RowGUID
				,@RegistrationSID                         = @RegistrationSID
				,@PracticeRegisterSectionSID              = @PracticeRegisterSectionSID
				,@RegistrationYear                        = @RegistrationYear
				,@NextFollowUp                            = @NextFollowUp
				,@RegistrationEffective                   = @RegistrationEffective
				,@ReservedRegistrantNo                    = @ReservedRegistrantNo
				,@ReasonSID                               = @ReasonSID
				,@RegistrationChangeInvoiceSID            = @RegistrationChangeInvoiceSID
				,@ComplaintSID                            = @ComplaintSID
				,@RegistrationChangeRowGUID               = @RegistrationChangeRowGUID
				,@RegistrationRequirementTypeSID          = @RegistrationRequirementTypeSID
				,@RegistrationRequirementLabel            = @RegistrationRequirementLabel
				,@RegistrationRequirementPersonDocTypeSID = @RegistrationRequirementPersonDocTypeSID
				,@RegistrationRequirementExamSID          = @RegistrationRequirementExamSID
				,@RegistrationRequirementExpiryMonths     = @RegistrationRequirementExpiryMonths
				,@RegistrationRequirementIsActive         = @RegistrationRequirementIsActive
				,@RegistrationRequirementRowGUID          = @RegistrationRequirementRowGUID
				,@RequirementStatusSCD                    = @RequirementStatusSCD
				,@RequirementStatusLabel                  = @RequirementStatusLabel
				,@IsFinal                                 = @IsFinal
				,@RequirementStatusSequence               = @RequirementStatusSequence
				,@RequirementStatusIsDefault              = @RequirementStatusIsDefault
				,@RequirementStatusRowGUID                = @RequirementStatusRowGUID
				,@PersonSID                               = @PersonSID
				,@PersonDocPersonDocTypeSID               = @PersonDocPersonDocTypeSID
				,@DocumentTitle                           = @DocumentTitle
				,@AdditionalInfo                          = @AdditionalInfo
				,@ArchivedTime                            = @ArchivedTime
				,@FileTypeSID                             = @FileTypeSID
				,@FileTypeSCD                             = @FileTypeSCD
				,@ShowToRegistrant                        = @ShowToRegistrant
				,@ApplicationGrantSID                     = @ApplicationGrantSID
				,@IsRemoved                               = @IsRemoved
				,@ExpiryDate                              = @ExpiryDate
				,@ApplicationReportSID                    = @ApplicationReportSID
				,@ReportEntitySID                         = @ReportEntitySID
				,@PersonDocCancelledTime                  = @PersonDocCancelledTime
				,@PersonDocProcessedTime                  = @PersonDocProcessedTime
				,@ContextLink                             = @ContextLink
				,@PersonDocRowGUID                        = @PersonDocRowGUID
				,@RegistrantSID                           = @RegistrantSID
				,@RegistrantExamExamSID                   = @RegistrantExamExamSID
				,@ExamDate                                = @ExamDate
				,@ExamResultDate                          = @ExamResultDate
				,@PassingScore                            = @PassingScore
				,@Score                                   = @Score
				,@ExamStatusSID                           = @ExamStatusSID
				,@SchedulingPreferences                   = @SchedulingPreferences
				,@AssignedLocation                        = @AssignedLocation
				,@ExamReference                           = @ExamReference
				,@ExamOfferingSID                         = @ExamOfferingSID
				,@RegistrantExamInvoiceSID                = @RegistrantExamInvoiceSID
				,@ConfirmedTime                           = @ConfirmedTime
				,@RegistrantExamCancelledTime             = @RegistrantExamCancelledTime
				,@RegistrantExamProcessedTime             = @RegistrantExamProcessedTime
				,@RegistrantExamRowGUID                   = @RegistrantExamRowGUID
				,@IsDeleteEnabled                         = @IsDeleteEnabled
				,@zContext                                = @zContext
				,@IsMandatory                             = @IsMandatory
		
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
