SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantAppReviewStatus#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantAppReviewStatus#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.RegistrantAppReviewStatus base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistrantAppReviewStatus (referred to as the "entity" view in SGI documentation).

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
	 rars.RegistrantAppReviewStatusSID
	,rar.RegistrantAppSID
	,rar.FormVersionSID
	,rar.PersonSID
	,rar.ReasonSID
	,rar.RecommendationSID
	,rar.LastValidateTime
	,rar.RowGUID                                                                       RegistrantAppReviewRowGUID
	,fs.FormStatusSCD
	,fs.FormStatusLabel
	,fs.IsFinal
	,fs.IsDefault                                                                      FormStatusIsDefault
	,fs.FormStatusSequence
	,fs.FormOwnerSID
	,fs.RowGUID                                                                        FormStatusRowGUID
	,dbo.fRegistrantAppReviewStatus#IsDeleteEnabled(rars.RegistrantAppReviewStatusSID) IsDeleteEnabled--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                                IsReselected		-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                                    IsNullApplied	-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                                 zContext				-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.RegistrantAppReviewStatus rars
join
	dbo.RegistrantAppReview       rar    on rars.RegistrantAppReviewSID = rar.RegistrantAppReviewSID
join
	sf.FormStatus                 fs     on rars.FormStatusSID = fs.FormStatusSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app review status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'RegistrantAppReviewStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant app assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'RegistrantAppSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this registrant app review is based on', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reason assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the recommendation assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'RecommendationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant app review record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'RegistrantAppReviewRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a final status.  Once the form achieves this status it is considered closed.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'IsFinal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default form status to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in the progression of a form from new to fully processed', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this form status', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'FormStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAppReviewStatus#Ext', 'COLUMN', N'zContext'
GO