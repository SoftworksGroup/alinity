SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vPersonGroup#TagList
/*********************************************************************************************************************************
View		: Person Group - Tag List
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns tags reported for a group as a comma separated list
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides a flattened text list of tags parsed from the TagList xml column.

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of records selected at random.">
	<SQLScript>
	<![CDATA[

select top(10) x.* from	sf.vPersonGroup#TagList x

if @@rowcount = 0 
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vPersonGroup#TagList'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	x.PersonGroupSID
 ,substring((
							select
								',' + Tag.t.value('@Name', 'nvarchar(50)') as [text()]
							from
								sf.PersonGroup											pg
							outer apply pg.TagList.nodes('//Tag') Tag(t)
							where
								pg.PersonGroupSID = x.PersonGroupSID
							for xml path('')
						)
						,2
						,1000
					 ) Tags
from
	sf.PersonGroup x;
GO
