SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#Registration$Base
(
	@RegistrantSID		int				-- must be provided - identifies registrant to return registration for
 ,@IsActive					bit				-- when 1 only currently active registration will be returned
 ,@RegistrationYear smallint	-- when set only the latest registration in that registration year will be returned
)
returns table
as
/*********************************************************************************************************************************
Function : Registrant - Registration - Base
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Helper function to fRegistrant#Registration to return the latest registration matching filter criteria
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This function encapsulates logic called repeatedly in dbo.fRegistrant#Registration.  The function applies filter conditions
to return a single registration for the given Registrant.  The first parameter - the @RegistrantSID - must be provided. The
remaining parameters may be passed as NULL.

The filter criteria supported are:

1) Returning only the current registration.  This is the latest registration with Active status.  Applies when @IsActive = 1.
2) Returning only the last registration for a given registration year.  Applies when @RegistrationYear is passed.
3) Otherwise, the latest registration is returned (it may be future dated or already expired).

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Selects latest registration for a registrant at random.">
    <SQLScript>
      <![CDATA[
declare @RegistrantSID int

select top (1)
	@RegistrantSID = rl.RegistrantSID
from
	dbo.Registration rl
where
	sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) = 1
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end
else
begin
	select * from		dbo.fRegistrant#Registration$Base(@RegistrantSID, null, null)
end
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrant#Registration$Base'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

return
(
	select top (1)
		rl.RegistrationSID
	 ,rl.RegistrantSID
	 ,rl.RegistrationNo
	 ,rl.PracticeRegisterSectionSID
	 ,rl.EffectiveTime
	 ,rl.ExpiryTime
	 ,rl.RegistrationYear
	from
		dbo.Registration rl
	where
		rl.RegistrantSID																	 = @RegistrantSID -- only include registrations for this registrant
		and
		(
			isnull(@IsActive, cast(0 as bit))								 = cast(0 as bit) or sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) = cast(1 as bit) -- optionally select only active registration
		)
		and
		(
			@RegistrationYear is null or rl.RegistrationYear = @RegistrationYear -- optionally select only registrations in a given registration year
		)
	order by
		rl.EffectiveTime desc
	 ,rl.RegistrationSID desc
);
GO
