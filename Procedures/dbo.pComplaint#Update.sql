SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pComplaint#Update]
	 @ComplaintSID                     int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ComplaintNo                      varchar(50)       = null -- table column values to update:
	,@RegistrantSID                    int               = null
	,@ComplaintTypeSID                 int               = null
	,@ComplainantTypeSID               int               = null
	,@ApplicationUserSID               int               = null
	,@OpenedDate                       date              = null
	,@ConductStartDate                 date              = null
	,@ConductEndDate                   date              = null
	,@ComplaintSummary                 varbinary(max)    = null
	,@ComplaintSeveritySID             int               = null
	,@OutcomeSummary                   varbinary(max)    = null
	,@IsDisplayedOnPublicRegistry      bit               = null
	,@ClosedDate                       date              = null
	,@DismissedDate                    date              = null
	,@ReasonSID                        int               = null
	,@TagList                          xml               = null
	,@FileExtension                    varchar(5)        = null
	,@UserDefinedColumns               xml               = null
	,@ComplaintXID                     varchar(150)      = null
	,@LegacyKey                        nvarchar(50)      = null
	,@UpdateUser                       nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                         timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                     tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                    bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                         xml               = null -- other values defining context for the update (if any)
	,@ComplainantTypeLabel             nvarchar(35)      = null -- not a base table column
	,@ComplainantTypeCategory          nvarchar(65)      = null -- not a base table column
	,@ComplainantTypeIsDefault         bit               = null -- not a base table column
	,@ComplainantTypeIsActive          bit               = null -- not a base table column
	,@ComplainantTypeRowGUID           uniqueidentifier  = null -- not a base table column
	,@ComplaintSeverityLabel           nvarchar(35)      = null -- not a base table column
	,@ComplaintSeverityCategory        nvarchar(65)      = null -- not a base table column
	,@ComplaintSeverityIsDefault       bit               = null -- not a base table column
	,@ComplaintSeverityIsActive        bit               = null -- not a base table column
	,@ComplaintSeverityRowGUID         uniqueidentifier  = null -- not a base table column
	,@ComplaintTypeLabel               nvarchar(35)      = null -- not a base table column
	,@ComplaintTypeCategory            nvarchar(65)      = null -- not a base table column
	,@ComplaintTypeIsDefault           bit               = null -- not a base table column
	,@ComplaintTypeIsActive            bit               = null -- not a base table column
	,@ComplaintTypeRowGUID             uniqueidentifier  = null -- not a base table column
	,@RegistrantPersonSID              int               = null -- not a base table column
	,@RegistrantNo                     varchar(50)       = null -- not a base table column
	,@YearOfInitialEmployment          smallint          = null -- not a base table column
	,@IsOnPublicRegistry               bit               = null -- not a base table column
	,@CityNameOfBirth                  nvarchar(30)      = null -- not a base table column
	,@CountrySID                       int               = null -- not a base table column
	,@DirectedAuditYearCompetence      smallint          = null -- not a base table column
	,@DirectedAuditYearPracticeHours   smallint          = null -- not a base table column
	,@LateFeeExclusionYear             smallint          = null -- not a base table column
	,@IsRenewalAutoApprovalBlocked     bit               = null -- not a base table column
	,@RenewalExtensionExpiryTime       datetime          = null -- not a base table column
	,@ArchivedTime                     datetimeoffset(7) = null -- not a base table column
	,@RegistrantRowGUID                uniqueidentifier  = null -- not a base table column
	,@ApplicationUserPersonSID         int               = null -- not a base table column
	,@CultureSID                       int               = null -- not a base table column
	,@AuthenticationAuthoritySID       int               = null -- not a base table column
	,@UserName                         nvarchar(75)      = null -- not a base table column
	,@LastReviewTime                   datetimeoffset(7) = null -- not a base table column
	,@LastReviewUser                   nvarchar(75)      = null -- not a base table column
	,@IsPotentialDuplicate             bit               = null -- not a base table column
	,@IsTemplate                       bit               = null -- not a base table column
	,@GlassBreakPassword               varbinary(8000)   = null -- not a base table column
	,@LastGlassBreakPasswordChangeTime datetimeoffset(7) = null -- not a base table column
	,@ApplicationUserIsActive          bit               = null -- not a base table column
	,@AuthenticationSystemID           nvarchar(50)      = null -- not a base table column
	,@ApplicationUserRowGUID           uniqueidentifier  = null -- not a base table column
	,@ReasonGroupSID                   int               = null -- not a base table column
	,@ReasonName                       nvarchar(50)      = null -- not a base table column
	,@ReasonCode                       varchar(25)       = null -- not a base table column
	,@ReasonSequence                   smallint          = null -- not a base table column
	,@ToolTip                          nvarchar(500)     = null -- not a base table column
	,@ReasonIsActive                   bit               = null -- not a base table column
	,@ReasonRowGUID                    uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                  bit               = null -- not a base table column
	,@ComplaintLabel                   nvarchar(115)     = null -- not a base table column
	,@IsDismissed                      bit               = null -- not a base table column
	,@IsClosed                         bit               = null -- not a base table column
	,@IsCloseEnabled                   bit               = null -- not a base table column
	,@ComplaintProcessSID              int               = null -- not a base table column
	,@ComplainantPersonSID             int               = null -- not a base table column
	,@ComplaintStatusLabel             nvarchar(35)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pComplaint#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Complaint table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Complaint table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vComplaint entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pComplaint procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Business rule compliance is checked through a table constraint which calls fComplaintCheck to test all rules.

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

		if @ComplaintSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ComplaintSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @ComplaintXID = ltrim(rtrim(@ComplaintXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ComplainantTypeLabel = ltrim(rtrim(@ComplainantTypeLabel))
		set @ComplainantTypeCategory = ltrim(rtrim(@ComplainantTypeCategory))
		set @ComplaintSeverityLabel = ltrim(rtrim(@ComplaintSeverityLabel))
		set @ComplaintSeverityCategory = ltrim(rtrim(@ComplaintSeverityCategory))
		set @ComplaintTypeLabel = ltrim(rtrim(@ComplaintTypeLabel))
		set @ComplaintTypeCategory = ltrim(rtrim(@ComplaintTypeCategory))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @CityNameOfBirth = ltrim(rtrim(@CityNameOfBirth))
		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @ReasonName = ltrim(rtrim(@ReasonName))
		set @ReasonCode = ltrim(rtrim(@ReasonCode))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @ComplaintLabel = ltrim(rtrim(@ComplaintLabel))
		set @ComplaintStatusLabel = ltrim(rtrim(@ComplaintStatusLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ComplaintNo) = 0 set @ComplaintNo = null
		if len(@FileExtension) = 0 set @FileExtension = null
		if len(@ComplaintXID) = 0 set @ComplaintXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ComplainantTypeLabel) = 0 set @ComplainantTypeLabel = null
		if len(@ComplainantTypeCategory) = 0 set @ComplainantTypeCategory = null
		if len(@ComplaintSeverityLabel) = 0 set @ComplaintSeverityLabel = null
		if len(@ComplaintSeverityCategory) = 0 set @ComplaintSeverityCategory = null
		if len(@ComplaintTypeLabel) = 0 set @ComplaintTypeLabel = null
		if len(@ComplaintTypeCategory) = 0 set @ComplaintTypeCategory = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@CityNameOfBirth) = 0 set @CityNameOfBirth = null
		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@ReasonName) = 0 set @ReasonName = null
		if len(@ReasonCode) = 0 set @ReasonCode = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@ComplaintLabel) = 0 set @ComplaintLabel = null
		if len(@ComplaintStatusLabel) = 0 set @ComplaintStatusLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ComplaintNo                      = isnull(@ComplaintNo,complaint.ComplaintNo)
				,@RegistrantSID                    = isnull(@RegistrantSID,complaint.RegistrantSID)
				,@ComplaintTypeSID                 = isnull(@ComplaintTypeSID,complaint.ComplaintTypeSID)
				,@ComplainantTypeSID               = isnull(@ComplainantTypeSID,complaint.ComplainantTypeSID)
				,@ApplicationUserSID               = isnull(@ApplicationUserSID,complaint.ApplicationUserSID)
				,@OpenedDate                       = isnull(@OpenedDate,complaint.OpenedDate)
				,@ConductStartDate                 = isnull(@ConductStartDate,complaint.ConductStartDate)
				,@ConductEndDate                   = isnull(@ConductEndDate,complaint.ConductEndDate)
				,@ComplaintSummary                 = isnull(@ComplaintSummary,complaint.ComplaintSummary)
				,@ComplaintSeveritySID             = isnull(@ComplaintSeveritySID,complaint.ComplaintSeveritySID)
				,@OutcomeSummary                   = isnull(@OutcomeSummary,complaint.OutcomeSummary)
				,@IsDisplayedOnPublicRegistry      = isnull(@IsDisplayedOnPublicRegistry,complaint.IsDisplayedOnPublicRegistry)
				,@ClosedDate                       = isnull(@ClosedDate,complaint.ClosedDate)
				,@DismissedDate                    = isnull(@DismissedDate,complaint.DismissedDate)
				,@ReasonSID                        = isnull(@ReasonSID,complaint.ReasonSID)
				,@TagList                          = isnull(@TagList,complaint.TagList)
				,@FileExtension                    = isnull(@FileExtension,complaint.FileExtension)
				,@UserDefinedColumns               = isnull(@UserDefinedColumns,complaint.UserDefinedColumns)
				,@ComplaintXID                     = isnull(@ComplaintXID,complaint.ComplaintXID)
				,@LegacyKey                        = isnull(@LegacyKey,complaint.LegacyKey)
				,@UpdateUser                       = isnull(@UpdateUser,complaint.UpdateUser)
				,@IsReselected                     = isnull(@IsReselected,complaint.IsReselected)
				,@IsNullApplied                    = isnull(@IsNullApplied,complaint.IsNullApplied)
				,@zContext                         = isnull(@zContext,complaint.zContext)
				,@ComplainantTypeLabel             = isnull(@ComplainantTypeLabel,complaint.ComplainantTypeLabel)
				,@ComplainantTypeCategory          = isnull(@ComplainantTypeCategory,complaint.ComplainantTypeCategory)
				,@ComplainantTypeIsDefault         = isnull(@ComplainantTypeIsDefault,complaint.ComplainantTypeIsDefault)
				,@ComplainantTypeIsActive          = isnull(@ComplainantTypeIsActive,complaint.ComplainantTypeIsActive)
				,@ComplainantTypeRowGUID           = isnull(@ComplainantTypeRowGUID,complaint.ComplainantTypeRowGUID)
				,@ComplaintSeverityLabel           = isnull(@ComplaintSeverityLabel,complaint.ComplaintSeverityLabel)
				,@ComplaintSeverityCategory        = isnull(@ComplaintSeverityCategory,complaint.ComplaintSeverityCategory)
				,@ComplaintSeverityIsDefault       = isnull(@ComplaintSeverityIsDefault,complaint.ComplaintSeverityIsDefault)
				,@ComplaintSeverityIsActive        = isnull(@ComplaintSeverityIsActive,complaint.ComplaintSeverityIsActive)
				,@ComplaintSeverityRowGUID         = isnull(@ComplaintSeverityRowGUID,complaint.ComplaintSeverityRowGUID)
				,@ComplaintTypeLabel               = isnull(@ComplaintTypeLabel,complaint.ComplaintTypeLabel)
				,@ComplaintTypeCategory            = isnull(@ComplaintTypeCategory,complaint.ComplaintTypeCategory)
				,@ComplaintTypeIsDefault           = isnull(@ComplaintTypeIsDefault,complaint.ComplaintTypeIsDefault)
				,@ComplaintTypeIsActive            = isnull(@ComplaintTypeIsActive,complaint.ComplaintTypeIsActive)
				,@ComplaintTypeRowGUID             = isnull(@ComplaintTypeRowGUID,complaint.ComplaintTypeRowGUID)
				,@RegistrantPersonSID              = isnull(@RegistrantPersonSID,complaint.RegistrantPersonSID)
				,@RegistrantNo                     = isnull(@RegistrantNo,complaint.RegistrantNo)
				,@YearOfInitialEmployment          = isnull(@YearOfInitialEmployment,complaint.YearOfInitialEmployment)
				,@IsOnPublicRegistry               = isnull(@IsOnPublicRegistry,complaint.IsOnPublicRegistry)
				,@CityNameOfBirth                  = isnull(@CityNameOfBirth,complaint.CityNameOfBirth)
				,@CountrySID                       = isnull(@CountrySID,complaint.CountrySID)
				,@DirectedAuditYearCompetence      = isnull(@DirectedAuditYearCompetence,complaint.DirectedAuditYearCompetence)
				,@DirectedAuditYearPracticeHours   = isnull(@DirectedAuditYearPracticeHours,complaint.DirectedAuditYearPracticeHours)
				,@LateFeeExclusionYear             = isnull(@LateFeeExclusionYear,complaint.LateFeeExclusionYear)
				,@IsRenewalAutoApprovalBlocked     = isnull(@IsRenewalAutoApprovalBlocked,complaint.IsRenewalAutoApprovalBlocked)
				,@RenewalExtensionExpiryTime       = isnull(@RenewalExtensionExpiryTime,complaint.RenewalExtensionExpiryTime)
				,@ArchivedTime                     = isnull(@ArchivedTime,complaint.ArchivedTime)
				,@RegistrantRowGUID                = isnull(@RegistrantRowGUID,complaint.RegistrantRowGUID)
				,@ApplicationUserPersonSID         = isnull(@ApplicationUserPersonSID,complaint.ApplicationUserPersonSID)
				,@CultureSID                       = isnull(@CultureSID,complaint.CultureSID)
				,@AuthenticationAuthoritySID       = isnull(@AuthenticationAuthoritySID,complaint.AuthenticationAuthoritySID)
				,@UserName                         = isnull(@UserName,complaint.UserName)
				,@LastReviewTime                   = isnull(@LastReviewTime,complaint.LastReviewTime)
				,@LastReviewUser                   = isnull(@LastReviewUser,complaint.LastReviewUser)
				,@IsPotentialDuplicate             = isnull(@IsPotentialDuplicate,complaint.IsPotentialDuplicate)
				,@IsTemplate                       = isnull(@IsTemplate,complaint.IsTemplate)
				,@GlassBreakPassword               = isnull(@GlassBreakPassword,complaint.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime = isnull(@LastGlassBreakPasswordChangeTime,complaint.LastGlassBreakPasswordChangeTime)
				,@ApplicationUserIsActive          = isnull(@ApplicationUserIsActive,complaint.ApplicationUserIsActive)
				,@AuthenticationSystemID           = isnull(@AuthenticationSystemID,complaint.AuthenticationSystemID)
				,@ApplicationUserRowGUID           = isnull(@ApplicationUserRowGUID,complaint.ApplicationUserRowGUID)
				,@ReasonGroupSID                   = isnull(@ReasonGroupSID,complaint.ReasonGroupSID)
				,@ReasonName                       = isnull(@ReasonName,complaint.ReasonName)
				,@ReasonCode                       = isnull(@ReasonCode,complaint.ReasonCode)
				,@ReasonSequence                   = isnull(@ReasonSequence,complaint.ReasonSequence)
				,@ToolTip                          = isnull(@ToolTip,complaint.ToolTip)
				,@ReasonIsActive                   = isnull(@ReasonIsActive,complaint.ReasonIsActive)
				,@ReasonRowGUID                    = isnull(@ReasonRowGUID,complaint.ReasonRowGUID)
				,@IsDeleteEnabled                  = isnull(@IsDeleteEnabled,complaint.IsDeleteEnabled)
				,@ComplaintLabel                   = isnull(@ComplaintLabel,complaint.ComplaintLabel)
				,@IsDismissed                      = isnull(@IsDismissed,complaint.IsDismissed)
				,@IsClosed                         = isnull(@IsClosed,complaint.IsClosed)
				,@IsCloseEnabled                   = isnull(@IsCloseEnabled,complaint.IsCloseEnabled)
				,@ComplaintProcessSID              = isnull(@ComplaintProcessSID,complaint.ComplaintProcessSID)
				,@ComplainantPersonSID             = isnull(@ComplainantPersonSID,complaint.ComplainantPersonSID)
				,@ComplaintStatusLabel             = isnull(@ComplaintStatusLabel,complaint.ComplaintStatusLabel)
			from
				dbo.vComplaint complaint
			where
				complaint.ComplaintSID = @ComplaintSID

		end
		
		if @IsClosed    = @ON and @ClosedDate    is null set @ClosedDate    = sf.fToday()								-- set column when null and extended view bit is passed to set it
		if @IsDismissed = @ON and @DismissedDate is null set @DismissedDate = sf.fToday()
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the new tags applied (if any)

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.ApplicationUserSID from dbo.Complaint x where x.ComplaintSID = @ComplaintSID) <> @ApplicationUserSID
		begin
			if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'application user'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ComplainantTypeSID from dbo.Complaint x where x.ComplaintSID = @ComplaintSID) <> @ComplainantTypeSID
		begin
			if (select x.IsActive from dbo.ComplainantType x where x.ComplainantTypeSID = @ComplainantTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'complainant type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ComplaintSeveritySID from dbo.Complaint x where x.ComplaintSID = @ComplaintSID) <> @ComplaintSeveritySID
		begin
			if (select x.IsActive from dbo.ComplaintSeverity x where x.ComplaintSeveritySID = @ComplaintSeveritySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'complaint severity'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ComplaintTypeSID from dbo.Complaint x where x.ComplaintSID = @ComplaintSID) <> @ComplaintTypeSID
		begin
			if (select x.IsActive from dbo.ComplaintType x where x.ComplaintTypeSID = @ComplaintTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'complaint type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ReasonSID from dbo.Complaint x where x.ComplaintSID = @ComplaintSID) <> @ReasonSID
		begin
			if (select x.IsActive from dbo.Reason x where x.ReasonSID = @ReasonSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'reason'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Mar 2019
		-- If a conduct start date was reported but
		-- no ending date, default the ending to the
		-- start

		if @ConductStartDate is not null and @ConductEndDate is null
		begin
			set @ConductEndDate = @ConductStartDate
		end

		-- Tim Edlund | Mar 2019
		-- If the complaint was dismissed, automatically set the
		-- closed date to the dismissed date. (Edge case for #Insert)

		if @DismissedDate is not null and @ClosedDate is null
		begin
			set @ClosedDate = @DismissedDate
		end
		
		-- Cory Ng | Apr 2019
		-- If the complaint or outcome summary do not already have  
		-- the unicode signature then prepend it

		if @ComplaintSummary is not null and substring(@ComplaintSummary,0, 3) <> 0xFFFE
		begin
			set @ComplaintSummary = 0xFFFE + @ComplaintSummary
		end

		if @OutcomeSummary is not null and substring(@OutcomeSummary,0, 3) <> 0xFFFE
		begin
			set @OutcomeSummary = 0xFFFE + @OutcomeSummary
		end
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pComplaint'
		)
		begin
		
			exec @errorNo = ext.pComplaint
				 @Mode                             = 'update.pre'
				,@ComplaintSID                     = @ComplaintSID
				,@ComplaintNo                      = @ComplaintNo output
				,@RegistrantSID                    = @RegistrantSID output
				,@ComplaintTypeSID                 = @ComplaintTypeSID output
				,@ComplainantTypeSID               = @ComplainantTypeSID output
				,@ApplicationUserSID               = @ApplicationUserSID output
				,@OpenedDate                       = @OpenedDate output
				,@ConductStartDate                 = @ConductStartDate output
				,@ConductEndDate                   = @ConductEndDate output
				,@ComplaintSummary                 = @ComplaintSummary output
				,@ComplaintSeveritySID             = @ComplaintSeveritySID output
				,@OutcomeSummary                   = @OutcomeSummary output
				,@IsDisplayedOnPublicRegistry      = @IsDisplayedOnPublicRegistry output
				,@ClosedDate                       = @ClosedDate output
				,@DismissedDate                    = @DismissedDate output
				,@ReasonSID                        = @ReasonSID output
				,@TagList                          = @TagList output
				,@FileExtension                    = @FileExtension output
				,@UserDefinedColumns               = @UserDefinedColumns output
				,@ComplaintXID                     = @ComplaintXID output
				,@LegacyKey                        = @LegacyKey output
				,@UpdateUser                       = @UpdateUser
				,@RowStamp                         = @RowStamp
				,@IsReselected                     = @IsReselected
				,@IsNullApplied                    = @IsNullApplied
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
		
		end

		-- update the record

		update
			dbo.Complaint
		set
			 ComplaintNo = @ComplaintNo
			,RegistrantSID = @RegistrantSID
			,ComplaintTypeSID = @ComplaintTypeSID
			,ComplainantTypeSID = @ComplainantTypeSID
			,ApplicationUserSID = @ApplicationUserSID
			,OpenedDate = @OpenedDate
			,ConductStartDate = @ConductStartDate
			,ConductEndDate = @ConductEndDate
			,ComplaintSummary = @ComplaintSummary
			,ComplaintSeveritySID = @ComplaintSeveritySID
			,OutcomeSummary = @OutcomeSummary
			,IsDisplayedOnPublicRegistry = @IsDisplayedOnPublicRegistry
			,ClosedDate = @ClosedDate
			,DismissedDate = @DismissedDate
			,ReasonSID = @ReasonSID
			,TagList = @TagList
			,FileExtension = @FileExtension
			,UserDefinedColumns = @UserDefinedColumns
			,ComplaintXID = @ComplaintXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ComplaintSID = @ComplaintSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Complaint where ComplaintSID = @complaintSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Complaint'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Complaint'
					,@Arg2        = @complaintSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'dbo.Complaint'
				,@Arg3        = @rowsAffected
				,@Arg4        = @complaintSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
	
		-- call the extended version of the procedure for update.post - if it exists
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pComplaint'
		)
		begin
		
			exec @errorNo = ext.pComplaint
				 @Mode                             = 'update.post'
				,@ComplaintSID                     = @ComplaintSID
				,@ComplaintNo                      = @ComplaintNo
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
				,@UpdateUser                       = @UpdateUser
				,@RowStamp                         = @RowStamp
				,@IsReselected                     = @IsReselected
				,@IsNullApplied                    = @IsNullApplied
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
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ComplaintSID
			from
				dbo.vComplaint ent
			where
				ent.ComplaintSID = @ComplaintSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ComplaintSID
				,ent.ComplaintNo
				,ent.RegistrantSID
				,ent.ComplaintTypeSID
				,ent.ComplainantTypeSID
				,ent.ApplicationUserSID
				,ent.OpenedDate
				,ent.ConductStartDate
				,ent.ConductEndDate
				,ent.ComplaintSummary
				,ent.ComplaintSeveritySID
				,ent.OutcomeSummary
				,ent.IsDisplayedOnPublicRegistry
				,ent.ClosedDate
				,ent.DismissedDate
				,ent.ReasonSID
				,ent.TagList
				,ent.FileExtension
				,ent.UserDefinedColumns
				,ent.ComplaintXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.ComplainantTypeLabel
				,ent.ComplainantTypeCategory
				,ent.ComplainantTypeIsDefault
				,ent.ComplainantTypeIsActive
				,ent.ComplainantTypeRowGUID
				,ent.ComplaintSeverityLabel
				,ent.ComplaintSeverityCategory
				,ent.ComplaintSeverityIsDefault
				,ent.ComplaintSeverityIsActive
				,ent.ComplaintSeverityRowGUID
				,ent.ComplaintTypeLabel
				,ent.ComplaintTypeCategory
				,ent.ComplaintTypeIsDefault
				,ent.ComplaintTypeIsActive
				,ent.ComplaintTypeRowGUID
				,ent.RegistrantPersonSID
				,ent.RegistrantNo
				,ent.YearOfInitialEmployment
				,ent.IsOnPublicRegistry
				,ent.CityNameOfBirth
				,ent.CountrySID
				,ent.DirectedAuditYearCompetence
				,ent.DirectedAuditYearPracticeHours
				,ent.LateFeeExclusionYear
				,ent.IsRenewalAutoApprovalBlocked
				,ent.RenewalExtensionExpiryTime
				,ent.ArchivedTime
				,ent.RegistrantRowGUID
				,ent.ApplicationUserPersonSID
				,ent.CultureSID
				,ent.AuthenticationAuthoritySID
				,ent.UserName
				,ent.LastReviewTime
				,ent.LastReviewUser
				,ent.IsPotentialDuplicate
				,ent.IsTemplate
				,ent.GlassBreakPassword
				,ent.LastGlassBreakPasswordChangeTime
				,ent.ApplicationUserIsActive
				,ent.AuthenticationSystemID
				,ent.ApplicationUserRowGUID
				,ent.ReasonGroupSID
				,ent.ReasonName
				,ent.ReasonCode
				,ent.ReasonSequence
				,ent.ToolTip
				,ent.ReasonIsActive
				,ent.ReasonRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.ComplaintLabel
				,ent.IsDismissed
				,ent.IsClosed
				,ent.IsCloseEnabled
				,ent.ComplaintProcessSID
				,ent.ComplainantPersonSID
				,ent.ComplaintStatusLabel
			from
				dbo.vComplaint ent
			where
				ent.ComplaintSID = @ComplaintSID

		end

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
