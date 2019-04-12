SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ContentTemplate] (
		[ContentTemplateSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[ContentTemplateSCD]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ContentTemplateLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ContentTemplateData]      [xml] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[ContentTemplateXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_ContentTemplate_ContentTemplateLabel]
		UNIQUE
		NONCLUSTERED
		([ContentTemplateLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ContentTemplate_ContentTemplateSCD]
		UNIQUE
		NONCLUSTERED
		([ContentTemplateSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ContentTemplate_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ContentTemplate]
		PRIMARY KEY
		CLUSTERED
		([ContentTemplateSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Content Template table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'CONSTRAINT', N'pk_ContentTemplate'
GO
ALTER TABLE [dbo].[ContentTemplate]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ContentTemplate]
	CHECK
	([dbo].[fContentTemplate#Check]([ContentTemplateSID],[ContentTemplateSCD],[ContentTemplateLabel],[ContentTemplateXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ContentTemplate]
CHECK CONSTRAINT [ck_ContentTemplate]
GO
ALTER TABLE [dbo].[ContentTemplate]
	ADD
	CONSTRAINT [df_ContentTemplate_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ContentTemplate]
	ADD
	CONSTRAINT [df_ContentTemplate_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ContentTemplate]
	ADD
	CONSTRAINT [df_ContentTemplate_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ContentTemplate]
	ADD
	CONSTRAINT [df_ContentTemplate_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ContentTemplate]
	ADD
	CONSTRAINT [df_ContentTemplate_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ContentTemplate]
	ADD
	CONSTRAINT [df_ContentTemplate_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ContentTemplate_LegacyKey]
	ON [dbo].[ContentTemplate] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'INDEX', N'ux_ContentTemplate_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is intended to store XML templates that provide limited customizability of screens in the web application. The column storing the screen configuration is ContentTemplateData. The first implementation of this table will only store on/off states for different UI components on the public register component of Alinity. We may provide future extensibility to the end-user in the form of user definable style sheets. Note that the name of this table is ContentTemplate -- if the user wants to make any change to a screen controlled by one of our templates, they will need to copy the XML configuration and modify as necessary.

Related records should be grouped by using a commong prefix on the ContentTemplateSCD and delimited with the unique identifier by a period (ie: "PUBLIC_REGISTER_CARD.MINIMAL", "PUBLIC_REGISTER_CARD.FULL", etc). Note that values in the ContentTemplateLabel column must be unique across the entire table.', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the content template assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'ContentTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the content template | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'ContentTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the content template to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'ContentTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the content template | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'ContentTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the content template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this content template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the content template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the content template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the content template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Content Template Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'CONSTRAINT', N'uk_ContentTemplate_ContentTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Content Template SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'CONSTRAINT', N'uk_ContentTemplate_ContentTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'CONSTRAINT', N'uk_ContentTemplate_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ContentTemplate_ContentTemplateData]
	ON [dbo].[ContentTemplate] ([ContentTemplateData])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Content Template Data (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'ContentTemplate', 'INDEX', N'xp_ContentTemplate_ContentTemplateData'
GO
ALTER TABLE [dbo].[ContentTemplate] SET (LOCK_ESCALATION = TABLE)
GO
