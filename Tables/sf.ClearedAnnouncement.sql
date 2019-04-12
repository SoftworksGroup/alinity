SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ClearedAnnouncement] (
		[ClearedAnnouncementSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[AnnouncementSID]            [int] NOT NULL,
		[ApplicationUserSID]         [int] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[ClearedAnnouncementXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_ClearedAnnouncement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ClearedAnnouncement]
		PRIMARY KEY
		CLUSTERED
		([ClearedAnnouncementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Cleared Announcement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'CONSTRAINT', N'pk_ClearedAnnouncement'
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ClearedAnnouncement]
	CHECK
	([sf].[fClearedAnnouncement#Check]([ClearedAnnouncementSID],[AnnouncementSID],[ApplicationUserSID],[ClearedAnnouncementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ClearedAnnouncement]
CHECK CONSTRAINT [ck_ClearedAnnouncement]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	ADD
	CONSTRAINT [df_ClearedAnnouncement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	ADD
	CONSTRAINT [df_ClearedAnnouncement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	ADD
	CONSTRAINT [df_ClearedAnnouncement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	ADD
	CONSTRAINT [df_ClearedAnnouncement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	ADD
	CONSTRAINT [df_ClearedAnnouncement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	ADD
	CONSTRAINT [df_ClearedAnnouncement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	WITH CHECK
	ADD CONSTRAINT [fk_ClearedAnnouncement_Announcement_AnnouncementSID]
	FOREIGN KEY ([AnnouncementSID]) REFERENCES [sf].[Announcement] ([AnnouncementSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[ClearedAnnouncement]
	CHECK CONSTRAINT [fk_ClearedAnnouncement_Announcement_AnnouncementSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the announcement system ID column in the Cleared Announcement table match a announcement system ID in the Announcement table. It also ensures that when a record in the Announcement table is deleted, matching child records in the Cleared Announcement table are deleted as well. Finally, the constraint blocks changes to the value of the announcement system ID column in the Announcement if matching child records exist in Cleared Announcement.', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'CONSTRAINT', N'fk_ClearedAnnouncement_Announcement_AnnouncementSID'
GO
ALTER TABLE [sf].[ClearedAnnouncement]
	WITH CHECK
	ADD CONSTRAINT [fk_ClearedAnnouncement_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[ClearedAnnouncement]
	CHECK CONSTRAINT [fk_ClearedAnnouncement_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Cleared Announcement table match a application user system ID in the Application User table. It also ensures that when a record in the Application User table is deleted, matching child records in the Cleared Announcement table are deleted as well. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Cleared Announcement.', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'CONSTRAINT', N'fk_ClearedAnnouncement_ApplicationUser_ApplicationUserSID'
GO
CREATE NONCLUSTERED INDEX [ix_ClearedAnnouncement_AnnouncementSID_ClearedAnnouncementSID]
	ON [sf].[ClearedAnnouncement] ([AnnouncementSID], [ClearedAnnouncementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Announcement SID foreign key column and avoids row contention on (parent) Announcement updates', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'INDEX', N'ix_ClearedAnnouncement_AnnouncementSID_ClearedAnnouncementSID'
GO
CREATE NONCLUSTERED INDEX [ix_ClearedAnnouncement_ApplicationUserSID_ClearedAnnouncementSID]
	ON [sf].[ClearedAnnouncement] ([ApplicationUserSID], [ClearedAnnouncementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'INDEX', N'ix_ClearedAnnouncement_ApplicationUserSID_ClearedAnnouncementSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ClearedAnnouncement_LegacyKey]
	ON [sf].[ClearedAnnouncement] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'INDEX', N'ux_ClearedAnnouncement_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table keeps track of announcements the user has cleared from their announcement dashboard.  This information is applied by the User Interface to avoid displaying the announcement.  Note that all announcements include an expiry date after which they will not appear for any user regardless of whether or not they have been cleared.  This table should be purged periodically of keys associated with expired (or deleted) announcements in order to keep UI performance acceptable.', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the cleared announcement assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'ClearedAnnouncementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The announcement assigned to this cleared', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'AnnouncementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this cleared announcement', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the cleared announcement | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'ClearedAnnouncementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the cleared announcement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this cleared announcement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the cleared announcement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the cleared announcement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the cleared announcement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ClearedAnnouncement', 'CONSTRAINT', N'uk_ClearedAnnouncement_RowGUID'
GO
ALTER TABLE [sf].[ClearedAnnouncement] SET (LOCK_ESCALATION = TABLE)
GO
