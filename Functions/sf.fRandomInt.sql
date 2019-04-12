SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fRandomInt]
(
	 @Lower							int																									-- lowest possible random value to return
	,@Upper							int																									-- highest possible random value to return
)
returns int
as
/*********************************************************************************************************************************
Function: Random Integer
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns a random integer between (inclusive) the low and high limit provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Dec 2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used in selecting records for audit or in generation of sample data.  The function returns a random integer
within the (inclusive) range specified.  Distribution within the range is typically even, however, spikes can occur.

Example:
--------

<TestHarness>
	<Test Name = "CheckDistribution" IsDefault ="true" Description="Calls the random function 100 times and stores results grouped by
value so that distribution of the random integers can be checked. A range of 1-4 is used.">
		<SQLScript>
			<![CDATA[
declare
	@i int = 0

declare
	@test table
( 
	Value int not null
)

while @i < 100
begin
	set @i += 1
	insert @test (value) values(sf.fRandomInt(1,4))
end

select
	x.Value
	,count(1)  CountOfValue
from
	@test x
group by
	x.value
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="4" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fRandomInt'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @RandomInt					int

	select
		@RandomInt = floor(((@Upper - @Lower + .9999999999) * x.RandomDec + @Lower))
	from
		sf.vRandomDec x																												-- selects from view to avoid function cerror (see view)

	return (@RandomInt)
end
GO
