SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vMessageLinkStatus]
as
/*********************************************************************************************************************************
View    : sf.vMessageLinkStatus
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.MessageLinkStatus - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.MessageLinkStatus table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vMessageLinkStatusExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vMessageLinkStatusExt documentation for details. To add additional content to this view, customize
the sf.vMessageLinkStatusExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 mls.MessageLinkStatusSID
	,mls.MessageLinkStatusSCD
	,mls.MessageLinkStatusLabel
	,mls.UsageNotes
	,mls.IsResendEnabled
	,mls.IsActive
	,mls.IsDefault
	,mls.UserDefinedColumns
	,mls.MessageLinkStatusXID
	,mls.LegacyKey
	,mls.IsDeleted
	,mls.CreateUser
	,mls.CreateTime
	,mls.UpdateUser
	,mls.UpdateTime
	,mls.RowGUID
	,mls.RowStamp
	,mlsx.IsDeleteEnabled
	,mlsx.IsReselected
	,mlsx.IsNullApplied
	,mlsx.zContext
from
	sf.MessageLinkStatus      mls
join
	sf.vMessageLinkStatus#Ext mlsx	on mls.MessageLinkStatusSID = mlsx.MessageLinkStatusSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.MessageLinkStatus', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the message link status assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'MessageLinkStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message link status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'MessageLinkStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the message link status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'MessageLinkStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the scenarios this status is intended to support', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the email invitation can be resent for this status (e.g. off for "confirmed") | This value cannot be set by the end user', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsResendEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this message link status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default message link status to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the message link status | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'MessageLinkStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the message link status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this message link status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the message link status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the message link status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the message link status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLinkStatus', 'COLUMN', N'zContext'
GO
