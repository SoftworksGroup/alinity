SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationSchedule] (
		[RegistrationScheduleSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationScheduleLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                     [bit] NOT NULL,
		[IsActive]                      [bit] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[RegistrationScheduleXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationSchedule_RegistrationScheduleLabel]
		UNIQUE
		NONCLUSTERED
		([RegistrationScheduleLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationSchedule_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationSchedule]
		PRIMARY KEY
		CLUSTERED
		([RegistrationScheduleSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Schedule table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'CONSTRAINT', N'pk_RegistrationSchedule'
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationSchedule]
	CHECK
	([dbo].[fRegistrationSchedule#Check]([RegistrationScheduleSID],[RegistrationScheduleLabel],[IsDefault],[IsActive],[RegistrationScheduleXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationSchedule]
CHECK CONSTRAINT [ck_RegistrationSchedule]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationSchedule]
	ADD
	CONSTRAINT [df_RegistrationSchedule_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrationSchedule_IsDefault]
	ON [dbo].[RegistrationSchedule] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Registration Schedule', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'INDEX', N'ux_RegistrationSchedule_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'RegistrationScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'RegistrationScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default registration schedule to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registration schedule record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration schedule | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'RegistrationScheduleXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration schedule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration schedule record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration schedule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration schedule record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Schedule Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'CONSTRAINT', N'uk_RegistrationSchedule_RegistrationScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSchedule', 'CONSTRAINT', N'uk_RegistrationSchedule_RowGUID'
GO
ALTER TABLE [dbo].[RegistrationSchedule] SET (LOCK_ESCALATION = TABLE)
GO
