SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSetup$BusinessRule]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit insert and update audit columns
	,@Language                      char(2)                                 -- language to install for
as
/*********************************************************************************************************************************
Procedure	: pSetup$BusinessRule
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Call library procedure to parse check function source code and insert business rules and messages 
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar		2012  |	Initial version
					: Tim Edlund	| Nov		2012	| Updated to call sf.pCheckFunction$SetBusinesRulesAll to carry out source code parsing.
																				Documentation updated.

Comments	
--------

This procedure is used during system setup (and development) to populate the sf.BusinessRule table with all rules defined in
check functions.  Check functions must match the naming convention and coding format created by the SGIStudio generator
procedure "pCheckFcnGen"; especially use of XML-like tag pairs demarcating the start and end of each rule.  

As sf.BusinessRule records are inserted, their associated sf.Message records are also inserted if they do not already exist.
Before running this procedure, sf.BusinessRule and sf.Message table rows should be deleted if all business rules and
messages are to be replaced.  

The actual work of the procedure is carried out by another library sproc:  pCheckFunction$SetBusinessRulesAll which in 
turn calls pCheckFunction$SetBusinessRules for each check function found.  See those routines for details of rule parsing.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			delete from sf.BusinessRule
			dbcc checkident( 'sf.BusinessRule', reseed, 1000000) with NO_INFOMSGS

			exec sf.pSetup$BusinessRule
				 @SetupUser = 'system@softworksgroup.com'
				,@Language = 'EN'

			select * from sf.BusinessRule

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pSetup$SF#BusinessRule'
	,@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin	

	declare
		 @errorNo 													int = 0														-- 0 no error, if <50000 SQL error, else business rule
		,@maxRow														int																-- loop limit
		,@i																	int																-- loop index
		,@schemaName												nvarchar(128)											-- next schema to process rules for
		,@dynSQL														nvarchar(1000)										-- buffer for dynamic SQL execution

	begin try

		declare
			@work                               table                             -- table to hold function names to process
			(
				 ID                               int                 identity(1,1)
				,SchemaName                       nvarchar(128)       not null
			)

		insert                                                                -- load the work table with the records to process 
			@work
		(
			 SchemaName
		)
		select distinct
			 r.ROUTINE_SCHEMA
		from 
			INFORMATION_SCHEMA.ROUTINES r
		join
			INFORMATION_SCHEMA.TABLES   t on r.ROUTINE_SCHEMA = t.TABLE_SCHEMA
			and
			t.TABLE_NAME = replace(substring(r.ROUTINE_NAME, 2, 127),'#Check', '')
		order by
			 r.ROUTINE_SCHEMA

		set @maxRow = @@rowcount
		set @i      = 0

		while @i < @maxRow
		begin

			set @i += 1

			select
				 @schemaName    = w.SchemaName
			from
				@work w
			where
				w.ID = @i

			exec sf.pCheckFunction#SetBusinessRulesBatch
				@SchemaName = @schemaName

		end
		
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																																	                            -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
