SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vRandomDec]
as
/*********************************************************************************************************************************
View    : Random Decimal
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns result of TSQL "rand()" function
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Dec 2014		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view exists to allow functions to call rand without violating TSQL function constraints. If rand() is used directly in a
function the error "Invalid use of a side-effecting operator ‘rand’ within a function" results.  By joining to this function
however, which always returns a single row, the error is avoided.

The value returned by the view is Decimal(18,18)

Example:
-------

<TestHarness>
  <Test Name = "Simple" IsDefault ="true" Description="Calls the view to return a random decimal value.">
    <SQLScript>
      <![CDATA[
select * from sf.vRandomDec
    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vRandomDec'
------------------------------------------------------------------------------------------------------------------------------- */

select	
	 rand() RandomDec
GO
