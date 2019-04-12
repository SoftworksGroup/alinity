SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIntToShortMonthName]
(
	 @MonthNo											int																				-- a valid month number from 1 to 12 (or -1 see below)
)
returns nchar(3)																													-- returns Unicode for concatenation with other strings
as
/*********************************************************************************************************************************
ScalarF	: Integer to Short Month Name
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns a 3-character month name for a given month number passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | August 2015		|	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is created primarily to support conversion of numeric month values to strings. This function returns a short
month name. Another function - sf.fIntToMonthName returns the full month value.

The function is not hard coded to English but rather uses TSQL date functions to return the month name in the language of the
installed server. 

Expected values : The function expects values from 1-12, however, if the current month in the client timezone is to be returned 
the special value "-1" can be passed in to return it.  If a value other than -1 or 1-12 is provided then "ERR" Is returned

Example
-------

select 
	 sf.fIntToShortMonthName(4)				M4
	,sf.fIntToShortMonthName(5)				M5
	,sf.fIntToShortMonthName(6)				M6
	,sf.fIntToShortMonthName(7)				M7
	,sf.fIntToShortMonthName(8)				M8
	,sf.fIntToShortMonthName(9)				M9
	,sf.fIntToShortMonthName(10)			M10
	,sf.fIntToShortMonthName(11)			M11
	,sf.fIntToShortMonthName(12)			M12
	,sf.fIntToShortMonthName(13)			M13
	,sf.fIntToShortMonthName(-1)			MNeg1
	,sf.fIntToShortMonthName(-2)			MNeg2
	,sf.fIntToShortMonthName(-2)			Blank

------------------------------------------------------------------------------------------------------------------------------- */

begin

	return(left(sf.fIntToMonthName(@MonthNo),3))

end
GO
