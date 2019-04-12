SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pProcessingStatus#Get
	@InProcessStatusSID int output	-- ID of message status for "INPROCESS"
 ,@ValidatedStatusSID int output	-- ID of message status for "VALIDATED"
 ,@ProcessedStatusSID int output	-- ID of message status for "PROCESSED"
 ,@ErrorStatusSID			int output	-- ID of message status for "ERROR"
 ,@JobRunSID					int = null	-- reference to sf.JobRun for async call updates
as
/*********************************************************************************************************************************
Procedure	: Processing Status - Get
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Returns processing-status key values used in staging record processing
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure is a component of the processing logic for staged data (stg). The procedure returns the key value of the common
processing status values from the sf.ProcessingStatus table.  Where a JobRun SID is provided, it also checks to ensure there is
an ID configured to run jobs in background. 

Example
-------
<TestHarness>
	<Test Name = "Default" IsDefault ="true" Description="Calls the procedure to return expected values as output parameters.">
		<SQLScript>
			<![CDATA[
declare
	@inProcessStatusSID int
 ,@validatedStatusSID int
 ,@processedStatusSID int
 ,@errorStatusSID			int
 ,@jobRunSID					int = 1000001;

exec sf.pProcessingStatus#Get
	@InProcessStatusSID = @inProcessStatusSID  output
 ,@ValidatedStatusSID = @validatedStatusSID	 output
 ,@ProcessedStatusSID = @processedStatusSID	 output
 ,@ErrorStatusSID = @errorStatusSID					 output
 ,@JobRunSID = @jobRunSID;

select
	@inProcessStatusSID InProcessStatusSID
 ,@validatedStatusSID ValidatedStatusSID
 ,@processedStatusSID ProcessedStatusSID
 ,@errorStatusSID			ErrorStatusSID;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="RowCount" ResultSet="2" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:04"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pProcessingStatus#Get'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo		int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)	-- message text (for business rule errors)    
	 ,@saUserName nvarchar(75);		-- system admin user name to login as (if not already SA)

	set @InProcessStatusSID = null; -- initialize output values
	set @ProcessedStatusSID = null;
	set @ValidatedStatusSID = null
	set @ErrorStatusSID = null;

	begin try

		-- obtain configuration settings required for processing

		select
			@InProcessStatusSID = (case when ps.ProcessingStatusSCD = 'INPROCESS' then ps.ProcessingStatusSID else @InProcessStatusSID end)
		 ,@ValidatedStatusSID = (case when ps.ProcessingStatusSCD = 'VALIDATED' then ps.ProcessingStatusSID else @ValidatedStatusSID end)
		 ,@ProcessedStatusSID = (case when ps.ProcessingStatusSCD = 'PROCESSED' then ps.ProcessingStatusSID else @ProcessedStatusSID end)
		 ,@ErrorStatusSID			= (case when ps.ProcessingStatusSCD = 'ERROR' then ps.ProcessingStatusSID else @ErrorStatusSID end)
		from
			sf.ProcessingStatus ps;

		if @InProcessStatusSID is null or @ProcessedStatusSID is null or @ErrorStatusSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConfigurationNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
			 ,@Arg1 = 'Processing Statuses';

			raiserror(@errorText, 18, 1);

		end;

		-- some operations of background processing require SA access; always run
		-- jobs as JobExec user to ensure all operations can be performed

		if @JobRunSID is not null
		begin

			select top (1)
				@saUserName = au.UserName
			from
				sf.ApplicationUser au
			where
				au.UserName = N'JobExec';

			if @saUserName is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoJobExecAccount'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A "Job Execution" account with system administrator rights could not be found to process the job. Contact the help desk for assistance to update your configuration.';

				raiserror(@errorText, 17, 1);

			end;

			exec sf.pApplicationUser#Authorize
				@UserName = @saUserName
			 ,@IPAddress = '10.0.0.1';

		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
