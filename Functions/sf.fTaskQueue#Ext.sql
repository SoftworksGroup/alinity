SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTaskQueue#Ext]
(
	 @TaskQueueSID			int								-- key of record to check
)
returns  @episode#Ext table
(
	 IsDeleteEnabled							bit							not null									-- indicates if record can be deleted
	,DeletionNote					nvarchar(1000)	null											-- description of how to enable delete if it is disabled
)
as
/*********************************************************************************************************************************
ScalarF		: Is Deleted Enabled for TaskQueue record
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns bit indicating whether the delete button should be enabled for the given TaskQueue record
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Christian T	| Mar 2013		|	Initial version

Comments	
--------
This function is used in the vTaskQueue#Ext view to determine whether or not the UI should enable the delete action on the 
given TaskQueue record.   Because the framework is designed to work independently of other schemas, this "generic" version 
of the function only checks for existence of foreign key relationships in other tables in the SF schema ONLY.  DBO and other
schemas are never considered. Within the production application relationships often exist in DBO and other schemas to the 
sf.ApplicationUser record and therefore this function typically requires an override be executed in the post deployment script 
of the application.

Task Queue deletion should disabled if:
-User is not a SysAdmin.
-Task queue has tasks that have a task status of pending or overdue.

Do not reference the #ext or entity view in the logic of this function.  Doing so will create a circular dependency reference
and deployment tools will fail!

Example
-------

select 
	  x.*
from
	sf.TaskQueue x
cross apply
	sf.fTaskQueue#Ext(x.TaskQueueSID)				
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @isDeleteEnabled												bit														-- return value
		,@ON																		bit		= cast(1 as bit)				-- constant to eliminate redundant casting syntax
		,@OFF																		bit		= cast(0 as bit)				-- constant to eliminate redundant casting syntax
		,@deletionNote									nvarchar(1000)								-- instructions on how to enable deletion if disabled
		,@statusPendingText											nvarchar(50)									-- user viewed label for the task status
		,@statusOverdueText											nvarchar(50)									-- user viewed label for the task status

	set @isDeleteEnabled = sf.fIsSysAdmin()																	-- must be SA to delete these records

	if(@isDeleteEnabled = @OFF)
	begin

		set @deletionNote =		N'Only system administrators are authorized to perform this action. Contact a system administrator if you need to perform this operation.'

	end
	else if @isDeleteEnabled = @ON																					-- disallow if TaskQueue has a Task that is pending or overdue
	and exists
	(
		select
			1
		from
			sf.TaskQueue tq
		join 
			sf.TaskTrigger tt on tq.TaskQueueSID = tt.TaskQueueSID
		left join 
			sf.Task t on tt.TaskTriggerSID = t.TaskTriggerSID or t.TaskQueueSID = tt.TaskQueueSID
		join
			sf.TaskStatus ts on t.TaskStatusSID = ts.TaskStatusSID 
			and 
			(ts.TaskStatusSCD = 'PENDING' or ts.TaskStatusSCD = 'OVERDUE')
		where
			tq.TaskQueueSID = @TaskQueueSID
	)
	begin
		set @isDeleteEnabled = @OFF

		select																																--get labels for status code values
			 @statusPendingText = (case when ts.TaskStatusSCD = 'PENDING' then ts.TaskStatusLabel else @statusPendingText end)
			,@statusOverdueText = (case when ts.TaskStatusSCD = 'OVERDUE' then ts.TaskStatusLabel else @statusOverdueText end)
		from 
			sf.TaskStatus ts
		where 
			(ts.TaskStatusSCD = 'PENDING' or ts.TaskStatusSCD = 'OVERDUE')


			set @deletionNote = cast(sf.fFormatString( N'This queue has tasks that are marked as {0} or {1}. Complete (or cancel) open tasks before deleting the task queue.', @statusPendingText + ',' + @statusOverdueText) as nvarchar(1000))

	end	

	if @isDeleteEnabled = @ON 
	and exists
	(
		select
			1
		from
			sf.TaskTrigger tt
		where
			tt.TaskQueueSID = @TaskQueueSID
	)
	begin

		set @isDeleteEnabled = @OFF
		set @deletionNote = N'This task queue has triggers defined for it.  Delete/move triggers before deleting the task queue.'

	end
	
	insert 
		@episode#Ext
		(
			 IsDeleteEnabled
			,DeletionNote
		)
	select 
		 @isDeleteEnabled
		,@deletionNote
		
	return

end
GO
