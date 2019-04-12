SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fErrorDetailsStrip]
(			
	 @ErrorText														nvarchar(4000)										-- error text to strip detail block out of
)
returns nvarchar(4000)
as
/*********************************************************************************************************************************
Sproc		: Error Details Strip
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: removes the technical details block from error message text provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | April 2010    |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in the test harness to remove the error details block.  

The error details block begins with the text: "[Error:" or "<ErrorNo>" depending on whether or not a user session has been set 
(see also sf.pUserSession#Set). In the test harness it is desirable to remove this block because it contains the line number of the 
error and minor changes in the sproc (even vertical spacing) will cause the line number to change.  Since using CHECKSUM comparisons 
on the resulting dataset from the test is a common assertion method, any change in line number requires resetting the checksum.  
By removing this block the need to reset checksums is greatly reduced.

Example
-------

declare
	@errorText				nvarchar(4000)

set @errorText = 
'The entry was not allowed because it would create a duplicate. The value for column(s): "ConfigParamGroupCode" must be unique in the sf.ConfigParamGroup table. [Error: 2627 | Severity: 16 | State: 1 | Procedure: pConfigParamGroupInsert | Line: 79 | Column: null  | Message: duplicate_key]'

select sf.fErrorDetailsStrip(@errorText)

set @errorText = 
'<Exception><MessageText>The entry was not allowed because it would create a duplicate. The value for column(s): "ConfigParamGroupCode" must be unique in the sf.ConfigParamGroup table.</MessageText><ErrorNo>2627</ErrorNo><ErrorSeverity>16</ErrorSeverity><ErrorState>1</ErrorState><ErrorProcedure>pConfigParamGroupInsert</ErrorProcedure><ErrorLine>79</ErrorLine><MessageCode>duplicate_key</MessageCode></Exception>'

select sf.fErrorDetailsStrip(@errorText)

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare 
		 @i          												int																-- character position for start of details tag
		,@j																	int																-- character position for end of details tag

	set @i = charindex( '[Error:', @ErrorText)

	if @i > 0
	begin
		set @ErrorText = left(@ErrorText, @i - 1)
	end

	set @i = charindex( '<ErrorNo>', @ErrorText)

	if @i > 0
	begin
		set @ErrorText = left(@ErrorText, @i - 1) + N'</Exception>'
	end
	 
	return(@ErrorText)

end
GO
