SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrationChange]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrationChange
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.RegistrationChange - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.RegistrationChange table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegistrationChangeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegistrationChangeExt documentation for details. To add additional content to this view, customize
the dbo.vRegistrationChangeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 rc.RegistrationChangeSID
	,rc.RegistrationSID
	,rc.PracticeRegisterSectionSID
	,rc.RegistrationYear
	,rc.NextFollowUp
	,rc.RegistrationEffective
	,rc.ReservedRegistrantNo
	,rc.ConfirmationDraft
	,rc.ReasonSID
	,rc.InvoiceSID
	,rc.ComplaintSID
	,rc.UserDefinedColumns
	,rc.RegistrationChangeXID
	,rc.LegacyKey
	,rc.IsDeleted
	,rc.CreateUser
	,rc.CreateTime
	,rc.UpdateUser
	,rc.UpdateTime
	,rc.RowGUID
	,rc.RowStamp
	,rcx.PracticeRegisterSID
	,rcx.PracticeRegisterSectionLabel
	,rcx.PracticeRegisterSectionIsDefault
	,rcx.IsDisplayedOnLicense
	,rcx.PracticeRegisterSectionIsActive
	,rcx.PracticeRegisterSectionRowGUID
	,rcx.RegistrationRegistrantSID
	,rcx.RegistrationPracticeRegisterSectionSID
	,rcx.RegistrationNo
	,rcx.RegistrationRegistrationYear
	,rcx.EffectiveTime
	,rcx.ExpiryTime
	,rcx.CardPrintedTime
	,rcx.RegistrationInvoiceSID
	,rcx.RegistrationReasonSID
	,rcx.FormGUID
	,rcx.RegistrationRowGUID
	,rcx.ReasonGroupSID
	,rcx.ReasonName
	,rcx.ReasonCode
	,rcx.ReasonSequence
	,rcx.ToolTip
	,rcx.ReasonIsActive
	,rcx.ReasonRowGUID
	,rcx.ComplaintNo
	,rcx.ComplaintRegistrantSID
	,rcx.ComplaintTypeSID
	,rcx.ComplainantTypeSID
	,rcx.ApplicationUserSID
	,rcx.OpenedDate
	,rcx.ConductStartDate
	,rcx.ConductEndDate
	,rcx.ComplaintSeveritySID
	,rcx.IsDisplayedOnPublicRegistry
	,rcx.ClosedDate
	,rcx.DismissedDate
	,rcx.ComplaintReasonSID
	,rcx.FileExtension
	,rcx.ComplaintRowGUID
	,rcx.PersonSID
	,rcx.InvoiceDate
	,rcx.Tax1Label
	,rcx.Tax1Rate
	,rcx.Tax1GLAccountCode
	,rcx.Tax2Label
	,rcx.Tax2Rate
	,rcx.Tax2GLAccountCode
	,rcx.Tax3Label
	,rcx.Tax3Rate
	,rcx.Tax3GLAccountCode
	,rcx.InvoiceRegistrationYear
	,rcx.CancelledTime
	,rcx.InvoiceReasonSID
	,rcx.IsRefund
	,rcx.InvoiceComplaintSID
	,rcx.InvoiceRowGUID
	,rcx.IsDeleteEnabled
	,rcx.IsReselected
	,rcx.IsNullApplied
	,rcx.zContext
	,rcx.IsViewEnabled
	,rcx.IsEditEnabled
	,rcx.IsApproveEnabled
	,rcx.IsRejectEnabled
	,rcx.IsUnlockEnabled
	,rcx.IsWithdrawalEnabled
	,rcx.IsInProgress
	,rcx.FormStatusSID
	,rcx.FormStatusSCD
	,rcx.FormStatusLabel
	,rcx.LastStatusChangeUser
	,rcx.LastStatusChangeTime
	,rcx.FormOwnerSID
	,rcx.FormOwnerSCD
	,rcx.FormOwnerLabel
	,rcx.IsPDFDisplayed
	,rcx.PersonDocSID
	,rcx.TotalDue
	,rcx.IsUnPaid
	,rcx.PersonMailingAddressSID
	,rcx.PersonStreetAddress1
	,rcx.PersonStreetAddress2
	,rcx.PersonStreetAddress3
	,rcx.PersonCityName
	,rcx.PersonStateProvinceName
	,rcx.PersonPostalCode
	,rcx.PersonCountryName
	,rcx.PersonCitySID
	,rcx.RegistrantPersonSID
	,rcx.RegistrationYearLabel
	,rcx.PracticeRegisterLabel
	,rcx.PracticeRegisterName
	,rcx.RegistrationChangeLabel
	,rcx.IsRegisterChange
	,rcx.HasOpenAudit
	,rcx.NewFormStatusSCD
	,rcx.ReasonSIDOnApprove
from
	dbo.RegistrationChange      rc
join
	dbo.vRegistrationChange#Ext rcx	on rc.RegistrationChangeSID = rcx.RegistrationChangeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.RegistrationChange', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration this change is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register section assigned to this registration change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional value set on approval to override the default effective date of the permit/license created', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationEffective'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number to assign to this registrant when they achieve their first "active-practice" registration  | This value is used when migration is enabled', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReservedRegistrantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registration change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this registration change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration change | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationChangeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration change | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration change record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration change | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration change record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration change record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register this section is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register section to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterSectionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register section to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterSectionIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this section should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a section accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register section record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterSectionIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register section record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterSectionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationRegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register section assigned to this registration', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationPracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A combination of the Registrant No + Registration Year + Registration Sequence - e.g. 12345.2019.1 for the registrant 12345''s first registration of 2019.  This format is set by the application and cannot be modified. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when a card was printed (if the College prints cards for this Registration type)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'CardPrintedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationInvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registration', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identifier for the member form (renewal, reinstatement) this registration resulted from if any | This value is blank if the registration was the result of an Administrator entered change since no member form is involved', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplaintRegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplaintTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the complaint was reported. | Normally the record entry date but provided to support back-dating when received through other channels', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'OpenedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the start of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ConductStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the end of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ConductEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint severity assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplaintSeveritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the outcome text is displayed on the public directory', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsDisplayedOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplaintReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ComplaintRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this invoice is based on', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date of the invoice. Defaults to the current date but may be edited when back-dating is required.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'Tax1GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'Tax2GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'Tax3GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year for which the revenue on the invoice is being collected. If this is not the same as the registration year the invoice is generated in, then deferred revenue accounts will apply to the exported transaction if they have been setup.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'InvoiceRegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'InvoiceReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice was setup to record a refund. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsRefund'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'InvoiceComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'InvoiceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether either the (logged in) user or administrator can view the registration change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsViewEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether the (logged in) user can edit/correct the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether the approve button should be made available to the user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsApproveEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether the reject button should be made available to the user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsRejectEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates administrator can unlock form for editing even when in certain final statuses', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsUnlockEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates the registration change form can be withdrawn by administrators or SA''s', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsWithdrawalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the form is now closed/finalized or still in progress (open)	', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsInProgress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of current/latest registration change status', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to set the form to a new status value', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User-friendly name for the registration change status		', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'username who made the last status change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'LastStatusChangeUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time the last status change was made', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'LastStatusChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the related sf.FormOwner record', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'person/group expected to perform next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'user-friendly name of person/group expected to perform next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if PDF form version should be displayed rather than the HTML (form is complete)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsPDFDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'amount owing on invoice associated with the registration change (blank if no invoice created)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'TotalDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice associated with the registration change is unpaid', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsUnPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of registrant''s current mailing address - if any', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonMailingAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current street address for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonStreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current street address for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonStreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current street address for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonStreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'City name for the registrant current address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonCityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'State/province name for the registrant current address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonStateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Postal code for the registrant current address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonPostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Country name for the registrant current address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonCountryName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of City record for the registrant current address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PersonCitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key value (in the person table) for this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'String show 2 years if the registration year provided is not based on a calendar year', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationYearLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label (short name) of the register this registration change is being made to', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the register this registration change is being made to', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'PracticeRegisterName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'a summary label for the registration change based on the register label and registration change status', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'RegistrationChangeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if this registration change involves a change in register from the originating registration', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'IsRegisterChange'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the registrant has an open audit - normally blocks registration change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'HasOpenAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to set the form to a new status value', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'NewFormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to set a reason on the new registration record on approval', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationChange', 'COLUMN', N'ReasonSIDOnApprove'
GO
