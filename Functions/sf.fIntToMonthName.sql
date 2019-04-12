SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIntToMonthName]
(
	 @MonthNo											int																				-- a valid month number from 1 to 12 (or -1 see below)
)
returns nvarchar(15)																											-- returns Unicode for concatenation with other strings
as
/*********************************************************************************************************************************
ScalarF	: Integer to  Month Name
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns full character month name for a given month number passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | August 2015		|	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is created primarily to support conversion of numeric month values to strings. This function returns a full
month name. Another function - sf.fIntToShortMonthName returns a 3-character month value.

The function is not hard coded to English but rather uses TSQL date functions to return the month name in the language of the
installed server. 

Expected values : The function expects values from 1-12, however, if the current month in the client timezone is to be returned 
the special value "-1" can be passed in to return it.  If a value other than -1 or 1-12 is provided then "ERR" Is returned

Example
-------

select 
	 sf.fIntToMonthName(4)			M4
	,sf.fIntToMonthName(5)			M5
	,sf.fIntToMonthName(6)			M6
	,sf.fIntToMonthName(7)			M7
	,sf.fIntToMonthName(8)			M8
	,sf.fIntToMonthName(9)			M9
	,sf.fIntToMonthName(10)			M10
	,sf.fIntToMonthName(11)			M11
	,sf.fIntToMonthName(12)			M12
	,sf.fIntToMonthName(13)			M13
	,sf.fIntToMonthName(-1)			MNeg1
	,sf.fIntToMonthName(-2)			MNeg2
	,sf.fIntToMonthName(-2)			Blank

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@shortMonthName			nvarchar(15)
	if @MonthNo is null set @MonthNo = 0

	if @MonthNo = -1 
	begin
		set @shortMonthName = datename(month, sf.fNow())
	end
	else if @MonthNo between 1 and 12
	begin
		set @shortMonthName = datename(month, dateadd(month, @MonthNo, -1))
	end
	else
	begin
		set @shortMonthName = N'ERROR'
	end

	return(@shortMonthName)

end
GO
