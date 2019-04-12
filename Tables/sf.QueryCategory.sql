SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[QueryCategory] (
		[QueryCategorySID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[QueryCategoryLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[QueryCategoryCode]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DisplayOrder]           [int] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[QueryCategoryXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_QueryCategory_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_QueryCategory_QueryCategoryLabel]
		UNIQUE
		NONCLUSTERED
		([QueryCategoryLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_QueryCategory_QueryCategoryCode]
		UNIQUE
		NONCLUSTERED
		([QueryCategoryCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_QueryCategory]
		PRIMARY KEY
		CLUSTERED
		([QueryCategorySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Query Category table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'CONSTRAINT', N'pk_QueryCategory'
GO
ALTER TABLE [sf].[QueryCategory]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_QueryCategory]
	CHECK
	([sf].[fQueryCategory#Check]([QueryCategorySID],[QueryCategoryLabel],[QueryCategoryCode],[DisplayOrder],[IsActive],[IsDefault],[QueryCategoryXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[QueryCategory]
CHECK CONSTRAINT [ck_QueryCategory]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_QueryCategoryLabel]
	DEFAULT (N'Default') FOR [QueryCategoryLabel]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_DisplayOrder]
	DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[QueryCategory]
	ADD
	CONSTRAINT [df_QueryCategory_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_QueryCategory_IsDefault]
	ON [sf].[QueryCategory] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Query Category', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'INDEX', N'ux_QueryCategory_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_QueryCategory_LegacyKey]
	ON [sf].[QueryCategory] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'INDEX', N'ux_QueryCategory_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the query category assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'QueryCategorySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the query category to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'QueryCategoryLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code to refer to the query category when positioning new queries within categories  | Codes starting with "S!" are system-required codes and cannot be changed', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'QueryCategoryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the order this category appears in on the user interface ', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'DisplayOrder'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this query category record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default query category to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the query category | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'QueryCategoryXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the query category | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this query category record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the query category | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the query category record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the query category record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Query Category Code column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'CONSTRAINT', N'uk_QueryCategory_QueryCategoryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'CONSTRAINT', N'uk_QueryCategory_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Query Category Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'QueryCategory', 'CONSTRAINT', N'uk_QueryCategory_QueryCategoryLabel'
GO
ALTER TABLE [sf].[QueryCategory] SET (LOCK_ESCALATION = TABLE)
GO
