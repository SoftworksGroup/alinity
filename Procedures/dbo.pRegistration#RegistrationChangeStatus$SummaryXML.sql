SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#RegistrationChangeStatus$SummaryXML
	@RegistrationYear int = null	-- registration year of the registration change (defaults to current registration year)
as
/*********************************************************************************************************************************
Sproc    : Registration - Registration Change Status Summary XML (Statistics)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns statistics information on Registration Changes for display in dashboards and form pages
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
				: Taylor Napier				| Dec 2018		| Moved the fRegistration call out of a sub-select to improve performance

Comments
--------
This table function summarizes results from dbo.fRegistration#RegistrationChangeStatus as statistics for display in dashboard 
widgets and reports.  The output format is XML.  See base function for detailed explanation of logic applied.

The @RegistrationYear parameter defaults to the current registration year if not provided.

Registration Changes in a status of WITHDRAWN are ignored by the returned data set.  When a registration change is WITHDRAWN the 
registrant is considered to be in the same status of not having started their registration change (No Form).

Note that the "OTHER" category is reserved for errors.  No forms should end up in this category but it is included to
preserve balancing to the actual total number of records.  No forms should appear in this category under normal circumstances
as it indicates forms are not in any status/ownership that is expected by the procedure.  If the total of the category is zero, 
it is not included in the XML output.

Maintenance note
----------------
No counts should appear in the "OTHER" category. If values are found there debug with:

select
	y.*
from
(
	select
		x.*
	 ,case
			when x.RegistrationChangeSID is null then 'Not Started'
			when x.FormOwnerSCD = 'REGISTRANT' then 'In Progress'
			when x.FormOwnerSCD = 'ADMIN' then 'In Admin Review'
			when x.FormOwnerSCD = 'NONE' then 'Rejected'
			when x.FormStatusSCD = 'APPROVED' and x.TotalDue > 0.00 then 'Not Paid'
			when x.FormStatusSCD = 'APPROVED' then 'Other: Approved with No License' -- this is an error condition also
			else 'Other: Unknown'
		end StatsGroup
	from
		dbo.fRegistration#RegistrationChangeStatus(2019) x
) y
where
	y.StatsGroup like 'Other%';

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the function to return registration change
	statistics for a year selected at random.">
    <SQLScript>
      <![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.RegistrationChange	frm
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @registrationYear

	exec dbo.pRegistration#RegistrationChangeStatus$SummaryXML
		@RegistrationYear = @registrationYear;

end;
		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
      <Assertion Type="ExecutionTime" Value="00:00:15"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistration#RegistrationChangeStatus$SummaryXML'
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
			StatGroup.PracticeRegisterLabel	 Label
		 ,Stat.RegistrationChangeStatLabel Label
		 ,isnull(z.Total, 0)							 Value
		from
			dbo.PracticeRegister StatGroup -- note that table alias' impact format of XML (do not modify)
		cross apply
		(
			select
				rs.RegistrationChangeStatSID
			 ,rs.RegistrationChangeStatLabel
			 ,rs.RegistrationChangeStatCode
			from
				dbo.vRegistrationChange#Stat rs
		)											 Stat
		left outer join
		(
			select
				x.PracticeRegisterSIDTo
				,case
					when x.RegistrationSIDTo is not null																			then 'COMPLETE'
					when x.RegistrationChangeSID is null																			then 'NOT.STARTED'
					when x.FormStatusSCD = 'APPROVED' and x.TotalDue > 0.00										then 'NOT.PAID'
					when x.FormOwnerSCD = 'REGISTRANT'																				then 'IN.PROGRESS'
					when x.FormOwnerSCD = 'ADMIN'																							then 'IN.ADMIN.REVIEW'
					when x.FormOwnerSCD = 'NONE'																							then 'REJECTED'
					else																																					 'OTHER'
				end RegistrationChangeStatCode
				,count(1) Total
			from
				dbo.fRegistration#RegistrationChangeStatus(@RegistrationYear) x
			group by
				x.PracticeRegisterSIDTo
			 ,case
					when x.RegistrationSIDTo is not null																			then 'COMPLETE'
					when x.RegistrationChangeSID is null																			then 'NOT.STARTED'
					when x.FormStatusSCD = 'APPROVED' and x.TotalDue > 0.00										then 'NOT.PAID'
					when x.FormOwnerSCD = 'REGISTRANT'																				then 'IN.PROGRESS'
					when x.FormOwnerSCD = 'ADMIN'																							then 'IN.ADMIN.REVIEW'
					when x.FormOwnerSCD = 'NONE'																							then 'REJECTED'
					else																																					 'OTHER'
				end
		) z on StatGroup.PracticeRegisterSID = z.PracticeRegisterSIDTo and Stat.RegistrationChangeStatCode = z.RegistrationChangeStatCode
		where
			(Stat.RegistrationChangeStatCode <> 'OTHER' or isnull(z.Total, 0) > 0)	-- eliminate unexpected categories if value is 0
		and
			statgroup.IsDefault <> cast(1 as bit) -- do not include the application base register
		order by
			StatGroup.PracticeRegisterLabel
		 ,Stat.RegistrationChangeStatSID
		for xml auto, type, root('Stats');

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
