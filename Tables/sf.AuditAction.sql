SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[AuditAction] (
		[AuditActionSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[AuditActionSCD]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AuditActionName]        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[AuditActionXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_AuditAction_AuditActionName]
		UNIQUE
		NONCLUSTERED
		([AuditActionName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AuditAction_AuditActionSCD]
		UNIQUE
		NONCLUSTERED
		([AuditActionSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AuditAction_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AuditAction]
		PRIMARY KEY
		CLUSTERED
		([AuditActionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Audit Action table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'CONSTRAINT', N'pk_AuditAction'
GO
ALTER TABLE [sf].[AuditAction]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AuditAction]
	CHECK
	([sf].[fAuditAction#Check]([AuditActionSID],[AuditActionSCD],[AuditActionName],[IsDefault],[AuditActionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[AuditAction]
CHECK CONSTRAINT [ck_AuditAction]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[AuditAction]
	ADD
	CONSTRAINT [df_AuditAction_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AuditAction_IsDefault]
	ON [sf].[AuditAction] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Audit Action', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'INDEX', N'ux_AuditAction_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AuditAction_LegacyKey]
	ON [sf].[AuditAction] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'INDEX', N'ux_AuditAction_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of events that are audited by the application. The list of events cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Specific application code detects each event type and codes it using the AuditActionSCD value from this table.', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the audit action assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'AuditActionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the audit action | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'AuditActionSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the audit action to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'AuditActionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the audit action - e.g. "Patient record access"', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default audit action to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the audit action | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'AuditActionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the audit action | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this audit action record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the audit action | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the audit action record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the audit action record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Audit Action Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'CONSTRAINT', N'uk_AuditAction_AuditActionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Audit Action SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'CONSTRAINT', N'uk_AuditAction_AuditActionSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AuditAction', 'CONSTRAINT', N'uk_AuditAction_RowGUID'
GO
ALTER TABLE [sf].[AuditAction] SET (LOCK_ESCALATION = TABLE)
GO
