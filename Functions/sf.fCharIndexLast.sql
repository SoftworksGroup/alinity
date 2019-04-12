SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fCharIndexLast]
(
	 @SearchValue											 nvarchar(250)												-- the character(s) to search for
	,@String                           nvarchar(4000)												-- the string to search in
)
returns int
as
/*********************************************************************************************************************************
ScalarF		: CharIndex Last
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns the last occurrence of the search value in the string 
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Dec 2014		|	Initial version
					: Tim Edlund	| Feb 2015		| Updated to improve performance by eliminating loop.  Now based on reverse() function.

Comments	
--------
This is a helper function to return the last occurrence of a character or sequence of characters within another string.  It 
uses charindex and accepts parameters in the same order as charindex to carry out the search.  If the value is not found in
the string then 0 is returned

Example
-------

<TestHarness>
	<Test Name = "Simple" IsDefault ="true" Description="Searches a string for a comma which should be found at position 15.">
		<SQLScript>
			<![CDATA[
select 
	 sf.fCharIndexLast( ',','red,green,blue,purple')										"Passed if 15"
	,sf.fCharIndexLast( 'hello','hello.world.hello.world.hello.world')  "Passed if 25"
	,sf.fCharIndexLast( 'doh','hello.world.hello.world.hello.world')		"Passed if 0"
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="15"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="25"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="0"/>
			<Assertion Type="ExecutionTime" Value="00:00:01"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fCharIndexLast'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@charIndexLast		int

	set @charIndexLast = charindex(reverse(@SearchValue), reverse(@String))	-- use reverse to run search from end of string 

	if isnull(@charIndexLast,0) > 0																					-- if value is not found, return 0
	begin																																		-- otherwise adjust reverse index found for string lengths
	
		set @charIndexLast =
		(
				len(@String) 
			- (
					@charIndexLast
				+ (len(@SearchValue) - 1)
				)
			+ 1
		)

	end

	return(@charIndexLast)

end
GO
