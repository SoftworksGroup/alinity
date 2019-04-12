SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AgeRangeType] (
		[AgeRangeTypeSID]        [int] IDENTITY(1000001, 1) NOT NULL,
		[AgeRangeTypeLabel]      [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AgeRangeTypeCode]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[Description]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[AgeRangeTypeXID]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_AgeRangeType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AgeRangeType_AgeRangeTypeLabel]
		UNIQUE
		NONCLUSTERED
		([AgeRangeTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AgeRangeType_AgeRangeTypeCode]
		UNIQUE
		NONCLUSTERED
		([AgeRangeTypeCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AgeRangeType]
		PRIMARY KEY
		CLUSTERED
		([AgeRangeTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Age Range Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'CONSTRAINT', N'pk_AgeRangeType'
GO
ALTER TABLE [dbo].[AgeRangeType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AgeRangeType]
	CHECK
	([dbo].[fAgeRangeType#Check]([AgeRangeTypeSID],[AgeRangeTypeLabel],[AgeRangeTypeCode],[IsDefault],[AgeRangeTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[AgeRangeType]
CHECK CONSTRAINT [ck_AgeRangeType]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[AgeRangeType]
	ADD
	CONSTRAINT [df_AgeRangeType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AgeRangeType_IsDefault]
	ON [dbo].[AgeRangeType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Age Range Type', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'INDEX', N'ux_AgeRangeType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table allows age ranges to be grouped into types - for example:  registrant-practice, reporting, etc.  The default age-range-type must be set on the range type used to report on the ages of clients/patients served in professional practice.  A second age range is required by the system for reporting on member activity such as the time required to complete renewals, the general age profiles of the registers, etc.  Two age-range-type-code values are used to identify these 2 required ranges:  CLIENTAGE and MEMBERAGE.  These code values must not be edited.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'AgeRangeTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the age range type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'AgeRangeTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default age range type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the age range type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'AgeRangeTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the age range type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this age range type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the age range type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the age range type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the age range type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Age Range Type Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'CONSTRAINT', N'uk_AgeRangeType_AgeRangeTypeCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'CONSTRAINT', N'uk_AgeRangeType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Age Range Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'AgeRangeType', 'CONSTRAINT', N'uk_AgeRangeType_AgeRangeTypeLabel'
GO
ALTER TABLE [dbo].[AgeRangeType] SET (LOCK_ESCALATION = TABLE)
GO
