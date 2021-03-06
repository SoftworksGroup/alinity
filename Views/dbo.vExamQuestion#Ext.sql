SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vExamQuestion#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vExamQuestion#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.ExamQuestion base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vExamQuestion (referred to as the "entity" view in SGI documentation).

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
	 eq.ExamQuestionSID
	,es.ExamSID
	,es.Sequence                                                            ExamSectionSequence
	,es.SectionTitle
	,es.RandomQuestionCount
	,es.WeightPerQuestion
	,es.MinimumCorrect
	,es.RowGUID                                                             ExamSectionRowGUID
	,kd.KnowledgeDomainLabel
	,kd.IsDefault                                                           KnowledgeDomainIsDefault
	,kd.IsActive                                                            KnowledgeDomainIsActive
	,kd.RowGUID                                                             KnowledgeDomainRowGUID
	,dbo.fExamQuestion#IsDeleteEnabled(eq.ExamQuestionSID)                  IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.ExamQuestion    eq
join
	dbo.ExamSection     es     on eq.ExamSectionSID = es.ExamSectionSID
join
	dbo.KnowledgeDomain kd     on eq.KnowledgeDomainSID = kd.KnowledgeDomainSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam question assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the display order of this exam section within the exam | If value is not set the order defaults to the entry order of the records', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'ExamSectionSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of questions to select randomly for inclusion in each registrants exam - "0" to include ALL questions', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'RandomQuestionCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The weighting of each question in this section.  Multiplied by questions included in section defines total mark possible.', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'WeightPerQuestion'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Set to a minimum score (weighted units) if passing the exam requires a minimum score on this section, otherwise, leave as 0.', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'MinimumCorrect'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam section record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'ExamSectionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the knowledge domain to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'KnowledgeDomainLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default knowledge domain to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'KnowledgeDomainIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this knowledge domain record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'KnowledgeDomainIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the knowledge domain record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'KnowledgeDomainRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestion#Ext', 'COLUMN', N'zContext'
GO
