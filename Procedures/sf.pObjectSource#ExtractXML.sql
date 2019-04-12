SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pObjectSource#ExtractXML]
	 @SchemaName					nvarchar(128)		= N'dbo'													-- schema where object is located (or in @ObjectName)
	,@ObjectName					nvarchar(257)																			-- name of view or procedure, may contain schema prefix
	,@Root								varchar(50)																				-- XML base tag that marks start and end of section
	,@IgnoreMissingXML		bit							= 0																-- when 1, missing XML is ignored - NULL is returned
	,@XMLDoc							xml							output														-- XML document containing content between root tags
as
/*********************************************************************************************************************************
Procedure	: Extract XML From Object Source code
Notice		: Copyright © 2012 Softworks Group Inc.
Summary		: Returns an XML document extracted from header comments defined in a view, stored procedure of function definition
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Feb		2014  |	Initial version
					: Tim Edlund	| Jul		2014	| Corrected intermittent bug caused by not creating the output XML in source line number 
																				order. Also added fully qualified object name reference for extracting source code 
																				(includes DB name) to ensure same object in other databases was not selected.

Comments	
--------
This is a utility procedure that locates XML content found between code tag markers in object source code. The object source code
is read from the SQL Server dictionary and must not be encrypted.  The XML, if found, is returned as an output variable. The 
procedure is used by generators to extract syntax - e.g. sf.pUnitTest#Extract. 

The @Root is automatically expanded to match the format of code tag pairs used in source code.  For example, if the code tag 
base "TestHarness" is passed for a view object, the procedure searches for the lines of code between 'Test Harness' in  angle 
brackets (see example below)

Everything between the tags must use valid XML syntax except that the TSQL in line comment characters "--" may prefix any line
including the lines that have the XML tags on them. To avoid escaping script sections, use the CDATA tag.  Refer to the Example 
section below, which shows the correct format for specifying unit tests that can be parsed for execution in a product test 
harness. 

Example:
--------
<TestHarness>
  <Test Name="pObjectSourceExtractXMLTest" IsDefault="true" Description="Parses test information from a framework sproc.  
	No data set returned.">
    <SQLScript>
      <![CDATA[
 
declare
	@XMLDoc			xml

exec sf.pObjectSource#ExtractXML
		 @ObjectName = N'sf.pApplicationUser#GetApplicationGrants'
		,@Root			= 'TestHarness'
		,@XMLDoc		= @XMLDoc output

]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02" />
    </Assertions>
  </Test>
  <Test Name="pObjectSourceExtractXMLCheckForUnitTests" Description="Parses test information from a framework sproc and selects 
	tests and assertions out of returned XML document.">
    <SQLScript>
      <![CDATA[
 
declare
	@testHarness			xml

exec sf.pObjectSource#ExtractXML
		 @ObjectName = N'sf.pApplicationUser#GetApplicationGrants'
		,@Root			= 'TestHarness'
		,@XMLDoc		= @testHarness output
    
;with cteTest as
(
	select 
		 Test.node.value('@Name'					, 'nvarchar(35)')						        TestName
		,Test.node.value('@IsDefault'			, 'bit')										        IsDefault
		,Test.node.value('@Description'		, 'nvarchar(max)')					        UsageNotes
		,Test.node.query('./SQLScript')																        SQLScript
	from
		@testHarness.nodes('TestHarness/Test') as Test(node) 	
)
,cteTestItem as
(
	select																														      -- extract each Test item attribute from the XML node
		 t.TestName
		,t.IsDefault
		,t.UsageNotes
		,t.SQLScript.value( '(.)'		, 'nvarchar(max)')								        SQLScript
	from
		cteTest t
)
select 
	 ti.TestName
	,ti.IsDefault
	,ti.UsageNotes
	,ti.SQLScript
from
	cteTestItem ti

;with cteTestAssertion as
(
	select 
		 a.node.value('@Type', 'varchar(25)')																	AssertionType
		,a.node.value('@ResultSet', 'int')																		ResultSet
		,a.node.value('@Row', 'int')																					RowNo
		,a.node.value('@Column', 'int')																				ColumnNo
		,a.node.value('@Value', 'nvarchar(1000)')															Value
	from
		@testHarness.nodes('TestHarness/Test/Assertions/Assertion') as a(node) 	
)

select 
	 ta.AssertionType
	,ta.ResultSet
	,ta.RowNo
	,ta.ColumnNo
	,ta.Value
from
	cteTestAssertion ta
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pObjectSource#ExtractXML'
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin	

	declare
		 @errorNo 													int = 0														-- 0 no error, if <50000 SQL error, else business rule
		,@errorText 												nvarchar(4000)										-- message text (for business rule errors)
		,@trace															nvarchar(1000)										-- debug tracing
		,@blankParm													varchar(100)											-- tracks blank values in required parameters
		,@ON																bit = cast(1 as bit)							-- constant for bit comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for bit comparisons
		,@TAB																nchar(1) = nchar(9)								-- constant for tab character
		,@i																	smallint													-- index position in string
		,@startLine													int	= 0														-- starting source line# for retrieved source section
		,@endLine														int = 0														-- ending source line# for retrieved source section
		,@objectOnly												nvarchar(128)											-- object name without the schema prefix
		,@fullObjectName										nvarchar(256)											-- object name including database and schema
		,@content														nvarchar(max)											-- XML document in string format

	declare 
		@source															table															-- table to hold retrieved source code lines
		( 
			 SourceLineNo											int	identity(1,1)
			,LineContent											nvarchar(4000)			not null
		)

	set @XMLDoc  = null

	begin try

		-- check parameters

		if @ObjectName	is null set @blankParm = '@ObjectName'
		if @Root				is null set @blankParm = '@Root'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm
			
			raiserror(@errorText, 18, 1)
		end

		if @IgnoreMissingXML is null set @IgnoreMissingXML = @OFF

		-- if no schema is included with the object name, nor passed explicitly, assume "dbo"

		set @i = charindex('.', @ObjectName)

		if isnull(@i,0) = 0
		begin
			if @SchemaName is null set @SchemaName = N'dbo' 
			set @objectOnly = convert(nvarchar(128), @ObjectName)
			set @ObjectName	= @SchemaName + '.' + @objectOnly
		end
		else
		begin
			set @SchemaName = left(@ObjectName, @i - 1)
			set @objectOnly	= replace(@ObjectName, @SchemaName + N'.', '')
		end

		-- raise an error if the object cannot be found

		if not exists 
		(
			select 
				1 
			from 
				sys.objects so
			join
				sys.schemas sc on so.schema_id = sc.schema_id
			where 
				so.name = @objectOnly
			and
				sc.name = @SchemaName
		) 
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'ObjectNotFound'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The database object "%1.%2" was not found in the database. The object may have not have been deployed or the name is incorrect.'
				,@Arg1					= @SchemaName
				,@Arg2					= @ObjectName

			raiserror(@errorText, 16, 1)

		end

		-- ensure root word does not include tag markers then extract the
		-- source code to the memory table for further processing

		set @Root = ltrim(rtrim(@Root))
		if left(@Root, 1)		= N'<' set @Root = ltrim(substring(@Root, 2, 49))
		if right(@Root, 1)	= N'>' set @Root = ltrim(left(@Root, len(@Root) - 1))

		set @fullObjectName = db_name() + '.' + @SchemaName + '.' + @objectOnly

		insert @source
		exec sys.sp_helptext @objname = @fullObjectName

		select top (1) @startLine = SourceLineNo from @source where LineContent like N'%<' + @Root + '%>%'
		select top (1) @endLine		= SourceLineNo from @source where LineContent like N'%</'+ @Root + '>%'

		-- if the root tag is not found, raise an error unless missing XML
		-- is to be ignored (parameter setting)

		if isnull(@startLine, 0) = 0 or isnull(@endLine, 0) = 0 
		begin

			if @IgnoreMissingXML = @OFF
			begin

				set @ObjectName = replace(@ObjectName, @SchemaName + N'.', '')

				exec sf.pMessage#Get
					 @MessageSCD  	= 'TagNotFoundInSource'
					,@MessageText 	= @errorText output
					,@DefaultText 	= N'The XML tag "%1" was not found in "%2.%3".'
					,@Arg1					= @Root
					,@Arg2					= @SchemaName
					,@Arg3					= @ObjectName

				raiserror(@errorText, 16, 1)

			end

			-- otherwise just return NULL output variable

		end
		else																																	-- tag was found, continue processing
		begin

			delete																															-- remove source lines that will not be converted to XML
				@source
			where
				SourceLineNo > @endLine
				or
				SourceLineNo < @startLine

			set @i = 1

			while @i > 0																												-- remove spaces and tabs from between opening comment
			begin																																-- and tag markers (tags MUST be on separate lines)
																																					-- CDATA ending tag must be on separate line as well!
				update
					@source
				set 
					LineContent = 
					case
						when ltrim(LineContent) like N'-- %<%'						then replace(ltrim(LineContent), N'-- ', N'--')
						when ltrim(LineContent) like N'--' + @TAB + '%<%' then replace(ltrim(LineContent), N'--' + @TAB, N'--')
						when ltrim(LineContent) like N'--]]>%'						then replace(ltrim(LineContent), N'--]]>', N']]>')		
						else LineContent
					end
				where
					ltrim(LineContent) like N'-- %<%'								
				or
					ltrim(LineContent) like N'--' + @TAB + '%<%' 
				or
					ltrim(LineContent) like N'--]]>%'													

				set @i = @@rowcount

			end

			update
				@source
			set
				LineContent = substring(LineContent, 3, 3997)
			where
				LineContent like N'--<%'
			
			select 
				@content =  isnull(@content, N'') + LineContent
			from 
				@source
			order by 
				SourceLineNo

			set @XMLDoc = cast(@content as xml)

		end
					
	end try

	begin catch
		if @ObjectName is not null exec sf.pLinePrint @ObjectName							-- this helps to let the developer know which object caused the error. 
		if @content is not null exec sf.pLinePrint @content										-- print content being converted to XML for debugging
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
