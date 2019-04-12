SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#Pending
(
	@RegistrationSID int					-- key of registration to check for pending forms
 ,@FormTypeCode		 varchar(15)	-- must be one of: APPLICATION, RENEWAL, REINSTATEMENT, REGCHANGE
)
returns nvarchar(250)
as
/*********************************************************************************************************************************
Sproc    : Reinstatement Check Pending
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure checks for the existence of pending registration forms that should block insert of a new form
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
This function returns an error message or a null text value.  The function is called from dbo.pRegistration#CheckPending
and also from dbo.pRegistrationChange#SetNew.  It attempts to prevent the situation where multiple registration change forms are 
pending on the same registration. For example, if a Reinstatement form for a given Registration record is created and an 
administrator comes along to apply also apply a Registration Change to that same registration while the Reinstatement is open, 
approval of both forms will not be possible.  Once the first of the form is approved it will generate a new Registration record.  
Now the second form, if approved, would take precedence over the first approval since it would create a Registration record with a 
later date. That scenario is specifically blocked when the attempt is made to approve a form which is associated with an 
out-of-date registration.  To avoid these scenarios from being possible, this check searches for and returns error text when
any of the problem scenarios is detected. 

Example:
--------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the function for a registration record selected at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrationSID int
 ,@formTypeCode		 varchar(15) = 'REGCHANGE';

select top (1)
	@registrationSID = x.RegistrationSID
from
	dbo.fRegistrant#LatestRegistration$SID(-1, null) x
order by
	newid();

if @@rowcount = 0 or @registrationSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select 
		 @registrationSID RegistrationSID
		,dbo.fRegistration#Pending(@registrationSID, @formTypeCode) PendingMessage

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistration#Pending'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@errorText nvarchar(4000)									-- message text - returned to caller if any
	 ,@OFF			 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@formName	 nvarchar(65);									-- name of current form

	-- validate type code passed and set form
	-- name for message

	if @FormTypeCode = 'APPLICATION'
	begin
		set @formName = N'application';
	end;
	else if @FormTypeCode = 'RENEWAL'
	begin
		set @formName = N'renewal';
	end;
	else if @FormTypeCode = 'REINSTATEMENT'
	begin
		set @formName = N'reinstatement';
	end;
	else if @FormTypeCode = 'REGCHANGE'
	begin
		set @formName = N'registration-change';
	end;
	else
	begin
		set @errorText =
			N'*** PROGRAM ERROR *** An invalid form-type-code "' + isnull(@FormTypeCode, '<NULL>') + N'" was provided to the function ' + object_name(@@procid);
	end;

	-- check for an open registration form for the 
	-- given registration record key

	if @RegistrationSID is not null and @errorText is null
	begin

		if @FormTypeCode <> 'REGCHANGE' and @errorText is null
		begin

			if exists
			(
				select
					1
				from
					dbo.RegistrationChange																									 x
				cross apply dbo.fRegistrationChange#CurrentStatus(x.RegistrationChangeSID, -1) cs
				where
					x.RegistrationSID = @RegistrationSID and cs.IsFinal = @OFF
			)
			begin

				set @errorText = N'The %1 cannot be created because a %2 form is pending for this registration. Withdraw/cancel the %2 before attempting to create the %1.';

				select 
					@errorText = isnull(m.MessageText, @errorText)	-- if override text exists use it, otherwise default	
				from
					sf.Message m
				where
					m.MessageSCD = 'RegistrationFormPending';

				set @errorText = replace(replace(@errorText, '%1', @formName), '%2', 'registration change');

			end;

		end;

		if @FormTypeCode <> 'RENEWAL' and @errorText is null
		begin

			if exists
			(
				select
					1
				from
					dbo.RegistrantRenewal																										x
				cross apply dbo.fRegistrantRenewal#CurrentStatus(x.RegistrantRenewalSID, -1) cs
				where
					x.RegistrationSID = @RegistrationSID and cs.IsFinal = @OFF
			)
			begin

				set @errorText = N'The %1 cannot be created because a %2 form is pending for this registration. Withdraw/cancel the %2 before attempting to create the %1.';

				select 
					@errorText = isnull(m.MessageText, @errorText)	-- if override text exists use it, otherwise default	
				from
					sf.Message m
				where
					m.MessageSCD = 'RegistrationFormPending';

				set @errorText = replace(replace(@errorText, '%1', @formName), '%2', 'renewal');
			end;

		end;

		if @FormTypeCode <> 'REINSTATEMENT' and @errorText is null
		begin

			if exists
			(
				select
					1
				from
					dbo.Reinstatement																							 x
				cross apply dbo.fReinstatement#CurrentStatus(x.ReinstatementSID, -1) cs
				where
					x.RegistrationSID = @RegistrationSID and cs.IsFinal = @OFF
			)
			begin

				set @errorText = N'The %1 cannot be created because a %2 form is pending for this registration. Withdraw/cancel the %2 before attempting to create the %1.';

				select 
					@errorText = isnull(m.MessageText, @errorText)	-- if override text exists use it, otherwise default	
				from
					sf.Message m
				where
					m.MessageSCD = 'RegistrationFormPending';

				set @errorText = replace(replace(@errorText, '%1', @formName), '%2', 'reinstatement');

			end;

		end;

		if @FormTypeCode <> 'APPLICATION' and @errorText is null
		begin

			if exists
			(
				select
					1
				from
					dbo.RegistrantApp																							 x
				outer apply dbo.fRegistrantApp#CurrentStatus(x.RegistrantAppSID, -1) cs
				where
					x.RegistrationSID = @RegistrationSID and cs.IsFinal = @OFF
			)
			begin

				set @errorText = N'The %1 cannot be created because a %2 form is pending for this registration. Withdraw/cancel the %2 before attempting to create the %1.';

				select 
					@errorText = isnull(m.MessageText, @errorText)	-- if override text exists use it, otherwise default	
				from
					sf.Message m
				where
					m.MessageSCD = 'RegistrationFormPending';

				set @errorText = replace(replace(@errorText, '%1', @formName), '%2', 'application');

			end;

		end;

	end;

	return (left(@errorText, 250));

end;
GO
