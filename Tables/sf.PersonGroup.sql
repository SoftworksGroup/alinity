SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonGroup] (
		[PersonGroupSID]               [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonGroupName]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PersonGroupLabel]             [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PersonGroupCategory]          [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Description]                  [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ApplicationUserSID]           [int] NOT NULL,
		[IsPreference]                 [bit] NOT NULL,
		[IsDocumentLibraryEnabled]     [bit] NOT NULL,
		[QuerySID]                     [int] NULL,
		[LastReviewUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LastReviewTime]               [datetimeoffset](7) NOT NULL,
		[TagList]                      [xml] NOT NULL,
		[SmartGroupCount]              [int] NOT NULL,
		[SmartGroupCountTime]          [datetimeoffset](7) NOT NULL,
		[IsActive]                     [bit] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[PersonGroupXID]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonGroup_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonGroup_PersonGroupName]
		UNIQUE
		NONCLUSTERED
		([PersonGroupName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonGroup_PersonGroupLabel]
		UNIQUE
		NONCLUSTERED
		([PersonGroupLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonGroup]
		PRIMARY KEY
		CLUSTERED
		([PersonGroupSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Group table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'CONSTRAINT', N'pk_PersonGroup'
GO
ALTER TABLE [sf].[PersonGroup]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonGroup]
	CHECK
	([sf].[fPersonGroup#Check]([PersonGroupSID],[PersonGroupName],[PersonGroupLabel],[PersonGroupCategory],[Description],[ApplicationUserSID],[IsPreference],[IsDocumentLibraryEnabled],[QuerySID],[LastReviewUser],[LastReviewTime],[SmartGroupCount],[SmartGroupCountTime],[IsActive],[PersonGroupXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonGroup]
CHECK CONSTRAINT [ck_PersonGroup]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_IsPreference]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPreference]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_IsDocumentLibraryEnabled]
	DEFAULT ((0)) FOR [IsDocumentLibraryEnabled]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_LastReviewUser]
	DEFAULT (suser_sname()) FOR [LastReviewUser]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_LastReviewTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastReviewTime]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>')) FOR [TagList]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_SmartGroupCount]
	DEFAULT ((0)) FOR [SmartGroupCount]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_SmartGroupCountTime]
	DEFAULT (sysdatetimeoffset()) FOR [SmartGroupCountTime]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonGroup]
	ADD
	CONSTRAINT [df_PersonGroup_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonGroup]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroup_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[PersonGroup]
	CHECK CONSTRAINT [fk_PersonGroup_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Person Group table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Person Group. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Person Group.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'CONSTRAINT', N'fk_PersonGroup_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[PersonGroup]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroup_Query_QuerySID]
	FOREIGN KEY ([QuerySID]) REFERENCES [sf].[Query] ([QuerySID])
ALTER TABLE [sf].[PersonGroup]
	CHECK CONSTRAINT [fk_PersonGroup_Query_QuerySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the query system ID column in the Person Group table match a query system ID in the Query table. It also ensures that records in the Query table cannot be deleted if matching child records exist in Person Group. Finally, the constraint blocks changes to the value of the query system ID column in the Query if matching child records exist in Person Group.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'CONSTRAINT', N'fk_PersonGroup_Query_QuerySID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroup_ApplicationUserSID_PersonGroupSID]
	ON [sf].[PersonGroup] ([ApplicationUserSID], [PersonGroupSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'INDEX', N'ix_PersonGroup_ApplicationUserSID_PersonGroupSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroup_QuerySID_PersonGroupSID]
	ON [sf].[PersonGroup] ([QuerySID], [PersonGroupSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Query SID foreign key column and avoids row contention on (parent) Query updates', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'INDEX', N'ix_PersonGroup_QuerySID_PersonGroupSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonGroup_LegacyKey]
	ON [sf].[PersonGroup] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'INDEX', N'ux_PersonGroup_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the name, owner and configuration details of groups of people created in the application.  Groups can be made up of individuals assigned to the group by the group creator, or, "smart groups" can be created that return members based on executing a query.  Group members are stored in the Person-Group-Member table and can be assigned rights to contribute to an online document library and/or to administer the group.  Smart group members cannot be assigned titles, rights or terms in this version of the software.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person group assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'PersonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the person group to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'PersonGroupName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the person group to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'PersonGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize groups under', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'PersonGroupCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this person group', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the member/client can manage membership in the group as a preference in their profile', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'IsPreference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query assigned to this person group', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity of the user (an administrator) who completed the last review of this group', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this group was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total number of group members the last time the  smart-group query was executed', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'SmartGroupCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the count of members in the smart group was last updated', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'SmartGroupCountTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person group record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person group | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'PersonGroupXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person group record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person group record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person group record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'CONSTRAINT', N'uk_PersonGroup_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Person Group Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'CONSTRAINT', N'uk_PersonGroup_PersonGroupName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Person Group Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'CONSTRAINT', N'uk_PersonGroup_PersonGroupLabel'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_PersonGroup_TagList]
	ON [sf].[PersonGroup] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'sf', 'TABLE', N'PersonGroup', 'INDEX', N'xp_PersonGroup_TagList'
GO
ALTER TABLE [sf].[PersonGroup] SET (LOCK_ESCALATION = TABLE)
GO
