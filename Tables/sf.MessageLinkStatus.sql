SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[MessageLinkStatus] (
		[MessageLinkStatusSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[MessageLinkStatusSCD]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MessageLinkStatusLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsResendEnabled]            [bit] NOT NULL,
		[IsActive]                   [bit] NOT NULL,
		[IsDefault]                  [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[MessageLinkStatusXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_MessageLinkStatus_MessageLinkStatusLabel]
		UNIQUE
		NONCLUSTERED
		([MessageLinkStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MessageLinkStatus_MessageLinkStatusSCD]
		UNIQUE
		NONCLUSTERED
		([MessageLinkStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MessageLinkStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_MessageLinkStatus]
		PRIMARY KEY
		CLUSTERED
		([MessageLinkStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Message Link Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'CONSTRAINT', N'pk_MessageLinkStatus'
GO
ALTER TABLE [sf].[MessageLinkStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_MessageLinkStatus]
	CHECK
	([sf].[fMessageLinkStatus#Check]([MessageLinkStatusSID],[MessageLinkStatusSCD],[MessageLinkStatusLabel],[IsResendEnabled],[IsActive],[IsDefault],[MessageLinkStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[MessageLinkStatus]
CHECK CONSTRAINT [ck_MessageLinkStatus]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_IsResendEnabled]
	DEFAULT ((0)) FOR [IsResendEnabled]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[MessageLinkStatus]
	ADD
	CONSTRAINT [df_MessageLinkStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MessageLinkStatus_IsDefault]
	ON [sf].[MessageLinkStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Message Link Status', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'INDEX', N'ux_MessageLinkStatus_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MessageLinkStatus_LegacyKey]
	ON [sf].[MessageLinkStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'INDEX', N'ux_MessageLinkStatus_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to store the status of links included in emails.  Links are included for users to confirm specific actions such as an invitation to be setup with a user account on the system.  Links are set up with a duration after which they expire and can no longer be used.  This reduces the attack surface on the application.  For trials requests and invitations, users typically need to confirm these requests via a link provided in email before they are acted upon by the system.  This table  stores codes and labels for the various statuses that are derived for the link.  For example: NEW, PENDING, EXPIRED, CONFIRMED and CANCELLED are typical statuses used. The list of codes cannot be updated by end users or configurators (no add or delete) since specific application logic is branched on the code value.  Description column values like the label can be changed to support client-specific terminology and language.  See table content for complete list of supported codes. Note that tables using these statuses do not contain foreign keys into this table because the system code value is derived based on values in the record and then looked up in this table to find the matching label for display on the user interface.', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the message link status assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'MessageLinkStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message link status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'MessageLinkStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the message link status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'MessageLinkStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the scenarios this status is intended to support', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the email invitation can be resent for this status (e.g. off for "confirmed") | This value cannot be set by the end user', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'IsResendEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this message link status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default message link status to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the message link status | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'MessageLinkStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the message link status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this message link status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the message link status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the message link status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the message link status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Link Status Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'CONSTRAINT', N'uk_MessageLinkStatus_MessageLinkStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Link Status SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'CONSTRAINT', N'uk_MessageLinkStatus_MessageLinkStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageLinkStatus', 'CONSTRAINT', N'uk_MessageLinkStatus_RowGUID'
GO
ALTER TABLE [sf].[MessageLinkStatus] SET (LOCK_ESCALATION = TABLE)
GO
