SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPerson#GetReviewerMatches]
	 @FirstName							nvarchar(30)									-- required - some matches will use first letter only
	,@LastName							nvarchar(35)									-- required - "like" search performed
	,@GenderSCD							char(1)				      					-- to limit results to a specific gender - ignored if not provided
	,@PrimaryEmailAddress		varchar(150)	      					-- primary email address matches supported
	,@MatchCount						int						= null output		-- rows returned
as
/*********************************************************************************************************************************
Procedure : Person - Get Matches
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : returns list of sf.Persons which match or partially match criteria entered to establish a new child entity
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)   | Month Year   | Change Summary
				 : ------------|--------------|-------------------------------------------------------------------------------------------
				 : Kris Dawson | April	2017  | Initial version
         : Kris Dawson | July   2017  | Update to support base grant and the two reviewer grants
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure is used by the quick add user interface for adding reviewers to the system. It will support adding people and users
or updating existing records so they can act as reviewers. This procedure uses sf.pPerson#GetMatches to get the matches based on
the entered details and then runs an additional query on the resulting records to determine what actions may be required to
setup that existing record as a reviewer.

Example
-------

<TestHarness>
	<Test Name="FirstNameLastName" IsDefault="true" Description="Returns matches for James Smith.">
		<SQLScript>
			<![CDATA[
exec dbo.pPerson#GetReviewerMatches
	 @FirstName		= 'James'
	,@LastName		= 'Smith'
	,@GenderSCD   = 'M'
	,@PrimaryEmailAddress = 'james.smith@fake.email.com'
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pPerson#GetReviewerMatches'
	
-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @errorNo                         int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided
		,@ON                              bit = cast(1 as bit)								-- constant for bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- constant for bit comparisons

	declare
		@matches		table																											-- stores results of query - SID only
	(
		 ID					                    int identity(1,1)	not null						-- identity to track add order - preserves custom sorts
		,PersonSID	                    int								not null						-- record ID joined to main entity to return results
		,LastName                       nvarchar(35)      not null                                
		,FirstName                      nvarchar(30)      not null                                
		,MiddleNames                    nvarchar(30)      null                                    
		,GenderLabel                    nvarchar(35)      not null                                
		,HomePhone                      varchar(25)       null                                    
		,MobilePhone                    varchar(25)       null                                    
		,PrimaryEmailAddress            varchar(150)      null                              
		,YearOfBirth                    int               null                                    
		,ApplicationUserSID             int               null                                    
		,IsFirstNameMatched             bit               not null                                
		,IsLastNameMatched              bit               not null                                
		,IsMiddleNamesMatched           bit               not null                              
		,IsGenderMatched                bit               not null                                   
		,IsLastNameSoundexMatched       bit               not null                          
		,IsHomePhoneMatched             bit               not null                                
		,IsMobilePhoneMatched           bit               not null                              
		,IsYearOfBirthMatched           bit               not null                              
		,IsPrimaryEmailAddressMatched   bit               not null 
		,RankOrder                      int               not null
		,IsApplicationUserCreated       bit               not null default(0)
		,IsApplicationUserActive        bit               not null default(0)
		,IsApplicationUserConfirmed     bit               not null default(0)
		,IsAppReviewerGranted           bit               not null default(0)
		,IsAppReviewerGrantActive       bit               not null default(0)
    ,IsAuditReviewerGranted         bit               not null default(0)
		,IsAuditReviewerGrantActive     bit               not null default(0)
    ,IsBaseGranted                  bit               not null default(0) 
		,IsBaseGrantActive              bit               not null default(0)
	)
		
	set @MatchCount = 0

	begin try

		-- check parameters

		if @FirstName             is null set @blankParm = 'FirstName'
		if @LastName              is null set @blankParm = 'LastName'
		if @GenderSCD             is null set @blankParm = 'GenderSCD'
		if @PrimaryEmailAddress   is null set @blankParm = 'PrimaryEmailAddress'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end

		-- get the person matches
		
		insert @matches
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
			 @FirstName             = @FirstName
			,@LastName              = @LastName
			,@GenderSCD             = @GenderSCD
			,@PrimaryEmailAddress   = @PrimaryEmailAddress
			,@MatchCount            = @MatchCount output

		-- update the rows for reviewer specific details

		update
			m
		set
			 m.IsApplicationUserCreated     = cast(isnull(au.ApplicationUserSID, 0) as bit)
			,m.IsApplicationUserActive      = isnull(au.IsActive, @OFF)
			,m.IsApplicationUserConfirmed   = isnull(au.IsConfirmed, @OFF)
			,m.IsAppReviewerGranted         = cast(isnull(app.ApplicationUserGrantSID, 0) as bit)					-- not checking IsSA, perhaps explicit grant required to show in drop down list....
			,m.IsAppReviewerGrantActive     = isnull(app.IsActive, @OFF)
      ,m.IsAuditReviewerGranted       = cast(isnull(aud.ApplicationUserGrantSID, 0) as bit)
      ,m.IsAuditReviewerGrantActive   = isnull(aud.IsActive, @OFF)
      ,m.IsBaseGranted                = cast(isnull(bas.ApplicationUserGrantSID, 0) as bit)
      ,m.IsBaseGrantActive            = isnull(bas.IsActive, @OFF)
		from
			@matches m
		left outer join
			sf.vApplicationUser au on m.PersonSID = au.PersonSID																					-- IsConfirmed, going to ignore 'AuthenticationAuthorityIsActive' since we only have one these days
		left outer join																																									-- double check that business rules prevent having 0..1 active and 0..* inactive
			sf.vApplicationUserGrant app on au.ApplicationUserSID = app.ApplicationUserSID
		and
			app.ApplicationGrantSCD = 'EXTERNAL.APPLICATION'
    left outer join																																									
			sf.vApplicationUserGrant aud on au.ApplicationUserSID = aud.ApplicationUserSID
		and
			aud.ApplicationGrantSCD = 'EXTERNAL.AUDIT'
    left outer join																																									
			sf.vApplicationUserGrant bas on au.ApplicationUserSID = bas.ApplicationUserSID
		and
			bas.ApplicationGrantSCD = 'EXTERNAL.BASE'

		-- select the matches

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
			,m.IsApplicationUserCreated    
			,m.IsApplicationUserActive
			,m.IsApplicationUserConfirmed
			,m.IsAppReviewerGranted       
      ,m.IsAppReviewerGrantActive   
      ,m.IsAuditReviewerGranted     
      ,m.IsAuditReviewerGrantActive 
      ,m.IsBaseGranted              
      ,m.IsBaseGrantActive          
		from
			@matches m

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																																	                            -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
