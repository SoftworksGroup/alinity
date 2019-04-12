SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationPage] (
		[ApplicationPageSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationPageLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ApplicationPageURI]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ApplicationRoute]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsSearchPage]             [bit] NOT NULL,
		[ApplicationEntitySID]     [int] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[ApplicationPageXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationPage_ApplicationPageLabel]
		UNIQUE
		NONCLUSTERED
		([ApplicationPageLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationPage_ApplicationPageURI]
		UNIQUE
		NONCLUSTERED
		([ApplicationPageURI])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationPage_ApplicationRoute]
		UNIQUE
		NONCLUSTERED
		([ApplicationRoute])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationPage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationPage]
		PRIMARY KEY
		CLUSTERED
		([ApplicationPageSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application Page table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'CONSTRAINT', N'pk_ApplicationPage'
GO
ALTER TABLE [sf].[ApplicationPage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationPage]
	CHECK
	([sf].[fApplicationPage#Check]([ApplicationPageSID],[ApplicationPageLabel],[ApplicationPageURI],[ApplicationRoute],[IsSearchPage],[ApplicationEntitySID],[ApplicationPageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationPage]
CHECK CONSTRAINT [ck_ApplicationPage]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_ApplicationEntitySID]
	DEFAULT ([sf].[fApplicationEntity#SID]('sf.ApplicationUser')) FOR [ApplicationEntitySID]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_IsSearchPage]
	DEFAULT ((0)) FOR [IsSearchPage]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationPage]
	ADD
	CONSTRAINT [df_ApplicationPage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationPage]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationPage_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[ApplicationPage]
	CHECK CONSTRAINT [fk_ApplicationPage_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Application Page table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Application Page. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Application Page.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'CONSTRAINT', N'fk_ApplicationPage_ApplicationEntity_ApplicationEntitySID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationPage_ApplicationEntitySID_ApplicationPageSID]
	ON [sf].[ApplicationPage] ([ApplicationEntitySID], [ApplicationPageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'INDEX', N'ix_ApplicationPage_ApplicationEntitySID_ApplicationPageSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationPage_LegacyKey]
	ON [sf].[ApplicationPage] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'INDEX', N'ux_ApplicationPage_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of web pages used in the application. The list of pages cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Pages are referenced from this table to support navigation and business rules.  The list of pages is maintained by product installation and upgrade scripts.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the application page to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'ApplicationPageLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The base link for the page in the application | This value is set by the development team and used as the basis for linking other components (reports, queries, etc.) to appear on the same page ', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'ApplicationPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Technical information used by the application to identify the web page a link should go to | This values applies in Model-View-Controller architectures. This is the “route” used – controller + action – by the application.  The “Application Page URI” columns is provided for Silverlight architectures. This value is to navigate from tasks to the corresponding pages where work can be carried out and is also used in email links to navigate directly to action pages for the user. ', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'ApplicationRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this page supports query references being passed into it for automatic execution', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'IsSearchPage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this page', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application page | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'ApplicationPageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application page | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application page record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application page | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application page record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Route column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'CONSTRAINT', N'uk_ApplicationPage_ApplicationRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'CONSTRAINT', N'uk_ApplicationPage_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Page Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'CONSTRAINT', N'uk_ApplicationPage_ApplicationPageLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Application Page URI column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationPage', 'CONSTRAINT', N'uk_ApplicationPage_ApplicationPageURI'
GO
ALTER TABLE [sf].[ApplicationPage] SET (LOCK_ESCALATION = TABLE)
GO
