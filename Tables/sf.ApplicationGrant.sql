SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationGrant] (
		[ApplicationGrantSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationGrantSCD]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ApplicationGrantName]     [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[ApplicationGrantXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationGrant_ApplicationGrantName]
		UNIQUE
		NONCLUSTERED
		([ApplicationGrantName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationGrant_ApplicationGrantSCD]
		UNIQUE
		NONCLUSTERED
		([ApplicationGrantSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationGrant_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationGrant]
		PRIMARY KEY
		CLUSTERED
		([ApplicationGrantSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application Grant table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'CONSTRAINT', N'pk_ApplicationGrant'
GO
ALTER TABLE [sf].[ApplicationGrant]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationGrant]
	CHECK
	([sf].[fApplicationGrant#Check]([ApplicationGrantSID],[ApplicationGrantSCD],[ApplicationGrantName],[IsDefault],[ApplicationGrantXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationGrant]
CHECK CONSTRAINT [ck_ApplicationGrant]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationGrant]
	ADD
	CONSTRAINT [df_ApplicationGrant_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationGrant_IsDefault]
	ON [sf].[ApplicationGrant] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Application Grant', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'INDEX', N'ux_ApplicationGrant_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationGrant_LegacyKey]
	ON [sf].[ApplicationGrant] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'INDEX', N'ux_ApplicationGrant_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of security grants used in the application. The list of grants cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  The list of grants is maintained by product installation and upgrade scripts.  It is possible to mark a single grant as a default. This causes the application to automatically assign that grant to users added to the system.  Use this option cautiously and never use it to assign a highly privileged grant. One grant record may be defined for enabling access to content (emails, document etc.) that are marked as having “restricted access”. The Restricted Access designation is an extra level of access control provided on a document by document basis.  Security grants already control access to email and document screens but this grant can be used to prevent particularly sensitive documents from users who otherwise have access (e.g. “case conduct” administrators, or “clinicians”).   ', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application grant | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application grant to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'description of functions this grant enables and other guidance and best-practices on applying it', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default application grant to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application grant | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'ApplicationGrantXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application grant record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application grant record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Grant Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'CONSTRAINT', N'uk_ApplicationGrant_ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Grant SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'CONSTRAINT', N'uk_ApplicationGrant_ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationGrant', 'CONSTRAINT', N'uk_ApplicationGrant_RowGUID'
GO
ALTER TABLE [sf].[ApplicationGrant] SET (LOCK_ESCALATION = TABLE)
GO
