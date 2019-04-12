SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pQuery#CheckCodes
	@ApplicationEntitySCD nvarchar(257) -- reference to query setup data in sf.Query
 ,@SchemaAndRoutineName nvarchar(257) -- quick search subroutine to return query codes for
 ,@SetupSprocName				nvarchar(257) -- name of the setup procedure
as
/*********************************************************************************************************************************
Sproc		: Returns query codes from the quick-search subroutine passed in
Notice	: Copyright © 2018 Softworks Group Inc.
Summary	: Returns a data set of query codes found in the sf.Query table and quick search subroutine defined for the entity
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This is a utility procedure used to validate that the query codes references in a setup sproc for a given entity are matched
one-for-one by query syntax statements in a given stored procedure.  The procedure is heavily dependent on the formatting of
the source code in the querying subroutine.  Specifically, an "IF" or "ELSE IF" statement checking a parameter named @QueryCode 
must appear at the start of the line and the query code value itself must begin with "S!" - e.g. 

if @QueryCode = 'S!PU.MY.QUERY' -- comment here is ignored

Spaces appearing anywhere in the line are ignored as is casing.  Comments appearing at the end of the line are ignored.

The procedure compares the parsed query codes to the query codes related to the @ApplicationEntitySCD passed in. If any
discrepancies are found between the 2 sets of codes, an error is raised.  The procedure returns and a data set including
all codes found in the setup procedure and sf.Query table for the given entity.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for a quick search subroutine selected at random.">
	<SQLScript>
	<![CDATA[

declare
	@applicationEntitySCD nvarchar(257)
 ,@schemaAndRoutineName nvarchar(257)
 ,@setupSprocName				nvarchar(257);

select top (1)
	@schemaAndRoutineName = r.SchemaAndRoutineName
from
	sf.vRoutine r
where
	r.RoutineName like 'pQuickSearch$%' and r.SchemaName = 'dbo'
order by
	newid();

if @@rowcount = 0 or @schemaAndRoutineName is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @applicationEntitySCD = replace(@schemaAndRoutineName, 'pQuickSearch$', '');
	set @setupSprocName = N'dbo.pSetup$SF#Query$' + replace(replace(@schemaAndRoutineName, 'pQuickSearch$', ''), 'dbo.', '');

	exec sf.pQuery#CheckCodes
		@ApplicationEntitySCD = @applicationEntitySCD
	 ,@SchemaAndRoutineName = @schemaAndRoutineName
	 ,@SetupSprocName = @setupSprocName;

end;

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pQuery#CheckCodes'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0					-- 0 no error, if <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000);	-- message text (for business rule errors)

	declare @source table -- table to hold retrieved source code lines
	(SourceLineNo int identity(1, 1), LineContent nvarchar(4000) not null);

	begin try

		-- load source code lines from target object

		insert
			@source (LineContent)
		exec sys.sp_helptext
			@objname = @SchemaAndRoutineName; -- load source code from object

		-- remove spaces from lines to simplify parsing

		update
			@source
		set
			LineContent = replace(LineContent, ' ', '')
		where
			charindex(' ', LineContent) > 0;

		-- remove lines not containing query codes

		delete @source where charindex('if@QueryCode=''S!', LineContent) = 0;

		-- parse lines to remove extraneous comments and quotes

		update
			@source
		set
			LineContent = substring(LineContent, charindex('S!', LineContent), 30)
		where
			charindex('S!', LineContent) > 0;

		update
			@source
		set
			LineContent = left(LineContent, charindex('''', LineContent) - 1)
		where
			charindex('''', LineContent) > 1;

		-- return the data set comparing the 2 query code lists

		select
			s.QueryCode SetupQueryCode
		 ,x.QueryCode SubroutineQueryCode
		 ,(case
				 when s.QueryCode is null then '*ERROR: Query syntax appears in ' + @SchemaAndRoutineName + ' but is missing from ' + @SetupSprocName
				 when x.QueryCode is null then '*ERROR: No query syntax defined in ' + @SchemaAndRoutineName + ' for code setup in ' + @SetupSprocName
				 else 'ok'
			 end
			)						Comment
		from
		(
			select
				q.QueryCode
			from
				sf.Query						 q
			join
				sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
			join
				sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				ae.ApplicationEntitySCD = @ApplicationEntitySCD and left(q.QueryCode, 2) = 'S!'
		)																													s
		full outer join
		(select left(s.LineContent, 30) QueryCode from @source s ) x on s.QueryCode = x.QueryCode
		order by
			isnull(s.QueryCode, x.QueryCode);

		-- raise error if discrepancy exists

		if exists
		(
			select
				1
			from
			(
				select
					q.QueryCode
				from
					sf.Query						 q
				join
					sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
				join
					sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
				where
					ae.ApplicationEntitySCD = @ApplicationEntitySCD and left(q.QueryCode, 2) = 'S!'
			)																													s
			full outer join
			(select left(s.LineContent, 30) QueryCode from @source s ) x on s.QueryCode = x.QueryCode
			where
				(s.QueryCode is null or x.QueryCode is null)
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'QueriesNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The query codes in the setup procedure %1 do not match the query codes in the quick search subroutine %2. See output in results window.'
			 ,@Arg1 = @SetupSprocName
			 ,@Arg2 = @SchemaAndRoutineName;

			raiserror(@errorText, 17, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;

GO
