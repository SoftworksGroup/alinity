SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRestriction] (
		[PracticeRestrictionSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRestrictionLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDisplayedOnLicense]         [bit] NOT NULL,
		[Description]                  [varbinary](max) NULL,
		[IsActive]                     [bit] NOT NULL,
		[IsSupervisionRequired]        [bit] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[PracticeRestrictionXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRestriction_PracticeRestrictionLabel]
		UNIQUE
		NONCLUSTERED
		([PracticeRestrictionLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeRestriction_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRestriction]
		PRIMARY KEY
		CLUSTERED
		([PracticeRestrictionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Restriction table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'CONSTRAINT', N'pk_PracticeRestriction'
GO
ALTER TABLE [dbo].[PracticeRestriction]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRestriction]
	CHECK
	([dbo].[fPracticeRestriction#Check]([PracticeRestrictionSID],[PracticeRestrictionLabel],[IsDisplayedOnLicense],[IsActive],[IsSupervisionRequired],[PracticeRestrictionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRestriction]
CHECK CONSTRAINT [ck_PracticeRestriction]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_IsDisplayedOnLicense]
	DEFAULT ((1)) FOR [IsDisplayedOnLicense]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_IsSupervisionRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsSupervisionRequired]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRestriction]
	ADD
	CONSTRAINT [df_PracticeRestriction_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRestriction_LegacyKey]
	ON [dbo].[PracticeRestriction] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'INDEX', N'ux_PracticeRestriction_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'PracticeRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice restriction to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'PracticeRestrictionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this restriction should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a restriction accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this document type applies to - available as help text on document type selection. This field is varbinary to ensure any searches done on this field disregard taged text and only search content text. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice restriction record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this condition-on-practice requires that a supervisor be identified to review/enforce the conditio', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'IsSupervisionRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice restriction | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'PracticeRestrictionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice restriction record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice restriction record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice restriction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Restriction Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'CONSTRAINT', N'uk_PracticeRestriction_PracticeRestrictionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRestriction', 'CONSTRAINT', N'uk_PracticeRestriction_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRestriction] SET (LOCK_ESCALATION = TABLE)
GO
