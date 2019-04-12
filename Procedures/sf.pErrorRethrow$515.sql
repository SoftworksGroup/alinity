SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pErrorRethrow$515]
	 @MessageSCD  												varchar(128)			output				  -- message code as found in sf.Message
	,@MessageText 												nvarchar(4000)		output					-- error message text
	,@ErrorSeverity 											int								output					-- severity: 16 user, 17 configuration, 18 program 
	,@ColumnName													nvarchar(128)			output					-- name of the column that was left blank
as
/*********************************************************************************************************************************
Sproc		: Error Re-throw 515
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: parses text for SQL error# 515 (not null constraint) and returns a more user friendly version of it
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr 2010		|	Initial version
				:	Tim Edlund	|	Mar	2011		|	Updated documentation
				: Tim Edlund	| Sep 2011		| Stripped out table name prefix on column name (RIA/EF standard uses entities no tables)
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This subroutine is called during an error event.  The caller has determined that SQL error 515 (a not null constraint) has fired.  
This procedure parses out the column name from the message and then attempts to find custom error text for that message in the 
sf.Message table. The code used to lookup the error is:  required_value_blank.  The column name is a replacement value in the 
text.  (See also pMessage#Get call and @DefaultText parameter in the code below.)

LIMITATION: The parsing logic has been checked for SQL Server 2008 - English.  Other versions of SQL Server and other languages 
may not format the message the same way.  If key positioning values in the message text passed in are not found, then the message 
text provided as a parameter is left unchanged. 

Following is an example of the "not null constraint" error text produced by SQL Server 2008 R2:

	Cannot insert the value NULL into column 'ParameterName', table 'Synoptec.sf.DBConfigParm'; 
	column does not allow nulls. INSERT fails.

Example
-------
	
See parent procedure.

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @i 																int																-- character position for substring processing
		,@j 																int																-- character position for substring processing
		,@oMessageCode 											varchar(128)											-- buffer for original output parameter values:
		,@oMessageText 											nvarchar(4000)
		,@oErrorSeverity 										int	

	set @oMessageCode		= @MessageSCD 
	set @oMessageText		= @MessageText																			-- capture original output parameter values
	set @oErrorSeverity	= @ErrorSeverity							

	set @i = charindex('''', @MessageText)
	set @j = charindex('''', @MessageText, @i + 1)

	if @i > 0 and @j > 0 																										-- if ' not found, return text as provided
	begin																																		-- otherwise attempt to find custom text for it

		set @ColumnName = substring(@MessageText, @i + 1, @j - @i - 1)				-- parse out column name (no table prefix - Sep 2011)
		set @ErrorSeverity = 16																								-- set severity to 16 - this is a business rule violation																	
		set @MessageSCD  = 'RequiredValueBlank'

		exec sf.pMessage#Get																									-- look up standard message for the not null constraint
			 @MessageSCD  = @MessageSCD 
			,@MessageText = @MessageText output
			,@DefaultText = N'A required value has been left blank (%1).'
			,@Arg1 				= @ColumnName

	end
	else
	begin
		set @MessageSCD 		= @oMessageCode
		set @MessageText		= @oMessageText																		-- code not isolated - return original values
		set @ErrorSeverity	= @oErrorSeverity							
		set @ColumnName			= null
	end

	return(0)

end
GO
