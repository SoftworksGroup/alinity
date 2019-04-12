SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fGLTransaction#SummaryByDay
(
	@StartDate date -- first posting day of GL transactions data to include
 ,@EndDate	 date -- last posting day of GL transactions to include
)
returns table
as
/*********************************************************************************************************************************
Function	: GL Transaction - Summary By Day
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Summarizes posting amounts by day for GL codes
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct 2017			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is intended for summary reporting on GL activity.  The results from the report can be used to create Journal Entries
for external General Ledger programs.  The total of debits and credits for each account is calculated along with a net entry 
for including in a Journal Entry.  Reporting must be selected for a range of GL posting dates. 

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

	-- insert into dbo.InvoicePayment
	-- (
	-- 		InvoiceSID
	-- 	,	PaymentSID
	-- 	,	AmountApplied
	-- 	,	AppliedDate
	-- 	,	GLPostingDate
	-- )	
	-- select
	-- 		@InvoiceSID
	-- 	,	@paymentSID
	-- 	, 1.01
	-- 	, @now
	-- 	, @now

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
		dbo.fGLTransaction#SummaryByDay(@now,@now)
	
	if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
	if @@TRANCOUNT > 0 rollback

	]]>
	</SQLScript>
	<Assertions>

		<Assertion Type="NotEmptyResultSet" ResultSet="1" />

		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="201"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="Bank Account"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="False"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="5" Value="True"/>
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="6" Value="False" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="7" Value="True" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="8" Value="False" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="10" Value="1.01" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="11" Value="1.01" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="12" Value="- " />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="13" Value="0.00" />
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName				= 'dbo.fGLTransaction#SummaryByDay'
	,	@DefaultTestOnly	=	1

------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		z.GLPostingDate
	 ,z.GLAccountCode
	 ,isnull(ga.GLAccountLabel, isnull(gaDf.GLAccountLabel + N' (Df)', N'[Removed]')) GLAccountLabel
	 ,isnull(ga.IsRevenueAccount, gaDf.IsRevenueAccount)															IsRevenueAccount
	 ,isnull(ga.IsBankAccount, gaDf.IsBankAccount)																		IsBankAccount
	 ,isnull(ga.IsTaxAccount, gaDf.IsTaxAccount)																			IsTaxAccount
	 ,isnull(ga.IsPAPAccount, gaDf.IsPAPAccount)																			IsPAPAccount
	 ,isnull(ga.IsUnappliedPaymentAccount, gaDf.IsUnappliedPaymentAccount)						IsUnappliedPaymentAccount
	 ,cast(gaDf.GLAccountSID as bit)																									IsDeferred
	 ,z.DebitAmount
	 ,z.CreditAmount
	 ,(case
			 when z.DebitAmount > z.CreditAmount then 'DB'
			 when z.CreditAmount > z.DebitAmount then 'CR'
			 else cast('-' as char(2))
		 end
		)																																								NetSign
	 ,(case
			 when z.DebitAmount > z.CreditAmount then z.DebitAmount - z.CreditAmount
			 when z.CreditAmount > z.DebitAmount then z.CreditAmount - z.DebitAmount
			 else cast(0.00 as decimal(11, 2))
		 end
		)																																								NetAmount
	from
	(
		select
			src.GLPostingDate
		 ,src.GLAccountCode
		 ,sum(src.DebitAmount)	DebitAmount
		 ,sum(src.CreditAmount) CreditAmount
		from	(
						select
							gt.GLPostingDate
						 ,gt.DebitGLAccountCode GLAccountCode
						 ,sum(gt.Amount)				DebitAmount
						 ,sum(0.00)							CreditAmount
						from
							dbo.GLTransaction gt
						where
							gt.GLPostingDate >= @StartDate and gt.GLPostingDate <= @EndDate and gt.IsExcluded = cast(0 as bit)
						group by
							gt.GLPostingDate
						 ,gt.DebitGLAccountCode
						union
						select
							gt.GLPostingDate
						 ,gt.CreditGLAccountCode GLAccountCode
						 ,sum(0.00)							 DebitAmount
						 ,sum(gt.Amount)				 CreditAmount
						from
							dbo.GLTransaction gt
						where
							gt.GLPostingDate >= @StartDate and gt.GLPostingDate <= @EndDate and gt.IsExcluded = cast(0 as bit)
						group by
							gt.GLPostingDate
						 ,gt.CreditGLAccountCode
					) src
		group by
			src.GLPostingDate
		 ,src.GLAccountCode
	)								z
	left outer join
		dbo.GLAccount ga on z.GLAccountCode		= ga.GLAccountCode
	left outer join
		dbo.GLAccount gaDf on z.GLAccountCode = gaDf.DeferredGLAccountCode
);
GO
