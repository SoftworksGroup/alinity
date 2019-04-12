SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pMemberPortal#GetInvoices
	@PersonSID int	-- key of person to return invoices for
as
/*********************************************************************************************************************************
Procedure	: Member Portal - Get Invoices
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns invoices for display on the Member Portal (for 1 person)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This procedure is an override of the table function dbo.fMemberPortal#Invoices.  See the table function for description of
logic/limitations.

Example
-------
<TestHarness>
	<Test Name = "Random" IsDefault = "true" Description="Calls procedure for a person with at least one non-cancelled
	invoice selected at random.">
		<SQLScript>
			<![CDATA[
declare @personSID int;

select top (1)
	@personSID = i.PersonSID
from
	dbo.Invoice i
where
	i.CancelledTime is null
order by
	newid();

if @@rowcount = 0 or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	
	exec dbo.pMemberPortal#GetInvoices
		@PersonSID = @personSID

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pMemberPortal#GetInvoices'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		select
			--!<ColumnList DataSource="dbo.fMemberPortal#Invoices" Alias="mpi">
			 mpi.InvoiceSID
			,mpi.CreateTime
			,mpi.InvoiceTypeSCD
			,mpi.FormStatusSCD
			,mpi.TotalAfterTax
			,mpi.TotalDue
			,mpi.IsPaid
			,mpi.IsPADPending
			,mpi.RegistrantAppSID
			,mpi.RegistrantRenewalSID
			,mpi.ReinstatementSID
			,mpi.RegistrationChangeSID
			,mpi.RenewalRegistrationYear
		--!</ColumnList>
		from
			dbo.fMemberPortal#Invoices(@PersonSID) mpi;

	end try
	begin catch

		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
