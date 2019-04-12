SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextTemplate#MergeWithMap]
	@TextTemplate							 nvarchar(max)		output				-- string with [@Column1] tokens to make replacements in
 ,@TokenMap									 sf.TokenMap			readonly			-- map of tokens in template to speed up parse logic
 ,@ApplicationEntitySCD			 varchar(50)										-- schema.table name of the source entity for replacements
 ,@RecordSID								 int														-- primary key value of the source of replacements
 ,@PersonEmailMessageRowGUID uniqueidentifier = null				-- GUID reference used in links for emails
 ,@PersonTextMessageRowGUID	 uniqueidentifier = null				-- GUID reference used in links for text messages
 ,@ReplacementSQL						 nvarchar(max)		= null output -- dynamic SQL string to retrieve replacement values 
as
/*********************************************************************************************************************************
Procedure : Note Template Merge
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Makes replacements of column tokens with values from the entity view specified
						
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Apr 2015    | Initial version
					: Richard K		| Jun 2015		|	Updated to support Views as entities in a merge.
					: Richard K	  | Sep 2015		| Updated code to more closely match framework changes
					: Cory Ng			| Jun 2016		| Added @PersonTextMessageRowGUID parameter to support merging of text messages
					: Cory Ng			| Jun 2016		| Updated to removed tilde if no spaces exists before or after
					: Tim Edlund	| Oct	2017		| Introduced mapping table (@tokenMap) and in-out pass of @replacementSQL
																				so that template need only be parsed once and all recipients merged.

Comments  
--------
This procedure replaces tokens placed into a string with values from the specified entity.  The source entity to obtain the 
replacement values from is identified by schema, tablename and a specific record number.  The schema defaults to DBO but the 
other parameters must be passed. 

The string passed in will receive replacements where tokens matching the column names from the specified entity are found. 
The format of the tokens is:  "[@ColumnName]".   If a token is placed into the string that does not match up to a column name 
in the entity, it is left unchanged (making it easy for users to recognize the error).   

If the column value associated with the token is null, a zero-length string is inserted. Some additional formatting is 
carried out by the procedure to remove extra blank spaces when 2 side-by-side tokens are replaced with nulls. The functionality 
of removing blanks is based on behavior of Word in its "mail merge" function.

The procedure also supports replacement of environment variable tokens - e.g. "[@@Date]".  Environment variable tokens use
a double "@@" sign.  They also include the list of link types that can be inserted into emails that direct the user to
a specific web page and action when the link is clicked in email.  These values are defined in the sf.MessageLink table
and also reference sf.ApplicationPage.  Added to the end of each link is the RowGUID of the sf.PersonEmailMessage. 

Note that the @PersonEmailMessageRowGUID parameter is mandatory when the application entity passed in is 
sf.PersonEmailMessage.

The procedure uses dynamic SQL to populate a table of tokens and replacement values from a single select to the source 
view. A loop is then used to process replacements in the string.  

@ReplacementSQL (in/out)
------------------------
Creating the SQL string to obtain the replacement values involves several complex queries.  In order to support the 
same template being processed for multiple recipients, the SQL string created by the procedure can be passed back 
to the caller as an outbound variable.  Then, on the call to this procedure for the next record, the string can be
passed back in - thereby avoiding its recreation.  The value [@@SourceRecordSID] is inserted as a placeholder for
the next record key to process. 

@TokenMap
---------
@TokenMap is a required variable. It is a read-only table containing the names of each merge field in the template
along with its position.  The table must be populated by the caller using sf.pTextTemplate#GetMap.  This table
need only be created once for the template and can then be passed on each call to this procedure to process the
next record.  

Not Supported
-------------
Replacements on any column except those of type "TimeStamp" and "Varbinary" is supported.  The string passed in can 
contain any characters except for "~".  Tilde's are reserved for internal processing of the routine to avoid nulls.

Known Limitations
-----------------
At the time of this writing the starting and ending positions returned are used for debugging since the use of this table to 
make replacements in the source template is accomplished by the tsql "replace" command.  A change in algorightm is possible to
use the "stuff" command which is faster (about 30%) however this would require updating the starting and ending positions 
after each replacement to recalculate their values based on the length of replacements just made.

Example
-------
<TestHarness>
	<Test Name="Demo" IsDefault="true" Description="Provides template string with several replacement tokens including one
	invalid one. Selects a sf.Person record at random for replacements and tests to ensure all tokens except the invalid one
	are replaced.">
		<SQLScript>
			<![CDATA[

				declare
						@string			nvarchar(max) 
					,@personSID		int

				select top (1) 
						@personSID = p.PersonSID
					,@string = N'The name is:[@FirstName] [@MiddleNames] [@LastName]. The record number is: #[@PersonSID] and it was'
					+ ' created [@CreateTime] and last updated by [@UpdateUser]. This [@InvalidToken] is not replaced!  The current '
					+ ' date is [@@Date] and the current time is [@@Time]'
				from 
					sf.Person p 
				order by 
					newid()
	 
				exec sf.pTextTemplate#MergeWithMap
						@TextTemplate							= @string output
					,@ApplicationEntitySCD			= 'sf.Person'
					,@RecordSID				= @personSID


			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/> 
			<Assertion Type="ScalarValue" ResultSet="1" RowNo="1" ColNo="1" Value="OK"/> 
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pTextTemplate#MergeWithMap'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo		int						= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)											-- message text (for business rule errors)
	 ,@blankParm	nvarchar(50)												-- tracks blank parameters for error checking
	 ,@ON					bit						= cast(1 as bit)			-- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@OFF				bit						= cast(0 as bit)			-- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@CRLF				nchar(2)			= char(13) + char(10) -- constant to format carriage return + line feed pairs
	 ,@TAB				nchar(1)			= char(9)							-- tab character used in formatting SQL
	 ,@schemaName nvarchar(60)												-- schema name of the source entity of replacements
	 ,@tableName	nvarchar(60)												-- table name of the source entity
	 ,@viewName		nvarchar(60)												-- view name of the source entity
	 ,@columnList nvarchar(max)												-- list of entity columns for the un-pivot clause
	 ,@maxRow			int																	-- loop limit
	 ,@i					int;																-- loop index

	declare @source table -- table of replacement values	
	(

		ID							 int					 identity(1, 1)
	 ,MergeToken			 nvarchar(131) not null
	 ,ReplacementValue nvarchar(max) null
	);

	set @TextTemplate = @TextTemplate; -- populate in all code paths; input/output parameter
	set @ReplacementSQL = @ReplacementSQL;

	begin try

		-- parse schema and table from entity code

		if @ReplacementSQL is null
		begin

			set @tableName = replace(replace(@ApplicationEntitySCD, '[', ''), ']', ''); -- if table name is passed with schema, parse it out				
			set @i = charindex('.', @tableName);

			if @i > 0 begin
									set @schemaName = left(@ApplicationEntitySCD, @i - 1);
									set @tableName = substring(@tableName, @i + 1, 50);
			end;

			if @tableName is null set @blankParm = '@tableName';
			if @schemaName is null set @blankParm = '@schemaName';

			if @blankParm is not null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'BlankParameter'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
				 ,@Arg1 = @blankParm;

				raiserror(@errorText, 18, 1);

			end;

			-- ensure data source is valid
			-- include views in eligible object list

			if not exists
			(
				select
					1
				from
					sf.vTable t
				where
					t.SchemaName = @schemaName and t.TableName = @tableName
			)	 and not exists
			(
				select
					1
				from
					sf.vView v
				where
					v.SchemaName = @schemaName and v.ViewName = 'v' + @tableName
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'ObjectNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The object %1 was not found.'
				 ,@Arg1 = @ApplicationEntitySCD;

				raiserror(@errorText, 18, 1);
			end;

		end;
		else
		begin

			-- where the replacement is being passed back into this procedure
			-- replace the token with the key for the current record

			set @ReplacementSQL = replace(@ReplacementSQL, ' = [@@SourceRecordSID]', ' = ' + ltrim(@RecordSID));
		end;

		-- populate table with environment tokens and replacements

		insert
			@source (MergeToken, ReplacementValue)
			select
				emf.MergeToken
			 ,replace(
								 emf.ReplacementValue
								,'[@RowGUID]'
								,isnull(isnull(cast(@PersonEmailMessageRowGUID as nvarchar(50)), cast(@PersonTextMessageRowGUID as nvarchar(50))), 'N/A')
							 )	-- replacement value itself may contain row guid replacement
			from
				sf.fEnvironment#MergeFields() emf;

		if @ReplacementSQL is null
		begin

			-- update table name if using a view as an entity

			if exists
			(
				select
					1
				from
					sf.vView v
				where
					v.SchemaName = @schemaName and v.ViewName = @tableName
			)
			begin
				set @tableName = substring(@tableName, 2, len(@tableName) - 1);
			end;

			-- see table function for details of environment fields

			set @viewName = @tableName;
			if @schemaName = N'rpt' set @viewName = cast(@tableName + 'Value' as nvarchar(60));
			if @schemaName = N'dbo' and @tableName = 'EpisodeReport' set @viewName = cast(@tableName + '#Base' as nvarchar(60));

			-- build source select statement and column list
			-- to use in un-pivot expression

			select
				@columnList			= isnull(@columnList + @CRLF + @TAB + @TAB + ',', @TAB + @TAB + ' ') + vc.ColumnName
			 ,@ReplacementSQL =
					isnull(@ReplacementSQL + @CRLF + @TAB + @TAB + ',', @TAB + 'select' + @CRLF + @TAB + @TAB + ' ') + 'isnull(convert(nvarchar(max),'
					+ (case
						 when vc.DataType = 'DateTimeOffset' then 'sf.fDTOffsetToClientDateTime(x.' + vc.ColumnName + ')'
						 when vc.DataType = 'UniqueIdentifier' then 'cast(x.' + vc.ColumnName + ' as nvarchar(50))'
						 else 'x.' + vc.ColumnName
						 end
						) + '), N''~'')' + @TAB + vc.ColumnName
			from
				sf.vViewColumn vc
			where
				vc.SchemaName		= @schemaName and vc.ViewName = N'v' + @viewName and vc.DataType <> 'timestamp' -- timestamp + varbinary types are not supported!
				and vc.DataType <> 'varbinary'
			order by
				vc.OrdinalPosition;

			set @ReplacementSQL += @CRLF + 'from' + @CRLF + @TAB + @schemaName + '.v' + @viewName + ' x ' + @CRLF + 'where' + @CRLF + @TAB + 'x.'
														 + (case when @schemaName = N'dbo' and @tableName = 'EpisodeReport' then 'EpisodeReportSID' 
														 when @schemaName = N'dbo' and @tableName = 'RegistrantRenewal#Search' then 'RegistrantLicenseSID'
														 else replace(@tableName, '#Search', '') + 'SID' end
															 ) + ' = ' + ltrim(@RecordSID);

			-- insert the inner select of source values into the completed
			-- statement with un-pivot section to flip columns to rows

			set @ReplacementSQL =
				N'select' + @CRLF + @TAB + '''[@'' + u.ColumnName + '']''' + @CRLF + @TAB + ',u.ReplacementValue' + @CRLF + 'from' + @CRLF + '(' + @CRLF
				+ @ReplacementSQL + @CRLF + ') p' + @CRLF + 'unpivot' + @CRLF + '(' + @CRLF + @TAB + 'ReplacementValue' + @CRLF + @TAB + 'for ColumnName in ' + @CRLF
				+ @TAB + '(' + @CRLF + @columnList + @CRLF + @TAB + ')' + @CRLF + ') u;';

		end;

		-- execute the dynamic SQL inserting the resulting
		-- tokens and replacement values into the memory table

		insert
			@source (MergeToken, ReplacementValue)
		exec sp_executesql @ReplacementSQL;

		select	@maxRow = count(1) from @TokenMap rm;
		set @i = 0;

		-- loop through the table replacing tokens with values in the string
		-- Note: if performance unacceptable, an alternative algorithm could 
		-- be tried using stuff() rather than replace()

		while @i < @maxRow
		begin

			set @i += 1;

			select
				@TextTemplate = replace(@TextTemplate, s.MergeToken, s.ReplacementValue)
			from
				@TokenMap rm
			join
				@source		s on rm.MergeToken = s.MergeToken
			where
				rm.ID = @i;

		end;

		-- finalize the format of the string by removing NULL markers
		-- (tilde characters) and trimming spaces for side-by-side nulls

		set @TextTemplate = replace(@TextTemplate, N' ~ ', ' ');
		set @TextTemplate = replace(@TextTemplate, N' ~', '');
		set @TextTemplate = replace(@TextTemplate, N'~ ', '');
		set @TextTemplate = replace(@TextTemplate, N'~', '');

		-- before passing back the sql string - update the key value
		-- with a token for replacement on next pass in

		set @ReplacementSQL = replace(@ReplacementSQL, ' = ' + ltrim(@RecordSID), ' = [@@SourceRecordSID]');

	end try

	begin catch
		print @ReplacementSQL; -- send dynamic SQL statement to console for debugging
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
