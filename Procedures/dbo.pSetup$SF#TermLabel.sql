SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#TermLabel]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TermLabel data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.TermLabel master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund   | May 2012      | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.TermLabel table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values. Terminology labels no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			delete from sf.TermLabel
			dbcc checkident( 'sf.TermLabel', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#TermLabel
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.TermLabel

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#TermLabel'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
	
	declare
		@setup                             table
		(
			 ID														int							    identity(1,1)
			,TermLabelSCD									varchar(35)			    not null
			,DefaultLabel    							nvarchar(100)		    not null
			,UsageNotes                   nvarchar(max)       not null
		)	

	begin try

		insert 
			@setup
			(
				 TermLabelSCD	
				,DefaultLabel
				,UsageNotes
			)
		values
			-- SGI Framework component terms ...
			 ('CREATED'												,N'Created by'					,N'This label applies to a change audit record when the row is added.')
			,('UPDATED'												,N'Updated by'					,N'This label applies to a change audit record when the row is updated.')
			,('REOPENED'											,N'Re-opened by'				,N'This label applies to a change audit record when the row is re-opened.')
			,('CLEARED'												,N'Cleared by'					,N'This label applies to a change audit record when the row is cleared.')
			,('JOBSTATUS.FAILEDCLEARED'				,N'Failed (Cleared)'    ,N'Indicates the job failed but the failure status has been acknowledged or cleared so that the job no longer appears on failed job inquiries.')
			,('JOBSTATUS.FAILED'							,N'Failed!'							,N'Indicates the job terminated with an error.')
			,('JOBSTATUS.CANCELLED'						,N'Cancelled'						,N'Indicates the job was cancelled by user request.')
			,('JOBSTATUS.CANCELLATIONPENDING'	,N'Cancellation Pending',N'Indicates a request to cancel the job is pending.  Requests to cancel the job must be acted on by the job itself.  If un-responsive, job must be failed from the Job Management screen.')
			,('JOBSTATUS.COMPLETE'						,N'Complete'						,N'Indicates the job completed successfully')
			,('JOBSTATUS.INPROCESS'						,N'In Process'					,N'Indicates the job is currently running, or appears to be running because no completion time or failure was provided.')
			-- application specific terms ...
			,('NOT.ASSIGNED'									,N'Not Assigned'				,N'This label is applied in form-review scenarios where no reviews have yet been assigned.')
			,('PENDING'												,N'Pending'							,N'This label is applied in various processing scenarios where reviews or other steps are pending (in-progress)')
			,('MIXED'													,N'Mixed'								,N'This label is applied form-review scenarios where there are mixed recommendations from the reviews assigned to the form.')
			,('CONVERSION'										,N'Conversion'					,N'This label is applied to records that have been imported into Alinity through a conversion process.')
		merge
			sf.TermLabel target
		using
		(
			select
				 x.TermLabelSCD	
				,x.DefaultLabel
				,x.UsageNotes					
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
		) source
		on 
			target.TermLabelSCD = source.TermLabelSCD
		when not matched by target then
			insert 
			(
				 TermLabelSCD
				,DefaultLabel
				,UsageNotes
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.TermLabelSCD
				,source.DefaultLabel
				,source.UsageNotes
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 
				 DefaultLabel           = source.DefaultLabel
				,UsageNotes             = source.UsageNotes
				,UpdateUser							= @SetupUser
				,DefaultLabelUpdateTime = sysdatetimeoffset()
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup            
		select @targetCount = count(1) from  sf.TermLabel

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupCountTooLow'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.TermLabel'
				,@Arg3          = @targetCount

			raiserror(@errorText, 18, 1)
		end
	
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
