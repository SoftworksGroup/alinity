SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vReinstatementStatus#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vReinstatementStatus#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.ReinstatementStatus base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vReinstatementStatus (referred to as the "entity" view in SGI documentation).

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
	 rs.ReinstatementStatusSID
	,rin.RegistrationSID
	,rin.PracticeRegisterSectionSID
	,rin.RegistrationYear
	,rin.FormVersionSID
	,rin.LastValidateTime
	,rin.NextFollowUp
	,rin.RegistrationEffective
	,rin.IsAutoApprovalEnabled
	,rin.ReasonSID
	,rin.InvoiceSID
	,rin.RowGUID                                                            ReinstatementRowGUID
	,fs.FormStatusSCD
	,fs.FormStatusLabel
	,fs.IsFinal
	,fs.IsDefault                                                           FormStatusIsDefault
	,fs.FormStatusSequence
	,fs.FormOwnerSID
	,fs.RowGUID                                                             FormStatusRowGUID
	,dbo.fReinstatementStatus#IsDeleteEnabled(rs.ReinstatementStatusSID)    IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.ReinstatementStatus rs
join
	dbo.Reinstatement       rin    on rs.ReinstatementSID = rin.ReinstatementSID
join
	sf.FormStatus           fs     on rs.FormStatusSID = fs.FormStatusSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reinstatement status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'ReinstatementStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration assigned to this reinstatement', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register section assigned to this reinstatement', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year the reinstatement is targeted to take effect in (set to current registration year at creation)', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional value set on approval to override the default effective date of the permit/license created', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'RegistrationEffective'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this reinstatement', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reinstatement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'ReinstatementRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a final status.  Once the form achieves this status it is considered closed.', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'IsFinal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default form status to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in the progression of a form from new to fully processed', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this form status', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'FormStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vReinstatementStatus#Ext', 'COLUMN', N'zContext'
GO
