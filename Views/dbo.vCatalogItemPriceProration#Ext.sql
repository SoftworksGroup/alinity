SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCatalogItemPriceProration#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vCatalogItemPriceProration#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.CatalogItemPriceProration base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vCatalogItemPriceProration (referred to as the "entity" view in SGI documentation).

Columns required to support the EF include constants passed by client and middle tier modules into the table API procedures as
parameters. These values control the insert/update/delete behaviour of the sprocs. For example: the IsNullApplied bit is set ON
in the view so that update procedures overwrite column values when matching parameters are NULL on calls from the client tier.
The default for this column in the call signature of the sproc is 0 (off) so that calls from the back-end do not overwrite with
null values.  The zContext XML value is always null but is required for binding to sproc calls using EF and RIA.

You can add additional columns, joins and examples of calling syntax, by placing them between the code tag pairs provided.  Items
placed within code tag pairs are preserved on regeneration.  Note that all additions to this view become part of the base product
and deploy for all client configurations.  This view is NOT an extension point for client-specific configurations.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 cipp.CatalogItemPriceProrationSID
	,cip.CatalogItemSID
	,cip.Price                                                                         CatalogItemPricePrice
	,cip.EffectiveTime
	,cip.RowGUID                                                                       CatalogItemPriceRowGUID
	,dbo.fCatalogItemPriceProration#IsDeleteEnabled(cipp.CatalogItemPriceProrationSID) IsDeleteEnabled--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                                IsReselected		-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                                    IsNullApplied	-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                                 zContext				-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
	,dbo.fRegistrationYear#FiscalMonthDay(cipp.StartMonthDay, zx.YearStartMonth)       FiscalStartMonthDay -- Identifies the month order in the year when the price should start applying | Use this value for ordering prorated prices
  --! </MoreColumns>
from
	dbo.CatalogItemPriceProration cipp
join
	dbo.CatalogItemPrice          cip    on cipp.CatalogItemPriceSID = cip.CatalogItemPriceSID
--! <MoreJoins>
join
(
	select
		month(rsy.YearStartTime) YearStartMonth
	from
		dbo.RegistrationScheduleYear rsy
	where
		rsy.RegistrationYear = dbo.fRegistrationYear#Current()
)																zx on 1													= 1
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the catalog item price proration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'CatalogItemPriceProrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item this price is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The price of the item', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'CatalogItemPricePrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the price becomes effective.  Allows for future dated pricing', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the catalog item price record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'CatalogItemPriceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vCatalogItemPriceProration#Ext', 'COLUMN', N'zContext'
GO