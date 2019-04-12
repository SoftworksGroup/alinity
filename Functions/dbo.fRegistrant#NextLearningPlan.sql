SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#NextLearningPlan
(
	@RegistrantSID int	-- key of registrant to look up learning plan values for
)
returns @NextLearningPlan table
(
	LastPlanRegistrationYear smallint null			-- year of current learning plan
 ,NextPlanRegistrationYear smallint not null	-- year of next learning plan
 ,IsNextPlanRequired			 bit			not null	-- indicates if the next plan year can be added
 ,CycleLengthYears				 smallint not null	-- years available to complete the CE requirements
)
as
/*********************************************************************************************************************************
TableF		: Registrant - Next Learning Plan
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a table of values to determine whether the last learning plan is valid
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Jun 2018		|	Initial version
					: Tim Edlund	| Jul 2018		| Updated to use IsLearningPlanEnabled bit rather than IsActivePractice bit
					: Cory Ng			| Mar 2019		| If no current learning plan return the registration year with an active CCP period not the
																				current registration year
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is called by routines managing the creation and reporting on Registrant Learning Plans.  It reports on the last
learning plan created for the registrant and also reports whether a new learning plan is now due to be created.  The function
bases the year of the new learning plan on the last plan year and adds the Cycle-Length associated with the learning model
of the current registration.  

The function looks at the registrant's current Register to determine if a learning plan is permitted on that register.  If 
learning plans are not enabled for the register, the Is-Next-Plan-Required value in the output table is assigned a value 
of 0 (OFF).  Note that inactive register types can still be allowed to provide learning plans at the client's preference.

Example
-------

<TestHarness>
	<Test Name = "Random10" Description="Returns the function values for 10 registrants selected at random.">
	<SQLScript>
	<![CDATA[

select
	rlx.*
from
(
	select top (10)
		reg.RegistrantSID
	from
		dbo.Registration reg
	order by
		newid()
)																															x
cross apply dbo.fRegistrant#NextLearningPlan(x.RegistrantSID) rlx;

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#NextLearningPlan'	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@OFF											bit			= cast(0 as bit)	-- constant for bit comparison = 0
	 ,@ON												bit			= cast(1 as bit)	-- constant for bit comparison = 0
	 ,@lastPlanRegistrationYear smallint									-- year of current learning plan
	 ,@nextPlanRegistrationYear smallint									-- year of next learning plan
	 ,@isNextPlanRequired				bit			= cast(1 as bit)	-- indicates if the next plan year can be added
	 ,@isLearningPlanEnabled		bit			= cast(1 as bit)	-- used to check for active practice
	 ,@cycleLengthYears					smallint;									-- length of continuing education cycle for the active registration;

	-- get year of last learning plan for this registrant

	select
		@lastPlanRegistrationYear = max(rlp.RegistrationYear)
	from
		dbo.RegistrantLearningPlan rlp
	where
		rlp.RegistrantSID = @RegistrantSID;

	-- get cycle length based on learning model associated
	-- with registrant's last status

	select
		@cycleLengthYears			 = lm.CycleLengthYears
	 ,@isLearningPlanEnabled = pr.IsLearningPlanEnabled
	from
		dbo.fRegistrant#LastRegistration(@RegistrantSID) rlr
	join
		dbo.PracticeRegister														 pr on rlr.PracticeRegisterSID = pr.PracticeRegisterSID
	join
		dbo.LearningModel																 lm on pr.LearningModelSID		 = lm.LearningModelSID;

	if @lastPlanRegistrationYear is null
	begin
		
		select																													-- no previous learning plan, set to active CE collection year
			@nextPlanRegistrationYear = rsy.RegistrationYear
		from
			dbo.RegistrationScheduleYear rsy
		where
			sf.fNow() between rsy.CECollectionStartTime and rsy.CECollectionEndTime

	end;
	else
	begin

		set @nextPlanRegistrationYear = (@lastPlanRegistrationYear + @cycleLengthYears);

		if not exists (                                                       -- don't allow plan to be added if its not within the CE collection period
      select
        1
      from
        dbo.RegistrationScheduleYear rsy
      where
        rsy.RegistrationYear = @nextPlanRegistrationYear
      and
        sf.fNow() between rsy.CECollectionStartTime and rsy.CECollectionEndTime
    )
		begin
			set @isNextPlanRequired = @OFF;
		end;

	end;

	if @isNextPlanRequired = @ON and @isLearningPlanEnabled = @OFF
	begin
		set @isNextPlanRequired = @OFF; -- new learning plans are not created for registrants on inactive practice registers
	end;

	insert
		@NextLearningPlan
	(
		LastPlanRegistrationYear
	 ,NextPlanRegistrationYear
	 ,IsNextPlanRequired
	 ,CycleLengthYears
	)
	values
	(
		@lastPlanRegistrationYear, isnull(@nextPlanRegistrationYear, 0), isnull(@isNextPlanRequired, @OFF), isnull(@cycleLengthYears, 0)
	);

	return;

end;
GO
