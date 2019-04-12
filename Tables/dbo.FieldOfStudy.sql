SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FieldOfStudy] (
		[FieldOfStudySID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[FieldOfStudyName]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FieldOfStudyCode]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FieldOfStudyCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                [bit] NOT NULL,
		[IsActive]                 [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[FieldOfStudyXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_FieldOfStudy_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FieldOfStudy_FieldOfStudyName]
		UNIQUE
		NONCLUSTERED
		([FieldOfStudyName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FieldOfStudy_FieldOfStudyCode]
		UNIQUE
		NONCLUSTERED
		([FieldOfStudyCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FieldOfStudy]
		PRIMARY KEY
		CLUSTERED
		([FieldOfStudySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Field Of Study table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'CONSTRAINT', N'pk_FieldOfStudy'
GO
ALTER TABLE [dbo].[FieldOfStudy]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FieldOfStudy]
	CHECK
	([dbo].[fFieldOfStudy#Check]([FieldOfStudySID],[FieldOfStudyName],[FieldOfStudyCode],[FieldOfStudyCategory],[IsDefault],[IsActive],[FieldOfStudyXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[FieldOfStudy]
CHECK CONSTRAINT [ck_FieldOfStudy]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[FieldOfStudy]
	ADD
	CONSTRAINT [df_FieldOfStudy_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FieldOfStudy_IsDefault]
	ON [dbo].[FieldOfStudy] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Field Of Study', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'INDEX', N'ux_FieldOfStudy_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Theis table is a master list of fields of study to further describe the registrant''s credential.  The value may only be relevant on qualifying credentials but is available for all credentials entered.  A default value is automatically provided where one is not set from the user interface.  The value is part of the description of a registrant''s credential (appears as foreign key on Registrant-Credential).  IThe code colum can be used to match codes which may be required for external reporting - e.g. for CIHI. ', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the field of study assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'FieldOfStudySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the field of study to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'FieldOfStudyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize the practice areas', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'FieldOfStudyCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default field of study to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this field of study record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the field of study | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'FieldOfStudyXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the field of study | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this field of study record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the field of study | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the field of study record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the field of study record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'CONSTRAINT', N'uk_FieldOfStudy_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Field Of Study Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'CONSTRAINT', N'uk_FieldOfStudy_FieldOfStudyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Field Of Study Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'FieldOfStudy', 'CONSTRAINT', N'uk_FieldOfStudy_FieldOfStudyCode'
GO
ALTER TABLE [dbo].[FieldOfStudy] SET (LOCK_ESCALATION = TABLE)
GO
