SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProfileUpdate] (
		[ProfileUpdateSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                 [int] NOT NULL,
		[RegistrationYear]          [int] NOT NULL,
		[FormVersionSID]            [int] NOT NULL,
		[FormResponseDraft]         [xml] NOT NULL,
		[LastValidateTime]          [datetimeoffset](7) NULL,
		[AdminComments]             [xml] NOT NULL,
		[NextFollowUp]              [date] NULL,
		[ConfirmationDraft]         [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAutoApprovalEnabled]     [bit] NOT NULL,
		[ReasonSID]                 [int] NULL,
		[ReviewReasonList]          [xml] NULL,
		[ParentRowGUID]             [uniqueidentifier] NULL,
		[UserDefinedColumns]        [xml] NULL,
		[ProfileUpdateXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_ProfileUpdate_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ProfileUpdate]
		PRIMARY KEY
		CLUSTERED
		([ProfileUpdateSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Profile Update table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'CONSTRAINT', N'pk_ProfileUpdate'
GO
ALTER TABLE [dbo].[ProfileUpdate]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ProfileUpdate]
	CHECK
	([dbo].[fProfileUpdate#Check]([ProfileUpdateSID],[PersonSID],[RegistrationYear],[FormVersionSID],[LastValidateTime],[NextFollowUp],[IsAutoApprovalEnabled],[ReasonSID],[ParentRowGUID],[ProfileUpdateXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ProfileUpdate]
CHECK CONSTRAINT [ck_ProfileUpdate]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_RegistrationYear]
	DEFAULT ([dbo].[fRegistrationYear#Current]()) FOR [RegistrationYear]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_FormResponseDraft]
	DEFAULT (CONVERT([xml],N'<FormResponses />')) FOR [FormResponseDraft]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_AdminComments]
	DEFAULT (CONVERT([xml],'<Comments />')) FOR [AdminComments]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_IsAutoApprovalEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAutoApprovalEnabled]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	ADD
	CONSTRAINT [df_ProfileUpdate_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ProfileUpdate]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdate_SF_FormVersion_FormVersionSID]
	FOREIGN KEY ([FormVersionSID]) REFERENCES [sf].[FormVersion] ([FormVersionSID])
ALTER TABLE [dbo].[ProfileUpdate]
	CHECK CONSTRAINT [fk_ProfileUpdate_SF_FormVersion_FormVersionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form version system ID column in the Profile Update table match a form version system ID in the Form Version table. It also ensures that records in the Form Version table cannot be deleted if matching child records exist in Profile Update. Finally, the constraint blocks changes to the value of the form version system ID column in the Form Version if matching child records exist in Profile Update.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'CONSTRAINT', N'fk_ProfileUpdate_SF_FormVersion_FormVersionSID'
GO
ALTER TABLE [dbo].[ProfileUpdate]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdate_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[ProfileUpdate]
	CHECK CONSTRAINT [fk_ProfileUpdate_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Profile Update table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Profile Update. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Profile Update.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'CONSTRAINT', N'fk_ProfileUpdate_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[ProfileUpdate]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdate_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[ProfileUpdate]
	CHECK CONSTRAINT [fk_ProfileUpdate_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Profile Update table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Profile Update. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Profile Update.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'CONSTRAINT', N'fk_ProfileUpdate_SF_Person_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdate_FormVersionSID_ProfileUpdateSID]
	ON [dbo].[ProfileUpdate] ([FormVersionSID], [ProfileUpdateSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Version SID foreign key column and avoids row contention on (parent) Form Version updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'ix_ProfileUpdate_FormVersionSID_ProfileUpdateSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdate_PersonSID_ProfileUpdateSID]
	ON [dbo].[ProfileUpdate] ([PersonSID], [ProfileUpdateSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'ix_ProfileUpdate_PersonSID_ProfileUpdateSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdate_ReasonSID_ProfileUpdateSID]
	ON [dbo].[ProfileUpdate] ([ReasonSID], [ProfileUpdateSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'ix_ProfileUpdate_ReasonSID_ProfileUpdateSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdate_RegistrationYear_NextFollowUp]
	ON [dbo].[ProfileUpdate] ([RegistrationYear], [NextFollowUp])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Profile Update searches based on the Registration Year + Next Follow Up columns', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'ix_ProfileUpdate_RegistrationYear_NextFollowUp'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ProfileUpdate_ParentRowGUID]
	ON [dbo].[ProfileUpdate] ([ParentRowGUID])
	WHERE (([ParentRowGUID] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Parent Row GUID value is not duplicated where the condition: "([ParentRowGUID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'ux_ProfileUpdate_ParentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'ProfileUpdateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year the profile update was created in (set to current registration year by default)', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this profile update', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains a list of reasons why Administrative Review of the form is required - null (blank) if no blocking reasons', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'ReviewReasonList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique identifier of the parent form (typically a renewal or reinstatement) the Profile Update is connected to.  | Null (blank) if this profile update form is not part of a form-set', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'ParentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the profile update | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'ProfileUpdateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the profile update | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this profile update record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the profile update | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the profile update record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the profile update record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'CONSTRAINT', N'uk_ProfileUpdate_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ProfileUpdate_AdminComments]
	ON [dbo].[ProfileUpdate] ([AdminComments])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Admin Comments (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'xp_ProfileUpdate_AdminComments'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ProfileUpdate_FormResponseDraft]
	ON [dbo].[ProfileUpdate] ([FormResponseDraft])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response Draft (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdate', 'INDEX', N'xp_ProfileUpdate_FormResponseDraft'
GO
ALTER TABLE [dbo].[ProfileUpdate] SET (LOCK_ESCALATION = TABLE)
GO
