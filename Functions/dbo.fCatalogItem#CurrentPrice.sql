SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fCatalogItem#CurrentPrice
(
	@CatalogItemSID int				-- item to return current price for
 ,@EffectiveTime	datetime	-- date for which current price should be obtained to support pro-rating (when null = current date)
)
returns table
/*********************************************************************************************************************************
Function	: Catalog Item - Current Price
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the current price in effect for the catalog item and effective date specified
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version
					: Tim Edlund	| Jul 2018		| Corrected error in prorate factor multiplication and add key of prorating record to output
					: Tim Edlund	| Jan 2019		| Corrected error in selection of prorated prices where registration year start <> Jan
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function determines the price in effect for a specific catalog item. Prices are stored in the Catalog Item Price table
but may also included pro-rated versions of the price which are stored in the Catalog Item Price Proration table.  The 
functions compares the effective date on the main Price record to obtain the full price which always applies if no @EffectiveTime
parameter is provided. 

When an effective time is passed in, the function checks whether a prorated price exists for the month and day contained in the 
date passed in. While a date-time data type is used for the parameter, proration is always based on the date and month in 
the registration year only (converted to a MMDD string). When comparing the MMDD in the table to the current date, the month
value is adjusted through a function so that if the fiscal year start is April for example, then the month of January is
compared as the 10th month in the year rather than the first. Proration can be set as an explicit amount in the table or may be
defined as a percentage of the full price.

When an effective time is not passed in (passed as NULL), then a prorated price is never returned.  The full price in effect
as of the current date is returned instead without discount.

A business rule ensures that pro-ration is not entered for catalog items marked as late fee.s

Example
-------
<TestHarness>
	<Test Name="Random" Description="Calls function for record selected at random">		
		<SQLScript>
			<![CDATA[

declare @catalogItemSID int;

select top (1)
	@catalogItemSID = ci.CatalogItemSID
from
	dbo.CatalogItem ci
order by
	newid();

if @@rowcount = 0 or @catalogItemSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.CatalogItemPriceSID
	 ,x.CatalogItemPriceProrationSID
	 ,x.Price		CurrentPrice
	 ,x.IsProrated
	 ,ci.CatalogItemLabel
	 ,ci.EffectiveTime
	 ,cip.Price FullPrice
	from
		dbo.CatalogItem																									 ci
	cross apply dbo.fCatalogItem#CurrentPrice(ci.CatalogItemSID, null) x
	left outer join
		dbo.CatalogItemPrice					cip on x.CatalogItemPriceSID					= cip.CatalogItemPriceSID
	left outer join
		dbo.CatalogItemPriceProration lrp on x.CatalogItemPriceProrationSID = lrp.CatalogItemPriceProrationSID
	where
		ci.CatalogItemSID = @catalogItemSID;

end;

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fCatalogItem#CurrentPrice'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

as
return
(
	select
		x.CatalogItemPriceSID
	 ,cipp.CatalogItemPriceProrationSID
	 ,(case
			 when @EffectiveTime is null then x.CurrentPrice
			 when cipp.Price <> 0.0 then cipp.Price
			 else cast(isnull((cipp.PercentageOfCurrentPrice / 100.000), 1) * x.CurrentPrice as decimal(11, 2))
		 end
		)																							 Price
	 ,cast(cipp.CatalogItemPriceProrationSID as bit) IsProrated
	from
	(
		select
			prfp.CatalogItemPriceSID
		 ,prfp.Price CurrentPrice
		from
		(
			select
				prfp.CatalogItemPriceSID
			 ,row_number() over (order by EffectiveTime desc) rn	-- order by latest effective then SID
			from
				dbo.CatalogItemPrice prfp
			where
				prfp.CatalogItemSID = @CatalogItemSID and prfp.EffectiveTime <= isnull(@EffectiveTime, sf.fNow()) -- compare to current time in the user's timezone
		)											 x
		join
			dbo.CatalogItemPrice prfp on x.CatalogItemPriceSID = prfp.CatalogItemPriceSID
		where
			x.rn = 1
	)																x
	left outer join
	(
		select
			cip.CatalogItemPriceSID
		 ,max(cipp.CatalogItemPriceProrationSID) CatalogItemProrationSID
		from
			dbo.CatalogItemPrice					cip
		join
			dbo.CatalogItemPriceProration cipp on cip.CatalogItemPriceSID = cipp.CatalogItemPriceSID
		left outer join
		(
			select
				month(rsy.YearStartTime) YearStartMonth
			from
				dbo.RegistrationScheduleYear rsy
			where
				rsy.RegistrationYear = dbo.fRegistrationYear(@EffectiveTime) -- get starting month of the fiscal year of the effective time (can be NULL)
		)																x on 1													= 1
		where
			cip.CatalogItemSID = @CatalogItemSID
			and dbo.fRegistrationYear#FiscalMonthDay(cipp.StartMonthDay, x.YearStartMonth) -- compare the specified start date for the price as a fiscal year "month day" value
												 <= dbo.fRegistrationYear#FiscalMonthDay(right(convert(varchar(8), @EffectiveTime, 112), 4), x.YearStartMonth) -- to the effective time
		group by
			cip.CatalogItemPriceSID
	)																z on x.CatalogItemPriceSID				= z.CatalogItemPriceSID
	left outer join
		dbo.CatalogItemPriceProration cipp on z.CatalogItemProrationSID = cipp.CatalogItemPriceProrationSID
);
GO
