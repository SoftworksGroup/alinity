SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantExam#GetNext
as
/*********************************************************************************************************************************
Sproc    : Registrant Exam - Get Next
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : Returns exam details for generating the next PDF for a completed exam
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year	| Change Summary
				 : ------------ + ----------- +-------------------------------------------------------------------------------------------
				 : Kris Dawson	| Apr 2019		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure is called by the client service to return the next exam to generate as a PDF.  The procedure is called by the middle
tier perpetually to generate PDF document whenever pending exams are available.  Only the next exam to generate is returned.  When 
no exams require generation, the middle tier waits for a period of time (about a minute) before calling again.

Pending exam documents must be in a PASSED or FAILED state, be an online exam, have an ExamConfiguration and ExamResponses, no
person doc context for the registrant exam that is primary and not have the ?????TODO set.

When an exam is found, its ???TODO time is automatically set to the current time in the USER timezone. If any error is detected
by the document generator service, the service must write the message into the ????TODOChangeAudit field.

The procedure returns the person document key (location to store PDF), the application report key (report to run), the entity 
key to pass to the report, and a check-sum of the XML report value when converted to a nvarchar string.  The services uses the
checksum to determine if the content of the report has changed in which case it must be re-retrieved (via a separate query).
This method allows reports to be cached by the service to speed up processing; particularly where the same report is run 
in succession across hundreds or thousands of records.

Calls during maintenance windows
--------------------------------
As the client service will be down during maintenance, there is no concern about checking for off-line status.  The application 
can still establish requests for exam generation while the service is disabled/stopped and it will catch-up when reactivated.

Example:
--------
<TestHarness>
	<Test Name="Default" IsDefault="true" Description="Begins a transaction, runs the get next sproc and then rolls back the transaction.">
		<SQLScript>
		<![CDATA[
begin transaction;

exec dbo.pRegistrantExam#GetNext

rollback transaction;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantExam#GetNext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int								= 0						-- 0 no error, if < 50000 SQL error, else business rule
	 ,@updateUser nvarchar(75)										-- service ID requesting the email (for audit)
	 ,@now				datetimeoffset(7) = sf.fNow();	-- current date in user timezone

	declare @exam table (RegistrantExamSID int not null);

	begin try

		-- set the ID of the user for audit field

-- SQL Prompt formatting off
		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'), 75); -- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName(); -- application user - or DB user if no application session set
-- SQL Prompt formatting on

		-- avoid EF sproc to minimize potential for record lock
		-- from another service and to minimize response time

		update
			dbo.RegistrantExam
		set
			ProcessedTime = @now
		 ,UpdateTime = sysdatetimeoffset()
		 ,UpdateUser = @updateUser
		output
			inserted.RegistrantExamSID
		into @exam
		where
			RegistrantExamSID =
		(
			select top (1)
				re.RegistrantExamSID
			from 
				dbo.RegistrantExam re
			join
				dbo.Exam e on re.ExamSID = e.ExamSID
			join
				dbo.ExamStatus es on re.ExamStatusSID = es.ExamStatusSID
			join
				sf.ApplicationEntity ae on ae.ApplicationEntitySCD = 'dbo.RegistrantExam'
			left outer join
				dbo.PersonDocContext pdc on pdc.EntitySID = re.RegistrantExamSID
			and
				pdc.ApplicationEntitySID = ae.ApplicationEntitySID
			and 
				pdc.IsPrimary = cast(1 as bit)
			where
				e.IsOnlineExam = cast(1 as bit)
			and
				(es.ExamStatusSCD = 'PASSED' or es.ExamStatusSCD = 'FAILED')
			and
				re.ExamConfiguration is not null
			and
				re.ExamResponses is not null
			and
				re.ProcessedTime is null
			and
				pdc.PersonDocContextSID is null
			order by -- priority selection
				re.UpdateTime
			 ,re.RegistrantExamSID
		);

		select
			 re.RegistrantExamSID
			,re.ExamSID
			,re.ExamConfiguration
			,re.ExamResponses
			,re.ExamResultDate
			,re.Score
			,re.PassingScore
			,r.PersonSID
			,r.RegistrantLabel
			,es.ExamStatusSCD
			,es.ExamStatusLabel
		from
			dbo.RegistrantExam re
		join
			@exam	e on re.RegistrantExamSID = e.RegistrantExamSID
		join
			dbo.vRegistrant r on re.RegistrantSID = r.RegistrantSID
		join
			dbo.ExamStatus es on re.ExamStatusSID = es.ExamStatusSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
