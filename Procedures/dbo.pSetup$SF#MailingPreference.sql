SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#MailingPreference]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
  ,@Language                      char(2)                                 -- language to install for
  ,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.MailingPreference data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.MailingPreference master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Feb		2017		| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure provides initial values for the sf.MailingPreference table. This is not a system-code table so the records are
suggestions only and no code dependencies exist for any values.  This procedure will only insert the records if the table is 
empty.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set 
	up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[

			exec dbo.pSetup$sf#MailingPreference
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.MailingPreference

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#MailingPreference'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for bit comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for bit comparisons

		
	begin try

    -- only insert suggested values if the table is empty!
    
    if not exists( select 1 from sf.MailingPreference )
    begin
    
			insert
				sf.MailingPreference
			(
				 MailingPreferenceLabel	
				,UsageNotes									
				,IsAutoOptIn
				,CreateUser
				,UpdateUser
			) 
			values
				 (N'Non-Optional'	,N'Non-optional email subscription, by accepting terms of use of the application the person has consented to receiving this class of email'	,@ON	,@SetupUser, @SetupUser)
				,(N'Commercial'		,N'An optional email subscription which contains promotional or advertising content.'																												,@ON	,@SetupUser, @SetupUser)

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
