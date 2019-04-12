SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CatalogItemPriceProration] (
		[CatalogItemPriceProrationSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[CatalogItemPriceSID]              [int] NOT NULL,
		[StartMonthDay]                    [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Price]                            [decimal](11, 2) NOT NULL,
		[PercentageOfCurrentPrice]         [decimal](6, 3) NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[CatalogItemPriceProrationXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_CatalogItemPriceProration_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CatalogItemPriceProration]
		PRIMARY KEY
		CLUSTERED
		([CatalogItemPriceProrationSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Catalog Item Price Proration table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'CONSTRAINT', N'pk_CatalogItemPriceProration'
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CatalogItemPriceProration]
	CHECK
	([dbo].[fCatalogItemPriceProration#Check]([CatalogItemPriceProrationSID],[CatalogItemPriceSID],[StartMonthDay],[Price],[PercentageOfCurrentPrice],[CatalogItemPriceProrationXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
CHECK CONSTRAINT [ck_CatalogItemPriceProration]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_Price]
	DEFAULT ((0.0)) FOR [Price]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_PercentageOfCurrentPrice]
	DEFAULT ((0.0)) FOR [PercentageOfCurrentPrice]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	ADD
	CONSTRAINT [df_CatalogItemPriceProration_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[CatalogItemPriceProration]
	WITH CHECK
	ADD CONSTRAINT [fk_CatalogItemPriceProration_CatalogItemPrice_CatalogItemPriceSID]
	FOREIGN KEY ([CatalogItemPriceSID]) REFERENCES [dbo].[CatalogItemPrice] ([CatalogItemPriceSID])
ALTER TABLE [dbo].[CatalogItemPriceProration]
	CHECK CONSTRAINT [fk_CatalogItemPriceProration_CatalogItemPrice_CatalogItemPriceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the catalog item price system ID column in the Catalog Item Price Proration table match a catalog item price system ID in the Catalog Item Price table. It also ensures that records in the Catalog Item Price table cannot be deleted if matching child records exist in Catalog Item Price Proration. Finally, the constraint blocks changes to the value of the catalog item price system ID column in the Catalog Item Price if matching child records exist in Catalog Item Price Proration.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'CONSTRAINT', N'fk_CatalogItemPriceProration_CatalogItemPrice_CatalogItemPriceSID'
GO
CREATE NONCLUSTERED INDEX [ix_CatalogItemPriceProration_CatalogItemPriceSID_CatalogItemPriceProrationSID]
	ON [dbo].[CatalogItemPriceProration] ([CatalogItemPriceSID], [CatalogItemPriceProrationSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Catalog Item Price SID foreign key column and avoids row contention on (parent) Catalog Item Price updates', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'INDEX', N'ix_CatalogItemPriceProration_CatalogItemPriceSID_CatalogItemPriceProrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to support prorating of the full price of the item to lesser amounts as the registration year progresses.  For example, half-way through the registration year 50% of the full-price might be charged.  If there are no proration entries for a given catalog-item-price record then the full price is charged on the invoice. The amount charged on an invoice can be adjusted by administrators using the invoice adjustment feature.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the catalog item price proration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'CatalogItemPriceProrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item price this proration is defined for', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'CatalogItemPriceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The month and day in the year when the reduced fee is applied. This price continues to apply unless another prorated fee is defined for later in the year  | Prorated fees are not supported for temporary permits.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'StartMonthDay'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The price as a decimal', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the catalog item price proration | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'CatalogItemPriceProrationXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the catalog item price proration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this catalog item price proration record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the catalog item price proration | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the catalog item price proration record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the catalog item price proration record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CatalogItemPriceProration', 'CONSTRAINT', N'uk_CatalogItemPriceProration_RowGUID'
GO
ALTER TABLE [dbo].[CatalogItemPriceProration] SET (LOCK_ESCALATION = TABLE)
GO
