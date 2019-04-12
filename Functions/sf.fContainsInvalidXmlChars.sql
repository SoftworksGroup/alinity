SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fContainsInvalidXmlChars]
(
	 @string  												nvarchar(max)												-- the string to check for invalid xml characters
) returns bit
as
/*********************************************************************************************************************************
Function	: Check string for invalid xml characters
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns true/false as a bit depending on whether invalid characters are present
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Oct	2017		| initial version

Comments	
--------
This function checks for invalid characters (character # 0-31 excluding 9, 10 and 13)

Example:
--------

<TestHarness>
  <Test Name="Basic" IsDefault="true" Description="A valid string, an invalid string and a null">
    <SQLScript>
      <![CDATA[      
select
	 sf.fContainsInvalidXmlChars('hello world')
	,sf.fContainsInvalidXmlChars('hello' + char(2) + 'world')
  ,sf.fContainsInvalidXmlChars(null)
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="0"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="0"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
    </Assertions>
  </Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fContainsInvalidXmlChars'

------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		 @ON												bit				  = cast(1 as bit)						-- used on bit comparisons to avoid multiple casts
		,@OFF												bit				  = cast(0 as bit)						-- used on bit comparisons to avoid multiple casts
		,@forApplicationEntitySID		int																			-- used to get the SID of the app entity from the provided SCD
    ,@illegalXmlRange           varchar(50) = '%['                      -- the range to use in the like clause of the check query
                                            + char(0) 
                                            + char(1) 
                                            + char(2) 
                                            + char(3) 
                                            + char(4) 
                                            + char(5) 
                                            + char(6)
                                            + char(7) 
                                            + char(8) 
                                            + char(11) 
                                            + char(12)
                                            + char(14) 
                                            + char(15) 
                                            + char(16) 
                                            + char(17) 
                                            + char(18) 
                                            + char(19) 
                                            + char(20)
                                            + char(21) 
                                            + char(22) 
                                            + char(23) 
                                            + char(24) 
                                            + char(25) 
                                            + char(26) 
                                            + char(27)
                                            + char(28) 
                                            + char(29) 
                                            + char(30) 
                                            + char(31)
                                            + ']%'  

	return
	(
    select
      case
        when exists (select 1 where @string like @illegalXmlRange) then @ON
        else @OFF
      end
	)

end
GO
