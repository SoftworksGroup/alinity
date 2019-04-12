SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationUserSession] (
		[ApplicationUserSessionSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationUserSID]            [int] NOT NULL,
		[IsActive]                      [bit] NOT NULL,
		[IPAddress]                     [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[ApplicationUserSessionXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationUserSession_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationUserSession]
		PRIMARY KEY
		CLUSTERED
		([ApplicationUserSessionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application User Session table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'CONSTRAINT', N'pk_ApplicationUserSession'
GO
ALTER TABLE [sf].[ApplicationUserSession]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationUserSession]
	CHECK
	([sf].[fApplicationUserSession#Check]([ApplicationUserSessionSID],[ApplicationUserSID],[IsActive],[IPAddress],[ApplicationUserSessionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationUserSession]
CHECK CONSTRAINT [ck_ApplicationUserSession]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_IPAddress]
	DEFAULT ((0)) FOR [IPAddress]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	ADD
	CONSTRAINT [df_ApplicationUserSession_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationUserSession]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUserSession_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[ApplicationUserSession]
	CHECK CONSTRAINT [fk_ApplicationUserSession_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Application User Session table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Application User Session. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Application User Session.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'CONSTRAINT', N'fk_ApplicationUserSession_ApplicationUser_ApplicationUserSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationUserSession_ApplicationUserSID_IsActive]
	ON [sf].[ApplicationUserSession] ([ApplicationUserSID], [IsActive])
	INCLUDE ([ApplicationUserSessionSID], [RowGUID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'INDEX', N'ix_ApplicationUserSession_ApplicationUserSID_IsActive'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationUserSession_LegacyKey]
	ON [sf].[ApplicationUserSession] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'INDEX', N'ux_ApplicationUserSession_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user session assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'ApplicationUserSessionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this session', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user session record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application user session | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'ApplicationUserSessionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application user session | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application user session record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application user session | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application user session record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user session record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSession', 'CONSTRAINT', N'uk_ApplicationUserSession_RowGUID'
GO
ALTER TABLE [sf].[ApplicationUserSession] SET (LOCK_ESCALATION = TABLE)
GO
