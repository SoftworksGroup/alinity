SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeScope] (
		[PracticeScopeSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeScopeName]      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PracticeScopeCode]      [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[PracticeScopeXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeScope_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeScope_PracticeScopeName]
		UNIQUE
		NONCLUSTERED
		([PracticeScopeName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeScope_PracticeScopeCode]
		UNIQUE
		NONCLUSTERED
		([PracticeScopeCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeScope]
		PRIMARY KEY
		CLUSTERED
		([PracticeScopeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Scope table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'CONSTRAINT', N'pk_PracticeScope'
GO
ALTER TABLE [dbo].[PracticeScope]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeScope]
	CHECK
	([dbo].[fPracticeScope#Check]([PracticeScopeSID],[PracticeScopeName],[PracticeScopeCode],[IsDefault],[IsActive],[PracticeScopeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeScope]
CHECK CONSTRAINT [ck_PracticeScope]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeScope]
	ADD
	CONSTRAINT [df_PracticeScope_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeScope_IsDefault]
	ON [dbo].[PracticeScope] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Practice Scope', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'INDEX', N'ux_PracticeScope_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Theis table is a master list of professional areas of responsibilty reported annually - typically on renewal forms.  The value is part of the description of a registrant''s employment (appears as foreign key on Registrant-Employment).  If a person has more than one area of responsibility with an employer, then the most significant or most responsible area should be identified.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the PracticeScopeXID column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice scope assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'PracticeScopeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice scope to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'PracticeScopeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice scope to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice scope record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice scope | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'PracticeScopeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice scope | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice scope record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice scope | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice scope record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice scope record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'CONSTRAINT', N'uk_PracticeScope_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Scope Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'CONSTRAINT', N'uk_PracticeScope_PracticeScopeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Scope Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeScope', 'CONSTRAINT', N'uk_PracticeScope_PracticeScopeCode'
GO
ALTER TABLE [dbo].[PracticeScope] SET (LOCK_ESCALATION = TABLE)
GO
