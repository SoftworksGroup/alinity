SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#DataSourceApplicationPage]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Procedure	: Set up data source application pages
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Ensures the sf.DataSourceApplicationPage table is updated with all accessible data sources
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version (revised approach from original version developed by Kris Dawson)
				: Tim Edlund					| Oct 2018		| Revised logic to add non-entity data sources to Table Management page

Comments	
--------
This procedure loads the sf.DataSourceApplicationPage table based on the sf.DataSource table and sf.ApplicationPage tables.
Both of these tables must have been loaded previously by pSetup.

In order for a data source to appear on an application page for export, a record is required providing the key of the 
data source and the application page it appears on.  There are 3 scenarios that create records for these pairings and
a separate INSERT occurs for each:

1) Base Entity Views - the procedure finds all page URI's ending in "List" and "Details" where a matching base entity
view exists for the part of the URI before List/Detail.  For example the page URI "PersonList" results in a check for a 
data source called "vPerson" and where that exists (and is a base entity view), the record is inserted for it. This
algorithm ensures all search (List) pages in the application have at least one export available.  The method also ensures
the references automatically update as page and entities are added and updated through development.

2) Base Entity Views on non-entity named URI's.  If a base entity view needs to appear on a page where the URI doesn't
match the data source name, they must be hard-coded.  The @work table is used to load these references. An example is
included the base entity dbo.vRegistrant on the "PersonList" page.  The entity can be selected by "PersonSID" so is 
valid for export on that page but the algorithm described in #1 above, would not have included it.

3) Table Management page references.  Even where the client has not been licensed for the DB Management module, a
reference to that page for each data sources is always created.  This is done because DB Management options always
appear for Help Desk staff and are useful tools in debugging and handling one-off export requests.  

4) Export specific data sources.  The DataSource setup procedure loads non-base entities by searching for an "|Export"
tag in the MS_Description property for the view.  These are always loaded on the Table Management page but may
also appear on other pages based on page URI's also entered in the MS_Description (see pSetup$SF#DataSource). If the 
tag use is "|EXPORT+" it is considered an "advanced" data source and a page reference for is only included on pages
other than the Table Management if the configuration is licensed for the DB Management module.  

Limitations
-----------
Note that if URI entered into the MS_Description property of the view is not found in the sf.ApplicationPage - no error
results.  When adding new URI's for a data source to appear on for export, be sure to check the UI after updating the 
description and re-running this procedure.

This procedure is dependent on the table being empty when the process starts. Any previous contents of the table
are deleted dbo.pSetup$SF#DataSource. See that procedure for further details.

Example
-------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures setup executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#DataSourceApplicationPage
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select
			  x.ApplicationPageURI
			 ,x.DBObjectName
			 ,x.DataSourceLabel
			 ,x.ToolTip
			from
				sf.vDataSourceApplicationPage x
			order by
				 x.ApplicationPageURI
				,x.DBObjectName;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#DataSourceApplicationPage'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo									 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText								 nvarchar(4000)													-- message text (for business rule errors)
	 ,@tranCount								 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName									 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState										 int																		-- error state detected in catch block
	 ,@ON												 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF											 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@defaultApplicationPageSID int																		-- application page SID for the business rule page
	 ,@isDBManagementEnabled		 bit;																		-- tracks whether Database Management module is licensed (enabled advanced data sources)

	declare @work table -- stores list of URI and Object pairs to enable as exports on standard search pages
	(
		ID					 int					 not null identity(1, 1)
	 ,PageURI			 varchar(150)	 not null
	 ,DBObjectName nvarchar(257) not null
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

		-- read parameters from configuration to determine placement of exports in 
		-- Table Management option

		select
			@isDBManagementEnabled = cast(lm.TotalLicenses as bit)
		from
			sf.vLicense#Module lm
		where
			lm.ModuleSCD = 'DBMANAGEMENT';	-- determine if advanced data sources are enabled (requires DB Management module licenses)

		select
			@defaultApplicationPageSID = ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'BusinessRuleList' or ap.ApplicationPageLabel = 'Table management'; -- determine default page for exports

		if @defaultApplicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = '"Table Management Page (URI)"';

			raiserror(@errorText, 17, 1);
		end;

		-- add all data sources to the Table Management page to support
		-- general exporting

		insert
			sf.DataSourceApplicationPage (DataSourceSID, ApplicationPageSID)
		select distinct
			ds.DataSourceSID
		 ,@defaultApplicationPageSID
		from
			sf.DataSource								 ds
		left outer join
			sf.DataSourceApplicationPage dsap on dsap.ApplicationPageSID = @defaultApplicationPageSID and ds.DataSourceSID = dsap.DataSourceSID
		where
			dsap.DataSourceApplicationPageSID is null;	-- avoid duplication

		-- insert references for "List" and "Details" pages
		-- that have a corresponding base entity view

		insert
			sf.DataSourceApplicationPage (DataSourceSID, ApplicationPageSID)
		select distinct
			z.DataSourceSID
		 ,z.ApplicationPageSID
		from
		(
			select
				ds.DataSourceSID
			 ,uri.ApplicationPageSID
			from
			(
				select
					ap.ApplicationPageURI
				 ,'v' + replace(replace(ap.ApplicationPageURI, 'List', ''), 'Details', '') ViewName
				 ,ap.ApplicationPageSID
				from
					sf.ApplicationPage ap
				where
					ap.ApplicationPageURI like '%List' or ap.ApplicationPageURI like '%Details'
			)								uri
			join
				sf.vView			v on uri.ViewName			= v.ViewName and (v.SchemaName = 'dbo' or v.SchemaName = 'sf' or v.SchemaName = 'stg') -- restrict to entity views only by finding associated table
			join
				sf.DataSource ds on ds.DBObjectName = v.SchemaAndViewName -- ensure view exists as a data source
		)															 z
		left outer join
			sf.DataSourceApplicationPage dsap on z.ApplicationPageSID = dsap.ApplicationPageSID and z.DataSourceSID = dsap.DataSourceSID
		where
			dsap.DataSourceApplicationPageSID is null;	-- coded defensively in case table not empty

		-- next load a table of references for base entity views
		-- that must be included on LIST pages that have a 
		-- different base name 

-- SQL Prompt formatting off
		insert @work (PageURI, DBObjectName)
		values
			('PersonList'				, N'dbo.vRegistrant')
		 ,('RegistrationList'	, N'dbo.vRegistrantApp')
		 ,('RegistrationList'	, N'dbo.vRegistrantRenewal')
		 ,('RegistrationList'	, N'dbo.vRegistrationChange')
-- SQL Prompt formatting on

		insert
			sf.DataSourceApplicationPage (ApplicationPageSID, DataSourceSID)
		select
			ap.ApplicationPageSID
		 ,ds.DataSourceSID
		from
			@work												 w
		join
			sf.DataSource								 ds on w.DBObjectName					 = ds.DBObjectName
		join
			sf.ApplicationPage					 ap on w.PageURI							 = ap.ApplicationPageURI
		left outer join
			sf.DataSourceApplicationPage dsap on ap.ApplicationPageSID = dsap.ApplicationPageSID and ds.DataSourceSID = dsap.DataSourceSID
		where
			dsap.DataSourceApplicationPageSID is null;	-- avoid duplication

		-- finally insert references for non-base entity views specifically created for
		-- Export and which are identified to appear on list/detail pages

		insert
			sf.DataSourceApplicationPage (DataSourceSID, ApplicationPageSID)
		select distinct
			z.DataSourceSID
		 ,z.ApplicationPageSID
		from
		(
			select
				ds.DataSourceSID
			 ,isnull(ap.ApplicationPageSID, @defaultApplicationPageSID) ApplicationPageSID
			 ,ds.DBObjectName
			 ,isnull(x.IsAdvancedDataSource, @OFF)											IsAdvancedDataSource
			 ,x.PageURIs
			 ,z.Item																										PageURI
			from
				sf.DataSource															 ds
			left outer join
			(
				select
					v.SchemaAndViewName
				 ,cast(charindex('|Export+', v.Description) as bit)																																										 IsAdvancedDataSource
				 ,replace(substring(ltrim(replace(substring(v.Description, charindex('|Export', v.Description) + 8, 250), '+', '')), 2, 250), ' ', '') PageURIs
				from
					sf.vView v
				where
					v.Description like '%|Export%'
			)																						 x on ds.DBObjectName = x.SchemaAndViewName
			outer apply sf.fSplitString(x.PageURIs, '^') z
			left outer join
				sf.ApplicationPage ap on z.Item = ap.ApplicationPageURI
		)															 z
		left outer join
			sf.DataSourceApplicationPage dsap on z.ApplicationPageSID = dsap.ApplicationPageSID and z.DataSourceSID = dsap.DataSourceSID
		where
			(z.IsAdvancedDataSource = @OFF or @isDBManagementEnabled = @ON) -- advanced views are not included unless DB Management is licensed
			and dsap.DataSourceApplicationPageSID is null;	-- avoid duplication

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
