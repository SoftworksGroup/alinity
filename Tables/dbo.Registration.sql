SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Registration] (
		[RegistrationSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]                  [int] NOT NULL,
		[PracticeRegisterSectionSID]     [int] NOT NULL,
		[RegistrationNo]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrationYear]               [smallint] NOT NULL,
		[EffectiveTime]                  [datetime] NOT NULL,
		[ExpiryTime]                     [datetime] NOT NULL,
		[CardPrintedTime]                [datetime] NULL,
		[InvoiceSID]                     [int] NULL,
		[ReasonSID]                      [int] NULL,
		[FormGUID]                       [uniqueidentifier] NULL,
		[UserDefinedColumns]             [xml] NULL,
		[RegistrationXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_Registration_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Registration_RegistrationNo]
		UNIQUE
		NONCLUSTERED
		([RegistrationNo])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Registration_RegistrantSID_EffectiveTime]
		UNIQUE
		NONCLUSTERED
		([RegistrantSID], [EffectiveTime])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Registration]
		PRIMARY KEY
		CLUSTERED
		([RegistrationSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'pk_Registration'
GO
ALTER TABLE [dbo].[Registration]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Registration]
	CHECK
	([dbo].[fRegistration#Check]([RegistrationSID],[RegistrantSID],[PracticeRegisterSectionSID],[RegistrationNo],[RegistrationYear],[EffectiveTime],[ExpiryTime],[CardPrintedTime],[InvoiceSID],[ReasonSID],[FormGUID],[RegistrationXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Registration]
CHECK CONSTRAINT [ck_Registration]
GO
ALTER TABLE [dbo].[Registration]
	ADD
	CONSTRAINT [df_Registration_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Registration]
	ADD
	CONSTRAINT [df_Registration_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Registration]
	ADD
	CONSTRAINT [df_Registration_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Registration]
	ADD
	CONSTRAINT [df_Registration_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Registration]
	ADD
	CONSTRAINT [df_Registration_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Registration]
	ADD
	CONSTRAINT [df_Registration_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Registration]
	WITH CHECK
	ADD CONSTRAINT [fk_Registration_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[Registration]
	CHECK CONSTRAINT [fk_Registration_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registration table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registration. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registration.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'fk_Registration_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[Registration]
	WITH CHECK
	ADD CONSTRAINT [fk_Registration_PracticeRegisterSection_PracticeRegisterSectionSID]
	FOREIGN KEY ([PracticeRegisterSectionSID]) REFERENCES [dbo].[PracticeRegisterSection] ([PracticeRegisterSectionSID])
ALTER TABLE [dbo].[Registration]
	CHECK CONSTRAINT [fk_Registration_PracticeRegisterSection_PracticeRegisterSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register section system ID column in the Registration table match a practice register section system ID in the Practice Register Section table. It also ensures that records in the Practice Register Section table cannot be deleted if matching child records exist in Registration. Finally, the constraint blocks changes to the value of the practice register section system ID column in the Practice Register Section if matching child records exist in Registration.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'fk_Registration_PracticeRegisterSection_PracticeRegisterSectionSID'
GO
ALTER TABLE [dbo].[Registration]
	WITH CHECK
	ADD CONSTRAINT [fk_Registration_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[Registration]
	CHECK CONSTRAINT [fk_Registration_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Registration table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Registration. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Registration.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'fk_Registration_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[Registration]
	WITH CHECK
	ADD CONSTRAINT [fk_Registration_Invoice_InvoiceSID]
	FOREIGN KEY ([InvoiceSID]) REFERENCES [dbo].[Invoice] ([InvoiceSID])
ALTER TABLE [dbo].[Registration]
	CHECK CONSTRAINT [fk_Registration_Invoice_InvoiceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice system ID column in the Registration table match a invoice system ID in the Invoice table. It also ensures that records in the Invoice table cannot be deleted if matching child records exist in Registration. Finally, the constraint blocks changes to the value of the invoice system ID column in the Invoice if matching child records exist in Registration.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'fk_Registration_Invoice_InvoiceSID'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_InvoiceSID_RegistrationSID]
	ON [dbo].[Registration] ([InvoiceSID], [RegistrationSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice SID foreign key column and avoids row contention on (parent) Invoice updates', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_InvoiceSID_RegistrationSID'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_EffectiveTime_ExpiryTime]
	ON [dbo].[Registration] ([EffectiveTime], [ExpiryTime])
	INCLUDE ([RegistrationSID], [RegistrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registration searches based on the Effective Time + Expiry Time columns', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_EffectiveTime_ExpiryTime'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_ReasonSID_RegistrationSID]
	ON [dbo].[Registration] ([ReasonSID], [RegistrationSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_ReasonSID_RegistrationSID'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_RegistrantSID_RegistrationSID]
	ON [dbo].[Registration] ([RegistrantSID], [RegistrationSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_RegistrantSID_RegistrationSID'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_RegistrationYear_RegistrantSID]
	ON [dbo].[Registration] ([RegistrationYear], [RegistrantSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registration searches based on the Registration Year + Registrant SID columns', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_RegistrationYear_RegistrantSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Registration_LegacyKey]
	ON [dbo].[Registration] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ux_Registration_LegacyKey'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Registration_FormGUID]
	ON [dbo].[Registration] ([FormGUID])
	WHERE (([FormGUID] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Form GUID value is not duplicated where the condition: "([FormGUID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ux_Registration_FormGUID'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_FormGUID]
	ON [dbo].[Registration] ([FormGUID])
	INCLUDE ([RegistrationSID], [EffectiveTime], [ExpiryTime])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registration searches based on the Form GUID column', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_FormGUID'
GO
CREATE NONCLUSTERED INDEX [ix_Registration_PracticeRegisterSectionSID]
	ON [dbo].[Registration] ([PracticeRegisterSectionSID])
	INCLUDE ([RegistrationSID], [RegistrantSID], [RegistrationYear], [EffectiveTime], [ExpiryTime])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Section SID foreign key column and avoids row contention on (parent) Practice Register Section updates', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'INDEX', N'ix_Registration_PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This record represents the members registration, registration or permit.  The default product language refers to this record as the "registration".  A new record is created each year or each time a new registration is issued.  There are several sources of new registrations:  Application Forms, Renewal Forms, Reinstatement Forms, and Registration Change Forms.  Registration Change forms are processed by administrators while the other 3 sources are member initiated.  In all cases the registration is only created once the form has been approved and, if fees are owing, paid for.  The relationship to the source form is stored as the "FormGUID" which is a pointer to that form''s RowGUID.  The key of the invoice from the source form is copied into this record.  The invoice key can be looked up through the FormGUID but is copied redundantly here  to enable a FK constraint to block deletion/enforce RI since the relationship to the FormGUID is not a FK.  Any notes or administrator comments associated with the registration are associated with the source form.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register section assigned to this registration', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A combination of the Registrant No + Registration Year + Registration Sequence - e.g. 12345.2019.1 for the registrant 12345''s first registration of 2019.  This format is set by the application and cannot be modified. ', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'RegistrationNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when a card was printed (if the College prints cards for this Registration type)', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'CardPrintedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registration', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identifier for the member form (renewal, reinstatement) this registration resulted from if any | This value is blank if the registration was the result of an Administrator entered change since no member form is involved', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'FormGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'RegistrationXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'uk_Registration_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration No column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'uk_Registration_RegistrationNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registrant SID + Effective Time" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Registration', 'CONSTRAINT', N'uk_Registration_RegistrantSID_EffectiveTime'
GO
ALTER TABLE [dbo].[Registration] SET (LOCK_ESCALATION = TABLE)
GO
