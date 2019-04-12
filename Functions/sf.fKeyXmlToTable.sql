SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fKeyXmlToTable]
(
	@xml							xml
)
returns @RecordKeys	table
(
	RecordKey				int
)
as
/*********************************************************************************************************************************
TableF	: KeyXML document to Table
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Converts an XML document of key (SID) values table rows of integer SID (record key) values 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng		  | Feb 2015		  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function parses the XML document provided into a table of integer record keys. The parsing method looks for a "SID" 
attribute only. The attribute may appear at any level in the XML document. If no SID attribute exists, an empty table is returned.

The standard XML format expected for the XML document is:

<Templates>														-- note that "Template" may be any identifier but the "SID" attribute is required!
	<Template SID="1000001"/>
	<Template SID="1000002"/>
</Templates>

---------------------------------

<TestHarness>
	<Test Name = "Simple" IsDefault ="true" Description="Select out two parameters">
		<SQLScript>
			<![CDATA[

declare @xml xml = N'
	<Templates>
		<Template SID="1000001"/>
		<Template SID="1000002"/>
	</Templates>'

declare
	@work table
	(
		 ID					int identity(1,1)
		,RecordKey	int	not null
	)

insert 
	@work 
(
	RecordKey
)
select
	x.RecordKey
from
	sf.fKeyXmlToTable(@xml) x

select * from @work

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="2" />
			<Assertion Type="ExecutionTime" Value="00:00:01"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fKeyXmlToTable'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	insert
		@RecordKeys
	select
		list.item.value('@SID[1]', 'int')  RecordKey
	from
		@xml.nodes('//*') as list(item) 
	where
		list.item.value('@SID[1]', 'int') is not null
	order by 
		1 

	return

end
GO
