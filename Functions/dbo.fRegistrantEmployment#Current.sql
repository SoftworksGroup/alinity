SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantEmployment#Current
(
	@PersonSID int	-- key of person to return current employment for
)
returns @currentEmployment table
(
	RecordNo								int						not null
 ,OrgSID									int						not null
 ,OrgName									nvarchar(150) not null
 ,OrgLabel								nvarchar(35)	not null
 ,OrgTypeName							nvarchar(50)	not null
 ,RegionName							nvarchar(50)	not null
 ,RegistrantEmploymentSID int						not null
 ,EmploymentTypeSID				int						not null
 ,EmploymentRoleSID				int						not null
 ,PracticeScopeSID				int						not null
 ,PracticeAreaSID					int						null
 ,AgeRangeSID							int						not null
 ,PracticeHours						int						not null
 ,IsActiveEmployer				bit						not null
 ,IsOnPublicRegistry			bit						not null
 ,Phone										varchar(25)		null
 ,IsEmployerInsurance			bit						null
 ,InsuranceOrgSID					int						null
 ,InsurancePolicyNo				nvarchar(25)	null
 ,InsuranceAmount					decimal(11,2) null
 ,SiteLocation						nvarchar(50)	null
 ,RegistrantEmploymentXID nvarchar(150) null
)
/*********************************************************************************************************************************
Function	: Registrant Employment - Current 
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns current employers for 1 person, for editing or display
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This table function modularizes the logic required to return current employers for editing or display. The function requires that a 
@PersonSID be identified to return records for. The function is called by the Renewal and Profile Update processes to return records 
for editing.  

Definition of "Current"
----------------------
The function returns the employment record if it was reported in the current registration year, or the previous registration
year. For the previous registration year only, the record must have at least 1 practice-hour reported. Having at least one
practice hour is not required for employment records in the current registration year since these records may be added on
Profile Update forms where hours are not reported.

If No Hours are Reported on Renewal
-----------------------------------
If the client renewal form configuration does not include practice hours, a check-box should be configured on the form where the 
member confirms that they worked for that employer in the year, or a confirmation that they didn't work for the employer.  The 
action of the check box should be to set the Practice-Hours column to 1 (worked for) or 0 (did not work for) and the system
can use those values for selection going forward.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Calls the function for a person at random with qualifying data.">
		<SQLScript>
			<![CDATA[
declare
	@personSID	 int
 ,@currentYear smallint = dbo.fRegistrationYear#Current();

select top (1)
	@personSID = r.PersonSID
from
	dbo.Registrant					 r
join
	dbo.RegistrantEmployment re on r.RegistrantSID = re.RegistrantSID
where
	re.RegistrationYear		= @currentYear -- in the current registration year
	or
	(
		re.RegistrationYear = (@currentYear - 1) and re.PracticeHours > 0 -- or in the previous year where they confirmed employment (1 hour or more)
	)
order by
	newid();

if @@rowcount = 0 or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		rec.RecordNo
	 ,rec.OrgSID
	 ,rec.OrgName
	 ,rec.OrgLabel
	 ,rec.OrgTypeName
	 ,rec.RegionName
	 ,rec.RegistrantEmploymentSID
	 ,rec.EmploymentTypeSID
	 ,rec.EmploymentRoleSID
	 ,rec.PracticeScopeSID
	 ,rec.PracticeAreaSID
	 ,rec.PracticeHours
	 ,rec.IsActiveEmployer
	 ,rec.IsOnPublicRegistry
	from
		dbo.fRegistrantEmployment#Current(@personSID) rec;

end;			
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantEmployment#Current'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare @currentYear smallint = dbo.fRegistrationYear#Current();

	insert
		@currentEmployment
	(
		RecordNo
	 ,OrgSID
	 ,OrgName
	 ,OrgLabel
	 ,OrgTypeName
	 ,RegionName
	 ,RegistrantEmploymentSID
	 ,EmploymentTypeSID
	 ,EmploymentRoleSID
	 ,PracticeScopeSID
	 ,PracticeAreaSID
	 ,AgeRangeSID
	 ,PracticeHours
	 ,IsActiveEmployer
	 ,IsOnPublicRegistry
	 ,Phone
	 ,IsEmployerInsurance
	 ,InsuranceOrgSID
	 ,InsurancePolicyNo
	 ,InsuranceAmount
	 ,SiteLocation
	 ,RegistrantEmploymentXID
	)
	select
		row_number() over (order by re.RegistrantEmploymentSID desc) RecordNo
	 ,o.OrgSID
	 ,o.OrgName
	 ,o.OrgLabel
	 ,ot.OrgTypeName
	 ,rgn.RegionName
	 ,re.RegistrantEmploymentSID
	 ,re.EmploymentTypeSID
	 ,re.EmploymentRoleSID
	 ,re.PracticeScopeSID
	 ,repa.PracticeAreaSID																				 PrimaryPracticeAreaSID
	 ,re.AgeRangeSID
	 ,re.PracticeHours
	 ,cast(re.PracticeHours as bit)																 IsActiveEmployer
	 ,re.IsOnPublicRegistry
	 ,re.Phone
	 ,re.IsEmployerInsurance
	 ,re.InsuranceOrgSID
	 ,re.InsurancePolicyNo
	 ,re.InsuranceAmount
	 ,re.SiteLocation
	 ,re.RegistrantEmploymentXID
	from
	(
		select
			re.OrgSID
		 ,max(re.RegistrantEmploymentSID) RegistrantEmploymentSID
		from
			dbo.Registrant					 r
		join
			dbo.RegistrantEmployment re on r.RegistrantSID = re.RegistrantSID
		where
			r.PersonSID							= @PersonSID -- find employment for the registrant renewing/updating their profile
			and
			(
				re.RegistrationYear		= @currentYear -- in the current registration year
				or
				(
					re.RegistrationYear = (@currentYear - 1) and re.PracticeHours > 0 -- or in the previous year where they confirmed employment (1 hour or more)
				)
			)
		group by
			re.OrgSID -- group by organization to get the latest record meeting the criteria for each employer
	)																			 x
	join
		dbo.Org															 o on x.OrgSID											= o.OrgSID
	join
		dbo.OrgType													 ot on o.OrgTypeSID									= ot.OrgTypeSID
	join
		dbo.Region													 rgn on o.RegionSID									= rgn.RegionSID
	join
		dbo.RegistrantEmployment						 re on x.RegistrantEmploymentSID		= re.RegistrantEmploymentSID
	left outer join
		dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID = repa.RegistrantEmploymentSID and repa.IsPrimary = cast(1 as	bit);

	return;

end;
GO
