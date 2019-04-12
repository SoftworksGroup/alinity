SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormVersion#ListItem]
(
	 @FormVersionSID									int																	-- primary key of FormVersion (parent row)
)
returns @formVersion#ListItem table
(
	 ListGUID													nvarchar(max)					
	,ListLabel												nvarchar(max)
	,[IsNumeric]											bit
	,Label														nvarchar(max)
	,Value														nvarchar(max)
	,IsExclusiveForMultiSelect				bit
	,ToolTip													nvarchar(max)
)
as
/*********************************************************************************************************************************
TableF	: Form Version - List Items
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Shreds form definition XML and returns list item attributes as table rows
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng		  | Jun		2016	  |	Initial Version 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

The function is used to flatten list-item-level information defined in the form definition XML, and return it as table rows.  
This function is used to get the label of the list item for a response. This function does not return all list items for
table lookup lists.

The main logic of the function is implemented through a XPath query that isolates all "Item" nodes from the form regardless
of the List they are found in. The parent node is looked up to get the list GUID and label. That document is then parsed into 
nodes and the list item attributes retrieved.


<TestHarness>
	<Test Name = "Simple" Description="Returns the top (1) episodes.">
	<SQLScript>
	<![CDATA[

		select top (1)							
				svlt.*				
		from 
			sf.FormVersion fv
		cross apply
			sf.fFormVersion#ListItem(fv.FormVersionSID) svlt
		order by
			newid()

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
		<Assertion Type="ExecutionTime" Value="00:00:05" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fFormVersion#ListItem'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @formDefinition		xml																								-- buffer for xml document of field information
		,@ON								bit				= cast(1 as bit)												-- used on bit comparisons to avoid multiple casts
		,@OFF								bit				= cast(0 as bit)												-- used on bit comparisons to avoid multiple casts
	
	select
		@formDefinition	= fv.FormDefinition
	from
		sf.FormVersion		fv 
	where
		fv.FormVersionSID = @FormVersionSID

	insert 
		@formVersion#ListItem
	(			
		 ListGUID							
		,ListLabel
		,[IsNumeric]
		,Label
		,Value
		,IsExclusiveForMultiSelect
		,ToolTip
	)
	select
		 fd.ListGUID
		,fd.ListLabel
		,case when fd.[IsNumeric] = 'true' then @ON else @OFF end
		,fd.Label
		,fd.Value
		,case when fd.IsExclusiveForMultiSelect = 'true' then @ON else @OFF end	
		,fd.ToolTip
	from
	(
		select
			 List.node.value('../@GUID', 'nvarchar(max)')										ListGUID
			,List.node.value('../@Label', 'nvarchar(max)')									ListLabel
			,List.node.value('../@IsNumeric', 'varchar(5)')									[IsNumeric]
			,List.node.value('@Label', 'nvarchar(max)')											Label
			,List.node.value('@Value', 'nvarchar(max)')											Value	
			,List.node.value('@IsExclusiveForMultiSelect', 'varchar(5)')		IsExclusiveForMultiSelect	
			,List.node.value('@ToolTip', 'nvarchar(max)')										ToolTip
		from   
			@formDefinition.nodes('//Item') List(node)  
	) fd
	return

end
GO
