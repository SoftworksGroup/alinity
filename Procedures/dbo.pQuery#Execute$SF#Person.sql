SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$SF#Person
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Search - Person
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Person records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Person
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
  <Test Name = "FindByPhone" IsDefault ="true" Description="Executes the procedure to search for a partial phone number selected at random">
    <SQLScript>
      <![CDATA[

declare
	@queryCode	 varchar(30) = 'S!P.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter;

select top (1)
	@phoneNumber = substring(p.MobilePhone, 5, 4)
from
	sf.Person					p
join
	sf.Person pu on p.PersonSID = pu.PersonSID
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
		@parameters (ParameterID, ParameterValue)
	values
	(N'PhoneNumber', @phoneNumber);

	exec dbo.pQuery#Execute$SF#Person
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
  <Test Name = "All" Description="Executes the procedure to return all forms in a year selected at random">
    <SQLScript>
      <![CDATA[

declare
	@queryCode	 varchar(30) = 'S!P.ALL*'
 ,@parameters	 dbo.Parameter;

if not exists(select 1 from sf.Person)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute$SF#Person
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
	 @ObjectName = 'dbo.pQuery#Execute$SF#Person'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int						= 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)																					-- message text (for business rule errors)   
	 ,@ON									 bit						= cast(1 as bit)												-- constant for bit comparisons = 1
	 ,@OFF								 bit						= cast(0 as bit)												-- constant for bit comparison = 0
	 ,@recentDateTime			 datetimeoffset = sf.fRecentAccessCutOff()							-- oldest point considered within the recent access hours
	 ,@registrationYear		 smallint = dbo.fRegistrationYear#Current()							-- current registration year
	 ,@userName						 nvarchar(75)		= sf.fApplicationUserSession#UserName() -- sf.ApplicationUser UserName for the current user
	 ,@phoneNumber				 varchar(25)																						-- search parameter for phone number columns
	 ,@streetAddress			 nvarchar(75)																						-- search parameter for street address columns
	 ,@practiceRegisterSID int																										-- search parameter for practice register to include
	 ,@specializationSID	 int																										-- search parameter for specialization to include/exclude
	 ,@isUpdatedByMeOnly	 bit;																										-- filters for signed in user only as updater of records

	begin try

		-- execute the query based on its code value 

		if @QueryCode = 'S!P.ALL*'
		begin

			select top (@MaxRows)
				p.PersonSID
			from
				sf.Person p
			order by
				p.LastName
			 ,p.FirstName;

		end;
		else if @QueryCode = 'S!P.BY.REGISTER'
		begin

			select
				@practiceRegisterSID = cast(p.ParameterValue as int)
			from
				@Parameters p
			where
				p.ParameterID = 'PracticeRegisterSID';

			select top (@MaxRows)
				r.PersonSID
			from
				dbo.fRegistrant#LatestRegistration$SID(-1, @RegistrationYear) lReg
			join
				dbo.Registrant															 r on lReg.RegistrantSID = r.RegistrantSID
			join
				dbo.Registration reg on lReg.RegistrationSID = reg.RegistrationSID
			join
				dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = @practiceRegisterSID

		end;
		else if @QueryCode = 'S!P.FIND.BY.PHONE'
		begin

			select
				@phoneNumber = p.ParameterValue
			from
				@Parameters p
			where
				p.ParameterID = 'PhoneNumber';

			select distinct
				p.PersonSID
			from
				sf.Person p
			where
				p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%';

		end;
		else if @QueryCode = 'S!P.FIND.BY.ADDRESS'
		begin

			select
				@streetAddress = p.ParameterValue
			from
				@Parameters p
			where
				p.ParameterID = 'StreetAddress';

			select distinct
				pma.PersonSID
			from
				dbo.PersonMailingAddress pma
			where
				(
					pma.StreetAddress1 like '%' + @streetAddress + '%'
					or pma.StreetAddress2 like '%' + @streetAddress + '%'
					or pma.StreetAddress3 like '%' + @streetAddress + '%'
				);

		end;
		else if @QueryCode = 'S!P.MISSING.SPECIALIZATION'
		begin

			select
				@specializationSID = p.ParameterValue
			from
				@Parameters p
			where
				p.ParameterID = 'SpecializationSID';

			select
				@practiceRegisterSID = cast(p.ParameterValue as int)
			from
				@Parameters p
			where
				p.ParameterID = 'PracticeRegisterSID';

			select
				r.PersonSID
			from
				dbo.fRegistrant#LatestRegistration(-1, @registrationYear) lReg
			join
				dbo.Registrant																						r on lReg.RegistrantSID																	= r.RegistrantSID
			left outer join
				dbo.RegistrantCredential																	rc on r.RegistrantSID																		= rc.RegistrantSID and rc.CredentialSID = @specializationSID -- check for designated specialization
																																				and sf.fIsActive(rc.EffectiveTime, rc.ExpiryTime) = @ON	 -- must be active
			where
				lReg.PracticeRegisterSID = @practiceRegisterSID -- for the selected register
				and rc.CredentialSID is null; -- include if the specialization is missing;

		end;
		else if @QueryCode = 'S!P.RECENTLY.UPDATED'
		begin

			select
				@isUpdatedByMeOnly = cast(p.ParameterValue as bit)
			from
				@Parameters p
			where
				p.ParameterID = 'IsUpdatedByMeOnly';

			select
				p.PersonSID
			from
				sf.Person p
			where
				p.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or p.UpdateUser = @userName);

		end;
		else
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Query Search'
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
