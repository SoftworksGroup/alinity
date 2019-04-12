SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormStatus] (
		[FormStatusSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[FormStatusSCD]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormStatusLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Description]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsFinal]                [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[FormStatusSequence]     [int] NOT NULL,
		[FormOwnerSID]           [int] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormStatusXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FormStatus_FormStatusLabel]
		UNIQUE
		NONCLUSTERED
		([FormStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormStatus_FormStatusSCD]
		UNIQUE
		NONCLUSTERED
		([FormStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormStatus]
		PRIMARY KEY
		CLUSTERED
		([FormStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'CONSTRAINT', N'pk_FormStatus'
GO
ALTER TABLE [sf].[FormStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormStatus]
	CHECK
	([sf].[fFormStatus#Check]([FormStatusSID],[FormStatusSCD],[FormStatusLabel],[IsFinal],[IsDefault],[FormStatusSequence],[FormOwnerSID],[FormStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormStatus]
CHECK CONSTRAINT [ck_FormStatus]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [DF_FormStatus_FormStatusSequence]
	DEFAULT ((0)) FOR [FormStatusSequence]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[FormStatus]
	ADD
	CONSTRAINT [df_FormStatus_IsFinal]
	DEFAULT (CONVERT([bit],(0))) FOR [IsFinal]
GO
ALTER TABLE [sf].[FormStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_FormStatus_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [sf].[FormStatus]
	CHECK CONSTRAINT [fk_FormStatus_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Form Status table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Form Status. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Form Status.', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'CONSTRAINT', N'fk_FormStatus_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_FormStatus_FormOwnerSID_FormStatusSID]
	ON [sf].[FormStatus] ([FormOwnerSID], [FormStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'INDEX', N'ix_FormStatus_FormOwnerSID_FormStatusSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormStatus_IsDefault]
	ON [sf].[FormStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Form Status', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'INDEX', N'ux_FormStatus_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormStatus_LegacyKey]
	ON [sf].[FormStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'INDEX', N'ux_FormStatus_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of statuses that are supported by the system on forms.  These statuses are used internally by the program to manage editing and do not correspond to end-user status definitions.  The list of statuses cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Specific application logic detects each status type using the Form-Status-SCD value from this table.', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An explanation of when this status is applied to the form', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a final status.  Once the form achieves this status it is considered closed.', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'IsFinal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default form status to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in the progression of a form from new to fully processed', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'FormStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this form status', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form status | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'FormStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Status Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'CONSTRAINT', N'uk_FormStatus_FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Status SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'CONSTRAINT', N'uk_FormStatus_FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormStatus', 'CONSTRAINT', N'uk_FormStatus_RowGUID'
GO
ALTER TABLE [sf].[FormStatus] SET (LOCK_ESCALATION = TABLE)
GO
