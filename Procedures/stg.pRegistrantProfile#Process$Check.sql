SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stg.[pRegistrantProfile#Process$Check]
	@RegistrantProfileSID		 int = null -- if single row processed, key of the profile record		
 ,@JobRunSID							 int = null -- reference to sf.JobRun for async call updates
 ,@InProcessStatusSID			 int output -- ID of message status for "INPROCESS"
 ,@ValidatedStatusSID			 int output -- ID of message status for "VALIDATED"
 ,@ProcessedStatusSID			 int output -- ID of message status for "PROCESSED"
 ,@ErrorStatusSID					 int output -- ID of message status for "ERROR"
 ,@DefaultCountrySID			 int output -- required to auto-add state-province if not directly provided
 ,@DefaultStateProvinceSID int output -- required to auto-add city if not directly provided
 ,@ApplicationGrantSID1		 int output -- key of application grant for: member portal base
 ,@ApplicationGrantSID2		 int output -- key of application grant for: applicant/registrant
as
/*********************************************************************************************************************************
Procedure	: Registrant Profile Process - Check 
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Subroutine to check configuration and return required configuration values for processing of staging records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure is a component of the processing logic for Registrant Profiles. The procedure checks to ensure required 
configuration settings are in place and raises an error if they are not found. Otherwise, the configuration values are returned as 
output variables.  

See also parent procedure for overview documentation and test harness.
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo		int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)									-- message text (for business rule errors)    
	 ,@ON					bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts

	set @InProcessStatusSID = null; -- initialize output values
	set @ProcessedStatusSID = null;
	set @ValidatedStatusSID = null
	set @ErrorStatusSID = null;
	set @DefaultCountrySID = null;
	set @DefaultStateProvinceSID = null;

	begin try

		-- if a specific records was passed into the parent, ensure it is valid

		if @RegistrantProfileSID is not null
		begin

			if not exists
			(
				select
					1
				from
					stg.RegistrantProfile x
				where
					x.RegistrantProfileSID = @RegistrantProfileSID
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'registrant profile (staging)'
				 ,@Arg2 = @RegistrantProfileSID;

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
		 ,@JobRunSID = @JobRunSID
		
		-- lookup defaults for country and state province (not mandatory)

		select
			@DefaultCountrySID = ctry.CountrySID
		from
			dbo.Country ctry
		where
			ctry.IsDefault = @ON;

		if @DefaultCountrySID is not null
		begin

			select
				@DefaultStateProvinceSID = sp.StateProvinceSID
			from
				dbo.StateProvince sp
			where
				sp.CountrySID = @DefaultCountrySID and sp.IsDefault = @ON;

		end;

		-- lookup required default grants for member records

		select
			@ApplicationGrantSID1 = ag.ApplicationGrantSID
		from
			sf.ApplicationGrant ag
		where
			ag.ApplicationGrantSCD = 'EXTERNAL.BASE';

		if @ApplicationGrantSID1 is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'User Grant'
			 ,@Arg2 = 'EXTERNAL.BASE';

			raiserror(@errorText, 18, 1);
		end;

		select
			@ApplicationGrantSID2 = ag.ApplicationGrantSID
		from
			sf.ApplicationGrant ag
		where
			ag.ApplicationGrantSCD = 'EXTERNAL.REGISTRANT';

		if @ApplicationGrantSID2 is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'User Grant'
			 ,@Arg2 = 'EXTERNAL.Registrant';

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
