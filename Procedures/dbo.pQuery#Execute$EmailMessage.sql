SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$EmailMessage
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Search - Email Message
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Email Message records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
				: Tim Edlund					| Apr	2019		| Applied security filter on ApplicationGrantSID in sf.EmailMessage

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Email Message
management. In order for query execution to synchronize with queries displayed on the user interface, the content of this procedure
and the query records created through sf.pSetup$SF#Query must be the same.

The @QueryCode value corresponds to the sf.Query.QueryCode column and is used for branching to the query to execute.  Any parameters
entered in the user interface for the query are stored as records in the @Parameters table and must be retrieved into local 
variables prior to execution.  Unless enforced as mandatory in the parameter definition, the parameter values can be null.
Zero-length strings detected in parameter values are converted to NULL's.  See also parent procedure.

Limitations
-----------
Although @MaxRows is passed as a parameter, a returned record limit is only enforced where "select top(@MaxRows)..." syntax is
implemented in the query.  If the enforcement of record limits has been turned off in the UI, the @MaxRows value has been set 
by the caller to a high value to avoid limiting the data set returned.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes the procedure to return all forms in a year selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode				varchar(30)	 = 'S!EMAIL.ALL'
 ,@parameters				dbo.Parameter

if not exists (select 1 from sf.EmailMessage)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute$EmailMessage
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
  <Test Name = "FindByPhone"  Description="Executes the procedure to search for a partial phone number selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode	 varchar(30) = 'S!EMAIL.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter

select top (1)
	 @phoneNumber = substring(p.MobilePhone, 5, 4)
from
	sf.Person				 p
join
	sf.PersonEmailMessage pem on p.PersonSID = pem.PersonSID
where
	len(ltrim(rtrim(substring(p.MobilePhone, 5, 4)))) = 4
order by
	newid();

if @@rowcount = 0 or @phoneNumber is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		@parameters (ParameterID, ParameterValue, Label)
	values
	(N'PhoneNumber', @phoneNumber, 'Phone');

	exec dbo.pQuery#Execute$EmailMessage
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999

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
	 @ObjectName = 'dbo.pQuery#Execute$EmailMessage'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo					 int							= 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)																						-- message text (for business rule errors)
	 ,@ON								 bit							= cast(1 as bit)												-- constant for bit comparisons = 1
	 ,@OFF							 bit							= cast(0 as bit)												-- constant for bit comparison = 0
	 ,@recentDateTime		 datetimeoffset		= sf.fRecentAccessCutOff()							-- oldest point considered within the recent access hours
	 ,@userName					 nvarchar(75)			= sf.fApplicationUserSession#UserName() -- sf.ApplicationUser UserName for the current user
	 ,@startDate				 date																											-- query parameter values retrieved for use in SELECTs:
	 ,@endDate					 date
	 ,@cutOffDate				 date
	 ,@cutOffNo					 int
	 ,@startDateTime		 datetime
	 ,@endDateTime			 datetime
	 ,@cutOffDateTime		 datetime
	 ,@startDateDTO			 datetimeoffset(7)
	 ,@endDateDTO				 datetimeoffset(7)
	 ,@cutOffDateDTO		 datetime
	 ,@isNotStarted			 bit
	 ,@phoneNumber			 varchar(25)
	 ,@streetAddress		 nvarchar(75)
	 ,@citySID					 int
	 ,@isUpdatedByMeOnly bit;

	begin try

		-- retrieve parameter values

		-- SQL Prompt formatting off
		select @recentDateTime				= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @startDate							= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @cutOffDate						= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'CutOffDate';
		select @isNotStarted					= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsNotStarted';
		select @phoneNumber						= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @cutOffNo							= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CutOffNo';
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

		if @cutOffDate is not null
		begin
			set @cutOffDateTime = @cutOffDate;
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

		-- if a query was saved as a default that has no
		-- data values for it, default them here based on 
		-- the most recent week of email activity
		if (@startDate is null or @endDate is null) and @QueryCode = 'S!EMAIL.ALL.LATEST.WK'
		begin
			select @endDateDTO = max (em.CreateTime) from sf.EmailMessage em;

			set @endDate = sf.fDTOffsetToClientDate(@endDateDTO);
			set @startDateDTO = dateadd(day, -7, @endDateDTO);
			set @startDate = sf.fDTOffsetToClientDate(@startDateDTO);
		end;

		-- execute the query 
		if @QueryCode = 'S!EMAIL.ALL'
		begin
			select top (@MaxRows)
				em.EmailMessageSID
			from
				sf.EmailMessage			em
			left outer join
				sf.ApplicationGrant ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				)
				and (@startDateDTO is null or em.CreateTime																										 >= @startDateDTO)
				and (@endDateDTO is null or em.CreateTime																											 <= @endDateDTO)
			order by
				em.EmailMessageSID;
		end;
		else if @QueryCode = 'S!EMAIL.ALL.LATEST.WK'
		begin
			select @endDateDTO = max (em.CreateTime) from sf.EmailMessage em;

			set @startDateDTO = dateadd(day, -7, @endDateDTO);

			select top (@MaxRows)
				em.EmailMessageSID
			from
				sf.EmailMessage			em
			left outer join
				sf.ApplicationGrant ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				)
				and (em.CreateTime between @startDateDTO and @endDateDTO)
			order by
				em.EmailMessageSID;
		end;
		else if @QueryCode = 'S!EMAIL.CANCELLED'
		begin
			select
				em.EmailMessageSID
			from
				sf.EmailMessage			em
			left outer join
				sf.ApplicationGrant ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				)
				and (@startDateDTO is null or em.CancelledTime																								 >= @startDateDTO)
				and (@endDateDTO is null or em.CancelledTime																									 <= @endDateDTO);
		end;
		else if @QueryCode = 'S!EMAIL.TO.ARCHIVE'
		begin
			set @cutOffDateTime = cast(convert(varchar(8), @cutOffDate, 112) + ' 23:59:59.99' as datetime);
			set @cutOffDateDTO = sf.fClientDateTimeToDTOffset(@cutOffDateTime); -- set to end of day

			select distinct
				em.EmailMessageSID
			from
				sf.EmailMessage			em
			left outer join
			(
				select
					pem.EmailMessageSID
				 ,max(pem.SentTime) SentTime
				 ,count(1)					RecipientCount
				from
					sf.PersonEmailMessage pem
				group by
					pem.EmailMessageSID
			)											pemX on em.EmailMessageSID	 = pemX.EmailMessageSID
			left outer join
				sf.ApplicationGrant ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				)
				and (pemX.SentTime																																						 < @cutOffDateDTO or em.CancelledTime < @cutOffDateDTO)
				and pemX.RecipientCount																																				 >= @cutOffNo;
		end;
		else if @QueryCode = 'S!EMAIL.ARCHIVED'
		begin
			select
				em.EmailMessageSID
			from
				sf.EmailMessage em
			where
				(@startDateDTO is null or em.ArchivedTime		>= @startDateDTO)
				and (@endDateDTO is null or em.ArchivedTime <= @endDateDTO)
				and (@isNotStarted													= @OFF or em.PurgedTime is null);
		end;
		else if @QueryCode = 'S!EMAIL.TRIMMED'
		begin
			select
				em.EmailMessageSID
			from
				sf.EmailMessage			em
			left outer join
				sf.ApplicationGrant ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				)
				and (@startDateDTO is null or em.PurgedTime																										 >= @startDateDTO)
				and (@endDateDTO is null or em.PurgedTime																											 <= @endDateDTO);
		end;
		else if @QueryCode = 'S!EMAIL.FIND.BY.PHONE'
		begin
			select distinct
				pem.EmailMessageSID
			from
			(
				select distinct
					p.PersonSID
				from
					sf.Person p
				where
					p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%'
			)												x
			join
				sf.PersonEmailMessage pem on x.PersonSID					 = pem.PersonSID
			join
				sf.EmailMessage				em on pem.EmailMessageSID		 = em.EmailMessageSID
			left outer join
				sf.ApplicationGrant		ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				);
		end;
		else if @QueryCode = 'S!EMAIL.FIND.BY.ADDRESS'
		begin
			if @streetAddress is null and @citySID is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'NoSearchParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No search criteria was provided. Enter at least one value.';

				raiserror(@errorText, 16, 1);
			end;

			select distinct
				pem.EmailMessageSID
			from
			(
				select distinct
					pma.PersonSID
				from
					dbo.PersonMailingAddress pma
				where
					(
						@streetAddress is null
						or pma.StreetAddress1 like '%' + @streetAddress + '%'
						or pma.StreetAddress2 like '%' + @streetAddress + '%'
						or pma.StreetAddress3 like '%' + @streetAddress + '%'
					)
					and (@citySID is null or pma.CitySID = @citySID)
			)												x
			join
				sf.PersonEmailMessage pem on x.PersonSID					 = pem.PersonSID
			join
				sf.EmailMessage				em on pem.EmailMessageSID		 = em.EmailMessageSID
			left outer join
				sf.ApplicationGrant		ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				);
		end;
		else if @QueryCode = 'S!EMAIL.RECENTLY.UPDATED'
		begin
			select
				em.EmailMessageSID
			from
				sf.EmailMessage			em
			left outer join
				sf.ApplicationGrant ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
			where
				(
					ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
				)
				and em.UpdateTime																																							 >= @recentDateTime
				and (@isUpdatedByMeOnly																																				 = @OFF or em.UpdateUser = @userName);
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
