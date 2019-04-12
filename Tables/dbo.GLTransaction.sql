SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GLTransaction] (
		[GLTransactionSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[PaymentSID]                   [int] NOT NULL,
		[InvoicePaymentSID]            [int] NULL,
		[DebitGLAccountCode]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreditGLAccountCode]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Amount]                       [decimal](11, 2) NOT NULL,
		[GLPostingDate]                [date] NOT NULL,
		[PaymentCheckSum]              [int] NOT NULL,
		[InvoicePaymentCheckSum]       [int] NULL,
		[ReversedGLTransactionSID]     [int] NULL,
		[IsExcluded]                   [bit] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[GLTransactionXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_GLTransaction_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_GLTransaction]
		PRIMARY KEY
		CLUSTERED
		([GLTransactionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the GLTransaction table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'CONSTRAINT', N'pk_GLTransaction'
GO
ALTER TABLE [dbo].[GLTransaction]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_GLTransaction]
	CHECK
	([dbo].[fGLTransaction#Check]([GLTransactionSID],[PaymentSID],[InvoicePaymentSID],[DebitGLAccountCode],[CreditGLAccountCode],[Amount],[GLPostingDate],[PaymentCheckSum],[InvoicePaymentCheckSum],[ReversedGLTransactionSID],[IsExcluded],[GLTransactionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[GLTransaction]
CHECK CONSTRAINT [ck_GLTransaction]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_IsExcluded]
	DEFAULT (CONVERT([bit],(0))) FOR [IsExcluded]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[GLTransaction]
	ADD
	CONSTRAINT [df_GLTransaction_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[GLTransaction]
	WITH CHECK
	ADD CONSTRAINT [fk_GLTransaction_InvoicePayment_InvoicePaymentSID]
	FOREIGN KEY ([InvoicePaymentSID]) REFERENCES [dbo].[InvoicePayment] ([InvoicePaymentSID])
ALTER TABLE [dbo].[GLTransaction]
	CHECK CONSTRAINT [fk_GLTransaction_InvoicePayment_InvoicePaymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice payment system ID column in the GLTransaction table match a invoice payment system ID in the Invoice Payment table. It also ensures that records in the Invoice Payment table cannot be deleted if matching child records exist in GLTransaction. Finally, the constraint blocks changes to the value of the invoice payment system ID column in the Invoice Payment if matching child records exist in GLTransaction.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'CONSTRAINT', N'fk_GLTransaction_InvoicePayment_InvoicePaymentSID'
GO
ALTER TABLE [dbo].[GLTransaction]
	WITH CHECK
	ADD CONSTRAINT [fk_GLTransaction_GLTransaction_ReversedGLTransactionSID]
	FOREIGN KEY ([ReversedGLTransactionSID]) REFERENCES [dbo].[GLTransaction] ([GLTransactionSID])
ALTER TABLE [dbo].[GLTransaction]
	CHECK CONSTRAINT [fk_GLTransaction_GLTransaction_ReversedGLTransactionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reversed gltransaction system ID column in the GLTransaction table match a gltransaction system ID in the GLTransaction table. It also ensures that records in the GLTransaction table cannot be deleted if matching child records exist in GLTransaction. Finally, the constraint blocks changes to the value of the gltransaction system ID column in the GLTransaction if matching child records exist in GLTransaction.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'CONSTRAINT', N'fk_GLTransaction_GLTransaction_ReversedGLTransactionSID'
GO
ALTER TABLE [dbo].[GLTransaction]
	WITH CHECK
	ADD CONSTRAINT [fk_GLTransaction_Payment_PaymentSID]
	FOREIGN KEY ([PaymentSID]) REFERENCES [dbo].[Payment] ([PaymentSID])
ALTER TABLE [dbo].[GLTransaction]
	CHECK CONSTRAINT [fk_GLTransaction_Payment_PaymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment system ID column in the GLTransaction table match a payment system ID in the Payment table. It also ensures that records in the Payment table cannot be deleted if matching child records exist in GLTransaction. Finally, the constraint blocks changes to the value of the payment system ID column in the Payment if matching child records exist in GLTransaction.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'CONSTRAINT', N'fk_GLTransaction_Payment_PaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_GLTransaction_GLPostingDate_CreditGLAccountCode]
	ON [dbo].[GLTransaction] ([GLPostingDate], [CreditGLAccountCode])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of GLTransaction searches based on the GLPosting Date + Credit GLAccount Code columns', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'INDEX', N'ix_GLTransaction_GLPostingDate_CreditGLAccountCode'
GO
CREATE NONCLUSTERED INDEX [ix_GLTransaction_GLPostingDate_DebitGLAccountCode]
	ON [dbo].[GLTransaction] ([GLPostingDate], [DebitGLAccountCode])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of GLTransaction searches based on the GLPosting Date + Debit GLAccount Code columns', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'INDEX', N'ix_GLTransaction_GLPostingDate_DebitGLAccountCode'
GO
CREATE NONCLUSTERED INDEX [ix_GLTransaction_InvoicePaymentSID_GLTransactionSID]
	ON [dbo].[GLTransaction] ([InvoicePaymentSID], [GLTransactionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice Payment SID foreign key column and avoids row contention on (parent) Invoice Payment updates', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'INDEX', N'ix_GLTransaction_InvoicePaymentSID_GLTransactionSID'
GO
CREATE NONCLUSTERED INDEX [ix_GLTransaction_PaymentSID_GLTransactionSID]
	ON [dbo].[GLTransaction] ([PaymentSID], [GLTransactionSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment SID foreign key column and avoids row contention on (parent) Payment updates', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'INDEX', N'ix_GLTransaction_PaymentSID_GLTransactionSID'
GO
CREATE NONCLUSTERED INDEX [ix_GLTransaction_ReversedGLTransactionSID_GLTransactionSID]
	ON [dbo].[GLTransaction] ([ReversedGLTransactionSID], [GLTransactionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reversed GLTransaction SID foreign key column and avoids row contention on (parent) GLTransaction updates', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'INDEX', N'ix_GLTransaction_ReversedGLTransactionSID_GLTransactionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the General Ledger entries associated with payments and application of payments to invoices.  Alinity records GL Transactions when payments are entered or move to a "paid" status. When payments are applied to invoices, the associated revenue accounts for each line item on the invoice are credited.  The system detects changes to columns affecting the GL entries by maintaining and comparing "CheckSum" values which are columns in Payment and InvoiceItem. ', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the gltransaction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'GLTransactionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The payment assigned to this gltransaction', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'PaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice payment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'InvoicePaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is used internally by the system to track which version of the payment record the GL transaction was created for.  The value is used to find entries to reverse when edits impacting the GL are made to the source record.  The value is copied from the GLCheckSum column on the Payment record.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'PaymentCheckSum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is used internally by the system to track which version of the payment record the GL transaction was created for.  The value is used to find entries to reverse when edits impacting the GL are made to the source record.  The value is copied from the GLCheckSum column on the Invoice Payment record.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'InvoicePaymentCheckSum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gltransaction this  is defined for', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'ReversedGLTransactionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this transaction should be excluded from reporting to external general ledger programs', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'IsExcluded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the gltransaction | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'GLTransactionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the gltransaction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this gltransaction record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the gltransaction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the gltransaction record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the gltransaction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'GLTransaction', 'CONSTRAINT', N'uk_GLTransaction_RowGUID'
GO
ALTER TABLE [dbo].[GLTransaction] SET (LOCK_ESCALATION = TABLE)
GO
