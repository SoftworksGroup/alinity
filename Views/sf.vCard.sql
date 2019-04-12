SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vCard]
as
/*********************************************************************************************************************************
View    : sf.vCard
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.Card - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.Card table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vCardExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vCardExt documentation for details. To add additional content to this view, customize
the sf.vCardExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 card.CardSID
	,card.CardTypeSID
	,card.CardLabel
	,card.CardContext
	,card.CSSDefinition
	,card.SummaryCardDefinition
	,card.DetailCardDefinition
	,card.HeaderDefinition
	,card.FooterDefinition
	,card.GridRowDefinition
	,card.IsActive
	,card.CardHelp
	,card.UserDefinedColumns
	,card.CardXID
	,card.LegacyKey
	,card.IsDeleted
	,card.CreateUser
	,card.CreateTime
	,card.UpdateUser
	,card.UpdateTime
	,card.RowGUID
	,card.RowStamp
	,cardx.CardTypeSCD
	,cardx.CardTypeLabel
	,cardx.CardTypeRowGUID
	,cardx.IsDeleteEnabled
	,cardx.IsReselected
	,cardx.IsNullApplied
	,cardx.zContext
from
	sf.Card      card
join
	sf.vCard#Ext cardx	on card.CardSID = cardx.CardSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.Card', 'SCHEMA', N'sf', 'VIEW', N'vCard', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the card assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the audit action assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the card to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional identifier of the use-case or context where this card should be applied.  | This value enables 2 (or more) cards of the same type to be in effect at the same time. ', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A string that defines the CSS style sheets that are used in the formatting of the web page', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CSSDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the summary card that appears to display search results | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'SummaryCardDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the detail card that appears when the user clicks the summary card on the search results page | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'DetailCardDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the header area of the page that the summary and detail cards are displayed on (optional) | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'HeaderDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the footer area of the page that the summary and detail cards are displayed on (optional) | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'FooterDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the grid/table row area (optional) | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'GridRowDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this card record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Instructions to present to the end user when this card is presented. Note that instructions from the "Parent" card in a card set are always displayed first even if the parent card does not appear until later in the card-set sequence.', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardHelp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the card | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the card | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this card record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the card | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the card record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the card record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the card type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the card type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the card type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'CardTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vCard', 'COLUMN', N'zContext'
GO
