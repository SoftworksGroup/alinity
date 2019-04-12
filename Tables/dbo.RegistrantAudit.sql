SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAudit] (
		[RegistrantAuditSID]        [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]             [int] NOT NULL,
		[AuditTypeSID]              [int] NOT NULL,
		[RegistrationYear]          [smallint] NOT NULL,
		[FormVersionSID]            [int] NOT NULL,
		[FormResponseDraft]         [xml] NOT NULL,
		[LastValidateTime]          [datetimeoffset](7) NULL,
		[AdminComments]             [xml] NOT NULL,
		[NextFollowUp]              [date] NULL,
		[PendingReviewers]          [xml] NULL,
		[ReasonSID]                 [int] NULL,
		[ConfirmationDraft]         [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAutoApprovalEnabled]     [bit] NOT NULL,
		[ReviewReasonList]          [xml] NULL,
		[UserDefinedColumns]        [xml] NULL,
		[RegistrantAuditXID]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAudit_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrantAudit_RegistrationYear_AuditTypeSID_RegistrantSID]
		UNIQUE
		NONCLUSTERED
		([RegistrationYear], [AuditTypeSID], [RegistrantSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAudit]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAuditSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Audit table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'pk_RegistrantAudit'
GO
ALTER TABLE [dbo].[RegistrantAudit]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAudit]
	CHECK
	([dbo].[fRegistrantAudit#Check]([RegistrantAuditSID],[RegistrantSID],[AuditTypeSID],[RegistrationYear],[FormVersionSID],[LastValidateTime],[NextFollowUp],[ReasonSID],[IsAutoApprovalEnabled],[RegistrantAuditXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAudit]
CHECK CONSTRAINT [ck_RegistrantAudit]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_RegistrationYear]
	DEFAULT ([sf].[fTodayYear]()) FOR [RegistrationYear]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_FormResponseDraft]
	DEFAULT (CONVERT([xml],N'<FormResponses />')) FOR [FormResponseDraft]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_AdminComments]
	DEFAULT (CONVERT([xml],'<Comments />')) FOR [AdminComments]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_IsAutoApprovalEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAutoApprovalEnabled]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	ADD
	CONSTRAINT [df_RegistrantAudit_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAudit_SF_FormVersion_FormVersionSID]
	FOREIGN KEY ([FormVersionSID]) REFERENCES [sf].[FormVersion] ([FormVersionSID])
ALTER TABLE [dbo].[RegistrantAudit]
	CHECK CONSTRAINT [fk_RegistrantAudit_SF_FormVersion_FormVersionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form version system ID column in the Registrant Audit table match a form version system ID in the Form Version table. It also ensures that records in the Form Version table cannot be deleted if matching child records exist in Registrant Audit. Finally, the constraint blocks changes to the value of the form version system ID column in the Form Version if matching child records exist in Registrant Audit.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'fk_RegistrantAudit_SF_FormVersion_FormVersionSID'
GO
ALTER TABLE [dbo].[RegistrantAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAudit_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantAudit]
	CHECK CONSTRAINT [fk_RegistrantAudit_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Audit table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Audit. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Audit.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'fk_RegistrantAudit_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAudit_AuditType_AuditTypeSID]
	FOREIGN KEY ([AuditTypeSID]) REFERENCES [dbo].[AuditType] ([AuditTypeSID])
ALTER TABLE [dbo].[RegistrantAudit]
	CHECK CONSTRAINT [fk_RegistrantAudit_AuditType_AuditTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the audit type system ID column in the Registrant Audit table match a audit type system ID in the Audit Type table. It also ensures that records in the Audit Type table cannot be deleted if matching child records exist in Registrant Audit. Finally, the constraint blocks changes to the value of the audit type system ID column in the Audit Type if matching child records exist in Registrant Audit.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'fk_RegistrantAudit_AuditType_AuditTypeSID'
GO
ALTER TABLE [dbo].[RegistrantAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAudit_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[RegistrantAudit]
	CHECK CONSTRAINT [fk_RegistrantAudit_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Registrant Audit table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Registrant Audit. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Registrant Audit.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'fk_RegistrantAudit_Reason_ReasonSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAudit_AuditTypeSID_RegistrantAuditSID]
	ON [dbo].[RegistrantAudit] ([AuditTypeSID], [RegistrantAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Audit Type SID foreign key column and avoids row contention on (parent) Audit Type updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'ix_RegistrantAudit_AuditTypeSID_RegistrantAuditSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAudit_FormVersionSID_RegistrantAuditSID]
	ON [dbo].[RegistrantAudit] ([FormVersionSID], [RegistrantAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Version SID foreign key column and avoids row contention on (parent) Form Version updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'ix_RegistrantAudit_FormVersionSID_RegistrantAuditSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAudit_ReasonSID_RegistrantAuditSID]
	ON [dbo].[RegistrantAudit] ([ReasonSID], [RegistrantAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'ix_RegistrantAudit_ReasonSID_RegistrantAuditSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAudit_RegistrantSID_RegistrantAuditSID]
	ON [dbo].[RegistrantAudit] ([RegistrantSID], [RegistrantAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'ix_RegistrantAudit_RegistrantSID_RegistrantAuditSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAudit_LegacyKey]
	ON [dbo].[RegistrantAudit] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'ux_RegistrantAudit_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant audit assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'RegistrantAuditSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of registrant audit', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'AuditTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'These comments are entered by Administrators and are shown to the Registrant.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'AdminComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'List of persons identified to complete reviews but who have not yet been assigned the review (draft content) - blank when no reviewers are pending', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'PendingReviewers'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registrant audit', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains a list of reasons why Administrative Review of the form is required - null (blank) if no blocking reasons', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'ReviewReasonList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant audit | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'RegistrantAuditXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant audit | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant audit record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant audit | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant audit record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'uk_RegistrantAudit_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registration Year + Audit Type SID + Registrant SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'CONSTRAINT', N'uk_RegistrantAudit_RegistrationYear_AuditTypeSID_RegistrantSID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAudit_AdminComments]
	ON [dbo].[RegistrantAudit] ([AdminComments])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Admin Comments (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'xp_RegistrantAudit_AdminComments'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAudit_FormResponseDraft]
	ON [dbo].[RegistrantAudit] ([FormResponseDraft])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response Draft (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAudit', 'INDEX', N'xp_RegistrantAudit_FormResponseDraft'
GO
ALTER TABLE [dbo].[RegistrantAudit] SET (LOCK_ESCALATION = TABLE)
GO
