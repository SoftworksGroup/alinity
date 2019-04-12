SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pEmailMessage#SetRecipients
	@EmailMessageSID int	-- existing message - where differential is applied
as
/*********************************************************************************************************************************
Procedure : Email Message - Set Recipients 
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Inserts (sf) Person Email Message records for send processing based on recipients captured to XML column
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Redeveloped from April 2015 initial version

Comments	
--------
This procedure looks up the (sf) email message key provided and retrieves the recipients the message is to be sent to. The 
recipients are stored in the RecipientList (xml) column in the parent Email Message record. This procedure parses the XML and
inserts the required (sf) Person Email Message records which are then the targets of the email queuing and merging procedures
which populate the records with the content to be sent. 

Limitations
-----------
The procedure checks each recipient in the list for a primary email address. If someone does not have an email address
they are "silently" omitted. The procedure does not raise or log errors on individuals marked as recipients but who do not
have an email address.  This situation can be avoided by using queries for email recipient selection that either avoid 
individuals without email addresses, or, clearly identify them on the UI as ineligible and exclude them from being saved
in the RecipientList XML column.

Example
-------
<TestHarness>
	<Test Name="RandomCopy" IsDefault="true" Description="Finds existing multi-recipient email at random, copies it
	and sets recipients (rolls back transaction).">
		<SQLScript>
		<![CDATA[
		
declare @emailMessageSID int;

select top (1)
	@emailMessageSID = em.EmailMessageSID
from
	sf.vEmailMessage em
where
	em.RecipientCount > 1 -- find existing email message to copy with multiple recipients
order by
	newid();

if @@rowcount = 0 or @emailMessageSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	print 'Old EmailMessageSID: ' + ltrim(@emailMessageSID);

	insert
		sf.EmailMessage -- copy the email
	(
		SenderEmailAddress
	 ,SenderDisplayName
	 ,PriorityLevel
	 ,Subject
	 ,Body
	 ,RecipientList
	 ,IsApplicationUserRequired
	 ,ApplicationUserSID
	 ,MessageLinkSID
	 ,LinkExpiryHours
	 ,ApplicationEntitySID
	)
	select
		SenderEmailAddress
	 ,SenderDisplayName
	 ,PriorityLevel
	 ,Subject + ' TEST'
	 ,Body
	 ,RecipientList
	 ,IsApplicationUserRequired
	 ,ApplicationUserSID
	 ,MessageLinkSID
	 ,LinkExpiryHours
	 ,ApplicationEntitySID
	from
		sf.EmailMessage em
	where
		em.EmailMessageSID = @emailMessageSID;

	set @emailMessageSID = ident_current('sf.EmailMessage');

	print 'New EmailMessageSID: ' + ltrim(@emailMessageSID);

	exec sf.pEmailMessage#SetRecipients
		@EmailMessageSID = @emailMessageSID;

	select
		pem.PersonSID
	 ,em.Subject
	from
		sf.PersonEmailMessage pem
	join
		sf.EmailMessage em on pem.EmailMessageSID = em.EmailMessageSID
	where
		pem.EmailMessageSID = @emailMessageSID;

	if @@trancount > 0 and xact_state() = 1
	begin
		rollback; -- don't retain the test result
	end;

end;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:01:15" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'sf.pEmailMessage#SetRecipients'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON						 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@recipientList xml														-- xml list of all recipients
	 ,@fileTypeSCD	 varchar(50)	 = '.PDF'					-- PDF file type
	 ,@fileTypeSID	 int														-- looked up PDF file type SID
	 ,@changeAudit	 nvarchar(max);									-- one-time audit comment calculation holder

	declare @recipients table (PersonSID int not null primary key, MergeKey int not null); -- buffer for parsed recipient list

	begin try

		if @EmailMessageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@EmailMessageSID';

			raiserror(@errorText, 18, 1);

		end;

		select
			@recipientList = em.RecipientList
		from
			sf.EmailMessage em
		where
			em.EmailMessageSID = @EmailMessageSID;

		if @recipientList is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Email Message'
			 ,@Arg2 = @EmailMessageSID;

			raiserror(@errorText, 18, 1);

		end;

		select
			@fileTypeSID = ft.FileTypeSID
		from
			sf.FileType ft
		where
			ft.FileTypeSCD = @fileTypeSCD;

		if @fileTypeSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConfigurationNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
			 ,@Arg1 = 'PDF file type';

			raiserror(@errorText, 17, 1);

		end;

		set @changeAudit = sf.fChangeAudit#Comment('Created', null);

		-- parse recipients from XML into memory table

		insert
			@recipients (PersonSID, MergeKey)
		select
			field.node.value('@PersonSID', 'int') PersonSID
		 ,field.node.value('@EntitySID', 'int') MergeKey
		from
			@recipientList.nodes('//Entity') as field(node);

		-- write recipients into email message table
		-- for send processing (process as single trx)

		insert
			sf.PersonEmailMessage (EmailMessageSID, PersonSID, MergeKey, FileTypeSID, FileTypeSCD, ChangeAudit)
		select
			@EmailMessageSID
		 ,x.PersonSID
		 ,x.MergeKey
		 ,@fileTypeSID FileTypeSID
		 ,@fileTypeSCD FileTypeSCD
		 ,@changeAudit ChangeAudit
		from
			@recipients						x
		join
			sf.PersonEmailAddress pea on x.PersonSID = pea.PersonSID and pea.IsPrimary = @ON
		option (recompile);

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
