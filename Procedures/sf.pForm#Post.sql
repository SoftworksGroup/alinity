SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pForm#Post
	@FormRecordSID	int						-- key of the form record (e.g. RegistrantAppSID)
 ,@FormActionCode varchar(15)		-- either 'SUBMIT' or 'APPROVE'
 ,@FormSchemaName nvarchar(128) -- schema of the form record (e.g. "dbo")
 ,@FormTableName	nvarchar(128) -- table containing the form responses (e.g. "RegistrantApp")
 ,@FormDefinition xml						-- the definition of the form from sf.FormVersion
 ,@Response				xml						-- the form responses to post - the approved content
 ,@DebugLevel			tinyint = 0		-- when > 0 sends generated SQL to console without executing
as
/*********************************************************************************************************************************
Procedure : Form Post
Notice    : Copyright © 2017 Softworks organization Inc.
Summary   : Posts values from approved forms into the main database tables
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Jul 2017		| Initial version
					: Tim Edlund	| Oct 2017		| Support mapping of field values to keys on the entity (no hidden field required)
					: Cory Ng			| Jan 2018		| Support multiple inserts or upserts for the same entity type on the main form
					: Tim Edlund	| Feb 2018		| Support assignment of primary key value on upsert to output variable.
					: Tim Edlund	| Jun 2018		| Added support for ~IsInsertEnabled field property to exclude records where user has
																				not marked the record for insert but default values exist in the form record.
					: Tim Edlund	| Sep 2018		| Improved performance of XML parse through introduction of OpenXML() function

Comments
--------
This procedure writes input saved into configured forms to database tables according to the mappings specified in the form design.
The procedure is expected to be called most frequently from #Approve sprocs (e.g. pRegistrantApp#Approve) to write values entered 
by the user to the main database tables.  Typically this is done only after the form has been approved by an administrator.  

All parameters must be passed. 

If the procedure detects that the form configuration includes no tables for updating, then it terminates early. The procedure parses
the "DBLink" section of the form definition.   The routine expects the following values for "LinkType" in the XML that defines
the form:

		ReadFirst							-- no action taken by this routine; database is read but not updated
    ReadLive							-- no action taken by this routine; database is read but not updated
    ReadLive_Insert				-- value is read onto the form whenever form is opened and then updated on posting by this routine
    ReadLive_Update				-- value is read onto the form whenever form is opened and then inserted to different table on posting
		ReadLive_Upsert				-- similar to insert but existing row is updated if it exists (requires #Upsert sproc on the table!)
    ReadFirst_Update			-- value is read onto the form on initial creation and then updated on posting by this routine
    ReadFirst_Insert			-- value is read onto the form on initial creation, then inserted into a different table on posting
    Insert								-- no value is read; no default - the values are inserted into a table on posting by this routine

Note that an "Update" direction is not valid without a read specification since a primary key value will be required to make the
update.  This routine reads the last 6 characters of this property to establish the database action required.

Support for inserting and updating multiple records of the same entity type in the main form is possible by specifying a RecordNo
on the DB link node on the form definition. The RecordNo uniquely identifies which FieldIDs should edit which records.

The test section includes a comprehensive example of a complete form with responses but the relevant part of the form definition 
for this procedure is the "DBLinks" section.  An example of the format expected in this section appears below:

<DBLinks>
...
    <Link Type="ReadFirst_Update" SchemaAndTableName="sf.Person" PostOnSubmit="True">
      <Statement>
        select
            p.FirstName [FirstName]
          , p.LastName [LastName]
          , p.MiddleNames [MiddleNames]
          , p.CommonName [CommonName]
          , convert(nvarchar(10), p.BirthDate, 126) [BirthDate]
          , p.HomePhone [HomePhone]
          , p.MobilePhone [MobilePhone]
        from
          sf.Person p
        join
          dbo.Registrant r
            on p.PersonSID = r.PersonSID
        where
          r.RegistrantSID = @RegistrantSID
      </Statement>
      <ResponseMapping>
        <Mapping FieldID="FirstName" Column="FirstName" />
        <Mapping FieldID="LastName" Column="LastName" />
        <Mapping FieldID="MiddleName" Column="MiddleNames" />
        <Mapping FieldID="CommonName" Column="CommonName" />
        <Mapping FieldID="DOB" Column="BirthDate" />
        <Mapping FieldID="HomePhone" Column="HomePhone" />
        <Mapping FieldID="MobilePhone" Column="MobilePhone" />
        <Mapping FieldID="RegistrantPersonSID" Column="PersonSID" IsEntityKey="True" />
      </ResponseMapping>
    </Link>
---
</DBLinks>

-- and responses

<FormResponses>
  <Response FieldID="FirstName" Value="Jovelyn" />
  <Response FieldID="LastName" Value="Flores" />
  <Response FieldID="MiddleName" Value="" />
  <Response FieldID="CommonName" Value="" />
  <Response FieldID="DOB" Value="1967-02-09" />
...
</FormReponses>

Example:
--------

Test from front end by completing an input form and then approving it.  A hard-coded test case appears below
but this test will be invalid depending on the state of the testing DB and its key values:

declare
	@formRecordSID	int						= 1001007
 ,@formSchemaName nvarchar(128) = 'dbo'
 ,@formTableName	nvarchar(128) = 'RegistrantApp'
 ,@response				xml
 ,@formDefinition xml;
select
	@formDefinition = fv.FormDefinition
 ,@response				= x.FormResponseDraft
from
	dbo.RegistrantApp x
join
	sf.FormVersion		fv on x.FormVersionSID = fv.FormVersionSID
where
	x.RegistrantAppSID = @formRecordSID;

exec sf.pForm#Post
	@FormRecordSID = @formRecordSID
 ,@FormActionCode = 'APPROVE'
 ,@FormSchemaName = @formSchemaName
 ,@FormTableName = @formTableName
 ,@FormDefinition = @formDefinition
 ,@Response = @response
 ,@DebugLevel = 2;	-- any value > 0 will print the SQL without executing it; 2 will show raw xml parse as a select
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)										-- message text (for business rule errors)    
	 ,@blankParm		varchar(50)												-- tracks if any required parameters are not provided     
	 ,@ON						bit							 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@OFF					bit							 = cast(0 as bit) -- used on bit comparisons to avoid multiple casts  
	 ,@CRLF					nchar(2)				 = char(13) + char(10)
	 ,@TAB					nchar(1)				 = char(9)
	 ,@debugString	nvarchar(70)											-- debugging trace label
	 ,@timeCheck		datetimeoffset(7)									-- performance checking time mark
	 ,@iDocForm			int																-- internal representation of form document
	 ,@iDocResp			int																-- internal representation of response document
	 ,@schemaName		nvarchar(128)
	 ,@tableName		nvarchar(128)
	 ,@linkType			varchar(6)
	 ,@formID				varchar(50)
	 ,@respID				varchar(50)
	 ,@recordNo			int
	 ,@sprocSQL			nvarchar(max)
	 ,@selectSQL		nvarchar(max)
	 ,@sqlScript		nvarchar(max)
	 ,@value				nvarchar(max)											-- value of parameter stored as string
	 ,@entityKeyCol varchar(128)											-- name of mapped entity key column
	 ,@userName			nvarchar(75)											-- login of current user (for error logging)
	 ,@maxRow				int
	 ,@i						int;

	declare @map table
	(
		ID							int						not null identity(1, 1)
	 ,FieldID					nvarchar(128) not null
	 ,SchemaName			nvarchar(128) not null
	 ,TableName				nvarchar(128) not null
	 ,IsEntityKey			bit						not null default cast(0 as bit)
	 ,FormID					varchar(50)		not null
	 ,RespID					varchar(50)		not null
	 ,ColumnName			nvarchar(128) not null
	 ,Value						nvarchar(max) null
	 ,LinkType				varchar(6)		not null
	 ,RecordNo				int						not null default 1
	 ,PostOnSubmit		bit						not null default cast(0 as bit) -- indicates record should post on SUBMIT (not just APPROVED) event
	 ,IsInsertEnabled bit						not null												-- indicates whether entry should be inserted or upserted (default is ON)
	);

	declare @target table
	(
		ID								int						not null identity(1, 1)
	 ,SchemaName				nvarchar(128) not null
	 ,TableName					nvarchar(128) not null
	 ,LinkType					varchar(6)		not null default N'Insert'
	 ,TableLevel				int						not null
	 ,FormID						varchar(50)		not null
	 ,RespID						varchar(50)		not null
	 ,RecordNo					int						not null default 1
	 ,OperationSequence int						not null
	);

	declare @variable table
	(
		ID								int						not null identity(1, 1)
	 ,VariableName			nvarchar(128) not null
	 ,TypeSpecification varchar(50)		not null
	);

	begin try

		-- check parameters

		if @DebugLevel > 1
		begin
			set @debugString = object_name(@@procid) + N' start';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

		end;

-- SQL Prompt formatting off
		if @FormRecordSID		is null set @blankParm = '@FormRecordSID';
		if @FormSchemaName	is null set @blankParm = '@FormSchemaName';
		if @FormTableName		is null set @blankParm = '@FormTableName';
		if @FormDefinition	is null set @blankParm = '@FormDefinition';
		if @Response				is null set @blankParm = '@Response';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @FormActionCode not in ('SUBMIT', 'APPROVE')
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'form action code'
			 ,@Arg2 = @FormActionCode
			 ,@Arg3 = '"SUBMIT", "APPROVE"';

			raiserror(@errorText, 18, 1);
		end;

		if @DebugLevel > 0
		begin

			select -- output values for confirmation when debugging
				@FormSchemaName + '.' + @FormTableName FormTable
			 ,@FormRecordSID												 FormRecordSID
			 ,@FormDefinition												 FormDefinition
			 ,@Response															 Response;

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'map insert starting'
				 ,@TimeCheck = @timeCheck output;

			end;

		end;

		exec sp_xml_preparedocument
			@hdoc = @iDocForm output
		 ,@xmlTest = @FormDefinition; -- create internal representation of form doc for openXML()   

		exec sp_xml_preparedocument
			@hdoc = @iDocResp output
		 ,@xmlTest = @Response; -- create internal representation of response doc for openXML()   

		-- parse the form definition to retrieve the update values and the
		-- database tables and columns they map to

		insert
			@map
		(
			FormID
		 ,RespID
		 ,SchemaName
		 ,TableName
		 ,FieldID
		 ,ColumnName
		 ,IsEntityKey
		 ,Value
		 ,LinkType
		 ,RecordNo
		 ,PostOnSubmit
		 ,IsInsertEnabled
		)
		select distinct
			isnull((case when map.IsEntityKey = @ON then map.FormID else resp.FormID end), '0') FormID
		 ,isnull(resp.RespID, '0')
		 ,cast(sf.fStringSegment(map.SchemaAndTableName, '.', 1) as nvarchar(128))						SchemaName
		 ,cast(sf.fStringSegment(map.SchemaAndTableName, '.', 2) as nvarchar(128))						TableName
		 ,map.FieldID
		 ,map.ColumnName
		 ,isnull(map.IsEntityKey, @OFF)
		 ,resp.Value
		 ,map.LinkType
		 ,isnull(map.RecordNo, 1)
		 ,isnull(map.PostOnSubmit, @OFF)
		 ,(case when map.ColumnName = '~IsInsertEnabled' then @OFF else @ON end)	-- default value; set with UPDATE below
		from
		(
			select
				FormID	-- the form ID is only filled in for repeating forms
			 ,SchemaAndTableName
			 ,right(LinkType, 6) LinkType
			 ,PostOnSubmit
			 ,FieldID
			 ,ColumnName
			 ,IsEntityKey
			 ,RecordNo
			from
				--				@FormDefinition.nodes('//Mapping') formDef(fd)
				openxml(@iDocForm, '//Mapping', 2)
				with
				(
					FormID varchar(50) '../@SubFormID'
				 ,SchemaAndTableName nvarchar(257) '../../@SchemaAndTableName'
				 ,LinkType varchar(25) '../../@Type'
				 ,PostOnSubmit bit '../../@PostOnSubmit'
				 ,FieldID nvarchar(128) '@FieldID'
				 ,ColumnName nvarchar(128) '@Column'
				 ,IsEntityKey bit '@IsEntityKey'
				 ,RecordNo nvarchar(257) '../../@RecordNo'
				)
		) map
		left outer join
		(
			select
				FormID
			 ,RespID
			 ,FieldID
			 ,Value
			from
				openxml(@iDocResp, '//Response', 2)
				with
				(
					FormID varchar(50) '../@FormID'
				 ,RespID varchar(50) '../@RespUUID'
				 ,FieldID nvarchar(128) '@FieldID'
				 ,Value nvarchar(max) '@Value'
				)
		) resp on isnull(map.FormID, 'main') = isnull(resp.FormID, 'main') -- form ID is not provided in mapping or response for main form (default it)
							and map.FieldID						 = resp.FieldID
		where
			right(map.LinkType, 6) in ('Insert', 'Update', 'Delete', 'Upsert') -- link types that don't impact the DB are ignored
			and
			(
				map.IsEntityKey										= @ON -- if field is mapped to entity a value is not required
				or
				(
					resp.Value is not null -- blank and null value overwrites are not supported (ignored)
					and resp.Value									<> N'-' -- single hyphens are treated as null (no drop-down list selection)
					and
					(
						len(ltrim(rtrim(resp.Value))) > 0 or map.ColumnName = '~IsInsertEnabled'
					)
				)
			);

		-- if there are no target tables the procedure exits early

		if @@rowcount > 0
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'map insert complete'
				 ,@TimeCheck = @timeCheck output;

			end;

			exec sp_xml_removedocument @hdoc = @iDocForm;		-- remove the xml docs to return memory
			exec sp_xml_removedocument @hdoc = @iDocResp;

			-- update the mappings to assign the sub-form ID to
			-- entity keys not directly mapped in the form XML

			update
				m
			set
				m.RespID = m2.RespID
			from
				@map m
			join
				@map m2 on m.FormID = m2.FormID and m2.RespID <> '0'
			where
				m.IsEntityKey = @ON and m.FormID <> '0' and m.RespID = '0';

			-- delete mappings for sub-forms where no content is provided 
			-- or where insert is disabled

			delete
			m
			from
				@map m
			join
			(
				select
					m.FormID
				 ,count(m.Value) ValuesProvided
				from
					@map m
				where
					isnull(m.FormID, '0') <> '0'
				group by
					m.FormID
			)			 x on m.FormID = x.FormID
			where
				x.ValuesProvided = 0; --or m.IsInsertEnabled = @OFF;

			-- perform a similar analysis for the main form by ensuring there is 
			-- is at least one entered value for each entity since "RecordNo" allows 
			-- multiple records to be specified on the main form

			delete
			m
			from
				@map m
			join
			(
				select
					m.SchemaName
				 ,m.TableName
				 ,count(m.Value) ValuesProvided
				from
					@map m
				where
					isnull(m.FormID, '0') = '0'
				group by
					m.SchemaName
				 ,m.TableName
			)			 x on m.SchemaName = x.SchemaName and m.TableName = x.TableName
			where
				x.ValuesProvided = 0;

			-- finally delete mappings on sub-forms where the IsInsertEnabled parameter is used
			-- on at least one record for the form type but not on this response; this occurs when 1 
			-- or mored fields default on the sub-form record but the bit value to include it is NULL

			delete
			m
			from
				@map m
			join
			(
				select distinct
					fd.FormID
				from
					@map fd
				where
					fd.ColumnName = '~IsInsertEnabled'
			)			 x on m.FormID = x.FormID
			join
			(
				select
					m.FormID
				 ,m.RespID
				 ,sum(case when m.ColumnName = '~IsInsertEnabled' then cast(cast(m.Value as bit) as int)else 0 end) IsInsertEnabledCount
				from
					@map m
				group by -- join to the form type that uses "~IsInsertEnabled"
					m.FormID	-- but this sub-form doesn't have the column (it is NULL)
				 ,m.RespID
			)			 z on x.FormID = z.FormID and m.RespID = z.RespID and z.IsInsertEnabledCount = 0;

			if @DebugLevel > 1
			begin

				if @DebugLevel > 1
				begin

					exec sf.pDebugPrint
						@DebugString = 'map deletions complete'
					 ,@TimeCheck = @timeCheck output;

				end;

				select
					m.ID
				 ,m.SchemaName
				 ,m.TableName
				 ,m.LinkType
				 ,m.FormID
				 ,m.ColumnName
				 ,m.FieldID
				 ,m.IsEntityKey
				 ,m.RespID
				 ,m.Value
				 ,m.RecordNo
				 ,m.PostOnSubmit
				 ,m.IsInsertEnabled
				from
					@map m
				order by
					m.SchemaName
				 ,m.TableName
				 ,m.LinkType
				 ,m.ID
				 ,m.RecordNo;

			end;

			-- insert statements must be processed in parent-child order according
			-- foreign keys so create a work table to control the sequence of all updates

			insert
				@target
			(
				SchemaName
			 ,TableName
			 ,LinkType
			 ,TableLevel
			 ,FormID
			 ,RespID
			 ,RecordNo
			 ,OperationSequence
			)
			select distinct
				map.SchemaName
			 ,map.TableName
			 ,map.LinkType
			 ,tl.TableLevel
			 ,map.FormID	-- a target record is created for each form/sub-form and record
			 ,map.RespID
			 ,map.RecordNo
			 ,(case when map.LinkType = 'Insert' then 3 when map.LinkType = 'Upsert' then 2 else 1 end) OperationSequence
			from
				@map					 map
			join
				sf.vTableLevel tl on map.SchemaName = tl.SchemaName and map.TableName = tl.TableName
			where -- limit tables to POST-ON-SUBMIT unless APPROVE is the action
				(@FormActionCode <> 'SUBMIT' or map.PostOnSubmit = @ON)
			order by -- ensures dependency order! (parents then children)
				tl.TableLevel
			 ,map.SchemaName
			 ,map.TableName
			 ,(case when map.LinkType = 'Insert' then 3 when map.LinkType = 'Upsert' then 2 else 1 end) -- process updates BEFORE insert/upsert when adding and updating to same table
			 ,map.FormID
			 ,map.RespID;

			set @maxRow = @@rowcount; -- store row count for stored procedure call formatting

			if @DebugLevel > 1 -- if debug mode is verbose (>1) then show mapping details
			begin

				if @DebugLevel > 1
				begin

					exec sf.pDebugPrint
						@DebugString = 'target insert complete'
					 ,@TimeCheck = @timeCheck output;

				end;

				select
					t.TableLevel
				 ,t.SchemaName
				 ,t.TableName
				 ,t.LinkType
				 ,t.FormID
				 ,t.RespID
				 ,t.RecordNo
				from
					@target t
				order by
					t.TableLevel
				 ,t.SchemaName
				 ,t.TableName
				 ,t.LinkType
				 ,t.FormID
				 ,t.RespID
				 ,t.RecordNo;

			end;

			-- store the PK and FK columns from the main form record
			-- as variables for assignment to procedure parameters

			insert
				@variable (VariableName, TypeSpecification)
			select
				N'@' + lower(left(vc.ColumnName, 1)) + substring(vc.ColumnName, 2, 127)
			 ,vc.TypeSpecification
			from
				sf.vViewColumn vc
			where
				vc.SchemaName = @FormSchemaName and vc.ViewName = N'v' + @FormTableName and right(vc.ColumnName, 3) = 'SID'
			order by
				vc.OrdinalPosition;

			if @@rowcount = 0
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Entity Definition (sf.ViewColumn)'
				 ,@Arg2 = @FormTableName;

				raiserror(@errorText, 18, 1);
			end;

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'variable insert complete'
				 ,@TimeCheck = @timeCheck output;

			end;

			-- create SELECT statement to retrieve the key values
			-- from the entity view

			select
				@selectSQL =
				isnull(@selectSQL + @CRLF + @TAB + ',' + @TAB, N'select' + @CRLF + @TAB + @TAB) + v.VariableName + N' = x.' + upper(substring(v.VariableName, 2, 1))
				+ substring(v.VariableName, 3, 127)
			from
				@variable v
			order by
				v.ID;

			set @selectSQL += @CRLF + N'from' + @CRLF + @TAB + @FormSchemaName + N'.v' + @FormTableName + N' x' + @CRLF + N'where' + @CRLF + @TAB + N'x.'
												+ @FormTableName + N'SID = ' + ltrim(@FormRecordSID);

			-- add a variable declaration for the primary key of
			-- each table if not already in the main entity

			insert
				@variable (VariableName, TypeSpecification)
			select distinct
				pk.VariableName
			 ,'int'
			from
			(
				select
					N'@' + lower(left(tgt.TableName, 1)) + substring(tgt.TableName, 2, 126) + 'SID' VariableName
				from
					@target tgt
			)						pk
			left outer join
				@variable v on pk.VariableName = v.VariableName
			where
				v.VariableName is null;

			-- create the syntax for declaring the variables
			-- required to support the parameter assignments

			select
				@sqlScript = isnull(@sqlScript + @CRLF + @TAB + ',' + @TAB, N'declare' + @CRLF + @TAB + @TAB) + v.VariableName + N' ' + v.TypeSpecification
			from
				@variable v
			order by
				v.ID;

			set @sqlScript += @CRLF + @CRLF + @selectSQL;

			-- now create syntax for inserting or updating
			-- each target table

			set @i = 0;

			while @i < @maxRow
			begin
				set @i += 1;
				set @sprocSQL = null;

				select
					@schemaName = w.SchemaName
				 ,@tableName	= w.TableName
				 ,@linkType		= w.LinkType
				 ,@formID			= w.FormID
				 ,@respID			= w.RespID
				 ,@recordNo		= w.RecordNo
				from
					@target w
				where
					w.ID = @i;

				-- create syntax for the sproc call for this record

				select
					@sprocSQL =
					isnull(@sprocSQL + @CRLF, N'') + @TAB + N',' + @TAB + N'@' + vc.ColumnName + N' = '
					+ (case
							 when charindex('int', vc.DataType) > 0 then (case
																															when m.IsEntityKey = @ON then N'@' + m.FieldID
																															else isnull(sf.fFormatString#StripToInt(cast(m.Value as nvarchar(50))), v.VariableName)
																														end
																													 )
							 when vc.DataType = 'decimal' or vc.DataType = 'float' or vc.DataType = 'bit' then m.Value
							 when vc.DataType = 'nchar' or vc.DataType = 'nvarchar' then sf.fQuoteString(m.Value)
							 else 'N' + sf.fQuoteString(m.Value)
						 end
						)
				from
					sf.vViewColumn vc -- use the entity view column set as a base to allow virtual columns to be applied
				left outer join
					@map					 m on vc.SchemaName											 = m.SchemaName
															and substring(vc.ViewName, 2, 128) = m.TableName
															and vc.ColumnName									 = m.ColumnName -- join to mapped instance of the column in the form if it exists
															and m.LinkType										 = @linkType
															and m.FormID											 = @formID
															and (m.RespID											 = @respID or m.IsEntityKey = @ON)
															and m.RecordNo										 = @recordNo
				left outer join
					@variable			 v on N'@' + vc.ColumnName							 = v.VariableName	 -- also map to variables to get foreign key values
				where
					vc.SchemaName											 = @schemaName
					and substring(vc.ViewName, 2, 128) = @tableName
					and (m.ColumnName is not null or v.VariableName is not null) -- if no content for column - ignore (will have to default)
					and vc.OrdinalPosition						 > 1	-- the primary key value is handled separately below
				order by
					vc.OrdinalPosition;

				if @sprocSQL is null
				begin
					exec sf.pMessage#Get
						@MessageSCD = 'InvalidColumnSpecified'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'One or more database column names identified in the form are invalid (entity = "%1.%2" and action = "%3".)'
					 ,@Arg1 = @schemaName
					 ,@Arg2 = @tableName
					 ,@Arg3 = @linkType;

					raiserror(@errorText, 18, 1);
				end;

				-- the PK value for update calls may be mapped from the entity view
				-- or retrieved to a hidden column; check for those 2 locations
				-- and otherwise use the variable (s/b populated by previous insert)

				set @value = null;
				set @entityKeyCol = null;

				select
					@value				= m.Value
				 ,@entityKeyCol = (case when m.IsEntityKey = @ON then m.FieldID else null end)
				from
					@map m
				where
					m.SchemaName		 = @schemaName
					and m.TableName	 = @tableName
					and m.ColumnName = @tableName + 'SID'
					and m.LinkType	 = @linkType
					and m.FormID		 = @formID
					and (m.RespID		 = @respID or m.IsEntityKey = @ON);

				set @sprocSQL =
					N'exec ' + @schemaName + N'.p' + @tableName + N'#' + @linkType + @CRLF + @TAB + @TAB -- insert syntax for primary key
					+ N'@' + @tableName + N'SID = '
					+ (case
							 when left(@linkType, 2) = 'Up' and @entityKeyCol is not null then '@' + lower(left(@entityKeyCol, 1)) + substring(@entityKeyCol, 2, 127)
							 when @value is null or @linkType <> 'Update' then '@' + lower(left(@tableName, 1)) + substring(@tableName, 2, 127) + 'SID'
							 else sf.fQuoteString(@value)
						 end
						) + (case when @linkType in ('Insert', 'Upsert') then ' output' else '' end) + @CRLF + @sprocSQL;

				-- for upserts only - pass the UUID (Response ID) from the form as 
				-- the @RowGUID parameter - used to check if row already exists

				if @linkType = 'Upsert' and @respID is not null and try_cast(@respID as uniqueidentifier) is not null
				begin
					set @sprocSQL = @sprocSQL + @CRLF + @TAB + N',' + @TAB + N'@RowGUID = ''' + @respID + N'''';

					-- if a value was provided for the primary key output variable
					-- for #Upsert, set it prior to the sproc call

					if @value is not null and @entityKeyCol is null
					begin
						set @sqlScript += @CRLF + @CRLF + N'set @' + lower(left(@tableName, 1)) + substring(@tableName, 2, 127) + N'SID = ' + ltrim(@value);
					end;

				end;

				set @sqlScript += @CRLF + @CRLF + @sprocSQL;

			end;

			if @DebugLevel > 1
			begin

				set @debugString = N'sproc calls generated';

				exec sf.pDebugPrint
					@DebugString = @debugString
				 ,@TimeCheck = @timeCheck output;

			end;

			if @DebugLevel > 0 -- do not execute statement if debug mode is active
			begin
				print @sqlScript; -- print generated script to console
			end;
			else
			begin
				exec sp_executesql @stmt = @sqlScript;	-- otherwise, execute the generated script
			end;

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'sproc exec/printing complete'
				 ,@TimeCheck = @timeCheck output;

			end;

		end;
	end try
	begin catch

		-- avoid losing the details of high severity errors arising from
		-- dynamic SQL posting them to the error log outside of normal handler

		if error_severity() >= 18
		begin

			set @userName = sf.fApplicationUserSession#UserName();

			insert
				sf.UnexpectedError
			(
				MessageSCD
			 ,ProcName
			 ,LineNumber
			 ,ErrorNumber
			 ,MessageText
			 ,ErrorSeverity
			 ,ErrorState
			 ,SPIDNo
			 ,MachineName
			 ,DBUser
			 ,CallParameter
			 ,CallEvent
			 ,CallSyntax
			 ,CreateUser
			 ,UpdateUser
			)
			select
				'ErrorOnDynamicSQL'
			 ,error_procedure()
			 ,error_line()
			 ,error_number()
			 ,sf.fErrorDetailsStrip(error_message())
			 ,error_severity()
			 ,error_state()
			 ,@@spid
			 ,lower(host_name())
			 ,lower(suser_sname())
			 ,0
			 ,'DynamicSQL'
			 ,cast(@sqlScript as varchar(4000))
			 ,@userName
			 ,@userName;

		end;

		-- and then re-throw instigating error for the end-user

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
