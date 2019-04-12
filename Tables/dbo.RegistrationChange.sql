SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationChange] (
		[RegistrationChangeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationSID]                [int] NOT NULL,
		[PracticeRegisterSectionSID]     [int] NOT NULL,
		[RegistrationYear]               [smallint] NOT NULL,
		[NextFollowUp]                   [date] NULL,
		[RegistrationEffective]          [date] NULL,
		[ReservedRegistrantNo]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ConfirmationDraft]              [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ReasonSID]                      [int] NULL,
		[InvoiceSID]                     [int] NULL,
		[ComplaintSID]                   [int] NULL,
		[UserDefinedColumns]             [xml] NULL,
		[RegistrationChangeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationChange_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationChange_RegistrationSID]
		UNIQUE
		NONCLUSTERED
		([RegistrationSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationChange]
		PRIMARY KEY
		CLUSTERED
		([RegistrationChangeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Change table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'pk_RegistrationChange'
GO
ALTER TABLE [dbo].[RegistrationChange]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationChange]
	CHECK
	([dbo].[fRegistrationChange#Check]([RegistrationChangeSID],[RegistrationSID],[PracticeRegisterSectionSID],[RegistrationYear],[NextFollowUp],[RegistrationEffective],[ReservedRegistrantNo],[ReasonSID],[InvoiceSID],[ComplaintSID],[RegistrationChangeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationChange]
CHECK CONSTRAINT [ck_RegistrationChange]
GO
ALTER TABLE [dbo].[RegistrationChange]
	ADD
	CONSTRAINT [df_RegistrationChange_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationChange]
	ADD
	CONSTRAINT [df_RegistrationChange_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationChange]
	ADD
	CONSTRAINT [df_RegistrationChange_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationChange]
	ADD
	CONSTRAINT [df_RegistrationChange_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationChange]
	ADD
	CONSTRAINT [df_RegistrationChange_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationChange]
	ADD
	CONSTRAINT [df_RegistrationChange_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationChange]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChange_Complaint_ComplaintSID]
	FOREIGN KEY ([ComplaintSID]) REFERENCES [dbo].[Complaint] ([ComplaintSID])
ALTER TABLE [dbo].[RegistrationChange]
	CHECK CONSTRAINT [fk_RegistrationChange_Complaint_ComplaintSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint system ID column in the Registration Change table match a complaint system ID in the Complaint table. It also ensures that records in the Complaint table cannot be deleted if matching child records exist in Registration Change. Finally, the constraint blocks changes to the value of the complaint system ID column in the Complaint if matching child records exist in Registration Change.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'fk_RegistrationChange_Complaint_ComplaintSID'
GO
ALTER TABLE [dbo].[RegistrationChange]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChange_Invoice_InvoiceSID]
	FOREIGN KEY ([InvoiceSID]) REFERENCES [dbo].[Invoice] ([InvoiceSID])
ALTER TABLE [dbo].[RegistrationChange]
	CHECK CONSTRAINT [fk_RegistrationChange_Invoice_InvoiceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice system ID column in the Registration Change table match a invoice system ID in the Invoice table. It also ensures that records in the Invoice table cannot be deleted if matching child records exist in Registration Change. Finally, the constraint blocks changes to the value of the invoice system ID column in the Invoice if matching child records exist in Registration Change.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'fk_RegistrationChange_Invoice_InvoiceSID'
GO
ALTER TABLE [dbo].[RegistrationChange]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChange_Registration_RegistrationSID]
	FOREIGN KEY ([RegistrationSID]) REFERENCES [dbo].[Registration] ([RegistrationSID])
ALTER TABLE [dbo].[RegistrationChange]
	CHECK CONSTRAINT [fk_RegistrationChange_Registration_RegistrationSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration system ID column in the Registration Change table match a registration system ID in the Registration table. It also ensures that records in the Registration table cannot be deleted if matching child records exist in Registration Change. Finally, the constraint blocks changes to the value of the registration system ID column in the Registration if matching child records exist in Registration Change.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'fk_RegistrationChange_Registration_RegistrationSID'
GO
ALTER TABLE [dbo].[RegistrationChange]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChange_PracticeRegisterSection_PracticeRegisterSectionSID]
	FOREIGN KEY ([PracticeRegisterSectionSID]) REFERENCES [dbo].[PracticeRegisterSection] ([PracticeRegisterSectionSID])
ALTER TABLE [dbo].[RegistrationChange]
	CHECK CONSTRAINT [fk_RegistrationChange_PracticeRegisterSection_PracticeRegisterSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register section system ID column in the Registration Change table match a practice register section system ID in the Practice Register Section table. It also ensures that records in the Practice Register Section table cannot be deleted if matching child records exist in Registration Change. Finally, the constraint blocks changes to the value of the practice register section system ID column in the Practice Register Section if matching child records exist in Registration Change.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'fk_RegistrationChange_PracticeRegisterSection_PracticeRegisterSectionSID'
GO
ALTER TABLE [dbo].[RegistrationChange]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChange_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[RegistrationChange]
	CHECK CONSTRAINT [fk_RegistrationChange_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Registration Change table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Registration Change. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Registration Change.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'fk_RegistrationChange_Reason_ReasonSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChange_ComplaintSID_RegistrationChangeSID]
	ON [dbo].[RegistrationChange] ([ComplaintSID], [RegistrationChangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint SID foreign key column and avoids row contention on (parent) Complaint updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'INDEX', N'ix_RegistrationChange_ComplaintSID_RegistrationChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChange_InvoiceSID_RegistrationChangeSID]
	ON [dbo].[RegistrationChange] ([InvoiceSID], [RegistrationChangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice SID foreign key column and avoids row contention on (parent) Invoice updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'INDEX', N'ix_RegistrationChange_InvoiceSID_RegistrationChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChange_PracticeRegisterSectionSID_RegistrationChangeSID]
	ON [dbo].[RegistrationChange] ([PracticeRegisterSectionSID], [RegistrationChangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Section SID foreign key column and avoids row contention on (parent) Practice Register Section updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'INDEX', N'ix_RegistrationChange_PracticeRegisterSectionSID_RegistrationChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChange_ReasonSID_RegistrationChangeSID]
	ON [dbo].[RegistrationChange] ([ReasonSID], [RegistrationChangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'INDEX', N'ix_RegistrationChange_ReasonSID_RegistrationChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChange_RegistrationYear_NextFollowUp]
	ON [dbo].[RegistrationChange] ([RegistrationYear], [NextFollowUp])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registration Change searches based on the Registration Year + Next Follow Up columns', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'INDEX', N'ix_RegistrationChange_RegistrationYear_NextFollowUp'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrationChange_InvoiceSID]
	ON [dbo].[RegistrationChange] ([InvoiceSID])
	WHERE (([InvoiceSID] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Invoice SID value is not duplicated where the condition: "([InvoiceSID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'INDEX', N'ux_RegistrationChange_InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'RegistrationChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration this change is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register section assigned to this registration change', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional value set on approval to override the default effective date of the permit/license created', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'RegistrationEffective'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number to assign to this registrant when they achieve their first "active-practice" registration  | This value is used when migration is enabled', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'ReservedRegistrantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registration change', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this registration change', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration change | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'RegistrationChangeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration change | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration change record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration change | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration change record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration change record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'uk_RegistrationChange_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration SID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChange', 'CONSTRAINT', N'uk_RegistrationChange_RegistrationSID'
GO
ALTER TABLE [dbo].[RegistrationChange] SET (LOCK_ESCALATION = TABLE)
GO
