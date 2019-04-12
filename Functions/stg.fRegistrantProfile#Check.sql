SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [stg].[fRegistrantProfile#Check]
	(
	 @RegistrantProfileSID            int
	,@ImportFileSID                   int
	,@ProcessingStatusSID             int
	,@LastName                        nvarchar(35)
	,@FirstName                       nvarchar(30)
	,@CommonName                      nvarchar(30)
	,@MiddleNames                     nvarchar(30)
	,@EmailAddress                    varchar(150)
	,@HomePhone                       varchar(25)
	,@MobilePhone                     varchar(25)
	,@IsTextMessagingEnabled          bit
	,@GenderLabel                     nvarchar(35)
	,@NamePrefixLabel                 nvarchar(35)
	,@BirthDate                       date
	,@DeathDate                       date
	,@UserName                        nvarchar(75)
	,@SubDomain                       varchar(63)
	,@Password                        nvarchar(50)
	,@StreetAddress1                  nvarchar(75)
	,@StreetAddress2                  nvarchar(75)
	,@StreetAddress3                  nvarchar(75)
	,@CityName                        nvarchar(30)
	,@StateProvinceName               nvarchar(30)
	,@PostalCode                      varchar(10)
	,@CountryName                     nvarchar(50)
	,@RegionLabel                     nvarchar(35)
	,@RegistrantNo                    varchar(50)
	,@PersonGroupLabel1               nvarchar(35)
	,@PersonGroupTitle1               nvarchar(75)
	,@PersonGroupIsAdministrator1     bit
	,@PersonGroupEffectiveDate1       date
	,@PersonGroupExpiryDate1          date
	,@PersonGroupLabel2               nvarchar(35)
	,@PersonGroupTitle2               nvarchar(75)
	,@PersonGroupIsAdministrator2     bit
	,@PersonGroupEffectiveDate2       date
	,@PersonGroupExpiryDate2          date
	,@PersonGroupLabel3               nvarchar(35)
	,@PersonGroupTitle3               nvarchar(75)
	,@PersonGroupIsAdministrator3     bit
	,@PersonGroupEffectiveDate3       date
	,@PersonGroupExpiryDate3          date
	,@PersonGroupLabel4               nvarchar(35)
	,@PersonGroupTitle4               nvarchar(75)
	,@PersonGroupIsAdministrator4     bit
	,@PersonGroupEffectiveDate4       date
	,@PersonGroupExpiryDate4          date
	,@PersonGroupLabel5               nvarchar(35)
	,@PersonGroupTitle5               nvarchar(75)
	,@PersonGroupIsAdministrator5     bit
	,@PersonGroupEffectiveDate5       date
	,@PersonGroupExpiryDate5          date
	,@PracticeRegisterLabel           nvarchar(35)
	,@PracticeRegisterSectionLabel    nvarchar(35)
	,@RegistrationEffectiveDate       date
	,@QualifyingCredentialLabel       nvarchar(35)
	,@QualifyingCredentialOrgLabel    nvarchar(35)
	,@QualifyingProgramName           nvarchar(65)
	,@QualifyingProgramStartDate      date
	,@QualifyingProgramCompletionDate date
	,@QualifyingFieldOfStudyName      nvarchar(50)
	,@CredentialLabel1                nvarchar(35)
	,@CredentialOrgLabel1             nvarchar(35)
	,@CredentialProgramName1          nvarchar(65)
	,@CredentialFieldOfStudyName1     nvarchar(50)
	,@CredentialEffectiveDate1        date
	,@CredentialExpiryDate1           date
	,@CredentialLabel2                nvarchar(35)
	,@CredentialOrgLabel2             nvarchar(35)
	,@CredentialProgramName2          nvarchar(65)
	,@CredentialFieldOfStudyName2     nvarchar(50)
	,@CredentialEffectiveDate2        date
	,@CredentialExpiryDate2           date
	,@CredentialLabel3                nvarchar(35)
	,@CredentialOrgLabel3             nvarchar(35)
	,@CredentialProgramName3          nvarchar(65)
	,@CredentialFieldOfStudyName3     nvarchar(50)
	,@CredentialEffectiveDate3        date
	,@CredentialExpiryDate3           date
	,@CredentialLabel4                nvarchar(35)
	,@CredentialOrgLabel4             nvarchar(35)
	,@CredentialProgramName4          nvarchar(65)
	,@CredentialFieldOfStudyName4     nvarchar(50)
	,@CredentialEffectiveDate4        date
	,@CredentialExpiryDate4           date
	,@CredentialLabel5                nvarchar(35)
	,@CredentialOrgLabel5             nvarchar(35)
	,@CredentialProgramName5          nvarchar(65)
	,@CredentialFieldOfStudyName5     nvarchar(50)
	,@CredentialEffectiveDate5        date
	,@CredentialExpiryDate5           date
	,@CredentialLabel6                nvarchar(35)
	,@CredentialOrgLabel6             nvarchar(35)
	,@CredentialProgramName6          nvarchar(65)
	,@CredentialFieldOfStudyName6     nvarchar(50)
	,@CredentialEffectiveDate6        date
	,@CredentialExpiryDate6           date
	,@CredentialLabel7                nvarchar(35)
	,@CredentialOrgLabel7             nvarchar(35)
	,@CredentialProgramName7          nvarchar(65)
	,@CredentialFieldOfStudyName7     nvarchar(50)
	,@CredentialEffectiveDate7        date
	,@CredentialExpiryDate7           date
	,@CredentialLabel8                nvarchar(35)
	,@CredentialOrgLabel8             nvarchar(35)
	,@CredentialProgramName8          nvarchar(65)
	,@CredentialFieldOfStudyName8     nvarchar(50)
	,@CredentialEffectiveDate8        date
	,@CredentialExpiryDate8           date
	,@CredentialLabel9                nvarchar(35)
	,@CredentialOrgLabel9             nvarchar(35)
	,@CredentialProgramName9          nvarchar(65)
	,@CredentialFieldOfStudyName9     nvarchar(50)
	,@CredentialEffectiveDate9        date
	,@CredentialExpiryDate9           date
	,@PersonSID                       int
	,@PersonEmailAddressSID           int
	,@ApplicationUserSID              int
	,@PersonMailingAddressSID         int
	,@RegionSID                       int
	,@NamePrefixSID                   int
	,@GenderSID                       int
	,@CitySID                         int
	,@StateProvinceSID                int
	,@CountrySID                      int
	,@RegistrantSID                   int
	,@RegistrantProfileXID            varchar(150)
	,@LegacyKey                       nvarchar(50)
	,@IsDeleted                       bit
	,@CreateUser                      nvarchar(75)
	,@CreateTime                      datetimeoffset(7)
	,@UpdateUser                      nvarchar(75)
	,@UpdateTime                      datetimeoffset(7)
	,@RowGUID                         uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : stg.fRegistrantProfile#Check
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
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.PersonEmailAddressSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ProcessingStatusSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.ApplicationUserSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.BirthDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CityName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CitySID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CommonName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CountryName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CountrySID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate6 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate7 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate8 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialEffectiveDate9 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate6 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate7 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate8 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialExpiryDate9 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName6 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName7 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName8 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialFieldOfStudyName9 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel6 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel7 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel8 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialLabel9 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel6 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel7 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel8 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialOrgLabel9 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName6 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName7 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName8 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CredentialProgramName9 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.DeathDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.EmailAddress A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.FirstName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.GenderLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.GenderSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.HomePhone A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.IsTextMessagingEnabled A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.LastName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MiddleNames A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MobilePhone A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.NamePrefixLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.NamePrefixSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.Password A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonEmailAddressSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupEffectiveDate1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupEffectiveDate2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupEffectiveDate3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupEffectiveDate4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupEffectiveDate5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupExpiryDate1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupExpiryDate2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupExpiryDate3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupExpiryDate4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupExpiryDate5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupIsAdministrator1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupIsAdministrator2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupIsAdministrator3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupIsAdministrator4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupIsAdministrator5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupLabel1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupLabel2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupLabel3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupLabel4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupLabel5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupTitle1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupTitle2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupTitle3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupTitle4 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonGroupTitle5 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonMailingAddressSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PersonSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PostalCode A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PracticeRegisterLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PracticeRegisterSectionLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QualifyingCredentialLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QualifyingCredentialOrgLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QualifyingFieldOfStudyName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QualifyingProgramCompletionDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QualifyingProgramName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QualifyingProgramStartDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegionLabel A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegionSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegistrantNo A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegistrantSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.RegistrationEffectiveDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StateProvinceName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StateProvinceSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress1 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress2 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.StreetAddress3 A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.SubDomain A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.UserName A value for "%1" is required.
$AutoRules | Tim Edlund        BackDatingLimit.RegistrationEffectiveDate The "%1" cannot be backdated. The backdating limit set is

Example
-------

select
	 RegistrantProfileSID
	,LastName
	,FirstName
	,CommonName
	,MiddleNames
	,stg.fRegistrantProfile#Check
		(
		 RegistrantProfileSID
		,ImportFileSID
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
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	stg.RegistrantProfile

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
	if @errorMessageSCD is null and @EmailAddress is not null and sf.fIsValidEmail(@EmailAddress) = @OFF												-- call framework function to check email address
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
		if (select x.IsActive from sf.PersonEmailAddress x where x.PersonEmailAddressSID = @PersonEmailAddressSID) = @OFF					-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.PersonEmailAddressSID'
			set @columnNames        = N'PersonEmailAddressSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'person email address'
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
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.ApplicationUserSID') = @ON and @ApplicationUserSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ApplicationUserSID'
		set @columnNames        = N'ApplicationUserSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Application User'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.BirthDate') = @ON and @BirthDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.BirthDate'
		set @columnNames        = N'BirthDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Birth Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CityName') = @ON and @CityName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CityName'
		set @columnNames        = N'CityName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'City Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CitySID') = @ON and @CitySID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CitySID'
		set @columnNames        = N'CitySID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'City'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CommonName') = @ON and @CommonName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CommonName'
		set @columnNames        = N'CommonName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Common Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CountryName') = @ON and @CountryName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CountryName'
		set @columnNames        = N'CountryName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Country Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CountrySID') = @ON and @CountrySID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CountrySID'
		set @columnNames        = N'CountrySID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Country'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate1') = @ON and @CredentialEffectiveDate1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate1'
		set @columnNames        = N'CredentialEffectiveDate1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate2') = @ON and @CredentialEffectiveDate2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate2'
		set @columnNames        = N'CredentialEffectiveDate2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate3') = @ON and @CredentialEffectiveDate3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate3'
		set @columnNames        = N'CredentialEffectiveDate3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate4') = @ON and @CredentialEffectiveDate4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate4'
		set @columnNames        = N'CredentialEffectiveDate4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate5') = @ON and @CredentialEffectiveDate5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate5'
		set @columnNames        = N'CredentialEffectiveDate5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate6') = @ON and @CredentialEffectiveDate6 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate6'
		set @columnNames        = N'CredentialEffectiveDate6'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 6'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate7') = @ON and @CredentialEffectiveDate7 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate7'
		set @columnNames        = N'CredentialEffectiveDate7'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 7'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate8') = @ON and @CredentialEffectiveDate8 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate8'
		set @columnNames        = N'CredentialEffectiveDate8'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 8'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialEffectiveDate9') = @ON and @CredentialEffectiveDate9 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialEffectiveDate9'
		set @columnNames        = N'CredentialEffectiveDate9'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Effective Date 9'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate1') = @ON and @CredentialExpiryDate1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate1'
		set @columnNames        = N'CredentialExpiryDate1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate2') = @ON and @CredentialExpiryDate2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate2'
		set @columnNames        = N'CredentialExpiryDate2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate3') = @ON and @CredentialExpiryDate3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate3'
		set @columnNames        = N'CredentialExpiryDate3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate4') = @ON and @CredentialExpiryDate4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate4'
		set @columnNames        = N'CredentialExpiryDate4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate5') = @ON and @CredentialExpiryDate5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate5'
		set @columnNames        = N'CredentialExpiryDate5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate6') = @ON and @CredentialExpiryDate6 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate6'
		set @columnNames        = N'CredentialExpiryDate6'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 6'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate7') = @ON and @CredentialExpiryDate7 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate7'
		set @columnNames        = N'CredentialExpiryDate7'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 7'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate8') = @ON and @CredentialExpiryDate8 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate8'
		set @columnNames        = N'CredentialExpiryDate8'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 8'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialExpiryDate9') = @ON and @CredentialExpiryDate9 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialExpiryDate9'
		set @columnNames        = N'CredentialExpiryDate9'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Expiry Date 9'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName1') = @ON and @CredentialFieldOfStudyName1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName1'
		set @columnNames        = N'CredentialFieldOfStudyName1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName2') = @ON and @CredentialFieldOfStudyName2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName2'
		set @columnNames        = N'CredentialFieldOfStudyName2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName3') = @ON and @CredentialFieldOfStudyName3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName3'
		set @columnNames        = N'CredentialFieldOfStudyName3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName4') = @ON and @CredentialFieldOfStudyName4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName4'
		set @columnNames        = N'CredentialFieldOfStudyName4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName5') = @ON and @CredentialFieldOfStudyName5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName5'
		set @columnNames        = N'CredentialFieldOfStudyName5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName6') = @ON and @CredentialFieldOfStudyName6 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName6'
		set @columnNames        = N'CredentialFieldOfStudyName6'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 6'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName7') = @ON and @CredentialFieldOfStudyName7 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName7'
		set @columnNames        = N'CredentialFieldOfStudyName7'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 7'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName8') = @ON and @CredentialFieldOfStudyName8 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName8'
		set @columnNames        = N'CredentialFieldOfStudyName8'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 8'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialFieldOfStudyName9') = @ON and @CredentialFieldOfStudyName9 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialFieldOfStudyName9'
		set @columnNames        = N'CredentialFieldOfStudyName9'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Field Of Study Name 9'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel1') = @ON and @CredentialLabel1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel1'
		set @columnNames        = N'CredentialLabel1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel2') = @ON and @CredentialLabel2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel2'
		set @columnNames        = N'CredentialLabel2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel3') = @ON and @CredentialLabel3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel3'
		set @columnNames        = N'CredentialLabel3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel4') = @ON and @CredentialLabel4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel4'
		set @columnNames        = N'CredentialLabel4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel5') = @ON and @CredentialLabel5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel5'
		set @columnNames        = N'CredentialLabel5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel6') = @ON and @CredentialLabel6 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel6'
		set @columnNames        = N'CredentialLabel6'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 6'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel7') = @ON and @CredentialLabel7 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel7'
		set @columnNames        = N'CredentialLabel7'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 7'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel8') = @ON and @CredentialLabel8 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel8'
		set @columnNames        = N'CredentialLabel8'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 8'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialLabel9') = @ON and @CredentialLabel9 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialLabel9'
		set @columnNames        = N'CredentialLabel9'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Label 9'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel1') = @ON and @CredentialOrgLabel1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel1'
		set @columnNames        = N'CredentialOrgLabel1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel2') = @ON and @CredentialOrgLabel2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel2'
		set @columnNames        = N'CredentialOrgLabel2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel3') = @ON and @CredentialOrgLabel3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel3'
		set @columnNames        = N'CredentialOrgLabel3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel4') = @ON and @CredentialOrgLabel4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel4'
		set @columnNames        = N'CredentialOrgLabel4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel5') = @ON and @CredentialOrgLabel5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel5'
		set @columnNames        = N'CredentialOrgLabel5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel6') = @ON and @CredentialOrgLabel6 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel6'
		set @columnNames        = N'CredentialOrgLabel6'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 6'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel7') = @ON and @CredentialOrgLabel7 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel7'
		set @columnNames        = N'CredentialOrgLabel7'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 7'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel8') = @ON and @CredentialOrgLabel8 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel8'
		set @columnNames        = N'CredentialOrgLabel8'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 8'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialOrgLabel9') = @ON and @CredentialOrgLabel9 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialOrgLabel9'
		set @columnNames        = N'CredentialOrgLabel9'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Org Label 9'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName1') = @ON and @CredentialProgramName1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName1'
		set @columnNames        = N'CredentialProgramName1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName2') = @ON and @CredentialProgramName2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName2'
		set @columnNames        = N'CredentialProgramName2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName3') = @ON and @CredentialProgramName3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName3'
		set @columnNames        = N'CredentialProgramName3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName4') = @ON and @CredentialProgramName4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName4'
		set @columnNames        = N'CredentialProgramName4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName5') = @ON and @CredentialProgramName5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName5'
		set @columnNames        = N'CredentialProgramName5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName6') = @ON and @CredentialProgramName6 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName6'
		set @columnNames        = N'CredentialProgramName6'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 6'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName7') = @ON and @CredentialProgramName7 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName7'
		set @columnNames        = N'CredentialProgramName7'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 7'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName8') = @ON and @CredentialProgramName8 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName8'
		set @columnNames        = N'CredentialProgramName8'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 8'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.CredentialProgramName9') = @ON and @CredentialProgramName9 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CredentialProgramName9'
		set @columnNames        = N'CredentialProgramName9'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Credential Program Name 9'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.DeathDate') = @ON and @DeathDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.DeathDate'
		set @columnNames        = N'DeathDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Death Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.EmailAddress') = @ON and @EmailAddress is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.EmailAddress'
		set @columnNames        = N'EmailAddress'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Email Address'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.FirstName') = @ON and @FirstName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.FirstName'
		set @columnNames        = N'FirstName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'First Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.GenderLabel') = @ON and @GenderLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.GenderLabel'
		set @columnNames        = N'GenderLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Gender Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.GenderSID') = @ON and @GenderSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.GenderSID'
		set @columnNames        = N'GenderSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Gender'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.HomePhone') = @ON and @HomePhone is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.HomePhone'
		set @columnNames        = N'HomePhone'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Home Phone'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.IsTextMessagingEnabled') = @ON and @IsTextMessagingEnabled is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.IsTextMessagingEnabled'
		set @columnNames        = N'IsTextMessagingEnabled'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Is Text Messaging Enabled'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.LastName') = @ON and @LastName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.LastName'
		set @columnNames        = N'LastName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Last Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.MiddleNames') = @ON and @MiddleNames is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MiddleNames'
		set @columnNames        = N'MiddleNames'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Middle Names'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.MobilePhone') = @ON and @MobilePhone is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MobilePhone'
		set @columnNames        = N'MobilePhone'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Mobile Phone'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.NamePrefixLabel') = @ON and @NamePrefixLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.NamePrefixLabel'
		set @columnNames        = N'NamePrefixLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Name Prefix Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.NamePrefixSID') = @ON and @NamePrefixSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.NamePrefixSID'
		set @columnNames        = N'NamePrefixSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Name Prefix'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.Password') = @ON and @Password is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.Password'
		set @columnNames        = N'Password'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Password'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonEmailAddressSID') = @ON and @PersonEmailAddressSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonEmailAddressSID'
		set @columnNames        = N'PersonEmailAddressSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Email Address'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupEffectiveDate1') = @ON and @PersonGroupEffectiveDate1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupEffectiveDate1'
		set @columnNames        = N'PersonGroupEffectiveDate1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Effective Date 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupEffectiveDate2') = @ON and @PersonGroupEffectiveDate2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupEffectiveDate2'
		set @columnNames        = N'PersonGroupEffectiveDate2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Effective Date 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupEffectiveDate3') = @ON and @PersonGroupEffectiveDate3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupEffectiveDate3'
		set @columnNames        = N'PersonGroupEffectiveDate3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Effective Date 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupEffectiveDate4') = @ON and @PersonGroupEffectiveDate4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupEffectiveDate4'
		set @columnNames        = N'PersonGroupEffectiveDate4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Effective Date 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupEffectiveDate5') = @ON and @PersonGroupEffectiveDate5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupEffectiveDate5'
		set @columnNames        = N'PersonGroupEffectiveDate5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Effective Date 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupExpiryDate1') = @ON and @PersonGroupExpiryDate1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupExpiryDate1'
		set @columnNames        = N'PersonGroupExpiryDate1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Expiry Date 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupExpiryDate2') = @ON and @PersonGroupExpiryDate2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupExpiryDate2'
		set @columnNames        = N'PersonGroupExpiryDate2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Expiry Date 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupExpiryDate3') = @ON and @PersonGroupExpiryDate3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupExpiryDate3'
		set @columnNames        = N'PersonGroupExpiryDate3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Expiry Date 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupExpiryDate4') = @ON and @PersonGroupExpiryDate4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupExpiryDate4'
		set @columnNames        = N'PersonGroupExpiryDate4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Expiry Date 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupExpiryDate5') = @ON and @PersonGroupExpiryDate5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupExpiryDate5'
		set @columnNames        = N'PersonGroupExpiryDate5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Expiry Date 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupIsAdministrator1') = @ON and @PersonGroupIsAdministrator1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupIsAdministrator1'
		set @columnNames        = N'PersonGroupIsAdministrator1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Is Administrator 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupIsAdministrator2') = @ON and @PersonGroupIsAdministrator2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupIsAdministrator2'
		set @columnNames        = N'PersonGroupIsAdministrator2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Is Administrator 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupIsAdministrator3') = @ON and @PersonGroupIsAdministrator3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupIsAdministrator3'
		set @columnNames        = N'PersonGroupIsAdministrator3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Is Administrator 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupIsAdministrator4') = @ON and @PersonGroupIsAdministrator4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupIsAdministrator4'
		set @columnNames        = N'PersonGroupIsAdministrator4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Is Administrator 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupIsAdministrator5') = @ON and @PersonGroupIsAdministrator5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupIsAdministrator5'
		set @columnNames        = N'PersonGroupIsAdministrator5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Is Administrator 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupLabel1') = @ON and @PersonGroupLabel1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupLabel1'
		set @columnNames        = N'PersonGroupLabel1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Label 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupLabel2') = @ON and @PersonGroupLabel2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupLabel2'
		set @columnNames        = N'PersonGroupLabel2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Label 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupLabel3') = @ON and @PersonGroupLabel3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupLabel3'
		set @columnNames        = N'PersonGroupLabel3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Label 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupLabel4') = @ON and @PersonGroupLabel4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupLabel4'
		set @columnNames        = N'PersonGroupLabel4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Label 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupLabel5') = @ON and @PersonGroupLabel5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupLabel5'
		set @columnNames        = N'PersonGroupLabel5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Label 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupTitle1') = @ON and @PersonGroupTitle1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupTitle1'
		set @columnNames        = N'PersonGroupTitle1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Title 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupTitle2') = @ON and @PersonGroupTitle2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupTitle2'
		set @columnNames        = N'PersonGroupTitle2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Title 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupTitle3') = @ON and @PersonGroupTitle3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupTitle3'
		set @columnNames        = N'PersonGroupTitle3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Title 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupTitle4') = @ON and @PersonGroupTitle4 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupTitle4'
		set @columnNames        = N'PersonGroupTitle4'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Title 4'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonGroupTitle5') = @ON and @PersonGroupTitle5 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonGroupTitle5'
		set @columnNames        = N'PersonGroupTitle5'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Group Title 5'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonMailingAddressSID') = @ON and @PersonMailingAddressSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonMailingAddressSID'
		set @columnNames        = N'PersonMailingAddressSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person Mailing Address'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PersonSID') = @ON and @PersonSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PersonSID'
		set @columnNames        = N'PersonSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Person'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PostalCode') = @ON and @PostalCode is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PostalCode'
		set @columnNames        = N'PostalCode'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Postal Code'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PracticeRegisterLabel') = @ON and @PracticeRegisterLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PracticeRegisterLabel'
		set @columnNames        = N'PracticeRegisterLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Practice Register Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.PracticeRegisterSectionLabel') = @ON and @PracticeRegisterSectionLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PracticeRegisterSectionLabel'
		set @columnNames        = N'PracticeRegisterSectionLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Practice Register Section Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.QualifyingCredentialLabel') = @ON and @QualifyingCredentialLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QualifyingCredentialLabel'
		set @columnNames        = N'QualifyingCredentialLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Qualifying Credential Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.QualifyingCredentialOrgLabel') = @ON and @QualifyingCredentialOrgLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QualifyingCredentialOrgLabel'
		set @columnNames        = N'QualifyingCredentialOrgLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Qualifying Credential Org Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.QualifyingFieldOfStudyName') = @ON and @QualifyingFieldOfStudyName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QualifyingFieldOfStudyName'
		set @columnNames        = N'QualifyingFieldOfStudyName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Qualifying Field Of Study Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.QualifyingProgramCompletionDate') = @ON and @QualifyingProgramCompletionDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QualifyingProgramCompletionDate'
		set @columnNames        = N'QualifyingProgramCompletionDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Qualifying Program Completion Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.QualifyingProgramName') = @ON and @QualifyingProgramName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QualifyingProgramName'
		set @columnNames        = N'QualifyingProgramName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Qualifying Program Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.QualifyingProgramStartDate') = @ON and @QualifyingProgramStartDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QualifyingProgramStartDate'
		set @columnNames        = N'QualifyingProgramStartDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Qualifying Program Start Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.RegionLabel') = @ON and @RegionLabel is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegionLabel'
		set @columnNames        = N'RegionLabel'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Region Label'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.RegionSID') = @ON and @RegionSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegionSID'
		set @columnNames        = N'RegionSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Region'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.RegistrantNo') = @ON and @RegistrantNo is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegistrantNo'
		set @columnNames        = N'RegistrantNo'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Registrant No'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.RegistrantSID') = @ON and @RegistrantSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegistrantSID'
		set @columnNames        = N'RegistrantSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Registrant'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.RegistrationEffectiveDate') = @ON and @RegistrationEffectiveDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.RegistrationEffectiveDate'
		set @columnNames        = N'RegistrationEffectiveDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Registration Effective Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.StateProvinceName') = @ON and @StateProvinceName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StateProvinceName'
		set @columnNames        = N'StateProvinceName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'State Province Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.StateProvinceSID') = @ON and @StateProvinceSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StateProvinceSID'
		set @columnNames        = N'StateProvinceSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'State Province'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.StreetAddress1') = @ON and @StreetAddress1 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress1'
		set @columnNames        = N'StreetAddress1'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 1'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.StreetAddress2') = @ON and @StreetAddress2 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress2'
		set @columnNames        = N'StreetAddress2'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 2'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.StreetAddress3') = @ON and @StreetAddress3 is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.StreetAddress3'
		set @columnNames        = N'StreetAddress3'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Street Address 3'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.SubDomain') = @ON and @SubDomain is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.SubDomain'
		set @columnNames        = N'SubDomain'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Sub Domain'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','ValueIsRequired.UserName') = @ON and @UserName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.UserName'
		set @columnNames        = N'UserName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'User Name'
	end
	--!</Rule>
	
	declare @backDateLimit  smallint
	set @backDateLimit = isnull(convert(smallint, sf.fConfigParam#Value('BackDatingLimit')), 0)				-- get limit (days) from configuration or default to 0
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','BackDatingLimit.RegistrationEffectiveDate') = @ON
	and datediff(day, @RegistrationEffectiveDate, sf.fDTOffsetToClientDate(@CreateTime)) > @backDateLimit
	begin
		set @errorMessageSCD    = 'BackDatingLimit.RegistrationEffectiveDate'
		set @columnNames        = N'RegistrationEffectiveDate'
		set @defaultMessageText = N'The "%1" cannot be backdated. The backdating limit set is %2 day(s).'
		set @arg1               = N'Registration Effective Date'
		set @arg2               = cast(@backDateLimit as nvarchar(10))
	end
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'stg',N'RegistrantProfile','?SomeMessageCode.ColumnName') = 1	-- check if rule is ON - REMOVE for mandatory rules
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
				r.RoutineName = 'stg#fRegistrantProfile#Check'
		)
		begin
		
			select @errorText = ext.stg#fRegistrantProfile#Check
				(
				 @RegistrantProfileSID
				,@ImportFileSID
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
				,@RegistrantProfileXID
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
			,@RegistrantProfileSID
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
