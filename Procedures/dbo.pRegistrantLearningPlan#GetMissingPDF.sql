SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#GetMissingPDF]
	@RegistrationYear int = null																						-- registration year to search by (nullable)
as
/*********************************************************************************************************************************
Sproc    : Registrant Learning Plan - Get Missing PDFs
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns the SIDs of all learning plans that require PDF generation.
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Cory Ng  				| Dec 2017 	 | Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure returns all learning plans where it is missing a PDF. This is used in the UI in determining which approved learning 
plans require PDF generation. 

Maintenance Note
----------------
The logic in this sproc is copied from dbo.fRegistrantLearningPlan#Search, if the logic changes here it must be updated in the other 
function as well.

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Returns all approved renewals missing a pdf.">
		<SQLScript>
			<![CDATA[

exec dbo.pRegistrantLearningPlan#GetMissingPDF

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantLearningPlan#GetMissingPDF'

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo	 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm varchar(50)										-- tracks name of any required parameter not passed
	 ,@ON				 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@i				 int														-- loop iteration counter
	 ,@maxrow		 int;														-- loop limit

	begin try

		select
       rr.RegistrantLearningPlanSID
      ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'LEARNINGPLAN') RegistrantLabel
    from
      dbo.RegistrantLearningPlan  rr
    join
      dbo.Registrant         r on rr.RegistrantSID = r.RegistrantSID
    join
      sf.Person              p on r.PersonSID = p.PersonSID
    join
	    sf.ApplicationEntity	 ae on ae.ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'
    left outer join
		    dbo.PersonDocContext pdc on ae.ApplicationEntitySID = pdc.ApplicationEntitySID
																	    and rr.RegistrantLearningPlanSID = pdc.EntitySID
																	    and pdc.IsPrimary = cast(1 as bit)
		cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rr.RegistrantLearningPlanSID) rrcs
    where
      rr.RegistrationYear = isnull(@RegistrationYear, rr.RegistrationYear)
    and
      rrcs.FormStatusSCD = 'APPROVED' 
    and 
      pdc.PersonDocContextSID is null;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
