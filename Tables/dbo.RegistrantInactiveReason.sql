SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantInactiveReason] (
		[RegistrantInactiveReasonSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantInactiveReasonLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]                          [bit] NOT NULL,
		[UserDefinedColumns]                [xml] NULL,
		[RegistrantInactiveReasonXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                         [bit] NOT NULL,
		[CreateUser]                        [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                        [datetimeoffset](7) NOT NULL,
		[UpdateUser]                        [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                        [datetimeoffset](7) NOT NULL,
		[RowGUID]                           [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                          [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantInactiveReason_RegistrantInactiveReasonLabel]
		UNIQUE
		NONCLUSTERED
		([RegistrantInactiveReasonLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrantInactiveReason_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantInactiveReason]
		PRIMARY KEY
		CLUSTERED
		([RegistrantInactiveReasonSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Inactive Reason table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'CONSTRAINT', N'pk_RegistrantInactiveReason'
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantInactiveReason]
	CHECK
	([dbo].[fRegistrantInactiveReason#Check]([RegistrantInactiveReasonSID],[RegistrantInactiveReasonLabel],[IsActive],[RegistrantInactiveReasonXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
CHECK CONSTRAINT [ck_RegistrantInactiveReason]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantInactiveReason]
	ADD
	CONSTRAINT [df_RegistrantInactiveReason_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantInactiveReason_LegacyKey]
	ON [dbo].[RegistrantInactiveReason] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'INDEX', N'ux_RegistrantInactiveReason_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant inactive reason assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'RegistrantInactiveReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registrant inactive reason to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'RegistrantInactiveReasonLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registrant inactive reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant inactive reason | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'RegistrantInactiveReasonXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant inactive reason | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant inactive reason record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant inactive reason | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant inactive reason record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant inactive reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registrant Inactive Reason Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'CONSTRAINT', N'uk_RegistrantInactiveReason_RegistrantInactiveReasonLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantInactiveReason', 'CONSTRAINT', N'uk_RegistrantInactiveReason_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantInactiveReason] SET (LOCK_ESCALATION = TABLE)
GO
