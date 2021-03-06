SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPerson]
as
/*********************************************************************************************************************************
View    : sf.vPerson
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.Person - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.Person table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vPersonExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vPersonExt documentation for details. To add additional content to this view, customize
the sf.vPersonExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 person.PersonSID
	,person.GenderSID
	,person.NamePrefixSID
	,person.FirstName
	,person.CommonName
	,person.MiddleNames
	,person.LastName
	,person.BirthDate
	,person.DeathDate
	,person.HomePhone
	,person.MobilePhone
	,person.IsTextMessagingEnabled
	,person.SignatureImage
	,person.IdentityPhoto
	,person.ImportBatch
	,person.UserDefinedColumns
	,person.PersonXID
	,person.LegacyKey
	,person.IsDeleted
	,person.CreateUser
	,person.CreateTime
	,person.UpdateUser
	,person.UpdateTime
	,person.RowGUID
	,person.RowStamp
	,personx.GenderSCD
	,personx.GenderLabel
	,personx.GenderIsActive
	,personx.GenderRowGUID
	,personx.NamePrefixLabel
	,personx.NamePrefixIsActive
	,personx.NamePrefixRowGUID
	,personx.IsDeleteEnabled
	,personx.IsReselected
	,personx.IsNullApplied
	,personx.zContext
	,personx.FileAsName
	,personx.FullName
	,personx.DisplayName
	,personx.AgeInYears
	,personx.PrimaryEmailAddressSID
	,personx.PrimaryEmailAddress
	,personx.Initials
	,personx.IsEmailUsedForLogin
from
	sf.Person      person
join
	sf.vPerson#Ext personx	on person.PersonSID = personx.PersonSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.Person', 'SCHEMA', N'sf', 'VIEW', N'vPerson', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An image file representing the users signature applied to documents when signed by the user electronically', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'SignatureImage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A picture of the person - may be used for identity confirmation', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IdentityPhoto'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'PersonXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the gender | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'GenderSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the gender to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'GenderLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this gender record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'GenderIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the gender record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'GenderRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the name prefix to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'NamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this name prefix record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'NamePrefixIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the name prefix record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'NamePrefixRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A filing label for the person based on last name,first name middle names', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for addressing based on name prefix (salutation) and full name', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'FullName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the person suitable for use on the UI and reports based on first name last name', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The age of the person reported in full years lived (the typical way we refer to how old we are)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'AgeInYears'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The initials of the person based on their common/first name and last name', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'Initials'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this email, if primary, should be used for the login profile (defaults to YES)', 'SCHEMA', N'sf', 'VIEW', N'vPerson', 'COLUMN', N'IsEmailUsedForLogin'
GO
