SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantEmployment] (
		[RegistrantEmploymentSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]               [int] NOT NULL,
		[OrgSID]                      [int] NOT NULL,
		[RegistrationYear]            [smallint] NOT NULL,
		[EmploymentTypeSID]           [int] NOT NULL,
		[EmploymentRoleSID]           [int] NOT NULL,
		[PracticeHours]               [int] NOT NULL,
		[PracticeScopeSID]            [int] NOT NULL,
		[AgeRangeSID]                 [int] NOT NULL,
		[IsOnPublicRegistry]          [bit] NOT NULL,
		[Phone]                       [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SiteLocation]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EffectiveTime]               [datetime] NULL,
		[ExpiryTime]                  [datetime] NULL,
		[Rank]                        [smallint] NOT NULL,
		[OwnershipPercentage]         [smallint] NOT NULL,
		[IsEmployerInsurance]         [bit] NOT NULL,
		[InsuranceOrgSID]             [int] NULL,
		[InsurancePolicyNo]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InsuranceAmount]             [decimal](11, 2) NULL,
		[UserDefinedColumns]          [xml] NULL,
		[RegistrantEmploymentXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantEmployment_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantEmployment]
		PRIMARY KEY
		CLUSTERED
		([RegistrantEmploymentSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Employment table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'pk_RegistrantEmployment'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantEmployment]
	CHECK
	([dbo].[fRegistrantEmployment#Check]([RegistrantEmploymentSID],[RegistrantSID],[OrgSID],[RegistrationYear],[EmploymentTypeSID],[EmploymentRoleSID],[PracticeHours],[PracticeScopeSID],[AgeRangeSID],[IsOnPublicRegistry],[Phone],[SiteLocation],[EffectiveTime],[ExpiryTime],[Rank],[OwnershipPercentage],[IsEmployerInsurance],[InsuranceOrgSID],[InsurancePolicyNo],[InsuranceAmount],[RegistrantEmploymentXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantEmployment]
CHECK CONSTRAINT [ck_RegistrantEmployment]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_RegistrationYear]
	DEFAULT ([sf].[fTodayYear]()) FOR [RegistrationYear]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_PracticeHours]
	DEFAULT ((0)) FOR [PracticeHours]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_IsOnPublicRegistry]
	DEFAULT (CONVERT([bit],(1))) FOR [IsOnPublicRegistry]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_Rank]
	DEFAULT ((5)) FOR [Rank]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_OwnershipPercentage]
	DEFAULT ((0)) FOR [OwnershipPercentage]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_IsEmployerInsurance]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEmployerInsurance]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	ADD
	CONSTRAINT [df_RegistrantEmployment_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Employment table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Registrant Employment table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_Org_OrgSID'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_AgeRange_AgeRangeSID]
	FOREIGN KEY ([AgeRangeSID]) REFERENCES [dbo].[AgeRange] ([AgeRangeSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_AgeRange_AgeRangeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the age range system ID column in the Registrant Employment table match a age range system ID in the Age Range table. It also ensures that records in the Age Range table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the age range system ID column in the Age Range if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_AgeRange_AgeRangeSID'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_EmploymentRole_EmploymentRoleSID]
	FOREIGN KEY ([EmploymentRoleSID]) REFERENCES [dbo].[EmploymentRole] ([EmploymentRoleSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_EmploymentRole_EmploymentRoleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the employment role system ID column in the Registrant Employment table match a employment role system ID in the Employment Role table. It also ensures that records in the Employment Role table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the employment role system ID column in the Employment Role if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_EmploymentRole_EmploymentRoleSID'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_EmploymentType_EmploymentTypeSID]
	FOREIGN KEY ([EmploymentTypeSID]) REFERENCES [dbo].[EmploymentType] ([EmploymentTypeSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_EmploymentType_EmploymentTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the employment type system ID column in the Registrant Employment table match a employment type system ID in the Employment Type table. It also ensures that records in the Employment Type table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the employment type system ID column in the Employment Type if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_EmploymentType_EmploymentTypeSID'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_PracticeScope_PracticeScopeSID]
	FOREIGN KEY ([PracticeScopeSID]) REFERENCES [dbo].[PracticeScope] ([PracticeScopeSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_PracticeScope_PracticeScopeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice scope system ID column in the Registrant Employment table match a practice scope system ID in the Practice Scope table. It also ensures that records in the Practice Scope table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the practice scope system ID column in the Practice Scope if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_PracticeScope_PracticeScopeSID'
GO
ALTER TABLE [dbo].[RegistrantEmployment]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmployment_Org_InsuranceOrgSID]
	FOREIGN KEY ([InsuranceOrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[RegistrantEmployment]
	CHECK CONSTRAINT [fk_RegistrantEmployment_Org_InsuranceOrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the insurance org system ID column in the Registrant Employment table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Registrant Employment. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Registrant Employment.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'fk_RegistrantEmployment_Org_InsuranceOrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_AgeRangeSID_RegistrantEmploymentSID]
	ON [dbo].[RegistrantEmployment] ([AgeRangeSID], [RegistrantEmploymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Age Range SID foreign key column and avoids row contention on (parent) Age Range updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_AgeRangeSID_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_EmploymentRoleSID_RegistrantEmploymentSID]
	ON [dbo].[RegistrantEmployment] ([EmploymentRoleSID], [RegistrantEmploymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Employment Role SID foreign key column and avoids row contention on (parent) Employment Role updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_EmploymentRoleSID_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_EmploymentTypeSID_RegistrantEmploymentSID]
	ON [dbo].[RegistrantEmployment] ([EmploymentTypeSID], [RegistrantEmploymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Employment Type SID foreign key column and avoids row contention on (parent) Employment Type updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_EmploymentTypeSID_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_InsuranceOrgSID_RegistrantEmploymentSID]
	ON [dbo].[RegistrantEmployment] ([InsuranceOrgSID], [RegistrantEmploymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Insurance Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_InsuranceOrgSID_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_OrgSID]
	ON [dbo].[RegistrantEmployment] ([OrgSID])
	INCLUDE ([RegistrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_PracticeScopeSID_RegistrantEmploymentSID]
	ON [dbo].[RegistrantEmployment] ([PracticeScopeSID], [RegistrantEmploymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Scope SID foreign key column and avoids row contention on (parent) Practice Scope updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_PracticeScopeSID_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmployment_RegistrantSID_RegistrantEmploymentSID]
	ON [dbo].[RegistrantEmployment] ([RegistrantSID], [RegistrantEmploymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'INDEX', N'ix_RegistrantEmployment_RegistrantSID_RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table defines the list of employers a registrant works for in a registration year.  The values are typically filled out during the registration renewal process.  The total hours worked for the employer in the year is required along with the primary area of responsibility.  The Practice Area is stored in a child table (Registrant-Employment-Practice-Area).  More than one practice area can be specified but for reporting to external partiy like CIHI, only the "primary" (Is-Primary = 1) is generally included.  The system establishes a "ranking" of employers based on the number of hours worked for each.  The link to registrant insurance is nullable but if filled in, indicates that the insurance for the member is provided through the employer and applies only to work in that employment location.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this employment is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'EmploymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'EmploymentRoleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice scope assigned to this registrant employment', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'PracticeScopeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Age Range assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'AgeRangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employer should be included in employers listed for the registrant on the public directly. The default setting is on, however, if the public registry configuration does not include employment, this setting has no impact.  Where employment is included in the public registry, this value should be included in the Profile Update form so that registrants can turn on/off the employers which display during the year as their employment changes.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'IsOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A phone number for this individual at their place of employment (do not enter mobile phone numbers here)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A location of employment within the organization facility (optional)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'SiteLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the employment started if precision beyond registration year is required ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when employment ended (blank if employment is still ongoing or expiry is unknown)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Where no hours have been reported for the employer, a ranking value used to set primary, secondary, etc. employer position.  ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'Rank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When non-zero indicates member is self-employed. When value is > 0, then a specific share-percentage of ownership is specified. | Note that the value "-1"  is used to indicate a member is self-employed but ownership is unknown or not specified.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'OwnershipPercentage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant employment', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant employment | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'RegistrantEmploymentXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant employment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant employment record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant employment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant employment record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant employment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmployment', 'CONSTRAINT', N'uk_RegistrantEmployment_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantEmployment] SET (LOCK_ESCALATION = TABLE)
GO
