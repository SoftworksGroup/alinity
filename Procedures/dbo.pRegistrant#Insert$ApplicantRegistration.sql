SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#Insert$ApplicantRegistration
	@RegistrantSID							int								-- key of registrant to assign to application register
 ,@RegistrationYear						smallint = null		-- year of registration to assign to the new application (defaults to current year)
 ,@PracticeRegisterSectionSID int = null				-- section of applicant register to asssign registrant to (otherwise "default" section)
 ,@RegistrationSID						int = null output -- key of new registration record created or found
as
/*********************************************************************************************************************************
Sproc    : Registrant Insert - Applicant Registration
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure ensures the new registrant has a registration on the Applicant (default) Practice Register
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2019		|	Initial version
				: Tim Edlund					| Mar 2019		| Added @PracticeRegisterSectionSID to support assignment of non-default sections

Comments
--------

This procedure is called from #Insert to ensure the registrant has an active registration on the Applicant practice register. If 
an active registration as an Applicant is not found, one is created.  If a section is passed, it will be assigned to the
registration added; otherwise the default section on the applicant register is used.

This procedure should NOT be called where a LegacyKey value is being passed in on the creation of the Registrant. 

Call as subroutine only (test from parent procedure).
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo	 int					 = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)										-- message text (for business rule errors)
	 ,@ON				 bit					 = cast(1 as bit);	-- constant for bit comparison and assignments

	set @RegistrationSID = null;

	begin try

		if @PracticeRegisterSectionSID is not null
		begin

			if not exists
			(
				select
					1
				from
					dbo.PracticeRegisterSection prs
				join
					dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
				where
					pr.IsDefault = @ON and prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'applicant-section (dbo.PracticeRegisterSection)'
				 ,@Arg2 = @PracticeRegisterSectionSID;

				raiserror(@errorText, 18, 1);

			end;
		end;
		else
		begin

			-- ensure Application register (default) has been configured

			select
				@PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			from
				dbo.PracticeRegisterSection prs
			join
				dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID and pr.IsDefault = @ON and prs.IsDefault = @ON;

			if @PracticeRegisterSectionSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
				 ,@Arg1 = '"Applicant Register"';

				raiserror(@errorText, 17, 1);
			end;

		end;

		-- check for active applicant status; if not found add it

		select
			@RegistrationSID = reg.RegistrationSID
		from
			dbo.Registration reg
		where
			reg.RegistrantSID																		= @RegistrantSID
			and reg.PracticeRegisterSectionSID									= @PracticeRegisterSectionSID
			and sf.fIsActive(reg.EffectiveTime, reg.ExpiryTime) = @ON;

		if isnull(@RegistrationSID, -1) = -1
		begin

			exec dbo.pRegistration#Insert
				@RegistrationSID = @RegistrationSID output
			 ,@RegistrantSID = @RegistrantSID
			 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID
			 ,@RegistrationYear = @RegistrationYear;

		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
