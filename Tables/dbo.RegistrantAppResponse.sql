SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAppResponse] (
		[RegistrantAppResponseSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAppSID]             [int] NOT NULL,
		[FormOwnerSID]                 [int] NOT NULL,
		[FormResponse]                 [xml] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[RegistrantAppResponseXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAppResponse_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAppResponse]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAppResponseSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant App Response table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'CONSTRAINT', N'pk_RegistrantAppResponse'
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAppResponse]
	CHECK
	([dbo].[fRegistrantAppResponse#Check]([RegistrantAppResponseSID],[RegistrantAppSID],[FormOwnerSID],[RegistrantAppResponseXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
CHECK CONSTRAINT [ck_RegistrantAppResponse]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	ADD
	CONSTRAINT [df_RegistrantAppResponse_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	ADD
	CONSTRAINT [df_RegistrantAppResponse_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	ADD
	CONSTRAINT [df_RegistrantAppResponse_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	ADD
	CONSTRAINT [df_RegistrantAppResponse_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	ADD
	CONSTRAINT [df_RegistrantAppResponse_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	ADD
	CONSTRAINT [df_RegistrantAppResponse_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppResponse_RegistrantApp_RegistrantAppSID]
	FOREIGN KEY ([RegistrantAppSID]) REFERENCES [dbo].[RegistrantApp] ([RegistrantAppSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAppResponse]
	CHECK CONSTRAINT [fk_RegistrantAppResponse_RegistrantApp_RegistrantAppSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant app system ID column in the Registrant App Response table match a registrant app system ID in the Registrant App table. It also ensures that when a record in the Registrant App table is deleted, matching child records in the Registrant App Response table are deleted as well. Finally, the constraint blocks changes to the value of the registrant app system ID column in the Registrant App if matching child records exist in Registrant App Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'CONSTRAINT', N'fk_RegistrantAppResponse_RegistrantApp_RegistrantAppSID'
GO
ALTER TABLE [dbo].[RegistrantAppResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppResponse_SF_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [dbo].[RegistrantAppResponse]
	CHECK CONSTRAINT [fk_RegistrantAppResponse_SF_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Registrant App Response table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Registrant App Response. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Registrant App Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'CONSTRAINT', N'fk_RegistrantAppResponse_SF_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppResponse_FormOwnerSID_RegistrantAppResponseSID]
	ON [dbo].[RegistrantAppResponse] ([FormOwnerSID], [RegistrantAppResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'INDEX', N'ix_RegistrantAppResponse_FormOwnerSID_RegistrantAppResponseSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppResponse_RegistrantAppSID_RegistrantAppResponseSID]
	ON [dbo].[RegistrantAppResponse] ([RegistrantAppSID], [RegistrantAppResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant App SID foreign key column and avoids row contention on (parent) Registrant App updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'INDEX', N'ix_RegistrantAppResponse_RegistrantAppSID_RegistrantAppResponseSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAppResponse_LegacyKey]
	ON [dbo].[RegistrantAppResponse] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'INDEX', N'ux_RegistrantAppResponse_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores this history of application form changes.  When the original form is submitted, a copy of responses is stored into this table.  If the applicant resubmits the form - e.g. to make corrections suggested by the administrator, a copy is stored for each submission.  Simiarly, if the administrator makes corrections of the form a version of the responses is saved each time.  The version that is approved is marked "Is-Approved".  Note that the Form-Response-Draft column in the parent Registrant-App table is used to maintain the currently edited version of form content.  The draft responses may or may not agree with any version of responses stored in this table since drafts can be saved but never submitted. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'RegistrantAppResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'RegistrantAppSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this registrant app response', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant app response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'RegistrantAppResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant app response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant app response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant app response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant app response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant app response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'CONSTRAINT', N'uk_RegistrantAppResponse_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAppResponse_FormResponse]
	ON [dbo].[RegistrantAppResponse] ([FormResponse])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppResponse', 'INDEX', N'xp_RegistrantAppResponse_FormResponse'
GO
ALTER TABLE [dbo].[RegistrantAppResponse] SET (LOCK_ESCALATION = TABLE)
GO
