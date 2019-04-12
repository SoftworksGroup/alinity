SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProfileUpdateResponse] (
		[ProfileUpdateResponseSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ProfileUpdateSID]             [int] NOT NULL,
		[FormOwnerSID]                 [int] NOT NULL,
		[FormResponse]                 [xml] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[ProfileUpdateResponseXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_ProfileUpdateResponse_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ProfileUpdateResponse]
		PRIMARY KEY
		CLUSTERED
		([ProfileUpdateResponseSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Profile Update Response table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'CONSTRAINT', N'pk_ProfileUpdateResponse'
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ProfileUpdateResponse]
	CHECK
	([dbo].[fProfileUpdateResponse#Check]([ProfileUpdateResponseSID],[ProfileUpdateSID],[FormOwnerSID],[ProfileUpdateResponseXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
CHECK CONSTRAINT [ck_ProfileUpdateResponse]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	ADD
	CONSTRAINT [df_ProfileUpdateResponse_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	ADD
	CONSTRAINT [df_ProfileUpdateResponse_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	ADD
	CONSTRAINT [df_ProfileUpdateResponse_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	ADD
	CONSTRAINT [df_ProfileUpdateResponse_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	ADD
	CONSTRAINT [df_ProfileUpdateResponse_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	ADD
	CONSTRAINT [df_ProfileUpdateResponse_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdateResponse_ProfileUpdate_ProfileUpdateSID]
	FOREIGN KEY ([ProfileUpdateSID]) REFERENCES [dbo].[ProfileUpdate] ([ProfileUpdateSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[ProfileUpdateResponse]
	CHECK CONSTRAINT [fk_ProfileUpdateResponse_ProfileUpdate_ProfileUpdateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the profile update system ID column in the Profile Update Response table match a profile update system ID in the Profile Update table. It also ensures that when a record in the Profile Update table is deleted, matching child records in the Profile Update Response table are deleted as well. Finally, the constraint blocks changes to the value of the profile update system ID column in the Profile Update if matching child records exist in Profile Update Response.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'CONSTRAINT', N'fk_ProfileUpdateResponse_ProfileUpdate_ProfileUpdateSID'
GO
ALTER TABLE [dbo].[ProfileUpdateResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdateResponse_SF_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [dbo].[ProfileUpdateResponse]
	CHECK CONSTRAINT [fk_ProfileUpdateResponse_SF_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Profile Update Response table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Profile Update Response. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Profile Update Response.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'CONSTRAINT', N'fk_ProfileUpdateResponse_SF_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdateResponse_FormOwnerSID_ProfileUpdateResponseSID]
	ON [dbo].[ProfileUpdateResponse] ([FormOwnerSID], [ProfileUpdateResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'INDEX', N'ix_ProfileUpdateResponse_FormOwnerSID_ProfileUpdateResponseSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdateResponse_ProfileUpdateSID_ProfileUpdateResponseSID]
	ON [dbo].[ProfileUpdateResponse] ([ProfileUpdateSID], [ProfileUpdateResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Profile Update SID foreign key column and avoids row contention on (parent) Profile Update updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'INDEX', N'ix_ProfileUpdateResponse_ProfileUpdateSID_ProfileUpdateResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores this history of profile update form changes.  When the original form is submitted, a copy of responses is stored into this table.  If the applicant resubmits the form - e.g. to make corrections suggested by the administrator, a copy is stored for each submission.  Simiarly, if the administrator makes corrections of the form a version of the responses is saved each time.  The version that is approved is marked "Is-Approved".  Note that the Form-Response-Draft column in the parent Registrant-App table is used to maintain the currently edited version of form content.  The draft responses may or may not agree with any version of responses stored in this table since drafts can be saved but never submitted. ', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'ProfileUpdateResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'ProfileUpdateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this profile update response', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the profile update response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'ProfileUpdateResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the profile update response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this profile update response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the profile update response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the profile update response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the profile update response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'CONSTRAINT', N'uk_ProfileUpdateResponse_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ProfileUpdateResponse_FormResponse]
	ON [dbo].[ProfileUpdateResponse] ([FormResponse])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateResponse', 'INDEX', N'xp_ProfileUpdateResponse_FormResponse'
GO
ALTER TABLE [dbo].[ProfileUpdateResponse] SET (LOCK_ESCALATION = TABLE)
GO
