SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCompletionTimeBand]
/*********************************************************************************************************************************
View			: (Form) Completion Time Band
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a list of form completion time bands to use in statistical/analytical reports
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Dec 2017    |	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns a fixed list of form completion time bands applied in various analytical reports in the system. Increasing or 
decreasing the number of bands significantly may negatively impact formatting of standard product reports. Test all affected 
reports after performing maintenance on this view.

Note that reports using these bands automatically add a band for "< 15" and ">90".  The display order starts at 2 intentionally
to allow for this.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

			declare 
				@DisplayOrder int
			
			select
				@DisplayOrder	= x.DisplayOrder
			from
				dbo.vCompletionTimeBand x
			order by
				newid()

			select
			  x.StartDuration			
			 ,x.EndDuration
			 ,x.DisplayOrder
			from
				dbo.vCompletionTimeBand x
			where
				x.DisplayOrder = @DisplayOrder

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[

			select
					x.StartDuration
				,	x.EndDuration
				,	x.DisplayOrder
			from
				dbo.vCompletionTimeBand x
			order by
				x.DisplayOrder

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vCompletionTimeBand'
 ,@DefaultTestOnly = 1
 -------------------------------------------------------------------------------------------------------------------------------- */
as
select 15 StartDuration, 30 EndDuration, 2 DisplayOrder
union
select 31 StartDuration, 45 EndDuration, 3 DisplayOrder
union
select 46 StartDuration, 60 EndDuration, 4 DisplayOrder
union
select 61 StartDuration, 90 EndDuration, 5 DisplayOrder;
GO
