SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pQuery#ValidateAll
	@SchemaName		nvarchar(128) = null	-- schema to limit verifications - e.g. 'sf'
 ,@ErrorCount		int = null output			-- count of errors encountered
 ,@RaiseOnError bit = 0								-- when passed as 1, an error is raised if errors are detected
as
/*********************************************************************************************************************************
Procedure : Validate All Query Syntax
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Checks each query stored in sf.Query to ensure SQL is valid - returns data set of errors or empty data set
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2013		|	Initial version
					: Tim Edlund	| Apr 2018		| Added parameter to raise error and avoided validating where IsActive = 0.
					: Taylor N		| Jun 2018		| Updated isnull case for @schemaName to ensure the full ApplicationEntitySCD is returned

Comments	
--------
This procedure is used to check query syntax after database model changes and upgrades.  Because Query SQL syntax is stored in 
sf.Query as strings and executed dynamically, building and deploying the project from VS alone won't surface errors in query 
syntax.  This procedure calls the pQuery#Execute sproc with the @ValidateOnly parameter set ON to check the syntax of each query.

If the query has parameters specified, the specification is passed to sf.pQuery#Execute which replaces the parameter tokens in the
query string.  Since the procedure is called in validation mode and no output need result, all parameters are passed using a NULL 
value. 

The procedure swallows any error encountered and writes details to a result table which is then provided as output to the caller.
If no errors are encountered, then the resulting data set is empty.  The @RaiseOnError parameter can be passed as 1 to raise
an error to the caller when the error count is > 0.  This is useful in automated deployments where the deployment should be
considered failed if any queries fail validation.

No parameters are required, however, it is possible to limit the queries inspected to an individual schema by passing the schema
name - e.g. @SchemaName = 'stg' 

Example
-------
<TestHarness>
  <Test Name = "SFOnly" IsDefault ="true" Description="Executes the procedure to validate queries in the SF Schema only.">
    <SQLScript>
      <![CDATA[
exec sf.pQuery#ValidateAll 
	@SchemaName = 'sf'
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:30"/>
    </Assertions>
  </Test>
  <Test Name = "AllWithRaise" IsDefault ="false" Description="Executes the procedure to validate queries in the DBO schema and raises error on failure.">
    <SQLScript>
      <![CDATA[
exec sf.pQuery#ValidateAll 
	@RaiseOnError = 1
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	 @ObjectName = 'sf.pQuery#ValidateAll'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo				 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText			 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON							 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@maxRows				 int														-- loop limit
	 ,@i							 int														-- loop index
	 ,@queryParameters xml														-- parameters specified for the query
	 ,@querySID				 int;														-- key of next query to validate

	declare @work table (ID int identity(1, 1), QuerySID int not null);

	declare @result table
	(
		ID									 int						identity(1, 1)
	 ,QuerySID						 int						not null
	 ,ApplicationEntitySCD nvarchar(257)	not null
	 ,QueryLabel					 nvarchar(35)		not null
	 ,QuerySQL						 nvarchar(max)	null
	 ,ErrorMessage				 nvarchar(4000) not null
	);

	set @ErrorCount = 0;

	begin try

		-- load work table with queries to check

		insert
			@work (QuerySID)
		select
			q.QuerySID
		from
			sf.Query						 q
		join
			sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
		join
			sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
		where
			ae.ApplicationEntitySCD like isnull(cast(@SchemaName + '.%' as varchar(50)), ae.ApplicationEntitySCD)
			and
			q.IsActive = @ON -- only active queries are validated
			and
			q.QuerySQL is not null
		order by
			ap.ApplicationEntitySID
		 ,q.QueryCategorySID
		 ,q.QuerySID;

		select @maxRows	 = @@rowcount, @i = 0;

		while @i < @maxRows
		begin

			set @i += 1;
			set @queryParameters = null;

			select
				@querySID				 = w.QuerySID
			 ,@queryParameters = q.QueryParameters
			from
				@work		 w
			join
				sf.Query q on w.QuerySID = q.QuerySID
			where
				w.ID = @i;

			begin try

				exec sf.pQuery#Execute
					@QuerySID = @querySID
				 ,@QueryParameters = @queryParameters
				 ,@ValidateOnly = @ON;

			end try
			begin catch

				insert
					@result
				(
					QuerySID
				 ,ApplicationEntitySCD
				 ,QueryLabel
				 ,QuerySQL
				 ,ErrorMessage
				)
				select
					q.QuerySID
				 ,ae.ApplicationEntitySCD
				 ,q.QueryLabel
				 ,q.QuerySQL
				 ,error_message()
				from
					sf.Query						 q
				join
					sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
				join
					sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
				where
					q.QuerySID = @querySID;

				set @ErrorCount += 1;

			end catch;

		end;

		select
			r.QuerySID
		 ,r.ApplicationEntitySCD
		 ,r.QueryLabel
		 ,r.QuerySQL
		 ,r.ErrorMessage
		from
			@result r
		order by
			r.ID;

		if @ErrorCount > 0 and @RaiseOnError = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'QueryValidationFailed'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'%1 queries failed validation. See output in SELECT window for error details or re-run sf.pQuery#ValidateAll.'
			 ,@Arg1 = @ErrorCount;

			raiserror(@errorText, 18, 1);

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
