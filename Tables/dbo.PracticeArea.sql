SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeArea] (
		[PracticeAreaSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeAreaName]            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PracticeAreaCode]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PracticeAreaCategory]        [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsPracticeScopeRequired]     [bit] NOT NULL,
		[IsDefault]                   [bit] NOT NULL,
		[IsActive]                    [bit] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[PracticeAreaXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeArea_PracticeAreaCode]
		UNIQUE
		NONCLUSTERED
		([PracticeAreaCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeArea_PracticeAreaName]
		UNIQUE
		NONCLUSTERED
		([PracticeAreaName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeArea_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeArea]
		PRIMARY KEY
		CLUSTERED
		([PracticeAreaSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Area table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'CONSTRAINT', N'pk_PracticeArea'
GO
ALTER TABLE [dbo].[PracticeArea]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeArea]
	CHECK
	([dbo].[fPracticeArea#Check]([PracticeAreaSID],[PracticeAreaName],[PracticeAreaCode],[PracticeAreaCategory],[IsPracticeScopeRequired],[IsDefault],[IsActive],[PracticeAreaXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeArea]
CHECK CONSTRAINT [ck_PracticeArea]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_IsPracticeScopeRequired]
	DEFAULT ((0)) FOR [IsPracticeScopeRequired]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeArea]
	ADD
	CONSTRAINT [df_PracticeArea_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeArea_IsDefault]
	ON [dbo].[PracticeArea] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Practice Area', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'INDEX', N'ux_PracticeArea_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeArea_LegacyKey]
	ON [dbo].[PracticeArea] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'INDEX', N'ux_PracticeArea_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Theis table is a master list of professional areas of responsibilty reported annually - typically on renewal forms.  The value is part of the description of a registrant''s employment (appears as foreign key on Registrant-Employment).  If a person has more than one area of responsibility with an employer, then the most significant or most responsible area should be identified.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the PracticeAreaXID column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice area assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'PracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice area to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'PracticeAreaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize the practice areas', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'PracticeAreaCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that a Practice Scope must be specified (otherwise Practice Scope defaults to Not Applicable)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'IsPracticeScopeRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice area to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice area record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice area | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'PracticeAreaXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice area | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice area record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice area | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice area record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice area record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Area Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'CONSTRAINT', N'uk_PracticeArea_PracticeAreaCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Area Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'CONSTRAINT', N'uk_PracticeArea_PracticeAreaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeArea', 'CONSTRAINT', N'uk_PracticeArea_RowGUID'
GO
ALTER TABLE [dbo].[PracticeArea] SET (LOCK_ESCALATION = TABLE)
GO
