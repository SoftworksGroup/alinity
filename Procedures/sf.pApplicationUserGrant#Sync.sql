SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserGrant#Sync]
	 @SourceApplicationUserSID    int                                       -- pk of user who is "template" of syncing grants
  ,@TargetApplicationUserSID    int                                       -- pk of user who will receive grants from source
  ,@UpdateUser                  nvarchar(75)     = null                   -- set to current application user unless "SystemUser" passed
as
/*********************************************************************************************************************************
Sproc    : Application User Grant - Synchronize
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Synchronizes grants between user profiles
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : -------------|-------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund   | Jul		2012	| Initial Version
				 : Tim Edlund		| Dec		2012	| Updated to use datetime for effective and expiry values rather than date's
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------

This procedure is use in managing user rights.  In the UI, the administrator is able to select a target profile and a template
profile to copy grants from.  This procedure identifies differences in grants and adds and disables grants as required to make
the target profile the same as the source profile.  

Note that grants are added as required but grants that exist in the Target but not the Source profile are made inactive
by setting the expiry time to the current time.  This is done to disable the grant immediately. 


<TestHarness>
<Extensions>
--! Insert Extended Test Code Here
</Extensions>
<Test Name = "No Output" Description="Ensure that two non sys admin users permissions can be synced.">
<SQLScript>
<![CDATA[
	declare
   @sourceApplicationUserSID    int
  ,@targetApplicationUserSID    int
    
select
  @sourceApplicationUserSID = au.ApplicationUserSID
from
  sf.vApplicationUser au
where
  au.IsSysAdmin = 0
order by
  newid()

select
  @targetApplicationUserSID = au.ApplicationUserSID
from
  sf.vApplicationUser au
where
  au.IsSysAdmin = 0
and
  au.ApplicationUserSID <> @sourceApplicationUserSID
order by
  newid()

exec sf.pApplicationUserGrant#Sync
	@SourceApplicationUserSID = @sourceApplicationUserSID
 ,@TargetApplicationUserSID = @targetApplicationUserSID

]]>
</SQLScript>
<Assertions>
  <Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUserGrant#Sync'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@blankParm                         varchar(100)                      -- tracks blank values in required parameters
    ,@ON																bit = cast(1 as bit)              -- constant - to reduce re-casting
    ,@OFF																bit = cast(0 as bit)              -- constant - to reduce re-casting
    ,@changeReason											nvarchar(500)                     -- stores term used to explain change in ChangeAudit column
		,@displayName												nvarchar(75)											-- name of user who is source of synchronization
    ,@expiryTimeNotNull									dateTime													-- used for time comparison in SELECT to simplify syntax
		,@now																datetime													-- current time

	begin try

		-- check parameters

		if @SourceApplicationUserSID is null set @blankParm = '@SourceApplicationUserSID'
		if @TargetApplicationUserSID is null set @blankParm = '@TargetApplicationUserSID'

		if @blankParm is not null
		begin
			
			exec sf.pMessage#Get 
				 @MessageSCD  = 'BlankParameter'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1        = @blankParm

			raiserror(@errorText, 18, 1)
	
		end

		select
			@displayName = au.FileAsName
		from
			sf.vApplicationUser au
		where
			au.ApplicationUserSID = @SourceApplicationUserSID

    if @displayName is null
    begin

			exec sf.pMessage#Get 
				 @MessageSCD  = 'InvalidParameterNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) provided to the database procedure is invalid. A "%2" record with a key value of "%3" could not be found.'
				,@Arg1        = 'SourceApplicationUserSID'
        ,@Arg2        = 'Application User'
        ,@Arg3        = @SourceApplicationUserSID

			raiserror(@errorText, 18, 1)

    end

    if not exists( select 1 from sf.ApplicationUser where ApplicationUserSID = @TargetApplicationUserSID)
    begin

			exec sf.pMessage#Get 
				 @MessageSCD  = 'InvalidParameterNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) provided to the database procedure is invalid. A "%2" record with a key value of "%3" could not be found.'
				,@Arg1        = 'TargetApplicationUserSID'
        ,@Arg2        = 'Application User'
        ,@Arg3        = @TargetApplicationUserSID

			raiserror(@errorText, 18, 1)

    end

    if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75) -- override for "SystemUser"
    if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()       -- application user - or DB user if no application session set

    -- obtain local-language specific labels for expired, reactivated, sync, etc.
    -- obtain from the term label table (configurable for each install)

    select
      @changeReason = isnull(tl.TermLabel, tl.DefaultLabel)
    from
      sf.TermLabel tl
    where
      tl.TermLabelSCD = 'SYNC.USER'

    if @changeReason is null set @changeReason = N'Synchronized to user'

		set @changeReason = cast(@changeReason + N' "' + @displayName + '"' as nvarchar(500))

		set @now = sf.fNow()																									-- current time in user timezone

    -- disable extra grants
		-- the effective and expiry date times passed to fChangeAudit#Assignment are the current 
		-- time unless the grant is future dated; expiry cannot precede the effective date

    update
      t
    set
			 t.ExpiryTime   = (case when t.EffectiveTime > @now then t.EffectiveTime else @now end)				-- in case effective was future dated!
			,t.UpdateTime		= sysdatetimeoffset()
			,t.UpdateUser		= @UpdateUser
      ,t.ChangeAudit  = sf.fChangeAudit#Assignment
												(
													 (case when t.EffectiveTime > @now then t.EffectiveTime else @now end)
													,(case when t.EffectiveTime > @now then t.EffectiveTime else @now end)
													,@changeReason
													,t.ChangeAudit
												)
    from
      sf.ApplicationUserGrant		t
    left outer join
      sf.vApplicationUserGrant	s 
      on 
        s.ApplicationUserSID = @SourceApplicationUserSID
      and
        t.ApplicationGrantSID = s.ApplicationGrantSID  
      and
        s.IsActive = @ON
    where
      t.ApplicationUserSID = @TargetApplicationUserSID
    and
      s.ApplicationGrantSID is null

    -- enable grants that are active for the source (template), and exist 
    -- but are inactive for the target user

		set @expiryTimeNotNull = dateadd(day, 1000, getdate())

    update
      t
    set
       t.EffectiveTime	= @now
			,t.ExpiryTime			= s.ExpiryTime																		-- set expiry time to null or future date on the source row!
      ,t.ChangeAudit		= sf.fChangeAudit#Assignment(@now, s.ExpiryTime, @changeReason, t.ChangeAudit)  
			,t.UpdateTime			= sysdatetimeoffset()
			,t.UpdateUser			= @UpdateUser
    from
      sf.ApplicationUserGrant t
    join
      sf.vApplicationUserGrant s 
				on 
				t.ApplicationGrantSID = s.ApplicationGrantSID 
				and 
				s.IsActive = @ON 
				and 
				s.ApplicationUserSID = @SourceApplicationUserSID
    where
			t.ApplicationUserSID = @TargetApplicationUserSID
		and
			sf.fIsActive(t.EffectiveTime, isnull(t.ExpiryTime, @expiryTimeNotNull)) = @OFF

    -- finally, add grant records that do not exist on the target but do
    -- exist on the source (template)																																															

    insert
      sf.ApplicationUserGrant
    (
       ApplicationUserSID
      ,ApplicationGrantSID
			,EffectiveTime
			,ExpiryTime
      ,ChangeAudit
			,CreateUser
    )
    select
       @TargetApplicationUserSID
      ,s.ApplicationGrantSID
			,@now
			,s.ExpiryTime
      ,sf.fChangeAudit#Assignment(@now, s.ExpiryTime, @changeReason, null)  
			,@UpdateUser
    from
      sf.vApplicationUserGrant s
    left outer join
			sf.vApplicationUserGrant t on s.ApplicationGrantSID = t.ApplicationGrantSID and t.ApplicationUserSID = @TargetApplicationUserSID
    where
      s.ApplicationUserSID = @SourceApplicationUserSID
    and
      s.IsActive = @ON
    and
      t.ApplicationGrantSID is null

	end try

	begin catch
		exec @errorNo  = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
