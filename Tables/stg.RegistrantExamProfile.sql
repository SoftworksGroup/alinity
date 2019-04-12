SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [stg].[RegistrantExamProfile] (
		[RegistrantExamProfileSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ImportFileSID]                [int] NOT NULL,
		[ProcessingStatusSID]          [int] NOT NULL,
		[RegistrantNo]                 [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmailAddress]                 [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FirstName]                    [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastName]                     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BirthDate]                    [date] NULL,
		[ExamIdentifier]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ExamDate]                     [date] NULL,
		[ExamTime]                     [time](0) NULL,
		[OrgLabel]                     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ExamResultDate]               [date] NULL,
		[PassingScore]                 [int] NULL,
		[Score]                        [int] NULL,
		[AssignedLocation]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ExamReference]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonSID]                    [int] NULL,
		[RegistrantSID]                [int] NULL,
		[OrgSID]                       [int] NULL,
		[ExamSID]                      [int] NULL,
		[ExamOfferingSID]              [int] NULL,
		[ProcessingComments]           [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]           [xml] NULL,
		[RegistrantExamProfileXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantExamProfile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantExamProfile]
		PRIMARY KEY
		CLUSTERED
		([RegistrantExamProfileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Exam Profile table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'pk_RegistrantExamProfile'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	ADD
	CONSTRAINT [df_RegistrantExamProfile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	ADD
	CONSTRAINT [df_RegistrantExamProfile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	ADD
	CONSTRAINT [df_RegistrantExamProfile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	ADD
	CONSTRAINT [df_RegistrantExamProfile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	ADD
	CONSTRAINT [df_RegistrantExamProfile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	ADD
	CONSTRAINT [df_RegistrantExamProfile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_DBO_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_DBO_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Exam Profile table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_DBO_Registrant_RegistrantSID'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_DBO_Exam_ExamSID]
	FOREIGN KEY ([ExamSID]) REFERENCES [dbo].[Exam] ([ExamSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_DBO_Exam_ExamSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam system ID column in the Registrant Exam Profile table match a exam system ID in the Exam table. It also ensures that records in the Exam table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the exam system ID column in the Exam if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_DBO_Exam_ExamSID'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_DBO_ExamOffering_ExamOfferingSID]
	FOREIGN KEY ([ExamOfferingSID]) REFERENCES [dbo].[ExamOffering] ([ExamOfferingSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_DBO_ExamOffering_ExamOfferingSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam offering system ID column in the Registrant Exam Profile table match a exam offering system ID in the Exam Offering table. It also ensures that records in the Exam Offering table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the exam offering system ID column in the Exam Offering if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_DBO_ExamOffering_ExamOfferingSID'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_SF_ImportFile_ImportFileSID]
	FOREIGN KEY ([ImportFileSID]) REFERENCES [sf].[ImportFile] ([ImportFileSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_SF_ImportFile_ImportFileSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the import file system ID column in the Registrant Exam Profile table match a import file system ID in the Import File table. It also ensures that records in the Import File table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the import file system ID column in the Import File if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_SF_ImportFile_ImportFileSID'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Registrant Exam Profile table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_SF_Person_PersonSID'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_SF_ProcessingStatus_ProcessingStatusSID]
	FOREIGN KEY ([ProcessingStatusSID]) REFERENCES [sf].[ProcessingStatus] ([ProcessingStatusSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_SF_ProcessingStatus_ProcessingStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the processing status system ID column in the Registrant Exam Profile table match a processing status system ID in the Processing Status table. It also ensures that records in the Processing Status table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the processing status system ID column in the Processing Status if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_SF_ProcessingStatus_ProcessingStatusSID'
GO
ALTER TABLE [stg].[RegistrantExamProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExamProfile_DBO_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [stg].[RegistrantExamProfile]
	CHECK CONSTRAINT [fk_RegistrantExamProfile_DBO_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Registrant Exam Profile table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Registrant Exam Profile. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Registrant Exam Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'fk_RegistrantExamProfile_DBO_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_ExamOfferingSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([ExamOfferingSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam Offering SID foreign key column and avoids row contention on (parent) Exam Offering updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_ExamOfferingSID_RegistrantExamProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_ExamSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([ExamSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam SID foreign key column and avoids row contention on (parent) Exam updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_ExamSID_RegistrantExamProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_ImportFileSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([ImportFileSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Import File SID foreign key column and avoids row contention on (parent) Import File updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_ImportFileSID_RegistrantExamProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_OrgSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([OrgSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_OrgSID_RegistrantExamProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_PersonSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([PersonSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_PersonSID_RegistrantExamProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_ProcessingStatusSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([ProcessingStatusSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Processing Status SID foreign key column and avoids row contention on (parent) Processing Status updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_ProcessingStatusSID_RegistrantExamProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExamProfile_RegistrantSID_RegistrantExamProfileSID]
	ON [stg].[RegistrantExamProfile] ([RegistrantSID], [RegistrantExamProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'INDEX', N'ix_RegistrantExamProfile_RegistrantSID_RegistrantExamProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant exam profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'RegistrantExamProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The import file assigned to this registrant exam profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant exam profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this registrant exam profile is based on', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this exam profile is defined for', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant exam profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam assigned to this registrant  profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam offering assigned to this registrant exam profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'ExamOfferingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant exam profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'RegistrantExamProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant exam profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant exam profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant exam profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant exam profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant exam profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'RegistrantExamProfile', 'CONSTRAINT', N'uk_RegistrantExamProfile_RowGUID'
GO
ALTER TABLE [stg].[RegistrantExamProfile] SET (LOCK_ESCALATION = TABLE)
GO
