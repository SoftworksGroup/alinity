SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonDocContext#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPersonDocContext#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PersonDocContext base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPersonDocContext (referred to as the "entity" view in SGI documentation).

Columns required to support the EF include constants passed by client and middle tier modules into the table API procedures as
parameters. These values control the insert/update/delete behaviour of the sprocs. For example: the IsNullApplied bit is set ON
in the view so that update procedures overwrite column values when matching parameters are NULL on calls from the client tier.
The default for this column in the call signature of the sproc is 0 (off) so that calls from the back-end do not overwrite with
null values.  The zContext XML value is always null but is required for binding to sproc calls using EF and RIA.

You can add additional columns, joins and examples of calling syntax, by placing them between the code tag pairs provided.  Items
placed within code tag pairs are preserved on regeneration.  Note that all additions to this view become part of the base product
and deploy for all client configurations.  This view is NOT an extension point for client-specific configurations.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pdc.PersonDocContextSID
	,pd.PersonSID
	,pd.PersonDocTypeSID
	,pd.DocumentTitle
	,pd.AdditionalInfo
	,pd.ArchivedTime
	,pd.FileTypeSID
	,pd.FileTypeSCD
	,pd.ShowToRegistrant
	,pd.ApplicationGrantSID
	,pd.IsRemoved
	,pd.ExpiryDate
	,pd.ApplicationReportSID
	,pd.ReportEntitySID
	,pd.CancelledTime
	,pd.ProcessedTime
	,pd.ContextLink
	,pd.RowGUID                                                             PersonDocRowGUID
	,ae.ApplicationEntitySCD
	,ae.ApplicationEntityName
	,ae.IsMergeDataSource
	,ae.RowGUID                                                             ApplicationEntityRowGUID
	,dbo.fPersonDocContext#IsDeleteEnabled(pdc.PersonDocContextSID)         IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.PersonDocContext pdc
join
	dbo.PersonDoc        pd     on pdc.PersonDocSID = pd.PersonDocSID
join
	sf.ApplicationEntity ae     on pdc.ApplicationEntitySID = ae.ApplicationEntitySID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person doc context assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'PersonDocContextSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this doc is based on', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person doc', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'PersonDocTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name or title of the document | This value is assigned automatically for system generated documents but is provided by the user for support documents (default image names often appear here).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'DocumentTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stores the name of the requirement or the form-field for which this document was provided | This value is combined with the document type to describe the document on the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'AdditionalInfo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the document was put into archived status', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person doc', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".pdf" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this document should be shown to the registrant it is related to on the client portal.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ShowToRegistrant'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether content of the document was removed by admin (e.g. to protect privacy)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'IsRemoved'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the document is no longer valid in meeting a licensing requirement (e.g. a new criminal record check may be required every 5 years) | This value is entered by the user so reflects their timezone', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ExpiryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The report assigned to this person doc', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ApplicationReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only applies when a document is generated from a report - provides key of the record to base the report on.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ReportEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the report to produce the document was cancelled (not generated) after being inserted but before being processed (the record can be deleted).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the report was generated and stored as document-content - appliesonly  when report key is identified.  | When this value is filled out and report-SID is filled out indicates report generation is no longer pending', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier used internally by the application to link the document to a source record (a context) to be inserted only after the document is inserted.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ContextLink'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'PersonDocRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDocContext#Ext', 'COLUMN', N'zContext'
GO
