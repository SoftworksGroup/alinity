SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationUserSession#BrowserInfo]
as
/*********************************************************************************************************************************
View			: Application User Session - Browser Info
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns columns for analysis or troubleshooting of browsers used by the system
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Jun 2018    |	Initial version

Comments	
--------
This view returns details about the browser attached to a particular session including the name, version and user agent.
This information can be used by the helpdesk to determine if an issue is caused by the browser being used or not. Additionally
this information can be aggregated to obtain usage statistics.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	select top (100)
		 x.*
	from
		sf.vApplicationUserSession#BrowserInfo x
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
	@ObjectName = 'sf.vApplicationUserSession#BrowserInfo'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 au.UserName
	,aus.CreateTime
	,aus.UpdateTime
	,aup.PropertyValue.value('/BrowserInfo[1]/@FullBrowser', 'varchar(200)')		FullBrowser
	,aup.PropertyValue.value('/BrowserInfo[1]/@BrowserPart', 'varchar(150)')		BrowserPart
	,aup.PropertyValue.value('/BrowserInfo[1]/@MajorVersion', 'int')						MajorVersion
	,aup.PropertyValue.value('/BrowserInfo[1]/@IsMobile', 'bit')								IsMobile
	,aup.PropertyValue.value('/BrowserInfo[1]/UserAgent[1]', 'nvarchar(2000)')	UserAgent
from
	sf.ApplicationUserSession aus
join
	sf.ApplicationUserSessionProperty aup on aus.ApplicationUserSessionSID = aup.ApplicationUserSessionSID and aup.PropertyName = 'BrowserInfo'
join
	sf.ApplicationUser au on aus.ApplicationUserSID = au.ApplicationUserSID
GO
