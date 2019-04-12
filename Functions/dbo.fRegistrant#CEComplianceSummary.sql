SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#CEComplianceSummary
(
	@RegistrantSID		int -- key of registrant to return learning plan details for or -1 for all registrants
 ,@RegistrationYear int -- registration year to use as criteria  - MANDATORY must be passed
)
returns table
/*********************************************************************************************************************************
Function: Registrant - Continuing Education Compliance Detail
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns one record for each registrant indicating whether they are compliant with CE requirements
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This function is intended for summarized reporting on the status of compliance with continuing education requirements.  A bit 
is returned indicating whether compliance has been achieved.  Use the dbo.fRegistrant#CEComplianceDetail table function to 
see compliance on a requirement-by-requirement basis.

The table returns a record for a single registrant passed in, or for all registrants (when -1 is passed for the @RegistrantSID).  

Note that for single-registrant or all-registrant modes, one record is returned for each registrant where their last registration in 
the year selected was on a register where Learning Plans are enabled.  Normally this will include only active-practice registers but 
non-practicing registers can also be configured to allow learning plan submissions.   If the function is being used where all 
registrants must be returned, then OUTER apply to the function from the full-set of registrant records.

The @RegistrationYear parameter is mandatory.  To call it for the current year pass: dbo.fRegistrationYear#Current().

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Returns all records for the current registration year">
    <SQLScript>
      <![CDATA[
declare @currentYear smallint = dbo.fRegistrationYear#Current();

select
	x.*
from
	dbo.fRegistrant#CEComplianceSummary(-1, @currentYear) x
order by
	x.RegistrantSID desc;

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
  <Test Name = "Random" Description="Returns 1 record for registrant selected at random for current registration year">
    <SQLScript>
      <![CDATA[
declare
	@registrantSID int			
 ,@currentYear	 smallint = dbo.fRegistrationYear#Current();

select top (1)
	@registrantSID = reg.RegistrantSID
from
	dbo.fRegistrant#LatestRegistration(-1, @currentYear) reg
where
	reg.IsLearningPlanEnabled = 1
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.fRegistrant#CEComplianceSummary(@registrantSID, @currentYear) x;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value = "1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrant#CEComplianceSummary'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		reg.RegistrantSID
	 ,rlp.RegistrantLearningPlanSID
	 ,reg.RegistrantLabel --# display label for the registrant
	 ,reg.EmailAddress
	 ,reg.HomePhone
	 ,reg.MobilePhone
	 ,@RegistrationYear																			RegistrationYear
	 ,cast(isnull(rlp.RegistrantLearningPlanSID, 0) as bit) IsLearningPlanReported
	 ,(@RegistrationYear - lm.CycleLengthYears + 1)					CycleStartRegistrationYear
	 ,@RegistrationYear																			CycleEndRegistrationYear
	 ,(case
			 when lm.CycleLengthYears = 1 then ltrim(@RegistrationYear)
			 else ltrim((@RegistrationYear - lm.CycleLengthYears + 1)) + ' - ' + ltrim(@RegistrationYear)
		 end
		)																											CycleTerm
	 ,cast(case when cd.RequirementsNotMet > 0 then 0 else 1 end as bit) IsCompliant
	 ,reg.FirstName
	 ,reg.MiddleNames
	 ,reg.LastName
	 ,reg.CommonName
	 ,reg.BirthDate
	 ,reg.EffectiveTime																			RegistrationEffectiveTime
	 ,reg.ExpiryTime																				RegistrationExpiryTime
	 ,reg.PersonSID
	from
		dbo.fRegistrant#LatestRegistration(@RegistrantSID, @RegistrationYear) reg
	left outer join
		dbo.RegistrantLearningPlan																						rlp on reg.RegistrantSID	 = rlp.RegistrantSID and rlp.RegistrationYear = @RegistrationYear
	left outer join
	(
		select
			cd.RegistrantSID
		 ,sum((case when cd.IsRequirementMet = 0 then 1 else 0 end)) RequirementsNotMet
		from
			dbo.fRegistrant#CEComplianceDetail(@RegistrantSID, @RegistrationYear) cd
		group by
			cd.RegistrantSID
	)																																				cd on reg.RegistrantSID		 = cd.RegistrantSID
	left outer join
		dbo.LearningModel																											lm on reg.LearningModelSID = lm.LearningModelSID
	where
		reg.IsLearningPlanEnabled = cast(1 as bit)	-- only include Registers where learning plans are enabled
);
GO
