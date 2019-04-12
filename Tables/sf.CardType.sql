SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[CardType] (
		[CardTypeSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[CardTypeSCD]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CardTypeLabel]          [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[CardTypeXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_CardType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CardType_CardTypeSCD]
		UNIQUE
		NONCLUSTERED
		([CardTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CardType_CardTypeLabel]
		UNIQUE
		NONCLUSTERED
		([CardTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CardType]
		PRIMARY KEY
		CLUSTERED
		([CardTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Card Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'CONSTRAINT', N'pk_CardType'
GO
ALTER TABLE [sf].[CardType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CardType]
	CHECK
	([sf].[fCardType#Check]([CardTypeSID],[CardTypeSCD],[CardTypeLabel],[CardTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[CardType]
CHECK CONSTRAINT [ck_CardType]
GO
ALTER TABLE [sf].[CardType]
	ADD
	CONSTRAINT [df_CardType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[CardType]
	ADD
	CONSTRAINT [df_CardType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[CardType]
	ADD
	CONSTRAINT [df_CardType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[CardType]
	ADD
	CONSTRAINT [df_CardType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[CardType]
	ADD
	CONSTRAINT [df_CardType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[CardType]
	ADD
	CONSTRAINT [df_CardType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of card types supported by application.  These card types are used internally by the program and do not correspond to end-user classification of cards. The list of card types cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Specific application logic detects each card type using the Card-Type-SCD value from this table.  Each configuration may also set the default owner associated with each', 'SCHEMA', N'sf', 'TABLE', N'CardType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the card type assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'CardTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the card type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'CardTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the card type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'CardTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the audit action - e.g. "Patient record access"', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the card type | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'CardTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the card type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this card type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the card type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the card type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the card type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'CONSTRAINT', N'uk_CardType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Card Type SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'CONSTRAINT', N'uk_CardType_CardTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Card Type Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'CardType', 'CONSTRAINT', N'uk_CardType_CardTypeLabel'
GO
ALTER TABLE [sf].[CardType] SET (LOCK_ESCALATION = TABLE)
GO
