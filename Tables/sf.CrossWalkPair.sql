SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[CrossWalkPair] (
		[CrossWalkPairSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[CrossWalkSID]           [int] NOT NULL,
		[SourceValue]            [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TargetValue]            [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[CrossWalkPairXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_CrossWalkPair_CrossWalkSID_SourceValue_TargetValue]
		UNIQUE
		NONCLUSTERED
		([CrossWalkSID], [SourceValue], [TargetValue])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CrossWalkPair_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CrossWalkPair]
		PRIMARY KEY
		CLUSTERED
		([CrossWalkPairSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Cross Walk Pair table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'CONSTRAINT', N'pk_CrossWalkPair'
GO
ALTER TABLE [sf].[CrossWalkPair]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CrossWalkPair]
	CHECK
	([sf].[fCrossWalkPair#Check]([CrossWalkPairSID],[CrossWalkSID],[SourceValue],[TargetValue],[CrossWalkPairXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[CrossWalkPair]
CHECK CONSTRAINT [ck_CrossWalkPair]
GO
ALTER TABLE [sf].[CrossWalkPair]
	ADD
	CONSTRAINT [df_CrossWalkPair_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[CrossWalkPair]
	ADD
	CONSTRAINT [df_CrossWalkPair_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[CrossWalkPair]
	ADD
	CONSTRAINT [df_CrossWalkPair_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[CrossWalkPair]
	ADD
	CONSTRAINT [df_CrossWalkPair_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[CrossWalkPair]
	ADD
	CONSTRAINT [df_CrossWalkPair_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[CrossWalkPair]
	ADD
	CONSTRAINT [df_CrossWalkPair_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[CrossWalkPair]
	WITH CHECK
	ADD CONSTRAINT [fk_CrossWalkPair_CrossWalk_CrossWalkSID]
	FOREIGN KEY ([CrossWalkSID]) REFERENCES [sf].[CrossWalk] ([CrossWalkSID])
ALTER TABLE [sf].[CrossWalkPair]
	CHECK CONSTRAINT [fk_CrossWalkPair_CrossWalk_CrossWalkSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the cross walk system ID column in the Cross Walk Pair table match a cross walk system ID in the Cross Walk table. It also ensures that records in the Cross Walk table cannot be deleted if matching child records exist in Cross Walk Pair. Finally, the constraint blocks changes to the value of the cross walk system ID column in the Cross Walk if matching child records exist in Cross Walk Pair.', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'CONSTRAINT', N'fk_CrossWalkPair_CrossWalk_CrossWalkSID'
GO
CREATE NONCLUSTERED INDEX [ix_CrossWalkPair_CrossWalkSID_CrossWalkPairSID]
	ON [sf].[CrossWalkPair] ([CrossWalkSID], [CrossWalkPairSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Cross Walk SID foreign key column and avoids row contention on (parent) Cross Walk updates', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'INDEX', N'ix_CrossWalkPair_CrossWalkSID_CrossWalkPairSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_CrossWalkPair_LegacyKey]
	ON [sf].[CrossWalkPair] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'INDEX', N'ux_CrossWalkPair_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the cross walk pair assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'CrossWalkPairSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The cross walk this pair is defined for', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'CrossWalkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the cross walk pair | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'CrossWalkPairXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the cross walk pair | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this cross walk pair record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the cross walk pair | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the cross walk pair record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the cross walk pair record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Cross Walk SID + Source Value + Target Value" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'CONSTRAINT', N'uk_CrossWalkPair_CrossWalkSID_SourceValue_TargetValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CrossWalkPair', 'CONSTRAINT', N'uk_CrossWalkPair_RowGUID'
GO
ALTER TABLE [sf].[CrossWalkPair] SET (LOCK_ESCALATION = TABLE)
GO
