SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ApplicationPageHelp]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- locale (country) to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ApplicationPageHelp data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Inserts progressive help content into sf.ApplicationPageHelp
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ----------- |-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov		2015  | Initial Version
				 : Richard K		| Jan		2015	| Updated some of the references from person to contact
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------
This procedure is responsible for establishing the progressive help text used in the application.  The content is stored in the
sf.ApplicationPageHelp table. Note that ALL the content in the current version of the table is DELETEd prior to the new content
being added. It is critical therefore, that this procedure be updated with any new help text prior to running it on the database!

Progressive help can be edited through the application itself when developer ID's are detected.  The resulting text is stored
into the sf.ApplicationPageHelp table.  To incorporate that text into this procedure, extract it using the following script:

declare
	 @CRLF				nchar(2)		= char(13) + char(10)
	,@TABS				nchar(2)		= replicate(char(9), 2)
	,@insertSQL		nvarchar(max) = N''
	
select top 10000																													-- note: TOP clause required to establish consistent behaviour of multi-row assignments!
		@insertSQL = @insertSQL + @CRLF 
	+ @TABS  
	+ 'insert sf.ApplicationPageHelp (ApplicationPageHelpID,StepSequence,ApplicationPageSID,HelpContent) values '
	+ '(' 
	+ '''' + aph.ApplicationPageHelpID + ''''
	+ ','	+ sf.fPadL(ltrim(aph.StepSequence), 3)
	+ @CRLF + @TABS + char(9) + ',(select x.ApplicationPageSID from sf.ApplicationPage x where x.ApplicationPageURI = ''' + (select x.ApplicationPageURI from sf.ApplicationPage x where x.ApplicationPageSID = aph.ApplicationPageSID) + ''')'
	+ @CRLF + @TABS + char(9) + ',''' + replace(aph.HelpContent, '''', '''''') + ''''
	+ ')' + @CRLF
from
	sf.ApplicationPageHelp aph
order by
		aph.ApplicationPageHelpID
	,aph.StepSequence

exec sf.pLinePrint @insertSQL

Example:
--------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Runs setup for sf.ApplicationPage then deletes content of application page help table and repopulates it.">
		<SQLScript>
			<![CDATA[

exec dbo.pSetup$SF#ApplicationPage 
	 @SetupUser = 'system@softworksgroup.com'
	,@Language = 'en'
	,@Region = null

exec dbo.pSetup$SF#ApplicationPageHelp 
	 @SetupUser = N'system@softworksgroup.com'
	,@Language  = 'en'
	,@Region		= null
	
select * from sf.ApplicationPageHelp

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$SF#ApplicationPageHelp'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
																																																																			
	begin try

		-- CAUTION ------------------------------------------------ prior content deleted!!
		delete sf.ApplicationPageHelp
		dbcc checkident( 'sf.ApplicationPageHelp', reseed, 1000000) with NO_INFOMSGS
		-----------------------------------------------------------
 		
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
		
	return(@errorNo)

end
GO
