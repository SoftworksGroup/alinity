SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDB#ValidateFKs
	@SchemaName nvarchar(128) = null	-- schema to check of null for ALL
 ,@DebugLevel int = 0								-- 1 increases trace output to the console, >= 2 disables execution of SQL commands
as
/*********************************************************************************************************************************
Sproc    : DB - Re-Check Foreign Keys
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure searches for un-trusted foreign keys and executes a script to re-validate any found
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This is a utility procedure to locate and correct un-trusted foreign keys in the database.

Sometimes as part of Data Migration strategy, or to carry out some ETL operation, team members disable foreign keys to 
improve performance or reduce initial errors. After the data load finishes the constraint can be re-enabled. What is often not
understood is that SQL Server won’t start using the foreign key constraint just by enabling it.  SQL Server must be instructed
to recheck all of the data that’s been loaded.  This procedure retrieves syntax from the sf.vForeignKey#Untrusted view and
executes it to fully re-enable constraints which require it. 

Example
-------
<TestHarness>
  <Test Name = "SFOnly" IsDefault ="true" Description="Validates un-trusted foreign keys in the SF schema.">
    <SQLScript>
      <![CDATA[
exec sf.pDB#ValidateFKs
	@SchemaName = 'sf'
 ,@DebugLevel = 1;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:30"/>
    </Assertions>
  </Test>
</TestHarness>
	
exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pDB#ValidateFKs'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@sqlCommand		nvarchar(1000)	-- buffer for dynamic SQL syntax
	 ,@confirmation nvarchar(250)		-- action and name of object to print in confirmation prompts
	 ,@i						int							-- loop iteration counter
	 ,@maxrow				int;						-- loop limit

	declare @work table
	(
		ID					 int						identity(1, 1)
	 ,Confirmation nvarchar(250)	not null
	 ,SQLCommand	 nvarchar(1000) not null
	);

	begin try

		-- load work table with commands to execute

		insert
			@work (Confirmation, SQLCommand)
		select
			'FK ' + fk.UntrustedFK + ' validated'
		 ,fk.ReCheckSQL
		from
			sf.vForeignKey#Untrusted fk
		where
			@SchemaName is null or fk.SchemaName = @SchemaName
		order by
			fk.SchemaAndTableName;

		set @maxrow = @@rowcount;

		if @maxrow = 0 and @DebugLevel > 0
		begin
			print 'ok - no FK''s require valdiation';
		end;

		-- now execute each command and print
		-- confirmations

		set @i = 0;

		while @i < @maxrow
		begin

			set @i += 1;

			select
				@sqlCommand		= w.SQLCommand
			 ,@confirmation = w.Confirmation
			from
				@work w
			where
				w.ID = @i;

			if @DebugLevel > 0
			begin
				print @sqlCommand; -- output command prior to execution to support debugging
			end;

			if @DebugLevel < 2 -- debug level of 2+ disables execution
			begin
				exec sys.sp_executesql @stmt = @sqlCommand;
				print 'ok - ' + @confirmation;
			end;

		end;

		if @DebugLevel < 2 and @maxrow > 0
		begin
			print 'ok ' + ltrim(@maxrow) + ' foreign key(s) validated';
		end;

	end try
	begin catch
		print @sqlCommand;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;


GO
