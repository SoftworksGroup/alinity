SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPersonDoc#GetNext
as
/*********************************************************************************************************************************
Sproc    : Person Document - Get Next
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns report criteria for next report to generate as a PDF and store into dbo.PersonDoc
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year	| Change Summary
				 : ------------ + ----------- +-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Mar 2018		| Initial version
				 : Kris Dawson	| Nov 2018		| Updated to include pending HTML to PDF docs
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure is called by the document generator service to return the next report to generate as a PDF.  The procedure is 
called by the middle tier perpetually to generate PDF document whenever pending reports are available.  Only the next report
to generate is returned.  When no reports require generation, the middle tier waits for a period of time (about a minute) before 
calling again.

Pending report documents must be in a PENDING status to be returned for processing. The reports are selected from the 
dbo.PersonDoc table where the ApplicationReportSID key is filled out, and both the ProcessedTime and CancelledTime columns are empty. 
An "IsPending" bit is included on the main entity view to incorporate this status however, for performance reasons, the value is 
recalculated by the select executed within this procedure.  Retrieval occurs in priority order based on the last update time - the 
oldest pending report is processed next.  A maximum of 1 record is returned by this procedure.  The record set returned will be 
empty, 0 records, if no reports are pending.

When a report is found, its processed time is automatically set to the current time in the USER timezone. If any error is detected
by the document generator service, the service must write the message into the ChangeAudit field.

The procedure returns the person document key (location to store PDF), the application report key (report to run), the entity 
key to pass to the report, and a check-sum of the XML report value when converted to a nvarchar string.  The services uses the
checksum to determine if the content of the report has changed in which case it must be re-retrieved (via a separate query).
This method allows reports to be cached by the service to speed up processing; particularly where the same report is run 
in succession across hundreds or thousands of records.

Calls during maintenance windows
--------------------------------
As the document generator service will be down during maintenance, there is no concern about checking for off-line status.  The
application can still establish requests for  report generation while the service is disabled/stopped and it will catch-up when
reactivated.

Example:
--------
<TestHarness>
	<Test Name="Set Recipient List" IsDefault="false" Description="Creates a person doc report request record, retrieves it, and
	then deletes it.">
		<SQLScript>
		<![CDATA[
		
declare
	@personSID						int
 ,@applicationReportSID int
 ,@personDocSID					int;

select top (1) @personSID	 = p.PersonSID from sf.Person p order by newid();

select
	@applicationReportSID = ar.ApplicationReportSID
from
	sf.ApplicationReport ar
where
	ar.ApplicationReportName = 'Entity Definition';

if @personSID is null or @applicationReportSID is null
begin

	raiserror('** ERROR: insufficient data to run test', 18, 1);

end;
else
begin

	exec dbo.pPersonDoc#Insert
		@PersonDocSID = @personDocSID output
	 ,@PersonSID = @personSID
	 ,@ApplicationReportSID = @applicationReportSID
	 ,@DocumentTitle = 'My Test Document'
	 ,@FileTypeSCD = '.PDF'
	 ,@ReportEntitySID = '1000001';

	exec dbo.pPersonDoc#GetNext;

	delete from dbo.PersonDoc where PersonDocSID = @personDocSID; -- clean-up after test
end;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="EmptyResultSet" ResultSet="0"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pPersonDoc#GetNext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int								= 0						-- 0 no error, if < 50000 SQL error, else business rule
	 ,@updateUser nvarchar(75)										-- service ID requesting the email (for audit)
	 ,@now				datetimeoffset(7) = sf.fNow();	-- current date in user timezone

	declare @message table (PersonDocSID int not null);

	begin try

		-- set the ID of the user for audit field

-- SQL Prompt formatting off
		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'), 75); -- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName(); -- application user - or DB user if no application session set
-- SQL Prompt formatting on

		-- avoid EF sproc to minimize potential for record lock
		-- from another service and to minimize response time

		update
			dbo.PersonDoc
		set
			ProcessedTime = @now
		 ,UpdateTime = sysdatetimeoffset()
		 ,UpdateUser = @updateUser
		output
			inserted.PersonDocSID
		into @message
		where
			PersonDocSID =
		(
			select top (1)
				pd.PersonDocSID
			from
				dbo.PersonDoc pd
			where
				(pd.ApplicationReportSID is not null or pd.DocumentHTML is not null)
			and
				pd.ProcessedTime is null
			and 
				pd.CancelledTime is null
			order by -- priority selection
				pd.UpdateTime
			 ,pd.PersonDocSID
		);

		select
			pd.PersonDocSID
		 ,pd.ApplicationReportSID
		 ,pd.ReportEntitySID
		 ,pd.DocumentHTML
		 ,pd.FileTypeSCD
		 ,checksum(cast(ar.ReportDefinition as nvarchar(max))) ReportCheckSum		-- services uses this value to check for changes to report
		from
			dbo.PersonDoc				 pd
		join
			@message						 m on pd.PersonDocSID					 = m.PersonDocSID
		left outer join
			sf.ApplicationReport ar on pd.ApplicationReportSID = ar.ApplicationReportSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
