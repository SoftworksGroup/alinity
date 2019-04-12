SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#ReinstatementFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve notes for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - Reinstatement Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| May 2018		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for Reinstatements belonging to the provided person and their related
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
				 ,dbo.fPersonNote#ReinstatementFolderXml(p.PersonSID)XML
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
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPersonNote#ReinstatementFolderXml'
	,@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 ra.ReinstatementSID					[@EntitySID]
			,'dbo.Reinstatement'					[@EntitySCD]
			,ra.ReinstatementLabel  			[@Name]
			,dbo.fPersonNote#ItemXml(@PersonSID, 'dbo.Reinstatement', ra.ReinstatementSID)
		from
			sf.Person p
		join
			dbo.Registrant r on p.PersonSID = r.PersonSID
		join
			dbo.vReinstatement ra on r.RegistrantSID = ra.RegistrantSID
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	)

end
GO
