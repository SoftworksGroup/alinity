SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pMessage#Get]
	@MessageSCD		varchar(128)									-- message code to retrieve text for
 ,@MessageText	nvarchar(4000) = null output	-- formatted text to return - large enough for replacements!
 ,@DefaultText	nvarchar(1000) = null					-- default text for message (supplied by developer) 
 ,@Arg1					sql_variant = null						-- replacement text for "%1" in the message text
 ,@Arg2					sql_variant = null						-- replacement text for "%2" in the message text
 ,@Arg3					sql_variant = null						-- replacement text for "%3" in the message text
 ,@Arg4					sql_variant = null						-- replacement text for "%4" in the message text
 ,@Arg5					sql_variant = null						-- replacement text for "%5" in the message text
 ,@Arg6					sql_variant = null						-- replacement text for "%6" in the message text
 ,@Arg7					sql_variant = null						-- replacement text for "%6" in the message text
 ,@Arg8					sql_variant = null						-- replacement text for "%6" in the message text
 ,@Arg9					sql_variant = null						-- replacement text for "%6" in the message text
 ,@SuppressCode bit = 0												-- when 1 the "...[MessageSCD]" is not added to text
as
/*********************************************************************************************************************************
Sproc		: Message Get
Notice  : Copyright © 2010 Softworks Group Inc.
Summary	: Returns formatted message text with replacements for the message code passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr	2010		|	Initial version
				: Tim Edlund	| Sep	2011		| Corrected bug on existing message update where SID was not being passed
				: Tim Edlund	| Jun	2014		| Added @SuppressCode as option to avoid including "[MessageSCD]" in output string 
				: Cory Ng			| Sep	2015		| Added a 6th replacement argument parameter
				: Tim Edlund	| Jan	2018		| Added support for alternate languages. Increased to 9 replacement parameters.
				: Tim Edlund	| May 2018		| Modified so that insert/update of messages only performed where no transaction is pending
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This is a utility procedure used primarily in error messaging although it is used in other situations where a message must be 
retrieved for display to the user. A code is passed into the procedure which is looked up in the framework's "Message" table. If 
the code is not found a new message record is created for it.  Default text for this new message should be passed into the 
procedure but if no default text is provided, a message will NOT be inserted and no error is returned.

The procedure allows message text to be created for SQL errors based on inserting a code value of SQL_[ErrorNo]. This feature 
enables developers and configurators to improve the default message which would have come out of the database by creating an 
override in sf.Message. The framework provides improved messages for certain SQL errors already including:  not null constraints, 
check constraints, and foreign key violations.  For further details on these messages see the subroutines of pErrorRethrow which 
provide the default text.  

Messages may be constructed with replacement symbols in the form of "%1", "%2", etc.  These values will be replaced by the 
parameter values @Arg1, @Arg2, ...  To use the same parameter more than once in the message repeat the replacement symbol in the 
text (e.g The value found was %1 and %1 is invalid). The replacement parameters are of the sql_variant type. The actual types 
provided, however, must be convertible into nvarchar() to be valid for the procedure and the total length of the message text 
resulting cannot exceed nvarchar(4000).  Note that while the back-end could use a nvarchar(max) data type this is not supported
in all front-end contexts which receive values from this procedure.

The procedure allows developers to keep updating their default message text as the application is developed. The procedure looks 
for differences in previously inserted default message text.  When it sees the default text has been updated, the newer text 
overwrites the value previously applied in the record. 

By providing a UI to maintain the messages it may be possible for configurators and/or system administrators to improve messages
from the original values provided by the developers.  If the end users do not operate in the same language as the creators of 
the application, it will be necessary to translate all messages to the new language.  Message text can be stored for any language 
but in order to support multiple languages concurrently, the sf.Culture and sf.AltLanguage tables must be used (see below).

Alternate Language Support
--------------------------
Text store in sf.Message is expected to be in the default language - typically English.  If other languages need to be supported
internally then message text must be entered into the sf.AltLanguage table which this procedure will return when it detects
that the logged in user does not have their profile using the default "culture". The culture is obtained from the sf.Culture
table based on the FK key value (Culture-SID column) in the sf.ApplicationUser table.

The lookup for the alternate language message is carried out by selecting for the Row GUID Of the default message 
(sf.Message.RowGUID) in the Source GUID column of the sf.AltLanguage table.  If alternate text is found it is returned instead of 
the default text, otherwise the default text is returned.  

Establishing alternate text is carried out through the application UI where the sf.Message table is maintained.  Where alternate
text is required, an option must be executed to create/update a record in the sf.AltLanguage table applying the message 
RowGUID in the SourceGUID column of the target table.

Example
-------
<TestHarness>
	<Test Name = "NewMessage" IsDefault ="true" Description="Calls procedure to return text for a new test message code.">
		<SQLScript>
			<![CDATA[

declare
	 @messageText	nvarchar(4000)
	,@errorNo			int
	,@date1				date
	,@date2				datetime

set @date1 = sysdatetimeoffset()
set @date2 = sysdatetimeoffset()

delete from sf.Message where MessageSCD = 'TestMessage'

exec sf.pMessage#Get															
	 @MessageSCD  = 'TestMessage'
	,@MessageText = @messageText output
	,@DefaultText = N'Messages can accept replacement values of various data types like strings (%1), dates (%2 and %4), and numbers (%3).'
	,@Arg1				= 'Hello World'
	,@Arg2				= @date1
	,@Arg3				= 3.14
	,@Arg4				= @date2			
  
select @messageText MessageText

delete from sf.Message where MessageSCD = 'TestMessage'
  
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = N'sf.pMessage#Get'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int						 = 0										-- 0 no error, if < 50000 SQL error, else business rule
	 ,@tranCount					 int						 = @@trancount					-- determines whether a wrapping transaction exists
	 ,@blankParm					 varchar(100)														-- tracks blank values in required parameters
	 ,@ON									 bit						 = cast(1 as bit)				-- constant for bit comparisons
	 ,@callerErrorNo			 int																		-- 0 no error, if < 50000 SQL error, else business rule
	 ,@defaultTextOld			 nvarchar(1000)													-- old version of default text (if message was found)
	 ,@messageSCDFound		 bit						 = 0										-- tracks whether message text found in sf.Message
	 ,@messageSID					 int																		-- PK value on found sf.message record
	 ,@rowGUID						 uniqueidentifier												-- GUID of message record if found 
	 ,@previousMessageText nvarchar(1000)													-- message text already in the record
	 ,@systemUser					 nvarchar(75)														-- creator of records - e.g. "system@synoptec.com"
	 ,@oMessageText				 nvarchar(4000);												-- buffer for initial output parameter value

	set @oMessageText = @MessageText; -- capture original output parameter values

	begin try

		-- check parameters

		if @MessageSCD is null set @blankParm = '@MessageSCD';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get -- recursive call!
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @MessageText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@MessageText, 18, 1);

		end;

		set @MessageSCD = ltrim(rtrim(@MessageSCD)); -- format the parameters for consistency
		set @callerErrorNo = error_number(); -- business rule >=50,000, SQL error <50,000, none (0)

		select -- lookup the message code
			@MessageText		= isnull(m.MessageText, m.DefaultText)	-- if override text exists use it, otherwise default	
		 ,@defaultTextOld = m.DefaultText													-- store default text to see if it is being updated 
		 ,@messageSID			= m.MessageSID													-- store key for update
		 ,@rowGUID				= m.RowGUID
		from
			sf.Message m
		where
			m.MessageSCD = @MessageSCD;

		set @messageSCDFound = cast(@@rowcount as bit);
		set @systemUser = cast(sf.fConfigParam#Value('SystemUser') as nvarchar(75)); -- get default value for audit columns

		-- add missing codes as long as default text is provided and
		-- no transactions were pending on entry

		if @messageSCDFound = 0 
		begin

			if @DefaultText is not null and @trancount = 0
			begin

				exec sf.pMessage#Insert
					@MessageSCD = @MessageSCD
				 ,@DefaultText = @DefaultText
				 ,@CreateUser = @systemUser;

			end;

			-- even if insert can't be performed, set text output

			set @MessageText = isnull(isnull(@DefaultText, @MessageText), @MessageSCD);

		end;
		else  -- message code was found
		begin

			if @defaultTextOld is not null and @DefaultText <> @defaultTextOld -- developers have provided updated default text
			begin

				if @trancount = 0 -- avoid the update if trx is pending
				begin

					select
						@previousMessageText = MessageText	-- avoid overwriting previous custom text to NULL!
					from
						sf.Message
					where
						MessageSCD = @MessageSCD;

					exec sf.pMessage#Update
						@MessageSID = @messageSID
					 ,@DefaultText = @DefaultText
					 ,@MessageText = @previousMessageText
					 ,@UpdateUser = @systemUser;

				end;

				set @MessageText = @DefaultText; -- update the previously retrieved text block

			end;

		end;

		if @messageSCDFound = @ON
		begin
			set @MessageText = cast(sf.fAltLanguage(@rowGUID, @MessageText) as nvarchar(4000)); -- check for an alternate language version of the text for the current user
		end;

		-- replacement message arguments - insert [null] if missing

		set @MessageText = replace(@MessageText, '%1', isnull(convert(nvarchar(4000), @Arg1), '[null]'));
		set @MessageText = replace(@MessageText, '%2', isnull(convert(nvarchar(4000), @Arg2), '[null]'));
		set @MessageText = replace(@MessageText, '%3', isnull(convert(nvarchar(4000), @Arg3), '[null]'));
		set @MessageText = replace(@MessageText, '%4', isnull(convert(nvarchar(4000), @Arg4), '[null]'));
		set @MessageText = replace(@MessageText, '%5', isnull(convert(nvarchar(4000), @Arg5), '[null]'));
		set @MessageText = replace(@MessageText, '%6', isnull(convert(nvarchar(4000), @Arg6), '[null]'));
		set @MessageText = replace(@MessageText, '%7', isnull(convert(nvarchar(4000), @Arg7), '[null]'));
		set @MessageText = replace(@MessageText, '%8', isnull(convert(nvarchar(4000), @Arg8), '[null]'));
		set @MessageText = replace(@MessageText, '%9', isnull(convert(nvarchar(4000), @Arg9), '[null]'));

		-- add code to the end of the message: "[Message: MessageCode]"
		-- pErrorRethrow removes this before display (no problem with English term)

		if isnull(@callerErrorNo, 0) = 0 and @SuppressCode = cast(0 as bit)
		begin
			set @MessageText = cast(@MessageText + ' [Message: ' + @MessageSCD + ']' as nvarchar(4000));
		end;

	end try
	begin catch
		set @MessageText = @oMessageText; -- reset outputs to original value on error
		rollback;
		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error

	end catch;

	return (@errorNo);

end;
GO
