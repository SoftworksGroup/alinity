SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pUnitTest#Extract]
	 @SchemaName					nvarchar(128) = N'dbo'														-- name to search for the object in
	,@ObjectName					nvarchar(128)																			-- name of the view, procedure or function
	,@ObjectType					varchar(10)		= '*'																-- "view", "procedure", "function" to extract all
as
/*********************************************************************************************************************************
Procedure: Unit Test Extract (from object source code)
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Parses unit tests from header comments in object definitions and stores them to sf.UnitTest and sf.UnitTestAssertion
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)			| Month Year	| Change Summary
				 : -------------- + ----------- + ----------------------------------------------------------------------------------------
				 : Tim Edlund			| Feb	2014		| Initial version
				 : Adam Panter		| May 2014		| Updated to support test extensions section
				 : Tim Edlund			| Nov 2014		| Added default "Value" for empty result set assertion
				 : Tim Edlund			| Jan 2018		| Updated documentation and added test scenario to extract all from SF, DBO and STG
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure is a utility to support the development process. The procedure retrieves the source code for the object(s) 
specified in the parameter and extracts comment lines from the header that define tests and assertions. The tests are then stored 
into the sf.UnitTest and sf.UnitTestAssertion tables.  From there tests can be executed from the database tier using 
sf.pUnitTest#Execute.  The primary use of the extracted tests, however, is to deliver their content into DB Unit Testing project
classes managed in Visual Studio. This approach allows good call syntax example to be created and tested from the database, and 
that same content can then be leveraged to apply to the DB testing harness which become part of an automated build process.

The syntax this procedure is able to extract is very specific.  An example of it appears below.  The format is XML but within
a TSQL comment block so that the tests can be easily cut and pasted into SSMS and other tools for quick "one off" testing during 
the development process and after changes are made.  Note that the "Assertions" section is used to tell the testing project what 
results are expected from each test. 

If you receive errors from this procedure as it attempts to extract content into the XML document, it is often easiest to debug
by pasting the content from the object script into an XML editor.  Most errors arise from syntax problems in the XML tags.

Once the content has been extracted as a valid XML document, it is inserted into the sf.UnitTest and sf.UnitTestAssert tables. 
Where previous tests exist they are replaced. Business rules are defined on the sf.UnitTest and sf.UnitTestAssertion tables to 
check for valid test types and assertion parameters. Note that only test types supported by Visual Studio database unit testing 
projects are allowed.  Some Visual Studio supported tests involving complex parameters are not supported. For example, in this 
version the "Expected Schema" test type is not supported.

The procedure can be called for a specific object (view, procedure or function) by passing its name as the @ObjectName parameter.
You may pass the schema either as part of the @ObjectName or separately through @SchemaName.  If you want to extract tests for 
multiple objects, you must pass the @ObjectName using wild card characters. For example @ObjectName = '%' will extract tests for
all objects in the specified schema.  If you wish to restrict objects to a type - pass the type into @ObjectType along with the 
wild card in @ObjectName.  For example - passing:
 
	 @SchemaName = 'sf'
	,@ObjectName = '%ApplicationUser%'
	,@ObjectType = 'procedure'

... results in all stored procedures in the SF schema including "ApplicationUser" in their names to be processed.

Note that if no test is defined for an object, and only a single object name has been specified, then the procedure returns an
error. If however a wild card has been used in the @ObjectName and multiple objects are being processed, if one or more of them 
does not have test syntax included in their definition no error is raised.  This is important since any errors raised stop 
processing of other objects.

Default test.  For each object a "default" test should be designated using the IsDefault="true" attribute in the code. The
default test should be constructed for a typical "sunny day scenario" - where typical parameter settings are provided.  If no
test is defined as the default in the test syntax, this procedure marks the FIRST test encountered as the default. Default test
are required by some code generators that need to examine typical result sets returned by procedures.

Example
-------
The format of tests expected by this procedure is shown below. 

<TestHarness>
  <Test Name="Simple" IsDefault="true" Description="Default test to parse tests into sf.UnitTest and sf.UnitTestAssertion. 
	No output">
    <SQLScript>
      <![CDATA[

exec sf.pUnitTest#Extract
	 @SchemaName = 'sf'
	,@ObjectName = 'pUnitTest#Extract'

]]>
    </SQLScript>
    <Assertions> 
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1"/>
    </Assertions>
  </Test>

  <Test Name="InvalidObjectName" Description="Ensures the procedure returns an error if the object provided is invalid">
    <SQLScript>
      <![CDATA[
begin try

exec sf.pUnitTest#Extract
	 @SchemaName = 'sf'
	,@ObjectName = 'pThis-Is-An-Invalid-Object-Name'

end try
begin catch

	select 
		'ERROR'						TestResult
		,error_number()		ErrorNo
		,error_message()	ErrorMessage

end catch
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="ERROR" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="50000" />
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1"/>
    </Assertions>
  </Test>

  <Test Name="ReturnTests" Description="Returns to result sets - the tests created and the assertions for each test">
    <SQLScript>
      <![CDATA[
exec sf.pUnitTest#Extract
		@SchemaName = 'sf'
	,@ObjectName = 'pUnitTest#Extract'

select * from sf.vUnitTest					ut	where ut.SchemaName		= 'sf' and ut.ObjectName	= 'pUnitTest#Extract'
select * from sf.vUnitTestAssertion uta where uta.SchemaName	= 'sf' and uta.ObjectName	= 'pUnitTest#Extract'
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value = "3"/>
      <Assertion Type="RowCount" ResultSet="2" Value = "7"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1"/>
    </Assertions>
  </Test>
  <Test Name="ExtractAll" Description="Extracts all tests from sf, dbo, and stg schemas then list tests with assertion counts.">
    <SQLScript>
      <![CDATA[
exec sf.pUnitTest#Extract
		@SchemaName = 'sf'
	,@ObjectName = '%'

exec sf.pUnitTest#Extract
	 @SchemaName = 'dbo'
	,@ObjectName = '%'

exec sf.pUnitTest#Extract
	 @SchemaName = 'stg'
	,@ObjectName = '%'

select
	ut.SchemaName + '.' + ut.ObjectName TestObject
 ,ut.TestName
 ,uta.Assertions
from
	sf.UnitTest ut
join
(
	select
		uta.UnitTestSID
	 ,count(1) Assertions
	from
		sf.UnitTestAssertion uta
	group by
		uta.UnitTestSID
)							uta on ut.UnitTestSID = uta.UnitTestSID
order by
	ut.SchemaName
 ,ut.ObjectName;
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:01:25"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pUnitTest#Extract'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on

  declare
 		 @errorNo														int = 0														-- 0 no error, <50000 SQL error, else business rule
		,@errorText													nvarchar(4000)										-- message text (for business rule errors)
		,@blankParm													varchar(50)												-- tracks if any required parameters are not provided
		,@ON																bit = cast(1 as bit)							-- constant for bit comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for bit comparisons
		,@maxRow														int																-- loop limiter - objects to process from @Work
		,@i																	int																-- loop index - next object to process
		,@nextObjectName										nvarchar(128)											-- name of next object to process
		,@nextObjectType										varchar(10)												-- type of object - e.g. view, procedure or function
		,@testHarness												xml																-- XML document to parse 
		,@ignoreMissingXML									bit = cast(0 as bit)							-- whether to ignore missing test definition (see above)
		,@defaultTestSID										int																-- captures system ID of the default test for the object

	declare
		@work															table																-- captures list of objects to process
		(
			 ID															int								not null identity(1,1)
			,SchemaName											nvarchar(128)			not null
			,ObjectName											nvarchar(128)			not null
			,ObjectType											varchar(10)				not null
		)

	declare
		@unitTest													table																-- captures parsed XML to insert to sf.UnitTest
		(
			 TestName												nvarchar(35)			not null
			,IsDefault											bit								not null
			,UsageNotes											nvarchar(max)			null
			,SQLScript											nvarchar(max)			not null	
			,Assertions											xml								null
		)

	declare
		@unitTestAssertion								table																-- captures parsed XML to insert to sf.UnitTestAssertion
		(
			 TestName												nvarchar(35)			not null
			,AssertionType									varchar(25)				not null
			,ResultSet											tinyint						null
			,RowNo													tinyint						null
			,ColumnNo												tinyint						null
			,Value													nvarchar(1000)		null
		)

	begin try
		
		-- check parameters

		if @ObjectName is null set @blankParm = 'ObjectName'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end    

		if @ObjectType = 'sproc'	set @ObjectType = 'procedure'
		if @ObjectType = 'fcn'		set @ObjectType = 'function'

		if @ObjectType is not null and @ObjectType not in ('*', 'view', 'procedure', 'function')
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'NotInList'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The %1 entered "%2" is not valid. It must be one of: %3'
				,@Arg1					= 'object type'
				,@Arg2					= @ObjectType
				,@Arg3					= '"procedure", "function", "view", or "*" for any'
			
			raiserror(@errorText, 16, 1)

		end

		if @ObjectType is null set @ObjectName = N'*'													-- no restrictions on object type

		-- if no schema is included with the object name, nor passed explicitly, assume "dbo"

		set @i = charindex('.', @ObjectName)

		if isnull(@i,0) = 0
		begin
			if @SchemaName is null set @SchemaName = N'dbo' 
		end
		else
		begin
			set @SchemaName = left(@ObjectName, @i - 1)
			set @ObjectName	= replace(@ObjectName, @SchemaName + N'.', '')
		end

		-- retrieve matching object names and load them into the
		-- work table for processing

		insert
			@work	
		(
			 SchemaName
			,ObjectName
			,ObjectType
		)
		select
			 x.SchemaName
			,x.ObjectName
			,x.ObjectType
		from
		(
			select
				 v.SchemaName
				,v.ViewName																												ObjectName		
				,'view'																														ObjectType
			from
				sf.vView	v
			where
				(@ObjectType = 'view' or @ObjectType = '*')
			and
				v.SchemaName = @SchemaName
			and
				v.ViewName like @ObjectName
			union
			select
				 r.SchemaName
				,r.RoutineName																										ObjectName	
				,'procedure'																											ObjectType
			from
				sf.vRoutine r
			where
				(@ObjectType = 'procedure' or @ObjectType = '*')
			and
				r.SchemaName = @SchemaName
			and
				r.RoutineType = 'PROCEDURE'
			and
				r.RoutineName like @ObjectName
			union
			select
				 r.SchemaName
				,r.RoutineName																										ObjectName
				,'function'																												ObjectType
			from
				sf.vRoutine r
			where
				(@ObjectType = N'function' or @ObjectType = '*')
			and
				r.SchemaName = @SchemaName
			and
				r.RoutineType = 'FUNCTION'
			and
				r.RoutineName like @ObjectName
		) x
		order by
			 x.ObjectType
			,x.ObjectName

		set	@maxRow = @@rowcount
		set @i			= 0

		if @maxRow = 0
		begin

			if @ObjectType <> '*' set @ObjectName = cast(@ObjectName + N' (' + @ObjectType + ')' as nvarchar(128))

			exec sf.pMessage#Get
				 @MessageSCD  	= 'ObjectNotFound'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The database object "%1.%2" was not found in the database. The object may have not have been deployed or the name is incorrect.'
				,@Arg1					= @SchemaName
				,@Arg2					= @ObjectName

			raiserror(@errorText, 16, 1)

		end

		if @maxRow > 1 set @ignoreMissingXML = cast(1 as bit)									-- if multiple objects specified - ignore missing tests

		while @i < @maxRow
		begin

			set @i += 1
			set @testHarness = null

			delete @unitTest																										-- remove results from prior iteration
			delete @unitTestAssertion

			select
				 @nextObjectName = w.ObjectName
				,@nextObjectType = w.ObjectType
			from
				@work	w
			where
				w.ID = @i

			-- call utility to extract an XML document from the source code
			-- between the root tags <TestHarness> and </TestHarness> 

			exec sf.pObjectSource#ExtractXML																		-- NOTE: if errors occur at this step paste content printed 
					 @SchemaName				= @SchemaName																-- to the console to an XML editor for syntax checking
					,@ObjectName				= @nextObjectName
					,@Root							= 'TestHarness'
					,@XMLDoc						= @testHarness output
					,@IgnoreMissingXML	= @ignoreMissingXML

			if @testHarness is not null																					-- if no XML was returned, move onto next object
			begin																																-- note: does NOT delete any existing tests if they exist	

				-- parse the XML document with a common table expression (non-recursive)
				-- into a memory table; the memory table is used to allow the assertions XML
				-- component to remain associated with the test header in the next pass

				;with cteTest as
				(
						select 
							 Test.node.value('@Name'					, 'nvarchar(35)')					TestName
							,Test.node.value('@IsDefault'			, 'bit')									IsDefault
							,Test.node.value('@Description'		, 'nvarchar(max)')				UsageNotes
							,Test.node.query('./SQLScript')															SQLScript
							,test.node.query('./Assertions')														Assertions
						from
							@testHarness.nodes('TestHarness/Test') as Test(node) 	
					union all
						select 
							 Test.node.value('@Name'					, 'nvarchar(35)')					TestName
							,Test.node.value('@IsDefault'			, 'bit')									IsDefault
							,Test.node.value('@Description'		, 'nvarchar(max)')				UsageNotes
							,Test.node.query('./SQLScript')															SQLScript
							,test.node.query('./Assertions')														Assertions
						from
							@testHarness.nodes('TestHarness/Extensions/Test') as Test(node) 
				)
				,cteTestItem as
				(
					select																													-- extract each Test item attribute from the corresponding XML node
						 t.TestName
						,t.IsDefault
						,t.UsageNotes
						,t.SQLScript.value( '(.)'		, 'nvarchar(max)')								SQLScript
						,t.Assertions																										
					from
						cteTest t
				)
				insert
					@unitTest
				(
					 TestName		
					,IsDefault	
					,UsageNotes
					,SQLScript
					,Assertions
				)		
				select 
					 ti.TestName
					,isnull(ti.IsDefault, @OFF)
					,ti.UsageNotes
					,ti.SQLScript
					,ti.Assertions																									-- XML document (sub component)
				from
					cteTestItem ti

				-- parse the assertions component of the XML document - relate the
				-- assertions to their tests using the test name

				insert
					@unitTestAssertion
				(
					 TestName			
					,AssertionType
					,ResultSet
					,RowNo
					,ColumnNo
					,Value
				)		
				select
					 ut.TestName
					,a.node.value('@Type', 'varchar(25)')														AssertionType
					,a.node.value('@ResultSet', 'int')															ResultSet
					,a.node.value('@Row', 'int')																		RowNo
					,a.node.value('@Column', 'int')																	ColumnNo
					,a.node.value('@Value', 'nvarchar(1000)')												Value
				from
					@unitTest ut
				cross apply
					ut.Assertions.nodes('Assertions/Assertion') a(node)

				-- remove any previous tests which may have been created for the 
				-- object, then insert the new tests and associated assertions

				begin transaction

				delete																														-- remove prior tests is they exist for the object
					sf.UnitTest																											-- cascade is ON to sf.UnitTestAssertion
				where
					SchemaName = @SchemaName
				and
					ObjectName = @nextObjectName

				insert
					sf.UnitTest
				(
					 SchemaName
					,ObjectName
					,ObjectType		
					,TestName	
					,IsDefault		
					,UsageNotes
					,SQLScript
				)
				select
					 @SchemaName
					,@nextObjectName
					,@nextObjectType
					,ut.TestName			
					,ut.IsDefault
					,ut.UsageNotes
					,ut.SQLScript
				from
					@unitTest ut

				insert
					sf.UnitTestAssertion
				(
					 UnitTestSID
					,AssertionType
					,ResultSet
					,RowNo
					,ColumnNo
					,Value
				)
				select
					 ut.UnitTestSID
					,uta.AssertionType
					,isnull(uta.ResultSet, 0)
					,isnull(uta.RowNo, 0)
					,isnull(uta.ColumnNo, 0)
					,(case when uta.AssertionType = 'EmptyResultSet' then '0' else uta.Value end)							-- set Value to 0 for empty row set assertions
				from
					@unitTestAssertion uta
				join
					sf.UnitTest				 ut		on ut.SchemaName = @SchemaName and ut.ObjectName = @nextObjectName and ut.TestName = uta.TestName

				-- set the first unit test as the default for this object
				-- if none was identified as the default

				if not exists (select 1 from sf.UnitTest ut where ut.SchemaName = @SchemaName and ut.ObjectName = @nextObjectName and ut.IsDefault = @ON)
				begin

					select top(1)
						@defaultTestSID = ut.UnitTestSID
					from
						sf.UnitTest ut
					where
						ut.SchemaName = @SchemaName and ut.ObjectName = @nextObjectName 
					order by
						ut.UnitTestSID

					update
						sf.UnitTest
					set
						IsDefault = @ON
					where
						UnitTestSID = @defaultTestSID

				end

				commit

			end

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
