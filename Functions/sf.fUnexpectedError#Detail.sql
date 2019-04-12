SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fUnexpectedError#Detail]
(
	@StartDate date -- first date to include in analysis (date of error in user timezone)
 ,@EndDate	 date -- last date to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Unexpected Error - Detail
Notice  : Copyright © 2017 Softworks Group Inc.
Detail	: Returns details on errors encountered in a given date range
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Detail
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on system errors.  The function returns one line for each Error Number an Procedure
Name that produced the error. An example of the specific error text is also retrieved based on the last occurrence of the error
number. 

The values from the procedure are presented as tabular text report.  The report is organized into one line for each Error Number.
The date range is only used for the WHERE clause (not sub-totaling).  The report is intended primary for use by the Help Desk.

Calling Syntax
--------------
declare
	@EndDate	 date = sf.fToday()
 ,@StartDate date;

set @StartDate = dateadd(day, -6, @EndDate);

select
	*
from
	sf.fUnexpectedError#Detail(@StartDate, @EndDate) x
order by
	x.ErrorNumber;
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.ErrorNumber
	 ,isnull(x.ProcName, '[Not Reported]') [Procedure]
	 ,ueMx.LineNumber											 Line
	 ,ueMx.ErrorSeverity									 Severity
	 ,ueMx.MessageText										 Message
	 ,ueMx.CallSyntax
	 ,ueMx.CreateUser
	 ,ueMx.CreateTime
	 ,x.ErrorCount
	from
	(
		select
			ue.ErrorNumber
		 ,ue.ProcName
		 ,count(1)									 ErrorCount
		 ,max(ue.UnexpectedErrorSID) UnexpectedErrorSID
		from	(
						select
							ue.ProcName
						 ,ue.CreateUser
						 ,ue.ErrorNumber
						 ,max(ue.UnexpectedErrorSID) UnexpectedErrorSID
						from
							sf.UnexpectedError ue
						where
							(sf.fDTOffsetToClientDate(ue.CreateTime) between @StartDate and @EndDate)
						group by
							ue.ProcName
						 ,ue.CreateUser
						 ,ue.ErrorNumber
					) ue
		group by
			ue.ErrorNumber
		 ,ue.ProcName
	)										 x
	join
		sf.UnexpectedError ueMx on x.UnexpectedErrorSID = ueMx.UnexpectedErrorSID
	left outer join
		sys.messages			 sysm on x.ErrorNumber				= sysm.message_id and sysm.language_id = 1033
);
GO
