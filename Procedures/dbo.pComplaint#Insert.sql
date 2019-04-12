SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pComplaint#Insert]
	 @ComplaintSID                     int               = null output			-- identity value assigned to the new record
	,@ComplaintNo                      varchar(50)       = null							-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pComplaint#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.Complaint table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Complaint table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vComplaint entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pComplaint procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

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

	set @ComplaintSID = null																								-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @ComplaintNo = ltrim(rtrim(@ComplaintNo))
		set @FileExtension = ltrim(rtrim(@FileExtension))
		set @ComplaintXID = ltrim(rtrim(@ComplaintXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @ApplicationUserSID = isnull(@ApplicationUserSID,sf.fApplicationUserSessionUserSID())
		set @OpenedDate = isnull(@OpenedDate,sf.fToday())
		set @IsDisplayedOnPublicRegistry = isnull(@IsDisplayedOnPublicRegistry,(0))
		set @TagList = isnull(@TagList,CONVERT(xml,N'<Tags/>'))
		set @FileExtension = isnull(@FileExtension,'.html')
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                = isnull(@IsReselected               ,(0))
		
		if @IsClosed    = @ON and @ClosedDate    is null set @ClosedDate    = sf.fToday()								-- set column when null and extended view bit is passed to set it
		if @IsDismissed = @ON and @DismissedDate is null set @DismissedDate = sf.fToday()
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the tags applied (if any)
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @ComplainantTypeSID    is null select @ComplainantTypeSID    = x.ComplainantTypeSID   from dbo.ComplainantType   x where x.IsDefault = @ON
		if @ComplaintSeveritySID  is null select @ComplaintSeveritySID  = x.ComplaintSeveritySID from dbo.ComplaintSeverity x where x.IsDefault = @ON
		if @ComplaintTypeSID      is null select @ComplaintTypeSID      = x.ComplaintTypeSID     from dbo.ComplaintType     x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Mar 2019
		-- If the complaint# was not passed or passed as "+", set it to the
		-- next value from the sequence

		if @ComplaintNo is null or @ComplaintNo = '+'
		begin

			exec dbo.pComplaint#GetNextNo
			  @ComplaintNo = @ComplaintNo output;

		end;

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
		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
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
				 @Mode                             = 'insert.pre'
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
		
		end

		-- insert the record

		insert
			dbo.Complaint
		(
			 ComplaintNo
			,RegistrantSID
			,ComplaintTypeSID
			,ComplainantTypeSID
			,ApplicationUserSID
			,OpenedDate
			,ConductStartDate
			,ConductEndDate
			,ComplaintSummary
			,ComplaintSeveritySID
			,OutcomeSummary
			,IsDisplayedOnPublicRegistry
			,ClosedDate
			,DismissedDate
			,ReasonSID
			,TagList
			,FileExtension
			,UserDefinedColumns
			,ComplaintXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @ComplaintNo
			,@RegistrantSID
			,@ComplaintTypeSID
			,@ComplainantTypeSID
			,@ApplicationUserSID
			,@OpenedDate
			,@ConductStartDate
			,@ConductEndDate
			,@ComplaintSummary
			,@ComplaintSeveritySID
			,@OutcomeSummary
			,@IsDisplayedOnPublicRegistry
			,@ClosedDate
			,@DismissedDate
			,@ReasonSID
			,@TagList
			,@FileExtension
			,@UserDefinedColumns
			,@ComplaintXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@ComplaintSID = scope_identity()																		-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.Complaint'
				,@Arg3        = @rowsAffected
				,@Arg4        = @ComplaintSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Jan 2018
		-- Insert a contact record for the investigated member. The registrant
		-- key is mandatory but if not passed avoid call to raise not-null
		-- error on table rather than error from sproc.

		if @RegistrantPersonSID is not null
		begin

			select
				@RegistrantPersonSID = r.PersonSID
			from
				dbo.Registrant r
			where
				r.RegistrantSID = @RegistrantSID;

			exec dbo.pComplaintContact#Insert
				@ComplaintSID = @ComplaintSID
			 ,@PersonSID = @RegistrantPersonSID
			 ,@ComplaintContactRoleSCD = 'MEMBER';

		end;

		-- Tim Edlund | Jan 2018
		-- Insert the complainant record if provided in the initial call. More
		-- than 1 complainant is supported in model but only 1 in initial call.

		if @ComplainantPersonSID is not null
		begin

			exec dbo.pComplaintContact#Insert
				@ComplaintSID = @ComplaintSID
			 ,@PersonSID = @ComplainantPersonSID
			 ,@ComplaintContactRoleSCD = 'COMPLAINANT';

		end;

		-- Tim Edlund | Mar 2019
		-- If a conduct start date was reported but
		-- no ending date, default the ending to the
		-- start

		if @ConductStartDate is not null and @ConductEndDate is null
		begin
			set @ConductEndDate = @ConductStartDate
		end

		-- Tim Edlund | Jan 2018
		-- If a process was specified, insert the associated
		-- events through a sub-routine

		if @ComplaintProcessSID is not null
		begin

			exec dbo.pComplaint#SetProcess
				@ComplaintSID = @ComplaintSID
			 ,@ComplaintProcessSID = @ComplaintProcessSID
			 ,@ReturnSelect = 0

		end;
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
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
				 @Mode                             = 'insert.post'
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
