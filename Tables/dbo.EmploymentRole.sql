SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmploymentRole] (
		[EmploymentRoleSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[EmploymentRoleName]     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EmploymentRoleCode]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[EmploymentRoleXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_EmploymentRole_EmploymentRoleCode]
		UNIQUE
		NONCLUSTERED
		([EmploymentRoleCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmploymentRole_EmploymentRoleName]
		UNIQUE
		NONCLUSTERED
		([EmploymentRoleName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmploymentRole_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmploymentRole]
		PRIMARY KEY
		CLUSTERED
		([EmploymentRoleSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Employment Role table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'CONSTRAINT', N'pk_EmploymentRole'
GO
ALTER TABLE [dbo].[EmploymentRole]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmploymentRole]
	CHECK
	([dbo].[fEmploymentRole#Check]([EmploymentRoleSID],[EmploymentRoleName],[EmploymentRoleCode],[IsDefault],[IsActive],[EmploymentRoleXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[EmploymentRole]
CHECK CONSTRAINT [ck_EmploymentRole]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[EmploymentRole]
	ADD
	CONSTRAINT [df_EmploymentRole_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmploymentRole_IsDefault]
	ON [dbo].[EmploymentRole] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Employment Role', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'INDEX', N'ux_EmploymentRole_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is a master list of types of employment roles used to describe employment records reported during renewal.  Generally it is used to refer to classes of positions or titles - e.g. "Staff Nurse", "Educator" etc.  The values can refer to any employment description appropriate for the organization.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the Employment-Role-XID (external ID) column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment role assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'EmploymentRoleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the employment role to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'EmploymentRoleName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default employment role to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employment role record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the employment role | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'EmploymentRoleXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the employment role | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this employment role record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the employment role | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the employment role record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the employment role record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Employment Role Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'CONSTRAINT', N'uk_EmploymentRole_EmploymentRoleCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Employment Role Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'CONSTRAINT', N'uk_EmploymentRole_EmploymentRoleName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentRole', 'CONSTRAINT', N'uk_EmploymentRole_RowGUID'
GO
ALTER TABLE [dbo].[EmploymentRole] SET (LOCK_ESCALATION = TABLE)
GO
