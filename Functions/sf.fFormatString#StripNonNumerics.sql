SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatString#StripNonNumerics]
(			
	 @StringToCheck						nvarchar(50)																	-- string to strip non numeric content from
)
returns nvarchar(50)
as
/*********************************************************************************************************************************
ScalarF	: Strip Non-Numeric Characters (for conversion to INT/Decimal)
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the string passed in with non-numeric characters stripped - allows 0-9, decimal point and leading "-" only
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Jul		2014 |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in transforming strings for conversion to INT and DECIMAL data types.  In situations where units of measure
or other values have been added to a string - e.g. "1.25mm" - conversion to a numeric type will fail.  This procedure returns the
value with the non-numeric characters stripped.

The function does include in the output a leading negative sign if provided, and ALL occurrences of decimal points. If the string
contains multiple decimal point values any subsequent attempt to convert to a numeric will fail!

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
  case when sf.fFormatString#StripNonNumerics('1.25mm')           = '1.25'  then 'OK' else '*FAILED' end          TestA
 ,case when sf.fFormatString#StripNonNumerics('-1.25mm')          = '-1.25' then 'OK' else '*FAILED' end          TestB
 ,case when sf.fFormatString#StripNonNumerics('-   1.   2  5mm')  = '-1.25' then 'OK' else '*FAILED' end          TestC
 ,case when sf.fFormatString#StripNonNumerics(null)               is null   then 'OK' else '*FAILED' end          TestD
 ,case when sf.fFormatString#StripNonNumerics('Hello World!')	    = ''      then 'OK' else '*FAILED' end          TestE
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
	@ObjectName = 'sf.fFormatString#StripNonNumerics'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @numericString						nvarchar(50)																-- return value - string with non numerics stripped
		,@i												int																					-- loop index
		,@charCount								int																					-- loop limit - characters to process
		,@ON									
				bit 					= cast(1 as bit)							-- constant to reduce repetitive casting
		,@OFF											bit 					= cast(0 as bit)							-- constant to reduce repetitive casting

	if @StringToCheck is not null 
	begin

		set @StringToCheck	= ltrim(rtrim(@StringToCheck))
		set @charCount			= len(@StringToCheck)
		set @numericString	= N''
		set @i							= 0

		while @i < @charCount
		begin
			set @i += 1
			if charindex(substring(@StringToCheck,@i,1),'0123456789.') <> 0 set @numericString += substring(@StringToCheck, @i, 1)
		end

		if left(@StringToCheck,1) = '-' set @numericString = cast(N'-' + @numericString as nvarchar(50))

	end

	return(@numericString)

end
GO
