SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#RegistrantRenewalFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve notes for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - RegistrantRenewal Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Oct	2017		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for RegistrantRenewals belonging to the provided person and their related
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
				 ,dbo.fPersonNote#RegistrantRenewalFolderXml(p.PersonSID)XML
				from
					sf.Person p;
				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>
	<Test Name="Single" Description="Return items for a single person">
		<SQLScript>
			<![CDATA[
					
					declare
					 @applicationUserSID					int
					,@userName										nvarchar(75)
					,@personNoteTypeSID						int
					,@personNoteSID								int
					,@formVersionSID							int
					,@registrationSID				int
					,@personSID										int
					,@registrationYear						smallint
					,@PracticeRegisterSectionSID	int
					,@applicationEntitySID				int
					,@RegistrantRenewalStatusSID	int
					,@RegistrantRenewalSID				int
					,@xml													xml

				begin tran
				
				select  top 1
					@formVersionSID = fv.FormVersionSID
				from
					sf.FormVersion fv
				order by
					newid()

				select top 1
						@registrationSID	= rl.RegistrationSID
					,	@personSID			= p.PersonSID
				from
					dbo.Registrant r
				join
					dbo.Registration rl on rl.RegistrantSID = r.RegistrantSID
				join
					sf.person p on r.PersonSID = p.PersonSID
				order by
				 newid()
				
				select @registrationYear = dbo.fRegistrationYear#Current()

				select
					@PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				from
					dbo.PracticeRegister pr
				join
					dbo.PracticeRegisterSection prs on prs.PracticeRegisterSID = pr.PracticeRegisterSID
				where
					pr.PracticeRegisterLabel = 'Active'
				and
					prs.IsDefault = cast(1 as bit)

				select top 1
					@RegistrantRenewalStatusSID = ps.RegistrantRenewalStatusSID
				from
					dbo.RegistrantRenewalStatus ps
				order by
					NEWID()

				select
					@personNoteTypeSID = pnt.PersonNoteTypeSID
				from
					dbo.PersonNoteType pnt
				where
					pnt.PersonNoteTypeLabel = 'Comment'

				select
					@ApplicationEntitySID = ae.ApplicationEntitySID
				from
					sf.ApplicationEntity ae
				where
					ae.ApplicationEntitySCD = 'dbo.RegistrantRenewal'

				insert into dbo.RegistrantRenewal
				(
						RegistrationSID
					, PracticeRegisterSectionSID
					, RegistrationYear
					,	FormVersionSID
				)
				select
						@registrationSID
					, @PracticeRegisterSectionSID
					, @registrationYear
					,	@formVersionSID
					--, '<FormResponse/>'
					--, '<AdminComment/>'

				set @RegistrantRenewalSID = scope_identity()

				insert into dbo.PersonNote
				(
					PersonSID
					,PersonNoteTypeSID
					,NoteContent
				)
				select
						@personSID
					,	@personNoteTypeSID
					,	'*** TEST ***'

				set @personNoteSID = scope_identity()

				insert into dbo.PersonNoteContext
				(
						PersonNoteSID
					,	ApplicationEntitySID
					,	EntitySID
				)
				select
						@personNoteSID
					,	@applicationEntitySID
					,	@RegistrantRenewalSID

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
					@xml = dbo.fPersonNote#RegistrantRenewalFolderXml(@PersonSID)
				
				select @xml

				select
						n.t.value('@EntitySID', 'int') EntitySID
					,	n.t.value('@EntitySCD', 'varchar(255)') EntitySCD
					,	n.t.value('@Name', 'varchar(100)') Name
				from
					@xml.nodes('Folder') n(t)

				select
						n.t.value('@PersonNoteSID', 'int') PersonNoteSID
					,	n.t.value('@NoteType', 'varchar(255)') Comment
					,	n.t.value('@Name', 'varchar(100)') [*** TEST ***]
				from
					@xml.nodes('Folder/Item') n(t)

				select
						n.t.value('@EntitySID', 'int') EntitySID
					,	n.t.value('@EntityName', 'varchar(255)') RegistrantRenewal
					,	n.t.value('@EntitySCD', 'varchar(100)') [dbo.RegistrantRenewal]
				from
					@xml.nodes('Folder/Item/NoteContexts/Context') n(t)

				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantRenewal" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="2" Value="Comment" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="3" Value="*** TEST ***" />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="2" Value="Registrant Renewal " />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="3" Value="dbo.RegistrantRenewal" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPersonNote#RegistrantRenewalFolderXml'
	,@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 ra.RegistrantRenewalSID					[@EntitySID]
			,'dbo.RegistrantRenewal'					[@EntitySCD]
			,ra.RegistrantRenewalLabel  			[@Name]
			,dbo.fPersonNote#ItemXml(@PersonSID, 'dbo.RegistrantRenewal', ra.RegistrantRenewalSID)
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
