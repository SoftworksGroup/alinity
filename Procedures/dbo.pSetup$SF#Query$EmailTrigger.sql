SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#Query$EmailTrigger]
as
/*********************************************************************************************************************************
Sproc    : Setup Email Trigger Queries
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns a data set of sf.Query master table data to pSetup$SF#Query
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Russell P		| Aug 2018		|	Initial version
					: Russell P		|	Feb 2019		| Added "SelectionTime" as a parameter and used in all queries

Comments	
--------
This procedure adds queries used to support email triggers. This does not create the actual email triggers, only the queries used.

Maintenance note: All new queries need to be added to the bottom of this file as QueryCode's get assigned in the order they appear
in the temp table. If added to the middle it will conflict with other queries that may already have the QueryCode assigned.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Returns configured registration queries.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#Query$EmailTrigger

			select * from sf.Query

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Query$EmailTrigger'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int = 0					-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)	-- message text (for business rule errors)
	 ,@applicationPageSID int							-- key of the search page where these queries are to appear
	 ,@defaultPageSID			int							-- key of the search page where these query is to appear if target page not found
	 ,@queryCategorySID		int;						-- key of the category/group to assign queries to

	begin try

		declare @setup table -- setup data for staging rows to be inserted
		(
			ID								 int					 identity(1, 1)
		 ,QueryCategorySID	 int					 not null
		 ,QueryLabel				 nvarchar(35)	 not null
		 ,ToolTip						 nvarchar(250) not null
		 ,QuerySQL					 nvarchar(max) not null
		 ,QueryParameters		 xml					 null
		 ,ApplicationPageSID int					 not null
		);

		select
			@defaultPageSID = ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		if @defaultPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationPage'
			 ,@Arg2 = 'ClientApplicationPortal';

			raiserror(@errorText, 18, 1);
		end;

		select top (1)
			@queryCategorySID = qc.QueryCategorySID
		from
			sf.QueryCategory qc
		where
			qc.QueryCategoryCode = 'S!WORKFLOW'
		order by
			qc.QueryCategorySID;

		if @queryCategorySID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.QueryCategory'
			 ,@Arg2 = 'S!WORKFLOW';

			raiserror(@errorText, 18, 1);
		end;

		-- TODO: Russ Aug 2018; trigger queries should appear on the UI so that they can be
		-- reviewed/tested by configurators and end users before email is generated. A
		-- query category "Workflow" is created to group these.  Logic
		-- to find the correct application page needs to be added.

		insert
			@setup
		(
			QueryCategorySID
		 ,ApplicationPageSID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		)
		select
			@queryCategorySID
		 ,isnull(@applicationPageSID, @defaultPageSID)
		 ,N'Apps ready for org verification'
		 ,N'Returns supervisors of applications ready for verification. This query is applied by the system in generating email and text messages through a workflow automation (where enabled - review with Help Desk). '
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
					 max(rar.RegistrantAppSID) RegistrantAppSID
					,rar.PersonSID
				from
					dbo.RegistrantAppReview								rar
				cross apply
					dbo.fRegistrantAppReview#CurrentStatus(rar.RegistrantAppReviewSID, -1) rarcs
				join
					sf.FormVersion												fv on rar.FormVersionSID = fv.FormVersionSID
				join
					sf.Form																f on fv.FormSID = f.FormSID
				cross apply
					dbo.fRegistrantAppReview#CurrentStatus(rar.RegistrantAppReviewSID, -1) rax
				where
					rax.FormOwnerSCD = ''ASSIGNEE''
				and
					([@SelectionTime] is null or rarcs.LastStatusChangeTime >= [@SelectionTime])
				group by
					rar.PersonSID';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Apps reviewed with feedback (Email)'
		 ,N'Returns all applications reviewed by an administrator but contains feedback for the applicant to review and a email has not been sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.RegistrantApp r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantApp#CurrentStatus(r.RegistrantAppSID, -1) rcs
				left outer join
				(
					select
						 rs.RegistrantAppSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.RegistrantApp rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantAppSID
				) x on r.RegistrantAppSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''RETURNED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Audits with feedback (Email)'
		 ,N'Returns all audits with feedback for which an email has not been sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
					 ra.RegistrantAuditSID
					,ra.PersonSID
				from
					dbo.vRegistrantAudit#Search ra
				left outer join
				(
					select
							pem.MergeKey					RegistrantAuditSID
						,max(pem.CreateTime)	LastEmailMessageCreateTime
					from
						sf.PersonEmailMessage pem
					join	
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID
					where
						ae.ApplicationEntitySCD = ''dbo.RegistrantAudit'' or ae.ApplicationEntitySCD = ''dbo.RegistrantAudit#Search''
					group by
						pem.MergeKey
				) x on ra.RegistrantAuditSID = x.RegistrantAuditSID
				where
					ra.RegistrantAuditStatusSCD = ''RETURNED''
				and
					([@SelectionTime] is null or ra.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegistrantAuditSID is null
				or
					ra.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		
		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Apps reviewed with feedback (SMS)'
		 ,N'Returns all applications reviewed by an administrator but contains feedback for the applicant to review and a SMS message has not been sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.RegistrantApp r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantApp#CurrentStatus(r.RegistrantAppSID, -1) rcs
				left outer join
				(
					select
						 rs.RegistrantAppSID RegFormRecordSID
						,max(pem.CreateTime) LastTextMessageCreateTime
					from
						dbo.RegistrantApp rs
					join
						sf.PersonTextMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.TextMessage em on pem.TextMessageSID = em.TextMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantAppSID
				) x on r.RegistrantAppSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''RETURNED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastTextMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Submitted applications (Email)'
		 ,N'Returns all applications submitted that did not have a email sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.RegistrantApp r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantApp#CurrentStatus(r.RegistrantAppSID, -1) rcs
				left outer join
				(
					select
						 rs.RegistrantAppSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.RegistrantApp rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantAppSID
				) x on r.RegistrantAppSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''SUBMITTED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Submitted audits (Email)'
		 ,N'Returns all audits submitted that did not have a email sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
						ra.RegistrantAuditSID
					,	rt.PersonSID
				from
					dbo.RegistrantAudit ra
				join
					dbo.Registrant rt on rt.RegistrantSID = ra.RegistrantSID
				join
				(
					select
							ras.RegistrantAuditSID
						,	ras.FormStatusSCD
						,	ras.LastStatusChangeTime
					from
						dbo.fRegistrantAudit#CurrentStatus(-1, -1) ras
				) ras on ras.RegistrantAuditSID = ra.RegistrantAuditSID
				left outer join
				(
					select
							pem.MergeKey						RegistrantAuditSID
						,	max(pem.CreateTime)			LastEmailMessageCreateTime
					from
						sf.PersonEmailMessage pem
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID
					where
						ae.ApplicationEntitySCD = ''dbo.RegistrantAudit''
					or
						ae.ApplicationEntitySCD = ''dbo.RegistrantAudit#Search''
					group by
						pem.MergeKey
				) x on ra.RegistrantAuditSID = x.RegistrantAuditSID
				where
					ras.FormStatusSCD = ''SUBMITTED''
				and
					([@SelectionTime] is null or ras.LastStatusChangeTime >= [@SelectionTime])
				and
					(x.RegistrantAuditSID is null or ras.LastStatusChangeTime > x.LastEmailMessageCreateTime)'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Withdrawn audits (Email)'
		 ,N'Returns all withdrawn audits that did not have a email sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'declare
@cutoff datetimeoffset = dateadd(d, -1, sysdatetimeoffset())
select
					 ra.RegistrantAuditSID
					,ra.PersonSID
				from
					dbo.vRegistrantAudit#Search ra
				left outer join
				(
					select
							pem.MergeKey					RegistrantAuditSID
						,max(pem.CreateTime)	LastEmailMessageCreateTime
					from
						sf.PersonEmailMessage pem
					join	
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID
					where
						ae.ApplicationEntitySCD = ''dbo.RegistrantAudit'' or ae.ApplicationEntitySCD = ''dbo.RegistrantAudit#Search''
					group by
						pem.MergeKey
				) x on ra.RegistrantAuditSID = x.RegistrantAuditSID
				where
					ra.RegistrantAuditStatusSCD = ''WITHDRAWN''
				and
					([@SelectionTime] is null or ra.LastStatusChangeTime >= [@SelectionTime])
        and
          ra.LastStatusChangeTime >= @cutoff
				and
				(
					x.RegistrantAuditSID is null
				or
					ra.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Submitted applications (SMS)'
		 ,N'Returns all applications submitted that did not have a text message sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.RegistrantApp r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantApp#CurrentStatus(r.RegistrantAppSID, -1) rcs
				left outer join
				(
					select
						 rs.RegistrantAppSID RegFormRecordSID
						,max(pem.CreateTime) LastTextMessageCreateTime
					from
						dbo.RegistrantApp rs
					join
						sf.PersonTextMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.TextMessage em on pem.TextMessageSID = em.TextMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantAppSID
				) x on r.RegistrantAppSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''SUBMITTED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastTextMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Approved applications (Email)'
		 ,N'Returns all applications approved that did not have a email message sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.RegistrantApp r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantApp#CurrentStatus(r.RegistrantAppSID, -1) rcs
				left outer join
				(
					select
						 rs.RegistrantAppSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.RegistrantApp rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantAppSID
				) x on r.RegistrantAppSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''APPROVED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';
			
		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Unpaid approved renewals (Email)'
		 ,N'Returns all renewals approved that aren''t paid and have not received an email yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
					r.RegistrationSID
					,reg.PersonSID
				from
					dbo.RegistrantRenewal																												 r
				join
					dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
				join
					dbo.Registration																														 re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant																															 reg on re.RegistrantSID = reg.RegistrantSID
				cross apply dbo.fRegistrantRenewal#CurrentStatus(r.RegistrantRenewalSID, -1) rcs
				join 
					dbo.RegistrantRenewalStatus rrs on rcs.RegistrantRenewalStatusSID = rrs.RegistrantRenewalStatusSID
				outer apply dbo.fInvoice#Total(r.InvoiceSID) zit
				left outer join
					dbo.vPAPSubscription																													paps on reg.PersonSID = paps.PersonSID
						and paps.IsActiveSubscription = cast(1 as bit)
				left outer join
				(
					select
						rs.RegistrantRenewalSID RegFormRecordSID
						,max(pem.CreateTime)			LastEmailMessageCreateTime
					from
						dbo.RegistrantRenewal rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID			= pem.MergeKey
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantRenewalSID
				) x on r.RegistrantRenewalSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD	= ''APPROVED''
				and 
					zit.IsPaid = cast(0 as bit)
				and
					pr.IsDefaultInactivePractice = cast(0 as bit)
				and
					paps.PAPSubscriptionSID is null
				and
					([@SelectionTime] is null or rrs.CreateTime >= [@SelectionTime])
				and
					(x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Paid approved renewals (Email)'
		 ,N'Returns all renewals approved that are paid and have not received an email yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
					r.RegistrationSID
					,reg.PersonSID
				from
					dbo.RegistrantRenewal																												 r
				join
					dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
				join
					dbo.Registration																														 re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant																															 reg on re.RegistrantSID = reg.RegistrantSID
				cross apply dbo.fRegistrantRenewal#CurrentStatus(r.RegistrantRenewalSID, -1) rcs
				join 
					dbo.RegistrantRenewalStatus rrs on rcs.RegistrantRenewalStatusSID = rrs.RegistrantRenewalStatusSID
				outer apply dbo.fInvoice#Total(r.InvoiceSID) zit
				left outer join
				(
					select
						rs.RegistrantRenewalSID RegFormRecordSID
						,max(pem.CreateTime)			LastEmailMessageCreateTime
					from
						dbo.RegistrantRenewal rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID			= pem.MergeKey
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantRenewalSID
				) x on r.RegistrantRenewalSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD	= ''APPROVED''
				and 
					zit.IsPaid = cast(1 as bit)
				and
					pr.IsDefaultInactivePractice = cast(0 as bit)
				and
					([@SelectionTime] is null or rrs.CreateTime >= [@SelectionTime])
				and
					(x.RegFormRecordSID is null or rrs.CreateTime > x.LastEmailMessageCreateTime)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Blocked renewals (Email)'
		 ,N'Returns all blocked renewals that have not received an email yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
					r.RegistrationSID
					,reg.PersonSID
				from
					dbo.RegistrantRenewal																												 r
				join
					dbo.Registration																														 re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant																															 reg on re.RegistrantSID = reg.RegistrantSID
				cross apply dbo.fRegistrantRenewal#CurrentStatus(r.RegistrantRenewalSID, -1) rcs
				join 
					dbo.RegistrantRenewalStatus rrs on rcs.RegistrantRenewalStatusSID = rrs.RegistrantRenewalStatusSID
				left outer join
				(
					select
						rs.RegistrantRenewalSID RegFormRecordSID
						,max(pem.CreateTime)			LastEmailMessageCreateTime
					from
						dbo.RegistrantRenewal rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID			= pem.MergeKey
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantRenewalSID
				) x on r.RegistrantRenewalSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD	= ''SUBMITTED'' and r.IsAutoApprovalEnabled = cast(0 as bit)
				and
					([@SelectionTime] is null or rrs.CreateTime >= [@SelectionTime])
				and
					(x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Inactive approved renewals (Email)'
		 ,N'Returns all approved renewals where they renewed into the default inactive register.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
					r.RegistrationSID
					,reg.PersonSID
				from
					dbo.RegistrantRenewal																												 r
				join
					dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
				join
					dbo.Registration																														 re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant																															 reg on re.RegistrantSID = reg.RegistrantSID
				cross apply dbo.fRegistrantRenewal#CurrentStatus(r.RegistrantRenewalSID, -1) rcs
				join 
					dbo.RegistrantRenewalStatus rrs on rcs.RegistrantRenewalStatusSID = rrs.RegistrantRenewalStatusSID
				outer apply dbo.fInvoice#Total(r.InvoiceSID) zit
				left outer join
				(
					select
						rs.RegistrantRenewalSID RegFormRecordSID
						,max(pem.CreateTime)			LastEmailMessageCreateTime
					from
						dbo.RegistrantRenewal rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID			= pem.MergeKey
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantRenewalSID
				) x on r.RegistrantRenewalSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD	= ''APPROVED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
					pr.IsDefaultInactivePractice = cast(1 as bit)
				and
					(x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';


		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Approved applications (SMS)'
		 ,N'Returns all applications approved that did not have a SMS message sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.RegistrantApp r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantApp#CurrentStatus(r.RegistrantAppSID, -1) rcs
				left outer join
				(
					select
						 rs.RegistrantAppSID RegFormRecordSID
						,max(pem.CreateTime) LastTextMessageCreateTime
					from
						dbo.RegistrantApp rs
					join
						sf.PersonTextMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.TextMessage em on pem.TextMessageSID = em.TextMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantAppSID
				) x on r.RegistrantAppSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''APPROVED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastTextMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Employer verification overdue'
		 ,N'Returns verifications in the employer verification status that have not been completed in the last 2 weeks.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
					 max(rar.RegistrantAppSID) RegistrantAppSID
					,rar.PersonSID
				from
					dbo.RegistrantAppReview rar
				join
					sf.FormVersion          fv on rar.FormVersionSID = fv.FormVersionSID
				join
					sf.Form                 f on fv.FormSID = f.FormSID
				cross apply
					dbo.fRegistrantAppReview#CurrentStatus(rar.RegistrantAppReviewSID, -1) rarx
				where
					rarx.FormOwnerSCD = ''SUPERVISOR''
				and
					([@SelectionTime] = [@SelectionTime])
				and
					datediff(day, rarx.LastStatusChangeTime, sysdatetimeoffset()) > 14
				group by
					rar.PersonSID'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Registrant review overdue'
		 ,N'Returns applications reviewed by admin and sent back to registrant but has not been re-submitted for more than 2 weeks.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
					 rar.RegistrantAppSID
					,rar.PersonSID
				from
					dbo.vRegistrantApp#Search rar
				where
					rar.RegistrantAppStatusSCD = ''RETURNED''
				and
					([@SelectionTime] = [@SelectionTime])
				and
					datediff(day, rar.LastStatusChangeTime, sysdatetimeoffset()) > 14'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Blocked PU (Email)'
		 ,N'Returns all blocked profile update forms that have not received an email.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
					pu.ProfileUpdateSID
				 ,pu.PersonSID
				from
					dbo.ProfileUpdate																										pu
				cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) pucs
				left outer join
				(
					select
						pem.MergeKey				ProfileUpdateSID
					 ,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						sf.PersonEmailMessage pem
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID
					where
						ae.ApplicationEntitySCD = ''dbo.ProfileUpdate''
					group by
						pem.MergeKey
				) x on pu.ProfileUpdateSID = x.ProfileUpdateSID
				where
					pucs.FormStatusSCD = ''SUBMITTED'' and pu.IsAutoApprovalEnabled = cast(0 as bit)
					and
						([@SelectionTime] is null or pucs.LastStatusChangeTime >= [@SelectionTime])
					and
					(
						x.ProfileUpdateSID is null or pucs.LastStatusChangeTime > x.LastEmailMessageCreateTime
					)
					and pucs.LastStatusChangeTime															> x.LastEmailMessageCreateTime'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Approved PU (Email)'
		 ,N'Returns all blocked profile update forms that have been approved and not received an email.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'select
					pu.ProfileUpdateSID
				 ,pu.PersonSID
				from
					dbo.ProfileUpdate																										pu
				cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) pucs
				left outer join
				(
					select
						pem.MergeKey				ProfileUpdateSID
					 ,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						sf.PersonEmailMessage pem
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID
					where
						ae.ApplicationEntitySCD = ''dbo.ProfileUpdate''
					group by
						pem.MergeKey
				) x on pu.ProfileUpdateSID = x.ProfileUpdateSID
				where
					pucs.FormStatusSCD																				= ''APPROVED''
					and
						([@SelectionTime] is null or pucs.LastStatusChangeTime >= [@SelectionTime])
					and
					(
						x.ProfileUpdateSID is null or pucs.LastStatusChangeTime > x.LastEmailMessageCreateTime
					)
					and pucs.LastStatusChangeTime															> x.LastEmailMessageCreateTime'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Approved Audit (Email)'
		 ,N'Returns all approved audit forms that have been approved and not received an email.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				declare
						@formTypeSID  int = (select FormTypeSID from sf.FormType where FormTypeSCD = ''AUDIT.MAIN'')

				select
						r.RegistrantAuditSID
					, reg.PersonSID
				from
						dbo.RegistrantAudit r
				join
					dbo.Registrant reg on r.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantAudit#CurrentStatus(r.RegistrantAuditSID, -1) rcs
				left outer join
				(
					select
							rs.RegistrantAuditSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.RegistrantAudit rs
					join
						sf.PersonEmailMessage pem on rs.RegistrantAuditSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.RegistrantAudit''
					group by
						rs.RegistrantAuditSID
				) x on r.RegistrantAuditSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''APPROVED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Renewals returned (Email)'
		 ,N'Returns all renewals that have been sent back to registrant for feedback'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
					r.RegistrationSID
					,reg.PersonSID
				from
					dbo.RegistrantRenewal																												 r
				join
					dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
				join
					dbo.Registration																														 re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant																															 reg on re.RegistrantSID = reg.RegistrantSID
				cross apply dbo.fRegistrantRenewal#CurrentStatus(r.RegistrantRenewalSID, -1) rcs
				join 
					dbo.RegistrantRenewalStatus rrs on rcs.RegistrantRenewalStatusSID = rrs.RegistrantRenewalStatusSID
				outer apply dbo.fInvoice#Total(r.InvoiceSID) zit
				left outer join
				(
					select
						rs.RegistrantRenewalSID RegFormRecordSID
						,max(pem.CreateTime)			LastEmailMessageCreateTime
					from
						dbo.RegistrantRenewal rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID			= pem.MergeKey
					join
						sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
					join
						sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.RegistrantRenewalSID
				) x on r.RegistrantRenewalSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD	= ''RETURNED''
				and
					([@SelectionTime] is null or rrs.CreateTime >= [@SelectionTime])
				and
					(x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Rejected/Declined Audit (Email)'
		 ,N'Returns all completed audit forms that have been rejected/declined and not received an email.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				declare
						@formTypeSID  int = (select FormTypeSID from sf.FormType where FormTypeSCD = ''AUDIT.MAIN'')

				select
						r.RegistrantAuditSID
					, reg.PersonSID
				from
						dbo.RegistrantAudit r
				join
					dbo.Registrant reg on r.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fRegistrantAudit#CurrentStatus(r.RegistrantAuditSID, -1) rcs
				left outer join
				(
					select
							rs.RegistrantAuditSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.RegistrantAudit rs
					join
						sf.PersonEmailMessage pem on rs.RegistrantAuditSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.RegistrantAudit''
					group by
						rs.RegistrantAuditSID
				) x on r.RegistrantAuditSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''REJECTED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

			insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Reinstatement with feedback (Email)'
		 ,N'Returns all reinstatements reviewed by an administrator but contains feedback for the registrant to review and a email has not been sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.Reinstatement r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fReinstatement#CurrentStatus(r.ReinstatementSID, -1) rcs
				left outer join
				(
					select
						 rs.ReinstatementSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.Reinstatement rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.ReinstatementSID
				) x on r.ReinstatementSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''RETURNED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Submitted reinstatements (Email)'
		 ,N'Returns all reinstatements submitted that did not have a email sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.Reinstatement r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fReinstatement#CurrentStatus(r.ReinstatementSID, -1) rcs
				left outer join
				(
					select
						 rs.ReinstatementSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.Reinstatement rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.ReinstatementSID
				) x on r.ReinstatementSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''SUBMITTED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryLabel
		 ,ToolTip
		 ,QueryParameters
		 ,QuerySQL
		 ,ApplicationPageSID
		)
		select
			@queryCategorySID
		 ,N'Approved reinstatements (Email)'
		 ,N'Returns all reinstatements approved that did not have a email message sent yet.'
		 ,'<Parameters><Parameter ID="SelectionTime" Label="Selection Time" Type="DatePicker" /></Parameters>'
		 ,N'
				select
						r.RegistrationSID
					, reg.PersonSID
				from
					 dbo.Reinstatement r
				join
					dbo.Registration re on r.RegistrationSID = re.RegistrationSID
				join
					dbo.Registrant reg on re.RegistrantSID = reg.RegistrantSID
				cross apply
					dbo.fReinstatement#CurrentStatus(r.ReinstatementSID, -1) rcs
				left outer join
				(
					select
						 rs.ReinstatementSID RegFormRecordSID
						,max(pem.CreateTime) LastEmailMessageCreateTime
					from
						dbo.Reinstatement rs
					join
						sf.PersonEmailMessage pem on rs.RegistrationSID = pem.MergeKey
					join
						sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
					join
						sf.ApplicationEntity ae on em.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = ''dbo.Registration''
					group by
						rs.ReinstatementSID
				) x on r.ReinstatementSID = x.RegFormRecordSID
				where
					rcs.FormStatusSCD  = ''APPROVED''
				and
					([@SelectionTime] is null or rcs.LastStatusChangeTime >= [@SelectionTime])
				and
				(
					x.RegFormRecordSID is null or rcs.LastStatusChangeTime > x.LastEmailMessageCreateTime
				)
			'
		 ,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ClientApplicationPortal';

		merge sf.Query as target
		using
		(
			select
				s.QueryCategorySID
			 ,'[NONE].' + ltrim(3000 + s.ID) QueryCode
			 ,s.QueryLabel
			 ,s.ToolTip
			 ,s.QuerySQL
			 ,s.QueryParameters
			 ,s.ApplicationPageSID
			from
				@setup s
		) as source
		(QueryCategorySID, QueryCode, QueryLabel, ToolTip, QuerySQL, QueryParameters, ApplicationPageSID)
		on (
				 target.QueryLabel = source.QueryLabel and target.ApplicationPageSID = source.ApplicationPageSID
			 )
		when matched and checksum(target.ToolTip, target.QuerySQL, cast(target.QueryParameters as nvarchar(max))) <> checksum(
																																																													 source.ToolTip
																																																													,source.QuerySQL
																																																													,cast(source.QueryParameters as nvarchar(max))
																																																												 ) then
			update set
				ToolTip = source.ToolTip
			 ,QuerySQL = source.QuerySQL
			 ,QueryParameters = source.QueryParameters
		when not matched by target then
			insert
			(
				QueryCategorySID
			 ,QueryCode
			 ,QueryLabel
			 ,ToolTip
			 ,QuerySQL
			 ,QueryParameters
			 ,ApplicationPageSID
			)
			values
			(
				source.QueryCategorySID, source.QueryCode, source.QueryLabel, source.ToolTip, source.QuerySQL, source.QueryParameters, source.ApplicationPageSID
			);


	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
