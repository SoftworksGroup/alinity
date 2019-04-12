SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantProfile#Update]
	 @RegistrantProfileSID            int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@ImportFileSID                   int               = null -- table column values to update:
	,@ProcessingStatusSID             int               = null
	,@LastName                        nvarchar(35)      = null
	,@FirstName                       nvarchar(30)      = null
	,@CommonName                      nvarchar(30)      = null
	,@MiddleNames                     nvarchar(30)      = null
	,@EmailAddress                    varchar(150)      = null
	,@HomePhone                       varchar(25)       = null
	,@MobilePhone                     varchar(25)       = null
	,@IsTextMessagingEnabled          bit               = null
	,@GenderLabel                     nvarchar(35)      = null
	,@NamePrefixLabel                 nvarchar(35)      = null
	,@BirthDate                       date              = null
	,@DeathDate                       date              = null
	,@UserName                        nvarchar(75)      = null
	,@SubDomain                       varchar(63)       = null
	,@Password                        nvarchar(50)      = null
	,@StreetAddress1                  nvarchar(75)      = null
	,@StreetAddress2                  nvarchar(75)      = null
	,@StreetAddress3                  nvarchar(75)      = null
	,@CityName                        nvarchar(30)      = null
	,@StateProvinceName               nvarchar(30)      = null
	,@PostalCode                      varchar(10)       = null
	,@CountryName                     nvarchar(50)      = null
	,@RegionLabel                     nvarchar(35)      = null
	,@RegistrantNo                    varchar(50)       = null
	,@PersonGroupLabel1               nvarchar(35)      = null
	,@PersonGroupTitle1               nvarchar(75)      = null
	,@PersonGroupIsAdministrator1     bit               = null
	,@PersonGroupEffectiveDate1       date              = null
	,@PersonGroupExpiryDate1          date              = null
	,@PersonGroupLabel2               nvarchar(35)      = null
	,@PersonGroupTitle2               nvarchar(75)      = null
	,@PersonGroupIsAdministrator2     bit               = null
	,@PersonGroupEffectiveDate2       date              = null
	,@PersonGroupExpiryDate2          date              = null
	,@PersonGroupLabel3               nvarchar(35)      = null
	,@PersonGroupTitle3               nvarchar(75)      = null
	,@PersonGroupIsAdministrator3     bit               = null
	,@PersonGroupEffectiveDate3       date              = null
	,@PersonGroupExpiryDate3          date              = null
	,@PersonGroupLabel4               nvarchar(35)      = null
	,@PersonGroupTitle4               nvarchar(75)      = null
	,@PersonGroupIsAdministrator4     bit               = null
	,@PersonGroupEffectiveDate4       date              = null
	,@PersonGroupExpiryDate4          date              = null
	,@PersonGroupLabel5               nvarchar(35)      = null
	,@PersonGroupTitle5               nvarchar(75)      = null
	,@PersonGroupIsAdministrator5     bit               = null
	,@PersonGroupEffectiveDate5       date              = null
	,@PersonGroupExpiryDate5          date              = null
	,@PracticeRegisterLabel           nvarchar(35)      = null
	,@PracticeRegisterSectionLabel    nvarchar(35)      = null
	,@RegistrationEffectiveDate       date              = null
	,@QualifyingCredentialLabel       nvarchar(35)      = null
	,@QualifyingCredentialOrgLabel    nvarchar(35)      = null
	,@QualifyingProgramName           nvarchar(65)      = null
	,@QualifyingProgramStartDate      date              = null
	,@QualifyingProgramCompletionDate date              = null
	,@QualifyingFieldOfStudyName      nvarchar(50)      = null
	,@CredentialLabel1                nvarchar(35)      = null
	,@CredentialOrgLabel1             nvarchar(35)      = null
	,@CredentialProgramName1          nvarchar(65)      = null
	,@CredentialFieldOfStudyName1     nvarchar(50)      = null
	,@CredentialEffectiveDate1        date              = null
	,@CredentialExpiryDate1           date              = null
	,@CredentialLabel2                nvarchar(35)      = null
	,@CredentialOrgLabel2             nvarchar(35)      = null
	,@CredentialProgramName2          nvarchar(65)      = null
	,@CredentialFieldOfStudyName2     nvarchar(50)      = null
	,@CredentialEffectiveDate2        date              = null
	,@CredentialExpiryDate2           date              = null
	,@CredentialLabel3                nvarchar(35)      = null
	,@CredentialOrgLabel3             nvarchar(35)      = null
	,@CredentialProgramName3          nvarchar(65)      = null
	,@CredentialFieldOfStudyName3     nvarchar(50)      = null
	,@CredentialEffectiveDate3        date              = null
	,@CredentialExpiryDate3           date              = null
	,@CredentialLabel4                nvarchar(35)      = null
	,@CredentialOrgLabel4             nvarchar(35)      = null
	,@CredentialProgramName4          nvarchar(65)      = null
	,@CredentialFieldOfStudyName4     nvarchar(50)      = null
	,@CredentialEffectiveDate4        date              = null
	,@CredentialExpiryDate4           date              = null
	,@CredentialLabel5                nvarchar(35)      = null
	,@CredentialOrgLabel5             nvarchar(35)      = null
	,@CredentialProgramName5          nvarchar(65)      = null
	,@CredentialFieldOfStudyName5     nvarchar(50)      = null
	,@CredentialEffectiveDate5        date              = null
	,@CredentialExpiryDate5           date              = null
	,@CredentialLabel6                nvarchar(35)      = null
	,@CredentialOrgLabel6             nvarchar(35)      = null
	,@CredentialProgramName6          nvarchar(65)      = null
	,@CredentialFieldOfStudyName6     nvarchar(50)      = null
	,@CredentialEffectiveDate6        date              = null
	,@CredentialExpiryDate6           date              = null
	,@CredentialLabel7                nvarchar(35)      = null
	,@CredentialOrgLabel7             nvarchar(35)      = null
	,@CredentialProgramName7          nvarchar(65)      = null
	,@CredentialFieldOfStudyName7     nvarchar(50)      = null
	,@CredentialEffectiveDate7        date              = null
	,@CredentialExpiryDate7           date              = null
	,@CredentialLabel8                nvarchar(35)      = null
	,@CredentialOrgLabel8             nvarchar(35)      = null
	,@CredentialProgramName8          nvarchar(65)      = null
	,@CredentialFieldOfStudyName8     nvarchar(50)      = null
	,@CredentialEffectiveDate8        date              = null
	,@CredentialExpiryDate8           date              = null
	,@CredentialLabel9                nvarchar(35)      = null
	,@CredentialOrgLabel9             nvarchar(35)      = null
	,@CredentialProgramName9          nvarchar(65)      = null
	,@CredentialFieldOfStudyName9     nvarchar(50)      = null
	,@CredentialEffectiveDate9        date              = null
	,@CredentialExpiryDate9           date              = null
	,@PersonSID                       int               = null
	,@PersonEmailAddressSID           int               = null
	,@ApplicationUserSID              int               = null
	,@PersonMailingAddressSID         int               = null
	,@RegionSID                       int               = null
	,@NamePrefixSID                   int               = null
	,@GenderSID                       int               = null
	,@CitySID                         int               = null
	,@StateProvinceSID                int               = null
	,@CountrySID                      int               = null
	,@RegistrantSID                   int               = null
	,@ProcessingComments              nvarchar(max)     = null
	,@UserDefinedColumns              xml               = null
	,@RegistrantProfileXID            varchar(150)      = null
	,@LegacyKey                       nvarchar(50)      = null
	,@UpdateUser                      nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                        timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                    tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                   bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                        xml               = null -- other values defining context for the update (if any)
	,@FileFormatSID                   int               = null -- not a base table column
	,@ApplicationEntitySID            int               = null -- not a base table column
	,@FileName                        nvarchar(100)     = null -- not a base table column
	,@LoadStartTime                   datetimeoffset(7) = null -- not a base table column
	,@LoadEndTime                     datetimeoffset(7) = null -- not a base table column
	,@IsFailed                        bit               = null -- not a base table column
	,@MessageText                     nvarchar(4000)    = null -- not a base table column
	,@ImportFileRowGUID               uniqueidentifier  = null -- not a base table column
	,@ProcessingStatusSCD             varchar(10)       = null -- not a base table column
	,@ProcessingStatusLabel           nvarchar(35)      = null -- not a base table column
	,@IsClosedStatus                  bit               = null -- not a base table column
	,@ProcessingStatusIsActive        bit               = null -- not a base table column
	,@ProcessingStatusIsDefault       bit               = null -- not a base table column
	,@ProcessingStatusRowGUID         uniqueidentifier  = null -- not a base table column
	,@PersonEmailAddressPersonSID     int               = null -- not a base table column
	,@PersonEmailAddressEmailAddress  varchar(150)      = null -- not a base table column
	,@IsPrimary                       bit               = null -- not a base table column
	,@PersonEmailAddressIsActive      bit               = null -- not a base table column
	,@PersonEmailAddressRowGUID       uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                 bit               = null -- not a base table column
	,@RegistrantLabel                 nvarchar(75)      = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantProfile#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the stg.RegistrantProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the stg.RegistrantProfile table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrantProfile entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantProfile procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrantProfileCheck to test all rules.

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

		if @RegistrantProfileSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrantProfileSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @LastName = ltrim(rtrim(@LastName))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @EmailAddress = ltrim(rtrim(@EmailAddress))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @GenderLabel = ltrim(rtrim(@GenderLabel))
		set @NamePrefixLabel = ltrim(rtrim(@NamePrefixLabel))
		set @UserName = ltrim(rtrim(@UserName))
		set @SubDomain = ltrim(rtrim(@SubDomain))
		set @Password = ltrim(rtrim(@Password))
		set @StreetAddress1 = ltrim(rtrim(@StreetAddress1))
		set @StreetAddress2 = ltrim(rtrim(@StreetAddress2))
		set @StreetAddress3 = ltrim(rtrim(@StreetAddress3))
		set @CityName = ltrim(rtrim(@CityName))
		set @StateProvinceName = ltrim(rtrim(@StateProvinceName))
		set @PostalCode = ltrim(rtrim(@PostalCode))
		set @CountryName = ltrim(rtrim(@CountryName))
		set @RegionLabel = ltrim(rtrim(@RegionLabel))
		set @RegistrantNo = ltrim(rtrim(@RegistrantNo))
		set @PersonGroupLabel1 = ltrim(rtrim(@PersonGroupLabel1))
		set @PersonGroupTitle1 = ltrim(rtrim(@PersonGroupTitle1))
		set @PersonGroupLabel2 = ltrim(rtrim(@PersonGroupLabel2))
		set @PersonGroupTitle2 = ltrim(rtrim(@PersonGroupTitle2))
		set @PersonGroupLabel3 = ltrim(rtrim(@PersonGroupLabel3))
		set @PersonGroupTitle3 = ltrim(rtrim(@PersonGroupTitle3))
		set @PersonGroupLabel4 = ltrim(rtrim(@PersonGroupLabel4))
		set @PersonGroupTitle4 = ltrim(rtrim(@PersonGroupTitle4))
		set @PersonGroupLabel5 = ltrim(rtrim(@PersonGroupLabel5))
		set @PersonGroupTitle5 = ltrim(rtrim(@PersonGroupTitle5))
		set @PracticeRegisterLabel = ltrim(rtrim(@PracticeRegisterLabel))
		set @PracticeRegisterSectionLabel = ltrim(rtrim(@PracticeRegisterSectionLabel))
		set @QualifyingCredentialLabel = ltrim(rtrim(@QualifyingCredentialLabel))
		set @QualifyingCredentialOrgLabel = ltrim(rtrim(@QualifyingCredentialOrgLabel))
		set @QualifyingProgramName = ltrim(rtrim(@QualifyingProgramName))
		set @QualifyingFieldOfStudyName = ltrim(rtrim(@QualifyingFieldOfStudyName))
		set @CredentialLabel1 = ltrim(rtrim(@CredentialLabel1))
		set @CredentialOrgLabel1 = ltrim(rtrim(@CredentialOrgLabel1))
		set @CredentialProgramName1 = ltrim(rtrim(@CredentialProgramName1))
		set @CredentialFieldOfStudyName1 = ltrim(rtrim(@CredentialFieldOfStudyName1))
		set @CredentialLabel2 = ltrim(rtrim(@CredentialLabel2))
		set @CredentialOrgLabel2 = ltrim(rtrim(@CredentialOrgLabel2))
		set @CredentialProgramName2 = ltrim(rtrim(@CredentialProgramName2))
		set @CredentialFieldOfStudyName2 = ltrim(rtrim(@CredentialFieldOfStudyName2))
		set @CredentialLabel3 = ltrim(rtrim(@CredentialLabel3))
		set @CredentialOrgLabel3 = ltrim(rtrim(@CredentialOrgLabel3))
		set @CredentialProgramName3 = ltrim(rtrim(@CredentialProgramName3))
		set @CredentialFieldOfStudyName3 = ltrim(rtrim(@CredentialFieldOfStudyName3))
		set @CredentialLabel4 = ltrim(rtrim(@CredentialLabel4))
		set @CredentialOrgLabel4 = ltrim(rtrim(@CredentialOrgLabel4))
		set @CredentialProgramName4 = ltrim(rtrim(@CredentialProgramName4))
		set @CredentialFieldOfStudyName4 = ltrim(rtrim(@CredentialFieldOfStudyName4))
		set @CredentialLabel5 = ltrim(rtrim(@CredentialLabel5))
		set @CredentialOrgLabel5 = ltrim(rtrim(@CredentialOrgLabel5))
		set @CredentialProgramName5 = ltrim(rtrim(@CredentialProgramName5))
		set @CredentialFieldOfStudyName5 = ltrim(rtrim(@CredentialFieldOfStudyName5))
		set @CredentialLabel6 = ltrim(rtrim(@CredentialLabel6))
		set @CredentialOrgLabel6 = ltrim(rtrim(@CredentialOrgLabel6))
		set @CredentialProgramName6 = ltrim(rtrim(@CredentialProgramName6))
		set @CredentialFieldOfStudyName6 = ltrim(rtrim(@CredentialFieldOfStudyName6))
		set @CredentialLabel7 = ltrim(rtrim(@CredentialLabel7))
		set @CredentialOrgLabel7 = ltrim(rtrim(@CredentialOrgLabel7))
		set @CredentialProgramName7 = ltrim(rtrim(@CredentialProgramName7))
		set @CredentialFieldOfStudyName7 = ltrim(rtrim(@CredentialFieldOfStudyName7))
		set @CredentialLabel8 = ltrim(rtrim(@CredentialLabel8))
		set @CredentialOrgLabel8 = ltrim(rtrim(@CredentialOrgLabel8))
		set @CredentialProgramName8 = ltrim(rtrim(@CredentialProgramName8))
		set @CredentialFieldOfStudyName8 = ltrim(rtrim(@CredentialFieldOfStudyName8))
		set @CredentialLabel9 = ltrim(rtrim(@CredentialLabel9))
		set @CredentialOrgLabel9 = ltrim(rtrim(@CredentialOrgLabel9))
		set @CredentialProgramName9 = ltrim(rtrim(@CredentialProgramName9))
		set @CredentialFieldOfStudyName9 = ltrim(rtrim(@CredentialFieldOfStudyName9))
		set @ProcessingComments = ltrim(rtrim(@ProcessingComments))
		set @RegistrantProfileXID = ltrim(rtrim(@RegistrantProfileXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @FileName = ltrim(rtrim(@FileName))
		set @MessageText = ltrim(rtrim(@MessageText))
		set @ProcessingStatusSCD = ltrim(rtrim(@ProcessingStatusSCD))
		set @ProcessingStatusLabel = ltrim(rtrim(@ProcessingStatusLabel))
		set @PersonEmailAddressEmailAddress = ltrim(rtrim(@PersonEmailAddressEmailAddress))
		set @RegistrantLabel = ltrim(rtrim(@RegistrantLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@LastName) = 0 set @LastName = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@EmailAddress) = 0 set @EmailAddress = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@GenderLabel) = 0 set @GenderLabel = null
		if len(@NamePrefixLabel) = 0 set @NamePrefixLabel = null
		if len(@UserName) = 0 set @UserName = null
		if len(@SubDomain) = 0 set @SubDomain = null
		if len(@Password) = 0 set @Password = null
		if len(@StreetAddress1) = 0 set @StreetAddress1 = null
		if len(@StreetAddress2) = 0 set @StreetAddress2 = null
		if len(@StreetAddress3) = 0 set @StreetAddress3 = null
		if len(@CityName) = 0 set @CityName = null
		if len(@StateProvinceName) = 0 set @StateProvinceName = null
		if len(@PostalCode) = 0 set @PostalCode = null
		if len(@CountryName) = 0 set @CountryName = null
		if len(@RegionLabel) = 0 set @RegionLabel = null
		if len(@RegistrantNo) = 0 set @RegistrantNo = null
		if len(@PersonGroupLabel1) = 0 set @PersonGroupLabel1 = null
		if len(@PersonGroupTitle1) = 0 set @PersonGroupTitle1 = null
		if len(@PersonGroupLabel2) = 0 set @PersonGroupLabel2 = null
		if len(@PersonGroupTitle2) = 0 set @PersonGroupTitle2 = null
		if len(@PersonGroupLabel3) = 0 set @PersonGroupLabel3 = null
		if len(@PersonGroupTitle3) = 0 set @PersonGroupTitle3 = null
		if len(@PersonGroupLabel4) = 0 set @PersonGroupLabel4 = null
		if len(@PersonGroupTitle4) = 0 set @PersonGroupTitle4 = null
		if len(@PersonGroupLabel5) = 0 set @PersonGroupLabel5 = null
		if len(@PersonGroupTitle5) = 0 set @PersonGroupTitle5 = null
		if len(@PracticeRegisterLabel) = 0 set @PracticeRegisterLabel = null
		if len(@PracticeRegisterSectionLabel) = 0 set @PracticeRegisterSectionLabel = null
		if len(@QualifyingCredentialLabel) = 0 set @QualifyingCredentialLabel = null
		if len(@QualifyingCredentialOrgLabel) = 0 set @QualifyingCredentialOrgLabel = null
		if len(@QualifyingProgramName) = 0 set @QualifyingProgramName = null
		if len(@QualifyingFieldOfStudyName) = 0 set @QualifyingFieldOfStudyName = null
		if len(@CredentialLabel1) = 0 set @CredentialLabel1 = null
		if len(@CredentialOrgLabel1) = 0 set @CredentialOrgLabel1 = null
		if len(@CredentialProgramName1) = 0 set @CredentialProgramName1 = null
		if len(@CredentialFieldOfStudyName1) = 0 set @CredentialFieldOfStudyName1 = null
		if len(@CredentialLabel2) = 0 set @CredentialLabel2 = null
		if len(@CredentialOrgLabel2) = 0 set @CredentialOrgLabel2 = null
		if len(@CredentialProgramName2) = 0 set @CredentialProgramName2 = null
		if len(@CredentialFieldOfStudyName2) = 0 set @CredentialFieldOfStudyName2 = null
		if len(@CredentialLabel3) = 0 set @CredentialLabel3 = null
		if len(@CredentialOrgLabel3) = 0 set @CredentialOrgLabel3 = null
		if len(@CredentialProgramName3) = 0 set @CredentialProgramName3 = null
		if len(@CredentialFieldOfStudyName3) = 0 set @CredentialFieldOfStudyName3 = null
		if len(@CredentialLabel4) = 0 set @CredentialLabel4 = null
		if len(@CredentialOrgLabel4) = 0 set @CredentialOrgLabel4 = null
		if len(@CredentialProgramName4) = 0 set @CredentialProgramName4 = null
		if len(@CredentialFieldOfStudyName4) = 0 set @CredentialFieldOfStudyName4 = null
		if len(@CredentialLabel5) = 0 set @CredentialLabel5 = null
		if len(@CredentialOrgLabel5) = 0 set @CredentialOrgLabel5 = null
		if len(@CredentialProgramName5) = 0 set @CredentialProgramName5 = null
		if len(@CredentialFieldOfStudyName5) = 0 set @CredentialFieldOfStudyName5 = null
		if len(@CredentialLabel6) = 0 set @CredentialLabel6 = null
		if len(@CredentialOrgLabel6) = 0 set @CredentialOrgLabel6 = null
		if len(@CredentialProgramName6) = 0 set @CredentialProgramName6 = null
		if len(@CredentialFieldOfStudyName6) = 0 set @CredentialFieldOfStudyName6 = null
		if len(@CredentialLabel7) = 0 set @CredentialLabel7 = null
		if len(@CredentialOrgLabel7) = 0 set @CredentialOrgLabel7 = null
		if len(@CredentialProgramName7) = 0 set @CredentialProgramName7 = null
		if len(@CredentialFieldOfStudyName7) = 0 set @CredentialFieldOfStudyName7 = null
		if len(@CredentialLabel8) = 0 set @CredentialLabel8 = null
		if len(@CredentialOrgLabel8) = 0 set @CredentialOrgLabel8 = null
		if len(@CredentialProgramName8) = 0 set @CredentialProgramName8 = null
		if len(@CredentialFieldOfStudyName8) = 0 set @CredentialFieldOfStudyName8 = null
		if len(@CredentialLabel9) = 0 set @CredentialLabel9 = null
		if len(@CredentialOrgLabel9) = 0 set @CredentialOrgLabel9 = null
		if len(@CredentialProgramName9) = 0 set @CredentialProgramName9 = null
		if len(@CredentialFieldOfStudyName9) = 0 set @CredentialFieldOfStudyName9 = null
		if len(@ProcessingComments) = 0 set @ProcessingComments = null
		if len(@RegistrantProfileXID) = 0 set @RegistrantProfileXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@FileName) = 0 set @FileName = null
		if len(@MessageText) = 0 set @MessageText = null
		if len(@ProcessingStatusSCD) = 0 set @ProcessingStatusSCD = null
		if len(@ProcessingStatusLabel) = 0 set @ProcessingStatusLabel = null
		if len(@PersonEmailAddressEmailAddress) = 0 set @PersonEmailAddressEmailAddress = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @ImportFileSID                   = isnull(@ImportFileSID,rp.ImportFileSID)
				,@ProcessingStatusSID             = isnull(@ProcessingStatusSID,rp.ProcessingStatusSID)
				,@LastName                        = isnull(@LastName,rp.LastName)
				,@FirstName                       = isnull(@FirstName,rp.FirstName)
				,@CommonName                      = isnull(@CommonName,rp.CommonName)
				,@MiddleNames                     = isnull(@MiddleNames,rp.MiddleNames)
				,@EmailAddress                    = isnull(@EmailAddress,rp.EmailAddress)
				,@HomePhone                       = isnull(@HomePhone,rp.HomePhone)
				,@MobilePhone                     = isnull(@MobilePhone,rp.MobilePhone)
				,@IsTextMessagingEnabled          = isnull(@IsTextMessagingEnabled,rp.IsTextMessagingEnabled)
				,@GenderLabel                     = isnull(@GenderLabel,rp.GenderLabel)
				,@NamePrefixLabel                 = isnull(@NamePrefixLabel,rp.NamePrefixLabel)
				,@BirthDate                       = isnull(@BirthDate,rp.BirthDate)
				,@DeathDate                       = isnull(@DeathDate,rp.DeathDate)
				,@UserName                        = isnull(@UserName,rp.UserName)
				,@SubDomain                       = isnull(@SubDomain,rp.SubDomain)
				,@Password                        = isnull(@Password,rp.Password)
				,@StreetAddress1                  = isnull(@StreetAddress1,rp.StreetAddress1)
				,@StreetAddress2                  = isnull(@StreetAddress2,rp.StreetAddress2)
				,@StreetAddress3                  = isnull(@StreetAddress3,rp.StreetAddress3)
				,@CityName                        = isnull(@CityName,rp.CityName)
				,@StateProvinceName               = isnull(@StateProvinceName,rp.StateProvinceName)
				,@PostalCode                      = isnull(@PostalCode,rp.PostalCode)
				,@CountryName                     = isnull(@CountryName,rp.CountryName)
				,@RegionLabel                     = isnull(@RegionLabel,rp.RegionLabel)
				,@RegistrantNo                    = isnull(@RegistrantNo,rp.RegistrantNo)
				,@PersonGroupLabel1               = isnull(@PersonGroupLabel1,rp.PersonGroupLabel1)
				,@PersonGroupTitle1               = isnull(@PersonGroupTitle1,rp.PersonGroupTitle1)
				,@PersonGroupIsAdministrator1     = isnull(@PersonGroupIsAdministrator1,rp.PersonGroupIsAdministrator1)
				,@PersonGroupEffectiveDate1       = isnull(@PersonGroupEffectiveDate1,rp.PersonGroupEffectiveDate1)
				,@PersonGroupExpiryDate1          = isnull(@PersonGroupExpiryDate1,rp.PersonGroupExpiryDate1)
				,@PersonGroupLabel2               = isnull(@PersonGroupLabel2,rp.PersonGroupLabel2)
				,@PersonGroupTitle2               = isnull(@PersonGroupTitle2,rp.PersonGroupTitle2)
				,@PersonGroupIsAdministrator2     = isnull(@PersonGroupIsAdministrator2,rp.PersonGroupIsAdministrator2)
				,@PersonGroupEffectiveDate2       = isnull(@PersonGroupEffectiveDate2,rp.PersonGroupEffectiveDate2)
				,@PersonGroupExpiryDate2          = isnull(@PersonGroupExpiryDate2,rp.PersonGroupExpiryDate2)
				,@PersonGroupLabel3               = isnull(@PersonGroupLabel3,rp.PersonGroupLabel3)
				,@PersonGroupTitle3               = isnull(@PersonGroupTitle3,rp.PersonGroupTitle3)
				,@PersonGroupIsAdministrator3     = isnull(@PersonGroupIsAdministrator3,rp.PersonGroupIsAdministrator3)
				,@PersonGroupEffectiveDate3       = isnull(@PersonGroupEffectiveDate3,rp.PersonGroupEffectiveDate3)
				,@PersonGroupExpiryDate3          = isnull(@PersonGroupExpiryDate3,rp.PersonGroupExpiryDate3)
				,@PersonGroupLabel4               = isnull(@PersonGroupLabel4,rp.PersonGroupLabel4)
				,@PersonGroupTitle4               = isnull(@PersonGroupTitle4,rp.PersonGroupTitle4)
				,@PersonGroupIsAdministrator4     = isnull(@PersonGroupIsAdministrator4,rp.PersonGroupIsAdministrator4)
				,@PersonGroupEffectiveDate4       = isnull(@PersonGroupEffectiveDate4,rp.PersonGroupEffectiveDate4)
				,@PersonGroupExpiryDate4          = isnull(@PersonGroupExpiryDate4,rp.PersonGroupExpiryDate4)
				,@PersonGroupLabel5               = isnull(@PersonGroupLabel5,rp.PersonGroupLabel5)
				,@PersonGroupTitle5               = isnull(@PersonGroupTitle5,rp.PersonGroupTitle5)
				,@PersonGroupIsAdministrator5     = isnull(@PersonGroupIsAdministrator5,rp.PersonGroupIsAdministrator5)
				,@PersonGroupEffectiveDate5       = isnull(@PersonGroupEffectiveDate5,rp.PersonGroupEffectiveDate5)
				,@PersonGroupExpiryDate5          = isnull(@PersonGroupExpiryDate5,rp.PersonGroupExpiryDate5)
				,@PracticeRegisterLabel           = isnull(@PracticeRegisterLabel,rp.PracticeRegisterLabel)
				,@PracticeRegisterSectionLabel    = isnull(@PracticeRegisterSectionLabel,rp.PracticeRegisterSectionLabel)
				,@RegistrationEffectiveDate       = isnull(@RegistrationEffectiveDate,rp.RegistrationEffectiveDate)
				,@QualifyingCredentialLabel       = isnull(@QualifyingCredentialLabel,rp.QualifyingCredentialLabel)
				,@QualifyingCredentialOrgLabel    = isnull(@QualifyingCredentialOrgLabel,rp.QualifyingCredentialOrgLabel)
				,@QualifyingProgramName           = isnull(@QualifyingProgramName,rp.QualifyingProgramName)
				,@QualifyingProgramStartDate      = isnull(@QualifyingProgramStartDate,rp.QualifyingProgramStartDate)
				,@QualifyingProgramCompletionDate = isnull(@QualifyingProgramCompletionDate,rp.QualifyingProgramCompletionDate)
				,@QualifyingFieldOfStudyName      = isnull(@QualifyingFieldOfStudyName,rp.QualifyingFieldOfStudyName)
				,@CredentialLabel1                = isnull(@CredentialLabel1,rp.CredentialLabel1)
				,@CredentialOrgLabel1             = isnull(@CredentialOrgLabel1,rp.CredentialOrgLabel1)
				,@CredentialProgramName1          = isnull(@CredentialProgramName1,rp.CredentialProgramName1)
				,@CredentialFieldOfStudyName1     = isnull(@CredentialFieldOfStudyName1,rp.CredentialFieldOfStudyName1)
				,@CredentialEffectiveDate1        = isnull(@CredentialEffectiveDate1,rp.CredentialEffectiveDate1)
				,@CredentialExpiryDate1           = isnull(@CredentialExpiryDate1,rp.CredentialExpiryDate1)
				,@CredentialLabel2                = isnull(@CredentialLabel2,rp.CredentialLabel2)
				,@CredentialOrgLabel2             = isnull(@CredentialOrgLabel2,rp.CredentialOrgLabel2)
				,@CredentialProgramName2          = isnull(@CredentialProgramName2,rp.CredentialProgramName2)
				,@CredentialFieldOfStudyName2     = isnull(@CredentialFieldOfStudyName2,rp.CredentialFieldOfStudyName2)
				,@CredentialEffectiveDate2        = isnull(@CredentialEffectiveDate2,rp.CredentialEffectiveDate2)
				,@CredentialExpiryDate2           = isnull(@CredentialExpiryDate2,rp.CredentialExpiryDate2)
				,@CredentialLabel3                = isnull(@CredentialLabel3,rp.CredentialLabel3)
				,@CredentialOrgLabel3             = isnull(@CredentialOrgLabel3,rp.CredentialOrgLabel3)
				,@CredentialProgramName3          = isnull(@CredentialProgramName3,rp.CredentialProgramName3)
				,@CredentialFieldOfStudyName3     = isnull(@CredentialFieldOfStudyName3,rp.CredentialFieldOfStudyName3)
				,@CredentialEffectiveDate3        = isnull(@CredentialEffectiveDate3,rp.CredentialEffectiveDate3)
				,@CredentialExpiryDate3           = isnull(@CredentialExpiryDate3,rp.CredentialExpiryDate3)
				,@CredentialLabel4                = isnull(@CredentialLabel4,rp.CredentialLabel4)
				,@CredentialOrgLabel4             = isnull(@CredentialOrgLabel4,rp.CredentialOrgLabel4)
				,@CredentialProgramName4          = isnull(@CredentialProgramName4,rp.CredentialProgramName4)
				,@CredentialFieldOfStudyName4     = isnull(@CredentialFieldOfStudyName4,rp.CredentialFieldOfStudyName4)
				,@CredentialEffectiveDate4        = isnull(@CredentialEffectiveDate4,rp.CredentialEffectiveDate4)
				,@CredentialExpiryDate4           = isnull(@CredentialExpiryDate4,rp.CredentialExpiryDate4)
				,@CredentialLabel5                = isnull(@CredentialLabel5,rp.CredentialLabel5)
				,@CredentialOrgLabel5             = isnull(@CredentialOrgLabel5,rp.CredentialOrgLabel5)
				,@CredentialProgramName5          = isnull(@CredentialProgramName5,rp.CredentialProgramName5)
				,@CredentialFieldOfStudyName5     = isnull(@CredentialFieldOfStudyName5,rp.CredentialFieldOfStudyName5)
				,@CredentialEffectiveDate5        = isnull(@CredentialEffectiveDate5,rp.CredentialEffectiveDate5)
				,@CredentialExpiryDate5           = isnull(@CredentialExpiryDate5,rp.CredentialExpiryDate5)
				,@CredentialLabel6                = isnull(@CredentialLabel6,rp.CredentialLabel6)
				,@CredentialOrgLabel6             = isnull(@CredentialOrgLabel6,rp.CredentialOrgLabel6)
				,@CredentialProgramName6          = isnull(@CredentialProgramName6,rp.CredentialProgramName6)
				,@CredentialFieldOfStudyName6     = isnull(@CredentialFieldOfStudyName6,rp.CredentialFieldOfStudyName6)
				,@CredentialEffectiveDate6        = isnull(@CredentialEffectiveDate6,rp.CredentialEffectiveDate6)
				,@CredentialExpiryDate6           = isnull(@CredentialExpiryDate6,rp.CredentialExpiryDate6)
				,@CredentialLabel7                = isnull(@CredentialLabel7,rp.CredentialLabel7)
				,@CredentialOrgLabel7             = isnull(@CredentialOrgLabel7,rp.CredentialOrgLabel7)
				,@CredentialProgramName7          = isnull(@CredentialProgramName7,rp.CredentialProgramName7)
				,@CredentialFieldOfStudyName7     = isnull(@CredentialFieldOfStudyName7,rp.CredentialFieldOfStudyName7)
				,@CredentialEffectiveDate7        = isnull(@CredentialEffectiveDate7,rp.CredentialEffectiveDate7)
				,@CredentialExpiryDate7           = isnull(@CredentialExpiryDate7,rp.CredentialExpiryDate7)
				,@CredentialLabel8                = isnull(@CredentialLabel8,rp.CredentialLabel8)
				,@CredentialOrgLabel8             = isnull(@CredentialOrgLabel8,rp.CredentialOrgLabel8)
				,@CredentialProgramName8          = isnull(@CredentialProgramName8,rp.CredentialProgramName8)
				,@CredentialFieldOfStudyName8     = isnull(@CredentialFieldOfStudyName8,rp.CredentialFieldOfStudyName8)
				,@CredentialEffectiveDate8        = isnull(@CredentialEffectiveDate8,rp.CredentialEffectiveDate8)
				,@CredentialExpiryDate8           = isnull(@CredentialExpiryDate8,rp.CredentialExpiryDate8)
				,@CredentialLabel9                = isnull(@CredentialLabel9,rp.CredentialLabel9)
				,@CredentialOrgLabel9             = isnull(@CredentialOrgLabel9,rp.CredentialOrgLabel9)
				,@CredentialProgramName9          = isnull(@CredentialProgramName9,rp.CredentialProgramName9)
				,@CredentialFieldOfStudyName9     = isnull(@CredentialFieldOfStudyName9,rp.CredentialFieldOfStudyName9)
				,@CredentialEffectiveDate9        = isnull(@CredentialEffectiveDate9,rp.CredentialEffectiveDate9)
				,@CredentialExpiryDate9           = isnull(@CredentialExpiryDate9,rp.CredentialExpiryDate9)
				,@PersonSID                       = isnull(@PersonSID,rp.PersonSID)
				,@PersonEmailAddressSID           = isnull(@PersonEmailAddressSID,rp.PersonEmailAddressSID)
				,@ApplicationUserSID              = isnull(@ApplicationUserSID,rp.ApplicationUserSID)
				,@PersonMailingAddressSID         = isnull(@PersonMailingAddressSID,rp.PersonMailingAddressSID)
				,@RegionSID                       = isnull(@RegionSID,rp.RegionSID)
				,@NamePrefixSID                   = isnull(@NamePrefixSID,rp.NamePrefixSID)
				,@GenderSID                       = isnull(@GenderSID,rp.GenderSID)
				,@CitySID                         = isnull(@CitySID,rp.CitySID)
				,@StateProvinceSID                = isnull(@StateProvinceSID,rp.StateProvinceSID)
				,@CountrySID                      = isnull(@CountrySID,rp.CountrySID)
				,@RegistrantSID                   = isnull(@RegistrantSID,rp.RegistrantSID)
				,@ProcessingComments              = isnull(@ProcessingComments,rp.ProcessingComments)
				,@UserDefinedColumns              = isnull(@UserDefinedColumns,rp.UserDefinedColumns)
				,@RegistrantProfileXID            = isnull(@RegistrantProfileXID,rp.RegistrantProfileXID)
				,@LegacyKey                       = isnull(@LegacyKey,rp.LegacyKey)
				,@UpdateUser                      = isnull(@UpdateUser,rp.UpdateUser)
				,@IsReselected                    = isnull(@IsReselected,rp.IsReselected)
				,@IsNullApplied                   = isnull(@IsNullApplied,rp.IsNullApplied)
				,@zContext                        = isnull(@zContext,rp.zContext)
				,@FileFormatSID                   = isnull(@FileFormatSID,rp.FileFormatSID)
				,@ApplicationEntitySID            = isnull(@ApplicationEntitySID,rp.ApplicationEntitySID)
				,@FileName                        = isnull(@FileName,rp.FileName)
				,@LoadStartTime                   = isnull(@LoadStartTime,rp.LoadStartTime)
				,@LoadEndTime                     = isnull(@LoadEndTime,rp.LoadEndTime)
				,@IsFailed                        = isnull(@IsFailed,rp.IsFailed)
				,@MessageText                     = isnull(@MessageText,rp.MessageText)
				,@ImportFileRowGUID               = isnull(@ImportFileRowGUID,rp.ImportFileRowGUID)
				,@ProcessingStatusSCD             = isnull(@ProcessingStatusSCD,rp.ProcessingStatusSCD)
				,@ProcessingStatusLabel           = isnull(@ProcessingStatusLabel,rp.ProcessingStatusLabel)
				,@IsClosedStatus                  = isnull(@IsClosedStatus,rp.IsClosedStatus)
				,@ProcessingStatusIsActive        = isnull(@ProcessingStatusIsActive,rp.ProcessingStatusIsActive)
				,@ProcessingStatusIsDefault       = isnull(@ProcessingStatusIsDefault,rp.ProcessingStatusIsDefault)
				,@ProcessingStatusRowGUID         = isnull(@ProcessingStatusRowGUID,rp.ProcessingStatusRowGUID)
				,@PersonEmailAddressPersonSID     = isnull(@PersonEmailAddressPersonSID,rp.PersonEmailAddressPersonSID)
				,@PersonEmailAddressEmailAddress  = isnull(@PersonEmailAddressEmailAddress,rp.PersonEmailAddressEmailAddress)
				,@IsPrimary                       = isnull(@IsPrimary,rp.IsPrimary)
				,@PersonEmailAddressIsActive      = isnull(@PersonEmailAddressIsActive,rp.PersonEmailAddressIsActive)
				,@PersonEmailAddressRowGUID       = isnull(@PersonEmailAddressRowGUID,rp.PersonEmailAddressRowGUID)
				,@IsDeleteEnabled                 = isnull(@IsDeleteEnabled,rp.IsDeleteEnabled)
				,@RegistrantLabel                 = isnull(@RegistrantLabel,rp.RegistrantLabel)
			from
				stg.vRegistrantProfile rp
			where
				rp.RegistrantProfileSID = @RegistrantProfileSID

		end
		
		set @HomePhone   = sf.fFormatPhone(@HomePhone)												-- format phone numbers to standard
		set @MobilePhone = sf.fFormatPhone(@MobilePhone)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ProcessingStatusSCD is not null and @ProcessingStatusSID = (select x.ProcessingStatusSID from stg.RegistrantProfile x where x.RegistrantProfileSID = @RegistrantProfileSID)
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.PersonEmailAddressSID from stg.RegistrantProfile x where x.RegistrantProfileSID = @RegistrantProfileSID) <> @PersonEmailAddressSID
		begin
			if (select x.IsActive from sf.PersonEmailAddress x where x.PersonEmailAddressSID = @PersonEmailAddressSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'person email address'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.ProcessingStatusSID from stg.RegistrantProfile x where x.RegistrantProfileSID = @RegistrantProfileSID) <> @ProcessingStatusSID
		begin
			if (select x.IsActive from sf.ProcessingStatus x where x.ProcessingStatusSID = @ProcessingStatusSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'processing status'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
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
				r.RoutineName = 'stg#pRegistrantProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantProfile
				 @Mode                            = 'update.pre'
				,@RegistrantProfileSID            = @RegistrantProfileSID
				,@ImportFileSID                   = @ImportFileSID output
				,@ProcessingStatusSID             = @ProcessingStatusSID output
				,@LastName                        = @LastName output
				,@FirstName                       = @FirstName output
				,@CommonName                      = @CommonName output
				,@MiddleNames                     = @MiddleNames output
				,@EmailAddress                    = @EmailAddress output
				,@HomePhone                       = @HomePhone output
				,@MobilePhone                     = @MobilePhone output
				,@IsTextMessagingEnabled          = @IsTextMessagingEnabled output
				,@GenderLabel                     = @GenderLabel output
				,@NamePrefixLabel                 = @NamePrefixLabel output
				,@BirthDate                       = @BirthDate output
				,@DeathDate                       = @DeathDate output
				,@UserName                        = @UserName output
				,@SubDomain                       = @SubDomain output
				,@Password                        = @Password output
				,@StreetAddress1                  = @StreetAddress1 output
				,@StreetAddress2                  = @StreetAddress2 output
				,@StreetAddress3                  = @StreetAddress3 output
				,@CityName                        = @CityName output
				,@StateProvinceName               = @StateProvinceName output
				,@PostalCode                      = @PostalCode output
				,@CountryName                     = @CountryName output
				,@RegionLabel                     = @RegionLabel output
				,@RegistrantNo                    = @RegistrantNo output
				,@PersonGroupLabel1               = @PersonGroupLabel1 output
				,@PersonGroupTitle1               = @PersonGroupTitle1 output
				,@PersonGroupIsAdministrator1     = @PersonGroupIsAdministrator1 output
				,@PersonGroupEffectiveDate1       = @PersonGroupEffectiveDate1 output
				,@PersonGroupExpiryDate1          = @PersonGroupExpiryDate1 output
				,@PersonGroupLabel2               = @PersonGroupLabel2 output
				,@PersonGroupTitle2               = @PersonGroupTitle2 output
				,@PersonGroupIsAdministrator2     = @PersonGroupIsAdministrator2 output
				,@PersonGroupEffectiveDate2       = @PersonGroupEffectiveDate2 output
				,@PersonGroupExpiryDate2          = @PersonGroupExpiryDate2 output
				,@PersonGroupLabel3               = @PersonGroupLabel3 output
				,@PersonGroupTitle3               = @PersonGroupTitle3 output
				,@PersonGroupIsAdministrator3     = @PersonGroupIsAdministrator3 output
				,@PersonGroupEffectiveDate3       = @PersonGroupEffectiveDate3 output
				,@PersonGroupExpiryDate3          = @PersonGroupExpiryDate3 output
				,@PersonGroupLabel4               = @PersonGroupLabel4 output
				,@PersonGroupTitle4               = @PersonGroupTitle4 output
				,@PersonGroupIsAdministrator4     = @PersonGroupIsAdministrator4 output
				,@PersonGroupEffectiveDate4       = @PersonGroupEffectiveDate4 output
				,@PersonGroupExpiryDate4          = @PersonGroupExpiryDate4 output
				,@PersonGroupLabel5               = @PersonGroupLabel5 output
				,@PersonGroupTitle5               = @PersonGroupTitle5 output
				,@PersonGroupIsAdministrator5     = @PersonGroupIsAdministrator5 output
				,@PersonGroupEffectiveDate5       = @PersonGroupEffectiveDate5 output
				,@PersonGroupExpiryDate5          = @PersonGroupExpiryDate5 output
				,@PracticeRegisterLabel           = @PracticeRegisterLabel output
				,@PracticeRegisterSectionLabel    = @PracticeRegisterSectionLabel output
				,@RegistrationEffectiveDate       = @RegistrationEffectiveDate output
				,@QualifyingCredentialLabel       = @QualifyingCredentialLabel output
				,@QualifyingCredentialOrgLabel    = @QualifyingCredentialOrgLabel output
				,@QualifyingProgramName           = @QualifyingProgramName output
				,@QualifyingProgramStartDate      = @QualifyingProgramStartDate output
				,@QualifyingProgramCompletionDate = @QualifyingProgramCompletionDate output
				,@QualifyingFieldOfStudyName      = @QualifyingFieldOfStudyName output
				,@CredentialLabel1                = @CredentialLabel1 output
				,@CredentialOrgLabel1             = @CredentialOrgLabel1 output
				,@CredentialProgramName1          = @CredentialProgramName1 output
				,@CredentialFieldOfStudyName1     = @CredentialFieldOfStudyName1 output
				,@CredentialEffectiveDate1        = @CredentialEffectiveDate1 output
				,@CredentialExpiryDate1           = @CredentialExpiryDate1 output
				,@CredentialLabel2                = @CredentialLabel2 output
				,@CredentialOrgLabel2             = @CredentialOrgLabel2 output
				,@CredentialProgramName2          = @CredentialProgramName2 output
				,@CredentialFieldOfStudyName2     = @CredentialFieldOfStudyName2 output
				,@CredentialEffectiveDate2        = @CredentialEffectiveDate2 output
				,@CredentialExpiryDate2           = @CredentialExpiryDate2 output
				,@CredentialLabel3                = @CredentialLabel3 output
				,@CredentialOrgLabel3             = @CredentialOrgLabel3 output
				,@CredentialProgramName3          = @CredentialProgramName3 output
				,@CredentialFieldOfStudyName3     = @CredentialFieldOfStudyName3 output
				,@CredentialEffectiveDate3        = @CredentialEffectiveDate3 output
				,@CredentialExpiryDate3           = @CredentialExpiryDate3 output
				,@CredentialLabel4                = @CredentialLabel4 output
				,@CredentialOrgLabel4             = @CredentialOrgLabel4 output
				,@CredentialProgramName4          = @CredentialProgramName4 output
				,@CredentialFieldOfStudyName4     = @CredentialFieldOfStudyName4 output
				,@CredentialEffectiveDate4        = @CredentialEffectiveDate4 output
				,@CredentialExpiryDate4           = @CredentialExpiryDate4 output
				,@CredentialLabel5                = @CredentialLabel5 output
				,@CredentialOrgLabel5             = @CredentialOrgLabel5 output
				,@CredentialProgramName5          = @CredentialProgramName5 output
				,@CredentialFieldOfStudyName5     = @CredentialFieldOfStudyName5 output
				,@CredentialEffectiveDate5        = @CredentialEffectiveDate5 output
				,@CredentialExpiryDate5           = @CredentialExpiryDate5 output
				,@CredentialLabel6                = @CredentialLabel6 output
				,@CredentialOrgLabel6             = @CredentialOrgLabel6 output
				,@CredentialProgramName6          = @CredentialProgramName6 output
				,@CredentialFieldOfStudyName6     = @CredentialFieldOfStudyName6 output
				,@CredentialEffectiveDate6        = @CredentialEffectiveDate6 output
				,@CredentialExpiryDate6           = @CredentialExpiryDate6 output
				,@CredentialLabel7                = @CredentialLabel7 output
				,@CredentialOrgLabel7             = @CredentialOrgLabel7 output
				,@CredentialProgramName7          = @CredentialProgramName7 output
				,@CredentialFieldOfStudyName7     = @CredentialFieldOfStudyName7 output
				,@CredentialEffectiveDate7        = @CredentialEffectiveDate7 output
				,@CredentialExpiryDate7           = @CredentialExpiryDate7 output
				,@CredentialLabel8                = @CredentialLabel8 output
				,@CredentialOrgLabel8             = @CredentialOrgLabel8 output
				,@CredentialProgramName8          = @CredentialProgramName8 output
				,@CredentialFieldOfStudyName8     = @CredentialFieldOfStudyName8 output
				,@CredentialEffectiveDate8        = @CredentialEffectiveDate8 output
				,@CredentialExpiryDate8           = @CredentialExpiryDate8 output
				,@CredentialLabel9                = @CredentialLabel9 output
				,@CredentialOrgLabel9             = @CredentialOrgLabel9 output
				,@CredentialProgramName9          = @CredentialProgramName9 output
				,@CredentialFieldOfStudyName9     = @CredentialFieldOfStudyName9 output
				,@CredentialEffectiveDate9        = @CredentialEffectiveDate9 output
				,@CredentialExpiryDate9           = @CredentialExpiryDate9 output
				,@PersonSID                       = @PersonSID output
				,@PersonEmailAddressSID           = @PersonEmailAddressSID output
				,@ApplicationUserSID              = @ApplicationUserSID output
				,@PersonMailingAddressSID         = @PersonMailingAddressSID output
				,@RegionSID                       = @RegionSID output
				,@NamePrefixSID                   = @NamePrefixSID output
				,@GenderSID                       = @GenderSID output
				,@CitySID                         = @CitySID output
				,@StateProvinceSID                = @StateProvinceSID output
				,@CountrySID                      = @CountrySID output
				,@RegistrantSID                   = @RegistrantSID output
				,@ProcessingComments              = @ProcessingComments output
				,@UserDefinedColumns              = @UserDefinedColumns output
				,@RegistrantProfileXID            = @RegistrantProfileXID output
				,@LegacyKey                       = @LegacyKey output
				,@UpdateUser                      = @UpdateUser
				,@RowStamp                        = @RowStamp
				,@IsReselected                    = @IsReselected
				,@IsNullApplied                   = @IsNullApplied
				,@zContext                        = @zContext
				,@FileFormatSID                   = @FileFormatSID
				,@ApplicationEntitySID            = @ApplicationEntitySID
				,@FileName                        = @FileName
				,@LoadStartTime                   = @LoadStartTime
				,@LoadEndTime                     = @LoadEndTime
				,@IsFailed                        = @IsFailed
				,@MessageText                     = @MessageText
				,@ImportFileRowGUID               = @ImportFileRowGUID
				,@ProcessingStatusSCD             = @ProcessingStatusSCD
				,@ProcessingStatusLabel           = @ProcessingStatusLabel
				,@IsClosedStatus                  = @IsClosedStatus
				,@ProcessingStatusIsActive        = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault       = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID         = @ProcessingStatusRowGUID
				,@PersonEmailAddressPersonSID     = @PersonEmailAddressPersonSID
				,@PersonEmailAddressEmailAddress  = @PersonEmailAddressEmailAddress
				,@IsPrimary                       = @IsPrimary
				,@PersonEmailAddressIsActive      = @PersonEmailAddressIsActive
				,@PersonEmailAddressRowGUID       = @PersonEmailAddressRowGUID
				,@IsDeleteEnabled                 = @IsDeleteEnabled
				,@RegistrantLabel                 = @RegistrantLabel
		
		end

		-- update the record

		update
			stg.RegistrantProfile
		set
			 ImportFileSID = @ImportFileSID
			,ProcessingStatusSID = @ProcessingStatusSID
			,LastName = @LastName
			,FirstName = @FirstName
			,CommonName = @CommonName
			,MiddleNames = @MiddleNames
			,EmailAddress = @EmailAddress
			,HomePhone = @HomePhone
			,MobilePhone = @MobilePhone
			,IsTextMessagingEnabled = @IsTextMessagingEnabled
			,GenderLabel = @GenderLabel
			,NamePrefixLabel = @NamePrefixLabel
			,BirthDate = @BirthDate
			,DeathDate = @DeathDate
			,UserName = @UserName
			,SubDomain = @SubDomain
			,Password = @Password
			,StreetAddress1 = @StreetAddress1
			,StreetAddress2 = @StreetAddress2
			,StreetAddress3 = @StreetAddress3
			,CityName = @CityName
			,StateProvinceName = @StateProvinceName
			,PostalCode = @PostalCode
			,CountryName = @CountryName
			,RegionLabel = @RegionLabel
			,RegistrantNo = @RegistrantNo
			,PersonGroupLabel1 = @PersonGroupLabel1
			,PersonGroupTitle1 = @PersonGroupTitle1
			,PersonGroupIsAdministrator1 = @PersonGroupIsAdministrator1
			,PersonGroupEffectiveDate1 = @PersonGroupEffectiveDate1
			,PersonGroupExpiryDate1 = @PersonGroupExpiryDate1
			,PersonGroupLabel2 = @PersonGroupLabel2
			,PersonGroupTitle2 = @PersonGroupTitle2
			,PersonGroupIsAdministrator2 = @PersonGroupIsAdministrator2
			,PersonGroupEffectiveDate2 = @PersonGroupEffectiveDate2
			,PersonGroupExpiryDate2 = @PersonGroupExpiryDate2
			,PersonGroupLabel3 = @PersonGroupLabel3
			,PersonGroupTitle3 = @PersonGroupTitle3
			,PersonGroupIsAdministrator3 = @PersonGroupIsAdministrator3
			,PersonGroupEffectiveDate3 = @PersonGroupEffectiveDate3
			,PersonGroupExpiryDate3 = @PersonGroupExpiryDate3
			,PersonGroupLabel4 = @PersonGroupLabel4
			,PersonGroupTitle4 = @PersonGroupTitle4
			,PersonGroupIsAdministrator4 = @PersonGroupIsAdministrator4
			,PersonGroupEffectiveDate4 = @PersonGroupEffectiveDate4
			,PersonGroupExpiryDate4 = @PersonGroupExpiryDate4
			,PersonGroupLabel5 = @PersonGroupLabel5
			,PersonGroupTitle5 = @PersonGroupTitle5
			,PersonGroupIsAdministrator5 = @PersonGroupIsAdministrator5
			,PersonGroupEffectiveDate5 = @PersonGroupEffectiveDate5
			,PersonGroupExpiryDate5 = @PersonGroupExpiryDate5
			,PracticeRegisterLabel = @PracticeRegisterLabel
			,PracticeRegisterSectionLabel = @PracticeRegisterSectionLabel
			,RegistrationEffectiveDate = @RegistrationEffectiveDate
			,QualifyingCredentialLabel = @QualifyingCredentialLabel
			,QualifyingCredentialOrgLabel = @QualifyingCredentialOrgLabel
			,QualifyingProgramName = @QualifyingProgramName
			,QualifyingProgramStartDate = @QualifyingProgramStartDate
			,QualifyingProgramCompletionDate = @QualifyingProgramCompletionDate
			,QualifyingFieldOfStudyName = @QualifyingFieldOfStudyName
			,CredentialLabel1 = @CredentialLabel1
			,CredentialOrgLabel1 = @CredentialOrgLabel1
			,CredentialProgramName1 = @CredentialProgramName1
			,CredentialFieldOfStudyName1 = @CredentialFieldOfStudyName1
			,CredentialEffectiveDate1 = @CredentialEffectiveDate1
			,CredentialExpiryDate1 = @CredentialExpiryDate1
			,CredentialLabel2 = @CredentialLabel2
			,CredentialOrgLabel2 = @CredentialOrgLabel2
			,CredentialProgramName2 = @CredentialProgramName2
			,CredentialFieldOfStudyName2 = @CredentialFieldOfStudyName2
			,CredentialEffectiveDate2 = @CredentialEffectiveDate2
			,CredentialExpiryDate2 = @CredentialExpiryDate2
			,CredentialLabel3 = @CredentialLabel3
			,CredentialOrgLabel3 = @CredentialOrgLabel3
			,CredentialProgramName3 = @CredentialProgramName3
			,CredentialFieldOfStudyName3 = @CredentialFieldOfStudyName3
			,CredentialEffectiveDate3 = @CredentialEffectiveDate3
			,CredentialExpiryDate3 = @CredentialExpiryDate3
			,CredentialLabel4 = @CredentialLabel4
			,CredentialOrgLabel4 = @CredentialOrgLabel4
			,CredentialProgramName4 = @CredentialProgramName4
			,CredentialFieldOfStudyName4 = @CredentialFieldOfStudyName4
			,CredentialEffectiveDate4 = @CredentialEffectiveDate4
			,CredentialExpiryDate4 = @CredentialExpiryDate4
			,CredentialLabel5 = @CredentialLabel5
			,CredentialOrgLabel5 = @CredentialOrgLabel5
			,CredentialProgramName5 = @CredentialProgramName5
			,CredentialFieldOfStudyName5 = @CredentialFieldOfStudyName5
			,CredentialEffectiveDate5 = @CredentialEffectiveDate5
			,CredentialExpiryDate5 = @CredentialExpiryDate5
			,CredentialLabel6 = @CredentialLabel6
			,CredentialOrgLabel6 = @CredentialOrgLabel6
			,CredentialProgramName6 = @CredentialProgramName6
			,CredentialFieldOfStudyName6 = @CredentialFieldOfStudyName6
			,CredentialEffectiveDate6 = @CredentialEffectiveDate6
			,CredentialExpiryDate6 = @CredentialExpiryDate6
			,CredentialLabel7 = @CredentialLabel7
			,CredentialOrgLabel7 = @CredentialOrgLabel7
			,CredentialProgramName7 = @CredentialProgramName7
			,CredentialFieldOfStudyName7 = @CredentialFieldOfStudyName7
			,CredentialEffectiveDate7 = @CredentialEffectiveDate7
			,CredentialExpiryDate7 = @CredentialExpiryDate7
			,CredentialLabel8 = @CredentialLabel8
			,CredentialOrgLabel8 = @CredentialOrgLabel8
			,CredentialProgramName8 = @CredentialProgramName8
			,CredentialFieldOfStudyName8 = @CredentialFieldOfStudyName8
			,CredentialEffectiveDate8 = @CredentialEffectiveDate8
			,CredentialExpiryDate8 = @CredentialExpiryDate8
			,CredentialLabel9 = @CredentialLabel9
			,CredentialOrgLabel9 = @CredentialOrgLabel9
			,CredentialProgramName9 = @CredentialProgramName9
			,CredentialFieldOfStudyName9 = @CredentialFieldOfStudyName9
			,CredentialEffectiveDate9 = @CredentialEffectiveDate9
			,CredentialExpiryDate9 = @CredentialExpiryDate9
			,PersonSID = @PersonSID
			,PersonEmailAddressSID = @PersonEmailAddressSID
			,ApplicationUserSID = @ApplicationUserSID
			,PersonMailingAddressSID = @PersonMailingAddressSID
			,RegionSID = @RegionSID
			,NamePrefixSID = @NamePrefixSID
			,GenderSID = @GenderSID
			,CitySID = @CitySID
			,StateProvinceSID = @StateProvinceSID
			,CountrySID = @CountrySID
			,RegistrantSID = @RegistrantSID
			,ProcessingComments = @ProcessingComments
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrantProfileXID = @RegistrantProfileXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrantProfileSID = @RegistrantProfileSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from stg.RegistrantProfile where RegistrantProfileSID = @registrantProfileSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'stg.RegistrantProfile'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'stg.RegistrantProfile'
					,@Arg2        = @registrantProfileSID
				
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
				,@Arg2        = 'stg.RegistrantProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrantProfileSID
			
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
				r.RoutineName = 'stg#pRegistrantProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantProfile
				 @Mode                            = 'update.post'
				,@RegistrantProfileSID            = @RegistrantProfileSID
				,@ImportFileSID                   = @ImportFileSID
				,@ProcessingStatusSID             = @ProcessingStatusSID
				,@LastName                        = @LastName
				,@FirstName                       = @FirstName
				,@CommonName                      = @CommonName
				,@MiddleNames                     = @MiddleNames
				,@EmailAddress                    = @EmailAddress
				,@HomePhone                       = @HomePhone
				,@MobilePhone                     = @MobilePhone
				,@IsTextMessagingEnabled          = @IsTextMessagingEnabled
				,@GenderLabel                     = @GenderLabel
				,@NamePrefixLabel                 = @NamePrefixLabel
				,@BirthDate                       = @BirthDate
				,@DeathDate                       = @DeathDate
				,@UserName                        = @UserName
				,@SubDomain                       = @SubDomain
				,@Password                        = @Password
				,@StreetAddress1                  = @StreetAddress1
				,@StreetAddress2                  = @StreetAddress2
				,@StreetAddress3                  = @StreetAddress3
				,@CityName                        = @CityName
				,@StateProvinceName               = @StateProvinceName
				,@PostalCode                      = @PostalCode
				,@CountryName                     = @CountryName
				,@RegionLabel                     = @RegionLabel
				,@RegistrantNo                    = @RegistrantNo
				,@PersonGroupLabel1               = @PersonGroupLabel1
				,@PersonGroupTitle1               = @PersonGroupTitle1
				,@PersonGroupIsAdministrator1     = @PersonGroupIsAdministrator1
				,@PersonGroupEffectiveDate1       = @PersonGroupEffectiveDate1
				,@PersonGroupExpiryDate1          = @PersonGroupExpiryDate1
				,@PersonGroupLabel2               = @PersonGroupLabel2
				,@PersonGroupTitle2               = @PersonGroupTitle2
				,@PersonGroupIsAdministrator2     = @PersonGroupIsAdministrator2
				,@PersonGroupEffectiveDate2       = @PersonGroupEffectiveDate2
				,@PersonGroupExpiryDate2          = @PersonGroupExpiryDate2
				,@PersonGroupLabel3               = @PersonGroupLabel3
				,@PersonGroupTitle3               = @PersonGroupTitle3
				,@PersonGroupIsAdministrator3     = @PersonGroupIsAdministrator3
				,@PersonGroupEffectiveDate3       = @PersonGroupEffectiveDate3
				,@PersonGroupExpiryDate3          = @PersonGroupExpiryDate3
				,@PersonGroupLabel4               = @PersonGroupLabel4
				,@PersonGroupTitle4               = @PersonGroupTitle4
				,@PersonGroupIsAdministrator4     = @PersonGroupIsAdministrator4
				,@PersonGroupEffectiveDate4       = @PersonGroupEffectiveDate4
				,@PersonGroupExpiryDate4          = @PersonGroupExpiryDate4
				,@PersonGroupLabel5               = @PersonGroupLabel5
				,@PersonGroupTitle5               = @PersonGroupTitle5
				,@PersonGroupIsAdministrator5     = @PersonGroupIsAdministrator5
				,@PersonGroupEffectiveDate5       = @PersonGroupEffectiveDate5
				,@PersonGroupExpiryDate5          = @PersonGroupExpiryDate5
				,@PracticeRegisterLabel           = @PracticeRegisterLabel
				,@PracticeRegisterSectionLabel    = @PracticeRegisterSectionLabel
				,@RegistrationEffectiveDate       = @RegistrationEffectiveDate
				,@QualifyingCredentialLabel       = @QualifyingCredentialLabel
				,@QualifyingCredentialOrgLabel    = @QualifyingCredentialOrgLabel
				,@QualifyingProgramName           = @QualifyingProgramName
				,@QualifyingProgramStartDate      = @QualifyingProgramStartDate
				,@QualifyingProgramCompletionDate = @QualifyingProgramCompletionDate
				,@QualifyingFieldOfStudyName      = @QualifyingFieldOfStudyName
				,@CredentialLabel1                = @CredentialLabel1
				,@CredentialOrgLabel1             = @CredentialOrgLabel1
				,@CredentialProgramName1          = @CredentialProgramName1
				,@CredentialFieldOfStudyName1     = @CredentialFieldOfStudyName1
				,@CredentialEffectiveDate1        = @CredentialEffectiveDate1
				,@CredentialExpiryDate1           = @CredentialExpiryDate1
				,@CredentialLabel2                = @CredentialLabel2
				,@CredentialOrgLabel2             = @CredentialOrgLabel2
				,@CredentialProgramName2          = @CredentialProgramName2
				,@CredentialFieldOfStudyName2     = @CredentialFieldOfStudyName2
				,@CredentialEffectiveDate2        = @CredentialEffectiveDate2
				,@CredentialExpiryDate2           = @CredentialExpiryDate2
				,@CredentialLabel3                = @CredentialLabel3
				,@CredentialOrgLabel3             = @CredentialOrgLabel3
				,@CredentialProgramName3          = @CredentialProgramName3
				,@CredentialFieldOfStudyName3     = @CredentialFieldOfStudyName3
				,@CredentialEffectiveDate3        = @CredentialEffectiveDate3
				,@CredentialExpiryDate3           = @CredentialExpiryDate3
				,@CredentialLabel4                = @CredentialLabel4
				,@CredentialOrgLabel4             = @CredentialOrgLabel4
				,@CredentialProgramName4          = @CredentialProgramName4
				,@CredentialFieldOfStudyName4     = @CredentialFieldOfStudyName4
				,@CredentialEffectiveDate4        = @CredentialEffectiveDate4
				,@CredentialExpiryDate4           = @CredentialExpiryDate4
				,@CredentialLabel5                = @CredentialLabel5
				,@CredentialOrgLabel5             = @CredentialOrgLabel5
				,@CredentialProgramName5          = @CredentialProgramName5
				,@CredentialFieldOfStudyName5     = @CredentialFieldOfStudyName5
				,@CredentialEffectiveDate5        = @CredentialEffectiveDate5
				,@CredentialExpiryDate5           = @CredentialExpiryDate5
				,@CredentialLabel6                = @CredentialLabel6
				,@CredentialOrgLabel6             = @CredentialOrgLabel6
				,@CredentialProgramName6          = @CredentialProgramName6
				,@CredentialFieldOfStudyName6     = @CredentialFieldOfStudyName6
				,@CredentialEffectiveDate6        = @CredentialEffectiveDate6
				,@CredentialExpiryDate6           = @CredentialExpiryDate6
				,@CredentialLabel7                = @CredentialLabel7
				,@CredentialOrgLabel7             = @CredentialOrgLabel7
				,@CredentialProgramName7          = @CredentialProgramName7
				,@CredentialFieldOfStudyName7     = @CredentialFieldOfStudyName7
				,@CredentialEffectiveDate7        = @CredentialEffectiveDate7
				,@CredentialExpiryDate7           = @CredentialExpiryDate7
				,@CredentialLabel8                = @CredentialLabel8
				,@CredentialOrgLabel8             = @CredentialOrgLabel8
				,@CredentialProgramName8          = @CredentialProgramName8
				,@CredentialFieldOfStudyName8     = @CredentialFieldOfStudyName8
				,@CredentialEffectiveDate8        = @CredentialEffectiveDate8
				,@CredentialExpiryDate8           = @CredentialExpiryDate8
				,@CredentialLabel9                = @CredentialLabel9
				,@CredentialOrgLabel9             = @CredentialOrgLabel9
				,@CredentialProgramName9          = @CredentialProgramName9
				,@CredentialFieldOfStudyName9     = @CredentialFieldOfStudyName9
				,@CredentialEffectiveDate9        = @CredentialEffectiveDate9
				,@CredentialExpiryDate9           = @CredentialExpiryDate9
				,@PersonSID                       = @PersonSID
				,@PersonEmailAddressSID           = @PersonEmailAddressSID
				,@ApplicationUserSID              = @ApplicationUserSID
				,@PersonMailingAddressSID         = @PersonMailingAddressSID
				,@RegionSID                       = @RegionSID
				,@NamePrefixSID                   = @NamePrefixSID
				,@GenderSID                       = @GenderSID
				,@CitySID                         = @CitySID
				,@StateProvinceSID                = @StateProvinceSID
				,@CountrySID                      = @CountrySID
				,@RegistrantSID                   = @RegistrantSID
				,@ProcessingComments              = @ProcessingComments
				,@UserDefinedColumns              = @UserDefinedColumns
				,@RegistrantProfileXID            = @RegistrantProfileXID
				,@LegacyKey                       = @LegacyKey
				,@UpdateUser                      = @UpdateUser
				,@RowStamp                        = @RowStamp
				,@IsReselected                    = @IsReselected
				,@IsNullApplied                   = @IsNullApplied
				,@zContext                        = @zContext
				,@FileFormatSID                   = @FileFormatSID
				,@ApplicationEntitySID            = @ApplicationEntitySID
				,@FileName                        = @FileName
				,@LoadStartTime                   = @LoadStartTime
				,@LoadEndTime                     = @LoadEndTime
				,@IsFailed                        = @IsFailed
				,@MessageText                     = @MessageText
				,@ImportFileRowGUID               = @ImportFileRowGUID
				,@ProcessingStatusSCD             = @ProcessingStatusSCD
				,@ProcessingStatusLabel           = @ProcessingStatusLabel
				,@IsClosedStatus                  = @IsClosedStatus
				,@ProcessingStatusIsActive        = @ProcessingStatusIsActive
				,@ProcessingStatusIsDefault       = @ProcessingStatusIsDefault
				,@ProcessingStatusRowGUID         = @ProcessingStatusRowGUID
				,@PersonEmailAddressPersonSID     = @PersonEmailAddressPersonSID
				,@PersonEmailAddressEmailAddress  = @PersonEmailAddressEmailAddress
				,@IsPrimary                       = @IsPrimary
				,@PersonEmailAddressIsActive      = @PersonEmailAddressIsActive
				,@PersonEmailAddressRowGUID       = @PersonEmailAddressRowGUID
				,@IsDeleteEnabled                 = @IsDeleteEnabled
				,@RegistrantLabel                 = @RegistrantLabel
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrantProfileSID
			from
				stg.vRegistrantProfile ent
			where
				ent.RegistrantProfileSID = @RegistrantProfileSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrantProfileSID
				,ent.ImportFileSID
				,ent.ProcessingStatusSID
				,ent.LastName
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.EmailAddress
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.GenderLabel
				,ent.NamePrefixLabel
				,ent.BirthDate
				,ent.DeathDate
				,ent.UserName
				,ent.SubDomain
				,ent.Password
				,ent.StreetAddress1
				,ent.StreetAddress2
				,ent.StreetAddress3
				,ent.CityName
				,ent.StateProvinceName
				,ent.PostalCode
				,ent.CountryName
				,ent.RegionLabel
				,ent.RegistrantNo
				,ent.PersonGroupLabel1
				,ent.PersonGroupTitle1
				,ent.PersonGroupIsAdministrator1
				,ent.PersonGroupEffectiveDate1
				,ent.PersonGroupExpiryDate1
				,ent.PersonGroupLabel2
				,ent.PersonGroupTitle2
				,ent.PersonGroupIsAdministrator2
				,ent.PersonGroupEffectiveDate2
				,ent.PersonGroupExpiryDate2
				,ent.PersonGroupLabel3
				,ent.PersonGroupTitle3
				,ent.PersonGroupIsAdministrator3
				,ent.PersonGroupEffectiveDate3
				,ent.PersonGroupExpiryDate3
				,ent.PersonGroupLabel4
				,ent.PersonGroupTitle4
				,ent.PersonGroupIsAdministrator4
				,ent.PersonGroupEffectiveDate4
				,ent.PersonGroupExpiryDate4
				,ent.PersonGroupLabel5
				,ent.PersonGroupTitle5
				,ent.PersonGroupIsAdministrator5
				,ent.PersonGroupEffectiveDate5
				,ent.PersonGroupExpiryDate5
				,ent.PracticeRegisterLabel
				,ent.PracticeRegisterSectionLabel
				,ent.RegistrationEffectiveDate
				,ent.QualifyingCredentialLabel
				,ent.QualifyingCredentialOrgLabel
				,ent.QualifyingProgramName
				,ent.QualifyingProgramStartDate
				,ent.QualifyingProgramCompletionDate
				,ent.QualifyingFieldOfStudyName
				,ent.CredentialLabel1
				,ent.CredentialOrgLabel1
				,ent.CredentialProgramName1
				,ent.CredentialFieldOfStudyName1
				,ent.CredentialEffectiveDate1
				,ent.CredentialExpiryDate1
				,ent.CredentialLabel2
				,ent.CredentialOrgLabel2
				,ent.CredentialProgramName2
				,ent.CredentialFieldOfStudyName2
				,ent.CredentialEffectiveDate2
				,ent.CredentialExpiryDate2
				,ent.CredentialLabel3
				,ent.CredentialOrgLabel3
				,ent.CredentialProgramName3
				,ent.CredentialFieldOfStudyName3
				,ent.CredentialEffectiveDate3
				,ent.CredentialExpiryDate3
				,ent.CredentialLabel4
				,ent.CredentialOrgLabel4
				,ent.CredentialProgramName4
				,ent.CredentialFieldOfStudyName4
				,ent.CredentialEffectiveDate4
				,ent.CredentialExpiryDate4
				,ent.CredentialLabel5
				,ent.CredentialOrgLabel5
				,ent.CredentialProgramName5
				,ent.CredentialFieldOfStudyName5
				,ent.CredentialEffectiveDate5
				,ent.CredentialExpiryDate5
				,ent.CredentialLabel6
				,ent.CredentialOrgLabel6
				,ent.CredentialProgramName6
				,ent.CredentialFieldOfStudyName6
				,ent.CredentialEffectiveDate6
				,ent.CredentialExpiryDate6
				,ent.CredentialLabel7
				,ent.CredentialOrgLabel7
				,ent.CredentialProgramName7
				,ent.CredentialFieldOfStudyName7
				,ent.CredentialEffectiveDate7
				,ent.CredentialExpiryDate7
				,ent.CredentialLabel8
				,ent.CredentialOrgLabel8
				,ent.CredentialProgramName8
				,ent.CredentialFieldOfStudyName8
				,ent.CredentialEffectiveDate8
				,ent.CredentialExpiryDate8
				,ent.CredentialLabel9
				,ent.CredentialOrgLabel9
				,ent.CredentialProgramName9
				,ent.CredentialFieldOfStudyName9
				,ent.CredentialEffectiveDate9
				,ent.CredentialExpiryDate9
				,ent.PersonSID
				,ent.PersonEmailAddressSID
				,ent.ApplicationUserSID
				,ent.PersonMailingAddressSID
				,ent.RegionSID
				,ent.NamePrefixSID
				,ent.GenderSID
				,ent.CitySID
				,ent.StateProvinceSID
				,ent.CountrySID
				,ent.RegistrantSID
				,ent.ProcessingComments
				,ent.UserDefinedColumns
				,ent.RegistrantProfileXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.FileFormatSID
				,ent.ApplicationEntitySID
				,ent.FileName
				,ent.LoadStartTime
				,ent.LoadEndTime
				,ent.IsFailed
				,ent.MessageText
				,ent.ImportFileRowGUID
				,ent.ProcessingStatusSCD
				,ent.ProcessingStatusLabel
				,ent.IsClosedStatus
				,ent.ProcessingStatusIsActive
				,ent.ProcessingStatusIsDefault
				,ent.ProcessingStatusRowGUID
				,ent.PersonEmailAddressPersonSID
				,ent.PersonEmailAddressEmailAddress
				,ent.IsPrimary
				,ent.PersonEmailAddressIsActive
				,ent.PersonEmailAddressRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrantLabel
			from
				stg.vRegistrantProfile ent
			where
				ent.RegistrantProfileSID = @RegistrantProfileSID

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
