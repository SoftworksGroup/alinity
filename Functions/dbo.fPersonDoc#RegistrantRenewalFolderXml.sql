SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#RegistrantRenewalFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve documents for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - RegistrantRenewal Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Jul	2017		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for RegistrantRenewals belonging to the provided person and their related
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
				 ,dbo.fPersonDoc#RegistrantRenewalFolderXml(p.PersonSID) ProfileUpdateFolderXML
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
					,@registrationSID				int
					,@PersonSID										int
					,@formVersionSID							int
					,@RegistrantRenewalSID				int
					,@formStatusSID								int
					,@practiceRegisterSectionSID	int
					,@responseXML									xml
					,@registrationYear						int

				begin tran
					
					select top 1
							@registrationSID	= rl.RegistrationSID
						,	@PersonSID						= p.PersonSID
					from
						dbo.Registration rl
					join
						dbo.Registrant r on r.RegistrantSID = rl.RegistrantSID
					join
						sf.Person p on r.PersonSID = p.PersonSID
					order by
						newid()
				

					
					select top 1
						@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
					from
						dbo.PracticeRegister pr
					join
						dbo.PracticeRegisterSection prs on prs.PracticeRegisterSID =  pr.PracticeRegisterSID
					where
						pr.IsActive = cast(1 as bit)
					and
						prs.IsActive = cast(1 as bit)

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

					select
						@registrationYear = dbo.fRegistrationYear#Current()

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

					insert into dbo.RegistrantRenewal
					(
							RegistrationSID
						,	FormVersionSID
						,	FormResponseDraft
						,	AdminComments
						, PracticeRegisterSectionSID
						,	RegistrationYear
					)
					select
							@registrationSID 
						,	@formVersionSID 
						,	'<FormReseponse/>' 
						, '<AdminComments/>' 
						,	@PracticeRegisterSectionSID 
						,	@registrationYear 

					set @RegistrantRenewalSID = scope_identity()

					insert into dbo.RegistrantRenewalStatus
					(
							RegistrantRenewalSID
						,	FormstatusSID
					)
					select
							@RegistrantRenewalSID
						,	@formStatusSID

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'


				select 
				 @responseXML = dbo.fPersonDoc#RegistrantRenewalFolderXml(@PersonSID) 
				
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
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantRenewal"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonDoc#RegistrantRenewalFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 ra.RegistrantRenewalSID					[@EntitySID]
			,'dbo.RegistrantRenewal'					[@EntitySCD]
			,ra.RegistrantRenewalLabel  			[@Name]
			,dbo.fPersonDoc#ItemXml(@PersonSID, 'dbo.RegistrantRenewal', ra.RegistrantRenewalSID)
		from
			sf.Person p
		join
			dbo.Registrant r on p.PersonSID = r.PersonSID
		join
			dbo.vRegistrantRenewal ra on r.RegistrantSID = ra.RegistrantSID
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	)

end
GO
