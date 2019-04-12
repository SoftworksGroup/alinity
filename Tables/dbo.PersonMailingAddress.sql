SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonMailingAddress] (
		[PersonMailingAddressSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                   [int] NOT NULL,
		[StreetAddress1]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StreetAddress2]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress3]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CitySID]                     [int] NOT NULL,
		[PostalCode]                  [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegionSID]                   [int] NOT NULL,
		[EffectiveTime]               [datetime] NOT NULL,
		[IsAdminReviewRequired]       [bit] NOT NULL,
		[LastVerifiedTime]            [datetimeoffset](7) NULL,
		[ChangeLog]                   [xml] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[PersonMailingAddressXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonMailingAddress_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonMailingAddress]
		PRIMARY KEY
		CLUSTERED
		([PersonMailingAddressSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Mailing Address table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'CONSTRAINT', N'pk_PersonMailingAddress'
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonMailingAddress]
	CHECK
	([dbo].[fPersonMailingAddress#Check]([PersonMailingAddressSID],[PersonSID],[StreetAddress1],[StreetAddress2],[StreetAddress3],[CitySID],[PostalCode],[RegionSID],[EffectiveTime],[IsAdminReviewRequired],[LastVerifiedTime],[PersonMailingAddressXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonMailingAddress]
CHECK CONSTRAINT [ck_PersonMailingAddress]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_IsAdminReviewRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAdminReviewRequired]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_ChangeLog]
	DEFAULT (CONVERT([xml],'<Changes />')) FOR [ChangeLog]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	ADD
	CONSTRAINT [df_PersonMailingAddress_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonMailingAddress_City_CitySID]
	FOREIGN KEY ([CitySID]) REFERENCES [dbo].[City] ([CitySID])
ALTER TABLE [dbo].[PersonMailingAddress]
	CHECK CONSTRAINT [fk_PersonMailingAddress_City_CitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the city system ID column in the Person Mailing Address table match a city system ID in the City table. It also ensures that records in the City table cannot be deleted if matching child records exist in Person Mailing Address. Finally, the constraint blocks changes to the value of the city system ID column in the City if matching child records exist in Person Mailing Address.', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'CONSTRAINT', N'fk_PersonMailingAddress_City_CitySID'
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonMailingAddress_Region_RegionSID]
	FOREIGN KEY ([RegionSID]) REFERENCES [dbo].[Region] ([RegionSID])
ALTER TABLE [dbo].[PersonMailingAddress]
	CHECK CONSTRAINT [fk_PersonMailingAddress_Region_RegionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the region system ID column in the Person Mailing Address table match a region system ID in the Region table. It also ensures that records in the Region table cannot be deleted if matching child records exist in Person Mailing Address. Finally, the constraint blocks changes to the value of the region system ID column in the Region if matching child records exist in Person Mailing Address.', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'CONSTRAINT', N'fk_PersonMailingAddress_Region_RegionSID'
GO
ALTER TABLE [dbo].[PersonMailingAddress]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonMailingAddress_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[PersonMailingAddress]
	CHECK CONSTRAINT [fk_PersonMailingAddress_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Mailing Address table match a person system ID in the Person table. It also ensures that when a record in the Person table is deleted, matching child records in the Person Mailing Address table are deleted as well. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Mailing Address.', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'CONSTRAINT', N'fk_PersonMailingAddress_SF_Person_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingAddress_CitySID_PersonMailingAddressSID]
	ON [dbo].[PersonMailingAddress] ([CitySID], [PersonMailingAddressSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the City SID foreign key column and avoids row contention on (parent) City updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'ix_PersonMailingAddress_CitySID_PersonMailingAddressSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingAddress_EffectiveTime_PersonMailingAddressSID_PersonSID]
	ON [dbo].[PersonMailingAddress] ([EffectiveTime], [PersonMailingAddressSID], [PersonSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Mailing Address searches based on the Effective Time + Person Mailing Address SID + Person SID columns', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'ix_PersonMailingAddress_EffectiveTime_PersonMailingAddressSID_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingAddress_PersonSID_PersonMailingAddressSID]
	ON [dbo].[PersonMailingAddress] ([PersonSID], [PersonMailingAddressSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'ix_PersonMailingAddress_PersonSID_PersonMailingAddressSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingAddress_RegionSID_PersonMailingAddressSID]
	ON [dbo].[PersonMailingAddress] ([RegionSID], [PersonMailingAddressSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Region SID foreign key column and avoids row contention on (parent) Region updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'ix_PersonMailingAddress_RegionSID_PersonMailingAddressSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonMailingAddress_LegacyKey]
	ON [dbo].[PersonMailingAddress] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'ux_PersonMailingAddress_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingAddress_EffectiveTime]
	ON [dbo].[PersonMailingAddress] ([EffectiveTime])
	INCLUDE ([PersonMailingAddressSID], [PersonSID], [StreetAddress1], [StreetAddress2], [StreetAddress3], [CitySID], [PostalCode])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Mailing Address searches based on the Effective Time column', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'ix_PersonMailingAddress_EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person mailing address assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'PersonMailingAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this person mailing address is in', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this person mailing address', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new address through a profile update or renewal entered online).  The form can be configured to block automatic approval when addresses change in the case of renewals.', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes of audit interest made to the record', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'ChangeLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person mailing address | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'PersonMailingAddressXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person mailing address | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person mailing address record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person mailing address | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person mailing address record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person mailing address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'CONSTRAINT', N'uk_PersonMailingAddress_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_PersonMailingAddress_ChangeLog]
	ON [dbo].[PersonMailingAddress] ([ChangeLog])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Change Log (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'PersonMailingAddress', 'INDEX', N'xp_PersonMailingAddress_ChangeLog'
GO
ALTER TABLE [dbo].[PersonMailingAddress] SET (LOCK_ESCALATION = TABLE)
GO
