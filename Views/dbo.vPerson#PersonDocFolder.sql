SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vPerson#PersonDocFolder
as
/*********************************************************************************************************************************
View    : Person - Person Documents (in folders)
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns XML for person entities containing their documents in an item/folder structure
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson | Feb 2017      |	Initial Version
				: Cory Ng			| Jul 2017			|	Add support for learning plan activity documents
				: Tim Edlund	| Aug 2018			| Improved performance by eliminating references to entity views
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the person key and XML that represents their PersonDoc records in an item/folder structure. Items without
context are placed in the "root" folder which will named for the person. Other documents will go in folders based on the
PersonDocContext record(s) related to it. While this view can be called for a number of Person records it is largely intended
to be constrained to a specific PersonSID.

NOTE: Current only RegistrantApp is supported in this view as a context.

NOTE: A document may show up in more than one "folder" if it has multiple context records

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

			declare 
				@PersonSID int
			
			select
				@PersonSID	= x.PersonSID
			from
				sf.Person x
			order by
				newid()
			

			select
				x.*
			from
				dbo.vPerson#PersonDocFolder x
			where
				x.PersonSID = @PersonSID

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[

			select
				x.*
			from
				dbo.vPerson#PersonDocFolder x

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:06:00"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vPerson#PersonDocFolder'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	p.PersonSID
 ,(
		select
			isnull(
							dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRATION')
						 ,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)
						) [@Name]
		 ,dbo.fPersonDoc#RegistrantAppFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#RegistrantCredentialFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#RegistrantAuditFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#RegistrantRenewalFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#RegistrantLearningPlanFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#ProfileUpdateFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#ExamFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#RegistrationChangeFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#ReinstatementFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#ComplaintFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#ConversionFolderXml(p.PersonSID)
		 ,dbo.fPersonDoc#ItemXml(p.PersonSID, null, null)
		for xml path('Folder'), type
	) RootFolder
from
	sf.Person			 p
left outer join
	dbo.Registrant r on p.PersonSID = r.PersonSID;
GO
