SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pJobSchedule#IsStarted]
as 
/*********************************************************************************************************************************
Sproc    : dbo.pJobSchedule#IsStarted
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Used to wrap the fJobSchedule#IsStarted() to circumvent EF limitation on function imports 
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Christian T	| May 2014			| Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure exists because there is currently no way in EF to import a function. You can only import stored procedures. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pJobSchedule#IsStarted

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pJobSchedule#IsStarted'
	,@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */
begin
select sf.fJobSchedule#IsStarted()
end
GO
