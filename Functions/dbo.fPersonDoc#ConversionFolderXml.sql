SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#ConversionFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve documents for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - Conversion Folder XML
Notice		: Copyright © 2019 Softworks Group Inc.
Summary		: returns an XML fragment (0..1 Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Mar 2019		| initial version

Comments	
--------
This function is used to get 0..1 Folder elements for person documents created during conversion. These are special document
contexts that are pointed at the ImportFile entity with a SID of -1.

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
				 ,dbo.fPersonDoc#ConversionFolderXml(p.PersonSID) [xml]
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
</TestHarness>

exec sf.pUnitTest#Execute
			@ObjectName = N'dbo.fPersonDoc#ConversionFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 -1																					[@EntitySID]
			,'sf.ImportFile'														[@EntitySCD]
			,sf.fTermLabel('CONVERSION', 'Conversion')	[@Name]
			,dbo.fPersonDoc#ItemXml(@PersonSID, 'sf.ImportFile', -1)
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'sf.ImportFile'
		for xml path('Folder')
	)

end
GO
