SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationPageHelp] (
		[ApplicationPageHelpSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationPageSID]         [int] NOT NULL,
		[ApplicationPageHelpID]      [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[HelpContent]                [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StepSequence]               [int] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[ApplicationPageHelpXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationPageHelp_ApplicationPageHelpID_ApplicationPageSID]
		UNIQUE
		NONCLUSTERED
		([ApplicationPageHelpID], [ApplicationPageSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationPageHelp_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationPageHelp]
		PRIMARY KEY
		CLUSTERED
		([ApplicationPageHelpSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application Page Help table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'CONSTRAINT', N'pk_ApplicationPageHelp'
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationPageHelp]
	CHECK
	([sf].[fApplicationPageHelp#Check]([ApplicationPageHelpSID],[ApplicationPageSID],[ApplicationPageHelpID],[StepSequence],[ApplicationPageHelpXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationPageHelp]
CHECK CONSTRAINT [ck_ApplicationPageHelp]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_StepSequence]
	DEFAULT ((0)) FOR [StepSequence]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	ADD
	CONSTRAINT [df_ApplicationPageHelp_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationPageHelp]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationPageHelp_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
ALTER TABLE [sf].[ApplicationPageHelp]
	CHECK CONSTRAINT [fk_ApplicationPageHelp_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Application Page Help table match a application page system ID in the Application Page table. It also ensures that records in the Application Page table cannot be deleted if matching child records exist in Application Page Help. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Application Page Help.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'CONSTRAINT', N'fk_ApplicationPageHelp_ApplicationPage_ApplicationPageSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationPageHelp_ApplicationPageSID_ApplicationPageHelpSID]
	ON [sf].[ApplicationPageHelp] ([ApplicationPageSID], [ApplicationPageHelpSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'INDEX', N'ix_ApplicationPageHelp_ApplicationPageSID_ApplicationPageHelpSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationPageHelp_LegacyKey]
	ON [sf].[ApplicationPageHelp] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'INDEX', N'ux_ApplicationPageHelp_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used by the application to store progressive help text.  The table is updateable by the development team and the help desk only.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page help assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'ApplicationPageHelpSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application page help | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'ApplicationPageHelpID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application page help | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'ApplicationPageHelpXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application page help | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application page help record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application page help | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application page help record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page help record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application Page Help ID + Application Page SID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'CONSTRAINT', N'uk_ApplicationPageHelp_ApplicationPageHelpID_ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageHelp', 'CONSTRAINT', N'uk_ApplicationPageHelp_RowGUID'
GO
ALTER TABLE [sf].[ApplicationPageHelp] SET (LOCK_ESCALATION = TABLE)
GO
