SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChange#GetDefaultDates]
	@RegistrationChangeSID int	-- key of the registration change to preview approval
as
/*********************************************************************************************************************************
Sproc    : Registration Change - Get Default Dates
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns default effective and expiry dates for the registration record
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
The procedure is called from the UI when the user clicks on the "Approve" option on the registration change. The procedure returns
default Effective and Expiry time values which can be updated by the user before calling the #Approve procedure.

This procedure does not make any changes to records.  

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a registration change selected at random.">
    <SQLScript>
      <![CDATA[
declare @registrationChangeSID int;

select top (1)
	@registrationChangeSID = rc.RegistrationChangeSID

from
	dbo.RegistrationChange																										rc
cross apply dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) cs
order by
	newid();

if @@rowcount = 0 or @registrationChangeSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationChange#GetDefaultDates
		@RegistrationChangeSID = @registrationChangeSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
  <Test Name = "RandomNewOrCorrected" IsDefault ="false" Description="Executes the procedure for a NEW or CORRECTED registration change selected at random.">
    <SQLScript>
      <![CDATA[
declare @registrationChangeSID int;

select top (1)
	@registrationChangeSID = rc.RegistrationChangeSID

from
	dbo.RegistrationChange																										rc
cross apply dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) cs
where
	cs.FormStatusSCD = 'NEW' or cs.FormStatusSCD = 'CORRECTED'
order by
	newid();

if @@rowcount = 0 or @registrationChangeSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationChange#GetDefaultDates
		@RegistrationChangeSID = @registrationChangeSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrationChange#GetDefaultDates'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)	-- message text for business rule errors
	 ,@blankParm									varchar(50)			-- name of required parameter left blank
	 ,@registrantSID							int
	 ,@practiceRegisterSectionSID int
	 ,@registrationYearLabel			nvarchar(9)
	 ,@effectiveTime							datetime
	 ,@expiryTime									datetime;

	begin try

-- SQL Prompt formatting off
		if @RegistrationChangeSID is null	set @blankParm = '@RegistrationChangeSID'
-- SQL Prompt formatting on

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		select
			@registrantSID							= rl.RegistrationSID
		 ,@practiceRegisterSectionSID = rc.PracticeRegisterSectionSID
		from
			dbo.RegistrationChange rc
		join
			dbo.Registration	 rl on rc.RegistrationSID = rl.RegistrationSID
		where
			rc.RegistrationChangeSID = @RegistrationChangeSID;

		if @registrantSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrationChange'
			 ,@Arg2 = @RegistrationChangeSID;

			raiserror(@errorText, 18, 1);
		end;

		exec dbo.pRegistration#Insert$GetDefaults
			@RegistrantSID = @registrantSID
		 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
		 ,@EffectiveTime = @effectiveTime output
		 ,@ExpiryTime = @expiryTime output;

		set @registrationYearLabel = dbo.fRegistrationYearLabel(@effectiveTime);

		select
			rc.RegistrationChangeSID
		 ,@registrationYearLabel RegistrationYearLabel
		 ,@effectiveTime				 EffectiveTime
		 ,@expiryTime						 ExpiryTime
		from
			dbo.RegistrationChange rc
		where
			rc.RegistrationChangeSID = @RegistrationChangeSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;

GO
