SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAuditReviewStatus] (
		[RegistrantAuditReviewStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAuditReviewSID]           [int] NOT NULL,
		[FormStatusSID]                      [int] NOT NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[RegistrantAuditReviewStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAuditReviewStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAuditReviewStatus]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAuditReviewStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Audit Review Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'CONSTRAINT', N'pk_RegistrantAuditReviewStatus'
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAuditReviewStatus]
	CHECK
	([dbo].[fRegistrantAuditReviewStatus#Check]([RegistrantAuditReviewStatusSID],[RegistrantAuditReviewSID],[FormStatusSID],[RegistrantAuditReviewStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
CHECK CONSTRAINT [ck_RegistrantAuditReviewStatus]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditReviewStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditReviewStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditReviewStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditReviewStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditReviewStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditReviewStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReviewStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	CHECK CONSTRAINT [fk_RegistrantAuditReviewStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Registrant Audit Review Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Registrant Audit Review Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Registrant Audit Review Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'CONSTRAINT', N'fk_RegistrantAuditReviewStatus_SF_FormStatus_FormStatusSID'
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReviewStatus_RegistrantAuditReview_RegistrantAuditReviewSID]
	FOREIGN KEY ([RegistrantAuditReviewSID]) REFERENCES [dbo].[RegistrantAuditReview] ([RegistrantAuditReviewSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAuditReviewStatus]
	CHECK CONSTRAINT [fk_RegistrantAuditReviewStatus_RegistrantAuditReview_RegistrantAuditReviewSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant audit review system ID column in the Registrant Audit Review Status table match a registrant audit review system ID in the Registrant Audit Review table. It also ensures that when a record in the Registrant Audit Review table is deleted, matching child records in the Registrant Audit Review Status table are deleted as well. Finally, the constraint blocks changes to the value of the registrant audit review system ID column in the Registrant Audit Review if matching child records exist in Registrant Audit Review Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'CONSTRAINT', N'fk_RegistrantAuditReviewStatus_RegistrantAuditReview_RegistrantAuditReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReviewStatus_FormStatusSID_RegistrantAuditReviewStatusSID]
	ON [dbo].[RegistrantAuditReviewStatus] ([FormStatusSID], [RegistrantAuditReviewStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'INDEX', N'ix_RegistrantAuditReviewStatus_FormStatusSID_RegistrantAuditReviewStatusSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAuditReviewStatus_LegacyKey]
	ON [dbo].[RegistrantAuditReviewStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'INDEX', N'ux_RegistrantAuditReviewStatus_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReviewStatus_RegistrantAuditReviewSID_RegistrantAuditReviewStatusSID]
	ON [dbo].[RegistrantAuditReviewStatus] ([RegistrantAuditReviewSID], [RegistrantAuditReviewStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Audit Review SID foreign key column and avoids row contention on (parent) Registrant Audit Review updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'INDEX', N'ix_RegistrantAuditReviewStatus_RegistrantAuditReviewSID_RegistrantAuditReviewStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant audit review status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'RegistrantAuditReviewStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence audit Review assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'RegistrantAuditReviewSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant audit review status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'RegistrantAuditReviewStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant audit review status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant audit review status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant audit review status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant audit review status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit review status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReviewStatus', 'CONSTRAINT', N'uk_RegistrantAuditReviewStatus_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantAuditReviewStatus] SET (LOCK_ESCALATION = TABLE)
GO
