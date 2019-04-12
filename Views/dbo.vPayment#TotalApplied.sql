SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPayment#TotalApplied]
/*********************************************************************************************************************************
View		: Payment - Total Applied
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the total of line items and taxes for PaymentPayments
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep		2017	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view calculates the total amount applied for a Payment.  The calculation casts the interim value to the system's standard
money format and in the surrounding totaling operation so that if 0 is returned (no data) it's type is also consistent with other 
columns returned.  Note that the total unapplied, if any, calculated in the main entity view for the Payment.

Note that applied amounts are included regardless of the status of the payment.  If the payment is PENDING or even DECLINED the
total amounts applied to invoices from the payment are included in the total calculated here.
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	ip.PaymentSID
 ,cast(isnull(sum(ip.AmountApplied), 0) as decimal(11, 2)) TotalApplied
from
	dbo.InvoicePayment ip
group by
	ip.PaymentSID;
GO
