SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fGLTransaction#DetailForDay]
(
	@PostingDateStart date	-- starting posting day of GL transactions data to include
 ,@PostingDateEnd		date	-- ending posting day of GL transactions data to include
 ,@GLAccountSID    int
)
returns table
as
/*********************************************************************************************************************************
Function: GL Transaction - Detail For Day
Notice  : Copyright © 2017 Softworks Group Inc.
Detail	: Provides detail GL transactions for the given date range of posting
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Detail
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct 2017			|	Initial Version
				: Taylor N		| Dec 2017			| Replaced the GLTransaction 'union' with a 'union all' to include missing records
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is intended for detail reporting on GL activity.  The results from the report can be used to reconcile and provide
backup for summary Journal Entries for passing to external General Ledger programs. 

Maintenance Note: columns down to "LastResponse" have common logic and structure in dbo.vTransaction#Detail. If logic
changes are required here, also make them in the view.

Example
-------
<TestHarness>
	<Test Name="Simple" Description="A basic test of the functionality">
		<SQLScript>
		<![CDATA[
	declare
			@personSID				int
		,	@paymentSID				int
		,	@paymentTypeSID		int
		,	@paymentStatusSID	int
		, @invoiceSID				int
		,	@GLAccountCode		int
		,	@now							datetime2 = sf.fNow()
		
	begin tran

		select 
			@personSID = p.PersonSID
		from
			sf.Person p
		order by
			newid()

		select
			@GLAccountCode = gl.GLAccountCode
		from
			dbo.GLAccount gl
		where
			gl.GLAccountCode = '201'

		
		insert into dbo.Invoice
		(
				PersonSID
			,	InvoiceDate
			, RegistrationYear
		)
		select
				@personSID
			,	@now
			, year(@now)

		set @invoiceSID = scope_identity()

		insert into dbo.InvoiceItem
		(
			InvoiceSID
			,InvoiceItemDescription
			,Price
			,Quantity
			,GLAccountCode
			,SourceGUID
		)
		select
				@invoiceSID
			,	'*** TEST INVOICE ITEM ***'
			,	1.01
			,	1
			,	@GLAccountCode
			, newid()
		
		select
			@paymentStatusSID =  ps.PaymentStatusSID
		from
			dbo.PaymentStatus ps
		where
			ps.PaymentStatusSCD = 'approved'

	select
		@paymentTypeSID = pt.PaymentTypeSID
	from
		dbo.PaymentType pt
	where
		pt.PaymentTypeSCD = 'CASH'

	insert into dbo.Payment
	(
			PersonSID
		,	PaymentTypeSID
		,	PaymentStatusSID
		, GLAccountCode
		,	GLPostingDate
		,	DepositDate
		,	AmountPaid
		,	NameOnCard
	)
	select
			@personSID
		,	@paymentTypeSID
		,	@PaymentStatusSID
		, '201'
		,	sf.fNow()
		,	sf.fNow()
		,	1.01
		,	'*** TEST ***'


	set @paymentSID = scope_identity()


	insert into dbo.GLTransaction
	(
			PaymentSID
		,	DebitGLAccountCode
		,	CreditGLAccountCode
		,	GLPostingDate 
		,	Amount
		, PaymentCheckSum
	)
	select
			@paymentSID
		,	201
		, 201
		,	@now
		, 1.01
		, 0

	select 
		* 
	from 
		fGLTransaction#DetailForDay(@now,@now,  0) x
	order by
		x.GLPostingDate
	,	x.GLAccountCode
	,	x.PaymentTypeLabel
	,	isnull(x.VerifiedTime, x.UpdateTime)
	,	x.TrxSign desc;
	
	if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
	if @@TRANCOUNT > 0 rollback
	]]>
	</SQLScript>
	<Assertions>

		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>

		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="201"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="Bank Account"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="DB"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="5" Value="1.01"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="7" Value="Cash (currency)" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="11" Value="*** TEST ***" />"
		
			<Assertion Type="ScalarValue" ResultSet="1" Row="2" Column="2" Value="201"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="2" Column="3" Value="Bank Account"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="2" Column="4" Value="CR"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="2" Column="6" Value="1.01"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="2" Column="7" Value="Cash (currency)" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="2" Column="11" Value="*** TEST ***" />"

		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName				= 'dbo.fGLTransaction#DetailForDay'
	,	@DefaultTestOnly	=	1

------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		x.GLPostingDate
	 ,x.GLAccountCode
	 ,isnull(ga.GLAccountLabel, isnull(gaDf.GLAccountLabel + N' (Df)', N'[Removed]'))								AccountName
	 ,x.TrxSign
	 ,(case when x.TrxSign = 'DB' then x.Amount else cast(null as decimal(11, 2))end)								DebitAmount
	 ,(case when x.TrxSign = 'CR' then x.Amount else cast(null as decimal(11, 2))end)								CreditAmount
	 ,pt.PaymentTypeLabel
	 ,p.DepositDate
	 ,dbo.fRegistrant#Label(ps.LastName, ps.FirstName, ps.MiddleNames, r.RegistrantNo, 'REGISTRATION') RegistrantLabel
	 ,p.PaymentCard
	 ,p.NameOnCard
	 ,p.PaymentSID																																									PaymentID
	 ,upper(p.TransactionID)																																				TransactionID
	 ,p.VerifiedTime
	 ,p.UpdateTime
	 ,p.LastResponseCode + ' - ' + replace(replace(p.LastResponseMessage, ' ', ''), '*=', '')				LastResponse
	from
	(
		select
			gt.GLPostingDate
		 ,gt.DebitGLAccountCode GLAccountCode
		 ,'DB'									TrxSign
		 ,gt.Amount
		 ,gt.PaymentSID
		from
			dbo.GLTransaction gt
		left outer join
			dbo.GLAccount			gaDB on gt.DebitGLAccountCode		= gaDB.GLAccountCode
		left outer join
			dbo.GLAccount			gaDBDf on gt.DebitGLAccountCode = gaDBDf.DeferredGLAccountCode
		where
			gt.GLPostingDate >= @PostingDateStart and gt.GLPostingDate <= @PostingDateEnd and gt.IsExcluded = cast(0 as bit)
		union all
		select
			gt.GLPostingDate
		 ,gt.CreditGLAccountCode GLAccountCode
		 ,'CR'									 TrxSign
		 ,gt.Amount
		 ,gt.PaymentSID
		from
			dbo.GLTransaction gt
		left outer join
			dbo.GLAccount			gaCR on gt.CreditGLAccountCode	 = gaCR.GLAccountCode
		left outer join
			dbo.GLAccount			gaCRDf on gt.CreditGLAccountCode = gaCRDf.DeferredGLAccountCode
		where
			gt.GLPostingDate >= @PostingDateStart and gt.GLPostingDate <= @PostingDateEnd and gt.IsExcluded = cast(0 as bit)
	)								 x
	join
		dbo.Payment	 p on x.PaymentSID			 = p.PaymentSID
	join
		dbo.PaymentType pt on p.PaymentTypeSID = pt.PaymentTypeSID
	join
		sf.Person ps on p.PersonSID = ps.PersonSID
	left outer join
		dbo.Registrant r on p.PersonSID				 = r.PersonSID
	left outer join
		dbo.GLAccount	 ga on x.GLAccountCode	 = ga.GLAccountCode
	left outer join
		dbo.GLAccount	 gaDf on x.GLAccountCode = gaDf.DeferredGLAccountCode
	where
      (ga.GLAccountSID = case when @GLAccountSID = 0 then ga.GLAccountSID else @GLAccountSID end
      or
      gaDf.GLAccountSID = case when @GLAccountSID = 0 then gaDf.GLAccountSID else @GLAccountSID end)
);
GO
