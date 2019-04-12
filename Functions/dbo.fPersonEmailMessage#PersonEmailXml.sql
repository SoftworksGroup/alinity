SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPersonEmailMessage#PersonEmailXml 
(@PersonSID int) -- the id of the person to retrieve emails for	
returns xml
as
/*********************************************************************************************************************************
Function	: Person Email Message - Item XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns a folder based XML document with email messages grouped by year (current year at root)
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Kris Dawson					| Feb 2017		|	Initial version
					: Cory Ng							| Apr 2017		| Added opened time in the returned XML
					: Cory Ng							| Mar 2018		| Returned IsGenerateOnly bit to show PDF icon on UI
					: Tim Edlund					| Apr	2019		| Applied security filter on ApplicationGrantSID in sf.EmailMessage

Comments
--------
This function is used to get folder/item XML, based on PersonEmailMessage entities that have a Subject and have a SentTime.
The emails are organized with the current year at the root and other emails organized by year.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[
declare
	@emailMessageSID			 int
 ,@PersonEmailMessageSID int
 ,@PersonSID						 int
 ,@FileTypeSID					 int
 ,@FileTypeSCD					 varchar(10)
 ,@recipientList				 xml
 ,@xml									 xml
 ,@now									 DATETIME2		= sf.fNow()
 ,@name									 nvarchar(255)

exec sf.pEntitySetDropCheck
	@TableName = 'EmailMessage'
 ,@SchemaName = 'sf'

exec sf.pEntitySetDropCheck
	@TableName = 'PersonEmailMessage'
 ,@SchemaName = 'sf'

begin tran

select
	@PersonSID = p.PersonSID
 ,@name			 = isnull(r.RegistrantLabel, p.FileAsName)
from
	sf.vPerson				 p
join
	sf.ApplicationUser au on p.PersonSID = au.PersonSID
left join
	dbo.vRegistrant		 r on au.PersonSID = r.PersonSID
where
	au.UserName = 'robin.p@softworks.ca'

set @recipientList =
(
	select
		Entity.PersonSID
	from
		sf.Person					 Entity
	join
		sf.ApplicationUser au on Entity.PersonSID = au.PersonSID
	where
		au.UserName = 'robin.p@softworks.ca'
	for xml auto, root('Recipients')
)

select
	@FileTypeSCD = ft.FileTypeSCD
 ,@FileTypeSID = ft.FileTypeSID
from
	sf.FileType ft
where
	ft.IsActive = cast(1 as bit)

insert into
	sf.EmailMessage
(
	SenderEmailAddress
 ,SenderDisplayName
 ,PriorityLevel
 ,Subject
 ,Body
 ,RecipientList
 ,IsApplicationUserRequired
 ,QueuedTime
)
select
	'test@softworksgroup.com'
 ,'*** TEST ***'
 ,1
 ,'*** TEST SUBJECT ***'
 ,CAST(N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum luctus.' as varbinary(max))
 ,@recipientList
 ,cast(1 as bit)
 ,@now

set @emailMessageSID = SCOPE_IDENTITY()

insert into
	sf.PersonEmailMessage
(
	PersonSID
 ,EmailMessageSID
 ,EmailAddress
 ,SelectedTime
 ,SentTime
 ,Subject
 ,Body
 ,EmailDocument
 ,FileTypeSID
 ,FileTypeSCD
 ,OpenedTime
 ,ChangeAudit
)
select
	@PersonSID
 ,@emailMessageSID
 ,'test@softworks.ca'
 ,@now
 ,@now
 ,'*** TEST ***'
 ,'*** TEST ***'
 ,cast('*** TEST ***' as varbinary(max))
 ,@FileTypeSID
 ,@FileTypeSCD
 ,@now
 ,'*** TEST ***'

set @PersonEmailMessageSID = scope_identity()

select @xml	 = dbo.fPersonEmailMessage#PersonEmailXml(@PersonSID)

select
	z.t.value('@Name', 'nvarchar(255)')
 ,@name
 ,case when z.t.value('@Name', 'nvarchar(255)') = @name then 'Pass' else 'Fail' end
from
(select @xml)											 x(n)
cross apply n.nodes('/RootFolder') z(t)

select
	f.t.value('@Name', 'nvarchar(255)')																																									Name
 ,f.t.value('@PersonEmailMessageSID', 'int')																																					PersonMessageSid
 ,f.t.value('@EmailMessageSID', 'nvarchar(255)')																																			EmailMessageSID
 ,f.t.value('@SentTime', 'nvarchar(max)')																																							Senttime
 ,f.t.value('@OpenedTime', 'nvarchar(max)')																																						OpenedTime
 ,case when f.t.value('@Name', 'nvarchar(255)') = '*** TEST ***' then 'Pass' else 'Fail' end													SubjectMatches
 ,case when f.t.value('@PersonEmailMessageSID', 'nvarchar(255)') = @PersonEmailMessageSID then 'Pass' else 'Fail' end PersonEmailMesasgeMatches
 ,case when f.t.value('@EmailMessageSID', 'nvarchar(255)') = @EmailMessageSID then 'Pass' else 'Fail' end							EmailMessageMatches
 ,case when f.t.value('@SentTime', 'nvarchar(255)') = @now then 'Pass' else 'Fail' end																SentTimeMatches
 ,case when f.t.value('@OpenedTime', 'nvarchar(255)') = @now then 'Pass' else 'Fail' end															OpenTimeMatches
from
(select @xml)									x(n)
cross apply n.nodes('//Item') f(t)
where
	f.t.value('@SentTime', 'nvarchar(max)') = @now

if @@rowcount = 0
	raiserror(N'* ERROR: no sample data found to run test', 18, 1)

if @@TRANCOUNT > 0 rollback

exec sf.pEntitySetAddCheck
	@TableName = 'EmailMessage'
 ,@SchemaName = 'sf'

exec sf.pEntitySetAddCheck
	@TableName = 'PersonEmailMessage'
 ,@SchemaName = 'sf'
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="Pass" />
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="6" Value="Pass" />
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="7" Value="Pass" />
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="8" Value="Pass" />
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="9" Value="Pass" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[
		
select
	p.PersonSID
 ,dbo.fPersonEmailMessage#PersonEmailXml(p.PersonSID)
from
	sf.Person p

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fPersonEmailMessage#PersonEmailXml'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@ON					 bit = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@currentYear int = datepart(year, sf.fNow());

	declare @selected table -- stores results of query - SID only
	(
		PersonEmailMessageSID int								not null	-- identity to track add order - preserves custom sorts
	 ,EmailMessageSID				int								not null	-- record ID joined to main entity to return results
	 ,Subject								nvarchar(max)			not null
	 ,SentTime							datetimeoffset(7) not null
	 ,OpenedTime						datetimeoffset(7) null
	 ,SentYear							int								not null
	 ,EmailAddress					nvarchar(max)			not null
	 ,IsPurged							bit								not null
	 ,PurgedTime						datetimeoffset		null
	 ,IsGenerateOnly				bit								not null
	 ,UpdateUser						nvarchar(75)			not null
	);

	insert into
		@selected
	select
		pem.PersonEmailMessageSID
	 ,pem.EmailMessageSID
	 ,pem.Subject
	 ,pem.SentTime
	 ,pem.OpenedTime
	 ,datepart(year, SentTime)
	 ,pem.EmailAddress
	 ,pem.IsPurged
	 ,pem.PurgedTime
	 ,pem.IsGenerateOnly
	 ,pem.UpdateUser
	from
		sf.vPersonEmailMessage pem
	where
		pem.PersonSID = @PersonSID and pem.Subject is not null and pem.SentTime is not null and pem.IsReadGranted = @ON;

	return
	(
		select
			isnull(r.RegistrantLabel, p.FileAsName) [@Name]
		 ,(
				select
					fld.SentYear [@Name]
				 ,(
						select
							pem.PersonEmailMessageSID [@PersonEmailMessageSID]
						 ,pem.EmailMessageSID				[@EmailMessageSID]
						 ,pem.Subject								[@Name]
						 ,pem.SentTime							[@SentTime]
						 ,pem.OpenedTime						[@OpenedTime]
						 ,pem.EmailAddress					[@EmailAddress]
						 ,pem.IsPurged							[@IsPurged]
						 ,pem.PurgedTime						[@PurgedTime]
						 ,pem.IsGenerateOnly				[@IsGenerateOnly]
						 ,pem.UpdateUser						[@UpdateUser]
						from
							@selected pem
						where
							pem.SentYear = fld.SentYear
						for xml path('Item'), type
					)
				from
					@selected fld
				where
					fld.SentYear <> @currentYear
				group by
					fld.SentYear
				for xml path('Folder'), type
			)
		 ,(
				select
					pem.PersonEmailMessageSID [@PersonEmailMessageSID]
				 ,pem.EmailMessageSID				[@EmailMessageSID]
				 ,pem.Subject								[@Name]
				 ,pem.SentTime							[@SentTime]
				 ,pem.OpenedTime						[@OpenedTime]
				 ,pem.EmailAddress					[@EmailAddress]
				 ,pem.IsPurged							[@IsPurged]
				 ,pem.PurgedTime						[@PurgedTime]
				 ,pem.IsGenerateOnly				[@IsGenerateOnly]
				 ,pem.UpdateUser						[@UpdateUser]
				from
					@selected pem
				where
					pem.SentYear = @currentYear
				for xml path('Item'), type
			)
		from
			sf.vPerson			p
		left outer join
			dbo.vRegistrant r on p.PersonSID = r.PersonSID
		where
			p.PersonSID = @PersonSID
		for xml path('RootFolder')
	);
end;
GO
