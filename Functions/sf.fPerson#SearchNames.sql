SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fPerson#SearchNames
(
	@SearchString			nvarchar(150) -- registrant name, # or email to search for (NOT combined with filters)
 ,@LastName					nvarchar(35)	-- last name (parsed from @SearchString)
 ,@FirstName				nvarchar(30)	-- first name (parsed from @SearchString)
 ,@MiddleNames			nvarchar(30)	-- middle names (parsed from @SearchString)
 ,@IsExtendedSearch bit						-- when 1 directs procedure to search other names and email addresses
)
returns @found table (PersonSID int not null)
/*********************************************************************************************************************************
TableF   : Person - Search Names
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This function returns sf.Person key values for records matching name and other-name criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
				: Cory Ng							| Jan 2019		| Fixed bug where email address search (PersonOtherName record was required previously)
				: Tim Edlund					| Mar 2019		| Updated to search on common-name as well on first-name searches

Comments	
--------
This function is intended to be called as a subroutine of search procedures on sf.Person name columns. It returns a list of 
Person-SID values which are then inserted into a working table in the calling search procedure.  The searches performed
include:
	a search of name parameters against sf.Person name values, 
	a search of name parameters against sf.PersonOtherName name values, and, 
	a search of @SearchString against the sf.PersonEmailAddress table (includes active and previous email addresses). 
	
Note that the last 2 searches in the list above are only performed if the @IsExtendedSearch parameter is passed as ON (1).

The @SearchString parameter must be provided but all other search parameters may be passed as NULL. The @LastName, @FirstName, and 
@MiddleNames values will typically be parsed from the @SearchString by the caller (via the sf.pSearchParam#Check function). The 
search string is required even when name values have been set to support searching by email address.

Known Limitations
-----------------
This function expects the parameters passed in to have been formatted by the sf.pSearchParam#Check procedure.  That procedure handles 
trimming of extraneous spaces and the addition of wildcard characters - such as at the end of the @SearchString.  If that procedure is 
not used to format the search parameters prior to calling this function, expected search results may not be achieved.

No ordering of results is performed within the function. To order by Last Name, First Name - the results must be joined to the 
sf.Person table by the caller.

Example
-------
<TestHarness>
  <Test Name = "Crossover" IsDefault ="true" Description="Executes the function to find a name at random where the middle name
	value must be searched in the first-name column">
    <SQLScript>
      <![CDATA[
declare
	@firstname		nvarchar(30)
 ,@lastname			nvarchar(35)
 ,@searchString nvarchar(150);

declare @selected table 
(
	ID				int identity(1, 1) not null 
 ,EntitySID int not null								
);

select top (1)
	@searchString = p.LastName + N',' + p.FirstName
 ,@firstname		= p.MiddleNames -- cross first and middle names
 ,@lastname			= p.LastName
from
	sf.Person p
where
	p.MiddleNames is not null
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		@selected (EntitySID)
	select 
		x.PersonSID 
	from
	 sf.fPerson#SearchNames(@searchString, @lastName, @firstName, null, 1) x

	select
		@searchString [Search String]
	 ,@lastname			[Last Name]
	 ,@firstname		[First Name];

	select
		p.PersonSID
	 ,p.LastName
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.PrimaryEmailAddress
	from
		@selected	 s
	join
		sf.vPerson p on s.EntitySID = p.PersonSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:0:03"/>
    </Assertions>
  </Test>
  <Test Name = "OtherName"  Description="Executes the function to find a name apearing in the Other-Names table.">
    <SQLScript>
      <![CDATA[
declare
	@firstname		nvarchar(30)
 ,@lastname			nvarchar(35)
 ,@searchString nvarchar(150);

declare @selected table
(
	ID				int identity(1, 1) not null 
 ,EntitySID int not null
);

select top (1)
	@searchString = pon.LastName + N',' + pon.FirstName
 ,@firstname		= pon.firstname	
 ,@lastname			= pon.LastName
from
	sf.PersonOtherName pon 
	where
	pon.MiddleNames is not null
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		@selected (EntitySID)
	select 
		x.PersonSID 
	from
	 sf.fPerson#SearchNames(@searchString, @lastName, @firstName, null, 1) x

	select
		@searchString [Search String]
	 ,@lastname			[Last Name]
	 ,@firstname		[First Name];

	select
		p.PersonSID
	 ,p.LastName
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.PrimaryEmailAddress
	from
		@selected	 s
	join
		sf.vPerson p on s.EntitySID = p.PersonSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:0:03"/>
    </Assertions>
  </Test>
  <Test Name = "PartialLastName"  Description="Executes the function to find based on partial last and first name (not extended search).">
    <SQLScript>
      <![CDATA[
declare
	@firstname		nvarchar(30)
 ,@lastname			nvarchar(35)	= 'car%'
 ,@searchString nvarchar(150) = 'car%';

declare @selected table (ID int identity(1, 1) not null, EntitySID int not null);

if not exists (select 1 from sf .Person p where p.LastName like @lastname)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		@selected (EntitySID)
	select
		x.PersonSID
	from
		sf.fPerson#SearchNames(@searchString, @lastname, @firstname, null, 0) x;

	select
		@searchString [Search String]
	 ,@lastname			[Last Name]
	 ,@firstname		[First Name];

	select
		p.PersonSID
	 ,p.LastName
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.PrimaryEmailAddress
	from
		@selected	 s
	join
		sf.vPerson p on s.EntitySID = p.PersonSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:0:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.fPerson#SearchNames'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON	 bit = cast(1 as bit)		-- constant for bit comparisons = 1

	-- wildcard characters are added to the end of name fields
	-- but not necessarily to the search string so this is done here

	if right(@SearchString, 1) <> '%'
	begin
		set @SearchString += '%';
	end;

	if @IsExtendedSearch = @ON and left(@SearchString, 1) <> '%' -- for extended search add to both sides of term
	begin
		set @SearchString = '%' + @SearchString;
	end;

	if @SearchString is null -- set search string to a value to avoid null scan 
	begin
		set @SearchString = '~'
	end

	-- search sf.Person 

	insert
		@found (PersonSID)
	select
		p.PersonSID
	from
		sf.Person p
	where
		(
			p.LastName like @LastName -- last name must match with last if provided													
			and
			(
				@FirstName is null -- if no first name provided, only needs to match on last name
				or p.FirstName like @FirstName -- or first name is matched
				or isnull(p.CommonName, '!') like @FirstName -- or first matches common (e.g. "Beth" for "Elizabeth")
				or p.FirstName like @MiddleNames -- or first name matches with middle names component
				or isnull(p.MiddleNames, '!') like @MiddleNames -- or middle names match
				or isnull(p.MiddleNames, '!') like @FirstName -- or middle name matches the first name provided
			)
		)
		or (
			@LastName is null -- last name must match with last if provided													
			and
			(
				p.FirstName like @FirstName -- or first name is matched
				or isnull(p.CommonName, '!') like @FirstName -- or first matches common (e.g. "Beth" for "Elizabeth")
				or p.FirstName like @MiddleNames -- or first name matches with middle names component
				or isnull(p.MiddleNames, '!') like @MiddleNames -- or middle names match
				or isnull(p.MiddleNames, '!') like @FirstName -- or middle name matches the first name provided
			)
		)
    or p.LastName like @SearchString -- or last name matches full search string (e.g. "Van Der Hook")
		or p.FirstName like @SearchString	-- or first name matches the search string on its own - e.g. "Tim"
		or isnull(p.CommonName, '!') like @SearchString;	-- or common name matches the search string on its own

	-- if the option to search other names and email addresses is enabled, add to the output table
	-- for additional matches ensuring to avoid creation of duplicate PersonSID values

	if @IsExtendedSearch = @ON
	begin

		insert
			@found (PersonSID)
		select distinct
			pea.PersonSID
		from
			sf.PersonEmailAddress pea
		left outer join
			sf.PersonOtherName		pon on pea.PersonSID = pon.PersonSID
		left outer join
			@found								s on pea.PersonSID	 = s.PersonSID
		where
			s.PersonSID is null -- avoid including person records found previously
			and
			(
				(
					pon.LastName like @LastName -- last name must match with last if provided													
					and
					(
						@FirstName is null -- if no first name provided, only needs to match on last name
						or pon.FirstName like @FirstName -- or first name is matched
						or pon.CommonName like @FirstName -- or first matches common (e.g. "Beth" for "Elizabeth")
						or pon.FirstName like @MiddleNames -- or first name matches with middle names component
						or isnull(pon.MiddleNames, '!') like @MiddleNames -- or middle names match
						or isnull(pon.MiddleNames, '!') like @FirstName -- or middle name matches the first name provided
					)
				) or pon.LastName like @SearchString -- or last name matches full search string (e.g. "Van Der Hook")
				or pon.FirstName like @SearchString -- or first name matches the search string on its own
				or isnull(pon.CommonName, '!') like @SearchString	-- or common name matches the search string on its own
				or pea.EmailAddress like @SearchString -- or email address matches the search string
			);

	end;

	return;
end;
GO
