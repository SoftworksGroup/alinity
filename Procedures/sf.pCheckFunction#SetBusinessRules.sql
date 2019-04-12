SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pCheckFunction#SetBusinessRules]
	 @SchemaName						nvarchar(128)		= N'dbo'												-- schema location of function - default = 'dbo'
	,@TableName							nvarchar(128)																		-- table name business rules are applied to
	,@FunctionName					nvarchar(128)																		-- check function name (no square brackets)
	,@CodeTagRoot						varchar(50)			= 'BusinessRules'								-- xml tag pair keyword containing all business rules
	,@CodeTagDetail					varchar(50)			= 'Rule'												-- xml tag pair keyword containing each business rule
as
/*********************************************************************************************************************************
Procedure	: Check Function Set Business Rules
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Parses check function to add missing business rules and messages to sf.BusinessRule and sf.Message table
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov	2012		|	Initial version
					: Tim Edlund	| Feb	2013		| Fixed bug to consider schema when checking if rule already exists.
					: Tim Edlund	| Feb 2014		| Updated default to turn rule OFF unless mandatory where rules are being added

Comments	
--------

LIMITATION: FIRST CUT ONLY - parsing is supported for the base functions in DBO but not the EXT version. Until updated, developers
must update the sf.BusinessRule table manually with new business rules entered into the extended version of the function. This 
version does not support more than 2 lines for the default message text.

This parsing procedure reads the source code of check functions to parse out the message code and default message text so that the 
business rule can be added to the sf.BusinessRule table if missing.  The sf.BusinessRule table is a control structure supported 
through a UI that allows batch validation of the database and also allows optional rules to be turned on and off.  Adding rules to 
check functions does not automatically add an sf.BusinessRule row so this procedure can be run after installation and upgrades, to 
ensure the rule table is up to date.  Similarly, if a rule is removed from a check function it is not automatically removed from 
the BR table so this procedure handles that deletion as well.

Because the sf.BusienssRule table is parented by sf.Message, the message record must also exist.  That dependency insert is 
automatically supported by the sf.pBusinessRule#Insert procedure.

This procedure can be called against all check functions in a given schema using sf.pCheckFunction#SetBusinessRulesBatch.

The schema, table and function name parameters are required to avoid building a hard coded dependency on current naming standards
used in SGI Studio which generates check function shells.  Similarly the procedure provides parameter positions for the XML tags
used to encapsulate all rules and each rule, however, a default is applied based on tags used in SG Studio at the time of 
authoring.

Example:
--------

declare
	 @schemaName			nvarchar(128) = N'sf'
	,@tableName				nvarchar(128) = N'ApplicationEntity'					-- set to table name to process
	,@functionName		nvarchar(128)

set @functionName = 'f' + @tableName + '#Check'

delete 
	sf.BusinessRule 
where 
	ApplicationEntitySID = (select ApplicationEntitySID from sf.ApplicationEntity ae where ae.ApplicationEntitySCD = @schemaName + '.' + @tableName)

exec sf.pCheckFunction#SetBusinessRules
	 @SchemaName		= @schemaName
	,@TableName			= @tableName
	,@FunctionName	= @functionName

select
	 br.ApplicationEntitySCD
	,br.MessageSCD
	,br.ColumnName
	,br.BusinessRuleStatus
	,br.BusinessRuleSID
	,br.ApplicationEntitySID
	,br.CreateTime
	,br.DefaultText
from
	sf.vBusinessRule  br
where
	br.ApplicationEntitySCD = @schemaName + '.' + @tableName
order by
	1, 2

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin	

	declare
		 @errorNo 													int = 0														-- 0 no error, if <50000 SQL error, else business rule
		,@errorText 												nvarchar(4000)										-- message text (for business rule errors)
		,@blankParm													varchar(100)											-- tracks blank values in required parameters
		,@schemaAndFunctionName							nvarchar(257)											-- combined object name used in error messages
		,@i																	int																-- loop index/record SID
		,@maxRow														int																-- loop limit
		,@j																	int																-- character position tracking
		,@startLine													int																-- starting source line# for retrieved source section
		,@endLine														int																-- ending source line# for retrieved source section
		,@messageSCD												varchar(75)												-- parsed from rule syntax - for documentation and sf.BusinessRule entry
		,@columnName												nvarchar(128)											-- name of column to distinguish between same rule on multiple columns
		,@defaultMessageText								nvarchar(1000)										-- parsed from rule syntax - for documentation and sf.BusinessRule entry
		,@lineContent												nvarchar(max)											-- block of tagged code to process
		,@lineContent2											nvarchar(250)											-- secondary line for comment text
		,@businessRuleStatus								char(1)														-- status to set new rule to when adding
		
	declare 
		@source															table															-- table to hold retrieved source code lines
		( 
			 SourceLineNo											int									identity(1,1)
			,LineContent											nvarchar(4000)			not null
		)

	declare																																	-- table to hold business rules to be checked/added
		@businessRule												table
		(
			 ID																int									identity(1,1)
			,MessageSCD												varchar(75)					not null
			,ColumnName												nvarchar(128)				null				
			,DefaultMessageText								nvarchar(1000)			not null
		)
		
	begin try

		-- check parameters

		if @SchemaName is null set @SchemaName = N'dbo'

		if @FunctionName		is null set @blankParm = '@FunctionName'
		if @SchemaName			is null set @blankParm = '@SchemaName'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm
			
			raiserror(@errorText, 18, 1)
		end

		set @schemaAndFunctionName = @SchemaName + '.' + @FunctionName

		if not exists 
		(
			select 
				1 
			from 
				sf.vRoutine r 
			where 
				r.SchemaName = @SchemaName 
			and 
				r.RoutineName = @FunctionName
			and
				r.RoutineType = 'FUNCTION'
		)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'DatabaseObjectNotFound'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The %1 "%2" was not located in the database. Check the %1 name and try again.'
				,@Arg1					= 'function'
				,@Arg2					= @schemaAndFunctionName
			
			raiserror(@errorText, 17, 1)

		end

		set @i			= 0
		set @maxRow = 0

		insert into @source
		exec sys.sp_helptext @objname = @schemaAndFunctionName	-- retrieve the function source into memory table
			
		select top (1) @startLine = SourceLineNo from @source where LineContent like N'%--!%<'  + @CodeTagRoot + '%>%'
		select top (1) @endLine		= SourceLineNo from @source where LineContent like N'%--!%</' + @CodeTagRoot + '>%'		
			
		if isnull(@startLine,0) > 0 and isnull(@endLine,0) > 0
		begin

			delete 
				@source 
			where 
				SourceLineNo < @startLine 
				or 
				SourceLineNo > @endLine																						-- delete root tags and code outside of them	
				
			select 
				 @maxRow	= max(s.SourceLineNo)																		-- isolate range of line numbers to process
				,@i				= min(s.SourceLineNo)
			from 
				@source s	

		end
			
		-- process the source lines within the tags
		
		set @startLine	= 0
		set @endLine		= 0
		
		while @i < @maxRow
		begin

			select																															-- find next tag (rule)
				@startLine = isnull(min(s.SourceLineNo),0)
			from
				@source s
			where
				s.LineContent like N'%--!%<' + @CodeTagDetail + '%'
			and
				s.SourceLineNo > @endLine																					-- search after last tag pair

			if isnull(@startLine,0) = 0																					-- no more tags
			begin
				set @startLine	= @maxRow + 1																			-- set to terminate the loop
			end
			else																																-- tag found - ensure it is closed
			begin
			
				select
					@endLine = isnull(min(s.SourceLineNo),0)
				from
					@source s
				where
					s.LineContent like N'%--!%</'	+ @CodeTagDetail + '>%'
				and
					s.SourceLineNo > @startLine																			-- search after this starting tag

				if @endLine = 0
				begin
				
					exec sf.pMessage#Get
						 @MessageSCD  	= 'CodeTagNotClosed'
						,@MessageText 	= @errorText output
						,@DefaultText 	= N'The code tag "%1" was not closed in the source code of "%2" near line %3.'
						,@Arg1					= @CodeTagDetail
						,@Arg2					= @schemaAndFunctionName
						,@Arg3					= @startLine
					
					raiserror(@errorText, 17, 1)
				
				end

			end
			
			if @endLine > @startLine																						
			begin
			
				set @lineContent = ''	
				
				select																														-- isolate the error message system code line
					@lineContent = s.LineContent 
				from
					@source s 
				where
					s.LineContent like N'%@errorMessageSCD%'
				and
					s.SourceLineNo > @startLine
				and
					s.SourceLineNo < @endLine
							
				if @@rowcount > 0																									-- parse messageSCD value
				begin
					set @messageSCD = convert(varchar(75), sf.fVariableSetting(N'@errorMessageSCD', @lineContent))	
					
					-- if a column name is included with the message code, strip it out; it must
					-- appear as the ending segment

					set @columnName = replace(@messageSCD, 'MBR.', '')

					if @columnName like N'%.%' 
					begin
						set @columnName = sf.fObjectName(@columnName)									-- this function returns ending segments

						if @columnName is not null and @columnName <> '' 
						begin
							set @messageSCD = left(@messageSCD, len(@messageSCD) - len(@columnName) - 1)					-- strip column from message code
						end

					end

					if (@columnName is null or @columnName = '') and @messageSCD not like '?%'
					begin

						exec sf.pMessage#Get
							 @MessageSCD  	= 'ColumnMissingOnBusinessRule'
							,@MessageText 	= @errorText output
							,@DefaultText 	= N'No column name was specified for business rule "%1" in function "%2.%3". Correct the check function.'
							,@Arg1					= @messageSCD
							,@Arg2					= @SchemaName
							,@Arg3					= @FunctionName
					
						raiserror(@errorText, 17, 1)

					end

					-- isolate text for message

					select
						 @lineContent = s.LineContent 
						,@j						= s.SourceLineNo
					from
						@source s 
					where
						s.LineContent like N'%@defaultMessageText%'
					and
						s.SourceLineNo > @startLine
					and
						s.SourceLineNo < @endLine
							
					if @@rowcount > 0
					begin
						
						-- check if message check has a second line - concatenated starting with "+" sign
						-- if found, add it to the first source code line (3rd line not currently supported!)
							
						select 
							@lineContent2 = convert(nvarchar(250), s.LineContent )
						from 
							@source s 
						where 
							s.SourceLineNo = @j + 1
								
						if replace(replace(@lineContent2, char(9), ''), ' ', '') like '+%' set @lineContent += replace(@lineContent2, N'+', '')
						
						set @defaultMessageText = sf.fVariableSetting(N'@defaultMessageText', @lineContent)
						
						if @messageSCD not like '?%'																	-- avoid inserting entry for templates
						begin

							insert																											-- insert the rule in memory table for processing later
								@businessRule
							(
								 MessageSCD
								,ColumnName
								,DefaultMessageText
							)
							select
								 @messageSCD
								,@columnName
								,@defaultMessageText

						end

					end

				end	
			
			end
			else
			begin
				set @i = @maxRow																									-- to terminate loop on next iteration
			end			

		end

		-- process each business rule found

		select
			@maxRow = count(1)
		from
			@businessRule

		set @i = 0

		while @i < @maxRow
		begin

			set @i += 1

			select
				 @messageSCD					= x.MessageSCD
				,@columnName					= x.ColumnName
				,@defaultMessageText	= x.DefaultMessageText
			from
				@businessRule x
			where
				x.ID = @i

			if not exists																												-- add it if not found	
			(
				select
					1
				from
					sf.vBusinessRule br
				where
					br.MessageSCD = @messageSCD
				and
					br.SchemaName = @SchemaName
				and
					br.TableName	= @TableName
				and
					br.ColumnName = @columnName
			)
			begin						

				if left(@messageSCD, 4) = 'MBR.' 
				begin
					set @businessRuleStatus = 'p'																		-- set mandatory rules to pending (ON)
				end
				else
				begin
					set @businessRuleStatus = 'x'																		-- others are set off
				end

				exec @errorNo = sf.pBusinessRule#Insert
					 @SchemaName					= @SchemaName
					,@TableName						= @TableName	
					,@BusinessRuleStatus	= @businessRuleStatus																			
					,@MessageSCD					= @messageSCD
					,@ColumnName					= @columnName
					,@DefaultText					= @defaultMessageText

			end

			-- delete any existing business rules that no code reference was located for
			-- in the current version of the function

			delete
				br
			from
				sf.BusinessRule				br	
			join
				sf.[Message]					m	 on br.MessageSID = m.MessageSID
			join
				sf.ApplicationEntity	ae on ae.ApplicationEntitySCD = @SchemaName + '.' + @TableName
			left outer join
				@businessRule					x		on m.MessageSCD = x.MessageSCD and br.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				x.ID is null																											-- business rule no longer in source code
			and
				br.ApplicationEntitySID = ae.ApplicationEntitySID									-- only delete for this entity

		end	

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
