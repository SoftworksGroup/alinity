SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegisterRestriction#EFInsert]
	 @PracticeRegisterSID                         int               = null	-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRestrictionSID                      int               = null	-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRegisterSectionSID                  int               = null	
	,@EffectiveTime                               datetime          = null	-- default: CONVERT(datetime,sf.fToday())
	,@ExpiryTime                                  datetime          = null	
	,@UserDefinedColumns                          xml               = null	
	,@PracticeRegisterRestrictionXID              varchar(150)      = null	
	,@LegacyKey                                   nvarchar(50)      = null	
	,@CreateUser                                  nvarchar(75)      = null	-- default: suser_sname()
	,@IsReselected                                tinyint           = null	-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                    xml               = null	-- other values defining context for the insert (if any)
	,@PracticeRegisterTypeSID                     int               = null	-- not a base table column (default ignored)
	,@RegistrationScheduleSID                     int               = null	-- not a base table column (default ignored)
	,@PracticeRegisterName                        nvarchar(65)      = null	-- not a base table column (default ignored)
	,@PracticeRegisterLabel                       nvarchar(35)      = null	-- not a base table column (default ignored)
	,@IsActivePractice                            bit               = null	-- not a base table column (default ignored)
	,@IsPublicRegistryEnabled                     bit               = null	-- not a base table column (default ignored)
	,@IsRenewalEnabled                            bit               = null	-- not a base table column (default ignored)
	,@IsLearningPlanEnabled                       bit               = null	-- not a base table column (default ignored)
	,@IsNextCEFormAutoAdded                       bit               = null	-- not a base table column (default ignored)
	,@IsEligibleSupervisor                        bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterIsSupervisionRequired       bit               = null	-- not a base table column (default ignored)
	,@IsEmploymentTerminated                      bit               = null	-- not a base table column (default ignored)
	,@IsGroupMembershipTerminated                 bit               = null	-- not a base table column (default ignored)
	,@TermPermitDays                              int               = null	-- not a base table column (default ignored)
	,@RegisterRank                                smallint          = null	-- not a base table column (default ignored)
	,@LearningModelSID                            int               = null	-- not a base table column (default ignored)
	,@ReasonGroupSID                              int               = null	-- not a base table column (default ignored)
	,@PracticeRegisterIsDefault                   bit               = null	-- not a base table column (default ignored)
	,@IsDefaultInactivePractice                   bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterIsActive                    bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterRowGUID                     uniqueidentifier  = null	-- not a base table column (default ignored)
	,@PracticeRestrictionLabel                    nvarchar(35)      = null	-- not a base table column (default ignored)
	,@PracticeRestrictionIsDisplayedOnLicense     bit               = null	-- not a base table column (default ignored)
	,@PracticeRestrictionIsActive                 bit               = null	-- not a base table column (default ignored)
	,@PracticeRestrictionIsSupervisionRequired    bit               = null	-- not a base table column (default ignored)
	,@PracticeRestrictionRowGUID                  uniqueidentifier  = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionPracticeRegisterSID  int               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionLabel                nvarchar(35)      = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDefault            bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsDisplayedOnLicense bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionIsActive             bit               = null	-- not a base table column (default ignored)
	,@PracticeRegisterSectionRowGUID              uniqueidentifier  = null	-- not a base table column (default ignored)
	,@IsActive                                    bit               = null	-- not a base table column (default ignored)
	,@IsPending                                   bit               = null	-- not a base table column (default ignored)
	,@IsDeleteEnabled                             bit               = null	-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPracticeRegisterRestriction#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPracticeRegisterRestriction#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pPracticeRegisterRestriction#Insert
			 @PracticeRegisterSID                         = @PracticeRegisterSID
			,@PracticeRestrictionSID                      = @PracticeRestrictionSID
			,@PracticeRegisterSectionSID                  = @PracticeRegisterSectionSID
			,@EffectiveTime                               = @EffectiveTime
			,@ExpiryTime                                  = @ExpiryTime
			,@UserDefinedColumns                          = @UserDefinedColumns
			,@PracticeRegisterRestrictionXID              = @PracticeRegisterRestrictionXID
			,@LegacyKey                                   = @LegacyKey
			,@CreateUser                                  = @CreateUser
			,@IsReselected                                = @IsReselected
			,@zContext                                    = @zContext
			,@PracticeRegisterTypeSID                     = @PracticeRegisterTypeSID
			,@RegistrationScheduleSID                     = @RegistrationScheduleSID
			,@PracticeRegisterName                        = @PracticeRegisterName
			,@PracticeRegisterLabel                       = @PracticeRegisterLabel
			,@IsActivePractice                            = @IsActivePractice
			,@IsPublicRegistryEnabled                     = @IsPublicRegistryEnabled
			,@IsRenewalEnabled                            = @IsRenewalEnabled
			,@IsLearningPlanEnabled                       = @IsLearningPlanEnabled
			,@IsNextCEFormAutoAdded                       = @IsNextCEFormAutoAdded
			,@IsEligibleSupervisor                        = @IsEligibleSupervisor
			,@PracticeRegisterIsSupervisionRequired       = @PracticeRegisterIsSupervisionRequired
			,@IsEmploymentTerminated                      = @IsEmploymentTerminated
			,@IsGroupMembershipTerminated                 = @IsGroupMembershipTerminated
			,@TermPermitDays                              = @TermPermitDays
			,@RegisterRank                                = @RegisterRank
			,@LearningModelSID                            = @LearningModelSID
			,@ReasonGroupSID                              = @ReasonGroupSID
			,@PracticeRegisterIsDefault                   = @PracticeRegisterIsDefault
			,@IsDefaultInactivePractice                   = @IsDefaultInactivePractice
			,@PracticeRegisterIsActive                    = @PracticeRegisterIsActive
			,@PracticeRegisterRowGUID                     = @PracticeRegisterRowGUID
			,@PracticeRestrictionLabel                    = @PracticeRestrictionLabel
			,@PracticeRestrictionIsDisplayedOnLicense     = @PracticeRestrictionIsDisplayedOnLicense
			,@PracticeRestrictionIsActive                 = @PracticeRestrictionIsActive
			,@PracticeRestrictionIsSupervisionRequired    = @PracticeRestrictionIsSupervisionRequired
			,@PracticeRestrictionRowGUID                  = @PracticeRestrictionRowGUID
			,@PracticeRegisterSectionPracticeRegisterSID  = @PracticeRegisterSectionPracticeRegisterSID
			,@PracticeRegisterSectionLabel                = @PracticeRegisterSectionLabel
			,@PracticeRegisterSectionIsDefault            = @PracticeRegisterSectionIsDefault
			,@PracticeRegisterSectionIsDisplayedOnLicense = @PracticeRegisterSectionIsDisplayedOnLicense
			,@PracticeRegisterSectionIsActive             = @PracticeRegisterSectionIsActive
			,@PracticeRegisterSectionRowGUID              = @PracticeRegisterSectionRowGUID
			,@IsActive                                    = @IsActive
			,@IsPending                                   = @IsPending
			,@IsDeleteEnabled                             = @IsDeleteEnabled

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
