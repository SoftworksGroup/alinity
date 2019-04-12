SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#CheckPending
	@RegistrationSID int					-- key of registration to check for pending forms
 ,@FormTypeCode		 varchar(15)	-- must be one of: APPLICATION, RENEWAL, REINSTATEMENT, REGCHANGE
as
/*********************************************************************************************************************************
Sproc    : Reinstatement Check Pending
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure checks for the existence of pending registration forms that should block insert of a new form
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This procedure is called from the registration form #Insert sprocs.  It checks for the existence of another pending (not closed)
form for the same registration. If one is found an error is raised.

This check attempts to prevent the situation where multiple registration change forms are pending on the same registration.
For example, if a Reinstatement form for a given Registration record is created and an administrator comes along to apply also
apply a Registration Change to that same registration while the Reinstatement is open, approval of both forms will not be
possible.  Once the first of the form is approved it will generate a new Registration record.  Now the second form, if approved,
would take precedence over the first approval since it would create a Registration record with a later date. That scenario is
specifically blocked when the attempt is made to approve a form which is associated with an out-of-date registration.  To avoid
these scenarios from being possible, this check blocks the insert until no other forms for the same registration are open.

Example:
--------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a registration record selected at random.">
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

	exec dbo.pRegistration#CheckPending
		@RegistrationSID = @registrationSID
	 ,@FormTypeCode = @formTypeCode;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistration#CheckPending'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo	 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm varchar(50)										-- tracks if any required parameters are not provided
	 ,@formName	 nvarchar(65);									-- name of current form

	begin try

-- SQL Prompt formatting off
		if @RegistrationSID is null	set @blankParm = '@RegistrationSID'
		if @FormTypeCode		is null set @blankParm = '@FormTypeCode';
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

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'fee type code'
			 ,@Arg2 = @FormTypeCode
			 ,@Arg3 = '"APPLICATION", "RENEWAL", "REINSTATEMENT", "REGCHANGE"';

			raiserror(@errorText, 18, 1);
		end;

		-- block insert if another change form is
		-- open for the same registration

		if @RegistrationSID is not null
		begin

			set @errorText = dbo.fRegistration#Pending(@RegistrationSID, @FormTypeCode); -- check is performed within this function

			if @errorText is not null
			begin
				raiserror(@errorText, 16, 1);
			end;

		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
