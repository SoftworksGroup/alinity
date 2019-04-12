SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vTaxConfiguration]
as
/*********************************************************************************************************************************
View    : dbo.vTaxConfiguration
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.TaxConfiguration - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.TaxConfiguration table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vTaxConfigurationExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vTaxConfigurationExt documentation for details. To add additional content to this view, customize
the dbo.vTaxConfigurationExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 tc.TaxConfigurationSID
	,tc.TaxSID
	,tc.TaxRate
	,tc.GLAccountSID
	,tc.EffectiveTime
	,tc.UserDefinedColumns
	,tc.TaxConfigurationXID
	,tc.LegacyKey
	,tc.IsDeleted
	,tc.CreateUser
	,tc.CreateTime
	,tc.UpdateUser
	,tc.UpdateTime
	,tc.RowGUID
	,tc.RowStamp
	,tcx.GLAccountCode
	,tcx.GLAccountLabel
	,tcx.IsRevenueAccount
	,tcx.IsBankAccount
	,tcx.IsTaxAccount
	,tcx.IsPAPAccount
	,tcx.IsUnappliedPaymentAccount
	,tcx.DeferredGLAccountCode
	,tcx.GLAccountIsActive
	,tcx.GLAccountRowGUID
	,tcx.TaxLabel
	,tcx.TaxSequence
	,tcx.TaxRowGUID
	,tcx.IsDeleteEnabled
	,tcx.IsReselected
	,tcx.IsNullApplied
	,tcx.zContext
	,tcx.ExpiryTime
from
	dbo.TaxConfiguration      tc
join
	dbo.vTaxConfiguration#Ext tcx	on tc.TaxConfigurationSID = tcx.TaxConfigurationSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.TaxConfiguration', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the tax configuration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxConfigurationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The tax this configuration is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The rate of the tax expressed as a decimal - e.g. a 5% tax is stored as 0.050', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The glaccount assigned to this tax configuration', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'GLAccountSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the tax configuration | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxConfigurationXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the tax configuration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this tax configuration record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the tax configuration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the tax configuration record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the tax configuration record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the glaccount to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is account is for collecting revenue - e.g. from registrations, exams, or products provided by the College', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsRevenueAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account can accept payments (eligible for selection when creating payment batches)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsBankAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a liability account used to collect one or more tax types', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The account where pre-authorized payments are deposited in the GL.  Note - this account must also be marked as a "bank account".', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsPAPAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account is used to record the liability of payments collected but which are not applied to any invoices.  Only one Unapplied Payment account is allowed. Setting this value on will un-set it on any other account that may have had the designation previously.', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsUnappliedPaymentAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional account code applying to revenue accounts only to accrue revenue collected for the next registration year.  This account applies primarily to renewal transactions which collect funds in the current year for registrations which take effect the following year.  You can separate that revenue into different accounts based on filling out this code. If not filled in, the base revenue account is used.  Note that the Registration Year for which the funds are collected is available for report selection whether or not deferred accounts are used.', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'DeferredGLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this glaccount record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'GLAccountIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the glaccount record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'GLAccountRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the tax to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of sequence of this tax in the list of taxes to be presented on invoices.  For example, if you want "GST" to appear 1st, then assign it number 1.  The current version of the system  supports a maximum of 3 tax types so this value must be 1, 2 or 3.  ', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the tax record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'TaxRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vTaxConfiguration', 'COLUMN', N'zContext'
GO
