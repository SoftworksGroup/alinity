SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fJobSchedule#IsStarted]()
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Job Scheduled Started
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns bit indicating whether the job schedule is running
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| July 2013		|	Initial version

Comments	
--------
This function is a component of the framework's job management system.  To understand the job and scheduling sub-system a working
knowledge of the SQL Server Service Broker technology is required.  

This function reads 3 system views to determine if the job scheduling system is operational.  The Service Broker must be enabled,
all framework queues required by the job scheduling system must be enabled, and if a service broker "conversation" initiated for 
the scheduling function must be found.  If any of these conditions are not met, the function returns 0 - indicating the job 
schedule is not operational.  

The framework's job scheduling does not use SQL Agent. Rather, the SQL Service Broker queue technology is used.  A single queue is 
used for the scheduling action, "JobScheduleQ", which manages a single conversation that, except in the case of errors, is never 
ended. If the schedule is not running, a conversation for it will not exist in sys.conversation_endpoints.

In order to kick off the scheduler the procedure sf.pJobSchedule#Start is called. In addition to initiating the scheduling
operation, it also attempts to re-enable any disabled queues. It will not, however, recreate or alter activation procedures
in the queues or enable Service Broker in the database.

The procedure sf.pJobSchedule#Stop can be called to stop the schedule.  Queues are not disabled by the #Stop procedure; only 
the schedule conversation is ended disabling the scheduling function, but leaving manual asynchronous job calling operational.

Trouble Shooting the Job Sub-System
-----------------------------------
The 4 requirements for an operational job scheduling system are described below.  Note that this function does NOT test
for condition #3.  Activation procedures are configured when queues are setup so any error in that configuration is likely 
related to a problem with a version upgrade and may indicate a wider set of problems.

1. The frameworks 3 required job queues are enabled: "is_receive_enabled" and "is enqueue_enabled" in sys.service_queues.
2. Activation is enabled. Check is_activation_enabled in sys.service_queues.
3. Activation is configured. Check activation_procedure, max_queue_readers and execute_ss_principal_id in sys.service_queues.
4. The Service Broker in the database is enabled. Check is_broker_enabled in sys.databases

Example
-------

declare 
	 @ON								bit		= cast(1 as bit)
	,@OFF								bit		= cast(0 as bit)

if sf.fJobSchedule#IsStarted() = @ON																			-- show current status of schedule
begin
	print 'Schedule is running'
	exec sf.pJobSchedule#Stop
end
else
begin
	print 'Schedule is NOT running'
	exec sf.pJobSchedule#Start
end

if sf.fJobSchedule#IsStarted() = @ON 
begin
	print 'Schedule is running'
end
else
begin
	print 'Schedule is NOT running'
	exec sf.pJobSchedule#Start																							-- leave schedule RUNNING!	
end
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @isStarted					bit																								-- return value
		,@ON								bit		= cast(1 as bit)														-- constant to eliminate redundant casting syntax
		,@OFF								bit		= cast(0 as bit)														-- constant to eliminate redundant casting syntax
		,@i									int																								-- index for iterating through required queue names
		,@queueName					nvarchar(128)																			-- next queue name to check

	set @isStarted = @ON

	if not exists																														-- ensure service broker is enabled on the database
	(
		select
			1
		from
			sys.databases sdb 
		where 
			sdb.name = db_name()
		and
			sdb.is_broker_enabled = 1
	)
	begin
		set @isStarted = @OFF
	end

	set @i = 0

	while @i < 3 and @isStarted = @ON																				-- ensure each required queue is enabled and activated
	begin

		set @i += 1

		if @i = 1 set @queueName = 'JobRequestQ'
		if @i = 2 set @queueName = 'JobProcessQ'
		if @i = 3 set @queueName = 'JobScheduleQ'
	
		if not exists
		(
			select 
				1 
			from 
				sys.service_queues sq
			where
				sq.name = @queueName
			and
				sq.is_receive_enabled = 1
			and
				sq.is_enqueue_enabled = 1
			and
				sq.is_activation_enabled = 1
		)
		begin
			set @isStarted = @OFF
		end

	end

	if @isStarted = @ON																										
	begin
		
		if not exists																													-- ensure the schedule conversation is open
			(
				select
					1
				from
					sys.conversation_endpoints ce
				where
					ce.far_service = 'JobSchedule'
				and
					ce.[state] <> 'ER'
				and
					ce.[state] <> 'CD'
				and
					ce.[state] <> 'DO'
			)
		begin
			set @isStarted = @OFF
		end

	end
	
	return(@isStarted)

end
GO
