SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SyncDataMap] (
		[SyncDataMapSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationEntitySID]     [int] NOT NULL,
		[SyncMode]                 [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDeleteProcessed]        [bit] NOT NULL,
		[IsEnabled]                [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[SyncDataMapXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_SyncDataMap_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_SyncDataMap_ApplicationEntitySID]
		UNIQUE
		NONCLUSTERED
		([ApplicationEntitySID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_SyncDataMap]
		PRIMARY KEY
		CLUSTERED
		([SyncDataMapSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Sync Data Map table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'CONSTRAINT', N'pk_SyncDataMap'
GO
ALTER TABLE [dbo].[SyncDataMap]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_SyncDataMap]
	CHECK
	([dbo].[fSyncDataMap#Check]([SyncDataMapSID],[ApplicationEntitySID],[SyncMode],[IsDeleteProcessed],[IsEnabled],[SyncDataMapXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[SyncDataMap]
CHECK CONSTRAINT [ck_SyncDataMap]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_IsDeleteProcessed]
	DEFAULT (CONVERT([bit],(0))) FOR [IsDeleteProcessed]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_IsEnabled]
	DEFAULT (CONVERT([bit],(1))) FOR [IsEnabled]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_SyncMode]
	DEFAULT ('PUSH') FOR [SyncMode]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[SyncDataMap]
	ADD
	CONSTRAINT [df_SyncDataMap_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[SyncDataMap]
	WITH CHECK
	ADD CONSTRAINT [fk_SyncDataMap_SF_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [dbo].[SyncDataMap]
	CHECK CONSTRAINT [fk_SyncDataMap_SF_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Sync Data Map table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Sync Data Map. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Sync Data Map.', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'CONSTRAINT', N'fk_SyncDataMap_SF_ApplicationEntity_ApplicationEntitySID'
GO
CREATE NONCLUSTERED INDEX [ix_SyncDataMap_ApplicationEntitySID_SyncDataMapSID]
	ON [dbo].[SyncDataMap] ([ApplicationEntitySID], [SyncDataMapSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'INDEX', N'ix_SyncDataMap_ApplicationEntitySID_SyncDataMapSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to specify synchronizations which are in effect between the Alinity database and a another database – typically a legacy system.  A record exists in the table for each Alinity entity which should be synchronized.  The synchronization process runs in background – typically every 15 minutes – to update the other database.  The synchronization direction is set in this record as either: PUSH (out from Alinity to the legacy database), or PULL (updates the Alinity database from changes in the legacy database).   The table controls which synchronizations the system will process but customizations are always required to implement the feature since a view on the legacy database is required that represent the columns that are to be synchronized.  If the sync mode is PUSH, then additional custom processing logic must be implemented to update the legacy records.  These customizations must be carried out by an Alinity configurator (Softworks staff member).', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the sync data map assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'SyncDataMapSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this sync data map', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The direction of the sync:  PUSH to push Alinity changes to the legacy database or PULL to update Alinity with external changes.', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'SyncMode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion actions (which may only inactivate records) is to be processed on the target database', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'IsDeleteProcessed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Turn off this setting to disable the synchronization in order to correct errors, while allowing other synchronizations to proceed.', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the sync data map | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'SyncDataMapXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the sync data map | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this sync data map record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the sync data map | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the sync data map record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the sync data map record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'CONSTRAINT', N'uk_SyncDataMap_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Entity SID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'SyncDataMap', 'CONSTRAINT', N'uk_SyncDataMap_ApplicationEntitySID'
GO
ALTER TABLE [dbo].[SyncDataMap] SET (LOCK_ESCALATION = TABLE)
GO
