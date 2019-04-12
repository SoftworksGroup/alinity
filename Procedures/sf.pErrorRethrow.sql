SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pErrorRethrow]
as
/*********************************************************************************************************************************
Sproc		: Error Re-throw 
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: retrieves message text from error event, reformats it, and re-raises it to the calling procedure
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr 2010		|	Initial version
				:	Tim Edlund	|	Mar	2011		|	Updated documentation
				: Tim Edlund	| Sep 2011		| Added support for check constraint errors (see also $Check subroutine)
        : Tim Edlund  | Aug 2012    | Updated all references to SystemSCD to increase length from 75 to 128 characters. 
				: Tim Edlund	| May 2018		| Removed rollback on pending transactions.  Rollbacks must be processed by caller!
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure is intended to be called in CATCH blocks.  The procedure retrieves the content of the error including the error 
message text and, depending on the error number, attempts to improve the default error text provided by SQL.

For certain SQL error numbers, error text stored by the framework in the sf.Message table is looked up and parameters retrieved 
out of the original message string are used to provide context in the message.  For example, in the case of not null constraints 
the column which has been left blank is replaced in the message text.  The SQL error types receiving this type of processing are:

515 	- not null constraints	- reclassified as severity 16 (user error)
547 	- foreign key and check constraint errors - reclassified as severity 18 (program error)
2627	- duplicate key errors	- reclassified as severity 17 (configuration error).

A subroutine is used for the formatting of each of these errors including replacement text.  LIMITATION: The algorithm of each of
these subroutines is dependent on the way the executing version of SQL Server formats its error text in English. Upgrades to 
future versions of SQL Server, or formatting used in other languages, may require updates and/or branches to the algorithms.

This procedure does not rollback transactions that are pending.  Rollbacks must be processed by the caller.

Custom text in the sf.Message table can be created for SQL error numbers other than those identified above, however, there are 
2 limitations:
	
	1) the code used to store the message in sf.Message must be in the format "SQL[ErrorNo]" and 
	2) replacement values cannot be processed for these specific error types.  

The reason for creating custom error text for other SQL errors would be to attempt to improve upon the default error text provided 
by SQL Server. Keep in mind, however, that the default text provided by SQL Server will be provided in the native language of the 
SQL install (while custom text will likely be provided in the language of the development team), and, replacement values are 
supported by SQL Server in the default text and cannot be supported for custom text. 

Errors caught and raised explicitly by the application's back-end are referred to as business rule errors.  These types are errors 
are raised in 2 ways: 

1. Error number 50,000 indicates a business rule violation raised explicitly by the application in response to user errors or 
	 configuration errors trapped by the application in procedures.  In order to support error logging operations, the message code 
	 of the business rule error is parsed out of the message text but otherwise the text is left the same as it was raised in the 
   error event.  A subroutine handles that processing.

	 For error number 50000 the routine also checks to see it appears a message code only has been raised.  In most cases the 
   calling procedure will already have looked up and raised the message text for a given message code since that is the only way 
   to get replacements into the text message.  For backward compatibility, however, it is possible for the caller to call 
   "raiserror" with the message code only.  In that situation the text for the code will be looked up but this approach will not 
   support replacement parameters (see also sf.pMessage#Get). This procedure will look up the code to obtain the full text from 
   sf.Message whenever the message text is <= 128 characters in length.  

2. Raising business rules from check constraints is also supported, and provides superior protection for data integrity.  This 
   method raises the error by setting error message parameters into a string (formatted with XML tags) and then an attempt is made 
   to cast it to a bit.  If no error conditions are detected in the check constraint function, the string is set to '1' and the 
   cast succeeds.  The cast-to-bit fails when error parameters have been placed into the string and the message produced exposes 
   all the required message parameters in the raised message text.  A subroutine $Check parse the elements of the error.

	Following is an example of the format retrieved in error_message() from a captured check constraint error (line breaks were 
  added):

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

	The replacement argument defined as "arg1" replaces the "%1" symbol in the default message text. Values can also be provided for
	"arg2" through "arg5" which replace "%1" through "%5" in the default text.  See also pMessage#Get.

The XML formatting required is simplified by passing the parameters involved to the function:  sf.fCheckErrorString which adds the
required XML formatting/tagging. See also sf.fCheckErrorString.

For business rule violations set to severity 17 (configuration error) or 18 (program error), the procedure looks up standard text 
to add to the end of the message as a suffix.  This is done to reduce the amount of repetitive text required in the sf.Message 
table.  The suffix text is stored in the sf.ConfigParam table and can be updated for any language. (See code below for the 
parameter codes.) This text should instruct the user on next steps to perform when these error severities are encountered. For 
example - the standard suffix might say something like:  

"Please retry.  If the error persists registrant technical support at 555-555-5555."   

Standard suffix text is not looked up and added to error severity 16 (user errors) since corrective action is typically variable 
for these errors and should be embedded in the message text directly.

The final format of the message text raised is impacted by whether or not it appears an application user is logged in. This is 
determined by looking at the session context.  (See sf.pUserSession#Set)  If no application user is detected, the procedure 
operates as if debugging from the back-end and the message text is raised as a simple string and with information about where the 
error was originally raised included at the end. English prefixes are hardcoded into the end of the string since debugging is to 
be performed by the development team only.  If a user session is detected, then the message is formatted as an XML document. The 
information included is the same, however, XML is used to simplify parsing for presentation by the user interface.

Because this procedure re-throws the error after processing the message, it is necessary to avoid subsequent attempts to process 
the message. This is achieved by setting the error state for the next raise to 255.  This special value identifies to this routine 
that the message has already been processed and no further processing is required.

Example
-------

declare
		@errorNo 						int = 0																
	 ,@blankParm					nvarchar(100)													
	 ,@messageText				nvarchar(4000)												
	 ,@myParm							nvarchar(100)													

begin try

	--exec sf.pUserSession#Set																								-- uncomment/comment to see impact of logged in session	
	--	 @UserName				= 'c.brown@sample.com'
	--	,@IPAddress				= '10.0.0.1'

	if @myParm is null set @blankParm = '@MyParm'								

	if @blankParm is not null 													
	begin
			
		exec sf.pMessage#Get
			 @MessageSCD  	= 'BlankParameter'
			,@MessageText 	= @MessageText output
			,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
			,@Arg1					= @blankParm

		raiserror(@MessageText, 18, 1)																				-- raise the error passing the retrieved message text

	end

end try

begin catch
	exec @errorNo = sf.pErrorRethrow	
end catch
------------------------------------------------------------------------------------------------------------------------------- */ 
			
begin

	set nocount on
	
	declare
		 @errorNo 													int																-- 0 no error, if < 50000 SQL error, else business rule
		,@errorProc 												nvarchar(128)											-- procedure error was generated from
		,@messageText 											nvarchar(4000)										-- error message text
		,@errorSeverity 										int																-- severity: 16 user, 17 configuration, 18 program 
		,@errorState 												int																-- between 0 and 127 (MS has not documented these!)
		,@errorLine 												int																-- line number in the calling procedure
		,@messageSCD  											varchar(128)											-- message code as found in sf.Message
		,@columnName 												nvarchar(128)											-- column name or comma delimited column name list
		,@columnNames 											xml																-- column name or column name list returned FOR XML
		,@rowSID														int																-- PK value on record where error occurred ($check only)
		,@MINLOGGINGSEVERITY								int							= 17							-- minimum error severity for logging error messages (treat as constant)
		,@messageXML 												xml																-- error message values in XML format (re-thrown value)	
		,@isBusinessRuleError								bit							= 0								-- indicates is a BR error - these are not logged

	set @errorNo 													= isnull(error_number(), 0)				-- retrieve error event values
	set @errorState 											= error_state()
	set @errorSeverity 										= error_severity()
	set @errorProc 												= error_procedure()
	set @errorLine 												= error_line()
	set @messageText 											= error_message()

	if @errorNo <> 0																												-- if errorNo = 0; no error - nothing to do!	
	begin

		if @errorNo = 50000 and @errorState = 255															-- error was previously re-thrown  - just re-throw it
		begin	
			raiserror(@messageText, @errorSeverity, @errorState)																								
		end
		else																																	-- error was not previously re-thrown
		begin

			-- parse certain common SQL messages and lookup improved message 
			-- text for them in the sf.Message table

			if @errorNo = 515																										-- not null constraint - override
			begin

				exec sf.pErrorRethrow$515
					 @MessageSCD  		= @messageSCD 			output
					,@MessageText 		= @messageText			output
					,@ErrorSeverity 	= @errorSeverity		output
					,@ColumnName			= @columnName				output

			end		
			else if @messageText like N'%<err>%</err>%'													-- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					 @MessageSCD  		= @messageSCD 			output
					,@MessageText 		= @messageText			output
					,@ErrorSeverity 	= @errorSeverity		output
					,@ColumnNames			= @columnNames			output
					,@RowSID					= @rowSID						output

				if @rowSID is not null																						-- add PK value onto end of message text
				begin
					set @messageText = convert(nvarchar(1900), @messageText + N' [SID=' + convert(varchar(10), @rowSID) + ']')
				end

				set @isBusinessRuleError = 1

			end
			else if @errorNo = 547																							-- fk and check constraints - override
			begin

				exec sf.pErrorRethrow$547
					 @MessageSCD  		= @messageSCD 			output
					,@MessageText 		= @messageText			output
					,@ErrorSeverity 	= @errorSeverity		output
					,@ColumnNames			= @columnNames			output

			end
			else if @errorNo = 2627																							-- unique key constraint - override
			begin
			
				exec sf.pErrorRethrow$2627
					 @MessageSCD  		= @messageSCD 			output
					,@MessageText 		= @messageText			output
					,@ErrorSeverity 	= @errorSeverity		output
					,@ColumnNames			= @columnNames			output

			end
			else if @errorNo < 50000																						-- look for custom message on all other SQL errors
			begin
			
				set @MessageSCD  = 'SQL'	+ convert(varchar(10), @errorNo)				-- MessageCode format must be:  SQL[errorNo]
				set @errorSeverity = 18																						-- all other SQL errors set to "program error" severity
			
				exec sf.pMessage#Get																											
					 @MessageSCD  = @messageSCD 																		-- look for message override
					,@MessageText = @messageText output
					
			end
			else if @errorNo = 50000																						-- business rule violation
			begin
			
				exec sf.pErrorRethrow$50000
					 @MessageSCD  		= @messageSCD 			output
					,@MessageText 		= @messageText			output

			end

			-- for configuration and program errors - add suffix text to advise user what to do next (from config table)

			if @errorSeverity = 17 set @messageText += isnull(' ' + sf.fConfigParam#Value('ConfigErrorSuffix'), '')
			if @errorSeverity = 18 set @messageText += isnull(' ' + sf.fConfigParam#Value('ProgramErrorSuffix'), '')

			-- log the error if the severity meets the threshold

			if @errorSeverity >= @MINLOGGINGSEVERITY and @isBusinessRuleError = 0	and @@trancount = 0 -- business rule violations raised via check constraint are not logged here
			begin

				exec sf.pErrorRethrow$Log
					 @ErrorNo										= @errorNo
					,@ErrorProc									= @errorProc
					,@ErrorLine									= @errorLine
					,@ErrorSeverity							= @errorSeverity
					,@ErrorState								= @errorState
					,@MessageSCD  							= @messageSCD 
					,@MessageText 							= @messageText

			end

			-- if context is set, return as a string in XML format for the 
			-- front end to work with
			
			if isnull(cast(context_info() as int),0) > 0
			begin
			
				if @columnNames is null and @columnName is not null								-- store single columns in XML
				begin
				
					set @columnNames =
						(
							select
								@ColumnName	as [@Name]
							for
								xml path('Property'), root('Properties') 
						)				
				
				end

				set @messageXML = 																																			
					(
					select
							@messageText 		MessageText
						 ,@errorNo 				ErrorNo
						 ,@errorSeverity 	ErrorSeverity
						 ,@errorState 		ErrorState
						 ,@errorProc 			ErrorProcedure
						 ,@errorLine 			ErrorLine
						 ,@columnNames
						 ,@messageSCD  		MessageCode
					for
						xml path('Exception')
					)

					set @messageText = convert(nvarchar(4000), @messageXML)			

			end
			else -- no context, must be testing so include debug information!
			begin

				-- copy XML column name set into comma delimited list

				if @columnName is null and @columnNames is not null
				begin


					select 
						@columnName = isnull( @columnName + ',', '') + ColumnNames.Name.value('.', 'nvarchar(128)')
					from
						@columnNames.nodes('/Properties/Property/@Name') as ColumnNames(Name)

				end

				if @columnName is null set @columnName = N'null'				

				set @messageText = 
					cast
					(
						@messageText + ' [Error: %d | Severity: %d | State: %d | Procedure: %s | Line: %d | Column: %s  | Message: %s]'
						as nvarchar(4000)																			
					)																																-- just for debug so OK to have English prefixes

			end

			-- and finally re-throw the error with state = 255 so it will not be 
			-- processed again on subsequent re-throw calls up through the stack

			raiserror																																					
			(
				 @messageText
				,@errorSeverity
				,255																																 
				,@errorNo    
				,@errorSeverity
				,@errorState
				,@errorProc
				,@errorLine
				,@columnName
				,@messageSCD 
			)

		end

	end
			
	return(@errorNo)
	
end
GO
