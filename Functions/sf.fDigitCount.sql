SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fDigitCount 
(
@StringToSearch nvarchar(max) -- string to search for digits in
)
returns int
as
/*********************************************************************************************************************************
Function: Digit Count
Notice  : Copyright © 2019 Softworks Group Inc.
Summary	: Returns the count of digits in the string passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Feb 2019		|	Initial version

Comments
--------
This is a utility function used to count the number of occurrence of digits (0-9) appears in the string passed in.  The algorithm 
replaces the digit values with a zero-length string and compares the starting and ending string lengths. 

Note: If a NULL string is passed in then 0 is returned as the count of digits rather than NULL.

Example:
--------

<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Execute the procedure to return the count of digits from a few different strings.">
    <SQLScript>
      <![CDATA[
select
	'mhp18332145920p03' Test1
	,sf.fDigitCount('mhp18332145920p03') [Result1=13]
	,'THIS_1_EXAMPLE_HAS_2_NUMBERS_IN_IT' Test2
	,sf.fDigitCount('mhp18332145920p03') [Result2=2]
	,'None' Test3
	,sf.fDigitCount('None') [Result3=0]
	,null Test4
	,sf.fDigitCount(null) [Result4=0]
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>  
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'sf.fDigitCount'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @DigitCount int;

	select
		@DigitCount =
		(len(@StringToSearch) * 10)
		- (len(replace(@StringToSearch, '0', '')) + len(replace(@StringToSearch, '1', '')) + len(replace(@StringToSearch, '2', ''))
			 + len(replace(@StringToSearch, '3', '')) + len(replace(@StringToSearch, '4', '')) + len(replace(@StringToSearch, '5', ''))
			 + len(replace(@StringToSearch, '6', '')) + len(replace(@StringToSearch, '7', '')) + len(replace(@StringToSearch, '8', ''))
			 + len(replace(@StringToSearch, '9', ''))
			);

	return isnull(@DigitCount, 0);

end;
GO
