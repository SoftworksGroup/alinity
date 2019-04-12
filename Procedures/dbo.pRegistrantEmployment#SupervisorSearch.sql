SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantEmployment#SupervisorSearch
	@SearchString nvarchar(150) = null	-- name or registrant# to search for 
 ,@PersonSID		int = null						-- to return existing supervisor if already set
as
/*********************************************************************************************************************************
Sproc    : Registrant Employment - Supervisor Search
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns results of a name or registration# search for a supervisor with eligibility annotation
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This procedure is designed to be called from a dynamic lookup control used in adding and editing (dbo) Employment Supervisor
records.  Employment supervisors are identified on the record by a PersonSID. Where the procedure is being called for
creating a new employment-supervisor record, the @PersonSID parameter will be NULL and a search string is expected. 

When the procedure is called during editing of an existing employment-supervisor record both parameters will be provided 
if the user has entered a search string to find a different supervisor.  In that situation the text-search using the 
string is performed and the @PersonSID value is ignored.  If no search string is provided, however, the procedure will 
return the label information for the @PersonSID provided.  This allows the control on the UI to be updated with the existing 
information when the record is first retrieved.

Enforce-Member-Supervisors Business Rule
----------------------------------------
A configuration parameter is included in the application which determines whether those persons selected as employment
supervisors must be active members, and, licensed on a Practice Register marked as being supervisor-eligible.  This 
procedure checks to see if the rule is being enforced and if so, and one or more names found in the search are not
eligible, the return value is annotated with "Not Eligible".  Note that the procedure does not filter out those ineligible
names since doing so would make the search appear as if it is not working.  If the user selects an ineligible supervisor
(on insert) the check constraint will prevent the entry.

Known Limitations
-----------------
Where the Enforce-Member-Supervisors business rule is on, a 3rd condition may apply where the supervisor must also be
employed at the same organization as the person they are supervising. This procedure does not mark individuals as ineligible
for this condition and does not require an OrgSID parameter to perform the search.  This 3rd condition is ignored since it 
is possible the supervisor being selected is valid but has simply not renewed or otherwise updated their employment information
at the time of their supervisee's entry.  If the supervisor were considered invalid the situation could only be resolved by all 
supervisors updating their information before all supervisees which would be difficult to achieve.  Instead the application 
provides queries identifying where "invalid" supervisor relationships exist and these queries are normally run after renewal 
has closed to enable all records to be updated with current employment information.

Extended search is NOT supported in this procedure.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a partial last name selected at random.">
    <SQLScript>
      <![CDATA[

declare @searchString nvarchar(150);

select top (1)
	@searchString = left(p.LastName, 4)
from
	sf.Person p
order by
	newid();

exec dbo.pRegistrantEmployment#SupervisorSearch
	@SearchString = @searchString;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:03:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrantEmployment#SupervisorSearch'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)									-- message text for business rule errors
	 ,@searchType									varchar(150)										-- type of search; returned in result for debugging
	 ,@ON													bit						= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF												bit						= cast(0 as bit)	-- constant for bit comparison = 0 
	 ,@maxRows										int															-- maximum rows allowed on search
	 ,@lastName										nvarchar(35)										-- for name searches, buffer for each name part:
	 ,@firstName									nvarchar(30)
	 ,@middleNames								nvarchar(30)
	 ,@registrantNo								varchar(50)											-- ID number search against reg# 
	 ,@isMemberSupervisorEnforced bit						= cast(1 as bit);

	declare @selected table -- stores primary key values of records to return
	(EntitySID int not null primary key);

	begin try

		set @SearchString = ltrim(rtrim(@SearchString));
		if len(@SearchString) = 0 set @SearchString = null;

		if @SearchString is null and @PersonSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@SearchString/@PersonSID';

			raiserror(@errorText, 18, 1);
		end;

		if @SearchString is not null
		begin

			exec sf.pSearchString#Parse
				@SearchString = @SearchString output
			 ,@LastName = @lastName output
			 ,@FirstName = @firstName output
			 ,@MiddleNames = @middleNames output
			 ,@IDNumber = @registrantNo output;

			if @registrantNo is not null
			begin

				set @searchType = 'Reg#';

				insert
					@selected (EntitySID)
				select
					r.PersonSID
				from
					dbo.Registrant r
				where
					r.RegistrantNo like @SearchString + '%';

			end;
			else
			begin

				set @searchType = 'Text';

				set @maxRows = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '200') as int);

				insert
					@selected (EntitySID)
				select top (@maxRows)
					px.PersonSID
				from
					sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @OFF) px
				order by
					px.PersonSID;

			end;

			set @isMemberSupervisorEnforced = isnull(convert(bit, sf.fConfigParam#Value('EnforceMemberSupervisors')), @ON);

		end;
		else if @PersonSID is not null -- otherwise return existing person information
		begin
			insert @selected ( EntitySID) values (@PersonSID);
			set @isMemberSupervisorEnforced = @OFF; -- do not re-validate previous entries
		end;

		select
			p.PersonSID
			,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)
			+ (case
					 when @isMemberSupervisorEnforced = @OFF then ''
					 when isnull(rlrSup.RegistrantIsCurrentlyActive, @OFF) = @OFF or isnull(pr.IsEligibleSupervisor, @OFF) = @OFF then ' (Not Eligible)'
					 else ''
				 end
				) -- allow ineligible supervisors to be returned but identify them
									SupervisorLabel
		 ,@searchType SearchType
		from
			@selected																														s
		join
			sf.Person																														p on s.EntitySID = p.PersonSID
		left outer join
			dbo.Registrant																											r on p.PersonSID = r.PersonSID
		outer apply dbo.fRegistrant#LatestRegistration(r.RegistrantSID, null) rlrSup
		left outer join
			dbo.PracticeRegister pr on rlrSup.PracticeRegisterSID = pr.PracticeRegisterSID
		option (recompile);

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
