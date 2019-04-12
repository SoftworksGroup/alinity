SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ControlType] (
		[ControlTypeSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[ControlTypeSCD]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ControlTypeLabel]       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ControlTypeXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_ControlType_ControlTypeLabel]
		UNIQUE
		NONCLUSTERED
		([ControlTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ControlType_ControlTypeSCD]
		UNIQUE
		NONCLUSTERED
		([ControlTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ControlType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ControlType]
		PRIMARY KEY
		CLUSTERED
		([ControlTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Control Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'CONSTRAINT', N'pk_ControlType'
GO
ALTER TABLE [sf].[ControlType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ControlType]
	CHECK
	([sf].[fControlType#Check]([ControlTypeSID],[ControlTypeSCD],[ControlTypeLabel],[IsDefault],[ControlTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ControlType]
CHECK CONSTRAINT [ck_ControlType]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ControlType]
	ADD
	CONSTRAINT [df_ControlType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ControlType_IsDefault]
	ON [sf].[ControlType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Control Type', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'INDEX', N'ux_ControlType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table contains the types of UI controls that can be specified on configurable forms in the system.  The contents of this table cannot be modified with the application but is included for reference.', 'SCHEMA', N'sf', 'TABLE', N'ControlType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the control type assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'ControlTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the control type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'ControlTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the control type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'ControlTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default control type to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the control type | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'ControlTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the control type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this control type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the control type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the control type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the control type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Control Type Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'CONSTRAINT', N'uk_ControlType_ControlTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Control Type SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'CONSTRAINT', N'uk_ControlType_ControlTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ControlType', 'CONSTRAINT', N'uk_ControlType_RowGUID'
GO
ALTER TABLE [sf].[ControlType] SET (LOCK_ESCALATION = TABLE)
GO
