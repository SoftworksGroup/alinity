SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$ComplaintType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.ComplaintType data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.ComplaintType table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Cory Ng								| Jan 2019		|	Initial version
					
Comments  
--------
This procedure populates the dbo.ComplaintType table with starting values during the application installation process. The
procedure does not modify the table if any records are found in it.  The procedure only inserts the records where the
table is empty.

Records in this table can be added and deleted by end users and the Alinity Service Desk team to meet the requirements of the
client.  The records inserted by the procedure are examples only and may be replaced/modified as required.

Note that while the client and configurator can manage the records in the table as required, the application does depend
on a default type existing.  This is necessary because the column is a mandatory FK in the dbo.Complaint table. If a 
default record is not found, one is added or assigned as the default.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$ComplaintType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.ComplaintType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$ComplaintType'
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

		if not exists (select 1 from dbo.ComplaintType)
		begin

			insert
				dbo.ComplaintType (ComplaintTypeLabel, ComplaintTypeCategory, Description, IsDefault, CreateUser, UpdateUser)
			values
				('Other misconduct', null, 'Complaint''s not related to either professional or sexual misconduct.', @OFF  ,@SetupUser, @SetupUser)
			 ,('Sexual misconduct', null, 'Complaint''s related to sexual abuse or misconduct with a patient or colleague.', @OFF ,@SetupUser, @SetupUser)
			 ,('Professional incompetence', null,'Complaint''s regarding member''s knowledge or skills related to their practice.', @OFF  ,@SetupUser, @SetupUser)
			 ,('Professional misconduct', null,'Complaint''s related to professional misconduct (eg: tardiness, bullying, profanity).', @OFF  ,@SetupUser, @SetupUser);

		end;

		-- ensure a default exists

		if not exists
		(
			select
				1
			from
				dbo.ComplaintType ct
			where
				ct.IsDefault = @ON and ct.IsActive = @ON
		)
		begin

			update
				dbo.ComplaintType
			set
				IsDefault = @ON
			 ,IsActive = @ON
			 ,UpdateUser = @SetupUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				ComplaintTypeSID =
			(
				select min (x.ComplaintTypeSID) from dbo.ComplaintType x
			);

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
