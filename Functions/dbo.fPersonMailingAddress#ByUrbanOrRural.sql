SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonMailingAddress#ByUrbanOrRural]
(
	@StartYear smallint -- the first year in the range to include in the analysis
 ,@EndYear	 smallint -- the last year in the range to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Registrant By Year and Gender
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns urban/rural area statistics for Canadian addresses within a range of years
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Dec 2017			|	Initial Version | CANADA ONLY!
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports analysis of living locations of members according to a "rural" or "urban" designation.  It returns one row 
for each year and urban/rural area combination.  The end user will typically select a range of years for the analysis which are
the parameters of the function.

The values may be visualized as a line or area chart, or with filtering - as a series of pie charts.  The analysis
uses the current (latest) postal code setting for each registrant.

Limitation
----------
End users cannot adjust the urban/rural selections available in the application.  The definition of what makes an address rural
and urban is set by the postal code.  Note that this analysis is only valid in the current version for Canadian postal
codes.  Analysis of US zip and codes from other countries is not supported in this version. 

Test(s)
-------
<TestHarness>
  <Test Name = "TenYears" IsDefault ="true" Description="Selects content from the table function using a 10-year time span ending 
	with the current year">
    <SQLScript>
      <![CDATA[
declare
	@startYear smallint
 ,@endYear	 smallint = datepart(year, sysdatetime());

set @startYear = @endYear - 10;

select
	z.RuralOrUrban
 ,z.TotalAddresses
 ,z.AddressYear
from
	dbo.fPersonMailingAddress#ByUrbanOrRural(@startYear, @endYear) z
order by
	z.TotalAddresses
 ,z.AddressYear desc;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fPersonMailingAddress#ByUrbanOrRural'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

as
return select
					z.AddressYear
				,z.RuralOrUrban
				,count(1) TotalAddresses
			 from (
							select
								yr.AddressYear
							 ,(case when substring(pma.PostalCode, 2, 1) = '0' then 'Rural' else 'Urban' end) RuralOrUrban
							from
							(
								select distinct
									year(pma.EffectiveTime) AddressYear
								from
									dbo.PersonMailingAddress pma
								where
									(year(pma.EffectiveTime) between @StartYear and @EndYear)
							)							yr
							cross apply (
														select
															x.PersonSID
														 ,max(x.EffectiveTime) EffectiveTime
														from
															dbo.PersonMailingAddress x
														join
															dbo.City								 cty on x.CitySID						= cty.CitySID
														join
															dbo.StateProvince				 sp on cty.StateProvinceSID = sp.StateProvinceSID
														join
															dbo.Country							 cntry on sp.CountrySID			= cntry.CountrySID
														where
															cntry.CountryName					= 'Canada'				-- analysis is only supported for CANADA !
															and year(x.EffectiveTime) <= yr.AddressYear -- a cross apply's WHERE clause can refer to a predecessor table
														group by
															x.PersonSID
													) zMx
							join
								dbo.PersonMailingAddress pma on zMx.PersonSID = pma.PersonSID and zMx.EffectiveTime = pma.EffectiveTime -- join to the record for the person with the Effective Time found above
						) z
			 group by
				 z.AddressYear
				,z.RuralOrUrban;
GO
