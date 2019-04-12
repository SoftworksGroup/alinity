SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantLearningPlan#CurrentStatus
(
	@RegistrantLearningPlanSID int	-- key of record to return status information for
)
returns table
/*********************************************************************************************************************************
Function	: Registrant Learning Plan Current (form) Status
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns the latest form status for the given learning plan record
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017		|	Initial version
					: Tim Edlund	| Dec	2017		| Extended select to return status of NEW when no status records exist for the parent key

Comments	
--------
This table function modularizes the logic required to determine the latest form status for a registrant learning plan record. The 
function is used when searching for learning plans of a given status in the search procedure.  

If NO status changes exist for a Registrant-Learning-Plan update, then a default record with a "NEW" status is returned.  You can
use a CROSS APPLY to connect to the view as 1 record will always be returned.  If no status records exist, the primary key column
(first column) will be NULL. All other columns are assigned a value based on the parent record and/or the NEW sf.FormStatus row.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the function.">
<SQLScript>
<![CDATA[
	select top 1000
		 x.*
	from
		dbo.RegistrantLearningPlan rlp
	cross apply
		dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) x
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantLearningPlan#CurrentStatus'

-------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		cs.RegistrantLearningPlanStatusSID
	 ,new.RegistrationYear
	 ,isnull(cs.FormStatusSID, new.FormStatusSID)																								FormStatusSID
	 ,isnull(cs.FormStatusSCD, new.FormStatusSCD)																								FormStatusSCD
	 ,isnull(cs.FormStatusLabel, new.FormStatusLabel)																						FormStatusLabel
	 ,isnull(cs.IsFinal, new.IsFinal)																														IsFinal
	 ,cast(case when isnull(cs.IsFinal, new.IsFinal) = cast(1 as bit) then 0 else 1 end as bit) IsInProgress
	 ,isnull(cs.IsDefault, new.IsDefault)																												IsDefault
	 ,isnull(cs.CreateUser, new.CreateUser)																											CreateUser
	 ,isnull(cs.CreateTime, new.CreateTime)																											CreateTime
	 ,isnull(cs.FormOwnerSID, new.FormOwnerSID)																									FormOwnerSID
	 ,isnull(cs.FormOwnerSCD, new.FormOwnerSCD)																									FormOwnerSCD
	 ,isnull(cs.FormOwnerLabel, new.FormOwnerLabel)																							FormOwnerLabel
	 ,isnull(cs.IsAssignee, new.IsAssignee)																											IsAssignee
	from
	(
		select
			rlp.CreateUser
		 ,rlp.CreateTime
		 ,fsNew.FormStatusSID
		 ,fsNew.FormStatusSCD
		 ,fsNew.FormStatusLabel
		 ,fsNew.IsFinal
		 ,fsNew.IsDefault
		 ,fsNew.FormOwnerSID
		 ,foNew.FormOwnerSCD
		 ,foNew.FormOwnerLabel
		 ,foNew.IsAssignee
		 ,rlp.RegistrationYear
		from
			dbo.RegistrantLearningPlan rlp
		join
			sf.FormStatus							 fsNew on fsNew.FormStatusSCD = 'NEW'
		join
			sf.FormOwner							 foNew on fsNew.FormOwnerSID	= foNew.FormOwnerSID
		where
			rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID
	) new
	outer apply
	(
		select top (1)
			rlps.RegistrantLearningPlanStatusSID
		 ,rlps.FormStatusSID
		 ,fs.FormStatusSCD
		 ,fs.FormStatusLabel
		 ,fs.IsFinal
		 ,cast(case when fs.IsFinal = cast(1 as bit) then 0 else 1 end as bit) IsInProgress
		 ,fs.IsDefault
		 ,rlps.CreateUser
		 ,rlps.CreateTime
		 ,fs.FormOwnerSID
		 ,fo.FormOwnerSCD
		 ,fo.FormOwnerLabel
		 ,fo.IsAssignee
		from
			dbo.RegistrantLearningPlanStatus rlps
		join
			sf.FormStatus										 fs on rlps.FormStatusSID = fs.FormStatusSID
		join
			sf.FormOwner										 fo on fs.FormOwnerSID		= fo.FormOwnerSID
		where
			rlps.RegistrantLearningPlanSID = @RegistrantLearningPlanSID
		order by
			rlps.CreateTime desc
		 ,rlps.RegistrantLearningPlanStatusSID desc
	) cs
);
GO
