SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAppReview#EFInsert]
	 @RegistrantAppSID               int               = null								-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pRegistrantAppReview#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantAppReview#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantAppReview#Insert
			 @RegistrantAppSID               = @RegistrantAppSID
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
