SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fStripInvalidXmlChars]
(
	 @string  												nvarchar(max)												-- the string to check for invalid xml characters
  ,@replacement                     varchar(25) = ''                    -- the string to replace invalid characters with
) returns nvarchar(max)
as
/*********************************************************************************************************************************
Function	: Strip Invalid Xml Chars
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns the provided string with invalid xml characters stripped
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Oct	2017		| initial version

Comments	
--------
This function replaces invalid characters (character # 0-31 excluding 9, 10 and 13), fContainsInvalidXmlChars can be
used before invoking this function to check for the existence of invalid xml in a string.

Example:
--------

<TestHarness>
  <Test Name="Basic" IsDefault="true" Description="Strips a valid string, an invalid string and a null">
    <SQLScript>
      <![CDATA[      
select
	 sf.fStripInvalidXmlChars('hello world','')
	,sf.fStripInvalidXmlChars('hello ' + char(2) + 'world','')
  ,sf.fStripInvalidXmlChars(null,'')
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="hello world"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="hello world"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value=""/>
      <Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
    </Assertions>
  </Test>
  <Test Name="Different string replacement" IsDefault="false" Description="Strips an invalid string but replaces the character with '?'">
    <SQLScript>
      <![CDATA[      
select
	 sf.fStripInvalidXmlChars('hello ' + char(2) + 'world', '?')
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="hello ?world"/>			
      <Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fStripInvalidXmlChars'

------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		 @ON												bit				  = cast(1 as bit)						-- used on bit comparisons to avoid multiple casts
		,@OFF												bit				  = cast(0 as bit)						-- used on bit comparisons to avoid multiple casts

  if @string is not null
  begin
    
    set @replacement = isnull(@replacement, '')
    set @string = replace(@string, char(0), @replacement)
    set @string = replace(@string, char(1), @replacement)
    set @string = replace(@string, char(2), @replacement)
    set @string = replace(@string, char(3), @replacement)
    set @string = replace(@string, char(4), @replacement)
    set @string = replace(@string, char(5), @replacement)
    set @string = replace(@string, char(6), @replacement)
    set @string = replace(@string, char(7), @replacement)
    set @string = replace(@string, char(8), @replacement)
    set @string = replace(@string, char(11), @replacement)
    set @string = replace(@string, char(12), @replacement)
    set @string = replace(@string, char(14), @replacement)
    set @string = replace(@string, char(15), @replacement)
    set @string = replace(@string, char(16), @replacement)
    set @string = replace(@string, char(17), @replacement)
    set @string = replace(@string, char(18), @replacement)
    set @string = replace(@string, char(19), @replacement)
    set @string = replace(@string, char(20), @replacement)
    set @string = replace(@string, char(21), @replacement)
    set @string = replace(@string, char(22), @replacement)
    set @string = replace(@string, char(23), @replacement)
    set @string = replace(@string, char(24), @replacement)
    set @string = replace(@string, char(25), @replacement)
    set @string = replace(@string, char(26), @replacement)
    set @string = replace(@string, char(27), @replacement)
    set @string = replace(@string, char(28), @replacement)
    set @string = replace(@string, char(29), @replacement)
    set @string = replace(@string, char(30), @replacement)
    set @string = replace(@string, char(31), @replacement)

  end
    
	return(@string)

end
GO
