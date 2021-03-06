SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonGroupDoc#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPersonGroupDoc#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PersonGroupDoc base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPersonGroupDoc (referred to as the "entity" view in SGI documentation).

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
	 pgd.PersonGroupDocSID
	,pgf.ParentPersonGroupFolderSID
	,pgf.PersonGroupSID
	,pgf.FolderName
	,pgf.IsRoot
	,pgf.RowGUID                                                            PersonGroupFolderRowGUID
	,ftype.FileTypeSCD                                                      FileTypeFileTypeSCD
	,ftype.FileTypeLabel
	,ftype.MimeType
	,ftype.IsInline
	,ftype.IsActive                                                         FileTypeIsActive
	,ftype.RowGUID                                                          FileTypeRowGUID
	,dbo.fPersonGroupDoc#IsDeleteEnabled(pgd.PersonGroupDocSID)             IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.PersonGroupDoc    pgd
join
	dbo.PersonGroupFolder pgf    on pgd.PersonGroupFolderSID = pgf.PersonGroupFolderSID
join
	sf.FileType           ftype  on pgd.FileTypeSID = ftype.FileTypeSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person group doc assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'PersonGroupDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person group this folder is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'PersonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person group folder record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'PersonGroupFolderRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'FileTypeFileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The MIME type to use when a client browser downloads or views a document.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'MimeType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a client browser downloads a document this indicates whether or not the browser should be asked to display rather than download the document. If the browser is unable to, due to lack of software or other settings, the file will instead be downloaded as normal.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'IsInline'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this file type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'FileTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'FileTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupDoc#Ext', 'COLUMN', N'zContext'
GO
