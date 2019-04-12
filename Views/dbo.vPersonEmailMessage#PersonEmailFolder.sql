SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonEmailMessage#PersonEmailFolder]
as
/*********************************************************************************************************************************
View    : Person Email Message (in folders)
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns XML for person entities containing their documents in an item/folder structure
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson | Feb 2017      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the person SID and XML that represents their PersonEmailMessage records in an item/folder structure. 
While this view can be called for a number of Person records it is largely intended to be constrained to a specific PersonSID.

Only person email messages that have been sent will appear in this view.

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
				dbo.vPersonEmailMessage#PersonEmailFolder x
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
				dbo.vPersonEmailMessage#PersonEmailFolder x

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vPersonEmailMessage#PersonEmailFolder'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

select
	 p.PersonSID
	,dbo.fPersonEmailMessage#PersonEmailXml(p.PersonSID) RootFolder
from
	sf.Person p
GO
