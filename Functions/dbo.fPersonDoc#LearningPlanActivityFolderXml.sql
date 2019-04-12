SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#LearningPlanActivityFolderXml]
(
	 @RegistrantLearningPlanSID int																					--the id of the learning plan to receive activities for
)
returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - LearningPlanActivity Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Nov	2018		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for LearningPlanActivities belonging to the provided person and their related
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
				 ,dbo.fPersonDoc#LearningPlanActivityFolderXml(p.PersonSID) ProfileUpdateFolderXML
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
					,@LearningPlanActivitySID					int
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

					insert into dbo.LearningPlanActivity
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
					
					set @LearningPlanActivitySID = scope_identity()

					insert into dbo.LearningPlanActivityStatus
					(
							LearningPlanActivitySID
						,	FormstatusSID
					)
					select
							@LearningPlanActivitySID
						,	@formStatusSID

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'


				select 
				 @responseXML = dbo.fPersonDoc#LearningPlanActivityFolderXml(@PersonSID) 
				
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
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.LearningPlanActivity"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonDoc#LearningPlanActivityFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	return ( select
			 lpa.LearningPlanActivitySID				[@EntitySID]
			,'dbo.LearningPlanActivity'					[@EntitySCD]
			,ct.CompetenceTypeLabel + ' - ' + ca.CompetenceActivityLabel  			[@Name]
			,dbo.fPersonDoc#ItemXml(r.PersonSID, 'dbo.LearningPlanActivity', lpa.LearningPlanActivitySID)
		from
			dbo.RegistrantLearningPlan rlp
		join
			dbo.Registrant r on rlp.RegistrantSID = r.RegistrantSID
		join
			dbo.LearningPlanActivity lpa on rlp.RegistrantLearningPlanSID = lpa.RegistrantLearningPlanSID
		join
			dbo.CompetenceTypeActivity cta on lpa.CompetenceTypeActivitySID = cta.CompetenceTypeActivitySID
		join
			dbo.CompetenceType ct on cta.CompetenceTypeSID = ct.CompetenceTypeSID
		join
			dbo.CompetenceActivity ca on cta.CompetenceActivitySID = ca.CompetenceActivitySID
		where
			rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID
		for xml path('Folder')
	);

end;
GO
