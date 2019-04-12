SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPracticeRegisterSection]
as
/*********************************************************************************************************************************
View    : dbo.vPracticeRegisterSection
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PracticeRegisterSection - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PracticeRegisterSection table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPracticeRegisterSectionExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPracticeRegisterSectionExt documentation for details. To add additional content to this view, customize
the dbo.vPracticeRegisterSectionExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 prs.PracticeRegisterSectionSID
	,prs.PracticeRegisterSID
	,prs.PracticeRegisterSectionLabel
	,prs.IsDefault
	,prs.IsDisplayedOnLicense
	,prs.Description
	,prs.IsActive
	,prs.UserDefinedColumns
	,prs.PracticeRegisterSectionXID
	,prs.LegacyKey
	,prs.IsDeleted
	,prs.CreateUser
	,prs.CreateTime
	,prs.UpdateUser
	,prs.UpdateTime
	,prs.RowGUID
	,prs.RowStamp
	,prsx.PracticeRegisterTypeSID
	,prsx.RegistrationScheduleSID
	,prsx.PracticeRegisterName
	,prsx.PracticeRegisterLabel
	,prsx.IsActivePractice
	,prsx.IsPublicRegistryEnabled
	,prsx.IsRenewalEnabled
	,prsx.IsLearningPlanEnabled
	,prsx.IsNextCEFormAutoAdded
	,prsx.IsEligibleSupervisor
	,prsx.IsSupervisionRequired
	,prsx.IsEmploymentTerminated
	,prsx.IsGroupMembershipTerminated
	,prsx.TermPermitDays
	,prsx.RegisterRank
	,prsx.LearningModelSID
	,prsx.ReasonGroupSID
	,prsx.PracticeRegisterIsDefault
	,prsx.IsDefaultInactivePractice
	,prsx.PracticeRegisterIsActive
	,prsx.PracticeRegisterRowGUID
	,prsx.IsDeleteEnabled
	,prsx.IsReselected
	,prsx.IsNullApplied
	,prsx.zContext
	,prsx.PracticeRegisterSectionDisplayLabel
	,prsx.ApplicationFormVersionSID
	,prsx.AppVerificationFormVersionSID
	,prsx.RenewalFormVersionSID
	,prsx.IsApplicationFormDefined
	,prsx.IsAppVerificationFormDefined
	,prsx.IsRenewalFormDefined
from
	dbo.PracticeRegisterSection      prs
join
	dbo.vPracticeRegisterSection#Ext prsx	on prs.PracticeRegisterSectionSID = prsx.PracticeRegisterSectionSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PracticeRegisterSection', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register section assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register this section is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register section to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register section to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this section should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a section accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this document type applies to - available as help text on document type selection. This field is varbinary to ensure any searches done on this field disregard taged text and only search content text. ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register section record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register section | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register section | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register section record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register section | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register section record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register section record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of practice register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'RegistrationScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice register to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates people on this register are authorized for active practice - if not checked, then the register is for non-practicing members which may include retired, maternity leave, students, etc. and competence requirements do not apply', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsActivePractice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates people included on this register will appear on the College''s public website unless they have opted out individually.  Note that this value is automatically disabled for in-active practice registers.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsPublicRegistryEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the renewal process is enabled for this register.  This value will generally be on except for some types of permits which cannot renew.  ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsRenewalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a CE/Learning plan should be enabled for members on this register  | This value must be checked for active-practice registers', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsLearningPlanEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a Learning Plan/CE form should automatically be added for the next reporting period when the previous CE report is complete', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsNextCEFormAutoAdded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates members on this register are eligible to act as employment supervisors for other members', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsEligibleSupervisor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates members on this register must have supervisors on practice (e.g. applies to provisional, student registers, etc.)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsSupervisionRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the application to expire active employment records when the member is moved onto this register | This setting only applies where employment terms are used (effective time must be filled in)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsEmploymentTerminated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the application to expire all group memberships when the member is moved onto this register ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsGroupMembershipTerminated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The default length of the term in days - applies only to Term-Permits | An administrator can override the default length of the term-permit by setting specific effective and expiry dates when the registration is created', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'TermPermitDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is relevant to Colleges that allow multiple concurrent registrations only.  It is used to set the priority or sequence of the most important registration where registrations on multiple registers exist for the same type period (does not apply to most configurations).', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'RegisterRank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The learning model assigned to this practice register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'LearningModelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this practice register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this register is the default for in-active practice status | UI only enables access where Is-Active-Practice is not checked. The value is used mostly during conversion to avoid gaps in registration history.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsDefaultInactivePractice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label for the section that includes the register label but suppress the section label if the same or Is-Displayed option off', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'PracticeRegisterSectionDisplayLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the latest approved application form for this section of the register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'ApplicationFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the latest approved application-verification form (used by supervisors) for this section of the register	', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'AppVerificationFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the latest approved renewal form for this section of the register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'RenewalFormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether an approved application form exists for this section of the register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsApplicationFormDefined'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether an approved application-verification form (used by supervisors) exists for this section of the register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsAppVerificationFormDefined'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether an approved renewal form exists for this section of the register', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRegisterSection', 'COLUMN', N'IsRenewalFormDefined'
GO