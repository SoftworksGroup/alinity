SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantEmployment#Top
(
	@RegistrantSID		int
 ,@RegistrationYear smallint
 ,@TopCount					tinyint
 ,@AsOfTime					datetime
)
returns table
as
/*********************************************************************************************************************************
TableFcn	: Employment Rank Top
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the rank of the employment record within the registration year based on highest practice hours 
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Jun 2018		|	Initial version
					: Tim Edlund	| Dec 2018		| Updated to include AgeRange key associated with the employment record

Comments	
--------

This function returns the EmploymentRank calculated column on the dbo.RegistrantEmployment table. The @TopCount parameter allows
the caller to specify a limit for the number of records that should be returned for the registrant.  The employment ranking is 
calculated based on highest practice hours to lowest practice hours within the registration year. The rank of employment is used 
for ordering records and for reporting to external parties including CIHI and Provincial Provider Registries.  

If the AsOfTime is provided (passed as not null) it is used to exclude terminated employment records.  It is possible to terminate 
employment during the year by entering an ExpiryTime value. This is optional and the value is not used in all configurations.
If employment date ranges are used and an @AsOfTime is also provided, the function excludes employment records which are not active
at the given time. Passing this parameter as not null also has the effect of selecting from the @RegistrationYear -1 as well as the
@Registration year passed.  This is necessary for situations where the procedure is being run for the current year and renewal
has not yet occurred so employment records may not be created for the year.

Example
-------
<TestHarness>
	<Test Name = "Random10" Description="Returns ranking for 10 employment records selected at random.">
	<SQLScript>
	<![CDATA[
select
  re.*
from
(
	select top (10)
		re.RegistrantSID
	 ,re.RegistrationYear
	from
		dbo.RegistrantEmployment re
	order by
		newid()
)													 x
cross apply
	dbo.fRegistrantEmployment#Top(x.RegistrantSID, x.RegistrationYear, 3, null) re
order by
	 re.RegistrantSID
	,re.RegistrationYear
	,re.EmploymentRankNo
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "Flatten10" Description="Shows example of returning output for top 3 employers flattened to a single row.">
	<SQLScript>
	<![CDATA[
select
	re.RegistrantSID
 ,re.RegistrationYear
 ,max(case when re.EmploymentRankNo = 1 then re.OrgSID end)						 Rank1OrgSID
 ,max(case when re.EmploymentRankNo = 1 then re.PracticeHours end)		 Rank1PracticeHours
 ,max(case when re.EmploymentRankNo = 1 then re.EmploymentTypeSID end) Rank1EmploymentTypeSID
 ,max(case when re.EmploymentRankNo = 2 then re.OrgSID end)						 Rank2OrgSID
 ,max(case when re.EmploymentRankNo = 2 then re.PracticeHours end)		 Rank2PracticeHours
 ,max(case when re.EmploymentRankNo = 2 then re.EmploymentTypeSID end) Rank2EmploymentTypeSID
 ,max(case when re.EmploymentRankNo = 3 then re.OrgSID end)						 Rank3OrgSID
 ,max(case when re.EmploymentRankNo = 3 then re.PracticeHours end)		 Rank3PracticeHours
 ,max(case when re.EmploymentRankNo = 3 then re.EmploymentTypeSID end) Rank3EmploymentTypeSID
from
(
	select top (10)
		re.RegistrantSID
	 ,re.RegistrationYear
	from
		dbo.RegistrantEmployment re
	order by
		newid()
)																																									x
cross apply dbo.fRegistrantEmployment#Top(x.RegistrantSID, x.RegistrationYear, 3, null) re
group by
	re.RegistrantSID
 ,re.RegistrationYear;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantEmployment#Top'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		x.RegistrantSID
	 ,x.RegistrationYear
	 ,x.EmploymentRankNo
	 ,x.PracticeHours
	 ,x.CreateTime
	 ,x.RegistrantEmploymentSID
	 ,x.OrgSID
	 ,x.EmploymentTypeSID
	 ,x.EmploymentRoleSID
	 ,x.PrimaryPracticeAreaSID
	 ,x.PracticeScopeSID
	 ,x.AgeRangeSID
	 ,x.IsOnPublicRegistry
	 ,x.Phone
	 ,x.EffectiveTime
	 ,x.ExpiryTime
	 ,x.UserDefinedColumns
	 ,x.RegistrantEmploymentXID
	 ,x.LegacyKey
	from
	(
		select
			row_number() over (order by re.PracticeHours desc, re.Rank asc, re.CreateTime desc) EmploymentRankNo -- "rank" is only applicable where no hours are recorded
		 ,re.RegistrantEmploymentSID
		 ,re.RegistrantSID
		 ,re.OrgSID
		 ,re.RegistrationYear
		 ,re.EmploymentTypeSID
		 ,re.EmploymentRoleSID
		 ,re.PracticeHours
		 ,repa.PracticeAreaSID																									 PrimaryPracticeAreaSID
		 ,re.PracticeScopeSID
		 ,re.AgeRangeSID
		 ,re.IsOnPublicRegistry
		 ,re.Phone
		 ,re.EffectiveTime
		 ,re.ExpiryTime
		 ,re.UserDefinedColumns
		 ,re.RegistrantEmploymentXID
		 ,re.LegacyKey
		 ,re.CreateTime
		from
			dbo.RegistrantEmployment						 re
		join
			dbo.Org o on re.OrgSID = o.OrgSID
		join
			dbo.OrgType ot on o.OrgTypeSID = ot.OrgTypeSID and ot.OrgTypeCode <> 'S!PLACEHOLDER'
		left outer join
			dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID = repa.RegistrantEmploymentSID and repa.IsPrimary = cast(1 as bit)
		where
			re.RegistrantSID												 = @RegistrantSID 
			and
			( 
				(re.RegistrationYear = @RegistrationYear and @AsOfTime is null) -- if no cut off time is provided the employment must be in the year specified
				or
				(@AsOfTime is not null and re.RegistrationYear >= @RegistrationYear - 1) -- if a cut off is provided, choose from the specified year and prior year
			) 
			and
			(
				@AsOfTime is null or re.EffectiveTime is null -- if the parameter is passed as null or the date ranges are not being used or ...
				or 
				(
				re.EffectiveTime <= @AsOfTime and -- the employment came into effect on or before the provided time and ...
				(re.ExpiryTime is null or re.ExpiryTime > @AsOfTime) -- the employment is not expired or expires after the time value provided
				) 
			) 
	) x
	where
		x.EmploymentRankNo <= @TopCount
);
GO
