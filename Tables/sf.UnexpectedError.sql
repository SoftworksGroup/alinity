SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[UnexpectedError] (
		[UnexpectedErrorSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[MessageSCD]             [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ProcName]               [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LineNumber]             [int] NULL,
		[ErrorNumber]            [int] NULL,
		[MessageText]            [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ErrorSeverity]          [int] NULL,
		[ErrorState]             [int] NULL,
		[SPIDNo]                 [int] NULL,
		[MachineName]            [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DBUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CallEvent]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CallParameter]          [int] NOT NULL,
		[CallSyntax]             [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[UnexpectedErrorXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_UnexpectedError_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_UnexpectedError]
		PRIMARY KEY
		CLUSTERED
		([UnexpectedErrorSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Unexpected Error table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'CONSTRAINT', N'pk_UnexpectedError'
GO
ALTER TABLE [sf].[UnexpectedError]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_UnexpectedError]
	CHECK
	([sf].[fUnexpectedError#Check]([UnexpectedErrorSID],[MessageSCD],[ProcName],[LineNumber],[ErrorNumber],[MessageText],[ErrorSeverity],[ErrorState],[SPIDNo],[MachineName],[DBUser],[CallEvent],[CallParameter],[CallSyntax],[UnexpectedErrorXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[UnexpectedError]
CHECK CONSTRAINT [ck_UnexpectedError]
GO
ALTER TABLE [sf].[UnexpectedError]
	ADD
	CONSTRAINT [df_UnexpectedError_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[UnexpectedError]
	ADD
	CONSTRAINT [df_UnexpectedError_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[UnexpectedError]
	ADD
	CONSTRAINT [df_UnexpectedError_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[UnexpectedError]
	ADD
	CONSTRAINT [df_UnexpectedError_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[UnexpectedError]
	ADD
	CONSTRAINT [df_UnexpectedError_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[UnexpectedError]
	ADD
	CONSTRAINT [df_UnexpectedError_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_UnexpectedError_LegacyKey]
	ON [sf].[UnexpectedError] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'INDEX', N'ux_UnexpectedError_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unexpected error assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'UnexpectedErrorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the unexpected error | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'UnexpectedErrorXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the unexpected error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this unexpected error record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the unexpected error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the unexpected error record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the unexpected error record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'UnexpectedError', 'CONSTRAINT', N'uk_UnexpectedError_RowGUID'
GO
ALTER TABLE [sf].[UnexpectedError] SET (LOCK_ESCALATION = TABLE)
GO
