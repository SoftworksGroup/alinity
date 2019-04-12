SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPracticeRegisterForm#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPracticeRegisterForm#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PracticeRegisterForm base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPracticeRegisterForm (referred to as the "entity" view in SGI documentation).

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
	 prf.PracticeRegisterFormSID
	,pr.PracticeRegisterTypeSID
	,pr.RegistrationScheduleSID
	,pr.PracticeRegisterName
	,pr.PracticeRegisterLabel
	,pr.IsActivePractice
	,pr.IsPublicRegistryEnabled
	,pr.IsRenewalEnabled
	,pr.IsLearningPlanEnabled
	,pr.IsNextCEFormAutoAdded
	,pr.IsEligibleSupervisor
	,pr.IsSupervisionRequired
	,pr.IsEmploymentTerminated
	,pr.IsGroupMembershipTerminated
	,pr.TermPermitDays
	,pr.RegisterRank
	,pr.LearningModelSID
	,pr.ReasonGroupSID
	,pr.IsDefault                                                           PracticeRegisterIsDefault
	,pr.IsDefaultInactivePractice
	,pr.IsActive                                                            PracticeRegisterIsActive
	,pr.RowGUID                                                             PracticeRegisterRowGUID
	,form.FormTypeSID
	,form.FormName
	,form.FormLabel
	,form.FormContext
	,form.AuthorCredit
	,form.IsActive                                                          FormIsActive
	,form.ApplicationUserSID
	,form.RowGUID                                                           FormRowGUID
	,dbo.fPracticeRegisterForm#IsDeleteEnabled(prf.PracticeRegisterFormSID) IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.PracticeRegisterForm prf
join
	dbo.PracticeRegister     pr     on prf.PracticeRegisterSID = pr.PracticeRegisterSID
join
	sf.Form                  form   on prf.FormSID = form.FormSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register form assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of practice register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'RegistrationScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice register to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates people on this register are authorized for active practice - if not checked, then the register is for non-practicing members which may include retired, maternity leave, students, etc. and competence requirements do not apply', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsActivePractice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates people included on this register will appear on the College''s public website unless they have opted out individually.  Note that this value is automatically disabled for in-active practice registers.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsPublicRegistryEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the renewal process is enabled for this register.  This value will generally be on except for some types of permits which cannot renew.  ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsRenewalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a CE/Learning plan should be enabled for members on this register  | This value must be checked for active-practice registers', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsLearningPlanEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a Learning Plan/CE form should automatically be added for the next reporting period when the previous CE report is complete', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsNextCEFormAutoAdded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates members on this register are eligible to act as employment supervisors for other members', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsEligibleSupervisor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates members on this register must have supervisors on practice (e.g. applies to provisional, student registers, etc.)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsSupervisionRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the application to expire active employment records when the member is moved onto this register | This setting only applies where employment terms are used (effective time must be filled in)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsEmploymentTerminated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the application to expire all group memberships when the member is moved onto this register ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsGroupMembershipTerminated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The default length of the term in days - applies only to Term-Permits | An administrator can override the default length of the term-permit by setting specific effective and expiry dates when the registration is created', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'TermPermitDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is relevant to Colleges that allow multiple concurrent registrations only.  It is used to set the priority or sequence of the most important registration where registrations on multiple registers exist for the same type period (does not apply to most configurations).', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'RegisterRank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The learning model assigned to this practice register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'LearningModelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this practice register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this register is the default for in-active practice status | UI only enables access where Is-Active-Practice is not checked. The value is used mostly during conversion to avoid gaps in registration history.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsDefaultInactivePractice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'PracticeRegisterRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the audit action assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'FormTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the form to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'FormName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'FormLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional identifier of the use-case or context where this form should be applied.  | This value enables 2 (or more) forms of the same type to be in effect at the same time.  By default the application chooses the latest published version but a context may be specified in the program code (e.g. a registration year) in which case the latest form for that context is selected.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'FormContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name, organization and other registrant information of the form''s author as along with any restrictions on use.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'AuthorCredit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this form record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'FormIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'FormRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterForm#Ext', 'COLUMN', N'zContext'
GO
