SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$Person
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Search - Person
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of person/member records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Mar 2019		| Revised to replace filters with queries (update to latest search standard)

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of person/member
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
  <Test Name = "All" IsDefault ="true" Description="Executes the procedure to return all registrations in the current registration year=">
    <SQLScript>
      <![CDATA[
declare
	@queryCode				varchar(30)	 = 'S!REG.ALL'
 ,@parameters				dbo.Parameter
 ,@registrationYear int					 = dbo.fRegistrationYear#Current()
 ,@latestRegistration dbo.LatestRegistration 

if not exists (select 1 from dbo.Registration where RegistrationYear = @registrationYear)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	create table #selected (EntitySID int not null);

	insert
		@latestRegistration (RegistrationSID, RegistrantSID)
	select
		lReg.RegistrationSID
	 ,lReg.RegistrantSID
	from
		dbo.fRegistrant#LatestRegistration$SID(-1, @registrationYear) lReg;

	exec dbo.pQuery#Execute$Person
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999
	 ,@RegistrationYear = @registrationYear
	 ,@LatestRegistration = @latestRegistration;

	 select * from #selected

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
  <Test Name = "AllReg" Description="Executes query against registrations (calls to Execute$Registration">
    <SQLScript>
      <![CDATA[
declare
	@queryCode				varchar(30)	 = 'S!REG.ALL'
 ,@parameters				dbo.Parameter
 ,@registrationYear int					 = dbo.fRegistrationYear#Current();

if not exists (select 1 from dbo .Registration where RegistrationYear = @registrationYear)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	if object_id('tempdb..#selected') is not null 
	begin
		drop table #selected;
	end;

	create table #selected (EntitySID int not null); 

	exec dbo.pQuery#Execute$Person
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999;

	select
		isnull(p.PersonSID, s.EntitySID) PersonSID
	 ,p.LastName
	 ,p.FirstName
	from
		#selected s
	join
		sf.Person p on s.EntitySID = p.PersonSID
	join
		dbo.Registrant r on p.PersonSID = r.PersonSID

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
	@queryCode	 varchar(30) = 'S!REG.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter
 ,@registrationYear int			
 ,@latestRegistration dbo.LatestRegistration 

select top (1)
	 @phoneNumber = substring(p.MobilePhone, 5, 4)
	,@registrationYear = reg.RegistrationYear
from
	sf.Person				 p
join
	dbo.Registrant	 r on p.PersonSID				= r.PersonSID
join
	dbo.Registration reg on r.RegistrantSID = reg.RegistrantSID
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

	create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine

	insert
		@parameters (ParameterID, ParameterValue, Label)
	values
	(N'PhoneNumber', @phoneNumber, 'Phone');

	exec dbo.pQuery#Execute$Person
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999
	 ,@RegistrationYear = @registrationYear
	 ,@LatestRegistration = @latestRegistration;

	 select * from #selected

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
  <Test Name = "ByRegister"  Description="Executes the procedure to search for a given register in the current year">
    <SQLScript>
      <![CDATA[
declare
	@queryCode					 varchar(30)	= 'S!REG.BY.REGISTER'
 ,@parameters					 dbo.Parameter
 ,@registrationYear		 int					= dbo.fRegistrationYear#Current()
 ,@latestRegistration dbo.LatestRegistration 
 ,@practiceRegisterSID int;

select top (1)
	@practiceRegisterSID = prs.PracticeRegisterSID
from
	dbo.Registration						reg
join
	dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
where
	reg.RegistrationYear = @registrationYear
order by
	newid();

if @practiceRegisterSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	create table #selected (EntitySID int not null);

	insert
		@latestRegistration (RegistrationSID, RegistrantSID)
	select
		lReg.RegistrationSID
	 ,lReg.RegistrantSID
	from
		dbo.fRegistrant#LatestRegistration$SID(-1, @registrationYear) lReg;

	insert
		@parameters (ParameterID, ParameterValue, Label)
	values
	(N'PracticeRegisterSID', @practiceRegisterSID, 'Register')
	 ,(N'CultureSID', 0, 'Culture');

	exec dbo.pQuery#Execute$Person
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999
	 ,@RegistrationYear = @registrationYear
	 ,@LatestRegistration = @latestRegistration;

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
	 @ObjectName = 'dbo.pQuery#Execute$Person'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int									 = 0																				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)																										-- message text (for business rule errors)   
	 ,@ON										 bit									 = cast(1 as bit)														-- constant for bit comparisons = 1
	 ,@OFF									 bit									 = cast(0 as bit)														-- constant for bit comparison = 0
	 ,@registrationYear			 smallint							 = dbo.fRegistrationYear#Current()					-- current registration year (unless overwritten as parameter)
	 ,@latestRegistration		 dbo.LatestRegistration																						-- table storing keys of registration record for selected year 
	 ,@recentDateTime				 datetimeoffset				 = sf.fRecentAccessCutOff()									-- oldest point considered within the recent access hours
	 ,@userName							 nvarchar(75)					 = sf.fApplicationUserSession#UserName()		-- sf.ApplicationUser UserName for the current user
	 ,@registrationYearLabel varchar(9)																												-- shows both years if not based on calendar year
	 ,@now									 datetimeoffset(7)		 = sf.fClientDateTimeToDTOffset(sf.fNow())	-- current time in client timezone as DTO	
	 ,@cultureSID						 int																															-- supports split of query by language (always null unless multiple languages)
	 ,@regFormTypeSID				 int																															-- search parameters:
	 ,@formStatusSID				 int
	 ,@practiceRegisterSID	 int
	 ,@practiceRegisterSIDTo int
	 ,@renewalReasonSID			 int
	 ,@applicationReasonSID	 int
	 ,@startDate						 date
	 ,@endDate							 date
	 ,@cutoffDate						 date
	 ,@startDateTime				 datetime
	 ,@endDateTime					 datetime
	 ,@cutoffDateTime				 datetime
	 ,@startDateDTO					 datetimeoffset(7)
	 ,@endDateDTO						 datetimeoffset(7)
	 ,@cutoffDTO						 datetimeoffset(7)
	 ,@phoneNumber					 varchar(25)
	 ,@streetAddress				 nvarchar(75)
	 ,@citySID							 int
	 ,@stateProvinceSID			 int
	 ,@regionSID						 int
	 ,@isPaidOnly						 bit
	 ,@isUpdatedByMeOnly		 bit
	 ,@isNotPaid						 bit
	 ,@isNotStarted					 bit
	 ,@isPADSubscriber			 bit
	 ,@isNotPADSubscriber		 bit;

	begin try

		if object_id('tempdb..#selected') is null -- create temporary table where it does not exist (testing scenarios only!)
		begin
			create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine
		end;

		-- if a registration query is specified, call that
		-- subroutine to return Person SID

		if @QueryCode like 'S!REG.%' and @QueryCode not like 'S!REG.FIND.%' and @QueryCode not like 'S!REG.RECENTLY.%'
		begin

			if @QueryCode not like 'S!REG.RENEWAL.%' -- for non-renewal queries pre-load latest registrations
			begin

				insert
					@latestRegistration (RegistrationSID, RegistrantSID)
				select
					lReg.RegistrationSID
				 ,lReg.RegistrantSID
				from
					dbo.fRegistrant#LatestRegistration$SID(-1, @registrationYear) lReg;

			end;

			exec dbo.[pQuery#Execute$Registration]
				@QueryCode = @QueryCode
			 ,@Parameters = @Parameters
			 ,@MaxRows = @MaxRows
			 ,@RegistrationYear = @registrationYear
			 ,@LatestRegistration = @latestRegistration
			 ,@ReturnPersonSID = @ON;

		end;
		else -- execute a query against (sf) person
		begin

			-- retrieve parameter values

		-- SQL Prompt formatting off
		select @cultureSID						= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CultureSID';
		select @regFormTypeSID				= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'RegFormTypeSID';
		select @formStatusSID					= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'FormStatusSID';
		select @practiceRegisterSID		= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'PracticeRegisterSID';
		select @practiceRegisterSIDTo = cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'PracticeRegisterSIDTo';
		select @renewalReasonSID			= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'RenewalReasonSID';
		select @applicationReasonSID	= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'ApplicationReasonSID';
		select @recentDateTime				= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @startDate							= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @phoneNumber						= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @streetAddress					= cast(p.ParameterValue as nvarchar(75))						from	@Parameters p	where	p.ParameterID = 'StreetAddress';
		select @citySID								= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CitySID';
		select @stateProvinceSID			= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'StateProvinceSID';
		select @regionSID							= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'RegionSID';
		select @isPaidOnly						= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsPaidOnly';
		select @isUpdatedByMeOnly			= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUpdatedByMeOnly';
		select @isNotPaid							= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsNotPaid';
		select @isNotStarted					= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsNotStarted';
		select @isPADSubscriber				= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsPADSubscriber';
		select @isNotPADSubscriber		= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsNotPADSubscriber';
		-- SQL Prompt formatting on

			if @recentDateTime is not null
			begin
				set @recentDateTime = cast(convert(varchar(8), @recentDateTime, 112) + ' 23:59:59.99' as datetime);
			end;

			-- validate date parameters to occur within the registration
			-- year where they have been provided

			if @startDate is not null
			begin

				if dbo.fRegistrationYear(@startDate) <> @registrationYear
				begin

					set @registrationYearLabel = dbo.fRegistrationYear#Label(@registrationYear);

					exec sf.pMessage#Get
						@MessageSCD = 'NotInRegYear'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 must be in the registration year "%2".'
					 ,@Arg1 = 'start date'
					 ,@Arg2 = @registrationYearLabel;

					raiserror(@errorText, 16, 1);
				end;

				set @startDateTime = @startDate;
				set @startDateDTO = sf.fClientDateTimeToDTOffset(@startDateTime); -- convert to server time for comparison
			end;

			if @endDate is not null
			begin

				if dbo.fRegistrationYear(@endDate) <> @registrationYear
				begin

					set @registrationYearLabel = dbo.fRegistrationYear#Label(@registrationYear);

					exec sf.pMessage#Get
						@MessageSCD = 'NotInRegYear'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 must be in the registration year "%2".'
					 ,@Arg1 = 'end date'
					 ,@Arg2 = @registrationYearLabel;

					raiserror(@errorText, 16, 1);
				end;

				set @endDateTime = cast(convert(varchar(8), @endDate, 112) + ' 23:59:59.99' as datetime);
				set @endDateDTO = sf.fClientDateTimeToDTOffset(@endDateTime); -- set to end of day
			end;

			if @cutoffDate is not null
			begin
				set @cutoffDateTime = @cutoffDate;
				set @cutoffDTO = sf.fClientDateTimeToDTOffset(@cutoffDateTime); -- convert to server time for comparison
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

			if @isNotStarted = @ON and @formStatusSID is not null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'ConflictingParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" and "%2" criteria cannot both be applied.'
				 ,@Arg1 = 'Form Status'
				 ,@Arg2 = 'Not Started';

				raiserror(@errorText, 16, 1);

			end;

			if @isPADSubscriber = @ON and @isNotPADSubscriber = @ON
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'ConflictingParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" and "%2" criteria cannot both be applied.'
				 ,@Arg1 = 'Include PAD Subscribers'
				 ,@Arg2 = 'Exclude PAD Subscribers';

				raiserror(@errorText, 16, 1);

			end;

			-- execute the query 

			if @QueryCode = 'S!REG.ALL'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows) lReg.RegistrationSID from @latestRegistration lReg
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.ALL.ACTIVE'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					lReg.RegistrationSID
				from
					dbo.fRegistrant#LatestRegistration(-1, @registrationYear) lReg
				where
					lReg.IsActivePractice = @ON
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.ALL.RENEWING'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					lReg.RegistrationSID
				from
					@latestRegistration					lReg
				join
					dbo.Registration						reg on lReg.RegistrationSID						= reg.RegistrationSID
				join
					dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
				where
					pr.IsRenewalEnabled = @ON
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.ALL.TERM.BASED'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					lReg.RegistrationSID
				from
					@latestRegistration					lReg
				join
					dbo.Registration						reg on lReg.RegistrationSID						= reg.RegistrationSID
				join
					dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
				join
					dbo.PracticeRegisterType		prt on pr.PracticeRegisterTypeSID			= prt.PracticeRegisterTypeSID
				where
					prt.PracticeRegisterTypeSCD <> 'PERPETUAL'
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.OPEN.FORMS'
			begin

				insert
					#selected (EntitySID)
				select
					fs.RegistrationSID
				from
					dbo.fRegistration#FormStatus(@latestRegistration) fs
				join
					dbo.vRegFormType																	rft on rft.RegFormTypeSID = @regFormTypeSID
				where
					fs.RegFormRecordSID is not null -- form must exist
					and fs.RegFormIsFinal = @OFF -- status is not final (form still open)
					and (@regFormTypeSID = 100 or	 fs.RegFormTypeCode = rft.RegFormTypeCode) -- Reg-Form-Type = 100 is "All"
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.BY.STATUS'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					fs.RegistrationSID
				from
					dbo.fRegistration#FormStatus(@latestRegistration) fs
				join
					dbo.vRegFormType																	rft on rft.RegFormTypeSID = @regFormTypeSID
				where
					fs.RegFormStatusSID	 = @formStatusSID -- filter to selected status
					and (@regFormTypeSID = 100 or fs.RegFormTypeCode = rft.RegFormTypeCode) -- Reg-Form-Type = 100 is "All"
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.BY.REGISTER'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					lReg.RegistrationSID
				from
					@latestRegistration					lReg
				join
					dbo.Registration						reg on lReg.RegistrationSID						= reg.RegistrationSID
				join
					dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = @practiceRegisterSID
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.FOLLOWUP'
			begin

				insert
					#selected (EntitySID)
				select
					fs.RegistrationSID
				from
					dbo.fRegistration#FormStatus(@latestRegistration) fs
				join
					dbo.vRegFormType																	rft on rft.RegFormTypeSID = @regFormTypeSID
				where
					fs.NextFollowUp				<= @endDate -- before cut off date entered 
					and fs.RegFormIsFinal = @OFF -- not already finalized
					and -- Reg-Form-Type = 100 is "All"
					(@regFormTypeSID			= 100 or fs.RegFormTypeCode = rft.RegFormTypeCode)
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.ABANDONED'
			begin

				insert
					#selected (EntitySID)
				select
					fs.RegistrationSID
				from
					dbo.fRegistration#FormStatus(@latestRegistration) fs
				join
					dbo.vRegFormType																	rft on rft.RegFormTypeSID = @regFormTypeSID
				where
					fs.RegFormStatusTime	<= @endDateDTO -- no change in status after the cut off date
					and fs.RegFormIsFinal = @OFF -- form is not finalized
					and (@regFormTypeSID = 100 or	 fs.RegFormTypeCode = rft.RegFormTypeCode) -- Reg-Form-Type = 100 is "All"
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.APPROVED'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					fs.RegistrationSID
				from
					dbo.fRegistration#FormStatus(@latestRegistration) fs
				join
					dbo.vRegFormType																	rft on rft.RegFormTypeSID = @regFormTypeSID
				where
					fs.RegFormStatusSCD = 'APPROVED'
					and (fs.RegFormStatusTime between @startDateDTO and @endDateDTO)
					and -- Reg-Form-Type = 100 is "All"
					(@regFormTypeSID		= 100 or fs.RegFormTypeCode = rft.RegFormTypeCode)
					and (@isPaidOnly		= @OFF or fs.RegFormTotalDue = 0.0)
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.CARD.NOT.PRINTED'
			begin

				insert
					#selected (EntitySID)
				select
					lReg.RegistrationSID
				from
					@latestRegistration					lReg
				join
					dbo.Registration						reg on lReg.RegistrationSID						= reg.RegistrationSID
				join
					dbo.Registrant							r on reg.RegistrantSID								= r.RegistrantSID
				join
					sf.ApplicationUser					au on r.PersonSID											= au.PersonSID
				join
					dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = @practiceRegisterSID
				where
					reg.CardPrintedTime is null and reg.CreateTime <= isnull(@cutoffDTO, reg.CreateTime) and (@cultureSID is null or au.CultureSID = @cultureSID) -- culture of member matches selected culture
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.CARD.PRINTED'
			begin

				insert
					#selected (EntitySID)
				select
					lReg.RegistrationSID
				from
					@latestRegistration					lReg
				join
					dbo.Registration						reg on lReg.RegistrationSID						= reg.RegistrationSID
				join
					dbo.Registrant							r on reg.RegistrantSID								= r.RegistrantSID
				join
					sf.ApplicationUser					au on r.PersonSID											= au.PersonSID
				join
					dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = @practiceRegisterSID
				where
					(reg.CardPrintedTime between @startDateTime and @endDateTime) and (@cultureSID is null or au.CultureSID = @cultureSID)	-- culture of member matches selected culture
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.EXPIRED'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					lReg.RegistrationSID
				from
					dbo.fRegistrant#LatestRegistration$SID(-1, null) lReg
				join
					dbo.Registration																 reg on lReg.RegistrationSID					 = reg.RegistrationSID
				join
					dbo.Registrant																	 r on reg.RegistrantSID								 = r.RegistrantSID
				join
					sf.ApplicationUser															 au on r.PersonSID										 = au.PersonSID
				join
					dbo.PracticeRegisterSection											 prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				where
					reg.RegistrationYear																			= @registrationYear
					and reg.ExpiryTime																				< @now
					and
					(
						@practiceRegisterSID is null or prs.PracticeRegisterSID = @practiceRegisterSID
					)
					and (@cultureSID is null or au.CultureSID									= @cultureSID)
				option (recompile); -- culture of member matches selected culture

			end;
			else if @QueryCode = 'S!REG.FIND.BY.PHONE'
			begin

				insert
					#selected (EntitySID)
				select
					lReg.RegistrationSID
				from
				(
					select distinct
						p.PersonSID
					from
						sf.Person p
					where
						p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%'
				)																																												 x
				join
					dbo.Registrant																																				 r on x.PersonSID = r.PersonSID
				cross apply dbo.[fRegistrant#LatestRegistration$SID](r.RegistrantSID, @registrationYear) lReg;

			end;
			else if @QueryCode = 'S!REG.FIND.BY.ADDRESS'
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
				select
					lReg.RegistrationSID
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
				)																																												 x
				join
					dbo.Registrant																																				 r on x.PersonSID = r.PersonSID
				cross apply dbo.[fRegistrant#LatestRegistration$SID](r.RegistrantSID, @registrationYear) lReg;

			end;
			else if @QueryCode = 'S!REG.FIND.BY.LOCATION'
			begin

				if @citySID is null and @stateProvinceSID is null and @regionSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'NoSearchParameters'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'No search criteria was provided. Enter at least one value.';

					raiserror(@errorText, 16, 1);
				end;

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					lReg.RegistrationSID
				from
					dbo.[fRegistrant#LatestRegistration$SID](-1, @registrationYear) lReg
				join
					dbo.Registration																								r on lReg.RegistrationSID						= r.RegistrationSID
				join
					dbo.PracticeRegisterSection																			prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.Registrant																									re on lReg.RegistrantSID						= re.RegistrantSID
				join
					sf.ApplicationUser																							au on re.PersonSID									= au.PersonSID
				join
				(
					select
						pma.PersonSID
					from
						dbo.PersonMailingAddress pma
					join
						dbo.City								 c on pma.CitySID									= c.CitySID
					join
					(
						select
							row_number() over (partition by
																	 pma.PersonSID
																 order by
																	 pma.EffectiveTime desc
																	,pma.PersonMailingAddressSID desc
																) rn	-- order by latest effective then SID
						 ,pma.PersonMailingAddressSID
						from
							dbo.PersonMailingAddress pma
					)													 x on pma.PersonMailingAddressSID = x.PersonMailingAddressSID and x.rn = 1
					where
						pma.CitySID						 = isnull(@citySID, pma.CitySID)
						and c.StateProvinceSID = isnull(@stateProvinceSID, c.StateProvinceSID)
						and pma.RegionSID			 = isnull(@regionSID, pma.RegionSID)
				)																																	x on re.PersonSID										= x.PersonSID
				where
					prs.PracticeRegisterSID = @practiceRegisterSID and (@cultureSID is null or au.CultureSID = @cultureSID) -- culture of member matches selected culture
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.RECENTLY.UPDATED'
			begin

				insert
					#selected (EntitySID)
				select
					lReg.RegistrationSID
				from
					@latestRegistration lReg
				join
					dbo.Registration		reg on lReg.RegistrationSID = reg.RegistrationSID
				join
					dbo.Registrant			r on reg.RegistrantSID			= r.RegistrantSID
				join
					sf.ApplicationUser	au on r.PersonSID						= au.PersonSID
				where
					reg.UpdateTime														>= @recentDateTime
					and (@isUpdatedByMeOnly										= @OFF or reg.UpdateUser = @userName)
					and (@cultureSID is null or au.CultureSID = @cultureSID)	-- culture of member matches selected culture
				option (recompile);

			end;
			else if @QueryCode = 'S!REG.RENEWAL.RVW.REQUIRED'
			begin

				if @renewalReasonSID is null
				begin

					insert
						#selected (EntitySID)
					select
						cs.RegistrationSID
					from
						dbo.fRegistrantRenewal#CurrentStatus(-1, @registrationYear + 1) cs
					join
						dbo.Registration																								r on cs.RegistrationSID = r.RegistrationSID
					join
						dbo.Registrant																									re on r.RegistrantSID		= re.RegistrantSID
					join
						sf.ApplicationUser																							au on re.PersonSID			= au.PersonSID
					where
						cs.FormOwnerSCD														= 'ADMIN' -- faster to select from the status only if no specific reason criteria required
						and (@cultureSID is null or au.CultureSID = @cultureSID); -- culture of member matches selected culture

				end;
				else
				begin

					insert
						#selected (EntitySID)
					select
						x.RegistrationSID
					from
					(
						select
							cs.RegistrationSID
						 ,cs.RegistrantRenewalSID
						from
							dbo.fRegistrantRenewal#CurrentStatus(-1, @registrationYear + 1) cs
						join
							dbo.Registration																								r on cs.RegistrationSID = r.RegistrationSID
						join
							dbo.Registrant																									re on r.RegistrantSID		= re.RegistrantSID
						join
							sf.ApplicationUser																							au on re.PersonSID			= au.PersonSID
						where
							cs.FormOwnerSCD = 'ADMIN' and (@cultureSID is null or au.CultureSID = @cultureSID)	-- culture of member matches selected culture

					) x
					join
					(
						select
							rsns.RegistrantRenewalSID
						from
							dbo.fRegistrantRenewal#ReviewReasons(-1, @registrationYear + 1) rsns
						where
							rsns.ReasonSID = @renewalReasonSID
					) y on x.RegistrantRenewalSID = y.RegistrantRenewalSID; -- limit result set to the specific reason criteria provided

				end;

			end;
			else if @QueryCode = 'S!REG.RENEWAL.NOT.STARTED'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.RegistrantRenewalSID is null
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and (@isPADSubscriber																				 = @OFF or rs.PAPSubscriptionSID is not null)
					and (@isNotPADSubscriber																		 = @OFF or rs.PAPSubscriptionSID is null)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID)
					and rs.IsNonRenewalRegistration															 = @OFF;

			end;
			else if @QueryCode = 'S!REG.RENEWAL.IN.PROGRESS'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.RegistrantRenewalSID is not null -- form is created
					and rs.RegistrationSIDTo is null -- new registration not created
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID)
					and rs.IsNonRenewalRegistration															 = @OFF;

			end;
			else if @QueryCode = 'S!REG.RENEWAL.NOT.PAID'
			begin

				insert
					#selected (EntitySID)
				select
					rnw.RegistrationSID
				from
				(
					select
						rnw.RegistrantRenewalSID
					 ,rnw.RegistrationSID
					 ,rnw.PracticeRegisterSectionSID
					from
						dbo.RegistrantRenewal												 rnw
					outer apply dbo.fInvoice#Total(rnw.InvoiceSID) it
					where
						rnw.RegistrationYear = (@registrationYear + 1) and it.TotalDue > 0	-- isolate unpaid invoices for the year as starting point
				)																																																	rnw
				join
					dbo.Registration																																								reg on rnw.RegistrationSID = reg.RegistrationSID
				join
					dbo.Registrant																																									r on reg.RegistrantSID = r.RegistrantSID
				join
					dbo.PracticeRegisterSection																																			prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				left outer join
					dbo.PAPSubscription																																							pad on r.PersonSID = pad.PersonSID and pad.CancelledTime is null
				left outer join
					sf.ApplicationUser																																							au on r.PersonSID = au.ApplicationUserSID -- to retrieve culture
				outer apply dbo.fRegistrantRenewal#CurrentStatus(rnw.RegistrantRenewalSID, @registrationYear + 1) cs
				where
					cs.FormStatusSCD																					= 'APPROVED'
					and
					(
						@practiceRegisterSID is null or prs.PracticeRegisterSID = @practiceRegisterSID
					)
					and (@isPADSubscriber																			= @OFF or pad.PAPSubscriptionSID is not null)
					and (@isNotPADSubscriber																	= @OFF or pad.PAPSubscriptionSID is null)
					and (@cultureSID is null or au.CultureSID									= @cultureSID);

			end;
			else if @QueryCode = 'S!REG.RENEWAL.PAP.UNAPPLIED'
			begin

				insert
					#selected (EntitySID)
				select distinct
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				join
					dbo.vPayment																			 pm on pm.PersonSID = rs.PersonSID and pm.PaymentTypeSCD = 'PAP' and pm.TotalUnapplied > 0.00 and pm.IsCancelled = @OFF
				where
					rs.FormStatusSCD																						 = 'APPROVED'
					and rs.TotalDue																							 = 0.00
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID)
					and rs.IsNonRenewalRegistration															 = @OFF;

			end;
			else if @QueryCode = 'S!REG.NOT.RENEWED'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.RegistrationSIDTo is null
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and (@formStatusSID is null or rs.FormStatusSID							 = @formStatusSID)
					and (@isNotPaid																							 = @OFF or rs.TotalDue > 0.00)
					and (@isNotStarted																					 = @OFF or rs.RegistrantRenewalSID is null)
					and (@isPADSubscriber																				 = @OFF or rs.PAPSubscriptionSID is not null)
					and (@isNotPADSubscriber																		 = @OFF or rs.PAPSubscriptionSID is null)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID)
					and rs.IsNonRenewalRegistration															 = @OFF;

			end;
			else if @QueryCode = 'S!REG.RENEWAL.DONE'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.RegistrationSIDTo is not null
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and
					(
						@practiceRegisterSIDTo is null or rs.PracticeRegisterSIDTo = @practiceRegisterSIDTo
					)
					and (@startDateDTO is null or rs.NewRegistrationTime				 >= @startDateDTO)
					and (@endDateDTO is null or rs.NewRegistrationTime					 <= @endDateDTO)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID)
					and rs.IsNonRenewalRegistration															 = @OFF;

			end;
			else if @QueryCode = 'S!REG.RENEWAL.REGCHANGE'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.RegistrationSIDTo is not null
					and rs.PracticeRegisterSIDFrom															 <> rs.PracticeRegisterSIDTo
					and rs.IsNonRenewalRegistration															 = @OFF
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and
					(
						@practiceRegisterSIDTo is null or rs.PracticeRegisterSIDTo = @practiceRegisterSIDTo
					)
					and (@startDateDTO is null or rs.NewRegistrationTime				 >= @startDateDTO)
					and (@endDateDTO is null or rs.NewRegistrationTime					 <= @endDateDTO)
					and (@isPADSubscriber																				 = @OFF or rs.PAPSubscriptionSID is not null)
					and (@isNotPADSubscriber																		 = @OFF or rs.PAPSubscriptionSID is null)
					and (@isPaidOnly																						 = @OFF or rs.TotalDue = 0.0)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.RENEWAL.BY.STATUS'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.FormStatusSID																						 = @formStatusSID -- matches form status (mandatory)
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					) and (@cultureSID is null or rs.CultureSID									 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.RENEWAL.ABANDONED'
			begin

				insert
					#selected (EntitySID)
				select
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rs
				where
					rs.LastStatusChangeTime																		 <= @endDateDTO -- no change in status after the cut off date
					and rs.RegistrationSIDTo is null -- renewal is not complete
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDTo = @practiceRegisterSID
					)
					and rs.IsNonRenewalRegistration														 = @OFF
					and (@cultureSID is null or rs.CultureSID									 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.RENEWAL.PAIDNOREG'
			begin

				insert
					#selected (EntitySID)
				select
					rnw.RegistrationSID
				from
					dbo.fRegistrantRenewal#CurrentStatus(-1, @registrationYear + 1) rnw
				left outer join
					dbo.Registration																								reg on rnw.RowGUID = reg.FormGUID	 -- see if new registration exists for the renewal
				where
					rnw.IsPaid = @ON and rnw.TotalAfterTax > 0.0 -- the renewal invoice is paid
					and reg.RegistrationSID is null;	-- a new registration record is NOT created for it

			end;
			else if @QueryCode = 'S!REG.RENEWAL.DIDNOT'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rnw.RegistrationSIDFrom
				from
					dbo.fRegistration#RenewalStatus(@registrationYear) rnw
				join
					dbo.Registrant																		 r on rnw.RegistrantSID = r.RegistrantSID
				join
					sf.ApplicationUser																 au on r.PersonSID			= au.PersonSID
				where
					rnw.IsNonRenewalRegistration																	= @ON
					and
					(
						@practiceRegisterSID is null or rnw.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and (@cultureSID is null or au.CultureSID											= @cultureSID);

			end;
			else if @QueryCode = 'S!REG.APPLICATION.RVW.REQUIRED'
			begin

				if @applicationReasonSID is null
				begin

					insert
						#selected (EntitySID)
					select
						cs.RegistrationSID
					from
						dbo.fRegistrantApp#CurrentStatus(-1, @registrationYear) cs
					join
						dbo.Registration																				r on cs.RegistrationSID = r.RegistrationSID
					join
						dbo.Registrant																					re on r.RegistrantSID		= re.RegistrantSID
					join
						sf.ApplicationUser																			au on re.PersonSID			= au.PersonSID
					where
						(cs.FormOwnerSCD													= 'ADMIN' or cs.FormOwnerSCD = 'REVIEWER') -- faster to select from the status only if no specific reason criteria required
						and (@cultureSID is null or au.CultureSID = @cultureSID); -- allow separation of result by language of member (email support)

				end;
				else
				begin

					insert
						#selected (EntitySID)
					select
						x.RegistrationSID
					from
					(
						select
							cs.RegistrationSID
						 ,cs.RegistrantAppSID
						from
							dbo.fRegistrantApp#CurrentStatus(-1, @registrationYear) cs
						join
							dbo.Registration																				r on cs.RegistrationSID = r.RegistrationSID
						join
							dbo.Registrant																					re on r.RegistrantSID		= re.RegistrantSID
						join
							sf.ApplicationUser																			au on re.PersonSID			= au.PersonSID
						where
							(cs.FormOwnerSCD = 'ADMIN' or cs.FormOwnerSCD = 'REVIEWER') and (@cultureSID is null or au.CultureSID = @cultureSID)
					) x
					join
					(
						select
							rsns.RegistrantAppSID
						from
							dbo.fRegistrantApp#ReviewReasons(-1, @registrationYear) rsns
						where
							rsns.ReasonSID = @applicationReasonSID
					) y on x.RegistrantAppSID = y.RegistrantAppSID; -- limit result set to the specific reason criteria provided

				end;

			end;
			else if @QueryCode = 'S!REG.APPLICATION.IN.PROGRESS'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#ApplicationStatus(@registrationYear) rs
				where
					rs.RegistrationSIDTo is null -- new registration not created
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDTo = @practiceRegisterSID
					) and (@cultureSID is null or rs.CultureSID								 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.APPLICATION.NOT.PAID'
			begin

				insert
					#selected (EntitySID)
				select
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#ApplicationStatus(@registrationYear) rs
				where
					rs.FormStatusSCD																						 = 'APPROVED'
					and rs.TotalDue																							 > 0.00
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDFrom = @practiceRegisterSID
					)
					and (@cultureSID is null or rs.CultureSID										 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.APPLICATION.DONE'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDTo
				from
					dbo.fRegistration#ApplicationStatus(@registrationYear) rs
				where
					rs.RegistrationSIDTo is not null -- new registration is created
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDTo = @practiceRegisterSID
					)
					and (rs.NewRegistrationTime between @startDateDTO and @endDateDTO)
					and (@cultureSID is null or rs.CultureSID									 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.APPLICATION.BY.STATUS'
			begin

				insert
					#selected (EntitySID)
				select top (@MaxRows)
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#ApplicationStatus(@registrationYear) rs
				where
					rs.FormStatusSID																					 = @formStatusSID -- matches form status (mandatory)
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDTo = @practiceRegisterSID
					) and (@cultureSID is null or rs.CultureSID								 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.APPLICATION.ABANDONED'
			begin

				insert
					#selected (EntitySID)
				select
					rs.RegistrationSIDFrom
				from
					dbo.fRegistration#ApplicationStatus(@registrationYear) rs
				where
					rs.LastStatusChangeTime																		 <= @endDateDTO -- no change in status after the cut off date
					and rs.RegistrationSIDTo is null -- application is not complete
					and rs.IsFinal																						 = @OFF -- form is not finalized
					and
					(
						@practiceRegisterSID is null or rs.PracticeRegisterSIDTo = @practiceRegisterSID
					) and (@cultureSID is null or rs.CultureSID								 = @cultureSID);

			end;
			else if @QueryCode = 'S!REG.APPLICATION.PAIDNOREG'
			begin

				insert
					#selected (EntitySID)
				select
					app.RegistrationSID
				from
					dbo.fRegistrantApp#CurrentStatus(-1, @registrationYear) app
				join
					dbo.Registration																				r on app.RegistrationSID = r.RegistrationSID
				join
					dbo.Registrant																					re on r.RegistrantSID		 = re.RegistrantSID
				join
					sf.ApplicationUser																			au on re.PersonSID			 = au.PersonSID
				left outer join
					dbo.Registration																				reg on app.RowGUID			 = reg.FormGUID	 -- see if new registration exists for the application
				where
					app.IsPaid																= @ON and app.TotalAfterTax > 0.0 -- the application invoice is paid
					and reg.RegistrationSID is null -- a new registration record is NOT created for it
					and (@cultureSID is null or au.CultureSID = @cultureSID);

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
		end;

	end try
	begin catch
		set noexec off;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
