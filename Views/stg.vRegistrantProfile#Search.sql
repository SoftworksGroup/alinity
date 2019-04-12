SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW stg.vRegistrantProfile#Search
as
/*********************************************************************************************************************************
View     : Registrant Profile Search
Notice   : Copyright © 2019 Softworks Group Inc.
Summary	 : Returns columns required for display on the Registrant Profile search screen
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This view returns a sub-set of the full Registrant Profile entity.  It is intended for use in search and dashboard procedures.  
To ensure the best possible response times for searching, only columns required for display in UI search results are included. 

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Select all recordsfrom the view.">
<SQLScript>
<![CDATA[

	select 
		 x.*
	from
		stg.vRegistrantProfile#Search x
	order by
		x.LastName, x.Firstname, x.MiddleNames, ImportFileSID

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:15" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'stg.vRegistrantProfile#Search'
-------------------------------------------------------------------------------------------------------------------------------- */

select
	rp.RegistrantProfileSID
 ,dbo.fRegistrant#Label(isnull(rp.LastName, N'[No Last name]'), isnull(rp.FirstName, N'[No First name]'), rp.MiddleNames, rp.RegistrantNo, 'REGISTRATION') RegistrantLabel
 ,rp.EmailAddress
 ,isnull(rp.MobilePhone, rp.HomePhone)																																																										 Phone
 ,rp.CityName
 ,isnull(rp.PracticeRegisterLabel, appReg.PracticeRegisterLabel)																																													 PracticeRegisterLabel
 ,ps.ProcessingStatusLabel
 ,imp.FileName
 ,sf.fDTOffsetToClientDateTime(imp.LoadEndTime)																																																						 LoadedTime
 ,rp.ProcessingComments
 ,ps.IsClosedStatus
	-- columns to support default sort order (indexed) and icons
 ,ps.ProcessingStatusSCD
 ,stg.fRegistrantProfile#IsDeleteEnabled(rp.RegistrantProfileSID)																																													 IsDeleteEnabled
 ,rp.LastName
 ,rp.FirstName
 ,rp.MiddleNames
 ,rp.ImportFileSID
from
	stg.RegistrantProfile rp
join
	sf.ImportFile					imp on rp.ImportFileSID			 = imp.ImportFileSID
join
	sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID
join
(
	select
		dbo.fPracticeRegisterSection#Label(prs.PracticeRegisterSectionSID) PracticeRegisterLabel
	from
		dbo.PracticeRegister				pr
	join
		dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID and prs.IsDefault = cast(1 as bit)
	where
		pr.IsDefault = cast(1 as bit)
)												appReg on 1									 = 1;
GO
