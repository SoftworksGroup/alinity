SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[CrossWalk] (
		[CrossWalkSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[CrossWalkLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[CrossWalkXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_CrossWalk_CrossWalkLabel]
		UNIQUE
		NONCLUSTERED
		([CrossWalkLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CrossWalk_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CrossWalk]
		PRIMARY KEY
		CLUSTERED
		([CrossWalkSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Cross Walk table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'CONSTRAINT', N'pk_CrossWalk'
GO
ALTER TABLE [sf].[CrossWalk]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CrossWalk]
	CHECK
	([sf].[fCrossWalk#Check]([CrossWalkSID],[CrossWalkLabel],[IsDefault],[CrossWalkXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[CrossWalk]
CHECK CONSTRAINT [ck_CrossWalk]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[CrossWalk]
	ADD
	CONSTRAINT [df_CrossWalk_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_CrossWalk_IsDefault]
	ON [sf].[CrossWalk] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Cross Walk', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'INDEX', N'ux_CrossWalk_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_CrossWalk_LegacyKey]
	ON [sf].[CrossWalk] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'INDEX', N'ux_CrossWalk_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the cross walk assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'CrossWalkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the cross walk to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'CrossWalkLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default cross walk to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the cross walk | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'CrossWalkXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the cross walk | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this cross walk record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the cross walk | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the cross walk record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the cross walk record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Cross Walk Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'CONSTRAINT', N'uk_CrossWalk_CrossWalkLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CrossWalk', 'CONSTRAINT', N'uk_CrossWalk_RowGUID'
GO
ALTER TABLE [sf].[CrossWalk] SET (LOCK_ESCALATION = TABLE)
GO
