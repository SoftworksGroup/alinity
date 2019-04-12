SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAuditReview] (
		[RegistrantAuditReviewSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAuditSID]           [int] NOT NULL,
		[FormVersionSID]               [int] NOT NULL,
		[PersonSID]                    [int] NOT NULL,
		[ReasonSID]                    [int] NULL,
		[RecommendationSID]            [int] NULL,
		[FormResponseDraft]            [xml] NOT NULL,
		[LastValidateTime]             [datetimeoffset](7) NULL,
		[ReviewerComments]             [xml] NULL,
		[ConfirmationDraft]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAutoApprovalEnabled]        [bit] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[RegistrantAuditReviewXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAuditReview_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAuditReview]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAuditReviewSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Audit Review table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'pk_RegistrantAuditReview'
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAuditReview]
	CHECK
	([dbo].[fRegistrantAuditReview#Check]([RegistrantAuditReviewSID],[RegistrantAuditSID],[FormVersionSID],[PersonSID],[ReasonSID],[RecommendationSID],[LastValidateTime],[IsAutoApprovalEnabled],[RegistrantAuditReviewXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
CHECK CONSTRAINT [ck_RegistrantAuditReview]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_FormResponseDraft]
	DEFAULT (CONVERT([xml],N'<FormResponses />')) FOR [FormResponseDraft]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_IsAutoApprovalEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAutoApprovalEnabled]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	ADD
	CONSTRAINT [df_RegistrantAuditReview_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReview_SF_FormVersion_FormVersionSID]
	FOREIGN KEY ([FormVersionSID]) REFERENCES [sf].[FormVersion] ([FormVersionSID])
ALTER TABLE [dbo].[RegistrantAuditReview]
	CHECK CONSTRAINT [fk_RegistrantAuditReview_SF_FormVersion_FormVersionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form version system ID column in the Registrant Audit Review table match a form version system ID in the Form Version table. It also ensures that records in the Form Version table cannot be deleted if matching child records exist in Registrant Audit Review. Finally, the constraint blocks changes to the value of the form version system ID column in the Form Version if matching child records exist in Registrant Audit Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'fk_RegistrantAuditReview_SF_FormVersion_FormVersionSID'
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReview_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[RegistrantAuditReview]
	CHECK CONSTRAINT [fk_RegistrantAuditReview_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Registrant Audit Review table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Registrant Audit Review. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Registrant Audit Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'fk_RegistrantAuditReview_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReview_Recommendation_RecommendationSID]
	FOREIGN KEY ([RecommendationSID]) REFERENCES [dbo].[Recommendation] ([RecommendationSID])
ALTER TABLE [dbo].[RegistrantAuditReview]
	CHECK CONSTRAINT [fk_RegistrantAuditReview_Recommendation_RecommendationSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the recommendation system ID column in the Registrant Audit Review table match a recommendation system ID in the Recommendation table. It also ensures that records in the Recommendation table cannot be deleted if matching child records exist in Registrant Audit Review. Finally, the constraint blocks changes to the value of the recommendation system ID column in the Recommendation if matching child records exist in Registrant Audit Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'fk_RegistrantAuditReview_Recommendation_RecommendationSID'
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReview_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[RegistrantAuditReview]
	CHECK CONSTRAINT [fk_RegistrantAuditReview_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Registrant Audit Review table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Registrant Audit Review. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Registrant Audit Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'fk_RegistrantAuditReview_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[RegistrantAuditReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditReview_RegistrantAudit_RegistrantAuditSID]
	FOREIGN KEY ([RegistrantAuditSID]) REFERENCES [dbo].[RegistrantAudit] ([RegistrantAuditSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAuditReview]
	CHECK CONSTRAINT [fk_RegistrantAuditReview_RegistrantAudit_RegistrantAuditSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant audit system ID column in the Registrant Audit Review table match a registrant audit system ID in the Registrant Audit table. It also ensures that when a record in the Registrant Audit table is deleted, matching child records in the Registrant Audit Review table are deleted as well. Finally, the constraint blocks changes to the value of the registrant audit system ID column in the Registrant Audit if matching child records exist in Registrant Audit Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'fk_RegistrantAuditReview_RegistrantAudit_RegistrantAuditSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReview_FormVersionSID_RegistrantAuditReviewSID]
	ON [dbo].[RegistrantAuditReview] ([FormVersionSID], [RegistrantAuditReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Version SID foreign key column and avoids row contention on (parent) Form Version updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'ix_RegistrantAuditReview_FormVersionSID_RegistrantAuditReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReview_PersonSID_RegistrantAuditReviewSID]
	ON [dbo].[RegistrantAuditReview] ([PersonSID], [RegistrantAuditReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'ix_RegistrantAuditReview_PersonSID_RegistrantAuditReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReview_ReasonSID_RegistrantAuditReviewSID]
	ON [dbo].[RegistrantAuditReview] ([ReasonSID], [RegistrantAuditReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'ix_RegistrantAuditReview_ReasonSID_RegistrantAuditReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReview_RecommendationSID_RegistrantAuditReviewSID]
	ON [dbo].[RegistrantAuditReview] ([RecommendationSID], [RegistrantAuditReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Recommendation SID foreign key column and avoids row contention on (parent) Recommendation updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'ix_RegistrantAuditReview_RecommendationSID_RegistrantAuditReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditReview_RegistrantAuditSID_RegistrantAuditReviewSID]
	ON [dbo].[RegistrantAuditReview] ([RegistrantAuditSID], [RegistrantAuditReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Audit SID foreign key column and avoids row contention on (parent) Registrant Audit updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'ix_RegistrantAuditReview_RegistrantAuditSID_RegistrantAuditReviewSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAuditReview_LegacyKey]
	ON [dbo].[RegistrantAuditReview] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'ux_RegistrantAuditReview_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The competence audit(lication) Review table is used to capture comments from employers and supervisors engaged to confirm the credentials and other claims made on the application form. The Review process is considered complete when the "Approved Time" is filled in.  Review forms are typically reviewed and approved by administrators (internal staff of the College).', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant audit review assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'RegistrantAuditReviewSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence audit assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'RegistrantAuditSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this registrant audit review is based on', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reason assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The recommendation assigned to this registrant audit review', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'RecommendationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior for confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant audit review | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'RegistrantAuditReviewXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant audit review | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant audit review record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant audit review | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant audit review record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit review record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'CONSTRAINT', N'uk_RegistrantAuditReview_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAuditReview_FormResponseDraft]
	ON [dbo].[RegistrantAuditReview] ([FormResponseDraft])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response Draft (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditReview', 'INDEX', N'xp_RegistrantAuditReview_FormResponseDraft'
GO
ALTER TABLE [dbo].[RegistrantAuditReview] SET (LOCK_ESCALATION = TABLE)
GO
