SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmploymentStatus] (
		[EmploymentStatusSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[EmploymentStatusName]     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EmploymentStatusCode]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                [bit] NOT NULL,
		[IsEmploymentExpected]     [bit] NOT NULL,
		[IsActive]                 [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[EmploymentStatusXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_EmploymentStatus_EmploymentStatusCode]
		UNIQUE
		NONCLUSTERED
		([EmploymentStatusCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmploymentStatus_EmploymentStatusName]
		UNIQUE
		NONCLUSTERED
		([EmploymentStatusName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmploymentStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmploymentStatus]
		PRIMARY KEY
		CLUSTERED
		([EmploymentStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Employment Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'CONSTRAINT', N'pk_EmploymentStatus'
GO
ALTER TABLE [dbo].[EmploymentStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmploymentStatus]
	CHECK
	([dbo].[fEmploymentStatus#Check]([EmploymentStatusSID],[EmploymentStatusName],[EmploymentStatusCode],[IsDefault],[IsEmploymentExpected],[IsActive],[EmploymentStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[EmploymentStatus]
CHECK CONSTRAINT [ck_EmploymentStatus]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[EmploymentStatus]
	ADD
	CONSTRAINT [df_EmploymentStatus_IsEmploymentExpected]
	DEFAULT (CONVERT([bit],(1))) FOR [IsEmploymentExpected]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmploymentStatus_IsDefault]
	ON [dbo].[EmploymentStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Employment Status', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'INDEX', N'ux_EmploymentStatus_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is a master list of categories describing the overall employment status of the registrant.  This is typically reported during the renewal process and is updated each year. The status is "forward looking" referring to their current status.  For example, while they may have workded only part-time in the past year they may be seeking full-time employment going forward.  The values can refer to any status descriptions appropriate for the organization.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the Employment-Status-XID (external ID) column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'EmploymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the employment status to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'EmploymentStatusName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default employment status to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates one or more active employment records are expected for members in this status', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'IsEmploymentExpected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employment status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the employment status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'EmploymentStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the employment status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this employment status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the employment status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the employment status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the employment status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Employment Status Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'CONSTRAINT', N'uk_EmploymentStatus_EmploymentStatusCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Employment Status Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'CONSTRAINT', N'uk_EmploymentStatus_EmploymentStatusName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentStatus', 'CONSTRAINT', N'uk_EmploymentStatus_RowGUID'
GO
ALTER TABLE [dbo].[EmploymentStatus] SET (LOCK_ESCALATION = TABLE)
GO
