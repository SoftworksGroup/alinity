SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonGroupDoc] (
		[PersonGroupDocSID]        [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonGroupFolderSID]     [int] NOT NULL,
		[DocumentTitle]            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileTypeSID]              [int] NOT NULL,
		[FileTypeSCD]              [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TagList]                  [xml] NOT NULL,
		[DocumentContent]          [varbinary](max) FILESTREAM NOT NULL,
		[DocumentNotes]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]       [xml] NULL,
		[PersonGroupDocXID]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonGroupDoc_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonGroupDoc]
		PRIMARY KEY
		CLUSTERED
		([PersonGroupDocSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Group Doc table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'CONSTRAINT', N'pk_PersonGroupDoc'
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonGroupDoc]
	CHECK
	([dbo].[fPersonGroupDoc#Check]([PersonGroupDocSID],[PersonGroupFolderSID],[DocumentTitle],[FileTypeSID],[FileTypeSCD],[PersonGroupDocXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonGroupDoc]
CHECK CONSTRAINT [ck_PersonGroupDoc]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>')) FOR [TagList]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	ADD
	CONSTRAINT [df_PersonGroupDoc_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroupDoc_PersonGroupFolder_PersonGroupFolderSID]
	FOREIGN KEY ([PersonGroupFolderSID]) REFERENCES [dbo].[PersonGroupFolder] ([PersonGroupFolderSID])
ALTER TABLE [dbo].[PersonGroupDoc]
	CHECK CONSTRAINT [fk_PersonGroupDoc_PersonGroupFolder_PersonGroupFolderSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person group folder system ID column in the Person Group Doc table match a person group folder system ID in the Person Group Folder table. It also ensures that records in the Person Group Folder table cannot be deleted if matching child records exist in Person Group Doc. Finally, the constraint blocks changes to the value of the person group folder system ID column in the Person Group Folder if matching child records exist in Person Group Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'CONSTRAINT', N'fk_PersonGroupDoc_PersonGroupFolder_PersonGroupFolderSID'
GO
ALTER TABLE [dbo].[PersonGroupDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroupDoc_SF_FileType_FileTypeSID]
	FOREIGN KEY ([FileTypeSID]) REFERENCES [sf].[FileType] ([FileTypeSID])
ALTER TABLE [dbo].[PersonGroupDoc]
	CHECK CONSTRAINT [fk_PersonGroupDoc_SF_FileType_FileTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file type system ID column in the Person Group Doc table match a file type system ID in the File Type table. It also ensures that records in the File Type table cannot be deleted if matching child records exist in Person Group Doc. Finally, the constraint blocks changes to the value of the file type system ID column in the File Type if matching child records exist in Person Group Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'CONSTRAINT', N'fk_PersonGroupDoc_SF_FileType_FileTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroupDoc_FileTypeSID_PersonGroupDocSID]
	ON [dbo].[PersonGroupDoc] ([FileTypeSID], [PersonGroupDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Type SID foreign key column and avoids row contention on (parent) File Type updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'INDEX', N'ix_PersonGroupDoc_FileTypeSID_PersonGroupDocSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroupDoc_PersonGroupFolderSID_PersonGroupDocSID]
	ON [dbo].[PersonGroupDoc] ([PersonGroupFolderSID], [PersonGroupDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Group Folder SID foreign key column and avoids row contention on (parent) Person Group Folder updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'INDEX', N'ix_PersonGroupDoc_PersonGroupFolderSID_PersonGroupDocSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonGroupDoc_LegacyKey]
	ON [dbo].[PersonGroupDoc] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'INDEX', N'ux_PersonGroupDoc_LegacyKey'
GO
CREATE FULLTEXT INDEX ON [dbo].[PersonGroupDoc]
	([DocumentTitle] LANGUAGE 0, [DocumentContent] TYPE COLUMN [FileTypeSCD] LANGUAGE 0)
	KEY INDEX [pk_PersonGroupDoc]
	ON (FILEGROUP [FullTextIndexData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST OFF
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person group doc assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'PersonGroupDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person group folder assigned to this person group doc', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'PersonGroupFolderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person group doc', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person group doc | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'PersonGroupDocXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person group doc | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person group doc record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person group doc | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person group doc record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person group doc record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'CONSTRAINT', N'uk_PersonGroupDoc_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_PersonGroupDoc_TagList]
	ON [dbo].[PersonGroupDoc] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'PersonGroupDoc', 'INDEX', N'xp_PersonGroupDoc_TagList'
GO
ALTER TABLE [dbo].[PersonGroupDoc] SET (LOCK_ESCALATION = TABLE)
GO
