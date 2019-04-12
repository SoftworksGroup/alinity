SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroupMember#Update]
	 @PersonGroupMemberSID           int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonGroupSID                 int               = null -- table column values to update:
	,@PersonSID                      int               = null
	,@Title                          nvarchar(75)      = null
	,@IsAdministrator                bit               = null
	,@IsContributor                  bit               = null
	,@EffectiveTime                  datetime          = null
	,@ExpiryTime                     datetime          = null
	,@IsReplacementRequiredAfterTerm bit               = null
	,@ReplacementClearedDate         date              = null
	,@UserDefinedColumns             xml               = null
	,@PersonGroupMemberXID           varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@GenderSID                      int               = null -- not a base table column
	,@NamePrefixSID                  int               = null -- not a base table column
	,@FirstName                      nvarchar(30)      = null -- not a base table column
	,@CommonName                     nvarchar(30)      = null -- not a base table column
	,@MiddleNames                    nvarchar(30)      = null -- not a base table column
	,@LastName                       nvarchar(35)      = null -- not a base table column
	,@BirthDate                      date              = null -- not a base table column
	,@DeathDate                      date              = null -- not a base table column
	,@HomePhone                      varchar(25)       = null -- not a base table column
	,@MobilePhone                    varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled         bit               = null -- not a base table column
	,@ImportBatch                    nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID                  uniqueidentifier  = null -- not a base table column
	,@PersonGroupName                nvarchar(65)      = null -- not a base table column
	,@PersonGroupLabel               nvarchar(35)      = null -- not a base table column
	,@PersonGroupCategory            nvarchar(65)      = null -- not a base table column
	,@Description                    nvarchar(500)     = null -- not a base table column
	,@ApplicationUserSID             int               = null -- not a base table column
	,@IsPreference                   bit               = null -- not a base table column
	,@IsDocumentLibraryEnabled       bit               = null -- not a base table column
	,@QuerySID                       int               = null -- not a base table column
	,@LastReviewUser                 nvarchar(75)      = null -- not a base table column
	,@LastReviewTime                 datetimeoffset(7) = null -- not a base table column
	,@SmartGroupCount                int               = null -- not a base table column
	,@SmartGroupCountTime            datetimeoffset(7) = null -- not a base table column
	,@PersonGroupIsActive            bit               = null -- not a base table column
	,@PersonGroupRowGUID             uniqueidentifier  = null -- not a base table column
	,@IsActive                       bit               = null -- not a base table column
	,@IsPending                      bit               = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@DisplayName                    nvarchar(65)      = null -- not a base table column
	,@EmailAddress                   varchar(150)      = null -- not a base table column
	,@PhoneNumber                    varchar(25)       = null -- not a base table column
	,@IsTermExpired                  bit               = null -- not a base table column
	,@TermLabel                      nvarchar(4000)    = null -- not a base table column
	,@IsReplacementRequired          bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroupMember#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.PersonGroupMember table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.PersonGroupMember table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonGroupMember entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonGroupMember procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonGroupMemberCheck to test all rules.

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

		if @PersonGroupMemberSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonGroupMemberSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @Title = ltrim(rtrim(@Title))
		set @PersonGroupMemberXID = ltrim(rtrim(@PersonGroupMemberXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @PersonGroupName = ltrim(rtrim(@PersonGroupName))
		set @PersonGroupLabel = ltrim(rtrim(@PersonGroupLabel))
		set @PersonGroupCategory = ltrim(rtrim(@PersonGroupCategory))
		set @Description = ltrim(rtrim(@Description))
		set @LastReviewUser = ltrim(rtrim(@LastReviewUser))
		set @DisplayName = ltrim(rtrim(@DisplayName))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @PhoneNumber = ltrim(rtrim(@PhoneNumber))
		set @TermLabel = ltrim(rtrim(@TermLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@Title) = 0 set @Title = null
		if len(@PersonGroupMemberXID) = 0 set @PersonGroupMemberXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@PersonGroupName) = 0 set @PersonGroupName = null
		if len(@PersonGroupLabel) = 0 set @PersonGroupLabel = null
		if len(@PersonGroupCategory) = 0 set @PersonGroupCategory = null
		if len(@Description) = 0 set @Description = null
		if len(@LastReviewUser) = 0 set @LastReviewUser = null
		if len(@DisplayName) = 0 set @DisplayName = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@PhoneNumber) = 0 set @PhoneNumber = null
		if len(@TermLabel) = 0 set @TermLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonGroupSID                 = isnull(@PersonGroupSID,pgm.PersonGroupSID)
				,@PersonSID                      = isnull(@PersonSID,pgm.PersonSID)
				,@Title                          = isnull(@Title,pgm.Title)
				,@IsAdministrator                = isnull(@IsAdministrator,pgm.IsAdministrator)
				,@IsContributor                  = isnull(@IsContributor,pgm.IsContributor)
				,@EffectiveTime                  = isnull(@EffectiveTime,pgm.EffectiveTime)
				,@ExpiryTime                     = isnull(@ExpiryTime,pgm.ExpiryTime)
				,@IsReplacementRequiredAfterTerm = isnull(@IsReplacementRequiredAfterTerm,pgm.IsReplacementRequiredAfterTerm)
				,@ReplacementClearedDate         = isnull(@ReplacementClearedDate,pgm.ReplacementClearedDate)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,pgm.UserDefinedColumns)
				,@PersonGroupMemberXID           = isnull(@PersonGroupMemberXID,pgm.PersonGroupMemberXID)
				,@LegacyKey                      = isnull(@LegacyKey,pgm.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,pgm.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,pgm.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,pgm.IsNullApplied)
				,@zContext                       = isnull(@zContext,pgm.zContext)
				,@GenderSID                      = isnull(@GenderSID,pgm.GenderSID)
				,@NamePrefixSID                  = isnull(@NamePrefixSID,pgm.NamePrefixSID)
				,@FirstName                      = isnull(@FirstName,pgm.FirstName)
				,@CommonName                     = isnull(@CommonName,pgm.CommonName)
				,@MiddleNames                    = isnull(@MiddleNames,pgm.MiddleNames)
				,@LastName                       = isnull(@LastName,pgm.LastName)
				,@BirthDate                      = isnull(@BirthDate,pgm.BirthDate)
				,@DeathDate                      = isnull(@DeathDate,pgm.DeathDate)
				,@HomePhone                      = isnull(@HomePhone,pgm.HomePhone)
				,@MobilePhone                    = isnull(@MobilePhone,pgm.MobilePhone)
				,@IsTextMessagingEnabled         = isnull(@IsTextMessagingEnabled,pgm.IsTextMessagingEnabled)
				,@ImportBatch                    = isnull(@ImportBatch,pgm.ImportBatch)
				,@PersonRowGUID                  = isnull(@PersonRowGUID,pgm.PersonRowGUID)
				,@PersonGroupName                = isnull(@PersonGroupName,pgm.PersonGroupName)
				,@PersonGroupLabel               = isnull(@PersonGroupLabel,pgm.PersonGroupLabel)
				,@PersonGroupCategory            = isnull(@PersonGroupCategory,pgm.PersonGroupCategory)
				,@Description                    = isnull(@Description,pgm.Description)
				,@ApplicationUserSID             = isnull(@ApplicationUserSID,pgm.ApplicationUserSID)
				,@IsPreference                   = isnull(@IsPreference,pgm.IsPreference)
				,@IsDocumentLibraryEnabled       = isnull(@IsDocumentLibraryEnabled,pgm.IsDocumentLibraryEnabled)
				,@QuerySID                       = isnull(@QuerySID,pgm.QuerySID)
				,@LastReviewUser                 = isnull(@LastReviewUser,pgm.LastReviewUser)
				,@LastReviewTime                 = isnull(@LastReviewTime,pgm.LastReviewTime)
				,@SmartGroupCount                = isnull(@SmartGroupCount,pgm.SmartGroupCount)
				,@SmartGroupCountTime            = isnull(@SmartGroupCountTime,pgm.SmartGroupCountTime)
				,@PersonGroupIsActive            = isnull(@PersonGroupIsActive,pgm.PersonGroupIsActive)
				,@PersonGroupRowGUID             = isnull(@PersonGroupRowGUID,pgm.PersonGroupRowGUID)
				,@IsActive                       = isnull(@IsActive,pgm.IsActive)
				,@IsPending                      = isnull(@IsPending,pgm.IsPending)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,pgm.IsDeleteEnabled)
				,@DisplayName                    = isnull(@DisplayName,pgm.DisplayName)
				,@EmailAddress                   = isnull(@EmailAddress,pgm.EmailAddress)
				,@PhoneNumber                    = isnull(@PhoneNumber,pgm.PhoneNumber)
				,@IsTermExpired                  = isnull(@IsTermExpired,pgm.IsTermExpired)
				,@TermLabel                      = isnull(@TermLabel,pgm.TermLabel)
				,@IsReplacementRequired          = isnull(@IsReplacementRequired,pgm.IsReplacementRequired)
			from
				sf.vPersonGroupMember pgm
			where
				pgm.PersonGroupMemberSID = @PersonGroupMemberSID

		end
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON
		begin
		
			if (select x.PersonGroupSID from sf.PersonGroupMember x where x.PersonGroupMemberSID = @PersonGroupMemberSID) <> @PersonGroupSID
			begin
			
				if (select x.IsActive from sf.PersonGroup x where x.PersonGroupSID = @PersonGroupSID) = @OFF
				begin
					
					exec sf.pMessage#Get
						 @MessageSCD  = 'AssignmentToInactiveParent'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
						,@Arg1        = N'person group'
					
					raiserror(@errorText, 16, 1)
					
				end
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Cory Ng | Jun 2017
		-- Set the expiry time if there is a difference between the
		-- active flag and the expiry time

		if @IsActive = @ON and @ExpiryTime is not null
		begin
			set @ExpiryTime = null
		end
		else if @IsActive = @OFF and @ExpiryTime is null
		begin
			set @ExpiryTime = sf.fNow()
		end
		--! </PreUpdate>

		-- update the record

		update
			sf.PersonGroupMember
		set
			 PersonGroupSID = @PersonGroupSID
			,PersonSID = @PersonSID
			,Title = @Title
			,IsAdministrator = @IsAdministrator
			,IsContributor = @IsContributor
			,EffectiveTime = @EffectiveTime
			,ExpiryTime = @ExpiryTime
			,IsReplacementRequiredAfterTerm = @IsReplacementRequiredAfterTerm
			,ReplacementClearedDate = @ReplacementClearedDate
			,UserDefinedColumns = @UserDefinedColumns
			,PersonGroupMemberXID = @PersonGroupMemberXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonGroupMemberSID = @PersonGroupMemberSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.PersonGroupMember where PersonGroupMemberSID = @personGroupMemberSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.PersonGroupMember'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.PersonGroupMember'
					,@Arg2        = @personGroupMemberSID
				
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
				,@Arg2        = 'sf.PersonGroupMember'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personGroupMemberSID
			
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
				 ent.PersonGroupMemberSID
			from
				sf.vPersonGroupMember ent
			where
				ent.PersonGroupMemberSID = @PersonGroupMemberSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonGroupMemberSID
				,ent.PersonGroupSID
				,ent.PersonSID
				,ent.Title
				,ent.IsAdministrator
				,ent.IsContributor
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsReplacementRequiredAfterTerm
				,ent.ReplacementClearedDate
				,ent.UserDefinedColumns
				,ent.PersonGroupMemberXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
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
				,ent.PersonGroupName
				,ent.PersonGroupLabel
				,ent.PersonGroupCategory
				,ent.Description
				,ent.ApplicationUserSID
				,ent.IsPreference
				,ent.IsDocumentLibraryEnabled
				,ent.QuerySID
				,ent.LastReviewUser
				,ent.LastReviewTime
				,ent.SmartGroupCount
				,ent.SmartGroupCountTime
				,ent.PersonGroupIsActive
				,ent.PersonGroupRowGUID
				,ent.IsActive
				,ent.IsPending
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.DisplayName
				,ent.EmailAddress
				,ent.PhoneNumber
				,ent.IsTermExpired
				,ent.TermLabel
				,ent.IsReplacementRequired
			from
				sf.vPersonGroupMember ent
			where
				ent.PersonGroupMemberSID = @PersonGroupMemberSID

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
