SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Exam] (
		[ExamSID]                       [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamName]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExamCategory]                  [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PassingScore]                  [int] NULL,
		[EffectiveTime]                 [datetime] NOT NULL,
		[ExpiryTime]                    [datetime] NULL,
		[IsOnlineExam]                  [bit] NOT NULL,
		[IsEnabledOnPortal]             [bit] NOT NULL,
		[Sequence]                      [int] NOT NULL,
		[CultureSID]                    [int] NOT NULL,
		[InstructionText]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastVerifiedTime]              [datetimeoffset](7) NULL,
		[MinLagDaysBetweenAttempts]     [smallint] NULL,
		[MaxAttemptsPerYear]            [tinyint] NULL,
		[VendorExamID]                  [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]            [xml] NULL,
		[ExamXID]                       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_Exam_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Exam_ExamName]
		UNIQUE
		NONCLUSTERED
		([ExamName])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Exam]
		PRIMARY KEY
		CLUSTERED
		([ExamSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'CONSTRAINT', N'pk_Exam'
GO
ALTER TABLE [dbo].[Exam]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Exam]
	CHECK
	([dbo].[fExam#Check]([ExamSID],[ExamName],[ExamCategory],[PassingScore],[EffectiveTime],[ExpiryTime],[IsOnlineExam],[IsEnabledOnPortal],[Sequence],[CultureSID],[LastVerifiedTime],[MinLagDaysBetweenAttempts],[MaxAttemptsPerYear],[VendorExamID],[ExamXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Exam]
CHECK CONSTRAINT [ck_Exam]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_IsOnlineExam]
	DEFAULT (CONVERT([bit],(0))) FOR [IsOnlineExam]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_IsEnabledOnPortal]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEnabledOnPortal]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_Sequence]
	DEFAULT ((0)) FOR [Sequence]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_MinLagDaysBetweenAttempts]
	DEFAULT ((0)) FOR [MinLagDaysBetweenAttempts]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_MaxAttemptsPerYear]
	DEFAULT ((99)) FOR [MaxAttemptsPerYear]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Exam]
	ADD
	CONSTRAINT [df_Exam_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Exam]
	WITH CHECK
	ADD CONSTRAINT [fk_Exam_SF_Culture_CultureSID]
	FOREIGN KEY ([CultureSID]) REFERENCES [sf].[Culture] ([CultureSID])
ALTER TABLE [dbo].[Exam]
	CHECK CONSTRAINT [fk_Exam_SF_Culture_CultureSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the culture system ID column in the Exam table match a culture system ID in the Culture table. It also ensures that records in the Culture table cannot be deleted if matching child records exist in Exam. Finally, the constraint blocks changes to the value of the culture system ID column in the Culture if matching child records exist in Exam.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'CONSTRAINT', N'fk_Exam_SF_Culture_CultureSID'
GO
CREATE NONCLUSTERED INDEX [ix_Exam_CultureSID_ExamSID]
	ON [dbo].[Exam] ([CultureSID], [ExamSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Culture SID foreign key column and avoids row contention on (parent) Culture updates', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'INDEX', N'ix_Exam_CultureSID_ExamSID'
GO
CREATE NONCLUSTERED INDEX [ix_Exam_ExamCategory_ExamName]
	ON [dbo].[Exam] ([ExamCategory], [ExamName])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Exam searches based on the Exam Category + Exam Name columns', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'INDEX', N'ix_Exam_ExamCategory_ExamName'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Exam_VendorExamID]
	ON [dbo].[Exam] ([VendorExamID])
	WHERE (([VendorExamID] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Vendor Exam ID value is not duplicated where the condition: "([VendorExamID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'INDEX', N'ux_Exam_VendorExamID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Exam entity is a master table of exam types recorded in member records.  The exams may be externally administered, or they may be exams configured within the Alinity Jurisprudence module.  The exam itself is the master category but each instance or sitting of an exam is recorded as an “Exam Offering” record. For an exam to appear on the member portal, it must have an non-expired Exam Offering.   Where the configuration supports multiple languages, exams must be created once in each language supported.  The “Culture” identifier ensures that the correct exam is offered to the member when they login to the portal according to the culture defined in their profile.   Exams no longer used can be marked in-active to prevent them from appearing in drop-down lists for administrators.  For Exams configured through the Jurisprudence Module, instructions/introductory text is stored at this level for presentation to the user.  The record also includes a Last-Verified-Time value that is set when validation of exams configured through Jurisprudence is achieved.  The process checks the exams for all business rules and if passed, the time is set.  When changes are made to the exam configuration values, re-verification is required.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the exam to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'ExamName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize exams (e.g. for display in different areas on member forms)', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'ExamCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum score for passing the exam (required for Alinity exams). Leave blank to always record pass/fail manually for external exams.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'PassingScore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the exam is enabled for selection on the member portal (applies only to online exams)', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'IsEnabledOnPortal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls order this exam appears in relative to other exams associated with the same credential | If not set the order defaults to entry order of the record', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the culture assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The question text to present to the exam candidate. Include reference links where they exist.  HTML formatting is supported.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'InstructionText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum days a member must wait between attempts at writing the exam', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'MinLagDaysBetweenAttempts'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of attempts a member is alloted to pass the exam within a registration year.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'MaxAttemptsPerYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam  | This value can be used when importing exam candidates to associate results with the correct exam', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'VendorExamID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'ExamXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'CONSTRAINT', N'uk_Exam_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Exam Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Exam', 'CONSTRAINT', N'uk_Exam_ExamName'
GO
ALTER TABLE [dbo].[Exam] SET (LOCK_ESCALATION = TABLE)
GO
