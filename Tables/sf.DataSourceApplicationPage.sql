SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[DataSourceApplicationPage] (
		[DataSourceApplicationPageSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[DataSourceSID]                    [int] NOT NULL,
		[ApplicationPageSID]               [int] NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[DataSourceApplicationPageXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_DataSourceApplicationPage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_DataSourceApplicationPage]
		PRIMARY KEY
		CLUSTERED
		([DataSourceApplicationPageSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Data Source Application Page table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'CONSTRAINT', N'pk_DataSourceApplicationPage'
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_DataSourceApplicationPage]
	CHECK
	([sf].[fDataSourceApplicationPage#Check]([DataSourceApplicationPageSID],[DataSourceSID],[ApplicationPageSID],[DataSourceApplicationPageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
CHECK CONSTRAINT [ck_DataSourceApplicationPage]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	ADD
	CONSTRAINT [df_DataSourceApplicationPage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	ADD
	CONSTRAINT [df_DataSourceApplicationPage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	ADD
	CONSTRAINT [df_DataSourceApplicationPage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	ADD
	CONSTRAINT [df_DataSourceApplicationPage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	ADD
	CONSTRAINT [df_DataSourceApplicationPage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	ADD
	CONSTRAINT [df_DataSourceApplicationPage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	WITH CHECK
	ADD CONSTRAINT [fk_DataSourceApplicationPage_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
ALTER TABLE [sf].[DataSourceApplicationPage]
	CHECK CONSTRAINT [fk_DataSourceApplicationPage_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Data Source Application Page table match a application page system ID in the Application Page table. It also ensures that records in the Application Page table cannot be deleted if matching child records exist in Data Source Application Page. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Data Source Application Page.', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'CONSTRAINT', N'fk_DataSourceApplicationPage_ApplicationPage_ApplicationPageSID'
GO
ALTER TABLE [sf].[DataSourceApplicationPage]
	WITH CHECK
	ADD CONSTRAINT [fk_DataSourceApplicationPage_DataSource_DataSourceSID]
	FOREIGN KEY ([DataSourceSID]) REFERENCES [sf].[DataSource] ([DataSourceSID])
ALTER TABLE [sf].[DataSourceApplicationPage]
	CHECK CONSTRAINT [fk_DataSourceApplicationPage_DataSource_DataSourceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the data source system ID column in the Data Source Application Page table match a data source system ID in the Data Source table. It also ensures that records in the Data Source table cannot be deleted if matching child records exist in Data Source Application Page. Finally, the constraint blocks changes to the value of the data source system ID column in the Data Source if matching child records exist in Data Source Application Page.', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'CONSTRAINT', N'fk_DataSourceApplicationPage_DataSource_DataSourceSID'
GO
CREATE NONCLUSTERED INDEX [ix_DataSourceApplicationPage_ApplicationPageSID_DataSourceApplicationPageSID]
	ON [sf].[DataSourceApplicationPage] ([ApplicationPageSID], [DataSourceApplicationPageSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'INDEX', N'ix_DataSourceApplicationPage_ApplicationPageSID_DataSourceApplicationPageSID'
GO
CREATE NONCLUSTERED INDEX [ix_DataSourceApplicationPage_DataSourceSID_DataSourceApplicationPageSID]
	ON [sf].[DataSourceApplicationPage] ([DataSourceSID], [DataSourceApplicationPageSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Data Source SID foreign key column and avoids row contention on (parent) Data Source updates', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'INDEX', N'ix_DataSourceApplicationPage_DataSourceSID_DataSourceApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to specify which web pages of the application the data-source should be made available on.  This will normally include one or more Search oriented pages.  These records should be added only by Alinity Help Desk staff.  Application pages should be selected only where the search entity includes the key column of the export.  For example, if the data-source is keyed by Person-SID and the Registration search returns Registrant-SID as its primary key but also returns Person-SID, then that page can be used as a location to make exporting from the data source available.  The application creates a query where the data source is selected using a JOIN to the (distinct) Person-SID column from the search entity.', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the data source application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'DataSourceApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The data source this page is defined for', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'DataSourceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The page assigned to this data source', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the data source application page | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'DataSourceApplicationPageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the data source application page | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this data source application page record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the data source application page | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the data source application page record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the data source application page record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DataSourceApplicationPage', 'CONSTRAINT', N'uk_DataSourceApplicationPage_RowGUID'
GO
ALTER TABLE [sf].[DataSourceApplicationPage] SET (LOCK_ESCALATION = TABLE)
GO
