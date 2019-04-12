SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPaymentStatus]
as
/*********************************************************************************************************************************
View    : dbo.vPaymentStatus
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PaymentStatus - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PaymentStatus table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPaymentStatusExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPaymentStatusExt documentation for details. To add additional content to this view, customize
the dbo.vPaymentStatusExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ps.PaymentStatusSID
	,ps.PaymentStatusSCD
	,ps.PaymentStatusLabel
	,ps.Description
	,ps.IsPaid
	,ps.PaymentStatusSequence
	,ps.UserDefinedColumns
	,ps.PaymentStatusXID
	,ps.LegacyKey
	,ps.IsDeleted
	,ps.CreateUser
	,ps.CreateTime
	,ps.UpdateUser
	,ps.UpdateTime
	,ps.RowGUID
	,ps.RowStamp
	,psx.IsDeleteEnabled
	,psx.IsReselected
	,psx.IsNullApplied
	,psx.zContext
from
	dbo.PaymentStatus      ps
join
	dbo.vPaymentStatus#Ext psx	on ps.PaymentStatusSID = psx.PaymentStatusSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PaymentStatus', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the payment status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'PaymentStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the payment status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'PaymentStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this status indicates the payment is in good standing and money was successfully received (or is assumed to be received as in the case of a check).', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'PaymentStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPaymentStatus', 'COLUMN', N'zContext'
GO
