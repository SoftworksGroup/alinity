SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#ComplaintEventFolderXml]
(
	 @ComplaintSID int																					-- the id of the complaint to retrieve events for
)
returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - ComplaintEvent Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Dec	2018		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for ComplaintEvents belonging to the provided person and their related
notes as nested Item elements.

IsReadGranted is checked, notes where this is 0 are excluded so MAKE SURE your session is set before use.

Example:
--------
<TestHarness>
	<Test Name="All" Description="Return all Items">
		<SQLScript>
			<![CDATA[
					
				declare
					 @applicationUserSID	int
					,@userName						nvarchar(75)

				begin tran
					
				-- Sign in as a random application user with admin grants
				select top(1)
					 @applicationUserSID	= aug.ApplicationUserSID
					,@userName						= aug.UserName
				from
					sf.vApplicationUserGrant aug
				where
					aug.ApplicationUserIsActive = cast(1 as bit)
				and
					sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID)  = 1
				order by
					newid()
				
				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'

				select 
					p.PersonSID
				 ,p.LastName
				 ,p.FirstName
				 ,dbo.fPersonNote#ComplaintEventFolderXml(p.PersonSID) ProfileUpdateFolderXML
				from
					sf.Person p;

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>
		<Test Name="Single" IsDefault="True" Description="Return items for a single complaint">
		<SQLScript>
			<![CDATA[
					
				declare
					 @userName										nvarchar(75)
					,@complaintSID								int
					,@responseXML									xml

					select top 1
							@complaintSID			= c.ComplaintSID
					from
						dbo.Complaint c
					order by
						newid()

				-- Sign in as a random application user with admin grants
				select top(1)
					 @userName						= aug.UserName
				from
					sf.vApplicationUserGrant aug
				where
					aug.ApplicationUserIsActive = cast(1 as bit)
				and
					sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID)  = 1
				order by
					newid()

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'

				select 
				 @responseXML = dbo.fPersonNote#ComplaintEventFolderXml(@complaintSID) 
				
				select @responseXML

				select
						n.t.value('@EntitySID', 'nvarchar(50)')
					,	n.t.value('@EntitySCD', 'nvarchar(50)')
					,	n.t.value('@Name', 'nvarchar(100)')
				from
					@responseXML.nodes('/Folder') n(t)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.ComplaintEvent"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonNote#ComplaintEventFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	return ( select
			 ce.ComplaintEventSID					[@EntitySID]
			,'dbo.ComplaintEvent'					[@EntitySCD]
			,ct.ComplaintTypeLabel + ' - ' + cet.ComplaintEventTypeLabel  			[@Name]
			,dbo.fPersonNote#ItemXml(r.PersonSID, 'dbo.ComplaintEvent', ce.ComplaintEventSID)
		from
			dbo.ComplaintEvent ce
		join
			dbo.Complaint c on ce.ComplaintSID = c.ComplaintSID
		join
			dbo.Registrant r on c.RegistrantSID = r.RegistrantSID
		join
			dbo.ComplaintType ct on c.ComplaintTypeSID = ct.ComplaintTypeSID
		join
			dbo.ComplaintEventType cet on ce.ComplaintEventTypeSID = cet.ComplaintEventTypeSID
		where
			ce.ComplaintSID = @ComplaintSID
		for xml path('Folder')
	);

end;
GO
