SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTagList#SetTagTimes]
(			
	 @TagList										xml																					-- tag list document to set tag times on
)
returns xml
as
/*********************************************************************************************************************************
ScalarF	: Tag List - set tag times
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns an XML document with "added times" inserted where missing for tags
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Mar 2015		|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
A standard format for "TagList" columns is followed for systems based on this framework.  An example of the format appears in 
the test harness below.  The TagList is made up of 0, 1 or more "Tag" elements which each have a Name and TimeAdded attribute.
The UI components add and remove the Tag element and Name attribute but they do not add the TimeAdded attribute. The time is
added through the EF procedures (#Insert and #Update) which pass the XML to this function.

Note that if the XML provided does not contain any "Tag" nodes, then none are added and the XML document returned is the
same as the one passed in (also applies if NULL passed in).

Example
-------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Accepts tag list document where 2 new tag values have been added.
				The current time should be added to the document on those 2 nodes.">
		<SQLScript>
			<![CDATA[
declare
	 @tagList	xml = N'
<TagList>
	<Tag Name="All" Added="2015-03-10T01:00:00-06:00"/>
	<Tag Name="BiteMe" Added="2014-01-19T02:00:00-06:00"/>
	<Tag Name="Christian" Added="2012-02-10T03:00:00-06:00" />
	<Tag Name="Sucks" Added="2013-07-14T00:04:00-06:00" />
	<Tag Name="ThisIsNew" />
	<Tag Name="BeNicer" Added="2015-08-04T05:00:00-06:00"/>
	<Tag Name="AndSoIsThis" />
</TagList>'

select sf.fTagList#SetTagTimes(@tagList) TagList
 
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
		</Assertions>
	</Test>
	<Test Name="NoTags" Description="An XML document with no tags is provided.  The return value should be the default XML format
				for an empty TagList (these columns are typically defined NOT NULL in tables where they are used).">
		<SQLScript>
			<![CDATA[
			
declare
	 @tagList	xml = N'<TagList />'

select sf.fTagList#SetTagTimes(@tagList) TagList
 
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fTagList#SetTagTimes'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		 @now											datetimeoffset(7) = sysdatetimeoffset()			-- current time (at server)
		,@newTagList							xml																					-- return value - updated tag list

	set @newTagList = 
	(
		select
			 x.TagName									'@Name'
			,isnull(x.AddedTime, @now)  '@AddedTime'														-- 2. apply current time where missing
		from
		(
			select 
				 tag.node.value('@Name'			, 'nvarchar(50)')				TagName				-- 1. parse original document
				,tag.node.value('@AddedTime', 'datetimeoffset(7)')	AddedTime
			from 
				@TagList.nodes('/TagList/Tag') as tag(node)
		) x
		for xml path('Tag'), root('TagList')																	-- 3. recast back to XML variable
	)

	return(isnull(@newTagList, @TagList))

end
GO
