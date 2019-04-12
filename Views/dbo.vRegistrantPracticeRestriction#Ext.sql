SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantPracticeRestriction#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantPracticeRestriction#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.RegistrantPracticeRestriction base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistrantPracticeRestriction (referred to as the "entity" view in SGI documentation).

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
	 rpr.RegistrantPracticeRestrictionSID
	,pr.PracticeRestrictionLabel
	,pr.IsDisplayedOnLicense                                                                  PracticeRestrictionIsDisplayedOnLicense
	,pr.IsActive                                                                              PracticeRestrictionIsActive
	,pr.IsSupervisionRequired
	,pr.RowGUID                                                                               PracticeRestrictionRowGUID
	,registrant.PersonSID
	,registrant.RegistrantNo
	,registrant.YearOfInitialEmployment
	,registrant.IsOnPublicRegistry
	,registrant.CityNameOfBirth
	,registrant.CountrySID
	,registrant.DirectedAuditYearCompetence
	,registrant.DirectedAuditYearPracticeHours
	,registrant.LateFeeExclusionYear
	,registrant.IsRenewalAutoApprovalBlocked
	,registrant.RenewalExtensionExpiryTime
	,registrant.ArchivedTime
	,registrant.RowGUID                                                                       RegistrantRowGUID
	,complaint.ComplaintNo
	,complaint.RegistrantSID                                                                  ComplaintRegistrantSID
	,complaint.ComplaintTypeSID
	,complaint.ComplainantTypeSID
	,complaint.ApplicationUserSID
	,complaint.OpenedDate
	,complaint.ConductStartDate
	,complaint.ConductEndDate
	,complaint.ComplaintSeveritySID
	,complaint.IsDisplayedOnPublicRegistry
	,complaint.ClosedDate
	,complaint.DismissedDate
	,complaint.ReasonSID
	,complaint.FileExtension
	,complaint.RowGUID                                                                        ComplaintRowGUID
	,sf.fIsActive(rpr.EffectiveTime, rpr.ExpiryTime)                                          IsActive--# Indicates if the assignment is currently active (not expired or future dated)
	,sf.fIsPending(rpr.EffectiveTime, rpr.ExpiryTime)                                         IsPending				--# Indicates if the assignment will come into effect in the future
	,dbo.fRegistrantPracticeRestriction#IsDeleteEnabled(rpr.RegistrantPracticeRestrictionSID) IsDeleteEnabled	--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                                       IsReselected		-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                                           IsNullApplied		-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                                        zContext-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.RegistrantPracticeRestriction rpr
join
	dbo.PracticeRestriction           pr         on rpr.PracticeRestrictionSID = pr.PracticeRestrictionSID
join
	dbo.Registrant                    registrant on rpr.RegistrantSID = registrant.RegistrantSID
left outer join
	dbo.Complaint                     complaint  on rpr.ComplaintSID = complaint.ComplaintSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant practice restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'RegistrantPracticeRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice restriction to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'PracticeRestrictionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this restriction should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a restriction accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'PracticeRestrictionIsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice restriction record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'PracticeRestrictionIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this condition-on-practice requires that a supervisor be identified to review/enforce the conditio', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsSupervisionRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice restriction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'PracticeRestrictionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ComplaintRegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ComplaintTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the complaint was reported. | Normally the record entry date but provided to support back-dating when received through other channels', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'OpenedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the start of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ConductStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the end of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ConductEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint severity assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ComplaintSeveritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the outcome text is displayed on the public directory', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsDisplayedOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'ComplaintRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Ext', 'COLUMN', N'zContext'
GO