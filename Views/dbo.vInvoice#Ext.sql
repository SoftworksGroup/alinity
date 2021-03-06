SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vInvoice#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vInvoice#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.Invoice base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vInvoice (referred to as the "entity" view in SGI documentation).

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
	 i.InvoiceSID
	,person.GenderSID
	,person.NamePrefixSID
	,person.FirstName
	,person.CommonName
	,person.MiddleNames
	,person.LastName
	,person.BirthDate
	,person.DeathDate
	,person.HomePhone
	,person.MobilePhone
	,person.IsTextMessagingEnabled
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,complaint.ComplaintNo
	,complaint.RegistrantSID
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
	,complaint.ReasonSID                                                    ComplaintReasonSID
	,complaint.FileExtension
	,complaint.RowGUID                                                      ComplaintRowGUID
	,reason.ReasonGroupSID
	,reason.ReasonName
	,reason.ReasonCode
	,reason.ReasonSequence
	,reason.ToolTip
	,reason.IsActive                                                        ReasonIsActive
	,reason.RowGUID                                                         ReasonRowGUID
	,dbo.fInvoice#IsDeleteEnabled(i.InvoiceSID)                             IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
																																																																													--! <MoreColumns>
 ,dbo.fRegistrant#Label(person.LastName, person.FirstName, person.MiddleNames, r.RegistrantNo, 'REGISTRANT') + ' '
	+ cast(sf.fDTOffsetToClientDate(i.CreateTime) as varchar(10)) + ' Due ' + format(zit.TotalDue, 'C')																	InvoiceLabel				--# display label for the invoice to use to select among invoices when making payment
 ,'#' + ltrim(i.InvoiceSID) + ' ' + cast(sf.fDTOffsetToClientDate(i.CreateTime) as varchar(10)) + ' Due ' + format(zit.TotalDue, 'C') InvoiceShortLabel		--# a shorter form of the display label to use when selecting invoices and the registrant is known
 ,zit.TotalBeforeTax																																																																			--# total amount of invoice not including tax
 ,zit.Tax1Total																																																																						--# total of tax type 1 for the invoice
 ,zit.Tax2Total																																																																						--# total of tax type 2 for the invoice
 ,zit.Tax3Total																																																																						--# total of tax type 3 for the invoice
 ,zit.TotalAdjustment																																																																			--# total amount of adjustments made on line items on the invoice
 ,zit.TotalAfterTax																																																																				--# total amount of the invoice - includes base amount, adjustments and tax
 ,zit.TotalPaid																																																																						--# total amount paid on the invoice
 ,zit.TotalDue																																																																						--# total that needs to be paid on the invoice (total after tax less paid amounts)
 ,zit.IsUnPaid																																																																						--# indicates if the invoice is currently unpaid
 ,zit.IsPaid																																																																							--# indicates if the invoice is currently paid
 ,zit.IsOverPaid																																																																					--# indicates if the invoice is currently overpaid
 ,cast((case
					when i.CancelledTime is not null then 0
					when zit.TotalDue <= 0 then 0
					when datediff(day, i.InvoiceDate, sf.fToday()) > 30 then 1
					else 0
				end
			 ) as bit)																																																											IsOverDue						--# Indicates if the invoice has an unpaid balance for more than 30 days
 ,zgla1.GLAccountLabel																																																								Tax1GLAccountLabel	--# label for the first tax account (credit GL account)
 ,zgla1.IsTaxAccount																																																									Tax1IsTaxAccount		--# indicator whether the first tax account has a tax-type in the GL setup
 ,zgla2.GLAccountLabel																																																								Tax2GLAccountLabel	--# label for the second tax account (credit GL account)
 ,zgla2.IsTaxAccount																																																									Tax2IsTaxAccount		--# indicator whether the second tax account has a tax-type in the GL setup
 ,zgla3.GLAccountLabel																																																								Tax3GLAccountLabel	--# label for the third tax account (credit GL account)
 ,zgla3.IsTaxAccount																																																									Tax3IsTaxAccount		--# indicator whether the third tax account has a tax-type in the GL setup
 ,case
		when dbo.fRegistrationYear(sf.fDTOffsetToClientDateTime(i.CreateTime)) < i.RegistrationYear then cast(1 as bit)
		else cast(0 as bit)
	end																																																																	IsDeferred					--# Indicates the revenue is collected for a later registration year
 ,cast((case when i.CancelledTime is null then 0 else 1 end) as bit)																																	IsCancelled					--# Indicates the invoice has been cancelled
 ,case
		when i.CancelledTime is null and
																 (
																	 zit.TotalPaid = 0.00
																	 or sf.fIsSysAdmin() = cast(1 as bit)
																	 or sf.fIsGranted('ADMIN.ACCOUNTING') = cast(1 as bit)
																 ) then sf.fIsGranted('ADMIN.BASE')
		else cast(0 as bit)
	end																																																																	IsEditEnabled				--# Indicates if current user can edit the invoice
 ,cast((
				 select
						count(1)
				 from
						dbo.PAPSubscription ps
				 where
					 ps.PersonSID = i.PersonSID and sf.fIsActive(ps.EffectiveTime, ps.CancelledTime) = cast(1 as bit)
			 ) as bit)																																																											IsPAPSubscriber
 ,(case
		 when sf.fNow() between rsy.PAPBlockStartTime and rsy.PAPBlockEndTime then cast(0 as bit)
		 else cast(1 as bit)
	 end
	)																																																																		IsPAPEnabled				--# Indicates whether use of pre-authorized balances to pay invoices is enabled (based on schedule)
	,zma.AddressBlockForPrint
	,zma.AddressBlockForHTML
--! </MoreColumns>
from
	dbo.Invoice   i
join
	sf.Person     person    on i.PersonSID = person.PersonSID
left outer join
	dbo.Complaint complaint on i.ComplaintSID = complaint.ComplaintSID
left outer join
	dbo.Reason    reason    on i.ReasonSID = reason.ReasonSID
--! <MoreJoins>
join
	dbo.RegistrationSchedule		 rs on rs.IsDefault								 = cast(1 as bit)
join
	dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = dbo.fRegistrationYear#Current()
outer apply dbo.fInvoice#Total(i.InvoiceSID) zit
outer apply dbo.fPersonMailingAddress#Formatted(i.PersonSID) zma
left outer join
	dbo.Registrant							 r on person.PersonSID						 = r.PersonSID
left outer join
	dbo.GLAccount								 zgla1 on i.Tax1GLAccountCode			 = zgla1.GLAccountCode
left outer join
	dbo.GLAccount								 zgla2 on i.Tax2GLAccountCode			 = zgla2.GLAccountCode
left outer join
	dbo.GLAccount								 zgla3 on i.Tax3GLAccountCode			 = zgla3.GLAccountCode;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the invoice assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'InvoiceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ComplaintTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the complaint was reported. | Normally the record entry date but provided to support back-dating when received through other channels', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'OpenedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the start of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ConductStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the end of the period the reported conduct took place', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ConductEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint severity assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ComplaintSeveritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the outcome text is displayed on the public directory', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsDisplayedOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this complaint', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ComplaintReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ComplaintRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'display label for the invoice to use to select among invoices when making payment', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'InvoiceLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'a shorter form of the display label to use when selecting invoices and the registrant is known', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'InvoiceShortLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount of invoice not including tax', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'TotalBeforeTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total of tax type 1 for the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax1Total'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total of tax type 2 for the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax2Total'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total of tax type 3 for the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax3Total'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount of adjustments made on line items on the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'TotalAdjustment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount of the invoice - includes base amount, adjustments and tax', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'TotalAfterTax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total amount paid on the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'TotalPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'total that needs to be paid on the invoice (total after tax less paid amounts)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'TotalDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice is currently unpaid', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsUnPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice is currently paid', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if the invoice is currently overpaid', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsOverPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the invoice has an unpaid balance for more than 30 days', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsOverDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'label for the first tax account (credit GL account)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax1GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicator whether the first tax account has a tax-type in the GL setup', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax1IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'label for the second tax account (credit GL account)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax2GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicator whether the second tax account has a tax-type in the GL setup', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax2IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'label for the third tax account (credit GL account)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax3GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicator whether the third tax account has a tax-type in the GL setup', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'Tax3IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the revenue is collected for a later registration year', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsDeferred'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the invoice has been cancelled', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if current user can edit the invoice', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether use of pre-authorized balances to pay invoices is enabled (based on schedule)', 'SCHEMA', N'dbo', 'VIEW', N'vInvoice#Ext', 'COLUMN', N'IsPAPEnabled'
GO
