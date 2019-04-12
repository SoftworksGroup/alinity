SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatUserName]
(
   @UserName                              nvarchar(75)                    -- user name to reformat
)
returns nvarchar(75)
as 
/*********************************************************************************************************************************
Function: Format User Name
Notice  : Copyright ©2014 Softworks Group Inc.
Summary	: Returns user name formatted in corporate standard:  "username@org.domain" 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| June 2014			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function formats user names for lookup in the sf.ApplicationUser table. The function ensures the user name is provided in 
lowercase.  If a the value is passed  in with a backslash separating the domain, e.g. "sgi\fj.cruiser", it is returned with the
domain separated by the "@" sign - e.g. "fj.cruiser@sgi".

Example
-------

<TestHarness>
  <Test Name="Basic" IsDefault="true" Description="Tests reformatting results for typical scenarios.">
    <SQLScript>
      <![CDATA[
      
select
	 sf.fFormatUserName( 'tim.e@softworksgroup.com' )															NoChange
	,sf.fFormatUserName( 'TIM.E@softworksgroup.com' )															CaseCorrections
	,sf.fFormatUserName( 'permitsy.com\tim.e' )															DomainPlacement 
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="tim.e@softworksgroup.com"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="tim.e@softworksgroup.com"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="tim.e@softworksgroup.com"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute @ObjectName = 'sf.fFormatUserName'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
     @charPosition                      int                               -- character position used in reformatting user name

	set @UserName     = lower(@UserName)																		-- reformat: "sgi\fj.cruiser" => "fj.cruiser@sgi"
	set @charPosition = charindex('\', @UserName)
	if @charPosition  > 0 set @UserName = substring(@UserName,@charPosition + 1, 75) + '@' + left(@UserName, @charPosition - 1)
	
	return @UserName

end
GO
