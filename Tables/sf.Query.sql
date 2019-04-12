SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Query] (
		[QuerySID]                     [int] IDENTITY(1000001, 1) NOT NULL,
		[QueryCategorySID]             [int] NOT NULL,
		[ApplicationPageSID]           [int] NOT NULL,
		[QueryLabel]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ToolTip]                      [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastExecuteTime]              [datetimeoffset](7) NOT NULL,
		[LastExecuteUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExecuteCount]                 [int] NOT NULL,
		[QuerySQL]                     [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QueryParameters]              [xml] NULL,
		[QueryCode]                    [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]                     [bit] NOT NULL,
		[IsApplicationPageDefault]     [bit] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[QueryXID]                     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_Query_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Query_QueryLabel_ApplicationPageSID]
		UNIQUE
		NONCLUSTERED
		([QueryLabel], [ApplicationPageSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Query_QueryCode]
		UNIQUE
		NONCLUSTERED
		([QueryCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Query]
		PRIMARY KEY
		CLUSTERED
		([QuerySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Query table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Query', 'CONSTRAINT', N'pk_Query'
GO
ALTER TABLE [sf].[Query]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Query]
	CHECK
	([sf].[fQuery#Check]([QuerySID],[QueryCategorySID],[ApplicationPageSID],[QueryLabel],[ToolTip],[LastExecuteTime],[LastExecuteUser],[ExecuteCount],[QueryCode],[IsActive],[IsApplicationPageDefault],[QueryXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Query]
CHECK CONSTRAINT [ck_Query]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_LastExecuteTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastExecuteTime]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_LastExecuteUser]
	DEFAULT (suser_sname()) FOR [LastExecuteUser]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_ExecuteCount]
	DEFAULT ((0)) FOR [ExecuteCount]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_QueryCode]
	DEFAULT ('[None]') FOR [QueryCode]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_IsApplicationPageDefault]
	DEFAULT ((0)) FOR [IsApplicationPageDefault]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Query]
	ADD
	CONSTRAINT [df_Query_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[Query]
	WITH CHECK
	ADD CONSTRAINT [fk_Query_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
ALTER TABLE [sf].[Query]
	CHECK CONSTRAINT [fk_Query_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Query table match a application page system ID in the Application Page table. It also ensures that records in the Application Page table cannot be deleted if matching child records exist in Query. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Query.', 'SCHEMA', N'sf', 'TABLE', N'Query', 'CONSTRAINT', N'fk_Query_ApplicationPage_ApplicationPageSID'
GO
ALTER TABLE [sf].[Query]
	WITH CHECK
	ADD CONSTRAINT [fk_Query_QueryCategory_QueryCategorySID]
	FOREIGN KEY ([QueryCategorySID]) REFERENCES [sf].[QueryCategory] ([QueryCategorySID])
ALTER TABLE [sf].[Query]
	CHECK CONSTRAINT [fk_Query_QueryCategory_QueryCategorySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the query category system ID column in the Query table match a query category system ID in the Query Category table. It also ensures that records in the Query Category table cannot be deleted if matching child records exist in Query. Finally, the constraint blocks changes to the value of the query category system ID column in the Query Category if matching child records exist in Query.', 'SCHEMA', N'sf', 'TABLE', N'Query', 'CONSTRAINT', N'fk_Query_QueryCategory_QueryCategorySID'
GO
CREATE NONCLUSTERED INDEX [ix_Query_ApplicationPageSID_QuerySID]
	ON [sf].[Query] ([ApplicationPageSID], [QuerySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'Query', 'INDEX', N'ix_Query_ApplicationPageSID_QuerySID'
GO
CREATE NONCLUSTERED INDEX [ix_Query_QueryCategorySID_QuerySID]
	ON [sf].[Query] ([QueryCategorySID], [QuerySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Query Category SID foreign key column and avoids row contention on (parent) Query Category updates', 'SCHEMA', N'sf', 'TABLE', N'Query', 'INDEX', N'ix_Query_QueryCategorySID_QuerySID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Query_ApplicationPageSID_IsApplicationPageDefault]
	ON [sf].[Query] ([ApplicationPageSID], [IsApplicationPageDefault])
	WHERE (([IsApplicationPageDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application Page SID + Is Application Page Default" columns is not duplicated where the condition: "([IsApplicationPageDefault]=(1))" is met', 'SCHEMA', N'sf', 'TABLE', N'Query', 'INDEX', N'ux_Query_ApplicationPageSID_IsApplicationPageDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Query_LegacyKey]
	ON [sf].[Query] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Query', 'INDEX', N'ux_Query_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table supports standard product queries and custom queries in the application.    The query syntax is defined as SQL in the Query SQL column.  That syntax MUST return the primary key value (only) for the entity records to be retrieved. This value is joined to the rest of the entity by query management functions within the application.  The relationship from the Query to the Application Entity is defined through the Query Category.  Query categories are used to classify large numbers of queries into groups on the user interface.  If this is not required, use the Query Category defined as "IsDefault" to avoid group labels.', 'SCHEMA', N'sf', 'TABLE', N'Query', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the query assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query category assigned to this query', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QueryCategorySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the query to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QueryLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A short help prompt explaining the purpose of the query to the end user when they mouse over the query label', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this query was last used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'LastExecuteTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identity of the user who last used this query | This value can be helpful in investigating queries which are not being used to ensure they are removed from the system', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'LastExecuteUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this query has been used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'ExecuteCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SQL syntax defining the selection of records for the query | Completing queries requires knowledge of SQL commands and the application database structure.', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QuerySQL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML structure used to store parameter names, data types, and other information needed to prompt the user for selection criteria to apply in the query | Query names must match values in the query SQL for replacement - e.g. "@MyParameter"', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QueryParameters'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value defining the location of the query in the execution procedure | Prefix is "S!" for system/product queries.', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QueryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this query record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default search for the menu option | This query is executed as the default search if the end-user has not saved their own default query', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'IsApplicationPageDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the query | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'QueryXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the query | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this query record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the query | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the query record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the query record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Query', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Query Code column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Query', 'CONSTRAINT', N'uk_Query_QueryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Query', 'CONSTRAINT', N'uk_Query_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Query Label + Application Page SID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Query', 'CONSTRAINT', N'uk_Query_QueryLabel_ApplicationPageSID'
GO
ALTER TABLE [sf].[Query] SET (LOCK_ESCALATION = TABLE)
GO
