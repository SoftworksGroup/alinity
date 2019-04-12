SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterType] (
		[PracticeRegisterTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterTypeSCD]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PracticeRegisterTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PracticeRegisterTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                        [bit] NOT NULL,
		[Description]                      [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]                         [bit] NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[PracticeRegisterTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterType_PracticeRegisterTypeLabel]
		UNIQUE
		NONCLUSTERED
		([PracticeRegisterTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeRegisterType_PracticeRegisterTypeSCD]
		UNIQUE
		NONCLUSTERED
		([PracticeRegisterTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeRegisterType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterType]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'CONSTRAINT', N'pk_PracticeRegisterType'
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterType]
	CHECK
	([dbo].[fPracticeRegisterType#Check]([PracticeRegisterTypeSID],[PracticeRegisterTypeSCD],[PracticeRegisterTypeLabel],[PracticeRegisterTypeCategory],[IsDefault],[IsActive],[PracticeRegisterTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterType]
CHECK CONSTRAINT [ck_PracticeRegisterType]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterType]
	ADD
	CONSTRAINT [df_PracticeRegisterType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegisterType_IsDefault]
	ON [dbo].[PracticeRegisterType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Practice Register Type', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'INDEX', N'ux_PracticeRegisterType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'PracticeRegisterTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the practice register type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'PracticeRegisterTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'PracticeRegisterTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'PracticeRegisterTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this register type applies to - available as help text on selection. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'PracticeRegisterTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Register Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'CONSTRAINT', N'uk_PracticeRegisterType_PracticeRegisterTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Register Type SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'CONSTRAINT', N'uk_PracticeRegisterType_PracticeRegisterTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterType', 'CONSTRAINT', N'uk_PracticeRegisterType_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterType] SET (LOCK_ESCALATION = TABLE)
GO
