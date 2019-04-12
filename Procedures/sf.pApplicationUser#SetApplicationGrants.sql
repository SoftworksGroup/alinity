SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#SetApplicationGrants]
(
	 @ApplicationUserSID          int                                       -- application user to set grants for
	,@ApplicationGrants           XML                                       -- xml of changes to apply - see required format below
	,@ChangeReason                nvarchar(4000)		= null                  -- reason text to incorporate into audit column
	,@EffectiveTime               datetime					= null									-- time change(s) take effect - defaults to now
)   
as
/*********************************************************************************************************************************
Procedure : Application User - Set Grants
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Sets Application User Grant table values to match settings (on/off on grants) provided as XML
History   : Author(s)			| Month Year  | Change Summary
					: --------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund		| Jul 	2012  | Initial version
					: Tim Edlund		| Nov		2012	|	Updated to allow ChangeReason to be null and reduced repetitive casting on bits
					: Tim Edlund		| Jun		2017	| Updated to remove references to instead of triggers
					: Cory Ng				| Feb		2018	| Updated to fix bug when re-activating grant to pass IsNullApplied to API sproc so expiry
																				| time doesn't get reselected
 
Comments  
--------
This procedure is used to support updating Application User Grants in the user interface.  The procedure accepts an XML document 
that identifies the change status of grants for the given user.  The source of this information is typically provided by
sf.pApplicationUser#GetGrants.  After the user has updated the grants in the UI, this procedure is called to write the changes
back to the database.

An XML format including the key node and attributes identified below (additional information may be included)

<ApplicationGrants>
	<ApplicationGrant ApplicationGrantSID="1000010" IsActiveNew="0"/>
	<ApplicationGrant ApplicationGrantSID="1000004" IsActiveNew="1"/>
	<ApplicationGrant ApplicationGrantSID="1000017" IsActiveNew="1"/>
 ...
</ApplicationGrants> 

The procedure uses the system ID, a look up of that ID against the child table, and the setting of the IsActiveNew bit 
to determine whether or not a grant/assignment needs to be inserted, expired, or re-activated. See case logic
below.

The procedure providing data for the UI - the "#Get" sproc - included values identifying the previous status of 
of each grant/assignment; whether it existed or not, active status, etc. That information is not used if passed.  
The information is looked up again during processing to ensure the latest values are considered where they were 
modified, by another user, since there were provided to the UI.

Example:
--------
This procedure is very complex to test from the back-end. Running the process from the UI for testing is recommended.

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Selects a user at random and set their grants">
		<SQLScript>
			<![CDATA[

				declare                                                                   -- select an application user at random
					@applicationUserSID     int
				 ,@ApplicationGrants  xml
 
				set @ApplicationGrants = 
				N'<ApplicationGrants>
					<ApplicationGrant ApplicationGrantSID="1000001" IsActiveNew="0"/>
					<ApplicationGrant ApplicationGrantSID="1000002" IsActiveNew="1"/>
					<ApplicationGrant ApplicationGrantSID="1000003" IsActiveNew="1"/>
				</ApplicationGrants>' 

				select top (1)
					@applicationUserSID = au.ApplicationUserSID
				from
					sf.ApplicationUser au
				order by 
					newid()

				exec sf.pApplicationUser#SetApplicationGrants
					 @ApplicationUserSID	= @applicationUserSID
					,@ChangeReason				= N'This is a test!'
					,@ApplicationGrants		= @ApplicationGrants
 
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#SetApplicationGrants'


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
		,@applicationGrantSID             int                                 -- next application grant to process
		,@isActiveNew                     bit                                 -- next grant status to process
		,@applicationUserGrantSID         int                                 -- next user grant to update - null if does not exist
		,@isActiveOld                     bit                                 -- current grant status if assignment exists
		,@isPending												bit																	-- indicates grant is pending (future dated and not canceled)
		,@expiryTime											datetime														-- end of term for updating grants

	declare
		@work                             table
		(
			 ID                             int     identity(1,1)
			,ApplicationGrantSID            int     not null
			,IsActiveNew                    bit     not null
		)
		
	begin try
	
		-- check parameters

		if @ApplicationUserSID    is null set @blankParm = 'ApplicationUserSID'
		if @ApplicationGrants     is null set @blankParm = 'ApplicationGrants'

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
			 ApplicationGrantSID
			,IsActiveNew
		)
		select
			 ApplicationGrants.aug.value('@ApplicationGrantSID[1]'    , 'int')  ApplicationGrantSID
			,ApplicationGrants.aug.value('@IsActiveNew[1]'            , 'bit')  IsActiveNew
		from
			@ApplicationGrants.nodes('//ApplicationGrant') as ApplicationGrants(aug)  

		set @maxRows = @@rowcount
		set @i       = 0

		if @maxRows = 0
		begin

			exec sf.pMessage#Get 
				 @MessageSCD  = 'NoXMLContent'
				,@MessageText = @errorText output
				,@DefaultText = N'No content was found in the XML document provided. The node searched was "%1".'
				,@Arg1        = '//ApplicationGrant'

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
				 @applicationGrantSID       = null
				,@isActiveNew               = null
				,@applicationUserGrantSID   = null
				,@isActiveOld               = null
				,@isPending									= null

			select  
				 @applicationGrantSID       = w.ApplicationGrantSID               -- obtain values required for update logic
				,@isActiveNew               = w.IsActiveNew
				,@applicationUserGrantSID   = aug.ApplicationUserGrantSID
				,@isActiveOld               = aug.IsActive
				,@isPending									= aug.IsPending
				,@expiryTime								= (case when aug.EffectiveTime > @EffectiveTime then EffectiveTime else @EffectiveTime end)
			from
				@work w
			left outer join
				sf.vApplicationUserGrant aug 
				on 
					w.ApplicationGrantSID = aug.ApplicationGrantSID 
					and 
					aug.ApplicationUserSID = @ApplicationUserSID
			where
				w.ID = @i

			if @applicationUserGrantSID is null and @isActiveNew = @ON					-- record does not exist and bit is on - insert it
			begin

				exec sf.pApplicationUserGrant#Insert
						@ApplicationUserSID		= @ApplicationUserSID
					,	@ApplicationGrantSID	= @applicationGrantSID
					,	@EffectiveTime				= @EffectiveTime												-- grant may be future dates so don't use current time
					,	@ChangeReason					= @ChangeReason												
				
			end
			else if @applicationUserGrantSID is not null and @isActiveOld = @ON and @isActiveNew = @OFF		-- existing assignment is being expired
			begin

				exec sf.pApplicationUserGrant#Update
						@ApplicationUserGrantSID	= @applicationUserGrantSID
					,	@ChangeReason							= @ChangeReason
					,	@ExpiryTime								= @expiryTime												-- calculated in SELECT above
					,	@IsReselected							= @OFF

			end
			else if @applicationUserGrantSID is not null and @isActiveOld = @OFF and @isActiveNew = @ON   -- existing grant is being re-activated
			begin
      
				exec sf.pApplicationUserGrant#Update
						@ApplicationUserGrantSID	= @applicationUserGrantSID
          , @ApplicationUserSID       = @ApplicationUserSID
          , @ApplicationGrantSID      = @applicationGrantSID
					,	@ChangeReason							= @ChangeReason
					,	@EffectiveTime						= @EffectiveTime
					,	@ExpiryTime								= null
					,	@IsReselected							= @OFF
          , @IsNullApplied            = @ON

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
