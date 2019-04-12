SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPersonDoc#IsReadGranted (@PersonDocSID int, @ApplicationGrantSCD varchar(30))
returns bit
as
/*********************************************************************************************************************************
Function	: Person Doc - Is Read Granted
Notice		: Copyright © 2015 Softworks Group Inc.
Summary		: Returns 1 (ON) when read access to the document is granted to the currently logged in user
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Aug 2015		|	Initial version
					: Cory Ng							| Jun 2016		| Updated to used framework function to check if users have access
					: Kris Dawson					| Feb 2017		| Updated for 'ShowToRegistrant' and cleaned up the query
					: Tim Edlund					| Apr 2019		| Updated to consider ApplicationGrantSID specified on the PersonDoc record

Comments
--------
This function is used to advise the UI and reports whether the existence of a specific document can be exposed to the currently
logged in user.  Generally administrators will have access to all documents and members will have access to documents in their 
document library, however, there are exceptions:

1) If the (dbo)PersonDoc record specifies an application grant, then only administrators with that grant will have access to that
document. A grant may be assigned to documents related to "Complaints" for example, in the context of the Alinity application.

2) A member will be restricted from accessing documents where the "Show To Registrant" bit is OFF.

Example
-------
<TestHarness>
	<Test Name="Admin" Description="Admin accessing un-restricted document">
		<SQLScript>
			<![CDATA[

declare
	@userName			nvarchar(75)
 ,@personDocSID int;

select top (1)
	@userName = aug.ApplicationUserSID
 ,@userName = aug.UserName
from
	sf.vApplicationUserGrant aug
where
	aug.ApplicationUserIsActive = cast(1 as bit) and sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID) = 1
order by
	newid();

if @@rowcount = 0 or @userName is null or @personDocSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec sf.pApplicationUser#Authorize
		@UserName = @userName
	 ,@IPAddress = '10.0.0.1';

	-- select a document without a grant assigned
	select top (1)
		@personDocSID = pd.PersonDocSID
	from
		dbo.PersonDoc pd
	where
		pd.ApplicationGrantSID is null
	order by
		newid();

	select dbo .fPersonDoc#IsReadGranted(@personDocSID) IsReadGranted;
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
	@ObjectName = 'dbo.fPersonDoc#IsReadGranted'
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
						dbo.PersonDoc			 pd
					join
						sf.ApplicationUser au on pd.PersonSID = au.PersonSID and au.UserName = @applicationUserName
					where
						pd.PersonDocSID = @PersonDocSID and pd.ShowToRegistrant = @ON
				)
					set @isReadGranted = @ON;
			end;
		end;
	end;

	return (@isReadGranted);
end;
GO
