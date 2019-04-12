SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoicePayment] (
		[InvoicePaymentSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[InvoiceSID]             [int] NOT NULL,
		[PaymentSID]             [int] NOT NULL,
		[AmountApplied]          [decimal](11, 2) NOT NULL,
		[AppliedDate]            [date] NOT NULL,
		[GLPostingDate]          [date] NULL,
		[CancelledTime]          [datetimeoffset](7) NULL,
		[ReasonSID]              [int] NULL,
		[UserDefinedColumns]     [xml] NULL,
		[InvoicePaymentXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_InvoicePayment_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_InvoicePayment]
		PRIMARY KEY
		CLUSTERED
		([InvoicePaymentSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Invoice Payment table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'CONSTRAINT', N'pk_InvoicePayment'
GO
ALTER TABLE [dbo].[InvoicePayment]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_InvoicePayment]
	CHECK
	([dbo].[fInvoicePayment#Check]([InvoicePaymentSID],[InvoiceSID],[PaymentSID],[AmountApplied],[AppliedDate],[GLPostingDate],[CancelledTime],[ReasonSID],[InvoicePaymentXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[InvoicePayment]
CHECK CONSTRAINT [ck_InvoicePayment]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_AmountApplied]
	DEFAULT ((0.00)) FOR [AmountApplied]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_AppliedDate]
	DEFAULT ([sf].[fToday]()) FOR [AppliedDate]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[InvoicePayment]
	ADD
	CONSTRAINT [df_InvoicePayment_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[InvoicePayment]
	WITH CHECK
	ADD CONSTRAINT [fk_InvoicePayment_Payment_PaymentSID]
	FOREIGN KEY ([PaymentSID]) REFERENCES [dbo].[Payment] ([PaymentSID])
ALTER TABLE [dbo].[InvoicePayment]
	CHECK CONSTRAINT [fk_InvoicePayment_Payment_PaymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment system ID column in the Invoice Payment table match a payment system ID in the Payment table. It also ensures that records in the Payment table cannot be deleted if matching child records exist in Invoice Payment. Finally, the constraint blocks changes to the value of the payment system ID column in the Payment if matching child records exist in Invoice Payment.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'CONSTRAINT', N'fk_InvoicePayment_Payment_PaymentSID'
GO
ALTER TABLE [dbo].[InvoicePayment]
	WITH CHECK
	ADD CONSTRAINT [fk_InvoicePayment_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[InvoicePayment]
	CHECK CONSTRAINT [fk_InvoicePayment_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Invoice Payment table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Invoice Payment. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Invoice Payment.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'CONSTRAINT', N'fk_InvoicePayment_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[InvoicePayment]
	WITH CHECK
	ADD CONSTRAINT [fk_InvoicePayment_Invoice_InvoiceSID]
	FOREIGN KEY ([InvoiceSID]) REFERENCES [dbo].[Invoice] ([InvoiceSID])
ALTER TABLE [dbo].[InvoicePayment]
	CHECK CONSTRAINT [fk_InvoicePayment_Invoice_InvoiceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice system ID column in the Invoice Payment table match a invoice system ID in the Invoice table. It also ensures that records in the Invoice table cannot be deleted if matching child records exist in Invoice Payment. Finally, the constraint blocks changes to the value of the invoice system ID column in the Invoice if matching child records exist in Invoice Payment.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'CONSTRAINT', N'fk_InvoicePayment_Invoice_InvoiceSID'
GO
CREATE NONCLUSTERED INDEX [ix_InvoicePayment_InvoiceSID_InvoicePaymentSID]
	ON [dbo].[InvoicePayment] ([InvoiceSID], [InvoicePaymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice SID foreign key column and avoids row contention on (parent) Invoice updates', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'INDEX', N'ix_InvoicePayment_InvoiceSID_InvoicePaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_InvoicePayment_PaymentSID_InvoicePaymentSID]
	ON [dbo].[InvoicePayment] ([PaymentSID], [InvoicePaymentSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment SID foreign key column and avoids row contention on (parent) Payment updates', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'INDEX', N'ix_InvoicePayment_PaymentSID_InvoicePaymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_InvoicePayment_ReasonSID_InvoicePaymentSID]
	ON [dbo].[InvoicePayment] ([ReasonSID], [InvoicePaymentSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'INDEX', N'ix_InvoicePayment_ReasonSID_InvoicePaymentSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_InvoicePayment_LegacyKey]
	ON [dbo].[InvoicePayment] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'INDEX', N'ux_InvoicePayment_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the payment amount applied to an invoice.  This allows support for multiple payments to one invoice and one payment to multiple invoices', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice payment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'InvoicePaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The invoice this payment is defined for', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The payment assigned to this invoice', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'PaymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The amount of money applied to the invoice.  This allows us to have one payment pay for multiple invoices.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'AmountApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the payment should be considered applied to the invoice.  | If the payment is entered late, this may be edited to a value before the current date. Must be after Deposit Date and Invoice Date.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'AppliedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the revenue transactions associated with the application of the payment are posted for inclusion in the General Ledger | This value is set by the system automatically by the system but can be overriden for manual payments.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'GLPostingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice payment', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the invoice payment | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'InvoicePaymentXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the invoice payment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this invoice payment record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the invoice payment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the invoice payment record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice payment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'InvoicePayment', 'CONSTRAINT', N'uk_InvoicePayment_RowGUID'
GO
ALTER TABLE [dbo].[InvoicePayment] SET (LOCK_ESCALATION = TABLE)
GO
