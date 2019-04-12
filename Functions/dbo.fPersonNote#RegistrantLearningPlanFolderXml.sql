SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#RegistrantLearningPlanFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve notes for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - RegistrantLearningPlan Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Dec	2017		| Initial version
					: Cory Ng			| Nov 2018		| Return learning plan activities as nested folders

Comments	
--------
This function is used to get 0..* Folder elements for RegistrantLearningPlans belonging to the provided person and their related
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
				 ,dbo.fPersonNote#RegistrantLearningPlanFolderXml(p.PersonSID)XML
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
					 @applicationUserSID							int
					,@userName												nvarchar(75)
					,@personNoteTypeSID								int
					,@personNoteSID										int
					,@formVersionSID									int
					,@registrantSID										int
					,@personSID												int
					,@registrationYear								smallint
					,@statusSID												int
					,@registrantLearningPlanStatusSID	int
					,@applicationEntitySID						int
					,@RegistrantLearningPlanSID				int
					,@xml															xml

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
					@statusSID = fs.FormStatusSID
				from
					sf.FormStatus fs
				where
					fs.FormStatusSCD = 'new'

				select top 1
					@RegistrantLearningPlanStatusSID = ps.RegistrantLearningPlanStatusSID
				from
					dbo.RegistrantLearningPlanStatus ps
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
					ae.ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'

				insert into dbo.RegistrantLearningPlan
				(
						RegistrantSID
					, RegistrationYear
					,	FormVersionSID
				)
				select
						@registrantSID
					, @registrationYear
					,	@formVersionSID
					--, '<FormResponse/>'
					--, '<AdminComment/>'

				set @RegistrantLearningPlanSID = scope_identity()

				insert into RegistrantLearningPlanStatus
				(
						RegistrantLearningPlanSID
					,	FormStatusSID
				)
				select
						@RegistrantLearningPlanSID
					,	@statusSID

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
					,	@RegistrantLearningPlanSID

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
					@xml = dbo.fPersonNote#RegistrantLearningPlanFolderXml(@PersonSID)
				
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
					,	n.t.value('@EntityName', 'varchar(255)') RegistrantLearningPlan
					,	n.t.value('@EntitySCD', 'varchar(100)') [dbo.RegistrantLearningPlan]
				from
					@xml.nodes('Folder/Item/NoteContexts/Context') n(t)

				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback


			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantLearningPlan" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="2" Value="Comment" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="3" Value="*** TEST ***" />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="2" Value="Registrant Learning Plan " />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="3" Value="dbo.RegistrantLearningPlan" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPersonNote#RegistrantLearningPlanFolderXml'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	return ( select
			 rlp.RegistrantLearningPlanSID					[@EntitySID]
			,'dbo.RegistrantLearningPlan'						[@EntitySCD]
			,f.FormLabel + ' (' + rlp.CycleRegistrationYearLabel + ')'  			[@Name]
			,dbo.fPersonNote#LearningPlanActivityFolderXml(rlp.RegistrantLearningPlanSID)
			,dbo.fPersonNote#ItemXml(@PersonSID, 'dbo.RegistrantLearningPlan', rlp.RegistrantLearningPlanSID)
		from
			sf.Person p
		join
			dbo.Registrant r on p.PersonSID = r.PersonSID
		join
			dbo.vRegistrantLearningPlan rlp on r.RegistrantSID = rlp.RegistrantSID
		join
			sf.Form f on rlp.FormSID = f.FormSID
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	);

end;
GO
