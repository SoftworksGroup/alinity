SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChange#Delete]
	 @RegistrationChangeSID                  int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@RegistrationSID                        int               = null
	,@PracticeRegisterSectionSID             int               = null
	,@RegistrationYear                       smallint          = null
	,@NextFollowUp                           date              = null
	,@RegistrationEffective                  date              = null
	,@ReservedRegistrantNo                   varchar(50)       = null
	,@ConfirmationDraft                      nvarchar(max)     = null
	,@ReasonSID                              int               = null
	,@InvoiceSID                             int               = null
	,@ComplaintSID                           int               = null
	,@UserDefinedColumns                     xml               = null
	,@RegistrationChangeXID                  varchar(150)      = null
	,@LegacyKey                              nvarchar(50)      = null
	,@IsDeleted                              bit               = null
	,@CreateUser                             nvarchar(75)      = null
	,@CreateTime                             datetimeoffset(7) = null
	,@UpdateTime                             datetimeoffset(7) = null
	,@RowGUID                                uniqueidentifier  = null
	,@PracticeRegisterSID                    int               = null
	,@PracticeRegisterSectionLabel           nvarchar(35)      = null
	,@PracticeRegisterSectionIsDefault       bit               = null
	,@IsDisplayedOnLicense                   bit               = null
	,@PracticeRegisterSectionIsActive        bit               = null
	,@PracticeRegisterSectionRowGUID         uniqueidentifier  = null
	,@RegistrationRegistrantSID              int               = null
	,@RegistrationPracticeRegisterSectionSID int               = null
	,@RegistrationNo                         nvarchar(50)      = null
	,@RegistrationRegistrationYear           smallint          = null
	,@EffectiveTime                          datetime          = null
	,@ExpiryTime                             datetime          = null
	,@CardPrintedTime                        datetime          = null
	,@RegistrationInvoiceSID                 int               = null
	,@RegistrationReasonSID                  int               = null
	,@FormGUID                               uniqueidentifier  = null
	,@RegistrationRowGUID                    uniqueidentifier  = null
	,@ReasonGroupSID                         int               = null
	,@ReasonName                             nvarchar(50)      = null
	,@ReasonCode                             varchar(25)       = null
	,@ReasonSequence                         smallint          = null
	,@ToolTip                                nvarchar(500)     = null
	,@ReasonIsActive                         bit               = null
	,@ReasonRowGUID                          uniqueidentifier  = null
	,@ComplaintNo                            varchar(50)       = null
	,@ComplaintRegistrantSID                 int               = null
	,@ComplaintTypeSID                       int               = null
	,@ComplainantTypeSID                     int               = null
	,@ApplicationUserSID                     int               = null
	,@OpenedDate                             date              = null
	,@ConductStartDate                       date              = null
	,@ConductEndDate                         date              = null
	,@ComplaintSeveritySID                   int               = null
	,@IsDisplayedOnPublicRegistry            bit               = null
	,@ClosedDate                             date              = null
	,@DismissedDate                          date              = null
	,@ComplaintReasonSID                     int               = null
	,@FileExtension                          varchar(5)        = null
	,@ComplaintRowGUID                       uniqueidentifier  = null
	,@PersonSID                              int               = null
	,@InvoiceDate                            date              = null
	,@Tax1Label                              nvarchar(8)       = null
	,@Tax1Rate                               decimal(4,4)      = null
	,@Tax1GLAccountCode                      varchar(50)       = null
	,@Tax2Label                              nvarchar(8)       = null
	,@Tax2Rate                               decimal(4,4)      = null
	,@Tax2GLAccountCode                      varchar(50)       = null
	,@Tax3Label                              nvarchar(8)       = null
	,@Tax3Rate                               decimal(4,4)      = null
	,@Tax3GLAccountCode                      varchar(50)       = null
	,@InvoiceRegistrationYear                smallint          = null
	,@CancelledTime                          datetimeoffset(7) = null
	,@InvoiceReasonSID                       int               = null
	,@IsRefund                               bit               = null
	,@InvoiceComplaintSID                    int               = null
	,@InvoiceRowGUID                         uniqueidentifier  = null
	,@IsDeleteEnabled                        bit               = null
	,@zContext                               xml               = null -- other values defining context for the delete (if any)
	,@IsViewEnabled                          bit               = null
	,@IsEditEnabled                          bit               = null
	,@IsApproveEnabled                       bit               = null
	,@IsRejectEnabled                        bit               = null
	,@IsUnlockEnabled                        bit               = null
	,@IsWithdrawalEnabled                    bit               = null
	,@IsInProgress                           bit               = null
	,@FormStatusSID                          int               = null
	,@FormStatusSCD                          varchar(25)       = null
	,@FormStatusLabel                        nvarchar(35)      = null
	,@LastStatusChangeUser                   nvarchar(75)      = null
	,@LastStatusChangeTime                   datetimeoffset(7) = null
	,@FormOwnerSID                           int               = null
	,@FormOwnerSCD                           varchar(25)       = null
	,@FormOwnerLabel                         nvarchar(35)      = null
	,@IsPDFDisplayed                         bit               = null
	,@PersonDocSID                           int               = null
	,@TotalDue                               decimal(11,2)     = null
	,@IsUnPaid                               bit               = null
	,@PersonMailingAddressSID                int               = null
	,@PersonStreetAddress1                   nvarchar(75)      = null
	,@PersonStreetAddress2                   nvarchar(75)      = null
	,@PersonStreetAddress3                   nvarchar(75)      = null
	,@PersonCityName                         nvarchar(30)      = null
	,@PersonStateProvinceName                nvarchar(30)      = null
	,@PersonPostalCode                       nvarchar(10)      = null
	,@PersonCountryName                      nvarchar(50)      = null
	,@PersonCitySID                          int               = null
	,@RegistrantPersonSID                    int               = null
	,@RegistrationYearLabel                  varchar(9)        = null
	,@PracticeRegisterLabel                  nvarchar(35)      = null
	,@PracticeRegisterName                   nvarchar(65)      = null
	,@RegistrationChangeLabel                nvarchar(100)     = null
	,@IsRegisterChange                       bit               = null
	,@HasOpenAudit                           bit               = null
	,@NewFormStatusSCD                       varchar(25)       = null
	,@ReasonSIDOnApprove                     int               = null
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChange#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the dbo.RegistrationChange table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationChange table. The procedure requires a primary key value to locate the record
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

Client specific customizations must be implemented in the ext.pRegistrationChange procedure. The extended procedure is only called
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
and in the ext.pRegistrationChange procedure for client-specific deletion rules.

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

		if @RegistrationChangeSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationChangeSID'

			raiserror(@errorText, 18, 1)
		end

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from dbo.RegistrationChange x where x.RegistrationChangeSID = @RegistrationChangeSID

		-- apply the table-specific pre-delete logic (if any)

		--! <PreDelete>
		-- Tim Edlund | Nov 2018
		-- Before deleting the form record, first delete any document contexts
		-- related to it and the document itself if no additional contexts remain.

		exec dbo.pForm#Delete$PersonDoc
			 @FormRecordSID = @RegistrationChangeSID
			,@ApplicationEntitySCD = 'dbo.RegistrationChange'
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
				r.RoutineName = 'pRegistrationChange'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChange
				 @Mode                                   = 'delete.pre'
				,@RegistrationChangeSID                  = @RegistrationChangeSID
				,@UpdateUser                             = @UpdateUser
				,@RowStamp                               = @RowStamp
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@NextFollowUp                           = @NextFollowUp
				,@RegistrationEffective                  = @RegistrationEffective
				,@ReservedRegistrantNo                   = @ReservedRegistrantNo
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ComplaintSID                           = @ComplaintSID
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@RegistrationChangeXID                  = @RegistrationChangeXID
				,@LegacyKey                              = @LegacyKey
				,@IsDeleted                              = @IsDeleted
				,@CreateUser                             = @CreateUser
				,@CreateTime                             = @CreateTime
				,@UpdateTime                             = @UpdateTime
				,@RowGUID                                = @RowGUID
				,@PracticeRegisterSID                    = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel           = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault       = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                   = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive        = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID         = @PracticeRegisterSectionRowGUID
				,@RegistrationRegistrantSID              = @RegistrationRegistrantSID
				,@RegistrationPracticeRegisterSectionSID = @RegistrationPracticeRegisterSectionSID
				,@RegistrationNo                         = @RegistrationNo
				,@RegistrationRegistrationYear           = @RegistrationRegistrationYear
				,@EffectiveTime                          = @EffectiveTime
				,@ExpiryTime                             = @ExpiryTime
				,@CardPrintedTime                        = @CardPrintedTime
				,@RegistrationInvoiceSID                 = @RegistrationInvoiceSID
				,@RegistrationReasonSID                  = @RegistrationReasonSID
				,@FormGUID                               = @FormGUID
				,@RegistrationRowGUID                    = @RegistrationRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
				,@ComplaintNo                            = @ComplaintNo
				,@ComplaintRegistrantSID                 = @ComplaintRegistrantSID
				,@ComplaintTypeSID                       = @ComplaintTypeSID
				,@ComplainantTypeSID                     = @ComplainantTypeSID
				,@ApplicationUserSID                     = @ApplicationUserSID
				,@OpenedDate                             = @OpenedDate
				,@ConductStartDate                       = @ConductStartDate
				,@ConductEndDate                         = @ConductEndDate
				,@ComplaintSeveritySID                   = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry            = @IsDisplayedOnPublicRegistry
				,@ClosedDate                             = @ClosedDate
				,@DismissedDate                          = @DismissedDate
				,@ComplaintReasonSID                     = @ComplaintReasonSID
				,@FileExtension                          = @FileExtension
				,@ComplaintRowGUID                       = @ComplaintRowGUID
				,@PersonSID                              = @PersonSID
				,@InvoiceDate                            = @InvoiceDate
				,@Tax1Label                              = @Tax1Label
				,@Tax1Rate                               = @Tax1Rate
				,@Tax1GLAccountCode                      = @Tax1GLAccountCode
				,@Tax2Label                              = @Tax2Label
				,@Tax2Rate                               = @Tax2Rate
				,@Tax2GLAccountCode                      = @Tax2GLAccountCode
				,@Tax3Label                              = @Tax3Label
				,@Tax3Rate                               = @Tax3Rate
				,@Tax3GLAccountCode                      = @Tax3GLAccountCode
				,@InvoiceRegistrationYear                = @InvoiceRegistrationYear
				,@CancelledTime                          = @CancelledTime
				,@InvoiceReasonSID                       = @InvoiceReasonSID
				,@IsRefund                               = @IsRefund
				,@InvoiceComplaintSID                    = @InvoiceComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@zContext                               = @zContext
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@FormStatusSID                          = @FormStatusSID
				,@FormStatusSCD                          = @FormStatusSCD
				,@FormStatusLabel                        = @FormStatusLabel
				,@LastStatusChangeUser                   = @LastStatusChangeUser
				,@LastStatusChangeTime                   = @LastStatusChangeTime
				,@FormOwnerSID                           = @FormOwnerSID
				,@FormOwnerSCD                           = @FormOwnerSCD
				,@FormOwnerLabel                         = @FormOwnerLabel
				,@IsPDFDisplayed                         = @IsPDFDisplayed
				,@PersonDocSID                           = @PersonDocSID
				,@TotalDue                               = @TotalDue
				,@IsUnPaid                               = @IsUnPaid
				,@PersonMailingAddressSID                = @PersonMailingAddressSID
				,@PersonStreetAddress1                   = @PersonStreetAddress1
				,@PersonStreetAddress2                   = @PersonStreetAddress2
				,@PersonStreetAddress3                   = @PersonStreetAddress3
				,@PersonCityName                         = @PersonCityName
				,@PersonStateProvinceName                = @PersonStateProvinceName
				,@PersonPostalCode                       = @PersonPostalCode
				,@PersonCountryName                      = @PersonCountryName
				,@PersonCitySID                          = @PersonCitySID
				,@RegistrantPersonSID                    = @RegistrantPersonSID
				,@RegistrationYearLabel                  = @RegistrationYearLabel
				,@PracticeRegisterLabel                  = @PracticeRegisterLabel
				,@PracticeRegisterName                   = @PracticeRegisterName
				,@RegistrationChangeLabel                = @RegistrationChangeLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
		end
		
		update																																-- set audit details on dbo.RegistrationChangeStatus rows that will delete through CASCADE
			dbo.RegistrationChangeStatus
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			RegistrationChangeSID = @RegistrationChangeSID

		update																																-- update "IsDeleted" column to trap audit information
			dbo.RegistrationChange
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationChangeSID = @RegistrationChangeSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				dbo.RegistrationChange
			where
				RegistrationChangeSID = @RegistrationChangeSID
			
			set @rowsAffected = @@rowcount
			
		end

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationChange where RegistrationChangeSID = @registrationChangeSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationChange'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationChange'
					,@Arg2        = @registrationChangeSID
				
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
				,@Arg2        = 'dbo.RegistrationChange'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationChangeSID
			
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
				r.RoutineName = 'pRegistrationChange'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChange
				 @Mode                                   = 'delete.post'
				,@RegistrationChangeSID                  = @RegistrationChangeSID
				,@UpdateUser                             = @UpdateUser
				,@RowStamp                               = @RowStamp
				,@RegistrationSID                        = @RegistrationSID
				,@PracticeRegisterSectionSID             = @PracticeRegisterSectionSID
				,@RegistrationYear                       = @RegistrationYear
				,@NextFollowUp                           = @NextFollowUp
				,@RegistrationEffective                  = @RegistrationEffective
				,@ReservedRegistrantNo                   = @ReservedRegistrantNo
				,@ConfirmationDraft                      = @ConfirmationDraft
				,@ReasonSID                              = @ReasonSID
				,@InvoiceSID                             = @InvoiceSID
				,@ComplaintSID                           = @ComplaintSID
				,@UserDefinedColumns                     = @UserDefinedColumns
				,@RegistrationChangeXID                  = @RegistrationChangeXID
				,@LegacyKey                              = @LegacyKey
				,@IsDeleted                              = @IsDeleted
				,@CreateUser                             = @CreateUser
				,@CreateTime                             = @CreateTime
				,@UpdateTime                             = @UpdateTime
				,@RowGUID                                = @RowGUID
				,@PracticeRegisterSID                    = @PracticeRegisterSID
				,@PracticeRegisterSectionLabel           = @PracticeRegisterSectionLabel
				,@PracticeRegisterSectionIsDefault       = @PracticeRegisterSectionIsDefault
				,@IsDisplayedOnLicense                   = @IsDisplayedOnLicense
				,@PracticeRegisterSectionIsActive        = @PracticeRegisterSectionIsActive
				,@PracticeRegisterSectionRowGUID         = @PracticeRegisterSectionRowGUID
				,@RegistrationRegistrantSID              = @RegistrationRegistrantSID
				,@RegistrationPracticeRegisterSectionSID = @RegistrationPracticeRegisterSectionSID
				,@RegistrationNo                         = @RegistrationNo
				,@RegistrationRegistrationYear           = @RegistrationRegistrationYear
				,@EffectiveTime                          = @EffectiveTime
				,@ExpiryTime                             = @ExpiryTime
				,@CardPrintedTime                        = @CardPrintedTime
				,@RegistrationInvoiceSID                 = @RegistrationInvoiceSID
				,@RegistrationReasonSID                  = @RegistrationReasonSID
				,@FormGUID                               = @FormGUID
				,@RegistrationRowGUID                    = @RegistrationRowGUID
				,@ReasonGroupSID                         = @ReasonGroupSID
				,@ReasonName                             = @ReasonName
				,@ReasonCode                             = @ReasonCode
				,@ReasonSequence                         = @ReasonSequence
				,@ToolTip                                = @ToolTip
				,@ReasonIsActive                         = @ReasonIsActive
				,@ReasonRowGUID                          = @ReasonRowGUID
				,@ComplaintNo                            = @ComplaintNo
				,@ComplaintRegistrantSID                 = @ComplaintRegistrantSID
				,@ComplaintTypeSID                       = @ComplaintTypeSID
				,@ComplainantTypeSID                     = @ComplainantTypeSID
				,@ApplicationUserSID                     = @ApplicationUserSID
				,@OpenedDate                             = @OpenedDate
				,@ConductStartDate                       = @ConductStartDate
				,@ConductEndDate                         = @ConductEndDate
				,@ComplaintSeveritySID                   = @ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry            = @IsDisplayedOnPublicRegistry
				,@ClosedDate                             = @ClosedDate
				,@DismissedDate                          = @DismissedDate
				,@ComplaintReasonSID                     = @ComplaintReasonSID
				,@FileExtension                          = @FileExtension
				,@ComplaintRowGUID                       = @ComplaintRowGUID
				,@PersonSID                              = @PersonSID
				,@InvoiceDate                            = @InvoiceDate
				,@Tax1Label                              = @Tax1Label
				,@Tax1Rate                               = @Tax1Rate
				,@Tax1GLAccountCode                      = @Tax1GLAccountCode
				,@Tax2Label                              = @Tax2Label
				,@Tax2Rate                               = @Tax2Rate
				,@Tax2GLAccountCode                      = @Tax2GLAccountCode
				,@Tax3Label                              = @Tax3Label
				,@Tax3Rate                               = @Tax3Rate
				,@Tax3GLAccountCode                      = @Tax3GLAccountCode
				,@InvoiceRegistrationYear                = @InvoiceRegistrationYear
				,@CancelledTime                          = @CancelledTime
				,@InvoiceReasonSID                       = @InvoiceReasonSID
				,@IsRefund                               = @IsRefund
				,@InvoiceComplaintSID                    = @InvoiceComplaintSID
				,@InvoiceRowGUID                         = @InvoiceRowGUID
				,@IsDeleteEnabled                        = @IsDeleteEnabled
				,@zContext                               = @zContext
				,@IsViewEnabled                          = @IsViewEnabled
				,@IsEditEnabled                          = @IsEditEnabled
				,@IsApproveEnabled                       = @IsApproveEnabled
				,@IsRejectEnabled                        = @IsRejectEnabled
				,@IsUnlockEnabled                        = @IsUnlockEnabled
				,@IsWithdrawalEnabled                    = @IsWithdrawalEnabled
				,@IsInProgress                           = @IsInProgress
				,@FormStatusSID                          = @FormStatusSID
				,@FormStatusSCD                          = @FormStatusSCD
				,@FormStatusLabel                        = @FormStatusLabel
				,@LastStatusChangeUser                   = @LastStatusChangeUser
				,@LastStatusChangeTime                   = @LastStatusChangeTime
				,@FormOwnerSID                           = @FormOwnerSID
				,@FormOwnerSCD                           = @FormOwnerSCD
				,@FormOwnerLabel                         = @FormOwnerLabel
				,@IsPDFDisplayed                         = @IsPDFDisplayed
				,@PersonDocSID                           = @PersonDocSID
				,@TotalDue                               = @TotalDue
				,@IsUnPaid                               = @IsUnPaid
				,@PersonMailingAddressSID                = @PersonMailingAddressSID
				,@PersonStreetAddress1                   = @PersonStreetAddress1
				,@PersonStreetAddress2                   = @PersonStreetAddress2
				,@PersonStreetAddress3                   = @PersonStreetAddress3
				,@PersonCityName                         = @PersonCityName
				,@PersonStateProvinceName                = @PersonStateProvinceName
				,@PersonPostalCode                       = @PersonPostalCode
				,@PersonCountryName                      = @PersonCountryName
				,@PersonCitySID                          = @PersonCitySID
				,@RegistrantPersonSID                    = @RegistrantPersonSID
				,@RegistrationYearLabel                  = @RegistrationYearLabel
				,@PracticeRegisterLabel                  = @PracticeRegisterLabel
				,@PracticeRegisterName                   = @PracticeRegisterName
				,@RegistrationChangeLabel                = @RegistrationChangeLabel
				,@IsRegisterChange                       = @IsRegisterChange
				,@HasOpenAudit                           = @HasOpenAudit
				,@NewFormStatusSCD                       = @NewFormStatusSCD
				,@ReasonSIDOnApprove                     = @ReasonSIDOnApprove
		
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
