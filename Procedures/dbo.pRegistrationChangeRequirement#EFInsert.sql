SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChangeRequirement#EFInsert]
	 @RegistrationChangeSID                   int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationRequirementSID              int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PersonDocSID                            int               = null			
	,@RegistrantExamSID                       int               = null			
	,@ExpiryMonths                            smallint          = null			-- default: (0)
	,@RequirementStatusSID                    int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@RequirementSequence                     int               = null			-- default: (10)
	,@UserDefinedColumns                      xml               = null			
	,@RegistrationChangeRequirementXID        varchar(150)      = null			
	,@LegacyKey                               nvarchar(50)      = null			
	,@CreateUser                              nvarchar(75)      = null			-- default: suser_sname()
	,@IsReselected                            tinyint           = null			-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                xml               = null			-- other values defining context for the insert (if any)
	,@RegistrationSID                         int               = null			-- not a base table column (default ignored)
	,@PracticeRegisterSectionSID              int               = null			-- not a base table column (default ignored)
	,@RegistrationYear                        smallint          = null			-- not a base table column (default ignored)
	,@NextFollowUp                            date              = null			-- not a base table column (default ignored)
	,@RegistrationEffective                   date              = null			-- not a base table column (default ignored)
	,@ReservedRegistrantNo                    varchar(50)       = null			-- not a base table column (default ignored)
	,@ReasonSID                               int               = null			-- not a base table column (default ignored)
	,@RegistrationChangeInvoiceSID            int               = null			-- not a base table column (default ignored)
	,@ComplaintSID                            int               = null			-- not a base table column (default ignored)
	,@RegistrationChangeRowGUID               uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RegistrationRequirementTypeSID          int               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementLabel            nvarchar(35)      = null			-- not a base table column (default ignored)
	,@RegistrationRequirementPersonDocTypeSID int               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementExamSID          int               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementExpiryMonths     smallint          = null			-- not a base table column (default ignored)
	,@RegistrationRequirementIsActive         bit               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementRowGUID          uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RequirementStatusSCD                    varchar(10)       = null			-- not a base table column (default ignored)
	,@RequirementStatusLabel                  nvarchar(35)      = null			-- not a base table column (default ignored)
	,@IsFinal                                 bit               = null			-- not a base table column (default ignored)
	,@RequirementStatusSequence               int               = null			-- not a base table column (default ignored)
	,@RequirementStatusIsDefault              bit               = null			-- not a base table column (default ignored)
	,@RequirementStatusRowGUID                uniqueidentifier  = null			-- not a base table column (default ignored)
	,@PersonSID                               int               = null			-- not a base table column (default ignored)
	,@PersonDocPersonDocTypeSID               int               = null			-- not a base table column (default ignored)
	,@DocumentTitle                           nvarchar(100)     = null			-- not a base table column (default ignored)
	,@AdditionalInfo                          nvarchar(50)      = null			-- not a base table column (default ignored)
	,@ArchivedTime                            datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@FileTypeSID                             int               = null			-- not a base table column (default ignored)
	,@FileTypeSCD                             varchar(8)        = null			-- not a base table column (default ignored)
	,@ShowToRegistrant                        bit               = null			-- not a base table column (default ignored)
	,@ApplicationGrantSID                     int               = null			-- not a base table column (default ignored)
	,@IsRemoved                               bit               = null			-- not a base table column (default ignored)
	,@ExpiryDate                              date              = null			-- not a base table column (default ignored)
	,@ApplicationReportSID                    int               = null			-- not a base table column (default ignored)
	,@ReportEntitySID                         int               = null			-- not a base table column (default ignored)
	,@PersonDocCancelledTime                  datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@PersonDocProcessedTime                  datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@ContextLink                             uniqueidentifier  = null			-- not a base table column (default ignored)
	,@PersonDocRowGUID                        uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RegistrantSID                           int               = null			-- not a base table column (default ignored)
	,@RegistrantExamExamSID                   int               = null			-- not a base table column (default ignored)
	,@ExamDate                                date              = null			-- not a base table column (default ignored)
	,@ExamResultDate                          date              = null			-- not a base table column (default ignored)
	,@PassingScore                            int               = null			-- not a base table column (default ignored)
	,@Score                                   int               = null			-- not a base table column (default ignored)
	,@ExamStatusSID                           int               = null			-- not a base table column (default ignored)
	,@SchedulingPreferences                   nvarchar(1000)    = null			-- not a base table column (default ignored)
	,@AssignedLocation                        varchar(15)       = null			-- not a base table column (default ignored)
	,@ExamReference                           varchar(25)       = null			-- not a base table column (default ignored)
	,@ExamOfferingSID                         int               = null			-- not a base table column (default ignored)
	,@RegistrantExamInvoiceSID                int               = null			-- not a base table column (default ignored)
	,@ConfirmedTime                           datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantExamCancelledTime             datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantExamProcessedTime             datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantExamRowGUID                   uniqueidentifier  = null			-- not a base table column (default ignored)
	,@IsDeleteEnabled                         bit               = null			-- not a base table column (default ignored)
	,@IsMandatory                             bit               = null			-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChangeRequirement#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrationChangeRequirement#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrationChangeRequirement#Insert
			 @RegistrationChangeSID                   = @RegistrationChangeSID
			,@RegistrationRequirementSID              = @RegistrationRequirementSID
			,@PersonDocSID                            = @PersonDocSID
			,@RegistrantExamSID                       = @RegistrantExamSID
			,@ExpiryMonths                            = @ExpiryMonths
			,@RequirementStatusSID                    = @RequirementStatusSID
			,@RequirementSequence                     = @RequirementSequence
			,@UserDefinedColumns                      = @UserDefinedColumns
			,@RegistrationChangeRequirementXID        = @RegistrationChangeRequirementXID
			,@LegacyKey                               = @LegacyKey
			,@CreateUser                              = @CreateUser
			,@IsReselected                            = @IsReselected
			,@zContext                                = @zContext
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
			,@IsMandatory                             = @IsMandatory

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
