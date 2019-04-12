SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAppReviewResponse] (
		[RegistrantAppReviewResponseSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAppReviewSID]             [int] NOT NULL,
		[FormOwnerSID]                       [int] NOT NULL,
		[FormResponse]                       [xml] NOT NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[RegistrantAppReviewResponseXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAppReviewResponse_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAppReviewResponse]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAppReviewResponseSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant App Review Response table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'CONSTRAINT', N'pk_RegistrantAppReviewResponse'
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAppReviewResponse]
	CHECK
	([dbo].[fRegistrantAppReviewResponse#Check]([RegistrantAppReviewResponseSID],[RegistrantAppReviewSID],[FormOwnerSID],[RegistrantAppReviewResponseXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
CHECK CONSTRAINT [ck_RegistrantAppReviewResponse]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	ADD
	CONSTRAINT [df_RegistrantAppReviewResponse_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	ADD
	CONSTRAINT [df_RegistrantAppReviewResponse_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	ADD
	CONSTRAINT [df_RegistrantAppReviewResponse_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	ADD
	CONSTRAINT [df_RegistrantAppReviewResponse_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	ADD
	CONSTRAINT [df_RegistrantAppReviewResponse_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	ADD
	CONSTRAINT [df_RegistrantAppReviewResponse_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReviewResponse_RegistrantAppReview_RegistrantAppReviewSID]
	FOREIGN KEY ([RegistrantAppReviewSID]) REFERENCES [dbo].[RegistrantAppReview] ([RegistrantAppReviewSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	CHECK CONSTRAINT [fk_RegistrantAppReviewResponse_RegistrantAppReview_RegistrantAppReviewSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant app review system ID column in the Registrant App Review Response table match a registrant app review system ID in the Registrant App Review table. It also ensures that when a record in the Registrant App Review table is deleted, matching child records in the Registrant App Review Response table are deleted as well. Finally, the constraint blocks changes to the value of the registrant app review system ID column in the Registrant App Review if matching child records exist in Registrant App Review Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'CONSTRAINT', N'fk_RegistrantAppReviewResponse_RegistrantAppReview_RegistrantAppReviewSID'
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReviewResponse_SF_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [dbo].[RegistrantAppReviewResponse]
	CHECK CONSTRAINT [fk_RegistrantAppReviewResponse_SF_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Registrant App Review Response table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Registrant App Review Response. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Registrant App Review Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'CONSTRAINT', N'fk_RegistrantAppReviewResponse_SF_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReviewResponse_FormOwnerSID_RegistrantAppReviewResponseSID]
	ON [dbo].[RegistrantAppReviewResponse] ([FormOwnerSID], [RegistrantAppReviewResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'INDEX', N'ix_RegistrantAppReviewResponse_FormOwnerSID_RegistrantAppReviewResponseSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReviewResponse_RegistrantAppReviewSID_RegistrantAppReviewResponseSID]
	ON [dbo].[RegistrantAppReviewResponse] ([RegistrantAppReviewSID], [RegistrantAppReviewResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant App Review SID foreign key column and avoids row contention on (parent) Registrant App Review updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'INDEX', N'ix_RegistrantAppReviewResponse_RegistrantAppReviewSID_RegistrantAppReviewResponseSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAppReviewResponse_LegacyKey]
	ON [dbo].[RegistrantAppReviewResponse] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'INDEX', N'ux_RegistrantAppReviewResponse_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores this history of Review form changes.  When the original form is submitted, a copy of responses is stored into this table.  If the supervisor resubmits the form - e.g. to make corrections suggested by the administrator, a copy is stored for each submission.  Simiarly, if the administrator makes corrections on the form a version of the responses is saved each time.  The version that is approved is marked "Is-Approved".  Note that the Form-Response-Draft column in the parent Registrant-App-Review table is used to maintain the currently edited version of form content.  The draft responses may or may not agree with any version of responses stored in this table since drafts can be saved but never submitted. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app review response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'RegistrantAppReviewResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'RegistrantAppReviewSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this registrant app review response', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant app review response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'RegistrantAppReviewResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant app review response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant app review response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant app review response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant app review response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant app review response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'CONSTRAINT', N'uk_RegistrantAppReviewResponse_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAppReviewResponse_FormResponse]
	ON [dbo].[RegistrantAppReviewResponse] ([FormResponse])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReviewResponse', 'INDEX', N'xp_RegistrantAppReviewResponse_FormResponse'
GO
ALTER TABLE [dbo].[RegistrantAppReviewResponse] SET (LOCK_ESCALATION = TABLE)
GO
