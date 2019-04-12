SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#QueryCategory]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.QueryCategory data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Updates the (sf) QueryCategory table with records required by application 
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Sep 2018		|	Initial version
					
Comments  
--------
This procedure populates the sf.QueryCategory table with values expected by the application.  This table can be updated by
end users or the help desk through the UI to create records required in the configuration.  The table must, however, maintain
a set of records expected by the application. These records are identified by the "code" column values which start with "S!".

This procedure ensures all expected system codes are in place in the table with the expected labels and other attributes.
Any missing records are added and existing records updated.

The procedure also checks for older system records - identified by the S! prefix - that are no longer part of the setup
and attempts to delete those.  Note that when old system code values are being removed or changed, a migration script
is required to move any records dependent on the old values (or to rename the code column value).

Known Limitations
-----------------
For most locations in the system "label" column values can be customized by the end-user directly through the user interface.  
For the Query Category table, however, any customized entries are overwritten on system categories as pSetup is executed and 
calls to this procedure take place. This ensures query categories are named consistently so that they are recognizable for 
(video) training.  If unique labels are required for a client, implement them in the client's post deployment script using the 
Query Category Code to locate records for update.

Example
-------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$SF#QueryCategory 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from sf.QueryCategory

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#QueryCategory'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON				 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

	declare @setup table
	(
		ID								 int					 identity(1, 1)
	 ,QueryCategoryCode	 varchar(30)	 not null
	 ,QueryCategoryLabel nvarchar(35)	 not null
	 ,IsDefault					 bit					 not null
	 ,DisplayOrder			 int					 not null
	 ,UsageNotes				 nvarchar(max) not null
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

		-- load setup table with categories required 
		-- by the application

		-- SQL Prompt formatting off
		insert @setup (QueryCategoryCode, QueryCategoryLabel, IsDefault, DisplayOrder, UsageNotes) -- space inserted in front of "General" to get it to sort into first position on UI
		values
			 ('S!DEFAULT'							,' General'												,@ON	, 100,'Default category for queries. This is the only category used unless the page provides so many queries that a break-down into multiple categories makes finding queries easier.')
			,('S!REGISTRATION'				,'Registration Management'				,@OFF , 115,'A collection of queries to support Registration management.')
			,('S!RENEWAL'							,'Renewal Management'							,@OFF , 120,'A collection of queries to support Renewal form management.')
			,('S!APPLICATION'					,'Application Management'					,@OFF , 125,'A collection of queries to support Application form management.')
			,('S!REGISTRATION.CHANGE'	,'Registration Change Management'	,@OFF , 130,'A collection of queries to support Registration Change form management.')
			,('S!REINSTATEMENT'				,'Reinstatement Management'				,@OFF , 135,'A collection of queries to support Reinstatement form management.')
			,('S!AUDIT'								,'Audit Management'								,@OFF , 140,'A collection of queries to support Audit form management.')
			,('S!PROFILE.UPDATE'			,'Profile Update Status'					,@OFF , 150,'A collection of queries to find profile updates based on status.')
			,('S!FORMS'						    ,'Member Forms'										,@OFF , 190,'A collection of queries to find records based on details stored in member form types.')
			,('S!LEARNING.PLAN'				,'CE Form Status'									,@OFF , 200,'A collection of queries to find profile updates based on status.')
			,('S!WORKFLOW'						,'Work-flow'											,@OFF , 205,'A collection of queries to support automating work-flow and task creation (e.g. email triggers).')
			,('S!PROFILE'						  ,'Profile'												,@OFF , 210,'A collection of queries to find records based on details stored on their profile.')
			,('S!FOLLOW.UP'						,'Follow-Up'											,@OFF , 215,'A collection of queries to find records requiring follow-up from administrators.')
			,('S!DATA.QUALITY'				,'Data Quality'										,@OFF , 220,'A collection of queries to find records requiring update to improve data quality.')
		-- SQL Prompt formatting on

		merge sf.QueryCategory target -- update the database for any new or changed system categories
		using
		(
			select
				x.QueryCategoryCode
			 ,x.QueryCategoryLabel
			 ,x.IsDefault
			 ,x.DisplayOrder
			 ,x.UsageNotes
			from
				@setup x
		) source
		on target.QueryCategoryCode = source.QueryCategoryCode
		when not matched by target then
			insert
			(
				QueryCategoryCode
			 ,QueryCategoryLabel
			 ,UsageNotes
			 ,IsDefault
			 ,DisplayOrder
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.QueryCategoryCode, source.QueryCategoryLabel, source.UsageNotes, source.IsDefault, source.DisplayOrder, @SetupUser, @SetupUser
			)
		when matched then update set
												target.QueryCategoryLabel = source.QueryCategoryLabel
											 ,target.IsDefault = source.IsDefault
											 ,target.DisplayOrder = source.DisplayOrder
											 ,target.UsageNotes = source.UsageNotes
											 ,target.UpdateUser = @SetupUser;

		-- remove records with previous system codes
		-- that are no longer in use 

		delete
		qc
		from
			sf.QueryCategory qc
		left outer join
			@setup					 s on qc.QueryCategoryCode = s.QueryCategoryCode
		where
			left(qc.QueryCategoryCode, 2) = 'S!' and s.QueryCategoryCode is null;

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
