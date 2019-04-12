SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#RegistrantLearningPlanFolderXml]
(
	@PersonSID int -- the id of the person to retrieve documents for
)
returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - RegistrantLearningPlan Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Jul	2017		| Initial version
					: Tim Edlund	| Nov 2017		| Updated for model updates - replacement of Learning Plan Item with Learning Plan Activity 
																				and introduction of Competence Type Activity to change normalization of activity items.
					: Cory Ng			| Dec 2017		| Change the document parent to learning plan instead of activity as part of re-modelling
					: Cory Ng			| Nov 2018		| Return learning plan activities as nested folders

Comments	
--------
This function is used to get 0..* Folder elements for RegistrantLearningPlans belonging to the provided person and their related
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
				 ,dbo.fPersonDoc#RegistrantLearningPlanFolderXml(p.PersonSID) ProfileUpdateFolderXML
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
					,@formVersionSID							int
					,@RegistrantLearningPlanSID					int
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

					insert into dbo.RegistrantLearningPlan
					(
							RegistrantSID
						,	FormVersionSID
						,	FormResponseDraft
						,	AdminComments
					)
					select
							@registrantSID
						,	@formVersionSID
						,	'<FormReseponse/>'
						, '<AdminComments/>'
					
					set @RegistrantLearningPlanSID = scope_identity()

					insert into dbo.RegistrantLearningPlanStatus
					(
							RegistrantLearningPlanSID
						,	FormstatusSID
					)
					select
							@RegistrantLearningPlanSID
						,	@formStatusSID

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'


				select 
				 @responseXML = dbo.fPersonDoc#RegistrantLearningPlanFolderXml(@PersonSID) 
				
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
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.RegistrantLearningPlan"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonDoc#RegistrantLearningPlanFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	return ( select
			 rlp.RegistrantLearningPlanSID					[@EntitySID]
			,'dbo.RegistrantLearningPlan'						[@EntitySCD]
			,f.FormLabel + ' (' + rlp.CycleRegistrationYearLabel + ')'  			[@Name]
			,dbo.fPersonDoc#LearningPlanActivityFolderXml(rlp.RegistrantLearningPlanSID)
			,dbo.fPersonDoc#ItemXml(@PersonSID, 'dbo.RegistrantLearningPlan', rlp.RegistrantLearningPlanSID)
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
