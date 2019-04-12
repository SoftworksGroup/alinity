SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RequirementStatus] (
		[RequirementStatusSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[RequirementStatusSCD]          [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RequirementStatusLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsFinal]                       [bit] NOT NULL,
		[Description]                   [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RequirementStatusSequence]     [int] NOT NULL,
		[IsDefault]                     [bit] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[RequirementStatusXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_RequirementStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RequirementStatus_RequirementStatusSCD]
		UNIQUE
		NONCLUSTERED
		([RequirementStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RequirementStatus_RequirementStatusLabel]
		UNIQUE
		NONCLUSTERED
		([RequirementStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RequirementStatus]
		PRIMARY KEY
		CLUSTERED
		([RequirementStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Requirement Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'CONSTRAINT', N'pk_RequirementStatus'
GO
ALTER TABLE [dbo].[RequirementStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RequirementStatus]
	CHECK
	([dbo].[fRequirementStatus#Check]([RequirementStatusSID],[RequirementStatusSCD],[RequirementStatusLabel],[IsFinal],[RequirementStatusSequence],[IsDefault],[RequirementStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RequirementStatus]
CHECK CONSTRAINT [ck_RequirementStatus]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_IsFinal]
	DEFAULT (CONVERT([bit],(0))) FOR [IsFinal]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_RequirementStatusSequence]
	DEFAULT ((0)) FOR [RequirementStatusSequence]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[RequirementStatus]
	ADD
	CONSTRAINT [df_RequirementStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RequirementStatus_IsDefault]
	ON [dbo].[RequirementStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Requirement Status', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'INDEX', N'ux_RequirementStatus_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the requirement status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RequirementStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the requirement status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RequirementStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the requirement status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RequirementStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a final status.  Once the requirement achieves this status it is considered closed.', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'IsFinal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An explanation of when this status is applied to the requirement', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this statuses should appear in when presented to the administrator on the form | These statuses are typically presented in a radio-button-set (<5) or drop down (5+) on the user interface.', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RequirementStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default requirement status to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the requirement status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RequirementStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the requirement status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this requirement status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the requirement status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the requirement status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the requirement status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'CONSTRAINT', N'uk_RequirementStatus_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Requirement Status SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'CONSTRAINT', N'uk_RequirementStatus_RequirementStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Requirement Status Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RequirementStatus', 'CONSTRAINT', N'uk_RequirementStatus_RequirementStatusLabel'
GO
ALTER TABLE [dbo].[RequirementStatus] SET (LOCK_ESCALATION = TABLE)
GO
