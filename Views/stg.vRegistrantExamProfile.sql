SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [stg].[vRegistrantExamProfile]
as
/*********************************************************************************************************************************
View    : stg.vRegistrantExamProfile
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for stg.RegistrantExamProfile - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the stg.RegistrantExamProfile table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to stg.vRegistrantExamProfileExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See stg.vRegistrantExamProfileExt documentation for details. To add additional content to this view, customize
the stg.vRegistrantExamProfileExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 rep.RegistrantExamProfileSID
	,rep.ImportFileSID
	,rep.ProcessingStatusSID
	,rep.RegistrantNo
	,rep.EmailAddress
	,rep.FirstName
	,rep.LastName
	,rep.BirthDate
	,rep.ExamIdentifier
	,rep.ExamDate
	,rep.ExamTime
	,rep.OrgLabel
	,rep.ExamResultDate
	,rep.PassingScore
	,rep.Score
	,rep.AssignedLocation
	,rep.ExamReference
	,rep.PersonSID
	,rep.RegistrantSID
	,rep.OrgSID
	,rep.ExamSID
	,rep.ExamOfferingSID
	,rep.ProcessingComments
	,rep.UserDefinedColumns
	,rep.RegistrantExamProfileXID
	,rep.LegacyKey
	,rep.IsDeleted
	,rep.CreateUser
	,rep.CreateTime
	,rep.UpdateUser
	,rep.UpdateTime
	,rep.RowGUID
	,rep.RowStamp
	,repx.FileFormatSID
	,repx.ApplicationEntitySID
	,repx.FileName
	,repx.LoadStartTime
	,repx.LoadEndTime
	,repx.IsFailed
	,repx.MessageText
	,repx.ImportFileRowGUID
	,repx.ProcessingStatusSCD
	,repx.ProcessingStatusLabel
	,repx.IsClosedStatus
	,repx.ProcessingStatusIsActive
	,repx.ProcessingStatusIsDefault
	,repx.ProcessingStatusRowGUID
	,repx.GenderSID
	,repx.NamePrefixSID
	,repx.PersonFirstName
	,repx.CommonName
	,repx.MiddleNames
	,repx.PersonLastName
	,repx.PersonBirthDate
	,repx.DeathDate
	,repx.HomePhone
	,repx.MobilePhone
	,repx.IsTextMessagingEnabled
	,repx.ImportBatch
	,repx.PersonRowGUID
	,repx.ExamName
	,repx.ExamCategory
	,repx.ExamPassingScore
	,repx.EffectiveTime
	,repx.ExpiryTime
	,repx.IsOnlineExam
	,repx.IsEnabledOnPortal
	,repx.Sequence
	,repx.CultureSID
	,repx.ExamLastVerifiedTime
	,repx.MinLagDaysBetweenAttempts
	,repx.MaxAttemptsPerYear
	,repx.VendorExamID
	,repx.ExamRowGUID
	,repx.ExamOfferingExamSID
	,repx.ExamOfferingOrgSID
	,repx.ExamOfferingExamTime
	,repx.SeatingCapacity
	,repx.CatalogItemSID
	,repx.BookingCutOffDate
	,repx.VendorExamOfferingID
	,repx.ExamOfferingRowGUID
	,repx.ParentOrgSID
	,repx.OrgTypeSID
	,repx.OrgName
	,repx.OrgOrgLabel
	,repx.StreetAddress1
	,repx.StreetAddress2
	,repx.StreetAddress3
	,repx.CitySID
	,repx.PostalCode
	,repx.RegionSID
	,repx.Phone
	,repx.Fax
	,repx.WebSite
	,repx.OrgEmailAddress
	,repx.InsuranceOrgSID
	,repx.InsurancePolicyNo
	,repx.InsuranceAmount
	,repx.IsEmployer
	,repx.IsCredentialAuthority
	,repx.IsInsurer
	,repx.IsInsuranceCertificateRequired
	,repx.IsPublic
	,repx.OrgIsActive
	,repx.IsAdminReviewRequired
	,repx.OrgLastVerifiedTime
	,repx.OrgRowGUID
	,repx.RegistrantPersonSID
	,repx.RegistrantRegistrantNo
	,repx.YearOfInitialEmployment
	,repx.IsOnPublicRegistry
	,repx.CityNameOfBirth
	,repx.CountrySID
	,repx.DirectedAuditYearCompetence
	,repx.DirectedAuditYearPracticeHours
	,repx.LateFeeExclusionYear
	,repx.IsRenewalAutoApprovalBlocked
	,repx.RenewalExtensionExpiryTime
	,repx.ArchivedTime
	,repx.RegistrantRowGUID
	,repx.IsDeleteEnabled
	,repx.IsReselected
	,repx.IsNullApplied
	,repx.zContext
	,repx.RegistrantLabel
from
	stg.RegistrantExamProfile      rep
join
	stg.vRegistrantExamProfile#Ext repx	on rep.RegistrantExamProfileSID = repx.RegistrantExamProfileSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'stg.RegistrantExamProfile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant exam profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RegistrantExamProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The import file assigned to this registrant exam profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant exam profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this registrant exam profile is based on', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this exam profile is defined for', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant exam profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam assigned to this registrant  profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam offering assigned to this registrant exam profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamOfferingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant exam profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RegistrantExamProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant exam profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant exam profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant exam profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant exam profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant exam profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file format assigned to this import file', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this import file', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the source file the import was read from (not necessarily unique).', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'FileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import service picked up the job for importing (start of import)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'LoadStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import of the file was completed successfully | Value is blank if Is-Failed is ON', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'LoadEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the import of this file failed or was cancelled by the user.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Summary of processing result (blank until processing is attempted).', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'MessageText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the import file record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ImportFileRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the processing status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ProcessingStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the processing status to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ProcessingStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates records in this status should be considered as closed by the application (not retryable) | This value cannot be set by the end user', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this processing status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ProcessingStatusIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default processing status to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ProcessingStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the processing status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ProcessingStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'PersonFirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'PersonLastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the exam to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize exams (e.g. for display in different areas on member forms)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum score for passing the exam (required for Alinity exams). Leave blank to always record pass/fail manually for external exams.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamPassingScore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the exam is enabled for selection on the member portal (applies only to online exams)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsEnabledOnPortal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls order this exam appears in relative to other exams associated with the same credential | If not set the order defaults to entry order of the record', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the culture assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum days a member must wait between attempts at writing the exam', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'MinLagDaysBetweenAttempts'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of attempts a member is alloted to pass the exam within a registration year.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'MaxAttemptsPerYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam  | This value can be used when importing exam candidates to associate results with the correct exam', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'VendorExamID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam this offering is defined for', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamOfferingExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this exam offering', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamOfferingOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the exam was taken', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamOfferingExamTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item assigned to this exam offering', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam offering | This value can be used when importing exam candidates to automatically book or associate a result with the exam offering ', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'VendorExamOfferingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam offering record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ExamOfferingRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'ParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgOrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'Fax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgLastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'OrgRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantExamProfile', 'COLUMN', N'zContext'
GO