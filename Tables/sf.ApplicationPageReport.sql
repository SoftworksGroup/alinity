SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationPageReport] (
		[ApplicationPageReportSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationPageSID]           [int] NOT NULL,
		[ApplicationReportSID]         [int] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[ApplicationPageReportXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationPageReport_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationPageReport]
		PRIMARY KEY
		CLUSTERED
		([ApplicationPageReportSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application Page Report table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'CONSTRAINT', N'pk_ApplicationPageReport'
GO
ALTER TABLE [sf].[ApplicationPageReport]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationPageReport]
	CHECK
	([sf].[fApplicationPageReport#Check]([ApplicationPageReportSID],[ApplicationPageSID],[ApplicationReportSID],[ApplicationPageReportXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationPageReport]
CHECK CONSTRAINT [ck_ApplicationPageReport]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	ADD
	CONSTRAINT [df_ApplicationPageReport_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	ADD
	CONSTRAINT [df_ApplicationPageReport_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	ADD
	CONSTRAINT [df_ApplicationPageReport_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	ADD
	CONSTRAINT [df_ApplicationPageReport_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	ADD
	CONSTRAINT [df_ApplicationPageReport_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	ADD
	CONSTRAINT [df_ApplicationPageReport_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationPageReport]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationPageReport_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[ApplicationPageReport]
	CHECK CONSTRAINT [fk_ApplicationPageReport_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Application Page Report table match a application page system ID in the Application Page table. It also ensures that when a record in the Application Page table is deleted, matching child records in the Application Page Report table are deleted as well. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Application Page Report.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'CONSTRAINT', N'fk_ApplicationPageReport_ApplicationPage_ApplicationPageSID'
GO
ALTER TABLE [sf].[ApplicationPageReport]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationPageReport_ApplicationReport_ApplicationReportSID]
	FOREIGN KEY ([ApplicationReportSID]) REFERENCES [sf].[ApplicationReport] ([ApplicationReportSID])
ALTER TABLE [sf].[ApplicationPageReport]
	CHECK CONSTRAINT [fk_ApplicationPageReport_ApplicationReport_ApplicationReportSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application report system ID column in the Application Page Report table match a application report system ID in the Application Report table. It also ensures that records in the Application Report table cannot be deleted if matching child records exist in Application Page Report. Finally, the constraint blocks changes to the value of the application report system ID column in the Application Report if matching child records exist in Application Page Report.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'CONSTRAINT', N'fk_ApplicationPageReport_ApplicationReport_ApplicationReportSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationPageReport_ApplicationPageSID_ApplicationPageReportSID]
	ON [sf].[ApplicationPageReport] ([ApplicationPageSID], [ApplicationPageReportSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'INDEX', N'ix_ApplicationPageReport_ApplicationPageSID_ApplicationPageReportSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationPageReport_ApplicationReportSID_ApplicationPageReportSID]
	ON [sf].[ApplicationPageReport] ([ApplicationReportSID], [ApplicationPageReportSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Report SID foreign key column and avoids row contention on (parent) Application Report updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'INDEX', N'ix_ApplicationPageReport_ApplicationReportSID_ApplicationPageReportSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationPageReport_LegacyKey]
	ON [sf].[ApplicationPageReport] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'INDEX', N'ux_ApplicationPageReport_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The same report can be called from more than one location in the application. This table stores the page or pages each report can be called from.  Note that the security for calling reports is inherited from the page; that is, if the user has access to the page, they automatically have access to reports that can be called from that page.  Note that for built-in reports (those that are not "custom"), the pages the report is available from cannot be altered.  Configurators, however, can add and change locations for calling custom reports.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page report assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'ApplicationPageReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The page this report is defined for', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The report assigned to this page', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'ApplicationReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application page report | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'ApplicationPageReportXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application page report | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application page report record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application page report | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application page report record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page report record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPageReport', 'CONSTRAINT', N'uk_ApplicationPageReport_RowGUID'
GO
ALTER TABLE [sf].[ApplicationPageReport] SET (LOCK_ESCALATION = TABLE)
GO
