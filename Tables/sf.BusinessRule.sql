SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[BusinessRule] (
		[BusinessRuleSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationEntitySID]     [int] NOT NULL,
		[MessageSID]               [int] NOT NULL,
		[ColumnName]               [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BusinessRuleStatus]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[BusinessRuleXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_BusinessRule_ApplicationEntitySID_MessageSID_ColumnName]
		UNIQUE
		NONCLUSTERED
		([ApplicationEntitySID], [MessageSID], [ColumnName])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_BusinessRule_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_BusinessRule]
		PRIMARY KEY
		CLUSTERED
		([BusinessRuleSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Business Rule table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'CONSTRAINT', N'pk_BusinessRule'
GO
ALTER TABLE [sf].[BusinessRule]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_BusinessRule]
	CHECK
	([sf].[fBusinessRule#Check]([BusinessRuleSID],[ApplicationEntitySID],[MessageSID],[ColumnName],[BusinessRuleStatus],[BusinessRuleXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[BusinessRule]
CHECK CONSTRAINT [ck_BusinessRule]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_BusinessRuleStatus]
	DEFAULT ('x') FOR [BusinessRuleStatus]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[BusinessRule]
	ADD
	CONSTRAINT [df_BusinessRule_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[BusinessRule]
	WITH CHECK
	ADD CONSTRAINT [fk_BusinessRule_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[BusinessRule]
	CHECK CONSTRAINT [fk_BusinessRule_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Business Rule table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Business Rule. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Business Rule.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'CONSTRAINT', N'fk_BusinessRule_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [sf].[BusinessRule]
	WITH CHECK
	ADD CONSTRAINT [fk_BusinessRule_Message_MessageSID]
	FOREIGN KEY ([MessageSID]) REFERENCES [sf].[Message] ([MessageSID])
ALTER TABLE [sf].[BusinessRule]
	CHECK CONSTRAINT [fk_BusinessRule_Message_MessageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the message system ID column in the Business Rule table match a message system ID in the Message table. It also ensures that records in the Message table cannot be deleted if matching child records exist in Business Rule. Finally, the constraint blocks changes to the value of the message system ID column in the Message if matching child records exist in Business Rule.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'CONSTRAINT', N'fk_BusinessRule_Message_MessageSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_BusinessRule_LegacyKey]
	ON [sf].[BusinessRule] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'INDEX', N'ux_BusinessRule_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_BusinessRule_MessageSID_BusinessRuleSID]
	ON [sf].[BusinessRule] ([MessageSID], [BusinessRuleSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Message SID foreign key column and avoids row contention on (parent) Message updates', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'INDEX', N'ix_BusinessRule_MessageSID_BusinessRuleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A row is required for each business rule in the application.  The BusinessRuleStatus value indicates whether the rule is o (on), x (off), p(pending), or, !(in process).  A UI is provided to turn optional rules on or off.  Pending indicates the user has turned the rule on but it is not yet applied.  ! - indicates the process to apply the rule is underway.  Errors are reported in BusinessRuleError.  All rules are applied through f<TableName>Check functions which are bound to table constraints.  These functions apply optional rules conditionally where BusinessRuleStatus <> ''x''.  The owning table to apply the rule against is determined through the relationship to ApplicationEntity.  If the same rule is applied to multiple tables, a BusinessRule row is required for each, however, the Message text can be stored once.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the business rule assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'BusinessRuleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this business rule', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The message assigned to this business rule', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'MessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The column name the rule applies to.  Required to distinguish betweeen rules when the same message is used on multiple columns in the same table.  If a rule involves multiple columns, choose the first column involved as it appears in the UI.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'ColumnName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether rule is o-n, x-off, or p-ending (turned on but rule check not yet run on table)', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'BusinessRuleStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the business rule | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'BusinessRuleXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the business rule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this business rule record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the business rule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the business rule record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the business rule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application Entity SID + Message SID + Column Name" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'CONSTRAINT', N'uk_BusinessRule_ApplicationEntitySID_MessageSID_ColumnName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'BusinessRule', 'CONSTRAINT', N'uk_BusinessRule_RowGUID'
GO
ALTER TABLE [sf].[BusinessRule] SET (LOCK_ESCALATION = TABLE)
GO
