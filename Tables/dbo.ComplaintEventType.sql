SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplaintEventType] (
		[ComplaintEventTypeSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintEventTypeSCD]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ComplaintEventTypeLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                   [bit] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[ComplaintEventTypeXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplaintEventType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ComplaintEventType_ComplaintEventTypeSCD]
		UNIQUE
		NONCLUSTERED
		([ComplaintEventTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ComplaintEventType_ComplaintEventTypeLabel]
		UNIQUE
		NONCLUSTERED
		([ComplaintEventTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplaintEventType]
		PRIMARY KEY
		CLUSTERED
		([ComplaintEventTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint Event Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'CONSTRAINT', N'pk_ComplaintEventType'
GO
ALTER TABLE [dbo].[ComplaintEventType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplaintEventType]
	CHECK
	([dbo].[fComplaintEventType#Check]([ComplaintEventTypeSID],[ComplaintEventTypeSCD],[ComplaintEventTypeLabel],[IsDefault],[ComplaintEventTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplaintEventType]
CHECK CONSTRAINT [ck_ComplaintEventType]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplaintEventType]
	ADD
	CONSTRAINT [df_ComplaintEventType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ComplaintEventType_IsDefault]
	ON [dbo].[ComplaintEventType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Complaint Event Type', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'INDEX', N'ux_ComplaintEventType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is a master list of types of complaint event types used to describe employment records reported during renewal.  Generally it is used to refer to classes of positions or titles - e.g. "Staff Nurse", "Educator" etc.  The values can refer to any employment description appropriate for the organization.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the Employment-Role-XID (external ID) column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint event type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'ComplaintEventTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the complaint event type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'ComplaintEventTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complaint event type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'ComplaintEventTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complaint event type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint event type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'ComplaintEventTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint event type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint event type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint event type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint event type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint event type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'CONSTRAINT', N'uk_ComplaintEventType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Complaint Event Type SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'CONSTRAINT', N'uk_ComplaintEventType_ComplaintEventTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Complaint Event Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEventType', 'CONSTRAINT', N'uk_ComplaintEventType_ComplaintEventTypeLabel'
GO
ALTER TABLE [dbo].[ComplaintEventType] SET (LOCK_ESCALATION = TABLE)
GO
