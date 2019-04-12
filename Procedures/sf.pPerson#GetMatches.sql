SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPerson#GetMatches]
	 @FirstName							nvarchar(30)									-- required - some matches will use first letter only
	,@LastName							nvarchar(35)									-- required - "like" search performed
	,@MiddleNames						nvarchar(30)	= null					-- not used for searching but impacts ordering of results if matched
	,@GenderSCD							char(1)				=	null					-- to limit results to a specific gender - ignored if not provided
	,@PrimaryEmailAddress		varchar(150)	=	null					-- primary email address matches supported
	,@HomePhone							varchar(25)		=	null					-- partial phone number matches supported
	,@MobilePhone						varchar(25)		= null					-- partial phone number matches supported
	,@BirthDate							date					= null					-- comparison occurs on the year of birth only	
	,@MatchCount						int						= null output		-- rows returned
as
/*********************************************************************************************************************************
Procedure : Person - Get Matches
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Returns list of sf.Persons which match or partially match criteria entered to establish a new child entity
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)   | Month Year   | Change Summary
				 : ------------|--------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund	 | Jun	2012    | Initial version
				 : Tim Edlund	 | Nov	2012		| Added output parameter.  Updated documentation and code formatting.
				 : Tim Edlund	 | Jan	2014		| Added the ApplicationUserSID to the returned data set to support branching in wizard UI's
				 : Cory Ng		 | Sep	2016		| Allow matching of the person's email address
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure supports wizard-styled UI's where the user has entered values required to establish a new Person or "Person Type"
record. The routine is typically called by a p[EntityName]#GetPersonMatches procedure in the DBO schema.  It assists the user
in avoiding the creation of a duplicate record. Parameter values passed to the procedure are searched in the sf.Person table
and matches and approximate matches are returned to the caller (the UI).  In the UI the user may choose to apply a Person record 
found as a new Person or "Person Type" record, or, if the Person is already a record of the Person Type desired, the operation 
is canceled.

When no rows are returned by this procedure then the values entered are unique and a new Person record needs to be created.

This procedure searches Person but the caller is actually supporting a wizard that is designed to add a child entity of sf.Person.
Examples may include:  Application User, Patients, Providers, Registrants, Contacts, etc.  Softworks database designs use a 
common Person record stored in the framework as a basis for other Person Type entities. The attributes of the sf.Person record are 
inherited by the child entity. In the DBO schema a view called dbo.vPerson#Types is typically implemented in order for the UI
to be able to tell which types the Person row returned is.

This procedure is very tightly coupled with "p[EntityName]#GetPersonMatches" procedures in the main application schemas. If the 
structure of results returned from this routine changes, other procedures in the main application will require updating.  Be
sure to advise other teams about any updates before deploying!!

This routine considers a wide range of name matches and partial matches when returning potential duplicates. SOUNDEX and phone 
number searches are also included in the algorithm.   

The values provided in first and middle names are searched for in both columns.  This is to ensure records are returned as
potential duplicates where the first and middle name order has been reported inconsistently.  Also where a record matches
on all other criteria but the middle name is blank, that record is still returned.  If a middle name is provided and it doesn't 
match a non-null middle names, the record is excluded.

When one or more phone numbers are provided they are searched in both the home and mobile column (similar to the first/middle
name switching).  The procedure removes format characters so that the search is done on digits only.

See the  WHERE clause in the syntax below for additional details of the search executed.

The records are returned in an order that attempts to put the most probable duplicates at the top of the list. For review 
purposes the ranking value is returned in the dataset but should not generally be displayed on the UI.

The procedure returns a bit for each column indicating whether or not it matches the associated column. The bit columns are
used on the UI to highlight the specific cells that match the values entered.  

Example
-------

<TestHarness>
  <Test Name="FirstNameLastName" IsDefault="true" Description="Returns matches for James Smith.">
    <SQLScript>
      <![CDATA[
exec sf.pPerson#GetMatches
	 @FirstName		= 'James'
	,@LastName		= 'Smith'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pPerson#GetMatches'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on

	declare
		 @errorNo                         int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@lastNameSoundex									varchar(5)													-- use to apply SOUNDEX search
		,@yearOfBirth											int																	-- derived from @BirthDate if provided
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided
		,@maxRows                         int                                 -- maximum rows to return on the search
		,@firstLetter                     nchar(1)                            -- first letter of first name
		
	set @MatchCount = 0

	begin try

		-- check parameters

		if @FirstName is null set @blankParm = 'FirstName'
		if @LastName  is null set @blankParm = 'LastName'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end

		-- prepare criteria for searching

		set @LastName		  = cast(sf.fSearchString#Format(@LastName)     as nvarchar(35))                       -- format search name values to eliminate outer spaces 
		set @FirstName	  = cast(sf.fSearchString#Format(@FirstName)    as nvarchar(30))                       -- and adds % character (when not null)
		set @MiddleNames  = cast(sf.fSearchString#Format(@MiddleNames)  as nvarchar(30))

		set @MobilePhone  = cast(sf.fReplaceAll(@MobilePhone, N'(,),-,', N',') as varchar(25))                 -- remove typical formatting characters from phone numbers
		set @HomePhone    = cast(sf.fReplaceAll(@HomePhone,   N'(,),-,', N',') as varchar(25))         

		-- for parameters not passed, set to values that won't be found on searches (avoid searching for nulls)

		set @firstLetter					= left(replace(replace(@FirstName, '%',''), '_', ''),1)
		set @lastNameSoundex			= soundex(replace(replace(@LastName, '%',''), '_', ''))
		set @yearOfBirth					= isnull(datepart(year, @BirthDate), -1)
		set @HomePhone						= isnull(@HomePhone, '?')
		set @MobilePhone					= isnull(@MobilePhone, '?')
		set @MiddleNames					= isnull(@MiddleNames, '?')
		set @PrimaryEmailAddress	= isnull(@PrimaryEmailAddress, '?')

		-- obtain max rows to return from configuration or set to 100

		set @maxRows = isnull(convert(smallint, sf.fConfigParam#Value('MaxRowsOnSearch')), convert(int, 100))

		-- execute the search
		-- values returned match any of the following:
		--			First Letter of FirstName + Soundex of LastName + no supplied BirthDate
		--			First Letter of FirstName + LastName + Year of Birth
		--			First Letter of FirstName + LastName (no year of birth)
		--			First Letter of FirstName + Soundex of LastName + Year of Birth
		--			HomePhone
		--			MobilePhone
		--			PrimaryEmailAddress
		
		select top (@maxRows)                                                 -- CHANGES to this structure must be coordinated with callers in DBO !
			 x.PersonSID
			,x.LastName		
			,x.FirstName
			,x.MiddleNames
			,x.GenderLabel
			,x.HomePhone
			,x.MobilePhone
			,x.EmailAddress																	PrimaryEmailAddress
			,x.YearOfBirth
			,x.ApplicationUserSID
			,cast(x.FirstNameMatched						as bit)			IsFirstNameMatched	-- convert non-zero matches to bit = 1
			,cast(x.LastNameMatched							as bit)			IsLastNameMatched
			,cast(x.MiddleNamesMatched					as bit)			IsMiddleNamesMatched			
			,cast(x.GenderMatched								as bit)			IsGenderMatched
			,cast(x.LastNameSoundexMatched			as bit)			IsLastNameSoundexMatched
			,cast(x.HomePhoneMatched						as bit)			IsHomePHoneMatched
			,cast(x.MobilePhoneMatched					as bit)			IsMobilePhoneMatched
			,cast(x.YearOfBirthMatched					as bit)			IsYearOfBirthMatched
			,cast(x.PrimaryEmailAddressMatched	as bit)			IsPrimaryEmailAddressMatched
			,(
				x.LastNameMatched 		
			+ x.FirstNameMatched 
			+ x.MiddleNamesMatched
			+ x.GenderMatched 
			+ x.LastNameSoundexMatched 
			+ x.HomePhoneMatched 
			+ x.MobilePhoneMatched 
			+ x.YearOfBirthMatched
			+ x.PrimaryEmailAddressMatched
			)																						RankOrder	
		from
		(
		select
			 p.PersonSID
			,p.LastName		
			,p.FirstName
			,p.MiddleNames
			,g.GenderLabel
			,p.HomePhone
			,p.MobilePhone
			,pea.EmailAddress
			,year(p.BirthDate)																																																					YearOfBirth
			,au.ApplicationUserSID
			,case																																																														                    -- assign points on matches for rank order
				when (p.FirstName like @FirstName or p.FirstName like @MiddleNames )																											then 3
				else 0
			 end																																																												FirstNameMatched
			,case
				when (isnull(p.MiddleNames,'!') like @FirstName or isnull(p.MiddleNames,'!') like @MiddleNames)														then 3
				else 0
			 end																																																												MiddleNamesMatched
			,case
				when soundex(p.LastName) = @lastNameSoundex																																								then 1
				else 0
			 end																																																												LastNameSoundexMatched
			,case
				when g.GenderSCD = isnull(@GenderSCD,'!')																																									then 1
				else 0
			 end																																																												GenderMatched
			,case
				when p.LastName like @LastName																																														then 5
				else 0
			 end																																																												LastNameMatched
			,case
				when year(p.BirthDate) = @yearOfBirth																																											then 2		
				else 0
			 end																																																												YearOfBirthMatched
			,case
				when (isnull(p.HomePhone, '!') = @HomePhone or isnull(p.HomePhone, '!') = @MobilePhone)																		then 2
				else 0
			 end																																																												HomePhoneMatched
			,case
				when (isnull(p.MobilePhone, '!') = @HomePhone or isnull(p.MobilePhone, '!') = @MobilePhone)																then 2
				else 0
			 end																																																												MobilePhoneMatched
			,case
				when (isnull(pea.EmailAddress, '!') = @PrimaryEmailAddress)																																then 5
				else 0
			 end																																																												PrimaryEmailAddressMatched
		from
			sf.Person p
		join
			sf.Gender g on p.GenderSID = g.GenderSID
		left outer join
			sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = cast(1 as bit)
		left outer join
			sf.ApplicationUser au on p.PersonSID = au.PersonSID
		where
			(
			(p.FirstName like @FirstName or isnull(p.MiddleNames,'!') like @FirstName )													                        -- first name provided matches or partially matches
			and 
			soundex(p.LastName) = @lastNameSoundex																												                              -- last name SOUNDEX matches
			and 
			g.GenderSCD = isnull(@GenderSCD,g.GenderSCD)																									                              -- gender matches if provided
			)
		or 
			(
			(p.FirstName like @firstLetter + N'%' or isnull(p.MiddleNames,'!') like @firstLetter + N'%')	                              -- first letter of first name matches to first/middle 
			and 
			p.LastName like @LastName																																				                            -- last name matches (with wild-card on end)
			)                                                                                                                           -- gender match not required
		or 
			(
			(p.FirstName like @firstLetter + N'%' or isnull(p.MiddleNames,'!') like @firstLetter + N'%')	                              -- first letter of first name matches to first/middle 
			and 
			soundex(p.LastName) = @lastNameSoundex																												                              -- last name SOUNDEX matches
			and
			isnull(year(p.BirthDate),-1) = @yearOfBirth																										                              -- year of birth matches
			)
		or 
			(isnull(p.HomePhone, '!') = @HomePhone or isnull(p.HomePhone, '!') = @MobilePhone)						                              -- phone found in either phone number column
		or 
			(isnull(p.MobilePhone, '!') = @HomePhone or isnull(p.MobilePhone, '!') = @MobilePhone)				                              -- phone found in either phone number column
		or 
			(isnull(pea.EmailAddress, '!') = @PrimaryEmailAddress)																																			-- primary email address matches the passed in email address
		) x
	order by
		(
				x.LastNameMatched 		
			+ x.FirstNameMatched 
			+ x.MiddleNamesMatched			
			+ x.GenderMatched 
			+ x.LastNameSoundexMatched 
			+ x.HomePhoneMatched 
			+ x.MobilePhoneMatched 
			+ x.YearOfBirthMatched
			+ x.PrimaryEmailAddressMatched
		 ) desc	
		,x.LastName
		,x.FirstName		
		
	set @MatchCount = @@rowcount																																									                  -- return results so that most likely duplicates appear first

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																																	                            -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
