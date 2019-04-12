SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmploymentType] (
		[EmploymentTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[EmploymentTypeName]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EmploymentTypeCode]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EmploymentTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                  [bit] NOT NULL,
		[IsActive]                   [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[EmploymentTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_EmploymentType_EmploymentTypeCode]
		UNIQUE
		NONCLUSTERED
		([EmploymentTypeCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmploymentType_EmploymentTypeName]
		UNIQUE
		NONCLUSTERED
		([EmploymentTypeName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmploymentType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmploymentType]
		PRIMARY KEY
		CLUSTERED
		([EmploymentTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Employment Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'CONSTRAINT', N'pk_EmploymentType'
GO
ALTER TABLE [dbo].[EmploymentType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmploymentType]
	CHECK
	([dbo].[fEmploymentType#Check]([EmploymentTypeSID],[EmploymentTypeName],[EmploymentTypeCode],[EmploymentTypeCategory],[IsDefault],[IsActive],[EmploymentTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[EmploymentType]
CHECK CONSTRAINT [ck_EmploymentType]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[EmploymentType]
	ADD
	CONSTRAINT [df_EmploymentType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmploymentType_IsDefault]
	ON [dbo].[EmploymentType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Employment Type', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'INDEX', N'ux_EmploymentType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is a master list of types of employment describing the specific employment records reported during renewal.  Generally it is used to refer to whether the employment was "Full-Time", "Part-Time/Casual".  The values can refer to other employment type descriptions appropriate for the organization.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the Employment-Type-XID (external ID) column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'EmploymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the employment type to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'EmploymentTypeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'EmploymentTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default employment type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employment type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the employment type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'EmploymentTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the employment type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this employment type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the employment type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the employment type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the employment type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Employment Type Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'CONSTRAINT', N'uk_EmploymentType_EmploymentTypeCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Employment Type Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'CONSTRAINT', N'uk_EmploymentType_EmploymentTypeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentType', 'CONSTRAINT', N'uk_EmploymentType_RowGUID'
GO
ALTER TABLE [dbo].[EmploymentType] SET (LOCK_ESCALATION = TABLE)
GO
