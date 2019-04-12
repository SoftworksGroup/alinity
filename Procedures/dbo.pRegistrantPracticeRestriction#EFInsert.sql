SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantPracticeRestriction#EFInsert]
	 @RegistrantSID                           int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PracticeRestrictionSID                  int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime                           datetime          = null			-- default: sf.fNow()
	,@ExpiryTime                              datetime          = null			
	,@IsDisplayedOnLicense                    bit               = null			-- default: (1)
	,@ComplaintSID                            int               = null			
	,@UserDefinedColumns                      xml               = null			
	,@RegistrantPracticeRestrictionXID        varchar(150)      = null			
	,@LegacyKey                               nvarchar(50)      = null			
	,@CreateUser                              nvarchar(75)      = null			-- default: suser_sname()
	,@IsReselected                            tinyint           = null			-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                xml               = null			-- other values defining context for the insert (if any)
	,@PracticeRestrictionLabel                nvarchar(35)      = null			-- not a base table column (default ignored)
	,@PracticeRestrictionIsDisplayedOnLicense bit               = null			-- not a base table column (default ignored)
	,@PracticeRestrictionIsActive             bit               = null			-- not a base table column (default ignored)
	,@IsSupervisionRequired                   bit               = null			-- not a base table column (default ignored)
	,@PracticeRestrictionRowGUID              uniqueidentifier  = null			-- not a base table column (default ignored)
	,@PersonSID                               int               = null			-- not a base table column (default ignored)
	,@RegistrantNo                            varchar(50)       = null			-- not a base table column (default ignored)
	,@YearOfInitialEmployment                 smallint          = null			-- not a base table column (default ignored)
	,@IsOnPublicRegistry                      bit               = null			-- not a base table column (default ignored)
	,@CityNameOfBirth                         nvarchar(30)      = null			-- not a base table column (default ignored)
	,@CountrySID                              int               = null			-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence             smallint          = null			-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours          smallint          = null			-- not a base table column (default ignored)
	,@LateFeeExclusionYear                    smallint          = null			-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked            bit               = null			-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime              datetime          = null			-- not a base table column (default ignored)
	,@ArchivedTime                            datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantRowGUID                       uniqueidentifier  = null			-- not a base table column (default ignored)
	,@ComplaintNo                             varchar(50)       = null			-- not a base table column (default ignored)
	,@ComplaintRegistrantSID                  int               = null			-- not a base table column (default ignored)
	,@ComplaintTypeSID                        int               = null			-- not a base table column (default ignored)
	,@ComplainantTypeSID                      int               = null			-- not a base table column (default ignored)
	,@ApplicationUserSID                      int               = null			-- not a base table column (default ignored)
	,@OpenedDate                              date              = null			-- not a base table column (default ignored)
	,@ConductStartDate                        date              = null			-- not a base table column (default ignored)
	,@ConductEndDate                          date              = null			-- not a base table column (default ignored)
	,@ComplaintSeveritySID                    int               = null			-- not a base table column (default ignored)
	,@IsDisplayedOnPublicRegistry             bit               = null			-- not a base table column (default ignored)
	,@ClosedDate                              date              = null			-- not a base table column (default ignored)
	,@DismissedDate                           date              = null			-- not a base table column (default ignored)
	,@ReasonSID                               int               = null			-- not a base table column (default ignored)
	,@FileExtension                           varchar(5)        = null			-- not a base table column (default ignored)
	,@ComplaintRowGUID                        uniqueidentifier  = null			-- not a base table column (default ignored)
	,@IsActive                                bit               = null			-- not a base table column (default ignored)
	,@IsPending                               bit               = null			-- not a base table column (default ignored)
	,@IsDeleteEnabled                         bit               = null			-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrantPracticeRestriction#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrantPracticeRestriction#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrantPracticeRestriction#Insert
			 @RegistrantSID                           = @RegistrantSID
			,@PracticeRestrictionSID                  = @PracticeRestrictionSID
			,@EffectiveTime                           = @EffectiveTime
			,@ExpiryTime                              = @ExpiryTime
			,@IsDisplayedOnLicense                    = @IsDisplayedOnLicense
			,@ComplaintSID                            = @ComplaintSID
			,@UserDefinedColumns                      = @UserDefinedColumns
			,@RegistrantPracticeRestrictionXID        = @RegistrantPracticeRestrictionXID
			,@LegacyKey                               = @LegacyKey
			,@CreateUser                              = @CreateUser
			,@IsReselected                            = @IsReselected
			,@zContext                                = @zContext
			,@PracticeRestrictionLabel                = @PracticeRestrictionLabel
			,@PracticeRestrictionIsDisplayedOnLicense = @PracticeRestrictionIsDisplayedOnLicense
			,@PracticeRestrictionIsActive             = @PracticeRestrictionIsActive
			,@IsSupervisionRequired                   = @IsSupervisionRequired
			,@PracticeRestrictionRowGUID              = @PracticeRestrictionRowGUID
			,@PersonSID                               = @PersonSID
			,@RegistrantNo                            = @RegistrantNo
			,@YearOfInitialEmployment                 = @YearOfInitialEmployment
			,@IsOnPublicRegistry                      = @IsOnPublicRegistry
			,@CityNameOfBirth                         = @CityNameOfBirth
			,@CountrySID                              = @CountrySID
			,@DirectedAuditYearCompetence             = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours          = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear                    = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked            = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime              = @RenewalExtensionExpiryTime
			,@ArchivedTime                            = @ArchivedTime
			,@RegistrantRowGUID                       = @RegistrantRowGUID
			,@ComplaintNo                             = @ComplaintNo
			,@ComplaintRegistrantSID                  = @ComplaintRegistrantSID
			,@ComplaintTypeSID                        = @ComplaintTypeSID
			,@ComplainantTypeSID                      = @ComplainantTypeSID
			,@ApplicationUserSID                      = @ApplicationUserSID
			,@OpenedDate                              = @OpenedDate
			,@ConductStartDate                        = @ConductStartDate
			,@ConductEndDate                          = @ConductEndDate
			,@ComplaintSeveritySID                    = @ComplaintSeveritySID
			,@IsDisplayedOnPublicRegistry             = @IsDisplayedOnPublicRegistry
			,@ClosedDate                              = @ClosedDate
			,@DismissedDate                           = @DismissedDate
			,@ReasonSID                               = @ReasonSID
			,@FileExtension                           = @FileExtension
			,@ComplaintRowGUID                        = @ComplaintRowGUID
			,@IsActive                                = @IsActive
			,@IsPending                               = @IsPending
			,@IsDeleteEnabled                         = @IsDeleteEnabled

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
