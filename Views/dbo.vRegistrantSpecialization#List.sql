SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantSpecialization#List
/*********************************************************************************************************************************
View		: Registrant Specialization - List
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns specializations (designated credentials) reported for a registrant as a comma separated list
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides a flattened text list of specialization credentials reported for a registrant. Example: "Use needles in practice,
Perform spinal,Order diagnostic imaging".

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of records selected at random.">
	<SQLScript>
	<![CDATA[

select top(10) x.* from	dbo.vRegistrantSpecialization#List x

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
	 @ObjectName = 'dbo.vRegistrantSpecialization#List'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select distinct
	x.RegistrantSID
 ,replace(substring((
											select
												',' + crd.CredentialLabel as [text()]
											from
												dbo.RegistrantCredential rc
											join
												dbo.Credential					 crd on rc.CredentialSID = crd.CredentialSID and crd.IsSpecialization = cast(1 as bit)
											where
												rc.RegistrantSID = x.RegistrantSID and sf.fIsActive(rc.EffectiveTime, rc.ExpiryTime) = cast(1 as bit)
											for xml path('')
										)
										,2
										,1000
									 )
					,'&amp;'
					,','
				 ) SpecializationList
from
	dbo.Registrant x;
GO
