SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pDebugPrint]
(
	 @DebugString				nvarchar(70)						= null											-- debug string to output - null for buffer flush only
	,@TimeCheck					datetimeoffset(7)				= null output								-- starting time for interval to calculate
)
as
/*********************************************************************************************************************************
Procedure	: Debug Print
Notice		: Copyright © 2014 Softworks Group Inc. 
Summary		: Outputs a string to the console immediately; also flushes buffer for any pending record sets
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Sep 2014		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This utility is used to implement debug statements in store procedures.  When PRINT and SELECT statements are used for debugging
their output only goes to the console when execution completes or when the 8K console buffer is full.  This procedure uses 
"raiserror" with a low severity and the "nowait" clause to cause the text provided to be printed immediately to the console. If 
there is any output pending from a SELECT statement, calling this procedure will also force that to appear on the console
since the buffer is automatically flushed.

Use of this procedure is only appropriate for back-end testing as these messages will appear on the error stack in .NET

Use of the procedure is best accomplished using a conditional "@Debug" parameter.  See also the examples in the test harness
code below.

Example:
--------

<TestHarness>
	<Test Name="DebugLevel1" IsDefault="true" Description="Prints 2 of 3 lines of output based on use of a debug level variable.">
		<SQLScript>
			<![CDATA[
			
declare
	 @debug			int = 1
	,@timeCheck	datetimeoffset(7)

if @debug > 1 exec sf.pDebugPrint 'This should NOT print'
if @debug > 0 exec sf.pDebugPrint 'No time interval', @TimeCheck = @timeCheck output
if @debug > 0 exec sf.pDebugPrint

waitfor delay '00:00:02'

if @debug > 0 exec sf.pDebugPrint 'Time interval should be about 2 seconds', @TimeCheck = @timeCheck output

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pDebugPrint'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@debugLine												nvarchar(140)												-- string to take the formatted print line
		,@callStackLevel									int	= (@@nestlevel - 1)							-- subtract 1 from call stack level to account for this procedure

	set @TimeCheck = @TimeCheck

	begin try

		if @callStackLevel = 0 set @callStackLevel = 1												-- if call is from script, adjust level + 1

		if @DebugString is null set @DebugString = N'Buffer flushed'

		set @DebugString = ltrim(rtrim(@DebugString))													-- trim the inbound string for formatting

		if @callStackLevel = 0
		begin
			set @debugLine	= N'[Level 0] ' + @DebugString
		end
		else
		begin

			set @debugLine = N'[Level ' + ltrim(@callStackLevel) + ']'
				+ replicate(N' ', @callStackLevel - 1 ) + N'->' + @DebugString		-- for subroutines, indent 1 space for each call level

		end

		-- if a time check was provided, show the interval between it
		-- and the current time

		if @TimeCheck is not null
		begin

			set @debugLine = left(@debugLine + replicate( '.', 85), 85) 
				+ '[Previous step at level ' + ltrim(@callStackLevel) + ' completed in ' 
				+ ltrim(cast(datediff(second, @TimeCheck, sysdatetimeoffset()) as varchar(5))) + ' seconds]'

		end

		raiserror(@debugLine, 10, 1) with nowait															-- the low-severity raise with "nowait" ensures immediate display on console
		set @TimeCheck = sysdatetimeoffset()																	-- reset the time for use on the next interval
				
	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
