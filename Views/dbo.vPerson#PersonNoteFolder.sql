SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPerson#PersonNoteFolder]
as
/*********************************************************************************************************************************
View    : Person - Person Notes (in folders)
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns XML for person entities containing their notes in an item/folder structure
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson | Oct 2017      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the person SID and XML that represents their PersonNote records in an item/folder structure. Items without
context are placed in the "root" folder which will named for the person. Other notes will go in folders based on the
PersonNoteContext record(s) related to it. While this view can be called for a number of Person records it is largely intended
to be constrained to a specific PersonSID.

NOTE: Current only RegistrantRenewal is supported in this view as a context.

NOTE: A note may show up in more than one "folder" if it has multiple context records

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
				dbo.vPerson#PersonNoteFolder x
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
				dbo.vPerson#PersonNoteFolder x

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
  @ObjectName = 'dbo.vPerson#PersonNoteFolder'
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
      ,dbo.fPersonNote#RegistrantRenewalFolderXml(p.PersonSID)
			,dbo.fPersonNote#RegistrantAuditFolderXml(p.PersonSID)
      ,dbo.fPersonNote#RegistrantLearningPlanFolderXml(p.PersonSID)
			,dbo.fPersonNote#ProfileUpdateFolderXml(p.PersonSID)
      ,dbo.fPersonNote#PaymentFolderXml(p.PersonSID)
			,dbo.fPersonNote#RegistrationChangeFolderXml(p.PersonSID)
      ,dbo.fPersonNote#ReinstatementFolderXml(p.PersonSID)
      ,dbo.fPersonNote#ComplaintFolderXml(p.PersonSID)
			,dbo.fPersonNote#ItemXml(p.PersonSID, null, null)
		for xml path ('Folder'), type
	) RootFolder
from
	sf.Person p
left outer join
	dbo.Registrant r	on p.PersonSID = r.PersonSID


GO
