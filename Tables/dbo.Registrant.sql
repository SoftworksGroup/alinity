SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Registrant] (
		[RegistrantSID]                      [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                          [int] NOT NULL,
		[RegistrantNo]                       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[YearOfInitialEmployment]            [smallint] NULL,
		[IsOnPublicRegistry]                 [bit] NOT NULL,
		[CityNameOfBirth]                    [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountrySID]                         [int] NULL,
		[DirectedAuditYearCompetence]        [smallint] NULL,
		[DirectedAuditYearPracticeHours]     [smallint] NULL,
		[LateFeeExclusionYear]               [smallint] NULL,
		[IsRenewalAutoApprovalBlocked]       [bit] NOT NULL,
		[RenewalExtensionExpiryTime]         [datetime] NULL,
		[PublicDirectoryComment]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ArchivedTime]                       [datetimeoffset](7) NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[RegistrantXID]                      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_Registrant_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Registrant_RegistrantNo]
		UNIQUE
		NONCLUSTERED
		([RegistrantNo])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Registrant_PersonSID]
		UNIQUE
		NONCLUSTERED
		([PersonSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Registrant]
		PRIMARY KEY
		CLUSTERED
		([RegistrantSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'CONSTRAINT', N'pk_Registrant'
GO
ALTER TABLE [dbo].[Registrant]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Registrant]
	CHECK
	([dbo].[fRegistrant#Check]([RegistrantSID],[PersonSID],[RegistrantNo],[YearOfInitialEmployment],[IsOnPublicRegistry],[CityNameOfBirth],[CountrySID],[DirectedAuditYearCompetence],[DirectedAuditYearPracticeHours],[LateFeeExclusionYear],[IsRenewalAutoApprovalBlocked],[RenewalExtensionExpiryTime],[ArchivedTime],[RegistrantXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Registrant]
CHECK CONSTRAINT [ck_Registrant]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_IsOnPublicRegistry]
	DEFAULT (CONVERT([bit],(1))) FOR [IsOnPublicRegistry]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_IsRenewalAutoApprovalBlocked]
	DEFAULT (CONVERT([bit],(0))) FOR [IsRenewalAutoApprovalBlocked]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Registrant]
	ADD
	CONSTRAINT [df_Registrant_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Registrant]
	WITH CHECK
	ADD CONSTRAINT [fk_Registrant_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[Registrant]
	CHECK CONSTRAINT [fk_Registrant_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Registrant table match a person system ID in the Person table. It also ensures that when a record in the Person table is deleted, matching child records in the Registrant table are deleted as well. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Registrant.', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'CONSTRAINT', N'fk_Registrant_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[Registrant]
	WITH CHECK
	ADD CONSTRAINT [fk_Registrant_Country_CountrySID]
	FOREIGN KEY ([CountrySID]) REFERENCES [dbo].[Country] ([CountrySID])
ALTER TABLE [dbo].[Registrant]
	CHECK CONSTRAINT [fk_Registrant_Country_CountrySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the country system ID column in the Registrant table match a country system ID in the Country table. It also ensures that records in the Country table cannot be deleted if matching child records exist in Registrant. Finally, the constraint blocks changes to the value of the country system ID column in the Country if matching child records exist in Registrant.', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'CONSTRAINT', N'fk_Registrant_Country_CountrySID'
GO
CREATE NONCLUSTERED INDEX [ix_Registrant_CountrySID_RegistrantSID]
	ON [dbo].[Registrant] ([CountrySID], [RegistrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Country SID foreign key column and avoids row contention on (parent) Country updates', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'INDEX', N'ix_Registrant_CountrySID_RegistrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_Registrant_PersonSID_RegistrantSID]
	ON [dbo].[Registrant] ([PersonSID], [RegistrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'INDEX', N'ix_Registrant_PersonSID_RegistrantSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Registrant_LegacyKey]
	ON [dbo].[Registrant] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'INDEX', N'ux_Registrant_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A Registrant is an individual who currently holds a registration/permit, did so in the past, or has applied for a registration.  This is the central entity around which applications, renewals, and licensing attributes are recorded.', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Optional comments that can be added to this member entry on the Public Directory | Used primarily to record complaint outcomes where Complaint Management module is not implemented', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'PublicDirectoryComment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'RegistrantXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'CONSTRAINT', N'uk_Registrant_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registrant No column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'CONSTRAINT', N'uk_Registrant_RegistrantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Person SID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Registrant', 'CONSTRAINT', N'uk_Registrant_PersonSID'
GO
ALTER TABLE [dbo].[Registrant] SET (LOCK_ESCALATION = TABLE)
GO
