SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [stg].[fCredentialProfile#Check]
	(
	 @CredentialProfileSID        int
	,@ProcessingStatusSID         int
	,@SourceFileName              nvarchar(100)
	,@ProgramStartDate            date
	,@ProgramTargetCompletionDate date
	,@EffectiveTime               date
	,@IsDisplayedOnLicense        bit
	,@ProgramName                 nvarchar(65)
	,@OrgName                     nvarchar(15)
	,@OrgLabel                    nvarchar(35)
	,@StreetAddress1              nvarchar(75)
	,@StreetAddress2              nvarchar(75)
	,@StreedAddress3              nvarchar(75)
	,@CityName                    nvarchar(30)
	,@StateProvinceName           nvarchar(30)
	,@StateProvinceCode           nvarchar(5)
	,@PostalCode                  varchar(10)
	,@CountryName                 nvarchar(50)
	,@CountryISOA3                char(3)
	,@Phone                       varchar(25)
	,@Fax                         varchar(25)
	,@WebSite                     varchar(250)
	,@RegionLabel                 nvarchar(35)
	,@RegionName                  nvarchar(50)
	,@CredentialTypeLabel         nvarchar(35)
	,@RegistrantSID               int
	,@CredentialSID               int
	,@CredentialTypeSID           int
	,@OrgSID                      int
	,@RegionSID                   int
	,@CredentialProfileXID        varchar(150)
	,@LegacyKey                   nvarchar(50)
	,@IsDeleted                   bit
	,@CreateUser                  nvarchar(75)
	,@CreateTime                  datetimeoffset(7)
	,@UpdateUser                  nvarchar(75)
	,@UpdateTime                  datetimeoffset(7)
	,@RowGUID                     uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : stg.fCredentialProfile#Check
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : returns 1 (bit) when record values comply with business rules
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pCheckFcnGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

The function is designed to be incorporated into a check constraint on the table.  The standard for enforcing business rules,
except those that apply only on DELETE, is to use a check constraint.  A single check constraint is implemented on each table.
The constraint checks business rules by calling this function which is passed all the columns of the table. The shell of this
function was generated by an SGI studio procedure.  The function requires customization by a developer to implement validation
logic unique to this table.  Some rules may have been "auto-generated" based on column naming conventions.

The function is designed to be called through a check constraint or through a select statement for batch checking records.  In
both cases all columns of the table (not entity view) must be passed to the function.

In order to support re-generation of functions from DB Studio, the logic for each rule must be implemented with comment based
"XML tagging".  The <BusinessRules> and </BusinessRules> tag pair must enclose the content of all rules and then each individual
rule must be enclosed in a <Rule> ... </Rule> tag pair. The rule name and author information is parsed by the generator inserted
into the business rule index for reference in the documentation header (below).

The function contains "base" rules and "optional rules". A function of the same name in the "ext" schema may contain rules that
apply to this client configuration only. All base rules in the function are enforced on 100% of client configurations while optional
rules can be turned off by setting the "IsEnforced" bit = 0 for the rule in the sf.BusinessRule configuration table through the UI.
Base rules do not check the status of the IsEnforced bit. The enforcement of optional rules must be ON by default. See template.

To Add New Business Rules
-------------------------
o Copy the template (at bottom) to create new rule.
o Include the name of the first column involved in the rule as last segment in @errorMessageSCD
o If rule is optional, call sf.fBusinessRuleIsEnforced with same @errorMessageSCD (include the ".ColumnName")
o Update "Author" value on copied from template to your name - otherwise rule will be overwritten on regeneration!
o Do not change "$AutoRules" syntax - otherwise updates to auto-rules are not generated.
o Remove call to sf.fBusinessRuleIsEnforced from copied template if rule is MANDATORY.
o Prefix MessageSCD with "MBR." if rule is MANDATORY (only).
o Nest IF block to avoid testing rules that do not apply based on preconditions (to improve performance).
o Ensure test of all rules are defined in the test harness project.
o Check performance and resolve as required.

Rule Added By                  MessageCode.Column & Text
------------------------------ ----------------------------------------------------------------------------------------------------
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.CredentialSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.OrgSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ProcessingStatusSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.RegionSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.CityName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CountryISOA3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CountryName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialTypeLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialTypeSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.EffectiveTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.Fax A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.IsDisplayedOnLicense A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.OrgLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.OrgName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.OrgSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.Phone A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PostalCode A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ProgramName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ProgramStartDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ProgramTargetCompletionDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegionLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegionName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegionSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegistrantSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StateProvinceCode A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StateProvinceName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreedAddress3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.WebSite A value for "%1" is required.
$AutoRules | Tim Edlund        BackDatingLimit.EffectiveTime The "%1" cannot be backdated. The backdating limit set is %2 day(s).

Example
-------

select
	 CredentialProfileSID
	,stg.fCredentialProfile#Check
		(
		 CredentialProfileSID
		,ProcessingStatusSID
		,SourceFileName
		,ProgramStartDate
		,ProgramTargetCompletionDate
		,EffectiveTime
		,IsDisplayedOnLicense
		,ProgramName
		,OrgName
		,OrgLabel
		,StreetAddress1
		,StreetAddress2
		,StreedAddress3
		,CityName
		,StateProvinceName
		,StateProvinceCode
		,PostalCode
		,CountryName
		,CountryISOA3
		,Phone
		,Fax
		,WebSite
		,RegionLabel
		,RegionName
		,CredentialTypeLabel
		,RegistrantSID
		,CredentialSID
		,CredentialTypeSID
		,OrgSID
		,RegionSID
		,ProcessingComments
		,UserDefinedColumns
		,CredentialProfileXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	stg.CredentialProfile

-------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @errorText                       nvarchar(4000)  = N'1'							-- text for errors or returns TRUE when valid
		,@checkFcn                        nvarchar(128)   = object_name(@@procid)												-- name of currently executing function
		,@columnNames                     nvarchar(500)												-- column(s) with error - if multiple separate with commas
		,@errorMessageSCD                 varchar(75)													-- message code to lookup on error
		,@defaultMessageText              nvarchar(1000)											-- message text to return if no override in sf.Message
		,@arg1                            nvarchar(1000)											-- replacement text for "%1" in the message text
		,@arg2                            nvarchar(1000)											-- replacement text for "%2" in the message text
		,@arg3                            nvarchar(1000)											-- replacement text for "%3" in the message text
		,@arg4                            nvarchar(1000)											-- replacement text for "%4" in the message text
		,@arg5                            nvarchar(1000)											-- replacement text for "%5" in the message text
		,@recentAccessHours               smallint														-- configuration value for "recent" insert threshold
		,@isInsert                        bit             = 0									-- 1 if record appears to be an insert (see logic below)
		,@isUpdate                        bit             = 0									-- 1 if not a "new" record
		,@isRecentInsert                  bit             = 0									-- 1 if record was inserted within RECENT hours
		,@ON                              bit             = cast(1 as bit)		-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit             = cast(0 as bit)		-- a constant to reduce repetitive cast syntax in bit comparisons

	-- get configuration value or default to 24 hours

	set @recentAccessHours = isnull(convert(smallint, sf.fConfigParam#Value('RecentAccessHours')), 24)

	if datediff(hour, @CreateTime, sysdatetimeoffset()) > @recentAccessHours-- older than "recent" hours - update only
	begin
		set @isUpdate = @ON
	end
	else if datediff(second, @CreateTime, sysdatetimeoffset()) <= 2					-- record is only 2 seconds old - assume INSERT
	begin
		set @isInsert       = @ON
		set @isRecentInsert = @ON
	end
	else																																		-- record inserted within configured "recent" hours
	begin
		set @isUpdate       = @ON
		set @isRecentInsert = @ON
	end
	
	--!<BusinessRules>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Credential x where x.CredentialSID = @CredentialSID) = @OFF			-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.CredentialSID'
			set @columnNames        = N'CredentialSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'credential'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Org x where x.OrgSID = @OrgSID) = @OFF	-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.OrgSID'
			set @columnNames        = N'OrgSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'org'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from sf.ProcessingStatus x where x.ProcessingStatusSID = @ProcessingStatusSID) = @OFF								-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ProcessingStatusSID'
			set @columnNames        = N'ProcessingStatusSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'processing status'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Region x where x.RegionSID = @RegionSID) = @OFF									-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.RegionSID'
			set @columnNames        = N'RegionSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'region'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.CityName') = @ON and @CityName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CityName'
		set @columnNames        = N'CityName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'City Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.CountryISOA3') = @ON and @CountryISOA3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CountryISOA3'
		set @columnNames        = N'CountryISOA3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Country ISOA3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.CountryName') = @ON and @CountryName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CountryName'
		set @columnNames        = N'CountryName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Country Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.CredentialSID') = @ON and @CredentialSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialSID'
		set @columnNames        = N'CredentialSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.CredentialTypeLabel') = @ON and @CredentialTypeLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialTypeLabel'
		set @columnNames        = N'CredentialTypeLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Type Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.CredentialTypeSID') = @ON and @CredentialTypeSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialTypeSID'
		set @columnNames        = N'CredentialTypeSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Type'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.EffectiveTime') = @ON and @EffectiveTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.EffectiveTime'
		set @columnNames        = N'EffectiveTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Effective Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.Fax') = @ON and @Fax is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.Fax'
		set @columnNames        = N'Fax'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Fax'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.IsDisplayedOnLicense') = @ON and @IsDisplayedOnLicense is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.IsDisplayedOnLicense'
		set @columnNames        = N'IsDisplayedOnLicense'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Is Displayed On License'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.OrgLabel') = @ON and @OrgLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.OrgLabel'
		set @columnNames        = N'OrgLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Org Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.OrgName') = @ON and @OrgName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.OrgName'
		set @columnNames        = N'OrgName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Org Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.OrgSID') = @ON and @OrgSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.OrgSID'
		set @columnNames        = N'OrgSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Org'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.Phone') = @ON and @Phone is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.Phone'
		set @columnNames        = N'Phone'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Phone'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.PostalCode') = @ON and @PostalCode is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PostalCode'
		set @columnNames        = N'PostalCode'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Postal Code'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.ProgramName') = @ON and @ProgramName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ProgramName'
		set @columnNames        = N'ProgramName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Program Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.ProgramStartDate') = @ON and @ProgramStartDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ProgramStartDate'
		set @columnNames        = N'ProgramStartDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Program Start Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.ProgramTargetCompletionDate') = @ON and @ProgramTargetCompletionDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ProgramTargetCompletionDate'
		set @columnNames        = N'ProgramTargetCompletionDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Program Target Completion Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.RegionLabel') = @ON and @RegionLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegionLabel'
		set @columnNames        = N'RegionLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Region Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.RegionName') = @ON and @RegionName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegionName'
		set @columnNames        = N'RegionName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Region Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.RegionSID') = @ON and @RegionSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegionSID'
		set @columnNames        = N'RegionSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Region'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.RegistrantSID') = @ON and @RegistrantSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegistrantSID'
		set @columnNames        = N'RegistrantSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Registrant'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.StateProvinceCode') = @ON and @StateProvinceCode is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StateProvinceCode'
		set @columnNames        = N'StateProvinceCode'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'State Province Code'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.StateProvinceName') = @ON and @StateProvinceName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StateProvinceName'
		set @columnNames        = N'StateProvinceName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'State Province Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.StreedAddress3') = @ON and @StreedAddress3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreedAddress3'
		set @columnNames        = N'StreedAddress3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Streed Address 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.StreetAddress1') = @ON and @StreetAddress1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress1'
		set @columnNames        = N'StreetAddress1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.StreetAddress2') = @ON and @StreetAddress2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress2'
		set @columnNames        = N'StreetAddress2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','ValueIsRequired.WebSite') = @ON and @WebSite is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.WebSite'
		set @columnNames        = N'WebSite'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Web Site'
	end
	--!</Rule>
	
	declare @backDateLimit  smallint
	set @backDateLimit = isnull(convert(smallint, sf.fConfigParam#Value('BackDatingLimit')), 0)				-- get limit (days) from configuration or default to 0
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','BackDatingLimit.EffectiveTime') = @ON
	and datediff(day, @EffectiveTime, sf.fDTOffsetToClientDate(@CreateTime)) > @backDateLimit
	begin
		set @errorMessageSCD    = 'BackDatingLimit.EffectiveTime'
		set @columnNames        = N'EffectiveTime'
		set @defaultMessageText = N'The "%1" cannot be backdated. The backdating limit set is %2 day(s).'
		set @arg1               = N'Effective Time'
		set @arg2               = cast(@backDateLimit as nvarchar(10))
	end
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'stg',N'CredentialProfile','?SomeMessageCode.ColumnName') = 1	-- check if rule is ON - REMOVE for mandatory rules
	and 1 = 0
	begin
		set @errorMessageSCD      = '?SomeMessageCode.ColumnName'
		set @columnNames          = N'?ColumnName1, ?ColumnName2'
		set @defaultMessageText   = N'?Some default message text ...'
		set @arg1                 = N'?SomeReplacementValue'
	end
	--!</Rule>
	
	--!</BusinessRules>
	
	-- if no base-product business rules were violated, run the extended version of the
	-- function if it exists
	
	if @errorMessageSCD is null
	begin
	
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'stg#fCredentialProfile#Check'
		)
		begin
		
			select @errorText = ext.stg#fCredentialProfile#Check
				(
				 @CredentialProfileSID
				,@ProcessingStatusSID
				,@SourceFileName
				,@ProgramStartDate
				,@ProgramTargetCompletionDate
				,@EffectiveTime
				,@IsDisplayedOnLicense
				,@ProgramName
				,@OrgName
				,@OrgLabel
				,@StreetAddress1
				,@StreetAddress2
				,@StreedAddress3
				,@CityName
				,@StateProvinceName
				,@StateProvinceCode
				,@PostalCode
				,@CountryName
				,@CountryISOA3
				,@Phone
				,@Fax
				,@WebSite
				,@RegionLabel
				,@RegionName
				,@CredentialTypeLabel
				,@RegistrantSID
				,@CredentialSID
				,@CredentialTypeSID
				,@OrgSID
				,@RegionSID
				,@CredentialProfileXID
				,@LegacyKey
				,@IsDeleted
				,@CreateUser
				,@CreateTime
				,@UpdateUser
				,@UpdateTime
				,@RowGUID
				)
		
		end
	
	end
	
	-- if the extended function returned error text it will already be formatted otherwise check
	-- for a message code value and format the error information for processing by sf.pErrorRethrow
	
	if @errorText not like N'<err>%' and @errorMessageSCD is not null
	begin
	
		set @errorText = sf.fCheckConstraintErrorString
			(
			 @errorMessageSCD
			,@defaultMessageText
			,@columnNames
			,@CredentialProfileSID
			,@arg1
			,@arg2
			,@arg3
			,@arg4
			,@arg5
			)
	
	end
	
	-- cast returns TRUE if no errors (@errorText=1) but throws an exception for processing by sf.pErrorRethrow otherwise
	
	return cast(@errorText as bit)
end
GO
