SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#ActivateHelpdesk]
as
/*********************************************************************************************************************************
Procedure : Application User - Activate helpdesk
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Updates the sysadmin grant for the help desk account to active for 12 hours
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Oct		2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is invoked when a user wants to allow the help desk access to their system. The sys admin grant for
the help desk user will be set to effective for 12 hours; this ensures that if the user forgets to deactivate the help 
desk account that the grant will be expired anyhow.

Example
-------

<TestHarness>
	<Test Name="CanRun" IsDefault="true" Description="Checks if the helpdesk user can be activated.">
		<SQLScript>
			<![CDATA[exec sf.pApplicationUser#ActivateHelpdesk]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
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
		,@applicationUserSID							int
		,@helpEmail												nvarchar(75)
		,@applicationUserGrantSID					int
		,@effectiveTime										datetime
		,@expiryTime											datetime

	begin try

		select
			 @applicationUserGrantSID = aug.ApplicationUserGrantSID
			,@applicationUserSID = aug.ApplicationUserSID
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

		select
			@helpEmail = cast(cp.ActiveParamValue as nvarchar(75))
		from
			sf.vConfigParam cp
		where
			cp.ConfigParamSCD = N'HelpdeskEmail'

		if @helpEmail is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'sf.ConfigParam'
				,@Arg2        = 'HelpdeskEmail'
				
			raiserror(@errorText, 18, 1)

		end

		-- update the grant record

		select
			@effectiveTime = sf.fNow(),
			@expiryTime = dateadd(hour, 24, sf.fNow())

		exec sf.pApplicationUserGrant#Update 
			 @ApplicationUserGrantSID	= @applicationUserGrantSID
			,@EffectiveTime						= @effectiveTime
			,@ExpiryTime							= @expiryTime
		
		-- return the email address for the help desk and the help desk user SID

		select 
			 @helpEmail							HelpEmail
			,@applicationUserSID		ApplicationUserSID

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
		end catch

	return(@errorNo)

end
GO
