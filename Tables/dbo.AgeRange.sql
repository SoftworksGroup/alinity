SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AgeRange] (
		[AgeRangeSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[AgeRangeTypeSID]        [int] NOT NULL,
		[AgeRangeLabel]          [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StartAge]               [smallint] NOT NULL,
		[EndAge]                 [smallint] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[AgeRangeXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_AgeRange_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AgeRange_AgeRangeLabel]
		UNIQUE
		NONCLUSTERED
		([AgeRangeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AgeRange]
		PRIMARY KEY
		CLUSTERED
		([AgeRangeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Age Range table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'CONSTRAINT', N'pk_AgeRange'
GO
ALTER TABLE [dbo].[AgeRange]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AgeRange]
	CHECK
	([dbo].[fAgeRange#Check]([AgeRangeSID],[AgeRangeTypeSID],[AgeRangeLabel],[StartAge],[EndAge],[IsDefault],[AgeRangeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[AgeRange]
CHECK CONSTRAINT [ck_AgeRange]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[AgeRange]
	ADD
	CONSTRAINT [df_AgeRange_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[AgeRange]
	WITH CHECK
	ADD CONSTRAINT [fk_AgeRange_AgeRangeType_AgeRangeTypeSID]
	FOREIGN KEY ([AgeRangeTypeSID]) REFERENCES [dbo].[AgeRangeType] ([AgeRangeTypeSID])
ALTER TABLE [dbo].[AgeRange]
	CHECK CONSTRAINT [fk_AgeRange_AgeRangeType_AgeRangeTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the age range type system ID column in the Age Range table match a age range type system ID in the Age Range Type table. It also ensures that records in the Age Range Type table cannot be deleted if matching child records exist in Age Range. Finally, the constraint blocks changes to the value of the age range type system ID column in the Age Range Type if matching child records exist in Age Range.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'CONSTRAINT', N'fk_AgeRange_AgeRangeType_AgeRangeTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_AgeRange_AgeRangeTypeSID_AgeRangeSID]
	ON [dbo].[AgeRange] ([AgeRangeTypeSID], [AgeRangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Age Range Type SID foreign key column and avoids row contention on (parent) Age Range Type updates', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'INDEX', N'ix_AgeRange_AgeRangeTypeSID_AgeRangeSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AgeRange_IsDefault]
	ON [dbo].[AgeRange] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Age Range', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'INDEX', N'ux_AgeRange_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to define a list of age ranges used through the system. These values are used to describe target age ranges for registrant-practices and in certain reporting scenarios. Note that age ranges must be configured so that the set of age ranges for the type includes all possible ages.  Use 0 (years) and 999 (years - 3 digits!) at the ends of the first and last range entered for the set.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'AgeRangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'AgeRangeTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the age range to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'AgeRangeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Starting age in years for the range', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'StartAge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ending age in years for the range', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'EndAge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default age range to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the age range | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'AgeRangeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the age range | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this age range record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the age range | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the age range record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the age range record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'CONSTRAINT', N'uk_AgeRange_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Age Range Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'AgeRange', 'CONSTRAINT', N'uk_AgeRange_AgeRangeLabel'
GO
ALTER TABLE [dbo].[AgeRange] SET (LOCK_ESCALATION = TABLE)
GO
