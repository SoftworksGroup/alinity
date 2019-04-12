SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pInvoice#RegForm
	@InvoiceSID int -- key of invoice to check for related registration forms
as
/*********************************************************************************************************************************
Sproc    : Invoice - Registration Form
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns the key and form-type-label for any registration form the given invoice is related to
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
Comments	
--------
This procedure is called from the user interface when positioned on an invoice. It checks registration form types to determine
if the invoice is related to one of them.  Business rules ensure an invoice can be associated with, at most, 1 registration
form type.  If a relationship is found, the key of the form and the type of the form are returned in a single row data
set. If no relationship to a registration form is found then a single record is still returned but with NULL values for the
2 columns.

Known Limitations
-----------------
This procedure must be updated as new registration form types are added to the application.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a record selected at random">
    <SQLScript>
      <![CDATA[

declare @invoiceSID int;

select top (1) @invoiceSID = i .InvoiceSID from dbo.Invoice i order by newid();

exec dbo.pInvoice#RegForm 
	 @InvoiceSID = @invoiceSID

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:02:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pInvoice#RegForm'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0					-- 0 no error, <50000 SQL error, else business rule

	begin try

		select
			 irf.RegFormSID
			,irf.RegFormTypeSCD
			,irf.RegFormTypeLabel
			,irf.FormStatusSCD
		from
			dbo.fInvoice#RegForm(@InvoiceSID) irf

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;




GO
