SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fOrg#Check]
	(
	 @OrgSID                         int
	,@ParentOrgSID                   int
	,@OrgTypeSID                     int
	,@OrgName                        nvarchar(150)
	,@OrgLabel                       nvarchar(35)
	,@StreetAddress1                 nvarchar(75)
	,@StreetAddress2                 nvarchar(75)
	,@StreetAddress3                 nvarchar(75)
	,@CitySID                        int
	,@PostalCode                     varchar(10)
	,@RegionSID                      int
	,@Phone                          varchar(25)
	,@Fax                            varchar(25)
	,@WebSite                        varchar(250)
	,@EmailAddress                   varchar(150)
	,@InsuranceOrgSID                int
	,@InsurancePolicyNo              varchar(25)
	,@InsuranceAmount                decimal(11,2)
	,@IsEmployer                     bit
	,@IsCredentialAuthority          bit
	,@IsInsurer                      bit
	,@IsInsuranceCertificateRequired bit
	,@IsPublic                       nchar(10)
	,@IsActive                       bit
	,@IsAdminReviewRequired          bit
	,@LastVerifiedTime               datetimeoffset(7)
	,@OrgXID                         varchar(150)
	,@LegacyKey                      nvarchar(50)
	,@IsDeleted                      bit
	,@CreateUser                     nvarchar(75)
	,@CreateTime                     datetimeoffset(7)
	,@UpdateUser                     nvarchar(75)
	,@UpdateTime                     datetimeoffset(7)
	,@RowGUID                        uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fOrg#Check
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
$AutoRules | Tim Edlund        MBR.InvalidEmailAddress.EmailAddress The email address is not a valid format. Ensure the address doe
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.CitySID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.InsuranceOrgSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.OrgTypeSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ParentOrgSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.RegionSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.EmailAddress A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.Fax A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.InsuranceAmount A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.InsuranceOrgSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.InsurancePolicyNo A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.IsPublic A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.LastVerifiedTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ParentOrgSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.Phone A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.WebSite A value for "%1" is required.
Tim Edlund | Oct 2017          MBR.InvalidPhone.Phone'; (see source for message text)
Tim Edlund | Oct 2017          MBR.InvalidPhone.Fax'; @columnNames = Fax'; (see source for message text)
Tim Edlund | Oct 2017          MBR.InvalidPostalCode.PostalCode'; (see source for message text)
Tim Edlund | Jul 2017          EmployerAssignmentsExist.IsEmployer (see source for message text)
Tim Edlund | Jul 2017          CredentialAssignmentsExist.IsCredentialAuthority (see source for message text)
Taylor Napier | March 2019     DuplicateOrgAddress.StreetAddress1 (see source for message text)
Tim Edlund | Mar 2019          MBR.RequiredWhen.InsuranceOrgSID'; (see source for message text)
Tim Edlund | Mar 2019          MBR.RequiredWhen.InsurancePolicyNo'; (see source for message text)

Example
-------

select
	 OrgSID
	,OrgLabel
	,StreetAddress1
	,StreetAddress2
	,dbo.fOrg#Check
		(
		 OrgSID
		,ParentOrgSID
		,OrgTypeSID
		,OrgName
		,OrgLabel
		,StreetAddress1
		,StreetAddress2
		,StreetAddress3
		,CitySID
		,PostalCode
		,RegionSID
		,Phone
		,Fax
		,WebSite
		,EmailAddress
		,InsuranceOrgSID
		,InsurancePolicyNo
		,InsuranceAmount
		,IsEmployer
		,IsCredentialAuthority
		,IsInsurer
		,IsInsuranceCertificateRequired
		,IsPublic
		,Comments
		,TagList
		,IsActive
		,IsAdminReviewRequired
		,LastVerifiedTime
		,ChangeLog
		,UserDefinedColumns
		,OrgXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	dbo.Org

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
	if @errorMessageSCD is null and @EmailAddress is not null and sf.fIsValidEmail(@EmailAddress) = @OFF					-- call framework function to check email address
	begin
		set @errorMessageSCD    = 'MBR.InvalidEmailAddress.EmailAddress'
		set @columnNames        = N'EmailAddress'
		
		set @defaultMessageText = N'The email address is not a valid format. Ensure the address does not contain spaces.'
		                        + 'An "@" sign must separate the username and the domain. Example: john.doe@softworksgroup.com"'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.City x where x.CitySID = @CitySID) = @OFF												-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.CitySID'
			set @columnNames        = N'CitySID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'city'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Org x where x.OrgSID = @InsuranceOrgSID) = @OFF									-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.InsuranceOrgSID'
			set @columnNames        = N'InsuranceOrgSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'insurance org'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.OrgType x where x.OrgTypeSID = @OrgTypeSID) = @OFF								-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.OrgTypeSID'
			set @columnNames        = N'OrgTypeSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'org type'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Org x where x.OrgSID = @ParentOrgSID) = @OFF											-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ParentOrgSID'
			set @columnNames        = N'ParentOrgSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'parent org'
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
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.EmailAddress') = @ON and @EmailAddress is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.EmailAddress'
		set @columnNames        = N'EmailAddress'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Email Address'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.Fax') = @ON and @Fax is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.Fax'
		set @columnNames        = N'Fax'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Fax'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.InsuranceAmount') = @ON and @InsuranceAmount is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.InsuranceAmount'
		set @columnNames        = N'InsuranceAmount'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Insurance Amount'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.InsuranceOrgSID') = @ON and @InsuranceOrgSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.InsuranceOrgSID'
		set @columnNames        = N'InsuranceOrgSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Insurance Org'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.InsurancePolicyNo') = @ON and @InsurancePolicyNo is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.InsurancePolicyNo'
		set @columnNames        = N'InsurancePolicyNo'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Insurance Policy No'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.IsPublic') = @ON and @IsPublic is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.IsPublic'
		set @columnNames        = N'IsPublic'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Is Public'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.LastVerifiedTime') = @ON and @LastVerifiedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.LastVerifiedTime'
		set @columnNames        = N'LastVerifiedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Last Verified Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.ParentOrgSID') = @ON and @ParentOrgSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ParentOrgSID'
		set @columnNames        = N'ParentOrgSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Parent Org'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.Phone') = @ON and @Phone is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.Phone'
		set @columnNames        = N'Phone'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Phone'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.StreetAddress2') = @ON and @StreetAddress2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress2'
		set @columnNames        = N'StreetAddress2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.StreetAddress3') = @ON and @StreetAddress3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress3'
		set @columnNames        = N'StreetAddress3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','ValueIsRequired.WebSite') = @ON and @WebSite is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.WebSite'
		set @columnNames        = N'WebSite'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Web Site'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2017" Updates="None">
	if @errorMessageSCD is null and @Phone is not null
	begin
		if exists
		(
			select
				1
			from
				dbo.Org						o
			join
				dbo.City					c on o.CitySID					 = c.CitySID
			join
				dbo.StateProvince sp on c.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country				ctry on sp.CountrySID		 = ctry.CountrySID and ctry.IsDefault = @ON
			where
				o.OrgSID = @OrgSID
		)	 and sf.fIsValidPhone(@Phone) = @OFF -- see framework function for validation details
		begin
			set @errorMessageSCD = 'MBR.InvalidPhone.Phone';
			set @columnNames = N'Phone';
			set @defaultMessageText
				= N'The phone number is not valid.  Numbers must include the area code. International numbers must start with "011" and include a country code.';
		end;	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2017" Updates="None">
	if @errorMessageSCD is null and @Fax is not null
	begin
		if exists
		(
			select
				1
			from
				dbo.Org						o
			join
				dbo.City					c on o.CitySID					 = c.CitySID
			join
				dbo.StateProvince sp on c.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country				ctry on sp.CountrySID		 = ctry.CountrySID and ctry.IsDefault = @ON
			where
				o.OrgSID = @OrgSID
		)	 and sf.fIsValidPhone(@Fax) = @OFF -- see framework function for validation details
		begin
			set @errorMessageSCD = 'MBR.InvalidPhone.Fax';			set @columnNames = N'Fax';
			set @defaultMessageText
				= N'The phone number is not valid.  Numbers must include the area code. International numbers must start with "011" and include a country code.';
		end;
	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2017" Updates="None">
	if @errorMessageSCD is null and @PostalCode is not null
	begin
		if exists
		(
			select
				1
			from
				dbo.Org						o
			join
				dbo.City					c on o.CitySID					 = c.CitySID
			join
				dbo.StateProvince sp on c.StateProvinceSID = sp.StateProvinceSID
			join
				dbo.Country				ctry on sp.CountrySID		 = ctry.CountrySID and ctry.IsDefault = @ON
			where
				o.OrgSID = @OrgSID
		)	 and sf.fIsValidPostalCode(@PostalCode) = @OFF -- see framework function for validation details
		begin
			set @errorMessageSCD = 'MBR.InvalidPostalCode.PostalCode';
			set @columnNames = N'PostalCode';
			set @defaultMessageText = N'The postal code is not a valid format.';
		end;
	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jul 2017" Updates="None">
	if @IsEmployer = @OFF
	begin

		select @arg1 = ltrim(count(1)) from dbo.RegistrantEmployment re where re.OrgSID = @OrgSID

		if @arg1 > N'0'
		begin
			set @errorMessageSCD      = 'EmployerAssignmentsExist.IsEmployer'
			set @columnNames          = N'IsEmployer'
			set @defaultMessageText   = N'This organization is referenced in %1 registrant employment records and so cannot be un-marked as an employer. To exclude the organization from being assigned going forward, mark the record in-active.'
		end

	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jul 2017" Updates="None">
	if @IsCredentialAuthority = @OFF
	begin

		select @arg1 = ltrim(count(1)) from dbo.RegistrantCredential rc where rc.OrgSID = @OrgSID

		if @arg1 > N'0'
		begin
			set @errorMessageSCD      = 'CredentialAssignmentsExist.IsCredentialAuthority'
			set @columnNames          = N'IsCredentialAuthority'
			set @defaultMessageText   = N'This organization is referenced in %1 records as a credential authority. It cannot be un-marked as a credential authority. To exclude the organization from being assigned going forward, mark the record in-active.'
		end

	end
	--!</Rule>
	
	--!<Rule Author="Taylor Napier | March 2019" Updates="None">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','DuplicateOrgAddress.StreetAddress1') = 1	-- check if rule is ON - REMOVE for mandatory rules
	begin
	
		set @arg1 = null

		select
			@arg1 = og.OrgName
		from
			dbo.Org og
		where
			og.OrgSID <> isnull(@OrgSID, -1)
		and
			og.StreetAddress1 = @StreetAddress1
		and
			og.PostalCode = @PostalCode
		and
			@PostalCode <> 'X0X 0X0' --ignore conversion/placeholder addresses

		if @arg1 is not null
		begin
			set @errorMessageSCD      = 'DuplicateOrgAddress.StreetAddress1'
			set @columnNames          = N'StreetAddress1'
			set @defaultMessageText   = N'This address is already in use by the "%1" organization. Please set a unique address, or update the previously mentioned organization.'
		end

	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Mar 2019" Updates="None">
	if @errorMessageSCD is null and @InsurancePolicyNo is not null and @InsuranceOrgSID is null
	begin
		set @errorMessageSCD = 'MBR.RequiredWhen.InsuranceOrgSID';
		set @columnNames = N'InsurancePolicyNo, InsuranceOrgSID';
		set @defaultMessageText = N'A(n) % must be provided when a(n) %2 is filled in.';
		set @arg1 = N'Insurance Provider Name';
		set @arg2 = N'Policy#';
	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Mar 2019" Updates="None">
	if @errorMessageSCD is null and @InsurancePolicyNo is null and @InsuranceOrgSID is not null
	begin
		set @errorMessageSCD = 'MBR.RequiredWhen.InsurancePolicyNo';
		set @columnNames = N'InsurancePolicyNo, InsuranceOrgSID';
		set @defaultMessageText = N'A(n) % must be provided when a(n) %2 is filled in.';
		set @arg1 = N'Policy#';
		set @arg2 = N'Insurance Provider Name';
	end
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'dbo',N'Org','?SomeMessageCode.ColumnName') = 1	-- check if rule is ON - REMOVE for mandatory rules
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
				r.RoutineName = 'fOrg#Check'
		)
		begin
		
			select @errorText = ext.fOrg#Check
				(
				 @OrgSID
				,@ParentOrgSID
				,@OrgTypeSID
				,@OrgName
				,@OrgLabel
				,@StreetAddress1
				,@StreetAddress2
				,@StreetAddress3
				,@CitySID
				,@PostalCode
				,@RegionSID
				,@Phone
				,@Fax
				,@WebSite
				,@EmailAddress
				,@InsuranceOrgSID
				,@InsurancePolicyNo
				,@InsuranceAmount
				,@IsEmployer
				,@IsCredentialAuthority
				,@IsInsurer
				,@IsInsuranceCertificateRequired
				,@IsPublic
				,@IsActive
				,@IsAdminReviewRequired
				,@LastVerifiedTime
				,@OrgXID
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
			,@OrgSID
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