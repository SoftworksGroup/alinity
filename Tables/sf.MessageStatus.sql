SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[MessageStatus] (
		[MessageStatusSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[MessageStatusSCD]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MessageStatusLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsClosedStatus]         [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[MessageStatusXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_MessageStatus_MessageStatusLabel]
		UNIQUE
		NONCLUSTERED
		([MessageStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MessageStatus_MessageStatusSCD]
		UNIQUE
		NONCLUSTERED
		([MessageStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MessageStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_MessageStatus]
		PRIMARY KEY
		CLUSTERED
		([MessageStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Message Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'CONSTRAINT', N'pk_MessageStatus'
GO
ALTER TABLE [sf].[MessageStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_MessageStatus]
	CHECK
	([sf].[fMessageStatus#Check]([MessageStatusSID],[MessageStatusSCD],[MessageStatusLabel],[IsClosedStatus],[IsActive],[IsDefault],[MessageStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[MessageStatus]
CHECK CONSTRAINT [ck_MessageStatus]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_IsClosedStatus]
	DEFAULT ((0)) FOR [IsClosedStatus]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[MessageStatus]
	ADD
	CONSTRAINT [df_MessageStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MessageStatus_IsDefault]
	ON [sf].[MessageStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Message Status', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'INDEX', N'ux_MessageStatus_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MessageStatus_LegacyKey]
	ON [sf].[MessageStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'INDEX', N'ux_MessageStatus_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of message statuses supported by the system (e.g. DRAFT, QUEUED, SENT, ARCHIVED). The list applies to both Email and Text (SMS) messages.  The list cannot be updated by end users or configurators (no add or delete).  Description column values like the label can be changed to support client-specific terminology and language.  The status values are used on the Email Message and Text Message entities to track basic flow from creation through sending, however, bounced record of non-received messages (if known) must be set manually. Note that the status codes are not foreign-keyed but derived in the extended entity view.', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the message status assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'MessageStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'MessageStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the message status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'MessageStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the scenarios this task status is intended to support', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates messages in this status should be considered as closed by the application (not retryable) | This value cannot be set by the end user', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this message status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default message status to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the message status | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'MessageStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the message status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this message status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the message status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the message status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the message status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Status Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'CONSTRAINT', N'uk_MessageStatus_MessageStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Status SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'CONSTRAINT', N'uk_MessageStatus_MessageStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageStatus', 'CONSTRAINT', N'uk_MessageStatus_RowGUID'
GO
ALTER TABLE [sf].[MessageStatus] SET (LOCK_ESCALATION = TABLE)
GO
