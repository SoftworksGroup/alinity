SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentProcessorResponse] (
		[PaymentProcessorResponseSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PaymentSID]                      [int] NOT NULL,
		[ResponseTime]                    [datetime] NOT NULL,
		[ResponseSource]                  [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ResponseDetails]                 [xml] NOT NULL,
		[TransactionID]                   [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsPaid]                          [bit] NOT NULL,
		[UserDefinedColumns]              [xml] NULL,
		[PaymentProcessorResponseXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_PaymentProcessorResponse_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PaymentProcessorResponse]
		PRIMARY KEY
		CLUSTERED
		([PaymentProcessorResponseSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Payment Processor Response table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'CONSTRAINT', N'pk_PaymentProcessorResponse'
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PaymentProcessorResponse]
	CHECK
	([dbo].[fPaymentProcessorResponse#Check]([PaymentProcessorResponseSID],[PaymentSID],[ResponseTime],[ResponseSource],[TransactionID],[IsPaid],[PaymentProcessorResponseXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
CHECK CONSTRAINT [ck_PaymentProcessorResponse]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_IsPaid]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPaid]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	ADD
	CONSTRAINT [df_PaymentProcessorResponse_ResponseDetails]
	DEFAULT (CONVERT([xml],N'<Events />')) FOR [ResponseDetails]
GO
ALTER TABLE [dbo].[PaymentProcessorResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_PaymentProcessorResponse_Payment_PaymentSID]
	FOREIGN KEY ([PaymentSID]) REFERENCES [dbo].[Payment] ([PaymentSID])
ALTER TABLE [dbo].[PaymentProcessorResponse]
	CHECK CONSTRAINT [fk_PaymentProcessorResponse_Payment_PaymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment system ID column in the Payment Processor Response table match a payment system ID in the Payment table. It also ensures that records in the Payment table cannot be deleted if matching child records exist in Payment Processor Response. Finally, the constraint blocks changes to the value of the payment system ID column in the Payment if matching child records exist in Payment Processor Response.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'CONSTRAINT', N'fk_PaymentProcessorResponse_Payment_PaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_PaymentProcessorResponse_PaymentSID_PaymentProcessorResponseSID]
	ON [dbo].[PaymentProcessorResponse] ([PaymentSID], [PaymentProcessorResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment SID foreign key column and avoids row contention on (parent) Payment updates', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'INDEX', N'ix_PaymentProcessorResponse_PaymentSID_PaymentProcessorResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to record responses from online payment processors.  The table is intended to support debugging and problem investigation of online payments going throug a payment processor (e.g. Moneris).   DO NOT create any business rules on the table or implement logic in the table''s EF procedures.  The table is written to by the UI immediately upon getting a result back on a payment attempt.  Each result is written to a separate record.  By avoiding business rules on the table the potential for response details to be lost due to errors (and resulting database transaction roll back) is minimized.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment processor response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'PaymentProcessorResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The payment this processor response is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'PaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the response was received from the processor (same as CreateTime except for manual entries)', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'ResponseTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The source of the response:  MANUAL entry, BROWSER, or SERVER', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'ResponseSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records a history of events and values provided to payment processors.  This information is used primarily for follow-up on unsuccessful debit and credit card processing attempts.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'ResponseDetails'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The transaction or reference number of provided by the 3rd party payment processor for tracking on their website.  | The column should always be filled in but NULLs (blanks) are allowed to minimize the probability of an update failure when recording a response.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'TransactionID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates payment was accepted', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment processor response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'PaymentProcessorResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment processor response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment processor response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment processor response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment processor response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment processor response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'CONSTRAINT', N'uk_PaymentProcessorResponse_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_PaymentProcessorResponse_ResponseDetails]
	ON [dbo].[PaymentProcessorResponse] ([ResponseDetails])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Response Details (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'PaymentProcessorResponse', 'INDEX', N'xp_PaymentProcessorResponse_ResponseDetails'
GO
ALTER TABLE [dbo].[PaymentProcessorResponse] SET (LOCK_ESCALATION = TABLE)
GO
