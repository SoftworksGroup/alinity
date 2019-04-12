SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormList] (
		[FormListSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[FormListCode]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormListLabel]          [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ToolTip]                [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormListXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FormList_FormListCode]
		UNIQUE
		NONCLUSTERED
		([FormListCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormList_FormListLabel]
		UNIQUE
		NONCLUSTERED
		([FormListLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormList_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormList]
		PRIMARY KEY
		CLUSTERED
		([FormListSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form List table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'CONSTRAINT', N'pk_FormList'
GO
ALTER TABLE [sf].[FormList]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormList]
	CHECK
	([sf].[fFormList#Check]([FormListSID],[FormListCode],[FormListLabel],[ToolTip],[FormListXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormList]
CHECK CONSTRAINT [ck_FormList]
GO
ALTER TABLE [sf].[FormList]
	ADD
	CONSTRAINT [df_FormList_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormList]
	ADD
	CONSTRAINT [df_FormList_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormList]
	ADD
	CONSTRAINT [df_FormList_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormList]
	ADD
	CONSTRAINT [df_FormList_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormList]
	ADD
	CONSTRAINT [df_FormList_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormList]
	ADD
	CONSTRAINT [df_FormList_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form list assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'FormListSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code used to identify the list when referenced within a form.  DO NOT change this value without first ensuring any forms relying on it have been updated.', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'FormListCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form list to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'FormListLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Guidance about the intended use of thd form.  This value appears as help text when forms are being selected by end users and also by administrators who maintain the form.', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form list | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'FormListXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form list | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form list record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form list | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form list record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form list record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form List Code column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'CONSTRAINT', N'uk_FormList_FormListCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form List Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'CONSTRAINT', N'uk_FormList_FormListLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormList', 'CONSTRAINT', N'uk_FormList_RowGUID'
GO
ALTER TABLE [sf].[FormList] SET (LOCK_ESCALATION = TABLE)
GO
