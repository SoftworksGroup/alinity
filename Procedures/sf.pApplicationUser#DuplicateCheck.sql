SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#DuplicateCheck] 
	(
	 @FirstName							nvarchar(30)						-- required - some matches will use first letter only
	,@LastName							nvarchar(35)						-- required - "like" search performed
	,@MiddleNames						nvarchar(30)	= null		-- not used for searching but impacts ordering of results if matched
	,@GenderSCD							char(1)				=	null		-- may be included to limit results to a specific gender - ignored if not provided
	,@HomePhone							varchar(25)		=	null		-- partial phone number matches supported
	,@MobilePhone						varchar(25)		= null		-- partial phone number matches supported
	,@BirthDate							date					= null		-- comparison occurs on the year of birth only	
	,@MaxRows								smallint			= null		-- maximum number of rows to return; defined in sf.ConfigParam or if null = 100
	) as
-- TODO: sproc needs completing
-- find all application users may be possible duplicates with this user. (look at PermitsyV6 pPerson#DuplicateCheck sproc)
-- Cory Ng February 2012
begin

	select top 3
		 x.LastName		
		,x.FirstName
		,x.MiddleNames
		,x.GenderLabel
		,x.HomePhone
		,x.MobilePhone
		,year(x.BirthDate)	YearOfBirth
		,cast(0 as bit)			IsFirstNameMatched																				-- convert non-zero matches to bit = 1
		,cast(1 as bit)			IsLastNameMatched
		,cast(0 as bit)			IsMiddleNamesMatched			
		,cast(0 as bit)			IsGenderMatched
		,cast(1 as bit)			IsLastNameSoundexMatched
		,cast(0 as bit)			IsHomePHoneMatched
		,cast(0 as bit)			IsMobilePhoneMatched
		,cast(0 as bit)			IsYearOfBirthMatched
		,1									RankOrder	
	from
		vPerson x
	order by
		newid()
		
		return(0)
end
GO
