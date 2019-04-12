SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pEffectiveExpiry#Set
	@EffectiveTime datetime					output	-- day the new registration takes effect (default available)
 ,@ExpiryTime		 datetime = null	output	-- last day the new registration remains in effect (default available)
as
/*********************************************************************************************************************************
Sproc    : Effective Expiry (range) - Set
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure sets effective and expiry datetime column values to the start/end of day or current time (see below)
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun 2018		|	Initial version

Comments	
--------
This procedure is called in contexts where a record has an "effective period" defined through a pair of date-time column values.
The columns are normally named "EffectiveTime" and "ExpiryTime".  Where an effective range is being forward dated or back-dated
this procedure will ensure the time components in the parameters are set to start-of-day and end-of-day values (12:00am and
11:59pm).  Where a value passed in is on the current day, however, the current time is used instead.

This logic ensures that where date/time ranges are being defined for the future or past, that full-days are reflected but 
allows multiple time ranges to be set within the current day.  Examples of these scenarios in the Alinity application
include:

1) Registration records set for renewal are future dated - and so take effect at midnight on the first day of the new
registration period and end at the end of the registration year.

2) An applicant may be approved the same day as they apply.  One registration record is created when they apply and
another when they are approved.  They both occur on the same day and do not overlap since current-day time values 
are used.

Example:
--------

<TestHarness>
	<Test Name = "TodayPlus30" IsDefault ="true" Description="Calls the procedure passing in the current day
	and current day +30 and the returns updated values in a select.  First value should have current time
	while second value should show end of day time.">
		<SQLScript>
			<![CDATA[

declare
	@effectiveTime datetime = sf.fToday()
 ,@expiryTime		 datetime = dateadd(day, 30, sf.fToday());


exec sf.pEffectiveExpiry#Set
	@EffectiveTime = @effectiveTime output
 ,@ExpiryTime = @expiryTime output;

select @effectiveTime	 EffectiveTime, @expiryTime ExpiryTime;
  
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:01"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pEffectiveExpiry#Set'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo int			= 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@today	 date			= sf.fToday() -- current date in the user timezone
	 ,@now		 datetime = sf.fNow();	-- current time in user timezone

	set @EffectiveTime = @EffectiveTime;
	set @ExpiryTime = @ExpiryTime;

	begin try

		-- ensure effective and expiry time values are set
		-- to start-of-day and end-of-day time values unless they
		-- are for the current day in which case current time is used

		if @EffectiveTime is not null
		begin

			if cast(@EffectiveTime as date) <> @today
			begin
				set @EffectiveTime = cast(cast(@EffectiveTime as date) as datetime); -- start of day 
			end;
			else -- effective is on current date so use current time
			begin
				set @EffectiveTime = @now;
			end;

		end;

		if @ExpiryTime is not null
		begin

			if cast(@ExpiryTime as date) <> @today
			begin
				set @ExpiryTime = cast(convert(varchar(8), cast(@ExpiryTime as date), 112) + ' 23:59:59.99' as datetime); -- end of day
			end;
			else -- expiry is on current date so use current time
			begin
				set @ExpiryTime = @now;
			end;

		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
