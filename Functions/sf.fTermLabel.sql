SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTermLabel]
(
	@TermLabelSCD varchar(35)		-- term label code to retrieve label for
 ,@DefaultLabel nvarchar(35)	-- default text for term label (supplied by developer) 
)
returns nvarchar(35)
as
/*********************************************************************************************************************************
Sproc		: TermLabel 
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns label text for a configurable term in the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2014		|	Initial version
				: Tim Edlund	| Jan	2018		| Added support for alternate languages. Increased to 9 replacement parameters.
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This is a utility function to lookup a term label code in the sf.TermLabel table. This allows applications to avoid hard coding
language and terminology supplied by database components in much the same was as the language provider is applied in the UI tier.
The function retrieves default or override label text based on a term label code referenced by the application. The design is 
similar to that used for customizing back-end message text (sf.Message/sf.pMessage#Get). 

Term Label is a master table providing terminology labels used by views and other database objects.  For example, by default the 
application may refer to patient cases as "case" and a database view might return a formatted label:  Case #12345”.  If the 
client prefers the term "encounter", that value can be entered in this table as an override label. This results in the view 
returning the label as:  "encounter #12345”.  The Default Label Term remains in place in the record and an override value is 
entered into the Label Term column.  The system keeps track of update times of the default and override values in order to manage 
product upgrades without overwriting user supplied values.  Note that these terms apply only to database objects and term labels 
produced from the database tier of the application.  The client-tier of the application implements a similar terminology 
configuration method using resource files (.resx) stored on the web server. 

A procedure-version of this function also exists:  sf.pTermLabel#Get.  The procedure version can be used to retrieve term label
values as an output variable but can also be used to insert new labels and update ones previously established.  This function
makes no changes to any tables so can only return labels that already exist.

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

Example:
--------

<TestHarness>
  <Test Name = "Standard" IsDefault ="true" Description="Adds a test term label and ensures it is retrieved from the table by the
        function.  Returns a second label which is not configured in the DB so that the default label passed in is returned.">
    <SQLScript>
      <![CDATA[
declare 
	@termLabel nvarchar(35)

exec sf.pTermLabel#Get															
	 @TermLabelSCD	= 'TEST.TERM.LABEL'
	,@TermLabel			= @termLabel output
	,@DefaultLabel	= N'Test Label Value'
  ,@UsageNotes    = N'Use this label for testing only.  Delete me!'

select 
	 sf.fTermLabel('TEST.TERM.LABEL', 'X Value')				TestResult1
	,sf.fTermLabel('NOT.DEFINED', 'No Label In Table')	TestResult2

delete 
	sf.TermLabel 
where 
	TermLabelSCD = 'TEST.TERM.LABEL'

    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Test Label"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="No Label In Table"/>      
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	@ObjectName = 'sf.fTermLabel'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@termLabel nvarchar(35)				-- return value
	 ,@rowGUID	 uniqueidentifier;	-- GUID of label record if found 


	set @TermLabelSCD = ltrim(rtrim(@TermLabelSCD));

	select -- lookup the term label code
		@termLabel = isnull(tl.TermLabel, tl.DefaultLabel)	-- if override label text exists use it, otherwise default	
	 ,@rowGUID	 = tl.RowGUID
	from
		sf.TermLabel tl
	where
		tl.TermLabelSCD = @TermLabelSCD;

	if @rowGUID is not null -- check for an alternate language version of the text for the current user
	begin
		set @termLabel = cast(sf.fAltLanguage(@rowGUID, @termLabel) as nvarchar(35));
	end;

	return (isnull(@termLabel, @DefaultLabel));

end;
GO
