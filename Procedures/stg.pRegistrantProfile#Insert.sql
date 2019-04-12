SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [stg].[pRegistrantProfile#Insert]
	 @RegistrantProfileSID            int               = null output				-- identity value assigned to the new record
	,@ImportFileSID                   int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@ProcessingStatusSID             int               = null							-- required! if not passed value must be set in custom logic prior to insert
	,@LastName                        nvarchar(35)      = null							
	,@FirstName                       nvarchar(30)      = null							
	,@CommonName                      nvarchar(30)      = null							
	,@MiddleNames                     nvarchar(30)      = null							
	,@EmailAddress                    varchar(150)      = null							
	,@HomePhone                       varchar(25)       = null							
	,@MobilePhone                     varchar(25)       = null							
	,@IsTextMessagingEnabled          bit               = null							-- default: (0)
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
	,@PersonGroupIsAdministrator1     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate1       date              = null							
	,@PersonGroupExpiryDate1          date              = null							
	,@PersonGroupLabel2               nvarchar(35)      = null							
	,@PersonGroupTitle2               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator2     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate2       date              = null							
	,@PersonGroupExpiryDate2          date              = null							
	,@PersonGroupLabel3               nvarchar(35)      = null							
	,@PersonGroupTitle3               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator3     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate3       date              = null							
	,@PersonGroupExpiryDate3          date              = null							
	,@PersonGroupLabel4               nvarchar(35)      = null							
	,@PersonGroupTitle4               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator4     bit               = null							-- default: (0)
	,@PersonGroupEffectiveDate4       date              = null							
	,@PersonGroupExpiryDate4          date              = null							
	,@PersonGroupLabel5               nvarchar(35)      = null							
	,@PersonGroupTitle5               nvarchar(75)      = null							
	,@PersonGroupIsAdministrator5     bit               = null							-- default: (0)
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
	,@CreateUser                      nvarchar(75)      = null							-- default: suser_sname()
	,@IsReselected                    tinyint           = null							-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                        xml               = null							-- other values defining context for the insert (if any)
	,@FileFormatSID                   int               = null							-- not a base table column (default ignored)
	,@ApplicationEntitySID            int               = null							-- not a base table column (default ignored)
	,@FileName                        nvarchar(100)     = null							-- not a base table column (default ignored)
	,@LoadStartTime                   datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@LoadEndTime                     datetimeoffset(7) = null							-- not a base table column (default ignored)
	,@IsFailed                        bit               = null							-- not a base table column (default ignored)
	,@MessageText                     nvarchar(4000)    = null							-- not a base table column (default ignored)
	,@ImportFileRowGUID               uniqueidentifier  = null							-- not a base table column (default ignored)
	,@ProcessingStatusSCD             varchar(10)       = null							-- not a base table column (default ignored)
	,@ProcessingStatusLabel           nvarchar(35)      = null							-- not a base table column (default ignored)
	,@IsClosedStatus                  bit               = null							-- not a base table column (default ignored)
	,@ProcessingStatusIsActive        bit               = null							-- not a base table column (default ignored)
	,@ProcessingStatusIsDefault       bit               = null							-- not a base table column (default ignored)
	,@ProcessingStatusRowGUID         uniqueidentifier  = null							-- not a base table column (default ignored)
	,@PersonEmailAddressPersonSID     int               = null							-- not a base table column (default ignored)
	,@PersonEmailAddressEmailAddress  varchar(150)      = null							-- not a base table column (default ignored)
	,@IsPrimary                       bit               = null							-- not a base table column (default ignored)
	,@PersonEmailAddressIsActive      bit               = null							-- not a base table column (default ignored)
	,@PersonEmailAddressRowGUID       uniqueidentifier  = null							-- not a base table column (default ignored)
	,@IsDeleteEnabled                 bit               = null							-- not a base table column (default ignored)
	,@RegistrantLabel                 nvarchar(75)      = null							-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : stg.pRegistrantProfile#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the stg.RegistrantProfile table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the stg.RegistrantProfile table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrantProfile entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrantProfile procedure. The extended procedure is only called
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

	set @RegistrantProfileSID = null																				-- initialize output parameter

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
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@FileName) = 0 set @FileName = null
		if len(@MessageText) = 0 set @MessageText = null
		if len(@ProcessingStatusSCD) = 0 set @ProcessingStatusSCD = null
		if len(@ProcessingStatusLabel) = 0 set @ProcessingStatusLabel = null
		if len(@PersonEmailAddressEmailAddress) = 0 set @PersonEmailAddressEmailAddress = null
		if len(@RegistrantLabel) = 0 set @RegistrantLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @IsTextMessagingEnabled = isnull(@IsTextMessagingEnabled,(0))
		set @PersonGroupIsAdministrator1 = isnull(@PersonGroupIsAdministrator1,(0))
		set @PersonGroupIsAdministrator2 = isnull(@PersonGroupIsAdministrator2,(0))
		set @PersonGroupIsAdministrator3 = isnull(@PersonGroupIsAdministrator3,(0))
		set @PersonGroupIsAdministrator4 = isnull(@PersonGroupIsAdministrator4,(0))
		set @PersonGroupIsAdministrator5 = isnull(@PersonGroupIsAdministrator5,(0))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                    = isnull(@IsReselected                   ,(0))
		
		set @HomePhone   = sf.fFormatPhone(@HomePhone)												-- format phone numbers to standard
		set @MobilePhone = sf.fFormatPhone(@MobilePhone)
		
		set @PostalCode = sf.fFormatPostalCode(@PostalCode)										-- format postal codes to standard
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @ProcessingStatusSCD is not null
		begin
		
			select
				@ProcessingStatusSID = x.ProcessingStatusSID
			from
				sf.ProcessingStatus x
			where
				x.ProcessingStatusSCD = @ProcessingStatusSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @ProcessingStatusSID  is null select @ProcessingStatusSID  = x.ProcessingStatusSID from sf.ProcessingStatus  x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
	
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
				r.RoutineName = 'stg#pRegistrantProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantProfile
				 @Mode                            = 'insert.pre'
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
				,@CreateUser                      = @CreateUser
				,@IsReselected                    = @IsReselected
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

		-- insert the record

		insert
			stg.RegistrantProfile
		(
			 ImportFileSID
			,ProcessingStatusSID
			,LastName
			,FirstName
			,CommonName
			,MiddleNames
			,EmailAddress
			,HomePhone
			,MobilePhone
			,IsTextMessagingEnabled
			,GenderLabel
			,NamePrefixLabel
			,BirthDate
			,DeathDate
			,UserName
			,SubDomain
			,Password
			,StreetAddress1
			,StreetAddress2
			,StreetAddress3
			,CityName
			,StateProvinceName
			,PostalCode
			,CountryName
			,RegionLabel
			,RegistrantNo
			,PersonGroupLabel1
			,PersonGroupTitle1
			,PersonGroupIsAdministrator1
			,PersonGroupEffectiveDate1
			,PersonGroupExpiryDate1
			,PersonGroupLabel2
			,PersonGroupTitle2
			,PersonGroupIsAdministrator2
			,PersonGroupEffectiveDate2
			,PersonGroupExpiryDate2
			,PersonGroupLabel3
			,PersonGroupTitle3
			,PersonGroupIsAdministrator3
			,PersonGroupEffectiveDate3
			,PersonGroupExpiryDate3
			,PersonGroupLabel4
			,PersonGroupTitle4
			,PersonGroupIsAdministrator4
			,PersonGroupEffectiveDate4
			,PersonGroupExpiryDate4
			,PersonGroupLabel5
			,PersonGroupTitle5
			,PersonGroupIsAdministrator5
			,PersonGroupEffectiveDate5
			,PersonGroupExpiryDate5
			,PracticeRegisterLabel
			,PracticeRegisterSectionLabel
			,RegistrationEffectiveDate
			,QualifyingCredentialLabel
			,QualifyingCredentialOrgLabel
			,QualifyingProgramName
			,QualifyingProgramStartDate
			,QualifyingProgramCompletionDate
			,QualifyingFieldOfStudyName
			,CredentialLabel1
			,CredentialOrgLabel1
			,CredentialProgramName1
			,CredentialFieldOfStudyName1
			,CredentialEffectiveDate1
			,CredentialExpiryDate1
			,CredentialLabel2
			,CredentialOrgLabel2
			,CredentialProgramName2
			,CredentialFieldOfStudyName2
			,CredentialEffectiveDate2
			,CredentialExpiryDate2
			,CredentialLabel3
			,CredentialOrgLabel3
			,CredentialProgramName3
			,CredentialFieldOfStudyName3
			,CredentialEffectiveDate3
			,CredentialExpiryDate3
			,CredentialLabel4
			,CredentialOrgLabel4
			,CredentialProgramName4
			,CredentialFieldOfStudyName4
			,CredentialEffectiveDate4
			,CredentialExpiryDate4
			,CredentialLabel5
			,CredentialOrgLabel5
			,CredentialProgramName5
			,CredentialFieldOfStudyName5
			,CredentialEffectiveDate5
			,CredentialExpiryDate5
			,CredentialLabel6
			,CredentialOrgLabel6
			,CredentialProgramName6
			,CredentialFieldOfStudyName6
			,CredentialEffectiveDate6
			,CredentialExpiryDate6
			,CredentialLabel7
			,CredentialOrgLabel7
			,CredentialProgramName7
			,CredentialFieldOfStudyName7
			,CredentialEffectiveDate7
			,CredentialExpiryDate7
			,CredentialLabel8
			,CredentialOrgLabel8
			,CredentialProgramName8
			,CredentialFieldOfStudyName8
			,CredentialEffectiveDate8
			,CredentialExpiryDate8
			,CredentialLabel9
			,CredentialOrgLabel9
			,CredentialProgramName9
			,CredentialFieldOfStudyName9
			,CredentialEffectiveDate9
			,CredentialExpiryDate9
			,PersonSID
			,PersonEmailAddressSID
			,ApplicationUserSID
			,PersonMailingAddressSID
			,RegionSID
			,NamePrefixSID
			,GenderSID
			,CitySID
			,StateProvinceSID
			,CountrySID
			,RegistrantSID
			,ProcessingComments
			,UserDefinedColumns
			,RegistrantProfileXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @ImportFileSID
			,@ProcessingStatusSID
			,@LastName
			,@FirstName
			,@CommonName
			,@MiddleNames
			,@EmailAddress
			,@HomePhone
			,@MobilePhone
			,@IsTextMessagingEnabled
			,@GenderLabel
			,@NamePrefixLabel
			,@BirthDate
			,@DeathDate
			,@UserName
			,@SubDomain
			,@Password
			,@StreetAddress1
			,@StreetAddress2
			,@StreetAddress3
			,@CityName
			,@StateProvinceName
			,@PostalCode
			,@CountryName
			,@RegionLabel
			,@RegistrantNo
			,@PersonGroupLabel1
			,@PersonGroupTitle1
			,@PersonGroupIsAdministrator1
			,@PersonGroupEffectiveDate1
			,@PersonGroupExpiryDate1
			,@PersonGroupLabel2
			,@PersonGroupTitle2
			,@PersonGroupIsAdministrator2
			,@PersonGroupEffectiveDate2
			,@PersonGroupExpiryDate2
			,@PersonGroupLabel3
			,@PersonGroupTitle3
			,@PersonGroupIsAdministrator3
			,@PersonGroupEffectiveDate3
			,@PersonGroupExpiryDate3
			,@PersonGroupLabel4
			,@PersonGroupTitle4
			,@PersonGroupIsAdministrator4
			,@PersonGroupEffectiveDate4
			,@PersonGroupExpiryDate4
			,@PersonGroupLabel5
			,@PersonGroupTitle5
			,@PersonGroupIsAdministrator5
			,@PersonGroupEffectiveDate5
			,@PersonGroupExpiryDate5
			,@PracticeRegisterLabel
			,@PracticeRegisterSectionLabel
			,@RegistrationEffectiveDate
			,@QualifyingCredentialLabel
			,@QualifyingCredentialOrgLabel
			,@QualifyingProgramName
			,@QualifyingProgramStartDate
			,@QualifyingProgramCompletionDate
			,@QualifyingFieldOfStudyName
			,@CredentialLabel1
			,@CredentialOrgLabel1
			,@CredentialProgramName1
			,@CredentialFieldOfStudyName1
			,@CredentialEffectiveDate1
			,@CredentialExpiryDate1
			,@CredentialLabel2
			,@CredentialOrgLabel2
			,@CredentialProgramName2
			,@CredentialFieldOfStudyName2
			,@CredentialEffectiveDate2
			,@CredentialExpiryDate2
			,@CredentialLabel3
			,@CredentialOrgLabel3
			,@CredentialProgramName3
			,@CredentialFieldOfStudyName3
			,@CredentialEffectiveDate3
			,@CredentialExpiryDate3
			,@CredentialLabel4
			,@CredentialOrgLabel4
			,@CredentialProgramName4
			,@CredentialFieldOfStudyName4
			,@CredentialEffectiveDate4
			,@CredentialExpiryDate4
			,@CredentialLabel5
			,@CredentialOrgLabel5
			,@CredentialProgramName5
			,@CredentialFieldOfStudyName5
			,@CredentialEffectiveDate5
			,@CredentialExpiryDate5
			,@CredentialLabel6
			,@CredentialOrgLabel6
			,@CredentialProgramName6
			,@CredentialFieldOfStudyName6
			,@CredentialEffectiveDate6
			,@CredentialExpiryDate6
			,@CredentialLabel7
			,@CredentialOrgLabel7
			,@CredentialProgramName7
			,@CredentialFieldOfStudyName7
			,@CredentialEffectiveDate7
			,@CredentialExpiryDate7
			,@CredentialLabel8
			,@CredentialOrgLabel8
			,@CredentialProgramName8
			,@CredentialFieldOfStudyName8
			,@CredentialEffectiveDate8
			,@CredentialExpiryDate8
			,@CredentialLabel9
			,@CredentialOrgLabel9
			,@CredentialProgramName9
			,@CredentialFieldOfStudyName9
			,@CredentialEffectiveDate9
			,@CredentialExpiryDate9
			,@PersonSID
			,@PersonEmailAddressSID
			,@ApplicationUserSID
			,@PersonMailingAddressSID
			,@RegionSID
			,@NamePrefixSID
			,@GenderSID
			,@CitySID
			,@StateProvinceSID
			,@CountrySID
			,@RegistrantSID
			,@ProcessingComments
			,@UserDefinedColumns
			,@RegistrantProfileXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected         = @@rowcount
			,@RegistrantProfileSID = scope_identity()														-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'stg.RegistrantProfile'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrantProfileSID
			
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
				r.RoutineName = 'stg#pRegistrantProfile'
		)
		begin
		
			exec @errorNo = ext.stg#pRegistrantProfile
				 @Mode                            = 'insert.post'
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
				,@CreateUser                      = @CreateUser
				,@IsReselected                    = @IsReselected
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
