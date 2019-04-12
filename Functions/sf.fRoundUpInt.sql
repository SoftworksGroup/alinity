SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fRoundUpInt]
(
	@Number								int							-- the number to be rounded
 ,@DecimalPlaces				int							-- pass as negative to round up from 10's (-1), 100's (-2), etc.
)
returns int
as
/*********************************************************************************************************************************
ScalarF : sf.fRoundUpInt
Notice  : Copyright © 2014 Softworks Group Inc.
Summary : returns a integer value - rounded up
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep		2011  |	Initial version

Comments	
--------
This function is used to force upward rounding.  This is a wrapper function which calls sf.fRoundUp to perform the operation.  The 
casting to and from the FLOAT value is taken care of by this function.  See sf.fRoundUp for logic details.

An integer is always returned, however, a negative value for @DecimalPlaces will cause the rounding to 10', 100's etc.

Example
-------
select sf.fRoundUpInt( 112, -1)					=> 120

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @numberRounded						int								-- return value
		,@numberAsFloat						float							-- casted value

	set @numberAsFloat = cast(@Number as float)
	set @numberRounded = cast(sf.fRoundUp(@numberAsFloat, @DecimalPlaces) as int)

	return(@numberRounded)
end
GO
