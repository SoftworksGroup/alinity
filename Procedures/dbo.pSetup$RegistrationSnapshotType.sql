SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$RegistrationSnapshotType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.RegistrationSnapshotType data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.RegistrationSnapshotType table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Jul 2018		|	Initial version
					
Comments  
--------
This procedure synchronizes the dbo.RegistrationSnapshotType table with the settings required by the current version of the 
application. The setup sproc ensures a record exists for each snapshot type supported.  Unique programming is required to 
generate the snapshots. If a record is not found it is added. If an extraneous record is found it is deleted.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$RegistrationSnapshotType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.RegistrationSnapshotType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$RegistrationSnapshotType'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON				 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

	declare @setup table
	(
		ID																int					 identity(1, 1)
	 ,RegistrationSnapshotTypeLabel			nvarchar(35) not null
	 ,RegistrationSnapshotTypeSCD				varchar(15)	 not null
	 ,RegistrationSnapshotLabelTemplate nvarchar(50) null
	 ,IsDefault													bit					 not null
	);

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		insert
			@setup
		(
			RegistrationSnapshotTypeLabel
		 ,RegistrationSnapshotTypeSCD
		 ,RegistrationSnapshotLabelTemplate
		 ,IsDefault
		)
		values
		(
			'CIHI Snapshot', 'CIHI', 'CIHI Snapshot: {DATE}', @ON
		);

		merge dbo.RegistrationSnapshotType target
		using
		(
			select
				x.RegistrationSnapshotTypeSCD
			 ,x.RegistrationSnapshotTypeLabel
			 ,RegistrationSnapshotLabelTemplate
			 ,IsDefault
			from
				@setup x
		) source
		on target.RegistrationSnapshotTypeSCD = source.RegistrationSnapshotTypeSCD
		when not matched by target then
			insert
			(
				RegistrationSnapshotTypeSCD
			 ,RegistrationSnapshotTypeLabel
			 ,RegistrationSnapshotLabelTemplate
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.RegistrationSnapshotTypeSCD, source.RegistrationSnapshotTypeLabel, source.RegistrationSnapshotLabelTemplate, source.IsDefault, @SetupUser
			 ,@SetupUser
			)
		when not matched by source then delete;

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and (@xState = -1 or @xState = 1)
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if (@xState = -1 or @xState = 1) -- full rollback since no previous trx was pending
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
