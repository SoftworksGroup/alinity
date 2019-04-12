SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fConfigParam#DefaultValue]
(			
	 @ConfigParamCode											varchar(25)												-- configuration parameter code to retrieve value for
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
Function: Configuration Parameter DEFAULT Value
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the DEFAULT value of a configuration parameter
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | May 2012	    |	Initial Version
				: Adam Panter	| June  2014		| Scalar value Assertions cannot be empty. Wrapping in an isnull to compare.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns the DEFAULT value of the configuration parameter matching the code passed in.  The function is very similar
to sf.fConfigParamValue except that the default value stored for the parameter is returned regardless of whether or not an override
value has been entered into the configuration.  The function is most typically used in procedures that "reset" configuration 
parameters back to the default values set at installation.

The values are retrieved from the sf.ConfigParam table.  Unlike prior versions of the framework, all configuration values are stored 
as nvarchar data types.  Any conversion required must be handled by the caller.  A related function - sf.fConfigParamDataType can be 
used to determine the SQL data type of the parameter value.

If the parameter name is not found a null value is returned.

The table stores the default value for each parameter (DefaultParamValue), and also a configuration specific value (ParamValue) 
where the value can be set through a UI component.  Not all configuration parameter values can be changed; the column "IsReadOnly" 
can be inspected to determine if the value is updatable.  If a configuration specific value is not stored, the default value 
is returned.

Example
-------


<TestHarness>
   <Test Name="fConfigParamDefaultValue_BadCode" IsDefault="true" Description="Tries to find a code that shouldn't exist">
    <SQLScript>
      <![CDATA[
				select isnull(sf.fConfigParam#DefaultValue('bad_param_code'), 0)														-- returns NULL
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="0"/> 
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>

	<Test Name="fConfigParamDefaultValue_ClientTimeZoneOffset" Description="Checks that the ClientTimeZoneOffset exists">
    <SQLScript>
      <![CDATA[
				select sf.fConfigParam#DefaultValue('ClientTimeZoneOffset')													-- returns NULL
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1" Row="1" Column="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>

	<Test Name="fConfigParamDefaultValue_SMPTPORT"  Description="Tries to convert the SMTP port to a small int">
    <SQLScript>
      <![CDATA[

			begin try
 
				select convert(smallint	, sf.fConfigParam#DefaultValue('SMTPPort'))	
 
			end try
			begin catch
 
  			select 
    			'ERROR'						TestResult
    			,error_number()		ErrorNo
    			,error_message()	ErrorMessage
 
			end catch
			
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1" Row="1" Column="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>
	</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fConfigParam#DefaultValue'
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare 
		@paramValue 												nvarchar(max)											-- value to return

		set @ConfigParamCode = lower(@ConfigParamCode)
		
		select
				@paramValue = cp.DefaultParamValue
		from
				sf.ConfigParam cp
		where
				cp.ConfigParamSCD	= @ConfigParamCode
		
		return(@paramValue)

end
GO
