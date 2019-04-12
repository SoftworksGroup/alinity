SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistration#Culture]
as
/*********************************************************************************************************************************
View    : Registration - Culture
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the display registration columns globalized to the logged in user's culture
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng   	| Jan 2018      |	Initial Version
				: Tim Edlund	| Mar 2018			| Updated to reference RegistrantPersonSID as PersonSID 
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
   @userName                nvarchar(75)
  ,@cultureSID              int
  ,@rowGUID                 uniqueidentifier
  ,@practiceRegisterRowGUID uniqueidentifier

select
  @userName   = au.UserName
 ,@cultureSID = c.CultureSID
from
  sf.VApplicationUserGrant au
join
  sf.Culture c on c.CultureSCD = 'fr-CA'
where
  au.IsActive = cast(1 as bit)
and
  au.ApplicationUserIsActive = cast(1 as bit)
order by
  newid()

select
   @rowGUID = ct.RowGUID 
  ,@practiceRegisterRowGUID = pr.RowGUID
from
  dbo.vRegistration ct
join
  dbo.PracticeRegister pr on ct.PracticeRegisterSID = pr.PracticeRegisterSID
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
   @SourceGUID        = @practiceRegisterRowGUID
  ,@FieldID           = 'PracticeRegisterLabel'
  ,@CultureSID        = @cultureSID
  ,@AltLanguageText   = '**TEST**'

-- test execution

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select
  x.PracticeRegisterLabel
from
  dbo.vRegistration#Culture x
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
			@ObjectName				= 'dbo.vRegistration#Culture'
		,	@DefaultTestOnly	= 1

------------------------------------------------------------------------------------------------------------------------------- */

select
   rl.RegistrationSID
  ,rl.RegistrantSID
  ,rl.RegistrantPersonSID PersonSID
  ,rl.PracticeRegisterSectionSID
	,rl.PracticeRegisterSID
  ,rl.RegistrationNo
  ,rl.RegistrationYear
  ,rl.EffectiveTime
  ,rl.ExpiryTime
	,zit.TotalDue
	,zit.TotalPaid
  ,rl.IsActive
  ,rl.IsPending
	,pr.IsDefault																																								IsApplicantRegister
  ,sf.fAltLanguage#Field(pr.RowGUID, 'PracticeRegisterName', pr.PracticeRegisterName, null)		PracticeRegisterName
  ,sf.fAltLanguage#Field(pr.RowGUID, 'PracticeRegisterLabel', pr.PracticeRegisterLabel, null) PracticeRegisterLabel
  ,rl.RowGUID
from
  dbo.vRegistration rl
join
  dbo.PracticeRegister pr on rl.PracticeRegisterSID = pr.PracticeRegisterSID
outer apply dbo.fInvoice#Total(rl.InvoiceSID) zit

GO
