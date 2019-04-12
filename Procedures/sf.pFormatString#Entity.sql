SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pFormatString#Entity]
(
	 @String										nvarchar(max)					output								-- in/out string to format; includes {ColumnName} symbols
	,@ApplicationEntitySCD			varchar(50)																	-- schema.tablename of entity to obtain values from
	,@RowSID										int										= null								-- PK of row to obtain replacement values from ... OR 
	,@RowGUID										uniqueidentifier			= null								-- GUID of row to obtain replacement values from
	)
as
/*********************************************************************************************************************************
Procedure : sf.pFormatString#Entity
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Replaces column tokens with values from the entity (view) in the string provided
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul		2013	|	Initial version

Comments	
--------
This procedure returns the string passed with replacements for column name symbols.  The column name symbols must be enclosed
in curly braces - "{MyColumnName}" and must be a column from the entity view associated with the @ApplicationEntitySCD passed.

The procedure also supports replacement of some environment variables:

{:Now:}		-- current date and time in the client timezone
{:Today:}	-- current date in the client timezone

Note that environment variable replacement symbols include colons within the curly braces while column names do not (to avoid
conflicting with column names found in entities).

When a value retrieved from the entity is null, a "term" is looked up from the sf.TermLabel table as a replacement.  The default
value is "<blank>".  Term look ups are also carried out for bit values - e.g. 1 = "yes", 0 = "no".  This avoids hard coding
these values for English.

Date and date and time values are formatted according to the DEFAULT date and datetime formats for the database.  This is obtained
by using the "convert" function and the "style" value of 0.  See SQL Server documentation to change the default date style.

Example
-------

declare
	 @string									nvarchar(max)
	,@applicationEntitySCD		varchar(50) = 'sf.ApplicationUser'
	,@rowGUID									uniqueidentifier

select top (1) @rowGUID =	au.RowGUID from sf.ApplicationUser au order by newid()											-- a random row for testing

set @string = N'The account for {DisplayName} has not been used in the last {DaysSinceLastDBAccess} days. '
							+'Please review the account to determine if it should be closed or removed from the system.  The current date is: {:Today:}'

set @string = N'The account for "{DisplayName}" has never been used.  The account was setup {CreateTime} by {CreateUser}. '
							+'Please review the account to determine if it should be closed or removed from the system.  The current time is: {:Now:}'

exec sf.pFormatString#Entity 
	 @String								= @string								output
	,@ApplicationEntitySCD	= @applicationEntitySCD
	,@RowSID								= null
	,@RowGUID								= @rowGUID

print @string

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@pkColumn												nvarchar(128)												-- name of entity's primary key column
		,@rowGUIDColumn										nvarchar(128)												-- name of entity's row GUID column
		,@schemaAndViewName								nvarchar(257)												-- fully qualified entity view name
		,@i																int																	-- loop index (for looping through columns)
		,@maxRow													int																	-- loop limiter			
		,@dynamicSQL											nvarchar(1000)											-- buffer for retrieval of column values
		,@columnName											nvarchar(128)												-- next column name to retrieve value for		
		,@columnValue											nvarchar(max)												-- buffer for next column value
		,@termLabelBit1										nvarchar(35)												-- language independent labels for:	
		,@termLabelBit0										nvarchar(35)												-- bit values : e.g. 1 - "yes", 0 - "no"
		,@termLabelNull										nvarchar(35)												-- null values: e.g. "blank"	

	declare															@work						table								-- table of columns to make replacements for
		(
			 ID															int							identity(1,1)
			,ColumnName											nvarchar(128)		not null
			,DynamicSQL											nvarchar(1000)	not null
		)
		
	set @String	= @String																										-- initialize output in all code paths (coding standard)

	begin try

				
		if @String is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@String'

			raiserror(@errorText, 18, 1)
		end

		if @RowSID is null and @RowGUID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameterOneOf'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter required by the database procedure was left blank. At lease 1 of the following parameters must be provided: %1'
				,@Arg1					= '@RowSID OR @RowGUID'

			raiserror(@errorText, 18, 1)
		end

		-- get dictionary values required to lookup replacements

		set @schemaAndViewName	= replace(@ApplicationEntitySCD, '.', '.v')															-- source of values is entity view: v<TableName>	
		set @pkColumn						= sf.fTable#PKColumnName(@ApplicationEntitySCD)													-- get PK column name of entity

		-- if the @RowSID was not passed, lookup its value based on the
		-- @RowGUID (one of the 2 must be passed)

		if @RowSID is null
		begin

			set @rowGUIDColumn	= sf.fTable#RowGUIDColumnName(@ApplicationEntitySCD)										-- get GUID column name of entity	
			set @dynamicSQL			= 'select @RowSID = ' + @pkColumn + ' from  ' + @ApplicationEntitySCD + ' where ' + @rowGUIDColumn + ' = @RowGUID'

			execute sp_executesql
				 @stmt		= @dynamicSQL
				,@params	= N'@RowSID int output, @RowGUID uniqueidentifier'
				,@RowSID	= @RowSID			output
				,@RowGUID = @RowGUID

		end

		-- lookup standard terms for bit and null values 
		-- (avoids hard coding for English)

		exec sf.pTermLabel#Get
			 @TermLabelSCD	= 'BIT.ON'
			,@TermLabel			= @termLabelBit1 output
			,@DefaultLabel	= N'yes'
			,@UsageNotes    = N'Display this label when bit/boolean data types are 1/TRUE.'

		exec sf.pTermLabel#Get
			 @TermLabelSCD	= 'BIT.OFF'
			,@TermLabel			= @termLabelBit0 output
			,@DefaultLabel	= N'No'
			,@UsageNotes    = N'Display this label when bit/boolean data types are 0/FALSE.'

		exec sf.pTermLabel#Get
			 @TermLabelSCD	= 'NULL'
			,@TermLabel			= @termLabelNull output
			,@DefaultLabel	= N'<blank>'
			,@UsageNotes    = N'Display this label when the value to be displayed is NULL or blank.'

		-- populate the work table with all column names from the entity which
		-- have a corresponding symbol "{ColumnName}", in the string

		insert
			@work
		(
			 ColumnName
			,DynamicSQL																													-- the dynamic SQL expression varies for some data types to improve formatting
		)
		select
			 vc.ColumnName
			,(
				case
					when vc.DataType					= N'bit'			then N'select @columnValue = (case when ' + vc.ColumnName + ' = 1 then ''' + @termLabelBit1 + ''' else ''' + @termLabelBit0 + ''' end) from ' + @schemaAndViewName + ' where ' + @pkColumn +' = @RowSID'
					when left(vc.DataType, 8) = N'datetime' then N'select @columnValue = convert( nvarchar(19), ' + vc.ColumnName + ', 0) from ' + @schemaAndViewName + ' where ' + @pkColumn +' = @RowSID'
					when vc.DataType					= N'date'			then N'select @columnValue = convert( nvarchar(11), ' + vc.ColumnName + ', 0) from ' + @schemaAndViewName + ' where ' + @pkColumn +' = @RowSID'
					else N'select @columnValue = cast(' + vc.ColumnName + ' as nvarchar(max)) from ' + @schemaAndViewName + ' where ' + @pkColumn +' = @RowSID'
				end
			)
		from
			sf.vViewColumn vc
		where
			vc.SchemaAndViewName = @schemaAndViewName
		and
			vc.DataType <> 'varbinary'																					-- avoid data types that do not format well as strings
		and
			vc.DataType <> 'xml'
		and
			vc.DataType <> 'timestamp'
		and
			charindex(N'{' + vc.ColumnName + '}', @String) > 0									-- search for the column name symbol in the string
		order by
			vc.OrdinalPosition

		set @maxRow = @@rowcount
		set @i			= 0

		-- loop through column names retrieving values from the entity
		-- and inserting them into the string

		while @i < @maxRow
		begin

			set @i += 1

			set @columnValue = null

			select
				 @dynamicSQL	= w.DynamicSQL
				,@columnName	= w.ColumnName
			from
				@work w
			where
				w.ID = @i

			execute sp_executesql
				 @stmt				= @dynamicSQL
				,@params			= N'@RowSID int, @ColumnValue nvarchar(max) output'
				,@RowSID			= @RowSID			
				,@ColumnValue = @columnValue output

			if @columnValue is null set @columnValue = isnull(@termLabelNull, N'')

			set @String = replace(@String, N'{' + @columnName + '}', @columnValue)

		end

		-- finally make the replacements for environment variables
		
		if charindex(N'{:Now:}'		, @String) > 0 set @String = replace( @String, N'{:Now:}'		, convert(nvarchar(19), sf.fNow(), 0))
		if charindex(N'{:Today:}'	, @String) > 0 set @String = replace( @String, N'{:Today:}'	, convert(nvarchar(11), sf.fToday(), 0))

	end try

	begin catch
		if @@trancount > 0 rollback
		print @dynamicSQL
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
