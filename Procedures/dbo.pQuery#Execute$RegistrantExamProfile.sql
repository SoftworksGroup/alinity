SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$RegistrantExamProfile
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Execute - Registrant Exam Profile
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Registrant Exam Profile records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2019		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Registrant
Exam Profile management. In order for query execution to synchronize with queries displayed on the user interface, the content of 
this procedure and the query records created through sf.pSetup$SF#Query$RegistrantExamProfile must be the same.

The @QueryCode value corresponds to the sf.Query.QueryCode column and is used for branching to the query to execute.  Any 
parameters entered in the user interface for the query are stored as records in the @Parameters table and must be retrieved into 
local variables prior to execution.  Unless enforced as mandatory in the parameter definition, the parameter values can be null.
Zero-length strings detected in parameter values are converted to NULL's.  See also parent procedure.

Limitations
-----------
Although @MaxRows is passed as a parameter, a returned record limit is only enforced where "select top(@MaxRows)..." syntax is
implemented in the query.  If the enforcement of record limits has been turned off in the UI, the @MaxRows value has been set 
by the caller to a high value to avoid limiting the data set returned.

Note that while a basic procedure test is included below, general query testing should be performed by the parent search
procedure: stg.pRegistrantExamProfile#SearchCT

Example 
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Executes the system default query">
    <SQLScript>
      <![CDATA[
declare
	@queryCode	varchar(30)
 ,@parameters dbo.Parameter;

select
	@queryCode = q.QueryCode
from
	sf.Query					 q
join
	sf.ApplicationPage ap on q.ApplicationPageSID = ap.ApplicationPageSID
where
	ap.ApplicationPageURI = 'RegistrantExamProfileList';

if not exists (select 1 from stg .RegistrantExamProfile)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine

	exec dbo.pQuery#Execute$RegistrantExamProfile
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999;

	select * from #selected

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pQuery#Execute$RegistrantExamProfile'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo						 int							= 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)																						-- message text (for business rule errors)   
	 ,@OFF								 bit							= cast(0 as bit)												-- constant for bit comparison = 0
	 ,@recentDateTime			 datetimeoffset		= sf.fRecentAccessCutOff()							-- oldest point considered within the recent access hours
	 ,@userName						 nvarchar(75)			= sf.fApplicationUserSession#UserName() -- sf.ApplicationUser UserName for the current user
	 ,@startDate					 date																											-- query parameter values retrieved for use in SELECTs:
	 ,@endDate						 date
	 ,@importFileSID			 int
	 ,@isUnprocessedOnly	 bit
	 ,@processingStatusSID int
	 ,@startDateTime			 datetime
	 ,@endDateTime				 datetime
	 ,@startDateDTO				 datetimeoffset(7)
	 ,@endDateDTO					 datetimeoffset(7)
	 ,@examIdentifier			 nvarchar(50)
	 ,@orgLabel						 nvarchar(35)
	 ,@isUpdatedByMeOnly	 bit;

	begin try
		if object_id('tempdb..#selected') is null -- create temporary table where it does not exist (testing scenarios only!)
		begin
			create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine
		end;

		-- retrieve parameter values
		-- SQL Prompt formatting off
		select @recentDateTime				= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @startDate							= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @importFileSID					= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'ImportFileSID';
		select @isUnprocessedOnly			= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUnProcessedOnly';
		select @processingStatusSID		= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'ProcessingStatusSID';
		select @examIdentifier				= cast(p.ParameterValue as nvarchar(50))						from	@Parameters p	where	p.ParameterID = 'StagingIdentifier';
		select @orgLabel							= cast(p.ParameterValue as nvarchar(35))						from	@Parameters p	where	p.ParameterID = 'StagingLabel';
		select @isUpdatedByMeOnly			= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUpdatedByMeOnly';
		-- SQL Prompt formatting on

		-- store start/end dates entered on the UI as DTO's to 
		-- enable comparison with server times
		if @recentDateTime is not null
		begin
			set @recentDateTime = cast(convert(varchar(8), @recentDateTime, 112) + ' 23:59:59.99' as datetime);
		end;

		if @startDate is not null
		begin
			set @startDateTime = @startDate;
			set @startDateDTO = sf.fClientDateTimeToDTOffset(@startDateTime); -- convert to server time for comparison
		end;

		if @endDate is not null
		begin
			set @endDateTime = cast(convert(varchar(8), @endDate, 112) + ' 23:59:59.99' as datetime);
			set @endDateDTO = sf.fClientDateTimeToDTOffset(@endDateTime); -- set to end of day
		end;

		-- exam ID and organization label require wildcards on 
		-- both sides for "like" searches 
		if @examIdentifier is not null
		begin
			if left(@examIdentifier, 1) <> '%'
			begin
				set @examIdentifier = N'%' + @examIdentifier;
			end;

			if right(@examIdentifier, 1) <> '%'
			begin
				set @examIdentifier += N'%';
			end;
		end;

		if @orgLabel is not null
		begin
			if left(@orgLabel, 1) <> '%'
			begin
				set @orgLabel = N'%' + @orgLabel;
			end;

			if right(@orgLabel, 1) <> '%'
			begin
				set @orgLabel += N'%';
			end;
		end;

		-- validate for conflicting parameters
		if @startDate > @endDate
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'DateRangeReversed'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" must be before the "%2".'
			 ,@Arg1 = 'Start Date'
			 ,@Arg2 = 'End Date';

			raiserror(@errorText, 16, 1);
		end;

		-- execute the query 
		if @QueryCode = 'S!REGXP.ALL'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			join
				sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID
			where
				(@startDateDTO is null or rxp.CreateTime				 >= @startDateDTO)
				and (@endDateDTO is null or rxp.CreateTime			 <= @endDateDTO)
				and (@importFileSID is null or rxp.ImportFileSID = @importFileSID)
				and (@examIdentifier is null or rxp.ExamIdentifier like @examIdentifier)
				and (@orgLabel is null or rxp.OrgLabel like @orgLabel)
				and (@isUnprocessedOnly													 = @OFF or ps.IsClosedStatus = @OFF)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.LAST.IMPORT'
		begin
			select
				@importFileSID = max(rxp.ImportFileSID)
			from
				stg.RegistrantExamProfile rxp;

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			where
				rxp.ImportFileSID = @importFileSID
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.UNPROCESSED'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			join
				sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.IsClosedStatus = @OFF
			where
				(@importFileSID is null or rxp.ImportFileSID = @importFileSID)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.BY.STATUS'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			where
				rxp.ProcessingStatusSID = @processingStatusSID and (@importFileSID is null or rxp.ImportFileSID = @importFileSID)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.BY.FILE'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			join
				sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID
			where
				rxp.ImportFileSID = @importFileSID and (@isUnprocessedOnly = @OFF or ps.IsClosedStatus = @OFF)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.CANCELLED'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			join
				sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.ProcessingStatusSCD = 'CANCELLED'
			where
				(@startDateDTO is null or rxp.CreateTime >= @startDateDTO) and (@endDateDTO is null or rxp.CreateTime <= @endDateDTO)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.EXAMIDENTIFIER'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			join
				sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID
			where
				rxp.ExamIdentifier like @examIdentifier and (@isUnprocessedOnly = @OFF or ps.IsClosedStatus = @OFF)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.ORGLABEL'
		begin
			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			join
				sf.ProcessingStatus				ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID
			where
				rxp.OrgLabel like @orgLabel and (@isUnprocessedOnly = @OFF or ps.IsClosedStatus = @OFF)
			order by
				rxp.RegistrantExamProfileSID;
		end;
		else if @QueryCode = 'S!REGXP.RECENTLY.UPDATED'
		begin
			insert
				#selected (EntitySID)
			select
				rxp.RegistrantExamProfileSID
			from
				stg.RegistrantExamProfile rxp
			where
				rxp.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or rxp.UpdateUser = @userName);
		end;
		else
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Query'
			 ,@Arg2 = @QueryCode;

			raiserror(@errorText, 18, 1);
		end;
	end try
	begin catch
		set noexec off;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;

GO
