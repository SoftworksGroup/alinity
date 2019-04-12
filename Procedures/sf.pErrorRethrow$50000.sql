SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pErrorRethrow$50000]
	 @MessageSCD  												varchar(128)				output				-- message code as found in sf.Message
	,@MessageText 												nvarchar(4000)			output				-- error message text
as
/*********************************************************************************************************************************
Sproc		: Error Re-throw 50000
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: parses the message code out of business rule error text 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| April 2010		|	Initial version
				:	Tim Edlund	|	March	2011		|	Updated documentation
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This subroutine is called during an error event.  The caller has determined that SQL error 50000 has fired. These are business 
rules errors raised explicitly by the application in response to user errors or configuration errors trapped by the application.  
In order to support error logging operations, the message code of the business rule error needs to be parsed out of the message 
text.  The code is placed into the error message in the format below by pMessage#Get:

	... some error text [MessageCode: MyMessageCode]
	
In order to make the message appear more user friendly, the message code is removed from the original text after parsing.

Example
-------
	
See parent procedure.

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin
	
	declare
		 @i 																int																-- position values for substring processing
		,@j 																int																-- position values for substring processing
		,@messageTag 												varchar(25)	= '[Message:'					-- tag to locate code in the original message string
		,@oMessageCode 											varchar(128)											-- buffer for original output parameter values:
		,@oMessageText 											nvarchar(4000)										

	set @oMessageCode		= @MessageSCD 																			-- capture original output parameter values
	set @oMessageText		= @MessageText																			

	if charindex(@messageTag, @MessageText) = 0 and len(@MessageText) <= 128 -- supports format where the message text IS the code
	begin																																						 

		set @MessageSCD  = cast(@MessageText as varchar)

		exec sf.pMessage#Get																									-- lookup the text for the code
			 @MessageSCD  = @MessageSCD 																				-- allows call to raiserror with code & no replacements
			,@MessageText = @MessageText output																	-- (no call to pMessage#Get to format text first)

	end
	else
	begin		

		set @i = charindex(@messageTag, @MessageText)													-- "message text [Message: message_code]" format													
		if @i > 0 set @j = charindex(']', @MessageText, @i + 1)								-- (the call to pMessage#Get was made before raise)

		if @i > 0 and @j > 0 
		begin

			set @i = @i + len(@messageTag)
			set @MessageSCD  = ltrim(rtrim(substring(@MessageText, @i, @j - @i)))
			set @i = @i - len(@messageTag)
			set @MessageText = substring(@MessageText, 1, @i - 1)
		end
		else																																	-- code not isolated - set to original values
		begin
			set @MessageSCD 	= @oMessageCode
			set @MessageText	= @oMessageText
		end
	end

	return(0)

end
GO
