SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroupMember#Insert]
	 @PersonGroupMemberSID           int               = null output				-- identity value assigned to the new record
	,@PersonGroupSID                 int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@PersonSID                      int               = null								-- required! if not passed value must be set in custom logic prior to insert
	,@Title                          nvarchar(75)      = null								
	,@IsAdministrator                bit               = null								-- default: CONVERT(bit,(0))
	,@IsContributor                  bit               = null								-- default: CONVERT(bit,(1))
	,@EffectiveTime                  datetime          = null								-- default: sf.fNow()
	,@ExpiryTime                     datetime          = null								
	,@IsReplacementRequiredAfterTerm bit               = null								-- default: CONVERT(bit,(0))
	,@ReplacementClearedDate         date              = null								
	,@UserDefinedColumns             xml               = null								
	,@PersonGroupMemberXID           varchar(150)      = null								
	,@LegacyKey                      nvarchar(50)      = null								
	,@CreateUser                     nvarchar(75)      = null								-- default: suser_sname()
	,@IsReselected                   tinyint           = null								-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                       xml               = null								-- other values defining context for the insert (if any)
	,@GenderSID                      int               = null								-- not a base table column (default ignored)
	,@NamePrefixSID                  int               = null								-- not a base table column (default ignored)
	,@FirstName                      nvarchar(30)      = null								-- not a base table column (default ignored)
	,@CommonName                     nvarchar(30)      = null								-- not a base table column (default ignored)
	,@MiddleNames                    nvarchar(30)      = null								-- not a base table column (default ignored)
	,@LastName                       nvarchar(35)      = null								-- not a base table column (default ignored)
	,@BirthDate                      date              = null								-- not a base table column (default ignored)
	,@DeathDate                      date              = null								-- not a base table column (default ignored)
	,@HomePhone                      varchar(25)       = null								-- not a base table column (default ignored)
	,@MobilePhone                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTextMessagingEnabled         bit               = null								-- not a base table column (default ignored)
	,@ImportBatch                    nvarchar(100)     = null								-- not a base table column (default ignored)
	,@PersonRowGUID                  uniqueidentifier  = null								-- not a base table column (default ignored)
	,@PersonGroupName                nvarchar(65)      = null								-- not a base table column (default ignored)
	,@PersonGroupLabel               nvarchar(35)      = null								-- not a base table column (default ignored)
	,@PersonGroupCategory            nvarchar(65)      = null								-- not a base table column (default ignored)
	,@Description                    nvarchar(500)     = null								-- not a base table column (default ignored)
	,@ApplicationUserSID             int               = null								-- not a base table column (default ignored)
	,@IsPreference                   bit               = null								-- not a base table column (default ignored)
	,@IsDocumentLibraryEnabled       bit               = null								-- not a base table column (default ignored)
	,@QuerySID                       int               = null								-- not a base table column (default ignored)
	,@LastReviewUser                 nvarchar(75)      = null								-- not a base table column (default ignored)
	,@LastReviewTime                 datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@SmartGroupCount                int               = null								-- not a base table column (default ignored)
	,@SmartGroupCountTime            datetimeoffset(7) = null								-- not a base table column (default ignored)
	,@PersonGroupIsActive            bit               = null								-- not a base table column (default ignored)
	,@PersonGroupRowGUID             uniqueidentifier  = null								-- not a base table column (default ignored)
	,@IsActive                       bit               = null								-- not a base table column (default ignored)
	,@IsPending                      bit               = null								-- not a base table column (default ignored)
	,@IsDeleteEnabled                bit               = null								-- not a base table column (default ignored)
	,@DisplayName                    nvarchar(65)      = null								-- not a base table column (default ignored)
	,@EmailAddress                   varchar(150)      = null								-- not a base table column (default ignored)
	,@PhoneNumber                    varchar(25)       = null								-- not a base table column (default ignored)
	,@IsTermExpired                  bit               = null								-- not a base table column (default ignored)
	,@TermLabel                      nvarchar(4000)    = null								-- not a base table column (default ignored)
	,@IsReplacementRequired          bit               = null								-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroupMember#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the sf.PersonGroupMember table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the sf.PersonGroupMember table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonGroupMember entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonGroupMember procedure. The extended procedure is only called
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

	set @PersonGroupMemberSID = null																				-- initialize output parameter

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

		set @Title = ltrim(rtrim(@Title))
		set @PersonGroupMemberXID = ltrim(rtrim(@PersonGroupMemberXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsAdministrator = isnull(@IsAdministrator,CONVERT(bit,(0)))
		set @IsContributor = isnull(@IsContributor,CONVERT(bit,(1)))
		set @EffectiveTime = isnull(@EffectiveTime,sf.fNow())
		set @IsReplacementRequiredAfterTerm = isnull(@IsReplacementRequiredAfterTerm,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                   = isnull(@IsReselected                  ,(0))
		
		if @EffectiveTime is not null set @EffectiveTime = sf.fSetMissingTime(@EffectiveTime)						-- add time component to date where stripped by UI control

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>

		-- insert the record

		insert
			sf.PersonGroupMember
		(
			 PersonGroupSID
			,PersonSID
			,Title
			,IsAdministrator
			,IsContributor
			,EffectiveTime
			,ExpiryTime
			,IsReplacementRequiredAfterTerm
			,ReplacementClearedDate
			,UserDefinedColumns
			,PersonGroupMemberXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonGroupSID
			,@PersonSID
			,@Title
			,@IsAdministrator
			,@IsContributor
			,@EffectiveTime
			,@ExpiryTime
			,@IsReplacementRequiredAfterTerm
			,@ReplacementClearedDate
			,@UserDefinedColumns
			,@PersonGroupMemberXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected         = @@rowcount
			,@PersonGroupMemberSID = scope_identity()														-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'sf.PersonGroupMember'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonGroupMemberSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>

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
