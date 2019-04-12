SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vFormListItem#Culture]
as
/*********************************************************************************************************************************
View    : Form List Item - Culture
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the display form list item columns globalized to the logged in user's culture
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
   @userName    nvarchar(75)
  ,@cultureSID  int
  ,@rowGUID     uniqueidentifier

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
from
  sf.FormListItem ct
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
   @SourceGUID        = @rowGUID
  ,@FieldID           = 'FormListItemLabel'
  ,@CultureSID        = @cultureSID
  ,@AltLanguageText   = '**TEST**'

-- test execution

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select
  x.FormListItemLabel
from
  sf.vFormListItem#Culture x
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
	@ObjectName = 'sf.vFormListItem#Culture'

------------------------------------------------------------------------------------------------------------------------------- */

select
   fli.FormListItemSID
  ,fli.FormListItemCode
  ,sf.fAltLanguage#Field(fli.RowGUID, 'FormListItemLabel', fli.FormListItemLabel, null) FormListItemLabel
  ,fli.FormListItemSequence
  ,sf.fAltLanguage#Field(fli.RowGUID, 'ToolTip', fli.ToolTip, null)                     ToolTip
  ,fli.FormListItemXID
  ,fli.RowGUID
from
  sf.FormListItem fli
GO
