SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reinstatement] (
		[ReinstatementSID]               [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationSID]                [int] NOT NULL,
		[PracticeRegisterSectionSID]     [int] NOT NULL,
		[RegistrationYear]               [int] NOT NULL,
		[FormVersionSID]                 [int] NOT NULL,
		[FormResponseDraft]              [xml] NOT NULL,
		[LastValidateTime]               [datetimeoffset](7) NULL,
		[AdminComments]                  [xml] NOT NULL,
		[NextFollowUp]                   [date] NULL,
		[RegistrationEffective]          [date] NULL,
		[ConfirmationDraft]              [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAutoApprovalEnabled]          [bit] NOT NULL,
		[ReasonSID]                      [int] NULL,
		[InvoiceSID]                     [int] NULL,
		[ReviewReasonList]               [xml] NULL,
		[UserDefinedColumns]             [xml] NULL,
		[ReinstatementXID]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_Reinstatement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Reinstatement_RegistrationSID]
		UNIQUE
		NONCLUSTERED
		([RegistrationSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Reinstatement]
		PRIMARY KEY
		CLUSTERED
		([ReinstatementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Reinstatement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'pk_Reinstatement'
GO
ALTER TABLE [dbo].[Reinstatement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Reinstatement]
	CHECK
	([dbo].[fReinstatement#Check]([ReinstatementSID],[RegistrationSID],[PracticeRegisterSectionSID],[RegistrationYear],[FormVersionSID],[LastValidateTime],[NextFollowUp],[RegistrationEffective],[IsAutoApprovalEnabled],[ReasonSID],[InvoiceSID],[ReinstatementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Reinstatement]
CHECK CONSTRAINT [ck_Reinstatement]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_RegistrationYear]
	DEFAULT ([dbo].[fRegistrationYear#Current]()) FOR [RegistrationYear]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_FormResponseDraft]
	DEFAULT (CONVERT([xml],N'<FormResponses />')) FOR [FormResponseDraft]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_AdminComments]
	DEFAULT (CONVERT([xml],'<Comments />')) FOR [AdminComments]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_IsAutoApprovalEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAutoApprovalEnabled]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Reinstatement]
	ADD
	CONSTRAINT [df_Reinstatement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Reinstatement]
	WITH CHECK
	ADD CONSTRAINT [fk_Reinstatement_SF_FormVersion_FormVersionSID]
	FOREIGN KEY ([FormVersionSID]) REFERENCES [sf].[FormVersion] ([FormVersionSID])
ALTER TABLE [dbo].[Reinstatement]
	CHECK CONSTRAINT [fk_Reinstatement_SF_FormVersion_FormVersionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form version system ID column in the Reinstatement table match a form version system ID in the Form Version table. It also ensures that records in the Form Version table cannot be deleted if matching child records exist in Reinstatement. Finally, the constraint blocks changes to the value of the form version system ID column in the Form Version if matching child records exist in Reinstatement.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'fk_Reinstatement_SF_FormVersion_FormVersionSID'
GO
ALTER TABLE [dbo].[Reinstatement]
	WITH CHECK
	ADD CONSTRAINT [fk_Reinstatement_PracticeRegisterSection_PracticeRegisterSectionSID]
	FOREIGN KEY ([PracticeRegisterSectionSID]) REFERENCES [dbo].[PracticeRegisterSection] ([PracticeRegisterSectionSID])
ALTER TABLE [dbo].[Reinstatement]
	CHECK CONSTRAINT [fk_Reinstatement_PracticeRegisterSection_PracticeRegisterSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register section system ID column in the Reinstatement table match a practice register section system ID in the Practice Register Section table. It also ensures that records in the Practice Register Section table cannot be deleted if matching child records exist in Reinstatement. Finally, the constraint blocks changes to the value of the practice register section system ID column in the Practice Register Section if matching child records exist in Reinstatement.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'fk_Reinstatement_PracticeRegisterSection_PracticeRegisterSectionSID'
GO
ALTER TABLE [dbo].[Reinstatement]
	WITH CHECK
	ADD CONSTRAINT [fk_Reinstatement_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[Reinstatement]
	CHECK CONSTRAINT [fk_Reinstatement_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Reinstatement table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Reinstatement. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Reinstatement.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'fk_Reinstatement_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[Reinstatement]
	WITH CHECK
	ADD CONSTRAINT [fk_Reinstatement_Registration_RegistrationSID]
	FOREIGN KEY ([RegistrationSID]) REFERENCES [dbo].[Registration] ([RegistrationSID])
ALTER TABLE [dbo].[Reinstatement]
	CHECK CONSTRAINT [fk_Reinstatement_Registration_RegistrationSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration system ID column in the Reinstatement table match a registration system ID in the Registration table. It also ensures that records in the Registration table cannot be deleted if matching child records exist in Reinstatement. Finally, the constraint blocks changes to the value of the registration system ID column in the Registration if matching child records exist in Reinstatement.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'fk_Reinstatement_Registration_RegistrationSID'
GO
ALTER TABLE [dbo].[Reinstatement]
	WITH CHECK
	ADD CONSTRAINT [fk_Reinstatement_Invoice_InvoiceSID]
	FOREIGN KEY ([InvoiceSID]) REFERENCES [dbo].[Invoice] ([InvoiceSID])
ALTER TABLE [dbo].[Reinstatement]
	CHECK CONSTRAINT [fk_Reinstatement_Invoice_InvoiceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice system ID column in the Reinstatement table match a invoice system ID in the Invoice table. It also ensures that records in the Invoice table cannot be deleted if matching child records exist in Reinstatement. Finally, the constraint blocks changes to the value of the invoice system ID column in the Invoice if matching child records exist in Reinstatement.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'fk_Reinstatement_Invoice_InvoiceSID'
GO
CREATE NONCLUSTERED INDEX [ix_Reinstatement_FormVersionSID_ReinstatementSID]
	ON [dbo].[Reinstatement] ([FormVersionSID], [ReinstatementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Version SID foreign key column and avoids row contention on (parent) Form Version updates', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'ix_Reinstatement_FormVersionSID_ReinstatementSID'
GO
CREATE NONCLUSTERED INDEX [ix_Reinstatement_InvoiceSID_ReinstatementSID]
	ON [dbo].[Reinstatement] ([InvoiceSID], [ReinstatementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice SID foreign key column and avoids row contention on (parent) Invoice updates', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'ix_Reinstatement_InvoiceSID_ReinstatementSID'
GO
CREATE NONCLUSTERED INDEX [ix_Reinstatement_PracticeRegisterSectionSID_ReinstatementSID]
	ON [dbo].[Reinstatement] ([PracticeRegisterSectionSID], [ReinstatementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Section SID foreign key column and avoids row contention on (parent) Practice Register Section updates', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'ix_Reinstatement_PracticeRegisterSectionSID_ReinstatementSID'
GO
CREATE NONCLUSTERED INDEX [ix_Reinstatement_ReasonSID_ReinstatementSID]
	ON [dbo].[Reinstatement] ([ReasonSID], [ReinstatementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'ix_Reinstatement_ReasonSID_ReinstatementSID'
GO
CREATE NONCLUSTERED INDEX [ix_Reinstatement_RegistrationYear_NextFollowUp]
	ON [dbo].[Reinstatement] ([RegistrationYear], [NextFollowUp])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Reinstatement searches based on the Registration Year + Next Follow Up columns', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'ix_Reinstatement_RegistrationYear_NextFollowUp'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Reinstatement_InvoiceSID]
	ON [dbo].[Reinstatement] ([InvoiceSID])
	WHERE (([InvoiceSID] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Invoice SID value is not duplicated where the condition: "([InvoiceSID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'ux_Reinstatement_InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reinstatement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'ReinstatementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration assigned to this reinstatement', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register section assigned to this reinstatement', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year the reinstatement is targeted to take effect in (set to current registration year at creation)', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional value set on approval to override the default effective date of the permit/license created', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'RegistrationEffective'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this reinstatement', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains a list of reasons why Administrative Review of the form is required - null (blank) if no blocking reasons', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'ReviewReasonList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the reinstatement | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'ReinstatementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the reinstatement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this reinstatement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the reinstatement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the reinstatement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reinstatement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'uk_Reinstatement_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration SID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'CONSTRAINT', N'uk_Reinstatement_RegistrationSID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Reinstatement_AdminComments]
	ON [dbo].[Reinstatement] ([AdminComments])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Admin Comments (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'xp_Reinstatement_AdminComments'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Reinstatement_FormResponseDraft]
	ON [dbo].[Reinstatement] ([FormResponseDraft])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response Draft (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'Reinstatement', 'INDEX', N'xp_Reinstatement_FormResponseDraft'
GO
ALTER TABLE [dbo].[Reinstatement] SET (LOCK_ESCALATION = TABLE)
GO
