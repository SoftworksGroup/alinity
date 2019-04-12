SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEntitySetAddCheck]
	@SchemaName		nvarchar(128) = null	-- specific schema to add check constraints on
 ,@TableName		nvarchar(128) = null	-- specific table to add check constraint on
 ,@EntityCount	int = null output			-- optional output parameter to report count of entities processed
 ,@ReturnSelect bit = 0								-- when 1 output values are returned as a dataset
as
/*********************************************************************************************************************************
Sproc    : sf.pEntitySetAddCheck
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Adds SGI-Standard check constraint to the table with NO CHECK option
-----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|--------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov	2012		|	Initial version
					: Tim Edlund	| Aug	2017		| Corrected bug so that computed columns are not passed to check functions.
					: Tim Edlund	| Aug	2018		| Avoided adding check constraints on any table in STG or EXT

Comments
--------
This procedure is used to apply an "SGI" standard table check constraint.  The procedure enables constraints that are missing where
the associated table has a "check" function matching the naming convention: f<TableName>#Check.  The procedure uses the NO CHECK 
option when enabling the constraint so no existing data is verified. Because no data is verified, the process is very quick. The 
constraint ensures any new or edited rows are subject to the business rules defined in the check function.

If you need to verify existing records, run sf.pEntitySetVerify.  

The SGI standard for enforcing business rules, except those that apply only on DELETE, is to use a check constraint.  A single
check constraint is implemented on each table. The one constraint checks all business rules by calling a function and passing
it all columns in the table. This procedure checks for the existence of the function according to a naming convention and,
where the function is found and the check constraint is not already enabled, it adds the constraint to the table.

If no @SchemaName or @TableName is passed in, then all missing check constraints are enabled.  Note that for systems that
use a staging schema (typically called "stg") - some tables are by-passed to avoid setting constraints on tables containing
raw conversion or interface data that is validated through processing routines.  See detailed logic below for tables by-passed.

To enable missing constraints on a particular schema - pass the @SchemaName only.  

The @EntityCount and @ReturnSelect parameters support extended information for back-end calls.

Example
-------
<TestHarness>
  <Test Name = "Any" IsDefault ="true" Description="Execute procedure for any tables where check constraint is not enabled">
    <SQLScript>
      <![CDATA[
exec sf.pEntitySetAddCheck
	@ReturnSelect	= 1	
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:02:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pEntitySetAddCheck'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo				int			 = 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@ON							bit			 = cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@CR							nchar(2) = char(13) + char(10)	-- constant: CR LF pair
	 ,@TAB						nchar(1) = char(9)							-- constant: tab character
	 ,@maxRow					int															-- loop limit
	 ,@i							int															-- loop iteration index
	 ,@columnList			nvarchar(max)										-- list of columns to pass to check function
	 ,@constraintName nvarchar(128)
	 ,@functionName		nvarchar(128)
	 ,@dynSQL					nvarchar(4000)									-- buffer for dynamic SQL statement
	 ,@debugString		nvarchar(35)										-- output string for debugging (printed to console)
	 ,@timeCheck			datetimeoffset(7);							-- debug time string

	set @EntityCount = 0;

	begin try

		declare @work table
		(
			ID						 int					 identity(1, 1)
		 ,SchemaName		 nvarchar(128) not null
		 ,TableName			 nvarchar(128) not null
		 ,ConstraintName nvarchar(128) not null
		 ,FunctionName	 nvarchar(128) not null
		);

		insert
			@work (SchemaName, TableName, ConstraintName, FunctionName)
		select
			r.SchemaName
		 ,t.TableName
		 ,N'ck_' + t.TableName
		 ,r.RoutineName
		from
			sf.vRoutine					r
		join
			sf.vTable						t on r.BaseSchemaName = t.SchemaName and r.BaseTableName = t.TableName
		left outer join
			sf.vCheckConstraint ck on t.SchemaName		= ck.SchemaName and ck.ConstraintName = N'ck_' + t.TableName -- naming convention!
		where
			r.RoutineType			= 'FUNCTION' and r.SchemaName <> 'ext' -- avoid extension schema
			and r.SchemaName	<> 'stg' -- avoid staging schema
			and r.RoutineName = N'f' + t.TableName + '#Check' -- naming convention!
			and r.SchemaName	= isnull(@SchemaName, r.SchemaName) -- filter for schema and/or tablename
			and t.TableName		= isnull(@TableName, t.TableName) and ck.ConstraintName is null
		order by
			t.SchemaName
		 ,t.TableName;

		set @maxRow = @@rowcount;
		set @i = 0;

		while @i < @maxRow
		begin

			set @i += 1;
			set @columnList = null;

			select
				@SchemaName			= w.SchemaName
			 ,@TableName			= w.TableName
			 ,@constraintName = w.ConstraintName
			 ,@functionName		= w.FunctionName
			from
				@work w
			where
				w.ID = @i;

			if @ReturnSelect = @ON
			begin

				set @debugString = left(@SchemaName + N'.' + @TableName + '...', 35)

				exec sf.pDebugPrint
					@DebugString = @debugString
				 ,@TimeCheck = @timeCheck output;

			end;

			select
				@columnList = isnull(@columnList + ',', N' ') + tc.ColumnName + @CR + @TAB + @TAB
			from
				sf.vTableColumn tc
			where
				tc.SchemaName						 = @SchemaName
				and tc.TableName				 = @TableName
				and tc.DataType					 <> 'timestamp'
				and tc.DataType					 <> 'text'
				and tc.DataType					 <> 'ntext'
				and tc.DataType					 <> 'image'
				and tc.DataType					 <> 'xml'
				and tc.TypeSpecification <> 'varbinary(max)'
				and tc.TypeSpecification <> 'nvarchar(max)'
				and tc.TypeSpecification <> 'varchar(max)'
				and tc.IsComputed = 0
			order by
				tc.OrdinalPosition;

			set @dynSQL =
				cast(N'alter table ' + @SchemaName + '.' + @TableName + ' with NOCHECK add constraint ' + @constraintName + @CR + 'check ' + @CR + '(' + @CR + @TAB
						 + @SchemaName + '.' + @functionName + @CR + @TAB + '(' + @CR + @TAB + @TAB + @columnList + ') = 1' + @CR + ')' + @CR as nvarchar(4000));

			exec sp_executesql @stmt = @dynSQL;

			set @EntityCount += 1;

		end;

		if @ReturnSelect = @ON
		begin

			select
				w.SchemaName
			 ,w.TableName
			 ,w.ConstraintName
			 ,w.FunctionName
			from
				@work w
			order by
				w.ID;

		end;

	end try
	begin catch
		print @dynSQL; -- print dynamic SQL buffer on errors
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
