SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExamQuestionChoice] (
		[ExamQuestionChoiceSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamQuestionSID]           [int] NOT NULL,
		[ChoiceText]                [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Sequence]                  [tinyint] NOT NULL,
		[IsCorrectAnswer]           [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[ExamQuestionChoiceXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_ExamQuestionChoice_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExamQuestionChoice]
		PRIMARY KEY
		CLUSTERED
		([ExamQuestionChoiceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam Question Choice table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'CONSTRAINT', N'pk_ExamQuestionChoice'
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExamQuestionChoice]
	CHECK
	([dbo].[fExamQuestionChoice#Check]([ExamQuestionChoiceSID],[ExamQuestionSID],[Sequence],[IsCorrectAnswer],[IsActive],[ExamQuestionChoiceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
CHECK CONSTRAINT [ck_ExamQuestionChoice]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_IsCorrectAnswer]
	DEFAULT (CONVERT([bit],(0))) FOR [IsCorrectAnswer]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_Sequence]
	DEFAULT ((0)) FOR [Sequence]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	ADD
	CONSTRAINT [df_ExamQuestionChoice_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ExamQuestionChoice]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamQuestionChoice_ExamQuestion_ExamQuestionSID]
	FOREIGN KEY ([ExamQuestionSID]) REFERENCES [dbo].[ExamQuestion] ([ExamQuestionSID])
ALTER TABLE [dbo].[ExamQuestionChoice]
	CHECK CONSTRAINT [fk_ExamQuestionChoice_ExamQuestion_ExamQuestionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam question system ID column in the Exam Question Choice table match a exam question system ID in the Exam Question table. It also ensures that records in the Exam Question table cannot be deleted if matching child records exist in Exam Question Choice. Finally, the constraint blocks changes to the value of the exam question system ID column in the Exam Question if matching child records exist in Exam Question Choice.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'CONSTRAINT', N'fk_ExamQuestionChoice_ExamQuestion_ExamQuestionSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ExamQuestionChoice_ExamQuestionSID_IsCorrectAnswer]
	ON [dbo].[ExamQuestionChoice] ([ExamQuestionSID], [IsCorrectAnswer])
	WHERE (([IsCorrectAnswer]=CONVERT([bit],(1))))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Exam Question SID + Is Correct Answer" columns is not duplicated where the condition: "([IsCorrectAnswer]=CONVERT([bit],(1)))" is met', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'INDEX', N'ux_ExamQuestionChoice_ExamQuestionSID_IsCorrectAnswer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The possible answers for each question are recorded as separate entries in the Exam-Question-Choice table. A question may have 2 or more choices defined as answers – at least one of which must be marked as the correct answer. (Less than 2 choices is invalid).  As of this writing multi-select questions are not supported so only a single choice can be marked as the correct answer (checked when the exam is verified).  Where the same choices are used by many questions, e.g. “Yes” and “No”, they can be copied from a previous question through a feature in the user interface. As of this writing all questions use a radio-button-set control type.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam question choice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'ExamQuestionChoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam question this choice is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the display order of the choice within the list of choices for the question | If value is not set the order defaults to the entry order of the records', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this exam question choice record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam question choice | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'ExamQuestionChoiceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam question choice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam question choice record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam question choice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam question choice record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam question choice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionChoice', 'CONSTRAINT', N'uk_ExamQuestionChoice_RowGUID'
GO
ALTER TABLE [dbo].[ExamQuestionChoice] SET (LOCK_ESCALATION = TABLE)
GO
