SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#GetLastRegistration
	@RegistrantSID int = null -- key of registrant to return registrations for
 ,@PersonSID		 int = null -- alternate parameter - can be passed instead of @RegistrantSID
as
/*********************************************************************************************************************************
Sproc    : Registrant - Get Registration Latest
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns latest registration record for a given registrant that optionally matches additional filter criteria
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This procedure is a wrapper for the dbo.fRegistrant#LastRegistration table function. See the function documentation for
details.

This procedure supports the @PersonSID which can be used as an alternative to passing the @RegistrantSID.  The parameter is
used only to resolve to a registrant SID so an error results if no registrant key exists for the given Person key.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Selects latest registration for a registrant at random.">
    <SQLScript>
      <![CDATA[
declare @RegistrantSID int

select top (1)
	@RegistrantSID = rl.RegistrantSID
from
	dbo.Registration rl
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end
else
begin

	exec dbo.pRegistrant#GetLastRegistration
		@RegistrantSID = @RegistrantSID

end
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrant#GetLastRegistration'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000);	-- message text for business rule errors

	begin try

		-- check parameters

		if @RegistrantSID is null and @PersonSID is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@RegistrantSID/@PersonSID';

			raiserror(@errorText, 18, 1);
		end;

		if @RegistrantSID is null
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID;

			if @RegistrantSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.Person'
				 ,@Arg2 = @PersonSID;

				raiserror(@errorText, 18, 1);
			end;

		end;

		select
			--!<ColumnList DataSource="fRegistrant#LastRegistration" Alias="r">
			 r.RegistrantSID
			,r.RegistrantNo
			,r.RegistrationSID
			,r.RegistrationNo
			,r.EffectiveTime
			,r.ExpiryTime
			,r.IsActive
			,r.PracticeRegisterSID
			,r.PracticeRegisterName
			,r.PracticeRegisterLabel
			,r.Description
			,r.IsActivePractice
			,r.IsApplicantRegister
			,r.PracticeRegisterSectionSID
			,r.IsSectionDisplayedOnLicense
			,r.PracticeRegisterSectionLabel
			,r.RegistrantAppSID
			,r.ApplicationRowGUID
			,r.ApplicationFormSID
			,r.ApplicationStatusSCD
			,r.RegistrantRenewalSID
			,r.RenewalRowGUID
			,r.RenewalFormSID
			,r.RenewalStatusSCD
			,r.ReinstatementSID
			,r.ReinstatementRowGUID
			,r.ReinstatementFormSID
			,r.ReinstatementStatusSCD
			,r.RegistrationChangeSID
			,r.RegistrationChangeRowGUID
			,r.RegistrationChangeStatusSCD
			,r.IsApplicationEnabled
			,r.IsRenewalEnabled
			,r.IsReinstatementEnabled
		--!</ColumnList>
		from
			dbo.fRegistrant#LastRegistration(@RegistrantSID) r;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
