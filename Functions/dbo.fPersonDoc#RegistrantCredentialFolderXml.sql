SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#RegistrantCredentialFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve documents for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - RegistrantCredential Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Feb	2017		| initial version

Comments	
--------
This function is used to get 0..* Folder elements for RegistrantCredentialss belonging to the provided person and their related
documents as nested Item elements.

IsReadGranted is checked, documents where this is 0 are excluded so MAKE SURE your session is set before use.

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
				 ,dbo.fPersonDoc#RegistrantCredentialFolderXml(p.PersonSID) [xml]
				from
					sf.Person p;
				
				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>
		<Test Name="Single" IsDefault="True" Description="Return items for a single person">
		<SQLScript>
			<![CDATA[
					
	
	
	declare
					 @applicationUserSID					int
					,@userName										nvarchar(75)
					,@RegistrantSID								int
					,@PersonSID										int
					,@credentialSID								int
					,@OrgSID											int
					,@RegistrantCredentialSID			int
					,@responseXML									xml

				begin tran
					
					select top 1
							@registrantSID	= r.RegistrantSID
						,	@PersonSID			= p.PersonSID
					from
						dbo.Registrant r
					join
						sf.Person p on r.PersonSID = p.PersonSID
					order by
						newid()

					select top 1
						@credentialSID = c.CredentialSID
					from
						dbo.[Credential] c
					where
						c.CredentialLabel = 'Re-Entry/Refresher'
					
				select top 1
					@orgSID = o.OrgSID
				from
					dbo.Org o
				order by
					newid()

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

					delete from dbo.RegistrantCredential
					where 
							RegistrantSID = @RegistrantSID

					insert into dbo.RegistrantCredential
					(
								RegistrantSID
							,	CredentialSID
							,	OrgSID
							,	ChangeAudit
					)
					select
							@registrantSID
						,	@credentialSID
						,	@OrgSID
						,'** TEST **'

					set @RegistrantCredentialSID = scope_identity()

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'


				select 
				 @responseXML = dbo.fPersonDoc#RegistrantCredentialFolderXml(@PersonSID) 
				
				select @responseXML

				select
						n.t.value('@EntitySID', 'nvarchar(50)')
					,	n.t.value('@EntitySCD', 'nvarchar(50)')
					,	n.t.value('@Name', 'nvarchar(100)')
				from
					@responseXML.nodes('/Folder') n(t)

				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantCredential"/>
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="3" Value="Re-Entry/Refresher" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
			@ObjectName = N'dbo.fPersonDoc#RegistrantCredentialFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 rc.RegistrantCredentialSID			[@EntitySID]
			,'dbo.RegistrantCredential'			[@EntitySCD]
			,cr.CredentialLabel							[@Name]
			,dbo.fPersonDoc#ItemXml(@PersonSID, 'dbo.RegistrantCredential', rc.RegistrantCredentialSID)
		from
			sf.Person p
		join
			dbo.Registrant r on p.PersonSID = r.PersonSID
		join
			dbo.RegistrantCredential rc on r.RegistrantSID = rc.RegistrantSID
		join
			dbo.vCredential cr on rc.CredentialSID = cr.CredentialSID
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	)

end
GO
