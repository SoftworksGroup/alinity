SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pMailingPreference#ApplyMissing]
	 @ReturnSelect								bit = 1																		-- controls whether or not to return counts of updates
as
/*********************************************************************************************************************************
Procedure : Mailing Preference - Apply Missing
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Applies missing person mailing preferences records for all "auto opt-in" mailing preferences
History   : Author(s)   | Month Year | Change Summary
          : ------------|------------|-----------------------------------------------------------------------------------------
          : Cory Ng		 	| Mar	2017	 | Initial version 
						
Comments
--------
This procedure creates all missing person mailing preferences for all mailing preferences set to auto opt-in. This procedure
is called through the UI after the the IsAutoOptIn flag is changed by the user, but not automatically called to prevent all
person mailing preferences from being added because of user error in configuring the mailing preference.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

			exec sf.pMailingPreference#ApplyMissing

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:03:00" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pMailingPreference#ApplyMissing'
	,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@mailingPreferenceSID						int																	-- the next auto opt-in mailing preference to process
		,@mailingPreferenceLabel					nvarchar(35)												-- label of the mailing preference
		,@i																int																	-- loop index
		,@maxRows													int																	-- loop limiter
		,@createUser											nvarchar(75)												-- currently logged in user
		,@resultMessage										nvarchar(max)												-- buffer to hold result message of process		
		,@preferenceMessage								nvarchar(4000)											-- buffer to hold individual message for each preference
		,@CRLF														nchar(2) = char(13) + char(10)			-- carriage return
		,@assignmentCount									int																	-- the number of assignments for each mailing preference

	declare
		@work				table
	(
		 ID												int identity(1,1)
		,MailingPreferenceSID			int
		,MailingPreferenceLabel		nvarchar(35)
	)

  begin try

		set @createUser = sf.fApplicationUserSession#UserName()								-- application user - or DB user if no application session set

		insert
			@work
		(
			 MailingPreferenceSID
			,MailingPreferenceLabel
		)
		select
			 mp.MailingPreferenceSID
			,mp.MailingPreferenceLabel
		from
			sf.MailingPreference mp
		where
			mp.IsAutoOptIn = @ON

		set @maxRows = @@rowcount
		set @i = 0
		set @resultMessage = ''
		
		while @i < @maxRows
		begin

			set @i += 1

			select
				 @mailingPreferenceSID		= w.MailingPreferenceSID
				,@mailingPreferenceLabel	= w.MailingPreferenceLabel
			from
				@work w
			where
				w.ID = @i

			insert
				sf.PersonMailingPreference
			(
				 PersonSID
				,MailingPreferenceSID
				,EffectiveTime
				,ChangeAudit
				,CreateUser
				,UpdateUser
			)
			select
				 p.PersonSID
				,@mailingPreferenceSID
				,sf.fNow()
				,sf.fChangeAudit#Assignment(sf.fNow(), null, null, null)
				,@createUser
				,@createUser
			from
				sf.Person p
			left outer join
				sf.PersonMailingPreference pmp on p.PersonSID = pmp.PersonSID and pmp.MailingPreferenceSID = @mailingPreferenceSID
			where
				pmp.PersonMailingPreferenceSID is null

			set @assignmentCount = @@rowcount
			
			exec sf.pMessage#Get
				 @MessageSCD		= 'RegionMappingReassignResult'
				,@MessageText		= @preferenceMessage output
				,@DefaultText		= N'%1 missing preference(s) assigned for %2'
				,@Arg1					= @assignmentCount
				,@Arg2					= @mailingPreferenceLabel
				,@SuppressCode	= @ON

			set @resultMessage += @preferenceMessage + @CRLF

		end

		if @ReturnSelect = @ON
		begin
			select @resultMessage ResultMessage
		end
		
  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
