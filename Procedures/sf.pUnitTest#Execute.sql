SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pUnitTest#Execute]
	 @SchemaName					nvarchar(128) = N'dbo'														-- name to search for the object in
	,@ObjectName					nvarchar(128)																			-- name of the view, procedure or function
	,@DefaultTestOnly			bit						= 0																	-- when 1, only the default test is executed
	,@ExtractTestsFirst		bit						= 1																	-- when 1, test is extracted from source before executing
as
/*********************************************************************************************************************************
Procedure Unit Test Execute
Notice    Copyright © 2014 Softworks Group Inc.
Summary   Executes tests, as stored in the sf.UnitTest table, for one view, procedure or function
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)			| Month Year	| Change Summary
				 : ---------------|-------------|------------------------------------------------------------------------------------------
				 : Tim Edlund			| Feb	2014		| Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure is a utility to support the development process. It allows SQL Scripts stored into the sf.UnitTest table to be 
executed from the back-end for one object: view, procedure or function. The test syntax is normally stored to the table through 
another procedure sf.pUnitTest#Extract. By passing the @ExtractTestsFirst bit as ON, the extraction process runs before the 
execution.

This procedure can be used to execute all tests defined for that object or only the "default" test (the sunny day scenario test) 
which is useful for code generators that need to examine data sets produced in order to complete syntax creation.

Note that this procedure cannot test multiple objects and is not a replacement for the robust testing harness available in Visual 
Studio.

The procedure must be called for a specific object (view, procedure or function) by passing its name into the @ObjectName 
parameter. You may pass the schema either as part of the @ObjectName or separately through @SchemaName.  You cannot pass wild 
cards into the object name parameters.

If the procedure is unable to find any tests for the parameters provided, an error is raised.  

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Execute the default test for a specific framework procedure after first extracting its latest tests from the source code.">
		<SQLScript>
			<![CDATA[
exec sf.pUnitTest#Execute
	 @SchemaName				= N'sf'
	,@ObjectName				= N'pApplicationUser#GetApplicationGrants'
	,@DefaultTestOnly		= 1
	,@ExtractTestsFirst = 1
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.UpdateDocumentTypeTest'
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo														int = 0														-- 0 no error, <50000 SQL error, else business rule
		,@errorText													nvarchar(4000)										-- message text (for business rule errors)
		,@blankParm													varchar(50)												-- tracks if any required parameters are not provided
		,@ON																bit = cast(1 as bit)							-- constant for bit comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for bit comparisons
		,@maxRow														int																-- loop limiter - objects to process from @Work
		,@i																	int																-- loop index - next object to process
		,@TestName													nvarchar(65)											-- name of next test to execute
		,@SQLScript													nvarchar(max)											-- next script to execute
		,@nextTestName											nvarchar(65)											-- name of next test to execute
		,@nextSQLScript											nvarchar(max)											-- next script to execute

	declare
		@work															table																-- captures list of tests to process
		(
			 ID															int								identity(1,1)
			,TestName												nvarchar(65)			not null
			,SQLScript											nvarchar(max)			not null
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

		-- extract the syntax for the test from the object's source code
		-- and store it into the sf.UnitTest and sf.UnitTestAssertion tables

		if @ExtractTestsFirst = @ON
		begin

		exec sf.pUnitTest#Extract
			 @SchemaName	= @SchemaName
			,@ObjectName	= @ObjectName
		end

		-- retrieve tests for processing

		insert
			@work	
		(
			 TestName
			,SQLScript
		)
		select
			 ut.TestName
			,ut.SQLScript
		from
			sf.UnitTest ut
		where
			ut.SchemaName = @SchemaName
		and
			ut.ObjectName = @ObjectName
		and
			(ut.IsDefault = @ON	or @DefaultTestOnly = @OFF)
		order by
			 ut.UnitTestSID

		set	@maxRow = @@rowcount
		set @i			= 0

		if @maxRow = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'ObjectNotFound'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The database object "%1.%2" was not found in the database. The object may have not have been deployed or the name is incorrect.'
				,@Arg1					= @SchemaName
				,@Arg2					= @ObjectName

			raiserror(@errorText, 16, 1)
		end

		-- process each test

		while @i < @maxRow
		begin

			set @i += 1

			select
				 @TestName		= w.TestName
				,@SQLScript		= w.SQLScript								-- script to execute as the test
			from
				@work	w
			where
				w.ID = @i

			exec sp_executesql 
				@stmt = @SQLScript

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
