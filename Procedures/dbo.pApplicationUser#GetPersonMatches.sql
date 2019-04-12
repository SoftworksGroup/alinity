SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pApplicationUser#GetPersonMatches]
	 @Name									nvarchar(140)               -- name to search for (first, middle, last) - see below
	,@GenderSCD							char(1)				=	null				-- may be included to limit results to a specific gender
	,@HomePhone							varchar(25)		=	null				-- partial phone number matches supported
	,@MobilePhone						varchar(25)		= null				-- partial phone number matches supported
	,@PrimaryEmailAddress		varchar(150)	= null				-- email address matches supported
	,@MatchCount						int						= null output	-- rows returned 
as
/*********************************************************************************************************************************
##Procedure  Application User - Get Person Matches
##Notice     Copyright © 2012 Softworks Group Inc.
##Summary    Returns list of sf.Persons which match or partially match criteria entered to establish a new ApplicationUser
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)   | Month Year   | Change Summary
				 : ------------|--------------|--------------------------------------------------------------------------------------------
				 : Cory Ng		 | May  2016    | Initial version
-----------------------------------------------------------------------------------------------------------------------------------
##Remarks
---------
This procedure supports a wizard-styled UI where the user has entered values to establish a new sf.Application User record. 
The routine assists the user in avoiding the creation of a duplicate record.  The parameter values are passed to a sub-procedure 
that checks to see if a sf.Person record exists with values similar to those passed in.  

The @Name parameter is required.  This value is split into Last, First and Middle name components by a framework routine.  See
sf.pSearchName#Split for details.  If no comma or space is included in the @Name column it is assumed to contain a last name. 

When potential matches are found, they are returned to the caller (the UI) at which point the user may choose to apply a Person
record found as a new ApplicationUser, or, if the Person is already a ApplicationUser, the operation is canceled. (and the UI 
should automatically navigated to the existing record.)

When no rows are returned by this procedure then the values entered are unique and a new ApplicationUser record should be created.

NOTE that this procedure searches on the sf.PERSON table and not sf.ApplicationUser. The Alinity™ database design uses a common 
Person record stored in the framework. The attributes of this record are inherited by Application Users and all other "person 
types" used by the application. It is possible, therefore, that a Person record will be found that matches the criteria passed BUT 
this does not mean that the Person row is a ApplicationUser. This must be determined by examining the IsApplicationUser bit 
returned with the data set.

Based on the results returned, the wizard process can then branch to either:

	o add a new sf.Person entity and then a new ApplicationUser and edit ApplicationUser details
	o convert a selected Person entity to a ApplicationUser and edit ApplicationUser details
	o advise the user the Person selected is already a ApplicationUser

This procedure is tightly coupled with the framework subroutine sf.pPerson#GetMatches. This procedure accepts its output into a 
table before adding additional elements from the dbo.vPerson#Types view.  If the structure of results returned from the subroutine 
changes, this procedure must be updated!

See sf.pPerson#GetMatches for details of the matching algorithm.

Example
-------

<TestHarness>
	<Test Name="FileAsName" IsDefault="true" Description="Select a full name at random from the person view and then search for it through the procedure.">
		<SQLScript>
			<![CDATA[
declare
	 @name				nvarchar(100)

select top 1
	 @name = p.FileAsName
from
	sf.vPerson p
order by
	newid()

exec dbo.pApplicationUser#GetPersonMatches
	 @Name = @name
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>
	
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                         int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided
		,@lastName                        nvarchar(35)                        -- for name searches, buffer for each name part: 		
		,@firstName                       nvarchar(30)
		,@middleNames                     nvarchar(30)

	declare                                                                 -- table to store matches in and return to the caller
		 @matches                         table
	(
		 ID                               int            identity(1,1)
		,PersonSID                        int            not null             -- standard structure returned from subroutine STARTS here
		,LastName                         nvarchar(35)   not null             
		,FirstName                        nvarchar(30)   not null
		,MiddleNames                      nvarchar(30)   null
		,GenderLabel                      nvarchar(35)   not null
		,HomePhone                        varchar(25)    null
		,MobilePhone                      varchar(25)    null
		,PrimaryEmailAddress							varchar(150)	 null
		,YearOfBirth                      int            null
		,ApplicationUserSID               int            null                 -- primary key value when Person IS an Application User
		,IsFirstNameMatched			          bit            not null
		,IsLastNameMatched                bit            not null
		,IsMiddleNamesMatched		          bit            not null
		,IsGenderMatched                  bit            not null
		,IsLastNameSoundexMatched         bit            not null
		,IsHomePhoneMatched               bit            not null
		,IsMobilePhoneMatched             bit            not null
		,IsYearOfBirthMatched             bit            not null
		,IsPrimaryEmailAddressMatched			bit						 not null
		,RankOrder                        int            not null             -- standard structure returned from subroutine ENDS here
		,IsRegistrant                     bit            not null default 0   -- bits to indicate person types:
		,IsOrgContact			                bit            not null default 0
		,IsApplicationUser                bit            not null default 0
	)
		
	set @MatchCount = 0

	begin try

		-- check parameters

		if @Name is null set @blankParm = 'Name'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end    

		-- split the @Name parameter into multiple components for
		-- application in the search

		exec sf.pSearchName#Split                                           
				 @SearchName   = @Name
				,@LastName     = @lastName     output
				,@FirstName    = @firstName    output
				,@MiddleNames  = @middleNames  output

		-- call the subroutine to return possible matches on existing sf.Person records

		insert
			@matches
			(
				 PersonSID               
				,LastName                
				,FirstName               
				,MiddleNames             
				,GenderLabel             
				,HomePhone               
				,MobilePhone   
				,PrimaryEmailAddress          
				,YearOfBirth    
				,ApplicationUserSID         
				,IsFirstNameMatched			 
				,IsLastNameMatched       
				,IsMiddleNamesMatched		 
				,IsGenderMatched         
				,IsLastNameSoundexMatched
				,IsHomePhoneMatched      
				,IsMobilePhoneMatched    
				,IsYearOfBirthMatched  
				,IsPrimaryEmailAddressMatched  
				,RankOrder
			)
			exec sf.pPerson#GetMatches
			 @FirstName						= @FirstName
			,@LastName						= @LastName
			,@MiddleNames					= @MiddleNames
			,@GenderSCD						= @GenderSCD
			,@PrimaryEmailAddress = @PrimaryEmailAddress
			,@MatchCount					= @MatchCount		output

		if @MatchCount > 0                                                    -- update rows found with the ApplicationUserSID where it exists
		begin

			update
				m
			set
				m.IsRegistrant        = pt.IsRegistrant
			 ,m.IsOrgContact			  = pt.IsOrgContact
			 ,m.IsApplicationUser   = pt.IsApplicationUser
			from
				@matches      m
			join
				dbo.vPerson#Types pt on m.PersonSID = pt.PersonSID
	 
		end

		select
			 m.PersonSID               
			,m.LastName                
			,m.FirstName               
			,m.MiddleNames             
			,m.GenderLabel             
			,m.HomePhone
			,m.MobilePhone
			,m.PrimaryEmailAddress
			,m.YearOfBirth             
			,m.ApplicationUserSID
			,m.IsFirstNameMatched			 
			,m.IsLastNameMatched       
			,m.IsMiddleNamesMatched		 
			,m.IsGenderMatched         
			,m.IsLastNameSoundexMatched
			,m.IsHomePhoneMatched      
			,m.IsMobilePhoneMatched    
			,m.IsYearOfBirthMatched  
			,m.IsPrimaryEmailAddressMatched
			,m.RankOrder  
			,m.IsRegistrant
			,m.IsOrgContact
			,m.IsApplicationUser
			,cast(case when (row_number() over (order by m.RankOrder desc))%2 = 0 then 1 else 0 end as bit) IsEven                      -- for striping every other line in UI
		from
			@matches m
		order by
			m.RankOrder desc   

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
