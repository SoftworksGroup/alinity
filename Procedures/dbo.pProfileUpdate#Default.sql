SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pProfileUpdate#Default]
	 @zContext               xml               = null                              -- default values provided from client-tier (if any)
	,@SetFKDefaults          bit               = 0                                 -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pProfileUpdate#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.ProfileUpdate records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.ProfileUpdate table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vProfileUpdate entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pProfileUpdate
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pProfileUpdate of the context of the call. All other parameters are also passed, however, only those parameters eligible
for default setting are passed for "output". All parameters corresponding to entity view columns are returned through a SELECT statement.

In order to simplify working with the XML parameter values, logic in the procedure parses the XML and assigns values to variables where
the variable name matches the column name in the XML (assumes single row).  The variables are then available to the table-specific and
client-specific logic.  The @zContext parameter is also passed, unmodified, to the extended procedure to support situations where values
are passed that are not mapped to column names.


-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@ON                     bit = cast(1 as bit)													-- constant for bit comparisons
		,@OFF                    bit = cast(0 as bit)													-- constant for bit comparisons
		,@profileUpdateSID       int               = -1												-- specific default required by EF - do not override
		,@personSID              int               = null											-- no default provided from DB constraint - OK to override
		,@registrationYear       int               = dbo.fRegistrationYear#Current()										-- default provided from DB constraint - OK to override
		,@formVersionSID         int               = null											-- no default provided from DB constraint - OK to override
		,@formResponseDraft      xml               = CONVERT(xml,N'<FormResponses />')									-- default provided from DB constraint - OK to override
		,@lastValidateTime       datetimeoffset(7) = null											-- no default provided from DB constraint - OK to override
		,@adminComments          xml               = CONVERT(xml,'<Comments />')												-- default provided from DB constraint - OK to override
		,@nextFollowUp           date              = null											-- no default provided from DB constraint - OK to override
		,@confirmationDraft      nvarchar(max)     = null											-- no default provided from DB constraint - OK to override
		,@isAutoApprovalEnabled  bit               = CONVERT(bit,(0))					-- default provided from DB constraint - OK to override
		,@reasonSID              int               = null											-- no default provided from DB constraint - OK to override
		,@reviewReasonList       xml               = null											-- no default provided from DB constraint - OK to override
		,@parentRowGUID          uniqueidentifier  = null											-- no default provided from DB constraint - OK to override
		,@userDefinedColumns     xml               = null											-- no default provided from DB constraint - OK to override
		,@profileUpdateXID       varchar(150)      = null											-- no default provided from DB constraint - OK to override
		,@legacyKey              nvarchar(50)      = null											-- no default provided from DB constraint - OK to override
		,@isDeleted              bit               = (0)											-- default provided from DB constraint - OK to override
		,@createUser             nvarchar(75)      = suser_sname()						-- default value ignored (value set by UI)
		,@createTime             datetimeoffset(7) = sysdatetimeoffset()			-- default value ignored (set to system time)
		,@updateUser             nvarchar(75)      = suser_sname()						-- default value ignored (value set by UI)
		,@updateTime             datetimeoffset(7) = sysdatetimeoffset()			-- default value ignored (set to system time)
		,@rowGUID                uniqueidentifier  = newid()									-- default value ignored (value set by system)
		,@rowStamp               timestamp         = null											-- default value ignored (value set by system)
		,@formSID                int               = 0												-- not a base table column (default ignored)
		,@versionNo              smallint          = 0												-- not a base table column (default ignored)
		,@revisionNo             smallint          = 0												-- not a base table column (default ignored)
		,@isSaveDisplayed        bit               = 0												-- not a base table column (default ignored)
		,@approvedTime           datetimeoffset(7)														-- not a base table column (default ignored)
		,@formVersionRowGUID     uniqueidentifier  = newid()									-- not a base table column (default ignored)
		,@genderSID              int               = 0												-- not a base table column (default ignored)
		,@namePrefixSID          int																					-- not a base table column (default ignored)
		,@firstName              nvarchar(30)      = N'?'											-- not a base table column (default ignored)
		,@commonName             nvarchar(30)																	-- not a base table column (default ignored)
		,@middleNames            nvarchar(30)																	-- not a base table column (default ignored)
		,@lastName               nvarchar(35)      = N'?'											-- not a base table column (default ignored)
		,@birthDate              date																					-- not a base table column (default ignored)
		,@deathDate              date																					-- not a base table column (default ignored)
		,@homePhone              varchar(25)																	-- not a base table column (default ignored)
		,@mobilePhone            varchar(25)																	-- not a base table column (default ignored)
		,@isTextMessagingEnabled bit               = 0												-- not a base table column (default ignored)
		,@importBatch            nvarchar(100)																-- not a base table column (default ignored)
		,@personRowGUID          uniqueidentifier  = newid()									-- not a base table column (default ignored)
		,@reasonGroupSID         int																					-- not a base table column (default ignored)
		,@reasonName             nvarchar(50)																	-- not a base table column (default ignored)
		,@reasonCode             varchar(25)																	-- not a base table column (default ignored)
		,@reasonSequence         smallint																			-- not a base table column (default ignored)
		,@toolTip                nvarchar(500)																-- not a base table column (default ignored)
		,@reasonIsActive         bit																					-- not a base table column (default ignored)
		,@reasonRowGUID          uniqueidentifier															-- not a base table column (default ignored)
		,@isDeleteEnabled        bit																					-- not a base table column (default ignored)
		,@isReselected           tinyint           = 1												-- specific default required by EF - do not override
		,@isNullApplied          bit               = 1												-- specific default required by EF - do not override
		,@profileUpdateLabel     nvarchar(80)																	-- not a base table column (default ignored)
		,@isViewEnabled          bit																					-- not a base table column (default ignored)
		,@isEditEnabled          bit																					-- not a base table column (default ignored)
		,@isSaveBtnDisplayed     bit																					-- not a base table column (default ignored)
		,@isApproveEnabled       bit																					-- not a base table column (default ignored)
		,@isRejectEnabled        bit																					-- not a base table column (default ignored)
		,@isUnlockEnabled        bit																					-- not a base table column (default ignored)
		,@isWithdrawalEnabled    bit																					-- not a base table column (default ignored)
		,@isInProgress           bit																					-- not a base table column (default ignored)
		,@isReviewRequired       bit																					-- not a base table column (default ignored)
		,@formStatusSID          int																					-- not a base table column (default ignored)
		,@formStatusSCD          varchar(25)																	-- not a base table column (default ignored)
		,@formStatusLabel        nvarchar(35)																	-- not a base table column (default ignored)
		,@formOwnerSID           int																					-- not a base table column (default ignored)
		,@formOwnerSCD           varchar(25)																	-- not a base table column (default ignored)
		,@formOwnerLabel         nvarchar(35)																	-- not a base table column (default ignored)
		,@lastStatusChangeUser   nvarchar(75)																	-- not a base table column (default ignored)
		,@lastStatusChangeTime   datetimeoffset(7)														-- not a base table column (default ignored)
		,@isPDFDisplayed         bit																					-- not a base table column (default ignored)
		,@personDocSID           int																					-- not a base table column (default ignored)
		,@newFormStatusSCD       varchar(25)																	-- not a base table column (default ignored)

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
		-- set mandatory FK values to -1 where requested
		
		if @SetFKDefaults = @ON
		begin
			set @personSID = -1
			set @formVersionSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @personSID              = isnull(context.node.value('@PersonSID'            ,'int'              ),@personSID)
			,@registrationYear       = isnull(context.node.value('@RegistrationYear'     ,'int'              ),@registrationYear)
			,@formVersionSID         = isnull(context.node.value('@FormVersionSID'       ,'int'              ),@formVersionSID)
			,@lastValidateTime       = isnull(context.node.value('@LastValidateTime'     ,'datetimeoffset(7)'),@lastValidateTime)
			,@nextFollowUp           = isnull(context.node.value('@NextFollowUp'         ,'date'             ),@nextFollowUp)
			,@confirmationDraft      = isnull(context.node.value('@ConfirmationDraft'    ,'nvarchar(max)'    ),@confirmationDraft)
			,@isAutoApprovalEnabled  = isnull(context.node.value('@IsAutoApprovalEnabled','bit'              ),@isAutoApprovalEnabled)
			,@reasonSID              = isnull(context.node.value('@ReasonSID'            ,'int'              ),@reasonSID)
			,@parentRowGUID          = isnull(context.node.value('@ParentRowGUID'        ,'uniqueidentifier' ),@parentRowGUID)
			,@profileUpdateXID       = isnull(context.node.value('@ProfileUpdateXID'     ,'varchar(150)'     ),@profileUpdateXID)
			,@legacyKey              = isnull(context.node.value('@LegacyKey'            ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		

		--! <Overrides>
		-- Tim Edlund | Jan 2018
		-- If a form version is not provided, default it to the latest published form of the
		-- correct type. Context sub-selections (using the sf.form.FormContext column) do NOT
		-- apply for profile updates since this form is only completed for a single year at
		-- a time. If a FormContext is provided it is ignored.

		if isnull(@formVersionSID, 0) = 0
		begin																																														

			select
				@formVersionSID = max(fv.FormVersionSID)
			from
				sf.Form                               f
			join
				sf.FormType ft  on f.FormTypeSID = ft.FormTypeSID and ft.FormTypeSCD = 'PROFILE.UPDATE'				-- only include profile update forms
			join
				sf.FormVersion                        fv  on f.FormSID = fv.FormSID and fv.VersionNo > 0			-- filter out non-published versions

		end;		
		--! </Overrides>
	
		-- call the extended version of the procedure (if it exists) for "default.pre" mode
		
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
				 @Mode                   = 'default.pre'
				,@ProfileUpdateSID = @profileUpdateSID
				,@PersonSID = @personSID output
				,@RegistrationYear = @registrationYear output
				,@FormVersionSID = @formVersionSID output
				,@FormResponseDraft = @formResponseDraft output
				,@LastValidateTime = @lastValidateTime output
				,@AdminComments = @adminComments output
				,@NextFollowUp = @nextFollowUp output
				,@ConfirmationDraft = @confirmationDraft output
				,@IsAutoApprovalEnabled = @isAutoApprovalEnabled output
				,@ReasonSID = @reasonSID output
				,@ReviewReasonList = @reviewReasonList output
				,@ParentRowGUID = @parentRowGUID output
				,@UserDefinedColumns = @userDefinedColumns output
				,@ProfileUpdateXID = @profileUpdateXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@FormSID = @formSID
				,@VersionNo = @versionNo
				,@RevisionNo = @revisionNo
				,@IsSaveDisplayed = @isSaveDisplayed
				,@ApprovedTime = @approvedTime
				,@FormVersionRowGUID = @formVersionRowGUID
				,@GenderSID = @genderSID
				,@NamePrefixSID = @namePrefixSID
				,@FirstName = @firstName
				,@CommonName = @commonName
				,@MiddleNames = @middleNames
				,@LastName = @lastName
				,@BirthDate = @birthDate
				,@DeathDate = @deathDate
				,@HomePhone = @homePhone
				,@MobilePhone = @mobilePhone
				,@IsTextMessagingEnabled = @isTextMessagingEnabled
				,@ImportBatch = @importBatch
				,@PersonRowGUID = @personRowGUID
				,@ReasonGroupSID = @reasonGroupSID
				,@ReasonName = @reasonName
				,@ReasonCode = @reasonCode
				,@ReasonSequence = @reasonSequence
				,@ToolTip = @toolTip
				,@ReasonIsActive = @reasonIsActive
				,@ReasonRowGUID = @reasonRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
				,@ProfileUpdateLabel = @profileUpdateLabel
				,@IsViewEnabled = @isViewEnabled
				,@IsEditEnabled = @isEditEnabled
				,@IsSaveBtnDisplayed = @isSaveBtnDisplayed
				,@IsApproveEnabled = @isApproveEnabled
				,@IsRejectEnabled = @isRejectEnabled
				,@IsUnlockEnabled = @isUnlockEnabled
				,@IsWithdrawalEnabled = @isWithdrawalEnabled
				,@IsInProgress = @isInProgress
				,@IsReviewRequired = @isReviewRequired
				,@FormStatusSID = @formStatusSID
				,@FormStatusSCD = @formStatusSCD
				,@FormStatusLabel = @formStatusLabel
				,@FormOwnerSID = @formOwnerSID
				,@FormOwnerSCD = @formOwnerSCD
				,@FormOwnerLabel = @formOwnerLabel
				,@LastStatusChangeUser = @lastStatusChangeUser
				,@LastStatusChangeTime = @lastStatusChangeTime
				,@IsPDFDisplayed = @isPDFDisplayed
				,@PersonDocSID = @personDocSID
				,@NewFormStatusSCD = @newFormStatusSCD
		
		end

		select
			 @profileUpdateSID ProfileUpdateSID
			,@personSID PersonSID
			,@registrationYear RegistrationYear
			,@formVersionSID FormVersionSID
			,@formResponseDraft FormResponseDraft
			,@lastValidateTime LastValidateTime
			,@adminComments AdminComments
			,@nextFollowUp NextFollowUp
			,@confirmationDraft ConfirmationDraft
			,@isAutoApprovalEnabled IsAutoApprovalEnabled
			,@reasonSID ReasonSID
			,@reviewReasonList ReviewReasonList
			,@parentRowGUID ParentRowGUID
			,@userDefinedColumns UserDefinedColumns
			,@profileUpdateXID ProfileUpdateXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@formSID FormSID
			,@versionNo VersionNo
			,@revisionNo RevisionNo
			,@isSaveDisplayed IsSaveDisplayed
			,@approvedTime ApprovedTime
			,@formVersionRowGUID FormVersionRowGUID
			,@genderSID GenderSID
			,@namePrefixSID NamePrefixSID
			,@firstName FirstName
			,@commonName CommonName
			,@middleNames MiddleNames
			,@lastName LastName
			,@birthDate BirthDate
			,@deathDate DeathDate
			,@homePhone HomePhone
			,@mobilePhone MobilePhone
			,@isTextMessagingEnabled IsTextMessagingEnabled
			,@importBatch ImportBatch
			,@personRowGUID PersonRowGUID
			,@reasonGroupSID ReasonGroupSID
			,@reasonName ReasonName
			,@reasonCode ReasonCode
			,@reasonSequence ReasonSequence
			,@toolTip ToolTip
			,@reasonIsActive ReasonIsActive
			,@reasonRowGUID ReasonRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@profileUpdateLabel ProfileUpdateLabel
			,@isViewEnabled IsViewEnabled
			,@isEditEnabled IsEditEnabled
			,@isSaveBtnDisplayed IsSaveBtnDisplayed
			,@isApproveEnabled IsApproveEnabled
			,@isRejectEnabled IsRejectEnabled
			,@isUnlockEnabled IsUnlockEnabled
			,@isWithdrawalEnabled IsWithdrawalEnabled
			,@isInProgress IsInProgress
			,@isReviewRequired IsReviewRequired
			,@formStatusSID FormStatusSID
			,@formStatusSCD FormStatusSCD
			,@formStatusLabel FormStatusLabel
			,@formOwnerSID FormOwnerSID
			,@formOwnerSCD FormOwnerSCD
			,@formOwnerLabel FormOwnerLabel
			,@lastStatusChangeUser LastStatusChangeUser
			,@lastStatusChangeTime LastStatusChangeTime
			,@isPDFDisplayed IsPDFDisplayed
			,@personDocSID PersonDocSID
			,@newFormStatusSCD NewFormStatusSCD

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