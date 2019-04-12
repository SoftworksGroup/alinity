SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER sf.tPersonEmailMessage
on sf.PersonEmailMessage
for insert, update
as
/*********************************************************************************************************************************
Trigger : Person Email Message
Notice  : Copyright © 2015 Softworks Group Inc.
Summary : Ensures file type SID FK value is updated for consistency whenever file type code value changes
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Tim Edlund | Feb 2017
-----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
The sf.PersonEmailMessage table includes both the FileTypeSID foreign key value and the FileTypeSCD. The code value is required to 
support full-text indexing but cannot be used as the foreign key to the sf.FileType table because of limitations in the Entity 
Framework so the FileTypeSID column is included; although redundant.

This trigger ensures that when a change to the File Type SCD value occurs, the correct File Type SID (FK) is automatically
looked up and stored into the table.  The look-up is carried out based on the code value (rather than on changes to the SID)
because file types are typically obtained from the extensions of uploaded files, or are set programmatically (e.g. in the case
of known .HTML formats such as email messages). 

Note that the trigger only applies the update if the SID value requires setting (see WHERE clause below). This is critical to 
avoid a continuous recursion since the trigger code updates the table the trigger is firing on.  

<TestHarness>
	<Test Name="Update" IsDefault="true" Description="Finds an existing record at random and changes the code of its file typem. The
	test then checks to ensure the FileTypeSID was changed by the trigger.  The logic then sets the file type back to its original
	value and checks that update as well.">
		<SQLScript>
			<![CDATA[
declare
	 @personEmailSID	int
	,@fileTypeSID1		int
	,@fileTypeSID2		int
	,@fileTypeSCD1		varchar(15)
	,@fileTypeSCD2		varchar(15)

select top (1)																															-- find a document at random to update
	 @personEmailSID	= pem.PersonEmailMessageSID
	,@fileTypeSID1		= pem.FileTypeSID
	,@fileTypeSCD1		= ft.FileTypeSCD
from
	sf.PersonEmailMessage pem
join
	sf.FileType	ft on pem.FileTypeSID = ft.FileTypeSID
order by
	newid()

select top (1)																															-- find a different file type at random
	 @fileTypeSID2 = ft.FileTypeSID
	,@fileTypeSCD2 = ft.FileTypeSCD
from
	sf.FileType ft
where
	ft.FileTypeSCD <> @fileTypeSCD1

if @personEmailSID is null or @fileTypeSID2 is null
begin

	select 
		 'FAILED'				Result
		,'NO TEST DATA'	Reason

end
else
begin

	update
		sf.PersonEmailMessage
	set
		FileTypeSCD = @fileTypeSCD2																						-- set to the new FK value
	where
		PersonEmailMessageSID = @personEmailSID

	select
		 (case when pem.FileTypeSID = @fileTypeSID2 then 'PASSED' else 'FAILED' end)	SetResult
	from
		sf.PersonEmailMessage pem
	where
		pem.PersonEmailMessageSID = @personEmailSID

	update
		sf.PersonEmailMessage
	set
		FileTypeSID = @fileTypeSCD1																						-- reset to original value
	where
		PersonEmailMessageSID = @personEmailSID

	select
		 (case when pem.FileTypeSID = @fileTypeSID1 then 'PASSED' else 'FAILED' end)	ResetResult
	from
		sf.PersonEmailMessage pem
	where
		pem.PersonEmailMessageSID = @personEmailSID

end
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" RowNo="1" ColumnNo="1" Value="PASSED"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="2" RowNo="1" ColumnNo="1" Value="PASSED"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName				= 'sf.tPersonEmailMessage'
	@DefaultTestOnly	= 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		update
			pem
		set
			pem.FileTypeSID = dt.FileTypeSID
		from
			inserted							i
		join
			sf.FileType						dt on i.FileTypeSCD						 = dt.FileTypeSCD
		join
			sf.PersonEmailMessage pem on i.PersonEmailMessageSID = pem.PersonEmailMessageSID
		where
			dt.FileTypeSID		<> pem.FileTypeSID -- avoid updating if already set - otherwise recursion!
			and pem.IsDeleted = cast(0 as bit); -- avoid if this is an update to the deletion bit

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

end;
GO
