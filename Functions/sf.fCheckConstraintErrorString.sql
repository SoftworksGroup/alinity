SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fCheckConstraintErrorString]
(
	 @MessageSCD											varchar(75)												-- message code to lookup on error
	,@DefaultMessageText							nvarchar(1000)		= null					-- message text to apply to code unless override has been created
	,@ColumnNames											nvarchar(500)			= null					-- name(s) of the column with error (if multiple split with a comma)
	,@RowSID													int								= null					-- primary key value (SID) where error occurred
	,@Arg1 														nvarchar(1000) 		= null					-- replacement text for "%1" in the message text
	,@Arg2 														nvarchar(1000) 		= null					-- replacement text for "%2" in the message text
	,@Arg3 														nvarchar(1000) 		= null					-- replacement text for "%3" in the message text
	,@Arg4 														nvarchar(1000) 		= null					-- replacement text for "%4" in the message text
	,@Arg5 														nvarchar(1000) 		= null					-- replacement text for "%5" in the message text
)
returns nvarchar(1900)
as
/*********************************************************************************************************************************
ScalarF	: Check Constraint Error String
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: formats parameter values passed as string with XML tags for parsing later via pErrorRethrow
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Sep 2010    |	Initial Version
				:							|							|
-----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in check constraints to return a string that contains error information.  The function is a component of 
the business rule enforcement through check constraints placed on tables.  The check constraint placed on the table makes a 
call to a function "p<TableName>Check" which is passed all values from the record as parameters.  The business rule logic is
contained within the function.

An error is raised by the function by setting the message parameters into a string returned by this function.  An attempt is then
made in the function to cast the string into a bit value (which fails).  If no error conditions are detected in the check constraint 
function, the string is set to '1' and the cast succeeds.  The cast-to-bit fails when error parameters have been placed into the 
string and the message produced exposes all the required message parameters in the raised message text.  The pErrorRethrow
procedure subroutines parse out the elements of the error and deliver a properly formatted message.

If the @MessageSCD value is NULL, the string returned is '1'.  That value will cast successfully to a bit and no error
will be raised.

Following is an example of the format retrieved in error_message() from a captured check constraint error:

	Conversion failed when converting the nvarchar value '<err><cs><c>ExpiryTime</c><c>AnotherColumn</c></cs>
	<msg cd="AssignmentClosedTermRequired">An expiry date is required. Correct the entry or ask your group 
	administrator to change settings to allow open-ended terms.</msg></err>' to data type bit'

Example
-------

-- test by violating check constraint and calling error handler

<TestHarness>
  <Test Name="fCheckConstraintErrorString" IsDefault="true" Description="Exercises the fCheckConstraintErrorString() function with
	a randomly selected Message record.">
    <SQLScript>
      <![CDATA[
				declare
					 @messageSID			int
					,@errorNo					int

				select top (1)																															-- find a message record at random
					@messageSID = m.MessageSID
				from
					sf.[Message] m
				where
					len(m.MessageSCD) between 2 and 65

				begin try

					update																																	-- attempt to violate the "no spaces allowed" rule
						sf.[Message]
					set
						MessageSCD = ltrim(rtrim(left(MessageSCD, 1) + ' ' + substring(MessageSCD, 2, 64)))
					where
						MessageSID = @messageSID

					select MessageSCD from sf.[Message] where MessageSID = @messageSID

				end try
				begin catch
					exec @errorNo = sf.pErrorRethrow																				-- catch the error and handle replacement values
				end catch
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fCheckConstraintErrorString'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @errorText												nvarchar(1900)	= N'1'								-- error string with components formatted with XML tags
		
	if @MessageSCD is not null
	begin
	
		set @errorText = 
			convert
				(
				nvarchar(1900), 
				N'<err>' + isnull(N'<cs><c>' + replace(@ColumnNames, ',', '</c><c>') + N'</c></cs>', '') 
				+ N'<msg' + isnull(N' cd="' + @MessageSCD + N'"', '')
				+ isnull(N' rw="' + convert(varchar(10), @RowSID) + N'"', '')
				+ isnull(N' arg1="' + convert(nvarchar(1000), @Arg1) + N'"', '') 
				+ isnull(N' arg2="' + convert(nvarchar(1000), @Arg2) + N'"', '')
				+ isnull(N' arg3="' + convert(nvarchar(1000), @Arg3) + N'"', '')
				+ isnull(N' arg4="' + convert(nvarchar(1000), @Arg4) + N'"', '')
				+ isnull(N' arg5="' + convert(nvarchar(1000), @Arg5) + N'"', '')
				+ N'>' 			
				+ replace(replace(isnull(@DefaultMessageText, N''), '<', '&lt;'), '>', '&gt;') + N'</msg></err>'
				)
				
	end

	return(@errorText)
end
GO
