SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pErrorRethrow$547]
	 @MessageSCD  												varchar(128)					output			-- message code as found in sf.Message
	,@MessageText 												nvarchar(4000)				output			-- error message text
	,@ErrorSeverity 											int										output			-- severity: 16 user, 17 configuration, 18 program 
	,@ColumnNames													xml										output			-- column list on which error occurred
AS
/*********************************************************************************************************************************
Sproc		: Error Re-throw 547
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: parses text for SQL error# 547 (foreign key OR check constraint) and returns a more user friendly version of it
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr 2010		|	Initial version
				:	Tim Edlund	|	Mar	2011		|	Updated documentation
				: Tim Edlund	| Sep 2011		| Stripped out table name prefix on column name (RIA/EF standard uses entities no tables)				
																			Returned column names as XML
				: Tim Edlund  | Aug 2012    | Change error severity from 17 to 18. Application must protect against FK violations.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This subroutine is called during an error event.  The caller has determined that SQL error 547 has fired.  Error 547 is raised for 
both foreign key constraint violations and for check constraint violations.  The procedures logic branches based on the contents 
of the default message string.  

The procedure parses out table and column names from the message and then attempts to find custom error text for foreign key 
violations in the sf.Message table. The code used to lookup this error type is:  "invalid_foreign_key".  The message text is 
expected to support replacement parameters for the columns and tables involved in the relationship. These values are looked up in 
the schema dictionary.  See the default text in the code below for details of message formatting.

The code used to lookup check constraints is based on the constraint name itself which must following a naming convention as 
follows:  ck_[TableName].[ColumName].[MessageCode].  The message code component is parsed and looked up.  For example, given a 
constraint name of "ck_DBConfigParm.DataType.invalid_base_type" the value "invalid_base_type" is looked up in the sf.Message 
table.

LIMITATION: The parsing logic has been checked for SQL Server 2008 - English.  Other versions of SQL Server and other languages 
may not format the message the same way.  If key positioning values in the message text passed in are not found, then the message 
text provided as a parameter is left unchanged. 

Following is an example of the foreign key error text provided by SQL Server 2008 R2:

		The INSERT statement conflicted with the FOREIGN KEY constraint "fk_UserSessionMessage_UserSession". 
		The conflict occurred in database "Synoptec", table "sf.UserSession", column 'UserSessionSID'.

and for delete:

		The DELETE statement conflicted with the REFERENCE constraint 
		"fk_CopyRecipientFacilityServiceType_FacilityServiceType_FacilityServiceTypeSID". The conflict occurred in database 
		"SynoptecDev", table "dbo.CopyRecipientFacilityServiceType", column 'FacilityServiceTypeSID'.

and here is sample of check constraint text:

		The INSERT statement conflicted with the CHECK constraint "ck_DBConfigParm.DataType.invalid_base_type". ...

Example
-------
	
declare
	 @messageSCD  												varchar(128)
	,@errorSeverity 											int
	,@columnNames													xml
	,@messageText 												nvarchar(4000)

set @messageText = N'The DELETE statement conflicted with the REFERENCE constraint "fk_EpisodeAdminNote_SF_ApplicationUser_ApplicationUserSID". The conflict occurred in database "SynoptecDev", table "dbo.EpisodeAdminNote", column ''ApplicationUserSID''.'

exec sf.pErrorRethrow$547
	 @MessageSCD  		= @messageSCD			output
	,@MessageText			= @messageText		output
	,@ErrorSeverity 	= @errorSeverity	output
	,@ColumnNames			= @columnNames		output

print @messageSCD
print @messageText
print @errorSeverity
print (cast(@columnNames as nvarchar(500)))

----------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @i 																int																-- character position values for substring processing
		,@j 																int																-- character position values for substring processing
		,@keyColumnList 										nvarchar(500)											-- buffer for listing columns in constraint definitions
		,@schemaName 											  nvarchar(128)											-- identifies schema of column(s) in constraint error
		,@tableName 												nvarchar(128)											-- identifies table of column(s) involved in constraint 
		,@uKTableName 											nvarchar(128)											-- identifies unique key table in foreign key constraint
		,@oMessageCode 											varchar(128)											-- buffer for original output parameter value:
		,@oMessageText 											nvarchar(4000)										
		,@oErrorSeverity 										int																

	set @ErrorSeverity = 18																								  -- set severity to 18 - UI should prevent these !

	set @oMessageCode		= @MessageSCD 
	set @oMessageText		= @MessageText																			-- capture original output parameter values
	set @oErrorSeverity	= @ErrorSeverity							

	set @i = charindex('"', @MessageText)
	set @j = charindex('"', @MessageText, @i + 1)

	if @i > 0 and @j > 0 set @MessageSCD  = substring(@MessageText, @i + 1, @j - @i - 1)

	if @MessageSCD  like 'fk[_]%' 
	begin

		set @i 						= charindex('"', @MessageText, @j + 1)
		set @j 						= charindex('"', @MessageText, @i + 1)
		set @i 						= charindex('"', @MessageText, @j + 1)
		set @j 						= charindex('.', @MessageText, @i + 1)
		set @schemaName 	= substring(@MessageText, @i + 1,  @j - @i - 1)

		if @i > 0 and @j > 0 																									-- if " not found, return text as provided
		begin																																	-- otherwise attempt to find custom text for it

			select
				 @keyColumnList = (case when @keyColumnList is null then tkc.ColumnName else @keyColumnList + ' + ' + tkc.ColumnName end)
			from
				sf.vTableKeyColumn tkc
			where
				tkc.SchemaName      = @schemaName
			and 
				tkc.ConstraintName  = @MessageSCD 
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

			select
				 @tableName 	= fk.FKTableName
				,@uKTableName = fk.UKTableName
			from
				sf.vForeignKey fk
			where
				fk.FKSchemaName = @schemaName
			and 
				fk.FKConstraintName = @MessageSCD 

			set @MessageSCD  = 'InvalidForeignKey'

			exec sf.pMessage#Get																								-- look up application message for fk constraint errors
					@MessageSCD  = @MessageSCD 
				 ,@MessageText = @MessageText output
				 ,@DefaultText = N'The entry or deletion was not allowed because all "%1" values in the "%2" table would no longer match a record in the "%3" table.'
				 ,@Arg1 = @keyColumnList
				 ,@Arg2 = @tableName
				 ,@Arg3 = @uKTableName

		end
		else
		begin
			set @MessageSCD 		= @oMessageCode
			set @MessageText		= @oMessageText																	-- no code to parse - reset output parameters
			set @ErrorSeverity	= @oErrorSeverity							
			set @ColumnNames		= null
		end
	end		
	else 																																		-- must be a check constraint
	begin

		set @MessageSCD  	= substring(@MessageText, @i + 1, @j - @i - 1)
		set @i 						= charindex('.', @MessageSCD )
		set @j 						= charindex('.', @MessageSCD , @i + 1)

		if @i > 0 and @j > 0 
		begin


			set @MessageSCD  = substring(@MessageSCD , @j + 1, 128)
			
			set @ColumnNames =
				(
					select
						substring(@MessageSCD , @i + 1, @j - @i - 1) as "@Name"
					for
						xml path('Property'), root('Properties')											-- store column name into XML
				)				
			
			exec sf.pMessage#Get																								-- look up the application message for check constraint
				 @MessageSCD  = @MessageSCD 
				,@MessageText = @MessageText output

		end
		else
		begin
			set @MessageSCD 		= @oMessageCode
			set @MessageText		= @oMessageText																	-- no message code isolated - reset output parameters
			set @ErrorSeverity	= @oErrorSeverity							
			set @ColumnNames			= null
		end

	end

	return(0)

end
GO
