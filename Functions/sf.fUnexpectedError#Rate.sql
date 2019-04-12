SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fUnexpectedError#Rate
(
	@StartDate date -- first date to include in analysis (date of error in user timezone)
 ,@EndDate	 date -- last date to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Unexpected Error - Rate
Notice  : Copyright © 2017 Softworks Group Inc.
Rate	: Returns statistics on the rate of errors per 100 logins encountered in a given date range
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Rate
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version 
				: Tim Edlund	| Feb 2018			| Updated to include row for every day in which at least one user session occurred
				: Tim Edlund	| Jan 2019			| Improved performance by eliminating conversion to client timezone values
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting of a daily error rate.  The value is calculated based on the number of user sessions created
(denominator) and the number of unique errors encountered for that user.  The function returns one line for each day in
the range for which at least one login occurred.  If the same error number is reported multiple times by the same procedure for 
the same user, it is only counted once.  That counting logic is shared by all fUnexpectedErro#% table functions.

The values from the procedure are presented as a line chart showing changes in the rate of errors over time.

Limitations
-----------
This function does NOT support conversion of parameters from the client timezone.  This limitation is in place as the conversion
greatly degrades the performance of the query.  Since error reports are primarily of interest to technical users and the Softworks
help desk, the values must be entered with respect to the server location time zone.

Calling Syntax
--------------
declare
	@EndDate	 date = sf.fToday()
 ,@StartDate date;

set @StartDate = dateadd(day, -6, @EndDate);

print @startDate
print @endDate

select
	*
from
	sf.fUnexpectedError#Rate(@StartDate, @EndDate) x
order by
	x.ErrorDate;
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		y.ActivityDate																																															ErrorDate
	 ,isnull(x.ErrorCount, 0)																																											ErrorCount
	 ,isnull(x.HandledExceptions, 0)																																							HandledExceptions
	 ,isnull(x.UnexpectedErrors, 0)																																								UnexpectedErrors
	 ,y.SessionCount
	 ,cast(round(100 * ((isnull(x.ErrorCount, 0.0) * 1.00000) / (y.SessionCount * 1.00000)), 1) as decimal(4, 1)) ErrorsPer100Users
	from
	(
		select
			aus.ActivityDate
		 ,count(1) SessionCount
		from
		(
			select
				cast(aus.CreateTime as date) ActivityDate
			from
				sf.ApplicationUserSession aus
			where
				aus.CreateTime >= @StartDate and cast(aus.CreateTime as date) <= @EndDate
		) aus
		group by
			aus.ActivityDate
	) y
	left outer join
	(
		select
			ue.ErrorDate
		 ,count(1)																								 ErrorCount
		 ,sum(case when ue.ErrorNumber = 50000 then 1 else 0 end)	 HandledExceptions
		 ,sum(case when ue.ErrorNumber <> 50000 then 1 else 0 end) UnexpectedErrors
		from
		(
			select
				cast(ue.CreateTime as date) ErrorDate
			 ,ue.CreateUser
			 ,ue.ErrorNumber
			 ,ue.ProcName
			from
				sf.UnexpectedError ue
			where
				ue.CreateTime >= @StartDate and cast(ue.CreateTime as date) <= @EndDate
			group by
				cast(ue.CreateTime as date)
			 ,ue.CreateUser
			 ,ue.ErrorNumber
			 ,ue.ProcName
		) ue
		group by
			ue.ErrorDate
	) x on y.ActivityDate = x.ErrorDate
);
GO
