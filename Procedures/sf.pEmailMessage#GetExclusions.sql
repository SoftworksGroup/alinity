SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#GetExclusions]
	 @EmailMessageSID int                               -- email message to get recipient exclusion lists
  ,@MailingPreferenceSID int                          -- the mailing preference to check for
as
/*********************************************************************************************************************************
Sproc    : Email Message - Get Exclusions
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns people that will be excluded from the mailing based on the mailing preference passed
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Cory Ng  				| Feb 2018 	 | Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure returns all people on the mailing that will be excluded based on the passed in mailing preference. This procedure
does not modify the recipient list XML to give the user the chance to switch to a different to a different mailing preference.

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Update a mailing preference to be excluded and ensure sproc returns at least one person">
		<SQLScript>
			<![CDATA[

declare
   @mailingPreferenceSID  int
  ,@emailMessageSID       int
  ,@personSID             int

select
   @personSID = pmp.PersonSID
  ,@emailMessageSID = em.EmailMessageSID
  ,@mailingPreferenceSID = pmp.MailingPreferenceSID
from
  sf.EmailMessage em
cross apply
  em.RecipientList.nodes('//Entity') Recipient(node)
join
  sf.PersonMailingPreference pmp on pmp.PersonSID = Recipient.node.value('@PersonSID', 'int')
order by
  newid()
  
begin tran

update
  sf.PersonMailingPreference
set
  ExpiryTime = sysdatetimeoffset()
where
  PersonSID = @personSID
and
  MailingPreferenceSID = @mailingPreferenceSID

exec sf.pEmailMessage#GetExclusions
   @EmailMessageSID = @emailMessageSID
  ,@MailingPreferenceSID = @mailingPreferenceSID

rollback

			]]>
		</SQLScript>
		<Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pEmailMessage#GetExclusions'

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo	 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm varchar(50)										-- tracks name of any required parameter not passed
	 ,@ON				 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit) -- constant for bit comparison = 0

	begin try

		select
      Recipient.node.value('@PersonSID', 'int') PersonSID
    from
      sf.EmailMessage em
    cross apply
      em.RecipientList.nodes('//Entity') Recipient(node)
    left outer join
      sf.PersonMailingPreference pmp on Recipient.node.value('@PersonSID', 'int') = pmp.PersonSID 
      and sf.fIsActive(pmp.EffectiveTime, pmp.ExpiryTime) = @ON
      and pmp.MailingPreferenceSID = @MailingPreferenceSID
    where
      em.EmailMessageSID = @EmailMessageSID
    and
      pmp.PersonMailingPreferenceSID is null

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
