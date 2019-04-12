SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pScript#ReplaceTokens
	@Script						nvarchar(max)				output		-- script to replace tokens in 
 ,@TokenReplacement sf.TokenReplacement readonly	-- table of replacement tokens and values from caller
 ,@ScriptAction			varchar(10) = 'NONE'					-- acceptable values are:  'EXECUTE', 'PRINT', 'NONE'
as
/*********************************************************************************************************************************
Sproc    : Script - Replace Tokens
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure replaces tokens with values in a given script based on a token-value pair parameter table
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
This is a utility procedure used to process scripts where token values must be replaced with values.  This is a common design
pattern for system-generated DB objects including store procedures, views and utility scripts.  The procedure requires a
table of tokens and value pairs to be passed in.  The token-value pairs must match the structure of the user-defined-type 
"TokenReplacement".  For example:

$ClientID$		CLPNA
$SchemaName$	sf
$Tablename$		Person
...

The use of "$" in token values is not required but some delimiter should be used to ensure replacements do not get applied
to non-token text values.  

The @ScriptAction is optional but may be used to either PRINT or EXECUTE the resulting script after the replacements are
made.  The default value is NONE - in which case no action is performed.  The script value passed in is also returned as an 
output parameter if further processing or execution is to be carried out by the caller. 

Example
-----------
<TestHarness>
  <Test Name = "Renewal" IsDefault ="true" Description="Executes the procedure with a short script using 3 replacements.
	Change action to EXECUTE to see error handling (divide by zero error is embedded in the script).">
    <SQLScript>
      <![CDATA[
declare
	@script						nvarchar(max)
 ,@tokenReplacement sf.TokenReplacement
 ,@scriptAction			varchar(10) = 'PRINT';

set @script = N'
-- this is a test script for "$ClientID$"
select top (1) 1/0 Error, x.* from $SchemaName$.$TableName$ x
'
-- SQL Prompt formatting off
insert
	@tokenReplacement
(
	Token
	,[Value]
)
values
	 ('$ClientID$','SGI')
	,('$SchemaName$','sf')
	,('$Tablename$','Person')
-- SQL Prompt formatting on

exec sf.pScript#ReplaceTokens
	@Script = @script output
 ,@TokenReplacement = @tokenReplacement
 ,@ScriptAction = @scriptAction;

select @script Script
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pScript#ReplaceTokens'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int								= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)															-- message text for business rule errors
	 ,@tranCount int								= @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128)			= object_name(@@procid) -- name of currently executing procedure
	 ,@xState		 int																				-- error state detected in catch block
	 ,@blankParm varchar(50)																-- tracks name of any required parameter not passed
	 ,@work			 sf.TokenReplacement												-- caller token-value pairs PLUS standard environment tokens
	 ,@i				 int																				-- loop iteration counter
	 ,@maxrow		 int																				-- loop limit
	 ,@token		 nvarchar(75)																-- next token to replace in script -e.g. "$ClientID$"
	 ,@value		 nvarchar(4000);														-- next value to replace token with

	 set @Script = @Script

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		-- check parameters

		if @Script is null set @blankParm = '@Script';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @ScriptAction is null set @ScriptAction = 'NONE';

		if @ScriptAction not in ('PRINT', 'EXECUTE', 'NONE')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'script action'
			 ,@Arg2 = @ScriptAction
			 ,@Arg3 = '"PRINT", "EXECUTE", or "NONE"';

			raiserror(@errorText, 18, 1);
		end;

		-- insert standard environment tokens and replacements

		-- SQL Prompt formatting off
		insert
			@work
		(
			Token
		 ,[Value]
		)
		values
		 ('$Year$'								,ltrim(year(sysdatetime())))
		,('$Month$'								,left(datename(month, sysdatetime()), 3))
		-- SQL Prompt formatting on

		-- add the caller's list of token-value pairs to the work
		-- table avoiding any environment values already stored

		insert
			@work (Token, [Value])
		select
			tr.Token
		 ,tr.[Value]
		from
			@TokenReplacement tr
		left outer join
			@work							w on tr.Token = w.Token
		where
			w.Token is null;

		-- process the token replacements in the script

		select @maxrow = max (w.ID) from @work w ;
		set @i = 0;

		while @i < @maxrow
		begin

			set @i += 1;

			select
				@token = w.Token
			 ,@value = w.[Value]
			from
				@work w
			where
				w.ID = @i;

			if @value is not null
			begin
				set @Script = replace(@Script, @token, @value);
			end;

		end;

		set @i += 1 -- increment to support additional debugging block

		if @ScriptAction = 'PRINT'
		begin
			exec sf.pLinePrint @TextToPrint = @Script;
		end;
		else if @ScriptAction = 'EXECUTE'
		begin
			exec sys.sp_executesql @stmt = @Script;
		end;

		if @tranCount = 0 commit;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if (@xState = 0 or @xState = 1) and @i > 0 and @i <= @maxrow
		begin

			set @token = null;
			set @value = null;

			select
				@token = w.Token
			 ,@value = w.[Value]
			from
				@work w
			where
				w.ID = @i;

			print error_message();
			print '---------------------';
			print 'ADDITIONAL DEBUG INFO';
			print ' ';
			print 'Failure occurred processing ID# ' + ltrim(@i);
			print 'Token: ' + isnull(@token, '<NULL>');
			print 'Value: ' + isnull(cast(@value as nvarchar(4000)), '<NULL>');

		end;

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		if @ScriptAction = 'EXECUTE' 
		begin

			if @Script is null 
			begin
				print '@Script IS NULL';
			end;
			else
			begin
				print 'SCRIPT CONTENT: ';
				exec sf.pLinePrint @TextToPrint = @Script;
			end;

		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error

	end catch;

	return (@errorNo);
end;
GO
