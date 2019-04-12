SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pQuery#Execute$RegistrantProfile]
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Execute - Registrant Profile
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Registrant Profile records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Registrant
Profile management. In order for query execution to synchronize with queries displayed on the user interface, the content of this
procedure and the query records created through sf.pSetup$SF#Query$RegistrantProfile must be the same.

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
procedure: stg.pRegistrantProfile#SearchCT

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
	ap.ApplicationPageURI = 'RegistrantProfileList';

if not exists (select 1 from stg .RegistrantProfile)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine

	exec dbo.pQuery#Execute$RegistrantProfile
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
	 @ObjectName = 'dbo.pQuery#Execute$RegistrantProfile'
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
	 ,@phoneNumber				 varchar(25)
	 ,@streetAddress			 nvarchar(75)
	 ,@citySID						 int
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
		select @phoneNumber						= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @streetAddress					= cast(p.ParameterValue as nvarchar(75))						from	@Parameters p	where	p.ParameterID = 'StreetAddress';
		select @citySID								= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CitySID';
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

		if @QueryCode = 'S!REGP.ALL'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			join
				sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID
			where
				(@startDateDTO is null or rp.CreateTime					>= @startDateDTO)
				and (@endDateDTO is null or rp.CreateTime				<= @endDateDTO)
				and (@importFileSID is null or rp.ImportFileSID = @importFileSID)
				and (@isUnprocessedOnly													= @OFF or ps.IsClosedStatus = @OFF)
			order by
				rp.RegistrantProfileSID;

		end;
		else if @QueryCode = 'S!REGP.LAST.IMPORT'
		begin

			select @importFileSID	 = max(rp.ImportFileSID) from stg.RegistrantProfile rp;

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			where
				rp.ImportFileSID = @importFileSID
			order by
				rp.RegistrantProfileSID;

		end;
		else if @QueryCode = 'S!REGP.UNPROCESSED'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			join
				sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.IsClosedStatus = @OFF
			where
				(@importFileSID is null or rp.ImportFileSID = @importFileSID)
			order by
				rp.RegistrantProfileSID;

		end;
		else if @QueryCode = 'S!REGP.BY.STATUS'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			where
				rp.ProcessingStatusSID = @processingStatusSID and (@importFileSID is null or rp.ImportFileSID = @importFileSID)
			order by
				rp.RegistrantProfileSID;

		end;
		else if @QueryCode = 'S!REGP.BY.FILE'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			join
				sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID
			where
				rp.ImportFileSID = @importFileSID and (@isUnprocessedOnly = @OFF or ps.IsClosedStatus = @OFF)
			order by
				rp.RegistrantProfileSID;

		end;
		else if @QueryCode = 'S!REGP.CANCELLED'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			join
				sf.ProcessingStatus		ps on rp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.ProcessingStatusSCD = 'CANCELLED'
			where
				(@startDateDTO is null or rp.CreateTime >= @startDateDTO) and (@endDateDTO is null or rp.CreateTime <= @endDateDTO)
			order by
				rp.RegistrantProfileSID;

		end;
		else if @QueryCode = 'S!REGP.FIND.BY.PHONE'
		begin

			insert
				#selected (EntitySID)
			select distinct
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			where
				rp.HomePhone like '%' + @phoneNumber + '%' or rp.MobilePhone like '%' + @phoneNumber + '%';

		end;
		else if @QueryCode = 'S!REGP.FIND.BY.ADDRESS'
		begin

			if @streetAddress is null and @citySID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoSearchParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No search criteria was provided. Enter at least one value.';

				raiserror(@errorText, 16, 1);
			end;

			insert
				#selected (EntitySID)
			select distinct
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			where
				(
					@streetAddress is null
					or rp.StreetAddress1 like '%' + @streetAddress + '%'
					or rp.StreetAddress2 like '%' + @streetAddress + '%'
					or rp.StreetAddress3 like '%' + @streetAddress + '%'
				)
				and (@citySID is null or rp.CitySID = @citySID);

		end;
		else if @QueryCode = 'S!REGP.RECENTLY.UPDATED'
		begin

			insert
				#selected (EntitySID)
			select
				rp.RegistrantProfileSID
			from
				stg.RegistrantProfile rp
			where
				rp.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or rp.UpdateUser = @userName);

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
