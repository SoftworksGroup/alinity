SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$SF#Query$Task
	@SetupUser nvarchar(75) -- user assigned to audit columns
as
/*********************************************************************************************************************************
Sproc    : Setup Query for Task management
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Synchronizes the sf.Query table for product queries used in management of Tasks
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments  
--------
This procedure sets up product queries used to manage Tasks.  The data is setup in the sf.Query table. Product queries
related to the entity which are no longer supported/required are removed from the table and any new queries are added.  Parameter 
details for existing queries are updated to ensure they match the current query syntax defined in the execution procedure:
dbo.pQuery#Execute#Task.

The procedure also calls a framework utility to verify that a one-to-one match exists for the query codes defined for setup and 
for which query syntax is defined in the query#execute subroutine. If any discrepancies are found an error is raised and no changes
to the sf.Query table are saved.  Details of the 2 code lists are returned as a data set.

Known Limitations
-----------------
For most locations in the system "label" column values can be customized by the end-user directly through the user interface.  For 
the Query table, however, any customized labels are overwritten as pSetup is executed and calls to this procedure take place. This 
ensures queries are named consistently so that they are recognizable for (video) training.  If unique labels are required for a 
client, implement them in the client's post deployment script using the Query Code to locate records for update.

Example:
--------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

exec dbo.pSetup$SF#Query$Task
	@SetupUser = N'system@softworksgroup.com'

if @@error = 0
begin

	select
		q.*
	from
		sf.Query						 q
	join
		sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
	join
		sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
	where
		ae.ApplicationEntitySCD = 'sf.Task'
	order by
		q.QueryLabel;

end;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:15" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Query$Task'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)												-- message text (for business rule errors)
	 ,@ON									bit						= cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@OFF								bit						= cast(0 as bit)				-- constant for bit comparisons = 0
	 ,@tranCount					int						= @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName						nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@xState							int																		-- error state detected in catch block
	 ,@defaultCategorySID int																		-- categories to put queries in:
	 ,@formsCategorySID		int
	 ,@applicationPageSID int																		-- key of the application page to associate queries with
	 ,@parametersDoc			xml;																	-- buffer to hold parameter definitions for query

	declare @setup table -- interim storage for query setup data
	(
		ID											 int					 identity(1, 1)
	 ,QueryCategorySID				 int					 not null
	 ,QueryCode								 varchar(30)	 not null
	 ,QueryLabel							 nvarchar(35)	 not null
	 ,IsApplicationPageDefault bit					 not null default cast(0 as bit)
	 ,ToolTip									 nvarchar(250) not null
	 ,QueryParameters					 xml					 null
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

		select
			@defaultCategorySID = (case when qc.QueryCategoryCode = 'S!DEFAULT' then qc.QueryCategorySID else @defaultCategorySID end)
		 ,@formsCategorySID		= (case when qc.QueryCategoryCode = 'S!FORMS' then qc.QueryCategorySID else @formsCategorySID end)
		from
			sf.QueryCategory qc;

		select
			@applicationPageSID = ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'TaskList';

		if @defaultCategorySID is null or @applicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = '"Query Category or Application Page"';

			raiserror(@errorText, 17, 1);

		end;

		-- insert each query with parameter definitions
		-- into the setup table

		----- All (for period) ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Label = 'Task created'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'To'
		 ,@DefaultValue = '[@@Date]'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskQueueSID'
		 ,@Label = 'Queue'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskContextSID'
		 ,@Label = 'Context'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.ALL', @parametersDoc, 'All', @OFF, N'Returns all tasks created in the selected date range'
		);

		----- All (latest week) ----- 

		set @parametersDoc = null;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.ALL.LATEST.WK', @parametersDoc, 'Latest week', @ON, N'Returns all tasks created in the latest week of task activity'
		);

		----- My tasks  ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Include unassigned'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.MINE', @parametersDoc, 'My tasks', @OFF, N'Returns all open tasks assigned to you (optionally include un-assigned)'
		);

		----- Due/OverDue ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'FollowUpDate'
		 ,@Label = 'Follow-up due'
		 ,@ParametersDoc = @parametersDoc output

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskQueueSID'
		 ,@Label = 'Task queue'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskContextSID'
		 ,@Label = 'Context'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.DUE', @parametersDoc, 'Due/Overdue', @OFF, N'Returns tasks where due date or next follow-up date is on or before selected date'
		);

		----- By Queue ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskQueueSID'
		 ,@Label = 'Task queue'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.QUEUE', @parametersDoc, 'By queue', @OFF, N'Returns tasks on a selected task queue'
		);

		----- Assigned to ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.ASSIGNED', @parametersDoc, 'Assigned to', @OFF, N'Returns tasks assigned to a selected administrator'
		);

		----- Unassigned ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskQueueSID'
		 ,@Label = 'Task queue'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.UNASSIGNED', @parametersDoc, 'Unassigned', @OFF, N'Returns tasks which have no administrator assigned'
		);

		----- Cancelled ----------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Label = 'Task cancelled'
		 ,@DefaultValue = '[@@Date]-60'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'To'
		 ,@DefaultValue = '[@@Date]'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.CANCELLED', @parametersDoc, 'Cancelled', @OFF, N'Returns tasks with a status of cancelled'
		);

		----- Context  ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'TaskContextSID'
		 ,@Label = 'Context'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.CONTEXT', @parametersDoc, 'Context', @OFF, N'Returns tasks associated with a particular form type or record type'
		);

		----- Renewal ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.RENEWAL', @parametersDoc, 'Renewal tasks', @OFF, N'Returns tasks associated with renewal forms'
		);

		----- Application ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.APPLICATION', @parametersDoc, 'Application tasks', @OFF, N'Returns tasks associated with application forms'
		);

		----- Reinstatement ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.REINSTATEMENT', @parametersDoc, 'Reinstatement tasks', @OFF, N'Returns tasks associated with reinstatement forms'
		);

		----- Registration Change ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.REG.CHANGE', @parametersDoc, 'Registration change tasks', @OFF, N'Returns tasks associated with registration changes'
		);

		----- Profile Update ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.PROFILE.UPDATE', @parametersDoc, 'Profile update tasks', @OFF, N'Returns tasks associated with profile update forms'
		);

		----- CE Plan/Report ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.LEARNING.PLAN', @parametersDoc, 'CE Plan/Report tasks', @OFF
		 ,N'Returns tasks associated with continuing education plans and reports'
		);

		----- Audit ----- 

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'AdminApplicationUserSID'
		 ,@Label = 'Assigned to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUnassigned'
		 ,@Label = 'Unassigned only'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsOverDue'
		 ,@Label = 'Overdue only'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Include closed after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@formsCategorySID, 'S!TASK.AUDIT', @parametersDoc, 'Audit tasks', @OFF, N'Returns tasks associated with audit forms'
		);

		----- Find By Phone -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PhoneNumber'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.FIND.BY.PHONE', @parametersDoc, 'Find by phone', @OFF
		 ,N'Returns records where the person''s home or mobile phone matches any portion of a number provided'
		);

		----- Find By Address -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StreetAddress'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CitySID'
		 ,@IsMandatory = @OFF
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.FIND.BY.ADDRESS', @parametersDoc, 'Find by address', @OFF
		 ,N'Returns records where the person''s address matches any portion of a street address provided'
		);

		----- Recently Updated -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RecentDateTime'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUpdatedByMeOnly'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!TASK.RECENTLY.UPDATED', @parametersDoc, 'Recently updated', @OFF
		 ,N'Returns records that were recently updated (and optionally restricted to updates made by the logged in user)'
		);

		-- delete any remaining product queries related to the entity 
		-- which are not in the current setup or are using the older
		-- style dynamic syntax stored directly in the table

		delete
		q
		from
			sf.Query						 q
		join
			sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
		join
			sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
		left outer join
			@setup							 s on q.QueryCode							 = s.QueryCode
		where
			ae.ApplicationEntitySCD = 'sf.Task'
			and
			((left(q.QueryCode, 2) = 'S!'	 and s.QueryCode is null) or left(q.QueryCode, 6) = '[None]' or left(q.QueryCode, 4) = 'None' or q.QuerySQL is not null);

		-- insert/update the query definitions to the latest version

		merge sf.Query target
		using
		(
			select
				x.QueryCategorySID
			 ,x.QueryCode
			 ,x.QueryLabel
			 ,x.IsApplicationPageDefault
			 ,x.ToolTip
			 ,x.QueryParameters
			 ,@applicationPageSID ApplicationPageSID
			 ,@SetupUser					CreateUser
			 ,@SetupUser					UpdateUser
			from
				@setup x
		) source
		on target.QueryCode = source.QueryCode
		when not matched by target then
			insert
			(
				QueryCategorySID
			 ,QueryCode
			 ,QueryLabel
			 ,IsApplicationPageDefault
			 ,ToolTip
			 ,QueryParameters
			 ,ApplicationPageSID
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.QueryCategorySID, source.QueryCode, source.QueryLabel, source.IsApplicationPageDefault, source.ToolTip, source.QueryParameters
			 ,source.ApplicationPageSID, source.CreateUser, source.UpdateUser
			)
		when matched then update set
												target.QueryLabel = source.QueryLabel
											 ,target.IsApplicationPageDefault = source.IsApplicationPageDefault
											 ,target.QueryCategorySID = source.QueryCategorySID
											 ,target.ToolTip = source.ToolTip
											 ,target.QueryParameters = source.QueryParameters
											 ,target.ApplicationPageSID = source.ApplicationPageSID
											 ,target.UpdateUser = source.UpdateUser;

		-- validate that the list of product query codes just setup
		-- matches the query codes for which syntax is defined in the
		-- Query Search subroutine

		exec sf.pQuery#CheckCodes
			@ApplicationEntitySCD = 'sf.Task'
		 ,@SchemaAndRoutineName = 'dbo.pQuery#Execute$Task'
		 ,@SetupSprocName = @procName;

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
