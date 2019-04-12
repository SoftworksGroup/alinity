SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPAPSubscription]
as
/*********************************************************************************************************************************
View    : dbo.vPAPSubscription
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PAPSubscription - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PAPSubscription table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPAPSubscriptionExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPAPSubscriptionExt documentation for details. To add additional content to this view, customize
the dbo.vPAPSubscriptionExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 paps.PAPSubscriptionSID
	,paps.PersonSID
	,paps.InstitutionNo
	,paps.TransitNo
	,paps.AccountNo
	,paps.WithdrawalAmount
	,paps.EffectiveTime
	,paps.CancelledTime
	,paps.UserDefinedColumns
	,paps.PAPSubscriptionXID
	,paps.LegacyKey
	,paps.IsDeleted
	,paps.CreateUser
	,paps.CreateTime
	,paps.UpdateUser
	,paps.UpdateTime
	,paps.RowGUID
	,paps.RowStamp
	,papsx.GenderSID
	,papsx.NamePrefixSID
	,papsx.FirstName
	,papsx.CommonName
	,papsx.MiddleNames
	,papsx.LastName
	,papsx.BirthDate
	,papsx.DeathDate
	,papsx.HomePhone
	,papsx.MobilePhone
	,papsx.IsTextMessagingEnabled
	,papsx.ImportBatch
	,papsx.PersonRowGUID
	,papsx.IsDeleteEnabled
	,papsx.IsReselected
	,papsx.IsNullApplied
	,papsx.zContext
	,papsx.RegistrantNo
	,papsx.RegistrantLabel
	,papsx.FileAsName
	,papsx.DisplayName
	,papsx.IsActiveSubscription
	,papsx.HasRejectedTrxs
	,papsx.HasUnappliedAmount
	,papsx.EmailAddress
	,papsx.TrxCount
	,papsx.RejectedTrxCount
	,papsx.TotalUnapplied
from
	dbo.PAPSubscription      paps
join
	dbo.vPAPSubscription#Ext papsx	on paps.PAPSubscriptionSID = papsx.PAPSubscriptionSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PAPSubscription', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the papsubscription assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'PAPSubscriptionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this papsubscription is based on', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The monetary value of the payment', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'WithdrawalAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The amount of funds to withdraw from the account.  ', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the papsubscription | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'PAPSubscriptionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the papsubscription | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this papsubscription record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the papsubscription | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the papsubscription record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the papsubscription record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'RegistrantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'RegistrantLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'file as name of the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display name of the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether subscription is in effect', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'IsActiveSubscription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has rejected transactions (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'HasRejectedTrxs'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has unapplied payment amounts (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'HasUnappliedAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has rejected transactions (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'TrxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has rejected transactions (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'RejectedTrxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has unapplied payment amounts (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription', 'COLUMN', N'TotalUnapplied'
GO