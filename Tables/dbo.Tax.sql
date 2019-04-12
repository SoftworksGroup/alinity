SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Tax] (
		[TaxSID]                 [int] IDENTITY(1000001, 1) NOT NULL,
		[TaxLabel]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TaxSequence]            [tinyint] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[TaxXID]                 [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Tax_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Tax_TaxLabel]
		UNIQUE
		NONCLUSTERED
		([TaxLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Tax]
		PRIMARY KEY
		CLUSTERED
		([TaxSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Tax table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'CONSTRAINT', N'pk_Tax'
GO
ALTER TABLE [dbo].[Tax]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Tax]
	CHECK
	([dbo].[fTax#Check]([TaxSID],[TaxLabel],[TaxSequence],[TaxXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Tax]
CHECK CONSTRAINT [ck_Tax]
GO
ALTER TABLE [dbo].[Tax]
	ADD
	CONSTRAINT [df_Tax_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Tax]
	ADD
	CONSTRAINT [df_Tax_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Tax]
	ADD
	CONSTRAINT [df_Tax_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Tax]
	ADD
	CONSTRAINT [df_Tax_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Tax]
	ADD
	CONSTRAINT [df_Tax_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Tax]
	ADD
	CONSTRAINT [df_Tax_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the tax assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'TaxSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the tax to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'TaxLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of sequence of this tax in the list of taxes to be presented on invoices.  For example, if you want "GST" to appear 1st, then assign it number 1.  The current version of the system  supports a maximum of 3 tax types so this value must be 1, 2 or 3.  ', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'TaxSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the tax | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'TaxXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the tax | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this tax record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the tax | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the tax record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the tax record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'CONSTRAINT', N'uk_Tax_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Tax Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Tax', 'CONSTRAINT', N'uk_Tax_TaxLabel'
GO
ALTER TABLE [dbo].[Tax] SET (LOCK_ESCALATION = TABLE)
GO
