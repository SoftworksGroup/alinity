SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAppReviewStatus] (
		[RegistrantAppReviewStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAppReviewSID]           [int] NOT NULL,
		[FormStatusSID]                    [int] NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[RegistrantAppReviewStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAppReviewStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAppReviewStatus]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAppReviewStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant App Review Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'CONSTRAINT', N'pk_RegistrantAppReviewStatus'
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAppReviewStatus]
	CHECK
	([dbo].[fRegistrantAppReviewStatus#Check]([RegistrantAppReviewStatusSID],[RegistrantAppReviewSID],[FormStatusSID],[RegistrantAppReviewStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
CHECK CONSTRAINT [ck_RegistrantAppReviewStatus]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAppReviewStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAppReviewStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAppReviewStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAppReviewStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAppReviewStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAppReviewStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReviewStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	CHECK CONSTRAINT [fk_RegistrantAppReviewStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Registrant App Review Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Registrant App Review Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Registrant App Review Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'CONSTRAINT', N'fk_RegistrantAppReviewStatus_SF_FormStatus_FormStatusSID'
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReviewStatus_RegistrantAppReview_RegistrantAppReviewSID]
	FOREIGN KEY ([RegistrantAppReviewSID]) REFERENCES [dbo].[RegistrantAppReview] ([RegistrantAppReviewSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAppReviewStatus]
	CHECK CONSTRAINT [fk_RegistrantAppReviewStatus_RegistrantAppReview_RegistrantAppReviewSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant app review system ID column in the Registrant App Review Status table match a registrant app review system ID in the Registrant App Review table. It also ensures that when a record in the Registrant App Review table is deleted, matching child records in the Registrant App Review Status table are deleted as well. Finally, the constraint blocks changes to the value of the registrant app review system ID column in the Registrant App Review if matching child records exist in Registrant App Review Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'CONSTRAINT', N'fk_RegistrantAppReviewStatus_RegistrantAppReview_RegistrantAppReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReviewStatus_FormStatusSID_RegistrantAppReviewStatusSID]
	ON [dbo].[RegistrantAppReviewStatus] ([FormStatusSID], [RegistrantAppReviewStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'INDEX', N'ix_RegistrantAppReviewStatus_FormStatusSID_RegistrantAppReviewStatusSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAppReviewStatus_LegacyKey]
	ON [dbo].[RegistrantAppReviewStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'INDEX', N'ux_RegistrantAppReviewStatus_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReviewStatus_RegistrantAppReviewSID_RegistrantAppReviewStatusSID]
	ON [dbo].[RegistrantAppReviewStatus] ([RegistrantAppReviewSID], [RegistrantAppReviewStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant App Review SID foreign key column and avoids row contention on (parent) Registrant App Review updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'INDEX', N'ix_RegistrantAppReviewStatus_RegistrantAppReviewSID_RegistrantAppReviewStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app review status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'RegistrantAppReviewStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app Review assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'RegistrantAppReviewSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant app review status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'RegistrantAppReviewStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant app review status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant app review status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant app review status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant app review status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant app review status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewStatus', 'CONSTRAINT', N'uk_RegistrantAppReviewStatus_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantAppReviewStatus] SET (LOCK_ESCALATION = TABLE)
GO
