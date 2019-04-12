SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute
	@QuerySID						int															-- key of the sf.Query record to execute query for 
 ,@ApplicationPageURI varchar(150)										-- identifies subroutine to execute query searches through
 ,@QueryParameters		xml = null											-- query parameter values assigned to variables in query syntax
 ,@IsRowLimitEnforced bit = 1													-- when 0, the limit of maximum rows to return is not enforced (see below)
 ,@RegistrationYear		smallint = null									-- registration year selected in the UI (where used on management screens)
 ,@LatestRegistration dbo.LatestRegistration readonly -- table storing keys of registration record for selected year (is NULLable)
as
/*********************************************************************************************************************************
Sproc    : Query Execute (main)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure validates references to sf.Query and calls subroutines to execute the query
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Jan 2019		| Added optional @LatestRegistration table parameter for pass-through to #execute
				: Tim Edlund					| Feb 2019		| Updated message when no default search is specified and added PersonList support

Comments	
--------
This procedure is called from search pages in the application to execute query searches.  The query syntax is stored in 
subroutines which this procedure calls.  The label, code and parameter definitions for the query are stored in the sf.Query table.  
This procedure validates the reference to the sf.Query record and extracts values from the XML @QueryParameters into a table for 
processing by the subroutine.  A separate subroutine is created for each entity which roughly corresponds to each application 
search page.  Where custom queries are defined in the client configuration, a version of each subroutine must also be created in 
the "ext" (extension point) schema of the client database.  After the query is executed this procedure is also responsible for 
updating the execution count and smart group query totals.

Note that the @LatestRegistration parameter is a table value.  While "= null" is not valid syntax, the parameter does not
have to be passed.  As of this writing, the parameter is only passed from search procedures using registration record data.

Legacy QuerySQL Syntax
----------------------
Prior to the Autumn of 2018 query syntax was stored in the QuerySQL column of sf.Query and executed dynamically. The procedure 
supports legacy queries by checking for a QueryCode value of "NONE" - in which case the legacy (sf) pQuery#Execute procedure is 
called. Support for legacy queries will eventually be removed.

Known Limitations
-----------------
This procedure must be updated to call a new subroutine as new application entities are added. Dynamic SQL is specifically 
avoided in calls to the subroutine to improve performance and simplify debugging.

The query sub-system supports use of SELECT statements to populate drop-down controls in query parameter screens however the
current version only supports numeric values in the Value/Label pair structure required.  If you have non-numeric Value
column required in the execution of the query, calculate a row_number() column in the syntax of the parameter's select statement,
the value of which can used when executing the query to retrieve the required character value (which can be placed in a 3rd
column).

Example
-------
<TestHarness>
  <Test Name = "ProfileUpdate" IsDefault ="true" Description="Executes the default search for Profile Update for the current year">
    <SQLScript>
      <![CDATA[
if not exists
(
	select
		1
	from
		sf.Query						 q
	join
		sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
	join
		sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
	where
		ae.ApplicationEntitySCD = 'ProfileUpdateList' and right(q.QueryCode, 1) = '*'
)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute
		@QuerySID = -1
	 ,@ApplicationPageURI = 'ProfileUpdateList'
	 ,@IsRowLimitEnforced = 0;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pQuery#Execute'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo			int						 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)																					-- message text for business rule errors
	 ,@extSprocName nvarchar(257)																						-- name of EXT version of procedure (if any)
	 ,@ON						bit						 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF					bit						 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@queryCode		varchar(30)																							-- the coded identifier of the query to pass to the subroutine
	 ,@maxRows			int																											-- maximum rows allowed on search
	 ,@parameters		dbo.Parameter																						-- table to store parameters values entered in UI
	 ,@userName			nvarchar(75)	 = sf.fApplicationUserSession#UserName()	-- name of user executing the query
	 ,@executeCount int																											-- count of times query was previously executed
	 ,@rowCount			int																											-- count of records returned by the query
	 ,@now					datetimeoffset = sysdatetimeoffset();										-- current time

	begin try

		-- validate the query SID or Code passed
		if @QuerySID is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@QuerySID';

			raiserror(@errorText, 18, 1);
		end;

		if @QuerySID = -1 -- indicates the default query should be called
		begin
			select
				@QuerySID = q.QuerySID
			from
				sf.ApplicationPage ap
			join
				sf.Query					 q on ap.ApplicationPageSID = q.ApplicationPageSID
			where
				ap.ApplicationPageURI = @ApplicationPageURI and q.IsApplicationPageDefault = @ON;

			if isnull(@QuerySID, -1) = -1
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'NoDefaultSearch'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A default search has not been configured. Select a query and mark it as your default by clicking the filter icon on the left-hand-side of the search results bar.';

				raiserror(@errorText, 16, 1);
			end;
		end;

		select
			@queryCode		= q.QueryCode
		 ,@executeCount = q.ExecuteCount
		from
			sf.Query q
		where
			q.QuerySID = @QuerySID;

		if @queryCode is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = '(sf) Query'
			 ,@Arg2 = @QuerySID;

			raiserror(@errorText, 18, 1);
		end;

		-- retrieve maximum row limit (must be applied within the 
		-- query syntax in subroutine to be enforced
		set @maxRows = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '200') as int);

		if @maxRows = 0 set @maxRows = 999999999;

		if @IsRowLimitEnforced = @OFF
		begin
			set @maxRows = 999999999;
		end;

		if left(@queryCode, 6) = '[None]' or left(@queryCode, 4) = 'NONE' -- old style query not converted - run legacy procedure
		begin
			exec sf.pQuery#Execute
				@QuerySID = @QuerySID
			 ,@QueryParameters = @QueryParameters
			 ,@MaxRows = @maxRows;
		end;
		else
		begin

			-- load memory table with parameter attributes parsed
			-- into rows and columns of memory table
			insert
				@parameters (ParameterID, Label, ParameterValue)
			select
				p.ID
			 ,p.Label
			 ,p.Value
			from
			(
				select
					parameter.node.value('@ID', 'nvarchar(128)')		ID
				 ,parameter.node.value('@Label', 'nvarchar(35)')	Label
				 ,parameter.node.value('@Value', 'nvarchar(max)') Value
				from
					@QueryParameters.nodes('Parameters/Parameter') as parameter(node)
			) p;

			-- replace literal references to NULL and format display
			-- values for each parameter except for SELECT types
			update
				@parameters
			set
				ParameterValue = null
			where
				(
					len(ltrim(rtrim(ParameterValue))) = 0 or ParameterValue = '*null*' or ParameterValue = 'null'
				) and ParameterValue is not null;

			-- branch to a call on the page specific query procedure based
			-- on the URI - if not a system code prefix call extension point
			if @ApplicationPageURI = 'PersonList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$Person';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$Person
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$Person
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'ProfileUpdateList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$ProfileUpdate';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$ProfileUpdate
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows
					 ,@RegistrationYear = @RegistrationYear;
				end;
				else
				begin
					exec dbo.pQuery#Execute$ProfileUpdate
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows
					 ,@RegistrationYear = @RegistrationYear;
				end;
			end;
			else if @ApplicationPageURI = 'RegistrationList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$Registration';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$Registration
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows
					 ,@RegistrationYear = @RegistrationYear
					 ,@LatestRegistration = @LatestRegistration;
				end;
				else
				begin
					exec dbo.pQuery#Execute$Registration
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows
					 ,@RegistrationYear = @RegistrationYear
					 ,@LatestRegistration = @LatestRegistration;
				end;
			end;
			else if @ApplicationPageURI = 'PaymentList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$Payment';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$Payment
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$Payment
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'InvoiceList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$Invoice';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$Invoice
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$Invoice
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'EmailMessageList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$EmailMessage';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$EmailMessage
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$EmailMessage
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'TaskList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$Task';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$Task
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$Task
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'ComplaintList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$Complaint';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$Complaint
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$Complaint
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'RegistrantProfileList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$RegistrantProfile';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$RegistrantProfile
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$RegistrantProfile
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else if @ApplicationPageURI = 'RegistrantExamProfileList'
			begin
				if left(@queryCode, 2) <> 'S!' -- not a system query - run extended procedure
				begin
					set @extSprocName = N'ext.pQuery#Execute$RegistrantExamProfile';

					if not exists (select 1 from sf .vRoutine r where r.SchemaAndRoutineName = @extSprocName)
					begin
						exec sf.pMessage#Get
							@MessageSCD = 'CustomProcedureMissing'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A request to process a custom %1 was made but no supporting procedure was found. Reference code is "%2" and expected procedure "%3"'
						 ,@Arg1 = 'query'
						 ,@Arg2 = @queryCode
						 ,@Arg3 = @extSprocName;
					end;

					exec ext.pQuery#Execute$RegistrantExamProfile
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
				else
				begin
					exec dbo.pQuery#Execute$RegistrantExamProfile
						@QueryCode = @queryCode
					 ,@Parameters = @parameters
					 ,@MaxRows = @maxRows;
				end;
			end;
			else
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'NotInList'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
				 ,@Arg1 = 'search page'
				 ,@Arg2 = @ApplicationPageURI
				 ,@Arg3 = '"PersonList", "ProfileUpdateList", "RegistrationList", "PaymentList", "InvoiceList", "TaskList", "EmailMessageList", "ComplaintList", "RegistrantProfileList", "RegistrantExamProfileList"';

				raiserror(@errorText, 18, 1);
			end;
		end;

		set @rowCount = @@rowcount;

		-- DO NOT PLACE EXECUTABLE lines between this statement and the pQuery#Execute sproc!

		-- if the query is being executed and no commit is pending
		-- then update the execution count and audit
		if xact_state() = 0
		begin
			set @executeCount += 1;

			exec sf.pQuery#Update
				@QuerySID = @QuerySID
			 ,@LastExecuteTime = @now
			 ,@LastExecuteUser = @userName
			 ,@ExecuteCount = @executeCount;

			-- also update the count where this is a
			-- smart group query
			update
				sf.PersonGroup
			set
				SmartGroupCount = @rowCount
			 ,SmartGroupCountTime = sysdatetimeoffset()
			where
				QuerySID = @QuerySID;
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
