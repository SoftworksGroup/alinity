SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [sf].[trApplicationUser#DefaultAuthenticationID]
on [sf].[ApplicationUser]
after insert
as
/*********************************************************************************************************************************
Table   : sf.ApplicationUser (after INSERT trigger)
Notice  : Copyright © 2014 Softworks Group Inc.
Summary : Updates the AuthenticationID column value with the RowGUID where no value was provided

Comments
--------
This trigger ensures that when the AuthenticationSystemID column begins with "[!", that it receives the value of the RowGUID
column.  

The AuthenticationSystemID column receives a GUID, or similar identifier, when a federated login system like MS Account or Google
Account is used. This identifies the user in a more permanent way since it is possible for the email captured in the UserName 
column to change over time.  The value can be passed in to sf.pApplicationUser#Authorize during the startup process to find
the user account instead of using the email address stored in the UserName.  Where no federated provider is used (direct email 
login) the AuthenticationSystemID column is set to the same value as the RowGUID (by this trigger).

Note - no test harness has been added to this trigger intentionally as it is tested automatically by the setup process.

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                             int = 0													-- 0 no error, <50000 SQL error, else business rule
		,@errorText                           nvarchar(4000)									-- message text (for business rule errors)
		,@ON																	bit = cast(1 as bit)						-- constant to avoid multiple casts
		,@OFF																	bit = cast(0 as bit)						-- constant to avoid multiple casts

	begin try

		update
			au
		set
			au.AuthenticationSystemID = cast(au.RowGUID as nvarchar(50))
		from
			inserted						i 
		join
			sf.ApplicationUser au on i.ApplicationUserSID = i.ApplicationUserSID
		and
			left(i.AuthenticationSystemID, 2) = N'[!'

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

end
GO
