SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPerson#AllNotes]
/*********************************************************************************************************************************
View			: Person - All Notes 
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns columns required for export of notes from the person screen
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| May 2018    |	Initial version					

Comments	
--------
This view returns the note entity with the tags flattened into a comma delimited list in addition to details about the
type, person and registrant (if any).  The view was created primarily to support exports.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	declare
		@work	table
		(
			PersonSID int not null
		)

	insert
		@work
	select top 100
		PersonSID
	from
		sf.Person
	order by
		newid()

	select 
		 ne.*
	from
		dbo.vPerson#NoteExport ne
	join
		@work w on ne.PersonSID = w.PersonSID
		
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vPerson#NoteExport'
-------------------------------------------------------------------------------------------------------------------------------- */
as
select 
	 pn.PersonNoteSID
	,pn.PersonSID
	,pn.PersonNoteTypeSID
	,pn.NoteTitle
	,pn.NoteContent
	,case when t.Tags is not null and len(t.Tags) > 2 then substring(t.Tags, 3, len(t.Tags) - 2) else null end Tags
	,pn.PersonNoteXID
	,pn.LegacyKey
	,pn.CreateUser
	,pn.CreateTime
	,pn.UpdateUser
	,pn.UpdateTime
	,pn.RowGUID
	,pnt.PersonNoteTypeLabel
	,pnt.PersonNoteTypeCategory
	,pnt.IsActive												PersonNoteTypeIsActive
	,p.FirstName
	,p.CommonName
	,p.MiddleNames
	,p.LastName
	,p.BirthDate
	,p.DeathDate
	,p.HomePhone
	,p.MobilePhone
	,p.RowGUID													PersonRowGUID
	,p.PersonXID
	,p.LegacyKey												PersonLegacyKey
	,r.RegistrantNo
	,r.RowGUID													RegistrantRowGUID
	,r.RegistrantXID
	,r.LegacyKey												RegistrantLegacyKey
from 
	dbo.PersonNote pn
join
	dbo.PersonNoteType pnt on pn.PersonNoteTypeSID = pnt.PersonNoteTypeSID
join
	sf.Person p on pn.PersonSID = p.PersonSID
left outer join
	dbo.Registrant r on pn.PersonSID = r.PersonSID
cross apply
	(
		select 
			(
				select 
					', ' + x.Tag.value('@Name[1]', 'nvarchar(1000)') 
				from 
					pn.TagList.nodes('/TagList/Tag') x(Tag) 
				for xml path('')
			) Tags
	) t
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns the content of notes recorded for a member.  Any tags applied to the note appear as a comma separated list.|EXPORT ^PersonList', 'SCHEMA', N'dbo', 'VIEW', N'vPerson#AllNotes', NULL, NULL
GO
