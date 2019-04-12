SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantLanguage#List
/*********************************************************************************************************************************
View		: Registrant Language - List
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns languages reported for a registrant as a comma separated list
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides a flattened text list of languages reported for a registrant. eg. "English,French,Spanish".

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of records selected at random.">
	<SQLScript>
	<![CDATA[

select top(10) x.* from	dbo.vRegistrantLanguage#List x

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
	 @ObjectName = 'dbo.vRegistrantLanguage#List'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select distinct
	x.RegistrantSID
 ,replace(substring((
											select
												',' + l.LanguageLabel as [text()]
											from
												dbo.RegistrantLanguage rl
											join
												dbo.Language					 l on rl.LanguageSID = l.LanguageSID
											where
												rl.RegistrantSID = x.RegistrantSID
											for xml path('')
										)
										,2
										,1000
									 )
					,'&amp;'
					,','
				 ) LanguageList
from
	dbo.Registrant x;
GO
