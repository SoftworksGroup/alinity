SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantRenewal#GetMissingPDF]
	@RegistrationYear int = null	-- registration year to search by (null for all years)
as
/*********************************************************************************************************************************
Procedure: Registrant Renewal - Get Missing PDF
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns a list of renewals that require PDF generation.
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version (revised from May 2017 version by Cory Ng)

Comments	
--------
This procedure returns all approved renewals where a PDF has not yet been generated.  The procedure is called from the UI
on the management page to enable administrators to invoke the PDF generation process.

Maintenance Note
----------------
The logic in this procedure is replicated in all member-service form types. Any changes to logic in this form must be applied
to other %#GetMissingPDF procedures.

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Returns all approved renewals where a PDF is not yet generated.">
		<SQLScript>
			<![CDATA[

exec dbo.pRegistrantRenewal#GetMissingPDF

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantRenewal#GetMissingPDF'
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo int = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@ON			 bit = cast(1 as bit);	-- constant for bit comparisons = 1

	begin try

		if @RegistrationYear is null set @RegistrationYear = -1;

		select
			cs.RegistrantRenewalSID
		 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'RENEWAL') RegistrantLabel
		from
			dbo.fRegistrantRenewal#CurrentStatus(-1, @RegistrationYear) cs
		join
			dbo.Registration																						reg on cs.RegistrationSID			 = reg.RegistrationSID
		join
			dbo.Registrant																							r on reg.RegistrantSID				 = r.RegistrantSID
		join
			sf.Person																										p on r.PersonSID							 = p.PersonSID
		join
			sf.ApplicationEntity																				ae on ae.ApplicationEntitySCD	 = 'dbo.RegistrantRenewal'
		left outer join
			dbo.PersonDocContext																				pdc on ae.ApplicationEntitySID = pdc.ApplicationEntitySID and cs.RegistrantRenewalSID = pdc.EntitySID and pdc.IsPrimary = @ON
		where
			cs.FormStatusSCD = 'APPROVED' and pdc.PersonDocContextSID is null;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
