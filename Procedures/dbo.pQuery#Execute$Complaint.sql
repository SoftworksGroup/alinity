SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$Complaint
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Execute - Complaint
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Complaint records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Registrant
Profile management. In order for query execution to synchronize with queries displayed on the user interface, the content of this
procedure and the query records created through sf.pSetup$SF#Query$Complaint must be the same.

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
procedure: dbo.pComplaint#SearchCT

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
	ap.ApplicationPageURI = 'ComplaintList'
and
	q.IsApplicationPageDefault = 1

if not exists (select 1 from dbo.Complaint)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @queryCode

	create table #selected (EntitySID int not null);

	exec dbo.pQuery#Execute$Complaint
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
	 @ObjectName = 'dbo.pQuery#Execute$Complaint'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)																						-- message text (for business rule errors)   
	 ,@OFF								bit							 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@recentDateTime			datetimeoffset	 = sf.fRecentAccessCutOff()								-- oldest point considered within the recent access hours
	 ,@userName						nvarchar(75)		 = sf.fApplicationUserSession#UserName()	-- sf.ApplicationUser UserName for the current user
	 ,@applicationUserSID int							 = sf.fApplicationUserSessionUserSID()		-- key of the currently logged in application user
	 ,@startDate					date																											-- query parameter values retrieved for use in SELECTs:
	 ,@endDate						date
	 ,@complaintTypeSID		int
	 ,@isOpenOnly					bit
	 ,@complainantTypeSID int
	 ,@adminApplicationUserSID int
	 ,@phoneNumber				varchar(25)
	 ,@streetAddress			nvarchar(75)
	 ,@citySID						int
	 ,@isUpdatedByMeOnly	bit;

	begin try

		if object_id('tempdb..#selected') is null -- create temporary table where it does not exist (testing scenarios only!)
		begin
			create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine
		end;

		-- retrieve parameter values
		-- SQL Prompt formatting off
		select @startDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate									= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @complaintTypeSID				= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'ComplaintTypeSID';
		select @complainantTypeSID			= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'ComplainantTypeSID';
		select @isOpenOnly							= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsOpenOnly';
		select @adminApplicationUserSID	= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'AdminApplicationUserSID';
		select @phoneNumber							= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @streetAddress						= cast(p.ParameterValue as nvarchar(75))						from	@Parameters p	where	p.ParameterID = 'StreetAddress';
		select @citySID									= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CitySID';
		select @recentDateTime					= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @isUpdatedByMeOnly				= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUpdatedByMeOnly';
		-- SQL Prompt formatting on

		-- store start/end dates entered on the UI as DTO's to 
		-- enable comparison with server times

		if @recentDateTime is not null
		begin
			set @recentDateTime = cast(convert(varchar(8), @recentDateTime, 112) + ' 23:59:59.99' as datetime);
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

		if @QueryCode = 'S!COMPLAINT.ALL'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				c.ComplaintSID
			from
				dbo.Complaint c
			where
				(@startDate is null or c.OpenedDate											 >= @startDate)
				and (@complaintTypeSID is null or c.ComplaintTypeSID		 = @complaintTypeSID)
				and (@complainantTypeSID is null or c.ComplainantTypeSID = @complainantTypeSID)
				and (@isOpenOnly																				 = @OFF or c.ClosedDate is null)
			order by
				c.ComplaintSID;

		end;
		else if @QueryCode = 'S!COMPLAINT.OPEN'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				c.ComplaintSID
			from
				dbo.Complaint c
			where
				c.ClosedDate is null
			order by
				c.ComplaintSID;

		end;
		else if @QueryCode = 'S!COMPLAINT.MY'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				c.ComplaintSID
			from
				dbo.Complaint c
			where
				c.ApplicationUserSID = @applicationUserSID and (@isOpenOnly = @OFF or c.ClosedDate is null)
			order by
				c.ComplaintSID;

		end;
		else if @QueryCode = 'S!COMPLAINT.STAFF.LEAD'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				c.ComplaintSID
			from
				dbo.Complaint c
			where
				c.ApplicationUserSID = @adminApplicationUserSID and (@isOpenOnly = @OFF or c.ClosedDate is null)
			order by
				c.ComplaintSID;

		end;
		else if @QueryCode = 'S!COMPLAINT.DISMISSED'
		begin

			insert
				#selected (EntitySID)
			select top (@MaxRows)
				c.ComplaintSID
			from
				dbo.Complaint c
			where
				c.DismissedDate is not null and (@startDate is null or c.DismissedDate >= @startDate) and (@endDate is null or c.DismissedDate >= @endDate)
			order by
				c.ComplaintSID;

		end;
		else if @QueryCode = 'S!COMPLAINT.FIND.BY.PHONE'
		begin

			insert
				#selected (EntitySID)
			select distinct
				c.ComplaintSID
			from
				dbo.Complaint	 c
			join
				dbo.Registrant r on c.RegistrantSID = r.RegistrantSID
			join
				sf.Person			 p on r.PersonSID			= p.PersonSID
			where
				p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%';

		end;
		else if @QueryCode = 'S!COMPLAINT.FIND.BY.ADDRESS'
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
				c.ComplaintSID
			from
				dbo.Complaint						 c
			join
				dbo.Registrant					 r on c.RegistrantSID = r.RegistrantSID
			join
				dbo.PersonMailingAddress pma on r.PersonSID		= pma.PersonSID
			where
				(
					@streetAddress is null
					or pma.StreetAddress1 like '%' + @streetAddress + '%'
					or pma.StreetAddress2 like '%' + @streetAddress + '%'
					or pma.StreetAddress3 like '%' + @streetAddress + '%'
				)
				and (@citySID is null or pma.CitySID = @citySID);

		end;
		else if @QueryCode = 'S!COMPLAINT.RECENTLY.UPDATED'
		begin

			insert
				#selected (EntitySID)
			select
				c.ComplaintSID
			from
				dbo.Complaint c
			where
				c.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or c.UpdateUser = @userName);

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
