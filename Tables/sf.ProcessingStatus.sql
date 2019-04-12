SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ProcessingStatus] (
		[ProcessingStatusSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[ProcessingStatusSCD]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ProcessingStatusLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]                [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsClosedStatus]            [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[IsDefault]                 [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[ProcessingStatusXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_ProcessingStatus_ProcessingStatusLabel]
		UNIQUE
		NONCLUSTERED
		([ProcessingStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ProcessingStatus_ProcessingStatusSCD]
		UNIQUE
		NONCLUSTERED
		([ProcessingStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ProcessingStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ProcessingStatus]
		PRIMARY KEY
		CLUSTERED
		([ProcessingStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Processing Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'CONSTRAINT', N'pk_ProcessingStatus'
GO
ALTER TABLE [sf].[ProcessingStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ProcessingStatus]
	CHECK
	([sf].[fProcessingStatus#Check]([ProcessingStatusSID],[ProcessingStatusSCD],[ProcessingStatusLabel],[IsClosedStatus],[IsActive],[IsDefault],[ProcessingStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ProcessingStatus]
CHECK CONSTRAINT [ck_ProcessingStatus]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_IsClosedStatus]
	DEFAULT ((0)) FOR [IsClosedStatus]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ProcessingStatus]
	ADD
	CONSTRAINT [df_ProcessingStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ProcessingStatus_IsDefault]
	ON [sf].[ProcessingStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Processing Status', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'INDEX', N'ux_ProcessingStatus_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ProcessingStatus_LegacyKey]
	ON [sf].[ProcessingStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'INDEX', N'ux_ProcessingStatus_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to store the status of draft records that are then applied to the main tables in the application.  Typical example of draft records include requests for trials, invites for new application users, and various types of imports.   For trials requests and invitations, users typically need to confirm these requests via a link provided in email before they are acted upon by the system.  For import records, the data is typically stored in the staging (stg) schema and then validated prior to processing into the main tables of the application.  This table then, records the status of the draft/staging records using system codes like: NEW, HELD, PROCESSED, ERROR, WARNING, etc. The list of codes cannot be updated by end users or configurators (no add or delete) since specific application logic is branched on the code value.  Description column values like the label can be changed to support client-specific terminology and language.  See table content for complete list of supported codes.', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the processing status assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the processing status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'ProcessingStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the processing status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'ProcessingStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the scenarios this status is intended to support', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates records in this status should be considered as closed by the application (not retryable) | This value cannot be set by the end user', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this processing status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default processing status to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the processing status | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'ProcessingStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the processing status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this processing status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the processing status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the processing status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the processing status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Processing Status Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'CONSTRAINT', N'uk_ProcessingStatus_ProcessingStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Processing Status SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'CONSTRAINT', N'uk_ProcessingStatus_ProcessingStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ProcessingStatus', 'CONSTRAINT', N'uk_ProcessingStatus_RowGUID'
GO
ALTER TABLE [sf].[ProcessingStatus] SET (LOCK_ESCALATION = TABLE)
GO
