SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonDocContext]
as
/*********************************************************************************************************************************
View    : dbo.vPersonDocContext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PersonDocContext - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PersonDocContext table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPersonDocContextExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPersonDocContextExt documentation for details. To add additional content to this view, customize
the dbo.vPersonDocContextExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pdc.PersonDocContextSID
	,pdc.PersonDocSID
	,pdc.ApplicationEntitySID
	,pdc.EntitySID
	,pdc.IsPrimary
	,pdc.UserDefinedColumns
	,pdc.PersonDocContextXID
	,pdc.LegacyKey
	,pdc.IsDeleted
	,pdc.CreateUser
	,pdc.CreateTime
	,pdc.UpdateUser
	,pdc.UpdateTime
	,pdc.RowGUID
	,pdc.RowStamp
	,pdcx.PersonSID
	,pdcx.PersonDocTypeSID
	,pdcx.DocumentTitle
	,pdcx.AdditionalInfo
	,pdcx.ArchivedTime
	,pdcx.FileTypeSID
	,pdcx.FileTypeSCD
	,pdcx.ShowToRegistrant
	,pdcx.ApplicationGrantSID
	,pdcx.IsRemoved
	,pdcx.ExpiryDate
	,pdcx.ApplicationReportSID
	,pdcx.ReportEntitySID
	,pdcx.CancelledTime
	,pdcx.ProcessedTime
	,pdcx.ContextLink
	,pdcx.PersonDocRowGUID
	,pdcx.ApplicationEntitySCD
	,pdcx.ApplicationEntityName
	,pdcx.IsMergeDataSource
	,pdcx.ApplicationEntityRowGUID
	,pdcx.IsDeleteEnabled
	,pdcx.IsReselected
	,pdcx.IsNullApplied
	,pdcx.zContext
from
	dbo.PersonDocContext      pdc
join
	dbo.vPersonDocContext#Ext pdcx	on pdc.PersonDocContextSID = pdcx.PersonDocContextSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PersonDocContext', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person doc context assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'PersonDocContextSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person doc this context is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this person doc context', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SID of the related entity. The query to get the entity row can be determined by the entity type (ApplicationEntitySID).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is the primary, or most important, document for this context.  This is normally sent to a PDF version of the system form for registration events: application form, renewal form, reinstatement form, etc.  The value is set by the system automatically. There can only be one primary document for each context (a context is a combination of entity and record number - e.g. a specific year''s renewal form).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsPrimary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person doc context | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'PersonDocContextXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person doc context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person doc context record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person doc context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person doc context record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc context record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this doc is based on', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person doc', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'PersonDocTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name or title of the document | This value is assigned automatically for system generated documents but is provided by the user for support documents (default image names often appear here).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'DocumentTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stores the name of the requirement or the form-field for which this document was provided | This value is combined with the document type to describe the document on the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'AdditionalInfo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the document was put into archived status', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person doc', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".pdf" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this document should be shown to the registrant it is related to on the client portal.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ShowToRegistrant'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether content of the document was removed by admin (e.g. to protect privacy)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsRemoved'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the document is no longer valid in meeting a licensing requirement (e.g. a new criminal record check may be required every 5 years) | This value is entered by the user so reflects their timezone', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ExpiryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The report assigned to this person doc', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ApplicationReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only applies when a document is generated from a report - provides key of the record to base the report on.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ReportEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the report to produce the document was cancelled (not generated) after being inserted but before being processed (the record can be deleted).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the report was generated and stored as document-content - appliesonly  when report key is identified.  | When this value is filled out and report-SID is filled out indicates report generation is no longer pending', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier used internally by the application to link the document to a source record (a context) to be inserted only after the document is inserted.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ContextLink'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'PersonDocRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext', 'COLUMN', N'zContext'
GO
