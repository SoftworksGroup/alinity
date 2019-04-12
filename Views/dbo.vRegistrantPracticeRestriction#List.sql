SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantPracticeRestriction#List
/*********************************************************************************************************************************
View		: Registrant Practice Restriction - List
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns active practice restrictions in effect for a registrant as a comma separated list
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides a flattened text list of Registrant Practice Restrictions currently in effect for a registrant. If more than
one restriction is in effect, they appear comma delimited.

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of records selected at random.">
	<SQLScript>
	<![CDATA[

select top(10) x.* from	dbo.vRegistrantPracticeRestriction#List x

if @@rowcount = 0 
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrantPracticeRestriction#List'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select distinct
	x.RegistrantSID
 ,replace(substring((
											select
												',' + pr.PracticeRestrictionLabel as [text()]
											from
												dbo.RegistrantPracticeRestriction rpr
											join
												dbo.PracticeRestriction					 pr on rpr.PracticeRestrictionSID = pr.PracticeRestrictionSID
											where
												rpr.RegistrantSID = x.RegistrantSID
											and
												sf.fIsActive(rpr.EffectiveTime, rpr.ExpiryTime) = cast(1 as bit)
											for xml path('')
										)
										,2
										,1000
									 )
					,'&amp;'
					,','
				 ) PracticeRestrictionList
from
	dbo.Registrant x;
GO
