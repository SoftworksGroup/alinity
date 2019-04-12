SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceItem] (
		[InvoiceItemSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[InvoiceSID]                 [int] NOT NULL,
		[InvoiceItemDescription]     [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Price]                      [decimal](11, 2) NOT NULL,
		[Quantity]                   [int] NOT NULL,
		[Adjustment]                 [decimal](11, 2) NOT NULL,
		[ReasonSID]                  [int] NULL,
		[IsTaxRate1Applied]          [bit] NOT NULL,
		[IsTaxRate2Applied]          [bit] NOT NULL,
		[IsTaxRate3Applied]          [bit] NOT NULL,
		[IsTaxDeductible]            [bit] NOT NULL,
		[GLAccountCode]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CatalogItemSID]             [int] NULL,
		[UserDefinedColumns]         [xml] NULL,
		[InvoiceItemXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_InvoiceItem_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_InvoiceItem]
		PRIMARY KEY
		CLUSTERED
		([InvoiceItemSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Invoice Item table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'CONSTRAINT', N'pk_InvoiceItem'
GO
ALTER TABLE [dbo].[InvoiceItem]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_InvoiceItem]
	CHECK
	([dbo].[fInvoiceItem#Check]([InvoiceItemSID],[InvoiceSID],[InvoiceItemDescription],[Price],[Quantity],[Adjustment],[ReasonSID],[IsTaxRate1Applied],[IsTaxRate2Applied],[IsTaxRate3Applied],[IsTaxDeductible],[GLAccountCode],[CatalogItemSID],[InvoiceItemXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[InvoiceItem]
CHECK CONSTRAINT [ck_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_Quantity]
	DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_Adjustment]
	DEFAULT ((0.00)) FOR [Adjustment]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[InvoiceItem]
	ADD
	CONSTRAINT [df_InvoiceItem_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[InvoiceItem]
	WITH CHECK
	ADD CONSTRAINT [fk_InvoiceItem_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[InvoiceItem]
	CHECK CONSTRAINT [fk_InvoiceItem_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Invoice Item table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Invoice Item. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Invoice Item.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'CONSTRAINT', N'fk_InvoiceItem_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[InvoiceItem]
	WITH CHECK
	ADD CONSTRAINT [fk_InvoiceItem_Invoice_InvoiceSID]
	FOREIGN KEY ([InvoiceSID]) REFERENCES [dbo].[Invoice] ([InvoiceSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[InvoiceItem]
	CHECK CONSTRAINT [fk_InvoiceItem_Invoice_InvoiceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the invoice system ID column in the Invoice Item table match a invoice system ID in the Invoice table. It also ensures that when a record in the Invoice table is deleted, matching child records in the Invoice Item table are deleted as well. Finally, the constraint blocks changes to the value of the invoice system ID column in the Invoice if matching child records exist in Invoice Item.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'CONSTRAINT', N'fk_InvoiceItem_Invoice_InvoiceSID'
GO
ALTER TABLE [dbo].[InvoiceItem]
	WITH CHECK
	ADD CONSTRAINT [fk_InvoiceItem_CatalogItem_CatalogItemSID]
	FOREIGN KEY ([CatalogItemSID]) REFERENCES [dbo].[CatalogItem] ([CatalogItemSID])
ALTER TABLE [dbo].[InvoiceItem]
	CHECK CONSTRAINT [fk_InvoiceItem_CatalogItem_CatalogItemSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the catalog item system ID column in the Invoice Item table match a catalog item system ID in the Catalog Item table. It also ensures that records in the Catalog Item table cannot be deleted if matching child records exist in Invoice Item. Finally, the constraint blocks changes to the value of the catalog item system ID column in the Catalog Item if matching child records exist in Invoice Item.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'CONSTRAINT', N'fk_InvoiceItem_CatalogItem_CatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_InvoiceItem_CatalogItemSID_InvoiceItemSID]
	ON [dbo].[InvoiceItem] ([CatalogItemSID], [InvoiceItemSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Catalog Item SID foreign key column and avoids row contention on (parent) Catalog Item updates', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'INDEX', N'ix_InvoiceItem_CatalogItemSID_InvoiceItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_InvoiceItem_InvoiceSID_InvoiceItemSID]
	ON [dbo].[InvoiceItem] ([InvoiceSID], [InvoiceItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Invoice SID foreign key column and avoids row contention on (parent) Invoice updates', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'INDEX', N'ix_InvoiceItem_InvoiceSID_InvoiceItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_InvoiceItem_ReasonSID_InvoiceItemSID]
	ON [dbo].[InvoiceItem] ([ReasonSID], [InvoiceItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'INDEX', N'ix_InvoiceItem_ReasonSID_InvoiceItemSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_InvoiceItem_LegacyKey]
	ON [dbo].[InvoiceItem] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'INDEX', N'ux_InvoiceItem_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table gives us a snapshot of each item on an invoice.  When an item is added to an invoice, we insert the revenue item’s price, label, and description into the table.  This is used for auditing and reporting', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice item assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'InvoiceItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The invoice this item is defined for', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A copy of the revenue item description.  This value can be updated to unique descriptions during the invoicing process.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'InvoiceItemDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A copy of the price of the revenue item as it was when added to the invoice', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The quantity of the item being purchased', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'Quantity'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice item', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A flag which represents if GST should be applied to the revenue item when invoiced', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'IsTaxRate1Applied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A flag which represents if PST/HST should be applied to the revenue item when invoiced', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'IsTaxRate2Applied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A flag which represents if another tax should be applied to the revenue item when invoiced.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'IsTaxRate3Applied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the catalog item assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the invoice item | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'InvoiceItemXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the invoice item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this invoice item record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the invoice item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the invoice item record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice item record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'InvoiceItem', 'CONSTRAINT', N'uk_InvoiceItem_RowGUID'
GO
ALTER TABLE [dbo].[InvoiceItem] SET (LOCK_ESCALATION = TABLE)
GO
