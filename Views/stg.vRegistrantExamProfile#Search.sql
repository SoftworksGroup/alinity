SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW stg.vRegistrantExamProfile#Search
as
/*********************************************************************************************************************************
View     : Registrant Exam Profile Search
Notice   : Copyright © 2019 Softworks Group Inc.
Summary	 : Returns columns required for display on the Registrant Exam Profile search screen
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2019		|	Initial version

Comments
--------
This view returns a sub-set of the full Registrant Exam Profile entity.  It is intended for use in search and dashboard procedures.  
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
		stg.vRegistrantExamProfile#Search x
	order by
		x.LastName, x.Firstname, ImportFileSID

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:15" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'stg.vRegistrantExamProfile#Search'
-------------------------------------------------------------------------------------------------------------------------------- */
select
	rxp.RegistrantExamProfileSID
 ,dbo.fRegistrant#Label(isnull(rxp.LastName, N'[No Last name]'), isnull(rxp.FirstName, N'[No First name]'), null, rxp.RegistrantNo, 'REGISTRATION') RegistrantLabel
 ,rxp.EmailAddress
 ,rxp.ExamIdentifier
 ,rxp.ExamDate
 ,rxp.Score
 ,rxp.OrgLabel
 ,rxp.ExamReference
 ,ps.ProcessingStatusLabel
 ,imp.FileName
 ,sf.fDTOffsetToClientDateTime(imp.LoadEndTime)																																																								 LoadedTime
 ,rxp.ProcessingComments
 ,ps.IsClosedStatus
	-- columns to support default sort order (indexed) and icons
 ,ps.ProcessingStatusSCD
 ,stg.fRegistrantExamProfile#IsDeleteEnabled(rxp.RegistrantExamProfileSID)																																										 IsDeleteEnabled
 ,rxp.LastName
 ,rxp.FirstName
 ,rxp.ImportFileSID
from
	stg.RegistrantExamProfile rxp
join
	sf.ImportFile							imp on rxp.ImportFileSID			= imp.ImportFileSID
join
	sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID;
GO
