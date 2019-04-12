SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonNoteContext] (
		[PersonNoteContextSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonNoteSID]            [int] NOT NULL,
		[ApplicationEntitySID]     [int] NOT NULL,
		[EntitySID]                [int] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[PersonNoteContextXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonNoteContext_PersonNoteSID_ApplicationEntitySID_EntitySID]
		UNIQUE
		NONCLUSTERED
		([PersonNoteSID], [ApplicationEntitySID], [EntitySID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonNoteContext_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonNoteContext]
		PRIMARY KEY
		CLUSTERED
		([PersonNoteContextSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Note Context table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'CONSTRAINT', N'pk_PersonNoteContext'
GO
ALTER TABLE [dbo].[PersonNoteContext]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonNoteContext]
	CHECK
	([dbo].[fPersonNoteContext#Check]([PersonNoteContextSID],[PersonNoteSID],[ApplicationEntitySID],[EntitySID],[PersonNoteContextXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonNoteContext]
CHECK CONSTRAINT [ck_PersonNoteContext]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	ADD
	CONSTRAINT [df_PersonNoteContext_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	ADD
	CONSTRAINT [df_PersonNoteContext_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	ADD
	CONSTRAINT [df_PersonNoteContext_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	ADD
	CONSTRAINT [df_PersonNoteContext_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	ADD
	CONSTRAINT [df_PersonNoteContext_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	ADD
	CONSTRAINT [df_PersonNoteContext_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonNoteContext]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonNoteContext_SF_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [dbo].[PersonNoteContext]
	CHECK CONSTRAINT [fk_PersonNoteContext_SF_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Person Note Context table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Person Note Context. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Person Note Context.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'CONSTRAINT', N'fk_PersonNoteContext_SF_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [dbo].[PersonNoteContext]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonNoteContext_PersonNote_PersonNoteSID]
	FOREIGN KEY ([PersonNoteSID]) REFERENCES [dbo].[PersonNote] ([PersonNoteSID])
ALTER TABLE [dbo].[PersonNoteContext]
	CHECK CONSTRAINT [fk_PersonNoteContext_PersonNote_PersonNoteSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person note system ID column in the Person Note Context table match a person note system ID in the Person Note table. It also ensures that records in the Person Note table cannot be deleted if matching child records exist in Person Note Context. Finally, the constraint blocks changes to the value of the person note system ID column in the Person Note if matching child records exist in Person Note Context.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'CONSTRAINT', N'fk_PersonNoteContext_PersonNote_PersonNoteSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonNoteContext_ApplicationEntitySID_PersonNoteContextSID]
	ON [dbo].[PersonNoteContext] ([ApplicationEntitySID], [PersonNoteContextSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'INDEX', N'ix_PersonNoteContext_ApplicationEntitySID_PersonNoteContextSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to relate a PersonNote entity to one or more other entities via the entity type (ApplicationEntitySID) and the entity''s SID. When used on the UI this will create an item/folder structure to nest the items under their related entities; support for specific entities must be added to the views that support the front-end.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person note context assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'PersonNoteContextSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person note this context is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'PersonNoteSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this person note context', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SID of the related entity. The query to get the entity row can be determined by the entity type (ApplicationEntitySID).', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person note context | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'PersonNoteContextXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person note context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person note context record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person note context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person note context record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person note context record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Person Note SID + Application Entity SID + Entity SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'CONSTRAINT', N'uk_PersonNoteContext_PersonNoteSID_ApplicationEntitySID_EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonNoteContext', 'CONSTRAINT', N'uk_PersonNoteContext_RowGUID'
GO
ALTER TABLE [dbo].[PersonNoteContext] SET (LOCK_ESCALATION = TABLE)
GO
