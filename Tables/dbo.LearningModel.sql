SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LearningModel] (
		[LearningModelSID]        [int] IDENTITY(1000001, 1) NOT NULL,
		[LearningModelSCD]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LearningModelLabel]      [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]               [bit] NOT NULL,
		[UnitTypeSID]             [int] NULL,
		[CycleLengthYears]        [smallint] NOT NULL,
		[IsCycleStartedYear1]     [bit] NOT NULL,
		[MaximumCarryOver]        [decimal](5, 2) NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[LearningModelXID]        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_LearningModel_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_LearningModel_LearningModelSCD]
		UNIQUE
		NONCLUSTERED
		([LearningModelSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_LearningModel_LearningModelLabel]
		UNIQUE
		NONCLUSTERED
		([LearningModelLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_LearningModel]
		PRIMARY KEY
		CLUSTERED
		([LearningModelSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Learning Model table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'CONSTRAINT', N'pk_LearningModel'
GO
ALTER TABLE [dbo].[LearningModel]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_LearningModel]
	CHECK
	([dbo].[fLearningModel#Check]([LearningModelSID],[LearningModelSCD],[LearningModelLabel],[IsDefault],[UnitTypeSID],[CycleLengthYears],[IsCycleStartedYear1],[MaximumCarryOver],[LearningModelXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[LearningModel]
CHECK CONSTRAINT [ck_LearningModel]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_CycleLengthYears]
	DEFAULT ((1)) FOR [CycleLengthYears]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_IsCycleStartedYear1]
	DEFAULT (CONVERT([bit],(0))) FOR [IsCycleStartedYear1]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_MaximumCarryOver]
	DEFAULT ((999.9)) FOR [MaximumCarryOver]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[LearningModel]
	ADD
	CONSTRAINT [df_LearningModel_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[LearningModel]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningModel_SF_UnitType_UnitTypeSID]
	FOREIGN KEY ([UnitTypeSID]) REFERENCES [sf].[UnitType] ([UnitTypeSID])
ALTER TABLE [dbo].[LearningModel]
	CHECK CONSTRAINT [fk_LearningModel_SF_UnitType_UnitTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the unit type system ID column in the Learning Model table match a unit type system ID in the Unit Type table. It also ensures that records in the Unit Type table cannot be deleted if matching child records exist in Learning Model. Finally, the constraint blocks changes to the value of the unit type system ID column in the Unit Type if matching child records exist in Learning Model.', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'CONSTRAINT', N'fk_LearningModel_SF_UnitType_UnitTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningModel_UnitTypeSID_LearningModelSID]
	ON [dbo].[LearningModel] ([UnitTypeSID], [LearningModelSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Unit Type SID foreign key column and avoids row contention on (parent) Unit Type updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'INDEX', N'ix_LearningModel_UnitTypeSID_LearningModelSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_LearningModel_IsDefault]
	ON [dbo].[LearningModel] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Learning Model', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'INDEX', N'ux_LearningModel_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the learning model assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'LearningModelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the learning model | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'LearningModelSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the learning model to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'LearningModelLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default learning model to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'UnitTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the length of time in years the member has to complete the learning plan requirements', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'CycleLengthYears'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if CE reporting begins in the first year of active practice | Otherwise CE plan records are created starting in year 2 - the first full year of practice', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'IsCycleStartedYear1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of units that can be applied to the next cycle across ALL learning requirements (or set at the Learning Requirement level only) - default is 9999 (not limited at this level)', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'MaximumCarryOver'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the learning model | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'LearningModelXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the learning model | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this learning model record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the learning model | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the learning model record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning model record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'CONSTRAINT', N'uk_LearningModel_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Learning Model SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'CONSTRAINT', N'uk_LearningModel_LearningModelSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Learning Model Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningModel', 'CONSTRAINT', N'uk_LearningModel_LearningModelLabel'
GO
ALTER TABLE [dbo].[LearningModel] SET (LOCK_ESCALATION = TABLE)
GO
