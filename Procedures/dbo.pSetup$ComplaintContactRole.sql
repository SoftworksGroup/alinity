SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$ComplaintContactRole]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.ComplaintContactRole data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Synchronizes the dbo.ComplaintContactRole table with values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2018		|	Initial version

Comments
--------					
This procedure populates the dbo.ComplaintContactRole table with values required by the application.  The procedure is run on 
installation and on each upgrade.  

Client administrators and configurators can change descriptive column values only on this table.  The set of records required by
the application in the table is fixed.

Note that for this table, the default record is also fixed and will be reset to the expected record whenever this procedure is
executed.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$ComplaintContactRole 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.ComplaintContactRole

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$ComplaintContactRole'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON				 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit)					-- constant for bit comparisons = 0
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

	declare @setup table
	(
		ComplaintContactRoleSCD	 varchar(20)	not null
	 ,ComplaintContactRoleName nvarchar(50) not null
	 ,IsDefault								 bit					not null default cast(0 as bit)
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

		-- populate a table with system-expected values

		insert
			@setup (ComplaintContactRoleSCD, ComplaintContactRoleName, IsDefault)
		values
			('COMPLAINANT', N'Complainant', @ON)
		 ,('MEMBER', N'Investigated member', @OFF)
		 ,('INVESTIGATOR', N'Investigator', @OFF)
		 ,('WITNESS', N'Witness', @OFF)
		 ,('REFERENCE', N'Reference', @OFF);

		merge dbo.ComplaintContactRole target
		using
		(
			select
				x.ComplaintContactRoleSCD
			 ,x.ComplaintContactRoleName
			 ,x.IsDefault
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.ComplaintContactRoleSCD = source.ComplaintContactRoleSCD
		when not matched by target then insert
																		(
																			ComplaintContactRoleSCD
																		 ,ComplaintContactRoleName
																		 ,IsDefault
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.ComplaintContactRoleSCD, source.ComplaintContactRoleName, source.IsDefault, @SetupUser, @SetupUser
																		)
		when matched then update set
												IsDefault = source.IsDefault
											 ,UpdateUser = @SetupUser
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
