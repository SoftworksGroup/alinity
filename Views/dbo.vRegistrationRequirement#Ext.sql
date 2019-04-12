SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrationRequirement#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrationRequirement#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.RegistrationRequirement base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistrationRequirement (referred to as the "entity" view in SGI documentation).

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
	 rr.RegistrationRequirementSID
	,rrt.RegistrationRequirementTypeLabel
	,rrt.RegistrationRequirementTypeCode
	,rrt.RegistrationRequirementTypeCategory
	,rrt.IsAppliedToPeople
	,rrt.IsAppliedToOrganizations
	,rrt.IsDefault                                                               RegistrationRequirementTypeIsDefault
	,rrt.IsActive                                                                RegistrationRequirementTypeIsActive
	,rrt.RowGUID                                                                 RegistrationRequirementTypeRowGUID
	,e.ExamName
	,e.ExamCategory
	,e.PassingScore
	,e.EffectiveTime
	,e.ExpiryTime
	,e.IsOnlineExam
	,e.IsEnabledOnPortal
	,e.Sequence
	,e.CultureSID
	,e.LastVerifiedTime
	,e.MinLagDaysBetweenAttempts
	,e.MaxAttemptsPerYear
	,e.VendorExamID
	,e.RowGUID                                                                   ExamRowGUID
	,pdt.PersonDocTypeSCD
	,pdt.PersonDocTypeLabel
	,pdt.PersonDocTypeCategory
	,pdt.IsDefault                                                               PersonDocTypeIsDefault
	,pdt.IsActive                                                                PersonDocTypeIsActive
	,pdt.RowGUID                                                                 PersonDocTypeRowGUID
	,dbo.fRegistrationRequirement#IsDeleteEnabled(rr.RegistrationRequirementSID) IsDeleteEnabled			--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                          IsReselected					-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                              IsNullApplied				-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                           zContext							-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,cast(case when rrt.RegistrationRequirementTypeCode like 'S!%.DEC' then 1 else 0 end as bit)		 IsDeclaration		--# Indicates whether the requirement is a delcaration type
 ,cast(case when rrt.RegistrationRequirementTypeCode like 'S!EXAM' then 1 else 0 end as bit)		 IsExam						--# Indicates whether the requirement is an exam
 ,cast(case when rrt.RegistrationRequirementTypeCode like 'S!DOCUMENT' then 1 else 0 end as bit) IsDocument				--# Indicates whether the requirement is a document
--! </MoreColumns>
from
	dbo.RegistrationRequirement     rr
join
	dbo.RegistrationRequirementType rrt    on rr.RegistrationRequirementTypeSID = rrt.RegistrationRequirementTypeSID
left outer join
	dbo.Exam                        e      on rr.ExamSID = e.ExamSID
left outer join
	dbo.PersonDocType               pdt    on rr.PersonDocTypeSID = pdt.PersonDocTypeSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration requirement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'RegistrationRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration requirement type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'RegistrationRequirementTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'RegistrationRequirementTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this type of requirement applies to people', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsAppliedToPeople'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this type of requirement applies to organizations', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsAppliedToOrganizations'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default registration requirement type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'RegistrationRequirementTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registration requirement type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'RegistrationRequirementTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration requirement type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'RegistrationRequirementTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the exam to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'ExamName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize exams (e.g. for display in different areas on member forms)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'ExamCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum score for passing the exam (required for Alinity exams). Leave blank to always record pass/fail manually for external exams.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PassingScore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the exam is enabled for selection on the member portal (applies only to online exams)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsEnabledOnPortal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls order this exam appears in relative to other exams associated with the same credential | If not set the order defaults to entry order of the record', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the culture assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum days a member must wait between attempts at writing the exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'MinLagDaysBetweenAttempts'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of attempts a member is alloted to pass the exam within a registration year.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'MaxAttemptsPerYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam  | This value can be used when importing exam candidates to associate results with the correct exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'VendorExamID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'ExamRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the person doc type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PersonDocTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the person doc type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PersonDocTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PersonDocTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default person doc type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PersonDocTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person doc type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PersonDocTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person doc type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'PersonDocTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the requirement is a delcaration type', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsDeclaration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the requirement is an exam', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsExam'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the requirement is a document', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationRequirement#Ext', 'COLUMN', N'IsDocument'
GO