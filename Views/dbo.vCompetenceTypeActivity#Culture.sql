SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCompetenceTypeActivity#Culture]
as
/*********************************************************************************************************************************
View    : Competence Type - Culture
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the display competence type columns globalized to the logged in user's culture
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng   	| Jan 2018      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view is used by the client portal UI or forms for displaying the globalized labels and help prompts. If alternate text cannot
be found for the user culture it returns the text set for the default culture (en-CA).

Example
-------
<TestHarness>
<Test Name="AltTextCheck" IsDefault="True" Description="Select a user with a French culture, ensure globalized label is returned">
<SQLScript>
<![CDATA[
declare
   @userName              nvarchar(75)
  ,@cultureSID            int
  ,@rowGUID               uniqueidentifier
  ,@competenceTypeRowGUID uniqueidentifier

select
  @userName   = au.UserName
 ,@cultureSID = c.CultureSID
from
  sf.ApplicationUser au
join
  sf.Culture c on c.CultureSCD = 'fr-CA'
order by
  newid()

select
   @rowGUID = ct.RowGUID 
  ,@competenceTypeRowGUID = ct.CompetenceTypeRowGUID
from
  dbo.vCompetenceTypeActivity ct
order by
  newid()

-- test data prep

begin tran

update
  sf.Culture
set
  IsActive = cast(1 as bit)
where
  CultureSCD = 'fr-CA'

update
  sf.ApplicationUser
set
  CultureSID = @cultureSID
where
  UserName = @userName
  
exec sf.pAltLanguage#Insert
   @SourceGUID        = @competenceTypeRowGUID
  ,@FieldID           = 'CompetenceTypeLabel'
  ,@CultureSID        = @cultureSID
  ,@AltLanguageText   = '**TEST**'

-- test execution

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select
  x.CompetenceTypeLabel
from
  dbo.vCompetenceTypeActivity#Culture x
where
  x.RowGUID = @rowGUID

if @@trancount > 0 rollback

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
  <Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="1" Value="**TEST**" />
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vCompetenceTypeActivity#Culture'

------------------------------------------------------------------------------------------------------------------------------- */

select
   cta.CompetenceTypeActivitySID
  ,cta.CompetenceTypeSID
  ,cta.CompetenceActivitySID
  ,sf.fAltLanguage#Field(ct.RowGUID, 'CompetenceTypeLabel'    , ct.CompetenceTypeLabel, null)     CompetenceTypeLabel
  ,sf.fAltLanguage#Field(ca.RowGUID, 'CompetenceActivityLabel', ca.CompetenceActivityLabel, null) CompetenceActivityLabel
	,sf.fAltLanguage#Field(ca.RowGUID, 'CompetenceActivityName' , ca.CompetenceActivityName, null)  CompetenceActivityName
	,ca.UnitValue
	,cta.EffectiveTime
	,cta.ExpiryTime
	,cta.CompetenceTypeActivityXID
  ,sf.fAltLanguage#Field(ct.RowGUID, 'HelpPrompt', ct.HelpPrompt, null)                           CompetenceTypeHelpPrompt
  ,sf.fAltLanguage#Field(ca.RowGUID, 'HelpPrompt', ca.HelpPrompt, null)                           CompetenceActivityHelpPrompt
  ,sf.fIsActive(cta.EffectiveTime, cta.ExpiryTime)  IsActive
  ,cta.RowGUID
from
  dbo.CompetenceTypeActivity cta
join
  dbo.CompetenceActivity ca on cta.CompetenceActivitySID = ca.CompetenceActivitySID
join
  dbo.CompetenceType ct on cta.CompetenceTypeSID = ct.CompetenceTypeSID
GO
