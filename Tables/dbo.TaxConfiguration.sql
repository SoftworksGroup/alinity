SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TaxConfiguration] (
		[TaxConfigurationSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[TaxSID]                  [int] NOT NULL,
		[TaxRate]                 [decimal](4, 4) NOT NULL,
		[GLAccountSID]            [int] NOT NULL,
		[EffectiveTime]           [datetime] NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[TaxConfigurationXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_TaxConfiguration_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TaxConfiguration]
		PRIMARY KEY
		CLUSTERED
		([TaxConfigurationSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Tax Configuration table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'CONSTRAINT', N'pk_TaxConfiguration'
GO
ALTER TABLE [dbo].[TaxConfiguration]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TaxConfiguration]
	CHECK
	([dbo].[fTaxConfiguration#Check]([TaxConfigurationSID],[TaxSID],[TaxRate],[GLAccountSID],[EffectiveTime],[TaxConfigurationXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[TaxConfiguration]
CHECK CONSTRAINT [ck_TaxConfiguration]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	ADD
	CONSTRAINT [df_TaxConfiguration_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	ADD
	CONSTRAINT [df_TaxConfiguration_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	ADD
	CONSTRAINT [df_TaxConfiguration_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	ADD
	CONSTRAINT [df_TaxConfiguration_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	ADD
	CONSTRAINT [df_TaxConfiguration_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	ADD
	CONSTRAINT [df_TaxConfiguration_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[TaxConfiguration]
	WITH CHECK
	ADD CONSTRAINT [fk_TaxConfiguration_GLAccount_GLAccountSID]
	FOREIGN KEY ([GLAccountSID]) REFERENCES [dbo].[GLAccount] ([GLAccountSID])
ALTER TABLE [dbo].[TaxConfiguration]
	CHECK CONSTRAINT [fk_TaxConfiguration_GLAccount_GLAccountSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the glaccount system ID column in the Tax Configuration table match a glaccount system ID in the GLAccount table. It also ensures that records in the GLAccount table cannot be deleted if matching child records exist in Tax Configuration. Finally, the constraint blocks changes to the value of the glaccount system ID column in the GLAccount if matching child records exist in Tax Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'CONSTRAINT', N'fk_TaxConfiguration_GLAccount_GLAccountSID'
GO
ALTER TABLE [dbo].[TaxConfiguration]
	WITH CHECK
	ADD CONSTRAINT [fk_TaxConfiguration_Tax_TaxSID]
	FOREIGN KEY ([TaxSID]) REFERENCES [dbo].[Tax] ([TaxSID])
ALTER TABLE [dbo].[TaxConfiguration]
	CHECK CONSTRAINT [fk_TaxConfiguration_Tax_TaxSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the tax system ID column in the Tax Configuration table match a tax system ID in the Tax table. It also ensures that records in the Tax table cannot be deleted if matching child records exist in Tax Configuration. Finally, the constraint blocks changes to the value of the tax system ID column in the Tax if matching child records exist in Tax Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'CONSTRAINT', N'fk_TaxConfiguration_Tax_TaxSID'
GO
CREATE NONCLUSTERED INDEX [ix_TaxConfiguration_GLAccountSID_TaxConfigurationSID]
	ON [dbo].[TaxConfiguration] ([GLAccountSID], [TaxConfigurationSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the GLAccount SID foreign key column and avoids row contention on (parent) GLAccount updates', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'INDEX', N'ix_TaxConfiguration_GLAccountSID_TaxConfigurationSID'
GO
CREATE NONCLUSTERED INDEX [ix_TaxConfiguration_TaxSID_TaxConfigurationSID]
	ON [dbo].[TaxConfiguration] ([TaxSID], [TaxConfigurationSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Tax SID foreign key column and avoids row contention on (parent) Tax updates', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'INDEX', N'ix_TaxConfiguration_TaxSID_TaxConfigurationSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaxConfiguration_LegacyKey]
	ON [dbo].[TaxConfiguration] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'INDEX', N'ux_TaxConfiguration_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the tax configuration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'TaxConfigurationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The tax this configuration is defined for', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'TaxSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The rate of the tax expressed as a decimal - e.g. a 5% tax is stored as 0.050', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'TaxRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The glaccount assigned to this tax configuration', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'GLAccountSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the tax configuration | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'TaxConfigurationXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the tax configuration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this tax configuration record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the tax configuration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the tax configuration record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the tax configuration record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'TaxConfiguration', 'CONSTRAINT', N'uk_TaxConfiguration_RowGUID'
GO
ALTER TABLE [dbo].[TaxConfiguration] SET (LOCK_ESCALATION = TABLE)
GO
