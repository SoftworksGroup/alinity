SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPracticeRegister#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vPracticeRegister#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.PracticeRegister base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPracticeRegister (referred to as the "entity" view in SGI documentation).

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
	 pr.PracticeRegisterSID
	,prt.PracticeRegisterTypeSCD
	,prt.PracticeRegisterTypeLabel
	,prt.PracticeRegisterTypeCategory
	,prt.IsDefault                                                          PracticeRegisterTypeIsDefault
	,prt.IsActive                                                           PracticeRegisterTypeIsActive
	,prt.RowGUID                                                            PracticeRegisterTypeRowGUID
	,rs.RegistrationScheduleLabel
	,rs.IsDefault                                                           RegistrationScheduleIsDefault
	,rs.IsActive                                                            RegistrationScheduleIsActive
	,rs.RowGUID                                                             RegistrationScheduleRowGUID
	,lm.LearningModelSCD
	,lm.LearningModelLabel
	,lm.IsDefault                                                           LearningModelIsDefault
	,lm.UnitTypeSID
	,lm.CycleLengthYears
	,lm.IsCycleStartedYear1
	,lm.MaximumCarryOver
	,lm.RowGUID                                                             LearningModelRowGUID
	,rg.ReasonGroupSCD
	,rg.ReasonGroupLabel
	,rg.IsLockedGroup
	,rg.RowGUID                                                             ReasonGroupRowGUID
	,dbo.fPracticeRegister#IsDeleteEnabled(pr.PracticeRegisterSID)          IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
																																												--! <MoreColumns>
 ,zprfx.RegistrantAppFormVersionSID																											--# Current published version of the registrant-application form
 ,zprfx.RegistrantAppVerificationFormVersionSID																					--# Current published version of the registrant-application-verification form
 ,zprfx.RegistrantRenewalFormVersionSID																									--# Current published version of the renewal form
 ,zprfx.RegistrantRenewalReviewFormVersionSID																						--# Current published version of the renewal review form
 ,zprfx.CompetenceReviewFormVersionSID																									--# Current published version of the competence audit form
 ,zprfx.CompetenceReviewAssessmentFormVersionSID																				--# Current published version of the competence audit review form
 ,zprfx.CurrentRegistrationYear																													--# Registration year for the current (client timezone) time
 ,zprfx.CurrentRenewalYear																															--# Registration year registrant can renew to - if renewal is open
 ,zprfx.CurrentReinstatementYear																												--# Current registration year registrant can reinstate/change registration for if open
 ,zprfx.NextReinstatementYear																														--# Next registration year registrant can change registration for if open (up to 2 reinstatement years may be open)
 ,zprfx.IsCurrentUserVerifier																														--# Indicates if current user has grant for verifying renewals and reinstatements
 ,cast(pr.LearningModelSID as bit)															IsLearningModelApplied	--# Indicates whether learning requirements are enforced for registration on this register
--! </MoreColumns>
from
	dbo.PracticeRegister     pr
join
	dbo.PracticeRegisterType prt    on pr.PracticeRegisterTypeSID = prt.PracticeRegisterTypeSID
join
	dbo.RegistrationSchedule rs     on pr.RegistrationScheduleSID = rs.RegistrationScheduleSID
left outer join
	dbo.LearningModel        lm     on pr.LearningModelSID = lm.LearningModelSID
left outer join
	dbo.ReasonGroup          rg     on pr.ReasonGroupSID = rg.ReasonGroupSID
--! <MoreJoins>
left outer join
	dbo.PracticeRegisterSection																	zprs on pr.PracticeRegisterSID = zprs.PracticeRegisterSID
																																			and zprs.IsDefault = cast(1 as bit)
outer apply dbo.fPracticeRegister#Ext(pr.PracticeRegisterSID) zprfx;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the practice register type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'PracticeRegisterTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrationScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default registration schedule to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrationScheduleIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registration schedule record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrationScheduleIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrationScheduleRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the learning model | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'LearningModelSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the learning model to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'LearningModelLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default learning model to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'LearningModelIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'UnitTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the length of time in years the member has to complete the learning plan requirements', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'CycleLengthYears'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if CE reporting begins in the first year of active practice | Otherwise CE plan records are created starting in year 2 - the first full year of practice', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsCycleStartedYear1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of units that can be applied to the next cycle across ALL learning requirements (or set at the Learning Requirement level only) - default is 9999 (not limited at this level)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'MaximumCarryOver'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning model record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'LearningModelRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the reason group | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'ReasonGroupSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the reason group to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'ReasonGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the group code reasons is reserved by the system and cannot have its members or codes altered.  The application requires that some groups exist with known code values.  Adding and deleting reasons from these groups, or changing their codes - is blocked by the application.  End users can still change the description of the reasons including customizing them for language.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsLockedGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason group record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'ReasonGroupRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current published version of the registrant-application form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrantAppFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current published version of the registrant-application-verification form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrantAppVerificationFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current published version of the renewal form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrantRenewalFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current published version of the renewal review form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'RegistrantRenewalReviewFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current published version of the competence audit form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'CompetenceReviewFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current published version of the competence audit review form', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'CompetenceReviewAssessmentFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Registration year for the current (client timezone) time', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'CurrentRegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Registration year registrant can renew to - if renewal is open', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'CurrentRenewalYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current registration year registrant can reinstate/change registration for if open', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'CurrentReinstatementYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Next registration year registrant can change registration for if open (up to 2 reinstatement years may be open)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'NextReinstatementYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if current user has grant for verifying renewals and reinstatements', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsCurrentUserVerifier'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether learning requirements are enforced for registration on this register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegister#Ext', 'COLUMN', N'IsLearningModelApplied'
GO
