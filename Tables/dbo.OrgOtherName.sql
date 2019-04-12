SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrgOtherName] (
		[OrgOtherNameSID]        [int] IDENTITY(1000001, 1) NOT NULL,
		[OrgSID]                 [int] NOT NULL,
		[OrgName]                [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExpiryDate]             [date] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[OrgOtherNameXID]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_OrgOtherName_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_OrgOtherName_OrgName_OrgSID]
		UNIQUE
		NONCLUSTERED
		([OrgName], [OrgSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_OrgOtherName]
		PRIMARY KEY
		CLUSTERED
		([OrgOtherNameSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Org Other Name table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'CONSTRAINT', N'pk_OrgOtherName'
GO
ALTER TABLE [dbo].[OrgOtherName]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_OrgOtherName]
	CHECK
	([dbo].[fOrgOtherName#Check]([OrgOtherNameSID],[OrgSID],[OrgName],[ExpiryDate],[OrgOtherNameXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[OrgOtherName]
CHECK CONSTRAINT [ck_OrgOtherName]
GO
ALTER TABLE [dbo].[OrgOtherName]
	ADD
	CONSTRAINT [df_OrgOtherName_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[OrgOtherName]
	ADD
	CONSTRAINT [df_OrgOtherName_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[OrgOtherName]
	ADD
	CONSTRAINT [df_OrgOtherName_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[OrgOtherName]
	ADD
	CONSTRAINT [df_OrgOtherName_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[OrgOtherName]
	ADD
	CONSTRAINT [df_OrgOtherName_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[OrgOtherName]
	ADD
	CONSTRAINT [df_OrgOtherName_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[OrgOtherName]
	WITH CHECK
	ADD CONSTRAINT [fk_OrgOtherName_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[OrgOtherName]
	CHECK CONSTRAINT [fk_OrgOtherName_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Org Other Name table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Org Other Name. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Org Other Name.', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'CONSTRAINT', N'fk_OrgOtherName_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_OrgOtherName_OrgSID_OrgOtherNameSID]
	ON [dbo].[OrgOtherName] ([OrgSID], [OrgOtherNameSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'INDEX', N'ix_OrgOtherName_OrgSID_OrgOtherNameSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table captures the history of names for organizations.  When an extended search is executed against organizations, both the current all previous names are searched.  The data is collected in this table automatically.  When the name is updated on the main record, the application records the prior name setting the current date (less 1 day) as the expiry date for the previous name.  The new name is effective the following day.  The user may update the expiry date to a previous date which in turn impacts the derived effective date of the current name. It is not possible to pre-enter future name changes for organizations. ', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org other name assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'OrgOtherNameSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this other name is defined for', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the organization', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org other name | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'OrgOtherNameXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org other name record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org other name record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org other name record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'CONSTRAINT', N'uk_OrgOtherName_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Org Name + Org SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'OrgOtherName', 'CONSTRAINT', N'uk_OrgOtherName_OrgName_OrgSID'
GO
ALTER TABLE [dbo].[OrgOtherName] SET (LOCK_ESCALATION = TABLE)
GO
