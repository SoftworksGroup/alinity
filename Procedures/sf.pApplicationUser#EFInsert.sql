SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#EFInsert]
	 @PersonSID                           int               = null					-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : sf.pApplicationUser#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pApplicationUser#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = sf.pApplicationUser#Insert
			 @PersonSID                           = @PersonSID
			,@CultureSID                          = @CultureSID
			,@AuthenticationAuthoritySID          = @AuthenticationAuthoritySID
			,@UserName                            = @UserName
			,@LastReviewTime                      = @LastReviewTime
			,@LastReviewUser                      = @LastReviewUser
			,@IsPotentialDuplicate                = @IsPotentialDuplicate
			,@IsTemplate                          = @IsTemplate
			,@GlassBreakPassword                  = @GlassBreakPassword
			,@LastGlassBreakPasswordChangeTime    = @LastGlassBreakPasswordChangeTime
			,@Comments                            = @Comments
			,@IsActive                            = @IsActive
			,@AuthenticationSystemID              = @AuthenticationSystemID
			,@ChangeAudit                         = @ChangeAudit
			,@UserDefinedColumns                  = @UserDefinedColumns
			,@ApplicationUserXID                  = @ApplicationUserXID
			,@LegacyKey                           = @LegacyKey
			,@CreateUser                          = @CreateUser
			,@IsReselected                        = @IsReselected
			,@zContext                            = @zContext
			,@AuthenticationAuthoritySCD          = @AuthenticationAuthoritySCD
			,@AuthenticationAuthorityLabel        = @AuthenticationAuthorityLabel
			,@AuthenticationAuthorityIsActive     = @AuthenticationAuthorityIsActive
			,@AuthenticationAuthorityIsDefault    = @AuthenticationAuthorityIsDefault
			,@AuthenticationAuthorityRowGUID      = @AuthenticationAuthorityRowGUID
			,@CultureSCD                          = @CultureSCD
			,@CultureLabel                        = @CultureLabel
			,@CultureIsDefault                    = @CultureIsDefault
			,@CultureIsActive                     = @CultureIsActive
			,@CultureRowGUID                      = @CultureRowGUID
			,@GenderSID                           = @GenderSID
			,@NamePrefixSID                       = @NamePrefixSID
			,@FirstName                           = @FirstName
			,@CommonName                          = @CommonName
			,@MiddleNames                         = @MiddleNames
			,@LastName                            = @LastName
			,@BirthDate                           = @BirthDate
			,@DeathDate                           = @DeathDate
			,@HomePhone                           = @HomePhone
			,@MobilePhone                         = @MobilePhone
			,@IsTextMessagingEnabled              = @IsTextMessagingEnabled
			,@ImportBatch                         = @ImportBatch
			,@PersonRowGUID                       = @PersonRowGUID
			,@ChangeReason                        = @ChangeReason
			,@IsDeleteEnabled                     = @IsDeleteEnabled
			,@ApplicationUserSessionSID           = @ApplicationUserSessionSID
			,@SessionGUID                         = @SessionGUID
			,@FileAsName                          = @FileAsName
			,@FullName                            = @FullName
			,@DisplayName                         = @DisplayName
			,@PrimaryEmailAddress                 = @PrimaryEmailAddress
			,@PrimaryEmailAddressSID              = @PrimaryEmailAddressSID
			,@PreferredPhone                      = @PreferredPhone
			,@LoginCount                          = @LoginCount
			,@NextProfileReviewDueDate            = @NextProfileReviewDueDate
			,@IsNextProfileReviewOverdue          = @IsNextProfileReviewOverdue
			,@NextGlassBreakPasswordChangeDueDate = @NextGlassBreakPasswordChangeDueDate
			,@IsNextGlassBreakPasswordOverdue     = @IsNextGlassBreakPasswordOverdue
			,@GlassBreakCountInLast24Hours        = @GlassBreakCountInLast24Hours
			,@License                             = @License
			,@IsSysAdmin                          = @IsSysAdmin
			,@LastDBAccessTime                    = @LastDBAccessTime
			,@DaysSinceLastDBAccess               = @DaysSinceLastDBAccess
			,@IsAccessingNow                      = @IsAccessingNow
			,@IsUnused                            = @IsUnused
			,@TemplateApplicationUserSID          = @TemplateApplicationUserSID
			,@LatestUpdateTime                    = @LatestUpdateTime
			,@LatestUpdateUser                    = @LatestUpdateUser
			,@DatabaseName                        = @DatabaseName
			,@IsConfirmed                         = @IsConfirmed
			,@AutoSaveInterval                    = @AutoSaveInterval
			,@IsFederatedLogin                    = @IsFederatedLogin
			,@DatabaseDisplayName                 = @DatabaseDisplayName
			,@DatabaseStatusColor                 = @DatabaseStatusColor
			,@ApplicationGrantXML                 = @ApplicationGrantXML
			,@Password                            = @Password

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
