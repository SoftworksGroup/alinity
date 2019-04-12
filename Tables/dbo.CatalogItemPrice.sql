SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CatalogItemPrice] (
		[CatalogItemPriceSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[CatalogItemSID]          [int] NOT NULL,
		[Price]                   [decimal](11, 2) NOT NULL,
		[EffectiveTime]           [datetime] NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[CatalogItemPriceXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_CatalogItemPrice_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CatalogItemPrice]
		PRIMARY KEY
		CLUSTERED
		([CatalogItemPriceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Catalog Item Price table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'CONSTRAINT', N'pk_CatalogItemPrice'
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CatalogItemPrice]
	CHECK
	([dbo].[fCatalogItemPrice#Check]([CatalogItemPriceSID],[CatalogItemSID],[Price],[EffectiveTime],[CatalogItemPriceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CatalogItemPrice]
CHECK CONSTRAINT [ck_CatalogItemPrice]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_EffectiveTime]
	DEFAULT (CONVERT([datetime],[sf].[fToday]())) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	ADD
	CONSTRAINT [df_CatalogItemPrice_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CatalogItemPrice]
	WITH CHECK
	ADD CONSTRAINT [fk_CatalogItemPrice_CatalogItem_CatalogItemSID]
	FOREIGN KEY ([CatalogItemSID]) REFERENCES [dbo].[CatalogItem] ([CatalogItemSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[CatalogItemPrice]
	CHECK CONSTRAINT [fk_CatalogItemPrice_CatalogItem_CatalogItemSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the catalog item system ID column in the Catalog Item Price table match a catalog item system ID in the Catalog Item table. It also ensures that when a record in the Catalog Item table is deleted, matching child records in the Catalog Item Price table are deleted as well. Finally, the constraint blocks changes to the value of the catalog item system ID column in the Catalog Item if matching child records exist in Catalog Item Price.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'CONSTRAINT', N'fk_CatalogItemPrice_CatalogItem_CatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_CatalogItemPrice_CatalogItemSID_CatalogItemPriceSID]
	ON [dbo].[CatalogItemPrice] ([CatalogItemSID], [CatalogItemPriceSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Catalog Item SID foreign key column and avoids row contention on (parent) Catalog Item updates', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'INDEX', N'ix_CatalogItemPrice_CatalogItemSID_CatalogItemPriceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the price set for catalog items.  The price may change over time.  New prices become effective based on the setting of the Effective-Time column in this table.  When an invoice is created and a catalog item is selected, the price at the time of creation is applied on the invoice-item record.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the catalog item price assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'CatalogItemPriceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item this price is defined for', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The price of the item', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the price becomes effective.  Allows for future dated pricing', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the catalog item price | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'CatalogItemPriceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the catalog item price | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this catalog item price record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the catalog item price | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the catalog item price record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the catalog item price record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPrice', 'CONSTRAINT', N'uk_CatalogItemPrice_RowGUID'
GO
ALTER TABLE [dbo].[CatalogItemPrice] SET (LOCK_ESCALATION = TABLE)
GO
