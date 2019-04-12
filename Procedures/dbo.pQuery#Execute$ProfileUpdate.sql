SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$ProfileUpdate
	@QueryCode				varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters				dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows					int											-- maximum rows allowed on search
 ,@RegistrationYear smallint								-- registration year selected in the UI 
as
/*********************************************************************************************************************************
Sproc    : Query Search - Profile Update
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Profile Update records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Profile Update
management. In order for query execution to synchronize with queries displayed on the user interface, the content of this procedure
and the query records created through sf.pSetup$SF#Query must be the same.

The @QueryCode value corresponds to the sf.Query.QueryCode column and is used for branching to the query to execute.  Any parameters
entered in the user interface for the query are stored as records in the @Parameters table and must be retrieved into local 
variables prior to execution.  Unless enforced as mandatory in the parameter definition, the parameter values can be null.
Zero-length strings detected in parameter values are converted to NULL's.  See also parent procedure.

Limitations
-----------
Although @MaxRows is passed as a parameter, a returned record limit is only enforced where "select top(@MaxRows) ..." syntax is
implemented in the query.  If the enforcement of record limits has been turned off in the UI, the @MaxRows value has been set 
by the caller to a high value to avoid limiting the data set returned.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes the procedure to return all forms in a year selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode	 varchar(30) = 'S!PU.ALL'
 ,@parameters				dbo.Parameter
 ,@registrationYear smallint

select top (1)
	@registrationYear = pu.RegistrationYear
from
	dbo.ProfileUpdate pu 
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute$ProfileUpdate
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999
	 ,@RegistrationYear = @registrationYear

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
	@queryCode	 varchar(30) = 'S!PU.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter
 ,@registrationYear smallint = dbo.fRegistrationYear#Current()

select top (1)
	@phoneNumber = substring(p.MobilePhone, 5, 4)
from
	sf.Person					p
join
	dbo.ProfileUpdate pu on p.PersonSID = pu.PersonSID and pu.RegistrationYear = @registrationYear
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

	exec dbo.pQuery#Execute$ProfileUpdate
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999
	 ,@RegistrationYear = @registrationYear

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
	 @ObjectName = 'dbo.pQuery#Execute$ProfileUpdate'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int							= 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)																						-- message text (for business rule errors)    
	 ,@OFF									 bit							= cast(0 as bit)												-- constant for bit comparison = 0
	 ,@recentDateTime				 datetimeoffset		= sf.fRecentAccessCutOff()							-- oldest point considered within the recent access hours
	 ,@userName							 nvarchar(75)			= sf.fApplicationUserSession#UserName() -- sf.ApplicationUser UserName for the current user
	 ,@registrationYearLabel varchar(9)																								-- shows both years if not based on calendar year
	 ,@formStatusSID				 int																											-- search parameter for the status of the form
	 ,@reasonSID						 int																											-- reason form is blocked (admin is next to act)
	 ,@startDate						 date																											-- search parameter based on date range (start)
	 ,@endDate							 date																											-- search parameter based on date range (end)
	 ,@startDateDTO					 datetimeoffset(7)																				-- client date from UI converted to system time
	 ,@endDateDTO						 datetimeoffset(7)																				-- client date from UI converted to system time
	 ,@phoneNumber					 varchar(25)																							-- search parameter for phone number columns
	 ,@streetAddress				 nvarchar(75)																							-- search parameter for street address columns
	 ,@citySID							 int																											-- search parameter for city
	 ,@isUpdatedByMeOnly		 bit;																											-- filters for signed in user only as updater of records

	begin try

		if @RegistrationYear is null
		begin
			set @RegistrationYear = dbo.fRegistrationYear#Current();
		end;

		-- execute the query based on its code value 

		if @QueryCode = 'S!PU.ALL'
		begin

			select top (@MaxRows)
				pu.ProfileUpdateSID
			from
				dbo.ProfileUpdate pu
			where
				pu.RegistrationYear = @RegistrationYear
			order by
				pu.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.OPEN.FORMS'
		begin

			select top (@MaxRows)
				cs.ProfileUpdateSID
			from
				dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
			where
				cs.IsFinal = @OFF
			order by
				cs.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.BY.STATUS'
		begin

			select
				@formStatusSID = cast(p.ParameterValue as int)
			from
				@Parameters		p
			join
				sf.FormStatus fs on cast(p.ParameterValue as int) = fs.FormStatusSID
			where
				p.ParameterID = 'FormStatusSID';

			select top (@MaxRows)
				cs.ProfileUpdateSID
			from
				dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
			where
				cs.FormStatusSID = @formStatusSID
			order by
				cs.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.FOLLOWUP'
		begin

			select
				@endDate = cast(replace(p.ParameterValue, '-', '') as date)
			from
				@Parameters p
			where
				p.ParameterID = 'EndDate';

			select top (@MaxRows)
				cs.ProfileUpdateSID
			from
				dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
			where
				cs.NextFollowUp <= @endDate and cs.IsFinal = @OFF
			order by
				cs.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.ABANDONED'
		begin

			select
				@endDate = cast(replace(p.ParameterValue, '-', '') as date)
			from
				@Parameters p
			where
				p.ParameterID = 'EndDate';

			select top (@MaxRows)
				cs.ProfileUpdateSID
			from
				dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
			where
				cs.LastStatusChangeTime <= @endDate and cs.IsFinal = @OFF
			order by
				cs.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.APPROVED'
		begin

			select
				@startDate = cast(replace(p.ParameterValue, '-', '') as date)
			from
				@Parameters p
			where
				p.ParameterID = 'StartDate';

			select
				@endDate = cast(replace(p.ParameterValue, '-', '') as date)
			from
				@Parameters p
			where
				p.ParameterID = 'EndDate';

			if dbo.fRegistrationYear(@startDate) <> @RegistrationYear or dbo.fRegistrationYear(@endDate) <> @RegistrationYear
			begin

				set @registrationYearLabel = dbo.fRegistrationYear#Label(@RegistrationYear);

				exec sf.pMessage#Get
					@MessageSCD = 'NotInRegYear'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 must be in the registration year "%2".'
				 ,@Arg1 = 'start and end dates'
				 ,@Arg2 = @registrationYearLabel;

				raiserror(@errorText, 16, 1);
			end;

			set @startDateDTO = sf.fClientDateTimeToDTOffset(@startDate); -- now convert to server time for comparison
			set @endDateDTO = sf.fClientDateTimeToDTOffset(cast(convert(varchar(8), @endDate, 112) + ' 23:59:59.99' as datetime));

			select top (@MaxRows)
				cs.ProfileUpdateSID
			from
				dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
			where
				cs.FormStatusSCD = 'APPROVED' and (cs.LastStatusChangeTime between @startDateDTO and @endDateDTO)
			order by
				cs.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.REVIEW.REASON'
		begin

			select
				@reasonSID = cast(p.ParameterValue as int)
			from
				@Parameters p
			join
				dbo.Reason	rsn on cast(p.ParameterValue as int) = rsn.ReasonSID
			where
				p.ParameterID = 'PUReasonSID';

			if @reasonSID is null
			begin

				select top (@MaxRows)
					cs.ProfileUpdateSID
				from
					dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
				where
					cs.FormOwnerSCD = 'ADMIN' -- faster to select from the status only if no specific reason criteria required
				order by
					cs.ProfileUpdateSID;

			end;
			else
			begin

				select top (@MaxRows)
					x.ProfileUpdateSID
				from
				(
					select
						cs.ProfileUpdateSID
					from
						dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
					where
						cs.FormOwnerSCD = 'ADMIN'
				) x
				join
				(
					select
						rsns.ProfileUpdateSID
					from
						dbo.fProfileUpdate#ReviewReasons(-1, @RegistrationYear) rsns
					where
						rsns.ReasonSID = @reasonSID
				) y on x.ProfileUpdateSID = y.ProfileUpdateSID -- limit result set to the specific reason criteria provided
			order by
				x.ProfileUpdateSID;

			end;

		end;
		else if @QueryCode = 'S!PU.FIND.BY.PHONE'
		begin

			select
				@phoneNumber = p.ParameterValue
			from
				@Parameters p
			where
				p.ParameterID = 'PhoneNumber';

			select top (@MaxRows)
				pu.ProfileUpdateSID
			from
			(
				select distinct
					p.PersonSID
				from
					sf.Person p
				where
					p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%'
			)										x
			join
				dbo.ProfileUpdate pu on x.PersonSID = pu.PersonSID
			where
				pu.RegistrationYear = @RegistrationYear
			order by
				pu.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.FIND.BY.ADDRESS'
		begin

			select
				@streetAddress = p.ParameterValue
			from
				@Parameters p
			where
				p.ParameterID = 'StreetAddress';

			select
				@citySID = cast(p.ParameterValue as int)
			from
				@Parameters p
			where
				p.ParameterID = 'CitySID';

			if @streetAddress is null and @citySID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoSearchParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No search criteria was provided. Enter at least one value.';

				raiserror(@errorText, 16, 1);
			end;

			select top (@MaxRows)
				pu.ProfileUpdateSID
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
			)										x
			join
				dbo.ProfileUpdate pu on x.PersonSID = pu.PersonSID
			where
				pu.RegistrationYear = @RegistrationYear
			order by
				pu.ProfileUpdateSID;

		end;
		else if @QueryCode = 'S!PU.RECENTLY.UPDATED'
		begin

			select
				 @isUpdatedByMeOnly = cast(p.ParameterValue as bit)
			from
				@Parameters p
			where
				p.ParameterID = 'IsUpdatedByMeOnly';

			select
				@recentDateTime = cast(replace(p.ParameterValue, '-', '') as date)
			from
				@Parameters p
			where
				p.ParameterID = 'RecentDateTime';

			select top (@MaxRows)
				pu.ProfileUpdateSID
			from
				dbo.ProfileUpdate pu
			where
				pu.RegistrationYear = @RegistrationYear and pu.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or pu.UpdateUser = @userName)
			order by
				pu.ProfileUpdateSID;

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
