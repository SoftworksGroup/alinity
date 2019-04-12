SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrgContact] (
		[OrgContactSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[OrgSID]                  [int] NOT NULL,
		[PersonSID]               [int] NOT NULL,
		[EffectiveTime]           [datetime] NOT NULL,
		[ExpiryTime]              [datetime] NULL,
		[IsReviewAdmin]           [bit] NOT NULL,
		[Title]                   [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DirectPhone]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAdminContact]          [bit] NOT NULL,
		[OwnershipPercentage]     [smallint] NOT NULL,
		[TagList]                 [xml] NOT NULL,
		[ChangeLog]               [xml] NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[OrgContactXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_OrgContact_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_OrgContact]
		PRIMARY KEY
		CLUSTERED
		([OrgContactSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Org Contact table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'CONSTRAINT', N'pk_OrgContact'
GO
ALTER TABLE [dbo].[OrgContact]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_OrgContact]
	CHECK
	([dbo].[fOrgContact#Check]([OrgContactSID],[OrgSID],[PersonSID],[EffectiveTime],[ExpiryTime],[IsReviewAdmin],[Title],[DirectPhone],[IsAdminContact],[OwnershipPercentage],[OrgContactXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[OrgContact]
CHECK CONSTRAINT [ck_OrgContact]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_IsReviewAdmin]
	DEFAULT (CONVERT([bit],(0))) FOR [IsReviewAdmin]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_IsAdminContact]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAdminContact]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_OwnershipPercentage]
	DEFAULT ((0)) FOR [OwnershipPercentage]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>')) FOR [TagList]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_ChangeLog]
	DEFAULT (CONVERT([xml],'<Changes />')) FOR [ChangeLog]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[OrgContact]
	ADD
	CONSTRAINT [df_OrgContact_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[OrgContact]
	WITH CHECK
	ADD CONSTRAINT [fk_OrgContact_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[OrgContact]
	CHECK CONSTRAINT [fk_OrgContact_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Org Contact table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Org Contact. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Org Contact.', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'CONSTRAINT', N'fk_OrgContact_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[OrgContact]
	WITH CHECK
	ADD CONSTRAINT [fk_OrgContact_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[OrgContact]
	CHECK CONSTRAINT [fk_OrgContact_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Org Contact table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Org Contact. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Org Contact.', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'CONSTRAINT', N'fk_OrgContact_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_OrgContact_OrgSID_OrgContactSID]
	ON [dbo].[OrgContact] ([OrgSID], [OrgContactSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'INDEX', N'ix_OrgContact_OrgSID_OrgContactSID'
GO
CREATE NONCLUSTERED INDEX [ix_OrgContact_PersonSID_OrgContactSID]
	ON [dbo].[OrgContact] ([PersonSID], [OrgContactSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'INDEX', N'ix_OrgContact_PersonSID_OrgContactSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_OrgContact_LegacyKey]
	ON [dbo].[OrgContact] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'INDEX', N'ux_OrgContact_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Org-Contact defines the relationship between people and organizations.  The most common relationship type is employment related to licensing.  When that is the situation then the Practice-Area value must also be filled in.  If the person is not a licensee who is employed by the organization (for example an HR person who reviews applications), then the Practice-Area should not be filled in. ', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org contact assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'OrgContactSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the organization assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Contact assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this individual can review/verify ALL applications for this organization without being specifically assigned as a reviewer', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'IsReviewAdmin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The position or role name that describes the relationship with this organization (job title)', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Direct phone number for this individual at the organization address (note: separate fields available for mobile and main organization phone numbers)', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'DirectPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this individual is a general contact for the organization.  This value distinguishes contacts administration can use for mailing information to for the organization, from contacts who have simply listed the organization as an employer.', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'IsAdminContact'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When value is > 0 indicates the contact has a share-percentage of ownership in the organization. | Note that ownership percentages may also be specified in Registrant-Employment and must be combined to attain full ownership view.', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'OwnershipPercentage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes of audit interest made to the record', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'ChangeLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org contact | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'OrgContactXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org contact | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org contact record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org contact | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org contact record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org contact record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'CONSTRAINT', N'uk_OrgContact_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_OrgContact_ChangeLog]
	ON [dbo].[OrgContact] ([ChangeLog])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Change Log (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'INDEX', N'xp_OrgContact_ChangeLog'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_OrgContact_TagList]
	ON [dbo].[OrgContact] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'OrgContact', 'INDEX', N'xp_OrgContact_TagList'
GO
ALTER TABLE [dbo].[OrgContact] SET (LOCK_ESCALATION = TABLE)
GO
