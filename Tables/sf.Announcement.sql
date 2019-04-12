SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Announcement] (
		[AnnouncementSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[Title]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AnnouncementText]          [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EffectiveTime]             [datetime] NOT NULL,
		[ExpiryTime]                [datetime] NOT NULL,
		[AdditionalInfoPageURI]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TagList]                   [xml] NOT NULL,
		[IsLoginAlert]              [bit] NOT NULL,
		[IsExtendedFormat]          [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[AnnouncementXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_Announcement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Announcement]
		PRIMARY KEY
		CLUSTERED
		([AnnouncementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Announcement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'CONSTRAINT', N'pk_Announcement'
GO
ALTER TABLE [sf].[Announcement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Announcement]
	CHECK
	([sf].[fAnnouncement#Check]([AnnouncementSID],[Title],[AnnouncementText],[EffectiveTime],[ExpiryTime],[AdditionalInfoPageURI],[IsLoginAlert],[IsExtendedFormat],[AnnouncementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Announcement]
CHECK CONSTRAINT [ck_Announcement]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_TagList]
	DEFAULT (CONVERT([xml],N'<TagList/>',(0))) FOR [TagList]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_IsLoginAlert]
	DEFAULT (CONVERT([bit],(0))) FOR [IsLoginAlert]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_IsExtendedFormat]
	DEFAULT (CONVERT([bit],(0))) FOR [IsExtendedFormat]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Announcement]
	ADD
	CONSTRAINT [df_Announcement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Announcement_LegacyKey]
	ON [sf].[Announcement] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'INDEX', N'ux_Announcement_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Announcements are short posts that appear on the landing page in the application.  The user interface advises users about new announcements they have not yet read with a badge count.  Announcements marked as “alerts” display as a gritter message on the landing page.  All announcements can also be viewed from a control on the Dashboard.  Announcements let users know about changes to the system, planned outages, news events or any other information administrators or product owners would like their user audience to know about.  It is possible to control which announcements are seen by which users by setting specific base grants to define the audience.  For example, "ADMIN.BASE" would show the announcement to all administrators while adding "CLIENT.BASE" (to Announcement-Application-Grant) would show the announcement on the client portal.  The UI control for announcements shows the user which announcements are “new” to them and which they have already seen.   A user can “clear” an announcement so that it no longer appears for them but still appears for other users.  All announcements must include an expiry date after which they will not appear for any user.  If all announcements have been cleared by a user (or are otherwise expired), the control is empty and may include a phrase like “Nothing new here”.', 'SCHEMA', N'sf', 'TABLE', N'Announcement', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the announcement assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'AnnouncementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title of the announcement that appears as a heading on landing page control', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this announcement should first become available to users on the system | Announcements can be post dated to appear in the future', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A date (and optionally time) after which the announcement should no longer be displayed', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A link to a web page providing additional content on the announcement ', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'AdditionalInfoPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of tags used to classify the announcement and to support filtering and searching', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'TagList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the announcement is displayed as an alert after login on the dashboard ', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'IsLoginAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates all formatting for the announcement is embedded in the content (no standard wrapping applied by the application) | Used internally by the help desk to create custom-format announcements', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'IsExtendedFormat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the announcement | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'AnnouncementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the announcement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this announcement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the announcement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the announcement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the announcement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'CONSTRAINT', N'uk_Announcement_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Announcement_TagList]
	ON [sf].[Announcement] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'sf', 'TABLE', N'Announcement', 'INDEX', N'xp_Announcement_TagList'
GO
ALTER TABLE [sf].[Announcement] SET (LOCK_ESCALATION = TABLE)
GO
