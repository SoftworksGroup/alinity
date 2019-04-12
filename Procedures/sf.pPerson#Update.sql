SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPerson#Update]
	 @PersonSID              int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@GenderSID              int               = null -- table column values to update:
	,@NamePrefixSID          int               = null
	,@FirstName              nvarchar(30)      = null
	,@CommonName             nvarchar(30)      = null
	,@MiddleNames            nvarchar(30)      = null
	,@LastName               nvarchar(35)      = null
	,@BirthDate              date              = null
	,@DeathDate              date              = null
	,@HomePhone              varchar(25)       = null
	,@MobilePhone            varchar(25)       = null
	,@IsTextMessagingEnabled bit               = null
	,@SignatureImage         varbinary(max)    = null
	,@IdentityPhoto          varbinary(max)    = null
	,@ImportBatch            nvarchar(100)     = null
	,@UserDefinedColumns     xml               = null
	,@PersonXID              varchar(150)      = null
	,@LegacyKey              nvarchar(50)      = null
	,@UpdateUser             nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp               timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected           tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied          bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext               xml               = null -- other values defining context for the update (if any)
	,@GenderSCD              char(1)           = null -- not a base table column
	,@GenderLabel            nvarchar(35)      = null -- not a base table column
	,@GenderIsActive         bit               = null -- not a base table column
	,@GenderRowGUID          uniqueidentifier  = null -- not a base table column
	,@NamePrefixLabel        nvarchar(35)      = null -- not a base table column
	,@NamePrefixIsActive     bit               = null -- not a base table column
	,@NamePrefixRowGUID      uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled        bit               = null -- not a base table column
	,@FileAsName             nvarchar(65)      = null -- not a base table column
	,@FullName               nvarchar(65)      = null -- not a base table column
	,@DisplayName            nvarchar(65)      = null -- not a base table column
	,@AgeInYears             int               = null -- not a base table column
	,@PrimaryEmailAddressSID int               = null -- not a base table column
	,@PrimaryEmailAddress    varchar(150)      = null -- not a base table column
	,@Initials               nchar(2)          = null -- not a base table column
	,@IsEmailUsedForLogin    bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pPerson#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.Person table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.Person table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPerson entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPerson procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonCheck to test all rules.

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

		if @PersonSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @PersonXID = ltrim(rtrim(@PersonXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @GenderSCD = ltrim(rtrim(@GenderSCD))
		set @GenderLabel = ltrim(rtrim(@GenderLabel))
		set @NamePrefixLabel = ltrim(rtrim(@NamePrefixLabel))
		set @FileAsName = ltrim(rtrim(@FileAsName))
		set @FullName = ltrim(rtrim(@FullName))
		set @DisplayName = ltrim(rtrim(@DisplayName))
		set @PrimaryEmailAddress = ltrim(rtrim(@PrimaryEmailAddress))
		set @Initials = ltrim(rtrim(@Initials))

		-- set zero length strings to null to avoid storing them in the record

		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@PersonXID) = 0 set @PersonXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@GenderSCD) = 0 set @GenderSCD = null
		if len(@GenderLabel) = 0 set @GenderLabel = null
		if len(@NamePrefixLabel) = 0 set @NamePrefixLabel = null
		if len(@FileAsName) = 0 set @FileAsName = null
		if len(@FullName) = 0 set @FullName = null
		if len(@DisplayName) = 0 set @DisplayName = null
		if len(@PrimaryEmailAddress) = 0 set @PrimaryEmailAddress = null
		if len(@Initials) = 0 set @Initials = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @GenderSID              = isnull(@GenderSID,person.GenderSID)
				,@NamePrefixSID          = isnull(@NamePrefixSID,person.NamePrefixSID)
				,@FirstName              = isnull(@FirstName,person.FirstName)
				,@CommonName             = isnull(@CommonName,person.CommonName)
				,@MiddleNames            = isnull(@MiddleNames,person.MiddleNames)
				,@LastName               = isnull(@LastName,person.LastName)
				,@BirthDate              = isnull(@BirthDate,person.BirthDate)
				,@DeathDate              = isnull(@DeathDate,person.DeathDate)
				,@HomePhone              = isnull(@HomePhone,person.HomePhone)
				,@MobilePhone            = isnull(@MobilePhone,person.MobilePhone)
				,@IsTextMessagingEnabled = isnull(@IsTextMessagingEnabled,person.IsTextMessagingEnabled)
				,@SignatureImage         = isnull(@SignatureImage,person.SignatureImage)
				,@IdentityPhoto          = isnull(@IdentityPhoto,person.IdentityPhoto)
				,@ImportBatch            = isnull(@ImportBatch,person.ImportBatch)
				,@UserDefinedColumns     = isnull(@UserDefinedColumns,person.UserDefinedColumns)
				,@PersonXID              = isnull(@PersonXID,person.PersonXID)
				,@LegacyKey              = isnull(@LegacyKey,person.LegacyKey)
				,@UpdateUser             = isnull(@UpdateUser,person.UpdateUser)
				,@IsReselected           = isnull(@IsReselected,person.IsReselected)
				,@IsNullApplied          = isnull(@IsNullApplied,person.IsNullApplied)
				,@zContext               = isnull(@zContext,person.zContext)
				,@GenderSCD              = isnull(@GenderSCD,person.GenderSCD)
				,@GenderLabel            = isnull(@GenderLabel,person.GenderLabel)
				,@GenderIsActive         = isnull(@GenderIsActive,person.GenderIsActive)
				,@GenderRowGUID          = isnull(@GenderRowGUID,person.GenderRowGUID)
				,@NamePrefixLabel        = isnull(@NamePrefixLabel,person.NamePrefixLabel)
				,@NamePrefixIsActive     = isnull(@NamePrefixIsActive,person.NamePrefixIsActive)
				,@NamePrefixRowGUID      = isnull(@NamePrefixRowGUID,person.NamePrefixRowGUID)
				,@IsDeleteEnabled        = isnull(@IsDeleteEnabled,person.IsDeleteEnabled)
				,@FileAsName             = isnull(@FileAsName,person.FileAsName)
				,@FullName               = isnull(@FullName,person.FullName)
				,@DisplayName            = isnull(@DisplayName,person.DisplayName)
				,@AgeInYears             = isnull(@AgeInYears,person.AgeInYears)
				,@PrimaryEmailAddressSID = isnull(@PrimaryEmailAddressSID,person.PrimaryEmailAddressSID)
				,@PrimaryEmailAddress    = isnull(@PrimaryEmailAddress,person.PrimaryEmailAddress)
				,@Initials               = isnull(@Initials,person.Initials)
				,@IsEmailUsedForLogin    = isnull(@IsEmailUsedForLogin,person.IsEmailUsedForLogin)
			from
				sf.vPerson person
			where
				person.PersonSID = @PersonSID

		end
		
		set @HomePhone   = sf.fFormatPhone(@HomePhone)												-- format phone numbers to standard
		set @MobilePhone = sf.fFormatPhone(@MobilePhone)
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @GenderSCD is not null and @GenderSID = (select x.GenderSID from sf.Person x where x.PersonSID = @PersonSID)
		begin
		
			select
				@GenderSID = x.GenderSID
			from
				sf.Gender x
			where
				x.GenderSCD = @GenderSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.GenderSID from sf.Person x where x.PersonSID = @PersonSID) <> @GenderSID
		begin
			if (select x.IsActive from sf.Gender x where x.GenderSID = @GenderSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'gender'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.NamePrefixSID from sf.Person x where x.PersonSID = @PersonSID) <> @NamePrefixSID
		begin
			if (select x.IsActive from sf.NamePrefix x where x.NamePrefixSID = @NamePrefixSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'name prefix'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Mar 2015
		-- Support overwrite of previously filled values with NULL		
		-- when special token passed (even where @IsNullApplied is off)

		if @MiddleNames = '[NULL]'									set @MiddleNames	= null
		if @BirthDate		= cast('18000101' as date)	set @BirthDate		= null
		if @HomePhone		= '[NULL]'									set @HomePhone		= null
		if @MobilePhone = '[NULL]'									set @MobilePhone	= null
		if @CommonName	= '[NULL]'									set @CommonName		= null

		-- Tim Edlund | Oct 2017
		-- Where names are passed in all uppercase or all lower case, convert
		-- them to mixed case

		if @LastName = upper(@LastName) collate Latin1_General_CS_AS or @LastName = lower(@LastName) collate Latin1_General_CS_AS
		begin
			set @LastName = cast(sf.fProperCase(@LastName) as nvarchar(35))
		end

		if @FirstName = upper(@FirstName) collate Latin1_General_CS_AS or @FirstName = lower(@FirstName) collate Latin1_General_CS_AS
		begin
			set @FirstName = cast(sf.fProperCase(@FirstName) as nvarchar(30))
		end

		if @MiddleNames = upper(@MiddleNames) collate Latin1_General_CS_AS or @MiddleNames = lower(@MiddleNames) collate Latin1_General_CS_AS
		begin
			set @MiddleNames = cast(sf.fProperCase(@MiddleNames) as nvarchar(30))
		end

		-- Tim Edlund | Oct 2016
		-- If a name change is detected and the name being replaced is not already
		-- in the person other-names table for this person, add it provided:
		--    1) the record was not previously edited the same day and
		--    2) the new name value is phonetically different than the old one (soundex)
		-- These 2 rules attempt to avoid capturing corrections of typos made on name
		-- entry into the person-other-names tables.

		declare
			 @oldFirstName     nvarchar(30)
			,@oldCommonName    nvarchar(30)
			,@oldMiddleNames   nvarchar(30)
			,@oldLastName      nvarchar(35)
			
		if @FirstName is not null and @LastName is not null
		begin

			select
				 @oldFirstName			= p.FirstName
				,@oldCommonName			= p.CommonName
				,@oldMiddleNames		= p.MiddleNames
				,@oldLastName				= p.LastName
			from
				sf.Person p
			where
				p.PersonSID = @PersonSID
			and
				cast(p.UpdateTime as date) <> cast(sysdatetime() as date)

			if (@oldFirstName <> @FirstName and soundex(@oldFirstName) <> soundex(@FirstName))
			or
			(@oldCommonName is not null and @CommonName is not null and @oldCommonName <> @CommonName and soundex(@oldCommonName) <> soundex(@CommonName))
			or
			(@oldMiddleNames is not null and @MiddleNames is not null and @oldMiddleNames <> @MiddleNames and soundex(@oldMiddleNames) <> soundex(@MiddleNames))
			or
			(@oldLastName <> @LastName and soundex(@oldLastName) <> soundex(@LastName))
			begin

				-- a change is detected, see if the previous name is
				-- already stored to avoid duplicates

				if not exists
				(
					select
						1
					from
						sf.PersonOtherName pon
					where
						pon.PersonSID									= @PersonSID
					and
						pon.FirstName									= @oldFirstName
					and
						isnull(pon.CommonName,N'x')		= isnull(@oldCommonName, N'x')
					and
						isnull(pon.MiddleNames,N'x')	= isnull(@oldMiddleNames, N'x')
					and
						pon.LastName									= @oldLastName
				)
				begin

					exec sf.pPersonOtherName#Insert
						 @PersonSID		= @PersonSID
						,@FirstName		= @oldFirstName
						,@CommonName	= @oldCommonName
						,@MiddleNames = @oldMiddleNames
						,@LastName		= @oldLastName

				end
			end

			-- Tim Edlund | Oct 2016
			-- When the procedure detects a change to the name, date of birth or gender
			-- a note is recorded in the audit log. The latest change information is
			-- placed at the top of the column value.

			-- TODO: May 2016 - logic for DOB and gender needs to go below the if block!
		end		

		--! </PreUpdate>

		-- update the record

		update
			sf.Person
		set
			 GenderSID = @GenderSID
			,NamePrefixSID = @NamePrefixSID
			,FirstName = @FirstName
			,CommonName = @CommonName
			,MiddleNames = @MiddleNames
			,LastName = @LastName
			,BirthDate = @BirthDate
			,DeathDate = @DeathDate
			,HomePhone = @HomePhone
			,MobilePhone = @MobilePhone
			,IsTextMessagingEnabled = @IsTextMessagingEnabled
			,SignatureImage = @SignatureImage
			,IdentityPhoto = @IdentityPhoto
			,ImportBatch = @ImportBatch
			,UserDefinedColumns = @UserDefinedColumns
			,PersonXID = @PersonXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonSID = @PersonSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.Person where PersonSID = @personSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.Person'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.Person'
					,@Arg2        = @personSID
				
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
				,@Arg2        = 'sf.Person'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		-- Tim Edlund | Dec 2012
		-- Handle insert, update and delete of primary email address for the person record.
		-- Logic branches on delete/update based on existence of PK value.  Call API procedures and
		-- suppress re-selection of the row from the child procedure.

		if @PrimaryEmailAddressSID is not null and @PrimaryEmailAddress is null													-- zero lengths string already converted to nulls			
		begin																																														-- at top of procedure

			exec sf.pPersonEmailAddress#Delete																	-- user has blanked out field in UI - delete it
				@PersonEmailAddressSID = @PrimaryEmailAddressSID

		end
		else if @PrimaryEmailAddressSID is not null														-- existing record - update it
		begin

			exec sf.pPersonEmailAddress#Update
				 @PersonEmailAddressSID = @PrimaryEmailAddressSID
				,@EmailAddress					= @PrimaryEmailAddress
				,@IsPrimary							= 1																				-- always the primary from this UI
				,@IsReselected					= 0																				-- don't return dataset										

		end
		else if @PrimaryEmailAddress is not null															-- new record required
		begin

			exec sf.pPersonEmailAddress#Insert
				 @PersonSID							= @PersonSID
				,@EmailAddress					= @PrimaryEmailAddress
				,@IsPrimary							= 1
				,@IsReselected					= 0				

		end
		--! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PersonSID
			from
				sf.vPerson ent
			where
				ent.PersonSID = @PersonSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonSID
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
				,ent.SignatureImage
				,ent.IdentityPhoto
				,ent.ImportBatch
				,ent.UserDefinedColumns
				,ent.PersonXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.GenderSCD
				,ent.GenderLabel
				,ent.GenderIsActive
				,ent.GenderRowGUID
				,ent.NamePrefixLabel
				,ent.NamePrefixIsActive
				,ent.NamePrefixRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.FileAsName
				,ent.FullName
				,ent.DisplayName
				,ent.AgeInYears
				,ent.PrimaryEmailAddressSID
				,ent.PrimaryEmailAddress
				,ent.Initials
				,ent.IsEmailUsedForLogin
			from
				sf.vPerson ent
			where
				ent.PersonSID = @PersonSID

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