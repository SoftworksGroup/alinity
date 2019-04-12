SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SyncDataMap]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.SyncDataMap data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (dbo) Payment Status master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Sep		2017    | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.SyncDataMap table with the settings required by the current version of the application. The
setup sproc ensures a record exists for the current list of application entities that support synchronization.  If a record is not
found it is added. If the record is found, however, the existing configuration for it - the synchronization direction (PUSH/PULL)
and whether it is currently enabled - are not changed.  If an extraneous record is found it is deleted.

Example:
--------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
exec dbo.pSetup$SyncDataMap
		@SetupUser = 'system@alinityapp.com'
	,@Language = 'EN'
	,@Region = 'CA'


select
	sdm.ApplicationEntitySID
 ,sdm.SyncMode
 ,sdm.IsDeleteProcessed
 ,sdm.IsEnabled
from
	dbo.SyncDataMap sdm;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SyncDataMap'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int = 0				-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000) -- message text (for business rule errors)
	 ,@sourceCount int						-- count of rows in the source table
	 ,@targetCount int;						-- count of rows in the target table

	declare @setup table
	(
		ID									 int				not null identity(1, 1)
	 ,SyncMode						 varchar(4) not null default 'PUSH'
	 ,IsDeleteProcessed		 bit				not null default cast(0 as bit)
	 ,IsEnabled						 bit				not null default cast(0 as bit)
	 ,ApplicationEntitySID int				not null
	);

	begin try

		insert
			@setup (ApplicationEntitySID)
		select
			ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD in 
			(
				 'dbo.Org'
				,'dbo.OrgContact'
				,'dbo.PersonMailingAddress'
				,'dbo.PersonNote'
				,'dbo.RegistrantCredential'
				,'dbo.RegistrantEmployment'
				,'dbo.RegistrantLanguage'
				,'dbo.Registration'
				,'dbo.RegistrantPracticeRestriction'
				,'sf.Person'
				,'sf.PersonOtherName'
			);

		merge dbo.SyncDataMap target
		using
		(
			select
				x.SyncMode
			 ,x.IsDeleteProcessed
			 ,x.IsEnabled
			 ,x.ApplicationEntitySID
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.ApplicationEntitySID = source.ApplicationEntitySID
		when not matched by target then insert
																		(
																			SyncMode
																		 ,IsDeleteProcessed
																		 ,IsEnabled
																		 ,ApplicationEntitySID
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.SyncMode, source.IsDeleteProcessed, source.IsEnabled, source.ApplicationEntitySID, @SetupUser, @SetupUser
																		)
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;

		select @targetCount	 = count(1) from dbo .SyncDataMap;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.SyncDataMap'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
