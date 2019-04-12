SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Invoice] (
		[InvoiceSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]              [int] NOT NULL,
		[InvoiceDate]            [date] NOT NULL,
		[Tax1Label]              [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax1Rate]               [decimal](4, 4) NULL,
		[Tax1GLAccountCode]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax2Label]              [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax2Rate]               [decimal](4, 4) NULL,
		[Tax2GLAccountCode]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax3Label]              [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax3Rate]               [decimal](4, 4) NULL,
		[Tax3GLAccountCode]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegistrationYear]       [smallint] NOT NULL,
		[CancelledTime]          [datetimeoffset](7) NULL,
		[ReasonSID]              [int] NULL,
		[IsRefund]               [bit] NOT NULL,
		[ComplaintSID]           [int] NULL,
		[UserDefinedColumns]     [xml] NULL,
		[InvoiceXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Invoice_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Invoice]
		PRIMARY KEY
		CLUSTERED
		([InvoiceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Invoice table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'CONSTRAINT', N'pk_Invoice'
GO
ALTER TABLE [dbo].[Invoice]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Invoice]
	CHECK
	([dbo].[fInvoice#Check]([InvoiceSID],[PersonSID],[InvoiceDate],[Tax1Label],[Tax1Rate],[Tax1GLAccountCode],[Tax2Label],[Tax2Rate],[Tax2GLAccountCode],[Tax3Label],[Tax3Rate],[Tax3GLAccountCode],[RegistrationYear],[CancelledTime],[ReasonSID],[IsRefund],[ComplaintSID],[InvoiceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Invoice]
CHECK CONSTRAINT [ck_Invoice]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_InvoiceDate]
	DEFAULT ([sf].[fToday]()) FOR [InvoiceDate]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_Tax1Label]
	DEFAULT (N'N/A') FOR [Tax1Label]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_Tax1Rate]
	DEFAULT ((0.0)) FOR [Tax1Rate]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_Tax2Label]
	DEFAULT (N'N/A') FOR [Tax2Label]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_Tax2Rate]
	DEFAULT ((0.0)) FOR [Tax2Rate]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_Tax3Label]
	DEFAULT (N'N/A') FOR [Tax3Label]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_Tax3Rate]
	DEFAULT ((0.0)) FOR [Tax3Rate]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_IsRefund]
	DEFAULT (CONVERT([bit],(0))) FOR [IsRefund]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Invoice]
	ADD
	CONSTRAINT [df_Invoice_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Invoice]
	WITH CHECK
	ADD CONSTRAINT [fk_Invoice_Complaint_ComplaintSID]
	FOREIGN KEY ([ComplaintSID]) REFERENCES [dbo].[Complaint] ([ComplaintSID])
ALTER TABLE [dbo].[Invoice]
	CHECK CONSTRAINT [fk_Invoice_Complaint_ComplaintSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint system ID column in the Invoice table match a complaint system ID in the Complaint table. It also ensures that records in the Complaint table cannot be deleted if matching child records exist in Invoice. Finally, the constraint blocks changes to the value of the complaint system ID column in the Complaint if matching child records exist in Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'CONSTRAINT', N'fk_Invoice_Complaint_ComplaintSID'
GO
ALTER TABLE [dbo].[Invoice]
	WITH CHECK
	ADD CONSTRAINT [fk_Invoice_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[Invoice]
	CHECK CONSTRAINT [fk_Invoice_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Invoice table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Invoice. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'CONSTRAINT', N'fk_Invoice_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[Invoice]
	WITH CHECK
	ADD CONSTRAINT [fk_Invoice_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[Invoice]
	CHECK CONSTRAINT [fk_Invoice_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Invoice table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Invoice. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'CONSTRAINT', N'fk_Invoice_SF_Person_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_Invoice_ComplaintSID_InvoiceSID]
	ON [dbo].[Invoice] ([ComplaintSID], [InvoiceSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint SID foreign key column and avoids row contention on (parent) Complaint updates', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'INDEX', N'ix_Invoice_ComplaintSID_InvoiceSID'
GO
CREATE NONCLUSTERED INDEX [ix_Invoice_InvoiceDate]
	ON [dbo].[Invoice] ([InvoiceDate])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Invoice searches based on the Invoice Date column', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'INDEX', N'ix_Invoice_InvoiceDate'
GO
CREATE NONCLUSTERED INDEX [ix_Invoice_PersonSID_InvoiceSID]
	ON [dbo].[Invoice] ([PersonSID], [InvoiceSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'INDEX', N'ix_Invoice_PersonSID_InvoiceSID'
GO
CREATE NONCLUSTERED INDEX [ix_Invoice_ReasonSID_InvoiceSID]
	ON [dbo].[Invoice] ([ReasonSID], [InvoiceSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'INDEX', N'ix_Invoice_ReasonSID_InvoiceSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Invoice_LegacyKey]
	ON [dbo].[Invoice] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'INDEX', N'ux_Invoice_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents an invoice which contains one or many items which the buyer wishes to purchase', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this invoice is based on', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date of the invoice. Defaults to the current date but may be edited when back-dating is required.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'Tax1GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'Tax2GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'Tax3GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year for which the revenue on the invoice is being collected. If this is not the same as the registration year the invoice is generated in, then deferred revenue accounts will apply to the exported transaction if they have been setup.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice was setup to record a refund. ', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'IsRefund'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this invoice', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the invoice | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'InvoiceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the invoice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this invoice record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the invoice | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the invoice record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Invoice', 'CONSTRAINT', N'uk_Invoice_RowGUID'
GO
ALTER TABLE [dbo].[Invoice] SET (LOCK_ESCALATION = TABLE)
GO
