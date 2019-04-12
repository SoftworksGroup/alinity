SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantEmploymentPracticeArea#List
/*********************************************************************************************************************************
View		: Registrant Employment Practice Area - List
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns Practice Areas as a comma separated list for each registrant employment record
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides a flattened text list of practice-areas reported for a each employment record for a registrant. eg. 
"Burns and wound management, Plastics, Hands" - as might result in a surgical profession.  The flattened value is 
useful in providing a summary of practice areas where normalization is at the level of dbo.RegistrantEmployment.

Note that for many organizations, only a single practice area is stored per employer.

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of records selected at random.">
	<SQLScript>
	<![CDATA[

select top(10) x.* from	dbo.vRegistrantEmploymentPracticeArea#List x

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
	 @ObjectName = 'dbo.vRegistrantEmploymentPracticeArea#List'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select distinct
	x.RegistrantEmploymentSID
 ,replace(substring((
											select
												',' + pa.PracticeAreaName as [text()]
											from
												dbo.RegistrantEmploymentPracticeArea repa
											join
												dbo.PracticeArea										 pa on repa.PracticeAreaSID					= pa.PracticeAreaSID
											join
												dbo.RegistrantEmployment						 re on repa.RegistrantEmploymentSID = re.RegistrantEmploymentSID
											where
												re.RegistrantEmploymentSID = x.RegistrantEmploymentSID
											for xml path('')
										)
										,2
										,1000
									 )
					,'&amp;'
					,','
				 ) PracticeAreaList
from
	dbo.RegistrantEmployment x;
GO
