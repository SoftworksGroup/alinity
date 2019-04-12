SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#SetTaskQueues]
(
	 @ApplicationUserSID          int                                       -- application user to set Queue subscriptions for
	,@TaskQueues									XML                                       -- xml of changes to apply - see required format below
	,@ChangeReason                nvarchar(4000)			= null                  -- reason text to incorporate into audit column
	,@EffectiveTime               datetime					= null									-- time change(s) take effect - defaults to now
)   
as
/*********************************************************************************************************************************
Procedure : Application User - Set Queues
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Sets Application User Grant table values to match settings (on/off on Queues) provided as XML
History   : Author(s)			| Month Year  | Change Summary
					: --------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund		| Jul 	2012  | Initial version
					: Tim Edlund		| Nov		2012	|	Updated to allow ChangeReason to be null and reduced repetitive casting on bits
					: Tim Edlund		| Dec		2012	| Updated to use datetimeoffset as parameters for EffectiveTime
					: Tim Edlund		| Jun		2017	| Updated to remove references to instead of triggers
 
Comments  
--------
This procedure is used to support updating Task Queue Subscribers from the user interface.  The procedure accepts an XML document 
that identifies the change status of subscriptions for the given user.  The source of this information is typically provided by
sf.pApplicationUser#GetTaskQueues. After the user has updated the task queue subscriptions in the UI, this procedure is called to 
write the changes back to the database.

An XML format including the key node and attributes identified below (additional information may be included)

<TaskQueues>
	<TaskQueue TaskQueueSID="1000010" SubscriptionIsActiveNew="0"/>					-- email preferences are omitted from this example!
	<TaskQueue TaskQueueSID="1000004" SubscriptionIsActiveNew="1"/>
	<TaskQueue TaskQueueSID="1000017" SubscriptionIsActiveNew="1"/>
 ...
</TaskQueues> 

The procedure uses the system ID, a look up of that ID against the child table, and the setting of the SubscriptionIsActiveNew 
bit to determine whether or not a subscription needs to be inserted, expired, or re-activated. See case logic below.

The procedure providing data for the UI - the "#Get" sproc - includes values identifying the previous status of of each 
subscription; whether it existed or not, active status, etc. That information is not used if passed.  The information is looked 
up again during processing to ensure the latest values are considered where they were modified, by another user, since there were 
provided to the UI.

Example:
--------
This procedure is very complex to test from the back-end. Running the process from the UI for testing is recommended.

declare                                                                   -- select an application user at random
	@applicationUserSID     int
 ,@TaskQueues							xml
 
set @TaskQueues = 
N'<TaskQueues>
	<TaskQueue TaskQueueSID="1000001" SubscriptionIsActiveNew="0"/>					-- additional columns for email preferences not shown
	<TaskQueue TaskQueueSID="1000002" SubscriptionIsActiveNew="1"/>
	<TaskQueue TaskQueueSID="1000003" SubscriptionIsActiveNew="1"/>
</TaskQueues>' 

select top (1)
	@applicationUserSID = au.ApplicationUserSID
from
	sf.ApplicationUser au
order by 
	newid()

exec sf.pApplicationUser#SetTaskQueues
	 @ApplicationUserSID	= @applicationUserSID
	,@ChangeReason				= N'This is a test!'
	,@TaskQueues					= @TaskQueues

-------------------------------------------------------------------------------------------------------------------------------- */
 
set nocount on
 
begin
 
	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided     
		,@ON															bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF															bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts   
		,@maxRows                         int                                 -- loop limit - rows to process
		,@i                               int                                 -- loop index
		,@TaskQueueSID										int                                 -- next Task Queue to process
		,@isActiveNew                     bit                                 -- next subscription status to process
		,@isDailySummaryEmailedNew				bit																	-- new setting for email frequency preference
		,@isNewTaskEmailedNew							bit																	-- new setting for whether email sent on new task assignment
		,@TaskQueueSubscriberSID					int                                 -- next user subscription to update - null if does not exist
		,@isActiveOld                     bit                                 -- current subscription status if assignment exists
		,@isDailySummaryEmailedOld				bit																	-- old setting for email frequency preference
		,@isNewTaskEmailedOld							bit																	-- old setting for whether email sent on new task assignment			
		,@isPending												bit																	-- indicates subscription is pending (future dated and not canceled)
		,@expiryTime											datetime														-- time to expiry the subscription (when de-activating on update)

	declare
		@work                             table
		(
			 ID                             int     identity(1,1)
			,TaskQueueSID										int     not null
			,SubscriptionIsActiveNew        bit     not null
			,IsDailySummaryEmailed					bit     not null
			,IsNewTaskEmailed								bit     not null
		)
		
	begin try
	
		-- check parameters

		if @ApplicationUserSID  is null set @blankParm = 'ApplicationUserSID'
		if @TaskQueues					is null set @blankParm = 'TaskQueues'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end   
		
		if not exists( select 1 from sf.ApplicationUser where ApplicationUserSID = @ApplicationUserSID)
		begin

			exec sf.pMessage#Get 
				 @MessageSCD  = 'ParameterNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) provided to the database procedure is invalid. A(n) "%2" record with a key value of "%3" could not be found.'
				,@Arg1        = 'ApplicationUserSID'
				,@Arg2        = 'ApplicationUser'
				,@Arg3        = @ApplicationUserSID

			raiserror(@errorText, 18, 1)

		end

		-- parse the XML and write values to a work table for processing
		
		insert
			@work
		(
			 TaskQueueSID
			,SubscriptionIsActiveNew
			,IsDailySummaryEmailed
			,IsNewTaskEmailed
		)
		select
			 TaskQueues.tq.value('@TaskQueueSID[1]', 'int')													TaskQueueSID
			,TaskQueues.tq.value('@SubscriptionIsActiveNew[1]', 'bit')							SubscriptionIsActiveNew
			,isnull(TaskQueues.tq.value('@IsDailySummaryEmailed[1]', 'bit'), @OFF)  IsDailySummaryEmailed
			,isnull(TaskQueues.tq.value('@IsNewTaskEmailed[1]', 'bit'), @OFF)				IsNewTaskEmailed
		from
			@TaskQueues.nodes('//TaskQueue') as TaskQueues(tq)  

		set @maxRows = @@rowcount
		set @i       = 0

		if @maxRows = 0
		begin

			exec sf.pMessage#Get 
				 @MessageSCD  = 'NoXMLContent'
				,@MessageText = @errorText output
				,@DefaultText = N'No content was found in the XML document provided. The node searched was "%1".'
				,@Arg1        = '//TaskQueue'

			raiserror(@errorText, 18, 1)

		end

		-- these updates cannot be backdated - set the effective time to the current
		-- time adjusted for user timezone if null or backdated

		set @EffectiveTime = sf.fNow()

		begin transaction                                                     -- all transactions succeed or all are rolled back

		while @i < @maxRows
		begin

			set @i += 1

			select                                                              -- initialize variables for next row to process
				 @TaskQueueSID							= null
				,@isActiveNew               = null
				,@TaskQueueSubscriberSID		= null
				,@isActiveOld               = null
				,@isPending									= null

			select  
				 @TaskQueueSID							= w.TaskQueueSID											-- obtain values required for update logic
				,@isActiveNew               = w.SubscriptionIsActiveNew
				,@isDailySummaryEmailedNew	= w.IsDailySummaryEmailed
				,@isNewTaskEmailedNew				= w.IsNewTaskEmailed
				,@TaskQueueSubscriberSID		= tqs.TaskQueueSubscriberSID
				,@isActiveOld               = tqs.IsActive
				,@isPending									= tqs.IsPending
				,@isDailySummaryEmailedOld	= tqs.IsDailySummaryEmailed
				,@isNewTaskEmailedOld				= tqs.IsNewTaskEmailed
				,@expiryTime								= (case when tqs.EffectiveTime > @EffectiveTime then tqs.EffectiveTime else @EffectiveTime end)
			from
				@work w
			left outer join
				sf.vTaskQueueSubscriber tqs
				on 
					w.TaskQueueSID = tqs.TaskQueueSID 
					and 
					tqs.ApplicationUserSID = @ApplicationUserSID
			where
				w.ID = @i

			if @TaskQueueSubscriberSID is null and @isActiveNew = @ON						-- record does not exist and bit is on - insert it
			begin

				exec sf.pTaskQueueSubscriber#Insert
						@ApplicationUserSID				= @ApplicationUserSID				
					,	@TaskQueueSID							= @TaskQueueSID
					,	@EffectiveTime						= @EffectiveTime										-- may be future dated so don't use current time
					, @IsNewTaskEmailed					= @isNewTaskEmailedNew
					,	@ChangeReason							= @ChangeReason
			
			end
			else if @TaskQueueSubscriberSID is not null and @isActiveOld = @ON and @isActiveNew = @OFF		-- existing assignment is being expired
			begin

				exec sf.pTaskQueueSubscriber#Update																-- don't alter the email preferences since this is being expired
						@TaskQueueSubscriberSID = @TaskQueueSubscriberSID
					,	@ChangeReason						= @ChangeReason
					, @ExpiryTime							= @expiryTime
					,	@IsReselected						= @OFF

			end
			else if @TaskQueueSubscriberSID is not null																										-- existing subscription
			and 
			(
			(@isActiveOld = @OFF and @isActiveNew = @ON)																									-- is being re-activated
			or
			sf.fIsDifferent(@isDailySummaryEmailedNew, @isDailySummaryEmailedOld) = @ON										-- or summary email preference is changing
			or
			sf.fIsDifferent(@isNewTaskEmailedNew, @isNewTaskEmailedOld) = @ON															-- or new task email preference is changing
			)
			begin

				exec sf.pTaskQueueSubscriber#Update																
						@TaskQueueSubscriberSID = @TaskQueueSubscriberSID
					,	@ChangeReason						= @ChangeReason
					,	@EffectiveTime					= @EffectiveTime											
					, @ExpiryTime							= null
					, @IsNewTaskEmailed				= @isNewTaskEmailedNew
					,	@IsReselected						= @OFF

			end

		end

		commit

	end try
 
	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch
 
	return(@errorNo)
 
end
GO
