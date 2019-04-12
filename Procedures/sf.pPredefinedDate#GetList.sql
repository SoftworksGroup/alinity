SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPredefinedDate#GetList]
as
/*********************************************************************************************************************************
Procedure : Predefined Date - Get List
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Returns a list of predefined dates
History   : Author(s)			| Month Year  | Change Summary
					: --------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng				| Feb		2014  | Initial version
 
Comments  
--------
This procedure is used to support UI's where setting date will is quicker and easier with predefined dates. For example, when 
updating the due date for a task, saying the task is due next week is easier than setting the specific date. The procedure 
returns the label to be shown on the UI as well as the date that corresponds with the label.

The values returns include Today, tomorrow, end of the week, next week, next month. End of the week is defined as the Friday of
the current week.

Example:

<TestHarness>
<Test Name = "Simple" Description="Should return 5 rows">
<SQLScript>
<![CDATA[
exec sf.pPredefinedDate#GetList
]]>
</SQLScript>
<Assertions>
  <Assertion Type="RowCount" RowSet="1" ResultSet="1" Value="5" />
  <Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pPredefinedDate#GetList'

-------------------------------------------------------------------------------------------------------------------------------- */
 
set nocount on
 
begin
 
	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@today														date					= sf.fToday()	
		,@todayTerm												nvarchar(35)												-- today label returned from sf.TermLabel
		,@tomorrowTerm										nvarchar(35)												-- tomorrow label returned from sf.TermLabel
		,@endOfTheWeekTerm								nvarchar(35)												-- end of the week label returned from sf.TermLabel
		,@nextWeekTerm										nvarchar(35)												-- next week label returned from sf.TermLabel
		,@nextMonthTerm										nvarchar(35)												-- next month label returned from sf.TermLabel
		
	begin try
	
		 declare
      @dates													table                            
      (
         Label												nvarchar(35)					not null
        ,Date		                      date									not null  
      )

		select
			@todayTerm = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'TODAY'
			
		select
			@tomorrowTerm = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'TOMORROW'
			
		select
			@endOfTheWeekTerm = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'ENDOFWEEK'
			
		select
			@nextWeekTerm = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'NEXTWEEK'
			
		select
			@nextMonthTerm = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'NEXTMONTH'

		if @todayTerm is null					set @todayTerm = 'Today'
		if @tomorrowTerm is null			set @tomorrowTerm = 'Tomorrow'
		if @endOfTheWeekTerm is null	set @endOfTheWeekTerm = 'End of the week'
		if @nextWeekTerm is null			set @nextWeekTerm = 'Next week'
		if @nextMonthTerm is null			set @nextMonthTerm = 'Next month'

		insert
			@dates
			(
				Label
				,Date
			)
			values
				 (@todayTerm				, @today)
				,(@tomorrowTerm			, dateadd(d, 1, @today))
				,(@endOfTheWeekTerm	, cast(dateadd(wk, datediff(wk, cast(0 as datetime), @today), cast(4 as datetime)) as date))
				,(@nextWeekTerm			, dateadd(wk, 1, @today))
				,(@nextMonthTerm		, dateadd(m, 1, @today))

		select 
			 Label
			,Date
		from
			@dates

	end try
 
	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch
 
	return(@errorNo)
 
end
GO
