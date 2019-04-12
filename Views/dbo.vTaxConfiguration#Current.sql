SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vTaxConfiguration#Current]
/*********************************************************************************************************************************
View		: Tax Configuration - Current Rate
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the tax rate currently in effect for each tax type
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Aug		2017		|	Initial Version
				: Cory Ng			| Feb		2018		| Added TaxRowGUID as a returned column to be used for getting alternate text for the label
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view determines the rate in effect for tax types.  It compares the effective date on the record to the current time
(in the user timezone) and returns the latest rate and GL Account key in effect. Any future dated rates are ignored.

Maintenance Note:  
-----------------
This function uses the same logic as dbo.fTaxConfiguration#Active which returns the same information and structure for
a given time.  Ensure any logic changes are copied into that function.
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	tc.TaxConfigurationSID
 ,tc.TaxSID
 ,tc.GLAccountSID
 ,t.TaxSequence
 ,t.TaxLabel
 ,ga.GLAccountCode
 ,ga.GLAccountLabel
 ,tc.TaxRate
 ,t.RowGUID									TaxRowGUID
from
(
	select
		tc.TaxConfigurationSID
	 ,row_number() over (partition by TaxSID order by EffectiveTime desc, TaxConfigurationSID) rn -- order by latest effective then SID
	from
		dbo.TaxConfiguration tc
	where
		tc.EffectiveTime <= sf.fNow() -- compare to current time in the user's timezone
)											 x
join
	dbo.TaxConfiguration tc on x.TaxConfigurationSID = tc.TaxConfigurationSID and x.rn = 1
join
	dbo.Tax							 t on tc.TaxSID							 = t.TaxSID
join
	dbo.GLAccount				 ga on tc.GLAccountSID			 = ga.GLAccountSID;
GO
