SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplaintSeverity] (
		[ComplaintSeveritySID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintSeverityLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ComplaintSeverityCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                     [bit] NOT NULL,
		[Description]                   [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]                      [bit] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[ComplaintSeverityXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplaintSeverity_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ComplaintSeverity_ComplaintSeverityLabel]
		UNIQUE
		NONCLUSTERED
		([ComplaintSeverityLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplaintSeverity]
		PRIMARY KEY
		CLUSTERED
		([ComplaintSeveritySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint Severity table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'CONSTRAINT', N'pk_ComplaintSeverity'
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplaintSeverity]
	CHECK
	([dbo].[fComplaintSeverity#Check]([ComplaintSeveritySID],[ComplaintSeverityLabel],[ComplaintSeverityCategory],[IsDefault],[IsActive],[ComplaintSeverityXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplaintSeverity]
CHECK CONSTRAINT [ck_ComplaintSeverity]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplaintSeverity]
	ADD
	CONSTRAINT [df_ComplaintSeverity_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ComplaintSeverity_IsDefault]
	ON [dbo].[ComplaintSeverity] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Complaint Severity', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'INDEX', N'ux_ComplaintSeverity_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint severity assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'ComplaintSeveritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complaint severity to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'ComplaintSeverityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'ComplaintSeverityCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complaint severity to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complaint severity record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint severity | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'ComplaintSeverityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint severity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint severity record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint severity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint severity record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint severity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'CONSTRAINT', N'uk_ComplaintSeverity_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Complaint Severity Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintSeverity', 'CONSTRAINT', N'uk_ComplaintSeverity_ComplaintSeverityLabel'
GO
ALTER TABLE [dbo].[ComplaintSeverity] SET (LOCK_ESCALATION = TABLE)
GO
