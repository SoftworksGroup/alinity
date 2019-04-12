SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fBusinessRuleIsEnforced]
(
	 @SchemaName							nvarchar(128)			-- schema where table is located
	,@TableName								nvarchar(128)			-- name of the table to lookup rule status for
	,@MessageSCD							varchar(75)				-- message code to lookup rule status for
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Business Rule Is Enforced
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns bit indicating whether a specific rule is enforced for a given rule name (message code), table and schema
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Oct 2011		|	Initial version
					: Tim Edlund	| Nov	2012		| Updated to incorporate optional column name in the search.
					: Tim Edlund	| Mar	2013		| Tuned to improve performance of query against business rule.
					: Kris Dawson | Jul 2013		| Updated to support override of back dating rule based on operating mode of DB
					: Tim Edlund	| Feb 2014		| Updated default to turn rule OFF unless mandatory where no sf.BusinessRule record found

Comments	
--------
This function is used to simplify syntax for checking to see whether certain optional business rules are enforced.  The function is
called in conditional checks for rule violations as the "first condition". The "BusinessRuleStatus" value in the sf.BusinessRule
table determines whether the rule will be applied.  That value is looked up through the entity view based on the schema-and-table
along with the message code and column.  The Column name must be embedded in the MessageSCD. 

Business rules are enforced by default but certain optional rules can be turned off by setting the BusinessRuleStatus to 'x'.

Example
-------

select 
	 br.SchemaName
	,br.TableName
	,br.MessageSCD
	,br.BusinessRuleStatus
	,sf.fBusinessRuleIsEnforced(br.SchemaName, br.TableName, br.MessageSCD)	IsEnforced
from
	sf.vBusinessRule br
	
select 
	 'test'																																	SchemaName
	,'invalidTable'																													TableName
	,'invalidMessage'																												MessageSCD
	,br.BusinessRuleStatus
	,sf.fBusinessRuleIsEnforced('invalid', 'invalid', 'invalid')						IsEnforced
from
	sf.vBusinessRule br
	
<TestHarness>
	<Test Name="fBusinessRuleIsEnforcedTest" IsDefault="true" Description="Exercises the 
	fBusinessRuleIsEnforced() function.">
		<SQLScript>
			<![CDATA[

				declare 
					 @BusinessRuleSID int  
					,@TableName				varchar(100) 
					,@MessageSID			int
					,@MessageSCD					varchar(100)
				select top (1) 
					 @BusinessRuleSID	= BusinessRuleSID 
					,@MessageSID			= MessageSID
				from 
					sf.BusinessRule
				order by 
					NewID()	 

				select top (1) @TableName = Table_Name from INFORMATION_SCHEMA.TABLES where TABLE_TYPE='BASE TABLE' order by NewID()
				select top (1) @MessageSCD = MessageSCD from sf.message where MessageSID = @MessageSID
				select 
					 'sf'																																SchemaName
					,@TableName																														TableName
					,@MessageSCD																													MessageSCD
					,br.BusinessRuleStatus
					,sf.fBusinessRuleIsEnforced('sf', @TableName, @MessageSCD)						IsEnforced
					,br.BusinessRuleSID
				from
					sf.vBusinessRule br
				where
					br.BusinessRuleSID = @BusinessRuleSID
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/> 
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fBusinessRuleIsEnforced'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @isEnforced						bit	= cast(1 as bit)													-- return value - defaults to ON
		,@ON										bit = cast(1 as bit)													-- constant for bit comparisons
		,@OFF										bit = cast(0 as bit)													-- constant for bit comparisons
		,@columnName						nvarchar(128)																	-- name of column to distinguish between same rule on multiple columns
		,@i											int																						-- character position index
		,@applicationEntitySCD	nvarchar(257)																	-- entity to search for
		,@operatingMode					varchar(10)																		-- the current database operating mode

	set @applicationEntitySCD = @SchemaName + '.' + @TableName

	-- if column name is embedded in message code, strip it out

	set @columnName = replace(@MessageSCD, 'MBR.', '')										
	set @i					= charindex(N'.', @columnName)

	if @i > 0 
	begin
		set @columnName = substring(@columnName, @i + 1, 128)									-- isolate column name
		set @MessageSCD = replace(@MessageSCD, '.' + @columnName, '')					-- strip from message code
	end
	else
	begin
		set @columnName = null																								-- no column name
	end

	-- if the rule is for back dating check the current operating mode, if it is conversion set is enforced off

	if @MessageSCD = 'BackDatingLimit'
	begin

		set @operatingMode = isnull(convert(varchar(10), sf.fConfigParam#Value('DBOperatingMode')), 'default')
		if @operatingMode = 'conversion' set @isEnforced = @OFF

	end

	-- if is enforced hasn't been overridden to off based on operating mode and rule type check to see if the rule is
	-- enabled for the application entity and column (if provided)	

	if @isEnforced = @ON
	begin	

		select
			@isEnforced = case when br.BusinessRuleStatus <> 'x' then @ON else @OFF end 
		from
			sf.BusinessRule				br
		join
			sf.ApplicationEntity	ae	on br.ApplicationEntitySID = ae.ApplicationEntitySID
		join
			sf.[Message] 					m		on br.MessageSID = m.MessageSID
		where
			ae.ApplicationEntitySCD = @applicationEntitySCD
		and
			m.MessageSCD = @MessageSCD
		and
			(@columnName is null or br.ColumnName = @columnName)

		if @@rowcount = 0 set @isEnforced = null															-- if the rule is not found, set on only if MBR (below)

	end

	-- if no business rule exists for the value being looked up by the
	-- check constraint - turn the rule off unless mandatory

	if @isEnforced is null
	begin

		if left(@MessageSCD, 4) = 'MBR.'
		begin
			set @isEnforced = @ON
		end
		else
		begin
			set @isEnforced = @OFF
		end
		
	end

	return(@isEnforced)

end
GO
