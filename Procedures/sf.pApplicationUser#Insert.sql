SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#Insert]
	 @ApplicationUserSID                  int               = null output		-- identity value assigned to the new record
	,@PersonSID                           int               = null					-- required! if not passed value must be set in custom logic prior to insert
	,@CultureSID                          int               = null					-- required! if not passed value must be set in custom logic prior to insert
	,@AuthenticationAuthoritySID          int               = null					-- required! if not passed value must be set in custom logic prior to insert
	,@UserName                            nvarchar(75)      = null					-- required! if not passed value must be set in custom logic prior to insert
	,@LastReviewTime                      datetimeoffset(7) = null					-- default: sysdatetimeoffset()
	,@LastReviewUser                      nvarchar(75)      = null					-- default: suser_sname()
	,@IsPotentialDuplicate                bit               = null					-- default: CONVERT(bit,(0))
	,@IsTemplate                          bit               = null					-- default: (0)
	,@GlassBreakPassword                  varbinary(8000)   = null					
	,@LastGlassBreakPasswordChangeTime    datetimeoffset(7) = null					
	,@Comments                            nvarchar(max)     = null					
	,@IsActive                            bit               = null					-- default: (1)
	,@AuthenticationSystemID              nvarchar(50)      = null					-- default: N'!'+CONVERT(nvarchar(48),newid(),(0))
	,@ChangeAudit                         nvarchar(max)     = null					-- default: 'Activated by '+suser_sname()
	,@UserDefinedColumns                  xml               = null					
	,@ApplicationUserXID                  varchar(150)      = null					
	,@LegacyKey                           nvarchar(50)      = null					
	,@CreateUser                          nvarchar(75)      = null					-- default: suser_sname()
	,@IsReselected                        tinyint           = null					-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                            xml               = null					-- other values defining context for the insert (if any)
	,@AuthenticationAuthoritySCD          varchar(10)       = null					-- not a base table column (default ignored)
	,@AuthenticationAuthorityLabel        nvarchar(35)      = null					-- not a base table column (default ignored)
	,@AuthenticationAuthorityIsActive     bit               = null					-- not a base table column (default ignored)
	,@AuthenticationAuthorityIsDefault    bit               = null					-- not a base table column (default ignored)
	,@AuthenticationAuthorityRowGUID      uniqueidentifier  = null					-- not a base table column (default ignored)
	,@CultureSCD                          varchar(10)       = null					-- not a base table column (default ignored)
	,@CultureLabel                        nvarchar(35)      = null					-- not a base table column (default ignored)
	,@CultureIsDefault                    bit               = null					-- not a base table column (default ignored)
	,@CultureIsActive                     bit               = null					-- not a base table column (default ignored)
	,@CultureRowGUID                      uniqueidentifier  = null					-- not a base table column (default ignored)
	,@GenderSID                           int               = null					-- not a base table column (default ignored)
	,@NamePrefixSID                       int               = null					-- not a base table column (default ignored)
	,@FirstName                           nvarchar(30)      = null					-- not a base table column (default ignored)
	,@CommonName                          nvarchar(30)      = null					-- not a base table column (default ignored)
	,@MiddleNames                         nvarchar(30)      = null					-- not a base table column (default ignored)
	,@LastName                            nvarchar(35)      = null					-- not a base table column (default ignored)
	,@BirthDate                           date              = null					-- not a base table column (default ignored)
	,@DeathDate                           date              = null					-- not a base table column (default ignored)
	,@HomePhone                           varchar(25)       = null					-- not a base table column (default ignored)
	,@MobilePhone                         varchar(25)       = null					-- not a base table column (default ignored)
	,@IsTextMessagingEnabled              bit               = null					-- not a base table column (default ignored)
	,@ImportBatch                         nvarchar(100)     = null					-- not a base table column (default ignored)
	,@PersonRowGUID                       uniqueidentifier  = null					-- not a base table column (default ignored)
	,@ChangeReason                        nvarchar(4000)    = null					-- not a base table column (default ignored)
	,@IsDeleteEnabled                     bit               = null					-- not a base table column (default ignored)
	,@ApplicationUserSessionSID           int               = null					-- not a base table column (default ignored)
	,@SessionGUID                         uniqueidentifier  = null					-- not a base table column (default ignored)
	,@FileAsName                          nvarchar(65)      = null					-- not a base table column (default ignored)
	,@FullName                            nvarchar(65)      = null					-- not a base table column (default ignored)
	,@DisplayName                         nvarchar(65)      = null					-- not a base table column (default ignored)
	,@PrimaryEmailAddress                 varchar(150)      = null					-- not a base table column (default ignored)
	,@PrimaryEmailAddressSID              int               = null					-- not a base table column (default ignored)
	,@PreferredPhone                      varchar(25)       = null					-- not a base table column (default ignored)
	,@LoginCount                          int               = null					-- not a base table column (default ignored)
	,@NextProfileReviewDueDate            smalldatetime     = null					-- not a base table column (default ignored)
	,@IsNextProfileReviewOverdue          bit               = null					-- not a base table column (default ignored)
	,@NextGlassBreakPasswordChangeDueDate smalldatetime     = null					-- not a base table column (default ignored)
	,@IsNextGlassBreakPasswordOverdue     bit               = null					-- not a base table column (default ignored)
	,@GlassBreakCountInLast24Hours        int               = null					-- not a base table column (default ignored)
	,@License                             xml               = null					-- not a base table column (default ignored)
	,@IsSysAdmin                          bit               = null					-- not a base table column (default ignored)
	,@LastDBAccessTime                    datetimeoffset(7) = null					-- not a base table column (default ignored)
	,@DaysSinceLastDBAccess               int               = null					-- not a base table column (default ignored)
	,@IsAccessingNow                      bit               = null					-- not a base table column (default ignored)
	,@IsUnused                            bit               = null					-- not a base table column (default ignored)
	,@TemplateApplicationUserSID          int               = null					-- not a base table column (default ignored)
	,@LatestUpdateTime                    datetimeoffset(7) = null					-- not a base table column (default ignored)
	,@LatestUpdateUser                    nvarchar(75)      = null					-- not a base table column (default ignored)
	,@DatabaseName                        nvarchar(128)     = null					-- not a base table column (default ignored)
	,@IsConfirmed                         bit               = null					-- not a base table column (default ignored)
	,@AutoSaveInterval                    smallint          = null					-- not a base table column (default ignored)
	,@IsFederatedLogin                    bit               = null					-- not a base table column (default ignored)
	,@DatabaseDisplayName                 nvarchar(129)     = null					-- not a base table column (default ignored)
	,@DatabaseStatusColor                 char(9)           = null					-- not a base table column (default ignored)
	,@ApplicationGrantXML                 xml               = null					-- not a base table column (default ignored)
	,@Password                            nvarchar(50)      = null					-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pApplicationUser#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.ApplicationUser table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.ApplicationUser table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vApplicationUser entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pApplicationUser procedure. The extended procedure is only called
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

	set @ApplicationUserSID = null																					-- initialize output parameter

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

		set @UserName = ltrim(rtrim(@UserName))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @Comments = ltrim(rtrim(@Comments))
		set @AuthenticationSystemID = ltrim(rtrim(@AuthenticationSystemID))
		set @ChangeAudit = ltrim(rtrim(@ChangeAudit))
		set @ApplicationUserXID = ltrim(rtrim(@ApplicationUserXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @LastReviewTime = isnull(@LastReviewTime,sysdatetimeoffset())
		set @LastReviewUser = isnull(@LastReviewUser,suser_sname())
		set @IsPotentialDuplicate = isnull(@IsPotentialDuplicate,CONVERT(bit,(0)))
		set @IsTemplate = isnull(@IsTemplate,(0))
		set @IsActive = isnull(@IsActive,(1))
		set @AuthenticationSystemID = isnull(@AuthenticationSystemID,N'!'+CONVERT(nvarchar(48),newid(),(0)))
		set @ChangeAudit = isnull(@ChangeAudit,'Activated by '+suser_sname())
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                     = isnull(@IsReselected                    ,(0))
		
		-- call a function to format the comment for the auditing column
		
		set @ChangeAudit = sf.fChangeAudit#Active(@IsActive, @ChangeReason, null)
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @AuthenticationAuthoritySCD is not null
		begin
		
			select
				@AuthenticationAuthoritySID = x.AuthenticationAuthoritySID
			from
				sf.AuthenticationAuthority x
			where
				x.AuthenticationAuthoritySCD = @AuthenticationAuthoritySCD
		
		end
		
		if @CultureSCD is not null
		begin
		
			select
				@CultureSID = x.CultureSID
			from
				sf.Culture x
			where
				x.CultureSCD = @CultureSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @AuthenticationAuthoritySID  is null select @AuthenticationAuthoritySID  = x.AuthenticationAuthoritySID from sf.AuthenticationAuthority  x where x.IsDefault = @ON
		if @CultureSID                  is null select @CultureSID                  = x.CultureSID                 from sf.Culture                  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Nov 2012
		-- When a record is first created the "last review" is marked with the current time
		-- and user.  Even if these values are provided, they are overwritten here to ensure
		-- they reflect the actual insert credentials and time.

		set @LastReviewTime = sysdatetimeoffset()
		set @LastReviewUser = @CreateUser

		-- Cory Ng | Jul 2014
		-- Sets the authentication system ID to a default value that will be replaced
		-- in a trigger after insert if the system ID is not passed. A default value
		-- exists on the column that sets it to the same value but if null is explicitly
		-- passed into the insert statement the default is not used.

		set @AuthenticationSystemID = isnull(@AuthenticationSystemID, N'[!' + cast(newid() as nvarchar(48)))

		-- Tim Edlund | May 2018
		-- Flag the account as a potential duplicate based on name and
		-- phone numbers. A UK ensures the email address/username
		-- will not be duplicated.  There are 3 scenarios for which
		-- the duplicate flag is set:

		if exists																															-- #1 Lastname and first name exist
		(
			select
				1
			from
				sf.Person p
			where
				p.LastName = @LastName and p.FirstName = @FirstName
			and
				p.PersonSID <> @PersonSID
		)
		begin
			set @IsPotentialDuplicate = @ON;
		end;

		if @IsPotentialDuplicate = @OFF and @MobilePhone is not null					-- #2 mobile phone number exists
		begin

			if exists (select 1 from sf .Person p where p.MobilePhone = @MobilePhone and p.PersonSID <> @PersonSID)
			begin
				set @IsPotentialDuplicate = @ON;
			end;

		end;

		if @IsPotentialDuplicate = @OFF and @HomePhone is not null						-- #3. Lastname, first initial of first name and home phone match
		begin

			if exists
			(
				select
					1
				from
					sf.Person p
				where
					p.LastName = @LastName and p.FirstName like left(@FirstName, 1)
				and
					p.PersonSID <> @PersonSID
			)
			begin

				if exists (select 1 from sf .Person p where p.HomePhone = @HomePhone and p.PersonSID <> @PersonSID)
				begin
					set @IsPotentialDuplicate = @ON;
				end;

			end;

		end;
		--! </PreInsert>

		-- insert the record

		insert
			sf.ApplicationUser
		(
			 PersonSID
			,CultureSID
			,AuthenticationAuthoritySID
			,UserName
			,LastReviewTime
			,LastReviewUser
			,IsPotentialDuplicate
			,IsTemplate
			,GlassBreakPassword
			,LastGlassBreakPasswordChangeTime
			,Comments
			,IsActive
			,AuthenticationSystemID
			,ChangeAudit
			,UserDefinedColumns
			,ApplicationUserXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@CultureSID
			,@AuthenticationAuthoritySID
			,@UserName
			,@LastReviewTime
			,@LastReviewUser
			,@IsPotentialDuplicate
			,@IsTemplate
			,@GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime
			,@Comments
			,@IsActive
			,@AuthenticationSystemID
			,@ChangeAudit
			,@UserDefinedColumns
			,@ApplicationUserXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected       = @@rowcount
			,@ApplicationUserSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.ApplicationUser'
				,@Arg3        = @rowsAffected
				,@Arg4        = @ApplicationUserSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Mar 2019
		-- If a template is specified on the insert, copy grants from the template
		-- to this user profile.  A subroutine handles the operation. If no template
		-- is identified, do NOT assign a default grant.

		if @TemplateApplicationUserSID is not null
		begin

			exec sf.pApplicationUserGrant#Sync
				@SourceApplicationUserSID = @TemplateApplicationUserSID
			 ,@TargetApplicationUserSID = @ApplicationUserSID
			 ,@UpdateUser = @CreateUser;

		end;

		-- Tim Edlund | Jun 2013
		-- Add administrative users (only) to any task queues that are marked
		-- with the auto-assign bit enabled

		if exists
		(
			select
				1
			from
				sf.ApplicationUserGrant aug
			join
				sf.ApplicationGrant			ag on aug.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				aug.ApplicationUserSID = @ApplicationUserSID and ag.ApplicationGrantSCD like 'ADMIN.%'
		)
		begin

			declare
				@i			int		-- loop index
			 ,@maxRow int;	-- max rows

			declare @work table (ID int identity(1, 1), TaskQueueSID int not null);

			insert
				@work (TaskQueueSID)
			select
				tq.TaskQueueSID
			from
				sf.TaskQueue tq
			where
				tq.IsActive = @ON and tq.IsAutoAssigned = @ON
			order by
				tq.TaskQueueSID;

			set @maxRow = @@rowcount;
			set @i = 0;

			while @i < @maxRow
			begin

				set @i += 1;

				select @recordSID	 = w.TaskQueueSID from @work w where w.ID = @i;

				exec sf.pTaskQueueSubscriber#Insert
					@ApplicationUserSID = @ApplicationUserSID
				 ,@TaskQueueSID = @recordSID;

			end;

		end;

		-- Tim Edlund | Apr 2017
		-- If a password was provided and no password is currently set, then update the
		-- record with the new encrypted password (will cause one recursion in trigger)

		if @Password is not null and exists
		(
			select
				1
			from
				sf.ApplicationUser au
			where
				au.ApplicationUserSID = @ApplicationUserSID and au.GlassBreakPassword is null
		)
		begin

			update
				sf.ApplicationUser
			set
				GlassBreakPassword = sf.fHashString(cast(RowGUID as nvarchar(50)), @Password)
			where
				ApplicationUserSID = @ApplicationUserSID;

		end;
	--! </PostInsert>

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
