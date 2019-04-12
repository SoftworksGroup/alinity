SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#RegistrantLearningPlanStatus$SummaryXML
	@RegistrationYear int = null	-- registration year of the learning plan (defaults to current registration year)
as
/*********************************************************************************************************************************
Sproc    : Registration - Learning Plan Status Summary XML (Statistics)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns statistics information on Learning Plans for display in dashboards and form management pages
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
				: Taylor Napier				| Dec 2018		| Moved the fRegistration call out of a sub-select to improve performance

Comments
--------
This table function summarizes results from dbo.fRegistration#RegistrantLearningPlanStatus as statistics for display in dashboard widgets
and reports.  The output format is XML.  See base function for detailed explanation of logic applied.

The @RegistrationYear parameter defaults to the current registration year if not provided.

Learning Plans in a status of WITHDRAWN are ignored by the returned data set.  When a learning plan is WITHDRAWN the registrant 
is considered to be in the same status of not having started their learning plan (No Form).

Note that the "OTHER" category is reserved for errors.  No forms should end up in this category but it is included to
preserve balancing to the actual total number of records.  No forms should appear in this category under normal circumstances
as it indicates forms are not in any status/ownership that is expected by the procedure.  If the total of the category is zero, 
it is not included in the XML output.

Maintenance note
----------------
No counts should appear in the "OTHER" category. If values are found there debug through the #CurrentStatus function.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the function to return learning plan
	statistics for a year selected at random.">
    <SQLScript>
      <![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.RegistrantLearningPlan frm
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @registrationYear;

	exec dbo.pRegistration#RegistrantLearningPlanStatus$SummaryXML
		@RegistrationYear = @registrationYear;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:15"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistration#RegistrantLearningPlanStatus$SummaryXML'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		if @RegistrationYear is null -- default to current registration year
		begin
			set @RegistrationYear = dbo.fRegistrationYear#Current()
		end

		-- return summarized content as an XML document

		select
			StatGroup.Label
		 ,Stat.RegistrantLearningPlanStatLabel Label
		 ,isnull(z.Total, 0)									 Value
		from
		(
			select
				rs.RegistrantLearningPlanStatSID
			 ,rs.RegistrantLearningPlanStatLabel
			 ,rs.RegistrantLearningPlanStatCode
			from
				dbo.vRegistrantLearningPlan#Stat rs
		) Stat
		cross apply
		(
			select 'All'	Label
		) StatGroup
		left outer join
		(
			select
				case
					when x.FormStatusSCD = 'APPROVED'																					then 'COMPLETE'
					when x.FormOwnerSCD = 'REGISTRANT'																				then 'IN.PROGRESS'
					when x.FormOwnerSCD = 'ASSIGNEE'																					then 'IN.PROGRESS' -- TODO TIM - remove this line after #currentStatus is updated to new standard
					when x.FormOwnerSCD = 'ADMIN'																							then 'IN.ADMIN.REVIEW'
					when x.FormOwnerSCD = 'NONE'																							then 'REJECTED'
					else																																					 'OTHER'
				end RegistrantLearningPlanStatCode
				,count(1) Total
			from
				dbo.RegistrantLearningPlan																												 rlp
			outer apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) x --TODO TIM - update syntax to select from function directly! see profile update version
			where
				rlp.RegistrationYear = @RegistrationYear and x.FormStatusSCD <> 'WITHDRAWN'
			group by
				case
					when x.FormStatusSCD = 'APPROVED'																					then 'COMPLETE'
					when x.FormOwnerSCD = 'REGISTRANT'																				then 'IN.PROGRESS'
					when x.FormOwnerSCD = 'ASSIGNEE'																					then 'IN.PROGRESS' -- TODO TIM - remove this line after #currentStatus is updated to new standard
					when x.FormOwnerSCD = 'ADMIN'																							then 'IN.ADMIN.REVIEW'
					when x.FormOwnerSCD = 'NONE'																							then 'REJECTED'
					else																																					 'OTHER'
				end
		) z on Stat.RegistrantLearningPlanStatCode = z.RegistrantLearningPlanStatCode
		where
			(Stat.RegistrantLearningPlanStatCode <> 'OTHER' or isnull(z.Total, 0) > 0)	-- eliminate unexpected categories if value is 0
		order by
			Stat.RegistrantLearningPlanStatSID
		for xml auto, type, root('Stats');

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
