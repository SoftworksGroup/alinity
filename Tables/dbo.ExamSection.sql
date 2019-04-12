SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExamSection] (
		[ExamSectionSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamSID]                 [int] NOT NULL,
		[Sequence]                [smallint] NOT NULL,
		[SectionTitle]            [nvarchar](85) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SectionText]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RandomQuestionCount]     [smallint] NOT NULL,
		[WeightPerQuestion]       [smallint] NOT NULL,
		[MinimumCorrect]          [smallint] NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[ExamSectionXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_ExamSection_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExamSection_ExamSID_SectionTitle]
		UNIQUE
		NONCLUSTERED
		([ExamSID], [SectionTitle])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExamSection]
		PRIMARY KEY
		CLUSTERED
		([ExamSectionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam Section table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'CONSTRAINT', N'pk_ExamSection'
GO
ALTER TABLE [dbo].[ExamSection]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExamSection]
	CHECK
	([dbo].[fExamSection#Check]([ExamSectionSID],[ExamSID],[Sequence],[SectionTitle],[RandomQuestionCount],[WeightPerQuestion],[MinimumCorrect],[ExamSectionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ExamSection]
CHECK CONSTRAINT [ck_ExamSection]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_Sequence]
	DEFAULT ((0)) FOR [Sequence]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_RandomQuestionCount]
	DEFAULT ((0)) FOR [RandomQuestionCount]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_WeightPerQuestion]
	DEFAULT ((0)) FOR [WeightPerQuestion]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_MinimumCorrect]
	DEFAULT ((0)) FOR [MinimumCorrect]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ExamSection]
	ADD
	CONSTRAINT [df_ExamSection_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ExamSection]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamSection_Exam_ExamSID]
	FOREIGN KEY ([ExamSID]) REFERENCES [dbo].[Exam] ([ExamSID])
ALTER TABLE [dbo].[ExamSection]
	CHECK CONSTRAINT [fk_ExamSection_Exam_ExamSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam system ID column in the Exam Section table match a exam system ID in the Exam table. It also ensures that records in the Exam table cannot be deleted if matching child records exist in Exam Section. Finally, the constraint blocks changes to the value of the exam system ID column in the Exam if matching child records exist in Exam Section.', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'CONSTRAINT', N'fk_ExamSection_Exam_ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To create an exam through the Jurisprudence module the starting point is creating one or more Exam Sections.  The section visually partition questions in the exam.  Each section has a title and may include introductory text. A single section can be used. The Section can also be configured to control how exam results will be calculated.  First, a Minimum-Score value can be set.  If the member does not achieve this score for the section, then they will be deemed as having failed the exam – regardless of how well they do in completing any other sections. (The UI does not cut the user off early – the entire exam can still be completed).  Leave the setting at 0 to avoid applying a minimum-score criteria. The second parameter impacting scoring is the Ratio-Of-Total-Score value. This can be used to establish the weight this section’s score should receive in calculating the total score. For example, if section 1 should be worth 50% of the total score and if the member achieved 30 points out of 50 in the section; then 0.50 x 30 = 15 points out of 0.50 x 50 = 25 point is the resulting weighted score.  If the value is left at the default of 0 then no such ratio is applied and the score is calculated based on total points across all Sections.  Note that ratios must either be used on all sections and total 1.00 (100%), or, they cannot be used on any section. ', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam section assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'ExamSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the display order of this exam section within the exam | If value is not set the order defaults to the entry order of the records', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The question text to present to the exam candidate. Include reference links where they exist.  HTML formatting is supported.', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'SectionText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of questions to select randomly for inclusion in each registrants exam - "0" to include ALL questions', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'RandomQuestionCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The weighting of each question in this section.  Multiplied by questions included in section defines total mark possible.', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'WeightPerQuestion'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Set to a minimum score (weighted units) if passing the exam requires a minimum score on this section, otherwise, leave as 0.', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'MinimumCorrect'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam section | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'ExamSectionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam section | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam section record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam section | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam section record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam section record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'CONSTRAINT', N'uk_ExamSection_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Exam SID + Section Title" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamSection', 'CONSTRAINT', N'uk_ExamSection_ExamSID_SectionTitle'
GO
ALTER TABLE [dbo].[ExamSection] SET (LOCK_ESCALATION = TABLE)
GO
