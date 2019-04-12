SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fErrorStripXML]
(			
	 @ErrorText														nvarchar(4000)										-- error text to convert from XML format
)
returns nvarchar(4000)
as
/*********************************************************************************************************************************
Sproc		: Error Strip XML
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Converts error message passed as string but containing XML tags to a simple string
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Feb 2014			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used primarily in logging operations where an error has occurred and the message raised is formatted using 
XML syntax.  While XML syntax is the desired format for reporting errors to the UI, when the error is occurring in a batch process
and needs to be logged, a simple text string format is required.  This function retrieves the message text and other details
and returns those as a formatted string without including XML tags.

If the string passed does not contain the XML markup expected for an error message, then the string is returned unmodified.

Following is a typical example of the @ErrorText expected (CR LF added):

<Exception>
	<MessageText>The Provider assigned is marked inactive. Only active assignments are allowed. [SID=1000115]</MessageText>
	<ErrorNo>245</ErrorNo>
	<ErrorSeverity>16</ErrorSeverity>
	<ErrorState>1</ErrorState>
	<ErrorProcedure>pProvider#Delete</ErrorProcedure>
	<ErrorLine>314</ErrorLine>
	<Properties>
		<Property Name="ProviderSID"/>
	</Properties>
	<MessageCode>AssignmentToInactiveParent.ProviderSID</MessageCode>
</Exception> at procedure "pErrorRethrow" line# 195

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Pass a typical error message containing XML tags and convert it to a formatted string for logging.">
		<SQLScript>
			<![CDATA[
declare
	@errorText   nvarchar(4000)
	
set @errorText = N'<Exception><MessageText>The Provider assigned is marked inactive. Only active assignments are allowed. [SID=1000115]</MessageText><ErrorNo>245</ErrorNo><ErrorSeverity>16</ErrorSeverity><ErrorState>1</ErrorState><ErrorProcedure>pProvider#Delete</ErrorProcedure><ErrorLine>314</ErrorLine><Properties><Property Name="ProviderSID"/></Properties><MessageCode>AssignmentToInactiveParent.ProviderSID</MessageCode></Exception> at procedure "pErrorRethrow" line# 195'
 
select sf.fErrorStripXML(@errorText) as ErrorAsString
 
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fErrorStripXML'
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare 
		 @errorString											nvarchar(4000)											-- the error message as formatted string (return value)
		,@errorXML												xml																	-- buffer to convert input string as xml if tags found
		,@i																int																	-- string position for opening XML tag
		,@j																int																	-- string position for closing XML tag

	set @i = charindex(N'<Exception>', @ErrorText)													-- search for expected tags
	set @j = charindex(N'</Exception>', @ErrorText)

	if @i > 0 and @j > 0
	begin
		set @errorXML = cast(substring(@ErrorText, @i, (@j + 12) - @i) as xml)-- convert input text to XML document between the tags

		select																																-- retrieve the message components from converted XML
			@errorString = 
			cast
				(
					ex.node.value('MessageText[1]', 'nvarchar(4000)')				
				+ N' [Error#:' + ltrim(ex.node.value('ErrorNo[1]', 'int'))
				+ N' Procedure:' + ex.node.value('ErrorProcedure[1]', 'nvarchar(128)')	
				+ N' Line#:' + ltrim(ex.node.value('ErrorLine[1]', 'int')) + ']'
				as nvarchar(4000)
				)
		from
			@errorXML.nodes('Exception') as ex(node) 	

	end
	else
	begin
		set @errorString = @ErrorText																					-- otherwise return the text without changing it
	end
	 
	return(@errorString)

end
GO
