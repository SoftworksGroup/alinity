SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPaymentType]
as
/*********************************************************************************************************************************
View    : dbo.vPaymentType
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PaymentType - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PaymentType table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPaymentTypeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPaymentTypeExt documentation for details. To add additional content to this view, customize
the dbo.vPaymentTypeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ptype.PaymentTypeSID
	,ptype.PaymentTypeSCD
	,ptype.PaymentTypeLabel
	,ptype.PaymentTypeCategory
	,ptype.GLAccountSID
	,ptype.PaymentStatusSID
	,ptype.IsReferenceRequired
	,ptype.DepositDateLagDays
	,ptype.IsRefundExcludedFromGL
	,ptype.ExcludeDepositFromGLBefore
	,ptype.IsDefault
	,ptype.IsActive
	,ptype.UserDefinedColumns
	,ptype.PaymentTypeXID
	,ptype.LegacyKey
	,ptype.IsDeleted
	,ptype.CreateUser
	,ptype.CreateTime
	,ptype.UpdateUser
	,ptype.UpdateTime
	,ptype.RowGUID
	,ptype.RowStamp
	,ptypex.GLAccountCode
	,ptypex.GLAccountLabel
	,ptypex.IsRevenueAccount
	,ptypex.IsBankAccount
	,ptypex.IsTaxAccount
	,ptypex.IsPAPAccount
	,ptypex.IsUnappliedPaymentAccount
	,ptypex.DeferredGLAccountCode
	,ptypex.GLAccountIsActive
	,ptypex.GLAccountRowGUID
	,ptypex.PaymentStatusSCD
	,ptypex.PaymentStatusLabel
	,ptypex.IsPaid
	,ptypex.PaymentStatusSequence
	,ptypex.PaymentStatusRowGUID
	,ptypex.IsDeleteEnabled
	,ptypex.IsReselected
	,ptypex.IsNullApplied
	,ptypex.zContext
	,ptypex.DepositDate
from
	dbo.PaymentType      ptype
join
	dbo.vPaymentType#Ext ptypex	on ptype.PaymentTypeSID = ptypex.PaymentTypeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PaymentType', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the payment type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the payment type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the glaccount assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'GLAccountSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the payment type', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the payment reference field must be filled in when checked.  This is normally required for check/cheque payment types.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsReferenceRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of days ahead of the date the transaction is recorded, payments of this type are expected to appear on the bank statement.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'DepositDateLagDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if refunds processed on this payment type should be exlcuded from reporting to external general ledgers. This value should be checked if refunds for this payment type are initiated in your GL program (typically as checks/cheques).', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsRefundExcludedFromGL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allows deposits for this payment type to be excluded from reporting to external GL when the transaction occurs prior to this date.  Typically only applies to PAP bank accounts for conversion period.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'ExcludeDepositFromGLBefore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default payment type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this payment type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the glaccount to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is account is for collecting revenue - e.g. from registrations, exams, or products provided by the College', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsRevenueAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account can accept payments (eligible for selection when creating payment batches)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsBankAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a liability account used to collect one or more tax types', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The account where pre-authorized payments are deposited in the GL.  Note - this account must also be marked as a "bank account".', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsPAPAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account is used to record the liability of payments collected but which are not applied to any invoices.  Only one Unapplied Payment account is allowed. Setting this value on will un-set it on any other account that may have had the designation previously.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsUnappliedPaymentAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional account code applying to revenue accounts only to accrue revenue collected for the next registration year.  This account applies primarily to renewal transactions which collect funds in the current year for registrations which take effect the following year.  You can separate that revenue into different accounts based on filling out this code. If not filled in, the base revenue account is used.  Note that the Registration Year for which the funds are collected is available for report selection whether or not deferred accounts are used.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'DeferredGLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this glaccount record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'GLAccountIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the glaccount record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'GLAccountRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the payment status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the payment status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this status indicates the payment is in good standing and money was successfully received (or is assumed to be received as in the case of a check).', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'PaymentStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default for the deposit date based on the lag defined for this payment type', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType', 'COLUMN', N'DepositDate'
GO