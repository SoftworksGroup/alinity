SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#RegistrantAuditFolderXml]
(
@PersonSID int -- the id of the person to retrieve documents for
)
returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - RegistrantAudit Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| May	2017		| initial version
					: Tim Edlund	| Aug 2018		| Improved performance by eliminating references to entity views

Comments	
--------
This function is used to get 0..* Folder elements for RegistrantAudits belonging to the provided person and their related
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
				 ,dbo.fPersonDoc#RegistrantAppFolderXml(p.PersonSID) ProfileUpdateFolderXML
				from
					sf.Person p;
				
				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ExecutionTime" Value="00:03:30"/>
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
					,@formVersionSID							int
					,@RegistrantAuditSID					int
					,@AuditTypeSID								int
					,@formStatusSID								int
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
						@AuditTypeSID = at.AuditTypeSID
					from
						dbo.AuditType at
					order by
						newid()

					select top 1
						@formVersionSID = fv.FormVersionSID
					from
						sf.FormVersion fv
					order by
						newid()
					
					select
						@formStatusSID = fs.FormStatusSID
					from
						sf.FormStatus fs
					where
						fs.FormStatusSCD = 'New'

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

					insert into dbo.RegistrantAudit
					(
							RegistrantSID
						,	FormVersionSID
						,	FormResponseDraft
						,	AdminComments
						,	AuditTypeSID
					)
					select
							@registrantSID
						,	@formVersionSID
						,	'<FormReseponse/>'
						, '<AdminComments/>'
						,	@AuditTypeSID
					
					set @RegistrantAuditSID = scope_identity()

					insert into dbo.RegistrantAuditStatus
					(
							RegistrantAuditSID
						,	FormstatusSID
					)
					select
							@RegistrantAuditSID
						,	@formStatusSID

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'


				select 
				 @responseXML = dbo.fPersonDoc#RegistrantAuditFolderXml(@PersonSID) 
				
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
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantAudit"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
		 @ObjectName = N'dbo.fPersonDoc#RegistrantAuditFolderXml'
		,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	return
	(
		select
			ra.RegistrantAuditSID												 [@EntitySID]
		 ,'dbo.RegistrantAudit'												 [@EntitySCD]
		 ,atype.AuditTypeLabel + N' - ' + case when cs.IsFinal = cast(0 as bit) then 'In Progress' else cs.FormStatusLabel end + ' ('
			+ cast(ra.RegistrationYear as char(4)) + ')' [@Name]
		 ,dbo.fPersonDoc#ItemXml(@PersonSID, 'dbo.RegistrantAudit', ra.RegistrantAuditSID)
		from
			sf.Person																												p
		join
			dbo.Registrant																									r on p.PersonSID = r.PersonSID
		join
			dbo.RegistrantAudit																							ra on r.RegistrantSID = ra.RegistrantSID
		join
			dbo.AuditType																										atype on ra.AuditTypeSID = atype.AuditTypeSID
		cross apply dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) cs
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	);

end;
GO
