SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantExam#Profile]
/*********************************************************************************************************************************
View    : Registrant Exam - Profile
Notice  : Copyright © 2018 Softworks Group Inc.
Summary : Returns a comprehensive record of registrant exams including exam name and result, offering and invoice/payment details
----------------------------------------------------------------------------------------------------------------------------------
History : Author              | Month Year  | Change Summary
        : ------------------- + ----------- + ------------------------------------------------------------------------------------
        : Tim Edlund					| Aug 2018    |    Initial version

Comments    
--------
This view provides details on registrant exams.  The view is intended for use in exports and for reporting. The leading columns
in the view provide registrant name and latest registration information for context.  
 
Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns exam information for 1 registrant selected at random.">
	<SQLScript>
	<![CDATA[

declare @registrantSID int;

select top (1)
	@registrantSID = re.RegistrantSID
from
	dbo.vRegistrantExam re
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.vRegistrantExam#Profile x
	where
		x.RegistrantSID = @registrantSID

end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "AllActive" Description="Returns exam records for all active registrants.">
	<SQLScript>
	<![CDATA[
select
	x.*
from
	dbo.vRegistrantExam#Profile x
where
	x.RegistrantIsCurrentlyActive = 1
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrantExam#Profile'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lreg.RegistrantNo
 ,lreg.RegistrantLabel
 ,lreg.RegistrationLabel
 ,lreg.LatestRegistrationYear
 ,lreg.RegistrantIsCurrentlyActive
 ,e.ExamName
 ,re.ExamDate
 ,er.ExamStatusLabel
 ,re.ExamResultDate
 ,re.Score
 ,e.PassingScore
 ,re.AssignedLocation
 ,re.ExamReference
 ,re.ConfirmedTime
 ,re.CancelledTime
 ,er.Sequence								ExamStatusSequence
 ,er.IsDefault							ExamStatusIsDefault
 ,eo.ExamTime								ExamOfferingExamTime
 ,eo.SeatingCapacity				ExamOfferingSeatingCapacity
 ,eo.BookingCutOffDate			ExamOfferingBookingCutOffDate
 ,o.OrgName									ExamOfferingOrgName
 ,o.OrgLabel								ExamOfferingOrgLabel
 ,c.CultureLabel						ExamOfferingCultureLabel
 ,ci.CatalogItemLabel				ExamOfferingCatalogItemLabel
 ,ci.InvoiceItemDescription ExamOfferingInvoiceItemDescription
 ,i.InvoiceSID							InvoiceNo
 ,i.InvoiceDate
 ,i.CancelledTime						InvoiceCancelledTime
 ,it.TotalBeforeTax					InvoiceTotalBeforeTax
 ,it.Tax1Total							InvoiceTax1Total
 ,it.Tax2Total							InvoiceTax2Total
 ,it.Tax3Total							InvoiceTax3Total
 ,it.TotalAdjustment				InvoiceTotalAdjustment
 ,it.TotalAfterTax					InvoiceTotalAfterTax
 ,it.TotalPaid							InvoiceTotalPaid
 ,it.TotalDue								InvoiceTotalDue
	--- standard export columns  -------------------
 ,lReg.PracticeRegisterLabel
 ,lReg.PracticeRegisterSectionLabel
 ,lReg.EmailAddress
 ,lReg.FirstName
 ,lReg.CommonName
 ,lReg.MiddleNames
 ,lReg.LastName
 ,lReg.PersonLegacyKey
 ,o.LegacyKey OrgLegacyKey
	--- system ID's ------------------------
 ,lreg.PersonSID
 ,lreg.RegistrantSID
 ,re.RegistrantExamSID
 ,e.ExamSID
 ,eo.ExamOfferingSID
 ,re.InvoiceSID
 ,eo.OrgSID
 ,eo.CatalogItemSID
from
	dbo.RegistrantExam												 re
join
	dbo.vRegistrant#LatestRegistration				 lreg on re.RegistrantSID = lreg.RegistrantSID
join
	dbo.Exam																	 e on re.ExamSID = e.ExamSID
left outer join
	dbo.ExamStatus														 er on re.ExamStatusSID = er.ExamStatusSID
left outer join
	dbo.ExamOffering													 eo on re.ExamOfferingSID = eo.ExamOfferingSID
left outer join
	dbo.CatalogItem														 ci on eo.CatalogItemSID = ci.CatalogItemSID
left outer join
	dbo.Org																		 o on eo.OrgSID = o.OrgSID
left outer join
	sf.Culture																 c on e.CultureSID = c.CultureSID
left outer join
	dbo.Invoice																 i on re.InvoiceSID = i.InvoiceSID
outer apply dbo.fInvoice#Total(i.InvoiceSID) it;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns details on exams completed by members including results, location, dates of writing, and associated invoice details of the exam was purchased. |EXPORT+ ^PersonList ^OrgList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam#Profile', NULL, NULL
GO
