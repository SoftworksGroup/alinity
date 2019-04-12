SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPersonNote#RegistrantAuditFolderXml 
(
	@PersonSID int -- the id of the person to retrieve notes for
)
returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - RegistrantRenewal Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Oct	2017		| Initial version
					: Tim Edlund	| Aug 2018		| Improved performance by eliminating references to entity views

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
					,@paymentTypeSID			int
					,@paymentStatusSID		int
					,@GLAccountCode				int

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
				 ,dbo.fPersonNote#RegistrantAuditFolderXml(p.PersonSID)XML
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
	<Test Name="Single" Description="Return items for a single person">
		<SQLScript>
			<![CDATA[
					
					declare
					 @applicationUserSID				int
					,@userName									nvarchar(75)
					,@personNoteTypeSID					int
					,@personNoteSID							int
					,@formVersionSID						int
					,@registrantSID							int
					,@personSID									int
					,@registrationYear					smallint
					,@auditTypeSID							int
					,@applicationEntitySID			int
					,@RegistrantAuditStatusSID	int
					,@RegistrantAuditSID				int
					,@xml												xml

				begin tran
				
				select  top 1
					@formVersionSID = fv.FormVersionSID
				from
					sf.FormVersion fv
				order by
					newid()

				select top 1
						@registrantSID	= r.RegistrantSID
					,	@personSID			= p.PersonSID
				from
					dbo.Registrant r
				join
					sf.person p on r.PersonSID = p.PersonSID
				order by
				 newid()
				
				select @registrationYear = dbo.fRegistrationYear#Current()

				select
					@auditTypeSID = at.AuditTypeSID
				from
					dbo.AuditType at
				where
					at.AuditTypeLabel = 'Basic'

				select top 1
					@RegistrantAuditStatusSID = ps.RegistrantAuditStatusSID
				from
					dbo.RegistrantAuditStatus ps
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
					ae.ApplicationEntitySCD = 'dbo.RegistrantAudit'

				insert into dbo.RegistrantAudit
				(
						RegistrantSID
					, AuditTypeSID
					, RegistrationYear
					,	FormVersionSID
				)
				select
						@registrantSID
					, @auditTypeSID
					, @registrationYear
					,	@formVersionSID
					--, '<FormResponse/>'
					--, '<AdminComment/>'

				set @RegistrantAuditSID = scope_identity()

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
					,	@RegistrantAuditSID

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
					@xml = dbo.fPersonNote#RegistrantAuditFolderXml(@PersonSID)
				
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
					,	n.t.value('@EntityName', 'varchar(255)') RegistrantAudit
					,	n.t.value('@EntitySCD', 'varchar(100)') [dbo.RegistrantAudit]
				from
					@xml.nodes('Folder/Item/NoteContexts/Context') n(t)

				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantAudit" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="2" Value="Comment" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="3" Value="*** TEST ***" />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="2" Value="Registrant Audit " />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="3" Value="dbo.RegistrantAudit" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPersonNote#RegistrantAuditFolderXml'
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
		 ,dbo.fPersonNote#ItemXml(@PersonSID, 'dbo.RegistrantAudit', ra.RegistrantAuditSID)
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
