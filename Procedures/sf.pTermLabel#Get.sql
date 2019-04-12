SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTermLabel#Get]
	@TermLabelSCD varchar(35)									-- term label code to retrieve label for
 ,@TermLabel		nvarchar(35)	= null output -- term label text to return
 ,@DefaultLabel nvarchar(35)	= null				-- default text for term label (supplied by developer) 
 ,@UsageNotes		nvarchar(max) = null				-- optional - notes about where the term is applied
as
/*********************************************************************************************************************************
Sproc		: Term Label Get
Notice  : Copyright © 2012 Softworks Group Inc.
Summary	: Returns label text for a configurable term in the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Tim Edlund	| May	2012		|	Initial version
				: Tim Edlund	| Jan	2018		| Added support for alternate languages.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This is a utility procedure used to support configuration of terminology in the application.  The procedure  retrieves default or 
override label text based on a term label code passed in.  The values are stored in the sf.TermLabel table. The design is similar 
to that used for customizing message text (sf.Message/sf.pMessage#Get). 

Term Label is a master table providing terminology labels used by views and other database objects.  For example, by default the 
application may refer to patient cases as “Case” and a database view might return a formatted label:  “Case #12345”.  If the 
client prefers the term “Encounter”, that value can be entered in this table as an override label. This results in the view 
returning the label as:  “Encounter #12345”.  The Default Label Term remains in place in the record and an override value is 
entered into the Label Term column.  

The database keeps track of update times of the default and override values in order to manage product upgrades without 
overwriting user supplied values.  Note that these terms apply only to database objects and term labels produced from the database 
tier of the application.  The client-tier of the application implements a similar terminology configuration method using resource 
files (.resx) stored on the web server. 

If Term Label code passed in is not found a new term label record is created for it.  Default text for this new term label should 
be passed into the procedure but if no default text is provided, a term label will NOT be inserted and no error is returned.

No replacements are supported for term labels (unlike pMessage#Get).

The procedure allows developers to keep updating their default term label text as the application is developed.  The procedure 
looks for differences in previously inserted default term label text.  When it sees the default text has been updated, the newer 
text overwrites the value previously in the record. 

By providing a UI to maintain the label values it may be possible for configurators and/or system administrators to better 
align application terminology with the terminology generally in use in the organization.  If the end users do not operate in the 
same language as the creators of  the application, it will be necessary to translate all messages to the new language.  Label 
text can be stored for any language but in order to support multiple languages concurrently, the sf.Culture and sf.AltLanguage 
tables must be used (see below).

Alternate Language Support
--------------------------
Text store in sf.TermLabel is expected to be in the default language - typically English.  If other languages need to be supported
internally then label text must be entered into the sf.AltLanguage table which this procedure will return when it detects
that the logged in user does not have their profile using the default "culture". The culture is obtained from the sf.Culture
table based on the FK key value (Culture-SID column) in the sf.ApplicationUser table.

The lookup for the alternate language label is carried out by selecting for the Row GUID Of the default label 
(sf.TermLabel.RowGUID) in the Source GUID column of the sf.AltLanguage table.  If alternate text is found it is returned instead 
of the default text, otherwise the default text is returned.  

Establishing alternate text is carried out through the application UI where the sf.TermLabel table is maintained.  Where alternate
text is required, an option must be executed to create/update a record in the sf.AltLanguage table applying the term label 
RowGUID in the SourceGUID column of the target table.

Test Harness
------------
<TestHarness>
	<Test Name = "NewMessage" IsDefault ="true" Description="Calls procedure to return label for a new test label code.">
		<SQLScript>
			<![CDATA[

declare
	 @termLabel	nvarchar(4000)
	,@errorNo			int

delete from sf.TermLabel where TermLabelSCD = 'TestTermLabel'

exec sf.pTermLabel#Get															
	 @TermLabelSCD	= 'TestTermLabel'
	,@TermLabel			= @termLabel output
	,@DefaultLabel	= N'Test Label Value'
  ,@UsageNotes    = N'Use this label for testing only.  Delete me!'

select @termLabel TermLabel

delete from sf.TermLabel where TermLabelSCD = 'TestTermLabel'
  
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = N'sf.pTermLabel#Get'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)										-- message text (for business rule errors)
	 ,@ON									bit							= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@blankParm					varchar(100)											-- tracks blank values in required parameters
	 ,@defaultLabelOld		nvarchar(35)											-- old version of term label (if message was found)
	 ,@termLabelSCDFound	bit							= 0								-- tracks whether term label found in sf.TermLabel
	 ,@termLabelSID				int																-- PK value on found sf.term label record
	 ,@rowGUID						uniqueidentifier									-- GUID of label record if found 
	 ,@previousTermLabel	nvarchar(35)											-- term label text already in the record
	 ,@previousUsageNotes nvarchar(max)											-- usage notes already in the record
	 ,@systemUser					nvarchar(75);											-- creator of records - e.g. "system@synoptec.com"

	set @TermLabel = null; -- to populate in all code paths

	begin try

		-- check parameters

		if @TermLabelSCD is null set @blankParm = '@TermLabelSCD';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		set @TermLabelSCD = ltrim(rtrim(@TermLabelSCD)); -- format the parameter for consistency

		select -- lookup the term label code
			@TermLabel			 = isnull(tl.TermLabel, tl.DefaultLabel)	-- if override label text exists use it, otherwise default	
		 ,@defaultLabelOld = tl.DefaultLabel												-- store default label to see if it is being updated 
		 ,@termLabelSID		 = tl.TermLabelSID												-- store key for update
		 ,@rowGUID				 = tl.RowGUID
		from
			sf.TermLabel tl
		where
			TermLabelSCD = @TermLabelSCD;

		set @termLabelSCDFound = cast(@@rowcount as bit); -- track whether code was found
		set @systemUser = cast(sf.fConfigParam#Value('SystemUser') as nvarchar(75)); -- get default value for audit columns

		-- add missing codes as long as default label text is provided and
		-- no un-committable transaction is pending

		if @termLabelSCDFound = 0
		begin

			if @DefaultLabel is not null and xact_state() <> -1
			begin

				exec sf.pTermLabel#Insert
					@TermLabelSCD = @TermLabelSCD
				 ,@DefaultLabel = @DefaultLabel
				 ,@UsageNotes = @UsageNotes
				 ,@CreateUser = @systemUser;

			end;

			-- even if insert can't be performed, set label output to the code value
			-- so that a null is not returned to the UI

			set @TermLabel = isnull(isnull(@DefaultLabel, @TermLabel), @TermLabelSCD);

		end;
		else -- term label code was found
		begin

			if @defaultLabelOld is not null and @DefaultLabel <> @defaultLabelOld -- developers have provided updated default label
			begin

				if xact_state() <> -1 -- avoid the update if trx is pending and un-committable
				begin

					select
						@previousTermLabel	= TermLabel																-- avoid overwriting previous custom label to null
					 ,@previousUsageNotes = isnull(@previousUsageNotes, UsageNotes) -- avoid overwriting previous usage notes to null
					from
						sf.TermLabel
					where
						TermLabelSCD = @TermLabelSCD;

					exec sf.pTermLabel#Update
						@TermLabelSID = @termLabelSID
					 ,@DefaultLabel = @DefaultLabel
					 ,@TermLabel = @previousTermLabel
					 ,@UsageNotes = @previousUsageNotes
					 ,@UpdateUser = @systemUser;

				end;

				set @TermLabel = @DefaultLabel; -- update the previously retrieved label block with the new default

			end;

		end;

		if @termLabelSCDFound = @ON -- check for an alternate language version of the text for the current user
		begin
			set @TermLabel = cast(sf.fAltLanguage(@rowGUID, @TermLabel) as nvarchar(35));
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
