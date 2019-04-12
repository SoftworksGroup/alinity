SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoice#RegForm] (@InvoiceSID int) -- key of invoice to return reg form for
returns table
/*********************************************************************************************************************************
Function: Invoice - Reg Form
Notice  : Copyright © 2019 Softworks Group Inc.
Summary	: Returns the key and form-type-label for any registration form the given invoice is related to
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng			| Jan 2019			|	Initial Version
				: Cory Ng			| Jan 2019			| Updated the FormTypeSCD returned so they match the values in the FormType table
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function checks registration form types to determine if the invoice is related to one of them.  Business rules ensure an 
invoice can be associated with, at most, 1 registration form type.  If a relationship is found, the key of the form and the type 
of the form are returned in a single row data set. If no relationship to a registration form is found then a single record is 
still returned but with NULL values for the 2 columns.

Example
-------
<TestHarness>
	<Test Name="Random" Description="Check the reg form information for a random invoice">
		<SQLScript>
		<![CDATA[

		select top (1) 
			x.*
		from 
			dbo.Invoice i 
		cross apply
			dbo.fInvoice#RegForm(i.InvoiceSID) x
		order by 
			newid();

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName				= 'dbo.fInvoice#RegForm'
	,	@DefaultTestOnly	=	1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
			coalesce(rnw.RegistrantRenewalSID, rin.ReinstatementSID, rc.RegistrationChangeSID, app.RegistrantAppSID) RegFormSID
		 ,case
			-- SQL Prompt formatting off
			when rnw.RegistrantRenewalSID is not null then cast('RENEWAL.MAIN' as varchar(18))
			when rin.ReinstatementSID			is not null then cast('REINSTATEMENT.MAIN' as varchar(18))
			when rc.RegistrationChangeSID is not null then cast('REGCHANGE' as varchar(18))
			when app.RegistrantAppSID			is not null then cast('APPLICATION.MAIN' as varchar(18))
			else cast(null as varchar(13))
			-- SQL Prompt formatting on
			end																																																			 RegFormTypeSCD
		 ,case
			-- SQL Prompt formatting off
			when rnw.RegistrantRenewalSID is not null then cast('Renewal' as varchar(19))
			when rin.ReinstatementSID			is not null then cast('Reinstatement' as varchar(19))
			when rc.RegistrationChangeSID is not null then cast('Registration Change' as varchar(19))
			when app.RegistrantAppSID			is not null then cast('Application' as varchar(19))
			else cast(null as varchar(19))
			-- SQL Prompt formatting on
			end																																																			 RegFormTypeLabel
     ,coalesce(rrcs.FormStatusSCD, rcs.FormStatusSCD, rccs.FormStatusSCD, racs.FormStatusSCD)                  FormStatusSCD
		from
			dbo.Invoice						 i
		left outer join
			dbo.RegistrantRenewal	 rnw on i.InvoiceSID = rnw.InvoiceSID
    outer apply
      dbo.fRegistrantRenewal#CurrentStatus(rnw.RegistrantRenewalSID, -1) rrcs
		left outer join
			dbo.Reinstatement			 rin on i.InvoiceSID = rin.InvoiceSID
    outer apply
      dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) rcs
		left outer join
			dbo.RegistrationChange rc on i.InvoiceSID	 = rc.InvoiceSID
    outer apply
      dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) rccs
		left outer join
			dbo.RegistrantApp			 app on i.InvoiceSID = app.InvoiceSID
    outer apply
      dbo.fRegistrantApp#CurrentStatus(app.RegistrantAppSID, -1) racs
		where
			i.InvoiceSID = @InvoiceSID
);
GO
