SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPersonOtherName]
as
/*********************************************************************************************************************************
View    : sf.vPersonOtherName
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.PersonOtherName - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.PersonOtherName table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vPersonOtherNameExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vPersonOtherNameExt documentation for details. To add additional content to this view, customize
the sf.vPersonOtherNameExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pon.PersonOtherNameSID
	,pon.PersonSID
	,pon.OtherNameTypeSID
	,pon.FirstName
	,pon.CommonName
	,pon.MiddleNames
	,pon.LastName
	,pon.UserDefinedColumns
	,pon.PersonOtherNameXID
	,pon.LegacyKey
	,pon.IsDeleted
	,pon.CreateUser
	,pon.CreateTime
	,pon.UpdateUser
	,pon.UpdateTime
	,pon.RowGUID
	,pon.RowStamp
	,ponx.OtherNameTypeLabel
	,ponx.OtherNameTypeIsDefault
	,ponx.OtherNameTypeIsActive
	,ponx.OtherNameTypeRowGUID
	,ponx.GenderSID
	,ponx.NamePrefixSID
	,ponx.PersonFirstName
	,ponx.PersonCommonName
	,ponx.PersonMiddleNames
	,ponx.PersonLastName
	,ponx.BirthDate
	,ponx.DeathDate
	,ponx.HomePhone
	,ponx.MobilePhone
	,ponx.IsTextMessagingEnabled
	,ponx.ImportBatch
	,ponx.PersonRowGUID
	,ponx.IsDeleteEnabled
	,ponx.IsReselected
	,ponx.IsNullApplied
	,ponx.zContext
from
	sf.PersonOtherName      pon
join
	sf.vPersonOtherName#Ext ponx	on pon.PersonOtherNameSID = ponx.PersonOtherNameSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.PersonOtherName', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person other name assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonOtherNameSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this other name is based on', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person other name', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'OtherNameTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname or family name of the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person other name | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonOtherNameXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person other name record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person other name record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person other name record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the other name type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'OtherNameTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default other name type to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'OtherNameTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this other name type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'OtherNameTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the other name type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'OtherNameTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonFirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonCommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonMiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonLastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonOtherName', 'COLUMN', N'zContext'
GO
