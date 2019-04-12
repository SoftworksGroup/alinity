SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonDocContext] (
		[PersonDocContextSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonDocSID]             [int] NOT NULL,
		[ApplicationEntitySID]     [int] NOT NULL,
		[EntitySID]                [int] NOT NULL,
		[IsPrimary]                [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[PersonDocContextXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonDocContext_PersonDocSID_ApplicationEntitySID_EntitySID]
		UNIQUE
		NONCLUSTERED
		([PersonDocSID], [ApplicationEntitySID], [EntitySID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonDocContext_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonDocContext]
		PRIMARY KEY
		CLUSTERED
		([PersonDocContextSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Doc Context table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'CONSTRAINT', N'pk_PersonDocContext'
GO
ALTER TABLE [dbo].[PersonDocContext]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonDocContext]
	CHECK
	([dbo].[fPersonDocContext#Check]([PersonDocContextSID],[PersonDocSID],[ApplicationEntitySID],[EntitySID],[IsPrimary],[PersonDocContextXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonDocContext]
CHECK CONSTRAINT [ck_PersonDocContext]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonDocContext]
	ADD
	CONSTRAINT [df_PersonDocContext_IsPrimary]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPrimary]
GO
ALTER TABLE [dbo].[PersonDocContext]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDocContext_SF_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [dbo].[PersonDocContext]
	CHECK CONSTRAINT [fk_PersonDocContext_SF_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Person Doc Context table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Person Doc Context. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Person Doc Context.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'CONSTRAINT', N'fk_PersonDocContext_SF_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [dbo].[PersonDocContext]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDocContext_PersonDoc_PersonDocSID]
	FOREIGN KEY ([PersonDocSID]) REFERENCES [dbo].[PersonDoc] ([PersonDocSID])
ALTER TABLE [dbo].[PersonDocContext]
	CHECK CONSTRAINT [fk_PersonDocContext_PersonDoc_PersonDocSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person doc system ID column in the Person Doc Context table match a person doc system ID in the Person Doc table. It also ensures that records in the Person Doc table cannot be deleted if matching child records exist in Person Doc Context. Finally, the constraint blocks changes to the value of the person doc system ID column in the Person Doc if matching child records exist in Person Doc Context.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'CONSTRAINT', N'fk_PersonDocContext_PersonDoc_PersonDocSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonDocContext_ApplicationEntitySID_EntitySID_IsPrimary]
	ON [dbo].[PersonDocContext] ([ApplicationEntitySID], [EntitySID], [IsPrimary])
	WHERE (([IsPrimary]=CONVERT([bit],(1))))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application Entity SID + Entity SID + Is Primary" columns is not duplicated where the condition: "([IsPrimary]=CONVERT([bit],(1)))" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'INDEX', N'ux_PersonDocContext_ApplicationEntitySID_EntitySID_IsPrimary'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDocContext_ApplicationEntitySID_PersonDocContextSID]
	ON [dbo].[PersonDocContext] ([ApplicationEntitySID], [PersonDocContextSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'INDEX', N'ix_PersonDocContext_ApplicationEntitySID_PersonDocContextSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDocContext_EntitySID_IsPrimary_ApplicationEntitySID]
	ON [dbo].[PersonDocContext] ([EntitySID], [IsPrimary], [ApplicationEntitySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Doc Context searches based on the Entity SID + Is Primary + Application Entity SID columns', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'INDEX', N'ix_PersonDocContext_EntitySID_IsPrimary_ApplicationEntitySID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonDocContext_LegacyKey]
	ON [dbo].[PersonDocContext] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'INDEX', N'ux_PersonDocContext_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to relate a PersonDoc entity to one or more other entities via the entity type (ApplicationEntitySID) and the entity''s SID. When used on the UI this will create an item/folder structure to nest the items under their related entities; support for specific entities must be added to the views that support the front-end.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person doc context assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'PersonDocContextSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person doc this context is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this person doc context', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SID of the related entity. The query to get the entity row can be determined by the entity type (ApplicationEntitySID).', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is the primary, or most important, document for this context.  This is normally sent to a PDF version of the system form for registration events: application form, renewal form, reinstatement form, etc.  The value is set by the system automatically. There can only be one primary document for each context (a context is a combination of entity and record number - e.g. a specific year''s renewal form).', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'IsPrimary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person doc context | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'PersonDocContextXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person doc context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person doc context record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person doc context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person doc context record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc context record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Person Doc SID + Application Entity SID + Entity SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'CONSTRAINT', N'uk_PersonDocContext_PersonDocSID_ApplicationEntitySID_EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocContext', 'CONSTRAINT', N'uk_PersonDocContext_RowGUID'
GO
ALTER TABLE [dbo].[PersonDocContext] SET (LOCK_ESCALATION = TABLE)
GO
