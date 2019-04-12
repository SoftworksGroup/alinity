SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pComplaint#EFInsert]
	 @ComplaintNo                      varchar(50)       = null							-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrantSID                    int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ComplaintTypeSID                 int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ComplainantTypeSID               int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ApplicationUserSID               int               = null							-- default: sf.fApplicationUserSessionUserSID()
	,@OpenedDate                       date              = null							-- default: sf.fToday()
	,@ConductStartDate                 date              = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ConductEndDate                   date              = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ComplaintSummary                 varbinary(max)    = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ComplaintSeveritySID             int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@OutcomeSummary                   varbinary(max)    = null							
	,@IsDisplayedOnPublicRegistry      bit               = null							-- default: (0)
	,@ClosedDate                       date              = null							
	,@DismissedDate                    date              = null							
	,@ReasonSID                        int               = null							
	,@TagList                          xml               = null							-- default: CONVERT(xml,N'<Tags/>')
	,@FileExtension                    varchar(5)        = null							-- default: '.html'
	,@UserDefinedColumns               xml               = null							
	,@ComplaintXID                     varchar(150)      = null							
	,@LegacyKey                        nvarchar(50)      = null							
	,@CreateUser                       nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                     tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                         xml               = null							-- other values defining context for the insert (if any)
	,@ComplainantTypeLabel             nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ComplainantTypeCategory          nvarchar(65)      = null							-- not a base table column (default ignored)
	,@ComplainantTypeIsDefault         bit               = null							-- not a base table column (default ignored)
	,@ComplainantTypeIsActive          bit               = null							-- not a base table column (default ignored)
	,@ComplainantTypeRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ComplaintSeverityLabel           nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ComplaintSeverityCategory        nvarchar(65)      = null							-- not a base table column (default ignored)
	,@ComplaintSeverityIsDefault       bit               = null							-- not a base table column (default ignored)
	,@ComplaintSeverityIsActive        bit               = null							-- not a base table column (default ignored)
	,@ComplaintSeverityRowGUID         uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ComplaintTypeLabel               nvarchar(35)      = null							-- not a base table column (default ignored)
	,@ComplaintTypeCategory            nvarchar(65)      = null							-- not a base table column (default ignored)
	,@ComplaintTypeIsDefault           bit               = null							-- not a base table column (default ignored)
	,@ComplaintTypeIsActive            bit               = null							-- not a base table column (default ignored)
	,@ComplaintTypeRowGUID             uniqueidentifier  = null							-- not a base table column (default ignored)
	,@RegistrantPersonSID              int               = null							-- not a base table column (default ignored)
	,@RegistrantNo                     varchar(50)       = null							-- not a base table column (default ignored)
	,@YearOfInitialEmployment          smallint          = null							-- not a base table column (default ignored)
	,@IsOnPublicRegistry               bit               = null							-- not a base table column (default ignored)
	,@CityNameOfBirth                  nvarchar(30)      = null							-- not a base table column (default ignored)
	,@CountrySID                       int               = null							-- not a base table column (default ignored)
	,@DirectedAuditYearCompetence      smallint          = null							-- not a base table column (default ignored)
	,@DirectedAuditYearPracticeHours   smallint          = null							-- not a base table column (default ignored)
	,@LateFeeExclusionYear             smallint          = null							-- not a base table column (default ignored)
	,@IsRenewalAutoApprovalBlocked     bit               = null							-- not a base table column (default ignored)
	,@RenewalExtensionExpiryTime       datetime          = null							-- not a base table column (default ignored)
	,@ArchivedTime                     datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@RegistrantRowGUID                uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ApplicationUserPersonSID         int               = null							-- not a base table column (default ignored)
	,@CultureSID                       int               = null							-- not a base table column (default ignored)
	,@AuthenticationAuthoritySID       int               = null							-- not a base table column (default ignored)
	,@UserName                         nvarchar(75)      = null							-- not a base table column (default ignored)
	,@LastReviewTime                   datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LastReviewUser                   nvarchar(75)      = null							-- not a base table column (default ignored)
	,@IsPotentialDuplicate             bit               = null							-- not a base table column (default ignored)
	,@IsTemplate                       bit               = null							-- not a base table column (default ignored)
	,@GlassBreakPassword               varbinary(8000)   = null							-- not a base table column (default ignored)
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@ApplicationUserIsActive          bit               = null							-- not a base table column (default ignored)
	,@AuthenticationSystemID           nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ApplicationUserRowGUID           uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ReasonGroupSID                   int               = null							-- not a base table column (default ignored)
	,@ReasonName                       nvarchar(50)      = null							-- not a base table column (default ignored)
	,@ReasonCode                       varchar(25)       = null							-- not a base table column (default ignored)
	,@ReasonSequence                   smallint          = null							-- not a base table column (default ignored)
	,@ToolTip                          nvarchar(500)     = null							-- not a base table column (default ignored)
	,@ReasonIsActive                   bit               = null							-- not a base table column (default ignored)
	,@ReasonRowGUID                    uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                  bit               = null							-- not a base table column (default ignored)
	,@ComplaintLabel                   nvarchar(115)     = null							-- not a base table column (default ignored)
	,@IsDismissed                      bit               = null							-- not a base table column (default ignored)
	,@IsClosed                         bit               = null							-- not a base table column (default ignored)
	,@IsCloseEnabled                   bit               = null							-- not a base table column (default ignored)
	,@ComplaintProcessSID              int               = null							-- not a base table column (default ignored)
	,@ComplainantPersonSID             int               = null							-- not a base table column (default ignored)
	,@ComplaintStatusLabel             nvarchar(35)      = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pComplaint#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pComplaint#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pComplaint#Insert
			 @ComplaintNo                      = @ComplaintNo
			,@RegistrantSID                    = @RegistrantSID
			,@ComplaintTypeSID                 = @ComplaintTypeSID
			,@ComplainantTypeSID               = @ComplainantTypeSID
			,@ApplicationUserSID               = @ApplicationUserSID
			,@OpenedDate                       = @OpenedDate
			,@ConductStartDate                 = @ConductStartDate
			,@ConductEndDate                   = @ConductEndDate
			,@ComplaintSummary                 = @ComplaintSummary
			,@ComplaintSeveritySID             = @ComplaintSeveritySID
			,@OutcomeSummary                   = @OutcomeSummary
			,@IsDisplayedOnPublicRegistry      = @IsDisplayedOnPublicRegistry
			,@ClosedDate                       = @ClosedDate
			,@DismissedDate                    = @DismissedDate
			,@ReasonSID                        = @ReasonSID
			,@TagList                          = @TagList
			,@FileExtension                    = @FileExtension
			,@UserDefinedColumns               = @UserDefinedColumns
			,@ComplaintXID                     = @ComplaintXID
			,@LegacyKey                        = @LegacyKey
			,@CreateUser                       = @CreateUser
			,@IsReselected                     = @IsReselected
			,@zContext                         = @zContext
			,@ComplainantTypeLabel             = @ComplainantTypeLabel
			,@ComplainantTypeCategory          = @ComplainantTypeCategory
			,@ComplainantTypeIsDefault         = @ComplainantTypeIsDefault
			,@ComplainantTypeIsActive          = @ComplainantTypeIsActive
			,@ComplainantTypeRowGUID           = @ComplainantTypeRowGUID
			,@ComplaintSeverityLabel           = @ComplaintSeverityLabel
			,@ComplaintSeverityCategory        = @ComplaintSeverityCategory
			,@ComplaintSeverityIsDefault       = @ComplaintSeverityIsDefault
			,@ComplaintSeverityIsActive        = @ComplaintSeverityIsActive
			,@ComplaintSeverityRowGUID         = @ComplaintSeverityRowGUID
			,@ComplaintTypeLabel               = @ComplaintTypeLabel
			,@ComplaintTypeCategory            = @ComplaintTypeCategory
			,@ComplaintTypeIsDefault           = @ComplaintTypeIsDefault
			,@ComplaintTypeIsActive            = @ComplaintTypeIsActive
			,@ComplaintTypeRowGUID             = @ComplaintTypeRowGUID
			,@RegistrantPersonSID              = @RegistrantPersonSID
			,@RegistrantNo                     = @RegistrantNo
			,@YearOfInitialEmployment          = @YearOfInitialEmployment
			,@IsOnPublicRegistry               = @IsOnPublicRegistry
			,@CityNameOfBirth                  = @CityNameOfBirth
			,@CountrySID                       = @CountrySID
			,@DirectedAuditYearCompetence      = @DirectedAuditYearCompetence
			,@DirectedAuditYearPracticeHours   = @DirectedAuditYearPracticeHours
			,@LateFeeExclusionYear             = @LateFeeExclusionYear
			,@IsRenewalAutoApprovalBlocked     = @IsRenewalAutoApprovalBlocked
			,@RenewalExtensionExpiryTime       = @RenewalExtensionExpiryTime
			,@ArchivedTime                     = @ArchivedTime
			,@RegistrantRowGUID                = @RegistrantRowGUID
			,@ApplicationUserPersonSID         = @ApplicationUserPersonSID
			,@CultureSID                       = @CultureSID
			,@AuthenticationAuthoritySID       = @AuthenticationAuthoritySID
			,@UserName                         = @UserName
			,@LastReviewTime                   = @LastReviewTime
			,@LastReviewUser                   = @LastReviewUser
			,@IsPotentialDuplicate             = @IsPotentialDuplicate
			,@IsTemplate                       = @IsTemplate
			,@GlassBreakPassword               = @GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime = @LastGlassBreakPasswordChangeTime
			,@ApplicationUserIsActive          = @ApplicationUserIsActive
			,@AuthenticationSystemID           = @AuthenticationSystemID
			,@ApplicationUserRowGUID           = @ApplicationUserRowGUID
			,@ReasonGroupSID                   = @ReasonGroupSID
			,@ReasonName                       = @ReasonName
			,@ReasonCode                       = @ReasonCode
			,@ReasonSequence                   = @ReasonSequence
			,@ToolTip                          = @ToolTip
			,@ReasonIsActive                   = @ReasonIsActive
			,@ReasonRowGUID                    = @ReasonRowGUID
			,@IsDeleteEnabled                  = @IsDeleteEnabled
			,@ComplaintLabel                   = @ComplaintLabel
			,@IsDismissed                      = @IsDismissed
			,@IsClosed                         = @IsClosed
			,@IsCloseEnabled                   = @IsCloseEnabled
			,@ComplaintProcessSID              = @ComplaintProcessSID
			,@ComplainantPersonSID             = @ComplainantPersonSID
			,@ComplaintStatusLabel             = @ComplaintStatusLabel

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
