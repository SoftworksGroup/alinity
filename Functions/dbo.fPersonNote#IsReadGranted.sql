SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#IsReadGranted] (@PersonNoteSID int, @ApplicationGrantSCD varchar(30))
returns bit
as
/*********************************************************************************************************************************
Function	: Person Note - Is Read Granted
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns 1 (ON) when read access to the note is granted to the currently logged in user
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Oct 2017		|	Initial version
					: Tim Edlund					| Apr 2019		| Updated to consider ApplicationGrantSID specified on the PersonNote record

Comments
--------
This function is used to advise the UI and reports whether the existence of a specific note can be exposed to the currently
logged in user.  Generally administrators will have access to all notes and members will have access to notes in their 
note library, however, there are exceptions:

1) If the (dbo)PersonNote record specifies an application grant, then only administrators with that grant will have access to that
note. A grant may be assigned to notes related to "Complaints" for example, in the context of the Alinity application.

2) A member will be restricted from accessing notes where the "Show To Registrant" bit is OFF.

Example
-------
<TestHarness>
	<Test Name="Admin" Description="Admin accessing un-restricted note">
		<SQLScript>
			<![CDATA[

declare
	@userName			 nvarchar(75)
 ,@personNoteSID int;

select top (1)
	@userName = aug.ApplicationUserSID
 ,@userName = aug.UserName
from
	sf.vApplicationUserGrant aug
where
	aug.ApplicationUserIsActive = cast(1 as bit) and sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID) = 1
order by
	newid();

if @@rowcount = 0 or @userName is null or @personNoteSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec sf.pApplicationUser#Authorize
		@UserName = @userName
	 ,@IPAddress = '10.0.0.1';

	-- select a note without a grant assigned
	select top (1)
		@personNoteSID = pn.PersonNoteSID
	from
		dbo.PersonNote pn
	where
		pn.ApplicationGrantSID is null
	order by
		newid();

	select dbo .fPersonNote#IsReadGranted(@personNoteSID) IsReadGranted;
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
	@ObjectName = 'dbo.fPersonNote#IsReadGranted'
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
						dbo.PersonNote			 pn
					join
						sf.ApplicationUser au on pn.PersonSID = au.PersonSID and au.UserName = @applicationUserName
					where
						pn.PersonNoteSID = @PersonNoteSID and pn.ShowToRegistrant = @ON
				)
					set @isReadGranted = @ON;
			end;
		end;
	end;

	return (@isReadGranted);
end;
GO
