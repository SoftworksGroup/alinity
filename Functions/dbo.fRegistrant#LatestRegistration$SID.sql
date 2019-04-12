SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#LatestRegistration$SID]
(
	@RegistrantSID		int -- key of registrant to return latest registration SID for or -1 for all registrants
 ,@RegistrationYear int -- registration year to use as criteria for "latest" - blank for current registration year
)
returns @LatestRegistrationSID table
(
	RegistrantSID		int not null
 ,RegistrationSID int not null
)
/*********************************************************************************************************************************
Function : Registrant - Latest Active Registration SID
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns the registrant SID and registration SID of the latest registration for a year for 1 or all registrants
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Apr 2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This is a helper function to return the primary key value of the latest registration for a member, or all members. To return the
data set for all members, pass -1.  The @RegistrationYear is an optional parameter. Leave it blank to return the latest
registration in effect for the member.  Provide a year to return the registration which was in effect (or will be in effect)
at the end of that registration year. The registration returned may or may not be "Active Practice" so if only currently 
practicing members need to be isolated the Is-Active-Practice on the associated register must be evaluated.

Note that leaving the year blank will not return a future dated registration that has not become effective yet such as a new 
registration created during the renewal period. Passing the year is useful where examination of a specific registration year, 
or even a future year, is required.  

To always get the last registration that exists for a person (including future dated) use the 
dbo.fRegistrant#LastRegistration function.

This function is called by fRegistrant#LatestRegistration but may also be called directly and used for other data set 
requirements.

Do NOT Convert to In-Line
-------------------------
Note that there is a significant performance improvement using this non-in-line table function structure when compared to
an in-line table function.  The in-line table structure needs to resolve "sf.fNow()" on every row while the structure 
implemented here needs to resolve it only once in the declaration statement.

Example
-------
<TestHarness>
  <Test Name = "OneRegistrant" IsDefault ="true" Description="Executes the function to return latest registration for a 
	single registrant at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrantSID int

select top (1)
	@registrantSID = reg.RegistrantSID
from
	dbo.Registration reg 
order by
	newid();

select
	x.RegistrantSID
 ,x.RegistrationSID
from
	dbo.fRegistrant#LatestRegistration$SID(@registrantSID,null) x;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "AllActive" IsDefault ="false" Description="Executes the function to return all latest registrations.">
    <SQLScript>
      <![CDATA[

select
	x.RegistrantSID
 ,x.RegistrationSID
from
	dbo.fRegistrant#LatestRegistration$SID(-1,null) x;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#LatestRegistration$SID'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
begin

	declare
		@start	datetime
	 ,@cutoff datetime;

	-- if no registration year was passed use the current time
	-- as the cut off for registration selection

	if @RegistrationYear is null
	begin
		set @cutoff = sf.fNow(); -- current time in user timezone
		set @RegistrationYear = dbo.fRegistrationYear#Current();
	end;

	-- otherwise lookup the end of the registration year
	-- from the table (if none found configuration is incomplete)

	select
		@start	= rsy.YearStartTime
	 ,@cutoff = isnull(@cutoff, rsy.YearEndTime)
	from
		dbo.RegistrationScheduleYear rsy
	where
		rsy.RegistrationYear = @RegistrationYear;

	if @start is null set @RegistrantSID = 0; -- will cause function to return no records so that error will be detected (config error!)

	insert
		@LatestRegistrationSID (RegistrantSID, RegistrationSID)
	select
		x.RegistrantSID
	 ,x.RegistrationSID
	from	(
					select
						reg.RegistrantSID
					 ,reg.RegistrationSID
					 ,rank() over (partition by
													 reg.RegistrantSID
												 order by
													 reg.EffectiveTime desc
													,reg.RegistrationSID desc
												) LatestRank
					from
						dbo.Registration reg
					where
						(
							reg.RegistrantSID		= @RegistrantSID or @RegistrantSID = -1
						) 
						and reg.EffectiveTime <= @cutoff and (reg.ExpiryTime > @start)	-- if expired must be expired after starting of target year
				) x
	where
		x.LatestRank = 1;

	return;

end;
GO
