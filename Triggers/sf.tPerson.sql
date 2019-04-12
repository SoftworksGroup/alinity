SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [sf].[tPerson]
	on [sf].[Person]
	for insert
as
/*********************************************************************************************************************************
Trigger : Person
Notice  : Copyright © 2017 Softworks Group Inc.
Summary : Ensures auto opt-in mailing preferences are assigned to newly inserted people
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Cory Ng | Mar 2017
-----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This trigger adds all "auto opt-in" mailing preferences when a new person is added.

<TestHarness>
	<Test Name="Insert" IsDefault="true" Description="Insert a ">
		<SQLScript>
			<![CDATA[

declare
	 @genderSID	int
	,@personSID int

select
	@genderSID = g.GenderSID
from
	sf.Gender g
where
	g.GenderSCD = 'M'

begin transaction

	exec sf.pPerson#Insert 
		 @PersonSID	= @personSID output
		,@FirstName = 'Billy'
		,@LastName	= 'Joel'
		,@GenderSID = @genderSID

	select
		 pmp.PersonMailingPreferenceSID
	from
		sf.PersonMailingPreference pmp
	where
		pmp.PersonSID = @personSID

rollback

]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName				= 'sf.tPerson'
	,@DefaultTestOnly	= 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo            int = 0																					-- 0 no error, <50000 SQL error, else business rule
		,@errorText          nvarchar(4000)																		-- message text (for business rule errors)
		,@ON								 bit = cast(1 as bit)															-- used on bit comparisons to avoid multiple casts

	begin try

		insert
			sf.PersonMailingPreference
		(
			 PersonSID
			,MailingPreferenceSID
			,EffectiveTime
			,ChangeAudit
			,CreateUser
			,UpdateUser
		)
		select
			 i.PersonSID
			,mp.MailingPreferenceSID
			,sf.fNow()
			,sf.fChangeAudit#Assignment(sf.fNow(), null, null, null)
			,i.CreateUser
			,i.CreateUser
		from
			inserted i
		cross join
			sf.MailingPreference mp
		where
			mp.IsAutoOptIn = @ON

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

end
GO
