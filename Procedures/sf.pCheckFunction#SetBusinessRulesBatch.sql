SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pCheckFunction#SetBusinessRulesBatch]
	 @SchemaName						nvarchar(128)		= N'dbo'												-- schema location of function - default = 'dbo'
	,@CodeTagRoot						varchar(50)			= 'BusinessRules'								-- xml tag pair keyword containing all business rules
	,@CodeTagDetail					varchar(50)			= 'Rule'												-- xml tag pair keyword containing each business rule
as
/*********************************************************************************************************************************
Procedure	: Check Function Set Business Rules - Batch
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Parses check function to add missing business rules and messages for a schema
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov		2012  |	Initial version
					: Tim Edlund	| Apr		2015	| Updated to ignore situation where check function is in schema but base table is dropped.

Comments	
--------

This procedure is a wrapper to call sf.pCheckFunction#SetBusinessRules for each check function in a given schema.  The procedure
searches the dictionary for functions matching the current naming convention:

				f<TableName>#Check

and calls the parsing procedure using dynamic SQL for each. 

The parsing procedure reads the source code of check functions to parse out the message code and default message text so that the 
business rule can be added to the sf.BusinessRule table if missing.  The sf.BusinessRule table is a control structure supported 
through a UI that allows batch validation of the database and also allows optional rules to be turned on and off.  Adding rules to 
check functions does not automatically add an sf.BusinessRule row so this procedure can be run after installation and upgrades, to 
ensure the rule table is up to date.  Similarly, if a rule is removed from a check function it is not automatically removed from the 
BR table so this procedure handles that deletion as well.

See sf.pCheckFunction#SetBusinessRules for details.

Example:
--------

delete from sf.BusinessRule

exec sf.pCheckFunction#SetBusinessRulesBatch 
	@SchemaName = N'sf'

select
	 br.ApplicationEntitySCD
	,br.MessageSCD
	,br.BusinessRuleStatus
	,br.BusinessRuleSID
	,br.ApplicationEntitySID
	,br.CreateTime
	,br.DefaultText
from
	sf.vBusinessRule  br
order by
	1, 2

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin	

	declare
		 @errorNo 													int = 0														-- 0 no error, if <50000 SQL error, else business rule
		,@errorText 												nvarchar(4000)										-- message text (for business rule errors)
		,@i																	int																-- loop index		
		,@maxRow														int																-- loop limit
		,@tableName													nvarchar(128)											-- table name business rules are applied to
		,@functionName											nvarchar(128)											-- check function name (no square brackets)
		,@sqlCmd														nvarchar(1000)										-- dynamic SQL execution buffer
		
	begin try

		declare
		@work					table
		(
			 ID						int							identity(1,1)
			,SchemaName		nvarchar(128)		not null
			,TableName		nvarchar(128)		not null
			,FunctionName	nvarchar(128)		not null
		)

		-- check parameters

		if @SchemaName is null set @SchemaName = N'dbo'

		insert
			@work
		(
			 SchemaName
			,TableName
			,FunctionName
		)
		select
			 r.BaseSchemaName
			,r.BaseTableName
			,r.RoutineName
		from
			sf.vRoutine r
		where
			r.RoutineName like 'f%#Check'																				--< NAMING CONVENTION applied here!
		and
			r.RoutineType = 'FUNCTION'
		and
			r.SchemaName = @SchemaName
		and
			r.BaseTableName is not null																					-- if function exists, but no table - ignore
		order by
			r.RoutineName

		set @maxRow = @@rowcount
		set @i			= 0

		while @i < @maxRow
		begin

			set @i += 1

			select
				 @schemaName		= w.SchemaName
				,@tableName			= w.TableName
				,@functionName	= w.FunctionName
			from
				@work w
			where
				w.ID = @i

			set @sqlCmd = N'sf.pCheckFunction#SetBusinessRules ''' + @schemaName + ''',''' + @tableName + ''',''' + @functionName + ''''

			exec sp_executesql 
				 @sqlCmd

		end

	end try

	begin catch

		select																																-- return progress information for follow-up
			 w.ID
			,w.SchemaName
			,w.TableName
			,w.FunctionName
		from
			@work w
		order by
			w.ID

		print @sqlCmd

		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
