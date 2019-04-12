SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonGroupFolder] (
		[PersonGroupFolderSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[ParentPersonGroupFolderSID]     [int] NULL,
		[PersonGroupSID]                 [int] NOT NULL,
		[FolderName]                     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsRoot]                         [bit] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[PersonGroupFolderXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonGroupFolder_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonGroupFolder]
		PRIMARY KEY
		CLUSTERED
		([PersonGroupFolderSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Group Folder table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'CONSTRAINT', N'pk_PersonGroupFolder'
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonGroupFolder]
	CHECK
	([dbo].[fPersonGroupFolder#Check]([PersonGroupFolderSID],[ParentPersonGroupFolderSID],[PersonGroupSID],[FolderName],[IsRoot],[PersonGroupFolderXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonGroupFolder]
CHECK CONSTRAINT [ck_PersonGroupFolder]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_IsRoot]
	DEFAULT ((0)) FOR [IsRoot]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	ADD
	CONSTRAINT [df_PersonGroupFolder_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonGroupFolder]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroupFolder_SF_PersonGroup_PersonGroupSID]
	FOREIGN KEY ([PersonGroupSID]) REFERENCES [sf].[PersonGroup] ([PersonGroupSID])
ALTER TABLE [dbo].[PersonGroupFolder]
	CHECK CONSTRAINT [fk_PersonGroupFolder_SF_PersonGroup_PersonGroupSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person group system ID column in the Person Group Folder table match a person group system ID in the Person Group table. It also ensures that records in the Person Group table cannot be deleted if matching child records exist in Person Group Folder. Finally, the constraint blocks changes to the value of the person group system ID column in the Person Group if matching child records exist in Person Group Folder.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'CONSTRAINT', N'fk_PersonGroupFolder_SF_PersonGroup_PersonGroupSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonGroupFolder_LegacyKey]
	ON [dbo].[PersonGroupFolder] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'INDEX', N'ux_PersonGroupFolder_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroupFolder_PersonGroupSID_PersonGroupFolderSID]
	ON [dbo].[PersonGroupFolder] ([PersonGroupSID], [PersonGroupFolderSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Group SID foreign key column and avoids row contention on (parent) Person Group updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'INDEX', N'ix_PersonGroupFolder_PersonGroupSID_PersonGroupFolderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person group folder assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'PersonGroupFolderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person group this folder is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'PersonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person group folder | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'PersonGroupFolderXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person group folder | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person group folder record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person group folder | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person group folder record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person group folder record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupFolder', 'CONSTRAINT', N'uk_PersonGroupFolder_RowGUID'
GO
ALTER TABLE [dbo].[PersonGroupFolder] SET (LOCK_ESCALATION = TABLE)
GO
