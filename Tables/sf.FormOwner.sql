SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormOwner] (
		[FormOwnerSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[FormOwnerSCD]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormOwnerLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsAssignee]             [bit] NOT NULL,
		[Description]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormOwnerXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FormOwner_FormOwnerLabel]
		UNIQUE
		NONCLUSTERED
		([FormOwnerLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormOwner_FormOwnerSCD]
		UNIQUE
		NONCLUSTERED
		([FormOwnerSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormOwner_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormOwner]
		PRIMARY KEY
		CLUSTERED
		([FormOwnerSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form Owner table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'CONSTRAINT', N'pk_FormOwner'
GO
ALTER TABLE [sf].[FormOwner]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormOwner]
	CHECK
	([sf].[fFormOwner#Check]([FormOwnerSID],[FormOwnerSCD],[FormOwnerLabel],[IsAssignee],[FormOwnerXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormOwner]
CHECK CONSTRAINT [ck_FormOwner]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_IsAssignee]
	DEFAULT ((0)) FOR [IsAssignee]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormOwner]
	ADD
	CONSTRAINT [df_FormOwner_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormOwner_LegacyKey]
	ON [sf].[FormOwner] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'INDEX', N'ux_FormOwner_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores a list of codes used by the application to track progress on forms. These codes identify the person or group expected to perform the next action on the form to progress it to the next step.  These values are associated with the status values that forms can be assigned. The list cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Specific application logic detects each status type using the Form-Owner-SCD value from this table.', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form owner assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form owner | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form owner to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this owner is a sub-type of assignee', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'IsAssignee'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An explanation of when this status is applied to the form', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form owner | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'FormOwnerXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form owner | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form owner record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form owner | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form owner record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form owner record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Owner Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'CONSTRAINT', N'uk_FormOwner_FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Owner SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'CONSTRAINT', N'uk_FormOwner_FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormOwner', 'CONSTRAINT', N'uk_FormOwner_RowGUID'
GO
ALTER TABLE [sf].[FormOwner] SET (LOCK_ESCALATION = TABLE)
GO
