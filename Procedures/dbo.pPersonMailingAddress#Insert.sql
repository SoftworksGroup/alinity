SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonMailingAddress#Insert]
	 @PersonMailingAddressSID   int               = null output							-- identity value assigned to the new record
	,@PersonSID                 int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@StreetAddress1            nvarchar(75)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@StreetAddress2            nvarchar(75)      = null										
	,@StreetAddress3            nvarchar(75)      = null										
	,@CitySID                   int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@PostalCode                varchar(10)       = null										
	,@RegionSID                 int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime             datetime          = null										-- required! if not passed value must be set in custom logic prior to insert
	,@IsAdminReviewRequired     bit               = null										-- default: CONVERT(bit,(0))
	,@LastVerifiedTime          datetimeoffset(7) = null										
	,@ChangeLog                 xml               = null										-- default: CONVERT(xml,'<Changes />')
	,@UserDefinedColumns        xml               = null										
	,@PersonMailingAddressXID   varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@CityName                  nvarchar(30)      = null										-- not a base table column (default ignored)
	,@StateProvinceSID          int               = null										-- not a base table column (default ignored)
	,@CityIsDefault             bit               = null										-- not a base table column (default ignored)
	,@CityIsActive              bit               = null										-- not a base table column (default ignored)
	,@CityIsAdminReviewRequired bit               = null										-- not a base table column (default ignored)
	,@CityRowGUID               uniqueidentifier  = null										-- not a base table column (default ignored)
	,@RegionLabel               nvarchar(35)      = null										-- not a base table column (default ignored)
	,@RegionName                nvarchar(50)      = null										-- not a base table column (default ignored)
	,@RegionIsDefault           bit               = null										-- not a base table column (default ignored)
	,@RegionIsActive            bit               = null										-- not a base table column (default ignored)
	,@RegionRowGUID             uniqueidentifier  = null										-- not a base table column (default ignored)
	,@GenderSID                 int               = null										-- not a base table column (default ignored)
	,@NamePrefixSID             int               = null										-- not a base table column (default ignored)
	,@FirstName                 nvarchar(30)      = null										-- not a base table column (default ignored)
	,@CommonName                nvarchar(30)      = null										-- not a base table column (default ignored)
	,@MiddleNames               nvarchar(30)      = null										-- not a base table column (default ignored)
	,@LastName                  nvarchar(35)      = null										-- not a base table column (default ignored)
	,@BirthDate                 date              = null										-- not a base table column (default ignored)
	,@DeathDate                 date              = null										-- not a base table column (default ignored)
	,@HomePhone                 varchar(25)       = null										-- not a base table column (default ignored)
	,@MobilePhone               varchar(25)       = null										-- not a base table column (default ignored)
	,@IsTextMessagingEnabled    bit               = null										-- not a base table column (default ignored)
	,@ImportBatch               nvarchar(100)     = null										-- not a base table column (default ignored)
	,@PersonRowGUID             uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
	,@HtmlAddress               nvarchar(512)     = null										-- not a base table column (default ignored)
	,@StateProvinceCode         nvarchar(5)       = null										-- not a base table column (default ignored)
	,@StateProvinceName         nvarchar(30)      = null										-- not a base table column (default ignored)
	,@ISOA3                     char(3)           = null										-- not a base table column (default ignored)
	,@CountryName               nvarchar(50)      = null										-- not a base table column (default ignored)
	,@IsCurrentAddress          bit               = null										-- not a base table column (default ignored)
	,@CountrySID                int               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonMailingAddress#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PersonMailingAddress table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PersonMailingAddress table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonMailingAddress entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonMailingAddress procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonMailingAddressCheck to test all rules.

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

	set @PersonMailingAddressSID = null																			-- initialize output parameter

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

		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @PersonMailingAddressXID = ltrim(rtrim(@PersonMailingAddressXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @CityName = ltrim(rtrim(@CityName))
		set @RegionLabel = ltrim(rtrim(@RegionLabel))
		set @RegionName = ltrim(rtrim(@RegionName))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @HtmlAddress = ltrim(rtrim(@HtmlAddress))
		set @StateProvinceCode = ltrim(rtrim(@StateProvinceCode))
		set @StateProvinceName = ltrim(rtrim(@StateProvinceName))
		set @ISOA3 = ltrim(rtrim(@ISOA3))
		set @CountryName = ltrim(rtrim(@CountryName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@PersonMailingAddressXID) = 0 set @PersonMailingAddressXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@CityName) = 0 set @CityName = null
		if len(@RegionLabel) = 0 set @RegionLabel = null
		if len(@RegionName) = 0 set @RegionName = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@HtmlAddress) = 0 set @HtmlAddress = null
		if len(@StateProvinceCode) = 0 set @StateProvinceCode = null
		if len(@StateProvinceName) = 0 set @StateProvinceName = null
		if len(@ISOA3) = 0 set @ISOA3 = null
		if len(@CountryName) = 0 set @CountryName = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsAdminReviewRequired = isnull(@IsAdminReviewRequired,CONVERT(bit,(0)))
		set @ChangeLog = isnull(@ChangeLog,CONVERT(xml,'<Changes />'))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected            = isnull(@IsReselected           ,(0))
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @CitySID    is null select @CitySID    = x.CitySID   from dbo.City   x where x.IsDefault = @ON
		if @RegionSID  is null select @RegionSID  = x.RegionSID from dbo.Region x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>

		-- Tim Edlund | Feb 2018
		-- Ensure the effective times for these records are set
		-- to the beginning of the day only. (Overwrites default
		-- code above.)

		set @EffectiveTime = cast((convert(varchar(8), isnull(@EffectiveTime, sf.fToday()), 112)) + ' 00:00:00.00' as datetime);

		-- Tim Edlund | Jul 2017
		-- Shuffle address lines up if a blank appears in an earlier line

		if @StreetAddress2 is not null and @StreetAddress1 is null
		begin
			set @StreetAddress1 = @StreetAddress2
			set @StreetAddress2 = null
		end

		if @StreetAddress3 is not null and @StreetAddress2 is null
		begin
			set @StreetAddress2 = @StreetAddress3
			set @StreetAddress3 = null
		end

		if @StreetAddress3 is not null and @StreetAddress1 is null
		begin
			set @StreetAddress1 = @StreetAddress3
			set @StreetAddress3 = null
		end

		-- Tim Edlund | Jan 2017
		-- If the (sf) Region Mapping table is populated, lookup the Region key
		-- to assign based on the postal code. If a match is not found, the
		-- default remains assigned.
		
		if @PostalCode is not null
		begin
		
			if exists (select 1 from dbo.RegionMapping)
			begin

				select top 1
					@recordSID = rm.RegionSID
				from
					dbo.RegionMapping rm
				where
					@PostalCode like rm.PostalCodeMask +'%'
				order by
					len(rm.PostalCodeMask) desc																			-- take the key of the longest (most granular) code that matches!

				if @recordSID is not null set @RegionSID = @recordSID

			end

		end

		if @RegionSID is null																									-- if there is no default region defined, advise end-user
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'Default Region'
			raiserror(@errorText, 17, 1)
		end

		-- Tim Edlund | Sep 2017
		-- If the insert is being done by a non-administrator, turn on the
		-- bit indicating admin review is required

		if sf.fIsGrantedToUserName('ADMIN.BASE',@CreateUser) = @OFF
		begin
			set @IsAdminReviewRequired = @ON
		end
		--! </PreInsert>
		
		exec sf.pEffectiveExpiry#Set																					-- ensure effective time has start of day time component or current time if today
		   @EffectiveTime = @EffectiveTime output
	
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
				r.RoutineName = 'pPersonMailingAddress'
		)
		begin
		
			exec @errorNo = ext.pPersonMailingAddress
				 @Mode                      = 'insert.pre'
				,@PersonSID                 = @PersonSID output
				,@StreetAddress1            = @StreetAddress1 output
				,@StreetAddress2            = @StreetAddress2 output
				,@StreetAddress3            = @StreetAddress3 output
				,@CitySID                   = @CitySID output
				,@PostalCode                = @PostalCode output
				,@RegionSID                 = @RegionSID output
				,@EffectiveTime             = @EffectiveTime output
				,@IsAdminReviewRequired     = @IsAdminReviewRequired output
				,@LastVerifiedTime          = @LastVerifiedTime output
				,@ChangeLog                 = @ChangeLog output
				,@UserDefinedColumns        = @UserDefinedColumns output
				,@PersonMailingAddressXID   = @PersonMailingAddressXID output
				,@LegacyKey                 = @LegacyKey output
				,@CreateUser                = @CreateUser
				,@IsReselected              = @IsReselected
				,@zContext                  = @zContext
				,@CityName                  = @CityName
				,@StateProvinceSID          = @StateProvinceSID
				,@CityIsDefault             = @CityIsDefault
				,@CityIsActive              = @CityIsActive
				,@CityIsAdminReviewRequired = @CityIsAdminReviewRequired
				,@CityRowGUID               = @CityRowGUID
				,@RegionLabel               = @RegionLabel
				,@RegionName                = @RegionName
				,@RegionIsDefault           = @RegionIsDefault
				,@RegionIsActive            = @RegionIsActive
				,@RegionRowGUID             = @RegionRowGUID
				,@GenderSID                 = @GenderSID
				,@NamePrefixSID             = @NamePrefixSID
				,@FirstName                 = @FirstName
				,@CommonName                = @CommonName
				,@MiddleNames               = @MiddleNames
				,@LastName                  = @LastName
				,@BirthDate                 = @BirthDate
				,@DeathDate                 = @DeathDate
				,@HomePhone                 = @HomePhone
				,@MobilePhone               = @MobilePhone
				,@IsTextMessagingEnabled    = @IsTextMessagingEnabled
				,@ImportBatch               = @ImportBatch
				,@PersonRowGUID             = @PersonRowGUID
				,@IsDeleteEnabled           = @IsDeleteEnabled
				,@HtmlAddress               = @HtmlAddress
				,@StateProvinceCode         = @StateProvinceCode
				,@StateProvinceName         = @StateProvinceName
				,@ISOA3                     = @ISOA3
				,@CountryName               = @CountryName
				,@IsCurrentAddress          = @IsCurrentAddress
				,@CountrySID                = @CountrySID
		
		end

		-- insert the record

		insert
			dbo.PersonMailingAddress
		(
			 PersonSID
			,StreetAddress1
			,StreetAddress2
			,StreetAddress3
			,CitySID
			,PostalCode
			,RegionSID
			,EffectiveTime
			,IsAdminReviewRequired
			,LastVerifiedTime
			,ChangeLog
			,UserDefinedColumns
			,PersonMailingAddressXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@StreetAddress1
			,@StreetAddress2
			,@StreetAddress3
			,@CitySID
			,@PostalCode
			,@RegionSID
			,@EffectiveTime
			,@IsAdminReviewRequired
			,@LastVerifiedTime
			,@ChangeLog
			,@UserDefinedColumns
			,@PersonMailingAddressXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected            = @@rowcount
			,@PersonMailingAddressSID = scope_identity()												-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PersonMailingAddress'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonMailingAddressSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
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
				r.RoutineName = 'pPersonMailingAddress'
		)
		begin
		
			exec @errorNo = ext.pPersonMailingAddress
				 @Mode                      = 'insert.post'
				,@PersonMailingAddressSID   = @PersonMailingAddressSID
				,@PersonSID                 = @PersonSID
				,@StreetAddress1            = @StreetAddress1
				,@StreetAddress2            = @StreetAddress2
				,@StreetAddress3            = @StreetAddress3
				,@CitySID                   = @CitySID
				,@PostalCode                = @PostalCode
				,@RegionSID                 = @RegionSID
				,@EffectiveTime             = @EffectiveTime
				,@IsAdminReviewRequired     = @IsAdminReviewRequired
				,@LastVerifiedTime          = @LastVerifiedTime
				,@ChangeLog                 = @ChangeLog
				,@UserDefinedColumns        = @UserDefinedColumns
				,@PersonMailingAddressXID   = @PersonMailingAddressXID
				,@LegacyKey                 = @LegacyKey
				,@CreateUser                = @CreateUser
				,@IsReselected              = @IsReselected
				,@zContext                  = @zContext
				,@CityName                  = @CityName
				,@StateProvinceSID          = @StateProvinceSID
				,@CityIsDefault             = @CityIsDefault
				,@CityIsActive              = @CityIsActive
				,@CityIsAdminReviewRequired = @CityIsAdminReviewRequired
				,@CityRowGUID               = @CityRowGUID
				,@RegionLabel               = @RegionLabel
				,@RegionName                = @RegionName
				,@RegionIsDefault           = @RegionIsDefault
				,@RegionIsActive            = @RegionIsActive
				,@RegionRowGUID             = @RegionRowGUID
				,@GenderSID                 = @GenderSID
				,@NamePrefixSID             = @NamePrefixSID
				,@FirstName                 = @FirstName
				,@CommonName                = @CommonName
				,@MiddleNames               = @MiddleNames
				,@LastName                  = @LastName
				,@BirthDate                 = @BirthDate
				,@DeathDate                 = @DeathDate
				,@HomePhone                 = @HomePhone
				,@MobilePhone               = @MobilePhone
				,@IsTextMessagingEnabled    = @IsTextMessagingEnabled
				,@ImportBatch               = @ImportBatch
				,@PersonRowGUID             = @PersonRowGUID
				,@IsDeleteEnabled           = @IsDeleteEnabled
				,@HtmlAddress               = @HtmlAddress
				,@StateProvinceCode         = @StateProvinceCode
				,@StateProvinceName         = @StateProvinceName
				,@ISOA3                     = @ISOA3
				,@CountryName               = @CountryName
				,@IsCurrentAddress          = @IsCurrentAddress
				,@CountrySID                = @CountrySID
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PersonMailingAddressSID
			from
				dbo.vPersonMailingAddress ent
			where
				ent.PersonMailingAddressSID = @PersonMailingAddressSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonMailingAddressSID
				,ent.PersonSID
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.EffectiveTime
				,ent.IsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.ChangeLog
				,ent.UserDefinedColumns
				,ent.PersonMailingAddressXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.CityName
				,ent.StateProvinceSID
				,ent.CityIsDefault
				,ent.CityIsActive
				,ent.CityIsAdminReviewRequired
				,ent.CityRowGUID
				,ent.RegionLabel
				,ent.RegionName
				,ent.RegionIsDefault
				,ent.RegionIsActive
				,ent.RegionRowGUID
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
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.HtmlAddress
				,ent.StateProvinceCode
				,ent.StateProvinceName
				,ent.ISOA3
				,ent.CountryName
				,ent.IsCurrentAddress
				,ent.CountrySID
			from
				dbo.vPersonMailingAddress ent
			where
				ent.PersonMailingAddressSID = @PersonMailingAddressSID

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
