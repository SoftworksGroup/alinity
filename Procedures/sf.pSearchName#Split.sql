SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSearchName#Split]
	 @SearchName											nvarchar(150)											    -- text containing the name values to search
	,@LastName												nvarchar(35)				output				    -- last name value parsed from @SearchName
	,@FirstName												nvarchar(30)				output				    -- first name value parsed from @SearchName
	,@MiddleNames											nvarchar(30) = null	output				    -- middle name value parsed from @SearchName		
as
/*********************************************************************************************************************************
Sproc    : Search Name Split
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Parses name search string provided into last, first and middle name components formatted and ready for "LIKE" search
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-------------------------------------------------------------------------------------------
				 : Tim Edlund   | Jun 2012			| Initial Version
				 : Tim Edlund		| Jan	2014		  | Updated to call table function of same name to return output

Comments  
--------
This is a wrapper procedure that calls the table function sf.fSearchName#Split to perform parsing of a search name into last, 
first and middle name components.  The name components are assumed to reside in sf.Person which is the basis of the data types and 
lengths of output parameters.  The function called parses the search string provided in @SearchName into 1 or more of the 3 name 
parts returned as output.  See the table function for a description of parsing logic.

Note that if a user wants to search for a multi-word last name only - without a first name, then they must put a comma at the end 
of the string.  This is so that the algorithm can distinguish between that case and the situation where a first and last name are
separated by a space.

Example/Test:

declare
	 @searchName											nvarchar(150)										      -- test parameter 
	,@lastName												nvarchar(35)
	,@firstName												nvarchar(30)
	,@middleNames											nvarchar(30)
	,@i																tinyint

set @i = 0

while @i < 9
begin

	set @i += 1

	if @i = 1 or @i = 9 set @SearchName = 'Edlund, Tim E'
	if @i = 2 set @SearchName = 'Van Man, Tim'
	if @i = 3 set @SearchName = 'Van Der Hoff, Tim E'
	if @i = 4 set @SearchName = '  Edlund, Tim   '
	if @i = 5 set @SearchName = 'Tim E Edlund'
	if @i = 6 set @SearchName = 'Tim Edlund'
	if @i = 7 set @SearchName = 'Edlund'
	if @i = 8 set @SearchName = ' Van Der Hoff   ,    '
	
	exec sf.pSearchName#Split
		 @SearchName				= @searchName
		,@LastName					= @lastName					output
		,@FirstName					= @firstName				output
		,@MiddleNames				= @middleNames			output

	print ' '
	print ('Iteration - ' + convert(char(1), @i) + ' ' + @searchName )
	print (isnull(@firstName,'null'))
	print (isnull(@middleNames,'null'))
	print (isnull(@lastName,'null'))

end

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin	

	declare
		 @errorNo                           int             = 0               -- 0 no error, <50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)

	set @LastName			= null		                                            -- initialize output values in all code paths
	set @FirstName		= null
	set @MiddleNames	= null

	begin try

		select
			 @LastName		= sn.LastName
			,@FirstName		= sn.FirstName
			,@MiddleNames	= sn.MiddleNames
		from
			sf.fSearchName#Split(@SearchName) sn

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																		  -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
