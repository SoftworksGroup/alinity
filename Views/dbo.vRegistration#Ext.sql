SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistration#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistration#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.Registration base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistration (referred to as the "entity" view in SGI documentation).

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
	 reg.RegistrationSID
	,prs.PracticeRegisterSID
	,prs.PracticeRegisterSectionLabel
	,prs.IsDefault                                                          PracticeRegisterSectionIsDefault
	,prs.IsDisplayedOnLicense
	,prs.IsActive                                                           PracticeRegisterSectionIsActive
	,prs.RowGUID                                                            PracticeRegisterSectionRowGUID
	,registrant.PersonSID                                                   RegistrantPersonSID
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
	,registrant.RowGUID                                                     RegistrantRowGUID
	,i.PersonSID                                                            InvoicePersonSID
	,i.InvoiceDate
	,i.Tax1Label
	,i.Tax1Rate
	,i.Tax1GLAccountCode
	,i.Tax2Label
	,i.Tax2Rate
	,i.Tax2GLAccountCode
	,i.Tax3Label
	,i.Tax3Rate
	,i.Tax3GLAccountCode
	,i.RegistrationYear                                                     InvoiceRegistrationYear
	,i.CancelledTime
	,i.ReasonSID                                                            InvoiceReasonSID
	,i.IsRefund
	,i.ComplaintSID
	,i.RowGUID                                                              InvoiceRowGUID
	,reason.ReasonGroupSID
	,reason.ReasonName
	,reason.ReasonCode
	,reason.ReasonSequence
	,reason.ToolTip
	,reason.IsActive                                                        ReasonIsActive
	,reason.RowGUID                                                         ReasonRowGUID
	,sf.fIsActive(reg.EffectiveTime, reg.ExpiryTime)                        IsActive									--# Indicates if the assignment is currently active (not expired or future dated)
	,sf.fIsPending(reg.EffectiveTime, reg.ExpiryTime)                       IsPending									--# Indicates if the assignment will come into effect in the future
	,dbo.fRegistration#IsDeleteEnabled(reg.RegistrationSID)                 IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,dbo.fRegistrant#Label(zp.LastName, zp.FirstName, zp.MiddleNames, registrant.RegistrantNo, 'REGISTRANT')	 RegistrantLabel									--# display label for the registrant
 ,zrsy.RegistrationYearLabel
 ,zpr.PracticeRegisterName																																																									--@ dbo.PracticeRegister.PracticeRegisterName
 ,zpr.PracticeRegisterLabel																																																									--@ dbo.PracticeRegister.PracticeRegisterLabel
 ,dbo.fRegistration#Label(reg.RegistrationSID)																														 RegistrationLabel								--# A label for the registration based on the register name, section (when not "Default" section) and year
 ,(case when zx.ApplicationUserSID = zau.ApplicationUserSID then cast(1 as bit)else zx.IsAdminGranted end) IsReadEnabled										--# Indicates if logged in user can review the registration (must be registrant or have Admin rights)
 ,zp.FirstName
 ,zp.MiddleNames
 ,zp.LastName
 ,zma.AddressBlockForPrint
 ,zma.AddressBlockForHTML
 ,dbo.fRegistration#Label(zrf.RegistrationSID)																														 FutureRegistrationLabel					--# A label for the future registration based on the register name, section (when not "Default" section) and year
 ,zrf.RegistrationYear																																										 FutureRegistrationYear						-- # The year of the future registration
 ,zrf.PracticeRegisterSID																																									 FuturePracticeRegisterSID				-- # Key of the practice register on the future registration
 ,zrf.PracticeRegisterLabel																																								 FuturePracticeRegisterLabel			-- # Name of the register (label value) of the future registration
 ,zrf.PracticeRegisterSectionSID																																					 FuturePracticeRegisterSectionSID -- # Key of the practice register section on the future registration
 ,zrf.PracticeRegisterSectionLabel																																				 FutureRegisterSectionLabel				-- # Name of the register section (label value) of the future registration
 ,zrf.EffectiveTime																																												 FutureEffectiveTime							-- # Date the future registration becomes effective
 ,zrf.ExpiryTime																																													 FutureExpiryTime									-- # Date the future registration expires
 ,zrf.CardPrintedTime																																											 FutureCardPrintedTime						-- # Date the future registration card was printed (blank if not printed)
 ,zrf.InvoiceSID																																													 FutureInvoiceSID									-- # Key of the invoice for the future dated registration
 ,zrf.ReasonSID																																														 FutureReasonSID									-- # Key of the reason (if any) for generating the future registration
,zrf.FormGUID																																														 FutureFormGUID										-- # Internal form identifier for the future dated registration
--! </MoreColumns>
from
	dbo.Registration            reg
join
	dbo.PracticeRegisterSection prs        on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.Registrant              registrant on reg.RegistrantSID = registrant.RegistrantSID
left outer join
	dbo.Invoice                 i          on reg.InvoiceSID = i.InvoiceSID
left outer join
	dbo.Reason                  reason     on reg.ReasonSID = reason.ReasonSID
--! <MoreJoins>
join
(
	select
		sf.fApplicationUserSessionUserSID() ApplicationUserSID
	 ,sf.fIsGranted('ADMIN.BASE')					IsAdminGranted
)																																			zx on 1 = 1
join
	sf.Person																														zp on registrant.PersonSID = zp.PersonSID
join
	dbo.vRegistrationScheduleYear																				zrsy on reg.RegistrationYear = zrsy.RegistrationYear and zrsy.RegistrationScheduleIsDefault = cast(1 as bit)
outer apply dbo.fPersonMailingAddress#Formatted(registrant.PersonSID) zma
left outer join
	dbo.PracticeRegister		 zpr on prs.PracticeRegisterSID = zpr.PracticeRegisterSID
left outer join
	sf.ApplicationUser			 zau on registrant.PersonSID		= zau.PersonSID
left outer join
	dbo.vRegistration#Future zrf on reg.RegistrantSID				= zrf.RegistrantSID;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register this section is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register section to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterSectionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register section to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterSectionIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this section should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a section accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register section record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterSectionIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register section record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterSectionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this invoice is based on', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'InvoicePersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date of the invoice. Defaults to the current date but may be edited when back-dating is required.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'Tax1GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'Tax2GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'Tax3GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year for which the revenue on the invoice is being collected. If this is not the same as the registration year the invoice is generated in, then deferred revenue accounts will apply to the exported transaction if they have been setup.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'InvoiceRegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The datetime when the invoice was cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'InvoiceReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice was setup to record a refund. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsRefund'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint assigned to this invoice', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the invoice record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'InvoiceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'RegistrantLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'PracticeRegisterLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the future registration based on the register name, section (when not "Default" section) and year', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'RegistrationLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if logged in user can review the registration (must be registrant or have Admin rights)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'IsReadEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the future registration based on the register name, section (when not "Default" section) and year', 'SCHEMA', N'dbo', 'VIEW', N'vRegistration#Ext', 'COLUMN', N'FutureRegistrationLabel'
GO