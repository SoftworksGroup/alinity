SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrg#Update]
	 @OrgSID                         int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ParentOrgSID                   int               = null -- table column values to update:
	,@OrgTypeSID                     int               = null
	,@OrgName                        nvarchar(150)     = null
	,@OrgLabel                       nvarchar(35)      = null
	,@StreetAddress1                 nvarchar(75)      = null
	,@StreetAddress2                 nvarchar(75)      = null
	,@StreetAddress3                 nvarchar(75)      = null
	,@CitySID                        int               = null
	,@PostalCode                     varchar(10)       = null
	,@RegionSID                      int               = null
	,@Phone                          varchar(25)       = null
	,@Fax                            varchar(25)       = null
	,@WebSite                        varchar(250)      = null
	,@EmailAddress                   varchar(150)      = null
	,@InsuranceOrgSID                int               = null
	,@InsurancePolicyNo              varchar(25)       = null
	,@InsuranceAmount                decimal(11,2)     = null
	,@IsEmployer                     bit               = null
	,@IsCredentialAuthority          bit               = null
	,@IsInsurer                      bit               = null
	,@IsInsuranceCertificateRequired bit               = null
	,@IsPublic                       nchar(10)         = null
	,@Comments                       nvarchar(max)     = null
	,@TagList                        xml               = null
	,@IsActive                       bit               = null
	,@IsAdminReviewRequired          bit               = null
	,@LastVerifiedTime               datetimeoffset(7) = null
	,@ChangeLog                      xml               = null
	,@UserDefinedColumns             xml               = null
	,@OrgXID                         varchar(150)      = null
	,@LegacyKey                      nvarchar(50)      = null
	,@UpdateUser                     nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                       timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                   tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                  bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                       xml               = null -- other values defining context for the update (if any)
	,@CityName                       nvarchar(30)      = null -- not a base table column
	,@StateProvinceSID               int               = null -- not a base table column
	,@CityIsDefault                  bit               = null -- not a base table column
	,@CityIsActive                   bit               = null -- not a base table column
	,@CityIsAdminReviewRequired      bit               = null -- not a base table column
	,@CityRowGUID                    uniqueidentifier  = null -- not a base table column
	,@OrgTypeName                    nvarchar(50)      = null -- not a base table column
	,@OrgTypeCode                    varchar(20)       = null -- not a base table column
	,@SectorCode                     varchar(5)        = null -- not a base table column
	,@OrgTypeCategory                nvarchar(65)      = null -- not a base table column
	,@OrgTypeIsDefault               bit               = null -- not a base table column
	,@OrgTypeIsActive                bit               = null -- not a base table column
	,@OrgTypeRowGUID                 uniqueidentifier  = null -- not a base table column
	,@RegionLabel                    nvarchar(35)      = null -- not a base table column
	,@RegionName                     nvarchar(50)      = null -- not a base table column
	,@RegionIsDefault                bit               = null -- not a base table column
	,@RegionIsActive                 bit               = null -- not a base table column
	,@RegionRowGUID                  uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                bit               = null -- not a base table column
	,@FullOrgLabel                   nvarchar(max)     = null -- not a base table column
	,@StateProvinceName              nvarchar(30)      = null -- not a base table column
	,@StateProvinceCode              nvarchar(5)       = null -- not a base table column
	,@CountrySID                     int               = null -- not a base table column
	,@CountryName                    nvarchar(50)      = null -- not a base table column
	,@CredentialCount                int               = null -- not a base table column
	,@QualifiedCredentialCount       int               = null -- not a base table column
	,@EmploymentCount                int               = null -- not a base table column
	,@NextReviewTime                 smalldatetime     = null -- not a base table column
	,@IsNextReviewDue                bit               = null -- not a base table column
	,@IsInsuranceEnabled             bit               = null -- not a base table column
	,@OrgNameEffectiveDate           date              = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pOrg#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.Org table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.Org table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vOrg entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pOrg procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fOrgCheck to test all rules.

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

		if @OrgSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@OrgSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @OrgName = ltrim(rtrim(@OrgName))
		set @OrgLabel = ltrim(rtrim(@OrgLabel))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @Phone = ltrim(rtrim(@Phone))
		set @Fax = ltrim(rtrim(@Fax))
		set @WebSite = ltrim(rtrim(@WebSite))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @InsurancePolicyNo = ltrim(rtrim(@InsurancePolicyNo))
		set @IsPublic = ltrim(rtrim(@IsPublic))
		set @Comments = ltrim(rtrim(@Comments))
		set @OrgXID = ltrim(rtrim(@OrgXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @CityName = ltrim(rtrim(@CityName))
		set @OrgTypeName = ltrim(rtrim(@OrgTypeName))
		set @OrgTypeCode = ltrim(rtrim(@OrgTypeCode))
		set @SectorCode = ltrim(rtrim(@SectorCode))
		set @OrgTypeCategory = ltrim(rtrim(@OrgTypeCategory))
		set @RegionLabel = ltrim(rtrim(@RegionLabel))
		set @RegionName = ltrim(rtrim(@RegionName))
		set @FullOrgLabel = ltrim(rtrim(@FullOrgLabel))
		set @StateProvinceName = ltrim(rtrim(@StateProvinceName))
		set @StateProvinceCode = ltrim(rtrim(@StateProvinceCode))
		set @CountryName = ltrim(rtrim(@CountryName))

		-- set zero length strings to null to avoid storing them in the record

		if len(@OrgName) = 0 set @OrgName = null
		if len(@OrgLabel) = 0 set @OrgLabel = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@Phone) = 0 set @Phone = null
		if len(@Fax) = 0 set @Fax = null
		if len(@WebSite) = 0 set @WebSite = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@InsurancePolicyNo) = 0 set @InsurancePolicyNo = null
		if len(@IsPublic) = 0 set @IsPublic = null
		if len(@Comments) = 0 set @Comments = null
		if len(@OrgXID) = 0 set @OrgXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@CityName) = 0 set @CityName = null
		if len(@OrgTypeName) = 0 set @OrgTypeName = null
		if len(@OrgTypeCode) = 0 set @OrgTypeCode = null
		if len(@SectorCode) = 0 set @SectorCode = null
		if len(@OrgTypeCategory) = 0 set @OrgTypeCategory = null
		if len(@RegionLabel) = 0 set @RegionLabel = null
		if len(@RegionName) = 0 set @RegionName = null
		if len(@FullOrgLabel) = 0 set @FullOrgLabel = null
		if len(@StateProvinceName) = 0 set @StateProvinceName = null
		if len(@StateProvinceCode) = 0 set @StateProvinceCode = null
		if len(@CountryName) = 0 set @CountryName = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ParentOrgSID                   = isnull(@ParentOrgSID,o.ParentOrgSID)
				,@OrgTypeSID                     = isnull(@OrgTypeSID,o.OrgTypeSID)
				,@OrgName                        = isnull(@OrgName,o.OrgName)
				,@OrgLabel                       = isnull(@OrgLabel,o.OrgLabel)
				,@StreetAddress1                 = isnull(@StreetAddress1,o.StreetAddress1)
				,@StreetAddress2                 = isnull(@StreetAddress2,o.StreetAddress2)
				,@StreetAddress3                 = isnull(@StreetAddress3,o.StreetAddress3)
				,@CitySID                        = isnull(@CitySID,o.CitySID)
				,@PostalCode                     = isnull(@PostalCode,o.PostalCode)
				,@RegionSID                      = isnull(@RegionSID,o.RegionSID)
				,@Phone                          = isnull(@Phone,o.Phone)
				,@Fax                            = isnull(@Fax,o.Fax)
				,@WebSite                        = isnull(@WebSite,o.WebSite)
				,@EmailAddress                   = isnull(@EmailAddress,o.EmailAddress)
				,@InsuranceOrgSID                = isnull(@InsuranceOrgSID,o.InsuranceOrgSID)
				,@InsurancePolicyNo              = isnull(@InsurancePolicyNo,o.InsurancePolicyNo)
				,@InsuranceAmount                = isnull(@InsuranceAmount,o.InsuranceAmount)
				,@IsEmployer                     = isnull(@IsEmployer,o.IsEmployer)
				,@IsCredentialAuthority          = isnull(@IsCredentialAuthority,o.IsCredentialAuthority)
				,@IsInsurer                      = isnull(@IsInsurer,o.IsInsurer)
				,@IsInsuranceCertificateRequired = isnull(@IsInsuranceCertificateRequired,o.IsInsuranceCertificateRequired)
				,@IsPublic                       = isnull(@IsPublic,o.IsPublic)
				,@Comments                       = isnull(@Comments,o.Comments)
				,@TagList                        = isnull(@TagList,o.TagList)
				,@IsActive                       = isnull(@IsActive,o.IsActive)
				,@IsAdminReviewRequired          = isnull(@IsAdminReviewRequired,o.IsAdminReviewRequired)
				,@LastVerifiedTime               = isnull(@LastVerifiedTime,o.LastVerifiedTime)
				,@ChangeLog                      = isnull(@ChangeLog,o.ChangeLog)
				,@UserDefinedColumns             = isnull(@UserDefinedColumns,o.UserDefinedColumns)
				,@OrgXID                         = isnull(@OrgXID,o.OrgXID)
				,@LegacyKey                      = isnull(@LegacyKey,o.LegacyKey)
				,@UpdateUser                     = isnull(@UpdateUser,o.UpdateUser)
				,@IsReselected                   = isnull(@IsReselected,o.IsReselected)
				,@IsNullApplied                  = isnull(@IsNullApplied,o.IsNullApplied)
				,@zContext                       = isnull(@zContext,o.zContext)
				,@CityName                       = isnull(@CityName,o.CityName)
				,@StateProvinceSID               = isnull(@StateProvinceSID,o.StateProvinceSID)
				,@CityIsDefault                  = isnull(@CityIsDefault,o.CityIsDefault)
				,@CityIsActive                   = isnull(@CityIsActive,o.CityIsActive)
				,@CityIsAdminReviewRequired      = isnull(@CityIsAdminReviewRequired,o.CityIsAdminReviewRequired)
				,@CityRowGUID                    = isnull(@CityRowGUID,o.CityRowGUID)
				,@OrgTypeName                    = isnull(@OrgTypeName,o.OrgTypeName)
				,@OrgTypeCode                    = isnull(@OrgTypeCode,o.OrgTypeCode)
				,@SectorCode                     = isnull(@SectorCode,o.SectorCode)
				,@OrgTypeCategory                = isnull(@OrgTypeCategory,o.OrgTypeCategory)
				,@OrgTypeIsDefault               = isnull(@OrgTypeIsDefault,o.OrgTypeIsDefault)
				,@OrgTypeIsActive                = isnull(@OrgTypeIsActive,o.OrgTypeIsActive)
				,@OrgTypeRowGUID                 = isnull(@OrgTypeRowGUID,o.OrgTypeRowGUID)
				,@RegionLabel                    = isnull(@RegionLabel,o.RegionLabel)
				,@RegionName                     = isnull(@RegionName,o.RegionName)
				,@RegionIsDefault                = isnull(@RegionIsDefault,o.RegionIsDefault)
				,@RegionIsActive                 = isnull(@RegionIsActive,o.RegionIsActive)
				,@RegionRowGUID                  = isnull(@RegionRowGUID,o.RegionRowGUID)
				,@IsDeleteEnabled                = isnull(@IsDeleteEnabled,o.IsDeleteEnabled)
				,@FullOrgLabel                   = isnull(@FullOrgLabel,o.FullOrgLabel)
				,@StateProvinceName              = isnull(@StateProvinceName,o.StateProvinceName)
				,@StateProvinceCode              = isnull(@StateProvinceCode,o.StateProvinceCode)
				,@CountrySID                     = isnull(@CountrySID,o.CountrySID)
				,@CountryName                    = isnull(@CountryName,o.CountryName)
				,@CredentialCount                = isnull(@CredentialCount,o.CredentialCount)
				,@QualifiedCredentialCount       = isnull(@QualifiedCredentialCount,o.QualifiedCredentialCount)
				,@EmploymentCount                = isnull(@EmploymentCount,o.EmploymentCount)
				,@NextReviewTime                 = isnull(@NextReviewTime,o.NextReviewTime)
				,@IsNextReviewDue                = isnull(@IsNextReviewDue,o.IsNextReviewDue)
				,@IsInsuranceEnabled             = isnull(@IsInsuranceEnabled,o.IsInsuranceEnabled)
				,@OrgNameEffectiveDate           = isnull(@OrgNameEffectiveDate,o.OrgNameEffectiveDate)
			from
				dbo.vOrg o
			where
				o.OrgSID = @OrgSID

		end
		
		set @Phone = sf.fFormatPhone(@Phone)																	-- format phone numbers to standard
		set @Fax   = sf.fFormatPhone(@Fax)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the new tags applied (if any)

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.CitySID from dbo.Org x where x.OrgSID = @OrgSID) <> @CitySID
		begin
			if (select x.IsActive from dbo.City x where x.CitySID = @CitySID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'city'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.InsuranceOrgSID from dbo.Org x where x.OrgSID = @OrgSID) <> @InsuranceOrgSID
		begin
			if (select x.IsActive from dbo.Org x where x.OrgSID = @InsuranceOrgSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'insurance org'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.OrgTypeSID from dbo.Org x where x.OrgSID = @OrgSID) <> @OrgTypeSID
		begin
			if (select x.IsActive from dbo.OrgType x where x.OrgTypeSID = @OrgTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'org type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ParentOrgSID from dbo.Org x where x.OrgSID = @OrgSID) <> @ParentOrgSID
		begin
			if (select x.IsActive from dbo.Org x where x.OrgSID = @ParentOrgSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'parent org'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.RegionSID from dbo.Org x where x.OrgSID = @OrgSID) <> @RegionSID
		begin
			if (select x.IsActive from dbo.Region x where x.RegionSID = @RegionSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'region'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Tim Edlund | Mar 2019
		-- If a name change is detected and the name being replaced is not already
		-- in the organization-other-names table for this organization, add it unless
		-- another name change has been captured previously for the same day; in
		-- which case update the previous name change.

		declare
			@oldOrgName			 nvarchar(35)
		 ,@orgOtherNameSID int;

		select @oldOrgName = o .OrgName from dbo .Org o where o.OrgSID = @OrgSID;

		if (@oldOrgName <> @OrgName)
		begin

			if not exists
			(
				select
					1
				from
					dbo.OrgOtherName oon
				where
					oon.OrgSID = @OrgSID and oon.OrgName = @oldOrgName	-- ensure the previous name is not already captured
			)
			begin

				select
					@orgOtherNameSID = oon.OrgOtherNameSID
				from
					dbo.OrgOtherName oon
				where
					oon.OrgSID = @OrgSID and cast(oon.UpdateTime as date) = cast(sysdatetime() as date);	-- check for previous name change on same day

				if @orgOtherNameSID is not null
				begin

					exec dbo.pOrgOtherName#Update
						@OrgOtherNameSID = @orgOtherNameSID
					 ,@OrgName = @oldOrgName; -- update existing name change

				end;
				else
				begin

					exec dbo.pOrgOtherName#Insert
						@OrgSID = @OrgSID
					 ,@OrgName = @oldOrgName; -- otherwise add the record

				end;
			end;
		end;

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
		-- If the Region Mapping table is populated, lookup the Region key
		-- to assign based on the postal code. If a match is not found,  the
		-- previous value remains assigned unless null.
		
		if @PostalCode is not null
		begin
		
			if exists (select 1 from dbo.RegionMapping)
			begin

				select top(1)
					@recordSID = rm.RegionSID				from
					dbo.RegionMapping rm
				where
					@PostalCode like rm.PostalCodeMask +'%'
				order by
					len(rm.PostalCodeMask) desc																			-- take the key of the longest (most granular) code that matches!

				if @recordSID is not null set @RegionSID = @recordSID

			end
			else if @RegionSID is null																					-- if the key was reset to NULL, set it to the default where defined			
			begin
				select @RegionSID = x.RegionSID from dbo.Region x where x.IsDefault = @ON
			end

		end

		-- Tim Edlund | Sep 2017
		-- If the bit recording the need for admin verification is being turned off,
		-- then update the verification time.  Similarly, if the verification time
		-- is changing, turn off the bit if ON.

		if @IsAdminReviewRequired = @OFF and (select o.IsAdminReviewRequired from dbo.Org o where o.OrgSID = @OrgSID) = @ON
		begin
			set @LastVerifiedTime = sysdatetimeoffset()
		end
		else if @IsAdminReviewRequired = @ON and (select o.LastVerifiedTime from dbo.Org o where o.OrgSID = @OrgSID) < @LastVerifiedTime
		begin
			set @IsAdminReviewRequired = @OFF
		end

		-- Tim Edlund | Sep 2017
		-- If the update is being done by a non-administrator, and the
		-- address was changed, turn on the bit indicating admin review
		-- is required

		if sf.fIsGrantedToUserName('ADMIN.BASE', @UpdateUser) = @OFF
		begin

			set @recordSID = null

			select
				@recordSID = checksum(o.StreetAddress1, o.StreetAddress2, o.StreetAddress3, o.CitySID, o.PostalCode)
			from
				dbo.Org o
			where
				o.OrgSID = @OrgSID;

			if checksum(@StreetAddress1, @StreetAddress2, @StreetAddress3, @CitySID, @PostalCode) <> @recordSID
			begin
				set @IsAdminReviewRequired = @ON;
			end;
		end;
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
				r.RoutineName = 'pOrg'
		)
		begin
		
			exec @errorNo = ext.pOrg
				 @Mode                           = 'update.pre'
				,@OrgSID                         = @OrgSID
				,@ParentOrgSID                   = @ParentOrgSID output
				,@OrgTypeSID                     = @OrgTypeSID output
				,@OrgName                        = @OrgName output
				,@OrgLabel                       = @OrgLabel output
				,@StreetAddress1                 = @StreetAddress1 output
				,@StreetAddress2                 = @StreetAddress2 output
				,@StreetAddress3                 = @StreetAddress3 output
				,@CitySID                        = @CitySID output
				,@PostalCode                     = @PostalCode output
				,@RegionSID                      = @RegionSID output
				,@Phone                          = @Phone output
				,@Fax                            = @Fax output
				,@WebSite                        = @WebSite output
				,@EmailAddress                   = @EmailAddress output
				,@InsuranceOrgSID                = @InsuranceOrgSID output
				,@InsurancePolicyNo              = @InsurancePolicyNo output
				,@InsuranceAmount                = @InsuranceAmount output
				,@IsEmployer                     = @IsEmployer output
				,@IsCredentialAuthority          = @IsCredentialAuthority output
				,@IsInsurer                      = @IsInsurer output
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired output
				,@IsPublic                       = @IsPublic output
				,@Comments                       = @Comments output
				,@TagList                        = @TagList output
				,@IsActive                       = @IsActive output
				,@IsAdminReviewRequired          = @IsAdminReviewRequired output
				,@LastVerifiedTime               = @LastVerifiedTime output
				,@ChangeLog                      = @ChangeLog output
				,@UserDefinedColumns             = @UserDefinedColumns output
				,@OrgXID                         = @OrgXID output
				,@LegacyKey                      = @LegacyKey output
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@CityName                       = @CityName
				,@StateProvinceSID               = @StateProvinceSID
				,@CityIsDefault                  = @CityIsDefault
				,@CityIsActive                   = @CityIsActive
				,@CityIsAdminReviewRequired      = @CityIsAdminReviewRequired
				,@CityRowGUID                    = @CityRowGUID
				,@OrgTypeName                    = @OrgTypeName
				,@OrgTypeCode                    = @OrgTypeCode
				,@SectorCode                     = @SectorCode
				,@OrgTypeCategory                = @OrgTypeCategory
				,@OrgTypeIsDefault               = @OrgTypeIsDefault
				,@OrgTypeIsActive                = @OrgTypeIsActive
				,@OrgTypeRowGUID                 = @OrgTypeRowGUID
				,@RegionLabel                    = @RegionLabel
				,@RegionName                     = @RegionName
				,@RegionIsDefault                = @RegionIsDefault
				,@RegionIsActive                 = @RegionIsActive
				,@RegionRowGUID                  = @RegionRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@FullOrgLabel                   = @FullOrgLabel
				,@StateProvinceName              = @StateProvinceName
				,@StateProvinceCode              = @StateProvinceCode
				,@CountrySID                     = @CountrySID
				,@CountryName                    = @CountryName
				,@CredentialCount                = @CredentialCount
				,@QualifiedCredentialCount       = @QualifiedCredentialCount
				,@EmploymentCount                = @EmploymentCount
				,@NextReviewTime                 = @NextReviewTime
				,@IsNextReviewDue                = @IsNextReviewDue
				,@IsInsuranceEnabled             = @IsInsuranceEnabled
				,@OrgNameEffectiveDate           = @OrgNameEffectiveDate
		
		end

		-- update the record

		update
			dbo.Org
		set
			 ParentOrgSID = @ParentOrgSID
			,OrgTypeSID = @OrgTypeSID
			,OrgName = @OrgName
			,OrgLabel = @OrgLabel
			,StreetAddress1 = @StreetAddress1
			,StreetAddress2 = @StreetAddress2
			,StreetAddress3 = @StreetAddress3
			,CitySID = @CitySID
			,PostalCode = @PostalCode
			,RegionSID = @RegionSID
			,Phone = @Phone
			,Fax = @Fax
			,WebSite = @WebSite
			,EmailAddress = @EmailAddress
			,InsuranceOrgSID = @InsuranceOrgSID
			,InsurancePolicyNo = @InsurancePolicyNo
			,InsuranceAmount = @InsuranceAmount
			,IsEmployer = @IsEmployer
			,IsCredentialAuthority = @IsCredentialAuthority
			,IsInsurer = @IsInsurer
			,IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
			,IsPublic = @IsPublic
			,Comments = @Comments
			,TagList = @TagList
			,IsActive = @IsActive
			,IsAdminReviewRequired = @IsAdminReviewRequired
			,LastVerifiedTime = @LastVerifiedTime
			,ChangeLog = @ChangeLog
			,UserDefinedColumns = @UserDefinedColumns
			,OrgXID = @OrgXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			OrgSID = @OrgSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.Org where OrgSID = @orgSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.Org'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.Org'
					,@Arg2        = @orgSID
				
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
				,@Arg2        = 'dbo.Org'
				,@Arg3        = @rowsAffected
				,@Arg4        = @orgSID
			
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
				r.RoutineName = 'pOrg'
		)
		begin
		
			exec @errorNo = ext.pOrg
				 @Mode                           = 'update.post'
				,@OrgSID                         = @OrgSID
				,@ParentOrgSID                   = @ParentOrgSID
				,@OrgTypeSID                     = @OrgTypeSID
				,@OrgName                        = @OrgName
				,@OrgLabel                       = @OrgLabel
				,@StreetAddress1                 = @StreetAddress1
				,@StreetAddress2                 = @StreetAddress2
				,@StreetAddress3                 = @StreetAddress3
				,@CitySID                        = @CitySID
				,@PostalCode                     = @PostalCode
				,@RegionSID                      = @RegionSID
				,@Phone                          = @Phone
				,@Fax                            = @Fax
				,@WebSite                        = @WebSite
				,@EmailAddress                   = @EmailAddress
				,@InsuranceOrgSID                = @InsuranceOrgSID
				,@InsurancePolicyNo              = @InsurancePolicyNo
				,@InsuranceAmount                = @InsuranceAmount
				,@IsEmployer                     = @IsEmployer
				,@IsCredentialAuthority          = @IsCredentialAuthority
				,@IsInsurer                      = @IsInsurer
				,@IsInsuranceCertificateRequired = @IsInsuranceCertificateRequired
				,@IsPublic                       = @IsPublic
				,@Comments                       = @Comments
				,@TagList                        = @TagList
				,@IsActive                       = @IsActive
				,@IsAdminReviewRequired          = @IsAdminReviewRequired
				,@LastVerifiedTime               = @LastVerifiedTime
				,@ChangeLog                      = @ChangeLog
				,@UserDefinedColumns             = @UserDefinedColumns
				,@OrgXID                         = @OrgXID
				,@LegacyKey                      = @LegacyKey
				,@UpdateUser                     = @UpdateUser
				,@RowStamp                       = @RowStamp
				,@IsReselected                   = @IsReselected
				,@IsNullApplied                  = @IsNullApplied
				,@zContext                       = @zContext
				,@CityName                       = @CityName
				,@StateProvinceSID               = @StateProvinceSID
				,@CityIsDefault                  = @CityIsDefault
				,@CityIsActive                   = @CityIsActive
				,@CityIsAdminReviewRequired      = @CityIsAdminReviewRequired
				,@CityRowGUID                    = @CityRowGUID
				,@OrgTypeName                    = @OrgTypeName
				,@OrgTypeCode                    = @OrgTypeCode
				,@SectorCode                     = @SectorCode
				,@OrgTypeCategory                = @OrgTypeCategory
				,@OrgTypeIsDefault               = @OrgTypeIsDefault
				,@OrgTypeIsActive                = @OrgTypeIsActive
				,@OrgTypeRowGUID                 = @OrgTypeRowGUID
				,@RegionLabel                    = @RegionLabel
				,@RegionName                     = @RegionName
				,@RegionIsDefault                = @RegionIsDefault
				,@RegionIsActive                 = @RegionIsActive
				,@RegionRowGUID                  = @RegionRowGUID
				,@IsDeleteEnabled                = @IsDeleteEnabled
				,@FullOrgLabel                   = @FullOrgLabel
				,@StateProvinceName              = @StateProvinceName
				,@StateProvinceCode              = @StateProvinceCode
				,@CountrySID                     = @CountrySID
				,@CountryName                    = @CountryName
				,@CredentialCount                = @CredentialCount
				,@QualifiedCredentialCount       = @QualifiedCredentialCount
				,@EmploymentCount                = @EmploymentCount
				,@NextReviewTime                 = @NextReviewTime
				,@IsNextReviewDue                = @IsNextReviewDue
				,@IsInsuranceEnabled             = @IsInsuranceEnabled
				,@OrgNameEffectiveDate           = @OrgNameEffectiveDate
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.OrgSID
			from
				dbo.vOrg ent
			where
				ent.OrgSID = @OrgSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.OrgSID
				,ent.ParentOrgSID
				,ent.OrgTypeSID
				,ent.OrgName
				,ent.OrgLabel
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CitySID
				,ent.PostalCode
				,ent.RegionSID
				,ent.Phone
				,ent.Fax
				,ent.WebSite
				,ent.EmailAddress
				,ent.InsuranceOrgSID
				,ent.InsurancePolicyNo
				,ent.InsuranceAmount
				,ent.IsEmployer
				,ent.IsCredentialAuthority
				,ent.IsInsurer
				,ent.IsInsuranceCertificateRequired
				,ent.IsPublic
				,ent.Comments
				,ent.TagList
				,ent.IsActive
				,ent.IsAdminReviewRequired
				,ent.LastVerifiedTime
				,ent.ChangeLog
				,ent.UserDefinedColumns
				,ent.OrgXID
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
				,ent.OrgTypeName
				,ent.OrgTypeCode
				,ent.SectorCode
				,ent.OrgTypeCategory
				,ent.OrgTypeIsDefault
				,ent.OrgTypeIsActive
				,ent.OrgTypeRowGUID
				,ent.RegionLabel
				,ent.RegionName
				,ent.RegionIsDefault
				,ent.RegionIsActive
				,ent.RegionRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.FullOrgLabel
				,ent.StateProvinceName
				,ent.StateProvinceCode
				,ent.CountrySID
				,ent.CountryName
				,ent.CredentialCount
				,ent.QualifiedCredentialCount
				,ent.EmploymentCount
				,ent.NextReviewTime
				,ent.IsNextReviewDue
				,ent.IsInsuranceEnabled
				,ent.OrgNameEffectiveDate
			from
				dbo.vOrg ent
			where
				ent.OrgSID = @OrgSID

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
