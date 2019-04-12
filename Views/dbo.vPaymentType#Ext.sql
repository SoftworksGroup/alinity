SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPaymentType#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPaymentType#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PaymentType base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPaymentType (referred to as the "entity" view in SGI documentation).

Columns required to support the EF include constants passed by client and middle tier modules into the table API procedures as
parameters. These values control the insert/update/delete behaviour of the sprocs. For example: the IsNullApplied bit is set ON
in the view so that update procedures overwrite column values when matching parameters are NULL on calls from the client tier.
The default for this column in the call signature of the sproc is 0 (off) so that calls from the back-end do not overwrite with
null values.  The zContext XML value is always null but is required for binding to sproc calls using EF and RIA.

You can add additional columns, joins and examples of calling syntax, by placing them between the code tag pairs provided.  Items
placed within code tag pairs are preserved on regeneration.  Note that all additions to this view become part of the base product
and deploy for all client configurations.  This view is NOT an extension point for client-specific configurations.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ptype.PaymentTypeSID
	,gla.GLAccountCode
	,gla.GLAccountLabel
	,gla.IsRevenueAccount
	,gla.IsBankAccount
	,gla.IsTaxAccount
	,gla.IsPAPAccount
	,gla.IsUnappliedPaymentAccount
	,gla.DeferredGLAccountCode
	,gla.IsActive                                                           GLAccountIsActive
	,gla.RowGUID                                                            GLAccountRowGUID
	,ps.PaymentStatusSCD
	,ps.PaymentStatusLabel
	,ps.IsPaid
	,ps.PaymentStatusSequence
	,ps.RowGUID                                                             PaymentStatusRowGUID
	,dbo.fPaymentType#IsDeleteEnabled(ptype.PaymentTypeSID)                 IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
	,dateadd(day, ptype.DepositDateLagDays, sf.fToday())										DepositDate								--# Default for the deposit date based on the lag defined for this payment type
  --! </MoreColumns>
from
	dbo.PaymentType   ptype
join
	dbo.GLAccount     gla    on ptype.GLAccountSID = gla.GLAccountSID
join
	dbo.PaymentStatus ps     on ptype.PaymentStatusSID = ps.PaymentStatusSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'PaymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the glaccount to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is account is for collecting revenue - e.g. from registrations, exams, or products provided by the College', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsRevenueAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account can accept payments (eligible for selection when creating payment batches)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsBankAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a liability account used to collect one or more tax types', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The account where pre-authorized payments are deposited in the GL.  Note - this account must also be marked as a "bank account".', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsPAPAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account is used to record the liability of payments collected but which are not applied to any invoices.  Only one Unapplied Payment account is allowed. Setting this value on will un-set it on any other account that may have had the designation previously.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsUnappliedPaymentAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional account code applying to revenue accounts only to accrue revenue collected for the next registration year.  This account applies primarily to renewal transactions which collect funds in the current year for registrations which take effect the following year.  You can separate that revenue into different accounts based on filling out this code. If not filled in, the base revenue account is used.  Note that the Registration Year for which the funds are collected is available for report selection whether or not deferred accounts are used.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'DeferredGLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this glaccount record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'GLAccountIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the glaccount record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'GLAccountRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the payment status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'PaymentStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the payment status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'PaymentStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this status indicates the payment is in good standing and money was successfully received (or is assumed to be received as in the case of a check).', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'PaymentStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default for the deposit date based on the lag defined for this payment type', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentType#Ext', 'COLUMN', N'DepositDate'
GO