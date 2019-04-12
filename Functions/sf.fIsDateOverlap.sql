SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fIsDateOverlap
(
	@Effective1 datetime	-- start of first date-range pair
 ,@Expiry1		datetime	-- end of first date-range pair
 ,@Effective2 datetime	-- start of second date-range pair
 ,@Expiry2		datetime	-- end of second date-range pair
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Date Overlap
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a bit indicating if the 2 date range pairs overlap or duplicate each other.
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|------------------------------------------------------------------------------------------
					: Taylor N		| Jan	2018		|	Initial version

Comments	
--------
This function is used to determine if two date terms (defined by "Effective" and "Expiry" date-times)  are active at the same
time. This function is most often used in error checking contexts where terms must not overlap each other.  Note that the 
end of each term may be NULL - indicating there is no known end to the term.  While not typically expected, the function also 
supports the start of the term being null which is treated as the term beginning infinitely in the past for the purpose of the 
comparison.

There are five scenarios where the terms can overlap or duplicate as depicted below:
			                   (x)|----------------------------------------|(y)
			    (x - n)|--------------------------------------------------------------|(y + n)
			    (x - n)|------------------------------------|(y - n)
			                                  (x + n)|--------------------------------|(y + n)
			                                  (x + n)|------|(y - n)
			                  (x2)|----------------------------------------|(y2)

Example
-------
<TestHarness>
	<Test Name = "MultipleScenarios" IsDefault ="true" Description="Calls the function testing multiple scenarios.">
		<SQLScript>
			<![CDATA[

	select
			sf.fIsDateOverlap('2018-01-01',	'2018-02-28',	'2018-03-01', '2018-04-30')		NoOverlapPrior
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	'2017-11-01', '2017-12-31')		NoOverlapPost
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	'2018-01-01', '2018-12-31')		OverlapSameDates
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	'2017-12-01', '2018-06-01')		OverlapStart
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	'2018-06-01', '2019-06-01')		OverlapEnd
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	'2018-04-01', '2018-08-01')		OverlapMiddle
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	'2001-01-01', null)						OverlapNullExpiry
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	null				,	'2019-01-01')		OverlapNullEffective
		,	sf.fIsDateOverlap('2018-01-01',	'2018-12-31',	null				,	null)						NullHalfDates
		,	sf.fIsDateOverlap(null				,	null				,	null				,	null)						NullFullDates
		,	sf.fIsDateOverlap(null				,	'2018-12-31', '2001-01-01',	null)						NullMixedMid
		,	sf.fIsDateOverlap('2018-12-31', null,					null,					'2001-01-01')		NullMixedEnd
		,	sf.fIsDateOverlap('2018-01-01 00:00:00', '2018-01-01 14:00:00', '2018-01-01 12:00:00', '2018-01-01 18:00:00')		OverlapTimeStamp
		,	sf.fIsDateOverlap('2018-01-01 00:00:00', '2018-01-01 14:00:00', '2018-01-01 14:00:01', '2018-01-01 18:00:00')		NoOverlapTimeStamp

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:01"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = N'sf.fIsDateOverlap'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @isOverlap bit = cast(0 as bit); -- return value

	if (
			 -- record 2 is effective before/concurrently record 1 is effective, AND record 2 expires after/concurrently record 1 is effective
			 (
				 (
					 @Effective1 is null or @Effective2 is null or @Effective2 <= @Effective1
				 ) and (@Expiry2 >= @Effective1 or @Expiry2 is null)
			 )
			 -- record 2 is effective before/concurrently record 1 expires, and record 2 expires after/concurrently record 1 is effective
			 or
			 ((@Effective2 is null or @Effective2 <= @Expiry1) and (@Expiry2 >= @Effective1 or @Effective1 is null))
			 -- record 2 is effective after/concurrently record 1 is effective, AND record 2 is effective before/concurrently record 1 expires
			 or
			 ((@Effective2 is null or @Effective2 >= @Effective1) and (@Effective2 <= @Expiry1 or @Expiry1 is null))
		 )
	begin
		set @isOverlap = cast(1 as bit);
	end;

	return (@isOverlap);

end;
GO
