SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationUserSessionProperty] (
		[ApplicationUserSessionPropertySID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationUserSessionSID]             [int] NOT NULL,
		[PropertyName]                          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PropertyValue]                         [xml] NOT NULL,
		[UserDefinedColumns]                    [xml] NULL,
		[ApplicationUserSessionPropertyXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                             [bit] NOT NULL,
		[CreateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                            [datetimeoffset](7) NOT NULL,
		[UpdateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                            [datetimeoffset](7) NOT NULL,
		[RowGUID]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                              [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationUserSessionProperty_ApplicationUserSessionSID_PropertyName]
		UNIQUE
		NONCLUSTERED
		([ApplicationUserSessionSID], [PropertyName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationUserSessionProperty_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationUserSessionProperty]
		PRIMARY KEY
		CLUSTERED
		([ApplicationUserSessionPropertySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application User Session Property table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'CONSTRAINT', N'pk_ApplicationUserSessionProperty'
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationUserSessionProperty]
	CHECK
	([sf].[fApplicationUserSessionProperty#Check]([ApplicationUserSessionPropertySID],[ApplicationUserSessionSID],[PropertyName],[ApplicationUserSessionPropertyXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
CHECK CONSTRAINT [ck_ApplicationUserSessionProperty]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	ADD
	CONSTRAINT [df_ApplicationUserSessionProperty_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	ADD
	CONSTRAINT [df_ApplicationUserSessionProperty_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	ADD
	CONSTRAINT [df_ApplicationUserSessionProperty_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	ADD
	CONSTRAINT [df_ApplicationUserSessionProperty_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	ADD
	CONSTRAINT [df_ApplicationUserSessionProperty_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	ADD
	CONSTRAINT [df_ApplicationUserSessionProperty_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUserSessionProperty_ApplicationUserSession_ApplicationUserSessionSID]
	FOREIGN KEY ([ApplicationUserSessionSID]) REFERENCES [sf].[ApplicationUserSession] ([ApplicationUserSessionSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[ApplicationUserSessionProperty]
	CHECK CONSTRAINT [fk_ApplicationUserSessionProperty_ApplicationUserSession_ApplicationUserSessionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user session system ID column in the Application User Session Property table match a application user session system ID in the Application User Session table. It also ensures that when a record in the Application User Session table is deleted, matching child records in the Application User Session Property table are deleted as well. Finally, the constraint blocks changes to the value of the application user session system ID column in the Application User Session if matching child records exist in Application User Session Property.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'CONSTRAINT', N'fk_ApplicationUserSessionProperty_ApplicationUserSession_ApplicationUserSessionSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationUserSessionProperty_LegacyKey]
	ON [sf].[ApplicationUserSessionProperty] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'INDEX', N'ux_ApplicationUserSessionProperty_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used at runtime by the software to store data structures that need to be retained through page refreshes and other context changes cannot, therefore, be stored on the client.  This information is not exposed to the UI or meaningful to end users for reporting. Any previous content for this table for a user is deleted at login.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user session property assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'ApplicationUserSessionPropertySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user session assigned to this property', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'ApplicationUserSessionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name assigned to the property by the application', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'PropertyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The value of the property - may be a JSON, XML or other structure but must be cast as XML for storage', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'PropertyValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application user session property | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'ApplicationUserSessionPropertyXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application user session property | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application user session property record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application user session property | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application user session property record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user session property record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application User Session SID + Property Name" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'CONSTRAINT', N'uk_ApplicationUserSessionProperty_ApplicationUserSessionSID_PropertyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'CONSTRAINT', N'uk_ApplicationUserSessionProperty_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ApplicationUserSessionProperty_PropertyValue]
	ON [sf].[ApplicationUserSessionProperty] ([PropertyValue])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Property Value (XML) column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserSessionProperty', 'INDEX', N'xp_ApplicationUserSessionProperty_PropertyValue'
GO
ALTER TABLE [sf].[ApplicationUserSessionProperty] SET (LOCK_ESCALATION = TABLE)
GO
