SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAuditResponse] (
		[RegistrantAuditResponseSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAuditSID]             [int] NOT NULL,
		[FormOwnerSID]                   [int] NOT NULL,
		[FormResponse]                   [xml] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[RegistrantAuditResponseXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAuditResponse_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAuditResponse]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAuditResponseSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Audit Response table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'CONSTRAINT', N'pk_RegistrantAuditResponse'
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAuditResponse]
	CHECK
	([dbo].[fRegistrantAuditResponse#Check]([RegistrantAuditResponseSID],[RegistrantAuditSID],[FormOwnerSID],[RegistrantAuditResponseXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
CHECK CONSTRAINT [ck_RegistrantAuditResponse]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	ADD
	CONSTRAINT [df_RegistrantAuditResponse_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	ADD
	CONSTRAINT [df_RegistrantAuditResponse_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	ADD
	CONSTRAINT [df_RegistrantAuditResponse_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	ADD
	CONSTRAINT [df_RegistrantAuditResponse_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	ADD
	CONSTRAINT [df_RegistrantAuditResponse_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	ADD
	CONSTRAINT [df_RegistrantAuditResponse_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditResponse_RegistrantAudit_RegistrantAuditSID]
	FOREIGN KEY ([RegistrantAuditSID]) REFERENCES [dbo].[RegistrantAudit] ([RegistrantAuditSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAuditResponse]
	CHECK CONSTRAINT [fk_RegistrantAuditResponse_RegistrantAudit_RegistrantAuditSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant audit system ID column in the Registrant Audit Response table match a registrant audit system ID in the Registrant Audit table. It also ensures that when a record in the Registrant Audit table is deleted, matching child records in the Registrant Audit Response table are deleted as well. Finally, the constraint blocks changes to the value of the registrant audit system ID column in the Registrant Audit if matching child records exist in Registrant Audit Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'CONSTRAINT', N'fk_RegistrantAuditResponse_RegistrantAudit_RegistrantAuditSID'
GO
ALTER TABLE [dbo].[RegistrantAuditResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditResponse_SF_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [dbo].[RegistrantAuditResponse]
	CHECK CONSTRAINT [fk_RegistrantAuditResponse_SF_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Registrant Audit Response table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Registrant Audit Response. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Registrant Audit Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'CONSTRAINT', N'fk_RegistrantAuditResponse_SF_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditResponse_FormOwnerSID_RegistrantAuditResponseSID]
	ON [dbo].[RegistrantAuditResponse] ([FormOwnerSID], [RegistrantAuditResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'INDEX', N'ix_RegistrantAuditResponse_FormOwnerSID_RegistrantAuditResponseSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditResponse_RegistrantAuditSID_RegistrantAuditResponseSID]
	ON [dbo].[RegistrantAuditResponse] ([RegistrantAuditSID], [RegistrantAuditResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Audit SID foreign key column and avoids row contention on (parent) Registrant Audit updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'INDEX', N'ix_RegistrantAuditResponse_RegistrantAuditSID_RegistrantAuditResponseSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAuditResponse_LegacyKey]
	ON [dbo].[RegistrantAuditResponse] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'INDEX', N'ux_RegistrantAuditResponse_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores this history of application form changes.  When the original form is submitted, a copy of responses is stored into this table.  If the applicant resubmits the form - e.g. to make corrections suggested by the administrator, a copy is stored for each submission.  Simiarly, if the administrator makes corrections of the form a version of the responses is saved each time.  The version that is approved is marked "Is-Approved".  Note that the Form-Response-Draft column in the parent Registrant-App table is used to maintain the currently edited version of form content.  The draft responses may or may not agree with any version of responses stored in this table since drafts can be saved but never submitted. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant audit response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'RegistrantAuditResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence audit assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'RegistrantAuditSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this registrant audit response', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant audit response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'RegistrantAuditResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant audit response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant audit response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant audit response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant audit response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'CONSTRAINT', N'uk_RegistrantAuditResponse_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAuditResponse_FormResponse]
	ON [dbo].[RegistrantAuditResponse] ([FormResponse])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditResponse', 'INDEX', N'xp_RegistrantAuditResponse_FormResponse'
GO
ALTER TABLE [dbo].[RegistrantAuditResponse] SET (LOCK_ESCALATION = TABLE)
GO
