SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ProcessingStatus]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ProcessingStatus data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.ProcessingStatus master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| June 2014			| Initial Version
				 : Richard K		| April 2015		| Updated to avoid overwriting user changes to ProcessingStatusLabel, UsageNotes
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.ProcessingStatus table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is updated to the column values for the current version of the 
application. Processing statuses no longer used are deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="SyncMaster" IsDefault="true" Description="Runs the setup procedure and returns a result set containing the master 
	table contents.">
		<SQLScript>
			<![CDATA[
			
exec dbo.pSetup$SF#ProcessingStatus
	@SetupUser  = 'system@softworksgroup.com'
 ,@Language   = 'EN'
 ,@Region     = 'AB'
	
select * from sf.ProcessingStatus
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet ="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute @ObjectName = 'dbo.pSetup$SF#ProcessingStatus'	-- run test with unit test method

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for boolean comparisons
	
	declare
		@setup                             table
		(
			 ID															int							    identity(1,1)
			,ProcessingStatusSCD						varchar(10)					not null
			,ProcessingStatusLabel					nvarchar(35)				not null
			,UsageNotes											nvarchar(max)				null
			,IsClosedStatus									bit									not null
			,IsDefault											bit									not null
		)	

	begin try

		insert 
			@setup
			(
				 ProcessingStatusSCD	
				,ProcessingStatusLabel
				,UsageNotes							
				,IsClosedStatus					
				,IsDefault							
			)
		values
			 ('NEW'				,N'New (no validation)' ,N'This status indicates that the record is ready for verification but no validation or processing has occurred yet.', @OFF, @ON)
			,('INPROCESS'	,N'In-Process'					,N'Indicates the record is currently being processed (locks the record to ensure no other changes are applied during processing).', @OFF, @OFF)
			,('VALIDATED'	,N'Validated'						,N'Indicates the record has been successfully validated but has not been processed (optional status used in "VALIDATE.ONLY" scenarios).', @OFF, @OFF)
			,('PROCESSED'	,N'Processed'						,N'This status indicates that the record was processed successfully. It is possible to process records where warnings are detected and the warning message is retained in the record.', @ON, @OFF)
			,('ERROR'			,N'Error'								,N'This status indicates that one or more error conditions were detected on the record during validation. Records with errors cannot be processed. If an error cannot be resolved, mark the record "CANCELLED" to remove it from further processing.', @OFF, @OFF)
			,('CANCELLED' ,N'Cancelled'						,N'This status indicates that the record was removed from the list of records to be processed.  If an error cannot be resolved, use this status to remove the record from the incomplete list.', @ON, @OFF)
			,('HELD'			,N'Held'								,N'This status indicates that the message was removed from the list of records to be processed but was not cancelled. Use this status to temporarily avoid processing a record.', @OFF, @OFF)
		merge
			sf.ProcessingStatus target
		using
		(
			select
				 x.ProcessingStatusSCD	
				,x.ProcessingStatusLabel
				,x.UsageNotes    
				,x.IsClosedStatus
				,x.IsDefault			
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
		) source
		on 
			target.ProcessingStatusSCD = source.ProcessingStatusSCD
		when not matched by target then
			insert 
			(
				 ProcessingStatusSCD	
				,ProcessingStatusLabel
				,UsageNotes    
				,IsClosedStatus	
				,IsDefault
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.ProcessingStatusSCD	
				,source.ProcessingStatusLabel
				,source.UsageNotes    
				,source.IsClosedStatus	
				,source.IsDefault
				,@SetupUser
				,@SetupUser
			)
		 when matched then
			update 
				set   
				IsClosedStatus					= source.IsClosedStatus
				,IsDefault							= source.IsDefault
				,UsageNotes							= source.UsageNotes
				,UpdateUser							= @SetupUser
		when not matched by source then
			delete
		;
	
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
