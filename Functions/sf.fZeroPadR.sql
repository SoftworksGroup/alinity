SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fZeroPadR]
(
	 @StringToPad		varchar(4000)									-- string that requires zero padding
	,@FinalLength		smallint											-- final length of the string
)
returns varchar(4000)
as
/*********************************************************************************************************************************
ScalarF		: Zero Pad (on the RIGHT)
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns string padded on the left hand side with zeros to @FinalLength
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| May 2010        |	Initial version
          : Ji Zhou     |                 | Paired and reviewed

Comments	
--------
This function is used for formatting fixed length output. It pads the string passed in with zeros on the RIGHT hand side to the
desired length.  If the string provided is already longer than the @FinalLength requested, the value will be truncated.

If either parameter is passed with NULL, then NULL is returned.

Note that the input parameter is varchar and not NVarchar. This is to make it easier to handle numerics being passed in after
spaces on the left hand side are trimmed. 

select cast(sql_variant_property(ltrim(cast(10 as int)),'BaseType') as varchar(20))					--> varchar
select cast(sql_variant_property(ltrim(cast(10.123 as float)),'BaseType') as varchar(20))		-->	varchar

Example
-------
select sf.fZeroPadR('10', 10)
select sf.fZeroPadR('10', 5)
select sf.fZeroPadR('10', 2)
select sf.fZeroPadR('100', 2)
select sf.fZeroPadR('6.4', 5)

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @zeroPad													varchar(4000)									-- return value

	if @StringToPad is not null and @FinalLength is not null
	begin
		set @zeroPad = replicate('0', @FinalLength) 
		set @zeroPad = left(@StringToPad + @zeroPad, @FinalLength)
	end

	return(@zeroPad)

end
GO
