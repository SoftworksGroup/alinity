SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExamQuestionReference] (
		[ExamQuestionReferenceSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamQuestionSID]              [int] NOT NULL,
		[ReferenceTitle]               [nvarchar](125) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ReferenceURL]                 [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[ExamQuestionReferenceXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_ExamQuestionReference_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExamQuestionReference_ExamQuestionSID_ReferenceTitle]
		UNIQUE
		NONCLUSTERED
		([ExamQuestionSID], [ReferenceTitle])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExamQuestionReference]
		PRIMARY KEY
		CLUSTERED
		([ExamQuestionReferenceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam Question Reference table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'CONSTRAINT', N'pk_ExamQuestionReference'
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExamQuestionReference]
	CHECK
	([dbo].[fExamQuestionReference#Check]([ExamQuestionReferenceSID],[ExamQuestionSID],[ReferenceTitle],[ReferenceURL],[ExamQuestionReferenceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ExamQuestionReference]
CHECK CONSTRAINT [ck_ExamQuestionReference]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	ADD
	CONSTRAINT [df_ExamQuestionReference_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	ADD
	CONSTRAINT [df_ExamQuestionReference_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	ADD
	CONSTRAINT [df_ExamQuestionReference_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	ADD
	CONSTRAINT [df_ExamQuestionReference_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	ADD
	CONSTRAINT [df_ExamQuestionReference_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	ADD
	CONSTRAINT [df_ExamQuestionReference_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ExamQuestionReference]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamQuestionReference_ExamQuestion_ExamQuestionSID]
	FOREIGN KEY ([ExamQuestionSID]) REFERENCES [dbo].[ExamQuestion] ([ExamQuestionSID])
ALTER TABLE [dbo].[ExamQuestionReference]
	CHECK CONSTRAINT [fk_ExamQuestionReference_ExamQuestion_ExamQuestionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam question system ID column in the Exam Question Reference table match a exam question system ID in the Exam Question table. It also ensures that records in the Exam Question table cannot be deleted if matching child records exist in Exam Question Reference. Finally, the constraint blocks changes to the value of the exam question system ID column in the Exam Question if matching child records exist in Exam Question Reference.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'CONSTRAINT', N'fk_ExamQuestionReference_ExamQuestion_ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores label text (Reference-Title) and a link to support exam questions. The UI ensures the links are opened in a new tab in the browser to avoid navigating away from the Exam.  The exam is formatted to include the references below the main question text.  ', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam question reference assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'ExamQuestionReferenceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam question this reference is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam question reference | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'ExamQuestionReferenceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam question reference | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam question reference record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam question reference | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam question reference record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam question reference record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Exam Question SID + Reference Title" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'CONSTRAINT', N'uk_ExamQuestionReference_ExamQuestionSID_ReferenceTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestionReference', 'CONSTRAINT', N'uk_ExamQuestionReference_RowGUID'
GO
ALTER TABLE [dbo].[ExamQuestionReference] SET (LOCK_ESCALATION = TABLE)
GO
