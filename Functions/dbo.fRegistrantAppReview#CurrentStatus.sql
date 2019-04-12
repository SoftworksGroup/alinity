SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantAppReview#CurrentStatus
(
	@RegistrantAppReviewSID int	-- key of record to return status information for or -1 for all
 ,@RegistrationYear smallint	-- year of form records to return, or -1 for all or when first param is provided
)
returns table
/*********************************************************************************************************************************
Function	: Application Review Current (form) Status
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the latest form status for 1 or all Application Review forms 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jun 2017		|	Initial version
 				: Tim Edlund          | Sep 2018		|	Updated to current standard - second parameter added

Comments	
--------
This table function modularizes the logic required to determine the latest status for one Application Review form, all forms, 
or all forms in a given Registration year. The function is called in 2 main scenarios:

1) To provide status information for a form record already selected.  In this scenario the key of the form record must
be passed as the first parameter and the second parameter must be passed as -1.

2) For query support for reporting.  Review forms are not presented in management screens except as a child forms under their
parent so querying in the UI directly against status is not required. Querying by status may be needed in certain reporting
scenarios where multiple records must be returned. In this context the first parameter should be passed as -1 and the second
parameter must be the Registration Year to return records for.

The function requires that both parameters be passed. To return the current status of all forms for all registration 
years, pass both parameters as -1.  Note that passing either value as NULL is not equivalent to passing as -1.

The function performs a sub-select to first determine the set of form records to operate on.  It then obtains the latest
status record (based on CreateTime and the primary key). 

Maintenance Notes
----------------- 
The data set returned is intentionally limited.  The appRvwlication makes extensive use of this function for searching and 
extending attribution can lead to performance issues.  For additional attribution use the dbo.fRegistrantAppReview#Ext and
dbo.fRegistrantAppReview#ByStatus functions.
 
The data set returned by this function is consistent with data sets returned by other functions following the same naming 
convention and which support status reporting on other form types.  Do not modify this function in such as way that the resulting
data set will be unique.  If changes to the data set are required, appRvwly them consistently through all functions of this type.
Note that a variance in the data set for forms that do/don't include a related invoice is expected.

Example
-------
<TestHarness>
	<Test Name = "ForYear" IsDefault = "true" Description="Selects dataset for all forms in a year selected at random.">
		<SQLScript>
			<![CDATA[
declare @registrationYear smallint;

select top (1)
	@registrationYear = app.RegistrationYear
from
	dbo.RegistrantApp app
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	if not exists(select 1 from dbo.RegistrantAppReview)
	begin
		raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
	end;
	else
	begin
		select x.* from		dbo.fRegistrantAppReview#CurrentStatus(-1, @registrationYear) x;
	end

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:15" />
		</Assertions>
	</Test>
	<Test Name = "Random" Description="Selects data set for a form selected at random.">
		<SQLScript>
			<![CDATA[
declare @RegistrantAppReviewSID int;

select top (1)
	@RegistrantAppReviewSID = appRvw.RegistrantAppReviewSID
from
	dbo.RegistrantAppReview appRvw
order by
	newid();

if @@rowcount = 0 or @RegistrantAppReviewSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from	dbo.fRegistrantAppReview#CurrentStatus(@RegistrantAppReviewSID, -1) x;
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:15" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantAppReview#CurrentStatus'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantAppReviewSID
	 ,z.RegistrationYear
	 ,z.RegistrantAppReviewStatusSID
	 ,fs.IsFinal
	 ,cast((case when fs.IsFinal = cast(1 as bit) then 0 else 1 end) as bit)																						 IsInProgress
	 ,(case fo.FormOwnerSCD when 'NONE' then fo.FormOwnerLabel when 'ADMIN' then fo.FormOwnerLabel else 'Reviewer' end)	 NextToAct
	 ,fs.FormStatusSID
	 ,isnull(fs.FormStatusSCD, 'NEW')																																										 FormStatusSCD	-- if no status recorded, consider as NEW
	 ,fs.FormStatusLabel
	 ,fs.FormOwnerSID
	 ,fo.FormOwnerSCD
	 ,fo.FormOwnerLabel
	 ,fo.IsAssignee
	 ,z.LastStatusChangeUser
	 ,z.LastStatusChangeTime
	 ,z.ReasonSID
	 ,rsn.ReasonCode
	 ,rsn.ReasonName
	 ,z.RecommendationSID
	 ,rec.ButtonLabel RecommendationLabel
	from
	(
		select
			f.RegistrantAppReviewSID
		 ,f.RegistrationYear
		 ,f.ReasonSID
		 ,f.RecommendationSID
		 ,cs.RegistrantAppReviewStatusSID
		 ,cs.FormStatusSID
		 ,isnull(cs.UpdateUser, f.UpdateUser) LastStatusChangeUser -- in case no status recorded, return creator of the record
		 ,isnull(cs.UpdateTime, f.UpdateTime) LastStatusChangeTime
		from
		(
			select
				appRvw.RegistrantAppReviewSID
			 ,app.RegistrationYear
			 ,appRvw.ReasonSID
			 ,appRvw.RecommendationSID
			 ,appRvw.UpdateUser
			 ,appRvw.UpdateTime
			from
				dbo.RegistrantAppReview appRvw
			join
				dbo.RegistrantApp app on appRvw.RegistrantAppSID = app.RegistrantAppSID and (@RegistrationYear = -1 or app.RegistrationYear = @RegistrationYear)
			where
				(@RegistrantAppReviewSID = -1 or appRvw.RegistrantAppReviewSID = @RegistrantAppReviewSID) 
		) f
		outer apply
		(
			select top (1) -- obtain latest status by create time
				fs.RegistrantAppReviewStatusSID
			 ,fs.FormStatusSID
			 ,fs.UpdateTime
			 ,fs.UpdateUser
			from
				dbo.RegistrantAppReviewStatus fs	-- status records inserted on each status change
			where
				fs.RegistrantAppReviewSID = f.RegistrantAppReviewSID
			order by
				fs.CreateTime desc
			 ,fs.RegistrantAppReviewStatusSID desc
		) cs
	)																						 z
	left outer join
		sf.FormStatus															 fs on z.FormStatusSID = fs.FormStatusSID
	left outer join
		sf.FormOwner															 fo on fs.FormOwnerSID = fo.FormOwnerSID
	left outer join
		dbo.Reason																 rsn on z.ReasonSID = rsn.ReasonSID
	left outer join
		dbo.Recommendation rec on z.RecommendationSID = rec.RecommendationSID
);
GO
