SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pErrorRethrow$2627]
	 @MessageSCD  												varchar(128)				output				-- message code as found in sf.Message
	,@MessageText 												nvarchar(4000)			output				-- error message text
	,@ErrorSeverity 											int									output				-- severity: 16 user, 17 configuration, 18 program 
	,@ColumnNames													xml									output				-- column list on which error occurred
as
/*********************************************************************************************************************************
Sproc		: Error Re-throw 2627 
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: parses text for sql error# 2627 (unique key constraint) and returns a more user friendly version of it
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| April 2010		|	Initial version
				:	Tim Edlund	|	March	2011		|	Updated documentation
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This subroutine is called during an error event.  The caller has determined that sql error 2627 (a unique key constraint) has 
fired.  This procedure parses out the columns and table name from the message and then attempts to find custom error text for that 
message in the sf.Message table. The code used to lookup the error is: "duplicate_key". The message is expected to allow for 
replacement values for the column list and table involved in the constraint.  See also the default text in the code below.

LIMITATION: The parsing logic has been checked for SQL Server 2008 - English.  Other versions of SQL Server and other languages 
may not format the message the same way.  If key positioning values in the message text passed in are not found, then the message 
text provided as a parameter is left unchanged. 

Following is an example of the unique key error text produced by SQL Server 2008 R2:

	Violation of UNIQUE KEY constraint 'uk_DBConfigParm_ParameterName'. 
	Cannot insert duplicate key in object 'sf.DBConfigParm'.

Example
-------
See parent procedure.

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @i 																int																-- position values for substring processing
		,@j 																int																-- position values for substring processing
		,@keyColumnList 										nvarchar(500)											-- buffer for listing columns involved in constraints
		,@schemaName 											  nvarchar(128)											-- identifies schema of column(s) in constraint error
		,@tableName 												nvarchar(128)											-- identifies name of table of column(s) in constraint
		,@uKTableName 											nvarchar(128)											-- identifies name of unique key table in fk constraints
		,@oMessageText 											nvarchar(4000)										-- buffer for original value of output parameters:
		,@oErrorSeverity 										int																

	set @oMessageText		= @MessageText																			-- capture original output parameter values
	set @oErrorSeverity	= @ErrorSeverity

	set @i 						= charindex('''', 	@MessageText)
	set @j 						= charindex('''', 	@MessageText, @i + 1)

	set @MessageSCD  	= substring(@MessageText, @i + 1, @j - @i - 1)

	set @i 						= charindex('''', 	@MessageText, @j + 1)
	set @j 						= charindex('.', 		@MessageText, @i + 1)

	set @schemaName 	= substring(@MessageText, @i + 1, @j - @i - 1)

	set @i 						= charindex('''', 	@MessageText, @j + 1)

	set @tableName 		= substring(@MessageText, @j + 1, @i - @j - 1)						

	if @i > 0 and @j > 0 																										-- if search not found, return text as provided
	begin																																		-- otherwise attempt to find custom text for it

		select
			 @keyColumnList = (case when @keyColumnList is null then tkc.ColumnName else @keyColumnList + ' + ' + tkc.ColumnName end)
		from
			sf.vTableKeyColumn tkc
		where
			tkc.SchemaName 		  = @schemaName
		and 
			tkc.ConstraintName 	= @MessageSCD 
		order by
				tkc.OrdinalPosition
				
		-- run same statement to format the column names as XML				
				
		set @ColumnNames =
		(
			select
				 tkc.ColumnName as "@Name"
			from
				sf.vTableKeyColumn tkc
			where
				tkc.SchemaName 		  = @schemaName
			and 
				tkc.ConstraintName 	= @MessageSCD 
			order by
					tkc.OrdinalPosition
			for
				xml path('Property'), root('Properties') 						
		)				

		if @keyColumnList is null set @keyColumnList = '(None found for constraint: ' + @MessageSCD + ' in the local database.)'			-- constraint may be in a remote DB - typically TenantServices

		set @errorSeverity = 16																								-- user error (duplicate value)
		set @MessageSCD  = 'DuplicateKey'

		exec sf.pMessage#Get																									-- look up standard message for the constraint
				@MessageSCD  = @MessageSCD 
			 ,@MessageText = @MessageText output
			 ,@DefaultText = N'The entry was not allowed because it would create a duplicate. The value for column(s): "%1" must be unique in the %2.%3 table.'
			 ,@Arg1 = @keyColumnList
			 ,@Arg2 = @schemaName
			 ,@Arg3 = @tableName

	end
	else
	begin

		set @MessageText		= @oMessageText																		-- replacement values not isolated - return originals
		set @ErrorSeverity	= @oErrorSeverity
		set @ColumnNames			= null
	
	end		

	return(0)

end
GO
