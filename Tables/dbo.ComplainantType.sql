SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplainantType] (
		[ComplainantTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplainantTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ComplainantTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                   [bit] NOT NULL,
		[Description]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]                    [bit] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[ComplainantTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplainantType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ComplainantType_ComplainantTypeLabel]
		UNIQUE
		NONCLUSTERED
		([ComplainantTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplainantType]
		PRIMARY KEY
		CLUSTERED
		([ComplainantTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complainant Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'CONSTRAINT', N'pk_ComplainantType'
GO
ALTER TABLE [dbo].[ComplainantType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplainantType]
	CHECK
	([dbo].[fComplainantType#Check]([ComplainantTypeSID],[ComplainantTypeLabel],[ComplainantTypeCategory],[IsDefault],[IsActive],[ComplainantTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplainantType]
CHECK CONSTRAINT [ck_ComplainantType]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplainantType]
	ADD
	CONSTRAINT [df_ComplainantType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ComplainantType_IsDefault]
	ON [dbo].[ComplainantType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Complainant Type', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'INDEX', N'ux_ComplainantType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complainant type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complainant type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'ComplainantTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'ComplainantTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complainant type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complainant type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complainant type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'ComplainantTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complainant type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complainant type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complainant type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complainant type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complainant type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'CONSTRAINT', N'uk_ComplainantType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Complainant Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplainantType', 'CONSTRAINT', N'uk_ComplainantType_ComplainantTypeLabel'
GO
ALTER TABLE [dbo].[ComplainantType] SET (LOCK_ESCALATION = TABLE)
GO
