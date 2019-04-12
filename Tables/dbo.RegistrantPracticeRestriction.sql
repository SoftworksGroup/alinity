SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantPracticeRestriction] (
		[RegistrantPracticeRestrictionSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]                        [int] NOT NULL,
		[PracticeRestrictionSID]               [int] NOT NULL,
		[EffectiveTime]                        [datetime] NOT NULL,
		[ExpiryTime]                           [datetime] NULL,
		[IsDisplayedOnLicense]                 [bit] NOT NULL,
		[ComplaintSID]                         [int] NULL,
		[UserDefinedColumns]                   [xml] NULL,
		[RegistrantPracticeRestrictionXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                            [bit] NOT NULL,
		[CreateUser]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                           [datetimeoffset](7) NOT NULL,
		[UpdateUser]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                           [datetimeoffset](7) NOT NULL,
		[RowGUID]                              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                             [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantPracticeRestriction_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantPracticeRestriction]
		PRIMARY KEY
		CLUSTERED
		([RegistrantPracticeRestrictionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Practice Restriction table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'CONSTRAINT', N'pk_RegistrantPracticeRestriction'
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantPracticeRestriction]
	CHECK
	([dbo].[fRegistrantPracticeRestriction#Check]([RegistrantPracticeRestrictionSID],[RegistrantSID],[PracticeRestrictionSID],[EffectiveTime],[ExpiryTime],[IsDisplayedOnLicense],[ComplaintSID],[RegistrantPracticeRestrictionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
CHECK CONSTRAINT [ck_RegistrantPracticeRestriction]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_IsDisplayedOnLicense]
	DEFAULT ((1)) FOR [IsDisplayedOnLicense]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	ADD
	CONSTRAINT [df_RegistrantPracticeRestriction_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantPracticeRestriction_Complaint_ComplaintSID]
	FOREIGN KEY ([ComplaintSID]) REFERENCES [dbo].[Complaint] ([ComplaintSID])
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	CHECK CONSTRAINT [fk_RegistrantPracticeRestriction_Complaint_ComplaintSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint system ID column in the Registrant Practice Restriction table match a complaint system ID in the Complaint table. It also ensures that records in the Complaint table cannot be deleted if matching child records exist in Registrant Practice Restriction. Finally, the constraint blocks changes to the value of the complaint system ID column in the Complaint if matching child records exist in Registrant Practice Restriction.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'CONSTRAINT', N'fk_RegistrantPracticeRestriction_Complaint_ComplaintSID'
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantPracticeRestriction_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	CHECK CONSTRAINT [fk_RegistrantPracticeRestriction_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Practice Restriction table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Practice Restriction. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Practice Restriction.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'CONSTRAINT', N'fk_RegistrantPracticeRestriction_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantPracticeRestriction_PracticeRestriction_PracticeRestrictionSID]
	FOREIGN KEY ([PracticeRestrictionSID]) REFERENCES [dbo].[PracticeRestriction] ([PracticeRestrictionSID])
ALTER TABLE [dbo].[RegistrantPracticeRestriction]
	CHECK CONSTRAINT [fk_RegistrantPracticeRestriction_PracticeRestriction_PracticeRestrictionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice restriction system ID column in the Registrant Practice Restriction table match a practice restriction system ID in the Practice Restriction table. It also ensures that records in the Practice Restriction table cannot be deleted if matching child records exist in Registrant Practice Restriction. Finally, the constraint blocks changes to the value of the practice restriction system ID column in the Practice Restriction if matching child records exist in Registrant Practice Restriction.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'CONSTRAINT', N'fk_RegistrantPracticeRestriction_PracticeRestriction_PracticeRestrictionSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantPracticeRestriction_ComplaintSID_RegistrantPracticeRestrictionSID]
	ON [dbo].[RegistrantPracticeRestriction] ([ComplaintSID], [RegistrantPracticeRestrictionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint SID foreign key column and avoids row contention on (parent) Complaint updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'INDEX', N'ix_RegistrantPracticeRestriction_ComplaintSID_RegistrantPracticeRestrictionSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantPracticeRestriction_PracticeRestrictionSID_RegistrantPracticeRestrictionSID]
	ON [dbo].[RegistrantPracticeRestriction] ([PracticeRestrictionSID], [RegistrantPracticeRestrictionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Restriction SID foreign key column and avoids row contention on (parent) Practice Restriction updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'INDEX', N'ix_RegistrantPracticeRestriction_PracticeRestrictionSID_RegistrantPracticeRestrictionSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantPracticeRestriction_RegistrantSID_RegistrantPracticeRestrictionSID]
	ON [dbo].[RegistrantPracticeRestriction] ([RegistrantSID], [RegistrantPracticeRestrictionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'INDEX', N'ix_RegistrantPracticeRestriction_RegistrantSID_RegistrantPracticeRestrictionSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantPracticeRestriction_LegacyKey]
	ON [dbo].[RegistrantPracticeRestriction] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'INDEX', N'ux_RegistrantPracticeRestriction_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant practice restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'RegistrantPracticeRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'PracticeRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this restriction/condition was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending time this restriction/condition was effective.  When blank indicates restriction remains in effect. | See Change Audit for history of restriction being turned on/off', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this restriction should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a restriction accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this registrant practice restriction', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant practice restriction | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'RegistrantPracticeRestrictionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant practice restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant practice restriction record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant practice restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant practice restriction record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant practice restriction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPracticeRestriction', 'CONSTRAINT', N'uk_RegistrantPracticeRestriction_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantPracticeRestriction] SET (LOCK_ESCALATION = TABLE)
GO
