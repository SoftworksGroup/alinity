SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Payment] (
		[PaymentSID]              [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]               [int] NOT NULL,
		[PaymentTypeSID]          [int] NOT NULL,
		[PaymentStatusSID]        [int] NOT NULL,
		[GLAccountCode]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[GLPostingDate]           [date] NULL,
		[DepositDate]             [date] NULL,
		[AmountPaid]              [decimal](11, 2) NOT NULL,
		[Reference]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NameOnCard]              [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PaymentCard]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TransactionID]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastResponseCode]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastResponseMessage]     [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VerifiedTime]            [datetime] NULL,
		[CancelledTime]           [datetimeoffset](7) NULL,
		[ReasonSID]               [int] NULL,
		[UserDefinedColumns]      [xml] NULL,
		[PaymentXID]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_Payment_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Payment]
		PRIMARY KEY
		CLUSTERED
		([PaymentSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Payment table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'CONSTRAINT', N'pk_Payment'
GO
ALTER TABLE [dbo].[Payment]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Payment]
	CHECK
	([dbo].[fPayment#Check]([PaymentSID],[PersonSID],[PaymentTypeSID],[PaymentStatusSID],[GLAccountCode],[GLPostingDate],[DepositDate],[AmountPaid],[Reference],[NameOnCard],[PaymentCard],[TransactionID],[LastResponseCode],[VerifiedTime],[CancelledTime],[ReasonSID],[PaymentXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Payment]
CHECK CONSTRAINT [ck_Payment]
GO
ALTER TABLE [dbo].[Payment]
	ADD
	CONSTRAINT [df_Payment_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Payment]
	ADD
	CONSTRAINT [df_Payment_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Payment]
	ADD
	CONSTRAINT [df_Payment_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Payment]
	ADD
	CONSTRAINT [df_Payment_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Payment]
	ADD
	CONSTRAINT [df_Payment_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Payment]
	ADD
	CONSTRAINT [df_Payment_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Payment]
	WITH CHECK
	ADD CONSTRAINT [fk_Payment_PaymentStatus_PaymentStatusSID]
	FOREIGN KEY ([PaymentStatusSID]) REFERENCES [dbo].[PaymentStatus] ([PaymentStatusSID])
ALTER TABLE [dbo].[Payment]
	CHECK CONSTRAINT [fk_Payment_PaymentStatus_PaymentStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment status system ID column in the Payment table match a payment status system ID in the Payment Status table. It also ensures that records in the Payment Status table cannot be deleted if matching child records exist in Payment. Finally, the constraint blocks changes to the value of the payment status system ID column in the Payment Status if matching child records exist in Payment.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'CONSTRAINT', N'fk_Payment_PaymentStatus_PaymentStatusSID'
GO
ALTER TABLE [dbo].[Payment]
	WITH CHECK
	ADD CONSTRAINT [fk_Payment_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[Payment]
	CHECK CONSTRAINT [fk_Payment_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Payment table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Payment. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Payment.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'CONSTRAINT', N'fk_Payment_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[Payment]
	WITH CHECK
	ADD CONSTRAINT [fk_Payment_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[Payment]
	CHECK CONSTRAINT [fk_Payment_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Payment table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Payment. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Payment.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'CONSTRAINT', N'fk_Payment_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[Payment]
	WITH CHECK
	ADD CONSTRAINT [fk_Payment_PaymentType_PaymentTypeSID]
	FOREIGN KEY ([PaymentTypeSID]) REFERENCES [dbo].[PaymentType] ([PaymentTypeSID])
ALTER TABLE [dbo].[Payment]
	CHECK CONSTRAINT [fk_Payment_PaymentType_PaymentTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment type system ID column in the Payment table match a payment type system ID in the Payment Type table. It also ensures that records in the Payment Type table cannot be deleted if matching child records exist in Payment. Finally, the constraint blocks changes to the value of the payment type system ID column in the Payment Type if matching child records exist in Payment.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'CONSTRAINT', N'fk_Payment_PaymentType_PaymentTypeSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Payment_LegacyKey]
	ON [dbo].[Payment] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'INDEX', N'ux_Payment_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_Payment_PaymentTypeSID_PaymentSID]
	ON [dbo].[Payment] ([PaymentTypeSID], [PaymentSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment Type SID foreign key column and avoids row contention on (parent) Payment Type updates', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'INDEX', N'ix_Payment_PaymentTypeSID_PaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_Payment_PersonSID_PaymentSID]
	ON [dbo].[Payment] ([PersonSID], [PaymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'INDEX', N'ix_Payment_PersonSID_PaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_Payment_ReasonSID_PaymentSID]
	ON [dbo].[Payment] ([ReasonSID], [PaymentSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'INDEX', N'ix_Payment_ReasonSID_PaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_Payment_PaymentStatusSID]
	ON [dbo].[Payment] ([PaymentStatusSID])
	INCLUDE ([PaymentSID], [PersonSID], [PaymentTypeSID], [GLPostingDate], [DepositDate], [AmountPaid], [Reference], [VerifiedTime], [CancelledTime], [CreateTime])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment Status SID foreign key column and avoids row contention on (parent) Payment Status updates', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'INDEX', N'ix_Payment_PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes a payment in the system.  Payments can be made by individuals who are not recorded in the Person table and therefore no foreign key exists to Person or Org.  The name of the payer is required for tracking and reporting and so is stored directly in the record whether defaulted based on a person record or not.  When payments are made against invoices the Invoice-Payment table is also populated.  ', 'SCHEMA', N'dbo', 'TABLE', N'Payment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this payment is based on', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of payment', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PaymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the payment', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the payment transaction is posted for inclusion in the General Ledger | This value is set by the system automatically for online payments but can be overriden for manual payments.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'GLPostingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the payment was deposited or settled', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'DepositDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The monetary value of the payment', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'AmountPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the check/cheque# or other reference for the payment.  This value can be set as required for certain types of payments through Payment Type in settings.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'Reference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name on the card used for payment. This value is used to help identify how a payment was made during follow-up.  The value is blank except where an payment card was used.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'NameOnCard'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The masked card number used for the online payment. This value is used to help identify how payment was made during follow-up. Only the first 4 and last 4 digits of the card number are retained. ', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PaymentCard'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The transaction or reference number of the payment to allow tracking.  This can be a cheque number, the transaction number of a debit reciept, transaction number from a 3rd party payment processor, etc...', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'TransactionID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is supported by some online payment processors only (e.g. Moneris).  It indicates the time when a server-to-server verification of the transaction processed occurred.  Other details of the verification are stored in the ProcessingLog.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'VerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this payment', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PaymentXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'CONSTRAINT', N'uk_Payment_RowGUID'
GO
ALTER TABLE [dbo].[Payment] SET (LOCK_ESCALATION = TABLE)
GO
