SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExamStatus] (
		[ExamStatusSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamStatusSCD]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExamStatusLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Sequence]               [int] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ExamStatusXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_ExamStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExamStatus_ExamStatusSCD]
		UNIQUE
		NONCLUSTERED
		([ExamStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExamStatus_ExamStatusLabel]
		UNIQUE
		NONCLUSTERED
		([ExamStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExamStatus]
		PRIMARY KEY
		CLUSTERED
		([ExamStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'CONSTRAINT', N'pk_ExamStatus'
GO
ALTER TABLE [dbo].[ExamStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExamStatus]
	CHECK
	([dbo].[fExamStatus#Check]([ExamStatusSID],[ExamStatusSCD],[ExamStatusLabel],[Sequence],[IsDefault],[ExamStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ExamStatus]
CHECK CONSTRAINT [ck_ExamStatus]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_Sequence]
	DEFAULT ((0)) FOR [Sequence]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ExamStatus]
	ADD
	CONSTRAINT [df_ExamStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ExamStatus_IsDefault]
	ON [dbo].[ExamStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Exam Status', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'INDEX', N'ux_ExamStatus_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exam Result is a system table recording the result types expected by the system.  This includes final results such as Passed/Fail and also pending status – where the exam is scheduled/started but not et complete, and where the exam was not-taken due to cancellation.  Administrators cannot add or remove entries from this table, but the label text displayed to members can be changed as required.', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'ExamStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the exam status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'ExamStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the exam status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'ExamStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to control the display order of exam results when presented on the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default exam status to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'ExamStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'CONSTRAINT', N'uk_ExamStatus_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Exam Status SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'CONSTRAINT', N'uk_ExamStatus_ExamStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Exam Status Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamStatus', 'CONSTRAINT', N'uk_ExamStatus_ExamStatusLabel'
GO
ALTER TABLE [dbo].[ExamStatus] SET (LOCK_ESCALATION = TABLE)
GO
