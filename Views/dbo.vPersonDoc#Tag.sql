SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonDoc#Tag]
as
/*********************************************************************************************************************************
View    : PersonDoc Tag
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns the list of unique tag names applied (in the TagList xml column) on all records of the table
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Christian	T | Mar 2015	    |	Initial Version (reviewed by Tim Edlund and updated to standard generated syntax)
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view is used in the UI to provide the user with the list of tag values previously applied to records in the table. Tags are
used in categorizing and searching the content contained in the record.

Be sure the XML column is the included in a primary XML index in order to achieve acceptable performance on large tables!

The view returns the TagName twice.  This is done intentionally to support the control used in the UI for TagList management
that requires a "code" and "value" structure. The view also returns a primary key, also required by the UI components, to
identify each record through an integer.  A blank date time offset is also returned as a placeholder.  The UI populates that
value with the time added from existing tags when editing  - by adding new tags to existing ones.

<TagList>
	<Tag TagName="[Name]" AddedTime="[Offset date]" />
</TagList>

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Calls the view to return all unique tags. Test ensures content is returned and
				that performance is acceptable.">
		<SQLScript>
			<![CDATA[

	begin tran

		declare
				@PersonSID					int
			,	@PersonDocTypeSID		int
			,	@FileTypeSID				int
			,	@FileTypeSCD				varchar(50)

		select top 1
			@PersonSID = p.PersonSID
		from
			sf.Person p

		select top 1
			 @PersonDocTypeSID = pdt.PersonDocTypeSID
		from
			dbo.PersonDocType pdt
		where
			pdt.IsActive = 1


		select top 1
				@FileTypeSID = ft.FileTypeSID
			,	@FileTypeSCD = ft.FileTypeSCD
		from
			sf.FileType ft
		where
			ft.IsActive = 1

		insert into
			dbo.PersonDoc
		(
				PersonSID
			,	PersonDocTypeSID
			,	DocumentTitle
			,	DocumentContent
			,	FileTypeSID
			,	FileTypeSCD
			,	TagList
			,	ChangeAudit
		)
		select
				@PersonSID
			,	@PersonDocTypeSID
			,	'Test Document'
			,	cast('Test' as varbinary)
			,	@FileTypeSID
			,	@FileTypeSCD
			, N'<TagList><Tag TagName=''TestName1''>Value1</Tag><Tag TagName=''TestName2''>Value2</Tag></TagList>'
			,	'Test'

		select
			 x.*
		from
			dbo.vPersonDoc#Tag x

		if @@rowcount = 0 raiserror('** no sample data to support test **', 18, 1)

	if @@TRANCOUNT > 0 rollback

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.vPersonDoc#Tag'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
select
	 x.TagSID
	,x.TagName
	,x.TagValue
	,cast(null as datetimeoffset(7))							    AddedTime									-- place holder for UI to populate from existing tags
from
(
	select
		 isnull(rank() over(order by t.TagName),-1)	    TagSID										-- this must be wrapped in the isnull() function in order for EF to serialize it as a non-nullable field.
		,t.TagName
		,t.Tagname																	    TagValue
	from
	(
		select
				tag.node.value('@TagName', 'nvarchar(30)')	TagName
		from
			dbo.PersonDoc x
		cross apply
			x.TagList.nodes('/TagList/Tag') as tag(node)
	) t
	group by
		t.TagName
	) x
GO
