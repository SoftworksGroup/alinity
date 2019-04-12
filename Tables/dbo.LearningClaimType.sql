SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LearningClaimType] (
		[LearningClaimTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[LearningClaimTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LearningClaimTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsValidForRenewal]             [bit] NOT NULL,
		[IsComplete]                    [bit] NOT NULL,
		[IsWithdrawn]                   [bit] NOT NULL,
		[IsDefault]                     [bit] NOT NULL,
		[IsActive]                      [bit] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[LearningClaimTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_LearningClaimType_LearningClaimTypeLabel]
		UNIQUE
		NONCLUSTERED
		([LearningClaimTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_LearningClaimType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_LearningClaimType]
		PRIMARY KEY
		CLUSTERED
		([LearningClaimTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Learning Claim Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'CONSTRAINT', N'pk_LearningClaimType'
GO
ALTER TABLE [dbo].[LearningClaimType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_LearningClaimType]
	CHECK
	([dbo].[fLearningClaimType#Check]([LearningClaimTypeSID],[LearningClaimTypeLabel],[LearningClaimTypeCategory],[IsValidForRenewal],[IsComplete],[IsWithdrawn],[IsDefault],[IsActive],[LearningClaimTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[LearningClaimType]
CHECK CONSTRAINT [ck_LearningClaimType]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_IsComplete]
	DEFAULT ((0)) FOR [IsComplete]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_IsValidForRenewal]
	DEFAULT (CONVERT([bit],(1))) FOR [IsValidForRenewal]
GO
ALTER TABLE [dbo].[LearningClaimType]
	ADD
	CONSTRAINT [df_LearningClaimType_IsWithdrawn]
	DEFAULT (CONVERT([bit],(0))) FOR [IsWithdrawn]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_LearningClaimType_IsDefault]
	ON [dbo].[LearningClaimType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Learning Claim Type', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'INDEX', N'ux_LearningClaimType_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_LearningClaimType_LegacyKey]
	ON [dbo].[LearningClaimType] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'INDEX', N'ux_LearningClaimType_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the learning claim type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'LearningClaimTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the learning claim type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'LearningClaimTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'LearningClaimTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When not checked, this item is only valid during planning and not for claiming at renewal time (e.g. "Unknown")', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'IsValidForRenewal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the learning activity is to be considered complete and included in the total credits/hours for the learning cycle', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'IsComplete'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the learning plan activity has been removed (equivalent to deleted)', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'IsWithdrawn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default learning claim type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this learning claim type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the learning claim type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'LearningClaimTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the learning claim type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this learning claim type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the learning claim type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the learning claim type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning claim type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Learning Claim Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'CONSTRAINT', N'uk_LearningClaimType_LearningClaimTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningClaimType', 'CONSTRAINT', N'uk_LearningClaimType_RowGUID'
GO
ALTER TABLE [dbo].[LearningClaimType] SET (LOCK_ESCALATION = TABLE)
GO
