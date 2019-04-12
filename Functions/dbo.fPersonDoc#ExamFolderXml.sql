SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#ExamFolderXml]
(
	@PersonSID int -- the id of the person to retrieve documents for
)
returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - Exam Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Apr	2018		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for Exams belonging to the provided person and their related
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
				 ,dbo.fPersonDoc#ExamFolderXml(p.PersonSID) ExamFolderXml
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
					 @applicationUserSID	int
					,@userName						nvarchar(75)
					,@personSID						int
					,@formVersionSID			int
					,@profileUpdateSID		int
					,@formStatusSID				int
					,@responseXML					xml

				begin tran
					
					select top 1
						@personSID = p.PersonSID
					from
						sf.Person p
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

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'

				select 
					p.PersonSID
				 ,p.LastName
				 ,p.FirstName
				 ,dbo.fPersonDoc#ExamFolderXml(p.PersonSID) ExamFolderXml
				from
					sf.Person p
				where
					p.PersonSID = @personSID;

				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonDoc#ExamFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	return ( select
			 e.ExamSID										[@EntitySID]
			,'dbo.Exam'										[@EntitySCD]
			,e.ExamName						  			[@Name]
			,dbo.fPersonDoc#ItemXml(@PersonSID, 'dbo.Exam', e.ExamSID)
		from
			dbo.Exam e
		join
			(
				select distinct
					 re.ExamSID
				from
					dbo.Registrant r
				join
					dbo.RegistrantExam re on r.RegistrantSID = re.RegistrantSID
				where
					r.PersonSID = @PersonSID
			) x on e.ExamSID = x.ExamSID
		for xml path('Folder')
	);

end;
GO
