SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pErrorRethrow$Check]
	 @MessageSCD  												varchar(128)							output	-- message code as found in sf.Message
	,@MessageText 												nvarchar(4000)						output	-- error message text
	,@ErrorSeverity 											int												output	-- severity: 16 user, 17 configuration, 18 program 
	,@ColumnNames													xml												output	-- column list on which business rule error occurred
	,@RowSID															int												output	-- primary key value on row where error occurred
as
/*********************************************************************************************************************************
Sproc		: Error Re-throw Check
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: parses text for errors raised through constraints and returns a more user friendly version
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep 2011			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This subroutine is called during an error event that is raised from a check constraint.  The error is raised by setting 
the message parameters into a string (formatted with XML tags) and then a cast to a bit is attempted on that string.  If no
error conditions are detected in the check constraint function, the string is set to '1' and the cast succeeds.  The cast-to-bit
fails when error parameters have been placed into the string and the message produced exposes all the required message parameters 
in the raised message text.  This procedure parses out the elements of the error and returns them as output parameters.

The caller has determined that this type of error occurred by looking for a specific pattern of XML tagging in the
message text (see pErrorRethrow).

Following is an example of the format retrieved in error_message() from a captured check constraint error 
(line breaks were added):

	Conversion failed when converting the nvarchar value '<err><cs><c>ExpiryTime</c><c>AnotherColumn</c></cs>
	<msg cd="AssignmentClosedTermRequired" rw=12345>An expiry date is required. Correct the entry or ask your group 
	administrator to change settings to allow open-ended terms.</msg></err>' to data type bit'	

In the example above the "rw" attribute defines the row - usually system ID (SID) - where the error occurred.  This value
is useful where the constraint can be raised in non-UI situations and so the explicit row with the error (on an update) is
not easily determined. 

It is also possible to format replacement arguments into the message using parameters: arg1, arg2, ... arg5.  For example:

	Conversion failed when converting the nvarchar value '<err><cs><c>PostalCodeStart</c><c>PostalCodeEnd</c></cs>
	<msg cd="PostalCodeRangeOverlaps" rw=12345 arg1="Edmonton North">The postal code range overlaps another range.  The
	first overlapping range detected is: %1.</msg></err>' to data type bit'	

The replacement argument defined as "arg1" replaces the "%1" symbol in the default message text.  See also pMessage#Get.

This procedure parses out the message code, default text, column names, etc. from the message text and then attempts to find 
custom error text for that message in the sf.Message table. The code used to lookup the error is parsed out of the message
text itself. 

Example
-------
	
See parent procedure.

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @i 																int																-- character position for substring processing
		,@j 																int																-- character position for substring processing
		,@messageXML												xml																-- message converted to XML for parsing
		,@oMessageSCD 											varchar(128)											-- buffer for original output parameter value:
		,@oMessageText 											nvarchar(4000)										-- reset to this value if unable to parse
		,@oErrorSeverity 										int																-- reset to this value if unable to parse
		,@defaultText												nvarchar(1000)										-- buffer for parsed default text
		,@Arg1 															nvarchar(4000) 										-- replacement text for "%1" in the message text
		,@Arg2 															nvarchar(4000) 										-- replacement text for "%2" in the message text
		,@Arg3 															nvarchar(4000) 										-- replacement text for "%3" in the message text
		,@arg4 															nvarchar(4000) 										-- replacement text for "%4" in the message text
		,@arg5 															nvarchar(4000) 										-- replacement text for "%5" in the message text

	set @RowSID					= null
	set @oMessageSCD		= @MessageSCD 
	set @oMessageText		= @MessageText																			-- capture original output parameter values
	set @oErrorSeverity	= @ErrorSeverity							

	set @i = charindex('<err>', @messageText)
	set @j = charindex('</err>', @messageText)
		
	if @i > 0 and @j > 0																										-- if the tags are not found, return text as provided	
	begin																																		-- otherwise parse out components using XML
		
		set @messageXML = convert(xml, substring(@messageText, @i, @j + 6 - @i))

		set @ErrorSeverity	= 16																														-- set severity to 16 - this is a business rule violation
		set @MessageSCD			= @messageXML.value('(/err/msg/@cd)[1]', 'varchar(128)' )				-- parse message code out of XML
		set @RowSID					= @messageXML.value('(/err/msg/@rw)[1]', 'int' )								-- parse record SID out of XML
		set @Arg1						= @messageXML.value('(/err/msg/@arg1)[1]', 'nvarchar(4000)' )		-- parse replacement arguments out of XML:
		set @Arg2						= @messageXML.value('(/err/msg/@arg2)[1]', 'nvarchar(4000)' )		-- up to 5 supported - 0 required
		set @Arg3						= @messageXML.value('(/err/msg/@arg3)[1]', 'nvarchar(4000)' )
		set @arg4						= @messageXML.value('(/err/msg/@arg4)[1]', 'nvarchar(4000)' )
		set @arg5						= @messageXML.value('(/err/msg/@arg5)[1]', 'nvarchar(4000)' )
		set @defaultText		= @messageXML.value('(/err/msg)[1]', 'nvarchar(1000)' )					-- parse default text out of XML

		set @ColumnNames =																										-- could be multiple columns, return as xml value
		(
			select
				Properties.Name.value('.', 'nvarchar(128)') as "@Name"
			from
				@messageXML.nodes('/err/cs/c') as Properties(Name)
			for
				xml path('Property'), root('Properties')
				
		)

		-- ensure 0 length argument strings are set to null

		if len(ltrim(@Arg1)) = 0 set @Arg1 = null
		if len(ltrim(@Arg2)) = 0 set @Arg2 = null
		if len(ltrim(@Arg3)) = 0 set @Arg3 = null
		if len(ltrim(@arg4)) = 0 set @arg4 = null
		if len(ltrim(@arg5)) = 0 set @arg5 = null
													
		-- the call below looks up message text for the message code parsed in the sf.Message table
		-- if no message exists for the code, a new record is added with default text; if the default
		-- text has not been overridden in the table, it will be updated with any new version parsed here

		exec sf.pMessage#Get																									-- looks up or adds the message if code is not found
			 @MessageSCD  = @MessageSCD
			,@MessageText = @MessageText output
			,@DefaultText = @defaultText
			,@Arg1				= @Arg1
			,@Arg2				= @Arg2
			,@Arg3				= @Arg3
			,@Arg4				= @arg4
			,@Arg5				= @arg5

	end
	else
	begin
		set @MessageSCD 		= @oMessageSCD
		set @MessageText		= @oMessageText																		-- code not isolated - return original values
		set @ErrorSeverity	= @oErrorSeverity							
		set @ColumnNames		= null
	end

	return(0)

end
GO
