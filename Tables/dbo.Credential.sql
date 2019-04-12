SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Credential] (
		[CredentialSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[CredentialTypeSID]         [int] NOT NULL,
		[CredentialLabel]           [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ToolTip]                   [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsRelatedToProfession]     [bit] NOT NULL,
		[IsProgramRequired]         [bit] NOT NULL,
		[IsSpecialization]          [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[CredentialCode]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[CredentialXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_Credential_CredentialLabel]
		UNIQUE
		NONCLUSTERED
		([CredentialLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Credential_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Credential]
		PRIMARY KEY
		CLUSTERED
		([CredentialSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Credential table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'CONSTRAINT', N'pk_Credential'
GO
ALTER TABLE [dbo].[Credential]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Credential]
	CHECK
	([dbo].[fCredential#Check]([CredentialSID],[CredentialTypeSID],[CredentialLabel],[ToolTip],[IsRelatedToProfession],[IsProgramRequired],[IsSpecialization],[IsActive],[CredentialCode],[CredentialXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Credential]
CHECK CONSTRAINT [ck_Credential]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_IsRelatedToProfession]
	DEFAULT (CONVERT([bit],(0))) FOR [IsRelatedToProfession]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_IsProgramRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsProgramRequired]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_IsSpecialization]
	DEFAULT (CONVERT([bit],(0))) FOR [IsSpecialization]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_CredentialCode]
	DEFAULT ('9') FOR [CredentialCode]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Credential]
	ADD
	CONSTRAINT [df_Credential_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Credential]
	WITH CHECK
	ADD CONSTRAINT [fk_Credential_CredentialType_CredentialTypeSID]
	FOREIGN KEY ([CredentialTypeSID]) REFERENCES [dbo].[CredentialType] ([CredentialTypeSID])
ALTER TABLE [dbo].[Credential]
	CHECK CONSTRAINT [fk_Credential_CredentialType_CredentialTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the credential type system ID column in the Credential table match a credential type system ID in the Credential Type table. It also ensures that records in the Credential Type table cannot be deleted if matching child records exist in Credential. Finally, the constraint blocks changes to the value of the credential type system ID column in the Credential Type if matching child records exist in Credential.', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'CONSTRAINT', N'fk_Credential_CredentialType_CredentialTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_Credential_CredentialTypeSID_CredentialSID]
	ON [dbo].[Credential] ([CredentialTypeSID], [CredentialSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Credential Type SID foreign key column and avoids row contention on (parent) Credential Type updates', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'INDEX', N'ix_Credential_CredentialTypeSID_CredentialSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Credential_LegacyKey]
	ON [dbo].[Credential] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'INDEX', N'ux_Credential_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The credential defines a master list of educational or training programs recognized by the College.  Each credential can be fiurther defined as relevant for a specific practice register through the "Practice Register Credential" table.  The credential values appear to applicants and licensees on application and renewal forms in the "Education" section.  An organization must always be identified with each credential.  Each combination of organization and Program Name must be unique.', 'SCHEMA', N'dbo', 'TABLE', N'Credential', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the credential assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of credential', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CredentialTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the credential to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CredentialLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short explanatory text describing the credential often shown to end-users on mouse-over and/or press of info button', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this credential is related to professional practice | This value is automaticallly set on by the application where the credential is set a qualifying', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'IsRelatedToProfession'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if a program-name must be entered when this credential is claimed | This option should be checked if the credential is a generic type like "Diploma", "Certificate", etc. where a specific field of study is not mentioned.', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'IsProgramRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this credential should be displayed as a specialization on the license/permit and Public Directory', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'IsSpecialization'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this credential record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code used to report on this credential either internally or externally.  The code for CIHI for "Not Provided" is "9" (set as default)', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CredentialCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the credential | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CredentialXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the credential | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this credential record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the credential | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the credential record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the credential record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Credential Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'CONSTRAINT', N'uk_Credential_CredentialLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Credential', 'CONSTRAINT', N'uk_Credential_RowGUID'
GO
ALTER TABLE [dbo].[Credential] SET (LOCK_ESCALATION = TABLE)
GO
