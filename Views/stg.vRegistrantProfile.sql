SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [stg].[vRegistrantProfile]
as
/*********************************************************************************************************************************
View    : stg.vRegistrantProfile
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for stg.RegistrantProfile - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the stg.RegistrantProfile table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to stg.vRegistrantProfileExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See stg.vRegistrantProfileExt documentation for details. To add additional content to this view, customize
the stg.vRegistrantProfileExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 rp.RegistrantProfileSID
	,rp.ImportFileSID
	,rp.ProcessingStatusSID
	,rp.LastName
	,rp.FirstName
	,rp.CommonName
	,rp.MiddleNames
	,rp.EmailAddress
	,rp.HomePhone
	,rp.MobilePhone
	,rp.IsTextMessagingEnabled
	,rp.GenderLabel
	,rp.NamePrefixLabel
	,rp.BirthDate
	,rp.DeathDate
	,rp.UserName
	,rp.SubDomain
	,rp.Password
	,rp.StreetAddress1
	,rp.StreetAddress2
	,rp.StreetAddress3
	,rp.CityName
	,rp.StateProvinceName
	,rp.PostalCode
	,rp.CountryName
	,rp.RegionLabel
	,rp.RegistrantNo
	,rp.PersonGroupLabel1
	,rp.PersonGroupTitle1
	,rp.PersonGroupIsAdministrator1
	,rp.PersonGroupEffectiveDate1
	,rp.PersonGroupExpiryDate1
	,rp.PersonGroupLabel2
	,rp.PersonGroupTitle2
	,rp.PersonGroupIsAdministrator2
	,rp.PersonGroupEffectiveDate2
	,rp.PersonGroupExpiryDate2
	,rp.PersonGroupLabel3
	,rp.PersonGroupTitle3
	,rp.PersonGroupIsAdministrator3
	,rp.PersonGroupEffectiveDate3
	,rp.PersonGroupExpiryDate3
	,rp.PersonGroupLabel4
	,rp.PersonGroupTitle4
	,rp.PersonGroupIsAdministrator4
	,rp.PersonGroupEffectiveDate4
	,rp.PersonGroupExpiryDate4
	,rp.PersonGroupLabel5
	,rp.PersonGroupTitle5
	,rp.PersonGroupIsAdministrator5
	,rp.PersonGroupEffectiveDate5
	,rp.PersonGroupExpiryDate5
	,rp.PracticeRegisterLabel
	,rp.PracticeRegisterSectionLabel
	,rp.RegistrationEffectiveDate
	,rp.QualifyingCredentialLabel
	,rp.QualifyingCredentialOrgLabel
	,rp.QualifyingProgramName
	,rp.QualifyingProgramStartDate
	,rp.QualifyingProgramCompletionDate
	,rp.QualifyingFieldOfStudyName
	,rp.CredentialLabel1
	,rp.CredentialOrgLabel1
	,rp.CredentialProgramName1
	,rp.CredentialFieldOfStudyName1
	,rp.CredentialEffectiveDate1
	,rp.CredentialExpiryDate1
	,rp.CredentialLabel2
	,rp.CredentialOrgLabel2
	,rp.CredentialProgramName2
	,rp.CredentialFieldOfStudyName2
	,rp.CredentialEffectiveDate2
	,rp.CredentialExpiryDate2
	,rp.CredentialLabel3
	,rp.CredentialOrgLabel3
	,rp.CredentialProgramName3
	,rp.CredentialFieldOfStudyName3
	,rp.CredentialEffectiveDate3
	,rp.CredentialExpiryDate3
	,rp.CredentialLabel4
	,rp.CredentialOrgLabel4
	,rp.CredentialProgramName4
	,rp.CredentialFieldOfStudyName4
	,rp.CredentialEffectiveDate4
	,rp.CredentialExpiryDate4
	,rp.CredentialLabel5
	,rp.CredentialOrgLabel5
	,rp.CredentialProgramName5
	,rp.CredentialFieldOfStudyName5
	,rp.CredentialEffectiveDate5
	,rp.CredentialExpiryDate5
	,rp.CredentialLabel6
	,rp.CredentialOrgLabel6
	,rp.CredentialProgramName6
	,rp.CredentialFieldOfStudyName6
	,rp.CredentialEffectiveDate6
	,rp.CredentialExpiryDate6
	,rp.CredentialLabel7
	,rp.CredentialOrgLabel7
	,rp.CredentialProgramName7
	,rp.CredentialFieldOfStudyName7
	,rp.CredentialEffectiveDate7
	,rp.CredentialExpiryDate7
	,rp.CredentialLabel8
	,rp.CredentialOrgLabel8
	,rp.CredentialProgramName8
	,rp.CredentialFieldOfStudyName8
	,rp.CredentialEffectiveDate8
	,rp.CredentialExpiryDate8
	,rp.CredentialLabel9
	,rp.CredentialOrgLabel9
	,rp.CredentialProgramName9
	,rp.CredentialFieldOfStudyName9
	,rp.CredentialEffectiveDate9
	,rp.CredentialExpiryDate9
	,rp.PersonSID
	,rp.PersonEmailAddressSID
	,rp.ApplicationUserSID
	,rp.PersonMailingAddressSID
	,rp.RegionSID
	,rp.NamePrefixSID
	,rp.GenderSID
	,rp.CitySID
	,rp.StateProvinceSID
	,rp.CountrySID
	,rp.RegistrantSID
	,rp.ProcessingComments
	,rp.UserDefinedColumns
	,rp.RegistrantProfileXID
	,rp.LegacyKey
	,rp.IsDeleted
	,rp.CreateUser
	,rp.CreateTime
	,rp.UpdateUser
	,rp.UpdateTime
	,rp.RowGUID
	,rp.RowStamp
	,rpx.FileFormatSID
	,rpx.ApplicationEntitySID
	,rpx.FileName
	,rpx.LoadStartTime
	,rpx.LoadEndTime
	,rpx.IsFailed
	,rpx.MessageText
	,rpx.ImportFileRowGUID
	,rpx.ProcessingStatusSCD
	,rpx.ProcessingStatusLabel
	,rpx.IsClosedStatus
	,rpx.ProcessingStatusIsActive
	,rpx.ProcessingStatusIsDefault
	,rpx.ProcessingStatusRowGUID
	,rpx.PersonEmailAddressPersonSID
	,rpx.PersonEmailAddressEmailAddress
	,rpx.IsPrimary
	,rpx.PersonEmailAddressIsActive
	,rpx.PersonEmailAddressRowGUID
	,rpx.IsDeleteEnabled
	,rpx.IsReselected
	,rpx.IsNullApplied
	,rpx.zContext
	,rpx.RegistrantLabel
from
	stg.RegistrantProfile      rp
join
	stg.vRegistrantProfile#Ext rpx	on rp.RegistrantProfileSID = rpx.RegistrantProfileSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'stg.RegistrantProfile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'RegistrantProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The import file assigned to this registrant profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person email address assigned to this registrant profile', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'PersonEmailAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'RegistrantProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file format assigned to this import file', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this import file', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the source file the import was read from (not necessarily unique).', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'FileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import service picked up the job for importing (start of import)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'LoadStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import of the file was completed successfully | Value is blank if Is-Failed is ON', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'LoadEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the import of this file failed or was cancelled by the user.', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Summary of processing result (blank until processing is attempted).', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'MessageText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the import file record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ImportFileRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the processing status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ProcessingStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the processing status to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ProcessingStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates records in this status should be considered as closed by the application (not retryable) | This value cannot be set by the end user', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this processing status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ProcessingStatusIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default processing status to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ProcessingStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the processing status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'ProcessingStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this email address is based on', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'PersonEmailAddressPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person email address record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'PersonEmailAddressIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person email address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'PersonEmailAddressRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vRegistrantProfile', 'COLUMN', N'zContext'
GO
