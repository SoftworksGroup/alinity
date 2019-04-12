SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEntitySetDropCheck]
	 @SchemaName                nvarchar(128)    = null											-- specific schema to drop check constraints on
	,@TableName									nvarchar(128)    = null											-- specific table to drop check constraint on
	,@EntityCount               int							 = null output							-- optional output parameter to report count of entities processed
	,@ReturnSelect              bit              = 0												-- when 1 output values are returned as a dataset
as
/*********************************************************************************************************************************
Sproc    : Entity Set - Drop Check (constraints)
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Drop SGI-Standard check constraints on tables specified, or all tables
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  		| Month Year	| Change Summary
					: --------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund		| May	2017		|	Initial version

Comments
--------
This is a utility procedure used during conversion and design activities to drop standard table check constraints.  Generally
check constraints should be left enabled on the database but may need to be dropped for reverse engineering model changes and/or
to simplify (or speed up) data conversion processes.

To re-add check constraints after conversion, run sf.pEntitySetAddCheck.  Then, to verify data is compliant with the constraints
run sf.pEntitySetVerify.  

If no @SchemaName or @TableName is passed in, then all existing check constraints are dropped.  To drop constraints on a 
particular schema - pass the @SchemaName only.  

The @EntityCount and @ReturnSelect parameters support extended information for back-end calls.

Example:

declare
	@entityCount		int

exec sf.pEntitySetAddCheck
	 @EntityCount		= @entityCount	output
	,@SchemaName		= 'SF'
	,@ReturnSelect	= 1	

exec sf.pEntitySetDropCheck
	 @EntityCount		= @entityCount	output
	,@SchemaName		= 'SF'
	,@ReturnSelect	= 1	

print @entityCount

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                           int = 0														-- 0 no error, <50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)										-- message text (for business rule errors)
		,@maxRow														int																-- loop limit
		,@i																	int																-- loop iteration index
		,@sqlCommand												nvarchar(1000)										-- buffer for dynamic SQL drop command

	set @EntityCount = 0

	begin try

		declare
			@work															table
			(
					ID														int							identity(1, 1)
				,	SQLCommand										nvarchar(1000)	not null
			)

		insert
			@work
			(
				SQLCommand
			)
		select 
			'alter table ' + tc.CONSTRAINT_SCHEMA + '.' + tc.TABLE_NAME + ' drop constraint ' + tc.CONSTRAINT_NAME
		from 
			INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
		where    
			tc.CONSTRAINT_TYPE = N'CHECK'
		and
			tc.CONSTRAINT_SCHEMA =  isnull(@SchemaName, tc.CONSTRAINT_SCHEMA)		-- filter for schema and/or tablename
		and
			tc.TABLE_NAME	= isnull(@TableName, tc.TABLE_NAME)		
		order by
			 tc.CONSTRAINT_SCHEMA
			,tc.TABLE_NAME	

		set @maxRow = @@rowcount
		set @i			= 0

		while @i < @maxrow
		begin

			set @i += 1

			select
				@sqlCommand = w.SQLCommand
			from
				@work	w
			where
				w.ID = @i

			exec sp_executesql @sqlCommand

			set @EntityCount += 1

		end

		if @ReturnSelect = 1
		begin
		
			select
				 w.SQLCommand
			from
				@work w
			order by
				w.ID
				
		end

	end try

	begin catch
		print @sqlCommand																											-- print dynamic SQL buffer on errors
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end

GO
