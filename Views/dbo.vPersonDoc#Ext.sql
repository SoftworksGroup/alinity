SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonDoc#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPersonDoc#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PersonDoc base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPersonDoc (referred to as the "entity" view in SGI documentation).

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
	 pd.PersonDocSID
	,pdt.PersonDocTypeSCD
	,pdt.PersonDocTypeLabel
	,pdt.PersonDocTypeCategory
	,pdt.IsDefault                                                          PersonDocTypeIsDefault
	,pdt.IsActive                                                           PersonDocTypeIsActive
	,pdt.RowGUID                                                            PersonDocTypeRowGUID
	,ftype.FileTypeSCD                                                      FileTypeFileTypeSCD
	,ftype.FileTypeLabel
	,ftype.MimeType
	,ftype.IsInline
	,ftype.IsActive                                                         FileTypeIsActive
	,ftype.RowGUID                                                          FileTypeRowGUID
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
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,ag.ApplicationGrantSCD
	,ag.ApplicationGrantName
	,ag.IsDefault                                                           ApplicationGrantIsDefault
	,ag.RowGUID                                                             ApplicationGrantRowGUID
	,ar.ApplicationReportName
	,ar.IconFillColor
	,ar.DisplayRank
	,ar.IsCustom
	,ar.RowGUID                                                             ApplicationReportRowGUID
	,dbo.fPersonDoc#IsDeleteEnabled(pd.PersonDocSID)                        IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,cast(0 as bit)																												IsDocReplaced			--# Virtual column used by application to indicate when document is replaced with new upload
 ,dbo.fPersonDoc#IsReadGranted(pd.PersonDocSID, ag.ApplicationGrantSCD) IsReadGranted			--# Indicates if the current session user has access to view the record
 ,cast(case
				 when pd.CancelledTime is not null then 0
				 when pd.ProcessedTime is null and pd.ApplicationReportSID is not null then 1
				 else 0
			 end as bit)																											IsReportPending		--# Indicates the document will be generated based on a report to be generated by the reporting service
 ,cast(case when pd.CancelledTime is not null then 1 else 0 end as bit) IsReportCancelled --# Indicates the report was cancelled prior to being generated
 ,zpdc.ApplicationEntitySID																																--# Key of the entity (form type) this document was uploaded for
 ,zpdc.EntitySID																																					--# Key of the form record this document was uploaded for
 ,zpdc.IsPrimary																																					--# Used by the application to control primary setting on new document context | Always 1 (ON) where a primary document exists or otherwise NULL
--! </MoreColumns>
from
	dbo.PersonDoc        pd
join
	dbo.PersonDocType    pdt    on pd.PersonDocTypeSID = pdt.PersonDocTypeSID
join
	sf.FileType          ftype  on pd.FileTypeSID = ftype.FileTypeSID
join
	sf.Person            person on pd.PersonSID = person.PersonSID
left outer join
	sf.ApplicationGrant  ag     on pd.ApplicationGrantSID = ag.ApplicationGrantSID
left outer join
	sf.ApplicationReport ar     on pd.ApplicationReportSID = ar.ApplicationReportSID
--! <MoreJoins>
left outer join
	dbo.PersonDocContext zpdc on pd.PersonDocSID			 = zpdc.PersonDocSID and zpdc.IsPrimary = cast(1 as bit); -- link to primary context (if any) UX ensures only 1 is possible
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person doc assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the person doc type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the person doc type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default person doc type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person doc type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonDocTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'FileTypeFileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The MIME type to use when a client browser downloads or views a document.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'MimeType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a client browser downloads a document this indicates whether or not the browser should be asked to display rather than download the document. If the browser is unable to, due to lack of software or other settings, the file will instead be downloaded as normal.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsInline'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this file type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'FileTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'FileTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application grant | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application grant to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default application grant to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationGrantIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationGrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application report to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationReportName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 9 character value that describes the color the icon should be displayed in on the charm bar', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IconFillColor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the order this report appears in within report menus (built-in and custom reports are separated)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'DisplayRank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, indicates this report was added specificially to the configuration and is not a built-in product report', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsCustom'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application report record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationReportRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column used by application to indicate when document is replaced with new upload', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsDocReplaced'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the current session user has access to view the record', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsReadGranted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the document will be generated based on a report to be generated by the reporting service', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsReportPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the report was cancelled prior to being generated', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsReportCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the entity (form type) this document was uploaded for', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the form record this document was uploaded for', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used by the application to control primary setting on new document context | Always 1 (ON) where a primary document exists or otherwise NULL', 'SCHEMA', N'dbo', 'VIEW', N'vPersonDoc#Ext', 'COLUMN', N'IsPrimary'
GO
