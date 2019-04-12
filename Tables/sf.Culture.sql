SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Culture] (
		[CultureSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[CultureSCD]             [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CultureLabel]           [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[CultureXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Culture_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Culture_CultureSCD]
		UNIQUE
		NONCLUSTERED
		([CultureSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Culture_CultureLabel]
		UNIQUE
		NONCLUSTERED
		([CultureLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Culture]
		PRIMARY KEY
		CLUSTERED
		([CultureSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Culture table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'CONSTRAINT', N'pk_Culture'
GO
ALTER TABLE [sf].[Culture]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Culture]
	CHECK
	([sf].[fCulture#Check]([CultureSID],[CultureSCD],[CultureLabel],[IsDefault],[IsActive],[CultureXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Culture]
CHECK CONSTRAINT [ck_Culture]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Culture]
	ADD
	CONSTRAINT [df_Culture_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Culture_IsDefault]
	ON [sf].[Culture] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Culture', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'INDEX', N'ux_Culture_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table contains list of languages which may be supported by the application through customization.  The application is provided in English only but through the use of resource files by user-interface components, and use of the “Alt-Language” table in the database structure, labels and messages appearing to end users can match their preferred language.  The preferred language is represented by the first 2-characters of the Culture SCD (system code) column in this table.   Note that “en-CA” must remain as the default culture in the current version of the framework.  If no customization has been done to support additional languages, then the Is-Active column on all other records in the table must be set OFF (0). ', 'SCHEMA', N'sf', 'TABLE', N'Culture', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the culture assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the culture | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'CultureSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the culture to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'CultureLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default culture to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this culture record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the culture | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'CultureXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the culture | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this culture record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the culture | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the culture record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the culture record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'CONSTRAINT', N'uk_Culture_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Culture SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'CONSTRAINT', N'uk_Culture_CultureSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Culture Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Culture', 'CONSTRAINT', N'uk_Culture_CultureLabel'
GO
ALTER TABLE [sf].[Culture] SET (LOCK_ESCALATION = TABLE)
GO
