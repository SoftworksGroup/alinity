SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fTaxConfiguration#Active] (@TransactionTime datetime)
returns table
/*********************************************************************************************************************************
View		: Tax Configuration - Active Rates 
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the taxes and rates in effect at the given date
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan 2018			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns determines the rate in effect for tax types at a given transaction date.  It is required for reposting 
transactions to the GL and for certain reporting requirements.  It compares the effective date on the record to the date 
(in the user timezone) and returns the latest rate and GL Account key(s) in effect. Any future dated rates are ignored.

Maintenance Note:  
-----------------
This function uses the same logic as dbo.vTaxConfiguration#Current which returns the same information and structure for
the current date-time. Ensure any logic changes are copied into that view.
Example
-------
<TestHarness>
	<Test Name="Simple" Description="Updates the current price and ensures the the updated price is returned">
		<SQLScript>
			<![CDATA[


			begin tran

			select 
					TaxSequence
				,	TaxLabel
				,	GLAccountCode
				,	GLAccountLabel
				,	TaxRate
			from
				dbo.fTaxConfiguration#Active (sf.fNow())

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="1" Row="1" Value="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="2" Row="1" Value="GST" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="3" Row="1" Value="301" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="4" Row="1" Value="Tax Account" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="5" Row="1" Value="0.0500" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="1" Row="2" Value="2" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="2" Row="2" Value="PST" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="3" Row="2" Value="301" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="4" Row="2" Value="Tax Account" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="5" Row="2" Value="0.0700" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fTaxConfiguration#Active'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return select
					tc.TaxConfigurationSID
				,tc.TaxSID
				,tc.GLAccountSID
				,t.TaxSequence
				,t.TaxLabel
				,ga.GLAccountCode
				,ga.GLAccountLabel
				,tc.TaxRate
			 from
				(
					select
						tc.TaxConfigurationSID
					 ,row_number() over (partition by TaxSID order by EffectiveTime desc, TaxConfigurationSID) rn -- order by latest effective then SID
					from
						dbo.TaxConfiguration tc
					where
						tc.EffectiveTime <= @TransactionTime -- compare to current time in the user's timezone
				)											 x
			 join
				 dbo.TaxConfiguration tc on x.TaxConfigurationSID = tc.TaxConfigurationSID and x.rn = 1
			 join
				 dbo.Tax							t on tc.TaxSID							= t.TaxSID
			 join
				 dbo.GLAccount				ga on tc.GLAccountSID				= ga.GLAccountSID;
GO
