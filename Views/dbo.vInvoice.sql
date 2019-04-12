SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vInvoice]
as
/*********************************************************************************************************************************
View    : dbo.vInvoice
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.Invoice - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.Invoice table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vInvoiceExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vInvoiceExt documentation for details. To add additional content to this view, customize
the dbo.vInvoiceExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 i.InvoiceSID
	,i.PersonSID
	,i.InvoiceDate
	,i.Tax1Label
	,i.Tax1Rate
	,i.Tax1GLAccountCode
	,i.Tax2Label
	,i.Tax2Rate
	,i.Tax2GLAccountCode
	,i.Tax3Label
	,i.Tax3Rate
	,i.Tax3GLAccountCode
	,i.RegistrationYear
	,i.CancelledTime
	,i.ReasonSID
	,i.IsRefund
	,i.ComplaintSID
	,i.UserDefinedColumns
	,i.InvoiceXID
	,i.LegacyKey
	,i.IsDeleted
	,i.CreateUser
	,i.CreateTime
	,i.UpdateUser
	,i.UpdateTime
	,i.RowGUID
	,i.RowStamp
	,ix.GenderSID
	,ix.NamePrefixSID
	,ix.FirstName
	,ix.CommonName
	,ix.MiddleNames
	,ix.LastName
	,ix.BirthDate
	,ix.DeathDate
	,ix.HomePhone
	,ix.MobilePhone
	,ix.IsTextMessagingEnabled
	,ix.ImportBatch
	,ix.PersonRowGUID
	,ix.ComplaintNo
	,ix.RegistrantSID
	,ix.ComplaintTypeSID
	,ix.ComplainantTypeSID
	,ix.ApplicationUserSID
	,ix.OpenedDate
	,ix.ConductStartDate
	,ix.ConductEndDate
	,ix.ComplaintSeveritySID
	,ix.IsDisplayedOnPublicRegistry
	,ix.ClosedDate
	,ix.DismissedDate
	,ix.ComplaintReasonSID
	,ix.FileExtension
	,ix.ComplaintRowGUID
	,ix.ReasonGroupSID
	,ix.ReasonName
	,ix.ReasonCode
	,ix.ReasonSequence
	,ix.ToolTip
	,ix.ReasonIsActive
	,ix.ReasonRowGUID
	,ix.IsDeleteEnabled
	,ix.IsReselected
	,ix.IsNullApplied
	,ix.zContext
	,ix.InvoiceLabel
	,ix.InvoiceShortLabel
	,ix.TotalBeforeTax
	,ix.Tax1Total
	,ix.Tax2Total
	,ix.Tax3Total
	,ix.TotalAdjustment
	,ix.TotalAfterTax
	,ix.TotalPaid
	,ix.TotalDue
	,ix.IsUnPaid
	,ix.IsPaid
	,ix.IsOverPaid
	,ix.IsOverDue
	,ix.Tax1GLAccountLabel
	,ix.Tax1IsTaxAccount
	,ix.Tax2GLAccountLabel
	,ix.Tax2IsTaxAccount
	,ix.Tax3GLAccountLabel
	,ix.Tax3IsTaxAccount
	,ix.IsDeferred
	,ix.IsCancelled
	,ix.IsEditEnabled
	,ix.IsPAPSubscriber
	,ix.IsPAPEnabled
	,ix.AddressBlockForPrint
	,ix.AddressBlockForHTML
from
	dbo.Invoice      i
join
	dbo.vInvoice#Ext ix	on i.InvoiceSID = ix.InvoiceSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.Invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this invoice is based on', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date of the invoice. Defaults to the current date but may be edited when back-dating is required.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax1GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax2GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax3GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year for which the revenue on the invoice is being collected. If this is not the same as the registration year the invoice is generated in, then deferred revenue accounts will apply to the exported transaction if they have been setup.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice was setup to record a refund. ', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsRefund'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the invoice | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'InvoiceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the invoice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this invoice record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the invoice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the invoice record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ComplaintTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the complaint was reported. | Normally the record entry date but provided to support back-dating when received through other channels', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'OpenedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the start of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ConductStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the end of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ConductEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint severity assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ComplaintSeveritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the outcome text is displayed on the public directory', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsDisplayedOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ComplaintReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ComplaintRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the invoice to use to select among invoices when making payment', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'InvoiceLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'a shorter form of the display label to use when selecting invoices and the registrant is known', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'InvoiceShortLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount of invoice not including tax', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'TotalBeforeTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total of tax type 1 for the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax1Total'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total of tax type 2 for the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax2Total'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total of tax type 3 for the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax3Total'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount of adjustments made on line items on the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'TotalAdjustment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount of the invoice - includes base amount, adjustments and tax', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'TotalAfterTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount paid on the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'TotalPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total that needs to be paid on the invoice (total after tax less paid amounts)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'TotalDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice is currently unpaid', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsUnPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice is currently paid', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice is currently overpaid', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsOverPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice has an unpaid balance for more than 30 days', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsOverDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'label for the first tax account (credit GL account)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax1GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicator whether the first tax account has a tax-type in the GL setup', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax1IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'label for the second tax account (credit GL account)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax2GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicator whether the second tax account has a tax-type in the GL setup', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax2IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'label for the third tax account (credit GL account)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax3GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicator whether the third tax account has a tax-type in the GL setup', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'Tax3IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the revenue is collected for a later registration year', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsDeferred'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the invoice has been cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if current user can edit the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether use of pre-authorized balances to pay invoices is enabled (based on schedule)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice', 'COLUMN', N'IsPAPEnabled'
GO