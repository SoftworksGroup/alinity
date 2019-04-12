SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonGroupMember] (
		[PersonGroupMemberSID]               [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonGroupSID]                     [int] NOT NULL,
		[PersonSID]                          [int] NOT NULL,
		[Title]                              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAdministrator]                    [bit] NOT NULL,
		[IsContributor]                      [bit] NOT NULL,
		[EffectiveTime]                      [datetime] NOT NULL,
		[ExpiryTime]                         [datetime] NULL,
		[IsReplacementRequiredAfterTerm]     [bit] NOT NULL,
		[ReplacementClearedDate]             [date] NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[PersonGroupMemberXID]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonGroupMember_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonGroupMember]
		PRIMARY KEY
		CLUSTERED
		([PersonGroupMemberSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Group Member table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'CONSTRAINT', N'pk_PersonGroupMember'
GO
ALTER TABLE [sf].[PersonGroupMember]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonGroupMember]
	CHECK
	([sf].[fPersonGroupMember#Check]([PersonGroupMemberSID],[PersonGroupSID],[PersonSID],[Title],[IsAdministrator],[IsContributor],[EffectiveTime],[ExpiryTime],[IsReplacementRequiredAfterTerm],[ReplacementClearedDate],[PersonGroupMemberXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonGroupMember]
CHECK CONSTRAINT [ck_PersonGroupMember]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_IsAdministrator]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAdministrator]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_IsContributor]
	DEFAULT (CONVERT([bit],(1))) FOR [IsContributor]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_IsReplacementRequiredAfterTerm]
	DEFAULT (CONVERT([bit],(0))) FOR [IsReplacementRequiredAfterTerm]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonGroupMember]
	ADD
	CONSTRAINT [df_PersonGroupMember_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonGroupMember]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroupMember_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [sf].[PersonGroupMember]
	CHECK CONSTRAINT [fk_PersonGroupMember_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Group Member table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Group Member. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Group Member.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'CONSTRAINT', N'fk_PersonGroupMember_Person_PersonSID'
GO
ALTER TABLE [sf].[PersonGroupMember]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonGroupMember_PersonGroup_PersonGroupSID]
	FOREIGN KEY ([PersonGroupSID]) REFERENCES [sf].[PersonGroup] ([PersonGroupSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[PersonGroupMember]
	CHECK CONSTRAINT [fk_PersonGroupMember_PersonGroup_PersonGroupSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person group system ID column in the Person Group Member table match a person group system ID in the Person Group table. It also ensures that when a record in the Person Group table is deleted, matching child records in the Person Group Member table are deleted as well. Finally, the constraint blocks changes to the value of the person group system ID column in the Person Group if matching child records exist in Person Group Member.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'CONSTRAINT', N'fk_PersonGroupMember_PersonGroup_PersonGroupSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroupMember_PersonGroupSID_PersonGroupMemberSID]
	ON [sf].[PersonGroupMember] ([PersonGroupSID], [PersonGroupMemberSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Group SID foreign key column and avoids row contention on (parent) Person Group updates', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'INDEX', N'ix_PersonGroupMember_PersonGroupSID_PersonGroupMemberSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonGroupMember_PersonSID_PersonGroupMemberSID]
	ON [sf].[PersonGroupMember] ([PersonSID], [PersonGroupMemberSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'INDEX', N'ix_PersonGroupMember_PersonSID_PersonGroupMemberSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonGroupMember_LegacyKey]
	ON [sf].[PersonGroupMember] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'INDEX', N'ux_PersonGroupMember_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the list of members in a group. If the group is configured as a "smart group" the members are returned based on the results of a query and physical records are not stored here.  Smart-group members cannot be assigned title or terms.  For Committed and Board oriented groups, it is possible to assign an term start and end to each member and to indicate whether that position needs replacing after the term.  Group members can also share documents online and be assigned rights to contribute to the group and add/remove members by being assigned Group Administrator rights.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person group member assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'PersonGroupMemberSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person group this member is defined for', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'PersonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this group member is based on', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the position in the group - e.g. "Chairperson", "Secretary", etc.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this group member has rights to add and delete all content for the group site including adding and deleting/expiring new group members.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'IsAdministrator'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this group member can upload documents to the group library, send message to other group members,  and make changes to other group content. Without this grant the member has read-only access.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'IsContributor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that this group member needs to be replaced after their term expires', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'IsReplacementRequiredAfterTerm'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when a replacement for this group member was found, or the requirement for replacement was cleared', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'ReplacementClearedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person group member | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'PersonGroupMemberXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person group member | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person group member record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person group member | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person group member record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person group member record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonGroupMember', 'CONSTRAINT', N'uk_PersonGroupMember_RowGUID'
GO
ALTER TABLE [sf].[PersonGroupMember] SET (LOCK_ESCALATION = TABLE)
GO
