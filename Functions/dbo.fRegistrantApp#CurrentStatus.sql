SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantApp#CurrentStatus
(
	@RegistrantAppSID int				-- key of record to return status information for or -1 for all
 ,@RegistrationYear smallint	-- year of form records to return, or -1 for all or when first param is provided
)
returns table
/*********************************************************************************************************************************
Function	: Application Current (form) Status
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the latest form status for 1 or all Application forms 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Cory Ng							| Dec 2018		| Updated IsReviewRequired to check if auto approval is blocked on validated forms
				: Tim Edlund					| Mar 2019		| Implemented next-to-act override back to APPLICANT if invoice is unpaid

Comments	
--------
This table function modularizes the logic required to determine the latest status for one Application form, all forms, 
or all forms in a given Registration year. The function is called in 2 main scenarios:

1) To provide status information for a form record already selected.  In this scenario the key of the form record must
be passed as the first parameter and the second parameter must be passed as -1.

2) For query support in the user interface.  The management screen for this form type includes a Registration Year as
a base criteria.  This allows administrators to manage forms for the latest year without cluttering up the UI with
forms already processed in previous years.  In this context the first parameter should be passed as -1 and the second
parameter must be the Registration Year to return records for.

The function requires that both parameters be passed. To return the current status of all forms for all registration 
years, pass both parameters as -1.  Note that passing either value as NULL is not equivalent to passing as -1.

The function performs a sub-select to first determine the set of form records to operate on.  It then obtains the latest
status record (based on CreateTime and the primary key). 

Maintenance Notes
----------------- 
*** Any logic change made to this function must also be made in dbo.fRegistration#FormStatus$Application ***

The data set returned is intentionally limited.  The application makes extensive use of this function for searching and 
extending attribution can lead to performance issues.  For additional attribution use the dbo.fRegistrantApp#Ext and
dbo.fRegistrantApp#ByStatus functions.
 
The data set returned by this function is consistent with data sets returned by other functions following the same naming 
convention and which support status reporting on other form types.  Do not modify this function in such as way that the resulting
data set will be unique.  If changes to the data set are required, apply them consistently through all functions of this type.
Note that a variance in the data set for forms that do/don't include a related invoice is expected.

Example
-------
<TestHarness>
	<Test Name = "ForYear" IsDefault = "true" Description="Selects dataset for all forms in a year selected at random.">
		<SQLScript>
			<![CDATA[
declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.RegistrantApp frm
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from		dbo.fRegistrantApp#CurrentStatus(-1, @registrationYear) x;
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
declare @RegistrantAppSID int;

select top (1)
	@RegistrantAppSID = frm.RegistrantAppSID
from
	dbo.RegistrantApp frm
order by
	newid();

if @@rowcount = 0 or @RegistrantAppSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from	dbo.fRegistrantApp#CurrentStatus(@RegistrantAppSID, -1) x;
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
	 @ObjectName = 'dbo.fRegistrantApp#CurrentStatus'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantAppSID
	 ,z.RegistrationYear
	 ,z.RegistrationSID
	 ,z.RegistrantAppStatusSID
	 ,z.IsFinal
	 ,z.IsInProgress
	 ,fo.FormOwnerSID
	 ,z.FormOwnerSCD
	 ,fo.FormOwnerLabel
	 ,fs.FormStatusSID
	 ,z.FormStatusSCD
	 ,(case
			 when fs.FormStatusSCD = 'APPROVED' and z.IsUnPaid = cast(1 as bit) then fs.FormStatusLabel + ' (not paid)'
			 else fs.FormStatusLabel
		 end
		)																																											 FormStatusLabel
	 ,z.LastStatusChangeUser
	 ,z.LastStatusChangeTime
	 ,z.IsAutoApprovalEnabled
	 ,(case when fs.IsFinal = cast(1 as bit) then cast(0 as bit)else z.IsReviewRequired end) IsReviewRequired -- finalized forms do not require review
	 ,z.NextFollowUp
	 ,z.PracticeRegisterSectionSIDTo
	 ,z.OrgSID
	 ,z.FormVersionSID
	 ,z.RowGUID
	 ,z.InvoiceSID
	 ,z.TotalAfterTax
	 ,z.TotalPaid
	 ,z.TotalDue
	 ,z.IsUnPaid
	 ,z.IsPaid
	 ,z.IsOverPaid
	 ,z.RecommendationLabel
	from
	(
		select
			x.RegistrantAppSID
		 ,x.RegistrationYear
		 ,x.RegistrationSID
		 ,x.RegistrantAppStatusSID
		 ,fs.IsFinal
		 ,cast((case when fs.IsFinal = cast(1 as bit) then 0 else 1 end) as bit) IsInProgress
		 ,(case
				 when fo.FormOwnerSCD is null then 'APPLICANT'
				 when (fs.FormStatusSCD = 'APPROVED' or fo.FormOwnerSCD = 'ADMIN') and it.IsUnPaid = cast(1 as bit) then 'APPLICANT'
				 when fo.FormOwnerSCD = 'ASSIGNEE' then 'APPLICANT'
				 else fo.FormOwnerSCD
			 end
			)																																			 FormOwnerSCD
		 ,isnull(fs.FormStatusSCD, 'NEW')																				 FormStatusSCD
		 ,x.LastStatusChangeUser
		 ,x.LastStatusChangeTime
		 ,x.IsAutoApprovalEnabled
		 ,x.IsReviewRequired
		 ,x.NextFollowUp
		 ,x.PracticeRegisterSectionSIDTo
		 ,x.OrgSID
		 ,x.FormVersionSID
		 ,x.RowGUID
		 ,x.InvoiceSID
		 ,it.TotalAfterTax																																						-- invoice details:
		 ,it.TotalPaid
		 ,it.TotalDue
		 ,it.IsUnPaid
		 ,it.IsPaid
		 ,it.IsOverPaid
		 ,dbo.fRegistrantApp#Recommendation(x.RegistrantAppSID)									 RecommendationLabel	-- summarizes review records (NULL if no review form configured)
		from
		(
			select
				f.RegistrantAppSID
			 ,f.RegistrationYear
			 ,f.RegistrationSID
			 ,f.IsAutoApprovalEnabled
			 ,f.IsReviewRequired
			 ,f.NextFollowUp
			 ,f.PracticeRegisterSectionSID				 PracticeRegisterSectionSIDTo
			 ,f.OrgSID
			 ,f.FormVersionSID
			 ,f.RowGUID
			 ,cs.RegistrantAppStatusSID
			 ,cs.FormStatusSID
			 ,isnull(cs.UpdateUser, f.UpdateUser) LastStatusChangeUser -- in case no status recorded, return creator of the record
			 ,isnull(cs.UpdateTime, f.UpdateTime) LastStatusChangeTime
			 ,f.InvoiceSID
			from
			(
				select
					frm.RegistrantAppSID
				 ,frm.RegistrationYear
				 ,frm.RegistrationSID
				 ,case when frm.IsAutoApprovalEnabled = cast(0 as bit) and frm.LastValidateTime is not null then cast(0 as bit) else cast(1 as bit) end				 IsAutoApprovalEnabled
				 ,case when frm.IsAutoApprovalEnabled = cast(0 as bit) and frm.LastValidateTime is not null then cast(1 as bit) else cast(0 as bit) end				 IsReviewRequired
				 ,frm.NextFollowUp
				 ,frm.PracticeRegisterSectionSID
				 ,frm.OrgSID
				 ,frm.FormVersionSID
				 ,frm.RowGUID
				 ,frm.InvoiceSID
				 ,frm.UpdateUser
				 ,frm.UpdateTime
				from
					dbo.RegistrantApp frm
				where
					(@RegistrantAppSID = -1 or frm.RegistrantAppSID = @RegistrantAppSID) and (@RegistrationYear = -1 or frm.RegistrationYear = @RegistrationYear)
			) f
			outer apply
			(
				select top (1) -- obtain latest status by create time
					fs.RegistrantAppStatusSID
				 ,fs.FormStatusSID
				 ,fs.UpdateTime
				 ,fs.UpdateUser
				from
					dbo.RegistrantAppStatus fs	-- status records inserted on each status change
				where
					fs.RegistrantAppSID = f.RegistrantAppSID
				order by
					fs.CreateTime desc
				 ,fs.RegistrantAppStatusSID desc
			) cs
		)																						 x
		left outer join
			sf.FormStatus															 fs on x.FormStatusSID = fs.FormStatusSID
		left outer join
			sf.FormOwner															 fo on fs.FormOwnerSID = fo.FormOwnerSID
		outer apply dbo.fInvoice#Total(x.InvoiceSID) it
	)								z
	join
		sf.FormOwner	fo on z.FormOwnerSCD	= fo.FormOwnerSCD
	join
		sf.FormStatus fs on z.FormStatusSCD = fs.FormStatusSCD
);
GO
