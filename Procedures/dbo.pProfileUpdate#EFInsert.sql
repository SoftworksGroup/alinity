SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pProfileUpdate#EFInsert]
	 @PersonSID              int               = null												-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pProfileUpdate#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pProfileUpdate#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

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

		-- call the main procedure

		exec @errorNo = dbo.pProfileUpdate#Insert
			 @PersonSID              = @PersonSID
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
