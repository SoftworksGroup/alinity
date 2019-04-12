SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDB#DropTable
	@SchemaName nvarchar(128) = N'dbo'	-- schema containing table to drop
 ,@TableName	nvarchar(128)						-- name of table to drop
 ,@DebugLevel tinyint = 0							-- pass as 1 for additional trace output, 2+ blocks DB changes
as
/*********************************************************************************************************************************
Sproc    : DB - Drop Table
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure drops a table first dropping remaining FK's where they exist (DO NOT deploy in production!)
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This is a utility procedure to drop tables where FK dependencies must be dropped first. The procedure is intended to support the
SGI development process only.  Ensure this procedure is dropped from production environments!

Example
-------
<TestHarness>
  <Test Name = "RandomYear" IsDefault ="true" Description="Creates and drops a test table in the dbo schema.">
    <SQLScript>
      <![CDATA[
create table dbo.MyTest
	(
		ID					 int						identity(1, 1)
	 ,Confirmation nvarchar(250)	not null
	 ,SQLCommand	 nvarchar(1000) not null
	)

exec sf.pDB#DropTable
	@SchemaName = N'dbo'
 ,@TableName = N'MyTest'
 --,@DebugLevel = 2;
 
select
	t.SchemaAndTableName
from
	sf.vTable t
where
	t.SchemaAndTableName = 'dbo.MyTest'
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="EmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pDB#DropTable'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)	-- message text for business rule errors
	 ,@blankParm		varchar(50)			-- tracks name of any required parameter not passed
	 ,@objectName		nvarchar(257)		-- name of database object to rename (includes schema)
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

		-- check parameters

		if @SchemaName is null set @blankParm = '@SchemaName';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		set @objectName = @SchemaName + N'.' + @TableName;

		-- only perform the table rename operation if the new
		-- table name does not already exist in the schema

		if not exists
		(
			select 1 from		sf.vTable t where t.SchemaAndTableName = @objectName
		)
		begin
			print 'Warning - table ' + @objectName + ' not found (already dropped)';
		end;
		else
		begin

			-- store commands to drop FK constraints referencing
			-- the table so that drop will success

			insert
				@work (Confirmation, SQLCommand)
			select
				fk.FKConstraintName + ' dropped'
			 ,N'alter table ' + fk.FKSchemaName + N'.' + fk.FKTableName + N' drop constraint ' + fk.FKConstraintName
			from
				sf.vForeignKey fk
			where
				(
					fk.FKSchemaName		= @SchemaName and fk.FKTableName = @TableName
				) or
					(
						fk.UKSchemaName = @SchemaName and fk.UKTableName = @TableName
					)
			order by
				fk.FKSchemaName
			 ,fk.FKTableName
			 ,fk.FKConstraintName;

			-- store the table drop command

			insert
				@work (Confirmation, SQLCommand)
			select @objectName + ' dropped' , N'drop table ' + @objectName;

			-- now execute each command in order
			-- printing confirmations where successful

			select @maxrow = max (w.ID) from @work w ;
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

			if @DebugLevel < 2
			begin
				print 'done (' + ltrim(@i) + ' commands processed)';
			end;

		end;

	end try
	begin catch
		print @sqlCommand;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
