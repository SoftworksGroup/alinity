SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fAppendString]
(
	 @targetString			nvarchar(max)																				-- the string that will appended to
	,@appendString			nvarchar(max)																				-- the string that will be appended to the target string
	,@separator					nvarchar(10)			= null														-- the separator to use if the target string is not null or empty
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Append String
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: appends a string to a target string with an optional separator - emulates StringBuilder's Add method
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Kris Dawson | Dec 2014		|	Initial Version
				:							|							|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function appends the provided string to the target string with an optional separator. If the target string is null or empty
the separator will not be appended, this supports functionality similar to StringBuilder in C#.

Example
-------

<TestHarness>
  <Test Name="Basic" IsDefault="true" Description="Five examples showing various combinations of strings">
    <SQLScript>
      <![CDATA[
      
select
	 sf.fAppendString('!!!!', '!!!!', null)
	,sf.fAppendString(null, '!!!!', null)
	,sf.fAppendString('    ', '!!!!', null)
	,sf.fAppendString(null, '!!!!', ',')
	,sf.fAppendString('!!!!', '!!!!', ',')
 
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="!!!!!!!!"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="!!!!"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="!!!!"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="!!!!"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="5" Value="!!!!,!!!!"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
    </Assertions>
  </Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fAppendString'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@result						nvarchar(max)																				-- return value

	select 
		@result = 
			case 
				when ltrim(isnull(@targetString, '')) = '' then isnull(@appendString, '')
				else @targetString + isnull(@separator, '') + isnull(@appendString, '')
			end

	return @result

end
GO
