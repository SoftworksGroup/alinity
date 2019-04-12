SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fConfigParamDataType]
(			
	 @ConfigParamCode											varchar(25)												-- config parameter code to retrieve data type for
)
returns varchar(15)
as
/*********************************************************************************************************************************
Function: Configuration Parameter Data Type
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the data type of a configuration parameter as stored in sf.ConfigParam
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | April 2010    |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns the data type of the configuration parameter matching the code passed in.  Configuration parameters are 
stored in the sf.ConfigParam table.  Unlike prior versions of the framework, all configuration values are stored as nvarchar data 
types but the data type the value should convert to is stored in the DataType column on the record.  Any conversion required must 
be handled by the caller and this function can be used to retrieve the data type to convert to.  A related function - 
sf.fConfigParamDataValue can be used to retrieve the actual value of the parameter.

If the parameter name is not found a null value is returned.

Example
-------

select sf.fConfigParamDataType('ApplicationName')
select sf.fConfigParamDataType('ConfigErrorSuffix')
select sf.fConfigParamDataType('ProgramErrorSuffix')
select sf.fConfigParamDataType('SystemUser')
select sf.fConfigParamDataType('bad_param_code')

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		@dataType 													varchar(15)												-- value to return

		set @ConfigParamCode = lower(@ConfigParamCode)
		
		select
				@dataType = cp.DataType
		from
				sf.ConfigParam cp
		where
				cp.ConfigParamSCD	= @ConfigParamCode
		
		return(@dataType)

end
GO
