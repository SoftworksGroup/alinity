SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#Update]
	 @ApplicationUserSID                  int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                           int               = null -- table column values to update:
	,@CultureSID                          int               = null
	,@AuthenticationAuthoritySID          int               = null
	,@UserName                            nvarchar(75)      = null
	,@LastReviewTime                      datetimeoffset(7) = null
	,@LastReviewUser                      nvarchar(75)      = null
	,@IsPotentialDuplicate                bit               = null
	,@IsTemplate                          bit               = null
	,@GlassBreakPassword                  varbinary(8000)   = null
	,@LastGlassBreakPasswordChangeTime    datetimeoffset(7) = null
	,@Comments                            nvarchar(max)     = null
	,@IsActive                            bit               = null
	,@AuthenticationSystemID              nvarchar(50)      = null
	,@ChangeAudit                         nvarchar(max)     = null
	,@UserDefinedColumns                  xml               = null
	,@ApplicationUserXID                  varchar(150)      = null
	,@LegacyKey                           nvarchar(50)      = null
	,@UpdateUser                          nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                            timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                        tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                       bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                            xml               = null -- other values defining context for the update (if any)
	,@AuthenticationAuthoritySCD          varchar(10)       = null -- not a base table column
	,@AuthenticationAuthorityLabel        nvarchar(35)      = null -- not a base table column
	,@AuthenticationAuthorityIsActive     bit               = null -- not a base table column
	,@AuthenticationAuthorityIsDefault    bit               = null -- not a base table column
	,@AuthenticationAuthorityRowGUID      uniqueidentifier  = null -- not a base table column
	,@CultureSCD                          varchar(10)       = null -- not a base table column
	,@CultureLabel                        nvarchar(35)      = null -- not a base table column
	,@CultureIsDefault                    bit               = null -- not a base table column
	,@CultureIsActive                     bit               = null -- not a base table column
	,@CultureRowGUID                      uniqueidentifier  = null -- not a base table column
	,@GenderSID                           int               = null -- not a base table column
	,@NamePrefixSID                       int               = null -- not a base table column
	,@FirstName                           nvarchar(30)      = null -- not a base table column
	,@CommonName                          nvarchar(30)      = null -- not a base table column
	,@MiddleNames                         nvarchar(30)      = null -- not a base table column
	,@LastName                            nvarchar(35)      = null -- not a base table column
	,@BirthDate                           date              = null -- not a base table column
	,@DeathDate                           date              = null -- not a base table column
	,@HomePhone                           varchar(25)       = null -- not a base table column
	,@MobilePhone                         varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled              bit               = null -- not a base table column
	,@ImportBatch                         nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                       uniqueidentifier  = null -- not a base table column
	,@ChangeReason                        nvarchar(4000)    = null -- not a base table column
	,@IsDeleteEnabled                     bit               = null -- not a base table column
	,@ApplicationUserSessionSID           int               = null -- not a base table column
	,@SessionGUID                         uniqueidentifier  = null -- not a base table column
	,@FileAsName                          nvarchar(65)      = null -- not a base table column
	,@FullName                            nvarchar(65)      = null -- not a base table column
	,@DisplayName                         nvarchar(65)      = null -- not a base table column
	,@PrimaryEmailAddress                 varchar(150)      = null -- not a base table column
	,@PrimaryEmailAddressSID              int               = null -- not a base table column
	,@PreferredPhone                      varchar(25)       = null -- not a base table column
	,@LoginCount                          int               = null -- not a base table column
	,@NextProfileReviewDueDate            smalldatetime     = null -- not a base table column
	,@IsNextProfileReviewOverdue          bit               = null -- not a base table column
	,@NextGlassBreakPasswordChangeDueDate smalldatetime     = null -- not a base table column
	,@IsNextGlassBreakPasswordOverdue     bit               = null -- not a base table column
	,@GlassBreakCountInLast24Hours        int               = null -- not a base table column
	,@License                             xml               = null -- not a base table column
	,@IsSysAdmin                          bit               = null -- not a base table column
	,@LastDBAccessTime                    datetimeoffset(7) = null -- not a base table column
	,@DaysSinceLastDBAccess               int               = null -- not a base table column
	,@IsAccessingNow                      bit               = null -- not a base table column
	,@IsUnused                            bit               = null -- not a base table column
	,@TemplateApplicationUserSID          int               = null -- not a base table column
	,@LatestUpdateTime                    datetimeoffset(7) = null -- not a base table column
	,@LatestUpdateUser                    nvarchar(75)      = null -- not a base table column
	,@DatabaseName                        nvarchar(128)     = null -- not a base table column
	,@IsConfirmed                         bit               = null -- not a base table column
	,@AutoSaveInterval                    smallint          = null -- not a base table column
	,@IsFederatedLogin                    bit               = null -- not a base table column
	,@DatabaseDisplayName                 nvarchar(129)     = null -- not a base table column
	,@DatabaseStatusColor                 char(9)           = null -- not a base table column
	,@ApplicationGrantXML                 xml               = null -- not a base table column
	,@Password                            nvarchar(50)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pApplicationUser#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.ApplicationUser table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.ApplicationUser table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vApplicationUser entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pApplicationUser procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fApplicationUserCheck to test all rules.

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

		if @ApplicationUserSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ApplicationUserSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @Comments = ltrim(rtrim(@Comments))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @ApplicationUserXID = ltrim(rtrim(@ApplicationUserXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @AuthenticationAuthoritySCD = ltrim(rtrim(@AuthenticationAuthoritySCD))
		set @AuthenticationAuthorityLabel = ltrim(rtrim(@AuthenticationAuthorityLabel))
		set @CultureSCD = ltrim(rtrim(@CultureSCD))
		set @CultureLabel = ltrim(rtrim(@CultureLabel))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ChangeReason = ltrim(rtrim(@ChangeReason))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @FullName = ltrim(rtrim(@FullName))
		set @DisplayName = ltrim(rtrim(@DisplayName))
		set @PrimaryEmailAddress = ltrim(rtrim(@PrimaryEmailAddress))
		set @PreferredPhone = ltrim(rtrim(@PreferredPhone))
		set @LatestUpdateUser = ltrim(rtrim(@LatestUpdateUser))
		set @DatabaseName = ltrim(rtrim(@DatabaseName))
		set @DatabaseDisplayName = ltrim(rtrim(@DatabaseDisplayName))
		set @DatabaseStatusColor = ltrim(rtrim(@DatabaseStatusColor))
		set @Password = ltrim(rtrim(@Password))

		-- set zero length strings to null to avoid storing them in the record

		if len(@UserName) = 0 set @UserName = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@Comments) = 0 set @Comments = null
		if len(@AuthenticationSystemID) = 0 set @AuthenticationSystemID = null
		if len(@ChangeAudit) = 0 set @ChangeAudit = null
		if len(@ApplicationUserXID) = 0 set @ApplicationUserXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@AuthenticationAuthoritySCD) = 0 set @AuthenticationAuthoritySCD = null
		if len(@AuthenticationAuthorityLabel) = 0 set @AuthenticationAuthorityLabel = null
		if len(@CultureSCD) = 0 set @CultureSCD = null
		if len(@CultureLabel) = 0 set @CultureLabel = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ChangeReason) = 0 set @ChangeReason = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@FullName) = 0 set @FullName = null
		if len(@DisplayName) = 0 set @DisplayName = null
		if len(@PrimaryEmailAddress) = 0 set @PrimaryEmailAddress = null
		if len(@PreferredPhone) = 0 set @PreferredPhone = null
		if len(@LatestUpdateUser) = 0 set @LatestUpdateUser = null
		if len(@DatabaseName) = 0 set @DatabaseName = null
		if len(@DatabaseDisplayName) = 0 set @DatabaseDisplayName = null
		if len(@DatabaseStatusColor) = 0 set @DatabaseStatusColor = null
		if len(@Password) = 0 set @Password = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                           = isnull(@PersonSID,au.PersonSID)
				,@CultureSID                          = isnull(@CultureSID,au.CultureSID)
				,@AuthenticationAuthoritySID          = isnull(@AuthenticationAuthoritySID,au.AuthenticationAuthoritySID)
				,@UserName                            = isnull(@UserName,au.UserName)
				,@LastReviewTime                      = isnull(@LastReviewTime,au.LastReviewTime)
				,@LastReviewUser                      = isnull(@LastReviewUser,au.LastReviewUser)
				,@IsPotentialDuplicate                = isnull(@IsPotentialDuplicate,au.IsPotentialDuplicate)
				,@IsTemplate                          = isnull(@IsTemplate,au.IsTemplate)
				,@GlassBreakPassword                  = isnull(@GlassBreakPassword,au.GlassBreakPassword)
				,@LastGlassBreakPasswordChangeTime    = isnull(@LastGlassBreakPasswordChangeTime,au.LastGlassBreakPasswordChangeTime)
				,@Comments                            = isnull(@Comments,au.Comments)
				,@IsActive                            = isnull(@IsActive,au.IsActive)
				,@AuthenticationSystemID              = isnull(@AuthenticationSystemID,au.AuthenticationSystemID)
				,@ChangeAudit                         = isnull(@ChangeAudit,au.ChangeAudit)
				,@UserDefinedColumns                  = isnull(@UserDefinedColumns,au.UserDefinedColumns)
				,@ApplicationUserXID                  = isnull(@ApplicationUserXID,au.ApplicationUserXID)
				,@LegacyKey                           = isnull(@LegacyKey,au.LegacyKey)
				,@UpdateUser                          = isnull(@UpdateUser,au.UpdateUser)
				,@IsReselected                        = isnull(@IsReselected,au.IsReselected)
				,@IsNullApplied                       = isnull(@IsNullApplied,au.IsNullApplied)
				,@zContext                            = isnull(@zContext,au.zContext)
				,@AuthenticationAuthoritySCD          = isnull(@AuthenticationAuthoritySCD,au.AuthenticationAuthoritySCD)
				,@AuthenticationAuthorityLabel        = isnull(@AuthenticationAuthorityLabel,au.AuthenticationAuthorityLabel)
				,@AuthenticationAuthorityIsActive     = isnull(@AuthenticationAuthorityIsActive,au.AuthenticationAuthorityIsActive)
				,@AuthenticationAuthorityIsDefault    = isnull(@AuthenticationAuthorityIsDefault,au.AuthenticationAuthorityIsDefault)
				,@AuthenticationAuthorityRowGUID      = isnull(@AuthenticationAuthorityRowGUID,au.AuthenticationAuthorityRowGUID)
				,@CultureSCD                          = isnull(@CultureSCD,au.CultureSCD)
				,@CultureLabel                        = isnull(@CultureLabel,au.CultureLabel)
				,@CultureIsDefault                    = isnull(@CultureIsDefault,au.CultureIsDefault)
				,@CultureIsActive                     = isnull(@CultureIsActive,au.CultureIsActive)
				,@CultureRowGUID                      = isnull(@CultureRowGUID,au.CultureRowGUID)
				,@GenderSID                           = isnull(@GenderSID,au.GenderSID)
				,@NamePrefixSID                       = isnull(@NamePrefixSID,au.NamePrefixSID)
				,@FirstName                           = isnull(@FirstName,au.FirstName)
				,@CommonName                          = isnull(@CommonName,au.CommonName)
				,@MiddleNames                         = isnull(@MiddleNames,au.MiddleNames)
				,@LastName                            = isnull(@LastName,au.LastName)
				,@BirthDate                           = isnull(@BirthDate,au.BirthDate)
				,@DeathDate                           = isnull(@DeathDate,au.DeathDate)
				,@HomePhone                           = isnull(@HomePhone,au.HomePhone)
				,@MobilePhone                         = isnull(@MobilePhone,au.MobilePhone)
				,@IsTextMessagingEnabled              = isnull(@IsTextMessagingEnabled,au.IsTextMessagingEnabled)
				,@ImportBatch                         = isnull(@ImportBatch,au.ImportBatch)
				,@PersonRowGUID                       = isnull(@PersonRowGUID,au.PersonRowGUID)
				,@ChangeReason                        = isnull(@ChangeReason,au.ChangeReason)
				,@IsDeleteEnabled                     = isnull(@IsDeleteEnabled,au.IsDeleteEnabled)
				,@ApplicationUserSessionSID           = isnull(@ApplicationUserSessionSID,au.ApplicationUserSessionSID)
				,@SessionGUID                         = isnull(@SessionGUID,au.SessionGUID)
				,@FileAsName                          = isnull(@FileAsName,au.FileAsName)
				,@FullName                            = isnull(@FullName,au.FullName)
				,@DisplayName                         = isnull(@DisplayName,au.DisplayName)
				,@PrimaryEmailAddress                 = isnull(@PrimaryEmailAddress,au.PrimaryEmailAddress)
				,@PrimaryEmailAddressSID              = isnull(@PrimaryEmailAddressSID,au.PrimaryEmailAddressSID)
				,@PreferredPhone                      = isnull(@PreferredPhone,au.PreferredPhone)
				,@LoginCount                          = isnull(@LoginCount,au.LoginCount)
				,@NextProfileReviewDueDate            = isnull(@NextProfileReviewDueDate,au.NextProfileReviewDueDate)
				,@IsNextProfileReviewOverdue          = isnull(@IsNextProfileReviewOverdue,au.IsNextProfileReviewOverdue)
				,@NextGlassBreakPasswordChangeDueDate = isnull(@NextGlassBreakPasswordChangeDueDate,au.NextGlassBreakPasswordChangeDueDate)
				,@IsNextGlassBreakPasswordOverdue     = isnull(@IsNextGlassBreakPasswordOverdue,au.IsNextGlassBreakPasswordOverdue)
				,@GlassBreakCountInLast24Hours        = isnull(@GlassBreakCountInLast24Hours,au.GlassBreakCountInLast24Hours)
				,@License                             = isnull(@License,au.License)
				,@IsSysAdmin                          = isnull(@IsSysAdmin,au.IsSysAdmin)
				,@LastDBAccessTime                    = isnull(@LastDBAccessTime,au.LastDBAccessTime)
				,@DaysSinceLastDBAccess               = isnull(@DaysSinceLastDBAccess,au.DaysSinceLastDBAccess)
				,@IsAccessingNow                      = isnull(@IsAccessingNow,au.IsAccessingNow)
				,@IsUnused                            = isnull(@IsUnused,au.IsUnused)
				,@TemplateApplicationUserSID          = isnull(@TemplateApplicationUserSID,au.TemplateApplicationUserSID)
				,@LatestUpdateTime                    = isnull(@LatestUpdateTime,au.LatestUpdateTime)
				,@LatestUpdateUser                    = isnull(@LatestUpdateUser,au.LatestUpdateUser)
				,@DatabaseName                        = isnull(@DatabaseName,au.DatabaseName)
				,@IsConfirmed                         = isnull(@IsConfirmed,au.IsConfirmed)
				,@AutoSaveInterval                    = isnull(@AutoSaveInterval,au.AutoSaveInterval)
				,@IsFederatedLogin                    = isnull(@IsFederatedLogin,au.IsFederatedLogin)
				,@DatabaseDisplayName                 = isnull(@DatabaseDisplayName,au.DatabaseDisplayName)
				,@DatabaseStatusColor                 = isnull(@DatabaseStatusColor,au.DatabaseStatusColor)
				,@ApplicationGrantXML                 = isnull(@ApplicationGrantXML,au.ApplicationGrantXML)
				,@Password                            = isnull(@Password,au.Password)
			from
				sf.vApplicationUser au
			where
				au.ApplicationUserSID = @ApplicationUserSID

		end
		
		-- update audit column when a change to the status of the record is detected
		
		if not exists
		(
			select
				1
			from
				sf.ApplicationUser x
			where
				x.ApplicationUserSID = @ApplicationUserSID												-- search for same record
			and
				x.IsActive = @IsActive																						-- with active bit value as passed
		)
		begin
			set @ChangeAudit = sf.fChangeAudit#Active(@IsActive, @ChangeReason, @ChangeAudit)
		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @AuthenticationAuthoritySCD is not null and @AuthenticationAuthoritySID = (select x.AuthenticationAuthoritySID from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID)
		begin
		
			select
				@AuthenticationAuthoritySID = x.AuthenticationAuthoritySID
			from
				sf.AuthenticationAuthority x
			where
				x.AuthenticationAuthoritySCD = @AuthenticationAuthoritySCD
		
		end
		
		if @CultureSCD is not null and @CultureSID = (select x.CultureSID from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID)
		begin
		
			select
				@CultureSID = x.CultureSID
			from
				sf.Culture x
			where
				x.CultureSCD = @CultureSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.AuthenticationAuthoritySID from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) <> @AuthenticationAuthoritySID
		begin
			if (select x.IsActive from sf.AuthenticationAuthority x where x.AuthenticationAuthoritySID = @AuthenticationAuthoritySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'authentication authority'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.CultureSID from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) <> @CultureSID
		begin
			if (select x.IsActive from sf.Culture x where x.CultureSID = @CultureSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'culture'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

    --! <PreUpdate>
    -- Tim Edlund | Dec 2012
    -- When the procedure detects a change to the IsActive bit an audit change is recorded
    -- including the user making the change, date and time, and an optional change reason.
		-- The latest change information is placed at the top of the column value.

    if not exists
    (
      select
        1
      from
        sf.ApplicationUser x
      where
        x.ApplicationUserSID = @ApplicationUserSID												-- search for same record
      and
        x.IsActive = @IsActive																						-- new setting of IsActive
    )
    begin
			set @ChangeAudit = sf.fChangeAudit#Active(@IsActive, @ChangeReason, @ChangeAudit)
    end

    -- Tim Edlund | Feb 2013
    -- When the procedure detects a change to the glass break password, the change time
		-- column for it is set automatically - overriding whatever value was passed. Note
		-- that if the password value is cleared, then the change time IS stored.

		if @GlassBreakPassword is null set @GlassBreakPassword = cast('~!@#' as varbinary(8000))

    if not exists
    (
      select
        1
      from
        sf.ApplicationUser x
      where
        x.ApplicationUserSID = @ApplicationUserSID												-- search for same record
      and
        isnull(x.GlassBreakPassword, cast('~!@#' as varbinary(8000))) = @GlassBreakPassword
    )
    begin
			set @LastGlassBreakPasswordChangeTime = sysdatetimeoffset()
    end

		if @GlassBreakPassword	= cast('~!@#' as varbinary(8000)) set @GlassBreakPassword = null

		-- Tim Edlund | May 2018
		-- When the potential duplicate flag is being cleared, automatically set
		-- the last reviewed time

		if @IsPotentialDuplicate = @OFF and exists
		(
			select
				1
			from
				sf.ApplicationUser au
			where
				au.ApplicationUserSID = @ApplicationUserSID and au.IsPotentialDuplicate = @ON
		)
		begin
			set @LastReviewTime = sysdatetimeoffset();
			set @LastReviewUser = @UpdateUser;
		end;

    --! </PreUpdate>

		-- update the record

		update
			sf.ApplicationUser
		set
			 PersonSID = @PersonSID
			,CultureSID = @CultureSID
			,AuthenticationAuthoritySID = @AuthenticationAuthoritySID
			,UserName = @UserName
			,LastReviewTime = @LastReviewTime
			,LastReviewUser = @LastReviewUser
			,IsPotentialDuplicate = @IsPotentialDuplicate
			,IsTemplate = @IsTemplate
			,GlassBreakPassword = @GlassBreakPassword
			,LastGlassBreakPasswordChangeTime = @LastGlassBreakPasswordChangeTime
			,Comments = @Comments
			,IsActive = @IsActive
			,AuthenticationSystemID = @AuthenticationSystemID
			,ChangeAudit = @ChangeAudit
			,UserDefinedColumns = @UserDefinedColumns
			,ApplicationUserXID = @ApplicationUserXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ApplicationUserSID = @ApplicationUserSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.ApplicationUser where ApplicationUserSID = @applicationUserSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.ApplicationUser'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.ApplicationUser'
					,@Arg2        = @applicationUserSID
				
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
				,@Arg2        = 'sf.ApplicationUser'
				,@Arg3        = @rowsAffected
				,@Arg4        = @applicationUserSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.ApplicationUserSID
			from
				sf.vApplicationUser ent
			where
				ent.ApplicationUserSID = @ApplicationUserSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.ApplicationUserSID
				,ent.PersonSID
				,ent.CultureSID
				,ent.AuthenticationAuthoritySID
				,ent.UserName
				,ent.LastReviewTime
				,ent.LastReviewUser
				,ent.IsPotentialDuplicate
				,ent.IsTemplate
				,ent.GlassBreakPassword
				,ent.LastGlassBreakPasswordChangeTime
				,ent.Comments
				,ent.IsActive
				,ent.AuthenticationSystemID
				,ent.ChangeAudit
				,ent.UserDefinedColumns
				,ent.ApplicationUserXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.AuthenticationAuthoritySCD
				,ent.AuthenticationAuthorityLabel
				,ent.AuthenticationAuthorityIsActive
				,ent.AuthenticationAuthorityIsDefault
				,ent.AuthenticationAuthorityRowGUID
				,ent.CultureSCD
				,ent.CultureLabel
				,ent.CultureIsDefault
				,ent.CultureIsActive
				,ent.CultureRowGUID
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.BirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.ChangeReason
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.ApplicationUserSessionSID
				,ent.SessionGUID
				,ent.FileAsName
				,ent.FullName
				,ent.DisplayName
				,ent.PrimaryEmailAddress
				,ent.PrimaryEmailAddressSID
				,ent.PreferredPhone
				,ent.LoginCount
				,ent.NextProfileReviewDueDate
				,ent.IsNextProfileReviewOverdue
				,ent.NextGlassBreakPasswordChangeDueDate
				,ent.IsNextGlassBreakPasswordOverdue
				,ent.GlassBreakCountInLast24Hours
				,ent.License
				,ent.IsSysAdmin
				,ent.LastDBAccessTime
				,ent.DaysSinceLastDBAccess
				,ent.IsAccessingNow
				,ent.IsUnused
				,ent.TemplateApplicationUserSID
				,ent.LatestUpdateTime
				,ent.LatestUpdateUser
				,ent.DatabaseName
				,ent.IsConfirmed
				,ent.AutoSaveInterval
				,ent.IsFederatedLogin
				,ent.DatabaseDisplayName
				,ent.DatabaseStatusColor
				,ent.ApplicationGrantXML
				,ent.Password
			from
				sf.vApplicationUser ent
			where
				ent.ApplicationUserSID = @ApplicationUserSID

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
