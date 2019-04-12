SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pQuery#Execute
	@QuerySID				 int				-- reference to the sf.Query record to execute query from
 ,@QueryParameters xml = null -- query parameters that replace tokens in query string
 ,@IncludeInactive bit = 1		-- passed from #Search sprocs for pass through as query variable
 ,@ValidateOnly		 bit = 0		-- when 1, query is not executed - just validated
 ,@BypassCheck		 bit = 0		-- when 1, by-passes query validation check
 ,@ReturnRowGUIDs	 bit = 0		-- when 1, returns ROW GUID columns rather than pk values
 ,@MaxRows				 int = null -- maximum rows to return (default from config param)
as
/*********************************************************************************************************************************
Procedure : Query Execute
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Called from search routines to execute dynamic queries and return SID's, or from API sproc to validate query SQL
						
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund  | Nov 2012    | Initial version
					: Tim Edlund	| Mar 2013		| Added support for validation only
					: Cory Ng			| May 2013		| Added support for query parameters
					: Tim Edlund	| Jul 2013		| Updated to support returning Row GUID values as well as PK's (for trigger processing)
					: Tim Edlund	| Feb	2014		| Added logic to populate last execution audit columns. 
					: Cory Ng			| Feb 2014		| Updated to support passing null as a query parameter value.
					: Tim Edlund	| Jun	2015		| Implemented additional protection against SQL injection attacks in main statement body.
					: Cory Ng			| Jul 2016		| Added call to pQuery#TableCheck to allow for product specific validation prior to execution
					: Kris Dawson	| Jan 2018		| Updated injection attack checking to allow queries to begin with a declare to support
																			| variable declaration for query tuning
					: Tim Edlund	| Aug 2018		| Ignore zero-length string parameter values (treat as null) - updated row counts

Comments  
--------
This procedure centralizes logic associated with executing dynamic queries.  The procedure is designed to be called from #Search
procedures that offer dynamic queries to the user in a drop-down list.  The procedure is also called for processing task triggers
to return source rows on which tasks are based.  When the procedure is called for task creation, the @ReturnRowGUID's parameter
is passed.

The dynamic queries may include custom queries entered by configurators.  

The QuerySID is provided to lookup the QuerySQL value from the sf.Query table.  

The @QueryParameters  must be passed into this procedure if the query requires parameters to execute. The XML includes a record
for each parameter.  An ID for each parameter is mandatory.  If an ID is not provided the procedure will fail.  A value for
each parameter should be provided for execution, however, for validation the values for each parameter are automatically set to 
NULL.  This allows the syntax of the query to be checked. 

It is best practice to name parameters ID's with enclosing square brackets and the @ sign as shown in the example  below. This
ensures errors are avoided with replacements where one parameter name can be found within another - e.g. consider doing value 
replacements for "@Street" and "@Street2".  By referencing the value as "[@Street]" we can be sure the parameter ID is not found
within another parameter ID (e.g. [@Street2]), and replaced in error.

Sample XML format:

<Parameters>
	<Parameter ID="[@SomeSID]"  Type="TextBox" Value="1000001"/>
	<Parameter ID="[@SomeDate]" Type="DatePicker" Value="05/12/2013"/>
	<Parameter ID="[@MyString]" Type="TextBox" Value="test"/>
	<Parameter ID="[@SomeParm]" Type="TextBox" Value="*null*"/>
</Parameters>

The @ValidateOnly parameter is used to validate the query syntax on saving. The function is called from within the pQuery#Insert
and pQuery#Update procedures to invoke the validation.  The calling procedures check for the error and report it back to the
caller in a conventional manner, with a specific "Error In Query" prefix. 

The @ReturnRowGUIDs parameter is called when row GUID's are needed instead of primary key values.  Note that no naming 
convention is hard coded for either the primary key column or the row GUID column.  The SQL Server dictionary is used to lookup
the correct column names based on attribute settings.  It is, however, essential that a primary key (single column) and a 
Row GUID column be defined on every table.  This is part of SGI database modeling standards.

SQL Injection Protection
------------------------
The statement retrieved as the basis of the query is checked for malicious code including semi-colons, non "select" SQL 
statements, execution statements, and, to ensure the statement begins with the "SELECT" keyword.  As the language develops
care must be taken to keep this code up to date.  Note that protection for parameterized values passed to sp_executeSQL is
built-into that stored procedure (bind variables).

Common Query Variables
----------------------
Before the query is executed, the procedure defines, sets and passes a number of environment variables that may be used in the 
query.  If the parameters are not used in the query then no errors arise.  This list of environment variables and usage notes 
appears in the DECLARE block below.  Note that when designing queries the specific environment variable names specified must 
be used.  Custom variable cannot be passed into the dynamic queries in this version of the framework.

Product Specific Validation
---------------------------
Prior to query execution the sf.pQuery#TableCheck procedure is called, in the framework this procedure is only a stub but is
intended to be overwritten in the product DB project to allow for custom validation. See documentation in sf.pQuery#TableCheck
for more details.

NO Try-Catch
------------
This procedure is normally executed within an INSERT-EXEC structure where the results of the query are returned into a 
memory table.  A Try-Catch is not used therefore since rollbacks are not supported within an INSERT-EXEC structure. Calling
programs must handle errors arising here.

Example
-------
<TestHarness>
	<Test Name="RequiredForEFImport" IsDefault="true" Description="This tests exists so that this sproc can be run from EF">
		<SQLScript>
			<![CDATA[

				select cast(1 as int) SID

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:30" />
		</Assertions>
	</Test>
	<Test Name = "RandomExec" Description="Executes a non-parameter query selected at random then returns query row values.">
		<SQLScript>
			<![CDATA[
declare @querySID int;

select top (1)
	@querySID = q.QuerySID
from
	sf.Query q
where
	charindex('@', QuerySQL) = 0
order by
	newid();

exec sf.pQuery#Execute @QuerySID = @querySID;
select
	q.QuerySID
 ,q.QueryLabel
 ,q.LastExecuteTime
 ,q.LastExecuteUser
 ,q.ExecuteCount
from
	sf.Query q
where
	q.QuerySID = @querySID;
		]]>
		</SQLScript>
		<Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1" />      
			<Assertion Type="RowCount" ResultSet="2" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:30"/>
		</Assertions>
	</Test>
	<Test Name="AllQueriesRun" IsDefault="false" Description="Test to ensure all queries run. Results are not confirmed just to 
	ensure basic errors are caught.">
		<SQLScript>
			<![CDATA[

declare
	 @querySID		int										
	,@maxRow			int		
	,@i						int	= 0
	,@ON					bit = cast(1 as bit)

declare
	@queries			table                            
	(
		 ID				int		identity(1,1)
		,QuerySID	int		not null  
	)

declare
	@errors					table
	(
		 ID						int identity(1,1)
		,QuerySID			int
		,ErrorMessage nvarchar(max)
	)

insert
	@queries (QuerySID)
select
	q.QuerySID
from
	sf.Query q
order by
	q.QuerySID

set @maxRow = @@rowcount

while @i < @maxRow
begin

	set @i += 1

	select
		@querySID = q.QuerySID
	from
		@queries q
	where
		q.ID = @i
	begin try
		
		exec sf.pQuery#Execute
			 @QuerySID = @querySID
			,@ValidateOnly = @ON

	end try
	begin catch
		insert
			@errors
			(
				 QuerySID
				,ErrorMessage
			)
			select
				 @querySID
				,ERROR_MESSAGE()

	end catch

end

select
	 q.QuerySID
	,q.QueryLabel
	,e.ErrorMessage
from
	@errors e
join
	sf.Query q on e.QuerySID = q.QuerySID 

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="EmptyResultSet" ResultSet="1"/> 
			<Assertion Type="ExecutionTime" Value="00:00:30" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pQuery#Execute'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int						= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)												-- message text (for business rule errors)    
	 ,@ON										 bit						= cast(1 as bit)			-- used on bit comparisons to avoid multiple casts
	 ,@OFF									 bit						= cast(0 as bit)			-- used on bit comparisons to avoid multiple casts
	 ,@querySQL							 nvarchar(max)												-- dynamic query string
	 ,@requiresParameters		 bit																	-- indicates the query requires parameters
	 ,@queryParamDefinitions nvarchar(max)												-- parameter definitions for the query
	 ,@i										 int						= 0										-- loop index
	 ,@maxParameterRow			 int																	-- loop limiter
	 ,@parmID								 nvarchar(128)												-- next parameter ID to process
	 ,@value								 nvarchar(max)	= null								-- next value to process
	 ,@applicationEntitySCD	 varchar(50)													-- schema and tablename of query source
	 ,@pkColumn							 nvarchar(128)												-- name of primary key column of source table
	 ,@rowGuidColumn				 nvarchar(128)												-- name of row GUID column of source table
	 ,@now									 datetimeoffset = sysdatetimeoffset() -- current time
	 ,@rowCount							 int																	-- count of records returned by the query
	 ,@executeCount					 int																	-- count of times the query has been executed
																																/* Common Query Variables: */
	 ,@recentHours					 int																	-- hours set in the RecentAccessHours configuration parameter
	 ,@recentDateTime				 datetimeoffset												-- oldest point considered within the recent access hours
	 ,@userSID							 int																	-- sf.ApplicationUser SID for the current user
	 ,@userSessionSID				 int																	-- sf.ApplicationUserSession SID for the current user
	 ,@userName							 nvarchar(75)													-- sf.ApplicationUser UserName for the current user
																																/* Placeholder query parameters: */
	 ,@p0										 nvarchar(max)	= null
	 ,@p1										 nvarchar(max)	= null
	 ,@p2										 nvarchar(max)	= null
	 ,@p3										 nvarchar(max)	= null
	 ,@p4										 nvarchar(max)	= null
	 ,@p5										 nvarchar(max)	= null
	 ,@p6										 nvarchar(max)	= null
	 ,@p7										 nvarchar(max)	= null
	 ,@p8										 nvarchar(max)	= null
	 ,@p9										 nvarchar(max)	= null;

	declare @parameters table
	(
		ID		 int					 identity(1, 1) not null
	 ,ParmID nvarchar(120) not null
	 ,Value	 nvarchar(max) null
	);

	select
		@querySQL							= q.QuerySQL
	 ,@requiresParameters		= cast(case when q.QueryParameters is not null then 1 else 0 end as bit)
	 ,@applicationEntitySCD = ae.ApplicationEntitySCD
	 ,@executeCount					= q.ExecuteCount
	 ,@QueryParameters			= case
															when @QueryParameters is not null then @QueryParameters
															when @ValidateOnly = @ON then q.QueryParameters
															else cast(null as xml)
														end
	from
		sf.Query						 q
	join
		sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
	join
		sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
	where
		q.QuerySID = @QuerySID;

	if @querySQL is null
	begin

		exec sf.pMessage#Get
			@MessageSCD = 'RecordNotFound'
		 ,@MessageText = @errorText output
		 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
		 ,@Arg1 = 'sf.Query'
		 ,@Arg2 = @QuerySID;

		raiserror(@errorText, 18, 1);

	end;
	else if @requiresParameters = @ON and @QueryParameters is null
	begin

		exec sf.pMessage#Get
			@MessageSCD = 'QueryParametersNotSupplied'
		 ,@MessageText = @errorText output
		 ,@DefaultText = N'The parameters for the query were not supplied. Record ID = %1.'
		 ,@Arg1 = @QuerySID;

		raiserror(@errorText, 18, 1);

	end;

	-- check for SQL injection

	set @querySQL = replace(replace(replace(@querySQL, char(13), ' '), char(10), ' '), char(9), ' '); -- strip CR/LF/TAB for injection attack tests

	if right(@querySQL, 1) = ';'
	begin
		set @querySQL = left(@querySQL, len(@querySQL) - 1);
	end;

-- SQL Prompt formatting off
	if charindex(';'					,	@querySQL) > 0 
	or charindex(' go '				,	@querySQL) > 0 
	or charindex('drop '			, @querySQL) > 0 
	or charindex('delete '		, @querySQL) > 0
	or charindex('update '		, replace(@querySQL,'ProfileUpdate','X')) > 0
	or charindex('merge '			, @querySQL) > 0
	or charindex('exec '			, @querySQL) > 0
	or charindex('exec('			, @querySQL) > 0
	or charindex('execute '		, @querySQL) > 0
	or charindex('execute('		, @querySQL) > 0
	or charindex('trunc '			, @querySQL) > 0
	or charindex('truncate '	, @querySQL) > 0
	or (left(ltrim(@querySQL), 7) <> 'select ' and left(ltrim(@querySQL), 7) <> 'declare')
	begin

		 exec sf.pMessage#Get
			 @MessageSCD  = 'SQLCannotBeExecuted'
			,@MessageText = @errorText output
			,@DefaultText = N'The SQL statement provided cannot be executed in this context. A single "%1" statement type is expected which does not begin with a comment (trailing ";" not allowed).'
			,@Arg1        = 'SELECT'

		raiserror(@errorText, 18, 1)

	end
-- SQL Prompt formatting on

	if @BypassCheck = @OFF
	begin

		exec sf.pQuery#TableCheck
			@QuerySID = @QuerySID
		 ,@ErrorText = @errorText output;

		if @errorText is not null
		begin
			raiserror(@errorText, 18, 1);
		end;

	end;

	-- set the common query variables

	set @recentHours = cast(isnull(sf.fConfigParam#Value('RecentAccessHours'), '24') as int);
	set @recentDateTime = sf.fRecentAccessCutOff();
	set @userSID = sf.fApplicationUserSessionUserSID();
	set @userSessionSID = sf.fApplicationUserSessionSID();
	set @userName = sf.fApplicationUserSession#UserName();

	-- retrieve configuration setting for maximum records to return
	-- on a search - to avoid rendering timeout on non-paged UI's

	if @MaxRows is null
		set @MaxRows = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '200') as int);
	if @MaxRows = 0 set @MaxRows = 999999999; -- setting of 0 = unlimited (not recommended!)

	-- define the parameters

-- SQL Prompt formatting off
	set @queryParamDefinitions =
		N'  @maxRows              int'
		+ ',@includeInactive			bit'
		+	',@recentHours					int'					
		+	',@recentDateTime				datetimeoffset'
		+	',@userSID							int'
		+ ',@userSessionSID				int'					
		+	',@userName							nvarchar(75)'
-- SQL Prompt formatting on

	-- if query parameters exist then set the parameter value to the correct variable

	if @QueryParameters is not null
	begin

-- SQL Prompt formatting off
		set @queryParamDefinitions +=
				',@p0										nvarchar(max)'
			+	',@p1										nvarchar(max)'
			+	',@p2										nvarchar(max)'
			+	',@p3										nvarchar(max)'
			+	',@p4										nvarchar(max)'
			+	',@p5										nvarchar(max)'
			+	',@p6										nvarchar(max)'
			+	',@p7										nvarchar(max)'
			+	',@p8										nvarchar(max)'
			+	',@p9										nvarchar(max)'
-- SQL Prompt formatting on

		insert
			@parameters (ParmID, Value)
		select
			parameter.node.value('@ID', 'nvarchar(128)')
		 ,parameter.node.value('@Value', 'nvarchar(max)')
		from
			@QueryParameters.nodes('Parameters/Parameter') as parameter(node);

		select @maxParameterRow	 = count(1) from @parameters ;

		while @i < @maxParameterRow
		begin

			set @value = null;

			select
				@parmID = p.ParmID
			 ,@value	= case when p.Value = '*null*' then null when len(ltrim(rtrim(p.Value))) = 0 then null else p.Value end -- if the string value is *null* or a zero-length string set value to null
			from
				@parameters p
			where
				p.ID = @i + 1;

			if @i = 0 set @p0 = @value;
			else if @i = 1 set @p1 = @value;
			else if @i = 2 set @p2 = @value;
			else if @i = 3 set @p3 = @value;
			else if @i = 4 set @p4 = @value;
			else if @i = 5 set @p5 = @value;
			else if @i = 6 set @p6 = @value;
			else if @i = 7 set @p7 = @value;
			else if @i = 8 set @p8 = @value;
			else if @i = 9 set @p9 = @value;

			-- find the parameter ID in the string - first searching for it
			-- enclosed in square brackets but otherwise without; replace name
			-- used in the string with parameter token that stores the value (p0,p1,etc)

			set @querySQL = replace(@querySQL, '[@' + @parmID + ']', '@p' + ltrim(@i));

			set @i += 1;

		end;

	end;

	-- if the query is to return row GUID's rather than primary key values
	-- replace the first occurrence of the PK column with the Row GUID column
	-- NOTE: this requires that the RowGUID column is IN the data source!

	if @ReturnRowGUIDs = @ON
	begin

		set @pkColumn = sf.fTable#PKColumnName(@applicationEntitySCD); -- lookup the PK column name from dictionary
		set @rowGuidColumn = sf.fTable#RowGUIDColumnName(@applicationEntitySCD); -- lookup row GUID column from dictionary

		set @querySQL = stuff(@querySQL, charindex(@pkColumn, @querySQL), len(@pkColumn), @rowGuidColumn);

	end;

	-- if validation only is requested, set NOEXEC on and off
	-- before and after the query - no output will result

	if @ValidateOnly = @ON
		set @querySQL = N'set noexec on;' + char(13) + char(10) + @querySQL + N';' + char(13) + char(10) + N'set noexec off;';

	-- and execute the query passing parameters in

	if @QueryParameters is not null
	begin

		if @ValidateOnly = @ON
		begin

			set @i = 0;
			while @i <= 9 and charindex(N'@p', @querySQL) > 0
			begin
				set @querySQL = replace(@querySQL, N'@p' + ltrim(@i), 'null');
				set @i += 1;
			end;

		end;

		exec sp_executesql
			@stmt = @querySQL
		 ,@params = @queryParamDefinitions
		 ,@MaxRows = @MaxRows
		 ,@IncludeInactive = @IncludeInactive
		 ,@recentHours = @recentHours
		 ,@recentDateTime = @recentDateTime
		 ,@userSID = @userSID
		 ,@userSessionSID = @userSessionSID
		 ,@userName = @userName
		 ,@p0 = @p0
		 ,@p1 = @p1
		 ,@p2 = @p2
		 ,@p3 = @p3
		 ,@p4 = @p4
		 ,@p5 = @p5
		 ,@p6 = @p6
		 ,@p7 = @p7
		 ,@p8 = @p8
		 ,@p9 = @p9;

		set @rowCount = @@rowcount;

	end;
	else
	begin

		-- if the query is only being validated, and the syntax includes parameter
		-- placeholders, replace them with NULL so that the query can still be validated

		exec sp_executesql
			@stmt = @querySQL
		 ,@params = @queryParamDefinitions
		 ,@MaxRows = @MaxRows
		 ,@IncludeInactive = @IncludeInactive
		 ,@recentHours = @recentHours
		 ,@recentDateTime = @recentDateTime
		 ,@userSID = @userSID
		 ,@userSessionSID = @userSessionSID
		 ,@userName = @userName;

		set @rowCount = @@rowcount;

	end;

	-- if the query is being executed and no commit is pending
	-- then update the execution count and audit

	if @ValidateOnly = @OFF and @errorText is null
	begin

		set @executeCount += 1;

		exec sf.pQuery#Update
			@QuerySID = @QuerySID
		 ,@LastExecuteTime = @now
		 ,@LastExecuteUser = @userName
		 ,@ExecuteCount = @executeCount;

		-- also update the count where this is a
		-- smart group query

		update
			sf.PersonGroup
		set
			SmartGroupCount = @rowCount
		 ,SmartGroupCountTime = sysdatetimeoffset()
		where
			QuerySID = @QuerySID;

	end;

	return (@errorNo);

end;
GO
