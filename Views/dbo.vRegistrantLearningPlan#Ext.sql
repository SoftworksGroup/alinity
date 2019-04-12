SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantLearningPlan#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantLearningPlan#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.RegistrantLearningPlan base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistrantLearningPlan (referred to as the "entity" view in SGI documentation).

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
	 rlp.RegistrantLearningPlanSID
	,lm.LearningModelSCD
	,lm.LearningModelLabel
	,lm.IsDefault                                                               LearningModelIsDefault
	,lm.UnitTypeSID
	,lm.CycleLengthYears
	,lm.IsCycleStartedYear1
	,lm.MaximumCarryOver
	,lm.RowGUID                                                                 LearningModelRowGUID
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
	,registrant.RowGUID                                                         RegistrantRowGUID
	,fv.FormSID
	,fv.VersionNo
	,fv.RevisionNo
	,fv.IsSaveDisplayed
	,fv.ApprovedTime
	,fv.RowGUID                                                                 FormVersionRowGUID
	,reason.ReasonGroupSID
	,reason.ReasonName
	,reason.ReasonCode
	,reason.ReasonSequence
	,reason.ToolTip
	,reason.IsActive                                                            ReasonIsActive
	,reason.RowGUID                                                             ReasonRowGUID
	,dbo.fRegistrantLearningPlan#IsDeleteEnabled(rlp.RegistrantLearningPlanSID) IsDeleteEnabled				--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                         IsReselected					-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                             IsNullApplied					-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                          zContext							-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,zrlpx.IsViewEnabled																																					--# Indicates whether either the (logged in) user or administrator can view the learning plan
 ,zrlpx.IsEditEnabled																																					--# Indicates whether the (logged in) user can edit/correct the form
 ,zrlpx.IsSaveBtnDisplayed																																		--# Indicates whether the save button is displayed on the form
 ,zrlpx.IsApproveEnabled																																			--# Indicates whether the approve button should be made available to the user
 ,zrlpx.IsRejectEnabled																																				--# Indicates whether the reject button should be made available to the user
 ,zrlpx.IsUnlockEnabled																																				--# Indicates administrator can unlock form for editing even when in certain final statuses
 ,zrlpx.IsWithdrawalEnabled																																		--# Indicates the learning plan form can be withdrawn by administrators or SA's
 ,zrlpx.IsInProgress																																					--# Indicates if the form is now closed/finalized or still in progress (open)	
 ,zrlpx.RegistrantLearningPlanStatusSID																												--# Key of current/latest learning plan status
 ,zrlpx.RegistrantLearningPlanStatusSCD																												--# Current/latest learning plan status		
 ,zrlpx.RegistrantLearningPlanStatusLabel																											--# User-friendly name for the learning plan status		
 ,zrlpx.LastStatusChangeUser																																	--# Username who made the last status change
 ,zrlpx.LastStatusChangeTime																																	--# Date and time the last status change was made
 ,zrlpx.FormOwnerSCD																																					--# Person/group expected to perform next action to progress the form
 ,zrlpx.FormOwnerLabel																																				--# User-friendly name of person/group expected to perform next action to progress the form
 ,zrlpx.FormOwnerSID																																					--# Key of the form owner expected to perform the next action to progress the form
 ,zrlpx.IsPDFDisplayed																																				--# Indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,zrlpx.PersonDocSID																																					--# Key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
 ,zrlpx.RegistrantLearningPlanLabel																														--# A summary label for the learning plan based on the register label and learning plan status
 ,zrlpx.RegistrationYearLabel																																	--# Text label for the registration (shows start and end year if calendar year end is crossed)		
 ,zrlpx.CycleEndRegistrationYear																															--# Ending year for the CE cycle this plan reports on
 ,zrlpx.CycleRegistrationYearLabel																														--# Label showing the display starting and display ending years of the CE cycle
 ,cast(null as varchar(25))																									 NewFormStatusSCD --# Used internally by the system to set the form to a new status value
--! </MoreColumns>
from
	dbo.RegistrantLearningPlan rlp
join
	dbo.LearningModel          lm         on rlp.LearningModelSID = lm.LearningModelSID
join
	dbo.Registrant             registrant on rlp.RegistrantSID = registrant.RegistrantSID
join
	sf.FormVersion             fv         on rlp.FormVersionSID = fv.FormVersionSID
left outer join
	dbo.Reason                 reason     on rlp.ReasonSID = reason.ReasonSID
--! <MoreJoins>
join
	dbo.RegistrationSchedule																								 zrs on zrs.IsDefault = cast(1 as bit)
join
	dbo.RegistrationScheduleYear																						 zrsy on zrs.RegistrationScheduleSID = zrsy.RegistrationScheduleSID and rlp.RegistrationYear = zrsy.RegistrationYear
outer apply dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) zrlpx;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrantLearningPlanSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the learning model | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LearningModelSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the learning model to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LearningModelLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default learning model to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LearningModelIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'UnitTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the length of time in years the member has to complete the learning plan requirements', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'CycleLengthYears'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if CE reporting begins in the first year of active practice | Otherwise CE plan records are created starting in year 2 - the first full year of practice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsCycleStartedYear1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of units that can be applied to the next cycle across ALL learning requirements (or set at the Learning Requirement level only) - default is 9999 (not limited at this level)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'MaximumCarryOver'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning model record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LearningModelRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form this version is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The version number of the form - e.g. 1, 2, 3, 999.  When a new version of the form is approved the version number moves up to the next whole number.  | Revision numbers are always 0 for approved versions of the form.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'VersionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number assigned as changes are made and saved between approved Versions of the form.  | Revision enable users to back to a previous state of the form and edit from that point.  When a form version is Approved, the form is saved, the version number is updated to the next whole number, and the revision number is set to 0. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RevisionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the Save/Save-For-Later button is displayed (otherwise only Submit is allowed) | Note that other business rules may also impact whether the Save button option is displayed', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsSaveDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this version of the form was approved for use in production.  | This value is blank for revisions of the form saved between production versions.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'ApprovedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form version record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'FormVersionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether either the (logged in) user or administrator can view the learning plan', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsViewEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the (logged in) user can edit/correct the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the save button is displayed on the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsSaveBtnDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the approve button should be made available to the user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsApproveEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the reject button should be made available to the user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsRejectEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates administrator can unlock form for editing even when in certain final statuses', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsUnlockEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the learning plan form can be withdrawn by administrators or SA''s', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsWithdrawalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the form is now closed/finalized or still in progress (open)	', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsInProgress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of current/latest learning plan status', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrantLearningPlanStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current/latest learning plan status		', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrantLearningPlanStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User-friendly name for the learning plan status		', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrantLearningPlanStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Username who made the last status change', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LastStatusChangeUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the last status change was made', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'LastStatusChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Person/group expected to perform next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User-friendly name of person/group expected to perform next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the form owner expected to perform the next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if PDF form version should be displayed rather than the HTML (form is complete)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'IsPDFDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A summary label for the learning plan based on the register label and learning plan status', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrantLearningPlanLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label showing the display starting and display ending years of the CE cycle', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'RegistrationYearLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ending year for the CE cycle this plan reports on', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'CycleEndRegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label showing the display starting and display ending years of the CE cycle', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'CycleRegistrationYearLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to set the form to a new status value', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlan#Ext', 'COLUMN', N'NewFormStatusSCD'
GO
