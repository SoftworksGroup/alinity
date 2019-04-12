SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stg.[pRegistrantExamProfile#Process$Check]
	@RegistrantExamProfileSID int = null	-- if single row processed, key of the profile record		
 ,@JobRunSID								int = null	-- reference to sf.JobRun for async call updates
 ,@InProcessStatusSID				int output	-- ID of message status for "INPROCESS"
 ,@ValidatedStatusSID				int output	-- ID of message status for "VALIDATED"
 ,@ProcessedStatusSID				int output	-- ID of message status for "PROCESSED"
 ,@ErrorStatusSID						int output	-- ID of message status for "ERROR"
as

/*********************************************************************************************************************************
Procedure	: Registrant Exam Profile Process - Check 
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Subroutine to check configuration and return required configuration values for processing of staging records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure is a component of the processing logic for Registrant Exam Profiles. The procedure checks to ensure required 
configuration settings are in place and raises an error if they are not found. Otherwise, the configuration values are returned as 
output variables.  

See also parent procedure for overview documentation and test harness.
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo	 int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000);	-- message text (for business rule errors)    

	set @InProcessStatusSID = null; -- initialize output values
	set @ProcessedStatusSID = null;
	set @ValidatedStatusSID = null
	set @ErrorStatusSID = null;

	begin try

		-- if a specific records was passed into the parent, ensure it is valid

		if @RegistrantExamProfileSID is not null
		begin

			if not exists
			(
				select
					1
				from
					stg.RegistrantExamProfile x
				where
					x.RegistrantExamProfileSID = @RegistrantExamProfileSID
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'registrant exam profile (staging)'
				 ,@Arg2 = @RegistrantExamProfileSID;

				raiserror(@errorText, 18, 1);

			end;

		end;

		-- call a subroutine to lookup up
		-- required statuses and check job run

		exec sf.pProcessingStatus#Get
			@InProcessStatusSID = @InProcessStatusSID output
		 ,@ValidatedStatusSID = @ValidatedStatusSID output
		 ,@ProcessedStatusSID = @ProcessedStatusSID output
		 ,@ErrorStatusSID = @ErrorStatusSID output
		 ,@JobRunSID = @JobRunSID;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
