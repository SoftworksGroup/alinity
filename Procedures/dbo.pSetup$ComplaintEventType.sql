SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$ComplaintEventType
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.ComplaintEventType data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Synchronizes the dbo.ComplaintEventType table with values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2018		|	Initial version

Comments
--------					
This procedure populates the dbo.ComplaintEventType table with values required by the application.  The procedure is run on 
installation and on each upgrade.  

Client administrators and configurators can change descriptive column values only on this table.  The set of records required by
the application in the table is fixed.


<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$ComplaintEventType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.ComplaintEventType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$ComplaintEventType'
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
		ComplaintEventTypeSCD		varchar(20)	 not null
	 ,ComplaintEventTypeLabel nvarchar(35) not null
	 ,IsDefault								bit					 not null default cast(0 as bit)
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
			@setup (ComplaintEventTypeSCD, ComplaintEventTypeLabel, IsDefault)
		values
			('INVESTIGATION', N'Investigation/Research', @ON)
		 ,('INTERVIEW', N'Interview', @OFF)
		 ,('DOC.REVIEW', N'Documentation Review', @OFF)
		 ,('HEARING', N'Hearing', @OFF)
		 ,('MEDIATION', N'Mediation', @OFF)
		 ,('ARBITRATION', N'Arbitration', @OFF);

		merge dbo.ComplaintEventType target
		using
		(
			select
				x.ComplaintEventTypeSCD
			 ,x.ComplaintEventTypeLabel
			 ,x.IsDefault
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.ComplaintEventTypeSCD = source.ComplaintEventTypeSCD
		when not matched by target then insert
																		(
																			ComplaintEventTypeSCD
																		 ,ComplaintEventTypeLabel
																		 ,IsDefault
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.ComplaintEventTypeSCD, source.ComplaintEventTypeLabel, source.IsDefault, @SetupUser, @SetupUser
																		)
		when matched then update set
											  UpdateUser = @SetupUser
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
