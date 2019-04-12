SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#HasConditionsOnPractice
(
	@RegistrantSID int	-- primary key of Registrant to check
)
returns bit
as
/*********************************************************************************************************************************
TableF	: Registrant - Has Conditions on Practice
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Checks a registrant to determine if the have active conditions on their practice
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
The function is called by the UI to establish whether the registrant currently has any conditions on their practice. If one
or more conditions exist, they are typically reflecting through an icon appearing on the UI. Note that this function is designed 
to return the results quickly and does not provide details on the nature of the condition - or even if multiple conditions exist.

<TestHarness>
	<Test Name = "Simple" Description="Returns open condition results for 10 registrants selected at random.">
	<SQLScript>
	<![CDATA[

		select top 100
			 r.RegistrantSID
			,dbo.fRegistrant#HasConditionsOnPractice(r.RegistrantSID)						HasConditionsOnPractice
		from 
			dbo.Registrant r

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrant#HasConditionsOnPractice'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@HasConditionsOnPractice bit										-- return value
	 ,@ON											 bit = cast(1 as bit);	-- used on bit comparisons to avoid multiple casts

	select
		@HasConditionsOnPractice = cast(isnull(count(1), 0) as bit)
	from
		dbo.Registrant										reg
	join
		dbo.RegistrantPracticeRestriction rpr on reg.RegistrantSID = rpr.RegistrantSID
	where
		reg.RegistrantSID = @RegistrantSID and sf.fIsActive(rpr.EffectiveTime, rpr.ExpiryTime) = @ON;

	return (@HasConditionsOnPractice);

end;
GO
