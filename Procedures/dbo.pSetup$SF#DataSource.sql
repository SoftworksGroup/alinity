SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#DataSource]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Procedure	: pSetup$DataSource
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Ensures the sf.DataSource table is updated with a basic list based on entities in application page
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version (revised approach from original version developed by Kris Dawson)
				: Tim Edlund					| Oct 2018		| Expanded data sources to include all views related to a base entity

Comments	
--------
This procedure is run during setup to ensure the sf.DataSource table has a record for all product entities, and an entry for
each view specifically identified for EXPORT.  Views designated for export may be in any schema including EXT (custom views).

The entire content of the table is replaced each time the procedure is run to ensure all deprecated entries are dropped.  Any 
default configuration saved for a data source export is saved before the drop occurs so that it can be re-applied into the new 
versions of the records.  The procedure processes the updates as a single transaction so that the previous configuration of
data sources is only replaced if all operations succeed.

Note that all data source records are created regardless of whether the configuration has the Database Management module
implemented.  The restriction on exports is implemented on the setup of sf.DataSourceApplicationPage.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#DataSource
				 @SetupUser = 'system@softworksgroup.com'
				,@Language = 'EN'
				,@Region = 'Alinity'	

			select * from sf.DataSource

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#DataSource'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000)													-- message text (for business rule errors)
	 ,@tranCount		 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName			 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState				 int																		-- error state detected in catch block
	 ,@ON						 bit					 = cast(1 as bit)					-- constant for bit comparison and assignments
	 ,@fileFormatSID int;																		-- key of default file format for data sources

	declare @work table
	(
		ID							int								not null identity(1, 1)
	 ,DataSourceLabel nvarchar(35)			not null
	 ,DBObjectName		nvarchar(257)			not null
	 ,ToolTip					nvarchar(500)			null
	 ,FileFormatSID		int								not null
	 ,ExportDefaults	xml								not null default (convert(xml, '<ExportDefaults />'))
	 ,LastExecuteTime datetimeoffset(7) null default sysdatetimeoffset()
	 ,LastExecuteUser nvarchar(75)			null
	 ,ExecuteCount		int								not null default (0)
	);

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		-- get default file format for new data sources

		select
			@fileFormatSID = ff.FileFormatSID
		from
			sf.FileFormat ff
		where
			ff.IsDefault = @ON;

		if @fileFormatSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = '"Default File Format"';

			raiserror(@errorText, 17, 1);

		end;

		-- first load the work table with base entity views preserving
		-- configuration content from existing data source records

		insert
			@work
		(
			DataSourceLabel
		 ,DBObjectName
		 ,ToolTip
		 ,FileFormatSID
		 ,ExportDefaults
		 ,LastExecuteTime
		 ,LastExecuteUser
		 ,ExecuteCount
		)
		select	(case when len(x.EntityName) <= 35 then x.EntityName else left(x.TableName, 35)end) DataSourceLabel
		 ,x.SchemaAndViewName
		 ,replace(replace(x.DefaultDescription, '%1', x.EntityName), '%2', x.TableName)
			+ (case
					 when x.ParentEntityList is null or len(x.ParentEntityList) = 0 then ''
					 else ' Directly related parent tables include: ' + x.ParentEntityList + '.'
				 end
				)
		 ,isnull(ds.FileFormatSID, @fileFormatSID)
		 ,isnull(ds.ExportDefaults, (convert(xml, '<ExportDefaults />')))
		 ,isnull(ds.LastExecuteTime, sysdatetimeoffset())
		 ,isnull(ds.LastExecuteUser, @SetupUser)
		 ,isnull(ds.ExecuteCount, 0)
		from
		(
			select
				v.SchemaAndViewName
			 ,t.TableName
			 ,sf.fObjectNameSpaced(t.TableName)																			 EntityName
			 ,'Base fields for "%1". This data source includes all exportable fields for the %2 table and '
				+ 'descriptive fields from parent tables and other calculated fields.' DefaultDescription -- create a default description which may include parent entities list
			 ,ltrim(substring((
													select
														', ' + sf.fObjectNameSpaced(fk.UKTableName) as [text()]
													from
														sf.vForeignKey fk
													where
														fk.FKSchemaName = t.SchemaName and fk.FKTableName = t.TableName
													for xml path('')
												)
												,3
												,1000
											 )
						 )																																 ParentEntityList
			from
				sf.vView	v
			join
				sf.vTable t on v.BaseSchemaName = t.SchemaName and v.BaseTableName = t.TableName	-- must match on a base table (entity view naming convention)
			where
				(v.SchemaName = 'dbo' or v.SchemaName = 'sf' or v.SchemaName = 'stg') and v.ViewName = 'v' + t.TableName	-- match on entity view name convention (no #Ext's etc.)
		)								x
		left outer join
			sf.DataSource ds on x.SchemaAndViewName = ds.DBObjectName -- check for this data source existing to preserve configuration settings and execution values
		order by
			x.SchemaAndViewName;

		-- next load table with non-base views which have been 
		-- marked with "|EXPORT" in the ms_description property

		insert
			@work
		(
			DataSourceLabel
		 ,DBObjectName
		 ,ToolTip
		 ,FileFormatSID
		 ,ExportDefaults
		 ,LastExecuteTime
		 ,LastExecuteUser
		 ,ExecuteCount
		)
		select	(case
							 when len(x.EntityName + isnull(' - ' + x.LabelSuffix, '')) <= 35 then x.EntityName + isnull(' - ' + x.LabelSuffix, '')
							 else left(replace(x.EntityName + isnull(' - ' + x.LabelSuffix, ''), ' ', ''), 35)
						 end
						) DataSourceLabel
		 ,x.SchemaAndViewName
		 ,x.ViewDescription
		 ,isnull(ds.FileFormatSID, @fileFormatSID)
		 ,isnull(ds.ExportDefaults, (convert(xml, '<ExportDefaults />')))
		 ,isnull(ds.LastExecuteTime, sysdatetimeoffset())
		 ,isnull(ds.LastExecuteUser, @SetupUser)
		 ,isnull(ds.ExecuteCount, 0)
		from
		(
			select
				v.SchemaAndViewName
			 ,t.TableName
			 ,sf.fObjectNameSpaced(t.TableName)								 EntityName
			 ,(case
					 when charindex('#', v.ViewName) > 1 then sf.fObjectNameSpaced(substring(v.ViewName, charindex('#', v.ViewName) + 1, 128))
					 else cast(null as nvarchar(128))
				 end
				)																								 LabelSuffix
			 ,left(v.Description, (case
															 when isnull(charindex('|', v.Description), 0) - 1 < 0 then len(v.Description)
															 else (charindex('|', v.Description) - 1)
														 end
														))													 ViewDescription
			 ,cast(charindex('|EXPORT', v.Description) as bit) IsExport
			from
				sf.vView	v
			join
				sf.vTable t on ((v.BaseSchemaName	 = t.SchemaName and v.BaseTableName = t.TableName) -- must either have a direct base table associated
												or -- the view is in the extended schema and matches a table name in one of the product schema
												(
													v.BaseSchemaName = 'ext'
													and t.TableName	 = substring(sf.fStringSegment(v.ViewName, '#', 1), 2, 128)
													and t.SchemaName in ('dbo', 'sf', 'stg')
												)
												or -- the view is in the dbo schema where the base table is in the framework schema (especially dbo.vPerson% views)
												(
													v.BaseSchemaName = 'dbo' and t.TableName = substring(sf.fStringSegment(v.ViewName, '#', 1), 2, 128) and t.SchemaName = 'sf'
												)
											 )
			where
				(
					v.SchemaName						 = 'dbo' or v.SchemaName = 'sf' or v.SchemaName = 'stg' or v.SchemaName = 'ext'
				) and right(v.ViewName, 4) <> '#Ext'
		)								x
		left outer join
			sf.DataSource ds on x.SchemaAndViewName = ds.DBObjectName -- check for this data source existing to preserve configuration settings and execution values
		left outer join
			@work					w on x.SchemaAndViewName	= w.DBObjectName -- join to previous loaded views to avoid any duplicate (in case custom descriptions supported later)
		where
			--x.IsExport = @ON and w.DBObjectName is null
			w.DBObjectName is null
		order by
			x.SchemaAndViewName;

		-- with the work table loaded with all data sources the 
		-- content of the existing data source tables is dropped

		delete from sf.DataSourceApplicationPage where DataSourceSID is not null; -- delete child records first
		dbcc checkident('sf.DataSourceApplicationPage', reseed, 1000000) with no_infomsgs;
		delete from sf.DataSource where DataSourceSID is not null;	-- then data sources
		dbcc checkident('sf.DataSource', reseed, 1000000) with no_infomsgs;

		-- update the label to avoid duplicates where the
		-- same view name appears in 2 schemas

		update
			w
		set
			w.DataSourceLabel = rtrim(left(w.DataSourceLabel, 29)) + ' (' + left(w.DBObjectName,3) + ')'
		from
			@work w
		join
		(
			select
				w.DataSourceLabel
			 ,count(1)	TotalSources
			 ,max(w.ID) MaxID
			from
				@work w
			group by
				w.DataSourceLabel
		)				z on w.DataSourceLabel = z.DataSourceLabel
		where
			z.TotalSources = 2 and w.ID = z.MaxID;

		-- finally write the new data sources and preserved configuration
		-- into the empty table

		insert
			sf.DataSource
		(
			DataSourceLabel
		 ,DBObjectName
		 ,ToolTip
		 ,FileFormatSID
		 ,ExportDefaults
		 ,LastExecuteTime
		 ,LastExecuteUser
		 ,ExecuteCount
		)
		select
			w.DataSourceLabel
		 ,w.DBObjectName
		 ,w.ToolTip
		 ,w.FileFormatSID
		 ,w.ExportDefaults
		 ,w.LastExecuteTime
		 ,w.LastExecuteUser
		 ,w.ExecuteCount
		from
			@work w;

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and (@xState = -1 or @xState = 1)
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if (@xState = -1 or @xState = 1) -- full rollback since no previous trx was pending
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error

	end catch;

	return (@errorNo);

end;
GO
