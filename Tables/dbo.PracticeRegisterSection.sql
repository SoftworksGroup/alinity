SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterSection] (
		[PracticeRegisterSectionSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterSID]              [int] NOT NULL,
		[PracticeRegisterSectionLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                        [bit] NOT NULL,
		[IsDisplayedOnLicense]             [bit] NOT NULL,
		[Description]                      [varbinary](max) NULL,
		[IsActive]                         [bit] NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[PracticeRegisterSectionXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterSection_PracticeRegisterSID_PracticeRegisterSectionLabel]
		UNIQUE
		NONCLUSTERED
		([PracticeRegisterSID], [PracticeRegisterSectionLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeRegisterSection_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterSection]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterSectionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Section table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'CONSTRAINT', N'pk_PracticeRegisterSection'
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterSection]
	CHECK
	([dbo].[fPracticeRegisterSection#Check]([PracticeRegisterSectionSID],[PracticeRegisterSID],[PracticeRegisterSectionLabel],[IsDefault],[IsDisplayedOnLicense],[IsActive],[PracticeRegisterSectionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
CHECK CONSTRAINT [ck_PracticeRegisterSection]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_IsDisplayedOnLicense]
	DEFAULT (CONVERT([bit],(0))) FOR [IsDisplayedOnLicense]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	ADD
	CONSTRAINT [df_PracticeRegisterSection_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterSection]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterSection_PracticeRegister_PracticeRegisterSID]
	FOREIGN KEY ([PracticeRegisterSID]) REFERENCES [dbo].[PracticeRegister] ([PracticeRegisterSID])
ALTER TABLE [dbo].[PracticeRegisterSection]
	CHECK CONSTRAINT [fk_PracticeRegisterSection_PracticeRegister_PracticeRegisterSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register system ID column in the Practice Register Section table match a practice register system ID in the Practice Register table. It also ensures that records in the Practice Register table cannot be deleted if matching child records exist in Practice Register Section. Finally, the constraint blocks changes to the value of the practice register system ID column in the Practice Register if matching child records exist in Practice Register Section.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'CONSTRAINT', N'fk_PracticeRegisterSection_PracticeRegister_PracticeRegisterSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegisterSection_LegacyKey]
	ON [dbo].[PracticeRegisterSection] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'INDEX', N'ux_PracticeRegisterSection_LegacyKey'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegisterSection_PracticeRegisterSID_IsDefault]
	ON [dbo].[PracticeRegisterSection] ([PracticeRegisterSID], [IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Practice Register Section for each Practice Register SID', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'INDEX', N'ux_PracticeRegisterSection_PracticeRegisterSID_IsDefault'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterSection_PracticeRegisterSID_PracticeRegisterSectionSID]
	ON [dbo].[PracticeRegisterSection] ([PracticeRegisterSID], [PracticeRegisterSectionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register SID foreign key column and avoids row contention on (parent) Practice Register updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'INDEX', N'ix_PracticeRegisterSection_PracticeRegisterSID_PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Practice Registration Section table allows applicants and licensees to be categorized into sections within the practice register.  The sections may refer to some type of status or standing - e.g. "Certified", "Deemed Competent" or the category may define a work-scenario - Rural, Urban, Long-Term Care, Acute Care, etc.  If your configuration does not require Register Sections, you must still provide a default.  For example, name the default "Full" and turn off the "Is Displayed On License" option to prevent including the section label on cards and reports.  The Revenue Item specified in this table is intended to identify an optional surcharge to be applied for applicants in that section of the register.  For example, international grads may be required to pay an additional administrative fee that is not required of those in the local/national section of the register.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register section assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register this section is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register section to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register section to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this section should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a section accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this document type applies to - available as help text on document type selection. This field is varbinary to ensure any searches done on this field disregard taged text and only search content text. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register section record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register section | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register section | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register section record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register section | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register section record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register section record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Practice Register SID + Practice Register Section Label" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'CONSTRAINT', N'uk_PracticeRegisterSection_PracticeRegisterSID_PracticeRegisterSectionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterSection', 'CONSTRAINT', N'uk_PracticeRegisterSection_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterSection] SET (LOCK_ESCALATION = TABLE)
GO
