SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPaymentProcessorResponse]
as
/*********************************************************************************************************************************
View    : dbo.vPaymentProcessorResponse
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PaymentProcessorResponse - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PaymentProcessorResponse table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPaymentProcessorResponseExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPaymentProcessorResponseExt documentation for details. To add additional content to this view, customize
the dbo.vPaymentProcessorResponseExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ppr.PaymentProcessorResponseSID
	,ppr.PaymentSID
	,ppr.ResponseTime
	,ppr.ResponseSource
	,ppr.ResponseDetails
	,ppr.TransactionID
	,ppr.IsPaid
	,ppr.UserDefinedColumns
	,ppr.PaymentProcessorResponseXID
	,ppr.LegacyKey
	,ppr.IsDeleted
	,ppr.CreateUser
	,ppr.CreateTime
	,ppr.UpdateUser
	,ppr.UpdateTime
	,ppr.RowGUID
	,ppr.RowStamp
	,pprx.PersonSID
	,pprx.PaymentTypeSID
	,pprx.PaymentStatusSID
	,pprx.GLAccountCode
	,pprx.GLPostingDate
	,pprx.DepositDate
	,pprx.AmountPaid
	,pprx.Reference
	,pprx.NameOnCard
	,pprx.PaymentCard
	,pprx.PaymentTransactionID
	,pprx.LastResponseCode
	,pprx.VerifiedTime
	,pprx.CancelledTime
	,pprx.ReasonSID
	,pprx.PaymentRowGUID
	,pprx.IsDeleteEnabled
	,pprx.IsReselected
	,pprx.IsNullApplied
	,pprx.zContext
	,pprx.IsManual
from
	dbo.PaymentProcessorResponse      ppr
join
	dbo.vPaymentProcessorResponse#Ext pprx	on ppr.PaymentProcessorResponseSID = pprx.PaymentProcessorResponseSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PaymentProcessorResponse', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment processor response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentProcessorResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The payment this processor response is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the response was received from the processor (same as CreateTime except for manual entries)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'ResponseTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The source of the response:  MANUAL entry, BROWSER, or SERVER', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'ResponseSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records a history of events and values provided to payment processors.  This information is used primarily for follow-up on unsuccessful debit and credit card processing attempts.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'ResponseDetails'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The transaction or reference number of provided by the 3rd party payment processor for tracking on their website.  | The column should always be filled in but NULLs (blanks) are allowed to minimize the probability of an update failure when recording a response.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'TransactionID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates payment was accepted', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment processor response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentProcessorResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment processor response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment processor response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment processor response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment processor response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment processor response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this payment is based on', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of payment', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the payment', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the payment transaction is posted for inclusion in the General Ledger | This value is set by the system automatically for online payments but can be overriden for manual payments.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'GLPostingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the payment was deposited or settled', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'DepositDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The monetary value of the payment', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'AmountPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the check/cheque# or other reference for the payment.  This value can be set as required for certain types of payments through Payment Type in settings.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'Reference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name on the card used for payment. This value is used to help identify how a payment was made during follow-up.  The value is blank except where an payment card was used.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'NameOnCard'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The masked card number used for the online payment. This value is used to help identify how payment was made during follow-up. Only the first 4 and last 4 digits of the card number are retained. ', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentCard'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The transaction or reference number of the payment to allow tracking.  This can be a cheque number, the transaction number of a debit reciept, transaction number from a 3rd party payment processor, etc...', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentTransactionID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is supported by some online payment processors only (e.g. Moneris).  It indicates the time when a server-to-server verification of the transaction processed occurred.  Other details of the verification are stored in the ProcessingLog.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'VerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this payment', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'PaymentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentProcessorResponse', 'COLUMN', N'zContext'
GO
