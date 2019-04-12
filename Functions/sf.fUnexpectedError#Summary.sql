SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fUnexpectedError#Summary]
(
	@StartDate date -- first date to include in analysis (date of error in user timezone)
 ,@EndDate	 date -- last date to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Unexpected Error - Summary
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on errors encountered in a given date range
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version 
				: Tim Edlund	| Feb 2018			| Updated to include row for every day in which at least one user session occurred
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on system error rates.  The function returns one or more rows for each day of the range 
where an error has occurred. A row is provided for each distinct error number encountered on that day.  Note that if the same
error number arises from multiple procedures, only a single record is returned.  

The values from the procedure are presented as a stacked bar graph where each bar is a day in the range.  Each section of the bar
is an Error number. The legend includes the Error Number and Description.

Calling Syntax
--------------

declare
	@EndDate	 date = sf.fToday()
 ,@StartDate date;

set @StartDate = dateadd(day, -6, @EndDate);

select
	*
from
	sf.fUnexpectedError#Summary(@StartDate, @EndDate) x
order by
	x.ErrorDate
 ,x.ErrorNumber;

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		y.ActivityDate ErrorDate
	 ,isnull(z.ErrorNumber, 0) ErrorNumber
	 ,isnull(z.ErrorCount,0) ErrorCount
	 ,isnull(left(sysm.text, 60), 'Handled Exception') Description
	from
	(
		select
			aus.ActivityDate
		 ,count(1) SessionCount
		from	(
						select
							sf.fDTOffsetToClientDate(aus.CreateTime) ActivityDate
						from
							sf.ApplicationUserSession aus
						where
							(sf.fDTOffsetToClientDate(aus.CreateTime) between @StartDate and @EndDate)
					) aus
		group by
			aus.ActivityDate
	) y
	left outer join
	(
		select
			x.ErrorDate
		 ,x.ErrorNumber
		 ,count(1) ErrorCount
		from	(
						select
							ue.ErrorDate
						 ,ue.ErrorNumber
						from	(
										select
											sf.fDTOffsetToClientDate(ue.CreateTime) ErrorDate
										 ,ue.CreateUser
										 ,ue.ErrorNumber
										 ,ue.ProcName
										from
											sf.UnexpectedError ue
										where
											(sf.fDTOffsetToClientDate(ue.CreateTime) between @StartDate and @EndDate)
										group by
											sf.fDTOffsetToClientDate(ue.CreateTime)
										 ,ue.CreateUser
										 ,ue.ErrorNumber
										 ,ue.ProcName
									) ue
					) x
		group by
			x.ErrorDate
		 ,x.ErrorNumber
	)							 z on y.ActivityDate = z.ErrorDate
	left outer join
		sys.messages sysm on z.ErrorNumber = sysm.message_id and sysm.language_id = 1033
);

GO
