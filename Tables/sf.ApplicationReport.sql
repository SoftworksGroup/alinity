SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationReport] (
		[ApplicationReportSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationReportName]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IconPathData]              [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IconFillColor]             [char](9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DisplayRank]               [tinyint] NOT NULL,
		[ReportDefinition]          [xml] NOT NULL,
		[ReportParameters]          [xml] NULL,
		[IsCustom]                  [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[ApplicationReportXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationReport_ApplicationReportName]
		UNIQUE
		NONCLUSTERED
		([ApplicationReportName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationReport_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationReport]
		PRIMARY KEY
		CLUSTERED
		([ApplicationReportSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application Report table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'CONSTRAINT', N'pk_ApplicationReport'
GO
ALTER TABLE [sf].[ApplicationReport]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationReport]
	CHECK
	([sf].[fApplicationReport#Check]([ApplicationReportSID],[ApplicationReportName],[IconFillColor],[DisplayRank],[IsCustom],[ApplicationReportXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationReport]
CHECK CONSTRAINT [ck_ApplicationReport]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_IconFillColor]
	DEFAULT ('#FF376092') FOR [IconFillColor]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_DisplayRank]
	DEFAULT ((0)) FOR [DisplayRank]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_IsCustom]
	DEFAULT (CONVERT([bit],(1),(0))) FOR [IsCustom]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationReport]
	ADD
	CONSTRAINT [df_ApplicationReport_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationReport_LegacyKey]
	ON [sf].[ApplicationReport] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'INDEX', N'ux_ApplicationReport_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stores all report definitions used in the application. The table stores both built-in reports and custom reports.  Through this table a new report can be added without requiring an application upgrade.  The "report definition language" (RDL) content (SQL Reports) is stored as XML.  Parameters the user is prompted for are described in a second XML column "ReportParameters" using the same structure applied to Query parameters.  The UI reads this table to display report icons in the charm bar.  The same report can be associated with multiple pages.  Note that for built-in reports, the value of the columns cannot be changed (not even the name).  This is because built-in reports are deleted and re-added on upgrades.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application report assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'ApplicationReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application report to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'ApplicationReportName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Coorindate data (technical) that describes the icon to display for the report in the charm bar', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'IconPathData'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 9 character value that describes the color the icon should be displayed in on the charm bar', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'IconFillColor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the order this report appears in within report menus (built-in and custom reports are separated)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'DisplayRank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The "report definition language" (RDL) file that describes the report', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'ReportDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML structure used to store parameter names, data types, and other information needed to prompt the user for selection criteria to apply in the report| Parameter names must match property names in the entity  - e.g. the parameter "@FacilitySID" would be replaced by the key of the facility record if one were selected in the user interface at the time the report is called.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'ReportParameters'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, indicates this report was added specificially to the configuration and is not a built-in product report', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'IsCustom'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application report | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'ApplicationReportXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application report | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application report record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application report | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application report record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application report record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Report Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'CONSTRAINT', N'uk_ApplicationReport_ApplicationReportName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'CONSTRAINT', N'uk_ApplicationReport_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ApplicationReport_ReportDefinition]
	ON [sf].[ApplicationReport] ([ReportDefinition])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Report Definition (XML) column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationReport', 'INDEX', N'xp_ApplicationReport_ReportDefinition'
GO
ALTER TABLE [sf].[ApplicationReport] SET (LOCK_ESCALATION = TABLE)
GO
