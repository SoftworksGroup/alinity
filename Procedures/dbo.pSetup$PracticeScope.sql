SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$PracticeScope]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.PracticeScope data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.PracticeScope table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Jun 2018		|	Initial version
					
Comments  
--------
This procedure populates the dbo.PracticeScope table with starting values during the application installation process. The
procedure does not modify the table if any records are found in the table. The procedure only inserts the records where the
table is empty, or, where a default value is not defined.

Records in this table can be added and deleted by end users and the Alinity Service Desk team to meet the requirements of the
client.  The records inserted by the procedure are examples only and may be replaced/modified as required.

Note that a record indicating the scope-of-practice is "NOT APPLICABLE" is required  as the default record by the application.  
This procedure will insert that record and mark it as the default is not already defined.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$PracticeScope 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.PracticeScope

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$PracticeScope'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON				 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

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

		if not exists (select 1 from dbo .PracticeScope)
		begin

			insert
				dbo.PracticeScope (PracticeScopeName, PracticeScopeCode, IsDefault, CreateUser, UpdateUser)
			values
			('Not Applicable', '999', @ON, @SetupUser, @SetupUser)	-- this value IS REQUIRED by the application
			 ,('Administration', '10', @OFF, @SetupUser, @SetupUser)
			 ,('Consulting', '20', @OFF, @SetupUser, @SetupUser)
			 ,('Mentoring', '30', @OFF, @SetupUser, @SetupUser)
			 ,('Research', '40', @OFF, @SetupUser, @SetupUser)
			 ,('Teaching', '50', @OFF, @SetupUser, @SetupUser)
			 ,('Direct Patient Care', '60', @OFF, @SetupUser, @SetupUser)
			 ,('Work Place Committees', '70', @OFF, @SetupUser, @SetupUser)
			 ,('Case Management', '80', @OFF, @SetupUser, @SetupUser)
			 ,('Program Development', '90', @OFF, @SetupUser, @SetupUser)
			 ,('Sales', '100', @OFF, @SetupUser, @SetupUser)
			 ,('Presentation/Speaking', '110', @OFF, @SetupUser, @SetupUser)
			 ,('Public Education', '120', @OFF, @SetupUser, @SetupUser)
			 ,('Other', '130', @OFF, @SetupUser, @SetupUser);

		end;

		-- ensure a default exists for the NA code since this
		-- is required by the application logic

		if not exists (select 1 from dbo .PracticeScope ps where ps.IsDefault = @ON)
		begin

			if not exists (select 1 from dbo .PracticeScope ps where ps.PracticeScopeCode = 'NA')
			begin

				insert
					dbo.PracticeScope (PracticeScopeName, PracticeScopeCode, IsDefault, CreateUser, UpdateUser)
				values
				('Not Applicable', '999', @ON, @SetupUser, @SetupUser);

			end;
			else
			begin

				update
					dbo.PracticeScope
				set
					IsDefault = @ON
				 ,UpdateTime = sysdatetimeoffset()
				 ,UpdateUser = @SetupUser
				where
					PracticeScopeCode = 'NA';

			end;

		end;

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
