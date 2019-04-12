SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fLicense#IsAvailable
(
	@ApplicationGrantSID int	-- application grant to check license availability for
)
returns bit
as
/*********************************************************************************************************************************
TableF	: License - Is Available
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Checks if another license is available to assign for the module associated with the application grant passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Apr 2017    | Initial version
				: Kris D and Tim E		| Sep 2018		|	Updated to distinguish between assignments of BASE and non-base grants

Comments	
--------
The framework products set a limit on the number of users who can be assigned a license through a license file stored in the
configuration.  Users can be added to the system without limit but whenever they are assigned a grant to access a part of the
system, a check is done by this function to see if providing that access would exceed the number of licenses available.

The function looks up the module associated with the grant key.  For example, the application grant may have a code of 
"EXTERNAL.BASE".  The associated module is EXTERNAL.  The module is looked up from the parsed license file using the
sf.vLicense#Module view.  If a module is not found, the grant is of a type that is not limited by license counts and the
function returns 1 (ON) to avoid blocking the grant assignment.  If no licenses are remaining however, 0 (OFF) is returned 
and a message is raised by the caller advising the user additional licenses are required.

On "STGDB" Servers Checks License Limits Are Ignored
----------------------------------------------------
The function contains logic to bypass checks on staging and test servers.  As the naming conventions for these types of 
servers is updated, changes to the function are required. Note that this can result in the available license counts on
staging severs, are returned by vLicense#ModuleStatus - to be negative.  This will not occur on production servers.

Maintenance Note (sf.vLicense#ModuleStatus has parallel logic)
--------------------------------------------------------------
The logic in this function is nearly the same as that implemented in the sf.vLicense#ModuleStatus view except that it calculates
the available license count for 1 specific module rather than all modules.  This results in faster processing and therefore this
function is used in the sf.pApplicationUserGrant#Insert routine which is called frequently.  If the logic in this function
requires updating, check if the same changes should be made in sf.vLicense#ModuleStatus.

<TestHarness>
	<Test Name = "Simple" Description="Returns license availability check on a module at random. ">
	<SQLScript>
	<![CDATA[

declare
	@applicationGrantSID int
 ,@moduleSCD					 varchar(30)
 ,@applicationGrantSCD varchar(30);

select top (1)
	@applicationGrantSID = ag.ApplicationGrantSID
 ,@moduleSCD					 = lm.ModuleSCD
 ,@applicationGrantSCD = ag.ApplicationGrantSCD
from
	sf.vLicense#Module	lm
join
	sf.ApplicationGrant ag on lm.ModuleSCD + '.BASE' = ag.ApplicationGrantSCD
where
	lm.TotalLicenses > 0
order by
	newid();

select
	@moduleSCD																		ModuleSCD
 ,@applicationGrantSCD													ApplicationGrantSCD
 ,sf.fLicense#IsAvailable(@applicationGrantSID) LicenseIsAvailable;

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="RowCount" ResultSet="1" Value="1" />
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName				= 'sf.fLicense#IsAvailable'
	,@DefaultTestOnly	= 1
------------------------------------------------------------------------------------------------------------------------------- */

begin


	declare
		@isLicenseAvailable	 bit				= cast(0 as bit)							-- return value
	 ,@ON									 bit				= cast(1 as bit)							-- used on bit comparisons to avoid multiple casts
	 ,@applicationGrantSCD varchar(30)															-- basis of module code associated with the grant
	 ,@moduleSCD					 varchar(30)															-- module code - includes ".BASE" extension
	 ,@baseGrantSCD				 varchar(30)															-- the base grant that the application grant belongs to
	 ,@totalLicenses			 int																			-- total licenses available for the module		
	 ,@assignedLicenses		 int																			-- licenses assigned (to active users)
	 ,@now								 datetime		= sf.fNow()										-- current time in user timezone
	 ,@tomorrow						 datetime		= dateadd(day, 1, sf.fNow()); -- to avoid null comparisons on expiry date

	select
		@applicationGrantSCD = ag.ApplicationGrantSCD -- obtain the code associated with the grant key
	from
		sf.ApplicationGrant ag
	where
		ag.ApplicationGrantSID = @ApplicationGrantSID;

	set @moduleSCD = cast(sf.fStringSegment(@applicationGrantSCD, '.', 1) as varchar(30));
	set @baseGrantSCD = cast(@moduleSCD + '.BASE' as varchar(30));

	select -- check if a licensed module is associated, and if so
		@totalLicenses = lm.TotalLicenses -- the number of licenses available in total (purchased)
	from
		sf.vLicense#Module lm
	where
		lm.ModuleSCD = @moduleSCD;

	if @@rowcount > 0 and charindex('STGDB', @@servername) = 0 -- if no module exists, the grant is not a base module grant (allow assignment)
	begin -- if on a test/staging server - allow the grant	

		select
			@assignedLicenses = count(1)	-- count the number of licenses already assigned for this module
		from
			sf.ApplicationGrant			ag
		join
			sf.ApplicationUserGrant aug on ag.ApplicationGrantSID = aug.ApplicationGrantSID
		join
			sf.ApplicationUser			au on aug.ApplicationUserSID	= au.ApplicationUserSID
		where
			ag.ApplicationGrantSCD																							 = @baseGrantSCD
			and
			(
				sf.fIsActive(aug.EffectiveTime, isnull(aug.ExpiryTime, @tomorrow)) = @ON or aug.EffectiveTime > @now
			) -- check applies to future dated as well!
			and au.IsActive																											 = @ON
			and au.UserName																											 <> N'JobExec' -- do not count built-in system users or members of the help desk team
			and right(au.UserName, 13)																					 <> '@softworks.ca'
			and right(au.UserName, 15)																					 <> '@alinityapp.com'
			and right(au.UserName, 19)																					 <> '@softworksgroup.com';

		if @applicationGrantSCD = @baseGrantSCD
		begin
			set @assignedLicenses = @assignedLicenses + 1; -- when assigning a BASE grant, an additiona license is used up
		end;

		if @totalLicenses >= isnull(@assignedLicenses, 0)
		begin
			set @isLicenseAvailable = @ON;
		end;

	end;
	else -- license limits are not enforced on the staging server
	begin
		set @isLicenseAvailable = @ON;
	end;

	return (@isLicenseAvailable);
end;
GO
