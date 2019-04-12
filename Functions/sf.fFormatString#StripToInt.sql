SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatString#StripToInt]
(
	@StringToCheck nvarchar(50) -- string to strip non numeric content from
)
returns nvarchar(50)
as
/*********************************************************************************************************************************
ScalarF	: Strip Non-Numeric Characters and Decimals (for conversion to INT)
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the string passed in with non-numeric characters and decimal precision stripped - allows 0-9, and leading "-" only
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Oct		2017 |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in transforming strings for conversion to INT.  It relies on fFormatString#StripToInt for handling
the stripping of all non-numeric characters other than the decimal point and digits after that.  

In situations where decimal values or units of measure or other values have been added to a string - e.g. "1.25mm" - conversion to 
an int type will fail.  This procedure returns the value with the non-numeric and decimal characters stripped.

The function does include in the output a leading negative sign if provided.

If the provided string contains no numeric values, then a zero-length string is returned.  If the provide string is NULL, then
NULL is returned.

Example
-------

<TestHarness>
  <Test Name = "MultipleInputs" IsDefault ="true" Description="Passes 5 different input values to function and compares to expected result.  
 OK is returned if the expected value is produced.">
    <SQLScript>
      <![CDATA[
select 
  case when sf.fFormatString#StripToInt('1.25mm')           = '1'  then 'OK' else '*FAILED' end          TestA
 ,case when sf.fFormatString#StripToInt('-1.25mm')          = '-1' then 'OK' else '*FAILED' end          TestB
 ,case when sf.fFormatString#StripToInt('-   1.   2  5mm')  = '-1' then 'OK' else '*FAILED' end          TestC
 ,case when sf.fFormatString#StripToInt(null)               is null   then 'OK' else '*FAILED' end       TestD
 ,case when sf.fFormatString#StripToInt('Hello World!')	    = ''      then 'OK' else '*FAILED' end       TestE
    ]]> 
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="OK"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="OK"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="OK"/>      
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="OK"/>      
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="5" Value="OK"/>      
      <Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fFormatString#StripToInt'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set @StringToCheck = case
											 when charindex('.', @StringToCheck) > 0 then left(@StringToCheck, charindex('.', @StringToCheck) - 1)
											 else @StringToCheck
											 end;

	return (sf.fFormatString#StripNonNumerics(@StringToCheck));

end;
GO
