SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pAnnouncement#GetLoginAlert]
	@ForUpdate				bit				= 0													-- when 1, returns a default row if an active announcement is not found
as
/*********************************************************************************************************************************
Procedure : Get login alert (announcement)
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Returns the latest active login alert announcement if any - may return default record for editing
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Mar	2015		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is invoked from the UI in 2 situations:

1) To return the most recent login alert announcement for display to the user
2) To return the most recent login alert for editing if one exists, or to return a default record for editing

The procedure searches for an announcement where the Is-Login-Alert bit is set ON and which is not expireed. If one is found
it is returned.  Otherwise, a default row is only returned if the @ForUpdate parameter is passed as 1.  If the @ForUpdate
parameter is passed as 0 and no active login alert exists, then an empty result set is returned.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Creates a new announcement alert and then updates it.">
		<SQLScript>
			<![CDATA[
declare
	@announcementSID int

exec sf.pAnnouncement#UpsertLoginAlert
	 @AnnouncementSID    = @announcementSID output
	,@Title              = N'Test login alert title text'
	,@Body               = N'Test login alert body text. Test login alert body text. Test login alert body text.'
	,@IsReselected       = 1

exec sf.pAnnouncement#UpsertLoginAlert
	 @Title              = N'Test login alert title text UPDATED'
	,@Body               = N'Test login alert body text UPDATED. Test login alert body text UPDATED.'
	,@IsReselected       = 1			
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pAnnouncement#UpsertLoginAlert'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@errorNo                         int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@announcementSID									int																	-- key of latest login announcement

	begin try

		select top (1)
			@announcementSID = a.AnnouncementSID
		from
			sf.vAnnouncement a
		where
			a.IsActive = @ON
			and
			a.IsLoginAlert = @ON
		order by
			a.EffectiveTime desc

		if @announcementSID is not null or @ForUpdate = @OFF
		begin

			select
				--!<ColumnList DataSource="sf.vAnnouncement" Alias="a">
				 a.AnnouncementSID
				,a.Title
				,a.AnnouncementText
				,a.EffectiveTime
				,a.ExpiryTime
				,a.AdditionalInfoPageURI
				,a.TagList
				,a.IsLoginAlert
				,a.IsExtendedFormat
				,a.UserDefinedColumns
				,a.AnnouncementXID
				,a.LegacyKey
				,a.IsDeleted
				,a.CreateUser
				,a.CreateTime
				,a.UpdateUser
				,a.UpdateTime
				,a.RowGUID
				,a.RowStamp
				,a.IsActive
				,a.IsPending
				,a.IsDeleteEnabled
				,a.IsReselected
				,a.IsNullApplied
				,a.zContext
				,a.IsClearedOrExpired
				,a.IsNew
				,a.ApplicationGrantSCD
					--!</ColumnList>
			from
				sf.vAnnouncement a
			where
				a.AnnouncementSID = @announcementSID

		end
		else if @ForUpdate = @ON
		begin
			exec sf.pAnnouncement#Default																				-- return default record for editing
		end

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
