SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CatalogItem] (
		[CatalogItemSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[CatalogItemLabel]              [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[InvoiceItemDescription]        [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsLateFee]                     [bit] NOT NULL,
		[ItemDetailedDescription]       [varbinary](max) NULL,
		[ItemSmallImage]                [varbinary](max) NULL,
		[ItemLargeImage]                [varbinary](max) NULL,
		[ImageAlternateText]            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAvailableOnClientPortal]     [bit] NOT NULL,
		[IsComplaintPenalty]            [bit] NOT NULL,
		[GLAccountSID]                  [int] NOT NULL,
		[IsTaxRate1Applied]             [bit] NOT NULL,
		[IsTaxRate2Applied]             [bit] NOT NULL,
		[IsTaxRate3Applied]             [bit] NOT NULL,
		[IsTaxDeductible]               [bit] NOT NULL,
		[EffectiveTime]                 [datetime] NOT NULL,
		[ExpiryTime]                    [datetime] NULL,
		[FileTypeSCD]                   [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileTypeSID]                   [int] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[CatalogItemXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_CatalogItem_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CatalogItem_CatalogItemLabel]
		UNIQUE
		NONCLUSTERED
		([CatalogItemLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CatalogItem]
		PRIMARY KEY
		CLUSTERED
		([CatalogItemSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Catalog Item table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'CONSTRAINT', N'pk_CatalogItem'
GO
ALTER TABLE [dbo].[CatalogItem]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CatalogItem]
	CHECK
	([dbo].[fCatalogItem#Check]([CatalogItemSID],[CatalogItemLabel],[InvoiceItemDescription],[IsLateFee],[ImageAlternateText],[IsAvailableOnClientPortal],[IsComplaintPenalty],[GLAccountSID],[IsTaxRate1Applied],[IsTaxRate2Applied],[IsTaxRate3Applied],[IsTaxDeductible],[EffectiveTime],[ExpiryTime],[FileTypeSCD],[FileTypeSID],[CatalogItemXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CatalogItem]
CHECK CONSTRAINT [ck_CatalogItem]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsLateFee]
	DEFAULT (CONVERT([bit],(0))) FOR [IsLateFee]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsAvailableOnClientPortal]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAvailableOnClientPortal]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsComplaintPenalty]
	DEFAULT (CONVERT([bit],(0))) FOR [IsComplaintPenalty]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsTaxRate1Applied]
	DEFAULT ((0)) FOR [IsTaxRate1Applied]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsTaxRate2Applied]
	DEFAULT ((0)) FOR [IsTaxRate2Applied]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsTaxRate3Applied]
	DEFAULT ((0)) FOR [IsTaxRate3Applied]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsTaxDeductible]
	DEFAULT ((1)) FOR [IsTaxDeductible]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_EffectiveTime]
	DEFAULT (CONVERT([datetime],[sf].[fToday]())) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_FileTypeSCD]
	DEFAULT ('.HTML') FOR [FileTypeSCD]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CatalogItem]
	ADD
	CONSTRAINT [df_CatalogItem_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[CatalogItem]
	WITH CHECK
	ADD CONSTRAINT [fk_CatalogItem_GLAccount_GLAccountSID]
	FOREIGN KEY ([GLAccountSID]) REFERENCES [dbo].[GLAccount] ([GLAccountSID])
ALTER TABLE [dbo].[CatalogItem]
	CHECK CONSTRAINT [fk_CatalogItem_GLAccount_GLAccountSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the glaccount system ID column in the Catalog Item table match a glaccount system ID in the GLAccount table. It also ensures that records in the GLAccount table cannot be deleted if matching child records exist in Catalog Item. Finally, the constraint blocks changes to the value of the glaccount system ID column in the GLAccount if matching child records exist in Catalog Item.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'CONSTRAINT', N'fk_CatalogItem_GLAccount_GLAccountSID'
GO
ALTER TABLE [dbo].[CatalogItem]
	WITH CHECK
	ADD CONSTRAINT [fk_CatalogItem_SF_FileType_FileTypeSID]
	FOREIGN KEY ([FileTypeSID]) REFERENCES [sf].[FileType] ([FileTypeSID])
ALTER TABLE [dbo].[CatalogItem]
	CHECK CONSTRAINT [fk_CatalogItem_SF_FileType_FileTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file type system ID column in the Catalog Item table match a file type system ID in the File Type table. It also ensures that records in the File Type table cannot be deleted if matching child records exist in Catalog Item. Finally, the constraint blocks changes to the value of the file type system ID column in the File Type if matching child records exist in Catalog Item.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'CONSTRAINT', N'fk_CatalogItem_SF_FileType_FileTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_CatalogItem_FileTypeSID_CatalogItemSID]
	ON [dbo].[CatalogItem] ([FileTypeSID], [CatalogItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Type SID foreign key column and avoids row contention on (parent) File Type updates', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'INDEX', N'ix_CatalogItem_FileTypeSID_CatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_CatalogItem_GLAccountSID_CatalogItemSID]
	ON [dbo].[CatalogItem] ([GLAccountSID], [CatalogItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the GLAccount SID foreign key column and avoids row contention on (parent) GLAccount updates', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'INDEX', N'ix_CatalogItem_GLAccountSID_CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the list of items for which the organization charges fees.  These items are added as invoice-item records in the invoicing process. The catalog items include registration fees, application fees, exams, conference attendance fees,  and may also include physical products  like T-Shirts and other logo-wear.  Items may be directly selectable by members on the client portal or may be restricted for adding on invoices created by Administrators only.  Pricing for items changes over time as stored in the Catalog-Item-Price table.  Catalog items may be associated with (one) General Ledger Account (typically a revenue account). ', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the catalog item assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the catalog item to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'CatalogItemLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the item to include on the invoice line', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'InvoiceItemDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a late fee (applies to renewals only) - the effective date for which is defined on the practice register', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsLateFee'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the item to include on an item detailed page.  If a link to an external page is required, include it in this content (HTML is supported)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'ItemDetailedDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A picture of the item for display on the website.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'ItemSmallImage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A thumbnail picture of the item for display on the website', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'ItemLargeImage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Text to display instead of the image if image display is turned off on the client browser', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'ImageAlternateText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this item is available for selection by members on the website (otherwise it is available to administrators only)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsAvailableOnClientPortal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this catalog item should appear in the list of penalties/fines displayed for recording complaint outcomes', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsComplaintPenalty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The glaccount assigned to this catalog item', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'GLAccountSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if GST should be applied to the revenue item when invoiced', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsTaxRate1Applied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if PST/HST should be applied to the revenue item when invoiced', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsTaxRate2Applied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if [Tax Type #3] should be applied to the revenue item when invoiced', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsTaxRate3Applied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this item is considered tax deductible (includes the item on tax receipts)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsTaxDeductible'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the item becomes available for including on invoices.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the item is no longer available for including on invoices.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document the email is stored as | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".PDF" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of catalog item', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the catalog item | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'CatalogItemXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the catalog item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this catalog item record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the catalog item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the catalog item record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the catalog item record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'CONSTRAINT', N'uk_CatalogItem_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Catalog Item Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItem', 'CONSTRAINT', N'uk_CatalogItem_CatalogItemLabel'
GO
ALTER TABLE [dbo].[CatalogItem] SET (LOCK_ESCALATION = TABLE)
GO
