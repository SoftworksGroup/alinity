SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationUserProfileProperty] (
		[ApplicationUserProfilePropertySID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationUserSID]                    [int] NOT NULL,
		[PropertyName]                          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PropertyValue]                         [xml] NOT NULL,
		[UserDefinedColumns]                    [xml] NULL,
		[ApplicationUserProfilePropertyXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                             [bit] NOT NULL,
		[CreateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                            [datetimeoffset](7) NOT NULL,
		[UpdateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                            [datetimeoffset](7) NOT NULL,
		[RowGUID]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                              [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationUserProfileProperty_ApplicationUserSID_PropertyName]
		UNIQUE
		NONCLUSTERED
		([ApplicationUserSID], [PropertyName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationUserProfileProperty_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationUserProfileProperty]
		PRIMARY KEY
		CLUSTERED
		([ApplicationUserProfilePropertySID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application User Profile Property table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'CONSTRAINT', N'pk_ApplicationUserProfileProperty'
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationUserProfileProperty]
	CHECK
	([sf].[fApplicationUserProfileProperty#Check]([ApplicationUserProfilePropertySID],[ApplicationUserSID],[PropertyName],[ApplicationUserProfilePropertyXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
CHECK CONSTRAINT [ck_ApplicationUserProfileProperty]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	ADD
	CONSTRAINT [df_ApplicationUserProfileProperty_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	ADD
	CONSTRAINT [df_ApplicationUserProfileProperty_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	ADD
	CONSTRAINT [df_ApplicationUserProfileProperty_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	ADD
	CONSTRAINT [df_ApplicationUserProfileProperty_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	ADD
	CONSTRAINT [df_ApplicationUserProfileProperty_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	ADD
	CONSTRAINT [df_ApplicationUserProfileProperty_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUserProfileProperty_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[ApplicationUserProfileProperty]
	CHECK CONSTRAINT [fk_ApplicationUserProfileProperty_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Application User Profile Property table match a application user system ID in the Application User table. It also ensures that when a record in the Application User table is deleted, matching child records in the Application User Profile Property table are deleted as well. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Application User Profile Property.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'CONSTRAINT', N'fk_ApplicationUserProfileProperty_ApplicationUser_ApplicationUserSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationUserProfileProperty_LegacyKey]
	ON [sf].[ApplicationUserProfileProperty] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'INDEX', N'ux_ApplicationUserProfileProperty_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table captures preferences and other configuration settings used by the software to customize the user experience.  The specific values stored are determined by the application.  Each property is assigned to a record, however, one property may have several sub-properties as defined in an XML structure. While users can update their configuration, this data is not exposed to the UI in the same form as it appears in the record and is rarely a subject of end user reporting.  ', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user profile property assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'ApplicationUserProfilePropertySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this profile property', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name assigned to the property by the application', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'PropertyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The value of the property - may be a JSON, XML or other structure but must be cast as XML for storage', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'PropertyValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application user profile property | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'ApplicationUserProfilePropertyXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application user profile property | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application user profile property record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application user profile property | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application user profile property record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user profile property record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Application User SID + Property Name" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'CONSTRAINT', N'uk_ApplicationUserProfileProperty_ApplicationUserSID_PropertyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'CONSTRAINT', N'uk_ApplicationUserProfileProperty_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ApplicationUserProfileProperty_PropertyValue]
	ON [sf].[ApplicationUserProfileProperty] ([PropertyValue])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Property Value (XML) column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUserProfileProperty', 'INDEX', N'xp_ApplicationUserProfileProperty_PropertyValue'
GO
ALTER TABLE [sf].[ApplicationUserProfileProperty] SET (LOCK_ESCALATION = TABLE)
GO
