SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vExamQuestionChoice]
as
/*********************************************************************************************************************************
View    : dbo.vExamQuestionChoice
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.ExamQuestionChoice - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.ExamQuestionChoice table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vExamQuestionChoiceExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vExamQuestionChoiceExt documentation for details. To add additional content to this view, customize
the dbo.vExamQuestionChoiceExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 eqc.ExamQuestionChoiceSID
	,eqc.ExamQuestionSID
	,eqc.ChoiceText
	,eqc.Sequence
	,eqc.IsCorrectAnswer
	,eqc.IsActive
	,eqc.UserDefinedColumns
	,eqc.ExamQuestionChoiceXID
	,eqc.LegacyKey
	,eqc.IsDeleted
	,eqc.CreateUser
	,eqc.CreateTime
	,eqc.UpdateUser
	,eqc.UpdateTime
	,eqc.RowGUID
	,eqc.RowStamp
	,eqcx.ExamSectionSID
	,eqcx.ExamQuestionSequence
	,eqcx.AttemptsAllowed
	,eqcx.KnowledgeDomainSID
	,eqcx.ExamQuestionIsActive
	,eqcx.ExamQuestionRowGUID
	,eqcx.IsDeleteEnabled
	,eqcx.IsReselected
	,eqcx.IsNullApplied
	,eqcx.zContext
from
	dbo.ExamQuestionChoice      eqc
join
	dbo.vExamQuestionChoice#Ext eqcx	on eqc.ExamQuestionChoiceSID = eqcx.ExamQuestionChoiceSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.ExamQuestionChoice', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam question choice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamQuestionChoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam question this choice is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the display order of the choice within the list of choices for the question | If value is not set the order defaults to the entry order of the records', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this exam question choice record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam question choice | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamQuestionChoiceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam question choice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam question choice record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam question choice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam question choice record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam question choice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam section assigned to this exam question', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the display order of the question within the section | If value is not set the order defaults to the entry order of the records', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamQuestionSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of attempts the exam candidate is provided to select the correct answer.', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'AttemptsAllowed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The knowledge domain assigned to this exam question', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'KnowledgeDomainSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this exam question record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamQuestionIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam question record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'ExamQuestionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vExamQuestionChoice', 'COLUMN', N'zContext'
GO
