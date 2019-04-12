SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantExam]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantExam
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.RegistrantExam - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.RegistrantExam table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegistrantExamExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegistrantExamExt documentation for details. To add additional content to this view, customize
the dbo.vRegistrantExamExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 re.RegistrantExamSID
	,re.RegistrantSID
	,re.ExamSID
	,re.ExamDate
	,re.ExamResultDate
	,re.PassingScore
	,re.Score
	,re.ExamStatusSID
	,re.SchedulingPreferences
	,re.AssignedLocation
	,re.ExamReference
	,re.ExamOfferingSID
	,re.InvoiceSID
	,re.ConfirmedTime
	,re.CancelledTime
	,re.ExamConfiguration
	,re.ExamResponses
	,re.ProcessedTime
	,re.ProcessingComments
	,re.UserDefinedColumns
	,re.RegistrantExamXID
	,re.LegacyKey
	,re.IsDeleted
	,re.CreateUser
	,re.CreateTime
	,re.UpdateUser
	,re.UpdateTime
	,re.RowGUID
	,re.RowStamp
	,rex.ExamName
	,rex.ExamCategory
	,rex.ExamPassingScore
	,rex.EffectiveTime
	,rex.ExpiryTime
	,rex.IsOnlineExam
	,rex.IsEnabledOnPortal
	,rex.ExamSequence
	,rex.CultureSID
	,rex.LastVerifiedTime
	,rex.MinLagDaysBetweenAttempts
	,rex.MaxAttemptsPerYear
	,rex.VendorExamID
	,rex.ExamRowGUID
	,rex.ExamStatusSCD
	,rex.ExamStatusLabel
	,rex.ExamStatusSequence
	,rex.ExamStatusIsDefault
	,rex.ExamStatusRowGUID
	,rex.RegistrantPersonSID
	,rex.RegistrantNo
	,rex.YearOfInitialEmployment
	,rex.IsOnPublicRegistry
	,rex.CityNameOfBirth
	,rex.CountrySID
	,rex.DirectedAuditYearCompetence
	,rex.DirectedAuditYearPracticeHours
	,rex.LateFeeExclusionYear
	,rex.IsRenewalAutoApprovalBlocked
	,rex.RenewalExtensionExpiryTime
	,rex.ArchivedTime
	,rex.RegistrantRowGUID
	,rex.InvoicePersonSID
	,rex.InvoiceDate
	,rex.Tax1Label
	,rex.Tax1Rate
	,rex.Tax1GLAccountCode
	,rex.Tax2Label
	,rex.Tax2Rate
	,rex.Tax2GLAccountCode
	,rex.Tax3Label
	,rex.Tax3Rate
	,rex.Tax3GLAccountCode
	,rex.RegistrationYear
	,rex.InvoiceCancelledTime
	,rex.ReasonSID
	,rex.IsRefund
	,rex.ComplaintSID
	,rex.InvoiceRowGUID
	,rex.ExamOfferingExamSID
	,rex.OrgSID
	,rex.ExamTime
	,rex.SeatingCapacity
	,rex.CatalogItemSID
	,rex.BookingCutOffDate
	,rex.VendorExamOfferingID
	,rex.ExamOfferingRowGUID
	,rex.IsDeleteEnabled
	,rex.IsReselected
	,rex.IsNullApplied
	,rex.zContext
	,rex.IsViewEnabled
	,rex.IsEditEnabled
	,rex.IsPDFDisplayed
	,rex.PersonDocSID
	,rex.ApplicationUserSID
from
	dbo.RegistrantExam      re
join
	dbo.vRegistrantExam#Ext rex	on re.RegistrantExamSID = rex.RegistrantExamSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.RegistrantExam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant exam assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RegistrantExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this exam is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the exam was taken', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the result of the exam was received', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamResultDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum score for passing the exam as defined at the time the record was created | This value can be edited by SA''s (only)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'PassingScore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The score achieved by the exam candidate', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'Score'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The member''s preference for scheduling the exam sitting - may include date, location, special requirements etc. - considered in assigning an exam sitting ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'SchedulingPreferences'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The seat#, room# or other location identifier within the building where the registrant wrote the exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'AssignedLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier for the candidate or exam from a 3rd party exam provider - e.g. a Yardstick exam ID or ASI exam-file result', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam offering assigned to this registrant exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamOfferingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The invoice assigned to this registrant exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when registration for the exam offering date was confirmed  - set automatically when invoice is paid or on $0 invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ConfirmedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when exam booking was cancelled (paid amounts available for refund or application to a new booking)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A document used internally by the application to display exam questions, answers and other details | This document is generated at the time the exam is created and is not affected by subsequent updates to the exam''s configuration', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamConfiguration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document containing the member answers to the exam questions. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamResponses'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the date and time the application service picks up the record for generation of the PDF', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records system error and warning messages, if any, associated with processing of the exam (PDF) document', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ProcessingComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant exam | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RegistrantExamXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant exam | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant exam record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant exam | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant exam record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant exam record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the exam to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize exams (e.g. for display in different areas on member forms)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum score for passing the exam (required for Alinity exams). Leave blank to always record pass/fail manually for external exams.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamPassingScore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the exam is enabled for selection on the member portal (applies only to online exams)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsEnabledOnPortal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls order this exam appears in relative to other exams associated with the same credential | If not set the order defaults to entry order of the record', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the culture assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum days a member must wait between attempts at writing the exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'MinLagDaysBetweenAttempts'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of attempts a member is alloted to pass the exam within a registration year.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'MaxAttemptsPerYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam  | This value can be used when importing exam candidates to associate results with the correct exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'VendorExamID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the exam status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the exam status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to control the display order of exam results when presented on the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default exam status to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this invoice is based on', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'InvoicePersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date of the invoice. Defaults to the current date but may be edited when back-dating is required.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'Tax1GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'Tax2GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'Tax3GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year for which the revenue on the invoice is being collected. If this is not the same as the registration year the invoice is generated in, then deferred revenue accounts will apply to the exported transaction if they have been setup.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'InvoiceCancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice was setup to record a refund. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsRefund'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'InvoiceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam this offering is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamOfferingExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this exam offering', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the exam was taken', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item assigned to this exam offering', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam offering | This value can be used when importing exam candidates to automatically book or associate a result with the exam offering ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'VendorExamOfferingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam offering record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ExamOfferingRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the exam can be viewed (allowed for the member or administrators)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsViewEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the exam can be edited (member must be logged in and exam not yet complete)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if PDF of the exam should be displayed rather than the HTML (exam is complete)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'IsPDFDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'key of the form PDF (blank/null if the PDF is not available or exam is not yet finalized)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'key of the registrant login record (used to select "My Exams" on member portal)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantExam', 'COLUMN', N'ApplicationUserSID'
GO
