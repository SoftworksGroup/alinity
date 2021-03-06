SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPAPSubscription#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPAPSubscription#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PAPSubscription base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPAPSubscription (referred to as the "entity" view in SGI documentation).

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
	 paps.PAPSubscriptionSID
	,person.GenderSID
	,person.NamePrefixSID
	,person.FirstName
	,person.CommonName
	,person.MiddleNames
	,person.LastName
	,person.BirthDate
	,person.DeathDate
	,person.HomePhone
	,person.MobilePhone
	,person.IsTextMessagingEnabled
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,dbo.fPAPSubscription#IsDeleteEnabled(paps.PAPSubscriptionSID)          IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,r.RegistrantNo																																																									--@dbo.Registrant.RegistrantNo
 ,dbo.fRegistrant#Label(person.LastName, person.FirstName, person.MiddleNames, r.RegistrantNo, 'REGISTRANT') RegistrantLabel			--# display label for the registrant
 ,sf.fFormatFileAsName(person.LastName, person.FirstName, person.MiddleNames)																 FileAsName						--# file as name of the registrant
 ,sf.fFormatDisplayName(person.LastName, isnull(person.CommonName, person.FirstName))												 DisplayName					--# display name of the registrant
 ,sf.fIsActive(paps.EffectiveTime, paps.CancelledTime)																											 IsActiveSubscription --# Indicates whether subscription is in effect
 ,cast(isnull(zSum.RejectedTrxCount, 0) as bit)																															 HasRejectedTrxs			--# Indicates whether this subscription has rejected transactions (used for searching)
 ,cast(isnull(zSum.TotalUnapplied, 0) as bit)																																 HasUnappliedAmount		--# Indicates whether this subscription has unapplied payment amounts (used for searching)
 ,pea.EmailAddress
 ,zSum.TrxCount
 ,isnull(zSum.RejectedTrxCount, 0)																																					 RejectedTrxCount
 ,isnull(zSum.TotalUnapplied, 0)																																						 TotalUnapplied
--! </MoreColumns>
from
	dbo.PAPSubscription paps
join
	sf.Person           person on paps.PersonSID = person.PersonSID
--! <MoreJoins>
left outer join
	dbo.Registrant				r on person.PersonSID						= r.PersonSID
left outer join
	sf.PersonEmailAddress pea on person.PersonSID					= pea.PersonSID and pea.IsPrimary = cast(1 as bit) and pea.IsActive = cast(1 as bit)
left outer join
(
	select
		pt.PAPSubscriptionSID
	 ,count(1)																												TrxCount
	 ,sum(case when pt.IsRejected = cast(1 as bit) then 1 else 0 end) RejectedTrxCount
	 ,sum(isnull(pmt.TotalUnapplied, 0.00))														TotalUnapplied
	from
		dbo.PAPTransaction													pt
	outer apply dbo.fPayment#Total(pt.PaymentSID) pmt
	group by
		pt.PAPSubscriptionSID
)												zSum on paps.PAPSubscriptionSID = zSum.PAPSubscriptionSID;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the papsubscription assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'PAPSubscriptionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'RegistrantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'RegistrantLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'file as name of the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display name of the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether subscription is in effect', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'IsActiveSubscription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has rejected transactions (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'HasRejectedTrxs'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has unapplied payment amounts (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'HasUnappliedAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has rejected transactions (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'TrxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has rejected transactions (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'RejectedTrxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this subscription has unapplied payment amounts (used for searching)', 'SCHEMA', N'dbo', 'VIEW', N'vPAPSubscription#Ext', 'COLUMN', N'TotalUnapplied'
GO
