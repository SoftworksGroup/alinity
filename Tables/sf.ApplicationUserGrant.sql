SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationUserGrant] (
		[ApplicationUserGrantSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationUserSID]          [int] NOT NULL,
		[ApplicationGrantSID]         [int] NOT NULL,
		[EffectiveTime]               [datetime] NOT NULL,
		[ExpiryTime]                  [datetime] NULL,
		[ChangeAudit]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[ApplicationUserGrantXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationUserGrant_ApplicationUserSID_ApplicationGrantSID]
		UNIQUE
		NONCLUSTERED
		([ApplicationUserSID], [ApplicationGrantSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationUserGrant_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationUserGrant]
		PRIMARY KEY
		CLUSTERED
		([ApplicationUserGrantSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application User Grant table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'CONSTRAINT', N'pk_ApplicationUserGrant'
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationUserGrant]
	CHECK
	([sf].[fApplicationUserGrant#Check]([ApplicationUserGrantSID],[ApplicationUserSID],[ApplicationGrantSID],[EffectiveTime],[ExpiryTime],[ApplicationUserGrantXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationUserGrant]
CHECK CONSTRAINT [ck_ApplicationUserGrant]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	ADD
	CONSTRAINT [df_ApplicationUserGrant_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUserGrant_ApplicationGrant_ApplicationGrantSID]
	FOREIGN KEY ([ApplicationGrantSID]) REFERENCES [sf].[ApplicationGrant] ([ApplicationGrantSID])
ALTER TABLE [sf].[ApplicationUserGrant]
	CHECK CONSTRAINT [fk_ApplicationUserGrant_ApplicationGrant_ApplicationGrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application grant system ID column in the Application User Grant table match a application grant system ID in the Application Grant table. It also ensures that records in the Application Grant table cannot be deleted if matching child records exist in Application User Grant. Finally, the constraint blocks changes to the value of the application grant system ID column in the Application Grant if matching child records exist in Application User Grant.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'CONSTRAINT', N'fk_ApplicationUserGrant_ApplicationGrant_ApplicationGrantSID'
GO
ALTER TABLE [sf].[ApplicationUserGrant]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUserGrant_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[ApplicationUserGrant]
	CHECK CONSTRAINT [fk_ApplicationUserGrant_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Application User Grant table match a application user system ID in the Application User table. It also ensures that when a record in the Application User table is deleted, matching child records in the Application User Grant table are deleted as well. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Application User Grant.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'CONSTRAINT', N'fk_ApplicationUserGrant_ApplicationUser_ApplicationUserSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationUserGrant_ApplicationGrantSID]
	ON [sf].[ApplicationUserGrant] ([ApplicationGrantSID])
	INCLUDE ([ApplicationUserGrantSID], [ApplicationUserSID], [EffectiveTime], [ExpiryTime])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Grant SID foreign key column and avoids row contention on (parent) Application Grant updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'INDEX', N'ix_ApplicationUserGrant_ApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationUserGrant_ApplicationUserSID_ApplicationUserGrantSID]
	ON [sf].[ApplicationUserGrant] ([ApplicationUserSID], [ApplicationUserGrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'INDEX', N'ix_ApplicationUserGrant_ApplicationUserSID_ApplicationUserGrantSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationUserGrant_LegacyKey]
	ON [sf].[ApplicationUserGrant] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'INDEX', N'ux_ApplicationUserGrant_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'ApplicationUserGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this grant', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The grant this user is assigned to', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this grant was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending time this grant was effective.  When blank indicates grant remains in effect. | See Change Audit for history of grant being turned on/off', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes to this grant assignment | The UI prompts for a reason for disabling or re-enabling the grant record and this reason, along with other audit information, are stored into this audit column.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application user grant | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'ApplicationUserGrantXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application user grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application user grant record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application user grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application user grant record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application User SID + Application Grant SID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'CONSTRAINT', N'uk_ApplicationUserGrant_ApplicationUserSID_ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserGrant', 'CONSTRAINT', N'uk_ApplicationUserGrant_RowGUID'
GO
ALTER TABLE [sf].[ApplicationUserGrant] SET (LOCK_ESCALATION = TABLE)
GO
