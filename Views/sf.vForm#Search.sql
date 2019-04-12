SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vForm#Search]
as
/*********************************************************************************************************************************
View			: Form Search
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the Form search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Jun 2018    |	Initial version

Comments	
--------
This view returns a sub-set of the full Form entity in addition to the SID and label for: FormType and ApplicationUser.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	select top (100)
		 x.*
	from
		sf.vForm#Search x
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
	@ObjectName = 'sf.vForm#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 f.FormSID
	,f.FormTypeSID
	,f.FormName
	,f.FormLabel
	,f.IsActive
	,f.ApplicationUserSID
	,f.CreateTime
	,f.CreateUser
	,f.UpdateTime
	,f.UpdateUser
	,ft.FormTypeLabel
	,sf.fFormatDisplayName(p.LastName, isnull(p.CommonName, p.FirstName))	DisplayName
from
	sf.Form f
join
	sf.FormType ft on f.FormTypeSID = ft.FormTypeSID
join
	sf.ApplicationUser au on f.ApplicationUserSID = au.ApplicationUserSID
join
	sf.Person p on au.PersonSID = p.PersonSID
GO
