SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAnnouncement#Search]
as
/*********************************************************************************************************************************
View    : Announcement Search
Notice  : Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the Person search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng   	| Sep 2017    |	Initial version

Comments	
--------
This view returns a sub-set of the full Announcement entity.  It is intended for use in search and dashboard procedures.  Only 
columns required for display in UI search results, or which are required for selecting records in the search procedure should be 
included.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	select top (1)
		 x.*
	from
		sf.vAnnouncement#Search x

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vAnnouncement#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	a.AnnouncementSID
 ,a.RowGUID
 ,a.Title
 ,a.AnnouncementText
 ,a.AdditionalInfoPageURI
 ,a.EffectiveTime
 ,a.ExpiryTime
 ,a.IsExtendedFormat
 ,a.IsLoginAlert
 ,a.IsActive
 ,a.IsPending
 ,a.IsNew
 ,a.IsDeleteEnabled
from
	sf.vAnnouncement a;
GO
