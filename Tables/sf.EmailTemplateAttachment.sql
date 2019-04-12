SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[EmailTemplateAttachment] (
		[EmailTemplateAttachmentSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[EmailTemplateSID]               [int] NOT NULL,
		[DocumentTitle]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileTypeSID]                    [int] NOT NULL,
		[FileTypeSCD]                    [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DocumentContent]                [varbinary](max) NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[EmailTemplateAttachmentXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_EmailTemplateAttachment_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmailTemplateAttachment]
		PRIMARY KEY
		CLUSTERED
		([EmailTemplateAttachmentSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Email Template Attachment table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'CONSTRAINT', N'pk_EmailTemplateAttachment'
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmailTemplateAttachment]
	CHECK
	([sf].[fEmailTemplateAttachment#Check]([EmailTemplateAttachmentSID],[EmailTemplateSID],[DocumentTitle],[FileTypeSID],[FileTypeSCD],[EmailTemplateAttachmentXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
CHECK CONSTRAINT [ck_EmailTemplateAttachment]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	ADD
	CONSTRAINT [df_EmailTemplateAttachment_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	ADD
	CONSTRAINT [df_EmailTemplateAttachment_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	ADD
	CONSTRAINT [df_EmailTemplateAttachment_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	ADD
	CONSTRAINT [df_EmailTemplateAttachment_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	ADD
	CONSTRAINT [df_EmailTemplateAttachment_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	ADD
	CONSTRAINT [df_EmailTemplateAttachment_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTemplateAttachment_FileType_FileTypeSID]
	FOREIGN KEY ([FileTypeSID]) REFERENCES [sf].[FileType] ([FileTypeSID])
ALTER TABLE [sf].[EmailTemplateAttachment]
	CHECK CONSTRAINT [fk_EmailTemplateAttachment_FileType_FileTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file type system ID column in the Email Template Attachment table match a file type system ID in the File Type table. It also ensures that records in the File Type table cannot be deleted if matching child records exist in Email Template Attachment. Finally, the constraint blocks changes to the value of the file type system ID column in the File Type if matching child records exist in Email Template Attachment.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'CONSTRAINT', N'fk_EmailTemplateAttachment_FileType_FileTypeSID'
GO
ALTER TABLE [sf].[EmailTemplateAttachment]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTemplateAttachment_EmailTemplate_EmailTemplateSID]
	FOREIGN KEY ([EmailTemplateSID]) REFERENCES [sf].[EmailTemplate] ([EmailTemplateSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[EmailTemplateAttachment]
	CHECK CONSTRAINT [fk_EmailTemplateAttachment_EmailTemplate_EmailTemplateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the email template system ID column in the Email Template Attachment table match a email template system ID in the Email Template table. It also ensures that when a record in the Email Template table is deleted, matching child records in the Email Template Attachment table are deleted as well. Finally, the constraint blocks changes to the value of the email template system ID column in the Email Template if matching child records exist in Email Template Attachment.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'CONSTRAINT', N'fk_EmailTemplateAttachment_EmailTemplate_EmailTemplateSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTemplateAttachment_EmailTemplateSID_EmailTemplateAttachmentSID]
	ON [sf].[EmailTemplateAttachment] ([EmailTemplateSID], [EmailTemplateAttachmentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Email Template SID foreign key column and avoids row contention on (parent) Email Template updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'INDEX', N'ix_EmailTemplateAttachment_EmailTemplateSID_EmailTemplateAttachmentSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTemplateAttachment_FileTypeSID_EmailTemplateAttachmentSID]
	ON [sf].[EmailTemplateAttachment] ([FileTypeSID], [EmailTemplateAttachmentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Type SID foreign key column and avoids row contention on (parent) File Type updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'INDEX', N'ix_EmailTemplateAttachment_FileTypeSID_EmailTemplateAttachmentSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmailTemplateAttachment_LegacyKey]
	ON [sf].[EmailTemplateAttachment] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'INDEX', N'ux_EmailTemplateAttachment_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Email messages may be sent with attached files.  This table stores the content of those files.  Note that the file may be uploaded from disk or copied from another document-type table in the system.  Documents already in another document table are copied into this record in order to ensure their content can be audited in the event the record containing the original document is deleted.  Only file types supported by the application, as defined in the File Type table, can be attached.  The email attachment table stores both the File Type SID value to support the Entity Framework but the File Type SCD (system code) value must also be stored, although redundant, in order to support full-text-searching of email.  The full-text-search option works much the same way as searching in Gmail or web-based Outlook.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email template attachment assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'EmailTemplateAttachmentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email template this attachment is defined for', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name or title of the document to show in the user interface (defaults to the file name uploaded)', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'DocumentTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of email template attachment', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".pdf" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The content of the document in native format (e.g. an Adobe PDF "binary")', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'DocumentContent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email template attachment | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'EmailTemplateAttachmentXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email template attachment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email template attachment record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email template attachment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email template attachment record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email template attachment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplateAttachment', 'CONSTRAINT', N'uk_EmailTemplateAttachment_RowGUID'
GO
ALTER TABLE [sf].[EmailTemplateAttachment] SET (LOCK_ESCALATION = TABLE)
GO
