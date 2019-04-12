SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Message] (
		[MessageSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[MessageSCD]                [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MessageName]               [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MessageText]               [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MessageTextUpdateTime]     [datetimeoffset](7) NULL,
		[DefaultText]               [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DefaultTextUpdateTime]     [datetimeoffset](7) NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[MessageXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_Message_MessageName]
		UNIQUE
		NONCLUSTERED
		([MessageName])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Message_MessageSCD]
		UNIQUE
		NONCLUSTERED
		([MessageSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Message_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Message]
		PRIMARY KEY
		CLUSTERED
		([MessageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Message table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Message', 'CONSTRAINT', N'pk_Message'
GO
ALTER TABLE [sf].[Message]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Message]
	CHECK
	([sf].[fMessage#Check]([MessageSID],[MessageSCD],[MessageName],[MessageText],[MessageTextUpdateTime],[DefaultText],[DefaultTextUpdateTime],[MessageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Message]
CHECK CONSTRAINT [ck_Message]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_DefaultTextUpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [DefaultTextUpdateTime]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Message]
	ADD
	CONSTRAINT [df_Message_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Message_LegacyKey]
	ON [sf].[Message] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Message', 'INDEX', N'ux_Message_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stores the messages used for display on the user interface.   Messages are typically defined in source code using calls to the sf.pMessage#Get procedure.  The table stores default text in English as provided by the developer or as modified in product upgrades.  Time columns on the table allow the default text to be updated during development through changes to values passed to sf.pMessage#Get.  The default text can be overriden in client configurations for other languages or for client-specfic terminology using the "MessageText" column.  That column is returned instead of DefaultText whenever it has content.  A UI is provided for client-specific customizations to the MessageText column. See also pMessage#Get.', 'SCHEMA', N'sf', 'TABLE', N'Message', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'MessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'MessageSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the message to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'MessageName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the message | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'MessageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this message record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the message record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Message', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Message', 'CONSTRAINT', N'uk_Message_MessageName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Message', 'CONSTRAINT', N'uk_Message_MessageSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Message', 'CONSTRAINT', N'uk_Message_RowGUID'
GO
ALTER TABLE [sf].[Message] SET (LOCK_ESCALATION = TABLE)
GO
