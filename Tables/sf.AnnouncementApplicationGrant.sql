SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[AnnouncementApplicationGrant] (
		[AnnouncementApplicationGrantSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[AnnouncementSID]                     [int] NOT NULL,
		[ApplicationGrantSID]                 [int] NOT NULL,
		[UserDefinedColumns]                  [xml] NULL,
		[AnnouncementApplicationGrantXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                           [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                           [bit] NOT NULL,
		[CreateUser]                          [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                          [datetimeoffset](7) NOT NULL,
		[UpdateUser]                          [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                          [datetimeoffset](7) NOT NULL,
		[RowGUID]                             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                            [timestamp] NOT NULL,
		CONSTRAINT [uk_AnnouncementApplicationGrant_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AnnouncementApplicationGrant]
		PRIMARY KEY
		CLUSTERED
		([AnnouncementApplicationGrantSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Announcement Application Grant table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'CONSTRAINT', N'pk_AnnouncementApplicationGrant'
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AnnouncementApplicationGrant]
	CHECK
	([sf].[fAnnouncementApplicationGrant#Check]([AnnouncementApplicationGrantSID],[AnnouncementSID],[ApplicationGrantSID],[AnnouncementApplicationGrantXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
CHECK CONSTRAINT [ck_AnnouncementApplicationGrant]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	ADD
	CONSTRAINT [df_AnnouncementApplicationGrant_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	ADD
	CONSTRAINT [df_AnnouncementApplicationGrant_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	ADD
	CONSTRAINT [df_AnnouncementApplicationGrant_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	ADD
	CONSTRAINT [df_AnnouncementApplicationGrant_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	ADD
	CONSTRAINT [df_AnnouncementApplicationGrant_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	ADD
	CONSTRAINT [df_AnnouncementApplicationGrant_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	WITH CHECK
	ADD CONSTRAINT [fk_AnnouncementApplicationGrant_Announcement_AnnouncementSID]
	FOREIGN KEY ([AnnouncementSID]) REFERENCES [sf].[Announcement] ([AnnouncementSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	CHECK CONSTRAINT [fk_AnnouncementApplicationGrant_Announcement_AnnouncementSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the announcement system ID column in the Announcement Application Grant table match a announcement system ID in the Announcement table. It also ensures that when a record in the Announcement table is deleted, matching child records in the Announcement Application Grant table are deleted as well. Finally, the constraint blocks changes to the value of the announcement system ID column in the Announcement if matching child records exist in Announcement Application Grant.', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'CONSTRAINT', N'fk_AnnouncementApplicationGrant_Announcement_AnnouncementSID'
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	WITH CHECK
	ADD CONSTRAINT [fk_AnnouncementApplicationGrant_ApplicationGrant_ApplicationGrantSID]
	FOREIGN KEY ([ApplicationGrantSID]) REFERENCES [sf].[ApplicationGrant] ([ApplicationGrantSID])
ALTER TABLE [sf].[AnnouncementApplicationGrant]
	CHECK CONSTRAINT [fk_AnnouncementApplicationGrant_ApplicationGrant_ApplicationGrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application grant system ID column in the Announcement Application Grant table match a application grant system ID in the Application Grant table. It also ensures that records in the Application Grant table cannot be deleted if matching child records exist in Announcement Application Grant. Finally, the constraint blocks changes to the value of the application grant system ID column in the Application Grant if matching child records exist in Announcement Application Grant.', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'CONSTRAINT', N'fk_AnnouncementApplicationGrant_ApplicationGrant_ApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_AnnouncementApplicationGrant_AnnouncementSID_AnnouncementApplicationGrantSID]
	ON [sf].[AnnouncementApplicationGrant] ([AnnouncementSID], [AnnouncementApplicationGrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Announcement SID foreign key column and avoids row contention on (parent) Announcement updates', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'INDEX', N'ix_AnnouncementApplicationGrant_AnnouncementSID_AnnouncementApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_AnnouncementApplicationGrant_ApplicationGrantSID_AnnouncementApplicationGrantSID]
	ON [sf].[AnnouncementApplicationGrant] ([ApplicationGrantSID], [AnnouncementApplicationGrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Grant SID foreign key column and avoids row contention on (parent) Application Grant updates', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'INDEX', N'ix_AnnouncementApplicationGrant_ApplicationGrantSID_AnnouncementApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table controls which users see each specific announcement.  The announcement is associated with one or more "base" grants.  When the user logs in, the application checks to see which base grants they have and only displays announcements associated with those grants.  For example, to have an announcement display to all administrative users, use the "ADMIN.BASE" grant.  To have the announcement display to multiple user groups, assoicate it with multiple base grants.', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the announcement application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'AnnouncementApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The announcement this grant is defined for', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'AnnouncementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The grant assigned to this announcement', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the announcement application grant | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'AnnouncementApplicationGrantXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the announcement application grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this announcement application grant record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the announcement application grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the announcement application grant record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the announcement application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AnnouncementApplicationGrant', 'CONSTRAINT', N'uk_AnnouncementApplicationGrant_RowGUID'
GO
ALTER TABLE [sf].[AnnouncementApplicationGrant] SET (LOCK_ESCALATION = TABLE)
GO
