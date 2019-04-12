SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fFormVersion#Field]
(
	 @FormVersionSID									int																	-- primary key of FormVersion (parent row)
)
returns @formVersion#Field table
(
	 FieldGUID													nvarchar(max)										
	,Label															nvarchar(max)
	,ControlType												varchar(25)
	,IsMandatory												bit
	,ListGUID														nvarchar(50)
	,ListLabel													nvarchar(4000)
	,ListEntity													nvarchar(128)
	,ListSIDColumn											nvarchar(128)
	,ListLabelColumn										nvarchar(128)
	,EmployerVerificationRequired				bit
)
as
/*********************************************************************************************************************************
TableF	: Form Version - Fields
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Shreds form definition XML and returns field attributes as table rows
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------+---------------+-------------------------------------------------------------------------------------------
				: Cory Ng		  | Jun		2016		|	Initial Version 
				: Robin Payne	| Jan		2017		|	Test harness fixes
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

The function is used to flatten field-level information defined in the form XML, and return it as table rows. This is primarily 
a helper function for views which require a forms field attributes. The function parses the "FormDefinition" (xml) value from the 
given form version to obtain the field attributes.  

The main logic of the function is implemented through a XPath query that isolates all "Field" nodes from the template regardless
of the Tab or Section level they are found in.  That document is then parsed into nodes and the field attributes retrieved.

This function is in the DBO schema instead of the SF schema because it returns product specific form attributes (eg: 
EmployerVerificationRequired).

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the form attributes for a template at random.">
	<SQLScript>
	<![CDATA[


		select
				fvf.*
		from
			(	select top 10
					x.FormVersionSID
				from
					sf.FormVersion x
				order by
					newid()
			) fv
		cross apply
			dbo.fFormVersion#Field(fv.FormVersionSID) fvf


	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:05" />
	</Assertions>
	</Test>



------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @formDefinition		xml																								-- buffer for xml document of field information
		,@CRLF							nchar(2) = char(13) + char(10)										-- carriage return line feed for formatting text blocks
		,@TAB								nchar(1)	= char(9)																-- tab character for formatting text blocks
		,@ON								bit				= cast(1 as bit)												-- used on bit comparisons to avoid multiple casts
		,@OFF								bit				= cast(0 as bit)												-- used on bit comparisons to avoid multiple casts
	
	select
		@formDefinition	= fv.FormDefinition
	from
		sf.FormVersion		fv 
	where
		fv.FormVersionSID = @FormVersionSID

	insert 
		@formVersion#Field
	(			
		 FieldGUID							
		,Label
		,ControlType
		,IsMandatory
		,ListGUID
		,ListLabel
		,ListEntity
		,ListSIDColumn
		,ListLabelColumn
		,EmployerVerificationRequired
	)
	select
		 fd.FieldGUID
		,fd.Label
		,fd.ControlType
		,case when fd.IsMandatory = 'true' then @ON else @OFF end
		,fd.ListGUID
		,l.ListLabel
		,l.ListEntity
		,l.ListSIDColumn
		,l.ListLabelColumn
		,case when fd.EmployerVerificationRequired = 'true' then @ON else @OFF end	

	from
	(
		select
			 Field.node.value('@GUID', 'nvarchar(max)')															FieldGUID
			,Field.node.value('@Type', 'varchar(25)')																ControlType
			,Field.node.value('@IsMandatory', 'varchar(5)')													IsMandatory
			,Field.node.value('@ListGUID', 'nvarchar(max)')													ListGUID
			,Field.node.value('@data-require-employer-verification', 'varchar(5)')	EmployerVerificationRequired
			
			,replace(replace(Field.node.query('./Label').value('.', 'nvarchar(max)'), @CRLF, ''), @TAB, '')		Label
		from   
			@formDefinition.nodes('//Field') Field(node)  
	) fd
	left outer join
	(
		select
			 ListItem.node.value('@GUID', 'varchar(50)')						ListGUID
			,ListItem.node.value('@Label', 'varchar(50)')						ListLabel
			,ListItem.node.value('@Entity', 'varchar(128)')					ListEntity
			,ListItem.node.value('@SIDColumn', 'varchar(128)')			ListSIDColumn
			,ListItem.node.value('@LabelColumn', 'varchar(128)')		ListLabelColumn
		from   
			@formDefinition.nodes('//List') ListItem(node)  

	) l on isnull(fd.ListGUID, '~') = l.ListGUID 
	return

end
GO
