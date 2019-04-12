SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CompetenceType] (
		[CompetenceTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[CompetenceTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CompetenceTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[HelpPrompt]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                  [bit] NOT NULL,
		[IsActive]                   [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[CompetenceTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_CompetenceType_CompetenceTypeLabel]
		UNIQUE
		NONCLUSTERED
		([CompetenceTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CompetenceType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CompetenceType]
		PRIMARY KEY
		CLUSTERED
		([CompetenceTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Competence Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'CONSTRAINT', N'pk_CompetenceType'
GO
ALTER TABLE [dbo].[CompetenceType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CompetenceType]
	CHECK
	([dbo].[fCompetenceType#Check]([CompetenceTypeSID],[CompetenceTypeLabel],[CompetenceTypeCategory],[IsDefault],[IsActive],[CompetenceTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CompetenceType]
CHECK CONSTRAINT [ck_CompetenceType]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CompetenceType]
	ADD
	CONSTRAINT [df_CompetenceType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_CompetenceType_IsDefault]
	ON [dbo].[CompetenceType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Competence Type', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'INDEX', N'ux_CompetenceType_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_CompetenceType_LegacyKey]
	ON [dbo].[CompetenceType] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'INDEX', N'ux_CompetenceType_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Credential Type table is used for categorizing or grouping credentials for reporting or business rule handling. The categories can be based on any criteria chosen.  For example, some types based on the designation granted by educational organizations might include: "Diploma", "Degree", "Post Graduate Degree", "Certificate".  ', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'CompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the competence type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'CompetenceTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'CompetenceTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Help text to display to the end user explaining this Competence Type (may be referred to as a "Practice Standard" or "Competence Band".  HTML formatting is supported.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'HelpPrompt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default competence type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this competence type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the competence type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'CompetenceTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the competence type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this competence type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the competence type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the competence type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the competence type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Competence Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'CONSTRAINT', N'uk_CompetenceType_CompetenceTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceType', 'CONSTRAINT', N'uk_CompetenceType_RowGUID'
GO
ALTER TABLE [dbo].[CompetenceType] SET (LOCK_ESCALATION = TABLE)
GO
