SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExamQuestion] (
		[ExamQuestionSID]        [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamSectionSID]         [int] NOT NULL,
		[Sequence]               [smallint] NOT NULL,
		[QuestionText]           [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AttemptsAllowed]        [tinyint] NOT NULL,
		[Explanation]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KnowledgeDomainSID]     [int] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ExamQuestionXID]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_ExamQuestion_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExamQuestion]
		PRIMARY KEY
		CLUSTERED
		([ExamQuestionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam Question table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'CONSTRAINT', N'pk_ExamQuestion'
GO
ALTER TABLE [dbo].[ExamQuestion]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExamQuestion]
	CHECK
	([dbo].[fExamQuestion#Check]([ExamQuestionSID],[ExamSectionSID],[Sequence],[AttemptsAllowed],[KnowledgeDomainSID],[IsActive],[ExamQuestionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ExamQuestion]
CHECK CONSTRAINT [ck_ExamQuestion]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_AttemptsAllowed]
	DEFAULT ((1)) FOR [AttemptsAllowed]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [DF_ExamQuestion_Sequence]
	DEFAULT ((0)) FOR [Sequence]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ExamQuestion]
	ADD
	CONSTRAINT [df_ExamQuestion_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ExamQuestion]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamQuestion_ExamSection_ExamSectionSID]
	FOREIGN KEY ([ExamSectionSID]) REFERENCES [dbo].[ExamSection] ([ExamSectionSID])
ALTER TABLE [dbo].[ExamQuestion]
	CHECK CONSTRAINT [fk_ExamQuestion_ExamSection_ExamSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam section system ID column in the Exam Question table match a exam section system ID in the Exam Section table. It also ensures that records in the Exam Section table cannot be deleted if matching child records exist in Exam Question. Finally, the constraint blocks changes to the value of the exam section system ID column in the Exam Section if matching child records exist in Exam Question.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'CONSTRAINT', N'fk_ExamQuestion_ExamSection_ExamSectionSID'
GO
ALTER TABLE [dbo].[ExamQuestion]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamQuestion_KnowledgeDomain_KnowledgeDomainSID]
	FOREIGN KEY ([KnowledgeDomainSID]) REFERENCES [dbo].[KnowledgeDomain] ([KnowledgeDomainSID])
ALTER TABLE [dbo].[ExamQuestion]
	CHECK CONSTRAINT [fk_ExamQuestion_KnowledgeDomain_KnowledgeDomainSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the knowledge domain system ID column in the Exam Question table match a knowledge domain system ID in the Knowledge Domain table. It also ensures that records in the Knowledge Domain table cannot be deleted if matching child records exist in Exam Question. Finally, the constraint blocks changes to the value of the knowledge domain system ID column in the Knowledge Domain if matching child records exist in Exam Question.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'CONSTRAINT', N'fk_ExamQuestion_KnowledgeDomain_KnowledgeDomainSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExamQuestion_ExamSectionSID_ExamQuestionSID]
	ON [dbo].[ExamQuestion] ([ExamSectionSID], [ExamQuestionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam Section SID foreign key column and avoids row contention on (parent) Exam Section updates', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'INDEX', N'ix_ExamQuestion_ExamSectionSID_ExamQuestionSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExamQuestion_KnowledgeDomainSID_ExamQuestionSID]
	ON [dbo].[ExamQuestion] ([KnowledgeDomainSID], [ExamQuestionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Knowledge Domain SID foreign key column and avoids row contention on (parent) Knowledge Domain updates', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'INDEX', N'ix_ExamQuestion_KnowledgeDomainSID_ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exam questions are organized into sections.  Each question requires the text to present to the member  Links to references are not stored in the question text but as separate entries in Exam-Question-Reference in order to provide more consistency in formatting and to ensure links are opened in a separate browser tab.  The number of attempts allowed to answer the question can also be configured.  This setting defaults to 1 but can be increased so that if the question is first answered incorrectly, 1 or more additional attempts can be provided with prompting from the user interface.  Note that when then exam is validated, the system checks to ensure the number of attempts is at least 1 less than the total number of answer-choices available. When the user answers a question correctly or exhausts all answer attempts, Explanation text can be configured reinforcing what the correct response is.  For some situations it will be desirable to have the system randomize questions selected and this is achieved by ', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam question assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'ExamQuestionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam section assigned to this exam question', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'ExamSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the display order of the question within the section | If value is not set the order defaults to the entry order of the records', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The question text to present to the exam candidate. Include reference links where they exist.  HTML formatting is supported.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'QuestionText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of attempts the exam candidate is provided to select the correct answer.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'AttemptsAllowed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The knowledge domain assigned to this exam question', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'KnowledgeDomainSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this exam question record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam question | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'ExamQuestionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam question | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam question record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam question | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam question record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam question record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamQuestion', 'CONSTRAINT', N'uk_ExamQuestion_RowGUID'
GO
ALTER TABLE [dbo].[ExamQuestion] SET (LOCK_ESCALATION = TABLE)
GO
