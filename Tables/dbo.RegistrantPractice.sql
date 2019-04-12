SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantPractice] (
		[RegistrantPracticeSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]              [int] NOT NULL,
		[RegistrationYear]           [smallint] NOT NULL,
		[EmploymentStatusSID]        [int] NOT NULL,
		[PlannedRetirementDate]      [date] NULL,
		[OtherJurisdiction]          [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OtherJurisdictionHours]     [int] NOT NULL,
		[TotalPracticeHours]         [int] NOT NULL,
		[OrgSID]                     [int] NULL,
		[InsurancePolicyNo]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InsuranceAmount]            [decimal](11, 2) NULL,
		[InsuranceCertificateNo]     [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]         [xml] NULL,
		[RegistrantPracticeXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantPractice_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrantPractice_RegistrationYear_RegistrantSID]
		UNIQUE
		NONCLUSTERED
		([RegistrationYear], [RegistrantSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantPractice]
		PRIMARY KEY
		CLUSTERED
		([RegistrantPracticeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Practice table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'CONSTRAINT', N'pk_RegistrantPractice'
GO
ALTER TABLE [dbo].[RegistrantPractice]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantPractice]
	CHECK
	([dbo].[fRegistrantPractice#Check]([RegistrantPracticeSID],[RegistrantSID],[RegistrationYear],[EmploymentStatusSID],[PlannedRetirementDate],[OtherJurisdiction],[OtherJurisdictionHours],[TotalPracticeHours],[OrgSID],[InsurancePolicyNo],[InsuranceAmount],[InsuranceCertificateNo],[RegistrantPracticeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantPractice]
CHECK CONSTRAINT [ck_RegistrantPractice]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_RegistrationYear]
	DEFAULT ([sf].[fTodayYear]()) FOR [RegistrationYear]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_OtherJurisdictionHours]
	DEFAULT ((0)) FOR [OtherJurisdictionHours]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_TotalPracticeHours]
	DEFAULT ((0)) FOR [TotalPracticeHours]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	ADD
	CONSTRAINT [df_RegistrantPractice_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantPractice]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantPractice_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantPractice]
	CHECK CONSTRAINT [fk_RegistrantPractice_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Practice table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Practice. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Practice.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'CONSTRAINT', N'fk_RegistrantPractice_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantPractice]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantPractice_EmploymentStatus_EmploymentStatusSID]
	FOREIGN KEY ([EmploymentStatusSID]) REFERENCES [dbo].[EmploymentStatus] ([EmploymentStatusSID])
ALTER TABLE [dbo].[RegistrantPractice]
	CHECK CONSTRAINT [fk_RegistrantPractice_EmploymentStatus_EmploymentStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the employment status system ID column in the Registrant Practice table match a employment status system ID in the Employment Status table. It also ensures that records in the Employment Status table cannot be deleted if matching child records exist in Registrant Practice. Finally, the constraint blocks changes to the value of the employment status system ID column in the Employment Status if matching child records exist in Registrant Practice.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'CONSTRAINT', N'fk_RegistrantPractice_EmploymentStatus_EmploymentStatusSID'
GO
ALTER TABLE [dbo].[RegistrantPractice]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantPractice_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[RegistrantPractice]
	CHECK CONSTRAINT [fk_RegistrantPractice_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Registrant Practice table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Registrant Practice. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Registrant Practice.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'CONSTRAINT', N'fk_RegistrantPractice_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantPractice_EmploymentStatusSID_RegistrantPracticeSID]
	ON [dbo].[RegistrantPractice] ([EmploymentStatusSID], [RegistrantPracticeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Employment Status SID foreign key column and avoids row contention on (parent) Employment Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'INDEX', N'ix_RegistrantPractice_EmploymentStatusSID_RegistrantPracticeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantPractice_OrgSID_RegistrantPracticeSID]
	ON [dbo].[RegistrantPractice] ([OrgSID], [RegistrantPracticeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'INDEX', N'ix_RegistrantPractice_OrgSID_RegistrantPracticeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantPractice_RegistrantSID_RegistrantPracticeSID]
	ON [dbo].[RegistrantPractice] ([RegistrantSID], [RegistrantPracticeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'INDEX', N'ix_RegistrantPractice_RegistrantSID_RegistrantPracticeSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantPractice_LegacyKey]
	ON [dbo].[RegistrantPractice] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'INDEX', N'ux_RegistrantPractice_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant practice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'RegistrantPracticeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this practice is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant practice', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'EmploymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When reporting hours from another jurisdiction, the name of the jurisdiction or employer can be collected here.  For many configurations only the total hours is recorded.  ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'OtherJurisdiction'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the number of hours worked outside of the jurisdiction when reporting of such hours is required in the configuration. Only total hours are captured and employers are generally not specified, however, a field for capturing the jurisdiction name and/or employer is provided but not validated against a master list.  Note that these hours are typically not qualifying for a minimum hours requirement if one exists for the registration/registration.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'OtherJurisdictionHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total practice hours in the year when hours by employer cannot be reported | When this value is 0 hours are determined by adding up employment hours', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'TotalPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant practice', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional certificate number provided to the member where a common policy is provided by the insurer', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'InsuranceCertificateNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant practice | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'RegistrantPracticeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant practice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant practice record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant practice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant practice record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant practice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'CONSTRAINT', N'uk_RegistrantPractice_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registration Year + Registrant SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantPractice', 'CONSTRAINT', N'uk_RegistrantPractice_RegistrationYear_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantPractice] SET (LOCK_ESCALATION = TABLE)
GO
