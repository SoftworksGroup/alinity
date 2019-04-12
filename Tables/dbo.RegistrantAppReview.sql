SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAppReview] (
		[RegistrantAppReviewSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAppSID]           [int] NOT NULL,
		[FormVersionSID]             [int] NOT NULL,
		[PersonSID]                  [int] NOT NULL,
		[ReasonSID]                  [int] NULL,
		[RecommendationSID]          [int] NULL,
		[FormResponseDraft]          [xml] NOT NULL,
		[LastValidateTime]           [datetimeoffset](7) NULL,
		[ReviewerComments]           [xml] NULL,
		[ConfirmationDraft]          [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]         [xml] NULL,
		[RegistrantAppReviewXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAppReview_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAppReview]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAppReviewSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant App Review table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'pk_RegistrantAppReview'
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAppReview]
	CHECK
	([dbo].[fRegistrantAppReview#Check]([RegistrantAppReviewSID],[RegistrantAppSID],[FormVersionSID],[PersonSID],[ReasonSID],[RecommendationSID],[LastValidateTime],[RegistrantAppReviewXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAppReview]
CHECK CONSTRAINT [ck_RegistrantAppReview]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_FormResponseDraft]
	DEFAULT (CONVERT([xml],N'<FormResponses />')) FOR [FormResponseDraft]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	ADD
	CONSTRAINT [df_RegistrantAppReview_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReview_SF_FormVersion_FormVersionSID]
	FOREIGN KEY ([FormVersionSID]) REFERENCES [sf].[FormVersion] ([FormVersionSID])
ALTER TABLE [dbo].[RegistrantAppReview]
	CHECK CONSTRAINT [fk_RegistrantAppReview_SF_FormVersion_FormVersionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form version system ID column in the Registrant App Review table match a form version system ID in the Form Version table. It also ensures that records in the Form Version table cannot be deleted if matching child records exist in Registrant App Review. Finally, the constraint blocks changes to the value of the form version system ID column in the Form Version if matching child records exist in Registrant App Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'fk_RegistrantAppReview_SF_FormVersion_FormVersionSID'
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReview_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[RegistrantAppReview]
	CHECK CONSTRAINT [fk_RegistrantAppReview_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Registrant App Review table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Registrant App Review. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Registrant App Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'fk_RegistrantAppReview_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReview_Recommendation_RecommendationSID]
	FOREIGN KEY ([RecommendationSID]) REFERENCES [dbo].[Recommendation] ([RecommendationSID])
ALTER TABLE [dbo].[RegistrantAppReview]
	CHECK CONSTRAINT [fk_RegistrantAppReview_Recommendation_RecommendationSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the recommendation system ID column in the Registrant App Review table match a recommendation system ID in the Recommendation table. It also ensures that records in the Recommendation table cannot be deleted if matching child records exist in Registrant App Review. Finally, the constraint blocks changes to the value of the recommendation system ID column in the Recommendation if matching child records exist in Registrant App Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'fk_RegistrantAppReview_Recommendation_RecommendationSID'
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReview_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[RegistrantAppReview]
	CHECK CONSTRAINT [fk_RegistrantAppReview_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Registrant App Review table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Registrant App Review. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Registrant App Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'fk_RegistrantAppReview_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[RegistrantAppReview]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAppReview_RegistrantApp_RegistrantAppSID]
	FOREIGN KEY ([RegistrantAppSID]) REFERENCES [dbo].[RegistrantApp] ([RegistrantAppSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAppReview]
	CHECK CONSTRAINT [fk_RegistrantAppReview_RegistrantApp_RegistrantAppSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant app system ID column in the Registrant App Review table match a registrant app system ID in the Registrant App table. It also ensures that when a record in the Registrant App table is deleted, matching child records in the Registrant App Review table are deleted as well. Finally, the constraint blocks changes to the value of the registrant app system ID column in the Registrant App if matching child records exist in Registrant App Review.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'fk_RegistrantAppReview_RegistrantApp_RegistrantAppSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReview_FormVersionSID_RegistrantAppReviewSID]
	ON [dbo].[RegistrantAppReview] ([FormVersionSID], [RegistrantAppReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Version SID foreign key column and avoids row contention on (parent) Form Version updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'ix_RegistrantAppReview_FormVersionSID_RegistrantAppReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReview_PersonSID_RegistrantAppReviewSID]
	ON [dbo].[RegistrantAppReview] ([PersonSID], [RegistrantAppReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'ix_RegistrantAppReview_PersonSID_RegistrantAppReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReview_ReasonSID_RegistrantAppReviewSID]
	ON [dbo].[RegistrantAppReview] ([ReasonSID], [RegistrantAppReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'ix_RegistrantAppReview_ReasonSID_RegistrantAppReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReview_RecommendationSID_RegistrantAppReviewSID]
	ON [dbo].[RegistrantAppReview] ([RecommendationSID], [RegistrantAppReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Recommendation SID foreign key column and avoids row contention on (parent) Recommendation updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'ix_RegistrantAppReview_RecommendationSID_RegistrantAppReviewSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAppReview_RegistrantAppSID_RegistrantAppReviewSID]
	ON [dbo].[RegistrantAppReview] ([RegistrantAppSID], [RegistrantAppReviewSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant App SID foreign key column and avoids row contention on (parent) Registrant App updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'ix_RegistrantAppReview_RegistrantAppSID_RegistrantAppReviewSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAppReview_LegacyKey]
	ON [dbo].[RegistrantAppReview] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'ux_RegistrantAppReview_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Registrant App(lication) Review table is used to capture comments from employers and supervisors engaged to confirm the credentials and other claims made on the application form. The Review process is considered complete when the "Approved Time" is filled in.  Review forms are typically reviewed and approved by administrators (internal staff of the College).', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app review assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'RegistrantAppReviewSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'RegistrantAppSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this registrant app review is based on', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reason assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the recommendation assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'RecommendationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant app review | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'RegistrantAppReviewXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant app review | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant app review record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant app review | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant app review record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant app review record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'CONSTRAINT', N'uk_RegistrantAppReview_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantAppReview_FormResponseDraft]
	ON [dbo].[RegistrantAppReview] ([FormResponseDraft])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response Draft (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAppReview', 'INDEX', N'xp_RegistrantAppReview_FormResponseDraft'
GO
ALTER TABLE [dbo].[RegistrantAppReview] SET (LOCK_ESCALATION = TABLE)
GO
