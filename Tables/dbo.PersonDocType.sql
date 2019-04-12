SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonDocType] (
		[PersonDocTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonDocTypeSCD]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PersonDocTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PersonDocTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                 [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[PersonDocTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonDocType_PersonDocTypeLabel]
		UNIQUE
		NONCLUSTERED
		([PersonDocTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonDocType_PersonDocTypeSCD]
		UNIQUE
		NONCLUSTERED
		([PersonDocTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonDocType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonDocType]
		PRIMARY KEY
		CLUSTERED
		([PersonDocTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Doc Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'CONSTRAINT', N'pk_PersonDocType'
GO
ALTER TABLE [dbo].[PersonDocType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonDocType]
	CHECK
	([dbo].[fPersonDocType#Check]([PersonDocTypeSID],[PersonDocTypeSCD],[PersonDocTypeLabel],[PersonDocTypeCategory],[IsDefault],[IsActive],[PersonDocTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PersonDocType]
CHECK CONSTRAINT [ck_PersonDocType]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PersonDocType]
	ADD
	CONSTRAINT [df_PersonDocType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonDocType_IsDefault]
	ON [dbo].[PersonDocType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Person Doc Type', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'INDEX', N'ux_PersonDocType_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonDocType_LegacyKey]
	ON [dbo].[PersonDocType] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'INDEX', N'ux_PersonDocType_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to classify documents imported or generated by the system. The types of documents are set by the product as various business rules or actions can be configured based on the type of document uploaded.  For example, a “Marks Transcript” may always require administrator review to be accepted while a “Renewal Form” which is generated by the system has already been approved by the time the PDF version of it is stored.  If you require a type of document you did not see listed, please advise the Help Desk and we will ensure it gets added.  In the interim you can use the “Other” document category.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Person Doc Type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'PersonDocTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the person doc type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'PersonDocTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the Person Doc Type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'PersonDocTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'PersonDocTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default Person Doc Type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this Person Doc Type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the Person Doc Type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'PersonDocTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the Person Doc Type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this Person Doc Type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the Person Doc Type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the Person Doc Type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the Person Doc Type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Person Doc Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'CONSTRAINT', N'uk_PersonDocType_PersonDocTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Person Doc Type SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'CONSTRAINT', N'uk_PersonDocType_PersonDocTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PersonDocType', 'CONSTRAINT', N'uk_PersonDocType_RowGUID'
GO
ALTER TABLE [dbo].[PersonDocType] SET (LOCK_ESCALATION = TABLE)
GO
