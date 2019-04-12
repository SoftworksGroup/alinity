SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonDoc] (
		[PersonDocSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                [int] NOT NULL,
		[PersonDocTypeSID]         [int] NOT NULL,
		[DocumentTitle]            [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AdditionalInfo]           [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DocumentContent]          [varbinary](max) FILESTREAM NULL,
		[DocumentHTML]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ArchivedTime]             [datetimeoffset](7) NULL,
		[FileTypeSID]              [int] NOT NULL,
		[FileTypeSCD]              [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TagList]                  [xml] NOT NULL,
		[DocumentNotes]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ShowToRegistrant]         [bit] NOT NULL,
		[ApplicationGrantSID]      [int] NULL,
		[IsRemoved]                [bit] NOT NULL,
		[ExpiryDate]               [date] NULL,
		[ApplicationReportSID]     [int] NULL,
		[ReportEntitySID]          [int] NULL,
		[CancelledTime]            [datetimeoffset](7) NULL,
		[ProcessedTime]            [datetimeoffset](7) NULL,
		[ContextLink]              [uniqueidentifier] NULL,
		[UserDefinedColumns]       [xml] NULL,
		[PersonDocXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonDoc_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonDoc_DocumentTitle_PersonSID]
		UNIQUE
		NONCLUSTERED
		([DocumentTitle], [PersonSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonDoc]
		PRIMARY KEY
		CLUSTERED
		([PersonDocSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Doc table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'pk_PersonDoc'
GO
ALTER TABLE [dbo].[PersonDoc]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonDoc]
	CHECK
	([dbo].[fPersonDoc#Check]([PersonDocSID],[PersonSID],[PersonDocTypeSID],[DocumentTitle],[AdditionalInfo],[ArchivedTime],[FileTypeSID],[FileTypeSCD],[ShowToRegistrant],[ApplicationGrantSID],[IsRemoved],[ExpiryDate],[ApplicationReportSID],[ReportEntitySID],[CancelledTime],[ProcessedTime],[ContextLink],[PersonDocXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonDoc]
CHECK CONSTRAINT [ck_PersonDoc]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_TagList]
	DEFAULT (CONVERT([xml],N'<TagList/>',(0))) FOR [TagList]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_ShowToRegistrant]
	DEFAULT (CONVERT([bit],(0))) FOR [ShowToRegistrant]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_IsRemoved]
	DEFAULT (CONVERT([bit],(0))) FOR [IsRemoved]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonDoc]
	ADD
	CONSTRAINT [df_PersonDoc_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PersonDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDoc_PersonDocType_PersonDocTypeSID]
	FOREIGN KEY ([PersonDocTypeSID]) REFERENCES [dbo].[PersonDocType] ([PersonDocTypeSID])
ALTER TABLE [dbo].[PersonDoc]
	CHECK CONSTRAINT [fk_PersonDoc_PersonDocType_PersonDocTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person doc type system ID column in the Person Doc table match a person doc type system ID in the Person Doc Type table. It also ensures that records in the Person Doc Type table cannot be deleted if matching child records exist in Person Doc. Finally, the constraint blocks changes to the value of the person doc type system ID column in the Person Doc Type if matching child records exist in Person Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'fk_PersonDoc_PersonDocType_PersonDocTypeSID'
GO
ALTER TABLE [dbo].[PersonDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDoc_SF_ApplicationReport_ApplicationReportSID]
	FOREIGN KEY ([ApplicationReportSID]) REFERENCES [sf].[ApplicationReport] ([ApplicationReportSID])
ALTER TABLE [dbo].[PersonDoc]
	CHECK CONSTRAINT [fk_PersonDoc_SF_ApplicationReport_ApplicationReportSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application report system ID column in the Person Doc table match a application report system ID in the Application Report table. It also ensures that records in the Application Report table cannot be deleted if matching child records exist in Person Doc. Finally, the constraint blocks changes to the value of the application report system ID column in the Application Report if matching child records exist in Person Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'fk_PersonDoc_SF_ApplicationReport_ApplicationReportSID'
GO
ALTER TABLE [dbo].[PersonDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDoc_SF_FileType_FileTypeSID]
	FOREIGN KEY ([FileTypeSID]) REFERENCES [sf].[FileType] ([FileTypeSID])
ALTER TABLE [dbo].[PersonDoc]
	CHECK CONSTRAINT [fk_PersonDoc_SF_FileType_FileTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file type system ID column in the Person Doc table match a file type system ID in the File Type table. It also ensures that records in the File Type table cannot be deleted if matching child records exist in Person Doc. Finally, the constraint blocks changes to the value of the file type system ID column in the File Type if matching child records exist in Person Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'fk_PersonDoc_SF_FileType_FileTypeSID'
GO
ALTER TABLE [dbo].[PersonDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDoc_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[PersonDoc]
	CHECK CONSTRAINT [fk_PersonDoc_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Doc table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Doc. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'fk_PersonDoc_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[PersonDoc]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonDoc_SF_ApplicationGrant_ApplicationGrantSID]
	FOREIGN KEY ([ApplicationGrantSID]) REFERENCES [sf].[ApplicationGrant] ([ApplicationGrantSID])
ALTER TABLE [dbo].[PersonDoc]
	CHECK CONSTRAINT [fk_PersonDoc_SF_ApplicationGrant_ApplicationGrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application grant system ID column in the Person Doc table match a application grant system ID in the Application Grant table. It also ensures that records in the Application Grant table cannot be deleted if matching child records exist in Person Doc. Finally, the constraint blocks changes to the value of the application grant system ID column in the Application Grant if matching child records exist in Person Doc.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'fk_PersonDoc_SF_ApplicationGrant_ApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_ApplicationGrantSID_PersonDocSID]
	ON [dbo].[PersonDoc] ([ApplicationGrantSID], [PersonDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Grant SID foreign key column and avoids row contention on (parent) Application Grant updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_ApplicationGrantSID_PersonDocSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_ApplicationReportSID_PersonDocSID]
	ON [dbo].[PersonDoc] ([ApplicationReportSID], [PersonDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Report SID foreign key column and avoids row contention on (parent) Application Report updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_ApplicationReportSID_PersonDocSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_CancelledTime_ProcessedTime_ApplicationReportSID]
	ON [dbo].[PersonDoc] ([CancelledTime], [ProcessedTime], [ApplicationReportSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Doc searches based on the Cancelled Time + Processed Time + Application Report SID columns', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_CancelledTime_ProcessedTime_ApplicationReportSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_ContextLink]
	ON [dbo].[PersonDoc] ([ContextLink])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Doc searches based on the Context Link column', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_ContextLink'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_FileTypeSID_PersonDocSID]
	ON [dbo].[PersonDoc] ([FileTypeSID], [PersonDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Type SID foreign key column and avoids row contention on (parent) File Type updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_FileTypeSID_PersonDocSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_PersonDocTypeSID_PersonDocSID]
	ON [dbo].[PersonDoc] ([PersonDocTypeSID], [PersonDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Doc Type SID foreign key column and avoids row contention on (parent) Person Doc Type updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_PersonDocTypeSID_PersonDocSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_PersonSID_PersonDocSID]
	ON [dbo].[PersonDoc] ([PersonSID], [PersonDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_PersonSID_PersonDocSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonDoc_ReportEntitySID_PersonDocSID]
	ON [dbo].[PersonDoc] ([ReportEntitySID], [PersonDocSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Doc searches based on the Report Entity SID + Person Doc SID columns', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ix_PersonDoc_ReportEntitySID_PersonDocSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonDoc_LegacyKey]
	ON [dbo].[PersonDoc] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'ux_PersonDoc_LegacyKey'
GO
CREATE FULLTEXT INDEX ON [dbo].[PersonDoc]
	([DocumentTitle] LANGUAGE 0, [DocumentContent] TYPE COLUMN [FileTypeSCD] LANGUAGE 0)
	KEY INDEX [pk_PersonDoc]
	ON (FILEGROUP [ApplicationRowData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST SYSTEM
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores documents associated with people who may be ContactRegistrants, Contacts or other stakeholders.  Documents associated with organizations or groups are not stored here.  Documents are uploaded through the application and stored as part of the person’s profile record.  Documents are categorized according to their context records which result in separation of documents into display folders. For example, an uploaded document like a Criminal Record Check may be associated with both a registration application and a conduct case.  The document is only stored once and then associated with multiple uses.  It is possible to indicate that the document is “view restricted”.  This means it will not appear on the person’s general profile screen but only for assigned uses.  This is typically the default setting for documents uploaded for conduct investigations which may not be appropriate to show to all administrative staff – only those assigned to that case.  To control the volume of documents managed for each person, you can set an archived date which removes the document from the default display, however it remains searchable and can be returned to active status whenever required.  You can also set an expiry on documents which must be replaced or renewed – for example a criminal record check may only be valid for 5 years so expires. In some cases, the document may be the result of running a report.  In that scenario the Document-Content is initially blank (null) and the Application-Report-SID value is filled out along with the Entity-SID which is passed to the report to generate the content.  A service runs the report and stores the output as a PDF document into the Report-Content column.  If report generation is to be cancelled, then the Cancelled Time value is filled out; otherwise the Processed Time is set when the report is selected for processing.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person doc assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this doc is based on', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person doc', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'PersonDocTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name or title of the document | This value is assigned automatically for system generated documents but is provided by the user for support documents (default image names often appear here).', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'DocumentTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stores the name of the requirement or the form-field for which this document was provided | This value is combined with the document type to describe the document on the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'AdditionalInfo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the application to temporarily store the format of documents as HTML for conversion to PDF by a background service| After HTML content is saved as PDF it is removed (set to null) in this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'DocumentHTML'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the document was put into archived status', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person doc', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".pdf" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of tags used to classify the document and to support filtering and searching', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'TagList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A brief description or abstract of the document that informs the user about the content without them having to open it', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'DocumentNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this document should be shown to the registrant it is related to on the client portal.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ShowToRegistrant'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether content of the document was removed by admin (e.g. to protect privacy)', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'IsRemoved'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the document is no longer valid in meeting a licensing requirement (e.g. a new criminal record check may be required every 5 years) | This value is entered by the user so reflects their timezone', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ExpiryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The report assigned to this person doc', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ApplicationReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only applies when a document is generated from a report - provides key of the record to base the report on.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ReportEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the report to produce the document was cancelled (not generated) after being inserted but before being processed (the record can be deleted).', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the report was generated and stored as document-content - appliesonly  when report key is identified.  | When this value is filled out and report-SID is filled out indicates report generation is no longer pending', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier used internally by the application to link the document to a source record (a context) to be inserted only after the document is inserted.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'ContextLink'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person doc | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'PersonDocXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person doc | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person doc record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person doc | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person doc record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'uk_PersonDoc_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Document Title + Person SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'CONSTRAINT', N'uk_PersonDoc_DocumentTitle_PersonSID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_PersonDoc_TagList]
	ON [dbo].[PersonDoc] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'PersonDoc', 'INDEX', N'xp_PersonDoc_TagList'
GO
ALTER TABLE [dbo].[PersonDoc] SET (LOCK_ESCALATION = TABLE)
GO
