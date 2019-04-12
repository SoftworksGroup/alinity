SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#DeactivateHelpdesk]
as
/*********************************************************************************************************************************
Procedure : Application User - Deactivate helpdesk
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Updates the sysadmin grant for the help desk account to be expired
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Oct		2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is invoked when a user wants to revoke help desk access to their system. The sys admin grant for the help desk
user will be set to expire immediately.

Example
-------

<TestHarness>
	<Test Name="CanRun" IsDefault="true" Description="Checks if the helpdesk user can be deactivated.">
		<SQLScript>
			<![CDATA[exec sf.pApplicationUser#DeactivateHelpdesk]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo													int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                  		-- message text (for business rule errors)
		,@applicationUserGrantSID					int
		,@expiryTime											datetime

	begin try

		select
			@applicationUserGrantSID = aug.ApplicationUserGrantSID
		from
			sf.vApplicationUserGrant aug
		where
			aug.UserName = N'admin@helpdesk'
		and
			aug.ApplicationGrantSCD = N'ADMIN.SYSADMIN'

		if @applicationUserGrantSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'sf.ApplicationUser'
				,@Arg2        = 'admin@helpdesk'
				
			raiserror(@errorText, 18, 1)

		end

		select @expiryTime = sf.fNow()

		exec sf.pApplicationUserGrant#Update 
			@ApplicationUserGrantSID = @applicationUserGrantSID,
			@ExpiryTime = @expiryTime

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
		end catch

	return(@errorNo)

end
GO
