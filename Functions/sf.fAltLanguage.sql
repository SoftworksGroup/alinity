SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fAltLanguage]
(
	@SourceGUID	 uniqueidentifier -- key (RowGUID) of the source record to lookup
 ,@DefaultText nvarchar(max)		-- text to return if no alternate language text found
)
returns nvarchar(max) -- caller must cast return value to appropriate length
as
/*********************************************************************************************************************************
Sproc		: Alt Language 
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns alternate language text, where defined, for the linking value (source table RowGUID) provided 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function provide alternate calling syntax for the sf.fAltLanguage#Field where no FieldID value is required to lookup the
alternate language text.  Please see sf.fAltLanguage#Field documentation for details.

Example:
--------

<TestHarness>
  <Test Name = "TermLabel" IsDefault ="true" Description="Adds a French test term label override and returns it for a 
	random user and culture (not necessarily French).">
    <SQLScript>
      <![CDATA[

declare
	@rowGUID						uniqueidentifier
 ,@applicationUserSID int
 ,@userName						nvarchar(75)
 ,@cultureSID					int;

select top (1)
	@applicationUserSID = aug.ApplicationUserSID
 ,@userName						= aug.UserName
from
	sf.vApplicationUserGrant aug
where
	aug.ApplicationUserIsActive = cast(1 as bit)
order by
	newid();

exec sf.pApplicationUser#Authorize
	@UserName = @userName
 ,@IPAddress = '10.0.0.1';

select top (1)
	@cultureSID = c.CultureSID -- select a non-default culture key
from
	sf.Culture c
where
	c.IsDefault = 0
order by
	newid();

select top (1)
	@rowGUID = tl.RowGUID -- find a term label without an override for the culture selected
from
	sf.TermLabel	 tl
left outer join
	sf.AltLanguage al on tl.RowGUID = al.SourceGUID and al.CultureSID = @cultureSID
where
	al.AltLanguageSID is null
order by
	newid();

begin transaction	-- the updates will be rolled back after the test

update
	sf.ApplicationUser
set
	CultureSID = @cultureSID -- assign the new culture to the user profile
where
	ApplicationUserSID = @applicationUserSID;

insert -- insert the test override
	sf.AltLanguage
	(
		SourceGUID
	 ,CultureSID
	 ,AltLanguageText
	)
	select
		@rowGUID
		,@cultureSID
		,N'Prétendre que vous êtes français!'

select sf.fAltLanguage(@rowGUID, null) MyTermLabel

rollback

    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	@ObjectName = 'sf.fAltLanguage'

------------------------------------------------------------------------------------------------------------------------------- */
begin
	return (sf.fAltLanguage#Field(@SourceGUID, null, @DefaultText, null));
end;
GO
