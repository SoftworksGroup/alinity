SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJob#Execute]
	 @CallSyntax							nvarchar(max)																	-- syntax for the job to execute
	,@JobRunSID								int																						-- key of sf.JobRun row recording events for this job
as
/*********************************************************************************************************************************
Procedure	: Job Execute
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Inserts a record into the sf.JobRun table and dynamically executes the SQL provided 
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun	2013		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is a component of the framework's job management system.  The procedure is called after a job has been read from
the queue by pJob#Receive.  This procedure receives the call syntax for the job and executes it using dynamic SQL.  The record
of the job in the sf.JobRun table has already been created and the reference to that record is provided in the @JobRunSID
parameter.

Note that the job's call syntax may include the symbol "{JobRunSID}" which will be replaced with the actual job run SID so that 
the procedure can update total records, records processed, and messaging on the sf.JobRun record as it proceeds.  The job can
mark itself complete by setting the ResultMessage and/or the IsFailed bit.  If the job does not mark itself completed, this 
procedure provides a default "ResultMessage" record.

If the job being called raises an error or an error occurs when attempting to execute the syntax, the sf.JobRun record is 
marked as having failed but no error is raised since the call is asynchronous and no UI session is monitoring messages.  Job
administrators can evaluate the progress, success and failure of jobs by using the Job Management screen in the application.

Example:
--------

exec sf.pJob#Execute
	N'select count(1) from sf.Person'
	,1000001

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@blankParm												varchar(128)												-- name of required parameter left blank
		,@termLabel												nvarchar(35)												-- label to display for initiating procedure
		,@resultMessage										nvarchar(max)												-- result message - end of job		
		
	begin try

		-- check parameters

		if @CallSyntax is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CallSyntax'

			raiserror(@errorText, 18, 1)
		end

		-- if syntax has job run key symbol, replace with the value

		if charindex(N'{JobRunSID}', @CallSyntax) > 0
		begin

			set @CallSyntax = replace(@CallSyntax, N'{JobRunSID}', ltrim(@JobRunSID))

			exec sf.pJobRun#Update
				 @JobRunSID		= @JobRunSID
				,@CallSyntax	= @CallSyntax

		end

		-- if any replacement parameters remain in the call syntax, store an error
		-- (these should have been replaced with null by sf.pJob#Call)

		if @CallSyntax like N'%{p_}%'
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'ParameterReplacementMissing'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'One or more parameters in the call syntax were not replaced.  The procedure could not be called.  Check call syntax for details.'
				,@Arg1					= '@CallSyntax'

			raiserror(@errorText, 17, 1)

		end

		-- call the job using dynamic SQL

		exec sp_executesql @stmt = @CallSyntax

		-- job is complete; if the result message is blank update it now

		if not exists
		(
			select
				1
			from
				sf.JobRun jr
			where
				jr.JobRunSID = @JobRunSID
			and
				jr.ResultMessage is not null
			and
				jr.EndTime is not null
		)
		begin

			select
				@resultMessage = isnull(tl.TermLabel, tl.DefaultLabel)
			from
				sf.TermLabel tl
			where
				tl.TermLabelSCD = 'JOBSTATUS.COMPLETE'

			if @resultMessage is null set @resultMessage = 'Complete'

			exec sf.pJobRun#Update																							-- note that when @ResultMessage is provided, the EndTime is
				 @JobRunSID				= @JobRunSID																		-- set automatically by the #Update procedure
				,@ResultMessage		= @resultMessage

		end
		
	end try

	begin catch

		-- if the job is not already marked as failed with a result message,
		-- set it to failed now

		if not exists
		(
			select
				1
			from
				sf.JobRun jr
			where
				jr.JobRunSID = @JobRunSID
			and
				jr.IsFailed = @ON
			and
				jr.ResultMessage is not null
			and
				jr.EndTime is not null				
		)
		begin

			set @resultMessage = cast(error_message() as nvarchar(max))

			exec sf.pJobRun#Update
				 @JobRunSID				= @JobRunSID
				,@IsFailed				= @ON
				,@ResultMessage		= @resultMessage

		end

	end catch

	return(@errorNo)

end
GO
