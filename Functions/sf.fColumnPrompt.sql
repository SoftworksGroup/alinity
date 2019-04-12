SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fColumnPrompt]
	(
	 @SchemaName					nvarchar(128)																			-- name of the schema owning the table column is in
	,@EntityName					nvarchar(128)																			-- name of the entity (table) associated with column
	,@ColumnName					nvarchar(128)																			-- entity view column to retrieve prompt text for
	)
returns nvarchar(512)
as
/*********************************************************************************************************************************
Function: Column Prompt
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the help text stored in the dictionary for the given column
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to generate default prompt text for dynamically generated screens and for use in code generation.  The 
function relies on the column description property stored in the dictionary.  According to Softworks and Alinity database 
modeling standards, column descriptions begin with help prompt text for displaying to end users. This text is intended to advise
end users what to enter into the column value or a description of it if the column is typically read only.  Additional technical
text describing the column may be added but must be separated from the help prompt text with a pipe "|" character.  This function 
returns the help text portion of the description only and ensures it begins with an upper case character.

This function is typically called by queries which combine column labels and column headings into XML snippets which are then
stored into project resource files as XML.  It is possible to override the default help prompt for specific languages and 
client-preferred terminology by editing the resource files.  NOTE - it is not best practice to change default help prompt test
in this function.  It is much better to improve help text generally by editing the description directly in the data model, or 
in the default help prompt generators of the "DBStudio" project which create them.

The @SchemaName and @EntityName parameter are required to ensure the correct help text is retrieved. 


Example:
--------


<TestHarness>
  <Test Name="fColumnPromptTest" IsDefault="true" Description="Exercies the fColumnPrompt function with
	a randomly selected table">
    <SQLScript>
      <![CDATA[
declare
	@TableName varchar(100)

select --top (1)
	@TableName = vw.TABLE_NAME 
from 
	INFORMATION_SCHEMA.VIEWS vw 
join
	sf.vApplicationEntity ae on vw.TABLE_SCHEMA + '.' + + substring(vw.TABLE_NAME, 2, 127) =  ae.ApplicationEntitySCD
where
	vw.TABLE_SCHEMA like 'sf'
order by
	NEWID() 


select top (1)
	 vc.SchemaName
	,vc.ViewName
	,vc.ColumnName
	,sf.fColumnLabel(t.TableName, vc.ColumnName)														ColumnLabel
	,sf.fColumnHeading(t.TableName, vc.ColumnName)													ColumnHeading
	,sf.fColumnPrompt(t.SchemaName, t.TableName, vc.ColumnName)							ColumnPrompt
	,vc.SchemaName + '.' + substring(vc.ViewName, 2, 127)
from
	sf.vViewColumn				vc
join
	sf.vApplicationEntity ae on vc.SchemaName + '.' + substring(vc.ViewName, 2, 127) = ae.ApplicationEntitySCD
join
	sf.vTable	t	 on ae.ApplicationEntitySCD = t.SchemaAndTableName
where
	vc.SchemaName = 'sf'
and
	vc.ViewName like @TableName

]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fColumnPrompt'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		 @ColumnPromptOut					nvarchar(512)							                  -- string to return; help prompt
		,@i												int																					-- string index position

	select																																	-- lookup description text for view column from dictionary	
		@ColumnPromptOut = vc.[Description]
	from
		sf.vViewColumn vc
	where
		vc.SchemaName = @SchemaName
	and
		vc.ViewName = N'v' + @EntityName
	and
		vc.ColumnName = @ColumnName

	-- if the description is not found in the view dictionary, look it up in table view

	if @@rowcount = 0
	begin

		select																																	-- lookup description text for view column from dictionary	
			@ColumnPromptOut = tc.[Description]
		from
			sf.vTableColumn tc
		where
			tc.SchemaName = @SchemaName
		and
			tc.TableName = @EntityName
		and
			tc.ColumnName = @ColumnName

		-- if no text is found, parameters provided are invalid

		if @@rowcount = 0  set @ColumnPromptOut = '[Column not found: ' + isnull(@SchemaName, '<NULL>') + '.' + isnull(@EntityName, '<NULL>') + '.' + isnull(@ColumnName, '<NULL>') + ']'

	end

	set @i = charindex( N'|', @ColumnPromptOut)																												-- check for pipe character and truncate at that point if found

	if isnull(@i,0) > 0 set @ColumnPromptOut = left(@ColumnPromptOut, @i - 1)

	set @ColumnPromptOut = upper(left(@ColumnPromptOut, 1)) + substring(@ColumnPromptOut, 2, 511)			-- ensure first character is uppercase	

	return(ltrim(rtrim(@ColumnPromptOut)))
	
end
GO
