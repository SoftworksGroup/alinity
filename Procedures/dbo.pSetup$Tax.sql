SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$Tax]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.Tax data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Update dbo.Tax and dbo.TaxConfiguration master tables with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Aug 2017			| Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure initializes the dbo.Tax and TaxConfiguration tables with a sample records if no records exist in the table. If a
tax configuration already exists, then no changes are made.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. Previous set up data is deleted
	prior to the test.">
		<SQLScript>
		<![CDATA[
		
			delete from dbo.Tax
			dbcc checkident( 'dbo.Tax', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$Tax
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.Tax

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$Tax'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant to refer to "true" bit value

	begin try
		
		if not exists (select 1 from dbo.Tax)
		begin

			insert
				dbo.Tax
			(
					TaxLabel		
				,	TaxSequence			
			)
			values
					(N'GST', 1)
				,	(N'PST', 2)

			insert
				dbo.TaxConfiguration
			(
					TaxSID
				,	TaxRate
				,	GLAccountSID
				, EffectiveTime
			)
			values
				 ((select x.TaxSID from dbo.Tax x where x.TaxSequence = 1),.050, (select min(x.GLAccountSID) from dbo.GLAccount x where x.IsTaxAccount = @ON), sysdatetime())
				,((select x.TaxSID from dbo.Tax x where x.TaxSequence = 2),.070, (select max(x.GLAccountSID) from dbo.GLAccount x where x.IsTaxAccount = @ON), sysdatetime())

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
		
	return(@errorNo)

end
GO
