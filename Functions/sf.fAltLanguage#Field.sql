SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fAltLanguage#Field]
(
  @SourceGUID						uniqueidentifier	-- key (RowGUID) of the source record to lookup
 ,@FieldID							varchar(128)			-- identifier of the field for which language text is required
 ,@DefaultText					nvarchar(max)			-- text to return if no alternate language text found
 ,@ApplicationUserSID		int								-- user to look up the language for (selects logged in user if null)
)
returns nvarchar(max) -- caller must cast return value to appropriate length
as
/*********************************************************************************************************************************
Sproc		: Alt Language 
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns alternate language text, where defined, for the linking value (source table RowGUID) and FieldID (optional) 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This is a utility function to lookup alternate language text in the sf.AltLanguage table.  It is called from procedures such as
pMessage#Get and pTermLabel#Get (without @FieldID) and by front-end components (usually with @FieldID).  The function is used to
override the default text that would otherwise be displayed and return a version of the text in the language matching the culture 
of the logged in user.

Default text stored in the main database tables such as sf.Message, sf.TermLabel and application specific tables in DBO is 
expected to be in the default language for the application - typically English.  If other languages need to be supported
internally then text must be entered into the sf.AltLanguage table which this function will return when it detects that the 
user does not have their profile using the default "culture". The culture is obtained from the CultureSID column of the
sf.ApplicationUser table.

The lookup for the alternate language is carried out based on the @SourceGUID passed in, and a @FieldID (if provided) along with
the culture key (reference to sf.Culture) of the logged in user as stored in their sf.ApplicationUser table.  The Source-GUID value 
is a RowGUID on the table where default text was obtained - e.g. sf.Message.  @SourceGUID and @CultureSID are always required but
@FieldID is optional.  If a record only has one value for which alternate text is relevant, then no FieldID for it needs to be 
stored on its sf.AltLanguage record.

If alternate text is found it is returned but otherwise the default text (previously found by the caller) is returned instead.

sf.fAltLanguage
---------------
Note that if a Field Identifier is not required for the lookup an alternate form of the function is provided which requires only the
SourceGUID, CultureSID and DefaultText.  That function calls this version passing NULL as @FieldID.  The alternate call syntax
is provided for convenience.

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
	 ,FieldID
	 ,AltLanguageText
	)
	select
		@rowGUID
		,@cultureSID
		,'MyFieldID'
		,N'Prétendre que vous êtes français!'

select sf.fAltLanguage(@rowGUID, 'MyFieldID', 'Some default text') MyTermLabel

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
	@ObjectName = 'sf.fAltLanguage#Field'
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@altLanguage				nvarchar(max)									-- return value
	 ,@OFF								bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@cultureSID					int;													-- key of the language record (sf.Culture) to lookup

	if @ApplicationUserSID is null											-- select logged in user if not passed
	begin
		set @ApplicationUserSID = sf.fApplicationUserSessionUserSID();
	end

	select
		@cultureSID = au.CultureSID
	from
		sf.ApplicationUser au
	join
		sf.Culture				 c on au.CultureSID = c.CultureSID
	where
		au.ApplicationUserSID = @ApplicationUserSID and c.IsDefault = @OFF;

	if @cultureSID is not null -- alternate lookup is not performed unless user has non-default culture applied
	begin

		select
			@altLanguage = al.AltLanguageText
		from
			sf.AltLanguage al
		where
			al.SourceGUID = @SourceGUID and al.CultureSID = @cultureSID and isnull(al.FieldID, '~') = isnull(@FieldID, '~');

	end;

	return (isnull(@altLanguage, @DefaultText));

end;
GO
