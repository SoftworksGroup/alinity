SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fTaxRates]
()
returns @taxRates table
(
		Tax1SID						int						null
	,	Tax1Label					nvarchar(8)		null
	,	Tax1Rate					decimal(4,4)	null
	, Tax1GLAccountSID	int						null
	, Tax1GLAccountCode	varchar(50)		null
	,	Tax2SID						int						null
	,	Tax2Label					nvarchar(8)		null
	,	Tax2Rate					decimal(4,4)	null
	, Tax2GLAccountSID	int						null
	, Tax2GLAccountCode	varchar(50)		null
	,	Tax3SID						int						null
	,	Tax3Label					nvarchar(8)		null
	,	Tax3Rate					decimal(4,4)	null
	, Tax3GLAccountSID	int						null
	, Tax3GLAccountCode	varchar(50)		null	
)				
as
/*********************************************************************************************************************************
TableF		: Tax Rates
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a single row table of current tax labels, rates and associated GL Account keys
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Aug 2017		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is called by extended views which much calculate tax amounts.  The system supports up to 3 tax types but
some configuration may have 0 or 1 or 2.  The view identifies the taxes in effect at the time it is executed along with current
rate and GL Account (dbo.GLAccount) primary key value.  These values are used to write out invoice line items associated with
the transaction.

The function always returns a single row and requires no parameters.

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="Returns current tax configuration.">
	<SQLScript>
	<![CDATA[

		select * from dbo.fTaxRates()

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fTaxRates
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@tax1SID						int						
	,	@tax1Label					nvarchar(8)
	,	@tax1Rate						decimal(4,4)	
	, @tax1GLAccountSID		int			
	, @tax1GLAccountCode	varchar(50)
	,	@tax2SID						int						
	,	@tax2Label					nvarchar(8)
	,	@tax2Rate						decimal(4,4)	
	, @tax2GLAccountSID		int			
	, @tax2GLAccountCode	varchar(50)
	,	@tax3SID						int						
	,	@tax3Label					nvarchar(8)	
	,	@tax3Rate						decimal(4,4)	
	, @tax3GLAccountSID		int			
	, @tax3GLAccountCode	varchar(50)	

	-- flatten 3 possible tax types to a single row; get latest taxes and rates in effect

	select
			@tax1SID						= (case when txc.TaxSequence = 1 then txc.TaxSID						else @tax1SID						end)
		,	@tax1Label					= (case when txc.TaxSequence = 1 then left(txc.TaxLabel, 8)	else @tax1Label					end)
		,	@tax1Rate						= (case when txc.TaxSequence = 1 then txc.TaxRate						else @tax1Rate					end)
		, @tax1GLAccountSID		= (case when txc.TaxSequence = 1 then txc.GLAccountSID			else @tax1GLAccountSID	end)
		, @tax1GLAccountCode	= (case when txc.TaxSequence = 1 then txc.GLAccountCode			else @tax1GLAccountCode	end)
		,	@tax2SID						= (case when txc.TaxSequence = 2 then txc.TaxSID						else @tax2SID						end)
		,	@tax2Label					= (case when txc.TaxSequence = 2 then left(txc.TaxLabel, 8)	else @tax2Label					end)
		,	@tax2Rate						= (case when txc.TaxSequence = 2 then txc.TaxRate						else @tax2Rate					end)
		, @tax2GLAccountSID		= (case when txc.TaxSequence = 2 then txc.GLAccountSID			else @tax2GLAccountSID	end)
		, @tax2GLAccountCode	= (case when txc.TaxSequence = 2 then txc.GLAccountCode			else @tax2GLAccountCode	end)
		,	@tax3SID						= (case when txc.TaxSequence = 3 then txc.TaxSID						else @tax3SID						end)
		,	@tax3Label					= (case when txc.TaxSequence = 3 then left(txc.TaxLabel, 8)	else @tax3Label					end)
		,	@tax3Rate						= (case when txc.TaxSequence = 3 then txc.TaxRate						else @tax3Rate					end)
		, @tax3GLAccountSID		= (case when txc.TaxSequence = 3 then txc.GLAccountSID			else @tax3GLAccountSID	end)
		, @tax3GLAccountCode	= (case when txc.TaxSequence = 3 then txc.GLAccountCode			else @tax3GLAccountCode	end)
	from	
			dbo.vTaxConfiguration#Current txc

	insert
		@taxRates
	(
			Tax1SID		
		,	Tax1Label
		,	Tax1Rate				
		, Tax1GLAccountSID
		, Tax1GLAccountCode
		,	Tax2SID			
		,	Tax2Label
		,	Tax2Rate				
		, Tax2GLAccountSID
		, Tax2GLAccountCode
		,	Tax3SID			
		,	Tax3Label
		,	Tax3Rate				
		, Tax3GLAccountSID
		, Tax3GLAccountCode
	) 
	values
	(
			@tax1SID
		, @tax1Label
		,	@tax1Rate					
		, @tax1GLAccountSID	
		, @tax1GLAccountCode
		,	@tax2SID	
		, @tax2Label		
		,	@tax2Rate					
		, @tax2GLAccountSID
		, @tax2GLAccountCode
		,	@tax3SID		
		, @tax3Label		
		,	@tax3Rate					
		, @tax3GLAccountSID	
		, @tax3GLAccountCode
	)

	return

end
GO
