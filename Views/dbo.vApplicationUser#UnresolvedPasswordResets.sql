SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vApplicationUser#UnresolvedPasswordResets]
/*********************************************************************************************************************************
View			: Application User - Unresolved Password Resets
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for following up on password reset emails where user has not logged in successfully
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Oct 2017    |	Initial version

Comments	
--------
This view returns a list of users who are suspects of having login problems.  The view is intended to support a report for following
up on users who requested a password reset (email) but do not have a successful login after the reset email was sent. The view returns
the total count of reset emails, the date/time of the last one and whether it was opened, along with contact information for 
follow-up.  Only active user accounts are included in the analysis.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

				declare
					@PersonSID							int
				,	@EmailMessageSID				int
				,	@PersonEmailMessageSID	int
				,	@EmailAddress						nvarchar(200)
				,	@FileTypeSID						int
				,	@FileTypeSCD						varchar(10)
				,	@EmailMessageSubject		varchar(50)
				,	@ApplicationEntitySID		int

			begin tran

			-- Set up data

			select
					@EmailMessageSubject	=		et.Subject
				,	@ApplicationEntitySID = et.ApplicationEntitySID
			from 
				sf.DefaultEmailTemplate det
			join
				sf.EmailTemplate et on det.EmailTemplateSID = et.EmailTemplateSID
			where
				det.DefaultEmailTemplateSCD = 'PASS.RESET'

			select top 1
				 @PersonSID			=	au.PersonSID
				,@EmailAddress	=	au.UserName
			from
				sf.ApplicationUser au
			order by
				newid()

			select
					@FileTypeSID	= ft.FileTypeSID
				,	@FileTypeSCD	= ft.FileTypeSCD
			from
				sf.FileType ft
			where
				ft.IsActive = 1
			order by
				newid()

			insert into sf.EmailMessage
			(
				SenderEmailAddress
				,SenderDisplayName
				,PriorityLevel
				,Subject
				,body
				--,MergedTime
				--,QueuedTime
				,RecipientList
				,ApplicationEntitySID
			)
			select
					'noreply@softworks.ca'
				,	'Test'
				, 1
				,	@EmailMessageSubject
				,	cast('TEST' as varbinary)
				--, dateadd(hour,-1,sf.fNow())
				--, dateadd(hour,-1,sf.fNow())
				,'<Recipients />'
				, @ApplicationEntitySID

			set @EmailMessageSID = scope_identity()
			
			insert into sf.PersonEmailMessage
			(
					PersonSID
				,	EmailAddress
				--,	SentTime
				,	Subject
				,	Body
				, EmailMessageSID
				, FileTypeSCD
				, FileTypeSID
				,	ChangeAudit
				, MergeKey
			)
			select
					@PersonSID
				,	@EmailAddress
				--,	sf.fNow()
				,	@EmailMessageSubject
				,	'** Hi **'
				,	@EmailMessageSID
				,	@FileTypeSCD
				,	@FileTypeSID
				,	'test'
				, 1015027

				set @PersonEmailMessageSID = scope_identity()

				update sf.EmailMessage
					set MergedTime = sf.fNow()
				where
					EmailMessageSID = @EmailMessageSID

				update sf.PersonEmailMessage
					set 
					SentTime = sf.fNow()
					,MergeKey = 1000021
				where
					PersonEmailMessageSID = @PersonEmailMessageSID

			-- Test View
			select top 1
			  x.RegistrantLabel
			 ,x.PasswordResets
			 ,x.LastResetEmailSent
			 ,x.LastSuccessfulLogin
			 ,x.LastEmailWasOpened
			 ,x.TotalLogins
			 ,x.[UserName/Email]
			 ,x.Phone
			from
				dbo.vApplicationUser#UnresolvedPasswordResets x
			order by
				x.RegistrantLabel
			where
				x.PersonSID = @PersonSID

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			if @@trancount > 0 rollback
			

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[

				declare
					@PersonSID							int
				,	@EmailMessageSID				int
				,	@PersonEmailMessageSID	int
				,	@EmailAddress						nvarchar(200)
				,	@FileTypeSID						int
				,	@FileTypeSCD						varchar(10)
				,	@EmailMessageSubject		varchar(50)
				,	@ApplicationEntitySID		int

			begin tran

			-- Set up data

			select
					@EmailMessageSubject	=		et.Subject
				,	@ApplicationEntitySID = et.ApplicationEntitySID
			from 
				sf.DefaultEmailTemplate det
			join
				sf.EmailTemplate et on det.EmailTemplateSID = et.EmailTemplateSID
			where
				det.DefaultEmailTemplateSCD = 'PASS.RESET'

			select top 1
				 @PersonSID			=	au.PersonSID
				,@EmailAddress	=	au.UserName
			from
				sf.ApplicationUser au
			order by
				newid()

			select
					@FileTypeSID	= ft.FileTypeSID
				,	@FileTypeSCD	= ft.FileTypeSCD
			from
				sf.FileType ft
			where
				ft.IsActive = 1
			order by
				newid()

			insert into sf.EmailMessage
			(
				SenderEmailAddress
				,SenderDisplayName
				,PriorityLevel
				,Subject
				,body
				--,MergedTime
				--,QueuedTime
				,RecipientList
				,ApplicationEntitySID
			)
			select
					'noreply@softworks.ca'
				,	'Test'
				, 1
				,	@EmailMessageSubject
				,	cast('TEST' as varbinary)
				--, dateadd(hour,-1,sf.fNow())
				--, dateadd(hour,-1,sf.fNow())
				,'<Recipients />'
				, @ApplicationEntitySID

			set @EmailMessageSID = scope_identity()
			
			insert into sf.PersonEmailMessage
			(
					PersonSID
				,	EmailAddress
				--,	SentTime
				,	Subject
				,	Body
				, EmailMessageSID
				, FileTypeSCD
				, FileTypeSID
				,	ChangeAudit
				, MergeKey
			)
			select
					@PersonSID
				,	@EmailAddress
				--,	sf.fNow()
				,	@EmailMessageSubject
				,	'** Hi **'
				,	@EmailMessageSID
				,	@FileTypeSCD
				,	@FileTypeSID
				,	'test'
				, 1015027

				set @PersonEmailMessageSID = scope_identity()

				update sf.EmailMessage
					set MergedTime = sf.fNow()
				where
					EmailMessageSID = @EmailMessageSID

				update sf.PersonEmailMessage
					set 
					SentTime = sf.fNow()
					,MergeKey = 1000021
				where
					PersonEmailMessageSID = @PersonEmailMessageSID

			-- Test View
			select
			  x.RegistrantLabel
			 ,x.PasswordResets
			 ,x.LastResetEmailSent
			 ,x.LastSuccessfulLogin
			 ,x.LastEmailWasOpened
			 ,x.TotalLogins
			 ,x.[UserName/Email]
			 ,x.Phone
			from
				dbo.vApplicationUser#UnresolvedPasswordResets x
			order by
				x.RegistrantLabel

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			if @@trancount > 0 rollback
			

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vApplicationUser#UnresolvedPasswordResets'
 ,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */
as
select
	p.PersonSID
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRATION') RegistrantLabel
 ,x.PasswordResets
 ,x.LastResetEmailSent																																					LastResetEmailSent
 ,LastLoginTime																																									LastSuccessfulLogin
 ,cast(case when x.LastResetEmailOpened is null then 0 else 1 end as bit)												LastEmailWasOpened
 ,y.TotalLogins
 ,(case
	 when sf.fIsDifferent(au.UserName, pea.EmailAddress) = 1 then au.UserName + '/' + isnull(pea.EmailAddress, '<none>')
	 else au.UserName
	 end
	)																																															[UserName/Email]
 ,isnull(p.MobilePhone + '/', '') + p.HomePhone																									Phone
from
(
	select
		pem.PersonSID
	 ,pem.Subject
	 ,count(1)						PasswordResets
	 ,max(pem.SentTime)		LastResetEmailSent
	 ,max(pem.OpenedTime) LastResetEmailOpened
	from
		sf.DefaultEmailTemplate det
	join
		sf.EmailTemplate				et on det.EmailTemplateSID = et.EmailTemplateSID
	join
		sf.PersonEmailMessage		pem on et.Subject					 = pem.Subject
	join
		sf.EmailMessage					em on pem.EmailMessageSID	 = em.EmailMessageSID and et.ApplicationEntitySID = em.ApplicationEntitySID
	where
		det.DefaultEmailTemplateSCD = 'PASS.RESET'
	group by
		pem.PersonSID
	 ,pem.Subject
)												x
join
	sf.Person							p on x.PersonSID	 = p.PersonSID
join
	sf.ApplicationUser		au on p.PersonSID	 = au.PersonSID
left outer join
(
	select
		au.PersonSID
	 ,count(1)						TotalLogins
	 ,min(aus.UpdateTime) FirstLoginTime
	 ,max(aus.UpdateTime) LastLoginTime
	from
		sf.ApplicationUserSession aus
	join
		sf.ApplicationUser				au on aus.ApplicationUserSID = au.ApplicationUserSID
	where
		au.IsActive = 1
	group by
		au.PersonSID
)												y on x.PersonSID	 = y.PersonSID
left outer join
	dbo.Registrant				r on p.PersonSID	 = r.PersonSID
left outer join
	sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = 1 and pea.IsActive = 1
where
	y.PersonSID is null or y.LastLoginTime < x.LastResetEmailSent;
GO
