SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[BusinessRuleError] (
		[BusinessRuleErrorSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[BusinessRuleSID]          [int] NOT NULL,
		[MessageText]              [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SourceSID]                [int] NOT NULL,
		[SourceGUID]               [uniqueidentifier] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[BusinessRuleErrorXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_BusinessRuleError_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_BusinessRuleError]
		PRIMARY KEY
		CLUSTERED
		([BusinessRuleErrorSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Business Rule Error table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'CONSTRAINT', N'pk_BusinessRuleError'
GO
ALTER TABLE [sf].[BusinessRuleError]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_BusinessRuleError]
	CHECK
	([sf].[fBusinessRuleError#Check]([BusinessRuleErrorSID],[BusinessRuleSID],[MessageText],[SourceSID],[SourceGUID],[BusinessRuleErrorXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[BusinessRuleError]
CHECK CONSTRAINT [ck_BusinessRuleError]
GO
ALTER TABLE [sf].[BusinessRuleError]
	ADD
	CONSTRAINT [df_BusinessRuleError_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[BusinessRuleError]
	ADD
	CONSTRAINT [df_BusinessRuleError_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[BusinessRuleError]
	ADD
	CONSTRAINT [df_BusinessRuleError_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[BusinessRuleError]
	ADD
	CONSTRAINT [df_BusinessRuleError_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[BusinessRuleError]
	ADD
	CONSTRAINT [df_BusinessRuleError_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[BusinessRuleError]
	ADD
	CONSTRAINT [df_BusinessRuleError_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[BusinessRuleError]
	WITH CHECK
	ADD CONSTRAINT [fk_BusinessRuleError_BusinessRule_BusinessRuleSID]
	FOREIGN KEY ([BusinessRuleSID]) REFERENCES [sf].[BusinessRule] ([BusinessRuleSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[BusinessRuleError]
	CHECK CONSTRAINT [fk_BusinessRuleError_BusinessRule_BusinessRuleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the business rule system ID column in the Business Rule Error table match a business rule system ID in the Business Rule table. It also ensures that when a record in the Business Rule table is deleted, matching child records in the Business Rule Error table are deleted as well. Finally, the constraint blocks changes to the value of the business rule system ID column in the Business Rule if matching child records exist in Business Rule Error.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'CONSTRAINT', N'fk_BusinessRuleError_BusinessRule_BusinessRuleSID'
GO
CREATE NONCLUSTERED INDEX [ix_BusinessRuleError_BusinessRuleSID_BusinessRuleErrorSID]
	ON [sf].[BusinessRuleError] ([BusinessRuleSID], [BusinessRuleErrorSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Business Rule SID foreign key column and avoids row contention on (parent) Business Rule updates', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'INDEX', N'ix_BusinessRuleError_BusinessRuleSID_BusinessRuleErrorSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_BusinessRuleError_LegacyKey]
	ON [sf].[BusinessRuleError] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'INDEX', N'ux_BusinessRuleError_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records a record for each row on the table where the business rule is violated.  The table is determined through the relationship of "ApplicationEntity" on the BusinessRule parent.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the business rule error assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'BusinessRuleErrorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The business rule this error is defined for', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'BusinessRuleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the business rule error | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'BusinessRuleErrorXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the business rule error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this business rule error record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the business rule error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the business rule error record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the business rule error record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'BusinessRuleError', 'CONSTRAINT', N'uk_BusinessRuleError_RowGUID'
GO
ALTER TABLE [sf].[BusinessRuleError] SET (LOCK_ESCALATION = TABLE)
GO
