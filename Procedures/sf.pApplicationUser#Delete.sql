SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#Delete]
	 @ApplicationUserSID                  int               = null -- required! id of row to delete - must be set in custom logic if not passed
	,@UpdateUser                          nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                            timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@PersonSID                           int               = null
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
	,@IsDeleted                           bit               = null
	,@CreateUser                          nvarchar(75)      = null
	,@CreateTime                          datetimeoffset(7) = null
	,@UpdateTime                          datetimeoffset(7) = null
	,@RowGUID                             uniqueidentifier  = null
	,@AuthenticationAuthoritySCD          varchar(10)       = null
	,@AuthenticationAuthorityLabel        nvarchar(35)      = null
	,@AuthenticationAuthorityIsActive     bit               = null
	,@AuthenticationAuthorityIsDefault    bit               = null
	,@AuthenticationAuthorityRowGUID      uniqueidentifier  = null
	,@CultureSCD                          varchar(10)       = null
	,@CultureLabel                        nvarchar(35)      = null
	,@CultureIsDefault                    bit               = null
	,@CultureIsActive                     bit               = null
	,@CultureRowGUID                      uniqueidentifier  = null
	,@GenderSID                           int               = null
	,@NamePrefixSID                       int               = null
	,@FirstName                           nvarchar(30)      = null
	,@CommonName                          nvarchar(30)      = null
	,@MiddleNames                         nvarchar(30)      = null
	,@LastName                            nvarchar(35)      = null
	,@BirthDate                           date              = null
	,@DeathDate                           date              = null
	,@HomePhone                           varchar(25)       = null
	,@MobilePhone                         varchar(25)       = null
	,@IsTextMessagingEnabled              bit               = null
	,@ImportBatch                         nvarchar(100)     = null
	,@PersonRowGUID                       uniqueidentifier  = null
	,@ChangeReason                        nvarchar(4000)    = null
	,@IsDeleteEnabled                     bit               = null
	,@zContext                            xml               = null -- other values defining context for the delete (if any)
	,@ApplicationUserSessionSID           int               = null
	,@SessionGUID                         uniqueidentifier  = null
	,@FileAsName                          nvarchar(65)      = null
	,@FullName                            nvarchar(65)      = null
	,@DisplayName                         nvarchar(65)      = null
	,@PrimaryEmailAddress                 varchar(150)      = null
	,@PrimaryEmailAddressSID              int               = null
	,@PreferredPhone                      varchar(25)       = null
	,@LoginCount                          int               = null
	,@NextProfileReviewDueDate            smalldatetime     = null
	,@IsNextProfileReviewOverdue          bit               = null
	,@NextGlassBreakPasswordChangeDueDate smalldatetime     = null
	,@IsNextGlassBreakPasswordOverdue     bit               = null
	,@GlassBreakCountInLast24Hours        int               = null
	,@License                             xml               = null
	,@IsSysAdmin                          bit               = null
	,@LastDBAccessTime                    datetimeoffset(7) = null
	,@DaysSinceLastDBAccess               int               = null
	,@IsAccessingNow                      bit               = null
	,@IsUnused                            bit               = null
	,@TemplateApplicationUserSID          int               = null
	,@LatestUpdateTime                    datetimeoffset(7) = null
	,@LatestUpdateUser                    nvarchar(75)      = null
	,@DatabaseName                        nvarchar(128)     = null
	,@IsConfirmed                         bit               = null
	,@AutoSaveInterval                    smallint          = null
	,@IsFederatedLogin                    bit               = null
	,@DatabaseDisplayName                 nvarchar(129)     = null
	,@DatabaseStatusColor                 char(9)           = null
	,@ApplicationGrantXML                 xml               = null
	,@Password                            nvarchar(50)      = null
as
/*********************************************************************************************************************************
Procedure : sf.pApplicationUser#Delete
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : deletes 1 row in the sf.ApplicationUser table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.ApplicationUser table. The procedure requires a primary key value to locate the record
to delete.

If the @UpdateUser parameter is set to the special value "SystemUser", then the system user established in sf.ConfigParam is
applied.  This option is useful for conversion and system generated deletes the user would not recognized as having caused. Any
other setting of @UpdateUser is ignored and the user identity is used for the deletion.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Other parameters are provided to set context of the deletion event for table-specific and client-specific logic.

Table-specific logic can be added through tagged sections (pre and post update) and a call to an extended procedure supports
client-specific logic. Logic implemented within code tags (table-specific logic) is part of the base product and applies to all client
configurations. Calls to the extended procedure occur immediately after the table-specific logic in both "pre-delete" and "post-delete"
contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pApplicationUser procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "delete.pre" or "delete.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

This procedure is constructed to support the "Change Data Capture" (CDC) feature. Capturing the user making deletions requires
that the UpdateUser column be set before the record is deleted.  If this is not done, it is not possible to see which user
made the deletion in the CDC table. To trap audit information, the "$isDeletedColumn" bit is set to 1 in an update first.  Once
the update is complete the delete operation takes place. Both operations are handled in a single transaction so that both rollback
if either is unsuccessful. This ensures no record remains in the table with the $isDeleteColumn$ bit set to 1 (no soft-deletes).

Business rules for deletion cannot be established in constraints so must be created in this procedure for product-based common rules
and in the ext.pApplicationUser procedure for client-specific deletion rules.

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

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- -- if no row version value was provided, look it up based on the primary key (avoids blocking)

		if @RowStamp is null select @RowStamp = x.RowStamp from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID

		-- apply the table-specific pre-delete logic (if any)

		--! <PreDelete>
		--  insert pre-delete logic here ...
		--! </PreDelete>
		
		update																																-- set audit details on sf.ApplicationUserGrant rows that will delete through CASCADE
			sf.ApplicationUserGrant
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			ApplicationUserSID = @ApplicationUserSID
		
		update																																-- set audit details on sf.ApplicationUserProfileProperty rows that will delete through CASCADE
			sf.ApplicationUserProfileProperty
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			ApplicationUserSID = @ApplicationUserSID
		
		update																																-- set audit details on sf.ClearedAnnouncement rows that will delete through CASCADE
			sf.ClearedAnnouncement
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			ApplicationUserSID = @ApplicationUserSID
		
		update																																-- set audit details on sf.TaskQueueSubscriber rows that will delete through CASCADE
			sf.TaskQueueSubscriber
		set
			 IsDeleted  = cast(1 as bit)
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @UpdateUser
		where
			ApplicationUserSID = @ApplicationUserSID

		update																																-- update "IsDeleted" column to trap audit information
			sf.ApplicationUser
		set
			 IsDeleted = cast(1 as bit)
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			ApplicationUserSID = @ApplicationUserSID
			and
			RowStamp = @RowStamp
		
		set @rowsAffected = @@rowcount
		
		if @rowsAffected = 1																									-- if update succeeded delete the record
		begin
			
			delete
				sf.ApplicationUser
			where
				ApplicationUserSID = @ApplicationUserSID
			
			set @rowsAffected = @@rowcount
			
		end

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
				,@Arg1        = 'delete'
				,@Arg2        = 'sf.ApplicationUser'
				,@Arg3        = @rowsAffected
				,@Arg4        = @applicationUserSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-delete logic (if any)

    --! <PostDelete>
    -- Tim Edlund | Nov 2012
    -- If the Application User deleted successfully, it is possible that no other roles exist for the
    -- associated sf.Person record.  Because the Framework cannot know the list of associations that
    -- may possibly exist, a delete of the sf.Person record is attempted in a separate catch block
    -- AFTER the previous updates are committed.  If any FK error assumes, it is not reported and
    -- the procedure returns normally.
   commit

    begin try

      begin transaction       -- begin another transaction since previous was committed

      delete
        sf.Person
      where
        PersonSID  = @PersonSID                                            -- attempt deletion of associated person

  end try
    begin catch
      set @errorNo = 0                                                    -- assumed to be FK error from non-SF schema table
    end catch
    --! </PostDelete>

		if @trancount = 0 and xact_state() = 1 commit transaction

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
