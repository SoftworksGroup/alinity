SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPerson#SearchNames
	@SearchString			nvarchar(150)				-- registrant name, # or email to search for (NOT combined with filters)
 ,@LastName					nvarchar(35) = null -- last name (parsed from @SearchString)
 ,@FirstName				nvarchar(30) = null -- first name (parsed from @SearchString)
 ,@MiddleNames			nvarchar(30) = null -- middle names (parsed from @SearchString)
 ,@IsExtendedSearch bit = null					-- when 1 directs procedure to search other names and email addresses
as
/*********************************************************************************************************************************
Sproc    : Person - Search Names
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns sf.Person key values for records matching name and other-name criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This procedure is sproc-style wrapper for the table function: sf.fPerson#SearchNames.  See that function for details.

NOTE: Unlike calling the table function directly, this procedure orders the key values returned alphabetically by
LastName + FirstName

Example
-------
<TestHarness>
  <Test Name = "Crossover" IsDefault ="true" Description="Executes the procedure to find a name at random where the a middle name
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
	exec sf.pPerson#SearchNames
		@SearchString = @searchString
	 ,@LastName = @lastname
	 ,@FirstName = @firstname
	 ,@IsExtendedSearch = 1;

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
  <Test Name = "OtherName"  Description="Executes the procedure to find a name apearing in the Other-Names table.">
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
	exec sf.pPerson#SearchNames
		@SearchString = @searchString
	 ,@LastName = @lastname
	 ,@FirstName = @firstname
	 ,@IsExtendedSearch = 1;

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
	 @ObjectName = 'sf.pPerson#SearchNames'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		select
			f.PersonSID
		from
			sf.fPerson#SearchNames(@SearchString, @LastName, @FirstName, @MiddleNames, @IsExtendedSearch) f
		join
			sf.Person																																											p on f.PersonSID = p.PersonSID
		order by
			p.LastName
		 ,p.FirstName
		 ,p.MiddleNames;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
