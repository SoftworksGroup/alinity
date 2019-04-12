SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TermLabel] (
		[TermLabelSID]               [int] IDENTITY(1000001, 1) NOT NULL,
		[TermLabelSCD]               [varchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TermLabel]                  [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UsageNotes]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TermLabelUpdateTime]        [datetimeoffset](7) NULL,
		[DefaultLabel]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DefaultLabelUpdateTime]     [datetimeoffset](7) NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[TermLabelXID]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_TermLabel_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TermLabel_TermLabelSCD]
		UNIQUE
		NONCLUSTERED
		([TermLabelSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TermLabel]
		PRIMARY KEY
		CLUSTERED
		([TermLabelSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Term Label table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'CONSTRAINT', N'pk_TermLabel'
GO
ALTER TABLE [sf].[TermLabel]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TermLabel]
	CHECK
	([sf].[fTermLabel#Check]([TermLabelSID],[TermLabelSCD],[TermLabel],[TermLabelUpdateTime],[DefaultLabel],[DefaultLabelUpdateTime],[TermLabelXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TermLabel]
CHECK CONSTRAINT [ck_TermLabel]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_DefaultLabelUpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [DefaultLabelUpdateTime]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TermLabel]
	ADD
	CONSTRAINT [df_TermLabel_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TermLabel_LegacyKey]
	ON [sf].[TermLabel] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'INDEX', N'ux_TermLabel_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Term Label is master table defining terminology labels used by views and other database objects.  For example, by default the application may refer to patient cases as “Case” and a database view might return a formatted label:  “Case #12345”.  If the client prefers the term “Encounter”, that value can be entered in this table as an override label. This results in the view returning the label as:  “Encounter #12345”.  The Default Label Term remains in place in the record and an override value is entered into the Label Term column.  The system keeps track of update times of the default and override values in order to manage product upgrades without overwriting user supplied values.  Note that these terms apply only to database objects and messages produced from the database tier of the application.  The client-tier of the application implements a similar terminology configuration method using resource files (.resx) stored on the web server.', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the term label assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'TermLabelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the term label | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'TermLabelSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'override text to apply instead of the default label shipped with the application', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'TermLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'notes on where this term is applied in the application', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the term label | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'TermLabelXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the term label | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this term label record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the term label | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the term label record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the term label record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'CONSTRAINT', N'uk_TermLabel_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Term Label SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TermLabel', 'CONSTRAINT', N'uk_TermLabel_TermLabelSCD'
GO
ALTER TABLE [sf].[TermLabel] SET (LOCK_ESCALATION = TABLE)
GO
