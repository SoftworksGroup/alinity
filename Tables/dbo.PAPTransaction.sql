SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAPTransaction] (
		[PAPTransactionSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[PAPBatchSID]            [int] NOT NULL,
		[PAPSubscriptionSID]     [int] NOT NULL,
		[AccountNo]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[InstitutionNo]          [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TransitNo]              [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[WithdrawalAmount]       [decimal](11, 2) NOT NULL,
		[IsRejected]             [bit] NOT NULL,
		[PaymentSID]             [int] NULL,
		[UserDefinedColumns]     [xml] NULL,
		[PAPTransactionXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_PAPTransaction_PAPBatchSID_PAPSubscriptionSID]
		UNIQUE
		NONCLUSTERED
		([PAPBatchSID], [PAPSubscriptionSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PAPTransaction_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PAPTransaction]
		PRIMARY KEY
		CLUSTERED
		([PAPTransactionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the PAPTransaction table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'CONSTRAINT', N'pk_PAPTransaction'
GO
ALTER TABLE [dbo].[PAPTransaction]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PAPTransaction]
	CHECK
	([dbo].[fPAPTransaction#Check]([PAPTransactionSID],[PAPBatchSID],[PAPSubscriptionSID],[AccountNo],[InstitutionNo],[TransitNo],[WithdrawalAmount],[IsRejected],[PaymentSID],[PAPTransactionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PAPTransaction]
CHECK CONSTRAINT [ck_PAPTransaction]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_IsRejected]
	DEFAULT ((0)) FOR [IsRejected]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PAPTransaction]
	ADD
	CONSTRAINT [df_PAPTransaction_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PAPTransaction]
	WITH CHECK
	ADD CONSTRAINT [fk_PAPTransaction_PAPBatch_PAPBatchSID]
	FOREIGN KEY ([PAPBatchSID]) REFERENCES [dbo].[PAPBatch] ([PAPBatchSID])
ALTER TABLE [dbo].[PAPTransaction]
	CHECK CONSTRAINT [fk_PAPTransaction_PAPBatch_PAPBatchSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the papbatch system ID column in the PAPTransaction table match a papbatch system ID in the PAPBatch table. It also ensures that records in the PAPBatch table cannot be deleted if matching child records exist in PAPTransaction. Finally, the constraint blocks changes to the value of the papbatch system ID column in the PAPBatch if matching child records exist in PAPTransaction.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'CONSTRAINT', N'fk_PAPTransaction_PAPBatch_PAPBatchSID'
GO
ALTER TABLE [dbo].[PAPTransaction]
	WITH CHECK
	ADD CONSTRAINT [fk_PAPTransaction_PAPSubscription_PAPSubscriptionSID]
	FOREIGN KEY ([PAPSubscriptionSID]) REFERENCES [dbo].[PAPSubscription] ([PAPSubscriptionSID])
ALTER TABLE [dbo].[PAPTransaction]
	CHECK CONSTRAINT [fk_PAPTransaction_PAPSubscription_PAPSubscriptionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the papsubscription system ID column in the PAPTransaction table match a papsubscription system ID in the PAPSubscription table. It also ensures that records in the PAPSubscription table cannot be deleted if matching child records exist in PAPTransaction. Finally, the constraint blocks changes to the value of the papsubscription system ID column in the PAPSubscription if matching child records exist in PAPTransaction.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'CONSTRAINT', N'fk_PAPTransaction_PAPSubscription_PAPSubscriptionSID'
GO
ALTER TABLE [dbo].[PAPTransaction]
	WITH CHECK
	ADD CONSTRAINT [fk_PAPTransaction_Payment_PaymentSID]
	FOREIGN KEY ([PaymentSID]) REFERENCES [dbo].[Payment] ([PaymentSID])
ALTER TABLE [dbo].[PAPTransaction]
	CHECK CONSTRAINT [fk_PAPTransaction_Payment_PaymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment system ID column in the PAPTransaction table match a payment system ID in the Payment table. It also ensures that records in the Payment table cannot be deleted if matching child records exist in PAPTransaction. Finally, the constraint blocks changes to the value of the payment system ID column in the Payment if matching child records exist in PAPTransaction.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'CONSTRAINT', N'fk_PAPTransaction_Payment_PaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_PAPTransaction_PAPSubscriptionSID_PAPTransactionSID]
	ON [dbo].[PAPTransaction] ([PAPSubscriptionSID], [PAPTransactionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the PAPSubscription SID foreign key column and avoids row contention on (parent) PAPSubscription updates', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'INDEX', N'ix_PAPTransaction_PAPSubscriptionSID_PAPTransactionSID'
GO
CREATE NONCLUSTERED INDEX [ix_PAPTransaction_PaymentSID_PAPTransactionSID]
	ON [dbo].[PAPTransaction] ([PaymentSID], [PAPTransactionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment SID foreign key column and avoids row contention on (parent) Payment updates', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'INDEX', N'ix_PAPTransaction_PaymentSID_PAPTransactionSID'
GO
CREATE NONCLUSTERED INDEX [ix_PAPTransaction_PAPBatchSID]
	ON [dbo].[PAPTransaction] ([PAPBatchSID])
	INCLUDE ([WithdrawalAmount], [IsRejected], [PaymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the PAPBatch SID foreign key column and avoids row contention on (parent) PAPBatch updates', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'INDEX', N'ix_PAPTransaction_PAPBatchSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pre-authorized payment transactions are created when a file of banking information is generated for  the host bank to process payments.  The file is stored in the PAP-Batch table. It is based on the transaction created here for each current subscriber to the PAP program.  Once the bank has processed the file and reported back on the status of transactions, any that are declined/rejected are marked and the batch can be approved.  The approval process creates a (dbo) Payment record for each transaction line and applies the payment to invoices where possible.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the paptransaction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'PAPTransactionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The papbatch assigned to this paptransaction', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'PAPBatchSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The papsubscription assigned to this paptransaction', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'PAPSubscriptionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The monetary value of the payment', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'WithdrawalAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this transaction was not processed successfully.  No payment was received.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'IsRejected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'PaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the paptransaction | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'PAPTransactionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the paptransaction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this paptransaction record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the paptransaction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the paptransaction record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the paptransaction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "PAPBatch SID + PAPSubscription SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'CONSTRAINT', N'uk_PAPTransaction_PAPBatchSID_PAPSubscriptionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PAPTransaction', 'CONSTRAINT', N'uk_PAPTransaction_RowGUID'
GO
ALTER TABLE [dbo].[PAPTransaction] SET (LOCK_ESCALATION = TABLE)
GO
