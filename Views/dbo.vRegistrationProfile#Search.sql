SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrationProfile#Search
as
/*********************************************************************************************************************************
View			: Registration Profile Search
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns columns required for the RegistrationProfile search page
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Cory Ng   	| Jul 2018		|	Initial version

Comments	
--------
This view returns columns required for display on the RegistrationProfile Search UI.  The view is called from 
pRegistrationProfile#SearchCT and may also be called from some other contexts.  The view should be constructed to ensure 
performance from the search UI is as fast as possible.  Only columns required for display in UI search results should be included.  
The actual search operations are performed within the procedure using raw tables wherever possible.  This view is only called at 
the end of the process to output results to the UI.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[
declare @RegistrationProfileSID int;

select top (1)
	@RegistrationProfileSID = reg.RegistrationProfileSID
from
	dbo.RegistrationProfile reg
order by
	newid();

if @@rowcount = 0 or @RegistrationProfileSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		*
	from
		dbo.vRegistrationProfile#Search x
	where
		x.RegistrationProfileSID = @RegistrationProfileSID;

end;
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrationProfile#Search'
	,@DefaultTestOnly= 1
-------------------------------------------------------------------------------------------------------------------------------- */

select
	rp.RegistrationProfileSID
 ,p.PersonSID
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT') RegistrantLabel
 ,rp.MessageText
 ,rp.IsInvalid
 ,rpx.IsModified
 ,dbo.fRegistrationProfile#IsDeleteEnabled(rp.RegistrationProfileSID)													IsDeleteEnabled
from
	dbo.RegistrationProfile rp
join
	dbo.Registrant					r on rp.RegistrantSID = r.RegistrantSID
join
	sf.Person								p on r.PersonSID			= p.PersonSID
cross apply
	dbo.fRegistrationProfile#Ext(rp.RegistrationProfileSID) rpx
GO
