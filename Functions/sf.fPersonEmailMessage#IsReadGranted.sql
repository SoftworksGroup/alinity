SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fPersonEmailMessage#IsReadGranted (@PersonEmailMessageSID int, @ApplicationGrantSCD varchar(30))
returns bit
as
/*********************************************************************************************************************************
Function	: Person Email - Is Read Granted
Notice		: Copyright © 2019 Softworks Group Inc.
Summary		: Returns 1 (ON) when read access to the email message is granted to the currently logged in user
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Apr 2019		|	Initial version

Comments
--------
This function is used to advise the UI and reports whether the existence of a specific email message can be exposed to the currently
logged in user.  Generally administrators will have access to all email messages except where the (sf) PersonEmailMessage record 
specifies an application grant that the administrator does not have. A grant may be assigned to email messages related to "Complaints" 
for example, in the context of the Alinity application.

Since email messages are sent to end users, all emails sent to the currently logged in user will be accessible. The function ensures
that access to other emails is not provided.

Example
-------
<TestHarness>
	<Test Name="Admin" Description="Admin accessing un-restricted email message">
		<SQLScript>
			<![CDATA[

declare
	@userName			nvarchar(75)
 ,@personEmailMessageSID int;

select top (1)
	@userName = aug.ApplicationUserSID
 ,@userName = aug.UserName
from
	sf.vApplicationUserGrant aug
where
	aug.ApplicationUserIsActive = cast(1 as bit) and sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID) = 1
order by
	newid();

if @@rowcount = 0 or @userName is null or @personEmailMessageSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec sf.pApplicationUser#Authorize
		@UserName = @userName
	 ,@IPAddress = '10.0.0.1';

	select top (1)
		@personEmailMessageSID = pea.PersonEmailMessageSID
	from
		sf.PersonEmailMessage pea
	where
		pea.ApplicationGrantSID is null
	order by
		newid();

	select sf .fPersonEmailMessage#IsReadGranted(@personEmailMessageSID) IsReadGranted;
end;

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="2"  Row="1" Column="1" Value="True" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fPersonEmailMessage#IsReadGranted'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@ON									 bit					= cast(1 as bit)
	 ,@OFF								 bit					= cast(0 as bit)
	 ,@isReadGranted			 bit					= sf.fIsSysAdmin()												-- return value; when user has access returns as 1 (ON)
	 ,@applicationUserName nvarchar(75) = sf.fApplicationUserSession#UserName();	-- login name of current user

	if @isReadGranted = @OFF
	begin
		if @ApplicationGrantSCD is not null
		begin
			set @isReadGranted = sf.fIsGrantedToUserName(@ApplicationGrantSCD, @applicationUserName);
		end;
		else
		begin
			set @isReadGranted = sf.fIsGrantedToUserName('ADMIN.BASE', @applicationUserName);

			if @isReadGranted = @OFF
			begin
				if exists
				(
					select
						1
					from
						sf.PersonEmailMessage			 pea
					join
						sf.ApplicationUser au on pea.PersonSID = au.PersonSID and au.UserName = @applicationUserName
					where
						pea.PersonEmailMessageSID = @PersonEmailMessageSID 
				)
					set @isReadGranted = @ON;
			end;
		end;
	end;

	return (@isReadGranted);
end;
GO
