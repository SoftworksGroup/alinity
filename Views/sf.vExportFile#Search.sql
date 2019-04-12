SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vExportFile#Search]
as
/*********************************************************************************************************************************
View			: Export File Search
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the Person search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| May 2018    |	Initial version

Comments	
--------
This view returns a sub-set of the full ExportFile entity in addition to the SID and label for: DataSource, ApplicationPage 
and ExportJob if the export used them. It is intended for use in search and dashboard procedures.  Only columns required for 
display in UI search results, or which are required for selecting records in the search procedure should be included.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	select top (100)
		 x.*
	from
		sf.vExportFile#Search x
	order by
		newid()
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vExportFile#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ef.ExportFileSID
	,ef.ProcessedTime
	,ef.MessageText
	,ef.IsFailed
	,ef.FileFormatLabel
	,ef.FileFormatSCD
	,ef.IsComplete
	,ef.IsInProcess
	,ef.IsDeleteEnabled
	,ef.CreateUser
	,ef.CreateTime	
	,ef.UpdateUser
	,ef.UpdateTime
	,ap.ApplicationPageSID 
	,case
		when ef.ExportSourceGUID = '12b0577a-2346-468c-b826-765d43c62693' then 'Archive'
		when ef.ExportSourceGUID = '31cc7e37-fb05-4cd1-af09-f11c774a4a37' then 'Download'
		else ap.ApplicationPageLabel
	end															ApplicationPageLabel
	,ds.DataSourceSID	
	,case
		when ef.ExportSourceGUID = '12b0577a-2346-468c-b826-765d43c62693' or ef.ExportSourceGUID = '31cc7e37-fb05-4cd1-af09-f11c774a4a37' then 'Email'
		else ds.DataSourceLabel
	end															DataSourceLabel
	,ej.ExportJobSID
	,ej.ExportJobName
	,datalength(ef.FileContent)			FileLength
from
	sf.vExportFile ef
left outer join
	sf.ApplicationPage ap on ef.ExportSpecification.value('/Export[1]/@ApplicationPageSID', 'int') = ap.ApplicationPageSID
left outer join
	sf.DataSource ds on ef.ExportSpecification.value('/Export[1]/@DataSourceSID', 'int') = ds.DataSourceSID
left outer join
	sf.ExportJob ej on ef.ExportSpecification.value('/Export[1]/@ExportJobSID', 'int') = ej.ExportJobSID
GO
