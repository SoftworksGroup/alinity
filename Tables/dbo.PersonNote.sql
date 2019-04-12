SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonNote] (
		[PersonNoteSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]               [int] NOT NULL,
		[PersonNoteTypeSID]       [int] NOT NULL,
		[NoteTitle]               [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoteContent]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ShowToRegistrant]        [bit] NOT NULL,
		[ApplicationGrantSID]     [int] NULL,
		[TagList]                 [xml] NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[PersonNoteXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonNote_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonNote]
		PRIMARY KEY
		CLUSTERED
		([PersonNoteSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Note table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'CONSTRAINT', N'pk_PersonNote'
GO
ALTER TABLE [dbo].[PersonNote]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonNote]
	CHECK
	([dbo].[fPersonNote#Check]([PersonNoteSID],[PersonSID],[PersonNoteTypeSID],[NoteTitle],[ShowToRegistrant],[ApplicationGrantSID],[PersonNoteXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonNote]
CHECK CONSTRAINT [ck_PersonNote]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_ShowToRegistrant]
	DEFAULT ((0)) FOR [ShowToRegistrant]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>')) FOR [TagList]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonNote]
	ADD
	CONSTRAINT [df_PersonNote_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonNote]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonNote_PersonNoteType_PersonNoteTypeSID]
	FOREIGN KEY ([PersonNoteTypeSID]) REFERENCES [dbo].[PersonNoteType] ([PersonNoteTypeSID])
ALTER TABLE [dbo].[PersonNote]
	CHECK CONSTRAINT [fk_PersonNote_PersonNoteType_PersonNoteTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person note type system ID column in the Person Note table match a person note type system ID in the Person Note Type table. It also ensures that records in the Person Note Type table cannot be deleted if matching child records exist in Person Note. Finally, the constraint blocks changes to the value of the person note type system ID column in the Person Note Type if matching child records exist in Person Note.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'CONSTRAINT', N'fk_PersonNote_PersonNoteType_PersonNoteTypeSID'
GO
ALTER TABLE [dbo].[PersonNote]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonNote_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[PersonNote]
	CHECK CONSTRAINT [fk_PersonNote_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Note table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Note. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Note.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'CONSTRAINT', N'fk_PersonNote_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[PersonNote]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonNote_SF_ApplicationGrant_ApplicationGrantSID]
	FOREIGN KEY ([ApplicationGrantSID]) REFERENCES [sf].[ApplicationGrant] ([ApplicationGrantSID])
ALTER TABLE [dbo].[PersonNote]
	CHECK CONSTRAINT [fk_PersonNote_SF_ApplicationGrant_ApplicationGrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application grant system ID column in the Person Note table match a application grant system ID in the Application Grant table. It also ensures that records in the Application Grant table cannot be deleted if matching child records exist in Person Note. Finally, the constraint blocks changes to the value of the application grant system ID column in the Application Grant if matching child records exist in Person Note.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'CONSTRAINT', N'fk_PersonNote_SF_ApplicationGrant_ApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonNote_ApplicationGrantSID_PersonNoteSID]
	ON [dbo].[PersonNote] ([ApplicationGrantSID], [PersonNoteSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Grant SID foreign key column and avoids row contention on (parent) Application Grant updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'INDEX', N'ix_PersonNote_ApplicationGrantSID_PersonNoteSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonNote_PersonNoteTypeSID_PersonNoteSID]
	ON [dbo].[PersonNote] ([PersonNoteTypeSID], [PersonNoteSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Note Type SID foreign key column and avoids row contention on (parent) Person Note Type updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'INDEX', N'ix_PersonNote_PersonNoteTypeSID_PersonNoteSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonNote_PersonSID_PersonNoteSID]
	ON [dbo].[PersonNote] ([PersonSID], [PersonNoteSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'INDEX', N'ix_PersonNote_PersonSID_PersonNoteSID'
GO
CREATE FULLTEXT INDEX ON [dbo].[PersonNote]
	([NoteContent] LANGUAGE 0)
	KEY INDEX [pk_PersonNote]
	ON (FILEGROUP [ApplicationRowData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST SYSTEM
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores notes entered by administrators and stored in a persons profile.  Notes in this table are always associated with an individual but may be associated more specifically by capturing a context record (PersonNoteContext) - for example if a note is in reference to a renewal, or an address change, or exam the Context record ensures that the application will display the note when the other record is accessed. The same note may have multiple contexts (very similar to the design for Person Documents).', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person note assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'PersonNoteSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this note is based on', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person note', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'PersonNoteTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Optional - may be used to specify a title for the note', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'NoteTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this note should be shown to the registrant it is related to on the client portal.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'ShowToRegistrant'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of tags used to classify the note and to support filtering and searching', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'TagList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person note | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'PersonNoteXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person note | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person note record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person note | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person note record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person note record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'CONSTRAINT', N'uk_PersonNote_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_PersonNote_TagList]
	ON [dbo].[PersonNote] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'PersonNote', 'INDEX', N'xp_PersonNote_TagList'
GO
ALTER TABLE [dbo].[PersonNote] SET (LOCK_ESCALATION = TABLE)
GO
