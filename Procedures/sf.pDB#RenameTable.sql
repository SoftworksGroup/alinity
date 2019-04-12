SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDB#RenameTable
	@SchemaName		nvarchar(128) = N'dbo'	-- schema where old and new tables  exist
 ,@OldTableName nvarchar(128)						-- table to rename (no schema prefix)
 ,@NewTableName nvarchar(128)						-- new name for the table
 ,@DebugLevel		tinyint = 0							-- pass as 1 for additional trace output, 2+ blocks DB changes
as
/*********************************************************************************************************************************
Sproc    : DB - Rename Table
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure renames a table and columns incorporating the old table name (DO NOT deploy in production!)
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This is a utility procedure to rename tables and columns incorporating the old table name across the database.  It is intended
for use in migration scripts executed before upgrading databases the most recent model.  The procedure is intended to support the
SGI development process only and relies heavily on SGI database modeling standards.  Ensure this procedure is dropped from
production environments!  

IMPORTANT: RENAME LONGER TABLE NAMES BEFORE SHORTER ONES where the table names contain shared words.  This is critical to 
ensuring renames are processed successfully. For example when renaming:

RegistrationChange->Reinstatement								-- WRONG ORDER!
RegistrationChangeStatus->ReinstatementStatus

RegistrationChangeStatus->ReinstatementStatus		-- CORRECT ORDER
RegistrationChange->Reinstatement								

Example
-------
<TestHarness>
  <Test Name = "RandomYear" IsDefault ="true" Description="Creates and renames a test table in the dbo schema.">
    <SQLScript>
      <![CDATA[
create table dbo.MyTest
(
	MyTestSID		int						identity(1, 1)
 ,MyTestLabel nvarchar(250) not null
 ,CreateTime	datetime			not null
);

exec sf.pDB#RenameTable
	@SchemaName = N'dbo'
 ,@OldTableName = N'MyTest'
 ,@NewTableName = N'JustATest'
-- ,@debugLevel = 1;

select
	tc.SchemaAndTableName
 ,tc.ColumnName
from
	sf.vTableColumn tc
where
	tc.SchemaAndTableName = 'dbo.JustATest'
order by
	tc.OrdinalPosition;

if @@rowcount > 0
begin
	drop table dbo.JustATest; -- remove the renamed table
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>
	
exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pDB#RenameTable'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000) -- message text for business rule errors
	 ,@blankParm		 varchar(50)		-- tracks name of any required parameter not passed
	 ,@oldObjectName nvarchar(257)	-- name of database object to rename (includes schema)
	 ,@newObjectName nvarchar(257)	-- name of renamed object (includes schema)
	 ,@sqlCommand		 nvarchar(1000) -- buffer for dynamic SQL syntax
	 ,@confirmation	 nvarchar(250)	-- action and name of object to print in confirmation prompts
	 ,@i						 int						-- loop iteration counter
	 ,@maxrow				 int;						-- loop limit

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

		set @oldObjectName = @SchemaName + N'.' + @OldTableName;
		set @newObjectName = @SchemaName + N'.' + @NewTableName;

		-- only perform the table rename operation if the new
		-- table name does not already exist in the schema

		if exists
		(
			select 1 from		sf.vTable t where t.SchemaAndTableName = @newObjectName
		)
		begin

			if exists
			(
				select 1 from		sf.vTable t where t.SchemaAndTableName = @oldObjectName
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'BothTablesExist'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Both the old (%1) and new (%2) (%3) exist in the schema.  Rename is not possible.'
				 ,@Arg1 = @oldObjectName
				 ,@Arg2 = @newObjectName
				 ,@Arg3 = 'tables';

				raiserror(@errorText, 18, 1);
			end;

			print 'Warning - table ' + @newObjectName + ' already exists (table renamed skipped)';
		end;
		else
		begin

			-- insert the table rename command
			-- into the work table

			insert
				@work (Confirmation, SQLCommand)
			select
				'table renamed: ' + @oldObjectName + ' -> ' + @newObjectName
			 ,N'exec sp_rename @objname = ''' + @oldObjectName + ''' ,@newname = ''' + @NewTableName + ''',@objtype = ''Object''';

		end;

		-- in order to successfully rename columns to confirm with the new 
		-- table name, xml primary indexes plus any indexes and constraints 
		-- referencing those columns must be dropped first

		if not exists
		(
			select
				1
			from
				sf.vTableColumn tc
			where
				tc.SchemaAndTableName = @oldObjectName and tc.ColumnName like '%' + @OldTableName + '%'
		)
		begin
			print 'ok - no columns require renaming';
		end;
		else
		begin

			-- store commands to drop FK constraints, default constraints and
			-- indexes that would otherwise block column renaming; these objects
			-- rebuild on deploy/schema compare

			insert
				@work (Confirmation, SQLCommand)
			select
				fk.FKConstraintName + ' dropped'
			 ,'alter table ' + (case when fk.FKTableName = @OldTableName then @newObjectName else fk.FKSchemaName + '.' + fk.FKTableName end) + ' drop constraint '
				+ fk.FKConstraintName
			from
				sf.vForeignKey fk
			where
				(
					fk.FKSchemaName		 = @SchemaName -- match current schema
					and fk.FKTableName = @OldTableName -- and table and drop all these FK's
				) or fk.FKConstraintName like '%[_]' + @OldTableName + 'SID%' -- but only if old-name + SID is referenced on other tables
			order by
				fk.FKSchemaName
			 ,fk.FKTableName
			 ,fk.FKConstraintName;

			insert
				@work (Confirmation, SQLCommand)
			select
				dc.ConstraintName + ' dropped'
			 ,'alter table ' + (case when dc.TableName = @OldTableName then @newObjectName else dc.ConstraintSchema + '.' + dc.TableName end) + ' drop constraint '
				+ dc.ConstraintName
			from
				sf.vDefaultConstraint dc
			where
				(
					dc.ConstraintSchema = @SchemaName -- match current schema
					and dc.TableName		= @OldTableName -- and table and drop all these DF's
				) or dc.ConstraintName like '%[_]' + @OldTableName + '%'	-- but only if full old-name is referenced on other tables
			order by
				dc.ConstraintSchema
			 ,dc.TableName
			 ,dc.ConstraintName;

			insert
				@work (Confirmation, SQLCommand)
			select
				ti.IndexName + ' dropped'
			 ,(case
					 when left(ti.IndexName, 3) in ('pk_', 'uk_') then 'alter table ' + @newObjectName + ' drop constraint ' + ti.IndexName
					 else
						 'drop index ' + ti.IndexName + ' on ' + (case when ti.TableName = @OldTableName then @newObjectName else ti.SchemaName + '.' + ti.TableName end)
				 end
				) SQLCommand
			from
				sf.vTableIndex ti
			where
				(
					ti.SchemaName		 = @SchemaName -- match current schema for 
					and ti.TableName = @OldTableName -- table and drop all these indexes
				) or ti.IndexName like '%[_]' + @OldTableName + '%' -- but only if full old-name is referenced on other tables
			order by (case when left(ti.IndexName, 3) = 'pk_' then 2 when left(ti.IndexName, 3) = 'uk_' then 1 else 0 end)
			 ,ti.SchemaName
			 ,ti.TableName
			 ,ti.IndexName;

			-- now store the column rename commands to process

			insert
				@work (Confirmation, SQLCommand)
			select
				tc.SchemaAndTableName + '.' + tc.ColumnName + ' renamed to ' + replace(tc.ColumnName, @OldTableName, @NewTableName)
			 ,'exec sp_rename @objName = ''' + (case when tc.TableName = @OldTableName then @newObjectName else tc.SchemaName + '.' + tc.TableName end) + '.'
				+ tc.ColumnName + ''', @newName = ''' + replace(tc.ColumnName, @OldTableName, @NewTableName) + ''', @objType = ''Column'''
			from
				sf.vTableColumn tc
			where
				tc.ColumnName like '%' + @OldTableName + '%'	-- but only if full old-name is referenced on other tables
			order by
				tc.SchemaName
			 ,tc.TableName
			 ,tc.ColumnName;

		end;

		-- finally create commands to update tables which may contain
		-- meta data referring to the old table name

		insert
			@work (Confirmation, SQLCommand)
		values
		(
			'Query Syntax updated for rename: $OldTableName$ -> $NewTableName$'
		 ,'update sf.Query set QuerySQL = replace(QuerySQL, ''$OldTableName$'', ''$NewTableName$'') where QuerySQL like ''%$OldTableName$%'''
		)
		 ,(
				'XML Form Definitions updated for rename: $OldTableName$ -> $NewTableName$'
			 ,'update sf.FormVersion set FormDefinition = cast(replace(cast(FormDefinition as nvarchar(max)), ''$OldTableName$'', ''$NewTableName$'') as xml) where cast(FormDefinition as nvarchar(max)) like ''%$OldTableName$%'''
			)
		 ,(
				'Form Type Codes updated for rename: $OldTableName$ -> $NewTableName$'
			 ,'update sf.FormType set	FormTypeSCD = replace(FormTypeSCD, ''$OldTableName$'', upper(''$NewTableName$'')) where FormTypeSCD like ''%$OldTableName$%'''
			)
		 ,(
				'Application Grant Codes updated for rename: $OldTableName$ -> $NewTableName$'
			 ,'update sf.ApplicationGrant set	ApplicationGrantSCD = replace(ApplicationGrantSCD, ''$OldTableName$'', upper(''$NewTableName$'')) where ApplicationGrantSCD like ''%$OldTableName$%'''
			)
		 ,(
				'Application Entity Codes updated for rename: $OldTableName$ -> $NewTableName$'
			 ,'update sf.ApplicationEntity set ApplicationEntitySCD = ''' + @newObjectName + ''' where ApplicationEntitySCD = ''' + @oldObjectName + ''''
			);

		-- replace the variable symbols in the statements

		update
			@work
		set
			SQLCommand = replace(replace(SQLCommand, '$OldTableName$', @OldTableName), '$NewTableName$', @NewTableName)
		 ,Confirmation = replace(replace(Confirmation, '$OldTableName$', @OldTableName), '$NewTableName$', @NewTableName)
		where
			SQLCommand like '%$%$%';

		-- drop all check constraints that may interfere with
		-- object renaming (executes unless debug level is 3+)

		if @DebugLevel < 3
		begin

			exec sf.pEntitySetDropCheck
				@EntityCount = @i output;

			if isnull(@i, 0) > 0
			begin
				print 'ok - ' + ltrim(@i) + ' check constraints dropped';
			end;

		end;

		-- now execute each command and print
		-- confirmations

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

	end try
	begin catch
		print @sqlCommand;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
