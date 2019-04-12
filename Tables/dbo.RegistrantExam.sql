SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantExam] (
		[RegistrantExamSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]             [int] NOT NULL,
		[ExamSID]                   [int] NOT NULL,
		[ExamDate]                  [date] NULL,
		[ExamResultDate]            [date] NULL,
		[PassingScore]              [int] NULL,
		[Score]                     [int] NULL,
		[ExamStatusSID]             [int] NOT NULL,
		[SchedulingPreferences]     [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AssignedLocation]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ExamReference]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ExamOfferingSID]           [int] NULL,
		[InvoiceSID]                [int] NULL,
		[ConfirmedTime]             [datetimeoffset](7) NULL,
		[CancelledTime]             [datetimeoffset](7) NULL,
		[ExamConfiguration]         [xml] NULL,
		[ExamResponses]             [xml] NULL,
		[ProcessedTime]             [datetimeoffset](7) NULL,
		[ProcessingComments]        [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]        [xml] NULL,
		[RegistrantExamXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantExam_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrantExam_RegistrantSID_ExamDate_ExamSID]
		UNIQUE
		NONCLUSTERED
		([RegistrantSID], [ExamDate], [ExamSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantExam]
		PRIMARY KEY
		CLUSTERED
		([RegistrantExamSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Exam table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'pk_RegistrantExam'
GO
ALTER TABLE [dbo].[RegistrantExam]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantExam]
	CHECK
	([dbo].[fRegistrantExam#Check]([RegistrantExamSID],[RegistrantSID],[ExamSID],[ExamDate],[ExamResultDate],[PassingScore],[Score],[ExamStatusSID],[SchedulingPreferences],[AssignedLocation],[ExamReference],[ExamOfferingSID],[InvoiceSID],[ConfirmedTime],[CancelledTime],[ProcessedTime],[RegistrantExamXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantExam]
CHECK CONSTRAINT [ck_RegistrantExam]
GO
ALTER TABLE [dbo].[RegistrantExam]
	ADD
	CONSTRAINT [df_RegistrantExam_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantExam]
	ADD
	CONSTRAINT [df_RegistrantExam_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantExam]
	ADD
	CONSTRAINT [df_RegistrantExam_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantExam]
	ADD
	CONSTRAINT [df_RegistrantExam_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantExam]
	ADD
	CONSTRAINT [df_RegistrantExam_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantExam]
	ADD
	CONSTRAINT [df_RegistrantExam_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantExam]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExam_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantExam]
	CHECK CONSTRAINT [fk_RegistrantExam_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Exam table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Exam. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Exam.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'fk_RegistrantExam_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantExam]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExam_Exam_ExamSID]
	FOREIGN KEY ([ExamSID]) REFERENCES [dbo].[Exam] ([ExamSID])
ALTER TABLE [dbo].[RegistrantExam]
	CHECK CONSTRAINT [fk_RegistrantExam_Exam_ExamSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam system ID column in the Registrant Exam table match a exam system ID in the Exam table. It also ensures that records in the Exam table cannot be deleted if matching child records exist in Registrant Exam. Finally, the constraint blocks changes to the value of the exam system ID column in the Exam if matching child records exist in Registrant Exam.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'fk_RegistrantExam_Exam_ExamSID'
GO
ALTER TABLE [dbo].[RegistrantExam]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExam_ExamOffering_ExamOfferingSID]
	FOREIGN KEY ([ExamOfferingSID]) REFERENCES [dbo].[ExamOffering] ([ExamOfferingSID])
ALTER TABLE [dbo].[RegistrantExam]
	CHECK CONSTRAINT [fk_RegistrantExam_ExamOffering_ExamOfferingSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam offering system ID column in the Registrant Exam table match a exam offering system ID in the Exam Offering table. It also ensures that records in the Exam Offering table cannot be deleted if matching child records exist in Registrant Exam. Finally, the constraint blocks changes to the value of the exam offering system ID column in the Exam Offering if matching child records exist in Registrant Exam.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'fk_RegistrantExam_ExamOffering_ExamOfferingSID'
GO
ALTER TABLE [dbo].[RegistrantExam]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExam_ExamStatus_ExamStatusSID]
	FOREIGN KEY ([ExamStatusSID]) REFERENCES [dbo].[ExamStatus] ([ExamStatusSID])
ALTER TABLE [dbo].[RegistrantExam]
	CHECK CONSTRAINT [fk_RegistrantExam_ExamStatus_ExamStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam status system ID column in the Registrant Exam table match a exam status system ID in the Exam Status table. It also ensures that records in the Exam Status table cannot be deleted if matching child records exist in Registrant Exam. Finally, the constraint blocks changes to the value of the exam status system ID column in the Exam Status if matching child records exist in Registrant Exam.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'fk_RegistrantExam_ExamStatus_ExamStatusSID'
GO
ALTER TABLE [dbo].[RegistrantExam]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantExam_Invoice_InvoiceSID]
	FOREIGN KEY ([InvoiceSID]) REFERENCES [dbo].[Invoice] ([InvoiceSID])
ALTER TABLE [dbo].[RegistrantExam]
	CHECK CONSTRAINT [fk_RegistrantExam_Invoice_InvoiceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice system ID column in the Registrant Exam table match a invoice system ID in the Invoice table. It also ensures that records in the Invoice table cannot be deleted if matching child records exist in Registrant Exam. Finally, the constraint blocks changes to the value of the invoice system ID column in the Invoice if matching child records exist in Registrant Exam.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'fk_RegistrantExam_Invoice_InvoiceSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExam_ExamOfferingSID_RegistrantExamSID]
	ON [dbo].[RegistrantExam] ([ExamOfferingSID], [RegistrantExamSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam Offering SID foreign key column and avoids row contention on (parent) Exam Offering updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'INDEX', N'ix_RegistrantExam_ExamOfferingSID_RegistrantExamSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExam_ExamSID_RegistrantExamSID]
	ON [dbo].[RegistrantExam] ([ExamSID], [RegistrantExamSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam SID foreign key column and avoids row contention on (parent) Exam updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'INDEX', N'ix_RegistrantExam_ExamSID_RegistrantExamSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExam_ExamStatusSID_RegistrantExamSID]
	ON [dbo].[RegistrantExam] ([ExamStatusSID], [RegistrantExamSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam Status SID foreign key column and avoids row contention on (parent) Exam Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'INDEX', N'ix_RegistrantExam_ExamStatusSID_RegistrantExamSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantExam_InvoiceSID_RegistrantExamSID]
	ON [dbo].[RegistrantExam] ([InvoiceSID], [RegistrantExamSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice SID foreign key column and avoids row contention on (parent) Invoice updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'INDEX', N'ix_RegistrantExam_InvoiceSID_RegistrantExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Registrant Exam entity records exam results for members. Various details of the exam can be recorded including at least the exam date and a pass/fail result, but may also include the member’s score, seating location, reference number for that sitting or assigned proctor name, invoice number for the exam, as well as attendance confirmation time or cancelled time if the member did not take the exam. The user interface allows administrators to record pass/fail results on exams taken by registrants as manual entries and through importing exam results.    Where the exam is configured through the Jurisprudence Module the Score is automatically filled in along with the pass/fail result based on the scoring configuration defined for the exam.  The confirmed time is automatically filled in when the exam is created for the registrant.  For exams created through Jurisprudence, the Exam-Configuration (XML) document is generated and stored when the member begins the exam.  A set of questions is selected for the exam according to the rules defined along with available answer-choices.  If exam questions and answer-choices are updated after the Registrant Exam record is created, those updates are not carried into existing exams since members may have already started answering questions. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant exam assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'RegistrantExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this exam is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam assigned to this registrant', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the exam was taken', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the result of the exam was received', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamResultDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum score for passing the exam as defined at the time the record was created | This value can be edited by SA''s (only)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'PassingScore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The score achieved by the exam candidate', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'Score'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant exam', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The member''s preference for scheduling the exam sitting - may include date, location, special requirements etc. - considered in assigning an exam sitting ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'SchedulingPreferences'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The seat#, room# or other location identifier within the building where the registrant wrote the exam', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'AssignedLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier for the candidate or exam from a 3rd party exam provider - e.g. a Yardstick exam ID or ASI exam-file result', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam offering assigned to this registrant exam', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamOfferingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The invoice assigned to this registrant exam', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when registration for the exam offering date was confirmed  - set automatically when invoice is paid or on $0 invoice', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ConfirmedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when exam booking was cancelled (paid amounts available for refund or application to a new booking)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A document used internally by the application to display exam questions, answers and other details | This document is generated at the time the exam is created and is not affected by subsequent updates to the exam''s configuration', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamConfiguration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document containing the member answers to the exam questions. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ExamResponses'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the date and time the application service picks up the record for generation of the PDF', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records system error and warning messages, if any, associated with processing of the exam (PDF) document', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'ProcessingComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant exam | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'RegistrantExamXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant exam | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant exam record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant exam | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant exam record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant exam record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'uk_RegistrantExam_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registrant SID + Exam Date + Exam SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantExam', 'CONSTRAINT', N'uk_RegistrantExam_RegistrantSID_ExamDate_ExamSID'
GO
ALTER TABLE [dbo].[RegistrantExam] SET (LOCK_ESCALATION = TABLE)
GO
